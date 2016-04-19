#!/bin/bash

# Record the number of twitter followers for the listed accounts

# To execute daily add to crontab:
# m h  dom mon dow   command
# 8 12 * * * /home/bcarreno/twitter.sh >> /home/bcarreno/twitter.log 2>&1

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

accounts=( "BernieSanders" "sensanders" "HillaryClinton" "realDonaldTrump" "tedcruz" "JebBush" "marcorubio" "RealBenCarson" )
for account in "${accounts[@]}"
do
	echo -e ${account}'\t'$(date +"%Y-%m-%d\t%H:%M:%S")'\t'$(t whois ${account} | grep Followers | awk '{print $2}' | sed 's/,//g')
	sleep 10
done
