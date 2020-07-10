function ATOS {
    param($var)
    $a = $null
    foreach ($name in $var) {
        $a = $a + $name + '; ' 
    }
    return $a
}
function ATOSMAC {
    param($nic, $ips)
    $a = $null
    foreach ($name in $nic) {
        $ip = $name.IPAddress | where {$_ -in $ips}
        if ($ip -ne $null) {        
            $a = $a + $name.MacAddress + '; '
        }
    }
    return $a
}
function Get-MachineType {
    param ($MachineModel)

    switch ($sysInfo.Model) { 
                     
    # Check for Hyper-V Machine Type 
    "Virtual Machine" { 
        $MachineType="Virtual Machine" 
        } 
 
    # Check for VMware Machine Type 
    "VMware Virtual Platform" { 
        $MachineType="Virtual Machine" 
        } 

    default { 
        $MachineType="Physical Machine" 
        } 
    }

    return $MachineType
}
$startdate = Get-Date

$ipconfig = ipconfig
[wmi]$bios = Get-WmiObject Win32_BIOS -Namespace "root\CIMV2" -ErrorVariable errbios
[wmi]$os = Get-WmiObject Win32_OperatingSystem -Namespace "root\CIMV2" -ErrorVariable erros
[wmi]$sysInfo = get-wmiobject Win32_ComputerSystem -Namespace "root\CIMV2" -ErrorVariable errsysInfo
[array]$mem = Get-WmiObject Win32_PhysicalMemory -Namespace "root\CIMV2" -ErrorVariable errmem
[array]$procs = Get-WmiObject Win32_Processor -Namespace "root\CIMV2" -ErrorVariable errprocs
[array]$disks = Get-WmiObject Win32_LogicalDisk -Namespace "root\CIMV2" -Filter DriveType=3 -ErrorVariable errdisks
foreach($disk in $disks){$total = $total + $disk.Size}
$disksize = [System.Math]::Round($total/1gb,2)
[array]$nic = Get-WmiObject Win32_NetworkAdapterConfiguration -Namespace "root\CIMV2" | where{$_.IPEnabled -eq "True"} -ErrorVariable errnic
$ips = $nic.IPAddress | where {$_ -notmatch "^fe80:*" -and $_ -notmatch "^192.168*" -and $_ -notmatch "^169.254*"}   | Sort-Object
if ($($ips | select -Skip 1).Count -eq 1) {
    $Additional_IP = $ips | Select -Skip 1
}
elseif ($($ips | select -Skip 1).Count -eq 0) {
    $Additional_IP = ""
}
else {
    $Additional_IP = ATOS -var $($ips | select -Skip 1)
}
$mac = ATOSMAC -nic $nic -ips $ips
if ($($mac.Split(";") | select -Skip 1) -eq " ") {
    $macaddress = $mac.Replace(";","")
}
else {
    $macaddress = $mac
}

$si = @{
    DeviceType = Get-MachineType -MachineModel $sysInfo.Model
    IP_Address = $ips | select -First 1
    "Additional IP" = $Additional_IP
    SubnetMask = ($ipconfig | where {$_ -match "Subnet"}).Split(":")[1].Replace(" ","")
    "MAC Address" = $macaddress
    Hostname = $bios.PSComputerName
    Serial_Number = $bios.SerialNumber
    Operating_System = [string]$os.Name.Substring(0,$os.Name.IndexOf("|"))
    Make = [string]$sysInfo.PrimaryOwnerName
    Model = [string]$sysInfo.Model
    "RAM(GB)" = $([string]([System.Math]::Round($sysInfo.TotalPhysicalMemory/1gb,2)))
    "No. of CPU" = [string]@($procs).count
    "Total HardDisk(GB)" = $disksize
    "CPU Vendor" = ($procs | Select -First 1).Manufacturer
    "CPU Cores per Socket" = $procs.SocketDesignation.Count
    "Number of CPU Sockets" = $($procs.NumberOfLogicalProcessors | Select -First 1) * $(($procs).count)
    "CPU Speed in MHz" = ($procs | Select -First 1).MaxClockSpeed
    "CPU Threads per Core" = $procs.NumberOfLogicalProcessors | Select -First 1
    "No of Disks Attached" = $disks.Count
    UUID = (Get-WmiObject -Class Win32_ComputerSystemProduct | Select-Object -Property UUID).UUID
    BIOS_Manufacturer = $bios.Manufacturer
    BIOS_Product_name = $bios.Name
    BIOS_Release_Date	= $($bios.ConvertToDateTime($bios.ReleaseDate) | Get-Date -Format dd-mm-yyyy)
    BIOS_Version = $bios.SMBIOSBIOSVersion
}



$ki = @{
    
    DeviceType = Get-MachineType -MachineModel $sysInfo.Model
    IP_Address = $ips | select -First 1
    "Additional IP" = $Additional_IP
    SubnetMask = ($ipconfig | where {$_ -match "Subnet"}).Split(":")[1].Replace(" ","")
    "MAC Address" = $macaddress
    Hostname = $bios.PSComputerName
    Serial_Number = $bios.SerialNumber
    Operating_System = [string]$os.Name.Substring(0,$os.Name.IndexOf("|"))
    Make = [string]$sysInfo.PrimaryOwnerName
    Model = [string]$sysInfo.Model
    "RAM(GB)" = $([string]([System.Math]::Round($sysInfo.TotalPhysicalMemory/1gb,2)))
    "No. of CPU" = [string]@($procs).count
    "Total HardDisk(GB)" = $disksize
    "CPU Vendor" = ($procs | Select -First 1).Manufacturer
    "CPU Cores per Socket" = $procs.SocketDesignation.Count
    "Number of CPU Sockets" = $($procs.NumberOfLogicalProcessors | Select -First 1) * $(($procs).count)
    "CPU Speed in MHz" = ($procs | Select -First 1).MaxClockSpeed
    "CPU Threads per Core" = $procs.NumberOfLogicalProcessors | Select -First 1
    "No of Disks Attached" = $disks.Count
    UUID = (Get-WmiObject -Class Win32_ComputerSystemProduct | Select-Object -Property UUID).UUID
    BIOS_Manufacturer = $bios.Manufacturer
    BIOS_Product_name = $bios.Name
    BIOS_Release_Date	= $($bios.ConvertToDateTime($bios.ReleaseDate) | Get-Date -Format dd-mm-yyyy)
    BIOS_Version = $bios.SMBIOSBIOSVersion
}


$Dev = Get-MachineType -MachineModel $sysInfo.Model
$ipp = $ips | select -First 1
$SubnetMask = ($ipconfig | where {$_ -match "Subnet"}).Split(":")[1].Replace(" ","")
if ($SubnetMask -Match "128.0.0.0" ) {$dsubnet = "$ipp/1"}
ElseIf ($SubnetMask -Match "192.0.0.0" ) {$dsubnet = "$ipp/2"}
ElseIf ($SubnetMask -Match "224.0.0.0" ) {$dsubnet = "$ipp/3"}
ElseIf ($SubnetMask -Match "240.0.0.0" ) {$dsubnet = "$ipp/4"}
ElseIf ($SubnetMask -Match "248.0.0.0" ) {$dsubnet = "$ipp/5"}
ElseIf ($SubnetMask -Match "252.0.0.0" ) {$dsubnet = "$ipp/6"}
ElseIf ($SubnetMask -Match "254.0.0.0" ) {$dsubnet = "$ipp/7"}
ElseIf ($SubnetMask -Match "255.0.0.0" ) {$dsubnet = "$ipp/8"}
ElseIf ($SubnetMask -Match "255.128.0.0" ) {$dsubnet = "$ipp/9"}
ElseIf ($SubnetMask -Match "255.192.0.0" ) {$dsubnet = "$ipp/10"}
ElseIf ($SubnetMask -Match "255.224.0.0" ) {$dsubnet = "$ipp/11"}
ElseIf ($SubnetMask -Match "255.240.0.0" ) {$dsubnet = "$ipp/12"}
ElseIf ($SubnetMask -Match "255.248.0.0" ) {$dsubnet = "$ipp/13"}
ElseIf ($SubnetMask -Match "255.252.0.0" ) {$dsubnet = "$ipp/14"}
ElseIf ($SubnetMask -Match "255.254.0.0" ) {$dsubnet = "$ipp/15"}
ElseIf ($SubnetMask -Match "255.255.0.0" ) {$dsubnet = "$ipp/16"}
ElseIf ($SubnetMask -Match "255.255.128.0" ) {$dsubnet = "$ipp/17"}
ElseIf ($SubnetMask -Match "255.255.192.0" ) {$dsubnet = "$ipp/18"}
ElseIf ($SubnetMask -Match "255.255.224.0" ) {$dsubnet = "$ipp/19"}
ElseIf ($SubnetMask -Match "255.255.240.0" ) {$dsubnet = "$ipp/20"}
ElseIf ($SubnetMask -Match "255.255.248.0" ) {$dsubnet = "$ipp/21"}
ElseIf ($SubnetMask -Match "255.255.252.0" ) {$dsubnet = "$ipp/22"}
ElseIf ($SubnetMask -Match "255.255.254.0" ) {$dsubnet = "$ipp/23"}
ElseIf ($SubnetMask -Match "255.255.255.0" ) {$dsubnet = "$ipp/24"}
ElseIf ($SubnetMask -Match "255.255.255.128" ) {$dsubnet = "$ipp/25"}
ElseIf ($SubnetMask -Match "255.255.255.224" ) {$dsubnet = "$ipp/26"}
ElseIf ($SubnetMask -Match "255.255.255.192" ) {$dsubnet = "$ipp/27"}
ElseIf ($SubnetMask -Match "255.255.255.240" ) {$dsubnet = "$ipp/28"}
ElseIf ($SubnetMask -Match "255.255.255.248" ) {$dsubnet = "$ipp/29"}
ElseIf ($SubnetMask -Match "255.255.255.252" ) {$dsubnet = "$ipp/30"}
ElseIf ($SubnetMask -Match "255.255.255.254" ) {$dsubnet = "$ipp/31"}
ElseIf ($SubnetMask -Match "255.255.255.255" ) {$dsubnet = "$ipp/32"}
Else {$dsubnet = "" }
$snet = ($ipconfig | where {$_ -match "Subnet"})
$MACAddress = $macaddress
$Hostname = $bios.PSComputerName
$Serial_Number = $bios.SerialNumber
$Operating_System = [string]$os.Name.Substring(0,$os.Name.IndexOf("|"))
$ver1 = ($Operating_System ).Split(" ")[3]
$ver2 = ($Operating_System ).Split(" ")[4]
$ver3 = ($Operating_System ).Split(" ")[5]
$ver = $ver1 +' ' + $ver2 + ' ' + $ver3
$Make = [string]$sysInfo.PrimaryOwnerName
$Model = [string]$sysInfo.Model
$RAM = $([string]([System.Math]::Round($sysInfo.TotalPhysicalMemory/1gb,2)))
$NoofCPU = [string]@($procs).count
$TotalHardDisk = $disksize
$CPUVendor = ($procs | Select -First 1).Manufacturer
$CPUCoresperSocket = $procs.SocketDesignation.Count
$NumberofCPUSockets = $($procs.NumberOfLogicalProcessors | Select -First 1) * $(($procs).count)
$CPUSpeedinMHz = ($procs | Select -First 1).MaxClockSpeed
$CPUThreadsperCore = $procs.NumberOfLogicalProcessors | Select -First 1
$NoofDisksAttached = $disks.Count
$UUID = (Get-WmiObject -Class Win32_ComputerSystemProduct | Select-Object -Property UUID).UUID
$BIOS_Manufacturer = $bios.Manufacturer
$BIOS_Product_name = $bios.Name
$BIOS_Release_Date	= $($bios.ConvertToDateTime($bios.ReleaseDate) | Get-Date -Format dd-mm-yyyy)
$BIOS_Version = $bios.SMBIOSBIOSVersion

$hyp = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V |Select-Object DisplayName, State
$hyp_display = $hyp.DisplayName;
$hyp_state = $hyp.State;
$vimal_1 = '';

if ( $hyp_state -Match "Enabled" )
{
  $vmdt = Get-VM | Select-Object Name, State;
  $vimal_1 = '","HYPERV_VMHOST":"';
  foreach ($vmnm in $vmdt)
  {
    $vm_hostname = $vmnm.Name;
    $vm_state = $vmnm.State;
    $vimal_1 = $vimal_1 + $vm_hostname + '|' + $vm_state +',';
  }
  $vimal_1 = $vimal_1 ;
}

$vimal = ""
$vimal += '{"DESCRIPTOR":"OS_HW_DISCOVERY","IPADDRESS":"'+ $ipp +'","VALUES":['+'"DEVICETYPE|'+$Dev+'","ADDITIONALIP|'+$Additional_IP+'","SUBNETMASK|'+$SubnetMask+'","SUBNET|'+$dsubnet+'","MACADDRESS|'+$MACAddress+'","HOSTNAME|'+$Hostname+'","SERIALNUMBER|'+$Serial_Number+'","OPERATINGSYSTEM|'+$Operating_System+'","OSSHORTNAME|WINDOWS","OSVERSION|'+$ver+'","MAKE|'+$Make+'","MODEL|'+$Model+'","RAM|'+$RAM+'","NUMBEROFCPU|'+$NoofCPU+'","HARDDISKSIZEGB|'+$TotalHardDisk+'","CPUVENDOR|'+$CPUVendor+'","CPUCOREPERSOCKET|'+$CPUCoresperSocket+'","CPUSPEEDMHZ|'+$CPUSpeedinMHz+'","CPUTHREADPERCORE|'+$CPUThreadsperCore+'","COREPERSOCKET|'+$CPUCoresperSocket+'","NUMBEROFCPUSOCKET|'+$NumberofCPUSockets+'","NUMBEROFHDD|'+$NoofDisksAttached+'","UUID|'+$UUID+'","BIOSMANUFACTURER|'+$BIOS_Manufacturer+'","BIOSPRODUCTNAME|'+$BIOS_Product_name+'","BIOSRELEASEDATE|'+$BIOS_Release_Date+'","BIOSVERSION|'+$BIOS_Version+'","HYPERVISOR|'+$hyp_state+$vimal_1+'"]}'
$vimal | Out-File C:\JAM\OS_HW_DISCOVERY_data.csv


#$si.Add("SumHDD",$total)

#[System.Collections.ArrayList]$sysCollection = New-Object System.Collections.ArrayList($null)
#$sysCollection.Add((New-Object PSObject -Property $ki))
#$sysCollection | select -Property DeviceType, IP_Address, "Additional IP", SubnetMask, "MAC Address", Hostname, Serial_Number, Operating_System, Make, Model , "RAM(GB)", "No. of CPU", "Total HardDisk(GB)", "CPU Vendor", "CPU Cores per Socket", "CPU Speed in MHz", "CPU Threads per Core", "Number of CPU Sockets", "No of Disks Attached", UUID, BIOS_Manufacturer, BIOS_Product_name, BIOS_Release_Date, BIOS_Version | Export-Csv C:\JAM\OS_HW_DISCOVERY_data.csv -NoTypeInformation -Force
#$sysCollection


$enddate = Get-Date
"$startdate" + ",OS_HW_DISCOVERY," + $Hostname + "," + $ipp + ",INFO,Script Started" | Out-File C:\JAM\Status_log.txt -Append
if ($errbios.Count -eq 0 -and $erros.Count -eq 0 -and $errsysInfo.Count -eq 0 -and $errmem.Count -eq 0 -and $errprocs.Count -eq 0 -and $errdisks.Count -eq 0 -and $errnic.Count -eq 0) {
    "$enddate" + ",OS_HW_DISCOVERY," + $Hostname + "," + $ipp + ",SUCCESS,Script Execution is successful" | Out-File C:\JAM\Status_log.txt -Append
}
else {
    "$enddate" + ",OS_HW_DISCOVERY," + $Hostname + "," + $ipp + ",FAILURE,Script Execution is failed" | Out-File C:\JAM\Status_log.txt -Append
} 
"$enddate" + ",OS_HW_DISCOVERY," + $Hostname + "," + $ipp + ",INFO,Script output generated" | Out-File C:\JAM\Status_log.txt -Append

$si = $null
$ki = $null
$sysCollection = $null