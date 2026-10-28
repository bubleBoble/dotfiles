# OMP configuration

`agent/config.yml` keeps the Claude-style composer with a custom status line:
model and thinking effort, working directory, Git branch, and context.
The local `context-tokens` extension supplies the inline `status` segment with
estimated occupied tokens and the window limit, for example `56K/500K`.
It refreshes once per second and repaints only when the displayed value changes.
The count comes from OMP's current context usage, not session totals.
Separate hook status rows and the session-color accent are disabled.

The dark theme `dark-lunar-messages`, stored in `agent/themes/`, preserves the
`dark-lunar` palette except for user messages in conversation history: a blue-gray
background (`#283449`) and light text (`#eef3f8`) distinguish them from assistant
replies. Both platform manifests deploy the theme to OMP's themes directory.

Startup hides the welcome logo, tips, and update notes, and does not check for
updates. Run `omp update` when you want to update manually.
The local `quiet-editor` extension renders the prompt as a dark blue-gray panel
(`#252a36`). Half-block top and bottom edges meet the input background without
gaps or coloring the outer half of either border row. Completion rows outside
the panel remain unchanged. It also hides empty-prompt keyboard hints without
changing shortcuts.

Run the following commands from the repository root.

Run `./install install omp` to deploy the theme and extensions, then restart OMP.
On Windows, rerun installation after changes to refresh deployed copies.

After deploying the theme, preview the extensions directly from the repository:

```sh
omp --config agents/omp/agent/config.yml \
    --extension agents/omp/agent/extensions/context-tokens.ts \
    --extension agents/omp/agent/extensions/quiet-editor.ts
```
