* https://wiki.gentoo.org/wiki/Vim/Guide
  * patrz linki na dole
* http://tnerual.eriogerg.free.fr/vimqrc.html
  * cheatsheet który można sobie scustomizować
* https://thomer.com/vi/vi.html
  * vi lovers
* https://www.nerdfonts.com/font-downloads
  * nerd fonts

* https://github.com/nvim-lua/kickstart.nvim.git
  * kickstart - patrz instalacja, zależności, czcionki, FAQ
    * w szczególności w FAQ patrz na "NVIM_APPNAME"

* https://github.com/ThePrimeagen/init.lua
  * primeagen

# Neovim
```sh
:tutor

:help nvim
:help lua-guide
:checkhealth
:help
:help news              # see changelog
:help nvim-features
:help vim.o

:s/<regexp>/<replacement>/g
:s/<regexp>/<replacement>/gc

:set autoindent
:set tabstop=4
ctrl d                  # move one auto indent right
ctrl t                  # move one auto indent left

:sp term://bash
:sp term://htop

space q                 # diagnostics quick list
space [d                # go to prev diagnostics msg
space ]d                # go to next diagnostics msg
space e                 # show diag error msg

ctrl h
     j
     k
     l

ctrl alt h    /    ctrl w H
         j                J
         k                K
         l                L

:Lazy
:Lazy ?                 # zajebiste
:Lazy sync

:help <plugin_name>
:help gitsigns

:help telescope
:help telescope.setup()
:Telescope help_tags
:Telescope
    ctrl /
:Telescope
    ESC
        ?
```

Ogólnie wszystkie keymapy do telesopa są pod `<leader>s`
```sh
space sh                # search help (kickstart)
space sk                # keymaps
space sf                # search files in curr workspace
space ss                # search builtin ie. To tak jak :Telescope, czyli np można zmienić tu colorscheme
space sw                # grep string
space sg                # live grep
space sd                # search diagnostics
space sr                # resume search
space s.                # search recent files
space space             # find existing buffers
space /                 # search current buffer
space s/                # live grep open files
space sn                # search neovim config files
```

### LSP
Patrz:
```sh
:help lsp-vs-treesitter
grn                     # rename variable under cursor
gra                     # execute a code action
grr                     # go to references
gri                     # go to implementation
grd                     # go to definition
ctrl t                  # go back
grD                     # go to declaration
g0                      # fuzzy find symbols in curr DOCUMENT
gW                      # fuzzy find symbols in curr WORKSPACE
grt                     # go to type definition
space t h               # toggle inlay hints
:help lspconfig-all
```

```sh
space f                 # format current buffer
:Telescope colorscheme
:colorscheme <TAB>
```

### Mason

Mason is a package manager which allows you to easily manage external editor
tooling such as LSP servers, DAP server, liters and formatters

see `:help standard-path`

```sh
:Mason
:Mason
    g?
```


### Run lua code inside neovim

:lua vim.opt.number = true
:lua vim.opt.number = false

### lua config vs vim config

:help lua-options
:help lua-guide-options 

`:set` to to samo co `vim.o`
```sh
set number # vimscript
vim.o.numer = true # lua

set wildignore=*.o,*.a,__pychache__ # vimscript
vim.o.wildignore = '*.o,*.a,__pychache__' # lua

vim.bo  -- buffer scoped options
vim.wo  -- window scoped options
```

w kickstarterze jest zajebiste okeinko z podpowiedziami, i np. ctrl+w h/j/k/l
jest przemapowane na ctrl+h/j/k/l ale jak nacisne ctrl+w to widze oryginalne
keymap'y z vim'a

# tools
vgrep

# nvim kickstart setup

git clone https://github.com/nvim-lua/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
rm -rf ~/.local/share/nvim/


### Use NVIM_APPNAME to keep multiple nvim configs
  * e.g.: use `NVIM_APPNAME=nvim-<SETUPNAME>`
  * clone kickstart into: `~/.config/nvim-kickstart`
  * create this alias:
  ```sh
  alias vimks='NVIM_APPNAME="nvim-kickstart" nvim'
  ```

### Uninstalling kickstart
* **data**: `~/.local/share/nvim-kickstart`
* **state**: `~/.local/state/nvim-kickstart`
* **lockfile**: `~/.config/nvim-kickstart`

# Notatki/wyjaśnienia
```lua
---@type vim.Option
local rtp = vim.opt.rtp -- rtp: runtimepath
rtp:prepend(lazypath)
```

to jest tanotacja do lua, używane np. przerz lua-language-server, mówi:
  * *the variable below is a `vim.option` object*

This codes prepends lazy plugin manager path to the runtimepath variable in
vim.opt so that the lazy.nvim is found before other plugins
