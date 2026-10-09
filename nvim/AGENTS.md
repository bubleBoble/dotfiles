# Neovim Config Rebuild

This directory is a fresh Neovim configuration being rebuilt from the beginning. Use the revived old configuration in `../nvim copy` as the reference for prior behavior and mappings, and preserve this rebuild's architecture:

- `init.lua` loads core modules and calls `require('lazy').setup(...)`.
- `lua/core/options.lua`, `keymaps.lua`, `autocommands.lua`, and `usercommands.lua` hold editor-wide settings and commands.
- `lua/core/lazyinit.lua` bootstraps lazy.nvim.
- `lua/plugins/` contains individual plugin specifications and configuration.
- `lua/plugins/deps/` holds standalone specs for shared dependencies; register each in `init.lua` and keep dependency links in consuming specs.
- Plugin repository references in specs and dependencies use full `https://github.com/owner/repository` URLs.
- Keep mappings in `lua/core/keymaps.lua` grouped under the plugin they control.
- Put general custom user commands in `lua/core/usercommands.lua`; keep `TSInstallConfigured` beside its local parser list in `lua/plugins/treesitter.lua`.
- Install Tree-sitter parsers and external formatter tools manually on each system; keep startup and plugin build steps free of parser or tool installation.

## Plugin workflow

Add plugins one at a time. For each plugin:

1. Before adding or explaining a plugin, update `nvim_setup_notes.md` with its purpose, dependencies, external tools, tradeoffs, default and configured keybindings, and current verification status. Add plugin entries as numbered steps so the notes remain a sequential record.
2. Explain its purpose, dependencies, external tools, tradeoffs, and all default and configured keybindings to the user.
3. Add only that plugin and its required configuration, keeping the existing architecture and options intact.
4. Install and exercise the plugin in Neovim. Check its health or diagnostics when available, and verify its key features and mappings in the relevant context. Report what was actually verified and any gaps; do not claim success without evidence.

Keep the plugin list empty until the user chooses a plugin to add. Keep `nvim_setup_notes.md` organized as sequential steps and update it whenever a plugin is added or explained. Update this file as the rebuild progresses if the user changes these guidelines.
