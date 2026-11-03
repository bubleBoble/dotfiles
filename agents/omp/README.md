# OMP configuration

## Models and agents

The configuration uses Codex `gpt-6.1-sol` with separate thinking levels:

| Role | Thinking | Used for |
| --- | --- | --- |
| `default` | medium | Daily conversation and implementation |
| `smol` | low | Bundled `scout` and `sonic` agents |
| `slow` | high | Explicit deep-analysis sessions |
| `plan` | high | Plan mode |
| `task` | medium | Bundled general-purpose task agent |
| `review` | high | Bundled `reviewer` and `security-reviewer` agents |

Roles reference `default`, `smol`, or `slow`, so changing the base model does not
require editing every agent mapping. These are effort differences, not separate
model price tiers. The bundled agent prompts and tool restrictions stay intact.
No custom agent files are needed.

- Use `Alt+M` to inspect or assign model roles.
- Toggle plan mode with `Alt+Shift+P`; assigning the `plan` role alone does not enter it.
- Start a deep-analysis session with `omp --model slow`.
- Ask for a specialist explicitly, for example: “Use the reviewer agent to check this change for correctness.”
- Use `/agents` to manage agent definitions and routing; use `Alt+A` to inspect and steer running agents.

Automatic prewalk handoffs and the passive advisor are not enabled by this setup.
Roles select models when a workload runs; they do not force delegation on every
request. Add a custom agent only when a recurring job needs instructions or tool
restrictions that the bundled agents do not provide.

Routing was smoke-tested with OMP v18.14.1: read-only `sonic` and `reviewer`
tasks completed on `gpt-6.1-sol` at low and high effort respectively. The same
model provider is shared, so this is not an independent-model review.

## Interface

`agent/config.yml` keeps the Claude-style composer with a custom status line:
model and thinking effort, plus the `context-tokens` extension's `status`
segment with estimated occupied tokens and the window limit, for example
`56K/500K`. The segment refreshes once per second and repaints only when the
displayed value changes; counts come from OMP's current context usage, not
session totals. Working directory and Git branch segments are disabled.
Separate hook status rows and the session-color accent are disabled.

The dark theme `dark-lunar-messages`, stored in `agent/themes/`, preserves the
`dark-lunar` palette except for user messages in conversation history: a blue-gray
background (`#283449`) and light text (`#eef3f8`) distinguish them from assistant
replies. Both platform manifests deploy the theme to OMP's themes directory.

Startup hides the welcome logo, tips, and update notes, and does not check for
updates. Run `omp update` when you want to update manually.
The local `quiet-editor` extension renders the prompt as a dark blue-gray panel
(`#252a36`). Half-block top and bottom edges meet the input background without
gaps or coloring the outer half of either border row. `@` and autocomplete
suggestion rows render above the panel instead of below it, so the input stays
at the bottom of the editor block and stops sliding while the suggestion list
filters on each keystroke; selection, Tab, and Enter behavior are unchanged.
OMP hides the status line while the completion list is open, so the editor
also renders a fallback dim status row (model, path, Git branch, context
tokens) below the panel for exactly as long as completion rows exist.
It also hides empty-prompt keyboard hints without changing shortcuts.

Run the following commands from the repository root.

Run `./install install omp` to deploy the theme and extensions, then restart OMP.
On Windows, rerun installation after changes to refresh deployed copies.

After deploying the theme, preview the extensions directly from the repository:

```sh
omp --config agents/omp/agent/config.yml \
    --extension agents/omp/agent/extensions/context-tokens.ts \
    --extension agents/omp/agent/extensions/quiet-editor.ts
```
