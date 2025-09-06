---@class YouVersionLinkerAutocmd
local M = {}


-- local parser = require("youversion-linker.parser")
local api = vim.api

---@param user_config YouVersionLinkerConfig
---@param create_and_show_popup_menu function
---@param close_current_menu_fn function
M.setup_trigger = function(user_config, create_and_show_popup_menu, close_current_menu_fn)
  local debounce_timer = nil
  -- if not user_config.filetypes then
  --   vim.notify("Filetypes not provided " .. vim.inspect(user_config.filetypes), vim.log.levels.WARN)
  -- end

  api.nvim_create_augroup('YouVersionLinker', {
    clear = true,
  })

  api.nvim_create_autocmd({ "TextChangedI", "FileType" }, {
    group = "YouVersionLinker",
    pattern = user_config.filetypes or { "*.md", "*.txt" },
    callback = function()
      if debounce_timer then
        vim.fn.timer_stop(debounce_timer)
        debounce_timer = nil
      end

      -- local cursor_pos = api.nvim_win_get_cursor(0)
      -- local line = api.nvim_get_current_line()
      -- local row, col = cursor_pos[1], cursor_pos[2]

      local ok, trigger_info = pcall(
        function()
          local cursor_pos = api.nvim_win_get_cursor(0)
          local line = api.nvim_get_current_line()
          local row, col = cursor_pos[1], cursor_pos[2]
          return require("youversion-linker.parser").find_trigger_and_text(line, col)
        end
      )
      if not ok then
        vim.notify("Parser error: " .. tostring(trigger_info), vim.log.levels.ERROR)
        -- return
      end

      if trigger_info.has_trigger and #trigger_info.trigger_text > 0 then
        close_current_menu_fn() -- close existing menu

        debounce_timer = vim.fn.timer_start(user_config.debounce_delay, function()
          debounce_timer = nil

          local current_cursor_pos = api.nvim_win_get_cursor(0)
          if not current_cursor_pos or #current_cursor_pos < 2 then
            return
          end

          local current_line = api.nvim_get_current_line()
          local current_row, current_col = current_cursor_pos[1], current_cursor_pos[2]

          local current_ok, current_trigger_info = pcall(require("youversion-linker.parser").find_trigger_and_text,
            current_line, current_col)
          if not current_ok then
            vim.notify("Parser error on re-check: " .. tostring(current_trigger_info), vim.log.levels.ERROR)
            -- return
          end

          if current_trigger_info and current_trigger_info.has_trigger and
              current_trigger_info.trigger_text and #current_trigger_info.trigger_text > 0 then
            local menu_ok, menu_err = pcall(create_and_show_popup_menu, user_config)
            if not menu_ok then
              vim.notify("Menu creation error: " .. tostring(menu_err), vim.log.levels.ERROR)
            end
            -- create_and_show_popup_menu(user_config)
          end
        end)
      else
        close_current_menu_fn() --close menu if there's no trigger
      end
    end
  })
end
return M
