-- :help vim.keymap.set()

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>') -- :help hlsearch, Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' }) -- lua vim.diagnostic.goto_next()
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror message' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "=============> Use h to move!! <============="<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "=============> Use l to move!! <============="<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "=============> Use k to move!! <============="<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "=============> Use j to move!! <============="<CR>')

-- Split navigation Use CTRL+<hjkl> to switch between splits, :help wincmd
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Some terminals have colliding keymaps or are not able to send distinct keycodes
vim.keymap.set('n', '<C-A-h>', '<C-w>H', { desc = 'Move window to the left' })

-- vim.keymap.set("n", "<C-A-l>", "<C-w>L", { desc = "Move window to the right" }) -- doesn't work
vim.keymap.set('n', '<C-A-j>', '<C-w>J', { desc = 'Move window to the lower' })
vim.keymap.set('n', '<C-A-k>', '<C-w>K', { desc = 'Move window to the upper' })

-- Colorscheme picker/manager
vim.keymap.set('n', '<leader>sc', '<cmd>Huez<CR>', { desc = 'Choose colorscheme' })

-- mini.map (minimap left sidebar)
-- vim.keymap.set('n', '<leader>mo', MiniMap.open, { desc = 'Minimap open' })
-- vim.keymap.set('n', '<leader>mr', MiniMap.refresh, { desc = 'Minimap refresh' })
-- vim.keymap.set('n', '<leader>mc', MiniMap.close, { desc = 'Minimap close' })
-- vim.keymap.set('n', '<leader>mt', MiniMap.toggle, { desc = 'Minimap toggle' })
-- vim.keymap.set('n', '<leader>ms', MiniMap.toggle_side, { desc = 'Minimap toggle side' })
-- vim.keymap.set('n', '<Leader>mf', MiniMap.toggle_focus, { desc = 'Minimap toggle focus' })

-- ========================================================================== --
-- From old config
-- ========================================================================== --

-- -- Disable the spacebar key's default behavior in Normal and Visual modes
-- vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- -- For conciseness
-- local opts = { noremap = true, silent = true }

-- -- Save file, ctrl+s
-- vim.keymap.set('n', '<C-s>', '<cmd> w <CR>', opts)

-- -- save file without auto-formatting
-- vim.keymap.set('n', '<leader>sn', '<cmd>noautocmd w <CR>', opts)

-- -- quit file
-- vim.keymap.set('n', '<C-q>', '<cmd> q <CR>', opts)

-- -- delete single character without copying into register
-- vim.keymap.set('n', 'x', '"_x', opts)

-- -- Vertical scroll and center
-- vim.keymap.set('n', '<C-d>', '<C-d>zz', opts)
-- vim.keymap.set('n', '<C-u>', '<C-u>zz', opts)

-- -- Find and center
-- vim.keymap.set('n', 'n', 'nzzzv', opts)
-- vim.keymap.set('n', 'N', 'Nzzzv', opts)

-- -- Resize with arrows
-- vim.keymap.set('n', '<S-Up>', ':resize -2<CR>', opts)
-- vim.keymap.set('n', '<S-Down>', ':resize +2<CR>', opts)
-- vim.keymap.set('n', '<S-Left>', ':vertical resize -2<CR>', opts)
-- vim.keymap.set('n', '<S-Right>', ':vertical resize +2<CR>', opts)

-- -- Buffers ???
-- vim.keymap.set('n', '<Tab>', ':bnext<CR>', opts)
-- vim.keymap.set('n', '<S-Tab>', ':bprevious<CR>', opts)
-- vim.keymap.set('n', '<leader>x', ':bdelete!<CR>', opts) -- close buffer
-- vim.keymap.set('n', '<leader>b', '<cmd> enew <CR>', opts) -- new buffer

-- -- Window management
-- vim.keymap.set('n', '<leader>v', '<C-w>v', opts) -- split window vertically
-- vim.keymap.set('n', '<leader>h', '<C-w>s', opts) -- split window horizontally
-- vim.keymap.set('n', '<leader>se', '<C-w>=', opts) -- make split windows equal width & height
-- vim.keymap.set('n', '<leader>xs', ':close<CR>', opts) -- close current split window

-- -- Navigate between splits
-- vim.keymap.set('n', '<C-k>', ':wincmd k<CR>', opts)
-- vim.keymap.set('n', '<C-j>', ':wincmd j<CR>', opts)
-- vim.keymap.set('n', '<C-h>', ':wincmd h<CR>', opts)
-- vim.keymap.set('n', '<C-l>', ':wincmd l<CR>', opts)

-- -- Tabs
-- vim.keymap.set('n', '<leader>to', ':tabnew<CR>', opts) -- open new tab
-- vim.keymap.set('n', '<leader>tx', ':tabclose<CR>', opts) -- close current tab
-- vim.keymap.set('n', '<leader>tn', ':tabn<CR>', opts) --  go to next tab
-- vim.keymap.set('n', '<leader>tp', ':tabp<CR>', opts) --  go to previous tab

-- -- Toggle line wrapping
-- vim.keymap.set('n', '<leader>lw', '<cmd>set wrap!<CR>', opts)

-- -- Stay in indent mode
-- vim.keymap.set('v', '<', '<gv', opts)
-- vim.keymap.set('v', '>', '>gv', opts)

-- -- Keep last yanked when pasting
-- vim.keymap.set('v', 'p', '"_dP', opts)

-- -- nnoremap <leader>lb :ls<CR>:b<space>
-- vim.keymap.set('n', '<leader>lb', ':ls<CR>:b ', { noremap = true })
