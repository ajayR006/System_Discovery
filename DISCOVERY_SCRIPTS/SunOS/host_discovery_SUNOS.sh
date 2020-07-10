#!/bin/bash
#set -x
source /opt/ngoagent/JAM/Discovery/script/JAM_CONFIG.conf;

st_dt=$(date);

CMD1=`which prtconf`;
CMD2=`which sneep`;
CMD3=`which prtdiag`;
CMD4=`which ifconfig`;
CMD5=`which uname`;

ipv4=`$CMD4 -a | awk '/flags/ {printf $1" "} /inet/ {print $2}' | grep -v lo | head -1 | awk -F':' '{print $2}' | sed 's/^ *//g'`
host=`hostname`
serial=`$CMD2 -t serial`

VR=`$CMD3 -v | grep -i "System Configuration" | grep -i virtual`
if [[ $? -eq 0 ]]
then
 DEVICE="VIRTUAL";
else
 DEVICE="PHYSICAL";
fi

os=`$CMD5 -a | awk '{print $1 " " $4}'|awk '{print $1}'`
VER=`$CMD5 -a | awk '{print $1 " " $4}'|awk '{print $2}'`
MAKE=`$CMD3 -v | grep 'System'| awk -F':' '{print $2}' |awk '{print $1, $2}'`
MODEL=`$CMD3 -v | grep 'System'| awk -F':' '{print $2}' |awk '{print $3,$4,$5}'`

ram=`$CMD1 | grep Mem | awk -F':' '{print $2}' | sed 's/^ *//g' | awk '{print $1}'`
ram=$(($ram/1024))
ADDIP=`$CMD4 -a|grep -i "inet" |grep -i "netmask" |grep -v "127" |grep -v "0.0.0.0" | awk '{print $2}' | grep -v $ipv4 | tr "\n" ' ' `
SUBNETV=`ifconfig -a |grep $ipv4|grep "broadcast"|awk '{print $4}'`

if [[ $SUBNETV == '80000000' ]]
then
    SUBNET=$ipv4"/1";
    SUBMASK="128.0.0.0";
elif [[ $SUBNETV == 'c0000000' ]]
then
    SUBNET=$ipv4"/2";
    SUBMASK="192.0.0.0";
elif [[ $SUBNETV == 'e0000000' ]]
then
    SUBNET=$ipv4"/3";
    SUBMASK="224.0.0.0";
elif [[ $SUBNETV == 'f0000000' ]]
then
    SUBNET=$ipv4"/4";
    SUBMASK="240.0.0.0";
elif [[ $SUBNETV == 'f8000000' ]]
then
    SUBNET=$ipv4"/5";
    SUBMASK="248.0.0.0";
elif [[ $SUBNETV == 'fc000000' ]]
then
    SUBNET=$ipv4"/6";
    SUBMASK="252.0.0.0";
elif [[ $SUBNETV == 'fe000000' ]]
then
    SUBNET=$ipv4"/7";
    SUBMASK="254.0.0.0";
elif [[ $SUBNETV == 'ff000000' ]]
then
    SUBNET=$ipv4"/8";
    SUBMASK="255.0.0.0";
elif [[ $SUBNETV == 'ff800000' ]]
then
    SUBNET=$ipv4"/9";
    SUBMASK="255.128.0.0";
elif [[ $SUBNETV == 'ffc00000' ]]
then
    SUBNET=$ipv4"/10";
    SUBMASK="255.192.0.0";
elif [[ $SUBNETV == 'ffe00000' ]]
then
    SUBNET=$ipv4"/11";
    SUBMASK="255.224.0.0";
elif [[ $SUBNETV == 'fff00000' ]]
then
    SUBNET=$ipv4"/12";
    SUBMASK="255.240.0.0";
elif [[ $SUBNETV == 'fff80000' ]]
then
    SUBNET=$ipv4"/13";
    SUBMASK="255.248.0.0";
elif [[ $SUBNETV == 'fffc0000' ]]
then
    SUBNET=$ipv4"/14";
    SUBMASK="255.252.0.0";
elif [[ $SUBNETV == 'fffe0000' ]]
then
    SUBNET=$ipv4"/15";
    SUBMASK="255.254.0.0";
elif [[ $SUBNETV == 'ffff0000' ]]
then
    SUBNET=$ipv4"/16";
    SUBMASK="255.255.0.0";
elif [[ $SUBNETV == 'ffff8000' ]]
then
    SUBNET=$ipv4"/17";
    SUBMASK="255.255.128.0";
elif [[ $SUBNETV == 'ffffc000' ]]
then
    SUBNET=$ipv4"/18";
    SUBMASK="255.255.192.0";
elif [[ $SUBNETV == 'ffffe000' ]]
then
    SUBNET=$ipv4"/19";
    SUBMASK="255.255.224.0";
elif [[ $SUBNETV == 'fffff000' ]]
then
    SUBNET=$ipv4"/20";
    SUBMASK="255.255.240.0";
elif [[ $SUBNETV == 'fffff800' ]]
then
    SUBNET=$ipv4"/21";
    SUBMASK="255.255.248.0";
elif [[ $SUBNETV == 'fffffc00' ]]
then
    SUBNET=$ipv4"/22";
    SUBMASK="255.255.252.0";
elif [[ $SUBNETV == 'fffffe00' ]]
then
    SUBNET=$ipv4"/23";
    SUBMASK="255.255.254.0";
elif [[ $SUBNETV == 'ffffff00' ]]
then
    SUBNET=$ipv4"/24";
    SUBMASK="255.255.255.0";
elif [[ $SUBNETV == 'ffffff80' ]]
then
    SUBNET=$ipv4"/25";
    SUBMASK="255.255.255.128";
elif [[ $SUBNETV == 'ffffffc0' ]]
then
    SUBNET=$ipv4"/26";
    SUBMASK="255.255.255.192";
elif [[ $SUBNETV == 'ffffffe0' ]]
then
    SUBNET=$ipv4"/27";
    SUBMASK="255.255.255.224";
elif [[ $SUBNETV == 'fffffff0' ]]
then
    SUBNET=$ipv4"/28";
    SUBMASK="255.255.255.240";
elif [[ $SUBNETV == 'fffffff8' ]]
then
    SUBNET=$ipv4"/29";
    SUBMASK="255.255.255.248";
elif [[ $SUBNETV == 'fffffffc' ]]
then
    SUBNET=$ipv4"/30";
    SUBMASK="255.255.255.252";
elif [[ $SUBNETV == 'fffffffe' ]]
then
    SUBNET=$ipv4"/31";
    SUBMASK="255.255.255.254";
elif [[ $SUBNETV == 'ffffffff' ]]
then
    SUBNET=$ipv4"/32";
    SUBMASK="255.255.255.255";
else
    SUBNET="":
    SUBMASK="";
fi


procInfo=$(psrinfo -pv)
             cpus=$(($(echo "$procInfo"|grep "physical processor"| wc -l)+0))
             cores=$(echo "$procInfo"|grep "physical processor"|awk 'BEGIN {t = 0;}{t += $5;} END {print t;}')
             ck4cores=$(echo "$procInfo"|grep 'cores')
             if [ -z "$ck4cores" ]
             then
                threads=$cores
             else
                threads=$(echo "$procInfo"|grep "physical processor"|awk 'BEGIN {t = 0;}{t += $8;} END {print t;}')
             fi
             cpuSpeed=$(psrinfo -pv|grep clock|uniq|head -1|sed -e "s/^.*clock//g" -e "s/)//g" -e "s/^ //g")
             cpuType="$(prtconf|head -5|tail -1)"
#echo "CPU No: "$cpus;
#echo "CPU Cores: "$cores;
#echo "CPU Threads: "$threads;
#echo "CPU Speed: "$cpuSpeed;
#echo "CPU Type: "$cpuType;
#echo '';
SocketNumber=`psrinfo -p`
hddsize=`zpool list|awk '{print $2}'|tail -1`;
UUID=`virtinfo -u |awk -F':' '{print $2}'| sed 's/^ *//g'`;


#CPU=`psrinfo -v | grep ^Status | tail -1 | awk '{x = $5 + 1; print x;}'`;
#CorePerSocket=`/usr/bin/kstat -m cpu_info | grep ncpu_per_chip | awk '{print $2}' | sort -u`
#CorePerSocket=`kstat cpu_info|grep core_id|sort -u|wc -l`
#CorePerCPU=`/usr/bin/kstat -m cpu_info | grep ncore_per_chip | awk '{print $2}' | sort -u`
#CorePerCPU=`kstat cpu_info|grep core_id|sort -u|wc -l`


#nproc=`(/usr/bin/kstat -m cpu_info | grep chip_id | sort -u | wc -l | tr -d ' ')`
#vproc=`(/usr/bin/kstat -m cpu_info | grep 'module: cpu_info' | sort -u | wc -l | tr -d ' ')`
#ncore=`(/usr/bin/kstat -m cpu_info | grep core_id | sort -u | wc -l | tr -d ' ')`
#echo "Total number of physical processors: $nproc"
#echo "Number of virtual processors: $vproc"
#echo "Total number of cores: $ncore"
#echo "Number of cores per physical processor: $(($ncore/$nproc))"
#echo "Number of hardware threads (strands) per core: $(($vproc/$ncore))"


ar1=$(ifconfig -a | grep -v LOOPBACK | grep -v IPv6 | grep -v inet | grep -v ether | grep -vi groupname | cut -d':' -f1 | sed 's/^ *//g')
for x in $ar1;do
m=`ifconfig $x | grep -i ether | awk '{print $2}'`
temp="$x => $m"
macadd="$macadd $temp"
n=`ifconfig $x | grep netmask | awk '{print $4}'`
netm=`printf '%d.%d.%d.%d\n' $(echo $n | sed 's/../0x& /g')`
temp1="$x => $netm"
subnet="$netm"

v6=`ifconfig net0 inet6 | grep inet6 | grep -v "::"`
if [ -z "$v6" ]
then
:
else
temp1="$v6"
IPv6="$IPv6 $temp1"
fi
done

#CLY=`prtvtoc /dev/rdsk/$1| grep "accessible"| cut -d"*" -f2| sed 's/^[ \t]*//'| cut -d" " -f1`
#SEC=`prtvtoc /dev/rdsk/$1| grep "sectors/cylinder"| cut -d"*" -f2| sed 's/^[ \t]*//'| cut -d" " -f1`
#BYT=`prtvtoc /dev/rdsk/$1| grep "bytes/sector"| cut -d"*" -f2| sed 's/^[ \t]*//'| cut -d" " -f1`
#SIZ=$((CLY*SEC*BYT))
#hdd=`iostat -E | grep Size | awk -F':' '{print $2}' | sed 's/^ *//g' | cut -d'.' -f 1 | awk '{sum+=$1}END{print sum}'`
#NoOfDisk=`iostat -E | grep 'disk' | wc -l | sed 's/^ *//g'`
#gateway=`netstat -rn | grep default | awk '{print $2}'`
#CPUVendor=`kstat cpu_info | grep vendor_id | head -1|awk '{print $2}'`
#cpuc=`kstat cpu_info | grep instance | tail -1 | awk '{print $4}'`
#CPUCore=$(($cpuc+1))

#echo  $NoOfDisk, $SocketNumber, $CorePerSocket, $CorePerCPU, $CPUType, $cpus, $CPUSpeed;

gateway=`netstat -rn | grep default | awk '{print $2}'`;
systemmanufacturer='';
systemproductname='';
biosreleasedate='';
biosversion='';

STMT='{';
STMT=$STMT'"DESCRIPTOR":"OS_HW_DISCOVERY",';
STMT=$STMT'"IPADDRESS":"'$ipv4'",';
STMT=$STMT'"VALUES":[';
STMT=$STMT'"DEVICETYPE|'$DEVICE'",';
STMT=$STMT'"ADDITIONALIP|'$ADDIP'",';
STMT=$STMT'"SUBNETMASK|'$SUBMASK'",';
STMT=$STMT'"SUBNET|'$SUBNET'",';
STMT=$STMT'"GATEWAY|'$gateway'",';
STMT=$STMT'"MACADDRESS|'$macadd'",';
STMT=$STMT'"HOSTNAME|'$host'",';
STMT=$STMT'"SERIALNUMBER|'$serial'",';
STMT=$STMT'"OPERATINGSYSTEM|'$os'",';
STMT=$STMT'"OSSHORTNAME|'$os'",';
STMT=$STMT'"OSVERSION|'$VER'",';
STMT=$STMT'"MODEL|'$MODEL'",';
STMT=$STMT'"RAM|'$ram'",';
STMT=$STMT'"NUMBEROFCPU|'$cpus'",';
STMT=$STMT'"HARDDISKSIZEGB|'$hddsize'",';
STMT=$STMT'"CPUVENDOR|'$cpuType'",';
STMT=$STMT'"CPUSPEEDMHZ|'$cpuSpeed'",';
STMT=$STMT'"CPUTHREADPERCORE|'$threads'",';
STMT=$STMT'"COREPERSOCKET|'$cores'",';
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


#echo "IP_Address,Additional IP,SubnetMask,MAC Address,Default gateway,Hostname,Serial_Number,Operating_System,Make,Model,RAM(GB),Total HardDisk(GB),No. of CPU,CPU Speed,No CPU per Socket,No of cores per CPU,CPU Vendor" >  /tmp/serverinfo_"$ip".csv

k=0;
for i in "$DEVICE" "$ipv4" "$ADDIP" "$SUBMASK" "$SUBNET" "$gateway" "$macadd" "$host" "$serial" "$os" "$os" "$VER" "$MAKE" "$MODEL" "$ram" "$cpus" "$hddsize" "$cpuType" "$cores" "$cpuSpeed" "$threads" "$cores" "$SocketNumber" "$NoOfDisk" "$UUID" "$systemmanufacturer" "$systemproductname" "$biosreleasedate" "$biosversion"
do
if [ ${#i} -gt 0 ]
then
  k="$((k + 1))";
fi
done

if [ $k -lt 24 ]
then
  suc="FAILURE";
  typ="Script Execution is failed";
fi
if [ $k -eq 24 ]
then
  suc="SUCCESS";
  typ="Script Execution is successfull";
fi

ed_dt=$(date);

echo $st_dt,"OS_HW_DISCOVERY",$host,$ipv4,"INFO","Script Started" >> $STALOG
echo $(date),"OS_HW_DISCOVERY",$host,$ipv4,$suc,$typ >> $STALOG
echo $ed_dt,"OS_HW_DISCOVERY",$host,$ipv4,"INFO","Script output generated" >> $STALOG
