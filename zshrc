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

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="robbyrussell"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git golang)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#
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
alias kx=kubectx
alias kns=kubens
alias vim=nvim
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

    # Add timestamps to the prompt
    # PROMPT='%{$fg[yellow]%}[%D{%f/%m/%y} %D{%L:%M:%S}] '$PROMPT

    # Ensure /opt/homebrew/bin is at the end
    export PATH="$PATH:/opt/homebrew/bin"
    export KUBECONFIG="/Users/paulbrittain/.kube/combinedconfig"

    export LD_LIBRARY_PATH="/Users/paulbrittain/Helio/core/workers/thumbnailprocessor/venv/lib/python3.11/site-packages/OpenImageIO/"

    # Helio paths
    alias hcore='cd ~/Helio/core/'
    alias hargocd='cd ~/Helio/argocd/'
    alias hdeveloper='cd ~/Helio/Developer/'
    alias hterraform='cd ~/Helio/terraform/'
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

    #export KUBECONFIG="$HOME/.kube/config:$HOME/helio/core/core-kubeconfig:$HOME/.kube/az-eus-2:$HOME/.kube/az-neu-1:$HOME/.kube/azure-eu-v3:$HOME/.kube/azure-eu-v6"
    export KUBECONFIG="$HOME/.kube/combined-config"

    export LD_LIBRARY_PATH="~/helio/core/workers/thumbnailprocessor/venv/lib/python3.11/site-packages/OpenImageIO/"

    # Helio paths
    alias hcore='cd ~/helio/core/'
    alias hargocd='cd ~/helio/argocd/'
    alias hdeveloper='cd ~/helio/developer/'
    alias hterraform='cd ~/helio/terraform/'

esac

alias dotfiles='cd ~/.dotfiles'
alias k8s='nvim +"lua require(\"kubectl\").open()"'

alias icat="kitten icat"

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
