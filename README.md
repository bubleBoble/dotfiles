Clone with:
```sh
git clone --recurse-submodules -j8 https://github.com/bubleBoble/dotfiles.git
```

The installer automatically selects `config_windows.conf` on Windows (including Git Bash), or `config_linux.conf` on Linux and WSL. Each manifest lists that platform's tools and target paths; shared configuration sources stay in the same repository.

Install all tools listed for your platform with `./install install`, or select individual tools:

```sh
./install install claude
./install install codex
./install install dsh
./install install vim
./install install claude codex dsh
```

Run `./install help` for full CLI help, or `./install help install` for installation options. Help is available only through the `help` command; `-h` and `--help` are not supported.

## Manifest and deployment behavior

Shared agent instructions and skills belong to explicitly named tool sections. The same selection works with `remove` and `sync-back`; `agents` selects only `~/.agents`.

Matt Pocock skills deploy directly from `agents/external/matpocock_skills_repo`; `agents/shared/skills` holds only locally maintained or other-source skills. Both manifests use directory-only wildcards for the engineering, productivity, and misc categories, excluding category READMEs and experimental skills.

After migrating from shared copies, replace existing Linux deployment symlinks (installation alone preserves even dangling symlinks):

```sh
./install remove claude pi omp codex dsh zed
./install install claude pi omp codex dsh zed
```

These commands refresh all managed symlinks for the selected agents, leaving regular files untouched. On Windows, back up existing skill copies before replacing them; deployments remain copies rather than links.

Linux uses symlinks. Windows copies files and directories without requiring symlink privileges; installed copies do not update automatically when the repository changes. Use `./install sync-back --include-files TOOL` to bring edits from installed copies back into the repository.

Without `--include-files`, sync-back skips copying and leaves repository files and directories unchanged. With the flag, selected repository sources are replaced with installed copies; directory mappings replace the whole directory rather than merge it. Symlinked targets are always skipped. Run `./install help sync-back` for the command's options.

The Windows manifest omits tmux, zsh, and the Linux DSH desktop launcher. Zed uses `$APPDATA/zed` on Windows and `$HOME/.config/zed` on Linux. Git Bash needs Python 3 available as `python3` for `./install`, or run `python install install` with native Windows Python.

Add mappings to each applicable platform manifest under a `[TOOL]` section using `SOURCE:TARGET`. Each mapping belongs to the section's tool, regardless of its source or target directory. Adding a tool requires only a new section, not an installer change.

Section names must be nonempty and contain no whitespace or brackets. A section can repeat to add more mappings to the same tool. Mappings before the first section and malformed section headers are rejected before installation, removal, or sync-back.

Sources are relative to the manifest's directory; targets must expand to absolute paths. Undefined variables are rejected before installation, removal, or sync-back. Existing targets are preserved during installation.

End source and target paths with `/*` to deploy every direct child, preserving names. Use `/*/` on the source and `/*` on the target to deploy only child directories, skipping files such as category READMEs.

## Tests

Create a local virtual environment and install the test and formatting tools from the repository root:

```bash
python3 -m venv tests/.venv
tests/.venv/bin/python -m pip install pytest black
```

Run all tests through that environment:

```bash
tests/.venv/bin/python -B -m pytest
```

For installer tests only, append `tests/test_install.py`. Format Python tests with `tests/.venv/bin/python -m black tests/`. Black, Ruff, and pytest conventions are defined in `pyproject.toml`; keep the Black and Ruff line-length settings aligned.

Activation is not required. On native Windows, create the environment with `python` and use `tests/.venv/Scripts/python.exe` instead of `tests/.venv/bin/python`.

The global Zed configuration in `zed/settings.json` uses the Ruff language server for Python formatting and linting. This supports the `Alt+Shift+F` format-selection binding. Editor formatting reads `[tool.ruff]` in each project's `pyproject.toml`, not `[tool.black]`. Zed manages the Ruff language server; a global Black executable is not required.

Zed formats shell scripts with `shfmt`, which must be installed on `PATH`. Shell editing and formatting use four spaces per indentation level. Zsh-specific syntax requires a version of `shfmt` with Zsh support.
