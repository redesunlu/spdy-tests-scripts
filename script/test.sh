#!/bin/bash

#facebook.com
#google.com
#youtube.com
#blogger.com
#twitter.com
#wordpress.com
#imgur.com
#youm7.com
#blog in blogger
#site in wordpress

source config.cfg
mkdir -p $output
mkdir -p $datadir
methods=("http" "https" "spdy")
for method in "${methods[@]}"
	do
		for site in $(cat sites.txt)
			do
				day=$(date +"%d%m%Y")
				hour=$( date +"%H%M")
				file="$method-$site-$day-$hour"
				rm -r $datadir
				tmpmethod=$method
				if [ "$method" = "spdy" ]; then
					tmpmethod="https"
					$chrome --remote-debugging-port=9222 --user-data-dir=$datadir --no-first-run --enable-benchmarking --dns-prefetch-disable --disable-translate --disable-extensions --disable-background-networking --safebrowsing-disable-auto-update --ignore-certificate-errors about:blank &
				else
					$chrome --remote-debugging-port=9222 --user-data-dir=$datadir --no-first-run --enable-benchmarking --dns-prefetch-disable --disable-translate --disable-extensions --disable-background-networking --safebrowsing-disable-auto-update --ignore-certificate-errors --use-spdy=off about:blank &
				fi
				PID_CHROME=$!
				sleep 10s
				$tshark -i eth0 -w $output$file.cap &
				PID_TSHARK=$!
				sleep 10s
				url="$tmpmethod://$site"
				$harcapt -o $output$file.har $url 
				PID_HAR=$!
				sync
				kill $PID_CHROME
				kill $PID_TSHARK
				day=$(date +"%d%m%Y")
				hour=$( date +"%H%M")
				echo "Method: $method - Site: $site - $day, $hour" >> log.txt 
				sleep 20s
		done
	done
