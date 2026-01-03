#!/bin/sh
set -euo pipefail

# --- Helpers ---
err() { echo "ERROR: $*" >&2; }
info() { echo "INFO: $*"; }

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check for wired carrier (returns 0 if at least one wired interface has carrier)
wired_has_carrier() {
  local iface carrier is_wireless
  for iface in /sys/class/net/*; do
    iface=$(basename "$iface")
    # ignore loopback
    [ "$iface" = "lo" ] && continue

    # if the kernel exposes carrier file, check it
    if [ -r "/sys/class/net/$iface/carrier" ]; then
      carrier=$(cat "/sys/class/net/$iface/carrier" 2>/dev/null || echo 0)
      # treat wireless interfaces as wireless; skip them for wired check
      if [ -d "/sys/class/net/$iface/wireless" ]; then
        continue
      fi
      if [ "$carrier" = "1" ]; then
        # an ethernet-like interface with link is present
        return 0
      fi
    fi
  done
  return 1
}

# List iwd devices and return array
list_iwd_devices() {
  iwctl device list | awk 'NR>1 {print $1}' || true
}

# Interactive wifi connect using iwctl
interactive_connect() {
  if ! command_exists iwctl; then
    err "iwctl not found. Install 'iwd' or run on an Arch ISO that has iwd."
    return 2
  fi

  local devs dev chosen ssid pass
  echo
  echo "Available wireless devices (from iwctl):"
  devs=()
  while IFS= read -r d; do
    [ -n "$d" ] && devs+=("$d")
  done < <(list_iwd_devices)

  if [ ${#devs[@]} -eq 0 ]; then
    err "No wireless devices found by iwctl."
    return 3
  fi

  for i in "${!devs[@]}"; do
    printf "  %d) %s\n" "$((i+1))" "${devs[$i]}"
  done

  # choose device
  read -rp "Choose wireless device (number, default 1): " chosen
  chosen=${chosen:-1}
  if ! [[ "$chosen" =~ ^[0-9]+$ ]] || [ "$chosen" -lt 1 ] || [ "$chosen" -gt "${#devs[@]}" ]; then
    err "Invalid selection."
    return 4
  fi
  dev="${devs[$((chosen-1))]}"
  info "Selected device: $dev"

  echo
  info "Scanning for networks (this may take a few seconds)..."
  iwctl station "$dev" scan

  echo
  info "Available networks:"
  iwctl station "$dev" get-networks || true

  echo
  read -rp "Enter SSID to connect to (exact case): " ssid
  [ -z "$ssid" ] && { err "SSID cannot be empty."; return 5; }

  read -rp "Enter passphrase (leave empty if open network): " -s pass
  echo

  info "Attempting to connect..."
  if [ -z "$pass" ]; then
    iwctl station "$dev" connect "$ssid"
  else
    iwctl station "$dev" connect "$ssid" <<<"$pass"
  fi

  echo
  info "Status (iwctl):"
  iwctl station "$dev" show || true
}

# Non-interactive connect using iwctl -- requires SSID and PASS (pass optional)
noninteractive_connect() {
  local ssid="$1"
  local pass="${2:-}"
  if ! command_exists iwctl; then
    err "iwctl not found. Install 'iwd' or run on an Arch ISO that has iwd."
    return 2
  fi

  # pick the first wireless device
  local dev
  dev=$(list_iwd_devices | head -n1)
  if [ -z "$dev" ]; then
    err "No wireless device found."
    return 3
  fi
  info "Using device: $dev"
  info "Scanning..."
  iwctl station "$dev" scan
  info "Attempting to connect to SSID: $ssid"
  if [ -z "$pass" ]; then
    iwctl station "$dev" connect "$ssid"
  else
    # iwctl usually prompts for passphrase; we feed it. If iwctl doesn't accept here, user may need interactive mode.
    iwctl station "$dev" connect "$ssid" <<<"$pass"
  fi

  info "Connection result:"
  iwctl station "$dev" show || true
}

# --- Main ---
main() {
  # parse args
  local SSID="" PASS="" MODE="interactive"
  while [ $# -gt 0 ]; do
    case $1 in
      --ssid) SSID="$2"; shift 2;;
      --pass) PASS="$2"; shift 2;;
      --help|-h) cat <<EOF
auto-wifi-if-no-cable.sh
If no wired cable is detected, connect to Wi-Fi (uses iwctl).

Usage:
  $0                # interactive
  $0 --ssid SSID [--pass PASSWORD]   # non-interactive

EOF
        exit 0;;
      *) err "Unknown option: $1"; exit 1;;
    esac
  done

  if [ -n "$SSID" ]; then
    MODE="noninteractive"
  fi

  info "Checking for wired connection..."
  if wired_has_carrier; then
    info "Wired cable detected. No Wi-Fi selection needed. Exiting."
    return 0
  fi

  info "No wired cable detected. Proceeding to Wi-Fi."
  if [ "$MODE" = "interactive" ]; then
    interactive_connect
  else
    noninteractive_connect "$SSID" "$PASS"
  fi
}

main "$@"
