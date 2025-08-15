local M = {}

local utils = require("youversion-linker.utils")

local function main(reference, version)
  local bible_reference = utils.regex_utils.detectBibleReference(reference)
  local parsed = utils.regex_utils.parseBookChapterVerses(bible_reference)
  local url = utils.build_url.buildYouVersionURL(parsed, version)

  -- if version then
  --   -- url = url .. "." .. version
  --   vim.notify("URL: " .. url)
  -- end
  local html = utils.get_html_page.fetch_url(url)
  local json_data = utils.extract_verse.extract_verse(html)
  local verse_data = utils.extract_verse.parse_json(json_data)
  verse_data.url = url
  verse_data.parsedReference = parsed

  return verse_data
end

M.get_bible_versions = utils.versions.get_bible_versions
M.lookup = utils.book_lookup
M.main = main

return M
