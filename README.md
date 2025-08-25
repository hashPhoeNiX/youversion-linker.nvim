# youversion-linker.nvim

This neovim plugin is inspired by the [obsidian-youversion-linker](https://github.com/jaanonim/obsidian-youversion-linker)


### Dependencies

This plugin requires the following Lua rocks. Please add this configuration to your `lazy.nvim` setup to ensure they are installed:

```lua
-- ~/.config/nvim/lua/plugins/luarocks.lua
{
    "vhyrro/luarocks.nvim",
    priority = 1000, -- Very high priority is required, luarocks.nvim should run as the first plugin in your config.
    -- config = true,
    opts = {
        rocks = { 
            "fzy", 
            "pathlib.nvim ~> 1.0",
            "luasocket",
            "luasec",
            "lrexlib-pcre",
            "cjson",
            "penlight",
            "jsregexp",
            "busted",
        },
    },
},
```
