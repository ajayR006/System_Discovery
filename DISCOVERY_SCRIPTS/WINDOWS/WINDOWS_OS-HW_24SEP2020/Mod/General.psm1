Function General-ModuleVersion
{
return "1_3";
}
Function MyStrDateTime
{
$str_day=$null;
$str_month=$null;
$str_year=$null;
$str_date=$snull;
$str_hour=$null;
$str_min=$null;
$str_second=$null;
$str_time=$null;
$str_date_time=$null;

$str_day=$(get-date).Day; if($str_day -lt 10) { $str_day = "0" + $str_day; }
$str_month=$(get-date).Month; if($str_month -lt 10) { $str_month = "0" + $str_month; }
$str_year=$(get-date).Year;
$str_date ="" + $str_day + "-" + $str_month + "-" + $str_year;

$str_hour=$(get-date).Hour; if($str_hour -lt 10) { $str_hour = "0" + $str_hour;}
$str_min=$(get-date).Minute; if($str_min -lt 10) { $str_min = "0" + $str_min;}
$str_second=$(get-date).Second; if($str_second -lt 10) { $str_second = "0" + $str_second; }
$str_time= "" + $str_hour + ":" + $str_min + ":" + $str_second +" ";

$str_date_time=$str_date + "   " + $str_time + "   ";

return $str_date_time;
}

Function Writeto-Log
{
param
(
[string]$TypeOfComment="Info",
[string]$Comment=$null,
[string]$LogPath=$null,
[switch]$EchoDisplayOff
)

$str_toDisplay=$( $(MyStrDateTime) + $TypeOfComment + ": " + $Comment);
    if($EchoDisplayOff -eq $True)
    {}
    else
    {
    write-host $str_toDisplay;
    }

    if([string]::IsNullOrEmpty($logPath) -eq $False)
    {
    Add-Content -Path $LogPath -Value $str_toDisplay;
    Start-Sleep -Milliseconds 100;
    }
}

Function Check-LogPath
{
param
(
[string]$LogPath=$null,
[Switch]$CreateNew
)

$i_return=0; 
 if(Test-Path $LogPath)
 {
  $i_return=1;
 if($CreateNew)
 {
    try
    {
        Out-file -FilePath $LogPath -Encoding utf8 -Force -ErrorAction Stop | Out-Null;
        $i_return=1;
    }
    catch
    {
        $i_return = -1;
    }
}

 }
 else
 {
 $str_temp=Split-Path -Path $LogPath -Leaf;
    if($str_temp.Contains(".Log") -or $str_temp.Contains(".Txt") -or $str_temp.Contains(".Csv"))
    {

        try
        {
        Create-Path -Path $(Split-path -Path $LogPath -Parent;);
        Out-file -FilePath $LogPath -Encoding utf8 -Force -ErrorAction Stop | Out-Null;

        $i_return=1;
        }
        catch
        {

        $i_return=-1;
        }
    }
    else
    {
    $i_return=-1;
    }
 }

 return $i_return;
}

Function Check-OutPath
{
param
(
[string]$OutPath=$null,
[Switch]$CreateNew
)
if($CreateNew)
{ return $(Check-LogPath -LogPath $OutPath -CreateNew); }
else
{ return $(Check-LogPath -LogPath $OutPath); }
}

Function Create-Path
{
param
(
[string]$Path=$null
)
    if(Test-path $path){}
    else
    {
    Create-Path $(Split-path $Path -Parent);
    New-Item -Path $(Split-Path $Path -Parent) -Name $(Split-Path $Path -Leaf) -ItemType Directory;
    }
}

Function Test-UserAdmin  
{  
    param()
    process {
        [Security.Principal.WindowsPrincipal]$currentuser = [Security.Principal.WindowsIdentity]::GetCurrent();
        return $currentuser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator);
    }
}

Function Killer-Time-Checker
{
    [CmdletBinding()]
    param 
    (
        $TimeOutinMinutes=10,
        $StartTime=""
    )

    $CurrentTime=Get-Date;
    $TimeDiff=$CurrentTime - $StartTime;
    if($TimeDiff.Minutes -ge $TimeOutinMinutes)
    {
        throw ("Script running for more than $TimeOutinMinutes minute(s).");
    }
}

Function Killer-Resource-Check
{
    $procObj=Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select-Object Average;
    if($procObj.Average -ge 80)
    {
        Throw "Processor running over or above 80%. Script will not run.";
    }

    $osObj = gwmi win32_operatingsystem;
    $FreeMemGB = $($osObj.FreePhysicalMemory / (1024 * 1024))
    if($FreeMemGB -le 1)
    {
        Throw "Available free memory is 1GB or less. Script will not run.";
    }
}

Function Get-PSIPv4
{
[array]$enabledNics =  gwmi win32_networkadapterconfiguration | where { $_.IPEnabled; };
[array]$ips = $enabledNics | ForEach-Object { $_.IPAddress; }
$ipv4arr=@();
ForEach($ip in $ips)
{
    if($ip.contains("."))
    {
        $ipv4arr += $ip;
    }
}
return $ipv4arr;
}


Function Get-PSIPv6
{
[array]$enabledNics =  gwmi win32_networkadapterconfiguration | where { $_.IPEnabled; };
[array]$ips = $enabledNics | ForEach-Object { $_.IPAddress; }
$ipv6arr=@();
ForEach($ip in $ips)
{
    if($ip.contains(":"))
    {
        $ipv6arr += $ip;
    }
}
return $ipv6arr;
}