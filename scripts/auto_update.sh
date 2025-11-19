#!/bin/bash

# Auto Update Script for Pi-hole and System
# Updates Pi-hole and system packages

LOG_FILE="/var/log/pihole-updates.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "$TIMESTAMP - Starting system and Pi-hole update" >> "$LOG_FILE"

# Update system packages
apt update >> "$LOG_FILE" 2>&1
apt upgrade -y >> "$LOG_FILE" 2>&1
apt autoremove -y >> "$LOG_FILE" 2>&1
apt autoclean >> "$LOG_FILE" 2>&1

# Update Pi-hole
if command -v pihole &> /dev/null; then
    pihole -up >> "$LOG_FILE" 2>&1
fi

# Check if kernel was updated
if [ -f /var/run/reboot-required ]; then
    echo "$TIMESTAMP - Reboot required due to kernel update" >> "$LOG_FILE"
    reboot
else
    echo "$TIMESTAMP - Update completed, no reboot required" >> "$LOG_FILE"
fi