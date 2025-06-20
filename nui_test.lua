local Menu = require("nui.menu")
local event = require("nui.utils.autocmd").event

local plugin = require("youversion-linker")
local pl = require("pl.pretty")

-- local insert_verse = require("test_insert_verse")
local buf = 0
local api = vim.api
local line = api.nvim_get_current_line()
local line_number, col = unpack(api.nvim_win_get_cursor(buf))
local row = line_number - 1 -- row based

local before = line:sub(1, col + 1) -- Get prefix of the cursor position
local after = line:sub(col + 2, -1) -- Get suffix of the cursor position
local trigger = line:sub(col+1, col+1)

print(trigger .. after)

local function replace_line_with_bible_verse(after, item_text, version)
  -- local line = api.nvim_get_current_line()
  -- local line_number, col = unpack(api.nvim_win_get_cursor(buf))
  -- local row = line_number - 1 -- row based

  -- local before = line:sub(1, col + 1) -- Get prefix of the cursor position
  -- local after = line:sub(col + 2, -1) -- Get suffix of the cursor position

  local result = plugin.core.main(after, version)

  api.nvim_buf_set_lines(
    buf,
    line_number - 1, line_number,
    false,
    { "--[[", item_text, result.verses, "]]"}
  )
end

function extractBibleReference(text)
  local book_name, chapter_verse_range = text:match("^([%a%s]+)%s(%d+:%d+[%-%d]*)" )

  if book_name and chapter_verse_range then
    return book_name .. " " .. chapter_verse_range
  else
    return nil -- Return nil if the pattern doesn't match
  end
end

local popup_options = {
  relative = "cursor",
  position = {
    row = 1,
    col = #after + 3,
  },
  size = {
    width = 25,
    height = 5,
  },
  border = {
    style = "rounded",
    text = {
      top = "[Bible Versions]",
      top_align = "center",
    },
  },
  win_options = {
    winhighlight = "Normal:Normal",
  }
}

local items = {}

local displayBook = plugin.core.lookup.getBook(after:match("^%s*([%S]+)")) -- match first word
local bible_versions = plugin.core.get_bible_versions()
for version, opt in pairs(bible_versions) do
  if opt.enabled then
    local display_text = string.format("%s %s - %s", after, displayBook, version)

    table.insert(items, 
      Menu.item(display_text)
    )
  end
end

-- pl.dump(items)

local menu = Menu(popup_options, {
  lines = items,
  -- lines = {
  --   Menu.item(after .. " KJV"),
  --   Menu.item(after .. " NKJV"),
  --   Menu.item(after .. " NIV"),
  --   Menu.item(after .. " AMP"),
  -- },
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
    replace_line_with_bible_verse(extractBibleReference(item.text), item.text, item.text:match("([^%s]+)$")) -- match last word
  end
})

menu:mount()

menu:on(event.InsertCharPre, function()
  local typed_char = vim.v.char

  if typed_char == "@" then
    print("Typed a trigger symbol!")
  end
end)

-- @John 3:16-18

-- @John 3:16-18
-- @
