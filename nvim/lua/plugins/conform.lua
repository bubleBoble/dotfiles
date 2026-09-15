return {
    'stevearc/conform.nvim',
    cmd = { 'ConformInfo' },
    keys = {
        {
            '<leader>ff',
            function()
                require('conform').format({
                    async = true,
                    lsp_format = 'fallback',
                })
            end,
            mode = 'n',
            desc = '[F]ormat whole buffer',
        },
        {
            '<leader>fs',
            function()
                require('conform').format({
                    async = true,
                    lsp_format = 'fallback',
                })
            end,
            mode = 'v',
            desc = '[F]ormat selection',
        },
    },
    opts = {
        format_on_save = false,
        notify_on_error = false,
        formatters_by_ft = {
            lua = { 'stylua' },
            c = { 'clang_format' },
            cpp = { 'clang_format' },
            python = { 'black', 'autopep8', 'isort' },
            json = { 'jq' },
        },
        formatters = {
            clang_format = {
                prepend_args = { '--style=file', '--fallback-style=WebKit' },
            },
            shfmt = {
                prepend_args = { '-i', '4' },
            },
        },
    },
}
