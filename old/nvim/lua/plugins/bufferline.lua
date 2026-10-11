return {
    'https://github.com/akinsho/bufferline.nvim',
    version = '*',
    dependencies = { 'https://github.com/nvim-tree/nvim-web-devicons' },
    opts = {
        options = {
            tab_size = 18,
            separator_style = 'thick',
            always_show_bufferline = true,
            offsets = {
                {
                    filetype = 'neo-tree',
                    text = 'Neo-tree',
                    highlight = 'Directory',
                    text_align = 'left',
                },
            },
        },
    },
}
