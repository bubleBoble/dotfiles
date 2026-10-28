# OpenCode

Run `./install install opencode` from the repository root to deploy shared rules,
the same local and external skills as OMP, and the configuration files in this
directory to `$HOME/.config/opencode/` on both platforms.

## Configuration

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
