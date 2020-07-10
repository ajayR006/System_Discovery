#!/usr/bin/bash
#set -x

CMD4=`which ifconfig`;
CMD1=`which pkginfo`;

st_dt=$(date);
ipv4=`$CMD4 -a | awk '/flags/ {printf $1" "} /inet/ {print $2}' | grep -v lo | head -1 | awk -F':' '{print $2}' | sed 's/^ *//g'`
host=`hostname`

PTH="/opt/ngoagent/JAM/Discovery/script/";
source ${PTH}JAM_CONFIG.conf

rm -f ${PTH}JAM_SW_*.csv

$CMD1 -l | egrep "PKGINST|VERSION|INSTDATE|ARCH|DESC" > $SWCSV1

lastline=`wc -l $SWCSV1|awk '{print $1}'`;
lastline=$((lastline+1));
cnt=$((lastline-1));
i=1;
STMT='{';
STMT=$STMT'"DESCRIPTOR":"INSTALLED_SW",';
STMT=$STMT'"IPADDRESS":"'$ipv4'",';
STMT=$STMT'"VALUES":["HOSTNAME|'$host'"],';
STMT=$STMT'"ITERATION":[';

while [ $i -lt $lastline ]
do
  swname=`sed -n "$i p" $SWCSV1|awk -F':' '{print $2}'`
  i=$((i+1));
  swarc=`sed -n "$i p" $SWCSV1|awk -F':' '{print $2}'`
  i=$((i+1));
  swver=`sed -n "$i p" $SWCSV1|awk -F':' '{print $2}'` 
  i=$((i+1));
  swdesc=`sed -n "$i p" $SWCSV1|awk -F':' '{print $2}'`
  i=$((i+1));
  swdt=`sed -n "$i p" $SWCSV1|awk -F':' '{print $2}'|awk '{print $2,$1,$3}'`
  i=$((i+1));
  STMT=$STMT'{';
  STMT=$STMT'"SOFTWARENAME":"'$swname'",';
  STMT=$STMT'"SWVERSION":"'$swver'",';
  STMT=$STMT'"INSTALLEDDT":"'$swdt'",';
  STMT=$STMT'"ARCHITECTURE":"'$swarc'",';
  if [[ $i -lt $cnt ]]
  then
      STMT=$STMT'"DESCRIPTION":"'$swdesc'"},';
  else
      STMT=$STMT'"DESCRIPTION":"'$swdesc'"}';
  fi 
#echo $swname, $swver, $swdt, $sqarc, $swdesc;
done
STMT=$STMT']';
STMT=$STMT'}';

echo $STMT > $SWCSV;


ed_dt=$(date);

filesize=$(stat -c%s "$SWCSV")
echo $st_dt,"INSTALLED_SW",$host,$ipv4,"INFO","Script Started" >> $STALOG

if (( filesize > 5000 )); then
   echo $(date),"INSTALLED_SW",$host,$ipv4,"SUCCESS","Script Execution is successfull" >> $STALOG
else
   echo $(date),"INSTALLED_SW",$host,$ipv4,"FAILURE","Script Execution is failed" >> $STALOG
fi

echo $ed_dt,"INSTALLED_SW",$host,$ipv4,"INFO","Script output generated" >> $STALOG