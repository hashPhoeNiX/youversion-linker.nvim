local state = require("nui.bible-completion.state")
local config = require("nui.bible-completion.config")
local regex = require("utils.regex_utils")

local M = {}

-- Lazy load completion module to break circular dependency
local function get_completion()
  return require("nui.bible-completion.completion")
end

-- Helper function to extract text after @ symbol
local function extract_trigger_text(line, cursor_col)
  -- Look backwards from cursor to find the @ symbol
  local before_cursor = line:sub(1, cursor_col)
  local at_pos = before_cursor:find("@[^%s]*$")
  
  if at_pos then
    local text_after_at = before_cursor:sub(at_pos + 1) -- Skip the @ symbol
    return text_after_at, at_pos
  end
  
  return nil, nil
end

-- ENHANCED: Better reference completion checking
local function is_reference_ready_for_completion(text)
  if not text or text == "" then
    return false
  end
  
  -- Patterns that suggest a complete or near-complete reference
  local completion_ready_patterns = {
    "%w+%s+%d+:%d+",           -- "John 3:16" - complete
    "%w+%s+%d+:%d+%-%d+",      -- "John 3:16-17" - complete with range
    "%d+%s*%w+%s+%d+:%d+",     -- "1 John 3:16" or "1John 3:16" - complete
    "%w+%s+%d+$",              -- "John 3" - chapter specified, ready for verse
    "%d+%s*%w+%s+%d+$",        -- "1 John 3" - chapter specified
    "%w+%s+%d+:",              -- "John 3:" - user started typing verse
    "%d+%s*%w+%s+%d+:",        -- "1 John 3:" - user started typing verse
  }
  
  for _, pattern in ipairs(completion_ready_patterns) do
    if text:match(pattern) then
      return true
    end
  end
  
  -- Also check if it's a recognized book name with some additional content
  local words = {}
  for word in text:gmatch("%S+") do
    table.insert(words, word)
  end
  
  -- If we have 2+ words and the first looks like a book, might be ready
  if #words >= 2 then
    return true
  end
  
  -- Single word that's long enough might be a book abbreviation ready for completion
  if #words == 1 and #text >= 3 then
    return true
  end
  
  return false
end

-- Helper function to check if we should trigger completion
local function should_trigger_completion(line, cursor_col)
  local user_config = config.get_config()
  
  -- Check for @ trigger first (only if enabled)
  if user_config.enable_trigger then
    local trigger_text, at_pos = extract_trigger_text(line, cursor_col)
    if trigger_text and trigger_text ~= "" then
      -- print("DEBUG: Found trigger text:", trigger_text, "at position:", at_pos)
-- ENHANCED: Only trigger if the reference looks ready for completion
      if is_reference_ready_for_completion(trigger_text) then
        -- print("DEBUG: Found ready trigger text:", trigger_text, "at position:", at_pos)
        return true, "trigger", trigger_text, at_pos
      else
        -- print("DEBUG: Trigger text not ready yet:", trigger_text)
        return false, nil, nil, nil
      end
    end
  end
  
  -- Fallback to automatic Bible reference detection (only if enabled)
  if user_config.enable_auto_detection then
    local success, reference = pcall(regex.detectBibleReference, line)
    if success and reference and reference ~= "" then
      -- print("DEBUG: Found Bible reference:", reference)
-- Additional check: only trigger for complete-looking references
      if is_reference_ready_for_completion(reference) then
        -- print("DEBUG: Found ready Bible reference:", reference)
        return true, "auto", reference, nil
      else
        -- print("DEBUG: Bible reference not ready yet:", reference)
        return false, nil, nil, nil
      end
    end
  end
  
  return false, nil, nil, nil
end

M.setup = function()
  -- print("DEBUG: Setting up autocmds")
  
  -- Clear any existing autocmds
  pcall(vim.api.nvim_del_augroup_by_name, "BibleCompletionMain")
  
  local main_group = vim.api.nvim_create_augroup("BibleCompletionMain", { clear = true })
  
  -- ENHANCED: Create autocmd for text changes with improved debouncing
  vim.api.nvim_create_autocmd("TextChangedI", {
    group = main_group,
    pattern = "*",
    callback = function()
      -- print("DEBUG: TextChangedI triggered")
      
      -- Clear existing timer
      if state.get_debounce_timer() then
        vim.fn.timer_stop(state.get_debounce_timer())
      end
      
      local user_config = config.get_config()
      
      -- ENHANCED: Longer debounce for trigger to allow more typing
      local debounce_time = user_config.debounce_ms
      local line = vim.api.nvim_get_current_line()
      local cursor_pos = vim.api.nvim_win_get_cursor(0)
      
      -- If user is typing a trigger (@), use longer debounce
      local trigger_text, _ = extract_trigger_text(line, cursor_pos[2])
      if trigger_text and not is_reference_ready_for_completion(trigger_text) then
        debounce_time = debounce_time * 2 -- Double the debounce time
      end
      
      -- Create debounced callback
      state.set_debounce_timer(vim.fn.timer_start(debounce_time, function()
        vim.schedule(function() -- Ensure we're in main thread
          local current_line = vim.api.nvim_get_current_line()
          local current_cursor_pos = vim.api.nvim_win_get_cursor(0)
          
          -- print("DEBUG: Checking line:", current_line, "cursor:", current_cursor_pos[2])
          
          local should_trigger, trigger_type, text, at_pos = should_trigger_completion(current_line, current_cursor_pos[2])
          
          if should_trigger then
            -- print("DEBUG: Should trigger completion:", trigger_type, text)
            local completion = get_completion()
            
            if trigger_type == "trigger" then
              completion.show_trigger_completion_menu(current_line, current_cursor_pos[2] + 1, text, at_pos)
            else
              completion.show_inline_completion_menu(current_line, current_cursor_pos[2] + 1)
            end
          else
            -- print("DEBUG: No trigger detected or not ready, cleaning state")
            state.cleanup_state()
          end
        end)
        
        state.set_debounce_timer(nil)
      end))
    end
  })
  
  -- Cleanup on vim exit
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = main_group,
    callback = state.cleanup_state,
  })
  
  -- print("DEBUG: Autocmds setup complete")
end

M.setup_menu_autocmds = function(main_buf, update_position_callback)
  if not state.get_autocmd_group() then
    state.set_autocmd_group(vim.api.nvim_create_augroup("BibleCompletionNUI", { clear = true }))
  end
  
  local user_config = config.get_config()
  
  vim.api.nvim_create_autocmd("CursorMovedI", {
    group = state.get_autocmd_group(),
    buffer = main_buf,
    callback = function()
      if state.get_cursor_move_timer() then
        vim.fn.timer_stop(state.get_cursor_move_timer())
      end
      
      state.set_cursor_move_timer(vim.fn.timer_start(user_config.cursor_debounce_ms, function()
        vim.schedule(function()
          update_position_callback()
        end)
        state.set_cursor_move_timer(nil)
      end))
    end,
  })
  
  vim.api.nvim_create_autocmd(
    { "InsertLeave", "WinLeave", "BufLeave" },
    {
      group = state.get_autocmd_group(),
      buffer = main_buf,
      once = true,
      callback = state.cleanup_state,
    }
  )
end

return M
