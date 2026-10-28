# OpenCode

Run `./install install opencode` from the repository root to deploy shared rules,
the same local and external skills as OMP, and the configuration files in this
directory to `$HOME/.config/opencode/` on both platforms.

## Configuration

The local `plugins/changes` TUI plugin lists changed files in the sidebar.
Click its heading or run `/changes` to toggle Git status and session changes.
Git status includes all uncommitted changes in the active session's directory.
Session changes compare the first through latest prompt using OpenCode snapshots;
snapshots must be enabled. Concurrent edits can appear in that comparison.
The initial mode is Git status. Data refreshes on server events and every three
seconds. The API groups untracked files as added and does not expose staging
details. Errors are shown rather than reported as a clean working tree.

Run the plugin's data-loading tests with:

```sh
node --test agents/opencode/plugins/changes/changes.test.mjs
```

- `opencode.json` holds runtime settings.
- `cli.json` holds OpenCode V2 terminal interface settings. Automatic copying on
  text selection is disabled with `terminal.copy: "manual"`.
- `tui.json` is the legacy terminal interface configuration.

Keep credentials outside this repository. OpenCode V2 reloads configuration
changes without a restart.

On Linux, installation preserves existing targets. Back up regular files and
move them aside if you want repository symlinks instead. Windows installation
asks before overwriting existing files.

See the OpenCode V2 documentation for [configuration](https://opencode.ai/v2/docs/config/),
[terminal settings](https://opencode.ai/v2/docs/cli/config/),
[instructions](https://opencode.ai/v2/docs/instructions/), and
[skills](https://opencode.ai/v2/docs/skills/).
