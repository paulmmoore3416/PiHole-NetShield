#!/bin/bash

# IoT Device Isolation Script for Pi-hole
# Isolates IoT devices for security

IOT_SUBNET="192.168.10.0/24"
IOT_INTERFACE="eth0"

# Function to add IoT isolation rules
isolate_iot() {
    echo "Isolating IoT subnet: $IOT_SUBNET"
    # Block IoT devices from accessing other subnets
    iptables -I FORWARD -s "$IOT_SUBNET" -d "192.168.1.0/24" -j DROP
    iptables -I FORWARD -s "192.168.1.0/24" -d "$IOT_SUBNET" -j DROP
    # Allow DNS and DHCP
    iptables -I FORWARD -s "$IOT_SUBNET" -d "192.168.1.1" -p udp --dport 53 -j ACCEPT
    iptables -I FORWARD -s "$IOT_SUBNET" -d "192.168.1.1" -p udp --dport 67 -j ACCEPT
    echo "IoT isolation rules applied"
}

# Function to remove IoT isolation
deisolate_iot() {
    echo "Removing IoT isolation"
    iptables -D FORWARD -s "$IOT_SUBNET" -d "192.168.1.0/24" -j DROP 2>/dev/null
    iptables -D FORWARD -s "192.168.1.0/24" -d "$IOT_SUBNET" -j DROP 2>/dev/null
    iptables -D FORWARD -s "$IOT_SUBNET" -d "192.168.1.1" -p udp --dport 53 -j ACCEPT 2>/dev/null
    iptables -D FORWARD -s "$IOT_SUBNET" -d "192.168.1.1" -p udp --dport 67 -j ACCEPT 2>/dev/null
    echo "IoT isolation rules removed"
}

# Main logic
case "$1" in
    isolate)
        isolate_iot
        ;;
    deisolate)
        deisolate_iot
        ;;
    *)
        echo "Usage: $0 {isolate|deisolate}"
        exit 1
        ;;
esac