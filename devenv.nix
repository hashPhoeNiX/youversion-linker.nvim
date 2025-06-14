{ pkgs, lib, config, inputs, ... }:

let
  plugins = [
    # { 
    #   name = "present";
    #   path = ./present.nvim/lua; 
    # }
    # {
    #   name = "at_popup";
    #   path = ./at_popup.nvim/lua;
    # }
    {
      name = "youversion-linker";
      path = ./lua;
    }
    # Add more plugins as needed:
    # { name = "another"; path = ./path/to/plugin/lua; }
  ];

  youversion-libraries = with pkgs.lua51Packages; [
    luasocket
    luasec
    lrexlib-pcre
    cjson
    penlight
    jsregexp
    busted
  ];
in
{
  env = {
    GREET = "devenv";
    EDITOR = "nvim";
    # NVIM_TEST_CONFIG = ./. + "/test-config/nvim";
  };

  packages = with pkgs; [
    neovim
    tree
    lua
    ripgrep
    fd
    git
    lua-language-server
    lua51Packages.lua
    lua51Packages.luarocks
  ] ++ youversion-libraries;
  scripts = {
    hello.exec = ''echo hello from $GREET'';
    
    # Edit the test configuration
    edit-config.exec = ''$EDITOR "$NVIM_TEST_CONFIG/init.lua"'';
    
    # Reset to template configuration
    reset-config.exec = ''
      touch "$NVIM_TEST_CONFIG/init.lua"
      chmod u+w "$NVIM_TEST_CONFIG/init.lua"
      echo "Configuration reset to template"
    '';
  };

  enterShell = let
    configDir = "$PWD/test-config";
    nvimDir = "${configDir}/nvim";
    luaDir = "${nvimDir}/lua";
  in ''
    export NVIM_TEST_CONFIG="${nvimDir}"

    if [ ! -d "${configDir}" ]; then
      mkdir -p "${nvimDir}"
      echo "Created missing directory: ${configDir}/nvim"
    fi

    # Setup isolated Neovim config
    export XDG_CONFIG_HOME="${configDir}"
    mkdir -p "${luaDir}"

    # Create symlinks for all plugins
    # ${lib.concatMapStringsSep "\n" (plugin: ''
    #   if [ -d "${plugin.path}" ]; then
    #     if [ -f "${plugin.path}/${plugin.name}.lua" ]; then
    #       ln -sfn "${plugin.path}/${plugin.name}.lua" "${luaDir}/${plugin.name}.lua"
    #       echo "Linked plugin file: ${plugin.name}.lua"
    #     else
    #       ln -sfn "${plugin.path}" "${luaDir}/${plugin.name}"
    #       echo "Linked plugin directory: ${plugin.name}"
    #     fi
    #   else
    #     echo "Warning: Plugin source not found at ${plugin.path}" >&2
    #   fi
    # '') plugins}

    # Initialize config if missing
    if [ ! -f "${nvimDir}/init.lua" ]; then
      mkdir -p "${nvimDir}"
      touch "${nvimDir}/init.lua"
      chmod u+w "${nvimDir}/init.lua"  # Make writable
      echo "Created init.lua from template (editable at $NVIM_TEST_CONFIG/init.lua)"
    else
      # Ensure existing config is writable
      chmod u+w "${nvimDir}/init.lua" 2>/dev/null || true
    fi

    echo "Plugins available:"
    echo "  present: require('present')"
    echo ""
    echo "Quick access commands:"
    echo "  edit-config   - Edit the test configuration"
    echo "  reset-config  - Reset config to template"
    echo "Run 'nvim' to start testing"
  '';

  enterTest = ''
    echo "Environment verification:"
    echo -n "Neovim version: "
    nvim --version | head -1
    echo "Plugin links in $NVIM_TEST_CONFIG/lua:"
    ls -l "$NVIM_TEST_CONFIG/lua"
    echo ""
    echo "Configuration status:"
    [ -w "$NVIM_TEST_CONFIG/init.lua" ] && 
      echo "init.lua is writable" || 
      echo "WARNING: init.lua is not writable"
  '';
}
