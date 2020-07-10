$startdate = Get-Date;
[array]$nic = Get-WmiObject Win32_NetworkAdapterConfiguration -Namespace "root\CIMV2" | where{$_.IPEnabled -eq "True"} -ErrorVariable errnic
$ips = $nic.IPAddress | where {$_ -notmatch "^fe80:*" -and $_ -notmatch "^192.168*" -and $_ -notmatch "^169.254*"}   | Sort-Object -ErrorVariable errips
$ipp = $ips | select -First 1;
$hst = get-wmiobject Win32_ComputerSystem | Select-Object Name -ErrorVariable errhst
$host1 = $hst.Name;


$Softwares = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate -ErrorVariable errsw
#Start-Transcript -Path C:\JAM\instSW_data.csv

#write-host '{"DESCRIPTOR":"INSTALLED_SW","IPADDRESS":"ipp","VALUES":["HOSTNAME|host"],"ITERATION":[' | Out-File C:\JAM\instSW_data.csv
$vimal = $vimal + '{"DESCRIPTOR":"INSTALLED_SW","IPADDRESS":"' + $ipp + '","VALUES":["HOSTNAME|' + $host1 + '"],"ITERATION":[';

foreach ($sw in $Softwares)
{
  $nm = $sw.DisplayName;
  $ver = $sw.DisplayVersion;
  $arc = $sw.Publisher;
  $dt = $sw.InstallDate;
  if ($nm -eq $null)
  {  $nulla = 'ok'; }
  else
  {
     #write-host '{"SOFTWARENAME":"' $nm '","SWVERSION":"' $ver '","ARCHITECTURE":"'$arc '","INSTALLEDDT":"'$dt '"},' | Out-File C:\JAM\instSW_data.csv -Append -Force
     $vimal = $vimal + '{"SOFTWARENAME":"' + $nm + '","SWVERSION":"' + $ver + '","ARCHITECTURE":"' + $arc + '","INSTALLEDDT":"' + $dt + '"},' ;
     #$vimal |Out-File C:\JAM\instSW_data.csv
    #write-host '{"DESCRIPTOR": "INSTALLED_SW","IPADDRESS": "ipp","VALUES":["HOSTNAME|host"],"ITERATION": [{"SOFTWARENAME": "'+$nm+'","SWVERSION": "'$sw.DisplayVersion'","ARCHITECTURE": "'$sw.Publisher'","INSTALLEDDT": "'$sw.InstallDate'"]}'
  }
}
#write-host ']}' | Out-File C:\JAM\instSW_data.csv -Append -Force
$vimal = $vimal + ']}' ;
$vimal |Out-File C:\JAM\instSW_data.csv
#Stop-Transcript

$enddate = Get-Date;

"$startdate" + ",INSTALLED_SW," + $host1 + "," + $ipp + ",INFO,Script Started" | Out-File C:\JAM\Status_log.txt -Append
if ($errnic.Count -eq 0 -and $errips.Count -eq 0 -and $errhst.Count -eq 0 -and $errsw.Count -eq 0 ) {
    "$enddate" + ",INSTALLED_SW," + $host1 + "," + $ipp + ",SUCCESS,Script Execution is successful" | Out-File C:\JAM\Status_log.txt -Append
}
else {
    "$enddate" + ",INSTALLED_SW," + $host1 + "," + $ipp + ",FAILURE,Script Execution is failed" | Out-File C:\JAM\Status_log.txt -Append
} 
"$enddate" + ",INSTALLED_SW," + $host1 + "," + $ipp + ",INFO,Script output generated" | Out-File C:\JAM\Status_log.txt -Append

$vimal = $null;
$nic = $null;
$hst = $null;