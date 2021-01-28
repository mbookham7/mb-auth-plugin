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
    ["kong.plugins."..pluginName..".handler"] = "kong/plugins/"..pluginName.."/handler.lua",
    ["kong.plugins."..pluginName..".schema"] = "kong/plugins/"..pluginName.."/schema.lua",
  }
}