let mapleader=" "
let maplocalleader=" "

set number
set relativenumber
set mouse=a
set noshowmode
set nowrap
set breakindent
set linebreak
set expandtab
set tabstop=8
set shiftwidth=4
set softtabstop=4
set virtualedit=block,onemore
set clipboard=unnamedplus
set undofile
set ignorecase
set smartcase
set smartindent
set signcolumn=yes
set updatetime=250
set timeoutlen=300
set splitright
set splitbelow
set list
set listchars=tab:»\ ,trail:·,nbsp:␣
set cursorline
set scrolloff=0
set sidescrolloff=0
set noconfirm
set termguicolors
set hlsearch
set whichwrap=bs<>[]hl
set numberwidth=4
set noswapfile
set showtabline=1
set cmdheight=1
set backspace=indent,eol,start
set pumheight=10
set conceallevel=0
set nobackup
set nowritebackup
set hidden
set wildmenu

augroup c_settings
    autocmd!
    autocmd FileType c,h setlocal colorcolumn=80
augroup END

nnoremap <Esc> :nohlsearch<CR>
nnoremap <C-s> :w<CR>
nnoremap <C-q> :bp\|sp\|bn\|bd<CR>
nnoremap x "_x
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap <leader>v <C-w>v
nnoremap <leader>h <C-w>s
nnoremap <leader>xs :close<CR>

nnoremap <C-h> <C-w><C-h>
nnoremap <C-l> <C-w><C-l>
nnoremap <C-j> <C-w><C-j>
nnoremap <C-k> <C-w><C-k>

nnoremap <S-Up> :resize -2<CR>
nnoremap <S-Down> :resize +2<CR>
nnoremap <S-Left> :vertical resize -2<CR>
nnoremap <S-Right> :vertical resize +2<CR>

nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>
nnoremap <leader>bx :bdelete!<CR>
nnoremap <leader>bn :enew<CR>

nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>
nnoremap <leader>bx :bdelete!<CR>
nnoremap <leader>bn :enew<CR>

nnoremap <leader>lw :set wrap!<CR>

" stay in visual indent mode
vnoremap < <gv
vnoremap > >gv

" exit terminal mode
tnoremap <Esc><Esc> <C-\><C-n>

" vertical terminal
nnoremap <leader>tv :40vsplit \| terminal<CR>A

" enter command mode
nnoremap <leader>; :
nnoremap <leader>c :

inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>

nnoremap <C-e> 2<C-e>
nnoremap <C-y> 2<C-y>
vnoremap <C-e> 2<C-e>
vnoremap <C-y> 2<C-y>

set termguicolors
colorscheme elflord
