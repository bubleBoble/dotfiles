# DSH Linux desktop app

## Purpose

A launcher for the existing DSH Web UI. It starts `dsh web` and opens Google Chrome or Chromium in **app mode**: a separate window without tabs or an address bar. No GTK/WebKit wrapper or changes to DSH are needed.

**Closing the browser app window stops the server started by the launcher.** Ctrl+W also closes it; Chrome reserves this shortcut, so the launcher cannot reliably prevent it. Closing stops ongoing work served by that DSH instance.

## Requirements

- Linux with a graphical desktop; this setup targets GNOME.
- Python 3.8 or newer, available as `python3`.
- Google Chrome or Chromium on PATH.
- DSH installed with its supported Node.js version; `dsh web` must work.
- Port 3080 free before launching.
- Zenity is optional for error dialogs.

The installer creates symlinks only; it does not install these dependencies.

## Installation

From the dotfiles repository root:

```sh
./install --install dsh
```

| Source | Purpose |
|--------|---------|
| [dsh-desktop](<dsh-desktop>) | Server and browser launcher |
| [dsh-desktop.desktop](<dsh-desktop.desktop>) | Application-menu entry |
| [dsh-desktop.svg](<dsh-desktop.svg>) | Application icon |

Installed locations:

```text
~/.local/bin/dsh-desktop
~/.local/share/applications/dsh-desktop.desktop
~/.local/share/icons/hicolor/scalable/apps/dsh-desktop.svg
```

Search for **DSH** in GNOME's application menu, then pin it to the dock if desired. Existing symlinks pick up launcher updates without reinstalling or refreshing the menu. The `dsh` installation selection also includes shared DSH instructions and skills.

**GNOME caution:** a previous installation coincided with a GNOME Shell segmentation fault while refreshing the applications menu, ending the desktop session. That menu-refresh bug is unresolved. Do not repeatedly reinstall or explicitly refresh the menu to troubleshoot this launcher.

## Launching and closing

Launch from the application menu, or:

```sh
~/.local/bin/dsh-desktop
```

Check dependencies without starting anything:

```sh
~/.local/bin/dsh-desktop --check
```

The launcher:

1. Holds a lock so repeated clicks do not start duplicate instances.
2. Refuses to launch if port 3080 is occupied. It never takes over or stops an externally started server; stop your terminal instance manually first.
3. Starts `dsh web --no-open --host 127.0.0.1 --port 3080`, initially in your home directory.
4. Waits for the authenticated startup URL, then opens it in a dedicated browser profile. Your ordinary Chrome windows are not used or stopped.
5. Waits for that browser to exit. Background browser mode is disabled so closing its last window permits shutdown.
6. Stops its owned server process group, allowing up to 10 seconds for graceful shutdown before force-stopping remaining group members.

Use the close button, Alt+F4, or Ctrl+W to quit. If you open additional windows within the dedicated profile, shutdown waits until those are closed too. Startup errors, browser failure, and handled termination signals also clean up owned processes. SIGKILL of the launcher itself cannot run cleanup.

DSH's configuration and saved sessions are unchanged. Old WebKit profile files are left untouched and are no longer used. Browser cookies and UI preferences live in the dedicated Chrome profile.

## Troubleshooting and local data

```text
~/.local/state/dsh-desktop/server.log     Server output
~/.local/state/dsh-desktop/browser.log    Browser output
~/.local/state/dsh-desktop/launch.lock    Lifetime lock
~/.config/dsh-desktop/chrome/             Dedicated browser profile
```

State directories and logs are private. **Do not share unredacted logs: they may contain authenticated URLs or other sensitive diagnostics.** `XDG_STATE_HOME` and `XDG_CONFIG_HOME` override the base directories.

- **Port 3080 occupied:** stop the existing server yourself.
- **No browser found:** install Google Chrome or Chromium and ensure it is on PATH.
- **DSH not found:** the launcher checks PATH, then the newest NVM installation containing DSH. Set `DSH_DESKTOP_DSH` to an executable path if needed; `NVM_DIR` selects a nonstandard NVM directory.
- **Startup or browser failure:** run the launcher from a terminal and inspect the corresponding private log.

Environment overrides must exist in the desktop launch environment, not just an interactive shell. The launcher does not change GNOME settings or the DSH frontend.

## Removal

Close the app, then run from the repository root:

```sh
./install --remove dsh
```

This removes the installed DSH symlinks, including shared instructions and skills. It does not stop an open app or delete its runtime data.
