local versions = require("nui.bible-completion.bible.versions")

local M = {}

local default_config = {
  debounce_ms = 300,  -- Reduced for better responsiveness
  cursor_debounce_ms = 300,  -- Faster cursor tracking
  trigger_debounce_ms = 500,    -- NEW: Specific debounce for @ trigger (longer)
  trigger_char = "@",           -- Character that triggers completion
  enable_auto_detection = true, -- Whether to enable automatic detection
  enable_trigger = true,        -- Whether to enable @ trigger
  
  -- NEW: Minimum requirements before triggering completion
  min_trigger_length = 3,       -- Minimum characters after @ before showing completion
  require_chapter_for_completion = false, -- Whether to require chapter before showing completion

  popup = {
    position = 50,
    enter = false,
    focusable = true,
    relative = "cursor",
    size = {
      width = 50,
      height = 10,
    },
    border = {
      style = "rounded",
      text = {
        top = " Bible Versions ",
        top_align = "left",
      },
    },
    buf_options = {
      modifiable = false,
      readonly = true,
      buftype = "nofile",
      swapfile = false,
      bufhidden = "wipe",
      filetype = "bible-completion",
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      cursorline = true,
      cursorcolumn = false,
      number = false,
      relativenumber = false,
      signcolumn = "no",
    },
  },
}

local config = vim.tbl_deep_extend("force", default_config, {})

M.setup = function(user_config)
  if user_config then
    config = vim.tbl_deep_extend("force", config, user_config)
  end
  
  if user_config and user_config.bible_versions then
    versions.configure_versions(user_config.bible_versions)
  end
end

M.configure = function(new_config)
  if new_config then
    config = vim.tbl_deep_extend("force", config, new_config)
  end
  
  if new_config and new_config.bible_versions then
    versions.configure_versions(new_config.bible_versions)
  end
end

M.get_config = function()
  return vim.deepcopy(config)
end

return M
