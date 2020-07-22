#!/usr/bin/env zsh

# Removing global NPM packages
npm uninstall -g diff-so-fancy eslint full-icu homebridge nodemon npm prettier tldr

# Removing brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh)"

# Removing dotfiles
TO_BE_REMOVED=(
    ".curlrc"
    ".editorconfig"
    ".gitconfig"
    ".gitignore"
    ".vimrc"
    ".wgetrc"
    ".zshenv"
    ".zshrc"
    ".oh-my-zsh"
    "Library/Application\ Support/Sublime\ Text\ 3/Packages/User"
)
for item in $TO_BE_REMOVED; do
    echo "Removing ${HOME}/${item}"
    rm -fR "${HOME}/${item}"
done

echo "Uninstall has finished"
