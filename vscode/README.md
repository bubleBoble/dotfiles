# VS Code configuration

Default-profile configuration translated from `../zed/settings.json` and `../zed/keymap.json`. VS Code calls its shortcut file `keybindings.json`, not `keymap.json`. Both files use JSON with comments (JSONC).

## Install

Run from the repository root:

```sh
./install install vscode
```

The installer manages only these two files:

| Platform | Destination |
|---|---|
| Linux / WSL | `~/.config/Code/User/settings.json` and `keybindings.json` |
| Windows | `%APPDATA%/Code/User/settings.json` and `keybindings.json` |

On Linux, move existing destination files or symlinks aside first: the installer preserves existing targets rather than replacing them. The new targets are symlinks, so later edits belong in this repository. On Windows, installation copies the files and asks before overwriting existing targets; rerun installation after repository edits. Use `./install sync-back --include-files vscode` to bring Windows edits back into the repository.

Use VS Code's **Default** profile. No named profiles, profile registrations, extension binaries, credentials, or workspace state are deployed. Leave Settings Sync off during migration so cloud settings do not replace the local configuration. Workspace settings in `.vscode/settings.json` and `*.code-workspace` files can still override these user settings. VS Code Insiders, VSCodium, portable mode, and custom `--user-data-dir` locations need different deployment paths.

Reload VS Code after installation. For a disposable preview, copy both files into a separate user-data directory's `User/` subdirectory and start `code --user-data-dir /path/to/preview --extensions-dir /path/to/preview-extensions`; this does not use the live default profile.

## Extensions and tools

Install the extensions used by the settings, with the Default profile active:

```sh
code --install-extension zhuangtongfa.material-theme
code --install-extension pkief.material-icon-theme
code --install-extension esbenp.prettier-vscode
code --install-extension charliermarsh.ruff
code --install-extension mkhl.shfmt
```

| Extension | Purpose |
|---|---|
| One Dark Pro (`zhuangtongfa.material-theme`) | Closest maintained theme to the active Zed theme |
| Material Icon Theme (`pkief.material-icon-theme`) | Explorer and editor file icons |
| Prettier (`esbenp.prettier-vscode`) | JSON, JSONC, and Markdown formatting |
| Ruff (`charliermarsh.ruff`) | Python formatting and linting |
| shfmt (`mkhl.shfmt`) | Shell formatting with four-space indentation |

Install **ComicShannsMono Nerd Font** on the host; the font itself is not in this repository. Install `shfmt` on `PATH`, using a version with Zsh support for Zsh scripts. In a remote window, install language extensions and formatter binaries on the remote host as appropriate.

For Python interpreter selection and type analysis, also install:

```sh
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
```

Zed's extension IDs are not VS Code extension IDs. HTML and Git support are built in. Lua, CMake, and TOML language tooling can be added separately; they are not silently installed by the dotfiles installer. The full collection of inactive Zed themes is not replicated.

## Editing and formatting

- Editor and terminal fonts use ComicShannsMono Nerd Font at 18 px. Editor font weight is 100; terminal font weight is 400. Ligatures are off.
- Vim is off by default. Word wrap, CodeLens, inlay hints, indentation guides, and cursor animation/blinking are off. Whitespace appears only in selections; sticky scroll and semantic highlighting remain on.
- Formatting is manual. Saving does not format files, trim trailing whitespace, or insert a final newline. Markdown explicitly keeps format-on-save off.
- JSON and JSONC use four spaces and Prettier. Python uses Ruff, with `RUF012` and `I001` ignored. Shell formatting uses shfmt with four spaces.
- `Alt+Shift+F` means **Format Selection**, matching Zed rather than VS Code's usual Format Document shortcut. A language provider must support range formatting. Use **Format Document** from the Command Palette when it does not.
- Project formatter configuration can override user defaults. Python formatting reads the project's Ruff configuration, not Black settings. Prettier reads project configuration when present.

## Shared shortcuts

These shortcuts work without Vim:

| Shortcut | Action |
|---|---|
| `Ctrl+Q` | Close the active text editor; does not quit the application elsewhere |
| `Ctrl+Shift+W` | Default Close Window binding removed |
| `Ctrl+K Ctrl+G` | Focus the built-in Source Control Graph |
| `Alt+R` | Toggle the terminal panel/focus |
| `Alt+Shift+Q` | Toggle the secondary sidebar |
| `Alt+E` | Maximize the active editor group, or the terminal panel when terminal-focused |
| `Ctrl+Shift+R` | Reveal the active file in Explorer |
| `Alt+Shift+T` | Toggle normal-layout editor tabs |
| `Alt+Shift+B` | Toggle breadcrumbs |
| `Alt+Shift+F` | Format the selection |
| `Ctrl+A A` | Select all in a text editor |
| `Ctrl+A H/J/K/L` or `Ctrl+A` then an arrow | Focus left/down/up/right |
| `Ctrl+A %` | Split a text editor right |
| `Ctrl+A "` | Split a text editor down |
| `Ctrl+A C` | Split an editor right, or split the active terminal |
| `Ctrl+A X` | Close an editor, or terminate the active terminal |
| `Ctrl+A Z` | Maximize an editor group or terminal panel |
| `Ctrl+A Ctrl+A` | Send a literal Ctrl+A to the terminal shell |
| Explorer `Space E` | Return focus to the active editor group |
| Explorer `Ctrl+H/J/K/L` | Move focus between workbench parts |

Chords are sequential: press and release `Ctrl+A`, then press the next key. `%`, `"`, and `?` are encoded as US-layout `Shift+5`, `Shift+'`, and `Shift+/`; adjust these bindings for another keyboard layout. `Ctrl+A` is a prefix in editors and terminals, not immediate Select All or shell beginning-of-line. Ordinary text inputs retain their normal selection behavior. Explorer bindings exclude rename/filter inputs.

Terminal chords are handled by VS Code, not sent to the shell. They can intercept a nested tmux session's prefix; use `Ctrl+A Ctrl+A` when the shell or tmux must receive Ctrl+A. In terminal split groups, left/up go to the previous split and right/down to the next split. This is split order, not Zed's geometric navigation. Outside a split group, directional commands navigate visible workbench parts.

## Optional Vim bindings

To enable the dormant Vim-only shortcuts, install `vscodevim.vim`, then set `vim.disableExtension` to `false`. It is explicitly `true` in this configuration so installing the extension alone does not change the current non-Vim behavior. Without that extension, its settings and command references are inactive and can appear as unknown in the editor.

In Normal and Visual modes, `Ctrl+E` / `Ctrl+Y` scroll two lines and `Ctrl+H/J/K/L` move focus. Normal mode also has:

| Shortcut | Action |
|---|---|
| `Shift+Up/Down/Left/Right` | Resize the editor layout by two VS Code increments |
| `Tab` / `Shift+Tab` | Next / previous editor in the current group |
| `Space E` | Focus Explorer |
| `Space ?` | Open user keyboard shortcuts JSON |
| `Space T T` | Toggle editor tabs |
| `Space T B` | Toggle breadcrumbs |

These bindings require an active VSCodeVim mode and do not intercept ordinary Insert-mode typing. Zed's two-step resize distance differs from VS Code's increments. Normal mode uses a block cursor, Insert mode a line cursor, and smartcase search is enabled.

## Differences and manual layout

- **Projects:** Zed's previous/next project shortcuts (`Alt+W`, `Alt+D`) and workspace sidebar (`Alt+Shift+W`) have no faithful built-in equivalent. They are not reassigned to unrelated editor-tab actions. Use VS Code's Open Recent/window commands for projects.
- **Layout:** move Explorer, Outline, and Source Control to the primary left sidebar, Chat to the right sidebar, and Terminal/Debug Console to the bottom as needed. Drag dividers to reproduce Zed's widths: Explorer 450 px, Git 800 px, agent 900 px, and terminal height 600 px. VS Code persists layout separately; user settings cannot reliably seed those pixel sizes, every view position, or the source's start-hidden behavior. The agent thread sidebar is extension-specific.
- **Zoom and splitting:** VS Code maximizes editor groups and panels through separate commands. Terminal `Ctrl+A C` follows VS Code's panel split orientation; directional terminal `%` / `"` splits are not implemented. Native VS Code terminal split shortcuts remain available.
- **Tabs:** the tab toggle changes the profile-wide normal-layout setting and restores multiple tabs, not a previous single-tab layout. Zen Mode can override it. Zed's per-pane tabbar state is not available.
- **Appearance:** One Dark Pro is used instead of One Dark Pro Glass. Glass/blur, Zed's exact chrome, separate 22 px UI font and agent font controls, close-button visibility details, title/branch widgets, and panel-specific toolbars do not map exactly. VS Code zoom scales the entire window, so it is not forced to imitate only Zed's UI font. The inactive Flexoki light theme is not selected or installed.
- **AI and collaboration:** Zed model IDs, subscriptions, edit-prediction provider, ACP servers, tool approvals, sandbox permissions, call muting, and agent thread UI do not transfer. VS Code AI tools need their own installation, sign-in, model selection, and permissions. No credentials or automatic tool approvals are copied.
- **Security:** Zed's trust-all-worktrees setting is deliberately not copied; VS Code Workspace Trust remains enabled.
- **Other editor details:** Zed's built-in which-key popup, exact multi-buffer previews, focus/mouse behavior, detailed scrollbar decorations, and Git avatar/path presentation have no complete one-to-one mapping. Existing VS Code behavior is retained where settings cannot reproduce them. Zed-specific unbindings for prediction ratings, agent actions, task rerun, and regex toggles are not translated into unrelated VS Code command removals.
- **Updates:** automatic application updates are disabled to match Zed. Update VS Code manually to receive security fixes.

## References

- [VS Code keyboard shortcuts, contexts, and removal rules](https://code.visualstudio.com/docs/configure/keybindings)
- [Terminal chords and shell key handling](https://code.visualstudio.com/docs/terminal/advanced)
- [Ruff VS Code settings](https://docs.astral.sh/ruff/editors/settings/)
- [shfmt extension](https://github.com/mkhl/shfmt)
- [VSCodeVim configuration](https://github.com/VSCodeVim/Vim#settings)
