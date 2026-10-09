# Zed

Install the editor settings, keymap, personal instructions, and shared skills:

```bash
./install --install zed agents
```

The installer leaves existing targets untouched. If Zed already has local settings or keymap files, they remain in place; migrating them into this repository is a separate step.

Shared instructions and skills remain maintained in [agents/shared](<../agents/shared/>). Zed's built-in agent reads personal instructions from `~/.config/zed/AGENTS.md` and global skills from `~/.agents/skills/`. The skills destination belongs to the installer's `agents` selection, not `zed`.

These instructions and skills apply to Zed's built-in agent. External agents use their own native configuration.
