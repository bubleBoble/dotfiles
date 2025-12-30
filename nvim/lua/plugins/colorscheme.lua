-- for more themes see: https://dotfyle.com/neovim/colorscheme/top
return {
        'folke/tokyonight.nvim',
        'catppuccin/nvim',
        'rebelot/kanagawa.nvim',
        'rose-pine/neovim',
        {
                'navarasu/onedark.nvim',
                priority = 1000, -- make sure to load this before all the other start plugins
                config = function()
                        require('onedark').setup({
                                style = 'darker', -- Warmer, Dakr, Warm, Cool, Darker, Deep
                        })
                        require('onedark').load()
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
                        require('onedark').load()
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

                        vim.cmd.colorscheme('gruvbox-material')
                end,
        },
}
