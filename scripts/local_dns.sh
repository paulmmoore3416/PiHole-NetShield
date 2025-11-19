#!/bin/bash

# Manage Pi-hole local DNS records
# Usage: local_dns.sh add <ip> <hostname>
#        local_dns.sh remove <hostname>
#        local_dns.sh list

LOCALLIST='/etc/pihole/local.list'

add(){
    ip="$1"
    host="$2"
    if grep -q "^$ip\s\+$host$" "$LOCALLIST" 2>/dev/null; then
        echo "Already exists"
        exit 0
    fi
    echo "$ip $host" >> "$LOCALLIST"
    # reload pihole FTL
    systemctl restart pihole-FTL
    echo "Added $host -> $ip"
}

remove(){
    host="$1"
    if ! grep -q "\b$host\b" "$LOCALLIST" 2>/dev/null; then
        echo "Not found"
        exit 1
    fi
    sed -i.bak "/\b$host\b/d" "$LOCALLIST"
    systemctl restart pihole-FTL
    echo "Removed $host"
}

list(){
    cat "$LOCALLIST" 2>/dev/null || true
}

case "$1" in
  add)
    add "$2" "$3"
    ;;
  remove)
    remove "$2"
    ;;
  list)
    list
    ;;
  *)
    echo "Usage: $0 {add <ip> <hostname>|remove <hostname>|list}"
    exit 2
    ;;
esac
