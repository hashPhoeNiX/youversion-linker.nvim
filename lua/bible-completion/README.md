# Bible Completion Plugin - Suggested File Structure

## Directory Structure
```
lua/
├── bible-completion/
│   ├── init.lua                 # Main entry point and setup
│   ├── config.lua              # Configuration management
│   ├── state.lua               # State management
│   ├── completion.lua          # Completion logic
│   ├── ui/
│   │   ├── menu.lua            # Menu creation and positioning
│   │   └── popup.lua           # Popup positioning utilities
│   ├── bible/
│   │   ├── parser.lua          # Bible reference parsing
│   │   ├── versions.lua        # Bible version management
│   │   └── loader.lua          # Book abbreviations loader
│   └── utils/
│       ├── keymaps.lua         # Temporary keymap management
│       └── autocmds.lua        # Autocmd setup and management
```

## File Responsibilities

### `init.lua` (Main Entry Point)
- Plugin setup and initialization
- Public API functions
- Integration with other modules
- Main autocmd setup

### `config.lua` (Configuration)
- Default configuration
- Configuration validation
- Runtime configuration updates
- Configuration merging utilities

### `state.lua` (State Management)
- Centralized state object
- State cleanup functions
- State validation
- State debugging utilities

### `completion.lua` (Core Logic)
- Bible passage detection
- Completion item generation
- Reference position tracking
- Main completion orchestration

### `ui/menu.lua` (Menu UI)
- NUI menu creation
- Menu event handling
- Selection management
- Menu lifecycle

### `ui/popup.lua` (Popup Positioning)
- Position calculation algorithms
- Popup repositioning logic
- Collision detection
- Screen boundary handling

### `bible/parser.lua` (Bible Parsing)
- Bible reference detection
- Reference parsing logic
- Reference validation
- Text position tracking

### `bible/versions.lua` (Bible Versions)
- Version definitions
- Version enabling/disabling
- Version formatting
- Version metadata

### `bible/loader.lua` (Data Loading)
- Book abbreviations loading
- JSON parsing
- Error handling for missing files
- File path resolution

### `utils/keymaps.lua` (Keymap Utils)
- Temporary keymap creation
- Keymap cleanup
- Navigation handling
- Key binding utilities

### `utils/autocmds.lua` (Autocmd Utils)
- Autocmd group management
- Event handler setup
- Timer management
- Cleanup automation

## Benefits of This Structure

1. **Separation of Concerns**: Each file has a single, clear responsibility
2. **Easier Testing**: Individual modules can be tested in isolation
3. **Better Maintainability**: Changes to UI don't affect parsing logic
4. **Cleaner Dependencies**: Clear module boundaries and imports
5. **Reusability**: Components can be reused in other contexts
6. **Debugging**: Easier to trace issues to specific modules
7. **Performance**: Only load what's needed when it's needed

## Migration Strategy

1. **Start with Config**: Extract configuration first as it's used everywhere
2. **Extract State**: Move state management to its own module
3. **Split UI Logic**: Separate menu creation from positioning logic
4. **Bible Logic**: Extract all Bible-specific parsing and loading
5. **Utilities Last**: Move utility functions to their own modules
6. **Refactor Main**: Clean up main file to orchestrate modules

## Key Considerations

- Keep interfaces between modules clean and minimal
- Use dependency injection where possible
- Maintain backward compatibility during migration
- Consider lazy loading for performance
- Document module interfaces clearly
- Use consistent error handling patterns across modules
