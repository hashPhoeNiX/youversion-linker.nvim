-- Chat GPT
-- return {
-- 	dir = "~/Projects/plugins/at_popup.nvim",
-- 	config = function()
-- 		require("at_popup").setup({
-- 			message = "Test message",
-- 			delay = 50,
-- 			position = "bottom",
-- 		})
-- 	end,
-- }
--
--
-- Gemini
-- return {
--   -- ... other plugins ...
--
--   {
--     -- If it's a local plugin, you might reference it by path,
--     -- or symlink it into your runtimepath.
--     -- For development, you can do:
--     -- 'path/to/your/popup_on_char_plugin', -- Replace with actual path
--     --
--     -- Or, if you push it to GitHub, users would install like this:
--     dir = "~/Projects/plugins/at_popup.nvim",
--  -- Example if you publish it
--     name = 'at_popup', -- Ensure the name matches the lua directory
--     config = function()
--       -- Call the setup function with your desired options
--       require('at_popup').setup({
--         trigger_chars = { 'x', '@', '#' }, -- Example: trigger on 'x', '@', or '#'
--         popup_content = {
--           'Hello from Popup!',
--           'This is a custom message.',
--           'Typed: ' .. vim.fn.char2nr(vim.v.char), -- Does not work directly here
--         },
--         popup_width = 30,
--         popup_height = 3,
--         popup_border = 'double',
--         popup_row_offset = 1,
--         popup_col_offset = 2,
--       })
--
--       -- If you want different behavior for different characters:
--       -- You would need to make `on_insert_char_pre` more sophisticated
--       -- to look up content based on the `char` argument.
--       -- For now, all trigger chars get the same content.
--     end
--   },
--
--   -- ... more plugins ...
-- }

return {
  dir = "~/Projects/plugins/at_popup.nvim",
  name = "at_popup",
  enabled = false,
  config = function()
      require("test_at_popup").setup({
        completions = {
          ["@"] = {
            { label = "@author", insertText = "@author: Your Name" },
            { label = "@param", insertText = "@param {type} name - description" },
            { label = "@return", insertText = "@return {type} description" },
            { label = "@todo", insertText = "@todo: " },
            { label = "@note", insertText = "@note: " },
          },
          ["^"] = {
            { label = "^HEAD", insertText = "^HEAD" },
            { label = "^main", insertText = "^main" },
            { label = "^master", insertText = "^master" },
            { label = "^develop", insertText = "^develop" },
          },
          [">"] = {
            { label = "> Quote", insertText = "> " },
            { label = ">> Nested Quote", insertText = ">> " },
            { label = ">>> Deep Quote", insertText = ">>> " },
            { label = "> Important", insertText = "> **Important:** " },
          },
        },
        trigger_chars = { "@", "^", ">" },
        auto_trigger = true,
      })
      
      -- Optional: Set up a manual trigger keymap
      vim.keymap.set('i', '<C-Space>', function()
        require('at_popup').trigger_completion()
      end, { desc = 'Trigger at_popup completion' })
    end,
}

