#!/bin/bash

# This script executes chromium, tshark and chrome-har-capturer to test 3 different methods 
# to load a web page (http,https,spdy) in order to determine which one is faster/better.

# Requeriments:
# - Chromium or Chrome
# - TShark
# - Chrome-har-capturer: https://github.com/cyrus-and/chrome-har-capturer

# Ensure your dumpcap binary has CAP_NET_ADMIN capabilities, so you don't have to be root
# setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip' /usr/bin/dumpcap

export DISPLAY=:0
source config.cfg
mkdir -p $outputdir
mkdir -p $datadir
methods=("http" "https" "spdy")
rm $outputdir* $logfile
touch $logfile
ssh root@hera "ipfw add 1000 pipe 1 ip from any to any; ipfw pipe 1 config bw 1000Kbp/s;"
for bw in $bw_list; do
  for delay in $delay_list; do
    ssh root@hera "ipfw pipe 1 config bw $bw delay $delay"
    echo "NEW TRAFFIC SHAPING: $bw x $delay" >> $logfile 
    for method in "${methods[@]}"; do
        urlmethod=$method
        if [ "$method" = "spdy" ]; then
            urlmethod="https"
            exec_cmd=$cmd
            ssh root@zeus "a2enmod spdy"
        else
            exec_cmd="$cmd --use-spdy=off"
            ssh root@zeus "a2dismod spdy"
        fi
        ssh root@zeus "service apache2 restart"
        for site in $sites; do
            echo "STARTED. Method: $method - Site: $site - $(date)" >> $logfile 
            day=$(date +"%d%m%Y")
            hour=$(date +"%H%M")
            file="$method-$site-$day-$hour"
            rm -r $datadir
            exec_cmd="$exec_cmd about:blank"
            #echo "Executing: $exec_cmd" >> $logfile
            $exec_cmd &
            PID_CHROME=$!
            sleep 3
            #echo "Executing: $tshark -i $iface -w $outputdir$file.cap" >> $logfile
            $tshark -i $iface -w $outputdir$file.cap &
            PID_TSHARK=$!
            sleep 3
            url="$urlmethod://$site"
            #echo "Executing: $harcapt -o $outputdir$file.har $url" >> $logfile
            $harcapt -o $outputdir$file.har $url 
            sync
            kill $PID_CHROME
            sleep 5
            kill $PID_TSHARK
            echo "FINISHED. Method: $method - Site: $site - $(date)" >> $logfile 
            sync
        done
    done
  done
done
