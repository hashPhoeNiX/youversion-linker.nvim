local M = {}

local parser = require("youversion-linker.parser")
local api = vim.api

M.setup_trigger = function(user_config, create_and_show_popup_menu, close_current_menu_fn)
  local debounce_timer = nil

  api.nvim_create_autocmd("TextChangedI",{
    pattern = "*",
    callback = function()
      if debounce_timer then
        vim.fn.timer_stop(debounce_timer)
        debounce_timer = nil
      end

      local line = api.nvim_get_current_line()
      local _, col = unpack(api.nvim_win_get_cursor(0))

      local trigger_info = parser.find_trigger_and_text(line, col)
      if trigger_info.has_trigger and #trigger_info.trigger_text > 0 then
        close_current_menu_fn() -- close existing menu
        debounce_timer = vim.fn.timer_start(200, function()
          debounce_timer = nil
          
          local current_line = api.nvim_get_current_line()
          local _, current_col = unpack(api.nvim_win_get_cursor(0))
          local current_trigger_info = parser.find_trigger_and_text(current_line, current_col)
          
          if current_trigger_info.has_trigger and #current_trigger_info.trigger_text > 0 then
            create_and_show_popup_menu(user_config)
          end
        end)
      else
        close_current_menu_fn() --close menu if there's no trigger
      end
    end
  })
end

return M
