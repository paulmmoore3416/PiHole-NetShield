#!/bin/bash

# Performance Monitoring Script for Pi-hole
# Monitors system resources and Pi-hole metrics

LOG_FILE="/var/log/pihole-performance.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# System metrics
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
MEM_USAGE=$(free | grep Mem | awk '{printf "%.2f", $3/$2 * 100.0}')
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

# Pi-hole metrics
if command -v pihole &> /dev/null; then
    QUERIES_TODAY=$(pihole -c -j | jq -r '.queries_today')
    BLOCKED_TODAY=$(pihole -c -j | jq -r '.blocked_today')
    PERCENT_BLOCKED=$(pihole -c -j | jq -r '.percent_blocked_today')
else
    QUERIES_TODAY="N/A"
    BLOCKED_TODAY="N/A"
    PERCENT_BLOCKED="N/A"
fi

# Log metrics
echo "$TIMESTAMP - CPU: ${CPU_USAGE}%, MEM: ${MEM_USAGE}%, DISK: ${DISK_USAGE}%, Queries: $QUERIES_TODAY, Blocked: $BLOCKED_TODAY, Percent: $PERCENT_BLOCKED%" >> "$LOG_FILE"

# Check thresholds
if (( $(echo "$CPU_USAGE > 80" | bc -l) )); then
    echo "$TIMESTAMP - WARNING: High CPU usage: ${CPU_USAGE}%" >> "$LOG_FILE"
fi

if (( $(echo "$MEM_USAGE > 80" | bc -l) )); then
    echo "$TIMESTAMP - WARNING: High memory usage: ${MEM_USAGE}%" >> "$LOG_FILE"
fi

if (( DISK_USAGE > 90 )); then
    echo "$TIMESTAMP - WARNING: High disk usage: ${DISK_USAGE}%" >> "$LOG_FILE"
fi