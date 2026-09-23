export ZSH_DISABLE_COMPFIX=true
export EDITOR=vim
export BREW="/opt/homebrew"

# Prefer US English and use UTF-8
export LANG="en_US"
export LC_ALL="en_US.UTF-8"

# Path
export PATH="$HOME/.bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$BREW/bin:$PATH"
export PATH="$BREW/sbin:$PATH"
export PATH="$BREW/opt/pnpm@8/bin:$PATH"

# Fast Node Manager
export PATH="$HOME/.fnm/current/bin:$PATH"
export FNM_MULTISHELL_PATH="$HOME/.fnm/current"
export FNM_DIR="$HOME/.fnm/"
export FNM_NODE_DIST_MIRROR=https://nodejs.org/dist
export FNM_LOGLEVEL=info

# Java
export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home"

# Android
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Docker
export DOCKER_HOME=$HOME/.docker/bin
export PATH=$PATH:$DOCKER_HOME

# Homebrew
export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications/Cask"

# Go
export GOPATH="$HOME/.go"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOBIN"

# ESP Matter
export ESP_IDF_PATH="$HOME/Sites/other/esp-idf"
export ESP_MATTER_PATH="$HOME/Sites/other/esp-matter"
export IDF_CCACHE_ENABLE=1

# KiCad
export PATH="$HOME/Applications/KiCad/KiCad.app/Contents/MacOS:$PATH"

export GREP_OPTIONS="--color=auto"
export LESS_TERMCAP_md="$ORANGE"

# Avoid issues with `gpg` as installed via Homebrew.
# https://stackoverflow.com/a/42265848/96656
export GPG_TTY=$(tty)

# Jest timezone preset
#export TZ="UTC"

# Fix ERR_OSSL_EVP_UNSUPPORTED
#export NODE_OPTIONS="--openssl-legacy-provider"

# Disable Vite's automatic browser window open behavior
export BROWSER=none
