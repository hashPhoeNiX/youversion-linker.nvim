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
end

M.get_config = function(user_config)
  local config_opts = config.get_config(user_config)
  return config_opts
end

M.create_and_update_bible_passage_popup = function(bible_passage_popup, result, items, item_id)
  if not bible_passage_popup or not bible_passage_popup.winid or not vim.api.nvim_win_is_valid(bible_passage_popup.winid) then
    return
  end

  local item = items[item_id]
  if not item then
    vim.notify("No item found for ID: " .. tostring(item_id), vim.log.levels.ERROR)
    return
  end

  local extracted_reference = result.extracted_reference
  if not extracted_reference then
    extracted_reference = parser.extract_bible_reference(item.text)
    if not extracted_reference then
      vim.notify("Could not parse Bible reference", vim.log.levels.ERROR)
      return
    end
  end

  if not extracted_reference.book then
    return
  end

  local bible_ref = (extracted_reference.book or result.trigger_text) ..
      " " .. (extracted_reference.chapter_verse_range or "")

  local version = item.text:match("([^%s]+)$") -- Extract version (last word)
  -- vim.notify("Bible ref: " .. bible_ref .. " Version: " .. version)
  local bible_text
  local success, _result = pcall(function()
    return core.main(bible_ref, version).verses
  end)
  if not success or not _result then
    bible_text = "Error fetching Bible text for " .. bible_ref .. " (" .. version .. ")"
    vim.notify(bible_text, vim.log.levels.ERROR)
  else
    bible_text = _result
  end
  -- vim.notify("Bible text fetched: " .. (bible_text or "nil"), vim.log.levels.DEBUG)

  local lines = { item.text, bible_text or "No text available" }
  -- vim.notify("Setting popup lines: " .. vim.inspect(lines), vim.log.levels.DEBUG)
  -- Set the 'modifiable' option to true
  vim.api.nvim_set_option_value('modifiable', true, { buf = bible_passage_popup.bufnr })

  -- Set the lines of the buffer
  vim.api.nvim_buf_set_lines(bible_passage_popup.bufnr, 0, -1, false, lines)

  -- Set the 'modifiable' option to false
  vim.api.nvim_set_option_value('modifiable', false, { buf = bible_passage_popup.bufnr })

  -- vim.api.nvim_buf_set_option(bible_passage_popup.bufnr, 'modifiable', true)
  -- vim.api.nvim_buf_set_lines(bible_passage_popup.bufnr, 0, -1, false, lines)
  -- vim.api.nvim_buf_set_option(bible_passage_popup.bufnr, 'modifiable', false)
end

M.create_and_show_popup_menu = function(user_config)
  local result = cursor.get_current_line()
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
        -- vim.notify("Menu on_change: item.id = " .. tostring(item.id), vim.log.levels.DEBUG)
        -- vim.notify("Menu on_change: item = " .. vim.inspect(item), vim.log.levels.DEBUG)
        M.create_and_update_bible_passage_popup(bible_passage_popup, result, items, item.id)
      end,
    })

    current_menu = menu
    current_popup = bible_passage_popup

    menu:mount()
    bible_passage_popup:mount()

    if items then
      M.create_and_update_bible_passage_popup(bible_passage_popup, result, items, 1) -- show bible passage of first item initially
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
