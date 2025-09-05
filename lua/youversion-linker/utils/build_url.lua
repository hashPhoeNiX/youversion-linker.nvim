local lookup = require("youversion-linker.utils.book_lookup")

local M = {}

-- Validate book name against a list
M.validateBookName = function(bookName, validBooks)
  -- Normalize book name
  local normalisedInput = bookName:lower():gsub("%s+", ""):gsub("%s+$", "")

  for _, validBook in ipairs(validBooks) do
    local normalisedValidBook = validBook:lower():gsub("%s+", "")
    if normalisedInput == normalisedValidBook then
      return validBook
    end
  end

  return nil, "Invalid book name: " .. bookName
end

M.buildYouVersionURL = function(parsedRef, version)
  version = version or "KJV" -- Default version
  if not parsedRef or not parsedRef.book or not parsedRef.chapter or not parsedRef.verseSection then
    return nil, "Parsed reference with book, chapter, and verseSection is required"
  end

  local book_success, book = pcall(lookup.getBook, parsedRef.book)
  if not book_success or not book then
    return nil, "Bible book not found: " .. tostring(parsedRef.book)
  end

  local version_id_success, version_id = pcall(lookup.getVersionId, 'eng', version)
  if not version_id_success or not version_id then
    return nil, "Bible version not found: " .. tostring(version)
  end

  local bookName = book:lower():gsub("%s+", "-"):gsub("[^%w-]", "")
  local baseURL = "https://www.bible.com/bible/" ..
      tostring(version_id) ..
      "/" .. bookName .. "." .. parsedRef.chapter .. "." .. parsedRef.verseSection:gsub("%s+", "")

  if parsedRef.verse then
    baseURL = baseURL .. "." .. parsedRef.verse
  end

  return baseURL
end

return M
