return { -- nvim-telescope/telescope.nvim: Fuzzy Finder (files, lsp, etc). It's more than just a "file finder"
        'nvim-telescope/telescope.nvim',
        event = 'VimEnter',
        dependencies = {
                'nvim-lua/plenary.nvim',
                { -- nvim-telescope/telescope-fzf-native.nvim
                        'nvim-telescope/telescope-fzf-native.nvim',

                        -- `build` is used to run some command when the plugin is installed or
                        -- updated. This is only run then, not every time Neovim starts up.
                        build = 'make',

                        -- `cond` is a condition used to determine whether this plugin should be
                        -- installed and loaded.
                        cond = function()
                                return vim.fn.executable('make') == 1
                        end,
                },
                { -- nvim-telescope/telescope-ui-select.nvim
                        'nvim-telescope/telescope-ui-select.nvim',
                },
                { -- nvim-tree/nvim-web-devicons
                        'nvim-tree/nvim-web-devicons',
                        enabled = vim.g.have_nerd_font,
                },
        },
        config = function()
                -- :help telescope and :help telescope.setup()
                require('telescope').setup({
                        defaults = {
                                --   mappings = {
                                --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
                                --   },
                                previewer = false,
                                sorting_strategy = 'ascending',
                                layout_strategy = 'vertical', -- use vertical layout
                                layout_config = {
                                        vertical = {
                                                prompt_position = 'top',
                                                preview_height = 0.5,
                                                results_height = 0.3,
                                                width = 0.6,
                                                height = 0.4,
                                        },
                                },
                                -- borderchars = { '─', '│', '─', '│', '+', '+', '+', '+' },
                                -- borderchars = { '-', '|', '-', '|', '+', '+', '+', '+' },
                                borderchars = { '─', '│', '─', '│', '+', '+', '+', '+' },
                        },
                        -- pickers = {}
                        extensions = {
                                ['ui-select'] = { require('telescope.themes').get_dropdown() },
                        },
                })

                -- Enable Telescope extensions if they are installed
                pcall(require('telescope').load_extension, 'fzf')
                pcall(require('telescope').load_extension, 'ui-select')

                -- See `:help telescope.builtin`
                local builtin = require('telescope.builtin')
                vim.keymap.set('n', '<leader>sh', builtin.help_tags, {
                        desc = '[S]earch [H]elp',
                })
                vim.keymap.set('n', '<leader>sk', builtin.keymaps, {
                        desc = '[S]earch [K]eymaps',
                })

                -- vim.keymap.set('n', '<leader>sf', builtin.find_files, {
                --         desc = '[S]earch [F]iles',
                -- })

                vim.keymap.set('n', '<leader>sf', function()
                        require('telescope.builtin').find_files({ previewer = false })
                end, { desc = '[S]earch [F]iles without preview' })

                vim.keymap.set('n', '<leader>ss', builtin.builtin, {
                        desc = '[S]earch [S]elect Telescope',
                })
                vim.keymap.set('n', '<leader>sw', builtin.grep_string, {
                        desc = '[S]earch current [W]ord',
                })
                vim.keymap.set('n', '<leader>sg', builtin.live_grep, {
                        desc = '[S]earch by [G]rep',
                })
                vim.keymap.set('n', '<leader>sd', builtin.diagnostics, {
                        desc = '[S]earch [D]iagnostics',
                })
                vim.keymap.set('n', '<leader>sr', builtin.resume, {
                        desc = '[S]earch [R]esume',
                })
                vim.keymap.set('n', '<leader>s.', builtin.oldfiles, {
                        desc = '[S]earch Recent Files ("." for repeat)',
                })
                -- vim.keymap.set('n', '<leader><leader>', builtin.buffers, {
                --         desc = '[ ] Find existing buffers',
                -- })
                local themes = require('telescope.themes')
                vim.keymap.set('n', '<leader><leader>', function()
                        require('telescope.builtin').buffers(themes.get_ivy({
                                sort_mru = true,
                                sort_lastused = true,
                                initial_mode = 'insert',
                        }))
                end, { desc = '[ ] Find existing buffers' })

                -- Overriding default behavior and theme
                -- vim.keymap.set('n', '<leader>/', function()
                --         -- You can pass additional configuration to Telescope to change the theme, layout, etc.
                --         builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
                --                 winblend = 10,
                --                 previewer = false,
                --         }))
                -- end, {
                --         desc = '[/] Fuzzily search in current buffer',
                -- })

                vim.keymap.set('n', '<leader>/', function()
                        builtin.current_buffer_fuzzy_find({
                                previewer = false,
                        })
                end, {
                        desc = '[/] Fuzzily search in current buffer',
                })

                -- :help telescope.builtin.live_grep()
                vim.keymap.set('n', '<leader>s/', function()
                        builtin.live_grep({
                                grep_open_files = true,
                                prompt_title = 'Live Grep in Open Files',
                        })
                end, {
                        desc = '[S]earch [/] in Open Files',
                })

                -- Shortcut for searching your Neovim configuration files
                vim.keymap.set('n', '<leader>sn', function()
                        builtin.find_files({
                                cwd = vim.fn.stdpath('config'),
                                previewer = false,
                        })
                end, {
                        desc = '[S]earch [N]eovim files',
                })
        end,
}
