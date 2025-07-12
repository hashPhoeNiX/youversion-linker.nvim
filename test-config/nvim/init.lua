require("config.lazy")
require("config.lsp")

vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set number")
vim.cmd("set relativenumber")
-- vim.cmd("set laststatus=1")
vim.cmd("set clipboard=unnamedplus")
vim.g.mapleader = " "
vim.opt.termguicolors = true

-- create a keymap for Lazy 
vim.keymap.set('n', '<leader>l', function() require('lazy').home() end, { desc = 'Lazy' })
vim.keymap.set('i', 'jj', '<Esc>', { desc = 'Insert Escape' })
vim.keymap.set('i', 'kk', '<Esc>', { desc = 'Insert Escape' })

-- vim.keymap.set('t', 'jk', '<Esc><Esc>', { desc = 'Terminal Escape' })
-- Directional window movements
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to lower window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to upper window' })
-- vim.keymap.set('t', '<C-k>', '<C-w>k', { desc = 'Move to upper window' })
vim.keymap.set('n', '<C-->', '<C-w>-', { desc = 'Resize windom window [up]' })
vim.keymap.set('n', '<C-==>', '<C-w>+', { desc = 'Resize windom window [down]' })

-- Terminal
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Open a terminal at the bottom of the screen with a fixed height.
-- vim.keymap.set("n", ",st", function()
--   vim.cmd.new()
--   vim.cmd.wincmd "J"
--   vim.api.nvim_win_set_height(0, 12)
--   vim.wo.winfixheight = true
--   vim.cmd.term()
-- end)


-- Run lua files
vim.keymap.set("n", "<leader><leader>x", function()
  local base = vim.fs.basename(vim.fn.expand("%"))
  if vim.startswith(base, "test_") then
    return "<cmd>lua MiniTest.run_file()<cr>"
  elseif vim.endswith(base, "_spec.lua") then
    return "<cmd>PlenaryBustedFile %<cr>"
  else
    return "<cmd>w<cr><cmd>so %<cr>"
  end
end, { expr = true })


-- LSP 
-- vim.lsp.enable({
--   -- lua
--   "lua_ls",
--   -- nix
--   -- "nil_ls",
--   "nixd",
--   -- python
--   -- "pyright",
--   -- "ruff",
--   -- markdown
--   -- "ltex",
--   -- terraform
--   -- "terraformls",
--   -- yaml
--   -- "yamlls",
--   -- bash
--   -- "bashls"
-- })
--
-- Initialize all test plugins
local plugins = {
	-- "present",
    -- "at_popup",
	-- Add new plugin names here matching what you defined in devenv.nix
}

for _, plugin in ipairs(plugins) do
	local status, _ = pcall(require, plugin)
	if not status then
		vim.notify("Failed to load plugin: " .. plugin, vim.log.levels.WARN)
	end
end

-- Example plugin configuration
-- require("present") --.setup({})
-- require("at_popup").setup({
--   message = "Test message",
--   delay = 50,
--   position = "bottom"
-- })
-- Add configurations for other plugins here
-- require("my_other_plugin").setup({ ... })
