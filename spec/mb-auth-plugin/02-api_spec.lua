local cjson = require "cjson"
local helpers = require "spec.helpers"

for _, strategy in helpers.each_strategy() do
  describe("Plugin: mb-auth-plugin (API) [#" .. strategy .. "]", function()
    local consumer
    local admin_client
    local bp
    local db

    lazy_setup(function()
      bp, db = helpers.get_db_utils(strategy, {
        "routes",
        "services",
        "plugins",
        "consumers",
        "mbbasicauth_credentials",
      }, {"mb-auth-plugin"})

      assert(helpers.start_kong({
        database = strategy,
        plugins  = "bundled,mb-auth-plugin",
      }))
    end)
    lazy_teardown(function()
      helpers.stop_kong()
    end)

    before_each(function()
      admin_client = helpers.admin_client()
    end)

    after_each(function()
      if admin_client then admin_client:close() end
    end)

    describe("/consumers/:consumer/mb-auth-plugin/", function()
      lazy_setup(function()
        consumer = bp.consumers:insert {
          username = "bob"
        }
        bp.consumers:insert {
          username = "nancy"
        }
      end)
      after_each(function()
        db:truncate("mbbasicauth_credentials")
      end)

      describe("POST", function()
        it("creates a mb-auth-plugin credential", function()
          local res = assert(admin_client:send {
            method = "POST",
            path = "/consumers/bob/mb-auth-plugin",
            body = {
              username = "bob",
              password = "kong"
            },
            headers = {
              ["Content-Type"] = "application/json"
            }
          })
          local body = assert.res_status(201, res)
          local json = cjson.decode(body)
          assert.equal(consumer.id, json.consumer.id)
          assert.equal("bob", json.username)
          assert.equal("kong", json.password)
        end)
        describe("errors", function()
          it("returns bad request", function()
            local res = assert(admin_client:send {
              method = "POST",
              path = "/consumers/bob/mb-auth-plugin",
              body = {},
              headers = {
                ["Content-Type"] = "application/json"
              }
            })
            local body = assert.res_status(400, res)
            local json = cjson.decode(body)
            assert.same({ password = "required field missing", username = "required field missing" }, json.fields)
          end)
          it("can use identical usernames", function()
            local res = assert(admin_client:send {
              method = "POST",
              path = "/consumers/bob/mb-auth-plugin",
              body = {
                username = "bob",
                password = "kong"
              },
              headers = {
                ["Content-Type"] = "application/json"
              }
            })

            assert.res_status(201, res)

            local res = assert(admin_client:send {
              method = "POST",
              path = "/consumers/nancy/mb-auth-plugin",
              body = {
                username = "bob",
                password = "kong2"
              },
              headers = {
                ["Content-Type"] = "application/json"
              }
            })
            assert.res_status(201, res)
          end)
        end)
      end)

      describe("GET", function()
        lazy_setup(function()
          assert(db.mbbasicauth_credentials:insert {
            username = "bob",
            password = "kong",
            consumer = { id = consumer.id },
          })
        end)
        lazy_teardown(function()
          db:truncate("mbbasicauth_credentials")
        end)
        it("retrieves the first page", function()
          local res = assert(admin_client:send {
            method = "GET",
            path = "/consumers/bob/mb-auth-plugin"
          })
          local body = assert.res_status(200, res)
          local json = cjson.decode(body)
          assert.is_table(json.data)
          assert.equal(1, #json.data)
        end)
      end)
    end)

    describe("/consumers/:consumer/mb-auth-plugin/:id", function()
      local credential
      before_each(function()
        db:truncate("mbbasicauth_credentials")
        credential = assert(db.mbbasicauth_credentials:insert {
          username = "bob",
          password = "kong",
          consumer = { id = consumer.id },
        })
      end)
      describe("GET", function()
        it("retrieves basic-auth credential by id", function()
          local res = assert(admin_client:send {
            method = "GET",
            path = "/consumers/bob/mb-auth-plugin/" .. credential.id
          })
          local body = assert.res_status(200, res)
          local json = cjson.decode(body)
          assert.equal(credential.id, json.id)
        end)
        it("retrieves credential by id only if the credential belongs to the specified consumer", function()
          bp.consumers:insert {
            username = "alice"
          }

          local res = assert(admin_client:send {
            method = "GET",
            path = "/consumers/bob/mb-auth-plugin/" .. credential.id
          })
          assert.res_status(200, res)

          res = assert(admin_client:send {
            method = "GET",
            path = "/consumers/alice/mb-auth-plugin/" .. credential.id
          })
          assert.res_status(404, res)
        end)
      end)

      describe("PATCH", function()
        it("updates a credential by id", function()

          local res = assert(admin_client:send {
            method = "PATCH",
            path = "/consumers/bob/mb-auth-plugin/" .. credential.id,
            body = {
              password = "4321"
            },
            headers = {
              ["Content-Type"] = "application/json"
            }
          })
          local body = assert.res_status(200, res)
          local json = cjson.decode(body)
          assert.equal("4321", json.password)
        end)
        describe("errors", function()
          it("handles invalid input", function()
            local res = assert(admin_client:send {
              method = "PATCH",
              path = "/consumers/bob/mb-auth-plugin/" .. credential.id,
              body = {
                password = 123
              },
              headers = {
                ["Content-Type"] = "application/json"
              }
            })
            local body = assert.res_status(400, res)
            local json = cjson.decode(body)
            assert.same({ password = "expected a string" }, json.fields)
          end)
        end)
      end)

      describe("DELETE", function()
        it("deletes a credential", function()
          local res = assert(admin_client:send {
            method = "DELETE",
            path = "/consumers/bob/mb-auth-plugin/" .. credential.id,
          })
          assert.res_status(204, res)
        end)
        describe("errors", function()
          it("returns 404 if not found", function()
            local res = assert(admin_client:send {
              method = "DELETE",
              path = "/consumers/bob/mb-auth-plugin/00000000-0000-0000-0000-000000000000"
            })
            assert.res_status(404, res)
          end)
        end)
      end)
    end)
  end)
end