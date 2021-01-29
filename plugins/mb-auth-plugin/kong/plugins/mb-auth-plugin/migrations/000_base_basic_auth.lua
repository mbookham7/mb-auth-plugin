return {
    postgres = {
      up = [[
        CREATE TABLE IF NOT EXISTS "mbbasicauth_credentials" (
          "id"           UUID                         PRIMARY KEY,
          "created_at"   TIMESTAMP WITH TIME ZONE     DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'),
          "consumer_id"  UUID                         REFERENCES "consumers" ("id") ON DELETE CASCADE,
          "username"     TEXT                         UNIQUE,
          "password"     TEXT
        );
        DO $$
        BEGIN
          CREATE INDEX IF NOT EXISTS "mbbasicauth_consumer_id_idx" ON "mbbasicauth_credentials" ("consumer_id");
        EXCEPTION WHEN UNDEFINED_COLUMN THEN
          -- Do nothing, accept existing state
        END$$;
      ]],
    },
  
    cassandra = {
      up = [[
        CREATE TABLE IF NOT EXISTS mbbasicauth_credentials (
          id          uuid PRIMARY KEY,
          created_at  timestamp,
          consumer_id uuid,
          password    text,
          username    text
        );
        CREATE INDEX IF NOT EXISTS ON mbbasicauth_credentials(username);
        CREATE INDEX IF NOT EXISTS ON mbbasicauth_credentials(consumer_id);
      ]],
    },
  }