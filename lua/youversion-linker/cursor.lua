local M = {}

local parser = require("youversion-linker.parser")
local core = require("youversion-linker.core")
local api = vim.api

M.get_current_line = function()
  local buf = 0
  local line = api.nvim_get_current_line()
  local line_number, col = unpack(api.nvim_win_get_cursor(buf))
  local row = line_number - 1 -- row based

  local trigger = line:sub(col + 1, col + 1)
  local before = line:sub(1, col + 1) -- Get prefix of the cursor position
  local after = line:sub(col + 2, -1) -- Get suffix of the cursor position

  -- print(trigger .. after)
  local trigger_info = parser.find_trigger_and_text(line, col)

  if not trigger_info.has_trigger then
    return nil
  end

  local trigger_text = trigger_info.trigger_text
  local success, extracted_reference = pcall(parser.extract_bible_reference, trigger_text)
  -- print(extracted_reference)
  if not extracted_reference and not success then
    return {
      buf = buf,
      line = line,
      line_number = line_number,
      col = col,
      trigger_pos = trigger_info.trigger_pos,
      trigger_text = trigger_text,
      displayBook = trigger_text, -- Use typed text as display
      bible_versions = core.get_bible_versions(),
      extracted_reference = nil,
    }
  end

  local displayBook = core.lookup.getBook(extracted_reference.book)
  return {
    buf = buf,
    line = line,
    line_number = line_number,
    col = col,
    trigger_pos = trigger_info.trigger_pos,
    trigger_text = trigger_text,
    displayBook = displayBook,
    bible_versions = core.get_bible_versions(),
    extracted_reference = extracted_reference,
  }
end

return M
