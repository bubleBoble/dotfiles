-- :help lua-guide-autocommands
-- autocommands are like event listeners - they fire after certain event happens

-- Highlight when yanking (copying) text, e.g.: see yap in n mode, :help vim.hl.on_yank()
vim.api.nvim_create_autocmd('TextYankPost', {
        desc = 'Highlight when yanking (copying) text',
        group = vim.api.nvim_create_augroup('kickstart-highlight-yank', {
                clear = true,
        }),
        callback = function()
                vim.hl.on_yank()
        end,
})
