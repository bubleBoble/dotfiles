# Dotfiles Repository Guide

This is a personal dotfiles repository for managing development environment configurations across multiple tools and terminals.

## What This Repository Is

A centralized configuration management system that maintains dotfiles (configuration files) for various tools and keeps them synced to the home directory via symlinks. This allows:
- Single source of truth for all configuration files
- Git-tracked changes to configurations
- Easy replication across machines via `git clone` and `install_symlinks.sh`

## Repository Structure

### Directory Organization

| Directory | Purpose |
|-----------|---------|
| **agents/** | Coding agent configurations and shared standards |
| **nvim/** | Neovim editor config and plugins (vendors LazyVim as a git submodule) |
| **tmux/** | Tmux terminal multiplexer config (includes git submodules) |
| **zsh/** | Zsh shell configuration |
| **kitty/** | Kitty terminal emulator config |
| **vim/** | Vim editor config |
| **vscode/** | VS Code settings (platform-specific: lin, win) |
| **yazi/** | Yazi file manager config and themes |
| **herdr/** | Herdr terminal multiplexer config |
| **gdb/** | GDB debugger configuration |
| **gnome/** | GNOME desktop settings (dconf, extensions) |
| **future/** | Experimental or archived configs (vim) |

### Key Files

- **`symlinks.conf`** — Master configuration defining source:target mappings
- **`install_symlinks.sh`** — Installer script that creates symlinks based on symlinks.conf
- **`AGENTS.md`** — This file; project-level guidelines for all coding agents
- **`CLAUDE.md`** — Claude Code-specific guidelines

## How It Works

### Installation Flow

```
1. git clone --recurse-submodules <repo>
                ↓
2. ./install_symlinks.sh --create
                ↓
3. Reads symlinks.conf (source:target pairs)
                ↓
4. Creates directories as needed
                ↓
5. Creates symlinks: repo files → ~/.config/, ~/.*, etc.
```

### symlinks.conf Format

Format: `SOURCE:TARGET` where:
- **SOURCE** — Path in repo (resolved with `$(pwd)`)
- **TARGET** — Path in home directory (resolved with `$HOME`)

Example:
```
$(pwd)/nvim:$HOME/.config/nvim
$(pwd)/zsh/.zshrc:$HOME/.zshrc
```

See the actual file for complete mappings, organized into blocks:
1. Common system configs
2. Shared agents assets
3. Claude configuration
4. OMP configuration

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
└── omp/                # OMP configuration
    └── agent/
        └── config.yml
```

**Shared assets** are symlinked to each agent's configuration directory. When modifying agent configurations or standards, edit files in `agents/` — symlinks propagate changes automatically.

## Modifying This Repository

### Guidelines

When adding or modifying configurations:

1. **Understand the symlink flow:**
   - Changes to source files in repo are reflected immediately via symlinks
   - If a tool doesn't load changes, check if it caches config on startup

2. **Update symlinks.conf:**
   - Add new entries in the appropriate block (common, claude, omp, tool-specific)
   - Format: `$(pwd)/path/to/file:$HOME/.config/target` or `$HOME/.file`
   - Group related entries together with comments

3. **Test changes:**
   - Run `./install_symlinks.sh --create` after modifying symlinks.conf
   - Verify symlinks point to correct locations: `ls -l ~/.config/nvim` (should show arrow)
   - Restart affected tools to reload configs

4. **Agents directory changes:**
   - Modify `agents/shared/AGENTS.md` for universal coding standards
   - Modify agent-specific files for agent-specific rules
   - Add skills to `agents/shared/skills/<skill-name>/SKILL.md`
   - Add hooks to `agents/shared/hooks/pre/` or `agents/shared/hooks/post/`

5. **Document changes:**
   - Update this file (AGENTS.md) if repo structure changes
   - Add READMEs to directories with complex configurations (e.g., nvim/readme.md)

### Common Modification Scenarios

**Adding a new tool configuration:**
1. Create tool directory: `mkdir <tool>`
2. Add config files: `<tool>/config-file`
3. Add to symlinks.conf: `$(pwd)/<tool>/file:$HOME/.config/<tool>/file`
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
- **Git submodules:** Tmux plugins and `nvim/LazyVim` are submodules. Clone with `--recurse-submodules` and be careful when updating.
- **Platform-specific configs:** VS Code has `lin` (Linux) and `win` (Windows) variants. Modify the appropriate one.
- **Caching:** Some tools cache configs on startup. Restart them after changes.

## Installation & Setup

### First Time

```bash
git clone --recurse-submodules -j8 https://github.com/bubleBoble/dotfiles.git ~/a-dev/dotfiles
cd ~/a-dev/dotfiles
./install_symlinks.sh --create
```

### Updating Existing Setup

```bash
cd ~/a-dev/dotfiles
git pull
git submodule update --recursive
./install_symlinks.sh --create  # Update any new symlinks
```

### Deleting Symlinks

```bash
./install_symlinks.sh --delete
./install_symlinks.sh --delete --include-files  # Also removes backed-up originals
```

## For Coding Agents

When asked to modify this repository:

1. **Understand the symlink structure first** — Don't edit symlink targets directly
2. **Verify the affected tool** — Which tool/config is being modified? (nvim, tmux, etc.)
3. **Update both source AND symlinks.conf** — New files need to be added to symlinks.conf
4. **Test symlink creation** — Run `./install_symlinks.sh --create` after changes
5. **Document structural changes** — Update this AGENTS.md if directory layout changes

Refer to this guide when making any modifications. Ask the user for clarification if requirements are ambiguous (especially for tool-specific config semantics).
