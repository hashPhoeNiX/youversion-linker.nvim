local cjson = require("cjson.safe")

local M = {}

M.load_book_abbreviations = function()
  local info = debug.getinfo(1, "S")
  if not info or not info.source then
    vim.notify("Warning: Could not determine plugin directory", vim.log.levels.WARN)
    return {}
  end
  
  local source = info.source:match("^@(.+)") or info.source:sub(2)
  -- print(source)
  local dirname = vim.fn.fnamemodify(source, ":h")
  -- print(dirname)
  local book_dir_path = vim.fn.resolve(dirname .. '/books/en.json')
  
  local success, file = pcall(io.open, book_dir_path, "r")
  if not success or not file then
    vim.notify("Bible book abbreviations not found at: " .. book_dir_path, vim.log.levels.WARN)
    return {}
  end
  
  local content = file:read("*a")
  file:close()
  
  local decoded_success, data = pcall(cjson.decode, content)
  if not decoded_success then
    vim.notify("Failed to parse Bible book abbreviations JSON", vim.log.levels.ERROR)
    return {}
  end
  
  return data
end

-- local sep = package.config:sub(1, 1)
-- local dirname = string.sub(debug.getinfo(1).source, 2, string.len('/youversion-linker.lua') * -1)
-- local book_dir_path = dirname .. 'books/en.json'
-- -- print("Book Path: " .. book_dir_path)
-- -- local native_path   = dirname .. sep .. 'native.lua
--
-- -- M.getBooksList = function()
-- local book_path = io.open(book_dir_path, "r")
-- local en_books = book_path:read("*a")
-- book_path:close()
-- local booksTable = cjson.decode(en_books)
-- vim.print(booksTable)
-- return booksTable
-- end

local booksTable = M.load_book_abbreviations()

M.cleanBookName = function(book)
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

  return nil, "Invalid book name: " .. bookName
end

return M
