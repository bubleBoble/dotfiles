# Dotfiles Repository Guide

This is a personal dotfiles repository for managing development environment configurations across multiple tools and terminals.

## What This Repository Is

A centralized configuration management system that maintains dotfiles (configuration files) for various tools and keeps them synced to the home directory via symlinks. This allows:
- Single source of truth for all configuration files
- Git-tracked changes to configurations
- Easy replication across machines via `git clone` and `./install --install`

## Repository Structure

### Directory Organization

| Directory | Purpose |
|-----------|---------|
| **agents/** | Coding agent configurations and shared standards |
| **agents/external/** | Third-party agent repositories; deploy assets directly from these checkouts |
| **nvim/** | Neovim editor config and plugins; `lua/plugins/deps/` holds shared dependency specs |
| **tmux/** | Tmux terminal multiplexer config (includes git submodules) |
| [**zsh/**](<zsh/>) | Zsh configuration and plugin submodules; see [zsh/README.md](<zsh/README.md>) when changing shell startup |
| **kitty/** | Kitty terminal emulator config |
| **vim/** | Vim editor config |
| [**vscode/**](<vscode/>) | Default-profile VS Code settings translated from Zed; see [vscode/README.md](<vscode/README.md>) for extensions, shortcuts, and differences |
| [**zed/**](<zed/>) | Zed editor configuration; install with `zed agents` for shared skills |
| **yazi/** | Yazi file manager config and themes |
| **herdr/** | Herdr terminal multiplexer config |
| **gdb/** | GDB debugger configuration |
| **gnome/** | GNOME desktop settings (dconf, extensions) |
| [**agents/dsh/**](<agents/dsh/>) | DSH Web profile and Linux desktop launcher (selected with `dsh`); see [agents/dsh/README.md](<agents/dsh/README.md>) for profile migration and backup scope |
| **future/** | Experimental or archived configs (vim) |

### Key Files

- **`config_linux.conf` / `config_windows.conf`** — Platform-specific source:target mappings and tool sets
- **`install`** — Automatically selects the platform manifest; symlinks on Linux, copies on Windows
- **`AGENTS.md`** — This file; project-level guidelines for all coding agents
- **`CLAUDE.md`** — Claude Code-specific guidelines

## How It Works

### Installation Flow

1. Clone the repository with submodules.
2. Run `./install install`.
3. Read `config_windows.conf` on Windows (including Git Bash), or `config_linux.conf` on Linux and WSL.
4. Create target directories as needed.
5. Create symlinks on Linux or copy files/directories on Windows.

### Platform Manifest Format

Format: `[TOOL]` sections containing `SOURCE:TARGET` mappings:
- **SOURCE** — Relative path resolved from the manifest's directory (the repository root)
- **TARGET** — Absolute destination after variable expansion (`$HOME`, or `$APPDATA` for Windows Zed); unresolved variables and relative targets are rejected before deployment
- **Per-child mappings** — End both sides with `/*` to create one mapping for each direct child while preserving its name. End the source with `/*/` instead to select only child directories
- **Tool selection** — Every mapping belongs to its explicit `[TOOL]` section until the next section header. Source and target directory names do not determine ownership. Put shared assets and launchers in the owning tool's section. Adding a tool requires a new section, not an installer change.

Section names must be nonempty and contain no whitespace or brackets. Sections may repeat to add mappings to the same tool. Mappings before the first section and malformed section headers are rejected before installation, removal, or sync-back.

Example:
```
[vim]
./vim/vimrc:$HOME/.vim/vimrc

[zsh]
./zsh/zshrc:$HOME/.zshrc

[claude]
./agents/shared/skills/*:$HOME/.claude/skills/*
```

Each manifest is complete; edit both when a mapping applies to both platforms. Linux-only tools belong only in `config_linux.conf`. Windows installations are copies: use `./install sync-back --include-files TOOL` to bring installed edits back into the repository. Without `--include-files`, sync-back leaves repository files and directories unchanged.

## Agents Directory

Manages configurations and shared standards for coding agents.

```
agents/
├── shared/              # Universal assets for all agents
│   ├── AGENTS.md       # Coding standards and rules
│   ├── skills/         # Agent skills
│   ├── hooks/          # Runtime hooks
│   └── extensions/     # Extensions
├── claude/             # Claude Code configuration
│   ├── CLAUDE.md
│   ├── settings.json
│   ├── keybindings.json
│   └── statusline.sh
├── pi/                 # Pi coding agent configuration
│   ├── keybindings.json
│   └── settings.json
├── opencode/           # OpenCode configuration
│   ├── opencode.json   # Runtime settings
│   └── tui.json        # Interface settings
└── omp/                # OMP configuration
    └── agent/
        └── config.yml
```

**Shared assets** are symlinked to each agent's configuration directory. When modifying agent configurations or standards, edit files in `agents/` — symlinks propagate changes automatically.

Matt Pocock skills deploy directly from `agents/external/matpocock_skills_repo`; `agents/shared/skills` holds only locally maintained or other-source skills. Both manifests use directory-only wildcards for the engineering, productivity, and misc categories, excluding category READMEs and experimental skills.

### Refreshing deployed agent assets

After migrating from shared copies, replace existing Linux deployment symlinks; installation alone preserves even dangling symlinks:

```sh
./install remove claude pi omp codex dsh zed
./install install claude pi omp codex dsh zed
```

These commands refresh managed symlinks for the selected agents on Linux, leaving regular files untouched. On Windows, rerun `./install install TOOL` to update installed copies; removal is not required.

## Modifying This Repository

### Guidelines

When adding or modifying configurations:

1. **Understand platform deployment:**
   - Linux symlinks reflect repository changes immediately; rerun `./install install TOOL` on Windows to update copies after confirming the listed overwrites. See [README.md](README.md#manifest-and-deployment-behavior) for replacement behavior and `sync-back` to capture installed edits.
   - If a tool doesn't load changes, check if it caches config on startup

2. **Update the applicable platform manifests:**
   - Add shared mappings to both `config_linux.conf` and `config_windows.conf`; keep platform-only tools in their respective manifest
   - Format: `./path/to/file:$HOME/.config/target` or `$HOME/.file`
   - Group mappings under the owning tool's `[TOOL]` section, including shared sources and launchers

3. **Test changes:**
   - Run `./install install` with a temporary `HOME` (and temporary `APPDATA` on Windows) after modifying manifests
   - Verify Linux symlinks point to the repository and Windows copies use the intended destinations
   - Restart affected tools to reload configs

4. **Agents directory changes:**
   - Modify `agents/shared/AGENTS.md` for universal coding standards
   - Modify agent-specific files for agent-specific rules
   - Add skills to `agents/shared/skills/<skill-name>/SKILL.md`
   - Keep third-party checkouts under `agents/external/` and map their assets directly in the platform manifests
   - Add hooks to `agents/shared/hooks/pre/` or `agents/shared/hooks/post/`

5. **Document changes:**
   - Update this file (AGENTS.md) if repo structure changes
   - Add READMEs to directories with complex configurations (e.g., nvim/readme.md)
   - Keep maintenance conventions in AGENTS.md; reserve READMEs for durable user-facing setup and usage information.

### Common Modification Scenarios

**Adding a new tool configuration:**
1. Create tool directory: `mkdir <tool>`
2. Add config files: `<tool>/config-file`
3. Add a `[<tool>]` section to each applicable platform manifest with mappings such as `./<tool>/file:$HOME/.config/<tool>/file`
4. Run install script

**Updating shared standards:**
1. Edit `agents/shared/AGENTS.md`
2. Changes take effect immediately via symlink

**Adding a new skill:**
1. Create directory: `agents/shared/skills/<skill-name>/`
2. Create SKILL.md: `agents/shared/skills/<skill-name>/SKILL.md`
3. Include frontmatter: `name:`, `description:`
4. Add skill content and examples

## Important Constraints

- **Do not edit config files via symlink targets** (e.g., `~/.config/nvim/init.lua`). Edit the source in the repo instead.
- **Git submodules:** Tmux plugins use submodules. Clone with `--recurse-submodules` and be careful when updating.
- **Platform-specific configs:** VS Code has `lin` (Linux) and `win` (Windows) variants. Modify the appropriate one.
- **Caching:** Some tools cache configs on startup. Restart them after changes.

## Zed Configuration

- **Keymaps:** Keep `zed/keymap.json` organized into shared shortcuts, default-binding overrides, and Vim-only editor shortcuts, with slash-banner section comments. Keep mode-independent bindings in the shared section, even if their keys are Vim-style.
- **Python formatting:** `zed/settings.json` uses the Ruff language server for formatting and linting, including the `Alt+Shift+F` format-selection binding. Editor formatting reads `[tool.ruff]` in each project's `pyproject.toml`, not `[tool.black]`. Zed manages the Ruff language server; a global Black executable is not required.
- **Shell formatting:** Use four spaces per indentation level for shell editing and formatting. See [README.md — Tool requirements](README.md#tool-requirements) for the `shfmt` dependency.

## Installation & Setup

### First Time

```bash
git clone --recurse-submodules -j8 https://github.com/bubleBoble/dotfiles.git ~/a-dev/dotfiles
cd ~/a-dev/dotfiles
./install install
```

### Updating Existing Setup

```bash
cd ~/a-dev/dotfiles
git pull
git submodule update --recursive
./install install  # Update symlinks
```

### Selecting Tools

```bash
./install install claude
./install install codex
./install install dsh
./install install vim
./install install claude codex dsh  # Multiple tools
./install remove dsh              # Same selection for removal
./install sync-back --include-files claude  # Allow repository overwrites
```

Omitting tool names manages all configured tools. `agents` selects only the shared `~/.agents` destination; it is not an alias for all coding agents.

### Deleting Symlinks

```bash
./install remove
./install remove --include-files  # Also removes regular-file targets
```

## For Coding Agents

### Tests and formatting

Use the persistent `tests/.venv` environment for Python tests and formatting. Create and manage it with Python's `venv` and `pip`, not `uv`.

Set up the environment from the repository root:

```bash
python3 -m venv tests/.venv
tests/.venv/bin/python -m pip install pytest black
```

Run all tests from the repository root:

```bash
tests/.venv/bin/python -B -m pytest
```

For installer tests only, append `tests/test_install.py`. Format Python tests with `tests/.venv/bin/python -m black tests/`. Keep Black, Ruff, and pytest conventions in `pyproject.toml`, with aligned Black and Ruff line-length settings.

Activation is not required. On native Windows, create the environment with `python` and use `tests/.venv/Scripts/python.exe` instead of `tests/.venv/bin/python`.

### Workflow

When asked to modify this repository:

1. **Understand the symlink structure first** — Don't edit symlink targets directly
2. **Verify the affected tool** — Which tool/config is being modified? (nvim, tmux, etc.)
3. **Update source and applicable platform manifests** — New mappings belong in `config_linux.conf`, `config_windows.conf`, or both
4. **Test installation** — Run `./install install` after changes
5. **Document structural changes** — Update this AGENTS.md if directory layout changes

Refer to this guide when making any modifications. Ask the user for clarification if requirements are ambiguous (especially for tool-specific config semantics).
