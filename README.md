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

Matt Pocock skills deploy directly from `agents/external/matpocock_skills_repo`; `agents/shared/skills` holds only locally maintained or other-source skills. Both manifests use directory-only wildcards for the engineering, productivity, and misc categories, excluding category READMEs and experimental skills.

After migrating from shared copies, replace existing Linux deployment symlinks (installation alone preserves even dangling symlinks):

```sh
./install --remove claude pi omp codex dsh zed
./install --install claude pi omp codex dsh zed
```

These commands refresh all managed symlinks for the selected agents, leaving regular files untouched. On Windows, back up existing skill copies before replacing them; deployments remain copies rather than links.

Linux uses symlinks. Windows copies files and directories without requiring symlink privileges; installed copies do not update automatically when the repository changes. Use `--sync-back TOOL` to bring edits from installed copies back into the repository.

The Windows manifest omits tmux, zsh, and the Linux DSH desktop launcher. Zed uses `$APPDATA/zed` on Windows and `$HOME/.config/zed` on Linux. Git Bash needs Python 3 available as `python3` for `./install`, or run `python install --install` with native Windows Python.

Add mappings to each applicable platform manifest using `SOURCE:TARGET`. Sources are relative to the manifest's directory; targets must expand to absolute paths. Undefined variables are rejected before installation, removal, or sync-back. Existing targets are preserved during installation.

End source and target paths with `/*` to deploy every direct child, preserving names. Use `/*/` on the source and `/*` on the target to deploy only child directories, skipping files such as category READMEs.

Run all tests with `python3 -B -m unittest discover -s tests -v`, or only installer tests with `python3 -B -m unittest discover -s tests -p test_install.py -v`.
