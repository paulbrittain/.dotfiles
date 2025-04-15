# --- History Configuration ---
HISTSIZE=10000
SAVEHIST=$HISTSIZE
HISTFILE=~/.zsh_history
HISTDUPE=erase

setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# --- Prompt (Powerlevel10k) ---
case $(uname) in
  Darwin)
    if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
      source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
    fi
    ;;
esac

[[ -f ~/powerlevel10k/powerlevel10k.zsh-theme ]] && source ~/powerlevel10k/powerlevel10k.zsh-theme
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# --- Shell Behavior ---
set -o vi
bindkey "^R" history-incremental-search-backward

# --- Initialization ---
zstyle ':completion:*' rehash true
autoload -U compinit && compinit

# --- Plugin: Completions & Suggestions ---
fpath=(~/.zsh/zsh-completions $fpath)
[[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# Accept autosuggestion with Tab instead of Right Arrow
bindkey '^ ' autosuggest-accept

# --- Path Configuration ---
export PATH=$HOME/bin:/usr/local/bin:$PATH
fpath=(~/google-cloud-sdk/completion/zsh $fpath)

# --- Python / Pyenv ---
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

# --- Node Version Manager (nvm) ---
export NVM_DIR=~/.nvm
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# --- Other Hooks & Tools ---
eval "$(direnv hook zsh)"
source <(kubectl completion zsh)
eval "$(zoxide init zsh)"

# --- Platform-Specific Configuration ---
case $(uname) in
  Darwin)
    # Google Cloud SDK
    [[ -f "$HOME/Documents/google-cloud-sdk/path.zsh.inc" ]] && source "$HOME/Documents/google-cloud-sdk/path.zsh.inc"
    [[ -f "$HOME/Documents/google-cloud-sdk/completion.zsh.inc" ]] && source "$HOME/Documents/google-cloud-sdk/completion.zsh.inc"

    # Golang
    export GOPRIVATE=git.helio.dev
    export GOPATH=/opt/homebrew/Cellar/go
    export GOBIN=$GOPATH/bin
    export PATH=$PATH:$GOBIN
    export PATH="$PATH:$HOME/.nsccli/bin:/opt/homebrew/bin"

    # OpenImageIO Library
    export LD_LIBRARY_PATH="$HOME/Helio/core/workers/thumbnailprocessor/venv/lib/python3.11/site-packages/OpenImageIO/"

    # Syntax Highlighting
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    source ~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh
    ;;

  Linux)
    # Google Cloud SDK
    [[ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]] && source "$HOME/google-cloud-sdk/path.zsh.inc"
    [[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]] && source "$HOME/google-cloud-sdk/completion.zsh.inc"

    # Golang
    export GOPRIVATE=git.helio.dev
    export GOPATH=$HOME/go
    export PATH=$PATH:$GOPATH/bin

    # Syntax Highlighting
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

    # OpenImageIO Library
    export LD_LIBRARY_PATH="$HOME/helio/core/workers/thumbnailprocessor/venv/lib/python3.11/site-packages/OpenImageIO/"
    ;;
esac

# --- Aliases ---
alias k=kubectl
alias ku=kubie
alias kx=kubectx
alias kns=kubens
alias vim="$(command -v nvim)"
alias k8s='nvim +"lua require(\"kubectl\").open()"'
alias cd='z'

# --- fzf Integration ---
source <(fzf --zsh)
alias fzf="fzf --preview 'bat --color=always {}'"

# --- MAN Pages ---
export MANPAGER='nvim +Man!'
export MANWIDTH=999
