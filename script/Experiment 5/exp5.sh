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

rm -r $OUTPUT_DIR
mkdir -p $OUTPUT_DIR
mkdir -p $HAR_DIR
mkdir -p $CAP_DIR
mkdir -p $RENDERED_SITES
mkdir -p $RECOVERED_SITES
mkdir -p $RESOURCES_TABLES

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
		start_time=$(date +"%d/%m/%Y-%H:%M:%S")
		day=$(date +"%d%m%Y")
		hour=$(date +"%H%M")
		file="$method-$site-$day-$hour"
		url="$urlmethod://$site"
		rtt=`ping -c 1 $site | grep rtt | tr "/" " " | cut -d " " -f 8`
		ip=`ping -c 1 $site | head -n 1 | tr [\(,\)] " " | cut -d " " -f 4`
		exec_cmd="$exec_cmd about:blank"

		$RENDER_SITE $urlmethod $site "$RENDERED_SITES/$method-$site-$day-$hour.png"
		wget -q -E -H -k -K -p -P /tmp $url
		mv /tmp/$site/ $RECOVERED_SITES/$file/
        python resources_table.py "$RESOURCES_TABLES/$file" 

		$exec_cmd &
		PID_CHROME=$!
		sleep 3

		$TSHARK -i $IFACE -f "$TSHARK_FILTER" -w "$CAP_DIR/$file.cap" &
		PID_TSHARK=$!
		sleep 3
		$HARCAPTURER -o "$HAR_DIR/$file.har" $url
		sync
		kill $PID_CHROME
		sleep 5
		kill $PID_TSHARK
		finish_time=$(date +"%d/%m/%Y-%H:%M:%S")
		sync
		./log.py --log $site $method 1 $file $start_time $finish_time $ip $rtt
	done
done
./log.py --parse
