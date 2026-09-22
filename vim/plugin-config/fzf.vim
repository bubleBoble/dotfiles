" ========================================
" FZF Keymaps
" ========================================

nnoremap <leader>sf :Files<CR>
nnoremap <leader>sg :Rg<CR>
nnoremap <leader>sn :Files ~/.vim<CR>
nnoremap <leader>sb :Buffers<CR>       " Search active buffers
nnoremap <leader>sh :Helptags<CR>      " Search Vim help documentation
nnoremap <leader>sl :BLines<CR>        " Fuzzy search lines in current buffer
nnoremap <leader>sL :Lines<CR>         " Fuzzy search lines across all loaded buffers
nnoremap <leader>sm :Marks<CR>         " Search Vim marks
nnoremap <leader>sc :Commits<CR>       " Search Git commits (requires Fugitive for full integration)
nnoremap <leader>ss :GFiles?<CR>       " Search modified Git files (git status)
nnoremap <leader>s/ :History/<CR>      " Search command-line history
