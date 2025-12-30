return { -- nvim-treesitter/nvim-treesitter: Highlight, edit, and navigate code
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
        opts = {
                ensure_installed = {
                        'c',
                        'cpp',
                        'rust',
                        'bash',
                        'diff',
                        'html',
                        'lua',
                        'luadoc',
                        'markdown',
                        'markdown_inline',
                        'query',
                        'vim',
                        'vimdoc',
                        'python',
                        'javascript',
                        'typescript',
                        'regex',
                        'dockerfile',
                        'toml',
                        'json',
                        'go',
                        'gitignore',
                        'yaml',
                        'make',
                        'cmake',
                        'css',
                },
                -- Autoinstall languages that are not installed
                auto_install = true,
                highlight = {
                        enable = true,
                        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
                        --  If you are experiencing weird indenting issues, add the language to
                        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
                        additional_vim_regex_highlighting = { 'ruby' },
                        -- Disable in large C buffers
                        disable = function(lang, bufnr)
                                return lang == 'c' and vim.api.nvim_buf_line_count(bufnr) > 50000
                        end,
                },
                indent = {
                        enable = true,
                        disable = { 'ruby' },
                },
                incremental_selection = {
                        enable = true,
                        keymaps = {
                                init_selection = '<leader>is', -- start inc selection
                                node_incremental = '<leader>iu', -- inc to the upper named parent
                                scope_incremental = '<leader>is', -- inc to the upper scope
                                node_decremental = '<leader>id', -- dec to the prev named node
                        },
                },
        },
        -- There are additional nvim-treesitter modules that you can use to interact
        -- with nvim-treesitter. You should go explore a few and see what interests you:
        --
        --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
        --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
        --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
}
