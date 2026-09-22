# Packages installed without root privilages are placed under $HOME/
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="eastwood"

# Marking untracked files under VCS as dirty.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

################################################################################
# fzf
################################################################################
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

fzfv() {
    local file
    file=$(fzf) || return
    [[ -n "$file" ]] && vim "$file"
}

################################################################################
# yazi terminal file manager
################################################################################
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
alias ta="tmux attach"
alias ha="herdr"
alias cls="clear"
alias gdb="gdb -q"
alias ls="eza --icons --group-directories-first"
alias ll="ls -l --header --group-directories-first"
alias llb="ls -l --grid --header --group-directories-first"
alias dotf="cd ~/git/dotfiles"
alias expl='nautilus -w . >/dev/null 2>&1 &!'
alias info="info --vi-keys"

export MANWIDTH=80
export LANG=en_US.UTF-8
export MANPATH="/usr/local/man:$MANPATH"
export EDITOR='vim'

################################################################################
# Distro specific
################################################################################
if [[ -r /etc/os-release ]]; then
    source /etc/os-release

    if [[ "$ID" == "fedora" || "$ID_LIKE" == *fedora* ]]; then
    elif [[ "$ID" == "debian" || "$ID_LIKE" == *debian* ]]; then
        eval "$(keychain --eval --agents ssh ~/.ssh/default_key --quiet)"
    fi
fi

################################################################################
# Windows paths for msys2 ucrt64 shell
################################################################################
if [[ "$OSTYPE" == msys* || -n "$MSYSTEM" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    export PATH="$HOME/.config/emacs/bin:$PATH"
    export PATH="$HOME/AppData/Local/Programs/Podman:$PATH"
    export PATH="$HOME/AppData/Local/omp:$PATH"
    export PATH="$HOME/.herdr/packages/standalone/releases/0.9.0-x86_64-pc-windows-msvc/:$PATH"
    export PATH="/c/nvm4w/nodejs/:$PATH"
fi

################################################################################
# Local config
################################################################################
[[ -f ~/.secrets/secrets.zsh ]] && source ~/.secrets/secrets.zsh
[[ -f ~/.local.zsh ]] && source ~/.local.zsh
