
local plugin = require("youversion-linker")
local pl = require("pl.pretty")

local line = vim.api.nvim_get_current_line()
local result = M.core.main(line)

pl.dump(result)

-- @John 3:16-18
