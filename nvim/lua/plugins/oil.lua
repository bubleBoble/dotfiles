return {
        'stevearc/oil.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
                CustomOilBar = function()
                        local path = vim.fn.expand('%')
                        path = path:gsub('oil://', '')

                        return '  ' .. vim.fn.fnamemodify(path, ':.')
                end

                require('oil').setup({
                        columns = {
                                'icon',
                                -- 'permissions',
                                -- 'size',
                                -- 'mtime',
                        },
                        keymaps = {
                                ['<C-h>'] = false,
                                ['<C-l>'] = false,
                                ['<C-k>'] = false,
                                ['<C-j>'] = false,
                                ['<M-h>'] = 'actions.select_split',
                                ['<C-c>'] = false,
                                ['q'] = 'actions.close',
                        },
                        win_options = {
                                winbar = '%{v:lua.CustomOilBar()}',
                        },
                        view_options = {
                                show_hidden = true,
                        },
                        float = {
                                padding = 2,
                                max_width = 90,
                                max_height = 0,
                        },
                })

                -- Open parent directory in current window
                vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })

                -- Open parent directory in floating window
                vim.keymap.set('n', '<space>e', require('oil').toggle_float, { desc = 'Open oil explorer' })
        end,
}
