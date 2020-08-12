#!/bin/bash
##################################
#            
# RJIL
# JAM Project
# AUG-2020
# vimal.kumar@ril.com
# JAM Disocvery Script
# Checksum file

CMD1=`which md5sum |head -1`;
PTH="/opt/ngoagent/JAM/Discovery/script/";
source ${PTH}JAM_CONFIG.conf
rm -f /opt/ngoagent/JAM/Discovery/script/CHK_*.log

st_dt=$(date);
host=`hostname`;
ipp=`/sbin/ip r|grep -i src|awk '{print $9}'|head -1`;

OSHWSCRIPT=`$CMD1 ${PTH}all_unix.sh`;
CONFIGFILE=`$CMD1 ${PTH}JAM_CONFIG.conf`;
RUNCHECKSUM=`$CMD1 ${PTH}run_checksum.sh`;
RUNOSHWSCRIPT=`$CMD1 ${PTH}run_all_unix.sh`
SWSCRIPT=`$CMD1 ${PTH}all_unix_installed_SW.sh`

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

ed_dt=$(date);
filesize=$(stat -c%s "$CHKLOG")
echo $st_dt,"CHECKSUM",$host,$ipp,"INFO","Script Started" >> $STALOG
if (( filesize > 400 )); then
   echo $(date),"CHECKSUM",$host,$ipp,"SUCCESS","Script Execution is successfull" >> $STALOG
else
   echo $(date),"CHECKSUM",$host,$ipp,"FAILURE","Script Execution is failed" >> $STALOG
fi
echo $ed_dt,"CHECKSUM",$host,$ipp,"INFO","Script output generated" >> $STALOG