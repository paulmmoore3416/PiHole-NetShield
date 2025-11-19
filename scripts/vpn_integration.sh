#!/bin/bash

# VPN Integration Script for Pi-hole
# Integrates VPN for secure remote access

VPN_CONFIG="/etc/openvpn/client.conf"
VPN_LOG="/var/log/pihole-vpn.log"

# Function to start VPN
start_vpn() {
    if [[ ! -f "$VPN_CONFIG" ]]; then
        echo "VPN config not found: $VPN_CONFIG"
        exit 1
    fi
    echo "Starting VPN..."
    openvpn --config "$VPN_CONFIG" --daemon --log "$VPN_LOG"
    sleep 5
    if pgrep openvpn > /dev/null; then
        echo "VPN started successfully"
    else
        echo "Failed to start VPN"
        exit 1
    fi
}

# Function to stop VPN
stop_vpn() {
    echo "Stopping VPN..."
    pkill openvpn
    echo "VPN stopped"
}

# Function to check VPN status
status_vpn() {
    if pgrep openvpn > /dev/null; then
        echo "VPN is running"
    else
        echo "VPN is not running"
    fi
}

# Main logic
case "$1" in
    start)
        start_vpn
        ;;
    stop)
        stop_vpn
        ;;
    status)
        status_vpn
        ;;
    *)
        echo "Usage: $0 {start|stop|status}"
        exit 1
        ;;
esac