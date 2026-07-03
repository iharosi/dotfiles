#!/usr/bin/env zsh
set -e

# Get the path of the script, usually: ~/.dotfiles/02-ohmyzsh.sh
pushd $(dirname $0) > /dev/null
SOURCE=$(pwd -P)
popd > /dev/null
cd "$SOURCE"

ZSH_HOME="${HOME}/.oh-my-zsh"
OHMYZSH_REPO_URL="https://github.com/ohmyzsh/ohmyzsh.git"

FILES_TO_BE_LINKED=(
    "custom/themes/agnoster-alternative.zsh-theme"
    "custom/functions.zsh"
    "custom/freedom.zsh"
)
DOTFILES_TO_BE_LINKED=(
    ".zshenv"
    ".zshrc"
)

function checkFiles() {
    echo -n "1/3 Checking source files... "
    for file in "${FILES_TO_BE_LINKED[@]}" "${DOTFILES_TO_BE_LINKED[@]}"; do
        if [ ! -f "$SOURCE/$file" ]; then
            echo "✗"
            echo "The following file does not exist:"
            echo "$SOURCE/$file"
            exit 1
        fi
    done
    echo "✔"
}

function installOhMyZsh() {
    echo -n "2/3 Installing Oh My ZSH... "
    if ! hash git >/dev/null 2>&1; then
        echo "✗"
        echo "Git not installed"
        exit 1
    fi
    if [ ! -d "$ZSH_HOME" ]; then
        /usr/bin/env git clone --quiet --depth 1 "${OHMYZSH_REPO_URL}" "${ZSH_HOME}" || {
            echo "✗"
            echo "Failed to clone oh-my-zsh"
            exit 1
        }
    fi
    echo "✔"
}

function createSymlinks() {
    echo -n "3/3 Linking custom files... "
    for file in "${FILES_TO_BE_LINKED[@]}"; do
        mkdir -p "$(dirname "${ZSH_HOME}/${file}")"
        ln -sfF "${SOURCE}/${file}" "${ZSH_HOME}/${file}" || {
            echo "✗"
            echo "Linking failed at $file"
            exit 1
        }
    done
    for file in "${DOTFILES_TO_BE_LINKED[@]}"; do
        ln -sfF "${SOURCE}/${file}" "${HOME}/${file}" || {
            echo "✗"
            echo "Linking failed at $file"
            exit 1
        }
    done
    echo "✔"
}

function cloneIfMissing() {
    local url="$1"
    local dest="$2"
    if [ -d "$dest" ]; then
        echo "  - already installed: $(basename "$dest")"
    else
        git clone --quiet --depth 1 "$url" "$dest" || {
            echo "  ✗ failed to clone $(basename "$dest")"
            exit 1
        }
        echo "  ✔ installed $(basename "$dest")"
    fi
}

function installPlugins() {
    echo "Installing plugins..."
    cloneIfMissing "https://github.com/zdharma-continuum/fast-syntax-highlighting.git" "${ZSH_HOME}/custom/plugins/fast-syntax-highlighting"
    cloneIfMissing "https://github.com/zsh-users/zsh-syntax-highlighting.git" "${ZSH_HOME}/custom/plugins/zsh-syntax-highlighting"
    cloneIfMissing "https://github.com/zsh-users/zsh-autosuggestions.git" "${ZSH_HOME}/custom/plugins/zsh-autosuggestions"
}

# Install Oh My Zsh, if not installed already
if [[ ! -d $ZSH && ! -d $ZSH_HOME ]]; then
    echo "Preparing Oh My ZSH install..."
    checkFiles
    installOhMyZsh
    createSymlinks
else
    echo "Oh My ZSH already installed, skipping core install."
fi

# Always safe to run — idempotent
installPlugins

# Unset variables
unset SOURCE ZSH_HOME OHMYZSH_REPO_URL FILES_TO_BE_LINKED DOTFILES_TO_BE_LINKED
unset -f checkFiles installOhMyZsh createSymlinks installPlugins cloneIfMissing
