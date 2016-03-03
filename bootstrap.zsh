#!/usr/bin/env zsh

# Get the path of the script, usually: ~/.dotfiles/bootstrap.zsh
pushd $(dirname $0) >/dev/null
script_path=$(pwd -P)
popd >/dev/null

# Oh My Zsh path
if [ ! -n "${ZSH}" ]; then
    ZSH="${HOME}/.oh-my-zsh"
fi

function installOhMyZsh() {
    # More about installing Oh-my-zsh: http://install.ohmyz.sh
    echo -n "Installing Oh-my-zsh... "

    # Clone the oh-my-zsh git repo
    local oh_my_zsh_repo="https://github.com/robbyrussell/oh-my-zsh.git"
    hash git >/dev/null && /usr/bin/env git clone -q "${oh_my_zsh_repo}" "${ZSH}" || {
        echo "✗"
        echo "Git not installed"
        exit 1
    }
    echo "✔"

    # Change the default shell
    echo "Change your default shell to zsh"
    chsh -s $(which zsh)
}

function doIt() {
    cd "${script_path}"

    echo -n "Updating dotfiles... "

    # Get the latest version of the repository
    git pull -q origin master

    if [[ ! $? -eq 0 ]]; then echo "✗"
    else echo "✔"
    fi

    # Install Oh My Zsh, if not installed already
    if [ ! -d "${ZSH}" ]; then
        installOhMyZsh
    fi

    # Copy all files to the home directory
    echo -n "Syncing files... "

    rsync --exclude ".git/" --exclude ".DS_Store" --exclude "bootstrap.zsh" \
        --exclude "README.md" -avq --no-perms . ${HOME}

    if [[ ! $? -eq 0 ]]; then echo "✗"
    else echo "✔"
    fi

    # Start zsh with the new settings
    /usr/bin/env zsh
    source ~/.zshrc

    # set zsh to default shell
    chsh -s /bin/zsh
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
unset script_path
