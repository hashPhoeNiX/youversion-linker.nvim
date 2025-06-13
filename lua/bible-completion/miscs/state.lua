local M = {}

-- FIXED: Improved state management
local state = {
  current_menu = nil,
  debounce_timer = nil,
  cursor_move_timer = nil,
  last_reference = nil,
  last_cursor_pos = nil,
  reference_start_col = nil,  -- NEW: Track where reference starts
  reference_end_col = nil,    -- NEW: Track where reference ends
  autocmd_group = nil,
  trigger_info = nil,         -- NEW: Trigger information storage
  temp_keymaps = {},
}

-- Clean state management functions
M.cleanup_state = function()
  -- Clean up temporary keymaps
  for _, keymap_info in ipairs(state.temp_keymaps) do
    local mode, key, buffer = keymap_info[1], keymap_info[2], keymap_info[3]
    pcall(vim.keymap.del, mode, key, { buffer = buffer })
  end
  state.temp_keymaps = {}
  
  if state.current_menu then
    state.current_menu:unmount()
    state.current_menu = nil
  end
  
  if state.debounce_timer then
    vim.fn.timer_stop(state.debounce_timer)
    state.debounce_timer = nil
  end
  
  if state.cursor_move_timer then
    vim.fn.timer_stop(state.cursor_move_timer)
    state.cursor_move_timer = nil
  end
  
  state.last_reference = nil
  state.last_cursor_pos = nil
  state.reference_start_col = nil
  state.reference_end_col = nil
  state.trigger_info = nil  -- NEW: Clear trigger info
end

M.get_state = function()
  return {
    has_active_menu = state.current_menu ~= nil,
    last_reference = state.last_reference,
    timer_active = state.debounce_timer ~= nil,
    cursor_timer_active = state.cursor_move_timer ~= nil,
    last_cursor_pos = state.last_cursor_pos,
    reference_start_col = state.reference_start_col,
    reference_end_col = state.reference_end_col,
  }
end

-- Getters and setters for state
M.get_current_menu = function()
  return state.current_menu
end

M.set_current_menu = function(menu)
  state.current_menu = menu
end

M.get_debounce_timer = function()
  return state.debounce_timer
end

M.set_debounce_timer = function(timer)
  state.debounce_timer = timer
end

M.get_cursor_move_timer = function()
  return state.cursor_move_timer
end

M.set_cursor_move_timer = function(timer)
  state.cursor_move_timer = timer
end

M.get_last_reference = function()
  return state.last_reference
end

M.set_last_reference = function(reference)
  state.last_reference = reference
end

M.get_last_cursor_pos = function()
  return state.last_cursor_pos
end

M.set_last_cursor_pos = function(pos)
  state.last_cursor_pos = pos
end

M.get_reference_start_col = function()
  return state.reference_start_col
end

M.set_reference_start_col = function(col)
  state.reference_start_col = col
end

M.get_reference_end_col = function()
  return state.reference_end_col
end

M.set_reference_end_col = function(col)
  state.reference_end_col = col
end

M.get_autocmd_group = function()
  return state.autocmd_group
end

M.set_autocmd_group = function(group)
  state.autocmd_group = group
end

M.get_temp_keymaps = function()
  return state.temp_keymaps
end

M.add_temp_keymap = function(keymap_info)
  table.insert(state.temp_keymaps, keymap_info)
end

M.set_trigger_info = function(info)
  state.trigger_info = info
end

M.get_trigger_info = function()
  return state.trigger_info
end

return M
