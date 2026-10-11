return {
    'https://github.com/stevearc/conform.nvim',
    dependencies = { 'https://github.com/mason-org/mason.nvim' },
    opts = {
        format_on_save = false,
        format_after_save = false,
        default_format_opts = {
            lsp_format = 'fallback',
        },
        formatters_by_ft = {
            lua = { 'stylua' },
            c = { 'clang_format' },
            cpp = { 'clang_format' },
        },
        formatters = {
            clang_format = {
                prepend_args = { '--style=file', '--fallback-style=WebKit' },
            },
        },
    },
}
