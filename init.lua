vim.cmd("set clipboard=unnamedplus")

-- Initialize all test plugins
local plugins = {
  "present",
  -- Add new plugin names here matching what you defined in devenv.nix
}

for _, plugin in ipairs(plugins) do
  local status, _ = pcall(require, plugin)
  if not status then
    vim.notify("Failed to load plugin: " .. plugin, vim.log.levels.WARN)
  end
end

-- Example plugin configuration
require("present") --.setup({})

-- Add configurations for other plugins here
-- require("my_other_plugin").setup({ ... })

