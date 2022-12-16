#!/usr/bin/env zsh

# Get the path of the script, usually: ~/.dotfiles/02-ohmyzsh.sh
pushd $(dirname $0) > /dev/null
SOURCE=$(pwd -P)
popd > /dev/null
cd $SOURCE;

ZSH_HOME="${HOME}/.oh-my-zsh"
OHMYZSH_REPO_URL="https://github.com/robbyrussell/oh-my-zsh.git"
FILES_TO_BE_LINKED=(
    "custom/themes/agnoster-iharosi.zsh-theme"
    "custom/themes/agnoster-iharosi-alt.zsh-theme"
    "custom/functions.zsh"
)
DOTFILES_TO_BE_LINKED=(
    ".zshenv"
    ".zshrc"
)

function checkFiles() {
    # Checking source files
    echo -n "1/3 Checking source files... "
    for file in $FILES_TO_BE_LINKED; do
        if [ ! -f "$SOURCE/$file" ]; then
            echo "✗"
            echo "The following file does not exist:"
            echo "$SOURCE/$file"
            exit 1
        fi
    done
    for file in $DOTFILES_TO_BE_LINKED; do
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
    # More about installing Oh-my-zsh: http://install.ohmyz.sh
    echo -n "2/3 Installing Oh My ZSH... "

    # Clone the oh-my-zsh git repo
    hash git >/dev/null \
    && /usr/bin/env git clone --quiet --depth 1 "${OHMYZSH_REPO_URL}" "${ZSH_HOME}" \
    || {
        echo "✗"
        echo "Git not installed"
        exit 1
    }
    echo "✔"
}

function createSymlinks() {
    # Create symlinks

    echo -n "3/3 Linking custom files... "

    for file in $FILES_TO_BE_LINKED; do
        ln -sfF \
            "${SOURCE}/${file}" \
            "${ZSH_HOME}/${file}" \
            || {
                echo "✗"
                echo "Linking failed at $file"
                exit 1
            }
    done
    for file in $DOTFILES_TO_BE_LINKED; do
        ln -sfF \
            "${SOURCE}/${file}" \
            "${HOME}/${file}" \
            || {
                echo "✗"
                echo "Linking failed at $file"
                exit 1
            }
    done
    echo "✔"
}

# Install Oh My Zsh, if not installed already
if [[ ! -d $ZSH && ! -d $ZSH_HOME ]];
then
    echo "Preparing Oh My ZSH install..."
    checkFiles
    installOhMyZsh
    createSymlinks
    source "${HOME}/.zshenv"
    source "${HOME}/.zshrc"
else
    echo "Oh My ZSH already installed, quitting..."
fi

# Unset variables
unset SOURCE
unset ZSH_HOME
unset OHMYZSH_REPO_URL
unset FILES_TO_BE_LINKED
unset checkFiles
unset installOhMyZsh
unset createSymlinks
unset changeToZsh
