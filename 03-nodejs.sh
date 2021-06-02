#!/usr/bin/env zsh

# Install latest LTS version
fnm i 14

# Set latest LTS as default
fnm default 14

# Use latest LTS
fnm use 14

# Install global packages
npm i -g diff-so-fancy eslint full-icu nodemon prettier tldr
