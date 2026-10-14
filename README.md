Clone with:
```sh
git clone --recurse-submodules -j8 https://github.com/bubleBoble/dotfiles.git
```

The installer automatically selects `config_windows.conf` on Windows (including Git Bash), or `config_linux.conf` on Linux and WSL. Each manifest lists that platform's tools and target paths; shared configuration sources stay in the same repository.

Install all tools listed for your platform with `./install --install`, or select individual tools:

```sh
./install --install claude
./install --install codex
./install --install dsh
./install --install vim
./install --install claude codex dsh
```

Shared agent instructions and skills follow the selected destination tool. The same
selection works with `--remove` and `--sync-back`; `agents` selects only `~/.agents`.

Linux uses symlinks. Windows copies files and directories without requiring symlink privileges; installed copies do not update automatically when the repository changes. Use `--sync-back TOOL` to bring edits from installed copies back into the repository.

The Windows manifest omits tmux, zsh, and the Linux DSH desktop launcher. Zed uses `$APPDATA/zed` on Windows and `$HOME/.config/zed` on Linux. Git Bash needs Python 3 available as `python3` for `./install`, or run `python install --install` with native Windows Python.

Add mappings to each applicable platform manifest using `SOURCE:TARGET`. Sources are relative to the manifest's directory; targets must expand to absolute paths. Undefined variables are rejected before installation, removal, or sync-back. Existing targets are preserved during installation.

Run all tests with `python3 -B -m unittest discover -s tests -v`, or only installer tests with `python3 -B -m unittest discover -s tests -p test_install.py -v`.
