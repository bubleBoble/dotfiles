return {
        'akinsho/bufferline.nvim',
        version = '*',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
                local bufferline = require('bufferline')
                local opts = {
                        options = {
                                -- :h bufferline-configuratuion
                                style_preset = bufferline.style_preset.default,
                                themable = true,
                                tab_size = 18,
                                diagnostics = false,
                                show_buffer_icons = true,
                                show_buffer_close_icons = true,
                                show_close_icon = true,
                                show_tab_indicators = true,
                                show_duplicate_prefix = true, -- whether to show duplicate buffer prefix
                                duplicates_across_groups = true, -- whether to consider duplicate paths in different groups as duplicates
                                persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
                                move_wraps_at_ends = false, -- whether or not the move command "wraps" at the first or last position
                                -- can also be a table containing 2 custom separators
                                -- [focused and unfocused]. eg: { '|', '|' }
                                separator_style = 'thick',
                                enforce_regular_tabs = false,
                                always_show_bufferline = true,
                                auto_toggle_bufferline = true,
                                hover = {
                                        enabled = false,
                                        delay = 200,
                                        reveal = { 'close' },
                                },
                                offsets = {
                                        {
                                                filetype = 'neo-tree',
                                                text = 'Neo-tree',
                                                highlight = 'Directory',
                                                text_align = 'left',
                                        },
                                },
                        },
                }
                require('bufferline').setup(opts)
        end,
}
