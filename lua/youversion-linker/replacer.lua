local M = {}

local core = require("youversion-linker.core")
local api = vim.api

local function separator_exists(bufnr, separator)
  -- Get all lines from the buffer.
  -- The arguments '0' and '-1' mean from the first line to the last.
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- Loop through each line to check for the separator.
  for _, line in ipairs(lines) do
    if line == separator then
      return true
    end
  end
  return false
end

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

  local trigger_char = current_line_result.trigger_char
  local new_lines
  local new_line_number
  if trigger_char == ">" then
    new_lines = {
      "",
      vim.trim(item_text),
      result.verses,
      "",
    }
    new_line_number = line_number
  elseif trigger_char == '@' then
    new_lines = {
      "[" .. vim.trim(item_text) .. "]" .. "(" .. result.url .. ")",
      ""
    }
    new_line_number = line_number
  elseif trigger_char == '^' then
    local last_line_idx = vim.api.nvim_buf_line_count(buf)
    local separator = "---"

    if separator_exists(buf, separator) then
      separator = ""
    else
      vim.api.nvim_buf_set_lines(buf, last_line_idx, last_line_idx, false, { separator })
      last_line_idx = last_line_idx + 1
    end
    item_text = vim.trim(item_text):gsub("%s", "")
    api.nvim_buf_set_lines(
      buf,
      line_number - 1, line_number,
      false,
      {
        before_trigger .. "[" .. trigger_char .. item_text .. "]",
        ""
      }
    )

    new_lines = {
      "[" ..
      trigger_char ..
      item_text .. "]" .. ": " .. "[" .. item_text .. "]" .. "(" .. result.url .. ")" .. " " .. result.verses,
      ""
    }

    new_line_number = last_line_idx + 1
  else
    vim.notify("No Trigger Character detected!", vim.log.levels.ERROR)
  end

  api.nvim_buf_set_lines(
    buf,
    new_line_number - 1, new_line_number,
    false,
    new_lines
  )
end

return M
