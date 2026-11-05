# Tern

Shared Tern terminal settings and CSS themes for Linux and Windows. Login credentials, sessions, file history, logs, and runtime state stay on each machine.

## Setup

1. Install [Tern](https://stencil.so/) and sign in on the new machine if prompted.
2. Install [Comic Shanns Mono Nerd Font](https://www.nerdfonts.com/font-downloads), the font selected in these settings.
3. Quit Tern before installing the settings.
4. From the repository root, run:

   ```sh
   ./install install tern
   ```

   On native Windows without Git Bash, use:

   ```powershell
   python install install tern
   ```

5. Start Tern again.

The installer symlinks `settings.json` and `themes/` into `~/.config/tern/` on Linux. On Windows, it copies `settings_windows.json` as `%APPDATA%\Tern\settings.json` and copies `themes/` alongside it. These are Tern's [default configuration directories](https://docs.stencil.so/tern/concepts/packages.html#directories); custom `XDG_CONFIG_HOME` or `TERN_CONFIG_DIR` locations are not targeted.

If settings already exist, back them up first. Windows lists the file and asks before overwriting it. Linux leaves existing files and symlinks unchanged: after backing up, move an existing regular `settings.json` out of the way and rerun the install command.

The Windows settings select Git Bash at `C:/Users/adam.domrazek/AppData/Local/Programs/Git/bin/bash.exe`; change `shell` in `settings_windows.json` if Git is installed elsewhere. Tern starts it as a login shell. Linux keeps its default shell.

## Sidebar appearance

The `dark-cosmos-sidebar` theme inherits `dark-cosmos` and displays hosts, sessions, and tabs as three indented levels. Rounded outlines sit inside each button, leaving space between neighboring outlines without changing Tern's tab-row sizing. Borders use the theme's subtle line color; host and session headings use secondary text with bold and semibold weights. Tab labels use normal weight. Native hover backgrounds and active-tab highlights stay unchanged. No plugin is needed.

Edit `themes/dark-cosmos-sidebar.css` to adjust the sidebar. Select `dark-cosmos` in Settings › Appearance › Theme to return to the stock appearance. See Tern's [custom themes](https://docs.stencil.so/tern/guides/themes.md).

## Herdr-style shortcuts

These bindings apply on Linux and Windows. Press and release `Ctrl+A` before each prefix sequence.

| Action | Keys after `Ctrl+A` |
| --- | --- |
| Split side by side | `%` |
| Split top/bottom | `"` |
| Focus pane left/down/up/right | `h` / `j` / `k` / `l`, or arrow keys |
| Next/previous pane | `Tab` / `Shift+Tab` |
| New tab | `c` |
| Select tab 1–9 | `1`–`9` |
| Rename tab | `,` |
| Close pane/tab | `x` / `Shift+X` |
| Toggle pane zoom | `z` |
| Toggle sidebar | `a` |
| Resize divider left/down/up/right | `r`, then `h` / `j` / `k` / `l`, or an arrow key |

Switch tabs directly with `Alt+Left` / `Alt+Right` or `Alt+H` / `Alt+L`.

Resizing is a three-key sequence, not Herdr's persistent resize mode: repeat `Ctrl+A`, `r`, direction for each adjustment. Herdr workspace navigation, indexed workspace selection, and detach are not mapped because Tern does not document equivalent actions. Other Tern default shortcuts remain available except where these bindings override them.

The prefix consumes `Ctrl+A`, so it no longer goes straight to the shell's start-of-line shortcut. When running Herdr inside Tern, these shared shortcuts are handled by Tern first.

See Tern's [binding syntax](https://docs.stencil.so/tern/guides/commands.html#binds) and [built-in actions](https://docs.stencil.so/tern/reference/actions.html).

## Save later changes

On Windows, quit Tern, then copy its installed settings back into this repository:

```sh
./install sync-back --include-files tern
```

Use `python install sync-back --include-files tern` on native Windows. Review the settings before committing, then commit and push the changes. On the other machine, pull the repository; rerun installation on Windows to refresh its copy, then restart Tern.

On Linux, edit the repository's `tern/settings.json`; the installed symlink points to it. If you change settings through Tern, check that the installed file remains a symlink before relying on it to update the repository.
