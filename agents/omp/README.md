# OMP configuration

`agent/config.yml` keeps the Claude-style composer with a custom status line:
model and thinking effort, plus the `context-tokens` extension's `status`
segment with estimated occupied tokens and the window limit, for example
`56K/500K`, and a `context-bar` segment: a 16-cell proportional bar of the
context window with the system prompt in accent and conversation messages in
the message color, free space dimmed. Both segments refresh once per second
and repaint only when the displayed value changes; counts come from OMP's
current context usage, not session totals. The bar estimates both sides at
about four characters per token because OMP does not expose its exact
per-category breakdown to extensions. Working directory and Git branch
segments are disabled.
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
