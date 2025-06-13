local cjson = require("cjson.safe")

local M = {}


local sep = package.config:sub(1, 1)
local dirname = string.sub(debug.getinfo(1).source, 2, string.len('/youversion-linker.lua') * -1)
local book_dir_path = dirname .. 'books/en.json'
-- print("Book Path: " .. book_dir_path)
-- local native_path   = dirname .. sep .. 'native.lua

-- M.getBooksList = function()
local book_path = io.open(book_dir_path, "r")
local en_books = book_path:read("*a")
book_path:close()
local booksTable = cjson.decode(en_books)
-- vim.print(booksTable)
-- return booksTable
-- end


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
