# --- History Configuration ---
HISTSIZE=20000
SAVEHIST=$HISTSIZE
HISTFILE=~/.zsh_history

setopt HIST_IGNORE_SPACE        # ignore commands starting with space
setopt HIST_IGNORE_ALL_DUPS     # no duplicate entries
setopt HIST_SAVE_NO_DUPS        # don't save dupes to file
setopt HIST_FIND_NO_DUPS        # don't show dupes in search
setopt HIST_REDUCE_BLANKS       # strip excess whitespace
setopt HIST_EXPIRE_DUPS_FIRST   # expire dupes before unique
setopt HIST_SAVE_BY_COPY        # atomic write, avoid clobbering

setopt APPEND_HISTORY           # append instead of overwrite
setopt EXTENDED_HISTORY         # timestamp support

# unset these to avoid issues
unsetopt SHARE_HISTORY
unsetopt INC_APPEND_HISTORY

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
autoload -Uz compinit
compinit

if command -v kubectl &>/dev/null; then
  source <(kubectl completion zsh)
  alias k='kubectl'
  compdef k=kubectl
fi

# --- Plugin: Completions & Suggestions ---
fpath=(~/.zsh/zsh-completions $fpath)
[[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# Accept autosuggestion with Tab instead of Right Arrow
bindkey '^ ' autosuggest-accept
bindkey '^[[C' autosuggest-accept

# --- Path Configuration ---
export PATH=$HOME/bin:/usr/local/bin:$PATH
fpath=(~/google-cloud-sdk/completion/zsh $fpath)

# --- Load zsh-defer (required for lazy loading) ---
if [[ -f ~/.zsh/zsh-defer/zsh-defer.plugin.zsh ]]; then
  source ~/.zsh/zsh-defer/zsh-defer.plugin.zsh
fi

# --- Lazy Loaded Tools ---
zsh-defer 'export PYENV_ROOT="$HOME/.pyenv"; export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"'
zsh-defer '[ -x "$(command -v pyenv)" ] && eval "$(pyenv init --path)"; eval "$(pyenv init -)"; eval "$(pyenv virtualenv-init -)"'

zsh-defer 'export NVM_DIR="$HOME/.nvm"'
zsh-defer '[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"'
zsh-defer '[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"'

zsh-defer 'eval "$(direnv hook zsh)"'

# --- Zoxide Better CD ---
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
    export LD_LIBRARY_PATH="$HOME/helio/core/.venv/lib/python3.11/site-packages/OpenImageIO/"

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
    #export LD_LIBRARY_PATH="$HOME/helio/core/workers/thumbnailprocessor/venv/lib/python3.11/site-packages/OpenImageIO/"
    ;;
esac

# Node Version Manager
case $(uname) in
  Darwin)
    export NVM_DIR="$HOME/.nvm"
    [ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"
    [ -s "$(brew --prefix nvm)/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix nvm)/etc/bash_completion.d/nvm"
    ;;
esac

# --- Aliases ---
alias ku=kubie
alias kx='ku ctx'
alias kns='ku ns'
alias vim="$(command -v nvim)"
alias k8s='nvim +"lua require(\"kubectl\").open()"'
alias cd='z'
alias ls='ls --color=auto'

# --- fzf Integration ---
source <(fzf --zsh)
alias fzf="fzf --preview 'bat --color=always {}'"

# --- MAN Pages ---
export MANPAGER='nvim +Man!'
export MANWIDTH=999
