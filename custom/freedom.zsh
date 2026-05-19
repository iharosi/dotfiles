# Freedom sets your router's gateway to the default gateway.

fd() {

  # Standard colors
  RED=$'\e[31m'
  GREEN=$'\e[32m'
  YELLOW=$'\e[33m'
  MAGENTA=$'\e[35m'
  CYAN=$'\e[36m'
  WHITE=$'\e[37m'

  # Reset
  RESET=$'\e[0m'

  typeset -A routes
  typeset -A choices
  typeset -A hwports
  typeset -A unique_gws

  utun_iface=""
  utun_gw=""
  selected_gw=""

  map_hardware_ports() {
    local current_port device line

    while read -r line; do
      if [[ $line == "Hardware Port:"* ]]; then
        current_port="${line#Hardware Port: }"
      elif [[ $line == "Device:"* ]]; then
        device="${line#Device: }"
        hwports[$device]="$current_port"
      fi
    done < <(networksetup -listallhardwareports)
  }

  collect_routes() {
    while read -r gw iface; do
      routes[$iface]=$gw

      if [[ $iface == utun* && -z $utun_iface ]]; then
        utun_iface="$iface"
        utun_gw="$gw"
      fi
    done < <(netstat -rn -f inet | awk '/^default/ {print $2, $NF}')
  }

  detect_vpn() {
    if [[ -z $utun_iface ]]; then
      echo "$RED✘$RESET No active tunnel interface detected as default gateway."
      return 1
    fi

    echo
    echo "Detected active tunnel interface:"
    echo "  ${WHITE}User Tunnel Network$RESET ($MAGENTA$utun_iface$RESET)"
    echo
  }

  build_gateway_choices() {
    local idx=1

    echo "Available IPv4 default routes (Wi-Fi / Ethernet only):"

    for iface gw in ${(kv)routes}; do
      if [[ $iface == en* ]]; then
        local port_name="${hwports[$iface]}"
        [[ -z $port_name ]] && port_name="Unknown"

        echo "  $idx) $CYAN$gw$RESET - $WHITE$port_name$RESET ($MAGENTA$iface$RESET)"
        choices[$idx]="$iface $gw"
        unique_gws[$gw]=1
        ((idx++))
      fi
    done

    if [[ ${#choices[@]} -eq 0 ]]; then
      echo "$RED✘$RESET No Ethernet or Wi-Fi default routes available."
      return 1
    fi
  }

  select_gateway() {
    # Auto select if only one
    if [[ ${#choices[@]} -eq 1 || ${#unique_gws[@]} -eq 1 ]]; then
      for iface info in ${(kv)choices}; do
        selected_gw=${info##* }
        break
      done

      echo
      echo "Auto selected gateway:"
      echo "  $CYAN$selected_gw $GREEN✔︎$RESET"
      echo
      return
    fi

    echo
    read "choice?Select default gateway [1]: "
    [[ -z $choice ]] && choice=1

    local sel=${choices[$choice]}
    if [[ -z $sel ]]; then
      echo "$RED✘$RESET Invalid selection."
      return 1
    fi

    selected_gw=${sel##* }
  }

  apply_routes() {
    echo "$YELLOW⚙︎$RESET Changing default gateway to $CYAN$selected_gw$RESET..."

    sudo route -n change default "$selected_gw" || return 1

    echo "$YELLOW⚙︎$RESET Re-routing intranet traffic..."

    sudo route -n add -net 10.35.0.0/24 -interface "$utun_iface" || return 1

    sudo route -n add -net 192.168.109.0/24 -interface "$utun_iface" || return 1

    echo
    echo "$GREEN✔︎$RESET Done."
  }

  map_hardware_ports
  collect_routes
  detect_vpn || return 1
  build_gateway_choices || return 1
  select_gateway || return 1

  sudo -v || return 1

  apply_routes
}