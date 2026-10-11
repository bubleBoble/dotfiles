return {
    'https://github.com/neovim/nvim-lspconfig',
    lazy = false,
    dependencies = {
        'https://github.com/mason-org/mason.nvim',
        'https://github.com/saghen/blink.cmp',
    },
    config = function()
        vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })

        vim.lsp.config('lua_ls', {
            settings = {
                Lua = {
                    completion = { callSnippet = 'Replace' },
                },
            },
        })

        vim.lsp.enable({ 'clangd', 'pyright', 'rust_analyzer', 'lua_ls' })
    end,
}
