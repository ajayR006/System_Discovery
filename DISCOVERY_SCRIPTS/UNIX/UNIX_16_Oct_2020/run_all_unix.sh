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
rm /opt/ngoagent/JAM/Discovery/script/CHK_*.log
rm /opt/ngoagent/JAM/Discovery/script/JAM_success_*.log
rm /opt/ngoagent/JAM/Discovery/script/JAM_SW_*.log
sleep 10

CMD10=`which timeout|head -1`;

ipp=`sudo /sbin/ip addr |grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep  -v 127.0.0| tr '\n' ' '| sed 's/.$/ /' | awk '{print $1}'`;

$CMD10 60s sudo bash ${PTH}run_checksum.sh

echo $ipp > $LOGERR
$CMD10 120s sudo bash  ${PTH}all_unix.sh 1> $OUTCSV 2>> $LOGERR

$CMD10 300s sudo bash  ${PTH}all_unix_installed_SW.sh