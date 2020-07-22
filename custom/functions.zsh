# Generate a random password
# @param integer $1 = 64 number of characters
# @param integer $2 = 0 exclude special characters
function randpass() {
    local chars="[:alnum:]"
    if [[ "$2" != 0 ]]; then
        chars+="+-\E*@#%=?!_;./"
    fi

    cat /dev/urandom | LC_ALL=C tr -dc "${chars}" | head -c ${1:-64} | awk '{print $1}'
}

# fast backup of a file or directory with timestamp
function buf() {
  for name in ${@%/}; do
      cp -R $name{,$(date +.%Y.%m.%d.%H.%M.%S)}
  done
}

# Convert latin1 srt files to utf8 and replaces accents accordingly
function toutf8() {
    for var in "$@"
    do
        echo "> $var"
        iconv -f WINDOWS-1252 -t UTF-8 $var > $var.utf8
        sed -i '' -e 's/
$//g' -e 's/õ/ő/g' -e 's/Õ/Ő/g' -e 's/Û/Ű/g' -e 's/û/ű/g' $var.utf8
        mv $var $var.backup.srt
        mv $var.utf8 $var
    done
}

# Determine size of a file or total size of a directory
function fs() {
  if du -b /dev/null > /dev/null 2>&1; then
    local arg=-sbh;
  else
    local arg=-sh;
  fi
  if [[ -n "$@" ]]; then
    du $arg -- "$@";
  else
    du $arg .[^.]* ./*;
  fi;
}

# Create a data URL from a file
function dataurl() {
  local mimeType=$(file -b --mime-type "$1");
  if [[ $mimeType == text/* ]]; then
    mimeType="${mimeType};charset=utf-8";
  fi
  echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')";
}

# Start an HTTP server from a directory, optionally specifying the port
function server() {
  local port="${1:-8000}";
  sleep 1 && open "http://localhost:${port}/" &
  # Set the default Content-Type to `text/plain` instead of `application/octet-stream`
  # And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
  python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port";
}

# `tre` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
function tre() {
  tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX;
}
