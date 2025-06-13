
local rex = require("rex_pcre")

-- ===================================================================
-- YOUVERSION LINKER PLUGIN - COMPLETE REGEX PATTERNS IN LUA
-- ===================================================================

-- 1. MAIN LINK DETECTION PATTERN
-- Used to match complete reference strings as user types (e.g., "John 3:16–18,20")
local linkRegex = [[
  (                         # Start capture group for entire match
    [12345]?                # Optional leading number (1-5) for books like "1 John", "2 Kings"
    [\s\p{L},'_-]*          # Zero or more: spaces, Unicode letters, comma, apostrophe, underscore, hyphen
    \p{L}                   # Must end with at least one Unicode letter (ensures we have a book name)
    [12345]?                # Optional trailing number for books like "1 John1" (rare case)
    \s+                     # Required space before chapter
    \d{1,3}                 # Chapter number (1-3 digits, handles up to chapter 999)
    (                       # Start optional verse section
      [:,.]\s?              # Verse separator: colon, comma, or period, optional space
      \d{1,3}               # First verse number (1-3 digits)
      (\s?[-–—]\s?\d{1,3})?   # Optional range: dash/en-dash/em-dash + end verse number... Added optional space. Remove if not needed
    )?                      # End optional first verse section
    (                       # Start section for additional verses/ranges
      [,.]\s?               # Comma or period separator with optional space
      \d{1,3}               # Additional verse number
      ([-–—]\d{1,3})?       # Optional range for this verse too
    )*                      # Zero or more additional verses (handles "16-18,20,22-24")
  )                         # End main capture group
]]

-- Clean the main pattern
local cleanLinkRegex = linkRegex:gsub("%s*#[^\r\n]*", ""):gsub("[\r\n%s]+", "")

-- 2. BOOK NAME PATTERNS
-- Used to identify or validate book names in isolation (e.g., "1 Kings" or "Revelation")
local bookRegex = "[12345]?[\\s\\p{L},'_-]*\\p{L}[12345]?"
local testBookRegex = "^" .. bookRegex .. "$"

-- 3. SEPARATOR PATTERNS
-- Used to split the numeric portion (chapter vs. verse, and verse ranges)
local chapterSeparatorRegex = "[:,.]+"
local rangeSeparatorRegex = "[-–—]+"

-- 4. Combination of 2 and 3 for extracting book, chapter, and verse
local extractPattern = [[
  (\d?\s*\p{L}+(?:\s+\p{L}+)*)  # Capture book name (with optional leading number)
  \s+                            # Space separator  
  (\d{1,3})                      # Capture chapter number
  (?:[:.](.+))?                  # Capture everything after colon/period as verse section
]]

local bookChapterVersesRegex = extractPattern:gsub("%s*#[^\r\n]*", ""):gsub("[\r\n%s]+", "")

return {
  linkRegex = cleanLinkRegex, -- Main link detection pattern
  bookRegex = bookRegex,     -- Book name pattern
  testBookRegex = testBookRegex, -- Exact book name match
  bookChapterVersesRegex = bookChapterVersesRegex, -- Book, chapter, and verses extraction
  chapterSeparatorRegex = chapterSeparatorRegex, -- Chapter separator
  rangeSeparatorRegex = rangeSeparatorRegex,     -- Range separator
}
