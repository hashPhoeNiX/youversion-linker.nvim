local M = {}

local Menu = require("nui.menu")
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event
local config = require("youversion-linker.config")
local parser = require("youversion-linker.parser")
local menu_module = require("youversion-linker.menu")
local replacer = require("youversion-linker.replacer")
local cursor = require("youversion-linker.cursor")
local autocmd = require("youversion-linker.autocmd")
local core = require("youversion-linker.core")
local api = vim.api

local current_menu = nil
local current_popup = nil
local bible_passages_cache = {} -- Cache for pre-fetched passages
local current_selected_id = 1   -- Track currently selected menu item ID

local function close_current_menu()
  -- vim.notify("Cleaning up existing popups", vim.log.levels.DEBUG)
  if current_menu then
    current_menu:unmount()
    current_menu = nil
  end
  if current_popup then
    current_popup:unmount()
    current_popup = nil
  end
  bible_passages_cache = {} -- Clear cache when menu closes
  current_selected_id = 1   -- Reset selected ID
end

M.get_config = function(user_config)
  local config_opts = config.get_config(user_config)
  return config_opts
end

-- Asynchronous Bible passage fetcher
local function fetch_bible_passage_async(result, item, item_id, callback)
  vim.schedule(function()
    local extracted_reference = result.extracted_reference
    if not extracted_reference then
      extracted_reference = parser.extract_bible_reference(item.text)
    end

    if extracted_reference and extracted_reference.book then
      local bible_ref = (extracted_reference.book or result.trigger_text) ..
          " " .. (extracted_reference.chapter_verse_range or "")

      local version = item.text:match("([^%s]+)$") -- Extract version (last word)

      local success, bible_text = pcall(function()
        local core_result = core.main(bible_ref, version)
        return core_result and core_result.verses or nil
      end)

      local passage_data
      if success and bible_text then
        passage_data = {
          text = bible_text,
          reference = item.text,
          loaded = true
        }
        vim.notify("✓ Loaded: " .. item.text, vim.log.levels.DEBUG)
      else
        passage_data = {
          text = "Error fetching Bible text for " .. bible_ref .. " (" .. version .. ")",
          reference = item.text,
          loaded = true,
          error = true
        }
        vim.notify("✗ Failed: " .. item.text, vim.log.levels.WARN)
      end

      callback(item_id, passage_data)
    else
      callback(item_id, {
        text = "Could not parse Bible reference",
        reference = item.text,
        loaded = true,
        error = true
      })
    end
  end)
end

-- Initialize cache with loading placeholders and start async fetching
local function initialize_bible_passages_async(result, menu_items, bible_passage_popup)
  -- Initialize cache with loading placeholders
  for i, item in ipairs(menu_items) do
    bible_passages_cache[i] = {
      text = "Loading Bible passage...",
      reference = item.text,
      loaded = false
    }
  end

  local total_items = #menu_items
  local loaded_count = 0

  vim.notify("Loading Bible passages for " .. total_items .. " versions...", vim.log.levels.INFO)

  -- Callback function for when each passage is fetched
  local function on_passage_loaded(item_id, passage_data)
    bible_passages_cache[item_id] = passage_data
    loaded_count = loaded_count + 1

    -- Update popup if this is the currently selected item
    if current_menu and current_popup and current_selected_id == item_id then
      M.update_bible_passage_popup(bible_passage_popup, bible_passages_cache, item_id)
    end

    -- Show progress notification
    if loaded_count == total_items then
      local error_count = 0
      for _, passage in pairs(bible_passages_cache) do
        if passage.error then
          error_count = error_count + 1
        end
      end

      if error_count == 0 then
        vim.notify("✓ All Bible passages loaded successfully!", vim.log.levels.INFO)
      else
        vim.notify(string.format("✓ Bible passages loaded (%d successful, %d failed)",
          total_items - error_count, error_count), vim.log.levels.INFO)
      end
    elseif loaded_count % 3 == 0 then -- Show progress every 3 items
      vim.notify(string.format("Loading... %d/%d", loaded_count, total_items), vim.log.levels.DEBUG)
    end
  end

  -- Start async fetching for all items
  for i, item in ipairs(menu_items) do
    -- Add small delays between requests to avoid overwhelming the API
    -- vim.defer_fn(function()
    fetch_bible_passage_async(result, item, i, on_passage_loaded)
    -- end, (i - 1) * 10) -- 10ms delay between each request
  end
end

-- Updated function to use cached passages (handles loading states)
M.update_bible_passage_popup = function(bible_passage_popup, bible_passages, item_id)
  if not bible_passage_popup or not bible_passage_popup.winid or not vim.api.nvim_win_is_valid(bible_passage_popup.winid) then
    return
  end

  local passage_data = bible_passages[item_id]
  if not passage_data then
    vim.notify("No passage data found for ID: " .. tostring(item_id), vim.log.levels.ERROR)
    return
  end

  local lines = { passage_data.reference, passage_data.text }

  -- Add loading indicator if still loading
  if not passage_data.loaded then
    lines[2] = passage_data.text .. " ⏳"
  end

  -- Set the 'modifiable' option to true
  vim.api.nvim_set_option_value('modifiable', true, { buf = bible_passage_popup.bufnr })

  -- Set the lines of the buffer
  vim.api.nvim_buf_set_lines(bible_passage_popup.bufnr, 0, -1, false, lines)

  -- Set the 'modifiable' option to false
  vim.api.nvim_set_option_value('modifiable', false, { buf = bible_passage_popup.bufnr })
end

M.create_and_show_popup_menu = function(user_config)
  local result = cursor.get_current_line(user_config)
  if result then
    local trigger_text = result.trigger_text
    if not result.extracted_reference then
      vim.notify("Bible reference not found for " .. trigger_text, vim.log.levels.WARN)
      return
    end
    local displayBook = result.displayBook or trigger_text

    local config_options = M.get_config(user_config)
    local menu_options = config_options.menu_options
    local popup_options = config_options.popup_options

    local menu_items = menu_module.create_menu_items(result)

    if #menu_items == 0 then
      vim.notify("No enabled Bible versions found", vim.log.levels.WARN)
      return
    end

    local items = {}
    for i, item in ipairs(menu_items) do
      table.insert(items, Menu.item(item.text, { id = i }))
    end

    local bible_passage_popup = Popup(popup_options)

    -- Initialize async fetching (this sets up loading placeholders immediately)
    initialize_bible_passages_async(result, menu_items, bible_passage_popup)

    local menu = Menu(menu_options, {
      lines = items,
      max_width = math.max(50, #trigger_text + #displayBook + 20), -- bible passage + display book + version lengths
      keymap = {
        focus_next = { "j", "<Down>", "<Tab>" },
        focus_prev = { "k", "<Up>", "<S-Tab>" },
        close = { "<Esc>", "<C-c>" },
        submit = { "<CR>", "<Space>" },
      },
      on_close = function()
        vim.notify("Menu closed", vim.log.levels.INFO)
        current_menu = nil -- clear when menu is closed
        current_popup = nil

        pcall(vim.keymap.del, { 'i', 'n' }, "<S-Tab>")
      end,
      on_submit = function(item)
        vim.notify("Selected: " .. item.text, vim.log.levels.INFO)
        local extracted_reference = result.extracted_reference
        if not extracted_reference then
          extracted_reference = parser.extract_bible_reference(item.text)
          if not extracted_reference then
            vim.notify("Could not parse Bible reference", vim.log.levels.ERROR)
            return
          end
        end
        local bible_ref = extracted_reference.book .. " " .. extracted_reference.chapter_verse_range
        local version = item.text:match("([^%s]+)$") -- Extract version (last word)
        replacer.replace_line_with_bible_verse(result, bible_ref, item.text, version)
        current_menu = nil                           -- clear reference after submission
        current_popup = nil

        pcall(vim.keymap.del, { 'i', 'n' }, "<S-Tab>")
      end,
      on_change = function(item, node)
        -- Track the currently selected item ID
        current_selected_id = item.id
        M.update_bible_passage_popup(bible_passage_popup, bible_passages_cache, item.id)
      end,
    })

    current_menu = menu
    current_popup = bible_passage_popup

    menu:mount()
    bible_passage_popup:mount()

    -- Show the first Bible passage initially
    if bible_passages_cache[1] then
      M.update_bible_passage_popup(bible_passage_popup, bible_passages_cache, 1)
    end

    vim.keymap.set({ "i", "n" }, "<S-Tab>", function()
      if current_menu and current_menu.winid then
        vim.schedule(function()
          vim.cmd("stopinsert") -- force exit insert mode first
          pcall(vim.api.nvim_set_current_win, current_menu.winid)
        end)
      else
        vim.notify("Popup menu is not active", vim.log.levels.WARN)
      end
    end, { desc = "Focus Bible version menu", buffer = true })

    menu:on(event.BufLeave, function()
      menu:unmount()
      bible_passage_popup:unmount()
      current_menu = nil
      current_popup = nil
      pcall(vim.keymap.del, 'i', "<S-Tab>")
    end)
  else
    vim.notify("No trigger with Bible verse text detected", vim.log.levels.INFO)
  end
end

M.setup_trigger = function(user_config)
  autocmd.setup_trigger(user_config, M.create_and_show_popup_menu, close_current_menu)
end

M.trigger_manual = function(user_config)
  close_current_menu()
  M.create_and_show_popup_menu(user_config)
end

return M
