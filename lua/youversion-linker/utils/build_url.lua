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

M.buildYouVersionURL = function(parsedRef)
  -- version = version or "KJV" -- Default version
  if not parsedRef then
    return nil, "Parsed reference is required"
  end

  local book = lookup.getBook(parsedRef.book)
  vim.print(book)
  local bookName = book:lower():gsub("%s+", "-"):gsub("[^%w-]", "")
  local baseURL = "https://www.bible.com/bible/" .. "1/" .. bookName .. "." .. parsedRef.chapter .. "." .. parsedRef.verseSection:gsub("%s+", "")

  if parsedRef.verse then
    baseURL = baseURL .. "." .. parsedRef.verse
  end

  print("Generated URL: " .. baseURL)
  return baseURL
end

return M
