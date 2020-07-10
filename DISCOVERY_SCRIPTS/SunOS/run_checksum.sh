#!/usr/bin/bash
##
#set -x

st_dt=$(date);
host=`hostname`

CMD1=`which md5sum`;
PTH="/opt/ngoagent/JAM/Discovery/script/";
source ${PTH}JAM_CONFIG.conf

rm -f /opt/ngoagent/JAM/Discovery/script/CHK_*.log

ipp=`/usr/sbin/ifconfig -a | awk '/flags/ {printf $1" "} /inet/ {print $2}' | grep -v lo | head -1 | awk -F':' '{print $2}' | sed 's/^ *//g'`

#echo $ipp' '`$CMD1 /opt/JAM_DISC/host_discovery_SUNOS.sh` > $CHKLOG
#echo $ipp' '`$CMD1 /opt/JAM_DISC/JAM_CONFIG.conf` >> $CHKLOG
#echo $ipp' '`$CMD1 /opt/JAM_DISC/run_checksum.sh` >> $CHKLOG
#echo $ipp' '`$CMD1 /opt/JAM_DISC/run_host_discovery_SUNOS.sh` >> $CHKLOG

OSHWSCRIPT=`$CMD1 ${PTH}host_discovery_SUNOS.sh`;
CONFIGFILE=`$CMD1 ${PTH}JAM_CONFIG.conf`;
RUNCHECKSUM=`$CMD1 ${PTH}run_checksum.sh`;
RUNOSHWSCRIPT=`$CMD1 ${PTH}run_host_discovery_SUNOS.sh`
SWSCRIPT=`$CMD1 ${PTH}installed_software_SUNOS.sh`

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