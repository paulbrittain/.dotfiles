# --- CachyOS defaults to be overridden below this line ---
if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
end

# --- Editor ---
set -x EDITOR nvim

# --- Vi ---
fish_vi_key_bindings

# --- Path ---
fish_add_path $HOME/bin /usr/local/bin

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

# --- Google Cloud SDK ---
if test -f $HOME/google-cloud-sdk/path.fish.inc
    source $HOME/google-cloud-sdk/path.fish.inc
end

# --- fzf ---
if command -q fzf
    fzf --fish | source
end

# --- Aliases ---
alias vim=nvim
alias ls='ls --color=auto'

alias cd=z
alias fzf="fzf --preview 'bat --color=always {}'"

# --- Man pages ---
set -x MANPAGER 'nvim +Man!'
set -x MANWIDTH 999
zoxide init fish | source
set -gx VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH
