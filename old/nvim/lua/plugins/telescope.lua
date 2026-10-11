return {
    'https://github.com/nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
        'https://github.com/nvim-lua/plenary.nvim',
        'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
        'https://github.com/nvim-telescope/telescope-ui-select.nvim',
        'https://github.com/nvim-tree/nvim-web-devicons',
    },
    config = function()
        -- :help telescope and :help telescope.setup()
        require('telescope').setup({
            defaults = {
                previewer = true,
            },
        })

        -- Enable Telescope extensions if they are installed
        pcall(require('telescope').load_extension, 'fzf')
        pcall(require('telescope').load_extension, 'ui-select')

        -- See `:help telescope.builtin`
        -- local builtin = require('telescope.builtin')
        -- local find_nvim_files = function()
        --     builtin.find_files({
        --         cwd = vim.fn.stdpath('config'),
        --         previewer = true,
        --     })
        -- end

        -- vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = 'Search help' })
        -- vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = 'Search keymaps' })
        -- vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = 'Search files' })
        -- vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = 'Search select telescope' })
        -- vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = 'Search current word' })
        -- vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = 'Search by frep' })
        -- vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = 'Search diagnostics' })
        -- vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = 'Search Resume' })
        -- vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = 'Search Recent Files ("." for repeat)' })
        -- vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = 'Find opened buffer' })
        -- vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = 'Fuzzy search current buffer' })
        -- vim.keymap.set('n', '<leader>s/', builtin.live_grep, { desc = 'Search in Open Files' })
        -- vim.keymap.set('n', '<leader>sn', find_nvim_files, { desc = 'Search neovim files' })
    end,
}
