vim.g.mapleader = ' ' -- :help mapleader, Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true -- Set to true if you have a Nerd Font installed and selected in the terminal
vim.o.number = true -- :help vim.o, :help option-list
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false -- Don't show the mode, since it's already in the status line
vim.o.wrap = false
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.virtualedit = 'block' -- to be able to place cursor in the place where here is not character - only in visual block mode
vim.o.inccommand = 'split' -- see find&replace results in a split (:%s/word/newword)

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
        vim.o.clipboard = 'unnamedplus'
end)

vim.o.breakindent = true -- Enable break indent
vim.o.undofile = true -- Save undo history
vim.o.ignorecase = true -- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.smartcase = true
vim.o.signcolumn = 'yes' -- Keep signcolumn on by default
vim.o.updatetime = 250
vim.o.timeoutlen = 300 -- mapped sequence wait time
vim.o.splitright = true -- how new splits should be opened
vim.o.splitbelow = true
vim.o.list = true -- :help list listchars lua-options lua-options-guide
vim.opt.listchars = {
        tab = '» ',
        trail = '·',
        nbsp = '␣',
}
vim.o.inccommand = 'split' -- preview substitutions live, as you type
vim.o.cursorline = false -- Show which line your cursor is on
vim.o.scrolloff = 0 -- Minimal number of screen lines to keep above and below the cursor
vim.o.confirm = false -- :help confirm
vim.o.termguicolors = true
