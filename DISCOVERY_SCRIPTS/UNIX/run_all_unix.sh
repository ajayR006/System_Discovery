#!/usr/bin/bash
##

PTH="/opt/ngoagent/JAM/Discovery/script/";
source ${PTH}JAM_CONFIG.conf
rm -f ${PTH}JAM_success_*.csv

ipp=`/sbin/ip r|grep -i src|awk '{print $9}' | head -1`

echo $ipp > $LOGERR
bash  ${PTH}all_unix.sh 1> $OUTCSV 2>> $LOGERR