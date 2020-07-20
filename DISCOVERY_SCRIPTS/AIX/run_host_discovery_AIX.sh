#!/usr/bin/bash
##

PTH="/opt/ngoagent/JAM/Discovery/script/";
source ${PTH}JAM_CONFIG.conf

rm -f ${PTH}JAM_success_*.csv

ipp=`prtconf|grep -i "IP Address:"|awk -F":" '{print $2}'|head -1`

echo $ipp > $LOGERR
bash ${PTH}host_discovery_AIX.sh 1> $OUTCSV 2>> $LOGERR