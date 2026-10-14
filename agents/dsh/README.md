# DSH

With DSH installed, run before first launch:

```sh
./install install dsh
dsh plugin --profile web install
dsh web
```

Includes your Web settings, plugins, **dsh-any-background theme and presets**, and shared skills. Linux also installs the desktop launcher. Sign in separately; credentials and sessions stay local.

Existing setup: stop DSH, back up the existing targets listed in your platform's [Linux manifest](../../config_linux.conf) or [Windows manifest](../../config_windows.conf), then rerun installation. Existing targets are never overwritten.

On Linux, the theme directory is symlinked so theme saves (including future wallpaper/font uploads) land in the repo. On Windows, it is copied; use `./install sync-back --include-files dsh` to bring local changes back into the repo. Review changes before committing and pushing. No theme export/import needed.
