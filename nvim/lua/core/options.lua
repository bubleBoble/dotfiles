vim.g.mapleader = ' ' -- :help mapleader, Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true -- Set to true if you have a Nerd Font installed and selected in the terminal
vim.o.number = true -- :help vim.o, :help option-list
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false -- don't show the mode, since it's already in the status line
vim.o.wrap = false
vim.o.breakindent = true -- indent wrapped lines - if wrapping is on
vim.o.linebreak = true -- if true and if line wrapping enabled, it won't break words
vim.o.expandtab = false -- convert tab to spaces
vim.o.tabstop = 8 -- number of spaces for TAB
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.virtualedit = 'block,onemore' -- to be able to place cursor in the place where here is not character - only in visual block mode
vim.o.inccommand = 'split' -- see find&replace results in a split (:%s/word/newword)

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
        vim.o.clipboard = 'unnamedplus'
end)

vim.o.undofile = true -- Save undo history
vim.o.ignorecase = true -- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.signcolumn = 'yes' -- Keep signcolumn on by default
vim.o.updatetime = 250
vim.o.timeoutlen = 300 -- mapped sequence wait time
vim.o.splitright = true -- how new vert splits should be opened
vim.o.splitbelow = true -- how new horiz splits should be opened
vim.o.list = true -- :help list listchars lua-options lua-options-guide
vim.opt.listchars = {
        tab = '» ',
        trail = '·',
        nbsp = '␣',
}
vim.o.inccommand = 'split' -- preview substitutions live, as you type
vim.o.cursorline = true -- highlight current line
vim.o.scrolloff = 0 -- minimal number of screen lines to keep above and below the cursor
vim.o.sidescrolloff = 0 -- minimal num of columns if wrap is false
vim.o.confirm = false -- :help confirm
vim.o.termguicolors = true
vim.o.hlsearch = true -- highligh when searching, default is true
vim.o.whichwrap = 'bs<>[]hl' -- which "horizontal" keys are allowed to travel to prev/next line (default: 'b,s')
vim.o.numberwidth = 4 -- number column width
vim.o.swapfile = false -- default is true
vim.o.showtabline = 1 -- show tabs line never/atleast2tabs/always - 0/1/2
vim.o.backspace = 'indent,eol,start'
vim.o.pumheight = 0 -- max popup menu size - 0 means whatever is need
vim.o.conceallevel = 0 -- So that `` is visible in markdown files (default: 1)
vim.wo.signcolumn = 'yes'
vim.o.backup = false -- whether to make backup while writing the file
vim.o.writebackup = false -- whether to create a backup while the file is being edited
vim.opt.runtimepath:remove('/usr/share/vim/vimfiles') -- Separate Vim plugins from Neovim in case Vim still in use (default: includes this path if Vim is installed)
vim.o.hidden = true -- will allow you to have modified buffers open in the "background" - ie not displayed in the window
vim.o.colorcolumn = '80'
