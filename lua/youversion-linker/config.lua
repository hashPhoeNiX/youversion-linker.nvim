local M = {}
local default_config = {
    popup_options = {
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
    win_options = {
      winhighlight = "Normal:Normal",
    }
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
