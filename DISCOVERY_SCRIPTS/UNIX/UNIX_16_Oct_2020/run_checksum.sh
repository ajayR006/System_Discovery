#!/bin/bash
##################################
#            
# RJIL
# JAM Project
# AUG-2020
# vimal.kumar@ril.com
# JAM Disocvery Script
# Checksum file
# Production-Version : 2.0

CMD1=`sudo which md5sum |head -1`;
PTH="/opt/ngoagent/JAM/Discovery/script/";
source ${PTH}JAM_CONFIG.conf
rm -f /opt/ngoagent/JAM/Discovery/script/CHK_*.log
SVER="script_version-2.0";
>$CHKLOG
sleep 5

st_dt=$(date +"%d-%m-%Y %T");
host=`hostname`;
ipp=`sudo /sbin/ip addr |grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep  -v 127.0.0| tr '\n' ' '| sed 's/.$/ /' | awk '{print $1}'`;

OSHWSCRIPT=`sudo $CMD1 ${PTH}all_unix.sh`;
CONFIGFILE=`sudo $CMD1 ${PTH}JAM_CONFIG.conf`;
RUNCHECKSUM=`sudo $CMD1 ${PTH}run_checksum.sh`;
RUNOSHWSCRIPT=`sudo $CMD1 ${PTH}run_all_unix.sh`
SWSCRIPT=`sudo $CMD1 ${PTH}all_unix_installed_SW.sh`

STMT='{';
STMT=$STMT'"DESCRIPTOR":"CHECKSUM",';
STMT=$STMT'"IPADDRESS":"'$ipp'",';
STMT=$STMT'"VALUES":["HOSTNAME|'$host'"],';
STMT=$STMT'"ITERATION":[';
for i in "$OSHWSCRIPT" "$CONFIGFILE" "$RUNCHECKSUM" "$RUNOSHWSCRIPT" "$SWSCRIPT";
do
  CHK=`echo ${i}|awk '{print $1}'`;
  SCRPATH=`echo ${i}|awk '{print $2}'`;
  if [[ ${i} == "$SWSCRIPT" ]]
  then
     STMT=$STMT'{"PATH":"'$SCRPATH'","CHECKSUM":"'$CHK'"}';
  else
     STMT=$STMT'{"PATH":"'$SCRPATH'","CHECKSUM":"'$CHK'"},';
  fi
done
STMT=$STMT']';
STMT=$STMT'}';
echo $STMT > $CHKLOG;

ed_dt=$(date +"%d-%m-%Y %T");
filesize=$(stat -c%s "$CHKLOG")
echo $st_dt,"CHECKSUM",$host-$ipp,"INFO","Script Started" >> $STALOG
if (( filesize > 400 )); then
   echo $(date +"%d-%m-%Y %T"),"CHECKSUM",$host-$ipp,"SUCCESS","Script Execution is successfull" >> $STALOG
else
   echo $(date +"%d-%m-%Y %T"),"CHECKSUM",$host-$ipp,"FAILURE","Script Execution is failed" >> $STALOG
fi
echo $ed_dt,"CHECKSUM",$host-$ipp,"INFO","Script output generated" >> $STALOG
echo $(date +"%d-%m-%Y %T"),"CHECKSUM",$host-$ipp,"INFO",$SVER >> $STALOG