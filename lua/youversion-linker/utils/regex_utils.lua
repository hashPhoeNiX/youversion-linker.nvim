-- ===================================================================
-- UTILITY FUNCTIONS FOR THE PLUGIN WORKFLOW
-- ===================================================================
local ok, rex = pcall(require, "rex_pcre")

if not ok then
  vim.notify("Missing 'lrexlib-pcre' dependency! Please check documentation for steps to install.", vim.log.levels.ERROR)
  return nil
end

local regex = require("youversion-linker.utils.regex_patterns")

local M = {}

local linkRegex = regex.linkRegex
local testBookRegex = regex.testBookRegex
local bookChapterVersesRegex = regex.bookChapterVersesRegex
local chapterSeparatorRegex = regex.chapterSeparatorRegex
local rangeSeparatorRegex = regex.rangeSeparatorRegex

-- Detect Bible referece
M.detectBibleReference = function(text)
  local match = rex.match(text, linkRegex)
  if match then
    return match
  else
    return nil
  end
end

-- Extract Book, Chapter, and Verse from text
M.parseBookChapterVerses = function(reference)
  local book, chapter, verseSection = rex.match(reference, bookChapterVersesRegex)
  if book and chapter then
    local result = {
      book = book,
      chapter = tonumber(chapter),
      verseSection = verseSection,
    }
    return result
  else
    return nil
  end
end

return M
