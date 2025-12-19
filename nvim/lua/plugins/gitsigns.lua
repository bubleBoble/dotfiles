return { -- gitsigns.nvim: Adds git related signs to the gutter
        'lewis6991/gitsigns.nvim',
        config = function()
                local opts = {
                        signs = {
                                add = {
                                        text = '+',
                                },
                                change = {
                                        text = '~',
                                },
                                delete = {
                                        text = '_',
                                },
                                topdelete = {
                                        text = '‾',
                                },
                                changedelete = {
                                        text = '~',
                                },
                        },
                }
                require('gitsigns').setup(opts)
        end,
}
