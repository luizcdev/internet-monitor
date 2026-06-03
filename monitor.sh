#!/bin/bash

LOG="internet_log.txt"

while true
do
    DATE=$(date "+%Y-%m-%d %H:%M:%S")

    RESULT=$(speedtest --accept-license --accept-gdpr --format=json)

    DOWNLOAD=$(echo $RESULT | jq '.download.bandwidth * 8 / 1000000')
    UPLOAD=$(echo $RESULT | jq '.upload.bandwidth * 8 / 1000000')
    PING=$(echo $RESULT | jq '.ping.latency')

    echo "[$DATE]" >> $LOG
    echo "Download: ${DOWNLOAD} Mbps" >> $LOG
    echo "Upload: ${UPLOAD} Mbps" >> $LOG
    echo "Ping: ${PING} ms" >> $LOG
    echo "------------------------" >> $LOG

    sleep 300
done

