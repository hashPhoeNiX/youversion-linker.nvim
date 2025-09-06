-- local ok, cjson = pcall(require, "cjson.safe")
--
-- if not ok then
--   vim.notify("Missing 'cjson' dependency! Please check documentation for steps to install.", vim.log.levels.ERROR)
--   return {}
-- end
--
local M = {}

local function load_json_file(path, error_context)
  local success, file = pcall(io.open, path, "r")
  if not success or not file then
    vim.notify(error_context .. " not found at: " .. path, vim.log.levels.WARN)
    return {}
  end

  local content = file:read("*a")
  file:close()

  local decoded_success, data_or_err = pcall(vim.json.decode, content)
  if not decoded_success then
    vim.notify("Failed to parse " .. error_context .. " JSON: " .. tostring(data_or_err), vim.log.levels.ERROR)
    return {}
  end

  return data_or_err
end

M.load_book_abbreviations = function()
  local info = debug.getinfo(1, "S")
  if not info or not info.source then
    vim.notify("Warning: Could not determine plugin directory", vim.log.levels.WARN)
    return {}
  end

  local source = info.source:match("^@(.+)") or info.source:sub(2)
  local dirname = vim.fn.fnamemodify(source, ":h")
  local book_dir_path = vim.fn.resolve(dirname .. '/books/en.json')

  return load_json_file(book_dir_path, "Bible book abbreviations")
end

M.load_bible_version_ids = function()
  local info = debug.getinfo(1, "S")
  if not info or not info.source then
    vim.notify("Warning: Could not determine plugin directory", vim.log.levels.WARN)
    return {}
  end

  local source = info.source:match("^@(.+)") or info.source:sub(2)
  local dirname = vim.fn.fnamemodify(source, ":h")
  local version_dir_path = vim.fn.resolve(dirname .. '/books/versions.json')

  return load_json_file(version_dir_path, "Bible version IDs")
end

local booksTable = M.load_book_abbreviations()
local bibleVersions = M.load_bible_version_ids()

M.cleanBookName = function(book)
  if not book then
    return ""
  end
  return book:lower():gsub("%s+", "")
end

M.getBook = function(bookName)
  local query = M.cleanBookName(bookName)
  for code, variant in pairs(booksTable) do
    for _, book in ipairs(variant) do
      if M.cleanBookName(book) == query then
        return code
      end
    end
  end

  return nil, "Invalid book name: " .. tostring(bookName)
end

M.getVersionId = function(lang_key, version)
  lang_key = lang_key or 'eng'
  local lang = bibleVersions[lang_key]
  if not lang or not lang.data then
    vim.notify("Language key not found: " .. tostring(lang_key), vim.log.levels.WARN)
    return nil, "Language key not found: " .. tostring(lang_key)
  end
  for _, value in pairs(lang.data) do
    if value.abbreviation == version then
      return value.id
    end
  end

  vim.notify("ID for bible version: " .. version .. " not found")
  return nil, "Abbreviation not found: " .. version
end

return M
