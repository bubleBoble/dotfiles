return {
    'https://github.com/nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    config = function()
        local parsers = {
            'bash',
            'c',
            'cpp',
            'json',
            'lua',
            'markdown',
            'markdown_inline',
            'python',
            'toml',
            'vim',
            'vimdoc',
            'yaml',
        }
        vim.api.nvim_create_user_command('TSInstallConfigured', function()
            require('nvim-treesitter.install').install(parsers, { summary = true })
        end, { desc = 'Install the Tree-sitter parsers configured for this Neovim setup' })

        vim.api.nvim_create_autocmd('FileType', {
            group = vim.api.nvim_create_augroup('treesitter-highlighting', { clear = true }),
            pattern = '*',
            callback = function(args)
                local parser = vim.treesitter.language.get_lang(args.match)
                if not vim.tbl_contains(parsers, parser) then
                    return
                end

                if not pcall(vim.treesitter.start, args.buf) then
                    return
                end

                vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
                vim.wo[0][0].foldmethod = 'expr'
                vim.wo[0][0].foldlevel = 99
            end,
        })
    end,
}
