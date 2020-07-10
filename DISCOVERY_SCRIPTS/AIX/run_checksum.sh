#!/usr/bin/bash
####
#set -x

st_dt=$(date);
host=`hostname`

PTH="/opt/ngoagent/JAM/Discovery/script/";
source ${PTH}JAM_CONFIG.conf

rm -f /opt/ngoagent/JAM/Disovery/script/CHK_*.log

ipp=`prtconf|grep -i "IP Address:"|awk -F":" '{print $2}' | head -1`



#echo $ipp' '`/usr/bin/csum -h MD5 ${PTH}host_discovery_AIX.sh` > $CHKLOG
#echo $ipp' '`/usr/bin/csum -h MD5 ${PTH}JAM_CONFIG.conf` >> $CHKLOG
#echo $ipp' '`/usr/bin/csum -h MD5 ${PTH}run_checksum.sh` >> $CHKLOG
#echo $ipp' '`/usr/bin/csum -h MD5 ${PTH}run_host_discovery_AIX.sh` >> $CHKLOG
#echo $ipp' '`/usr/bin/csum -h MD5 ${PTH}installed_software_AIX.sh` >> $CHKLOG

OSHWSCRIPT=`/usr/bin/csum -h MD5 ${PTH}host_discovery_AIX.sh`;
CONFIGFILE=`/usr/bin/csum -h MD5 ${PTH}JAM_CONFIG.conf`;
RUNCHECKSUM=`/usr/bin/csum -h MD5 ${PTH}run_checksum.sh`;
RUNOSHWSCRIPT=`/usr/bin/csum -h MD5 ${PTH}run_host_discovery_AIX.sh`;
SWSCRIPT=`/usr/bin/csum -h MD5 ${PTH}installed_software_AIX.sh`;

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


filesize=`wc -c $CHKLOG | awk '{print $1}'`
filesize=$((filesize+0));

echo $st_dt,"CHECKSUM",$host,$ipp,"INFO","Script Started" >> $STALOG

if (( filesize > 400 )); then
   echo $(date),"CHECKSUM",$host,$ipp,"SUCCESS","Script Execution is successfull" >> $STALOG
else
   echo $(date),"CHECKSUM",$host,$ipp,"FAILURE","Script Execution is failed" >> $STALOG
fi

echo $ed_dt,"CHECKSUM",$host,$ipp,"INFO","Script output generated" >> $STALOG