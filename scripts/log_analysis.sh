#!/bin/bash

# Log Analysis Script for Pi-hole
# Analyzes logs for troubleshooting and optimization

LOG_FILE="/var/log/pihole/pihole.log"
ANALYSIS_FILE="/var/log/pihole-analysis.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "$TIMESTAMP - Starting log analysis" > "$ANALYSIS_FILE"

# Count total queries
TOTAL_QUERIES=$(grep "query" "$LOG_FILE" | wc -l)
echo "Total queries: $TOTAL_QUERIES" >> "$ANALYSIS_FILE"

# Count blocked queries
BLOCKED_QUERIES=$(grep "blocked" "$LOG_FILE" | wc -l)
echo "Blocked queries: $BLOCKED_QUERIES" >> "$ANALYSIS_FILE"

# Calculate block percentage
if [[ $TOTAL_QUERIES -gt 0 ]]; then
    BLOCK_PERCENTAGE=$(( BLOCKED_QUERIES * 100 / TOTAL_QUERIES ))
    echo "Block percentage: $BLOCK_PERCENTAGE%" >> "$ANALYSIS_FILE"
fi

# Top blocked domains
echo "Top 10 blocked domains:" >> "$ANALYSIS_FILE"
grep "blocked" "$LOG_FILE" | awk '{print $6}' | sort | uniq -c | sort -nr | head -10 >> "$ANALYSIS_FILE"

# Top clients
echo "Top 10 clients:" >> "$ANALYSIS_FILE"
grep "query" "$LOG_FILE" | awk '{print $8}' | sort | uniq -c | sort -nr | head -10 >> "$ANALYSIS_FILE"

# Error analysis
echo "Errors in last 24 hours:" >> "$ANALYSIS_FILE"
grep -E "(error|fail)" "$LOG_FILE" | tail -20 >> "$ANALYSIS_FILE"

echo "$TIMESTAMP - Log analysis completed" >> "$ANALYSIS_FILE"