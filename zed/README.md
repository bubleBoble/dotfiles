# Zed

Install the editor settings, keymap, personal instructions, and shared skills:

```bash
./install --install zed agents
```

The installer leaves existing targets untouched. If Zed already has local settings or keymap files, they remain in place; migrating them into this repository is a separate step.

Shared instructions and skills remain maintained in [agents/shared](<../agents/shared/>). Zed's built-in agent reads personal instructions from `~/.config/zed/AGENTS.md` and global skills from `~/.agents/skills/`. The skills destination belongs to the installer's `agents` selection, not `zed`.

These instructions and skills apply to Zed's built-in agent. External agents use their own native configuration.

## Vim key bindings

`settings.json` enables Vim mode. To leave it while testing, run `workspace: toggle vim mode` from the command palette.

| Keys | Action | Scope |
| --- | --- | --- |
| Ctrl-Q | Close the active tab, with the normal unsaved-change prompt | File editor, any mode |
| Ctrl-E / Ctrl-Y | Scroll down / up two lines | Normal and visual modes |
| Ctrl-H/J/K/L | Focus the left / lower / upper / right Zed pane | Normal and visual modes; project panel outside rename input |
| Shift-Up / Shift-Down | Shrink / grow the active split's height by two lines | Normal mode |
| Shift-Left / Shift-Right | Shrink / grow the active split's width by two character widths | Normal mode |
| Tab / Shift-Tab | Next / previous tab in the active pane | Normal mode |
| Space E | Toggle file-explorer focus, like Ctrl-Shift-E | Normal mode; project panel outside rename input |
| Space ? | Open the keymap editor to search actions and key bindings | Normal mode |
| Space T B | Show / hide the tab bar | Normal mode |
| Alt-Shift-F | Format selected text | File editor, including visual mode |
| Alt-T | Toggle the terminal panel, preserving its maximized state | Workspace |

Maximize the terminal once using its tab-bar maximize button. Alt-T then hides and reopens it maximized without ending the terminal session. Do not chain terminal focus and zoom with `action::Sequence`: Zed captures the original focus for both actions, so zoom can target the editor instead.

Ctrl-Q no longer quits Zed outside a file editor. Insert-mode Tab and Shift-arrow text selection remain unchanged. Pane navigation stays inside Zed; it does not control external terminal-multiplexer panes.

### Language-server shortcuts

Zed's Vim defaults already cover most navigation. The custom keymap adds Neovim-style `gr` for references and leader shortcuts for rename and code actions.

| Keys | Action |
| --- | --- |
| `gd` / `gD` | Go to definition / declaration |
| `gy` / `gI` | Go to type definition / implementation |
| `gr` | Find all references |
| `K` | Hover documentation |
| `Space R N` | Rename symbol |
| `Space C A` | Code actions |
| `gs` / `gS` | Find a symbol in the current file / project |
| `]d` / `[d` | Next / previous diagnostic |

These shortcuts run in normal mode and depend on the active language server's capabilities. The longer default `grn`, `grr`, `gri`, and `gra` chords are removed in normal mode.

Selection formatting uses `editor::FormatSelections`, not whole-file formatting. It requires a language server that supports range formatting or a supported Prettier range formatter; external command formatters cannot format selections. Whole-file formatting remains available with Ctrl-Shift-I.

References: [Zed key bindings](https://zed.dev/docs/key-bindings), [Vim mode](https://zed.dev/docs/vim), and [Zed action reference](https://zed.dev/docs/all-actions).
