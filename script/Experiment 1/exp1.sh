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
ssh root@hera "ipfw add 1000 pipe 1 ip from any to any; ipfw pipe 1 config bw 1000Kbp/s;"
for bw in $BW_LIST; do
    for delay in $DELAY_LIST; do
        ssh root@hera "ipfw pipe 1 config bw $bw delay $delay"
        echo "NEW TRAFFIC SHAPING: $bw x $delay" >> $LOGFILE
        for method in "${methods[@]}"; do
            if [ "$method" = "spdy" ]; then
                urlmethod="https"
                exec_cmd=$RUN
                ssh root@zeus "a2enmod spdy"
            else
                urlmethod=$method
                exec_cmd="$RUN --use-spdy=off"
                ssh root@zeus "a2dismod spdy"
            fi

            ssh root@zeus "service apache2 restart"
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
    done
done
