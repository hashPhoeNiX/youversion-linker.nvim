local state = require("nui.bible-completion.state")

local M = {}

M.setup_temp_keymaps = function(menu_items, update_position_callback)
  -- Set up keymaps with proper menu selection handling
  local main_buf = vim.api.nvim_get_current_buf()
  
  local function setup_temp_keymap(mode, key, action)
    vim.keymap.set(mode, key, action, {
      buffer = main_buf,
      nowait = true,
      silent = true,
    })
    state.add_temp_keymap({mode, key, main_buf})
  end
  
  -- Selection handling
  local current_selection = 1
  local max_items = #menu_items
  
  local function update_selection(direction)
    if not state.get_current_menu() then return end
    
    if direction == "next" then
      current_selection = current_selection < max_items and current_selection + 1 or 1
    elseif direction == "prev" then
      current_selection = current_selection > 1 and current_selection - 1 or max_items
    end
    
    local menu_win = state.get_current_menu().winid
    if menu_win and vim.api.nvim_win_is_valid(menu_win) then
      vim.api.nvim_win_set_cursor(menu_win, {current_selection, 0})
    end
  end
  
  local function submit_current_selection()
    if not state.get_current_menu() then return end
    
    local selected_item = menu_items[current_selection]
    if selected_item and selected_item.value then
      vim.schedule(function()
        local current_line = vim.api.nvim_get_current_line()
        local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
        
        local new_line = current_line:gsub(
          vim.pesc(state.get_last_reference()),
          selected_item.value,
          1
        )
        
        vim.api.nvim_set_current_line(new_line)
        
        local new_col = cursor_col + #selected_item.value - #state.get_last_reference()
        vim.api.nvim_win_set_cursor(0, {cursor_row, math.max(0, new_col)})
        
        state.cleanup_state()
      end)
    end
  end
  
  -- Set up navigation keymaps
  setup_temp_keymap('i', '<C-n>', function() update_selection("next") end)
  setup_temp_keymap('i', '<C-p>', function() update_selection("prev") end)
   -- setup_temp_keymap('i', '<CR>', submit_current_selection)
  setup_temp_keymap('i', '<C-y>', function() submit_current_selection() end)
  setup_temp_keymap('i', '<Tab>', function() update_selection("next") end)
  setup_temp_keymap('i', '<S-Tab>', function() update_selection("prev") end)
  setup_temp_keymap('i', '<Esc>', function()
    state.cleanup_state()
    vim.schedule(function()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
    end)
  end)
end

return M
