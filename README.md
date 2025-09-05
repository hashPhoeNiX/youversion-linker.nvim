<!-- # youversion-linker.nvim

This neovim plugin is inspired by the [obsidian-youversion-linker](https://github.com/jaanonim/obsidian-youversion-linker)
-->
# YouVersion Linker.nvim

A Neovim plugin for quickly inserting Bible passages and links from [YouVersion](https://www.bible.com) into your notes. Supports Markdown and text files, with popup menus for selecting Bible versions.

The plugin is heavily inspired by the [obsidian-youversion-linker](https://github.com/jaanonim/obsidian-youversion-linker)

---

## Features

- Detects Bible references with triggers (`>`, `@`, `^`) as you type.
- Popup menu to select Bible version.
- Fetches and inserts passage text and links.
- Customizable filetypes, versions, and popup appearance.
- Asynchronous fetching and caching of passages.
- Manual trigger support.
- Robust regex parsing for Bible references.
- Fetches passages directly from YouVersion using HTTP.

---

## Requirements

- **Neovim** >= 0.11.1
- [luasocket](https://luarocks.org/modules/luarocks/luasocket) (for HTTP requests)  
  _Install:_ `luarocks install luasocket`
- [lrexlib-pcre](https://luarocks.org/modules/rrthomas/lrexlib-pcre) (for regex parsing)  
  _Install:_ `luarocks install lrexlib-pcre`
- [lua-cjson](https://luarocks.org/modules/mpx/lua-cjson) (for JSON parsing)  
  _Install:_ `luarocks install lua-cjson`

<!-- ### Dependencies -->

This plugin requires the following Lua rocks. Please add this configuration to your `lazy.nvim` setup to ensure they are installed:

```lua
-- ~/.config/nvim/lua/plugins/luarocks.lua
{
    "vhyrro/luarocks.nvim",
    priority = 1000, -- Very high priority is required, luarocks.nvim should run as the first plugin in your config.
    -- config = true,
    opts = {
        rocks = { 
            -- "fzy", 
            -- "pathlib.nvim ~> 1.0",
            "luasocket",
            -- "luasec",
            "lrexlib-pcre",
            "cjson",
            -- "penlight",
            -- "jsregexp",
            "busted",
        },
    },
},
```

---

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "yourusername/youversion-linker.nvim",
  config = function()
    require("youversion-linker").setup()
  end,
}
```

### Manual

Clone into your `~/.config/nvim/lua` or `pack` directory, then add to your config:

```lua
require("youversion-linker").setup()
```

---

## Configuration

You can pass options to `setup()` to customize behavior:

```lua
require("youversion-linker").setup({
  debounce_delay = 50,
  filetypes = { "*.md", "*.txt" },
  bible_versions = {
    KJV = { enabled = true },
    NIV = { enabled = true },
    AMP = { enabled = false },
  },
  menu_options = {
    -- See lua/youversion-linker/config.lua for all options
  },
  popup_options = {
    -- See lua/youversion-linker/config.lua for all options
  },
})
```

See [`lua/youversion-linker/config.lua`](lua/youversion-linker/config.lua) for all available options.

---

## Usage

### Automatic Trigger

- Type a Bible reference with a trigger character:
  - `>John 3:16`
  - `@Psalm 23:1`
  - `^Romans 8:28`
- After typing, a popup menu appears to select the Bible version.
- Use `<Tab>`, `<S-Tab>`, or arrow keys to navigate.
- Press `<CR>` or `<Space>` to insert the passage.
- Use `<Esc>` to close the menu.

### Manual Trigger

You can call the menu manually:

```lua
require("youversion-linker").manual_trigger()
```

Or from the command line:

```
:lua require("youversion-linker").manual_trigger()
```

---

## Keymaps

- `<Tab>` / `<S-Tab>`: Navigate popup menu.
- `<CR>` / `<Space>`: Insert selected passage.
- `<Esc>`: Close popup menu.

---

## Troubleshooting

- **Popup does not appear:**  
  - Check your filetype and trigger character.
  - Ensure all Lua dependencies (`luasocket`, `lrexlib-pcre`, `lua-cjson`) are installed and available to Lua.
- **Passage not inserted:**  
  - Make sure the reference is valid.
  - Check for errors in `:messages`.
- **Regex, HTTP, or JSON errors:**  
  - Ensure all dependencies are installed.
- **Debugging:**  
  - Set `NVIM_PLUGIN_DEBUG=1` in your environment for verbose output.

---

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

- [ ] Add tests and CI workflow.
- [ ] Add stylua and luacheck configs.
- [ ] Add screenshots or GIFs to this README.
- [ ] Add a `:help` doc in `doc/youversion-linker.txt`.

---

## License

MIT

---

## Credits

- [YouVersion](https://www.bible.com)
- [luasocket](https://luarocks.org/modules/luarocks/luasocket)
- [lrexlib-pcre](https://luarocks.org/modules/rrthomas/lrexlib-pcre)
- [lua-cjson](https://luarocks.org/modules/mpx/lua-cjson)
- Neovim plugin community

---

## Screenshot

<!-- Add a screenshot or GIF here when available -->

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for updates.

