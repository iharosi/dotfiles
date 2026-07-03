#!/usr/bin/env zsh

# Install command-line tools using Homebrew.
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Turn off brew analytics.
brew analytics off

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Install apps
brew install --cask font-hack-nerd-font \
  imageoptim \
  iterm2 \
  keepingyouawake \
  microsoft-teams \
  microsoft-outlook \
  sublime-text

# Install tools
brew install \
  fnm \
  gnupg \
  speedtest-cli \
  trash \
  tree

# Remove outdated versions from the cellar.
brew cleanup
