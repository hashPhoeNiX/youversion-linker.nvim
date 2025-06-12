return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
    -- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  lazy = false, -- neo-tree will lazily load itself
  ---@module "neo-tree"
  ---@type neotree.Config?
  opts = {
    sources = { "filesystem", "buffers", "git_status", "document_symbols" },
    -- fill any relevant options here
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = true,
      },
      -- Even if you include a filesystem block, it won’t load if “filesystem” is not in sources.  filesystem.follow_current_file.enabled
      follow_current_file = { enabled = false },
      group_empty_dirs = true,
      hijack_netrw_behavior = "disabled",
    },
  },
}
