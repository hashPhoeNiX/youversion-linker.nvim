local M = {}

local Menu = require("nui.menu")
local event = require("nui.utils.autocmd").event

local pl = require("pl.pretty")
local config = require("youversion-linker.config")
local core = require("youversion-linker.core")

local api = vim.api

local current_menu = nil
local debounce_timer = nil

local function extract_bible_reference(text)
  local book_name, chapter_verse_range = text:match("^([%a%s]+)%s(%d+:%d+[%-%d]*)" )

  if book_name and chapter_verse_range then
    return { book = book_name, chapter_verse_range = chapter_verse_range }
  else
    -- print(text)
    return nil -- Return nil if the pattern doesn't match
  end
end

local function find_trigger_and_text(line, cursor_col)
  for i = cursor_col, 1, -1 do
    local char = line:sub(i, i)
    if char == "@" then
      local trigger_text = line:sub(i + 1, cursor_col)
      return {
        trigger_pos = i,
        trigger_text = trigger_text,
        has_trigger = true
      }
    elseif char:match("%s") then
      local text_so_far = line:sub(i, cursor_col)
      if not text_so_far:match(":") then
        break
      end
    end
  end
  return { has_trigger = false }
end

local function close_current_menu()
  if current_menu then
    current_menu:unmount()
    current_menu = nil
  end
end

M.get_current_line = function()
  local buf = 0
  local line = api.nvim_get_current_line()
  local line_number, col = unpack(api.nvim_win_get_cursor(buf))
  local row = line_number - 1 -- row based

  local trigger = line:sub(col+1, col+1)
  local before = line:sub(1, col + 1) -- Get prefix of the cursor position
  local after = line:sub(col + 2, -1) -- Get suffix of the cursor position

  print(trigger .. after)
  local trigger_info = find_trigger_and_text(line, col)

  if not trigger_info.has_trigger then
    return nil
  end

  local trigger_text = trigger_info.trigger_text
  local extracted_reference = extract_bible_reference(trigger_text)
  if not extracted_reference then
    return {
      buf = buf,
      line = line,
      line_number = line_number,
      col = col,
      trigger_pos = trigger_info.trigger_pos,
      trigger_text = trigger_text,
      displayBook = trigger_text, -- Use typed text as display
      bible_versions = core.get_bible_versions(),
      extracted_reference = nil,
    }
  end

  local displayBook = core.lookup.getBook(extracted_reference.book)
  return {
    buf = buf,
    line = line,
    line_number = line_number,
    col = col,
    trigger_pos = trigger_info.trigger_pos,
    trigger_text = trigger_text,
    displayBook = displayBook,
    bible_versions = core.get_bible_versions(),
    extracted_reference = extracted_reference,
  }

end

local function replace_line_with_bible_verse(current_line_result, bible_ref, item_text, version)
  local buf = current_line_result.buf
  -- local after = current_line_result.after
  local line = current_line_result.line
  local line_number = current_line_result.line_number
  local trigger_pos = current_line_result.trigger_pos
  local col = current_line_result.col

  local result = core.main(bible_ref, version)


  local before_trigger = line:sub(1, trigger_pos - 1)
  local after_cursor = line:sub(col + 1, -1)

  local new_lines = {
    "--[[",
    item_text,
    result.verses,
    "]]",
  }

  api.nvim_buf_set_lines(
    buf,
    line_number - 1, line_number,
    false,
    new_lines
  )
end



M.get_config = function(user_config)
  local config_opts = config.get_config(user_config)

  return config_opts
end

local function create_menu_items(result)
  -- local result = M.get_current_line()
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

M.setup_trigger = function(user_config)
  api.nvim_create_autocmd("TextChangedI",{
    pattern = "*",
    callback = function()
      if debounce_timer then
        vim.fn.timer_stop(debounce_timer)
        debounce_timer = nil
      end

      local line = api.nvim_get_current_line()
      local _, col = unpack(api.nvim_win_get_cursor(0))

      local trigger_info = find_trigger_and_text(line, col)
      if trigger_info.has_trigger and #trigger_info.trigger_text > 0 then
        close_current_menu() -- close existing menu
        debounce_timer = vim.fn.timer_start(200, function()
          debounce_timer = nil
          
          local current_line = api.nvim_get_current_line()
          local _, current_col = unpack(api.nvim_win_get_cursor(0))
          local current_trigger_info = find_trigger_and_text(current_line, current_col)
          
          if current_trigger_info.has_trigger and #current_trigger_info.trigger_text > 0 then
            M.create_and_show_popup_menu(user_config)
          end
        end)
      else
        close_current_menu() --close menu if there's no trigger
      end
    end

  })
end

M.create_and_show_popup_menu = function(user_config)
  local result = M.get_current_line()
  if result then
    -- local after = result.after
    local trigger_text = result.trigger_text
    local displayBook = result.displayBook
    -- local extracted_reference = result.extracted_reference

    local popup_options = M.get_config(user_config).popup_options
    local items = create_menu_items(result)

    if #items == 0 then
      vim.notify("No enabled Bible versions found", vim.log.levels.WARN)
      return
    end

    local menu = Menu(popup_options, {
      lines = items,
      max_width = math.max(50, #trigger_text + #displayBook + 20), -- bible passage + display book + version lengths
      keymap = {
        focus_next = {"j", "<Down>", "<Tab>"},
        focus_prev = {"k", "<Up>", "<S-Tab>"},
        close = {"<Esc>", "<C-c>"},
        submit = {"<CR>", "<Space>"},
      },
      on_close = function()
        vim.notify("Menu closed", vim.log.levels.INFO)
        current_menu = nil -- clear when menu is closed
        pcall(vim.keymap.del, 'i', "<S-Tab>")
      end,
      on_submit = function(item)
        vim.notify("Selected: " .. item.text, vim.log.levels.INFO)
        -- vim.print(vim.inspect(extractBibleReference(item.text)))
        local extracted_reference = result.extracted_reference
        if not extracted_reference then
          extracted_reference = extract_bible_reference(item.text)
          if not extracted_reference then
            vim.notify("Could not parse Bible reference", vim.log.levels.ERROR)
            return
          end
        end
        local bible_ref = extracted_reference.book .. " " .. extracted_reference.chapter_verse_range
        local version = item.text:match("([^%s]+)$") -- Extract version (last word)
        replace_line_with_bible_verse(result, bible_ref, item.text, version)
        current_menu = nil -- clear reference after submission
        pcall(vim.keymap.del, 'i', "<S-Tab>")
      end
    })

    current_menu = menu

    menu:mount()
    -- vim.keymap.set("i", "<C-Tab>", function()
    --   if current_menu then
    --     api.nvim_set_current_win(current_menu.winid)
    --   end
    -- end, { desc = "Focus Bible version menu" })
    vim.keymap.set("i", "<S-Tab>", function()
      if current_menu and current_menu.winid then
        vim.schedule(function()
          vim.cmd("stopinsert") -- force exit insert mode first
          pcall(vim.api.nvim_set_current_win, current_menu.winid)
        end)
      else
        vim.notify("Popup menu is not active", vim.log.levels.WARN)
      end
    end, { desc = "Focus Bible version menu", buffer = true })

    menu:on(event.BufLeave, function()
      menu:unmount()
      current_menu = nil

      pcall(vim.keymap.del, 'i', "<S-Tab>")
    end)
    -- menu:on(event.InsertCharPre, function()
    --   local typed_char = vim.v.char
    --
    --   if typed_char == "@" then
    --     print("Typed a trigger symbol!")
    --   end
    -- end)

  else
    vim.notify("No trigger with Bible verse text detected", vim.log.levels.INFO)  end
end


M.trigger_manual = function(user_config)
  close_current_menu()
  M.create_and_show_popup_menu(user_config)
end

return M
