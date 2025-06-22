local M = {}

local core = require("youversion-linker.core")
local api = vim.api

M.replace_line_with_bible_verse = function(current_line_result, bible_ref, item_text, version)
  local buf = current_line_result.buf
  -- local after = current_line_result.after
  local line = current_line_result.line
  local line_number = current_line_result.line_number
  local trigger_pos = current_line_result.trigger_pos
  local col = current_line_result.col

  local result = core.main(bible_ref, version)

  local before_trigger = line:sub(1, trigger_pos - 1)
  local after_cursor = line:sub(col + 1, -1)

  local new_lines = {
    "--[[",
    item_text,
    result.verses,
    "]]",
  }

  api.nvim_buf_set_lines(
    buf,
    line_number - 1, line_number,
    false,
    new_lines
  )
end

return M
