return { -- vague2k/huez: theme picker/manager, uses telescope
        'vague2k/huez.nvim',
        -- if you want registry related features, uncomment line below
        import = 'huez-manager.import',
        branch = 'stable',
        event = 'UIEnter',
        dependencies = {
                'nvim-telescope/telescope.nvim', -- optional but highly recommended
        },
        opts = {
                path = vim.fs.normalize(vim.fn.stdpath('data') --[[@as string]]) .. '/huez',
                fallback = 'default',
                suppress_messages = true,
                theme_config_module = nil,
                exclude = {},
                -- exclude = { 'desert', 'evening', 'industry', 'koehler', 'morning', 'murphy', 'pablo', 'peachpuff', 'ron', 'shine', 'slate', 'torte', 'zellner', 'blue', 'darkblue', 'delek', 'quiet', 'elflord', 'habamax', 'lunaperche', 'zaibatsu', 'wildcharm', 'sorbet', 'vim' },
                background = 'dark',
                picker = {
                        themes = {
                                layout = 'right',
                                opts = {},
                        },
                        favorites = {
                                layout = 'right',
                                opts = {},
                        },
                        live = {
                                layout = 'right',
                                opts = {},
                        },
                        ensured = {
                                layout = 'right',
                                opts = {},
                        },
                },
        },
}
