#!/bin/bash
##################################
#            
# RJIL
# JAM Project
# AUG-2020
# vimal.kumar@ril.com
# JAM Disocvery Script
# Installed Software script file

PTH="/opt/ngoagent/JAM/Discovery/script/";
source ${PTH}JAM_CONFIG.conf
rm -f ${PTH}JAM_SW_*.csv

st_dt=$(date);

Disc_Installed_SW_RHEL()
{
    ipp=`/sbin/ip r|grep -i src|awk '{print $9}'|head -1`;
	host=`hostname`;
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
			VDT=`echo "$LINE"| awk -F',' '{print $5}'`;

			STMT=$STMT'{';
			STMT=$STMT'"SOFTWARENAME":"'$VSW'",';
			STMT=$STMT'"SWVERSION":"'$VVER'",';
			if [[ $CNT -lt $VLINENO ]]
			then
				STMT=$STMT'"INSTALLEDDT":"'$VDT'"},';
			else
				STMT=$STMT'"INSTALLEDDT":"'$VDT'"}';
			fi
		fi
	done < $SWCSV1
	STMT=$STMT']';
	STMT=$STMT'}';
	echo $STMT > $SWCSV;

	ed_dt=$(date);
	filesize=$(stat -c%s "$SWCSV1");
	echo $st_dt,"INSTALLED_SW",$host,$ipp,"INFO","Script Started" >> $STALOG;
	if (( filesize > 5000 )); then
		echo $(date),"INSTALLED_SW",$host,$ipp,"SUCCESS","Script Execution is successfull" >> $STALOG;
	else
		echo $(date),"INSTALLED_SW",$host,$ipp,"FAILURE","Script Execution is failed" >> $STALOG;
	fi
	echo $ed_dt,"INSTALLED_SW",$host,$ipp,"INFO","Script output generated" >> $STALOG
}


Disc_Installed_SW_CENT()
{
	ipp=`/sbin/ip r|grep -i src|awk '{print $9}'|head -1`;
	host=`hostname`;
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
			VDT=`echo "$LINE"| awk -F',' '{print $5}'`;

			STMT=$STMT'{';
			STMT=$STMT'"SOFTWARENAME":"'$VSW'",';
			STMT=$STMT'"SWVERSION":"'$VVER'",';
			if [[ $CNT -lt $VLINENO ]]
			then
				STMT=$STMT'"INSTALLEDDT":"'$VDT'"},';
			else
				STMT=$STMT'"INSTALLEDDT":"'$VDT'"}';
			fi
		fi
	done < $SWCSV1
	STMT=$STMT']';
	STMT=$STMT'}';
	echo $STMT > $SWCSV;

	ed_dt=$(date);
	filesize=$(stat -c%s "$SWCSV1");
	echo $st_dt,"INSTALLED_SW",$host,$ipp,"INFO","Script Started" >> $STALOG;
	if (( filesize > 5000 )); then
		echo $(date),"INSTALLED_SW",$host,$ipp,"SUCCESS","Script Execution is successfull" >> $STALOG;
	else
		echo $(date),"INSTALLED_SW",$host,$ipp,"FAILURE","Script Execution is failed" >> $STALOG;
	fi
	echo $ed_dt,"INSTALLED_SW",$host,$ipp,"INFO","Script output generated" >> $STALOG;
}


Disc_Installed_SW_SUSE()
{
	ipp=`/sbin/ip r|grep -i src|awk '{print $9}'|head -1`;
	host=`hostname`;
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
			VER=`echo "$LINE"| awk -F',' '{print $4}'`;
			VDT=`echo "$LINE"| awk -F',' '{print $5}'`;

			STMT=$STMT'{';
			STMT=$STMT'"SOFTWARENAME":"'$VSW'",';
			STMT=$STMT'"SWVERSION":"'$VER'",';
			if [[ $CNT -lt $VLINENO ]]
			then
				STMT=$STMT'"INSTALLEDDT":"'$VDT'"},';
			else
				STMT=$STMT'"INSTALLEDDT":"'$VDT'"}';
			fi
		fi
	done < $SWCSV1
	STMT=$STMT']';
	STMT=$STMT'}';
	echo $STMT > $SWCSV;

	ed_dt=$(date);
	filesize=$(stat -c%s "$SWCSV1")
	echo $st_dt,"INSTALLED_SW",$host,$ipp,"INFO","Script Started" >> $STALOG;
	if (( filesize > 5000 )); then
		echo $(date),"INSTALLED_SW",$host,$ipp,"SUCCESS","Script Execution is successfull" >> $STALOG;
	else
		echo $(date),"INSTALLED_SW",$host,$ipp,"FAILURE","Script Execution is failed" >> $STALOG;
	fi
	echo $ed_dt,"INSTALLED_SW",$host,$ipp,"INFO","Script output generated" >> $STALOG;
}

Disc_Installed_SW_UBUNTU()
{
	ipp=`/sbin/ip r|grep -i src|awk '{print $9}'|head -1`;
	host=`hostname`;
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
			VARCH=`echo "$LINE"| awk -F',' '{print $5}'`;
			VDESC=`echo "$LINE"| awk -F',' '{print $6}'`;

			STMT=$STMT'{';
			STMT=$STMT'"SOFTWARENAME":"'$VSW'",';
			STMT=$STMT'"SWVERSION":"'$VVER'",';
			STMT=$STMT'"ARCHITECTURE":"'$VARCH'",';
			if [[ $CNT -lt $VLINENO ]]
			then
				STMT=$STMT'"DESCRIPTION":'$VDESC'},';
			else
				STMT=$STMT'"DESCRIPTION":'$VDESC'}';
			fi
		fi
	done < $SWCSV1
	STMT=$STMT']';
	STMT=$STMT'}';
	echo $STMT > $SWCSV;
	
	ed_dt=$(date);
	filesize=$(stat -c%s "$SWCSV1");
	echo $st_dt,"INSTALLED_SW",$host,$ipp,"INFO","Script Started" >> $STALOG;
	if (( filesize > 5000 )); then
		echo $(date),"INSTALLED_SW",$host,$ipp,"SUCCESS","Script Execution is successfull" >> $STALOG;
	else
		echo $(date),"INSTALLED_SW",$host,$ipp,"FAILURE","Script Execution is failed" >> $STALOG;
	fi
	echo $ed_dt,"INSTALLED_SW",$host,$ipp,"INFO","Script output generated" >> $STALOG;
}


if [ -f /etc/redhat-release ]; then
    os=`cat /etc/redhat-release`
elif [ -f  /etc/SuSE-release ]; then
    os=`cat /etc/SuSE-release`
else
    os=`lsb_release -d | cut -d':' -f2`
fi

ipp=`/sbin/ip r|grep -i src|awk '{print $9}'|head -1`;
VAROS=`echo $os|awk -F"release" '{print $1}'|awk '{print $1}' `
awk 'BEGIN{OFS=",";print "IP","hostname","Software Name","Version","Installed Date"}' > $SWCSV1;

if [ "$VAROS" = "Red" ]; then
    OSNAME="RHEL";
	awk 'BEGIN{OFS=",";print "IP","hostname","Software Name","Version","Installed Date"}' > $SWCSV1;
	rpm -qa --last|awk -v ht=`hostname` -v ip=$ipp 'BEGIN{OFS=","};{n=split($1,a,"-");print ip,ht,$1,a[n-1],$3"-"$4"-"$5}' >> $SWCSV1;
	Disc_Installed_SW_RHEL;
elif [ "$VAROS" = "CentOS" ]; then
	OSNAME="CENT";
	awk 'BEGIN{OFS=",";print "IP","hostname","Software Name","Version","Installed Date"}' > $SWCSV1;
	rpm -qa --last|awk -v ht=`hostname` -v ip=$ipp 'BEGIN{OFS=","};{n=split($1,a,"-");print ip,ht,$1,a[n-1],$3"-"$4"-"$5}' >> $SWCSV1;
	Disc_Installed_SW_CENT;
elif [ "$VAROS" = "SUSE" ]; then
	OSNAME="SUSE";
	rpm -qa --last|awk -v ht=`hostname` -v ip=$ipp 'BEGIN{OFS=","};{n=split($1,a,"-");print ip,ht,$1,a[n-1],$3"-"$4"-"$6}' >> $SWCSV1;
	Disc_Installed_SW_SUSE;
elif [ "$VAROS" = "Ubuntu" ]; then
	OSNAME="UBUNTU";
	dpkg-query -l |awk -v ht=`hostname` -v ip=$ipp -v x="\"" 'BEGIN{OFS=","}; NR>5 {print ip,ht,$2,$3,$4,x$5" "$6" "$7" "$8" "$9" "$10" "$11" "$12" "$13" "$14" "$15" "$16" "$17 x}' >> $SWCSV1;
	Disc_Installed_SW_UBUNTU;
else
	OSNAME="NULL";
fi