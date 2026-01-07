require('core.options')
require('core.keymaps')
require('core.autocommands')
require('core.lazyinit')

require('lazy').setup({
        require('plugins.nvim-web-devicons'),
        require('plugins.guess-indent'),
        require('plugins.gitsigns'),
        require('plugins.which-key'),
        require('plugins.telescope'),
        require('plugins.lazydev'),
        require('plugins.nvim-lspconfig'),
        require('plugins.conform'),
        require('plugins.blink'),
        require('plugins.mini'),
        -- require('plugins.nvim-treesitter'),
        -- require('plugins.nvim-treesitter-textobjects'),
        require('plugins.colorscheme'),
        require('plugins.huez'),
        require('plugins.neotree'),
        -- require('plugins.oil'),
        require('plugins.vscode-diff'),
        require('plugins.lualine'),
        require('plugins.bufferline'),
        require('plugins.zenmode'),
}, {
        ui = {
                -- If you are using a Nerd Font: set icons to an empty table which will use the
                -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
                icons = vim.g.have_nerd_font and {} or {
                        cmd = '⌘',
                        config = '🛠',
                        event = '📅',
                        ft = '📂',
                        init = '⚙',
                        keys = '🗝',
                        plugin = '🔌',
                        runtime = '💻',
                        require = '🌙',
                        source = '📄',
                        start = '🚀',
                        task = '📌',
                        lazy = '💤',
                },
        },
})
