local M = {}

M.core = require("youversion-linker.core")
local menu = require("youversion-linker.menu")

M.setup = function(user_config)
  user_config = user_config or {}
  menu.setup_trigger(user_config)
end

M.manual_trigger = function(user_config)
  menu.trigger_manual(user_config)
end

return M
