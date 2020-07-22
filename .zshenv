export ZSH_DISABLE_COMPFIX=true
export EDITOR=vim

# Prefer US English and use UTF-8
export LANG="en_US"
export LC_ALL="en_US.UTF-8"

# Path
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin"
# export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
# export PATH="$PATH:/usr/local/opt/node@12/bin"
# export PATH="$PATH:/Applications/microchip/xc8/v1.45/bin"
export PATH="$PATH:${HOME}/.bin"

# Java JRE
# export JAVA_HOME="/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home"
# export JAVA_HOME="${HOME}/Applications/Java/jdk1.8.0_181.jdk/Contents/Home"
# export PATH="$PATH:$JAVA_HOME/bin"

# export HOMEBREW_GITHUB_API_TOKEN=""
export HOMEBREW_CASK_OPTS="--appdir=${HOME}/Applications/Cask"

export GREP_OPTIONS="--color=auto"
export LESS_TERMCAP_md="$ORANGE"

# Avoid issues with `gpg` as installed via Homebrew.
# https://stackoverflow.com/a/42265848/96656
export GPG_TTY=$(tty)
