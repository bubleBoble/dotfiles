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

-- Create an autocmd group for C/C++ project navigation
vim.api.nvim_create_augroup('c_cpp_path', { clear = true })

-- Set path, suffixesadd, and wildignore for C/C++ files
vim.api.nvim_create_autocmd('FileType', {
        group = 'c_cpp_path',
        pattern = { 'c', 'cpp' },
        callback = function()
                -- Recursively search subdirectories
                -- set path+=**
                vim.opt_local.path:append('**')

                -- Automatically try these extensions when using gf or :find
                -- set suffixesadd=.h,.hpp,.c,.cpp
                vim.opt_local.suffixesadd = { '.h', '.hpp', '.c', '.cpp', '.s' }

                -- Ignore this folders in searches
                -- set wildignore+=*/build/*,*/Debug/*,*/Release/*,*/.git/*, */.cache/*
                vim.opt_local.wildignore:append({ '*/build/*', '*/Debug/*', '*/Release/*', '*/.git/*', '*/.cache/*' })
        end,
})
