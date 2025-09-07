>[!Bible] [Proverbs 19:21 PRO - NIV](https://www.bible.com/bible/111/pro.19.21)
>Many are the plans in a person’s heart,
>but it is the LORD’s purpose that prevails.

# YouVersion Linker.nvim

A modern Neovim plugin for seamlessly inserting Bible passages and links from [YouVersion](https://www.bible.com) into your notes. Built with Neovim best practices and Lua excellence.

![YouVersion Linker Demo](https://via.placeholder.com/800x400.png?text=YouVersion+Linker+nvim+Demo+GIF)

## ✨ Features

- **Smart Reference Detection**: Automatically detects Bible references as you type using customizable triggers (`>`, `@`, `^`)
- **Beautiful Popup Interface**: Dual-panel menu showing Bible versions and real-time passage preview
- **Async Performance**: Non-blocking asynchronous fetching with intelligent caching
- **Fully Customizable**: Extensive configuration options for keymaps, versions, and UI
- **Modern Architecture**: Built following Neovim plugin best practices with type safety
<!-- - **Zero External Dependencies**: Uses Neovim's built-in capabilities (HTTP, JSON parsing) -->
- **Multiple File Support**: Works with Markdown, text files, and any custom filetypes

## 🚀 Quick Start

## Requirements

- **Neovim** >= 0.11.1
- [luasocket](https://luarocks.org/modules/luarocks/luasocket) (for HTTP requests)  
  _Install:_ `luarocks install luasocket`
- [lrexlib-pcre](https://luarocks.org/modules/rrthomas/lrexlib-pcre) (for regex parsing)  
  _Install:_ `luarocks install lrexlib-pcre`

<!-- ### Dependencies -->

This plugin requires the following Lua rocks. Please add this configuration to your `lazy.nvim` setup to ensure they are installed:

```lua
-- ~/.config/nvim/lua/plugins/luarocks.lua
{
    "vhyrro/luarocks.nvim",
    priority = 1000,
    opts = {
        rocks = { 
            "luasocket",
            "lrexlib-pcre",
            "busted",
        },
    },
},
```

### Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "yourusername/youversion-linker.nvim",
  config = function()
    require("youversion-linker").setup()
  end,
}
```

### Basic Usage

1. Type a Bible reference with a trigger character:
   ```markdown
   >John 3:16
   @Psalm 23:1  
   ^Romans 8:28
   ```
2. A popup menu appears with available Bible versions
3. Navigate with `j`/`k` or arrow keys, see passage previews in real-time
4. Press `<CR>` to insert the formatted passage and link

## ⚙️ Configuration

### Default Setup

```lua
require("youversion-linker").setup({
  -- Basic settings
  debounce_delay = 20,      -- ms delay before popup appears
  filetypes = { "*.md", "*.txt", "*.qmd" },
  
  -- Bible versions to show in menu
  bible_versions = {
    KJV = { enabled = true },
    NIV = { enabled = true },
    ESV = { enabled = false },
    NASB = { enabled = true },
    -- Add any version from YouVersion
  },
  
  -- Customize menu navigation keys
  menu_keymaps = {
    focus_next = { "j", "<Down>", "<Tab>" },
    focus_prev = { "k", "<Up>", "<S-Tab>" },
    close = { "<Esc>", "<C-c>", "q" },
    submit = { "<CR>", "<Space>" },
    focus_menu = { "<S-Tab>" },  -- Focus menu from insert mode
  },
  
  -- UI customization
  popup_char_spacing = 2,
  menu_options = {
    size = { width = 25, height = 5 },
    border = { style = "rounded" },
    -- ... other nui.menu options
  },
  popup_options = {
    size = { width = 45, height = 15 },
    border = { style = "rounded" },
    -- ... other nui.popup options
  }
})
```

See [`lua/youversion-linker/config.lua`](lua/youversion-linker/config.lua) for all available options.

### Advanced Configuration

```lua
-- Support both setup() and global config
vim.g.youversion_linker_config = {
  bible_versions = {
    NKJV = { enabled = true },
    NLT = { enabled = false },
  }
}

require("youversion-linker").setup({
  menu_keymaps = {
    focus_next = { "<C-n>" },  -- Custom key for next item
    focus_prev = { "<C-p>" },  -- Custom key for previous item
  }
})
```

## 🎯 Usage

### Automatic Triggering

The plugin automatically detects Bible references in these formats:
- `>Genesis 1:1` - Creates a block quote with passage
- `@John 3:16` - Creates an inline link
- `^Romans 12:2` - Creates a footnote reference

### Manual Commands

```vim
"YouVersionLinker commands:
:YouVersionLink      " Trigger the menu manually
:YouVersionConfig    " Show current configuration
```

### Keymaps

The plugin provides `<Plug>` mappings for custom keybindings:

```lua
-- Create your own keymaps
vim.keymap.set("n", "<leader>yb", "<Plug>(YouVersionLinkerTrigger)", {
  desc = "Trigger YouVersion linker"
})

vim.keymap.set("i", "<C-b>", "<Plug>(YouVersionLinkerTrigger)", {
  desc = "Trigger YouVersion linker (insert mode)"
})
```

## 🔧 API

### Public Functions

```lua
-- Core functionality
require("youversion-linker").setup(config) -- Initialize plugin
require("youversion-linker").manual_trigger() -- Open menu manually

-- Direct access to Bible utilities
local core = require("youversion-linker.core")
local passage = core.main("John 3:16", "KJV") -- Get passage data

-- Version management  
local versions = require("youversion-linker.utils.versions")
versions.configure_versions({ ESV = { enabled = true } })
```

## 🏗️ Architecture

This plugin follows Neovim best practices:

### Modern Design Patterns
- **Type Safety**: Comprehensive LuaCATS annotations throughout
- **Lazy Loading**: Modules load on-demand, not at startup
- **Separation of Concerns**: Clean separation between config, UI, and logic
- **Error Handling**: Robust error handling with graceful fallbacks

### Module Structure
```
youversion-linker/
├── main.lua          # Primary interface and menu management
├── config.lua        # Configuration handling with validation
├── core.lua          # Core Bible reference processing
├── autocmd.lua       # Automatic triggering system
├── parser.lua        # Reference parsing utilities
├── cursor.lua        # Cursor position and context detection
├── menu.lua          # Popup menu creation and management
├── replacer.lua      # Text insertion and formatting
└── utils/
    ├── build_url.lua     # URL construction
    ├── extract_verse.lua # Passage extraction from HTML
    ├── get_html_page.lua # HTTP requests (using Neovim built-ins)
    ├── book_lookup.lua   # Book name and version resolution
    ├── regex_utils.lua   # Reference pattern matching
    ├── regex_patterns.lua # Regex patterns for Bible references
    └── versions.lua      # Version management
```

## 🌟 Advanced Features

### Custom Bible Versions

```lua
-- Add custom versions or override defaults
require("youversion-linker").setup({
  bible_versions = {
    -- Enable/disable predefined versions
    KJV = { enabled = true },
    NIV = { enabled = false },
    
    -- Add custom versions (must be available on YouVersion)
    CUSTOM = { enabled = true },
  }
})
```

### Multiple Language Support

The plugin supports multiple languages through YouVersion's API:

```lua
-- Not yet implemented in UI, but API-ready
local lookup = require("youversion-linker.utils.book_lookup")
local book_code = lookup.getBook("约翰福音", "chs") -- Chinese Simplified
local version_id = lookup.getVersionId("chs", "CUV") -- Chinese Union Version
```

### Programmatic Access

```lua
-- Direct API access for integration with other plugins
local core = require("youversion-linker.core")

-- Get passage data without UI
local passage_data = core.main("Psalm 23", "KJV")
print(passage_data.verses) -- "The LORD is my shepherd..."
print(passage_data.url)    -- "https://www.bible.com/bible/..."

-- Get available versions
local versions = require("youversion-linker.utils.versions").get_bible_versions()
```

## 🔍 Troubleshooting

### Common Issues

**Popup doesn't appear:**
- Check that your filetype is enabled in configuration
- Verify the trigger characters (`>`, `@`, `^`) are being used

**Passages not loading:**
- Check internet connection
- Verify YouVersion API accessibility

**Configuration issues:**
```lua
-- Enable debug mode
vim.g.youversion_linker_debug = true
```

### Debugging

```lua
-- Check current configuration
:YouVersionConfig

-- Manually trigger the plugin
:YouVersionLink

-- Check Neovim version compatibility
:version  # Requires Neovim 0.9+
```

## 🚧 TODO / Roadmap

### High Priority
- [ ] Replace external dependencies (luasocket, rex_pcre) with Neovim built-ins
- [ ] Implement proper lazy loading for all modules
- [ ] Add comprehensive test suite
- [ ] Create proper help documentation (`:help youversion-linker`)

### Medium Priority
- [ ] Add support for custom reference patterns
- [ ] Implement proper session management for HTTP requests
- [ ] Add more configuration validation
- [ ] Improve error handling and user feedback

### Low Priority
- [ ] Add support for multiple Bible translations in parallel
- [ ] Implement bookmark/favorite passages system
- [ ] Add integration with note-taking plugins (Obsidian, etc.)
- [ ] Create visual demo GIFs for documentation

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Testing

```bash
# Run tests (coming soon)
make test

# Lint code
make lint

# Format code
make format
```

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed release notes.

### Recent Improvements
- **v0.3**: Complete rewrite following Neovim best practices
- **v0.2**: Added type annotations and configuration validation
- **v0.1**: Initial release with basic functionality

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [YouVersion](https://www.bible.com) for their excellent API and Bible resources
- [Neovim](https://neovim.io) team for the amazing editor and Lua ecosystem
- [nui.nvim](https://github.com/MunifTanjim/nui.nvim) for the fantastic popup components
- Inspired by [obsidian-youversion-linker](https://github.com/jaanonim/obsidian-youversion-linker)

## 📞 Support

- 📖 [Documentation](docs/README.md) - Detailed usage guide
- 🐛 [Issue Tracker](https://github.com/yourusername/youversion-linker.nvim/issues) - Report bugs or request features
- 💬 [Discussions](https://github.com/yourusername/youversion-linker.nvim/discussions) - Ask questions and share ideas

---

**Happy Bible studying!** 📖✨
