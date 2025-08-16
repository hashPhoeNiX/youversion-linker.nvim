local M = {}
local default_config = {
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
}

-- calculating the bible text popup position relative to the menu
local popup_col = default_config.menu_options.position.col + default_config.menu_options.size.width + 2 -- 3 character spacing

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

local config = vim.tbl_deep_extend("force", default_config, {})

M.get_config = function(user_config)
  if user_config then
    config = vim.tbl_deep_extend("force", config, user_config)
  end
  -- vim.print("Config loaded" .. vim.inspect(config))
  return config
end

return M
