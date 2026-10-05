return {
    'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    lazy = false,
    dependencies = { 'https://github.com/nvim-treesitter/nvim-treesitter' },
    opts = {
        select = { lookahead = true },
    },
}
