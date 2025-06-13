local pl = require("pl.pretty")
local core = require("youversion-linker.core")

local line = vim.api.nvim_get_current_line()

local result = core.main(line)

pl.dump(result)
