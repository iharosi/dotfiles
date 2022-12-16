#!/usr/bin/env zsh

# Install latest LTS version
fnm install 16

# Set latest LTS as default
fnm default 16

# Use latest LTS
fnm use 16

# Install global packages
npm i -g diff-so-fancy eslint full-icu prettier tldr
