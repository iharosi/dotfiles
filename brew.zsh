#!/usr/bin/env zsh

# Install command-line tools using Homebrew.

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade --all

brew install dark-mode
brew install mariadb
brew install nmap
brew install testdisk
brew install the_silver_searcher
brew install trash
brew install tree
brew install rename
brew install speedtest_cli
brew install ssh-copy-id
brew install wakeonlan
brew install wget

# Install NodeJS and global packages
brew install node
npm install -g babel-cli
npm install -g babel-preset-es2015
npm install -g bower
npm install -g cordova
npm install -g csslint
npm install -g diff-so-fancy
npm install -g grunt-cli
npm install -g gulp
npm install -g htmlhint
npm install -g ios-deploy
npm install -g ios-sim
npm install -g jade-lint
npm install -g jshint
npm install -g mocha
npm install -g peerflix
npm install -g peerflix-server
npm install -g tldr
npm install -g yo

# Install native apps
brew tap caskroom/cask
brew install brew-cask

function installcask() {
    if brew cask info "${@}" | grep "Not installed" > /dev/null; then
        brew cask install "${@}"
    else
        echo "${@} is already installed."
    fi
}

# installcask dropbox
# installcask google-chrome
# installcask google-chrome-canary
# installcask tor-browser
# installcask imagealpha
# installcask imageoptim
installcask iterm2
installcask vlc

# Remove outdated versions from the cellar.
brew cleanup
