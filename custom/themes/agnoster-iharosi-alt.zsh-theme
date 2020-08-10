# vim:ft=zsh ts=2 sw=2 sts=2
#
# Based on agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for ZSH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://gist.github.com/1595572).
#
# In addition, I recommend the
# [Cobalt2 theme](https://github.com/altercation/solarized/),
# Monaco for Powerline font and, if you're using it on Mac OS X,
# [iTerm 2](http://www.iterm2.com/) over Terminal.app -
# it has significantly better color fidelity.
#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'
SEGMENT_SEPARATOR=''

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  local user=`whoami`

  if [[ "$user" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black default "%(!.%{%F{yellow}%}.) $user%m"
  fi
}

# Git: branch/detached head, dirty status
prompt_git() {
  local ref dirty
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    ZSH_THEME_GIT_PROMPT_DIRTY='±'
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git show-ref --head -s --abbrev |head -n1 2> /dev/null)"
    if [[ -n $dirty ]]; then
      prompt_segment yellow black
    else
      prompt_segment green black
    fi
    echo -n " ${ref/refs\/heads\// }$dirty"
  fi
}

# Dir: current working directory
prompt_dir() {
  prompt_segment 24 white ' %~'
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"

  [[ -n "$symbols" ]] && prompt_segment 25 default "$symbols"
}

function online_check() {
  ping -c 1 -W 1 -o 1.0.0.1 2>/dev/null | grep 'received' | awk '{print $4}'
}

function prompt_online() {
  if [[ $(online_check) == 0 ]]; then
    prompt_segment 24 red ""
  else
    prompt_segment 24 white ""
  fi
}

function prompt_battery() {
  local source percent battery ac

  battery="Battery Power"
  ac="AC Power"
  source=$(pmset -g ps | sed -nE "s/.+'(.+)'$/\1/p")
  percent=$(pmset -g ps | sed -nE 's/.*[[:blank:]]+([[:digit:]]+)%.*/\1/p')

  if [[ $source == $ac ]]; then
    if [[ $percent == 100 ]]; then
      prompt_segment 24 white ""
    elif [[ $percent -ge 95 ]]; then
      prompt_segment 24 white ""
    elif [[ $percent -ge 90 ]]; then
      prompt_segment 24 white ""
    elif [[ $percent -ge 80 ]]; then
      prompt_segment 24 white ""
    elif [[ $percent -ge 65 ]]; then
      prompt_segment 24 white ""
    elif [[ $percent -ge 50 ]]; then
      prompt_segment 24 white ""
    elif [[ $percent -ge 40 ]]; then
      prompt_segment 24 white ""
    elif [[ $percent -ge 30 ]]; then
      prompt_segment 24 white ""
    elif [[ $percent -ge 10 ]]; then
      prompt_segment 24 white ""
    elif [[ $percent -ge 0 ]]; then
      prompt_segment 24 red ""
    fi
  elif [[ $source == $battery ]]; then
    if [[ $percent == 100 ]]; then
      prompt_segment 24 white ""
    elif [[ $percent -ge 95 ]]; then
      prompt_segment 24 white ""
    elif [[ $percent -ge 90 ]]; then
      prompt_segment 24 white ""
    elif [[ $percent -ge 80 ]]; then
      prompt_segment 24 white ""
    elif [[ $percent -ge 70 ]]; then
      prompt_segment 24 white ""
    elif [[ $percent -ge 60 ]]; then
      prompt_segment 24 white ""
    elif [[ $percent -ge 50 ]]; then
      prompt_segment 24 white ""
    elif [[ $percent -ge 40 ]]; then
      prompt_segment 24 white ""
    elif [[ $percent -ge 30 ]]; then
      prompt_segment 24 white ""
    elif [[ $percent -ge 20 ]]; then
      prompt_segment 24 white ""
    elif [[ $percent -ge 10 ]]; then
      prompt_segment 24 white ""
    elif [[ $percent -ge 0 ]]; then
      prompt_segment 24 red ""
    fi
  fi
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_online
  prompt_battery
  prompt_context
  prompt_dir
  prompt_git
  prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt)
» '

