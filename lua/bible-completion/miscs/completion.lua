-- completion.lua
local parser = require("nui.bible-completion.bible.parser")
local popup = require("nui.bible-completion.ui.popup")
local menu = require("nui.bible-completion.ui.menu")
local state = require("nui.bible-completion.state")
local config = require("nui.bible-completion.config")

local M = {}

-- Streamlined completion item generation
M.get_completion_items = function(biblePassage, bibleResult)
  return popup.get_completion_items(biblePassage, bibleResult)
end

-- NEW: Get completion items from trigger text
M.get_trigger_completion_items = function(trigger_text)
  -- Parse the trigger text as a Bible reference
  local bible_result = parser.parse_trigger_text(trigger_text)
  
  if not bible_result then
    return {}
  end
  
  return popup.get_completion_items(bible_result.book, bible_result)
end

-- FIXED: More efficient popup repositioning
M.update_popup_position = function()
  print("DEBUG: update_popup_position called.")
  if not state.get_current_menu() or not state.get_last_reference() then
    print("DEBUG: update_popup_position: No current menu or last reference. Returning.")
    return
  end
  
  local current_line = vim.api.nvim_get_current_line()
  local current_pos = vim.api.nvim_win_get_cursor(0)
  
  -- FIXED: More lenient cursor movement detection
  if state.get_last_cursor_pos() and 
     state.get_last_cursor_pos()[1] == current_pos[1] and 
     math.abs(state.get_last_cursor_pos()[2] - current_pos[2]) < 1 then
    return -- No movement
  end
  
  state.set_last_cursor_pos(current_pos)
  
  -- Re-detect reference position in current line
  local bibleResult = parser.get_bible_passage(current_line, current_pos[2])
  
  -- FIXED: Check if bibleResult is nil before accessing its properties
  if not bibleResult then
    state.cleanup_state()
    return
  end
  
  local biblePassage = bibleResult.book
  local biblePassageURL = bibleResult.bible_url
  
  if not biblePassage then
    state.cleanup_state()
    return
  end
  
  -- FIXED: Recreate menu instead of trying to reposition
  -- This is more reliable than trying to reposition NUI components
  if biblePassage ~= state.get_last_reference() then
    state.cleanup_state()
    -- Trigger new menu creation
    vim.schedule(function()
      M.show_inline_completion_menu(current_line, current_pos[2] + 1)
    end)
    return
  end
  
  -- FIXED: For same reference, try gentle repositioning
  local pos = menu.calculate_popup_position(current_line, biblePassage, bibleResult, current_pos[2])
  
  local current_menu = state.get_current_menu()
  if current_menu and current_menu.winid and vim.api.nvim_win_is_valid(current_menu.winid) then
    local success = pcall(vim.api.nvim_win_set_config, current_menu.winid, {
      relative = "cursor",
      row = pos.row,
      col = pos.col,
      width = pos.width,
      height = pos.height,
    })
    
    if not success then
      -- If repositioning fails, recreate the menu
      state.cleanup_state()
      vim.schedule(function()
        M.show_inline_completion_menu(current_line, current_pos[2] + 1)
      end)
    end
  end
end

-- NEW: Show completion menu for @ trigger
M.show_trigger_completion_menu = function(line, col, trigger_text, at_pos)
  local cursor_col = col and (col - 1) or vim.api.nvim_win_get_cursor(0)[2]
  
  -- Parse the trigger text
  local bible_result = parser.parse_trigger_text(trigger_text)
  
  if not bible_result then
    state.cleanup_state()
    return
  end
  
  print("Trigger completion for:", trigger_text)
  -- print(bible_result)
  
  local biblePassage = bible_result.book
  local biblePassageURL = bible_result.bible_url
  
  if not biblePassage then
    state.cleanup_state()
    return
  end
  
  -- Get completion items
  local completion_items = M.get_completion_items(biblePassage, bible_result)
  if #completion_items == 0 then
    state.cleanup_state()
    return
  end
  
  state.cleanup_state()
  state.set_last_reference(biblePassage)
  state.set_last_cursor_pos(vim.api.nvim_win_get_cursor(0))
  
  -- Store trigger information for replacement
  state.set_trigger_info({
    at_pos = at_pos,
    trigger_text = trigger_text,
    replacement_start = at_pos - 1, -- 0-indexed for vim.api calls
    replacement_end = cursor_col
  })
  
  menu.create_and_show_trigger_menu(line, biblePassage, cursor_col, completion_items, M.update_popup_position)
end

-- FIXED: Complete rewrite with better positioning logic
M.show_inline_completion_menu = function(line, col)
  local cursor_col = col and (col - 1) or vim.api.nvim_win_get_cursor(0)[2]
  local bible_result = parser.get_bible_passage(line, cursor_col)
  
  -- FIXED: Check if bible_result is nil before proceeding
  if not bible_result then
    state.cleanup_state()
    return
  end
  
  -- print(bible_result)
  local biblePassage = bible_result.book
  local biblePassageURL = bible_result.bible_url
  
  if not biblePassage then
    state.cleanup_state()
    return
  end
  
  -- FIXED: Always recreate menu for cursor-dependent positioning
  local completion_items = M.get_completion_items(biblePassage, bible_result)
  if #completion_items == 0 then
    state.cleanup_state()
    return
  end
  
  state.cleanup_state()
  state.set_last_reference(biblePassage)
  state.set_last_cursor_pos(vim.api.nvim_win_get_cursor(0))
  
  menu.create_and_show_menu(line, biblePassage, bible_result, cursor_col, completion_items, M.update_popup_position)
end

return M
