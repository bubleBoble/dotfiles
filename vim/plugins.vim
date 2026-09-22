" ========================================
" Plugin Manifest
" ========================================

call plug#begin()
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sensible'
call plug#end()


" ========================================
" Per-Plugin Configuration
" ========================================
" Each plugin's settings/keymaps live in their own file under
" plugin-config/, sourced automatically here.

for s:f in glob(expand('<sfile>:p:h') . '/plugin-config/*.vim', 0, 1)
    execute 'source ' . s:f
endfor
unlet s:f
