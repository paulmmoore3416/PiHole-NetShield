#!/bin/bash

# Network Traffic Analyzer for Pi-hole
# Analyzes network traffic patterns

LOG_FILE="/var/log/pihole-network.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Get top DNS queries
echo "$TIMESTAMP - Top DNS queries:" >> "$LOG_FILE"
tail -n 1000 /var/log/pihole/pihole.log | grep "query" | awk '{print $6}' | sort | uniq -c | sort -nr | head -10 >> "$LOG_FILE"

# Get blocked domains
echo "$TIMESTAMP - Top blocked domains:" >> "$LOG_FILE"
tail -n 1000 /var/log/pihole/pihole.log | grep "blocked" | awk '{print $6}' | sort | uniq -c | sort -nr | head -10 >> "$LOG_FILE"

# Network interface stats
echo "$TIMESTAMP - Network interface statistics:" >> "$LOG_FILE"
ip -s link show eth0 >> "$LOG_FILE"

# Pi-hole client stats
echo "$TIMESTAMP - Top clients:" >> "$LOG_FILE"
pihole -c -j | jq -r '.top_sources | to_entries[] | "\(.key): \(.value)"' | head -10 >> "$LOG_FILE"