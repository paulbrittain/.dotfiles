# --- History Configuration ---
HISTSIZE=20000
SAVEHIST=$HISTSIZE
HISTFILE=~/.zsh_history

# Editor
export EDITOR=vim

setopt HIST_IGNORE_SPACE        # ignore commands starting with space
setopt HIST_IGNORE_ALL_DUPS     # no duplicate entries
setopt HIST_SAVE_NO_DUPS        # don't save dupes to file
setopt HIST_FIND_NO_DUPS        # don't show dupes in search
setopt HIST_REDUCE_BLANKS       # strip excess whitespace
setopt HIST_EXPIRE_DUPS_FIRST   # expire dupes before unique
setopt HIST_SAVE_BY_COPY        # atomic write, avoid clobbering
setopt HIST_FCNTL_LOCK          # use fcntl() to lock $HISTFILE during writes;
                                # prevents torn multi-line entries when several
                                # tmux panes' zsh shells write concurrently

setopt INC_APPEND_HISTORY_TIME  # write immediately, include elapsed time
setopt EXTENDED_HISTORY         # timestamp support
unsetopt SHARE_HISTORY
unsetopt APPEND_HISTORY

export HISTORY_IGNORE="(\&|[bf]g|c|clear|history|exit|q|pwd|* --help)"

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

# --- Plugin: Completions & Suggestions ---
fpath=(~/.zsh/zsh-completions $fpath)
[[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# Accept autosuggestion with Tab instead of Right Arrow
bindkey '^ ' autosuggest-accept
bindkey '^[[C' autosuggest-accept

# NVM
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

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

    # Syntax Highlighting
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

    source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
    [[ -f /usr/share/doc/pkgfile/command-not-found.zsh ]] && source /usr/share/doc/pkgfile/command-not-found.zsh

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
alias vim="$(command -v nvim)"
alias cd='z'
alias ls='ls --color=auto'

# --- History Search ---
if [[ $(uname) == "Linux" ]]; then
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down
fi

# --- fzf Integration ---
export FZF_CTRL_R_OPTS="--exact"  # substring match by default; prefix query with ' for fuzzy
source <(fzf --zsh)
alias fzf="fzf --preview 'bat --color=always {}'"

# --- MAN Pages ---
export MANPAGER='nvim +Man!'
export MANWIDTH=999
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

source ~/.anthropic_env

. "$HOME/.local/bin/env"
