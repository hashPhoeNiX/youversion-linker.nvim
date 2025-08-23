return {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = {
    'devenv.nix',
    '.direnv',
    '.devenv',
    '.luarc.json',
    '.luarc.jsonc',
    '.luacheckrc',
    '.stylua.toml',
    'stylua.toml',
    '.git',
  },
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        path = vim.split(package.path, ';'),
      },
      diagnostics = {
        globals = { 'vim' },
        workspaceDelay = -1,
      },
      workspace = {
        -- library = vim.api.nvim_get_runtime_file('', true),
        library = { vim.env.VIMRUNTIME },
        maxPreload = 1000,
        preloadFileSize = 1000,
        checkThirdParty = false,
        ignoreSubmodules = true,
      },
      telemetry = { enable = false },
    },
  },
}
