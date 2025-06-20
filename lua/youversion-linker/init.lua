local M = {}

M.core = require("youversion-linker.core")
local menu = require("youversion-linker.menu")

M.setup = function(user_config)
  menu.create_and_show_popup_menu(user_config)
end

return M
