local rex = require("rex_pcre")
local regex_utils = require("youversion-linker.utils.regex_utils")

local M = {}

M.extract_bible_reference = function(text)
  local success, bible_reference = pcall(regex_utils.detectBibleReference, text)
  if not success then
    vim.notify("The input is not a valid bible reference", vim.log.levels.ERROR)
  end

  local ref_success, parsed_reference = pcall(regex_utils.parseBookChapterVerses, bible_reference)
  if not ref_success then
    vim.notify("Bible Reference" .. bible_reference .. " not found", vim.log.levels.ERROR)
    -- return nil
  end

  local book_name = parsed_reference.book
  local chapter_verse_range

  if parsed_reference.verseSection then
    chapter_verse_range = tostring(parsed_reference.chapter) .. ":" .. parsed_reference.verseSection:gsub("%s+", "")
  else
    chapter_verse_range = tostring(parsed_reference.chapter)
  end

  -- local book_name, chapter_verse_range = text:match("^([%a%s]+)%s(%d+:%d+[%-%d]*)" )

  if book_name and chapter_verse_range then
    return { book = book_name, chapter_verse_range = chapter_verse_range }
  else
    return nil -- Return nil if the pattern doesn't match
  end
end

M.find_trigger_and_text = function(line, cursor_col)
  for i = cursor_col, 1, -1 do
    local char = line:sub(i, i)
    if char == "@" then
      local trigger_text = line:sub(i + 1, cursor_col)
      return {
        trigger_pos = i,
        trigger_text = trigger_text,
        has_trigger = true
      }
    elseif char:match("%s") then
      local text_so_far = line:sub(i, cursor_col)
      if not text_so_far:match(":") then
        break
      end
    end
  end
  return { has_trigger = false }
end

return M
