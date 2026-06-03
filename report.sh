#!/bin/bash

LOG_FILE="internet_log.txt"

if [ ! -f "$LOG_FILE" ]; then
    echo "Log file not found: $LOG_FILE"
    exit 1
fi

# Start and end timestamps
START_DATE=$(grep -m1 '^\[' "$LOG_FILE" | tr -d '[]')
END_DATE=$(grep '^\[' "$LOG_FILE" | tail -1 | tr -d '[]')

# Convert dates to Unix timestamps
START_TS=$(date -d "$START_DATE" +%s 2>/dev/null)
END_TS=$(date -d "$END_DATE" +%s 2>/dev/null)

# Monitoring duration
DURATION_SEC=$((END_TS - START_TS))

DAYS=$((DURATION_SEC / 86400))
HOURS=$(((DURATION_SEC % 86400) / 3600))
MINUTES=$(((DURATION_SEC % 3600) / 60))

# Extract metrics
DOWNLOADS=$(grep "Download:" "$LOG_FILE" | awk '{print $2}')
UPLOADS=$(grep "Upload:" "$LOG_FILE" | awk '{print $2}')
PINGS=$(grep "Ping:" "$LOG_FILE" | awk '{print $2}')

TOTAL_TESTS=$(echo "$DOWNLOADS" | wc -l | tr -d ' ')

if [ "$TOTAL_TESTS" -eq 0 ]; then
    echo "No measurements found."
    exit 1
fi

# Average values
AVG_DOWNLOAD=$(echo "$DOWNLOADS" | awk '{sum+=$1} END {printf "%.2f", sum/NR}')
AVG_UPLOAD=$(echo "$UPLOADS" | awk '{sum+=$1} END {printf "%.2f", sum/NR}')
AVG_PING=$(echo "$PINGS" | awk '{sum+=$1} END {printf "%.3f", sum/NR}')

# Min and max values
MIN_DOWNLOAD=$(echo "$DOWNLOADS" | sort -n | head -1)
MAX_DOWNLOAD=$(echo "$DOWNLOADS" | sort -n | tail -1)

MIN_UPLOAD=$(echo "$UPLOADS" | sort -n | head -1)
MAX_UPLOAD=$(echo "$UPLOADS" | sort -n | tail -1)

MIN_PING=$(echo "$PINGS" | sort -n | head -1)
MAX_PING=$(echo "$PINGS" | sort -n | tail -1)

# Average interval between measurements
if [ "$TOTAL_TESTS" -gt 1 ]; then
    AVG_INTERVAL_SEC=$((DURATION_SEC / (TOTAL_TESTS - 1)))
    AVG_INTERVAL_MIN=$((AVG_INTERVAL_SEC / 60))
    AVG_INTERVAL_REM_SEC=$((AVG_INTERVAL_SEC % 60))
else
    AVG_INTERVAL_MIN=0
    AVG_INTERVAL_REM_SEC=0
fi

# Count failed measurements
FAILED_TESTS=0

while IFS= read -r line; do
    if [[ "$line" =~ ^\[.*\]$ ]]; then

        read -r line1 || true
        read -r line2 || true
        read -r line3 || true

        if [[ ! "$line1" =~ Download: ]] || \
           [[ ! "$line2" =~ Upload: ]] || \
           [[ ! "$line3" =~ Ping: ]]; then
            ((FAILED_TESTS++))
        fi
    fi
done < "$LOG_FILE"

TOTAL_ATTEMPTS=$((TOTAL_TESTS + FAILED_TESTS))

if [ "$TOTAL_ATTEMPTS" -gt 0 ]; then
    SUCCESS_RATE=$(awk -v ok="$TOTAL_TESTS" -v total="$TOTAL_ATTEMPTS" \
        'BEGIN { printf "%.2f", (ok/total)*100 }')
else
    SUCCESS_RATE="0.00"
fi

cat << EOF

==================================================
NETWORK PERFORMANCE REPORT
==================================================

ANALYZED PERIOD
---------------
Start Date        : ${START_DATE}
End Date          : ${END_DATE}
Duration          : ${DAYS}d ${HOURS}h ${MINUTES}m
Average Interval  : ${AVG_INTERVAL_MIN}m ${AVG_INTERVAL_REM_SEC}s

DOWNLOAD
---------
Average Speed     : ${AVG_DOWNLOAD} Mbps
Minimum Speed     : ${MIN_DOWNLOAD} Mbps
Maximum Speed     : ${MAX_DOWNLOAD} Mbps

UPLOAD
-------
Average Speed     : ${AVG_UPLOAD} Mbps
Minimum Speed     : ${MIN_UPLOAD} Mbps
Maximum Speed     : ${MAX_UPLOAD} Mbps

LATENCY
-------
Average Ping      : ${AVG_PING} ms
Minimum Ping      : ${MIN_PING} ms
Maximum Ping      : ${MAX_PING} ms

AVAILABILITY
------------
Valid Tests       : ${TOTAL_TESTS}
Failed Tests      : ${FAILED_TESTS}
Success Rate      : ${SUCCESS_RATE}%

==================================================

EOF
