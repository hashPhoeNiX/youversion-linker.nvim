return {
  'saghen/blink.cmp',
  -- lazy = false, -- lazy loading handled internally

  version = '1.*',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
    -- 'super-tab' for mappings similar to vscode (tab to accept)
    -- 'enter' for enter to accept
    -- 'none' for no mappings
    --
    -- All presets have the following mappings:
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    --
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = { preset = 'super-tab' },


    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono'
    },

    -- (Default) Only show the documentation popup when manually triggered
    completion = {
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
        window = {
          border = "rounded",
          winblend = vim.o.pumblend,
        },
      },
      accept = {
        auto_brackets = {
          enabled = true,
        },
      },
      list = {
        selection = {
          preselect = true,
          auto_insert = false,
        },
        cycle = { from_top = false }
      },
      menu = {
        border = "rounded",
        -- Minimum width should be controlled by components
        min_width = 1,
        draw = {
          columns = {
            { "kind_icon" },
            { "label",    "label_description", gap = 1 },
            { "provider" },
          },
          components = {
            provider = {
              text = function(ctx)
                return "[" .. ctx.item.source_name:sub(1, 3):upper() .. "]"
              end,
            },
          },
        },
      },
    },
    signature = {
      enabled = true,
      window = {
        show_documentation = true,
        border = "rounded",
        winblend = vim.o.pumblend,
      },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  -- opts_extend = { "sources.default" },
}
