-- :help vim.keymap.set()

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>') -- :help hlsearch, Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' }) -- lua vim.diagnostic.goto_next()
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
-- vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror message' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Save file, ctrl+s
vim.keymap.set('n', '<C-s>', '<cmd> w <CR>')

-- quit file
-- vim.keymap.set('n', '<C-q>', '<cmd> q <CR>')

-- display empty buffer after deleting the current one
vim.keymap.set('n', '<C-q>', ':bp|sp|bn|bd<CR>', { noremap = true, silent = true })

-- delete single character without copying into register
vim.keymap.set('n', 'x', '"_x')

-- save file without auto-formatting
-- vim.keymap.set('n', '<leader>sn', '<cmd>noautocmd w <CR>', opts)

-- Vertical scroll and center
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- Find and center - center screen each time you hit 'n' or 'N' on search result
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "=============> Use h to move!! <============="<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "=============> Use l to move!! <============="<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "=============> Use k to move!! <============="<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "=============> Use j to move!! <============="<CR>')

-- Window management
vim.keymap.set('n', '<leader>v', '<C-w>v') -- split window vertically
vim.keymap.set('n', '<leader>h', '<C-w>s') -- split window horizontally
-- vim.keymap.set('n', '<leader>ve', '<C-w>=') -- make split windows equal width & height
vim.keymap.set('n', '<leader>xs', ':close<CR>', { desc = 'Close split' }) -- close current split window

-- Split navigation Use CTRL+h/j/k/l to switch between splits, :help wincmd
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Resize splits with arrow keys
vim.keymap.set('n', '<S-Up>', ':resize -2<CR>')
vim.keymap.set('n', '<S-Down>', ':resize +2<CR>')
vim.keymap.set('n', '<S-Left>', ':vertical resize -2<CR>')
vim.keymap.set('n', '<S-Right>', ':vertical resize +2<CR>')

-- Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set('n', '<C-A-h>', '<C-w>H', { desc = 'Move window to the left' })

-- vim.keymap.set("n", "<C-A-l>", "<C-w>L", { desc = "Move window to the right" }) -- doesn't work
-- vim.keymap.set('n', '<C-A-j>', '<C-w>J', { desc = 'Move window to the lower' })
-- vim.keymap.set('n', '<C-A-k>', '<C-w>K', { desc = 'Move window to the upper' })

-- Colorscheme picker/manager
vim.keymap.set('n', '<leader>sc', '<cmd>Huez<CR>', { desc = 'Choose colorscheme' })

-- jj as ESC
-- vim.keymap.set('i', 'jj', '<ESC>', { noremap = false })
-- vim.keymap.set('i', 'jk', '<ESC>', { noremap = false })

-- Buffers
vim.keymap.set('n', '<Tab>', ':bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<S-Tab>', ':bprevious<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<leader>bx', ':bdelete!<CR>', { desc = 'Close buffer' })
vim.keymap.set('n', '<leader>bn', '<cmd> enew <CR>', { desc = 'New buffer' })

-- Tabs
vim.keymap.set('n', '<leader>to', ':tabnew<CR>', { desc = 'Open new tab' })
vim.keymap.set('n', '<leader>tx', ':tabclose<CR>', { desc = 'Close tab' })
vim.keymap.set('n', '<leader>tn', ':tabn<CR>', { desc = 'Goto next tab' })
vim.keymap.set('n', '<leader>tp', ':tabp<CR>', { desc = 'Goto prev tab' })

-- Toggle line wrapping, or just use :set wrap!
vim.keymap.set('n', '<leader>lw', '<cmd>set wrap!<CR>', opts)

-- Stay in indent mode after doing >> or <<
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- Toggle lualine
local lualine_hidden = false
local laststatus_prev = vim.o.laststatus
local cmdheight_prev = vim.o.cmdheight

local function ToggleLualine()
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
vim.keymap.set('n', '<leader>ul', ToggleLualine, { desc = 'Toggle lualine', noremap = true, silent = true })

-- Terminal
vim.keymap.set('n', '<leader>tv', [[<cmd>vsplit | term<cr>A]], { desc = 'Open [t]erminal in [v]ertical split' })
vim.keymap.set('n', '<leader>th', [[<cmd>split | term<cr>A]], { desc = 'Open [t]erminal in [h]orizontal split' })

vim.keymap.set('n', '<leader>;', ':', { desc = 'Command mode' })
vim.keymap.set('n', '<leader>c', ':', { desc = 'Command mode' })
