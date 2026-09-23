#!/usr/bin/env zsh

# Install latest LTS version
fnm install 24

# Set latest LTS as default
fnm default 24

# Use latest LTS
fnm use 24

# Install global packages
npm i -g diff-so-fancy tldr
