local M = {}

local Menu = require("nui.menu")
local event = require("nui.utils.autocmd").event

local pl = require("pl.pretty")
local config = require("youversion-linker.config")
local core = require("youversion-linker.core")

local api = vim.api

local function extract_bible_reference(text)
  local book_name, chapter_verse_range = text:match("^([%a%s]+)%s(%d+:%d+[%-%d]*)" )

  if book_name and chapter_verse_range then
    return { book = book_name, chapter_verse_range = chapter_verse_range }
  else
    -- print(text)
    return nil -- Return nil if the pattern doesn't match
  end
end

-- local function find_trigger_and_text(line, cursor_col)
--   for i = cursor_col, 1, -1 do
--     local char = line:sub(i, i)
--     if char == "@" then
--       local trigger_text = line:sub(i + 1, cursor_col)
--       return {
--         trigger_pos = i,
--         trigger_text = trigger_text,
--         has_trigger = true
--       }
--     elseif char:match("%s") then
--       break
--     end
--   end
--   return { has_trigger = false }
-- end

M.get_current_line = function()
  local buf = 0
  local line = api.nvim_get_current_line()
  local line_number, col = unpack(api.nvim_win_get_cursor(buf))
  local row = line_number - 1 -- row based

  local before = line:sub(1, col + 1) -- Get prefix of the cursor position
  local after = line:sub(col + 2, -1) -- Get suffix of the cursor position
  local trigger = line:sub(col+1, col+1)

  print(trigger .. after)

  if after and after ~= "" then
    local extracted_reference = extract_bible_reference(after)
    if extracted_reference then
      local displayBook = core.lookup.getBook(extracted_reference.book)
      return {
        buf = buf,
        after = after,
        line_number = line_number,
        col = col,
        trigger = trigger,
        displayBook = displayBook,
        bible_versions = core.get_bible_versions(),
        extracted_reference = extracted_reference,
      }
    end
  end
  return nil
end

local function replace_line_with_bible_verse(current_line_result, bible_ref, item_text, version)
  local buf = current_line_result.buf
  local after = current_line_result.after
  local line_number = current_line_result.line_number

  local result = core.main(bible_ref, version)

  api.nvim_buf_set_lines(
    buf,
    line_number - 1, line_number,
    false,
    { "--[[", item_text, result.verses, "]]"}
  )
end



M.get_config = function(user_config)
  local config_opts = config.get_config(user_config)

  return config_opts
end

local function create_menu_items(result)
  -- local result = M.get_current_line()
  local bible_versions = result.bible_versions
  local after = result.after
  local displayBook = result.displayBook

  local items = {}

  for version, opt in pairs(bible_versions) do
    if opt.enabled then
      local display_text = string.format("%s %s - %s", after, displayBook, version)
      table.insert(items, 
        Menu.item(display_text)
      )
    end
  end

  return items
end

-- M.setup_trigger = function(user_config)
--   api.nvim_create_autocmd("TextChangedI",{
--     pattern = "*",
--     callback = function()
--       local line = api.nvim_get_current_line()
--
--   })
-- end

M.create_and_show_popup_menu = function(user_config)
  local result = M.get_current_line()
  if result then
    local after = result.after
    local displayBook = result.displayBook
    local extracted_reference = result.extracted_reference

    local popup_options = M.get_config(user_config).popup_options
    local items = create_menu_items(result)

    local menu = Menu(popup_options, {
      lines = items,
      max_width = #after + #displayBook + 10, -- bible passage + display book + version lengths
      keymap = {
        focus_next = {"j", "<Down>", "<Tab>"},
        focus_prev = {"k", "<Up>", "<S-Tab>"},
        close = {"<Esc>", "<C-c>"},
        submit = {"<CR>", "<Space>"},
      },
      on_close = function()
        print("CLOSED")
      end,
      on_submit = function(item)
        print("SUBMITTED", vim.inspect(item.text))
        -- vim.print(vim.inspect(extractBibleReference(item.text)))

        local bible_ref = extracted_reference.book .. " " .. extracted_reference.chapter_verse_range
        replace_line_with_bible_verse(result, bible_ref, item.text, item.text:match("([^%s]+)$")) -- match last word
      end
    })

    menu:mount()
    menu:on(event.BufLeave, function()
      menu:unmount()
    end)
    -- menu:on(event.InsertCharPre, function()
    --   local typed_char = vim.v.char
    --
    --   if typed_char == "@" then
    --     print("Typed a trigger symbol!")
    --   end
    -- end)

  else
    vim.notify("No bible Verse detected")
  end
end

return M
