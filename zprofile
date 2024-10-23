if [[ "$(uname)" == "Darwin" ]]; then
    # macOS specific configurations
    eval "$(/opt/homebrew/bin/brew shellenv)"
    # Added by OrbStack: command-line tools and integration
    source ~/.orbstack/shell/init.zsh 2>/dev/null || :
fi

