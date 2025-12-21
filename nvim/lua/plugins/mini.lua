return { -- echasnovski/mini.nvim
        'echasnovski/mini.nvim',
        config = function()
                -- Better Around/Inside textobjects
                --
                -- Examples:
                --  - va)  - [V]isually select [A]round [)]paren
                --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
                --  - ci'  - [C]hange [I]nside [']quote
                require('mini.ai').setup({
                        n_lines = 500,
                })

                -- Add/delete/replace surroundings (brackets, quotes, etc.)
                --
                -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
                -- - sd'   - [S]urround [D]elete [']quotes
                -- - sr)'  - [S]urround [R]eplace [)] [']
                require('mini.surround').setup()

                -- Simple and easy statusline.
                --  You could remove this setup call if you don't like it,
                --  and try some other statusline plugin
                local statusline = require('mini.statusline')
                -- set use_icons to true if you have a Nerd Font
                statusline.setup({
                        use_icons = vim.g.have_nerd_font,
                })

                -- You can configure sections in the statusline by overriding their
                -- default behavior. For example, here we set the section for
                -- cursor location to LINE:COLUMN
                ---@diagnostic disable-next-line: duplicate-set-field
                statusline.section_location = function()
                        return '%2l:%-2v'
                end

                require('mini.map').setup({
                        -- Highlight integrations (none by default)
                        integrations = nil,

                        -- Symbols used to display data
                        symbols = {
                                -- Encode symbols. See `:h MiniMap.config` for specification and
                                -- `:h MiniMap.gen_encode_symbols` for pre-built ones.
                                -- Default: solid blocks with 3x2 resolution.
                                encode = nil,

                                -- Scrollbar parts for view and line. Use empty string to disable any.
                                scroll_line = '█',
                                scroll_view = '┃',
                        },

                        -- Window options
                        window = {
                                -- Whether window is focusable in normal way (with `wincmd` or mouse)
                                focusable = true,

                                -- Side to stick ('left' or 'right')
                                side = 'right',

                                -- Whether to show count of multiple integration highlights
                                show_integration_count = true,

                                -- Total width
                                width = 10,

                                -- Value of 'winblend' option
                                winblend = 25,

                                -- Z-index
                                zindex = 10,
                        },
                })

                vim.keymap.set('n', '<leader>m', '', { desc = 'Minimap' })
                vim.keymap.set('n', '<leader>mo', MiniMap.open, { desc = 'Minimap open' })
                vim.keymap.set('n', '<leader>mr', MiniMap.refresh, { desc = 'Minimap refresh' })
                vim.keymap.set('n', '<leader>mc', MiniMap.close, { desc = 'Minimap close' })
                vim.keymap.set('n', '<leader>mt', MiniMap.toggle, { desc = 'Minimap toggle' })
                vim.keymap.set('n', '<leader>ms', MiniMap.toggle_side, { desc = 'Minimap toggle side' })
                vim.keymap.set('n', '<Leader>mf', MiniMap.toggle_focus, { desc = 'Minimap toggle focus' })

                -- ... and there is more!
                --  Check out: https://github.com/echasnovski/mini.nvim
        end,
}
