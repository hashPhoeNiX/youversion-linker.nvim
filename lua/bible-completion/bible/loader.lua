local cjson = require("cjson.safe")

local M = {}

-- Simplified file loading with better error messages
M.load_book_abbreviations = function()
  local info = debug.getinfo(1, "S")
  if not info or not info.source then
    vim.notify("Warning: Could not determine plugin directory", vim.log.levels.WARN)
    return {}
  end
  
  local source = info.source:match("^@(.+)") or info.source:sub(2)
  local dirname = vim.fn.fnamemodify(source, ":h")
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

local bible_book_abbreviations = M.load_book_abbreviations()

M.get_book_abbreviations = function()
  return bible_book_abbreviations
end

return M
