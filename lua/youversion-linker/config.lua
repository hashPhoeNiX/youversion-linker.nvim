---@module "youversion-linker.config"
local M = {}

---@class MenuKeymapsConfig
---@field focus_next string[]
---@field focus_prev string[]
---@field close string[]
---@field submit string[]
---@field focus_menu string[]

---@class YouVersionLinkerConfig
---@field debounce_delay number
---@field filetypes string[] Default filetypes to activate the plugin in
---@field popup_char_spacing number Space between the menu popup and the bible text popup
---@field menu_options table nui.menu configurations
---@field bible_versions table Enabled Bible Versions will be displayed in the popup
---@field popup_options table Bible Text Popup options from nui.popup
local default_config = {
  debounce_delay = 20,
  filetypes = { "*.md", "*.txt" },
  popup_char_spacing = 2,

  menu_options = {
    enter = false,
    focusable = true,
    relative = "cursor",
    position = {
      row = 1,
      col = 3,
    },
    size = {
      width = 25,
      height = 5,
    },
    border = {
      style = "rounded",
      text = {
        top = "[Bible Versions]",
        top_align = "center",
      },
    },
    buf_options = {
      readonly = true,
    },
    win_options = {
      winhighlight = "Normal:Normal",
    }
  },

  menu_keymaps = {
    focus_next = { "j", "<Down>", "<Tab>" },
    focus_prev = { "k", "<Up>", "<S-Tab>" },
    close = { "<Esc>", "<C-c>", "q" },
    submit = { "<CR>", "<Space>" },
    focus_menu = { "<S-Tab>" }, -- For focusing menu from insert mode
  },
}

-- calculating the bible text popup position relative to the menu
---@type number Calculate the position of the bible text popup
local popup_col = default_config.menu_options.position.col + default_config.menu_options.size.width +
    default_config.popup_char_spacing

default_config.popup_options = {
  position = {
    row = 1, --default_config.menu_options.position.row,
    col = popup_col,
  },
  size = {
    width = 45,
    height = 15,
  },
  relative = "cursor",
  border = {
    style = "rounded",
    text = {
      top = " Bible Text ",
      top_align = "center",
    },
  },
  win_options = {
    winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
  },
  buf_options = {
    modifiable = false,
    readonly = true,
  }
}

default_config.bible_versions = {
  NIV = { enabled = false },
  KJV = { enabled = true },
  NKJV = { enabled = true },
  NLT = { enabled = false },
  AMP = { enabled = true },
}

-- local config = vim.tbl_deep_extend("force", default_config, {})

---@param user_config table Accepts user configuration
---@return YouVersionLinkerConfig
M.get_config = function(user_config)
  local global_config = vim.g.youversion_linker_config or {}
  local config = vim.tbl_deep_extend("force", default_config, global_config, user_config or {})
  -- if user_config then
  --   config = vim.tbl_deep_extend("force", config, user_config)
  -- end
  -- vim.print("Config loaded" .. vim.inspect(config))
  return config
end

return M
