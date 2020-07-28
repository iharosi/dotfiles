#!/usr/bin/env zsh

# Install latest LTS version
fnm i 12

# Set latest LTS as default
fnm default 12

# Use latest LTS
fnm use 12

# Install global packages
npm i -g diff-so-fancy eslint full-icu homebridge nodemon npm prettier tldr
