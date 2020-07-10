[wmi]$bios = Get-WmiObject Win32_BIOS -Namespace "root\CIMV2" -ErrorVariable errbios
$Hostname = $bios.PSComputerName

[array]$nic = Get-WmiObject Win32_NetworkAdapterConfiguration -Namespace "root\CIMV2" | where{$_.IPEnabled -eq "True"} -ErrorVariable errnic
$ips = $nic.IPAddress | where {$_ -notmatch "^fe80:*" -and $_ -notmatch "^192.168*" -and $_ -notmatch "^169.254*"}   | Sort-Object
$IP_Address = $ips | select -First 1

"$Hostname" + "," + "$IP_Address" + "," + (Get-FileHash "C:\Temp\discovery_script\discovery_script_V1.0.ps1").Hash | Out-File C:\Temp\discovery_script\OS_HW_DISCOVERY_filehash.txt
