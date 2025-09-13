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

local function place_cursor_after_inserted_text(new_line_number, new_lines, inserted_text, buf)
  local win = api.nvim_get_current_win()
  local last_inserted_line_num = new_line_number + #new_lines - 1
  local last_line = api.nvim_buf_get_lines(buf, last_inserted_line_num - 1, last_inserted_line_num, false)[1] or ""
  local col
  if inserted_text and #inserted_text > 0 then
    local idx = last_line:find(inserted_text, 1, true)
    if idx then
      col = idx + (#inserted_text - 2) -- place cursor after inserted text
    else
      col = #last_line
    end
  else
    col = #last_line
  end
  api.nvim_win_set_cursor(win, { last_inserted_line_num, col })
end


local function place_cursor_at_line_end(new_line_number, new_lines, after_cursor, buf)
  local win = api.nvim_get_current_win()
  local last_inserted_line_num = new_line_number + #new_lines - 1
  local last_line = api.nvim_buf_get_lines(buf, last_inserted_line_num - 1, last_inserted_line_num, false)[1] or ""
  local col
  if after_cursor and #after_cursor > 0 then
    local idx = last_line:find(vim.pesc(after_cursor), 1, true)
    if idx then
      col = idx - 1 -- place cursor just before after_cursor
    else
      col = #last_line
    end
  else
    col = #last_line
  end
  api.nvim_win_set_cursor(win, { last_inserted_line_num, col })
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
  local inserted_text -- new variable

  if trigger_char == ">" then
    -- Split verses by newlines and format each line as a block quote
    local verse_lines = vim.split(result.verses, "\n", { plain = true })

    new_lines = {
      before_trigger .. ">" .. "[!Bible] [" .. vim.trim(item_text) .. "]" .. "(" .. result.url .. ")" .. after_cursor,
    }

    -- Add each verse line as a block quote
    for _, verse_line in ipairs(verse_lines) do
      table.insert(new_lines, ">" .. verse_line)
    end

    table.insert(new_lines, "")
    new_line_number = line_number
    api.nvim_buf_set_lines(
      buf,
      new_line_number - 1, new_line_number,
      false,
      new_lines
    )
    place_cursor_at_line_end(new_line_number, new_lines, after_cursor, buf)
  elseif trigger_char == '@' then
    inserted_text = "[" .. vim.trim(item_text) .. "]" .. "(" .. result.url .. ")"
    new_lines = {
      before_trigger .. inserted_text .. after_cursor,
    }
    new_line_number = line_number

    api.nvim_buf_set_lines(
      buf,
      new_line_number - 1, new_line_number,
      false,
      new_lines
    )
    place_cursor_after_inserted_text(new_line_number, new_lines, inserted_text, buf)
  elseif trigger_char == '^' then
    local last_line_idx = vim.api.nvim_buf_line_count(buf)
    local separator = "# Footnote"

    if separator_exists(buf, separator) then
      separator = ""
    else
      vim.api.nvim_buf_set_lines(buf, last_line_idx, last_line_idx, false, { "", separator, "" })
      last_line_idx = last_line_idx + 2 -- adjust last line index for the empty lines before and after the separator
    end
    item_text = vim.trim(item_text):gsub("%s", "")
    inserted_text = "[" .. trigger_char .. item_text .. "]"
    local footnote_lines = {
      before_trigger .. inserted_text .. after_cursor,
    }

    api.nvim_buf_set_lines(
      buf,
      line_number - 1, line_number,
      false,
      footnote_lines
    )
    place_cursor_after_inserted_text(line_number, footnote_lines, inserted_text, buf)

    local verses = result.verses:gsub("\n", " ")

    new_lines = {
      "[" ..
      trigger_char ..
      item_text .. "]" .. ": " .. "[" .. item_text .. "]" .. "(" .. result.url .. ")" .. " " .. verses,
      ""
    }

    new_line_number = last_line_idx + 1

    api.nvim_buf_set_lines(
      buf,
      new_line_number - 1, new_line_number,
      false,
      new_lines
    )
  else
    vim.notify("No Trigger Character detected!", vim.log.levels.ERROR)
  end
end

return M
