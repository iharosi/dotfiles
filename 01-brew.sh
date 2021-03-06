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
# f1viewer: https://github.com/SoMuchForSubtlety/f1viewer
brew tap somuchforsubtlety/tap
# Fast Node Manager: https://github.com/Schniz/fnm
brew tap Schniz/tap
# Install nerd fonts: https://github.com/ryanoasis/nerd-fonts
brew tap homebrew/cask-fonts
# rmtree for uninstalling brew package with dependencies: https://github.com/beeftornado/homebrew-rmtree
brew tap beeftornado/rmtree

function installcask() {
    if brew info --cask "${@}" | grep "Not installed" > /dev/null; then
        brew info --cask "${@}"
    else
        echo "${@} is already installed."
    fi
}

# Install apps
installcask charles
installcask docker
installcask figma
installcask firefox
installcask font-hack-nerd-font
installcask google-chrome
installcask go2shell
installcask imagealpha
installcask imageoptim
installcask iterm2
installcask kap
installcask keepingyouawake
installcask macdown
installcask microsoft-teams
installcask postman
installcask sketch
installcask slack
installcask sublime-merge
installcask sublime-text
installcask suspicious-package
installcask xquartz
installcask vlc

# Install tools
brew install \
  cksfv \
  coreutils \
  f1viewer \
  fnm \
  gnupg \
  ios-deploy \
  mas \
  mkvtoolnix \
  mplayer \
  nmap \
  rclone \
  rename \
  ssh-copy-id \
  speedtest_cli \
  telnet \
  testdisk \
  the_silver_searcher \
  trash \
  tree \
  wakeonlan \
  wget \
  youtube-dl

# Remove outdated versions from the cellar.
brew cleanup
