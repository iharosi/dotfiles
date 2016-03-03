# Generate a random password
# @param integer $1 = 32 number of characters
# @param integer $2 = 1 include special characters
function randpass() {
    local chars="[:alnum:]"
    if [[ "$2" == 1 ]]; then
        chars+="+-\E*@#%=?!_;./"
    fi

    cat /dev/urandom | LC_ALL=C tr -dc "${chars}" | head -c ${1:-32} | awk '{print $1}'
}

# fast backup of a file with timestamp
buf () {
    cp $1{,$(date +.%Y.%m.%d.%H.%M.%S)};
}
