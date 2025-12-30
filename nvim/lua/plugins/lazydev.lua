return { -- folke/lazydev.nvim: configures Lua LSP for your Neovim config, runtime and plugins
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
                -- Load luvit types when the `vim.uv` word is found
                library = {
                        {
                                path = '${3rd}/luv/library',
                                words = { 'vim%.uv' },
                        },
                },
        },
}
