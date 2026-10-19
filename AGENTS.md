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
| **vscode/** | VS Code settings (platform-specific: lin, win) |
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
- **SOURCE** — Relative path resolved from the repository root
- **TARGET** — Absolute destination after variable expansion (`$HOME`, or `$APPDATA` for Windows Zed); unresolved variables and relative targets are rejected before deployment
- **Per-child mappings** — End both sides with `/*` to create one mapping for each direct child while preserving its name. End the source with `/*/` instead to select only child directories
- **Tool selection** — Every mapping belongs to its explicit `[TOOL]` section until the next section header. Source and target directory names do not determine ownership. Put shared assets and launchers in the owning tool's section. See [README.md](README.md) for section syntax.

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
└── omp/                # OMP configuration
    └── agent/
        └── config.yml
```

**Shared assets** are symlinked to each agent's configuration directory. When modifying agent configurations or standards, edit files in `agents/` — symlinks propagate changes automatically.

## Modifying This Repository

### Guidelines

When adding or modifying configurations:

1. **Understand platform deployment:**
   - Linux symlinks reflect repository changes immediately; Windows copies require reinstalling after backing up/removing existing targets, or `--sync-back` to capture installed edits
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

Use the persistent `tests/.venv` environment for Python tests and formatting. Create and manage it with Python's `venv` and `pip`, not `uv`; see [README.md — Tests](README.md#tests) for setup. Run `tests/.venv/bin/python -B -m pytest` from the repository root (native Windows: `tests/.venv/Scripts/python.exe`). Keep Black, Ruff, and pytest conventions in `pyproject.toml`.

When asked to modify this repository:

1. **Understand the symlink structure first** — Don't edit symlink targets directly
2. **Verify the affected tool** — Which tool/config is being modified? (nvim, tmux, etc.)
3. **Update source and applicable platform manifests** — New mappings belong in `config_linux.conf`, `config_windows.conf`, or both
4. **Test installation** — Run `./install install` after changes
5. **Document structural changes** — Update this AGENTS.md if directory layout changes

Refer to this guide when making any modifications. Ask the user for clarification if requirements are ambiguous (especially for tool-specific config semantics).
