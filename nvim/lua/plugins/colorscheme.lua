-- for more themes see: https://dotfyle.com/neovim/colorscheme/top
return {
    { 'bluz71/vim-moonfly-colors', name = 'moonfly', lazy = false, priority = 1000 },
    'nyoom-engineering/oxocarbon.nvim',
    'folke/tokyonight.nvim',
    'catppuccin/nvim',
    'rebelot/kanagawa.nvim',
    'rose-pine/neovim',
    { 'miikanissi/modus-themes.nvim' },
    { 'projekt0n/github-nvim-theme', name = 'github-theme' },
    {
        'navarasu/onedark.nvim',
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            require('onedark').setup({
                style = 'Deep', -- Warmer, Dakr, Warm, Cool, Darker, Deep
            })
        end,
    },
    {
        'navarasu/onedark.nvim',
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            require('onedark').setup({
                style = 'dark', -- or "light", "darker", "cool", "deep", "warm", "warmer"
                comments = { italic = false },
            })
        end,
    },
    {
        'sainnhe/gruvbox-material',
        priority = 1000, -- load first
        config = function()
            vim.g.gruvbox_material_background = 'hard' -- soft | medium | hard
            vim.g.gruvbox_material_foreground = 'material' -- material | mix | original
            vim.g.gruvbox_material_enable_italic = 1
            vim.g.gruvbox_material_better_performance = 1
        end,
    },
    { 'agude/vim-eldar', priority = 1000 },
    { 'NLKNguyen/papercolor-theme', priority = 1000 },
    { 'EdenEast/nightfox.nvim', priority = 1000 },
    { 'lunarvim/darkplus.nvim' },
    { 'chriskempson/base16-vim' },
    { 'lurst/austere.vim' },
    { 'huyvohcmc/atlas.vim' },
    {
        'silentium-theme/silentium.nvim',
        config = function()
            local silentium = require('silentium')
            silentium.setup({
                accent = '#9c9c9c',
                white = '#b9b7b7',
                light_gray = '#8f8f8f',
                gray = '#737373',
                ghost = '#404040',
                dark_gray = '#282828',
                dark = '#141414',
                diff_add = '#363636',
                diff_change = '#444444',
                diff_delete = '#252525',
                diff_text = '#5a5a5a',
            })
        end,
    },
    { 'zaki/zazen' },
    { 'robertmeta/nofrils' },
    { 'Lokaltog/vim-monotone' },
}
