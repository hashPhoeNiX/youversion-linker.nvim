local M = {}

M.core = require("youversion-linker.core")
local plugin = require("youversion-linker.default")

M.setup = function(user_config)
  user_config = user_config or {}
  plugin.setup_trigger(user_config)
end

M.manual_trigger = function(user_config)
  plugin.trigger_manual(user_config)
end

return M
