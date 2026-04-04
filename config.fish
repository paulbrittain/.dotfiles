# --- CachyOS defaults to be overridden below this line ---
source /usr/share/cachyos-fish-config/cachyos-config.fish

# --- Editor ---
set -x EDITOR nvim

# --- Vi ---
fish_vi_key_bindings

# --- Path ---
fish_add_path $HOME/bin /usr/local/bin

# --- Golang ---
set -x GOPRIVATE git.helio.dev
set -x GOPATH $HOME/go
fish_add_path $GOPATH/bin

# --- pyenv ---
set -x PYENV_ROOT $HOME/.pyenv
fish_add_path $PYENV_ROOT/bin $PYENV_ROOT/shims
if command -q pyenv
    pyenv init - | source
end

# --- nvm (via fisher plugin) ---
# Run: fisher install jorgebucaran/nvm.fish

# --- direnv ---
if command -q direnv
    direnv hook fish | source
end

# --- zoxide (replaces cd) ---
if command -q zoxide
    zoxide init fish | source
end

# --- kubectl ---
if command -q kubectl
    kubectl completion fish | source
    alias k=kubectl
end

# --- Google Cloud SDK ---
if test -f $HOME/google-cloud-sdk/path.fish.inc
    source $HOME/google-cloud-sdk/path.fish.inc
end

# --- fzf ---
if command -q fzf
    fzf --fish | source
end

# --- Aliases ---
alias ku=kubie
alias kx='ku ctx'
alias kns='ku ns'
alias vim=nvim
alias k8s='nvim +"lua require(\"kubectl\").open()"'
alias ls='ls --color=auto'

alias cd=z
alias fzf="fzf --preview 'bat --color=always {}'"

# --- Man pages ---
set -x MANPAGER 'nvim +Man!'
set -x MANWIDTH 999
