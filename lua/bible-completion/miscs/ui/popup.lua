local pl = require("pl.pretty")

local state = require("nui.bible-completion.state")
local config = require("nui.bible-completion.config")
local versions = require("nui.bible-completion.bible.versions")
local parser = require("nui.bible-completion.bible.parser")

local M = {}

-- Cache for Bible text to avoid repeated API calls
local bible_text_cache = {}

-- FIXED: Simplified completion items - no more lazy loading here
local function get_completion_items(biblePassage, bibleResult)
  if not biblePassage or biblePassage == "" then
    return {}
  end
  
  local displayBook = bibleResult.display_text or ""
  local items = {}
  
  local bible_versions = versions.get_bible_versions()
  for version, opt in pairs(bible_versions) do
    if opt.enabled then
      -- FIXED: Create simple placeholder items - Bible text will be fetched on selection
      local display_text = string.format("%s %s - %s", biblePassage, displayBook, version)
      
      table.insert(items, {
        text = display_text,
        value = display_text,  -- Use display text as placeholder
        version = version,
      })
    end
  end
  
  return items
end

-- Cache function for when we actually need the text
M.get_bible_text_cached = function(biblePassageURL, version)
  local cache_key = biblePassageURL .. "." .. version
  
  if bible_text_cache[cache_key] then
    return bible_text_cache[cache_key]
  end
  
  local success, bible_text = pcall(parser.get_bible_passage_text, biblePassageURL, version)
  if success and bible_text then
    bible_text_cache[cache_key] = bible_text
    return bible_text
  end
  
  return nil
end

-- FIXED: Improved popup positioning that avoids covering text
M.calculate_popup_position = function(line, biblePassage, bibleResult, cursor_col)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local win_height = vim.api.nvim_win_get_height(0)
  local win_width = vim.api.nvim_win_get_width(0)
  
  -- Calculate popup dimensions
  local completion_items = get_completion_items(biblePassage, bibleResult)
  local user_config = config.get_config()
  local popup_height = math.min(#completion_items + 2, user_config.popup.size.height)
  local popup_width = math.min(user_config.popup.size.width, win_width - 10)
  
  -- Determine vertical position (above or below cursor)
  local lines_below = win_height - cursor_pos[1]
  local show_above = lines_below < popup_height and cursor_pos[1] > popup_height
  local row_offset = show_above and -(popup_height + 1) or 1
  
  -- FIXED: Horizontal positioning to avoid covering the reference
  local col_offset = 0
  
  if state.get_reference_end_col() and cursor_col then
    -- Position popup after the reference text
    local space_after_ref = state.get_reference_end_col() - cursor_col + 3
    if space_after_ref > 0 and space_after_ref < win_width - popup_width then
      col_offset = space_after_ref
    else
      -- If not enough space after, try before the reference
      local space_before_ref = state.get_reference_start_col() - cursor_col - popup_width - 2
      if space_before_ref > -cursor_col then
        col_offset = space_before_ref
      else
        -- Fallback: position at a safe distance from cursor
        col_offset = math.min(10, win_width - popup_width - cursor_col)
      end
    end
  else
    -- Fallback positioning
    col_offset = 5
  end
  
  return {
    row = row_offset,
    col = col_offset,
    width = popup_width,
    height = math.min(#completion_items, user_config.popup.size.height),
  }
end

M.get_completion_items = get_completion_items

-- Clear cache function (optional, for memory management)
M.clear_cache = function()
  bible_text_cache = {}
end

return M
