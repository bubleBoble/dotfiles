# Dotfiles Repository Guide

## Scope & Editing

- This repository manages tool configurations through Linux symlinks and Windows copies.
- Edit repository sources, never installed symlink targets such as `~/.config/nvim/init.lua`.
- Identify the affected tool and platform before editing; ask when tool-specific behavior is materially ambiguous.
- Write READMEs for humans: purpose, setup, usage, and necessary warnings.
- Put coding-agent workflow and maintenance instructions in `AGENTS.md`, not READMEs.
- Keep the root README concise; link to tool-specific READMEs for detailed human-facing guidance.
- Update this guide when repository structure changes.
- Read [README.md](README.md) for installation, updates, removal, and deployment behavior.

## Repository Map

- `agents/`: agent-specific configurations; `agents/shared/`: universal standards, skills, hooks, and extensions.
- `agents/external/`: third-party checkouts; deploy assets directly from them.
- `nvim/`: Neovim; shared dependency specs live in `lua/plugins/deps/`.
- `tmux/` and `zsh/`: configurations with plugin submodules; clone with `--recurse-submodules` and preserve submodule changes.
- Read [zsh/README.md](zsh/README.md) before changing shell startup.
- `zed/` and `vscode/`: editor configurations; VS Code has `lin` and `win` variants.
- Read [vscode/README.md](vscode/README.md) for extensions, shortcuts, and editor differences.
- `tern/`: shared terminal settings and CSS themes for Linux and Windows; see [tern/README.md](tern/README.md) for setup and sync-back.
- `agents/dsh/`: DSH Web profile and Linux launcher, selected with `dsh`.
- Read [agents/dsh/README.md](agents/dsh/README.md) before changing profile migration or backup scope.
- Other tool directories: `kitty/`, `vim/`, `yazi/`, `herdr/`, `gdb/`, and `gnome/`; `future/` holds experimental or archived configurations.

## Manifests & Deployment

- `install` selects `config_linux.conf` on Linux/WSL and `config_windows.conf` on Windows, including Git Bash.
- Each manifest is complete; update both for shared mappings and only the applicable manifest for platform-specific mappings.
- Use `[TOOL]` sections containing `SOURCE:TARGET` mappings, such as `./vim/vimrc:$HOME/.vim/vimrc`.
- Resolve sources relative to the manifest directory (repository root).
- Targets must be absolute after variable expansion; unresolved variables and relative targets are rejected.
- Use `$HOME` for home destinations and `$APPDATA` for Windows Zed.
- End both sides with `/*` for per-child mappings; use `/*/` on the source to select only directories.
- Section names must be nonempty and contain no whitespace or brackets; repeated sections are allowed.
- Mappings before a section and malformed section headers are rejected before install, removal, or sync-back.
- Ownership comes only from the section, not directory names; put shared assets and launchers under the owning tool.
- Add tools through new directories and manifest sections, not installer changes.
- Omitting tool names selects all configured tools; `agents` selects only `~/.agents`, not all coding agents.
- Linux source edits propagate through symlinks; installation preserves existing symlinks, including dangling ones.
- On Windows, rerun `./install install TOOL` and confirm listed overwrites to update installed copies.
- Use `./install sync-back --include-files TOOL` to bring installed edits into the repository; without the flag, repository contents remain unchanged.
- After manifest changes, run `./install install` with a temporary `HOME` and, on Windows, temporary `APPDATA`.
- Verify Linux symlink destinations and Windows copy destinations; restart affected tools to reload cached configurations.

## Agent Assets

- Edit `agents/shared/AGENTS.md` for universal standards and agent-specific files for agent-specific rules.
- Add local skills at `agents/shared/skills/<skill-name>/SKILL.md` with `name` and `description` frontmatter, instructions, and examples.
- Add hooks under `agents/shared/hooks/pre/` or `agents/shared/hooks/post/`.
- Deploy Matt Pocock skills directly from `agents/external/matpocock_skills_repo`.
- Reserve `agents/shared/skills` for locally maintained or other-source skills.
- Keep directory-only wildcards for the engineering, productivity, and misc categories in both manifests; exclude category READMEs and experimental skills.
- Select `zed agents` when installing Zed with shared skills.
- After migrating asset sources, follow [Refreshing agent symlinks](README.md#refreshing-agent-symlinks); installation alone does not replace Linux symlinks.

## Editor Conventions

- Keep Zed and VS Code settings and keymaps aligned where supported; document unavoidable differences in `vscode/README.md`.
- Organize `zed/keymap.json` into shared shortcuts, default-binding overrides, and Vim-only editor shortcuts with slash-banner comments.
- Keep mode-independent bindings in the shared section, even for Vim-style keys.
- Zed uses its managed Ruff language server for Python formatting and linting, including `Alt+Shift+F` format selection.
- Editor formatting reads `[tool.ruff]` in each project's `pyproject.toml`, not `[tool.black]`; global Black is not required.
- Use four-space shell indentation for editing and formatting; see [Tool requirements](README.md#tool-requirements) for `shfmt`.

## Tests & Formatting

- Run Python tests and formatting from the repository root using persistent `tests/.venv`; manage it with `venv` and `pip`, not `uv`.
- Create the environment if missing: `python3 -m venv tests/.venv`.
- Install test dependencies: `tests/.venv/bin/python -m pip install pytest black`.
- Run all tests: `tests/.venv/bin/python -B -m pytest`.
- For installer tests only, append `tests/test_install.py`.
- Format Python tests: `tests/.venv/bin/python -m black tests/`.
- Keep Black, Ruff, and pytest conventions in `pyproject.toml`, with matching Black and Ruff line lengths.
- Activation is unnecessary; on native Windows, create the environment with `python` and use `tests/.venv/Scripts/python.exe`.
- After changing the OpenCode changes plugin, run `node --test agents/opencode/plugins/changes/changes.test.mjs` from the repository root.
