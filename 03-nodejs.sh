#!/usr/bin/env zsh

# Install latest LTS version
fnm install 22

# Set latest LTS as default
fnm default 22

# Use latest LTS
fnm use 22

# Install global packages
npm i -g diff-so-fancy tldr
