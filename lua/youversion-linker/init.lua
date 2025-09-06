local M = {}

M.core = require("youversion-linker.core")
-- local plugin = require("lua.youversion-linker.main")

M.setup = function(user_config)
  local plugin = require("youversion-linker.main")
  user_config = user_config or {}
  M._config = plugin.get_config(user_config)


  plugin.setup_trigger(M._config)

  -- Create user commands
  vim.api.nvim_create_user_command("YouVersionLink", function(opts)
    plugin.trigger_manual(M._config)
  end, {
    desc = "Trigger YouVersion linker manually",
  })

  -- Show current configuration
  vim.api.nvim_create_user_command("YouVersionConfig", function(opts)
    vim.print(M._config)
  end, {
    desc = "Show YouVersion linker configuration",
  })
end

M.manual_trigger = function(user_config)
  require("youversion-linker.main").trigger_manual(user_config)
end

return M
