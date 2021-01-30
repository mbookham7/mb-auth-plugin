package = "mb-auth-plugin"
version = "0.1.0-1"


supported_platforms = {"linux", "macosx"}
source = {
  url = "http://github.com/mbookham7/mb-auth-plugin",
  tag = "0.1.0"
}

description = {
  summary = "mb-auth-plugin is a basic auth pluging with caching, configrable TTL and JWT in header.",
  homepage = "http://github.com/mbookham7/mb-auth-plugin",
  license = "MIT"
}

dependencies = {
}

local pluginName = "mb-auth-plugin"
build = {
  type = "builtin",
  modules = {
    ["kong.plugins."..pluginName..".handler"] = "handler.lua",
    ["kong.plugins."..pluginName..".schema"] = "schema.lua",
    ["kong.plugins."..pluginName..".access"] = "access.lua",
    ["kong.plugins."..pluginName..".crypto"] = "crypto.lua",
    ["kong.plugins."..pluginName..".daos"] = "daos.lua",
    ["kong.plugins."..pluginName..".api"] = "api.lua",    
    ["kong.plugins."..pluginName..".migrations.init"] = "migrations/init.lua",
    ["kong.plugins."..pluginName..".migrations.000_base_basic_auth"] = "migrations/000_base_basic_auth.lua",
    ["kong.plugins."..pluginName..".migrations.002_130_to_140"] = "migrations/002_130_to_140.lua",
    ["kong.plugins."..pluginName..".migrations.003_200_to_210"] = "migrations/003_200_to_210.lua",
  }
}




