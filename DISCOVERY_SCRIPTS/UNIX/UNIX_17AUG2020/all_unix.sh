#!/bin/bash
##################################
#            
# RJIL
# JAM Project
# AUG-2020
# vimal.kumar@ril.com
# JAM Disocvery Script
# OS-Hardware script file
# Production-Version : 2.0

source /opt/ngoagent/JAM/Discovery/script/JAM_CONFIG.conf;

st_dt=$(date);

Disc_RHEL_OS_HW() 
{
    CMD1=`which dmidecode | head -1`;
	CMD2=`which free | head -1`;
	CMD3=`which ip | head -1`;
	#CMD4=`which ipcalc`;
	CMD5=`which parted | head -1`;
	
	os=`cat /etc/redhat-release | head -1`;
	OSVER=`echo $os|awk -F"release" '{print $2}' | awk -F" " '{print $1}'`;
	VAROS=`echo $os|awk -F"release" '{print $1}'|awk '{print $1}'`;
	OSNAME='RHEL';
	VER=`echo $os|awk -F"release" '{print $2}' | awk -F"." '{print $1}'`;
	VER="$((VER + 0))";
	
	ipv4=`$CMD3 addr |grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep  -v 127.0.0| tr '\n' ' '| sed 's/.$/ /' | awk '{print $1}'`;
	ipv6=`$CMD3 -6 addr  | grep "inet6 2405" | grep -v "scope global dynamic" | awk '{print $2}'|sed s'/...$//' |tr '\n' ' ' |awk '{print $1}'`;
	addipv4=`$CMD3 -4 addr | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep  -v 127.0.0|grep -v $ipv4 | tr '\n' ' '| sed 's/.$/ /'`;
	addipv6=`$CMD3 -6 addr  | grep "inet6 2405"| grep -v "scope global dynamic" | awk '{print $2}'|sed s'/...$//' |tr '\n' ' '`;
	addip="$ipv4 $ipv6 $addipv4 $addipv6";
	host=`hostname`;
	serial=`$CMD1 -t system |grep 'Serial Number' | awk -F':' '{print $2}'|sed 's/^ *//g'`;
	UUID=`$CMD1 -t system |grep 'UUID' | awk -F':' '{print $2}'|sed 's/^ *//g'`;
	
	make=`$CMD1 -t system | grep "Man" | awk -F':' '{print $2}'|sed 's/^ *//g'| awk -F',' '{print $1}'`;
	model=`$CMD1 -t system | grep "Product" | cut -d ":" -f 2|sed 's/^ *//g'`;
	ram=`$CMD2 -g | grep Mem  | awk '{print $2}'`;
	ram1=$(($ram+1));
	hdd=`$CMD5 -s unit GB -l | grep -i Disk | awk '{print $3}' | grep -v MB | cut -d 'G' -f 1 | awk '{sum+=$1}END{print sum}'`;
	cpu=`cat /proc/cpuinfo | grep processor | wc -l`;
	gateway=`$CMD3 route | grep -i default |awk  '{print $3}'`;
	macadd=`$CMD3 -o link|  awk '{print $2,$(NF-2)}' | grep -v "00:00:00:00:00:00"| sed 's/$/ /' | sed 's/: /->/' | tr '\n' ' '`;
	subnet=`$CMD3 addr | grep $ipv4 | awk '{print $2}' | head -1`;
	
	XX=`ifconfig -a|grep $ipv4`;
	if [[ "$XX" = *"Mask:"* ]]; then
		subnetmask=`echo $XX|awk -F"Mask:" '{print $2}'`;
	fi
	if [[ "$XX" = *"netmask"* ]]; then
		subnetmask=`echo $XX|awk -F"netmask" '{print $2}' | awk '{print $1}'`;
	fi

	CPUType=`/usr/bin/lscpu | grep -i 'Vendor ID'|awk '{print $3}'`;
	#Number of cores per socket
	CPUCore=`/usr/bin/lscpu | grep -i 'Core(s) per socket'|awk '{print $4}'`;
	CPUSpeed=`/usr/bin/lscpu | grep -i 'CPU MHz' | awk '{print $3}'`;
	CorePerCPU=`/usr/bin/lscpu |grep -i 'Thread(s) per core' | awk '{print $4}'`;
	CorePerSocket=`/usr/bin/lscpu | grep -i 'Core(s) per socket' | awk '{print $4}'`;
	SocketNumber=`/usr/bin/lscpu | grep -i 'Socket(s):' | awk -F: '{print $2}'`;
	SocketNumber="$((SocketNumber + 0))";
	
	#Disk
	NoOfDisk=`lsblk -d|grep -i disk|wc -l`;

	#physical or virtual
	DEVICE=`$CMD1 -s system-product-name |grep -i 'Virtual'|wc -l|awk '{if($1 >0) print "VIRTUAL"; else print "PHYSICAL"}'`;
	
	#BIOS info
	systemmanufacturer=`$CMD1 -s system-manufacturer`;
	systemproductname=`$CMD1 -s system-product-name`;
	biosreleasedate=`$CMD1 -s bios-release-date`;
	biosversion=`$CMD1 -s bios-version`;
	
	STMT='{';
	STMT=$STMT'"DESCRIPTOR":"OS_HW_DISCOVERY",';
	STMT=$STMT'"IPADDRESS":"'$ipv4'",';
	STMT=$STMT'"VALUES":[';
	STMT=$STMT'"DEVICETYPE|'$DEVICE'",';
	STMT=$STMT'"ADDITIONALIP|'$addip'",';
	STMT=$STMT'"SUBNETMASK|'$subnetmask'",';
	STMT=$STMT'"SUBNET|'$subnet'",';
	STMT=$STMT'"GATEWAY|'$gateway'",';
	STMT=$STMT'"MACADDRESS|'$macadd'",';
	STMT=$STMT'"HOSTNAME|'$host'",';
	STMT=$STMT'"SERIALNUMBER|'$serial'",';
	STMT=$STMT'"OPERATINGSYSTEM|'$os'",';
	STMT=$STMT'"OSSHORTNAME|'$OSNAME'",';
	STMT=$STMT'"OSVERSION|'$OSVER'",';
	STMT=$STMT'"MAKE|'$make'",';
	STMT=$STMT'"MODEL|'$model'",';
	STMT=$STMT'"RAM|'$ram1'",';
	STMT=$STMT'"NUMBEROFCPU|'$cpu'",';
	STMT=$STMT'"HARDDISKSIZEGB|'$hdd'",';
	STMT=$STMT'"CPUVENDOR|'$CPUType'",';
	STMT=$STMT'"CPUCOREPERSOCKET|'$CPUCore'",';
	STMT=$STMT'"CPUSPEEDMHZ|'$CPUSpeed'",';
	STMT=$STMT'"CPUTHREADPERCORE|'$CorePerCPU'",';
	STMT=$STMT'"COREPERSOCKET|'$CorePerSocket'",';
	STMT=$STMT'"NUMBEROFCPUSOCKET|'$SocketNumber'",';
	STMT=$STMT'"NUMBEROFHDD|'$NoOfDisk'",';
	STMT=$STMT'"UUID|'$UUID'",';
	STMT=$STMT'"BIOSMANUFACTURER|'$systemmanufacturer'",';
	STMT=$STMT'"BIOSPRODUCTNAME|'$systemproductname'",';
	STMT=$STMT'"BIOSRELEASEDATE|'$biosreleasedate'",';
	STMT=$STMT'"BIOSVERSION|'$biosversion'"';
	STMT=$STMT']';
	STMT=$STMT'}';
	echo $STMT;

	k=0;
	for i in "$DEVICE" "$ipv4" "$addip" "$subnetmask" "$subnet" "$gateway" "$macadd" "$host" "$serial" "$os" "$OSNAME" "$OSVER" "$make" "$model" "$ram1" "$cpu" "$hdd" "$CPUType" "$CPUCore" "$CPUSpeed" "$CorePerCPU" "$CorePerSocket" "$SocketNumber" "$NoOfDisk" "$UUID" "$systemmanufacturer" "$systemproductname" "$biosreleasedate" "$biosversion"
	do
		if [ ${#i} -gt 0 ]
		then
			k="$((k + 1))";
		fi
	done

	if [ $k -lt 29 ]
	then
		suc="FAILURE";
		typ="Script Execution is failed";
	fi
	if [ $k -eq 29 ]
	then
		suc="SUCCESS";
		typ="Script Execution is successfull";
	fi
	
	ed_dt=$(date);
	echo $st_dt,"OS_HW_DISCOVERY",$host,$ipv4,"INFO","Script Started" >> $STALOG
	echo $(date),"OS_HW_DISCOVERY",$host,$ipv4,$suc,$typ >> $STALOG
	echo $ed_dt,"OS_HW_DISCOVERY",$host,$ipv4,"INFO","Script output generated" >> $STALOG
}

Disc_CENT_OS_HW() 
{
	CMD1=`which dmidecode`;
	CMD2=`which free`;
	CMD3=`which ip`;
	#CMD4=`which ipcalc`;
	CMD5=`which parted`;
	
	os=`cat /etc/redhat-release | head -1`;
	OSVER=`echo $os|awk -F"release" '{print $2}' | awk -F" " '{print $1}'`;
	VAROS=`echo $os|awk -F"release" '{print $1}'|awk '{print $1}'`;
	OSNAME='CENT';
	VER=`echo $os|awk -F"release" '{print $2}' | awk -F"." '{print $1}'`;
	VER="$((VER + 0))";
	
	ipv4=`$CMD3 addr |grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep  -v 127.0.0| tr '\n' ' '| sed 's/.$/ /' | awk '{print $1}'`;
	ipv6=`$CMD3 -6 addr  | grep "inet6 2405" | grep -v "scope global dynamic" | awk '{print $2}'|sed s'/...$//' |tr '\n' ' ' |awk '{print $1}'`;
	addipv4=`$CMD3 -4 addr | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep  -v 127.0.0|grep -v $ipv4 | tr '\n' ' '| sed 's/.$/ /'`;
	addipv6=`$CMD3 -6 addr  | grep "inet6 2405"| grep -v "scope global dynamic" | awk '{print $2}'|sed s'/...$//' |tr '\n' ' '`;
	addip="$ipv4 $ipv6 $addipv4 $addipv6";
	host=`hostname`;
	serial=`$CMD1 -t system |grep 'Serial Number' | awk -F':' '{print $2}'|sed 's/^ *//g'`;
	UUID=`$CMD1 -t system |grep 'UUID' | awk -F':' '{print $2}'|sed 's/^ *//g'`;

	make=`$CMD1 -t system | grep "Man" | awk -F':' '{print $2}'|sed 's/^ *//g'| awk -F',' '{print $1}'`;
	model=`$CMD1 -t system | grep "Product" | cut -d ":" -f 2|sed 's/^ *//g'`;
	ram=`$CMD2 -g | grep Mem  | awk '{print $2}'`;
	ram1=$(($ram+1));
	hdd=`$CMD5 -s unit GB -l | grep -i Disk | awk '{print $3}' | grep -v MB | cut -d 'G' -f 1 | awk '{sum+=$1}END{print sum}'`;
	cpu=`cat /proc/cpuinfo | grep processor | wc -l`;
	gateway=`$CMD3 route | grep -i default |awk  '{print $3}'`;
	macadd=`$CMD3 -o link|  awk '{print $2,$(NF-2)}' | grep -v "00:00:00:00:00:00"| sed 's/$/ /' | sed 's/: /->/' | tr '\n' ' '`;
	subnet=`$CMD3 addr | grep $ipv4 | awk '{print $2}' | head -1`;
	
	XX=`ifconfig -a|grep $ipv4`
	if [[ "$XX" = *"Mask:"* ]]; then
		subnetmask=`echo $XX|awk -F"Mask:" '{print $2}'`;
	fi
	if [[ "$XX" = *"netmask"* ]]; then
		subnetmask=`echo $XX|awk -F"netmask" '{print $2}' | awk '{print $1}'`;
	fi

	CPUType=`/usr/bin/lscpu | grep -i 'Vendor ID'|awk '{print $3}'`;
	#Number of cores per socket
	CPUCore=`/usr/bin/lscpu | grep -i 'Core(s) per socket'|awk '{print $4}'`;
	CPUSpeed=`/usr/bin/lscpu | grep -i 'CPU MHz' | awk '{print $3}'`;
	CorePerCPU=`/usr/bin/lscpu |grep -i 'Thread(s) per core' | awk '{print $4}'`;
	CorePerSocket=`/usr/bin/lscpu | grep -i 'Core(s) per socket' | awk '{print $4}'`;
	SocketNumber=`/usr/bin/lscpu | grep -i 'Socket(s):' | awk -F: '{print $2}'`;
	SocketNumber="$((SocketNumber + 0))";
	
	#Disk
	NoOfDisk=`lsblk -d|grep -i disk|wc -l`;

	#physical or virtual
	DEVICE=`$CMD1 -s system-product-name |grep -i 'Virtual'|wc -l|awk '{if($1 >0) print "VIRTUAL"; else print "PHYSICAL"}'`;
	
	#BIOS info
	systemmanufacturer=`$CMD1 -s system-manufacturer`;
	systemproductname=`$CMD1 -s system-product-name`;
	biosreleasedate=`$CMD1 -s bios-release-date`;
	biosversion=`$CMD1 -s bios-version`;
	
	STMT='{';
	STMT=$STMT'"DESCRIPTOR":"OS_HW_DISCOVERY",';
	STMT=$STMT'"IPADDRESS":"'$ipv4'",';
	STMT=$STMT'"VALUES":[';
	STMT=$STMT'"DEVICETYPE|'$DEVICE'",';
	STMT=$STMT'"ADDITIONALIP|'$addip'",';
	STMT=$STMT'"SUBNETMASK|'$subnetmask'",';
	STMT=$STMT'"SUBNET|'$subnet'",';
	STMT=$STMT'"GATEWAY|'$gateway'",';
	STMT=$STMT'"MACADDRESS|'$macadd'",';
	STMT=$STMT'"HOSTNAME|'$host'",';
	STMT=$STMT'"SERIALNUMBER|'$serial'",';
	STMT=$STMT'"OPERATINGSYSTEM|'$os'",';
	STMT=$STMT'"OSSHORTNAME|'$OSNAME'",';
	STMT=$STMT'"OSVERSION|'$OSVER'",';
	STMT=$STMT'"MAKE|'$make'",';
	STMT=$STMT'"MODEL|'$model'",';
	STMT=$STMT'"RAM|'$ram1'",';
	STMT=$STMT'"NUMBEROFCPU|'$cpu'",';
	STMT=$STMT'"HARDDISKSIZEGB|'$hdd'",';
	STMT=$STMT'"CPUVENDOR|'$CPUType'",';
	STMT=$STMT'"CPUCOREPERSOCKET|'$CPUCore'",';
	STMT=$STMT'"CPUSPEEDMHZ|'$CPUSpeed'",';
	STMT=$STMT'"CPUTHREADPERCORE|'$CorePerCPU'",';
	STMT=$STMT'"COREPERSOCKET|'$CorePerSocket'",';
	STMT=$STMT'"NUMBEROFCPUSOCKET|'$SocketNumber'",';
	STMT=$STMT'"NUMBEROFHDD|'$NoOfDisk'",';
	STMT=$STMT'"UUID|'$UUID'",';
	STMT=$STMT'"BIOSMANUFACTURER|'$systemmanufacturer'",';
	STMT=$STMT'"BIOSPRODUCTNAME|'$systemproductname'",';
	STMT=$STMT'"BIOSRELEASEDATE|'$biosreleasedate'",';
	STMT=$STMT'"BIOSVERSION|'$biosversion'"';
	STMT=$STMT']';
	STMT=$STMT'}';
	echo $STMT;

	k=0;
	for i in "$DEVICE" "$ipv4" "$addip" "$subnetmask" "$subnet" "$gateway" "$macadd" "$host" "$serial" "$os" "$OSNAME" "$OSVER" "$make" "$model" "$ram1" "$cpu" "$hdd" "$CPUType" "$CPUCore" "$CPUSpeed" "$CorePerCPU" "$CorePerSocket" "$SocketNumber" "$NoOfDisk" "$UUID" "$systemmanufacturer" "$systemproductname" "$biosreleasedate" "$biosversion"
	do
		if [ ${#i} -gt 0 ]
		then
			k="$((k + 1))";
		fi
	done

	if [ $k -lt 29 ]
	then
		suc="FAILURE";
		typ="Script Execution is failed";
	fi
	if [ $k -eq 29 ]
	then
		suc="SUCCESS";
		typ="Script Execution is successfull";
	fi
	
	ed_dt=$(date);
	echo $st_dt,"OS_HW_DISCOVERY",$host,$ipv4,"INFO","Script Started" >> $STALOG;
	echo $(date),"OS_HW_DISCOVERY",$host,$ipv4,$suc,$typ >> $STALOG;
	echo $ed_dt,"OS_HW_DISCOVERY",$host,$ipv4,"INFO","Script output generated" >> $STALOG;
}


Disc_SUSE_OS_HW() 
{
	CMD1=`which dmidecode`;
	CMD2=`which free`;
	CMD3=`which ip`;
	#CMD4=`which ipcalc`;
	CMD5=`which parted`;
	
	os=`cat /etc/SuSE-release | head -1`;
	OSVER=`cat /etc/SuSE-release|grep -i version | awk -F"VERSION =" '{print $2}' |awk '{print $1}'`;
	VAROS=`echo $os|awk -F"release" '{print $1}'|awk '{print $1}'`;
	OSNAME='SUSE';
	VER=`echo $os|grep -i version | awk -F"VERSION =" '{print $2}' |awk '{print $1}'`;
	VER="$((VER + 0))";

	ipv4=`$CMD3 addr |grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep  -v 127.0.0| tr '\n' ' '| sed 's/.$/ /' | awk '{print $1}'`;
	ipv6=`$CMD3 -6 addr  | grep "inet6 2405" | grep -v "scope global dynamic" | awk '{print $2}'|sed s'/...$//' |tr '\n' ' ' |awk '{print $1}'`;
	addipv4=`$CMD3 -4 addr | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep  -v 127.0.0|grep -v $ipv4 | tr '\n' ' '| sed 's/.$/ /'`;
	addipv6=`$CMD3 -6 addr  | grep "inet6 2405"| grep -v "scope global dynamic" | awk '{print $2}'|sed s'/...$//' |tr '\n' ' '`;
	addip="$ipv4 $ipv6 $addipv4 $addipv6";
	host=`hostname`;
	serial=`$CMD1 -t system |grep 'Serial Number' | awk -F':' '{print $2}'|sed 's/^ *//g'`;
	UUID=`$CMD1 -t system |grep 'UUID' | awk -F':' '{print $2}'|sed 's/^ *//g'`;

	make=`$CMD1 -t system | grep "Man" | awk -F':' '{print $2}'|sed 's/^ *//g'| awk -F',' '{print $1}'`;
	model=`$CMD1 -t system | grep "Product" | cut -d ":" -f 2|sed 's/^ *//g'`;
	ram=`$CMD2 -g | grep Mem  | awk '{print $2}'`;
	ram1=$(($ram+1));
	hdd=`$CMD5 -s unit GB -l | grep -i Disk | awk '{print $3}' | grep -v MB | cut -d 'G' -f 1 | awk '{sum+=$1}END{print sum}'`;
	cpu=`cat /proc/cpuinfo | grep processor | wc -l`;
	gateway=`$CMD3 route | grep -i default |awk  '{print $3}'`;
	macadd=`$CMD3 -o link|  awk '{print $2,$(NF-2)}' | grep -v "00:00:00:00:00:00"| sed 's/$/ /' | sed 's/: /->/' | tr '\n' ' '`;
	subnet=`$CMD3 addr | grep $ipv4 | awk '{print $2}' | head -1`;
	
	XX=`ifconfig -a|grep $ipv4`
	if [[ "$XX" = *"Mask:"* ]]; then
		subnetmask=`echo $XX|awk -F"Mask:" '{print $2}'`
	fi
	if [[ "$XX" = *"netmask"* ]]; then
		subnetmask=`echo $XX|awk -F"netmask" '{print $2}' | awk '{print $1}'`
	fi
	
	CPUType=`/usr/bin/lscpu | grep -i 'Vendor ID'|awk '{print $3}'`;
	#Number of cores per socket
	CPUCore=`/usr/bin/lscpu | grep -i 'Core(s) per socket'|awk '{print $4}'`;
	CPUSpeed=`/usr/bin/lscpu | grep -i 'CPU MHz' | awk '{print $3}'`;
	CorePerCPU=`/usr/bin/lscpu |grep -i 'Thread(s) per core' | awk '{print $4}'`;
	CorePerSocket=`/usr/bin/lscpu | grep -i 'Core(s) per socket' | awk '{print $4}'`;
	SocketNumber=`/usr/bin/lscpu | grep -i 'Socket(s):' | awk -F: '{print $2}'`;
	SocketNumber="$((SocketNumber + 0))";

	#Disk
	NoOfDisk=`lsblk -d|grep -i disk|wc -l`;

	#physical or virtual
	DEVICE=`$CMD1 -s system-product-name |grep -i 'Virtual'|wc -l|awk '{if($1 >0) print "VIRTUAL"; else print "PHYSICAL"}'`;
	
	#BIOS info
	systemmanufacturer=`$CMD1 -s system-manufacturer`;
	systemproductname=`$CMD1 -s system-product-name`;
	biosreleasedate=`$CMD1 -s bios-release-date`;
	biosversion=`$CMD1 -s bios-version`;

    STMT='{';
	STMT=$STMT'"DESCRIPTOR":"OS_HW_DISCOVERY",';
	STMT=$STMT'"IPADDRESS":"'$ipv4'",';
	STMT=$STMT'"VALUES":[';
	STMT=$STMT'"DEVICETYPE|'$DEVICE'",';
	STMT=$STMT'"ADDITIONALIP|'$addip'",';
	STMT=$STMT'"SUBNETMASK|'$subnetmask'",';
	STMT=$STMT'"SUBNET|'$subnet'",';
	STMT=$STMT'"GATEWAY|'$gateway'",';
	STMT=$STMT'"MACADDRESS|'$macadd'",';
	STMT=$STMT'"HOSTNAME|'$host'",';
	STMT=$STMT'"SERIALNUMBER|'$serial'",';
	STMT=$STMT'"OPERATINGSYSTEM|'$os'",';
	STMT=$STMT'"OSSHORTNAME|'$OSNAME'",';
	STMT=$STMT'"OSVERSION|'$OSVER'",';
	STMT=$STMT'"MAKE|'$make'",';
	STMT=$STMT'"MODEL|'$model'",';
	STMT=$STMT'"RAM|'$ram1'",';
	STMT=$STMT'"NUMBEROFCPU|'$cpu'",';
	STMT=$STMT'"HARDDISKSIZEGB|'$hdd'",';
	STMT=$STMT'"CPUVENDOR|'$CPUType'",';
	STMT=$STMT'"CPUCOREPERSOCKET|'$CPUCore'",';
	STMT=$STMT'"CPUSPEEDMHZ|'$CPUSpeed'",';
	STMT=$STMT'"CPUTHREADPERCORE|'$CorePerCPU'",';
	STMT=$STMT'"COREPERSOCKET|'$CorePerSocket'",';
	STMT=$STMT'"NUMBEROFCPUSOCKET|'$SocketNumber'",';
	STMT=$STMT'"NUMBEROFHDD|'$NoOfDisk'",';
	STMT=$STMT'"UUID|'$UUID'",';
	STMT=$STMT'"BIOSMANUFACTURER|'$systemmanufacturer'",';
	STMT=$STMT'"BIOSPRODUCTNAME|'$systemproductname'",';
	STMT=$STMT'"BIOSRELEASEDATE|'$biosreleasedate'",';
	STMT=$STMT'"BIOSVERSION|'$biosversion'"';
	STMT=$STMT']';
	STMT=$STMT'}';
	echo $STMT;

	k=0;
	for i in "$DEVICE" "$ipv4" "$addip" "$subnetmask" "$subnet" "$gateway" "$macadd" "$host" "$serial" "$os" "$OSNAME" "$OSVER" "$make" "$model" "$ram1" "$cpu" "$hdd" "$CPUType" "$CPUCore" "$CPUSpeed" "$CorePerCPU" "$CorePerSocket" "$SocketNumber" "$NoOfDisk" "$UUID" "$systemmanufacturer" "$systemproductname" "$biosreleasedate" "$biosversion"
	do
		if [ ${#i} -gt 0 ]
		then
			k="$((k + 1))";
		fi
	done

	if [ $k -lt 29 ]
	then
		suc="FAILURE";
		typ="Script Execution is failed";
	fi
	if [ $k -eq 29 ]
	then
		suc="SUCCESS";
		typ="Script Execution is successfull";
	fi

	ed_dt=$(date);
	echo $st_dt,"OS_HW_DISCOVERY",$host,$ipv4,"INFO","Script Started" >> $STALOG
	echo $(date),"OS_HW_DISCOVERY",$host,$ipv4,$suc,$typ >> $STALOG
	echo $ed_dt,"OS_HW_DISCOVERY",$host,$ipv4,"INFO","Script output generated" >> $STALOG
}


Disc_UBUNTU_OS_HW() 
{
	CMD1=`which dmidecode`;
	CMD2=`which free`;
	CMD3=`which ip`;
	#CMD4=`which ipcalc`;
	CMD5=`which parted`;
	
	os=`lsb_release -d | cut -d':' -f2 | head -1`;
	OSVER=`echo $os| awk '{print $2 }'`;
	VAROS=`echo $os|awk -F"release" '{print $1}'|awk '{print $1}'`;
	OSNAME='UBUNTU';
	VER=`echo $os| awk '{print $2 }'|awk -F"." '{print $1}'`;
	VER="$((VER + 0))";

	ipv4=`$CMD3 addr |grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep  -v 127.0.0| tr '\n' ' '| sed 's/.$/ /' | awk '{print $1}'`;
	ipv6=`$CMD3 -6 addr  | grep "inet6 2405" | grep -v "scope global dynamic" | awk '{print $2}'|sed s'/...$//' |tr '\n' ' ' |awk '{print $1}'`;
	addipv4=`$CMD3 -4 addr | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep  -v 127.0.0|grep -v $ipv4 | tr '\n' ' '| sed 's/.$/ /'`;
	addipv6=`$CMD3 -6 addr  | grep "inet6 2405"| grep -v "scope global dynamic" | awk '{print $2}'|sed s'/...$//' |tr '\n' ' '`;
	addip="$ipv4 $ipv6 $addipv4 $addipv6";
	host=`hostname`;
	serial=`$CMD1 -t system |grep 'Serial Number' | awk -F':' '{print $2}'|sed 's/^ *//g'`;
	UUID=`$CMD1 -t system |grep 'UUID' | awk -F':' '{print $2}'|sed 's/^ *//g'`;
	
	make=`$CMD1 -t system | grep "Man" | awk -F':' '{print $2}'|sed 's/^ *//g'| awk -F',' '{print $1}'`;
	model=`$CMD1 -t system | grep "Product" | cut -d ":" -f 2|sed 's/^ *//g'`;
	ram=`$CMD2 -g | grep Mem  | awk '{print $2}'`;
	ram1=$(($ram+1));
	hdd=`$CMD5 -s unit GB -l | grep -i Disk | awk '{print $3}' | grep -v MB | cut -d 'G' -f 1 | awk '{sum+=$1}END{print sum}'`;
	cpu=`cat /proc/cpuinfo | grep processor | wc -l`;
	gateway=`$CMD3 route | grep -i default |awk  '{print $3}'`;
	macadd=`$CMD3 -o link|  awk '{print $2,$(NF-2)}' | grep -v "00:00:00:00:00:00"| sed 's/$/ /' | sed 's/: /->/' | tr '\n' ' '`;
	subnet=`$CMD3 addr | grep $ipv4 | awk '{print $2}' | head -1`;
	
	XX=`ifconfig -a|grep $ipv4`
	if [[ "$XX" = *"Mask:"* ]]; then
		subnetmask=`echo $XX|awk -F"Mask:" '{print $2}'`
	fi
	if [[ "$XX" = *"netmask"* ]]; then
		subnetmask=`echo $XX|awk -F"netmask" '{print $2}' | awk '{print $1}'`
	fi
	
	CPUType=`/usr/bin/lscpu | grep -i 'Vendor ID'|awk '{print $3}'`;
	#Number of cores per socket;
	CPUCore=`/usr/bin/lscpu | grep -i 'Core(s) per socket'|awk '{print $4}'`;
	CPUSpeed=`/usr/bin/lscpu | grep -i 'CPU MHz' | awk '{print $3}'`;
	CorePerCPU=`/usr/bin/lscpu |grep -i 'Thread(s) per core' | awk '{print $4}'`;
	CorePerSocket=`/usr/bin/lscpu | grep -i 'Core(s) per socket' | awk '{print $4}'`;
	SocketNumber=`/usr/bin/lscpu | grep -i 'Socket(s):' | awk -F: '{print $2}'`;
	SocketNumber="$((SocketNumber + 0))";
	
	#Disk
	NoOfDisk=`lsblk -d|grep -i disk|wc -l`;

	#physical or virtual
	DEVICE=`$CMD1 -s system-product-name |grep -i 'Virtual'|wc -l|awk '{if($1 >0) print "VIRTUAL"; else print "PHYSICAL"}'`;

	#BIOS info
	systemmanufacturer=`$CMD1 -s system-manufacturer`;
	systemproductname=`$CMD1 -s system-product-name`;
	biosreleasedate=`$CMD1 -s bios-release-date`;
	biosversion=`$CMD1 -s bios-version`;
	
	STMT='{';
	STMT=$STMT'"DESCRIPTOR":"OS_HW_DISCOVERY",';
	STMT=$STMT'"IPADDRESS":"'$ipv4'",';
	STMT=$STMT'"VALUES":[';
	STMT=$STMT'"DEVICETYPE|'$DEVICE'",';
	STMT=$STMT'"ADDITIONALIP|'$addip'",';
	STMT=$STMT'"SUBNETMASK|'$subnetmask'",';
	STMT=$STMT'"SUBNET|'$subnet'",';
	STMT=$STMT'"GATEWAY|'$gateway'",';
	STMT=$STMT'"MACADDRESS|'$macadd'",';
	STMT=$STMT'"HOSTNAME|'$host'",';
	STMT=$STMT'"SERIALNUMBER|'$serial'",';
	STMT=$STMT'"OPERATINGSYSTEM|'$os'",';
	STMT=$STMT'"OSSHORTNAME|'$OSNAME'",';
	STMT=$STMT'"OSVERSION|'$OSVER'",';
	STMT=$STMT'"MAKE|'$make'",';
	STMT=$STMT'"MODEL|'$model'",';
	STMT=$STMT'"RAM|'$ram1'",';
	STMT=$STMT'"NUMBEROFCPU|'$cpu'",';
	STMT=$STMT'"HARDDISKSIZEGB|'$hdd'",';
	STMT=$STMT'"CPUVENDOR|'$CPUType'",';
	STMT=$STMT'"CPUCOREPERSOCKET|'$CPUCore'",';
	STMT=$STMT'"CPUSPEEDMHZ|'$CPUSpeed'",';
	STMT=$STMT'"CPUTHREADPERCORE|'$CorePerCPU'",';
	STMT=$STMT'"COREPERSOCKET|'$CorePerSocket'",';
	STMT=$STMT'"NUMBEROFCPUSOCKET|'$SocketNumber'",';
	STMT=$STMT'"NUMBEROFHDD|'$NoOfDisk'",';
	STMT=$STMT'"UUID|'$UUID'",';
	STMT=$STMT'"BIOSMANUFACTURER|'$systemmanufacturer'",';
	STMT=$STMT'"BIOSPRODUCTNAME|'$systemproductname'",';
	STMT=$STMT'"BIOSRELEASEDATE|'$biosreleasedate'",';
	STMT=$STMT'"BIOSVERSION|'$biosversion'"';
	STMT=$STMT']';
	STMT=$STMT'}';
	echo $STMT;
	
	k=0;
	for i in "$DEVICE" "$ipv4" "$addip" "$subnetmask" "$subnet" "$gateway" "$macadd" "$host" "$serial" "$os" "$OSNAME" "$OSVER" "$make" "$model" "$ram1" "$cpu" "$hdd" "$CPUType" "$CPUCore" "$CPUSpeed" "$CorePerCPU" "$CorePerSocket" "$SocketNumber" "$NoOfDisk" "$UUID" "$systemmanufacturer" "$systemproductname" "$biosreleasedate" "$biosversion"
	do
		if [ ${#i} -gt 0 ]
		then
			k="$((k + 1))";
		fi
	done

	if [ $k -lt 29 ]
	then
		suc="FAILURE";
		typ="Script Execution is failed";
	fi
	if [ $k -eq 29 ]
	then
		suc="SUCCESS";
	typ="Script Execution is successfull";
	fi
	
	ed_dt=$(date);
	echo $st_dt,"OS_HW_DISCOVERY",$host,$ipv4,"INFO","Script Started" >> $STALOG
	echo $(date),"OS_HW_DISCOVERY",$host,$ipv4,$suc,$typ >> $STALOG
	echo $ed_dt,"OS_HW_DISCOVERY",$host,$ipv4,"INFO","Script output generated" >> $STALOG
}


CMD1=`which dmidecode | head -1`;
CMD2=`which free | head -1`;
CMD3=`which ip | head -1`;
#CMD4=`which ipcalc`;
CMD5=`which parted | head -1`;

if [ -f /etc/redhat-release ]; then
        os=`cat /etc/redhat-release`
elif [ -f  /etc/SuSE-release ]; then
        os=`cat /etc/SuSE-release`
else
        os=`lsb_release -d | cut -d':' -f2`
fi

VAROS=`echo $os|awk -F"release" '{print $1}'|awk '{print $1}'`

if [ "$VAROS" = "Red" ]; then
OSNAME='RHEL';
elif [ "$VAROS" = "CentOS" ]; then
OSNAME='CENT';
elif [ "$VAROS" = "SUSE" ]; then
OSNAME='SUSE';
elif [ "$VAROS" = "Ubuntu" ]; then
OSNAME='UBUNTU';
else
OSNAME='NULL';
fi

#mysql_db="$((mysql_db + 0))"
if [ "$OSNAME" = "RHEL" ]; then
    Disc_RHEL_OS_HW;
elif [ "$OSNAME" = "CENT" ]; then
    Disc_CENT_OS_HW;
elif [ "$OSNAME" = "SUSE" ]; then
    Disc_SUSE_OS_HW;
elif [ "$OSNAME" = "UBUNTU" ]; then
    Disc_UBUNTU_OS_HW;
else
	echo "No Unix OS";
fi




