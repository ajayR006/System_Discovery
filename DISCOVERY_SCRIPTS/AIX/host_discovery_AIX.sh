#!/usr/bin/bash
#####

source /opt/ngoagent/JAM/Discovery/script/JAM_CONFIG.conf

st_dt=$(date);

#ipv4=`sudo /usr/sbin/ifconfig -a | awk '/flags/ {printf $1" "} /inet/ {print $2}' | grep -v lo | head -1 | awk -F':' '{print $2}' | sed 's/^ *//g'`
ipv4=`prtconf|grep -i "IP Address:"|awk -F":" '{print $2}'`
en=`sudo /usr/sbin/ifconfig -a | awk '/flags/ {printf $1" "} /inet/ {print $2}' | grep -v lo | head -1 | awk -F':' '{print $1}'`
addip1=`sudo /usr/sbin/ifconfig -a | awk '/flags/ {printf $1" "} /inet/ {print $2}' | grep -v lo | grep -v $ipv4 | grep -v "::" | awk -F':' '{print $2}' | tr '\n' ' '`

subnetmask=`lsattr -E -a netmask -l $en -F value`;
if [ "$subnetmask" == "128.0.0.0" ];
then
   dsubnet=$iPv4"/1";
elif [ "$subnetmask" == "192.0.0.0" ];
then
   dsubnet=$ipv4"/2";
elif [ "$subnetmask" == "224.0.0.0" ];
then
   dsubnet=$ipv4"/3";
elif [ "$subnetmask" == "240.0.0.0" ];
then
   dsubnet=$ipv4"/4";
elif [ "$subnetmask" == "248.0.0.0" ];
then
   dsubnet=$ipv4"/5";
elif [ "$subnetmask" == "252.0.0.0" ];
then
   dsubnet=$ipv4"/6";
elif [ "$subnetmask" == "254.0.0.0" ];
then
   dsubnet=$ipv4"/7";
elif [ "$subnetmask" == "255.0.0.0" ];
then
   dsubnet=$ipv4"/8";
elif [ "$subnetmask" == "255.128.0.0" ];
then
   dsubnet=$ipv4"/9";
elif [ "$subnetmask" == "255.192.0.0" ];
then
   dsubnet=$ipv4"/10";
elif [ "$subnetmask" == "255.224.0.0" ];
then
   dsubnet=$ipv4"/11";
elif [ "$subnetmask" == "255.240.0.0" ];
then
   dsubnet=$ipv4"/12";
elif [ "$subnetmask" == "255.248.0.0" ];
then
   dsubnet=$ipv4"/13";
elif [ "$subnetmask" == "255.252.0.0" ];
then
   dsubnet=$ipv4"/14";
elif [ "$subnetmask" == "255.254.0.0" ];
then
   dsubnet=$ipv4"/15";
elif [ "$subnetmask" == "255.255.0.0" ];
then
   dsubnet=$ipv4"/16";
elif [ "$subnetmask" == "255.255.128.0" ];
then
   dsubnet=$ipv4"/17";
elif [ "$subnetmask" == "255.255.192.0" ];
then
   dsubnet=$ipv4"/18";
elif [ "$subnetmask" == "255.255.224.0" ];
then
   dsubnet=$ipv4"/19";
elif [ "$subnetmask" == "255.255.240.0" ];
then
   dsubnet=$ipv4"/20";
elif [ "$subnetmask" == "255.255.248.0" ];
then
   dsubnet=$ipv4"/21";
elif [ "$subnetmask" == "255.255.252.0" ];
then
   dsubnet=$ipv4"/22";
elif [ "$subnetmask" == "255.255.254.0" ];
then
   dsubnet=$ipv4"/23";
elif [ "$subnetmask" == "255.255.255.0" ];
then
   dsubnet=$ipv4"/24";
elif [ "$subnetmask" == "255.255.255.128" ];
then
   dsubnet=$ipv4"/25";
elif [ "$subnetmask" == "255.255.255.192" ];
then
   dsubnet=$ipv4"/26";
elif [ "$subnetmask" == "255.255.255.224" ];
then
   dsubnet=$ipv4"/27";
elif [ "$subnetmask" == "255.255.255.240" ];
then
   dsubnet=$ipv4"/28";
elif [ "$subnetmask" == "255.255.255.248" ];
then
   dsubnet=$ipv4"/29";
elif [ "$subnetmask" == "255.255.255.252" ];
then
   dsubnet=$ipv4"/30";
elif [ "$subnetmask" == "255.255.255.254" ];
then
   dsubnet=$ipv4"/31";
elif [ "$subnetmask" == "255.255.255.255" ];
then
   dsubnet=$ipv4"/32";
else
   dsubnet="";
fi

ar1=$(ifconfig -a | cut -d':' -f1 | grep -v inet | grep -v tcp | grep -v lo)
for x in $ar1
do
 p=`lsattr -El $x | grep -i netmask | awk '{print $2}' |tr '\n' ' '`
 temp="$x => $p"
 subnet="$subnet $temp"
 v6=`lsattr -El $x | grep -i netaddr6 | awk '{print $2}'| grep -v IPv6 |tr '\n' ' '`
 if [ -z "$v6" ]
  then
  :
 else
  temp1="$v6"
  IPv6="$IPv6 $temp1"
 fi
 mac=`entstat -d $x |egrep Hard | awk '{print $3}'| head -1`
 temp2="$x => $mac"
 macadd="$macadd $temp2"
done
addip="$addip1 $IPv6"

gateway=`lsconf | grep -i gateway| awk '{print $2}'|head -1`;
host=`sudo hostname`;
serial=`sudo prtconf | grep 'Machine Serial Number' | awk -F':' '{print $2}' | sed 's/^ *//g'`
os=`sudo uname -a | awk '{print $1 " " $4}'`
shortos=`sudo uname -a | awk '{print $1}'`
osversion=`sudo uname -a | awk '{print $4}'`
make=`sudo prtconf | grep 'System Model' | awk -F':' '{print $2}' | sed 's/^ *//g' | cut -d',' -f 1`
model=`sudo prtconf | grep 'System Model' | awk -F':' '{print $2}' | sed 's/^ *//g' | cut -d',' -f 2`

CorePerCPU=`sudo lscfg -vp | grep -i way | awk '{print $1}'|head -1`
ram=`sudo prtconf | grep Mem | awk -F':' '{print $2}' | sed 's/^ *//g' | awk '{print $1}' | head -1`
ram1=$(($ram/1024))

cpunumbers=`sudo prtconf | grep 'Number Of Processors' | awk -F':' '{print $2}' | sed 's/^ *//g'`
CPUType=`sudo prtconf | grep -i "Processor Type" | awk -F':' '{print $2}' | sed 's/^ *//g'`
CPUSpeed=`sudo prtconf | grep -i speed| awk '{print $4}'`
CPUTHREAD=`lsattr -El proc0 |grep -i "smt_threads"|awk '{ print $2}'`;

SIZE=0
dcnt=0
for ff in $(sudo lspv | awk '{ print $1 }')
do
size=$(sudo bootinfo -s $ff)
((SIZE=SIZE+size))
dcnt=$((dcnt + 1))
done
GB=1024
hdd=$((SIZE / GB))

#physical or virtual
DEVICE=`uname -L |awk '{print $1}'`
((DEVICE=DEVICE+0))
if [ $DEVICE -gt 0 ]
then
   DEVICE='VIRTUAL';
else
   DEVICE='PHYSICAL';
fi

DUMMY='';

#Disk
#NoOfDisk=`ls /dev/sd*[a-z] | wc -l`
#NoOfDisk=`lsblk -d|grep -i disk|wc -l`
#NoOfDisk=`lsdev -Cc disk|wc -l`
#((NoOfDisk=NoOfDisk +0))

BIOSNAME=`prtconf|grep -i "Platform Firmware level"|awk -F":" '{print $2}'`
BIOSMANUFACTURER=`prtconf|grep -i "Firmware Version:"|awk -F":" '{print $2}'|awk -F"," '{print $1}'`
BIOSVERSION=`prtconf|grep -i "Firmware Version:"|awk -F":" '{print $2}'|awk -F"," '{print $2}'`

#echo "DeviceType, IP, AddItionalIP, SubnetMask, Subnet, MACAddress, Hostname, SerailNumber, OS, ShortOS, ShortVersion, Make, Model, RAM, CPUNumber, TotalHDD, CPUVendor, CPU Cores per Socket, CPU Speed in MHz, CPU Threads per Core, Cores per Socket, Number of CPU Sockets, No of Disks Attached, UUID, BIOS_Manufacturer, BIOS_Product_name, BIOS_Release_Date, BIOS_Version";
#echo $DEVICE, $ipv4, $addip, $subnetmask, $dsubnet, $macadd, $host, $serial, $os, $shortos, $osversion, $make, $model, $ram1, $cpunumbers, $hdd, $CPUType, $CorePerCPU, $CPUSpeed, $CPUTHREAD, $DUMMY, $DUMMY, $dcnt, $DUMMY, $BIOSMANUFACTURER, $DUMMY, $DUMMY, $BIOSVERSION;

STMT='{';
STMT=$STMT'"DESCRIPTOR":"OS_HW_DISCOVERY",';
STMT=$STMT'"IPADDRESS":"'$ipv4'",';
STMT=$STMT'"VALUES":[';
STMT=$STMT'"DEVICETYPE|'$DEVICE'",';
STMT=$STMT'"ADDITIONALIP|'$addip'",';
STMT=$STMT'"SUBNETMASK|'$subnetmask'",';
STMT=$STMT'"SUBNET|'$dsubnet'",';
STMT=$STMT'"GATEWAY|'$gateway'",';
STMT=$STMT'"MACADDRESS|'$macadd'",';
STMT=$STMT'"HOSTNAME|'$host'",';
STMT=$STMT'"SERIALNUMBER|'$serial'",';
STMT=$STMT'"OPERATINGSYSTEM|'$os'",';
STMT=$STMT'"OSSHORTNAME|'$shortos'",';
STMT=$STMT'"OSVERSION|'$osversion'",';
STMT=$STMT'"MAKE|'$make'",';
STMT=$STMT'"MODEL|'$model'",';
STMT=$STMT'"RAM|'$ram1'",';
STMT=$STMT'"NUMBEROFCPU|'$cpunumbers'",';
STMT=$STMT'"HARDDISKSIZEGB|'$hdd'",';
STMT=$STMT'"CPUVENDOR|'$CPUType'",';
STMT=$STMT'"CPUCOREPERSOCKET|'$CorePerCPU'",';
STMT=$STMT'"CPUSPEEDMHZ|'$CPUSpeed'",';
STMT=$STMT'"CPUTHREADPERCORE|'$CPUTHREAD'",';
STMT=$STMT'"COREPERSOCKET|'$DUMMY'",';
STMT=$STMT'"NUMBEROFCPUSOCKET|'$DUMMY'",';
STMT=$STMT'"NUMBEROFHDD|'$dcnt'",';
STMT=$STMT'"UUID|'$DUMMY'",';
STMT=$STMT'"BIOSMANUFACTUIRER|'$BIOSMANUFACTURER'",';
STMT=$STMT'"BIOSPRODUCTNAME|'$DUMMY'",';
STMT=$STMT'"BIOSRELEASEDATE|'$DUMMY'",';
STMT=$STMT'"BIOSVERSION|'$BIOSVERSION'"';
STMT=$STMT']';
STMT=$STMT'}';
echo $STMT;

k=0;
for i in "$DEVICE" "$ipv4" "$addip" "$subnetmask" "$dsubnet" "$gateway" "$macadd" "$host" "$serial" "$os" "$shortos" "$osversion" "$make" "$model" "$ram1" "$cpunumbers" "$hdd" "$CPUType" "$CorePerCPU" "$CPUSpeed" "$CPUTHREAD" "$DUMMY" "$DUMMY" "$dcnt" "$DUMMY" "$BIOSMANUFACTURER" "$DUMMY" "$DUMMY" "$BIOSVERSION"
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