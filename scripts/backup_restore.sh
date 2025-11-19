#!/bin/bash

# Backup and Restore Script for Pi-hole
# Handles backup and restore of Pi-hole configuration

BACKUP_DIR="/var/backups/pihole"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

# Function to create backup
backup() {
    echo "Creating Pi-hole backup..."
    mkdir -p "$BACKUP_DIR"
    tar -czf "$BACKUP_DIR/pihole_backup_$TIMESTAMP.tar.gz" /etc/pihole /etc/dnsmasq.d /var/log/pihole* 2>/dev/null
    echo "Backup created: $BACKUP_DIR/pihole_backup_$TIMESTAMP.tar.gz"
}

# Function to restore from backup
restore() {
    local backup_file=$1
    if [[ ! -f "$backup_file" ]]; then
        echo "Backup file not found: $backup_file"
        exit 1
    fi
    echo "Restoring from backup: $backup_file"
    systemctl stop pihole-FTL
    tar -xzf "$backup_file" -C /
    systemctl start pihole-FTL
    pihole -g
    echo "Restore completed"
}

# Main logic
case "$1" in
    backup)
        backup
        ;;
    restore)
        if [[ $# -ne 2 ]]; then
            echo "Usage: $0 restore <backup_file>"
            exit 1
        fi
        restore "$2"
        ;;
    *)
        echo "Usage: $0 {backup|restore <backup_file>}"
        exit 1
        ;;
esac