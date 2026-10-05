vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<C-s>', '<cmd> w <CR>')
vim.keymap.set('n', '<C-q>', ':bp|sp|bn|bd<CR>', { noremap = true, silent = true })
vim.keymap.set('n', 'x', '"_x')
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

vim.keymap.set('n', '<leader>v', '<C-w>v', { desc = 'Split window vertically' })
vim.keymap.set('n', '<leader>h', '<C-w>s', { desc = 'Split window horizontally' })
vim.keymap.set('n', '<leader>xs', ':close<CR>', { desc = 'Close split' })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<S-Up>', ':resize -2<CR>')
vim.keymap.set('n', '<S-Down>', ':resize +2<CR>')
vim.keymap.set('n', '<S-Left>', ':vertical resize -2<CR>')
vim.keymap.set('n', '<S-Right>', ':vertical resize +2<CR>')

vim.keymap.set('n', '<Tab>', ':bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<S-Tab>', ':bprevious<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<leader>bx', ':bdelete!<CR>', { desc = 'Close buffer' })
vim.keymap.set('n', '<leader>bn', '<cmd> enew <CR>', { desc = 'New buffer' })
vim.keymap.set('n', '<leader>to', ':tabnew<CR>', { desc = 'Open new tab' })
vim.keymap.set('n', '<leader>tx', ':tabclose<CR>', { desc = 'Close tab' })
vim.keymap.set('n', '<leader>tn', ':tabn<CR>', { desc = 'Goto next tab' })
vim.keymap.set('n', '<leader>tp', ':tabp<CR>', { desc = 'Goto prev tab' })
vim.keymap.set('n', '<leader>lw', '<cmd>set wrap!<CR>', { desc = 'Toggle line wrap' })
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

vim.keymap.set('n', '<leader>tv', [[<cmd>40vsplit | term<cr>A]], { desc = 'Open [t]erminal in [v]ertical split' })
vim.keymap.set('n', '<leader>;', ':', { desc = 'Command mode' })
vim.keymap.set('n', '<leader>c', ':', { desc = 'Command mode' })
vim.keymap.set('i', '<C-h>', '<Left>')
vim.keymap.set('i', '<C-j>', '<Down>')
vim.keymap.set('i', '<C-k>', '<Up>')
vim.keymap.set('i', '<C-l>', '<Right>')
vim.keymap.set({ 'n', 'v' }, '<C-e>', '2<C-e>', { noremap = true })
vim.keymap.set({ 'n', 'v' }, '<C-y>', '2<C-y>', { noremap = true })

-- Keep Neovim's fold commands and expose them to keymap telescope pickers.
vim.keymap.set('n', 'zc', 'zc', { desc = 'Close fold' })
vim.keymap.set('n', 'zo', 'zo', { desc = 'Open fold' })
vim.keymap.set('n', 'za', 'za', { desc = 'Toggle fold' })
vim.keymap.set('n', 'zM', 'zM', { desc = 'Close all folds' })
vim.keymap.set('n', 'zR', 'zR', { desc = 'Open all folds' })

--=============================================================================
-- Tree-sitter text objects
--=============================================================================
-- Tree-sitter text objects: use after v, d, c, or y (visual, delete, change, yank).
-- vaf: visually select around a function.
-- vif: visually select inside a function.
-- vac: visually select around a class.
-- vic: visually select inside a class.
-- vaa: visually select around an argument.
-- via: visually select inside an argument.
local function select_textobject(query)
    require('nvim-treesitter-textobjects.select').select_textobject(query, 'textobjects')
end

vim.keymap.set({ 'x', 'o' }, 'af', function()
    select_textobject('@function.outer')
end, { desc = 'Select outer function' })
vim.keymap.set({ 'x', 'o' }, 'if', function()
    select_textobject('@function.inner')
end, { desc = 'Select inner function' })
vim.keymap.set({ 'x', 'o' }, 'ac', function()
    select_textobject('@class.outer')
end, { desc = 'Select outer class' })
vim.keymap.set({ 'x', 'o' }, 'ic', function()
    select_textobject('@class.inner')
end, { desc = 'Select inner class' })
vim.keymap.set({ 'x', 'o' }, 'aa', function()
    select_textobject('@parameter.outer')
end, { desc = 'Select outer argument' })
vim.keymap.set({ 'x', 'o' }, 'ia', function()
    select_textobject('@parameter.inner')
end, { desc = 'Select inner argument' })

--=============================================================================
-- Neotree plugin
--=============================================================================
vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<CR>', { desc = 'Toggle file explorer (neotree)' })
vim.keymap.set('n', '<leader>R', '<cmd>Neotree reveal<CR>', { desc = 'Reveal current file in the explorer neotree' })
-- vim.keymap.set("n", "<leader>e", ":Neotree toggle position=float<CR>", { noremap = true, silent = true }) -- focus file explorer
-- vim.cmd([[nnoremap \ :Neotree reveal<cr>]])

--=============================================================================
-- Telescope plugin
-- See `:help telescope.builtin`
--=============================================================================
local builtin = require('telescope.builtin')
local find_nvim_files = function()
    builtin.find_files({
        cwd = vim.fn.stdpath('config'),
        previewer = true,
    })
end

local function map_telescope_keymap_helper(mode, lhs, picker, desc, opts)
    vim.keymap.set(mode, lhs, function()
        local settings = type(opts) == 'function' and opts() or opts
        require('telescope.builtin')[picker](settings or {})
    end, { desc = desc })
end

vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = 'Search :help pages' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = 'Search keymaps' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = 'Search files' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = 'Search select telescope' })
vim.keymap.set('n', '<leader>tsw', builtin.grep_string, { desc = 'Search current word' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = 'Search diagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = 'Search Resume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = 'Search Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = 'Find opened buffer' })
vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = 'Fuzzy search current buffer' })
vim.keymap.set('n', '<leader>s/', builtin.live_grep, { desc = 'Search in Open Files' })
vim.keymap.set('n', '<leader>sn', find_nvim_files, { desc = 'Search neovim files' })
vim.keymap.set('n', '<leader>sj', builtin.jumplist, { desc = 'Search jumplist' })
vim.keymap.set('n', '<leader>sl', builtin.loclist, { desc = 'Search location list' })
vim.keymap.set('n', '<leader>sM', builtin.man_pages, { desc = 'Search Man pages' })
vim.keymap.set('n', '<leader>svo', builtin.vim_options, { desc = 'Search VIM options' })
vim.keymap.set('n', '<leader>svc<CR>', builtin.commands, { desc = 'Search VIM commands' })
vim.keymap.set('n', '<leader>svch', builtin.command_history, { desc = 'Search VIM commands history' })
vim.keymap.set('n', '<leader>sc', builtin.lsp_document_symbols, { desc = 'Search symbol (LSP)' })
map_telescope_keymap_helper('n', '<leader>st', 'colorscheme', 'Search colorschemes', { enable_preview = true })
vim.keymap.set('n', '<leader>sa', builtin.autocommands, { desc = 'Search auto commands' })
vim.keymap.set('n', '<leader>s"', builtin.registers, { desc = 'Search registers' })
vim.keymap.set('n', '<leader>sg<CR>', builtin.live_grep, { desc = 'Search by grep' })
vim.keymap.set('n', '<leader>sgc', builtin.git_commits, { desc = 'Search git commits' })
vim.keymap.set('n', '<leader>sgs', builtin.git_status, { desc = 'Search git status' })
vim.keymap.set('n', '<leader>sgS', builtin.git_stash, { desc = 'Search git stash' })
vim.keymap.set('n', '<leader>sgf', builtin.git_files, { desc = 'Search git files' })

--=============================================================================
-- Fugitive plugin
--=============================================================================
vim.keymap.set('n', '<leader>gd', '<cmd>Git log --graph --oneline --decorate --all<CR>', { desc = 'Show Git history graph' })

--=============================================================================
-- LSP code navigation (Telescope pickers in buffers with an attached server)
--=============================================================================
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-navigation-keymaps', { clear = true }),
    callback = function(event)
        local map = function(lhs, picker, desc, opts)
            vim.keymap.set('n', lhs, function()
                require('telescope.builtin')[picker](opts or {})
            end, { buffer = event.buf, desc = desc })
        end

        map('gd', 'lsp_definitions', 'LSP: Go to definition', { reuse_win = true })
        map('gr', 'lsp_references', 'LSP: Go to references')
        map('gI', 'lsp_implementations', 'LSP: Go to implementation', { reuse_win = true })
        map('gy', 'lsp_type_definitions', 'LSP: Go to type definition', { reuse_win = true })
    end,
})

--=============================================================================
-- Bufferline plugin
--=============================================================================
vim.keymap.set('n', '<S-h>', '<cmd>BufferLineCyclePrev<CR>', { desc = 'Previous buffer in bufferline' })
vim.keymap.set('n', '<S-l>', '<cmd>BufferLineCycleNext<CR>', { desc = 'Next buffer in bufferline' })

--=============================================================================
-- Persistence plugin
--=============================================================================
-- stylua: ignore start
local p = require('persistence')
vim.keymap.set('n', '<leader>qs', function() p.load() end, { desc = 'Restore session for current directory' })
vim.keymap.set('n', '<leader>qS', function() p.select() end, { desc = 'Select saved session' })
vim.keymap.set('n', '<leader>ql', function() p.load({ last = true }) end, { desc = 'Restore last session' })
vim.keymap.set('n', '<leader>qd', function() p.stop() end, { desc = 'Do not save current session' })
-- stylua: ignore end

--=============================================================================
-- Lualine plugin
--=============================================================================
local lualine_hidden = false
local laststatus_prev = vim.o.laststatus
local cmdheight_prev = vim.o.cmdheight

local function togglelualine()
    local ok, lualine = pcall(require, 'lualine')
    if not ok then
        vim.notify('Lualine not loaded', vim.log.levels.WARN)
        return
    end

    if lualine_hidden then
        lualine.hide({ unhide = true })
        vim.o.laststatus = laststatus_prev
        vim.o.cmdheight = cmdheight_prev
        lualine_hidden = false
    else
        laststatus_prev = vim.o.laststatus
        cmdheight_prev = vim.o.cmdheight
        lualine.hide()
        vim.o.laststatus = 0
        vim.o.cmdheight = 0
        lualine_hidden = true
    end
end
vim.keymap.set('n', '<leader>ul', togglelualine, { desc = 'Toggle lualine', noremap = true, silent = true })

--=============================================================================
-- Conform plugin
--=============================================================================
-- Manual formatting.
vim.keymap.set('n', '<leader>f', function()
    require('conform').format({ async = true })
end, { desc = 'Format buffer' })
vim.keymap.set('', '<leader>f', function()
    require('conform').format({ async = true, lsp_fallback = true })
end, { desc = 'Format selection' })

-- The old extra.floating_term module is not present in this config.
--[[
vim.keymap.set('n', '<leader>`', function()
    require('extra.floating_term').toggle_terminal()
end, { desc = 'Toggle floating terminal' })
vim.keymap.set('t', '<esc>', function()
    require('extra.floating_term').toggle_terminal()
end, { desc = 'Close floating terminal' })
]]

-- Harpoon is not installed (these mappings were already commented in the old config).
-- local harpoon = require('harpoon')
-- harpoon:setup()
-- vim.keymap.set('n', '<leader>ra', function() harpoon:list():add() end)
-- vim.keymap.set('n', '<leader>re', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
-- vim.keymap.set('n', '<leader>r1', function() harpoon:list():select(1) end)
-- vim.keymap.set('n', '<leader>r2', function() harpoon:list():select(2) end)
-- vim.keymap.set('n', '<leader>r3', function() harpoon:list():select(3) end)
-- vim.keymap.set('n', '<leader>r4', function() harpoon:list():select(4) end)
-- vim.keymap.set('n', '<C-M-p>', function() harpoon:list():prev() end)
-- vim.keymap.set('n', '<C-M-n>', function() harpoon:list():next() end)
