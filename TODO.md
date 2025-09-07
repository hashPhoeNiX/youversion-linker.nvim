1. Create a table of verses
2. Fetch all the bible passage fpr each verse that's enabled
3. Add the results to the returned table
4. Find a way to run that asynchronously
5. Create a nui popup with the items as different bible versions.
6. Fetch the bible verse corresponding to the version selected either by generating the url and fetvhing from there or using the above approach.


[2025-06-19 00:50]
- [x] Adjust popup to fetch the bible passage from the display text and parse that into the function to fetch the verse
[ ] Add a trigger for character detection
- [x] Auto update menu popup as letters are being typed
- [x] Fix issue of reading books that starts with numbers, such as 1 John, etc.

[2025-08-26 23:44]
- [-] add caching for popup bible text display
- [-] find a faster alternative to luasocket fetching the bible.com page
- [-] code refactor
- [-] update readme
- [-] add documentation
- [-] Test plugin with obsidian nvim
- [-] Replace default menu navigation with autocmd which allows users to add their own keymaps

[2025-09-03 20:36]
# TODO: nvim-best-practices Compliance

- [ ] **Add a LICENSE file** (MIT recommended).
- [ ] **Add a CONTRIBUTING.md** with guidelines for contributors.
- [ ] **Add a minimal, reproducible config in the README** for quick testing.
- [ ] **Add a screenshot or GIF** showing plugin usage.
- [ ] **Add a CI workflow** (e.g., GitHub Actions) for linting and tests.
- [ ] **Add a stylua.toml** for consistent Lua formatting.
- [ ] **Add a .luacheckrc** for linting.
- [ ] **Add a CHANGELOG.md** for tracking changes.
- [ ] **Add a SECURITY.md** for vulnerability reporting.
- [ ] **Add a badge for CI status** in the README.
- [ ] **Add a badge for version or downloads** in the README.
- [ ] **Add a badge for license** in the README.
- [ ] **Add plugin metadata to your rockspec** (if publishing to luarocks).
- [ ] **Add a test suite** (unit tests for Lua modules).
- [ ] **Add a `:help` doc** (in `doc/youversion-linker.txt`).
- [ ] **Add a `setup()` function** that does not have side effects.
- [ ] **Avoid global variables and side effects** in your Lua modules.
- [ ] **Use `require("youversion-linker")` as the main entry point.**
- [ ] **Support Neovim’s plugin manager conventions** (e.g., lazy-loading).
- [ ] **Document all public APIs** in README and/or help file.
- [ ] **Add clear error messages and logging** for troubleshooting.
- [ ] **Add support for Neovim’s `:messages` and `vim.notify`.**
- [ ] **Add support for user configuration overrides.**
- [ ] **Add support for disabling/enabling features via config.**
- [ ] **Add support for custom keymaps.**
- [ ] **Add support for custom filetypes.**
- [ ] **Add support for custom popup appearance.**
- [ ] **Add support for internationalization/localization (optional).**

[2025-09-07 22:42]

- [-] Add Bible book completion
- [-] Order the bible version menu items or allow users to determine the order of display


