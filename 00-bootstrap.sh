#!/usr/bin/env zsh

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until scripts have finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Get the path of the script, usually: ~/.dotfiles/bootstrap.zsh
pushd $(dirname $0) > /dev/null
SOURCE_DIR=$(pwd -P)
popd > /dev/null
cd $SOURCE_DIR;

function update() {
    echo -n "1/3 Updating dotfiles... "

    # Get the latest version of the repository
    git pull --quiet origin master

    if [[ ! $? -eq 0 ]]; then echo "✗"; else echo "✔"; fi
}

function createSymlinks() {
    local FILES_TO_BE_LINKED=(
        ".curlrc"
        ".editorconfig"
        ".gitconfig"
        ".gitignore"
        ".vimrc"
        ".wgetrc"
        ".zshenv"
        ".zshrc"
    )
    local DIR_TO_BE_LINKED=(
        "Library/Application Support/Sublime Text/Packages/User"
    )

    echo -n "2/3 Checking source files... "
    for file in $FILES_TO_BE_LINKED; do
        if [ ! -f "$SOURCE_DIR/$file" ]; then
            echo "✗"
            echo "The following file does not exist:"
            echo "$SOURCE_DIR/$file"
            exit 1
        fi
    done
    echo "✔"

    echo -n "3/3 Linking configuration files... "
    for file in $FILES_TO_BE_LINKED; do
        ln -sfF \
            "${SOURCE_DIR}/${file}" \
            "${HOME}/${file}" \
            || {
                echo "✗"
                echo "Linking failed at $file"
                exit 1
            }
    done
    for dir in $DIR_TO_BE_LINKED; do
        mkdir -p "$(dirname "${HOME}/${dir}")"
        ln -sfF \
            "${SOURCE_DIR}/${dir}" \
            "${HOME}/${dir}" \
            || {
                echo "✗"
                echo "Linking failed at $file"
                exit 1
            }
    done
    echo "✔"
}

function doIt() {
    update
    createSymlinks
    echo "Picking up environment variables..."
    source "$HOME/.zshenv"
    echo "Running install scripts... "
    source "$SOURCE_DIR/01-ohmyzsh.sh"
    source "$SOURCE_DIR/02-brew.sh"
    source "$SOURCE_DIR/03-nodejs.sh"
    source "$SOURCE_DIR/04-macos.sh"
}

# Show a warning message, before the installation
if [[ "$1" == "--force" || "$1" == "-f" ]]; then
    doIt
else
    echo -n "This may overwrite existing files in your home directory." \
        "Are you sure? (y/N) "

    read -q
    local answer=$?

    echo

    if [[ ${answer} -eq 0 ]]; then
        doIt
    fi
fi

unset SOURCE_DIR
