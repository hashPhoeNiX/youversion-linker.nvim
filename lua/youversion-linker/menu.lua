local M = {}

local Menu = require("nui.menu")

M.create_menu_items = function(result)
  local bible_versions = result.bible_versions
  local trigger_text = result.trigger_text
  -- local after = result.after
  local displayBook = result.displayBook

  local items = {}

  for version, opt in pairs(bible_versions) do
    if opt.enabled then
      local display_text = string.format("%s %s - %s", trigger_text, displayBook, version)
      table.insert(items,
        Menu.item(display_text)
      )
    end
  end

  return items
end

M.close_current_menu = function(current_menu)
  if current_menu then
    current_menu:unmount()
    current_menu = nil
  end
  return current_menu
end

return M
