# DSH

With DSH installed, run before first launch:

```sh
./install --install dsh
dsh plugin --profile web install
dsh web
```

Includes your Web settings, plugins, **dsh-any-background theme and presets**, shared skills, and desktop launcher. Sign in separately; credentials and sessions stay local.

Existing setup: stop DSH, back up the existing targets listed in [config.conf](../config.conf), then rerun installation. Existing targets are never overwritten.

The theme directory is symlinked so theme saves (including future wallpaper/font uploads) land in the repo. Review changes before committing and pushing. No theme export/import needed.
