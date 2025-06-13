local config = require("nui.bible-completion.config")
local state = require("nui.bible-completion.state")
local completion = require("nui.bible-completion.completion")
local autocmds = require("nui.bible-completion.utils.autocmds")

local M = {}

-- Enhanced setup function with better validation
M.setup = function(user_config)
  local nui_available, _ = pcall(require, "nui.menu")
  if not nui_available then
    vim.notify("nui.nvim is required for this plugin", vim.log.levels.ERROR)
    return false
  end
  
  config.setup(user_config)
  autocmds.setup()
  
  return true
end

-- Runtime configuration updates
M.configure = function(new_config)
  config.configure(new_config)
end

-- Utility functions for debugging and introspection
M.get_config = function()
  return config.get_config()
end

M.get_state = function()
  return state.get_state()
end

-- Manual trigger function for testing
M.trigger_completion = function()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  completion.show_inline_completion_menu(line, col + 1)
end

return M
