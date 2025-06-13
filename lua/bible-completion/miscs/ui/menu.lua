local Menu = require("nui.menu")
local popup = require("nui.bible-completion.ui.popup")
local state = require("nui.bible-completion.state")
local config = require("nui.bible-completion.config")
local keymaps = require("nui.bible-completion.utils.keymaps")
local autocmds = require("nui.bible-completion.utils.autocmds")
local parser = require("nui.bible-completion.bible.parser")

local M = {}

-- Calculate popup position
M.calculate_popup_position = function(line, biblePassage, bibleResult, cursor_col)
  return popup.calculate_popup_position(line, biblePassage, bibleResult, cursor_col)
end

M.create_and_show_menu = function(line, biblePassage, bibleResult, cursor_col, completion_items, update_position_callback)
  -- print("DEBUG: Creating menu with", #completion_items, "items")
  
  if #completion_items == 0 then
    -- print("DEBUG: No completion items, aborting menu creation")
    return
  end
  
  -- Create nui.nvim menu items - FIXED: Store original item data properly
  local menu_items = {}
  for i, item in ipairs(completion_items) do
    table.insert(menu_items, Menu.item(item.text, {
      original_item = item,  -- Store the original item
      index = i 
    }))
  end
  
  -- Calculate position
  local pos = M.calculate_popup_position(line, biblePassage, bibleResult, cursor_col)
  local user_config = config.get_config()
  
  -- print("DEBUG: Menu position:", vim.inspect(pos))
  
  -- Create nui.nvim menu
  local menu = Menu({
    position = {
      row = pos.row,
      col = pos.col,
    },
    size = {
      width = pos.width,
      height = math.min(pos.height, #completion_items),
    },
    relative = "cursor",
    border = user_config.popup.border,
    win_options = user_config.popup.win_options,
    buf_options = user_config.popup.buf_options,
    focusable = true,
    enter = true,
  }, {
    lines = menu_items,
    max_width = pos.width - 4,
    keymap = {
      focus_next = { "j", "<Down>" },
      focus_prev = { "k", "<Up>" },
      close = { "<Esc>", "q", "<C-c>" },
      submit = { "<CR>" },
    },
    on_close = function()
      -- print("DEBUG: Menu closed")
      state.cleanup_state()
    end,
    on_submit = function(item)
      -- print("DEBUG: Menu item submitted:", vim.inspect(item))
      
      -- FIXED: Access the original item data correctly
      local original_item = item.original_item
      if not original_item then
        -- print("DEBUG: No original item found")
        state.cleanup_state()
        return
      end
      
      -- Close the menu immediately
      menu:unmount()
      
      -- FIXED: Fetch Bible text only when selected
      vim.schedule(function()
        local bible_text = nil
        
        -- Only fetch if we don't have the actual Bible text yet
        if original_item.value == original_item.text then
          -- This means we have a placeholder, need to fetch actual text
          local biblePassageURL = bibleResult.bible_url
          local version = original_item.version
          
          -- Show loading message
          -- print("Loading " .. version .. "...")
          
          local success, fetched_text = pcall(parser.get_bible_passage_text, biblePassageURL, version)
          if success and fetched_text then
            bible_text = fetched_text
          else
            bible_text = original_item.text -- Fallback to display text
            -- print("Failed to fetch Bible text for " .. version)
          end
        else
          bible_text = original_item.value
        end
        
        -- Now perform the text replacement
        local current_line = vim.api.nvim_get_current_line()
        local cursor_row, cursor_col_current = unpack(vim.api.nvim_win_get_cursor(0))
        
        local last_reference = state.get_last_reference()
        if not last_reference or last_reference == "" then
          -- print("DEBUG: No last reference found, inserting at cursor")
          local before_cursor = current_line:sub(1, cursor_col_current)
          local after_cursor = current_line:sub(cursor_col_current + 1)
          local new_line = before_cursor .. bible_text .. after_cursor
          
          vim.api.nvim_set_current_line(new_line)
          vim.api.nvim_win_set_cursor(0, {cursor_row, cursor_col_current + #bible_text})
        else
          -- Replace the detected reference
          local ref_start, ref_end = current_line:find(vim.pesc(last_reference), 1, true)
          if ref_start then
            local before_ref = current_line:sub(1, ref_start - 1)
            local after_ref = current_line:sub(ref_end + 1)
            local new_line = before_ref .. bible_text .. after_ref
            
            vim.api.nvim_set_current_line(new_line)
            vim.api.nvim_win_set_cursor(0, {cursor_row, ref_start - 1 + #bible_text})
          else
            -- print("DEBUG: Could not find reference to replace, inserting at cursor")
            local before_cursor = current_line:sub(1, cursor_col_current)
            local after_cursor = current_line:sub(cursor_col_current + 1)
            local new_line = before_cursor .. bible_text .. after_cursor
            
            vim.api.nvim_set_current_line(new_line)
            vim.api.nvim_win_set_cursor(0, {cursor_row, cursor_col_current + #bible_text})
          end
        end
        
        state.cleanup_state()
      end)
    end,
  })
  
  -- Store menu and mount
  state.set_current_menu(menu)
  
  -- Mount menu with error handling
  local mount_success, mount_err = pcall(function()
    menu:mount()
  end)
  
  if not mount_success then
    -- print("DEBUG: Failed to mount menu:", mount_err)
    state.cleanup_state()
    return
  end
  
  -- print("DEBUG: Menu mounted successfully")
  
  -- Set buffer options after mounting
  vim.schedule(function()
    if menu.bufnr and vim.api.nvim_buf_is_valid(menu.bufnr) then
      vim.api.nvim_set_option_value('modifiable', false, { buf = menu.bufnr })
      vim.api.nvim_set_option_value('readonly', true, { buf = menu.bufnr })
      vim.api.nvim_set_option_value('buftype', 'nofile', { buf = menu.bufnr })
    end
  end)
  
  -- Setup keymaps and autocmds
  keymaps.setup_temp_keymaps(menu_items, update_position_callback)
  autocmds.setup_menu_autocmds(vim.api.nvim_get_current_buf(), update_position_callback)
end

-- Create menu specifically for trigger completions
M.create_and_show_trigger_menu = function(line, biblePassage, bibleResult, cursor_col, completion_items, update_callback)
  -- print("DEBUG: Creating trigger menu with", #completion_items, "items")
  
  if #completion_items == 0 then
    -- print("DEBUG: No trigger completion items")
    return
  end
  
  -- Calculate position
  local pos = M.calculate_popup_position(line, biblePassage, bibleResult, cursor_col)
  local user_config = config.get_config()
  
  -- Create menu items for trigger completion - FIXED: Store original data
  local menu_items = {}
  for i, item in ipairs(completion_items) do
    table.insert(menu_items, Menu.item(item.text, {
      original_item = item, -- Store original item data
      index = i
    }))
  end
  
  -- Create the menu
  local menu = Menu({
    position = {
      row = pos.row,
      col = pos.col,
    },
    size = {
      width = pos.width,
      height = math.min(pos.height, #completion_items),
    },
    relative = "cursor",
    border = {
      style = "rounded",
      text = {
        top = " Bible Completion ",
        top_align = "center",
      },
    },
    win_options = user_config.popup.win_options,
    buf_options = user_config.popup.buf_options,
    focusable = true,
    enter = false,
  }, {
    lines = menu_items,
    max_width = pos.width - 4,
    keymap = {
      focus_next = { "j", "<Down>", "<Tab>" },
      focus_prev = { "k", "<Up>", "<S-Tab>" },
      close = { "<Esc>", "<C-c>" },
      submit = { "<CR>", "<Space>" },
    },
    on_close = function()
      -- print("DEBUG: Trigger menu closed")
      state.cleanup_state()
    end,
    on_submit = function(item)
      -- print("DEBUG: Trigger menu item submitted:", vim.inspect(item))
      
      menu:unmount()
      
      vim.schedule(function()
        -- FIXED: Use original item data
        local original_item = item.original_item
        if original_item then
          M.handle_trigger_selection(original_item, bibleResult)
        end
        state.cleanup_state()
      end)
    end,
  })
  
  -- Mount with error handling
  local mount_success, mount_err = pcall(function()
    menu:mount()
  end)
  
  if not mount_success then
    -- print("DEBUG: Failed to mount trigger menu:", mount_err)
    state.cleanup_state()
    return
  end
  
  -- print("DEBUG: Trigger menu mounted successfully")
  state.set_current_menu(menu)
end

-- Handle selection for trigger completions - FIXED: Add lazy loading here too
M.handle_trigger_selection = function(selected_item, bibleResult)
  local trigger_info = state.get_trigger_info()
  if not trigger_info then
    -- print("DEBUG: No trigger info available")
    return
  end
  
  -- print("DEBUG: Handling trigger selection:", vim.inspect(selected_item))
  
  local current_line = vim.api.nvim_get_current_line()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  
  -- FIXED: Fetch Bible text on demand for trigger too
  local replacement_text = nil
  
  if selected_item.value == selected_item.text then
    -- Need to fetch the actual Bible text
    local biblePassageURL = bibleResult.bible_url
    local version = selected_item.version
    
    -- print("Loading " .. version .. "...")
    
    local success, fetched_text = pcall(parser.get_bible_passage_text, biblePassageURL, version)
    if success and fetched_text then
      replacement_text = fetched_text
    else
      replacement_text = selected_item.text -- Fallback
      -- print("Failed to fetch Bible text for " .. version)
    end
  else
    replacement_text = selected_item.value
  end
  
  if replacement_text and trigger_info.replacement_start and trigger_info.replacement_end then
    local before_trigger = current_line:sub(1, trigger_info.replacement_start - 1)
    local after_trigger = current_line:sub(trigger_info.replacement_end + 1)
    local new_line = before_trigger .. replacement_text .. after_trigger
    
    -- Update the line
    vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
    
    -- Position cursor after the inserted text
    local new_cursor_col = trigger_info.replacement_start - 1 + #replacement_text
    vim.api.nvim_win_set_cursor(0, { row, new_cursor_col })
  end
end

return M
