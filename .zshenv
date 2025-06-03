export ZSH_DISABLE_COMPFIX=true
export EDITOR=vim
export BREW="/opt/homebrew"

# Prefer US English and use UTF-8
export LANG="en_US"
export LC_ALL="en_US.UTF-8"

# Path
#export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin"
# export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
export PATH="$HOME/.bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$BREW/bin:$PATH"
export PATH="$BREW/sbin:$PATH"
#export PATH="$BREW/anaconda3/bin:$PATH"
#export PATH="$HOME/.cargo/bin:$PATH"
#export PATH="$HOME/.pyenv/shims:$PATH"
#export PATH="$HOME/Library/Python/3.9/bin:$PATH"
export PATH="$BREW/opt/pnpm@8/bin:$PATH"
# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.cache/lm-studio/bin"
# Added by Windsurf
export PATH="$HOME/.codeium/windsurf/bin:$PATH"

# Fast Node Manager
export PATH="$HOME/.fnm/current/bin:$PATH"
export FNM_MULTISHELL_PATH="$HOME/.fnm/current"
export FNM_DIR="$HOME/.fnm/"
export FNM_NODE_DIST_MIRROR=https://nodejs.org/dist
export FNM_LOGLEVEL=info

# For compilers to find ffmpeg@5 you may need to set:
#export LDFLAGS="-L$BREW/opt/ffmpeg@5/lib"
#export CPPFLAGS="-I$BREW/opt/ffmpeg@5/include"
#export PKG_CONFIG_PATH="$BREW/Cellar/ffmpeg@5/5.1.3/lib/pkgconfig/"

# Java
#export JAVA_HOME="/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home"
export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"
#export JAVA_HOME="$HOME/Applications/Java/jdk1.8.0_181.jdk/Contents/Home"
#export PATH="$PATH:$JAVA_HOME/bin"
#export PATH="$BREW/opt/openjdk/bin:$PATH"
#export PATH="$BREW/opt/openjdk@17/bin:$PATH"

# Android
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

# export HOMEBREW_GITHUB_API_TOKEN=""
export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications/Cask"

export GREP_OPTIONS="--color=auto"
export LESS_TERMCAP_md="$ORANGE"

# Avoid issues with `gpg` as installed via Homebrew.
# https://stackoverflow.com/a/42265848/96656
export GPG_TTY=$(tty)

# Jest timezone preset
#export TZ="UTC"

# Fix ERR_OSSL_EVP_UNSUPPORTED
#export NODE_OPTIONS="--openssl-legacy-provider"

# Ollama
export OLLAMA_HOST="0.0.0.0:11434"

# Go
export GOPATH="$HOME/.go"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOBIN"
