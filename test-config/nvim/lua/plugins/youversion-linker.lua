
return {
  -- "hashPhoeNiX/youversion-linker.nvim",
  -- branch = "feat/initial-setup",
  dir = "~/Projects/youversion-linker.nvim",
  name = "youversion-linker",
  config = function()
    -- Defer setup to avoid circular dependencies
    vim.schedule(function()
      require("youversion-linker").setup({})
    end)
  end
}
