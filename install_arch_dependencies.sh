#!/usr/bin/env bash

# Template taken from https://betterdev.blog/minimal-safe-bash-script-template/

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat << EOF # remove the space between << and EOF, this is due to web plugin issue
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] -p param_value arg1 [arg2...]

Script that installs Paul Brittain's Arch Linux dependencies and tools

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  # default values of variables set from params
  flag=0
  param=''

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -f | --flag) flag=1 ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  return 0
}

parse_params "$@"
setup_colors

msg "${BLUE}[*] Updating Arch repositories...${NOFORMAT}"
sudo pacman -Sy

msg "${BLUE}[*] Installing base packages via pacman...${NOFORMAT}"
base_packages=(
  base-devel
  zsh
  fzf
  bat
  direnv
  kubectl
  zsh-syntax-highlighting
  git
  python
  alacritty
)

for pkg in "${base_packages[@]}"; do
  if ! pacman -Qi "$pkg" &>/dev/null; then
    sudo pacman -S --noconfirm "$pkg"
  else
    msg "${YELLOW}[!] Skipping: $pkg already installed${NOFORMAT}"
  fi
done

msg "${BLUE}[*] Cloning and building Neovim...${NOFORMAT}"
if ! command -v nvim &>/dev/null && [ ! -d "$HOME/git/neovim/.git" ]; then
  msg "${BLUE}[*] Cloning and building Neovim...${NOFORMAT}"
  git clone https://github.com/neovim/neovim.git "$HOME/git/neovim"
  cd "$HOME/git/neovim"
  make CMAKE_BUILD_TYPE=RelWithDebInfo
  sudo make install
  cd "$HOME"
else
  msg "${YELLOW}[!] Skipping: Neovim already cloned and built${NOFORMAT}"
fi

msg "${BLUE}[*] Installing AUR packages via yay...${NOFORMAT}"
aur_packages=(
  zsh-theme-powerlevel10k
  pyenv
  nvm
  kubectx
  kubens
  nerd-fonts
)

for pkg in "${aur_packages[@]}"; do
  if ! pacman -Qi "$pkg" &>/dev/null; then
    yay -S --noconfirm "$pkg"
  else
    msg "${YELLOW}[!] Skipping: $pkg already installed${NOFORMAT}"
  fi
done

msg "${BLUE}[*] Installing Zsh Tools...${NOFORMAT}"
declare -A repos=(
  ["~/.zsh/zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
  ["~/.zsh/zsh-completions"]="https://github.com/zsh-users/zsh-completions"
  ["~/powerlevel10k"]="https://github.com/romkatv/powerlevel10k.git"
  ["~/.zsh/zsh-defer"]="https://github.com/romkatv/zsh-defer"
)

for dir in "${!repos[@]}"; do
  eval dir_expanded="$dir"
  if [ ! -d "$dir_expanded/.git" ]; then
    git clone --depth 1 "${repos[$dir]}" "$dir_expanded"
  else
    msg "${YELLOW}[!] Skipping: $dir already exists${NOFORMAT}"
  fi
done

msg "${BLUE}[*] Setting Zsh as default shell...${NOFORMAT}"
current_shell=$(getent passwd "$USER" | cut -d: -f7)
zsh_path=$(command -v zsh)

if [ "$current_shell" != "$zsh_path" ]; then
  msg "${BLUE}[*] Setting Zsh as default shell...${NOFORMAT}"
  chsh -s "$zsh_path"
else
  msg "${YELLOW}[!] Skipping: Zsh already set as default shell${NOFORMAT}"
fi

msg "${BLUE}[*] All dependencies and tools installed. Manual steps:${NOFORMAT}"

msg "${BLUE}[*]  - Set your terminal font to a Nerd Font (e.g., FiraCode Nerd Font).${NOFORMAT}"
msg "${BLUE}[*]  - Run 'p10k configure' in Zsh if Powerlevel10k isn't set up yet.${NOFORMAT}"
msg "${BLUE}[*]  - Start Neovim and run Mason and Lazy to install plugins and LSPs.${NOFORMAT}"

