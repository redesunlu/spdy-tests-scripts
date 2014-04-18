#!/bin/bash

# This script executes chromium, tshark and chrome-har-capturer to test 3
# different methods loading a web page (http,https,spdy) in order to determine
# which one is faster/better.

# Requeriments:
# - Chromium or Chrome
# - TShark
# - Chrome-har-capturer: https://github.com/cyrus-and/chrome-har-capturer

# Ensure your dumpcap binary has CAP_NET_ADMIN capabilities, so you don't have
# to be root
# setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip' /usr/bin/dumpcap


CONFIG_FILE="./config.cfg"

source $CONFIG_FILE
source $SITES_FILE

export DISPLAY=:0

rm -r $OUTPUT_DIR $LOGFILE
mkdir -p $OUTPUT_DIR

METHODS=("http" "https" "spdy")
for method in "${METHODS[@]}"; do
	if [ "$method" = "spdy" ]; then
		urlmethod="https"
		exec_cmd=$RUN
	else
		urlmethod=$method
		exec_cmd="$RUN --use-spdy=off"
	fi
	for site in $SITES; do
		echo "STARTED. Method: $method - Site: $site - $(date)" >> $LOGFILE
		day=$(date +"%d%m%Y")
		hour=$(date +"%H%M")
		file="$method-$site-$day-$hour"
		url="$urlmethod://$site"
		exec_cmd="$exec_cmd about:blank"

		$exec_cmd &
		PID_CHROME=$!
		sleep 3
		$TSHARK -i $IFACE -w $OUTPUT_DIR$file.cap &
		PID_TSHARK=$!
		sleep 3
		$HARCAPTURER -o $OUTPUT_DIR$file.har $url
		sync
		kill $PID_CHROME
		sleep 5
		kill $PID_TSHARK
		echo "FINISHED. Method: $method - Site: $site - $(date)" >> $LOGFILE
		sync
	done
done
