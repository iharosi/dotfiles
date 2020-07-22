#!/usr/bin/env zsh

# Install latest LTS version
fnm i 12

# Use just installed version
fnm use 12

# Install global packages
npm i -g diff-so-fancy eslint full-icu homebridge nodemon npm prettier tldr
