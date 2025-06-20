-- local M = {}

local plugin = require("youversion-linker")
local pl = require("pl.pretty")
local api = vim.api

local buf = 0

local line = api.nvim_get_current_line()
print(line)
local line_number, column_number = unpack(api.nvim_win_get_cursor(0))

local before = line:sub(1, column_number + 1) -- Get prefix of the cursor position
local after = line:sub(column_number + 2, -1) -- Get suffix of the cursor position
--
print("Before: " .. before .. " After: " .. after)

local result = plugin.core.main(after, 'KJV')
--
-- -- api.nvim_buf_set_text(
-- --   0,
-- --   line_number - 1, column_number, -- (start row, column)
-- --   line_number - 1, -1, -- (end row, column)
-- --   {after} -- {}replacement}
-- -- )
-- api.nvim_buf_set_lines(
--   buf,
--   line_number - 1, line_number,
--   false,
--   { "--[[", after, result.verses, "]]"}
-- )
pl.dump(result)
--

-- local function replace_line_with_bible_verse(after)
--   -- local line = api.nvim_get_current_line()
--   local line_number, col = unpack(api.nvim_win_get_cursor(buf))
--   local row = line_number - 1 -- row based
--
--   -- local before = line:sub(1, col + 1) -- Get prefix of the cursor position
--   -- local after = line:sub(col + 2, -1) -- Get suffix of the cursor position
--
--   local result = plugin.core.main(after)
--
--   api.nvim_buf_set_lines(
--     buf,
--     line_number - 1, line_number,
--     false,
--     { "--[[", after, result.verses, "]]"}
--   )
-- end

-- replace_line_with_bible_verse(after)

-- M.replace_line_with_bible_verse = replace_line_with_bible_verse

-- return M

-- @John 3:16-18
-- @John 3:16-18
