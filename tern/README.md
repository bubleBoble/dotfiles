# Tern

Shared Tern terminal settings for Linux and Windows. Only `settings.json` is managed; login credentials, sessions, file history, logs, and runtime state stay on each machine.

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

The installer symlinks `~/.config/tern/settings.json` on Linux and copies `%APPDATA%\Tern\settings.json` on Windows. These are Tern's [default configuration directories](https://docs.stencil.so/tern/concepts/packages.html#directories); custom `XDG_CONFIG_HOME` or `TERN_CONFIG_DIR` locations are not targeted.

If settings already exist, back them up first. Windows lists the file and asks before overwriting it. Linux leaves existing files and symlinks unchanged: after backing up, move an existing regular `settings.json` out of the way and rerun the install command.

## Save later changes

On Windows, quit Tern, then copy its installed settings back into this repository:

```sh
./install sync-back --include-files tern
```

Use `python install sync-back --include-files tern` on native Windows. Review the settings before committing, then commit and push the changes. On the other machine, pull the repository; rerun installation on Windows to refresh its copy, then restart Tern.

On Linux, edit the repository's `tern/settings.json`; the installed symlink points to it. If you change settings through Tern, check that the installed file remains a symlink before relying on it to update the repository.
