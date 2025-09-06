---@class VerseData
---@field title string
---@field version string
---@field verses string
---@field url string
---@field parsedReference table
---@field bible_reference string

local M = {}

---@param reference string
---@param version string|nil
---@return VerseData|nil
local function main(reference, version)
  local utils = require("youversion-linker.utils")
  local bible_reference = utils.regex_utils.detectBibleReference(reference)
  local parsed = utils.regex_utils.parseBookChapterVerses(bible_reference)
  local url = utils.build_url.buildYouVersionURL(parsed, version)

  local html = utils.get_html_page.fetch_url(url)
  local json_data = utils.extract_verse.extract_verse(html)
  local verse_data = utils.extract_verse.parse_json(json_data)

  verse_data.url = url
  verse_data.parsedReference = parsed
  verse_data.bible_reference = bible_reference

  return verse_data
end

M.get_bible_versions = require("youversion-linker.utils.versions").get_bible_versions
M.lookup = require("youversion-linker.utils").book_lookup
M.main = main

return M
