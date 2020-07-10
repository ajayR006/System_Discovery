#!/usr/bin/ksh

st_dt=$(date);
host=`hostname`

PTH="/opt/ngoagent/JAM/Discovery/script/";
source ${PTH}JAM_CONFIG.conf

rm -f ${PTH}JAM_SW_*.csv

awk 'BEGIN{OFS=",";print "IP","hostname","Software Name","Version"}' > $SWCSV1
ipp=`prtconf|grep -i "IP Address:"|awk -F":" '{print $2}'`
lslpp -Lc | awk -v ht=`hostname` -v ipv=`echo $ipp` -F: ' NR>1 {print ipv" ; "ht" ; "$1" ; "$8" ; "$3}' >> $SWCSV1

VLINENO=`wc -l $SWCSV1|awk '{print $1}'`;
VLINENO="$((VLINENO + 0))";
CNT=0;

STMT='{';
STMT=$STMT'"DESCRIPTOR":"INSTALLED_SW",';
STMT=$STMT'"IPADDRESS":"'$ipp'",';
STMT=$STMT'"VALUES":["HOSTNAME|'$host'"],';
STMT=$STMT'"ITERATION":[';
while IFS= read -r LINE
do
  CNT="$((CNT + 1))";
  if [[ $CNT -gt 1 ]]
  then
    VSW=`echo "$LINE"| awk -F',' '{print $3}'`;
    VVER=`echo "$LINE"| awk -F',' '{print $4}'`;
    
    STMT=$STMT'{';
    STMT=$STMT'"SOFTWARENAME":"'$VSW'",';
    if [[ $CNT -lt $VLINENO ]]
    then
       STMT=$STMT'"SWVERSION":"'$VVER'"},';
    else
       STMT=$STMT'"SWVERSION":"'$VVER'"}';
    fi
  fi
done < $SWCSV1
STMT=$STMT']';
STMT=$STMT'}';
echo $STMT > $SWCSV;

ed_dt=$(date);

filesize=`wc -c $SWCSV1 | awk '{print $1}'`
filesize=$((filesize+0));

echo $st_dt,"INSTALLED_SW",$host,$ipp,"INFO","Script Started" >> $STALOG

if (( filesize > 5000 )); then
   echo $(date),"INSTALLED_SW",$host,$ipp,"SUCCESS","Script Execution is successfull" >> $STALOG
else
   echo $(date),"INSTALLED_SW",$host,$ipp,"FAILURE","Script Execution is failed" >> $STALOG
fi

echo $ed_dt,"INSTALLED_SW",$host,$ipp,"INFO","Script output generated" >> $STALOG