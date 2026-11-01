# Dotfiles

## Setup

```sh
git clone --recurse-submodules -j8 https://github.com/bubleBoble/dotfiles.git
cd dotfiles

./install install             # All tools
# Or select tools; agents installs shared ~/.agents files:
./install install zed agents

./install help
./install help install

# Native Windows (Git Bash uses the commands above and needs python3):
python install install
```

See individual tool READMEs for additional setup.

## Updating and removing configurations

```sh
git pull
git submodule update --recursive
./install install             # Refresh installed configurations; restart affected tools

./install remove zed          # Omit tool names to remove all
# Linux removal preserves regular files unless --include-files is supplied.

# Copy installed edits back; replaces repository files and whole mapped directories:
./install sync-back --include-files zed
# Symlinked targets are skipped; without --include-files, nothing is copied back.
```

Back up installed edits before reinstalling on Windows: overwrites require confirmation, but no backups are created. Directory copies merge; replacing a directory with a file removes its contents. Destination symlinks are replaced, not followed.

### Refreshing agent symlinks

```sh
# Linux: replace old asset links after migration; regular files remain untouched.
# Installation alone preserves existing links, including dangling ones.
./install remove claude pi omp codex dsh zed
./install install claude pi omp codex dsh zed
# Windows: reinstall only; no removal needed.
```

## Tool requirements

Zed shell formatting needs `shfmt` on `PATH`, with Zsh support when editing Zsh files.
