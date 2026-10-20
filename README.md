Clone with:
```sh
git clone --recurse-submodules -j8 https://github.com/bubleBoble/dotfiles.git
```

The installer automatically selects `config_windows.conf` on Windows (including
Git Bash), or `config_linux.conf` on Linux and WSL. Each manifest lists that
platform's tools and target paths; shared configuration sources stay in the same
repository.

Install all tools listed for your platform with `./install install`, or select
individual tools:

```sh
./install install claude
./install install codex
./install install dsh
./install install vim
./install install claude codex dsh
```

Run `./install help` for full CLI help, or `./install help install` for
installation options. Help is available only through the `help` command; `-h`
and `--help` are not supported.

## Manifest and deployment behavior

The same tool selection works with `remove` and `sync-back`; `agents` selects
only `~/.agents`, not all coding agents.

Linux uses symlinks. Windows copies files and directories without requiring
symlink privileges; installed copies do not update automatically when the
repository changes. Use `./install sync-back --include-files TOOL` to bring
edits from installed copies back into the repository.

On Windows, installation lists existing destination files that will be
overwritten and asks for confirmation once, before making any changes. Enter `y`
or `yes` to continue; any other answer, Enter, or closed input cancels the whole
installation. No force flag is needed. Directory copies merge repository
contents into the destination and preserve destination-only files. If a file
must replace a directory, the prompt lists that directory and its contents
before replacement. Existing destination symlinks are replaced, not followed.
Back up installed edits before confirming; installation does not create backups.

Without `--include-files`, sync-back skips copying and leaves repository files
and directories unchanged. With the flag, selected repository sources are
replaced with installed copies; directory mappings replace the whole directory
rather than merge it. Symlinked targets are always skipped. Run `./install help
sync-back` for the command's options.

The Windows manifest omits tmux, zsh, and the Linux DSH desktop launcher. Zed
uses `$APPDATA/zed` on Windows and `$HOME/.config/zed` on Linux. Git Bash needs
Python 3 available as `python3` for `./install`, or run `python install install`
with native Windows Python.

## Tool requirements

Zed shell formatting requires `shfmt` on `PATH`. Use a version with Zsh support
when editing Zsh files.
