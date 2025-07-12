local M = {}

local Menu = require("nui.menu")
local event = require("nui.utils.autocmd").event

local config = require("youversion-linker.config")
local parser = require("youversion-linker.parser")
local menu_module = require("youversion-linker.menu")
local replacer = require("youversion-linker.replacer")
local cursor = require("youversion-linker.cursor")
local autocmd = require("youversion-linker.autocmd")

local api = vim.api

local current_menu = nil

local function close_current_menu()
  current_menu = menu_module.close_current_menu(current_menu)
end

M.get_config = function(user_config)
  local config_opts = config.get_config(user_config)
  return config_opts
end

M.create_and_show_popup_menu = function(user_config)
  local result = cursor.get_current_line()
  if result then
    -- local after = result.after
    local trigger_text = result.trigger_text
    local displayBook = result.displayBook
    -- local extracted_reference = result.extracted_reference

    local popup_options = M.get_config(user_config).popup_options
    local items = menu_module.create_menu_items(result)

    if #items == 0 then
      vim.notify("No enabled Bible versions found", vim.log.levels.WARN)
      return
    end

    local menu = Menu(popup_options, {
      lines = items,
      max_width = math.max(50, #trigger_text + #displayBook + 20), -- bible passage + display book + version lengths
      keymap = {
        focus_next = {"j", "<Down>", "<Tab>"},
        focus_prev = {"k", "<Up>", "<S-Tab>"},
        close = {"<Esc>", "<C-c>"},
        submit = {"<CR>", "<Space>"},
      },
      on_close = function()
        vim.notify("Menu closed", vim.log.levels.INFO)
        current_menu = nil -- clear when menu is closed
        pcall(vim.keymap.del, 'i', "<S-Tab>")
      end,
      on_submit = function(item)
        vim.notify("Selected: " .. item.text, vim.log.levels.INFO)
        -- vim.print(vim.inspect(extractBibleReference(item.text)))
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
        current_menu = nil -- clear reference after submission
        pcall(vim.keymap.del, 'i', "<S-Tab>")
      end
    })

    current_menu = menu

    menu:mount()
    vim.keymap.set("i", "<S-Tab>", function()
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
      current_menu = nil
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
