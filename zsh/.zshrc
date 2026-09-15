# Packages installed without root privilages are placed under $HOME/
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="miloshadzic"

# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Marking untracked files under VCS as dirty.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(
        git
        zsh-autosuggestions
        zsh-syntax-highlighting
        # nvm
)

source $ZSH/oh-my-zsh.sh

export MANPATH="/usr/local/man:$MANPATH"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
        export EDITOR='vim'
else
        export EDITOR='nvim'
fi

################################################################################
# NVM stuff lol
################################################################################
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

################################################################################
# Run tmux by default
################################################################################
# if command -v tmux &> /dev/null && \
#    [[ -o interactive ]] && \
#    [[ -z "$VSCODE_RESOLVING_ENVIRONMENT" ]] && \
#    [[ "$TERM_PROGRAM" != "vscode" ]] && \
#    [[ ! "$TERM" =~ screen ]] && \
#    [[ ! "$TERM" =~ tmux ]] && \
#    [[ -z "$TMUX" ]]; then
#         exec tmux
# fi

################################################################################
# fzf
################################################################################
# source <(fzf --zsh)

fman ()
{
        local man_page;
        man_page=$(man -k . | sort | fzf --prompt='Man Pages> ' --preview='echo {} | awk "{print \$1}" | xargs man' --preview-window=right:60%:wrap);
        man "$(echo "$man_page" | awk '{print $1}')"
}

################################################################################
# vgrep with fzf - https://github.com/vrothberg/vgrep
################################################################################
fvgrep() {
      INITIAL_QUERY="$1"
      VGREP_PREFIX="vgrep --no-header "
      FZF_DEFAULT_COMMAND="$VGREP_PREFIX '$INITIAL_QUERY'" \
      fzf --bind "change:reload:$VGREP_PREFIX {q} || true" --ansi --phony --tac --query "$INITIAL_QUERY" \
      | awk '{print $1}' | xargs -I{} -o vgrep --show {}
}

################################################################################
# yazi terminal file manager
################################################################################

# change pwd when quiting yazi
# https://yazi-rs.github.io/docs/quick-start
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

################################################################################
# Aliases
################################################################################
alias fzf="fzf --height 40% --layout reverse --border"
# alias fzfv ="vim $(fzf)"
alias vi="nvim"
alias vimks='NVIM_APPNAME="nvim-kickstart" nvim'
alias vimlazyvim='NVIM_APPNAME="nvim-lazyvim" nvim'
alias ta="tmux attach"
alias ha="herdr"
alias cls="clear"
alias gdb="gdb -q"
alias cs="cd /home/dadam/Documents/05-gd-a-notatki/tools"
alias ls="eza --icons --group-directories-first"
alias ll="ls -l --group-directories-first"
alias dotf="cd /home/dadam/a-dev/dotfiles"
alias expl='nautilus -w . >/dev/null 2>&1 &!'
alias info="info --vi-keys"

export MANWIDTH=80

# if [ -z "${SSH_AUTH_SOCK:-}" ]; then
#     eval "$(ssh-agent -s)" >/dev/null
# fi
# ssh-add -l

export LANG=en_US.UTF-8
export PATH=/home/dadam/go/bin:$PATH

# Windows paths for msys2 ucrt64 shell
if [[ "$OSTYPE" == msys* || -n "$MSYSTEM" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    export PATH="$HOME/.config/emacs/bin:$PATH"
    export PATH="$HOME/AppData/Local/Programs/Podman:$PATH"
    export PATH="$HOME/AppData/Local/omp:$PATH"
    export PATH="$HOME/.herdr/packages/standalone/releases/0.9.0-x86_64-pc-windows-msvc/:$PATH"
    export PATH="/c/nvm4w/nodejs/:$PATH"
fi

eval "$(zoxide init zsh)"

export PATH="$HOME/.opencode/bin:$PATH"
[[ -f ~/.secrets/secrets.zsh ]] && source ~/.secrets/secrets.zsh

alias claude="env -u ANTHROPIC_API_KEY claude"
