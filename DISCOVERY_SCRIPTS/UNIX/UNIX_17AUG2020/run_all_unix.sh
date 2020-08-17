#!/bin/bash
##################################
#            
# RJIL
# JAM Project
# AUG-2020
# vimal.kumar@ril.com
# JAM Disocvery Script
# wrapper file
# Production-Version : 2.0

PTH="/opt/ngoagent/JAM/Discovery/script/";
source ${PTH}JAM_CONFIG.conf
rm -f ${PTH}JAM_success_*.log

CMD10=`which timeout|head -1`;

ipp=`/sbin/ip r|grep -i src|awk '{print $9}' | head -1`

$CMD10 30s bash ${PTH}run_checksum.sh

echo $ipp > $LOGERR
$CMD10 60s bash  ${PTH}all_unix.sh 1> $OUTCSV 2>> $LOGERR

$CMD10 120s bash  ${PTH}all_unix_installed_SW.sh