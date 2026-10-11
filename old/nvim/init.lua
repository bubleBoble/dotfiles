require('core.options')
require('core.autocommands')
require('core.lazyinit')

require('lazy').setup({
    require('plugins.deps.nvim-web-devicons'), -- nvim-tree/nvim-web-devicons: file icons
    require('plugins.deps.plenary'), -- nvim-lua/plenary.nvim: shared Lua utilities
    require('plugins.deps.nui'), -- MunifTanjim/nui.nvim: UI components for Neo-tree
    require('plugins.deps.window-picker'), -- s1n7ax/nvim-window-picker: choose a window from Neo-tree
    require('plugins.deps.telescope-fzf-native'), -- nvim-telescope/telescope-fzf-native.nvim: native fuzzy sorter
    require('plugins.deps.telescope-ui-select'), -- nvim-telescope/telescope-ui-select.nvim: Telescope picker for vim.ui.select
    require('plugins.colorscheme'), -- multiple repositories: available colorschemes
    require('plugins.which-key'), -- folke/which-key.nvim: keybinding hints
    require('plugins.neo-tree'), -- nvim-neo-tree/neo-tree.nvim: file explorer
    -- require('plugins.bufferline'), -- akinsho/bufferline.nvim: buffer tab bar
    -- require('plugins.lualine'), -- nvim-lualine/lualine.nvim: statusline
    require('plugins.guess-indent'), -- NMAC427/guess-indent.nvim: detect indentation settings
    require('plugins.persistence'), -- folke/persistence.nvim: save and restore editing sessions
    require('plugins.goyo'), -- junegunn/goyo.vim: 80-column Markdown writing layout
    -- require('plugins.gitsigns'), -- lewis6991/gitsigns.nvim: Git change markers and hunks
    require('plugins.fugitive'), -- tpope/vim-fugitive: Git commands and history graph
    require('plugins.mason'), -- mason-org/mason.nvim: external tool manager
    require('plugins.blink'), -- saghen/blink.cmp: autocompletion
    require('plugins.lspconfig'), -- neovim/nvim-lspconfig: language server defaults and activation
    require('plugins.conform'), -- stevearc/conform.nvim: manual code formatting
    require('plugins.telescope'), -- nvim-telescope/telescope.nvim: fuzzy finder
    require('plugins.treesitter'), -- nvim-treesitter/nvim-treesitter: syntax parsing and highlighting
    require('plugins.treesitter-textobjects'), -- nvim-treesitter/nvim-treesitter-textobjects: syntax-aware text objects
    require('plugins.codediff') -- esmuellert/codediff.nvim: vscode-like diff
})
require('core.keymaps')
require('core.usercommands')
