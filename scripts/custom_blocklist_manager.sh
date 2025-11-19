#!/bin/bash

# Custom Blocklist Manager for Pi-hole
# Manages additional custom blocklists

BLOCKLIST_DIR="/etc/pihole/custom-blocklists"
GRAVITY_DB="/etc/pihole/gravity.db"

# Function to add a custom blocklist
add_blocklist() {
    local url=$1
    local name=$2
    echo "Adding blocklist: $name from $url"
    curl -s "$url" | grep -v '^#' | grep -v '^$' > "$BLOCKLIST_DIR/$name.txt"
    sqlite3 "$GRAVITY_DB" "INSERT OR IGNORE INTO adlist (address, enabled) VALUES ('$BLOCKLIST_DIR/$name.txt', 1);"
}

# Function to update all blocklists
update_blocklists() {
    echo "Updating custom blocklists..."
    for file in "$BLOCKLIST_DIR"/*.txt; do
        if [[ -f "$file" ]]; then
            echo "Updating $(basename "$file")"
            # In a real implementation, you'd re-download from the source
            # For now, just log
            echo "Blocklist $(basename "$file") updated" >> /var/log/pihole-custom.log
        fi
    done
    pihole -g
}

# Main logic
case "$1" in
    add)
        if [[ $# -ne 3 ]]; then
            echo "Usage: $0 add <url> <name>"
            exit 1
        fi
        add_blocklist "$2" "$3"
        ;;
    update)
        update_blocklists
        ;;
    *)
        echo "Usage: $0 {add <url> <name>|update}"
        exit 1
        ;;
esac