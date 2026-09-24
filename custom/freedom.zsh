# Freedom: split tunnel for a full-tunnel VPN (tested with GlobalProtect).
#
#   - Internet traffic goes through the local router instead of the VPN.
#   - Only FD_ROUTES (and the VPN's DNS servers) stay in the tunnel.
#   - DNS goes to the LAN's resolver (e.g. Pi-hole); only FD_DOMAINS go to the VPN's DNS.
#
# Everything is discovered at run time. Company-specific settings live outside
# this repo in ~/.config/freedom/config (see freedom.conf.example).
# Run `fd` after every VPN connect; run it without a VPN to clean up leftovers.
# `fd -f` re-applies everything and lets you pick the router again.
# While split, a background keep-alive sends one DNS query through the tunnel every
# FD_KEEPALIVE seconds, so the VPN's idle timeout doesn't disconnect it.

typeset -g FD_CONFIG=${XDG_CONFIG_HOME:-$HOME/.config}/freedom/config
typeset -g FD_SPLIT_KEY=State:/Network/Service/fd.split/DNS
typeset -g FD_KEEPALIVE_PID=${TMPDIR:-/tmp}/fd-keepalive.pid

_fd_sc_show()  { print "show $1" | scutil }
_fd_sc_val()   { _fd_sc_show $1 | awk -v f="$2" '$1 == f {print $3; exit}' }
_fd_sc_array() { _fd_sc_show $1 | awk -v f="$2" '$1 == f {a = 1; next} a && /}/ {exit} a {print $3}' }

# "<service key> <interface>" for every IPv4 network service
_fd_services() {
  local key
  for key in $(print 'list State:/Network/Service/[^/]+/IPv4' | scutil | awk '{print $4}'); do
    print ${key%/IPv4} $(_fd_sc_val $key InterfaceName)
  done
}

# "<device>\t<hardware port>" in macOS service order (preferred first)
_fd_service_order() {
  networksetup -listnetworkserviceorder |
    sed -n 's/^(Hardware Port: \(.*\), Device: \(.*\))$/\2\t\1/p'
}

# Add a route, or change it if it already exists. Prints the error on failure.
_fd_route() {
  sudo route -qn add "$@" >/dev/null 2>&1 && return
  local err
  err=$(sudo route -qn change "$@" 2>&1 >/dev/null) || { print -r -- "$err"; return 1 }
}

# Aligned "label  value" rows; extra values go on their own lines under the first
_fd_row() {
  local label=$1 v; shift
  for v; do
    printf "  %s%-9s%s %s\n" "$DIM" "$label" "$RESET" "$v"
    label=
  done
}

# Plain-language message: headline (may be empty), then bullet lines.
# A last argument starting with "Details:" is shown dimmed.
_fd_say() {
  local icon=$1 headline=$2 line; shift 2
  echo
  [[ -n $headline ]] && echo "  ${icon:+$icon }$headline"
  for line; do
    [[ $line == Details:* ]] && line="$DIM$line$RESET"
    print -r -- "$line" | fold -s -w 76 | {
      read -r line && echo "    • $line"
      while read -r line; do echo "      $line"; done
    }
  done
  echo
}

_fd_fail() { _fd_say "$RED✘$RESET" "$@"; return 1 }

_fd_sudo() {
  sudo -v 2>/dev/null && return
  _fd_fail "Couldn't get administrator rights." \
    "Changing network settings needs an admin account on this Mac." \
    "Check your password, or ask whoever manages this Mac to make you an admin." \
    "Nothing was changed."
}

_fd_flush_dns() {
  sudo dscacheutil -flushcache
  sudo killall -HUP mDNSResponder
}

_fd_keepalive_stop() {
  local pid
  [[ -r $FD_KEEPALIVE_PID ]] && read -r pid < $FD_KEEPALIVE_PID
  [[ -n $pid ]] && ps -p $pid -o command= | grep -q fd-keepalive && kill $pid 2>/dev/null
  rm -f $FD_KEEPALIVE_PID
}

# Background loop: query <dns server> for <name> every FD_KEEPALIVE seconds.
# Stops when <service key> disappears (VPN disconnected) or a newer loop takes over.
_fd_keepalive_start() {
  local key=$1 ns=$2 name=${3:-.}
  _fd_keepalive_stop
  (( FD_KEEPALIVE > 0 )) && [[ -n $ns ]] || return
  zsh -fc '
    trap "" HUP
    while sleep $2; do
      [[ $(<$1) == $$ ]] 2>/dev/null || exit
      [[ $(print "show $3" | scutil) == *"No such key"* ]] && break
      dig +short +time=3 +tries=1 @$4 $5
    done
    rm -f $1
  ' fd-keepalive $FD_KEEPALIVE_PID $FD_KEEPALIVE $key $ns $name </dev/null >/dev/null 2>&1 &!
  print $! > $FD_KEEPALIVE_PID
}

_fd_keepalive_every() {
  (( FD_KEEPALIVE % 60 )) && print "${FD_KEEPALIVE}s" || print "$(( FD_KEEPALIVE / 60 )) min"
}

# Current setup as aligned rows. Uses fd's locals.
_fd_summary() {
  local vpn_gw=$(_fd_sc_val ${svc_of[$vpn_if]}/IPv4 Router)
  echo
  _fd_row "" "$DIM$(printf '%-19s' IP)Interface$RESET"
  _fd_row VPN "$CYAN$(printf '%-19s' ${vpn_gw:-?})$MAGENTA$vpn_if$RESET"
  _fd_row Gateway "$CYAN$(printf '%-19s' $lan_gw)$MAGENTA$lan_if$RESET $DIM($RESET$WHITE$lan_port$RESET$DIM)$RESET"
  echo

  local -a tunneled
  local t
  for t in $FD_ROUTES; do
    tunneled+=( "$CYAN$(printf '%-19s' $t)$MAGENTA$vpn_if$RESET" )
  done
  for t in $vpn_dns; do
    tunneled+=( "$CYAN$(printf '%-19s' $t)$MAGENTA$vpn_if$RESET $DIM(VPN DNS)$RESET" )
  done
  (( ${#FD_ROUTES} )) || tunneled+=( "$YELLOW!$RESET No FD_ROUTES in config" )
  tunneled+=( "$DIM$(printf '%-19s' 'everything else')$RESET$MAGENTA$lan_if$RESET $DIM($RESET$WHITE$lan_port$RESET$DIM)$RESET" )
  _fd_row Routes $tunneled
  echo

  if (( dns_split )); then
    _fd_row "VPN DNS" "$CYAN${(j:, :)vpn_dns}$RESET" "  $WHITE"${^FD_DOMAINS}$RESET
    _fd_row "LAN DNS" "$CYAN${(j:, :)lan_dns}$RESET" "  ${DIM}everything else$RESET"
  elif (( ! ${#FD_DOMAINS} )); then
    _fd_row DNS "$YELLOW!$RESET No FD_DOMAINS in config, all DNS stays on the VPN"
  else
    _fd_row DNS "$RED✘$RESET Could not read DNS servers (LAN: ${lan_dns[*]:-none}, VPN: ${vpn_dns[*]:-none})"
  fi
  echo

  if [[ -r $FD_KEEPALIVE_PID ]]; then
    _fd_row Keepalive "every $(_fd_keepalive_every) $DIM→$RESET $CYAN${vpn_dns[1]}$RESET $DIM(${FD_DOMAINS[1]:-.})$RESET"
  elif (( FD_KEEPALIVE > 0 )); then
    _fd_row Keepalive "$YELLOW!$RESET Not running (no VPN DNS server found)"
  else
    _fd_row Keepalive "${DIM}off (FD_KEEPALIVE=0)$RESET"
  fi
}

_fd_keepalive_note() {
  if [[ -r $FD_KEEPALIVE_PID ]]; then
    print "Every $(_fd_keepalive_every), one tiny company lookup goes through the VPN, so it doesn't disconnect when idle."
  else
    print "Without VPN traffic, the VPN may disconnect when idle (e.g. after 30 minutes)."
  fi
}

_fd_dns_note() {
  if (( dns_split )); then
    print "Company websites are looked up by the company; everything else by your own network, so your ad blocker (e.g. Pi-hole) works again."
  else
    print "All website lookups still go through the company, so your own ad blocker (e.g. Pi-hole) is bypassed."
  fi
}

fd() {
  local RED=$'\e[31m' GREEN=$'\e[32m' YELLOW=$'\e[33m' MAGENTA=$'\e[35m'
  local CYAN=$'\e[36m' WHITE=$'\e[37m' DIM=$'\e[2m' RESET=$'\e[0m'

  local -a FD_DOMAINS FD_ROUTES
  local FD_KEEPALIVE=300
  [[ -r $FD_CONFIG ]] && source $FD_CONFIG

  local key ifc dev gw port choice net ns i err force dns_split already
  local vpn_if lan_if lan_gw lan_port cur_if
  local -A svc_of gw_of
  local -a choices vpn_dns lan_dns split_domains
  [[ $1 == -f ]] && force=1

  # --- Discover ---------------------------------------------------------------

  _fd_services | while read -r key ifc; do svc_of[$ifc]=$key; done

  for ifc in ${(ok)svc_of}; do
    [[ $ifc == utun* ]] && { vpn_if=$ifc; break }
  done

  if [[ -z $vpn_if ]]; then
    _fd_keepalive_stop
    if [[ -z $(_fd_sc_show $FD_SPLIT_KEY | grep ServerAddresses) ]]; then
      _fd_fail "The company VPN isn't connected." \
        "Connect the VPN first, then run ${WHITE}fd$RESET again."
      return
    fi
    _fd_sudo || return
    print "remove $FD_SPLIT_KEY" | sudo scutil && _fd_flush_dns
    _fd_say "$GREEN✔︎$RESET" "Cleaned up after the last VPN session." \
      "The VPN isn't connected, so your Mac is back to its normal settings." \
      "A leftover company DNS setting from last time was removed." \
      "After connecting the VPN again, run ${WHITE}fd$RESET."
    return
  fi

  netstat -rn -f inet | awk '$1 == "default" && $NF ~ /^en/ {print $NF, $2}' |
    while read -r ifc gw; do gw_of[$ifc]=$gw; done

  _fd_service_order | while IFS=$'\t' read -r dev port; do
    [[ -n ${gw_of[$dev]} ]] && choices+=("$dev ${gw_of[$dev]} $port")
  done

  if (( ! ${#choices} )); then
    _fd_fail "No Wi-Fi or Ethernet connection with internet access found." \
      "Check that Wi-Fi or a network cable is connected, then run ${WHITE}fd$RESET again." \
      "Nothing was changed."
    return
  fi

  # Interface of the main (not interface-bound) default route: en* once fd has run
  cur_if=$(netstat -rn -f inet | awk '$1 == "default" && $3 !~ /I/ {print $NF; exit}')

  # --- Select the local router --------------------------------------------------

  local -a gws=( ${(u)${${choices#* }%% *}} )
  if (( ! force )) && (( ${choices[(I)$cur_if *]} )); then
    choice=${choices[(I)$cur_if *]}       # keep the router fd picked last time
  elif (( ${#gws} == 1 )); then
    choice=1
  else
    echo
    echo "Available routers (in macOS service order):"
    for (( i = 1; i <= ${#choices}; i++ )); do
      dev=${choices[i]%% *}; gw=${${choices[i]#* }%% *}; port=${choices[i]#* * }
      echo "  $i) $CYAN$gw$RESET - $WHITE$port$RESET ($MAGENTA$dev$RESET)"
    done
    echo
    read "choice?Select router [1]: "
    [[ -z $choice ]] && choice=1
    if [[ $choice != <-> ]] || (( choice < 1 || choice > ${#choices} )); then
      _fd_fail "\"$choice\" isn't one of the listed numbers." "Nothing was changed."
      return
    fi
  fi

  lan_if=${choices[choice]%% *}
  lan_gw=${${choices[choice]#* }%% *}
  lan_port=${choices[choice]#* * }

  # --- DNS servers on both sides -------------------------------------------------

  lan_dns=( $(_fd_sc_array ${svc_of[$lan_if]}/DNS ServerAddresses) )
  vpn_dns=( $(_fd_sc_array ${svc_of[$vpn_if]}/DNS ServerAddresses) )

  # Already applied: the VPN entry points at the LAN DNS, the real ones are in fd.split
  if [[ -n ${vpn_dns:*lan_dns} ]]; then
    vpn_dns=( $(_fd_sc_array $FD_SPLIT_KEY ServerAddresses) )
    split_domains=( $(_fd_sc_array $FD_SPLIT_KEY SupplementalMatchDomains) )
    dns_split=1
  fi

  # --- Already on? ------------------------------------------------------------------

  already=1
  [[ $cur_if == $lan_if ]] || already=
  for net in $FD_ROUTES; do
    [[ $(route -n get -net $net 2>/dev/null | awk '/interface:/ {print $2}') == $vpn_if ]] || already=
  done
  if (( ${#FD_DOMAINS} )); then
    [[ ${(j: :)${(o)split_domains}} == ${(j: :)${(o)FD_DOMAINS}} ]] || already=
  fi

  if (( already && ! force )); then
    echo
    echo "  $GREEN✔︎$RESET Split tunnel is already on. Nothing was changed."
    _fd_keepalive_start ${svc_of[$vpn_if]}/IPv4 ${vpn_dns[1]} ${FD_DOMAINS[1]}
    _fd_summary
    _fd_say "" "${WHITE}What does it mean for you?$RESET" \
      "Internet traffic goes through your own router ($lan_port), not the VPN." \
      "Company networks stay reachable through the VPN." \
      "$(_fd_dns_note)" \
      "$(_fd_keepalive_note)" \
      "To pick another router or re-apply everything, run ${WHITE}fd -f$RESET."
    return
  fi

  # --- Apply ------------------------------------------------------------------------

  _fd_sudo || return

  if ! err=$(sudo route -qn change default $lan_gw 2>&1 >/dev/null); then
    _fd_fail "Couldn't send internet traffic through your router ($lan_port)." \
      "Nothing was changed: all traffic still goes through the VPN, as before." \
      "Try again. If it keeps failing, reconnect the VPN and run ${WHITE}fd$RESET." \
      "Details: route change default $lan_gw: ${err:-unknown error}"
    return
  fi

  for net in $FD_ROUTES; do
    err=$(_fd_route -net $net -interface $vpn_if) && continue
    _fd_fail "Couldn't keep company network $net on the VPN." \
      "Internet already goes through your router, but that company network may be unreachable." \
      "Disconnect and reconnect the VPN to undo everything, then run ${WHITE}fd$RESET again." \
      "Details: route add -net $net: $err"
    return
  done
  for ns in $vpn_dns; do
    err=$(_fd_route -host $ns -interface $vpn_if) && continue
    _fd_fail "Couldn't keep the company DNS server $ns on the VPN." \
      "Company websites may not load." \
      "Disconnect and reconnect the VPN to undo everything, then run ${WHITE}fd$RESET again." \
      "Details: route add -host $ns: $err"
    return
  done

  dns_split=
  if (( ${#FD_DOMAINS} && ${#lan_dns} && ${#vpn_dns} )); then
    err=$(sudo scutil 2>&1 <<EOF
d.init
d.add ServerAddresses * ${vpn_dns[*]}
d.add SupplementalMatchDomains * ${FD_DOMAINS[*]}
set $FD_SPLIT_KEY
get ${svc_of[$vpn_if]}/DNS
d.add ServerAddresses * ${lan_dns[*]}
set ${svc_of[$vpn_if]}/DNS
EOF
)
    if [[ -n $err ]]; then
      _fd_fail "Couldn't change the DNS settings." \
        "Internet and company networks work, but your ad blocker is still bypassed." \
        "Disconnect and reconnect the VPN to undo everything, then run ${WHITE}fd$RESET again." \
        "Details: scutil: $err"
      return
    fi
    _fd_flush_dns
    dns_split=1
  fi

  echo
  echo "  $GREEN✔︎$RESET Split tunnel is on."
  _fd_keepalive_start ${svc_of[$vpn_if]}/IPv4 ${vpn_dns[1]} ${FD_DOMAINS[1]}
  _fd_summary
  _fd_say "" "${WHITE}What does it mean for you?$RESET" \
    "Internet traffic now goes through your own router ($lan_port), not the VPN." \
    "Company networks stay reachable through the VPN." \
    "$(_fd_dns_note)" \
    "$(_fd_keepalive_note)" \
    "Reconnected the VPN or woke from sleep? Run ${WHITE}fd$RESET again."
}
