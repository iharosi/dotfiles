#!/usr/bin/env zsh

# Install command-line tools using Homebrew.
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Turn off brew analytics.
brew analytics off

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Add external repositories to homebrew
# Fast Node Manager: https://github.com/Schniz/fnm
brew tap Schniz/tap
# Install nerd fonts: https://github.com/ryanoasis/nerd-fonts
brew tap homebrew/cask-fonts
# rmtree for uninstalling brew package with dependencies: https://github.com/beeftornado/homebrew-rmtree
brew tap beeftornado/rmtree

# Install apps
brew install --cask font-hack-nerd-font \
  imageoptim \
  iterm2 \
  keepingyouawake \
  macdown \
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
