" ========================================
" Options
" ========================================
set encoding=UTF-8
set spelllang=en_us,de_de,es_es
set nohlsearch " Disable highlight on search
set number " Enable line numbers
set mouse=a " Enable mouse mode
set breakindent " Enable break indent
set undofile " Save undo history
set ignorecase " Case-insensitive searching unless \C or capital in search
set smartcase " Enable smart case
set signcolumn=yes " Keep signcolumn on by default
set updatetime=250 " Decrease update time
set timeoutlen=300 " Time to wait for a mapped sequence to complete (in milliseconds)
set nobackup " Don't create a backup file
set nowritebackup " Don't write backup before overwriting
set completeopt=menuone,noselect " Better completion experience
set whichwrap+=<,>,[,],h,l " Allow certain keys to move to the next line
set nowrap " Display long lines as one line
set linebreak " Don't break words when wrapping
set scrolloff=8 " Keep 8 lines above/below cursor
set sidescrolloff=8 " Keep 8 columns to the left/right of cursor
set relativenumber " Use relative line numbers
set numberwidth=4 " Number column width
set shiftwidth=4 " Spaces per indentation
set tabstop=4 " Spaces per tab
set softtabstop=4 " Spaces per tab during editing ops
set expandtab " Convert tabs to spaces
set nocursorline " Don't highlight the current line
set splitbelow " Horizontal splits below current window
set splitright " Vertical splits to the right
set noswapfile " Don't use a swap file
set hidden " Allow switching buffers without saving
set smartindent " Smart indentation
set showtabline=2 " Always show tab line
set backspace=indent,eol,start " Configurable backspace behavior
set pumheight=10 " Popup menu height
set conceallevel=0 " Make `` visible in markdown
set fileencoding=utf-8 " File encoding
set cmdheight=1 " Command line height
set autoindent " Auto-indent new lines
set shortmess+=c " Don't show completion menu messages
set iskeyword+=- " Treat hyphenated words as whole words
set showmatch " show the matching part of pairs [] {} and ()
set laststatus=2 " Show status bar
set statusline=%f " Path to the file
set statusline+=%= " Switch to the right side
set statusline+=%l " Current line
set statusline+=/ " Separator
set statusline+=%L " Total lines


" ========================================
" Syntax, Colors & Display
" ========================================

" Syntax highlighting
syntax on

" Sync clipboard with OS
if system('uname -s') == "Darwin\n"
  set clipboard=unnamed "OSX
else
  set clipboard=unnamedplus "Linux
endif

" True colors
if !has('gui_running') && &term =~ '\%(screen\|tmux\)'
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
set termguicolors

" Use a line cursor within insert mode and a block cursor everywhere else.
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"

" Netrw
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25 
" Use 'l' instead of <CR> to open files
augroup netrw_setup | au!
    au FileType netrw nmap <buffer> l <CR>
augroup END

" Colorscheme
" colorscheme industry
colorscheme wildcharm
set background=dark
" hi Normal ctermbg=NONE guibg=NONE
" hi NonText ctermbg=NONE guibg=NONE guifg=NONE ctermfg=NONE
" hi VertSplit guibg=NONE guifg=NONE ctermbg=NONE ctermfg=NONE

" Set undofile location so that vim doesn't make a mess everywhere
if has('persistent_undo')         "check if your vim version supports
  set undodir=$HOME/.vim/undo     "directory where the undo files will be stored
  set undofile                    "turn on the feature
endif
