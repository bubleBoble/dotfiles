# Neovim Config — LazyVim

This config is built on [LazyVim](https://www.lazyvim.org/), a preconfigured Neovim distribution powered by [lazy.nvim](https://github.com/folke/lazy.nvim). Only this `nvim/` directory is ours to edit — never modify LazyVim's own plugin specs; override/extend them from `lua/plugins/` and `lua/config/` instead.

**Finding ground truth:** the actual source of every default option, keymap, and plugin spec is vendored locally at `LazyVim/` (see below) — grep/read it directly instead of relying only on web search. It's the exact version pinned by this config, so it's more reliable than docs for the installed behavior (docs can drift from the pinned commit). Web search / the docs above are still useful for prose explanations, extras not enabled here, and migration notes.

## Docs index

Full docs: https://www.lazyvim.org/. Relevant sections:

- **Getting Started** — https://www.lazyvim.org/ — overview, requirements, features.
- **Installation** — https://www.lazyvim.org/installation
- **Configuration** — https://www.lazyvim.org/configuration — how this repo customizes LazyVim.
  - General — https://www.lazyvim.org/configuration/general
  - Examples — https://www.lazyvim.org/configuration/examples
  - Keymaps — https://www.lazyvim.org/configuration/keymaps
  - lazy.nvim options — https://www.lazyvim.org/configuration/lazy.nvim
  - Plugins — https://www.lazyvim.org/configuration/plugins — adding/overriding plugin specs (what we do in `lua/plugins/`).
  - Recipes — https://www.lazyvim.org/configuration/recipes
  - Tips — https://www.lazyvim.org/configuration/tips
- **Keymaps (defaults)** — https://www.lazyvim.org/keymaps
- **Plugins (bundled, by category)** — https://www.lazyvim.org/plugins
  - Coding — https://www.lazyvim.org/plugins/coding
  - Colorscheme — https://www.lazyvim.org/plugins/colorscheme
  - Editor — https://www.lazyvim.org/plugins/editor
  - Formatting — https://www.lazyvim.org/plugins/formatting
  - Linting — https://www.lazyvim.org/plugins/linting
  - LSP — https://www.lazyvim.org/plugins/lsp
  - Treesitter — https://www.lazyvim.org/plugins/treesitter
  - UI — https://www.lazyvim.org/plugins/ui
  - Util — https://www.lazyvim.org/plugins/util
- **Extras (opt-in modules, enabled via `lazyvim.json`)** — https://www.lazyvim.org/extras
  - AI — avante, claudecode, codeium, copilot, copilot-chat, copilot-native, sidekick, supermaven, tabnine
  - Coding — blink, luasnip, mini-comment, mini-snippets, mini-surround, neogen, nvim-cmp, yanky
  - DAP — core, nlua
  - Editor — aerial, dial, fzf, harpoon2, illuminate, inc-rename, leap, mini-diff, mini-files, mini-move, navic, neo-tree, outline, overseer, refactoring, snacks_explorer, snacks_picker, telescope
  - Formatting — black, prettier
  - Lang — angular, ansible, astro, clangd, clojure, cmake, dart, docker, dotnet, elixir, elm, ember, erlang, git, gleam, go, haskell, helm, java, json, julia, kotlin, lean, markdown, nix, nushell, ocaml, php, prisma, python, r, rego, ruby, rust, scala, solidity, sql, svelte, tailwind, terraform, tex, thrift, toml, twig, typescript (+ biome, oxc, tsc, vtsls), typst, vue, yaml, zig
  - Linting — eslint
  - LSP — neoconf, none-ls
  - Test — core
  - UI — alpha, dashboard-nvim, edgy, indent-blankline, mini-animate, mini-indentscope, mini-starter, smear-cursor, treesitter-context
  - Util — chezmoi, dot, gh, gitui, mini-hipatterns, octo, project, rest, startuptime
  - VSCode (running inside vscode-neovim) — https://www.lazyvim.org/extras/vscode
- **News** (breaking changes / migration notes between LazyVim versions) — https://www.lazyvim.org/news

## Repo layout

- `lua/config/` — `options.lua`, `keymaps.lua`, `autocmds.lua`, `lazy.lua` (bootstraps lazy.nvim + LazyVim).
- `lua/plugins/` — one file per plugin/spec; each returned table is merged into LazyVim's plugin list (can add, override, or `enabled = false` a default plugin).
- `LazyVim/` — **git submodule**, a local clone of https://github.com/LazyVim/LazyVim. `lazy.lua` points lazy.nvim at it via `dir = vim.fn.stdpath("config") .. "/LazyVim"` instead of letting lazy.nvim clone/manage it. Never edit files inside this directory — treat it exactly like LazyVim's normal install; a local edit is silently lost on the next submodule update and diverges from upstream.
- `lazyvim.json` — tracks which LazyVim `extras` are enabled and the installed config version.
- `lazy-lock.json` — pinned commits for every other plugin, managed by lazy.nvim (don't hand-edit). LazyVim itself is intentionally absent from this file since its version is now tracked by the submodule pointer instead.

## Updating vendored LazyVim

Because LazyVim is a submodule, lazy.nvim's `:Lazy update`/`:Lazy sync` does **not** touch it. Update it explicitly:

```bash
git -C nvim/LazyVim fetch
git -C nvim/LazyVim checkout <tag-or-commit>   # or: git -C nvim/LazyVim pull origin main
git add nvim/LazyVim
git commit -m "..."
```

Then restart Neovim (or `:Lazy reload`) to pick up the new LazyVim source. Check https://www.lazyvim.org/news for breaking changes before bumping.