# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUPE=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

case `uname` in
  Darwin)
    # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
    # Initialization code that may require console input (password prompts, [y/n]
    # confirmations, etc.) must go above this block; everything else may go below.
    if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
      source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
    fi
esac

fpath=(~/google-cloud-sdk/completion/zsh $fpath)

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git golang)

source $ZSH/oh-my-zsh.sh

# set vi mode and enable reverse history search
set -o vi
bindkey "^R" history-incremental-search-backward

# pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"  # Only if you use pyenv-virtualenv
fi

# Aliases
alias k=kubectl
alias ku=kubie
alias kx=kubectx
alias kns=kubens
alias vim="$(command -v nvim)"
alias marmot=/Users/paulbrittain/Personal/bluemarmot/main

export NVM_DIR=~/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Additional configurations
eval "$(direnv hook zsh)"
source <(kubectl completion zsh)

case `uname` in
  Darwin)
    # commands for OS X go here
    # The next line updates PATH for the Google Cloud SDK.
    if [ -f '/Users/paulbrittain/Documents/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/paulbrittain/Documents/google-cloud-sdk/path.zsh.inc'; fi

    # The next line enables shell command completion for gcloud.
    if [ -f '/Users/paulbrittain/Documents/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/paulbrittain/Documents/google-cloud-sdk/completion.zsh.inc'; fi

    # Golang configuration
    export GOPRIVATE=git.helio.dev
    export GOPATH=/opt/homebrew/Cellar/go
    export GOBIN=$GOPATH/bin
    export PATH=$PATH:$GOBIN
    export PATH="$PATH:/Users/paulbrittain/.nsccli/bin"

    # Ensure /opt/homebrew/bin is at the end
    export PATH="$PATH:/opt/homebrew/bin"

    export LD_LIBRARY_PATH="/Users/paulbrittain/Helio/core/workers/thumbnailprocessor/venv/lib/python3.11/site-packages/OpenImageIO/"

    # Helio paths
    alias hcore='cd ~/Helio/core/'
    alias hargocd='cd ~/Helio/argocd/'
    alias hdeveloper='cd ~/Helio/Developer/'
    alias hterraform='cd ~/Helio/terraform/'
    alias hnative='cd ~/Helio/native-plugins/'
  ;;
  Linux)
    # The next line updates PATH for the Google Cloud SDK.
    if [ -f '/home/sabana/google-cloud-sdk/path.zsh.inc' ]; then . '/home/sabana/google-cloud-sdk/path.zsh.inc'; fi

    # The next line enables shell command completion for gcloud.
    if [ -f '/home/sabana/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/sabana/google-cloud-sdk/completion.zsh.inc'; fi

    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh    # Golang configuration
    export GOPRIVATE=git.helio.dev
    export GOPATH=$HOME/go
    export PATH=$PATH:$GOPATH/bin
    export LD_LIBRARY_PATH="~/helio/core/workers/thumbnailprocessor/venv/lib/python3.11/site-packages/OpenImageIO/"

    # Helio convenience paths
    alias hcore='cd ~/helio/core/'
    alias hargocd='cd ~/helio/argocd/'
    alias hdeveloper='cd ~/helio/developer/'
    alias hterraform='cd ~/helio/terraform/'
    alias hnative='cd ~/helio/native-plugins/'

esac

alias dotfiles='cd ~/.dotfiles'
alias k8s='nvim +"lua require(\"kubectl\").open()"'
alias icat="kitten icat"

# fzf
source <(fzf --zsh)
alias fzf="fzf --preview 'bat --color=always {}'"

case `uname` in
  Darwin)
    # commands for OS X go here
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    source ~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh
  ;;
  Linux)
    # commands for Linux go here
esac

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# MAN pages
export MANPAGER='nvim +Man!'
export MANWIDTH=999
