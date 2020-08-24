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

export PATH=$PATH:/usr/sbin;
PTH="/opt/ngoagent/JAM/Discovery/script/";
source ${PTH}JAM_CONFIG.conf
rm -f ${PTH}JAM_success_*.log

CMD10=`which timeout|head -1`;

ipp=`sudo /sbin/ip r|grep -i src|awk '{print $9}' | head -1`

$CMD10 60s sudo bash ${PTH}run_checksum.sh

echo $ipp > $LOGERR
$CMD10 120s sudo bash  ${PTH}all_unix.sh 1> $OUTCSV 2>> $LOGERR

$CMD10 300s sudo bash  ${PTH}all_unix_installed_SW.sh