#!/usr/bin/bash
##

PTH="/opt/ngoagent/JAM/Discovery/script/";
source ${PTH}JAM_CONFIG.conf

rm -f ${PTH}JAM_success_*.csv

ipp=`/usr/sbin/ifconfig -a | awk '/flags/ {printf $1" "} /inet/ {print $2}' | grep -v lo | head -1 | awk -F':' '{print $2}' | sed 's/^ *//g'`

echo $ipp > $LOGERR
bash ${PTH}host_discovery_SUNOS.sh 1> $OUTCSV 2>> $LOGERR