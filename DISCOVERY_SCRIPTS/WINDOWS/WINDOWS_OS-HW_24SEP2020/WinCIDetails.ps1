Function InitializeScript
{
    param 
    (
    [String]$ModulePath=""
    )

    $returnStatus=$False;
    try
    {
        import-module -Name $($ModulePath + "\Mod\General.psm1") -WarningAction SilentlyContinue -ErrorAction Stop | out-null;
        $returnStatus=$true;
    }
    catch
    {
        $returnStatus=$False;
    }
    return $returnStatus;
}

Function UpdateStatusLog
{
    param(
            $Service_Function="",
            $Version="",
            $IP_Address="",
            $Log_Type="",
            $Log_Message=""
    )
    $dt=Get-Date -Format "ddd MMM dd HH:mm:ss yyyy";
    $dtArr=$dt.split(" ");
    $tempdt=$dtArr[-1];
    $tempdt=(get-culture).Name + " " + $tempdt;
    $dtArr[-1]=$tempdt;
    $strdt=""
    $dtArr | Foreach {$strdt += $_ + " "};
    $strdt=$strdt.Trim();
    $StatusLogString=$strdt;
    $StatusLogString=$StatusLogString + "," + $Service_Function;
    $StatusLogString=$StatusLogString + ","  + "Script_Version-" + $Version;
    $StatusLogString=$StatusLogString + ","  + $env:Computername;
    $StatusLogString=$StatusLogString + "-" + $IP_Address;
    $StatusLogString=$StatusLogString + "," + $Log_Type;
    $StatusLogString=$StatusLogString + "," + $Log_Message + ".";
    return $StatusLogString;
}

$My_FullPath=$MyInvocation.MyCommand.Path;
$My_FolderPath=Split-Path -Path $My_FullPath -Parent;
$My_Name=Split-Path -Path $My_FullPath -Leaf;

$My_InFolder= $My_FolderPath + "\In";
$My_InFile= "In" + $My_Name.Replace(".ps1",".Csv");
$My_InFullPath= $My_InFolder + "\" + $My_InFile;
$InPath= $My_InFullPath;

$My_OutFolder= $My_FolderPath + "\Out";
$My_OutFile= "Out" + $My_Name.Replace(".ps1",".Csv");
$My_OutFullPath= $My_OutFolder + "\" + $My_OutFile;
$OutPath= $My_OutFullPath;

$My_LogFolder= $My_FolderPath + "\Log";
$My_LogFile= $My_Name.Replace(".ps1",".Log");
$My_LogFullPath= $My_LogFolder + "\" + $My_LogFile;
$LogPath= $My_LogFullPath;

$My_StatusLogPath=$env:ProgramFiles + "\NGOAgent\JAM\Stats\Status.Log";
$My_StatusLogString="";

$TemplateVersion="2.2";
$ScriptVersion="1.2";
$SelfTimer=30;
$ScriptStartTime=get-date;
$user = $env:Username;
$sysName=$env:Computername;
$ScriptExitCode=0;

if(InitializeScript -ModulePath $My_FolderPath -eq $true)
{
    if ((Check-LogPath -LogPath $LogPAth -eq 1) -and `
        (Check-OutPath -OutPath $OutPath -CreateNew -eq 1))
    {
        Writeto-Log -TypeOfComment Info -Comment "Logging Initialized.";
        Writeto-Log -TypeOfComment Info -Comment "********************************************SCRIPT START********************************************" -LogPath $LogPath;
        Writeto-Log -TypeOfComment Info -Comment "Script Name $My_Name." -LogPath $LogPath;
        Writeto-Log -TypeOfComment Info -Comment "Script Version $ScriptVersion." -LogPath $LogPath;
        Writeto-Log -TypeOfComment Info -Comment "Template Version $TemplateVersion." -LogPath $LogPath -EchoDisplayOff;
        Writeto-Log -TypeOfComment Info -Comment "Logged in user is $User." -LogPath $LogPath;
        if(Test-UserAdmin)
        {Writeto-Log -TypeOfComment Info -Comment "Script running with Admin privilieges." -LogPath $Logpath -EchoDisplayOff;}
        else
        {Writeto-Log -TypeOfComment Info -Comment "Script not running with Admin privilieges." -LogPath $Logpath -EchoDisplayOff;}
        Writeto-Log -TypeOfComment Info -Comment "System name is $sysName." -LogPath $Logpath;
        Writeto-Log -TypeOfComment Info -Comment $("OS " + $($(gwmi win32_operatingsystem).name.split("|"))[0]) -LogPath $LogPath;
        Writeto-Log -TypeOfComment Info -Comment $("Powershell version is " + $PSVersionTable.PSVersion.Major + ".") -LogPath $LogPath;
        Writeto-Log -TypeOfComment Info -Comment "Path of Script file is $My_FullPath."-LogPath $LogPath;
        Writeto-Log -TypeOfComment Info -Comment "Path of Log File is $LogPath." -LogPath $LogPath;
        try
        {
            Killer-Time-Checker -TimeOutinMinutes $SelfTimer -StartTime $ScriptStartTime;
            Killer-Resource-Check;

            $ipv4=$null;$ipv6=$null;
            $objCSVCreation=$null; $temp=$null;

            if(test-path -path $My_StatusLogPath)
            {
                writeto-log -TypeOfComment Info -Comment "Status.log file is present at $My_StatusLogPath." -LogPath $LogPath ;
                writeto-log -TypeOfComment Info -Comment "File will be appended." -LogPath $LogPath ;
            }
            else 
            {
                writeto-log -TypeOfComment Info -Comment "Status.log file not present at $My_StatusLogPath." -LogPath $LogPath ;
                writeto-log -TypeOfComment Info -Comment "Attempting to create the file and structure." -LogPath $LogPath;
                if($(Check-LogPath -LogPath $My_StatusLogPath -CreateNew) -eq -1)
                {
                    writeto-log -TypeOfComment Error -Comment "Unable to create $My_StatusLogPath." -LogPath $LogPath;
                    writeto-log -TypeOfComment Error -Comment "Script cannot continue." -LogPath $Logpath;

                    $ScriptExitCode=-1;
                    Writeto-Log -TypeOfComment Info -Comment "Script exit code is $ScriptExitCode." -LogPath $LogPAth;
                    Writeto-Log -TypeOfComment Info -Comment ".............................................SCRIPT END............................................." -LogPath $LogPath;
                    Exit -1;
                }
                else
                {
                    $My_StatusLogString="Timestamp";
                    $My_StatusLogString=$My_StatusLogString + ",Service_Function";
                    $My_StatusLogString=$My_StatusLogString + ",Version";
                    $My_StatusLogString=$My_StatusLogString + ",IP_Address";
                    $My_StatusLogString=$My_StatusLogString + ",Log_Type";
                    $My_StatusLogString=$My_StatusLogString + ",Log_Message";
                    Add-Content -Path $My_StatusLogPath -Value $My_StatusLogString -Encoding UTF8 -ErrorAction Stop;
                    start-sleep -Milliseconds 100;
                }
            }

            $ipv4=$(get-PSIPv4) -as [array]; $ipv6=(get-PSIPv6) -as [array];
            $ipv4=$($ipv4 | where { -not($_.Contains("127.0.")) -and -not($_.Contains("169.254.")) }) -as [array];
            if($ipv4 -eq $null)
            {
                $ipv4=@();
                $ipv4 += "Invalid IP.";
            }
            if($ipv6 -eq $null)
            {
                $ipv6=@();
                $ipv6 += "Invalid IP.";
            }


            $My_StatusLogString = UpdateStatusLog -Service_Function "OS_HW_DISCOVERY" -Version $ScriptVersion -IP_Address $ipv4[0] -Log_Type "Info" -Log_Message "Script Start";
            Add-Content -Path $My_StatusLogPath -Value $My_StatusLogString -Encoding UTF8 -ErrorAction Stop;
            start-sleep -Milliseconds 100;
            Writeto-Log -TypeOfComment Info -Comment "First update in Status log." -LogPath $LogPath;
            Writeto-Log -TypeOfComment Info -Comment $My_StatusLogString -LogPath $LogPath;

            Writeto-Log -TypeOfComment Info -Comment "Processing..." -LogPath $LogPath;

            $objCSVCreation = new-object pscustomobject;
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "Descriptor" -Value "OS_HW_DISCOVERY"
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "MachineType" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "IPAddress" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "AdditionalIP" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "SubnetMask" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "Subnet" -Value "";
			$objCSVCreation | Add-Member -MemberType NoteProperty -Name "Gateway" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "MACAddress" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "Hostname" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "Serial_Number" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "OS" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "OSSHOTNAME" -Value "WINDOWS";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "Version" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "Make" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "Model" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "RAM" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "No_of_CPU" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "Total_HDD" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "CPU_Vendor" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "CPU_cores_per_socket" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "CPU_speed" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "CPU_threads" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "NO_of_CPU_Sockets" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "No_of_Disks" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "UUID" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "BIOS_Manufacturer" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "BIOS_ProductName" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "BIOS_Release_Date" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "BIOS_Release_Version" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "BIOS_Version" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "HYPERVISOR" -Value "";
            $objCSVCreation | Add-Member -MemberType NoteProperty -Name "HYPERV_VMHOST" -Value "";
            
            $ComputerSystemInfo = Get-WmiObject -Class Win32_ComputerSystem; 
            [array]$enabledNics =  gwmi win32_networkadapterconfiguration | where { $_.IPEnabled; };
            $psBios=gwmi win32_bios;
            $os =  gwmi win32_operatingsystem;
            [array]$processor=gwmi win32_processor;
            [array]$hdd= gwmi win32_diskdrive;
            $ComputerSystemInfoproduct=gwmi win32_computersystemProduct;

            switch ($ComputerSystemInfo.Model) 
            { 
                 
                "Virtual Machine" 
                { 
                    $MachineType="Virtual";
                    break; 
                } 

                "VMware Virtual Platform" 
                { 
                    $MachineType="Virtual";
                    break;
                } 

                "VirtualBox" 
                { 
                    $MachineType="Virtual";
                    break;
                } 

                default 
                { 
                    $MachineType="Physical";
                    break;
                } 
            }
            $objCSVCreation.MachineType = $MachineType;

            $flag=$false;
            foreach($nic in $enabledNics)
            {
                [array]$ips=@();
                $ips = $nic | foreach {$_.IPAddress};
                foreach($ip in $ips)
                {
                    if($ip.Contains("."))
                    {
                        if($ip.Contains("169.254.") -or $nic.IPAddress.Contains("127.0"))
                        {}
                        else 
                        {
                            $objCSVCreation.IPAddress = $ip;
			    $vimal_ip = $ip;
                            $objCSVCreation.SubnetMask = $nic.IPSubnet[0];
                            $objCSVCreation.MacAddress = $nic.MACAddress;
                            $flag=$true;
                            break; 
                        }
                    }
                }
                if($flag -eq $true)
                {
                    break;
                }
                    
            }

            $objCSVCreation.AdditionalIP = $ipv6[0];
            $objCSVCreation.Hostname = $env:Computername;
            $objCSVCreation.Serial_Number = $psBios.SerialNumber;
            $objCSVCreation.OS = $os.name.split("|")[0];
            $objCSVCreation.Version = $os.BuildNumber;
            $objCSvCreation.Make = $os.Manufacturer;
            $compSystem=$ComputerSystemInfo;
            $objCSVCreation.Model = $compSystem.Model;
            $objCSVCreation.RAM=$os.TotalVisibleMemorySize / (1024 * 1024);
            $objCSVCreation.No_of_CPU=$processor.Length;
            $temp = 0;
            $hdd | foreach {$temp=$temp + $_.Size}
            $objCSvCreation.Total_HDD = $temp / (1024 * 1024);
            $objCSVCreation.CPU_Vendor = $processor[0].Name;
            $objCSVCreation.CPU_cores_per_socket = $processor[0].NumberOfCores;
            $objCSVCreation.CPU_speed = $($processor[0].Name.split(" "))[-1];
            $objCSVCreation.CPU_threads = $processor[0].NumberofLogicalProcessors;
            $objCSVCreation.NO_of_CPU_Sockets = $processor.Length;
            $objCSVCreation.No_of_Disks = $hdd.Length;
            $objCSVCreation.UUID = $ComputerSystemInfoproduct.UUID;
            $objCSVCreation.BIOS_Manufacturer = $psbios.Manufacturer;
            $objCSVCreation.BIOS_ProductName = $psbios.Name;
            $BiosDate=gwmi win32_bios -Property ReleaseDate;
            $BiosReleaseDate=$BiosDate.ConvertToDateTime($BiosDate.ReleaseDate);
            $objCSVCreation.BIOS_Release_Date = get-date $BiosReleaseDate -Format "dd-MM-yyyy";
            $objCSVCreation.BIOS_Release_Version=$psbios.SMBIOSBIOSVersion;
            $temp="";
            $psbios.BIOSVersion | foreach { $temp = $temp + $_ + " " }
            $objCSvCreation.BIOS_Version = $temp;

			$ipconfig = ipconfig
			$gw1 = (Get-NetIPConfiguration).IPv4DefaultGateway|select NextHop
			$gw = $gw1.NextHop
			$ipp1 = Test-Connection -ComputerName (hostname) -Count 1  | Select IPV4Address
			$ipp = $ipp1.IPV4Address
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

			$objCSVCreation.Subnet = $dsubnet;
			$objCSVCreation.Gateway = $gw;
			
			$hyp = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V |Select-Object DisplayName, State
			$hyp_display = $hyp.DisplayName;
			$hyp_state = $hyp.State;
			$vimal_1 = '';

			if ( $hyp_state -Match "Enabled" )
			{
				$vmdt = Get-VM | Select-Object Name, State;
				#$vimal_1 = '","HYPERV_VMHOST":"';
				$vimal_1 = "";
				foreach ($vmnm in $vmdt)
				{
					$vm_hostname = $vmnm.Name;
					$vm_state = $vmnm.State;
					$vimal_1 = $vimal_1 + $vm_hostname + '|' + $vm_state +',';
				}
				$vimal_1 = $vimal_1 ;
			}
            
			$objCSvCreation.HYPERVISOR = $hyp_state;
			$objCSvCreation.HYPERV_VMHOST = $vimal_1;
			
            $objCSVCreation | Convertto-csv | out-file -FilePath $OutPath -Encoding utf8;
            start-sleep -Milliseconds 100;
            $(import-csv $OutPath) | ConvertTo-Json | Out-file $($OutPath.Replace(".Csv",".Json")) -Encoding utf8; 
            start-sleep -Milliseconds 100;
            Writeto-Log -TypeOfComment Info -Comment "Clearing Temporary files." -LogPath $LogPAth;
            Remove-Item -Path $OutPath -Force -Confirm:$false -ErrorAction SilentlyContinue | Out-null;

            $My_StatusLogString = UpdateStatusLog -Service_Function "OS_HW_DISCOVERY" -Version $ScriptVersion -IP_Address $ipv4[0] -Log_Type "Success" -Log_Message "Script execution successful";
            Add-Content -Path $My_StatusLogPath -Value $My_StatusLogString -Encoding UTF8 -ErrorAction Stop;
            start-sleep -Milliseconds 100;
            Writeto-Log -TypeOfComment Info -Comment "Second update in Status log." -LogPath $LogPath;
            Writeto-Log -TypeOfComment Info -Comment $My_StatusLogString -LogPath $LogPath;

            $My_StatusLogString = UpdateStatusLog -Service_Function "OS_HW_DISCOVERY" -Version $ScriptVersion -IP_Address $ipv4[0] -Log_Type "Info" -Log_Message "Script output generated";
            Add-Content -Path $My_StatusLogPath -Value $My_StatusLogString -Encoding UTF8 -ErrorAction Stop;
            start-sleep -Milliseconds 100;
            Writeto-Log -TypeOfComment Info -Comment "Third update in Status log." -LogPath $LogPath;
            Writeto-Log -TypeOfComment Info -Comment $My_StatusLogString -LogPath $LogPath;

            $ScriptExitCode=0;
            Writeto-Log -TypeOfComment Info -Comment "Script exit code is $ScriptExitCode." -LogPath $LogPAth;
        }
        catch
        {
            Writeto-Log -TypeOfComment Error -Comment "Abnormal termination." -LogPath $LogPath;
            Writeto-Log -TypeOfComment Error -Comment $("On line number '" + $error[0].invocationinfo.ScriptLinenumber +"'.") -LogPath $LogPath -EchoDisplayOff;
            Writeto-Log -TypeOfComment Error -Comment $("Code error '" + $error[0].invocationinfo.Line.trim() +"'.") -LogPath $LogPath -EchoDisplayOff;
            Writeto-Log -TypeOfComment Error -Comment $("Exception details '" + $error[0].exception +"'.") -LogPath $LogPath -EchoDisplayOff;
            
            $My_StatusLogString = UpdateStatusLog -Service_Function "OS_HW_DISCOVERY" -Version $ScriptVersion -IP_Address $ipv4[0] -Log_Type "Failure" -Log_Message "Script execution failure";
            Add-Content -Path $My_StatusLogPath -Value $My_StatusLogString -Encoding UTF8 -ErrorAction Stop;
            start-Sleep -Milliseconds 100;
            Writeto-Log -TypeOfComment Info -Comment "Second update in Status log." -LogPath $LogPath;
            Writeto-Log -TypeOfComment Info -Comment $My_StatusLogString -LogPath $LogPath;
        
            $My_StatusLogString = UpdateStatusLog -Service_Function "OS_HW_DISCOVERY" -Version $ScriptVersion -IP_Address $ipv4[0] -Log_Type "Info" -Log_Message "Script output uncertain";
            Add-Content -Path $My_StatusLogPath -Value $My_StatusLogString -Encoding UTF8 -ErrorAction Stop;
            start-Sleep -Milliseconds 100;
            Writeto-Log -TypeOfComment Info -Comment "Third update in Status log." -LogPath $LogPath;
            Writeto-Log -TypeOfComment Info -Comment $My_StatusLogString -LogPath $LogPath;
            
            $ScriptExitCode=1;
            Writeto-Log -TypeOfComment Info -Comment "Script exit code is $ScriptExitCode." -LogPath $LogPAth;
        }

        Writeto-Log -TypeOfComment Info -Comment "*********************************************SCRIPT END*********************************************" -LogPath $LogPath;
    }
    else
    {
        Writeto-Log -TypeOfComment Info -Comment "Logging and/or Output could not be initialized.";
        Writeto-Log -TypeOfComment Info -Comment "Script cannot start.";

        $ScriptExitCode=2;
        Writeto-Log -TypeOfComment Info -Comment "Script exit code is $ScriptExitCode." -LogPath $LogPAth;
        Writeto-Log -TypeOfComment Info -Comment ".............................................SCRIPT END............................................." -LogPath $LogPath;
    }
}
else 
{
    Write-Host $("Module file missing at " + $My_FolderPath + "\Mod\General.psm1");
    Write-Host "Script cannot start.";

    $ScriptExitCode=3;
    Write-Host "Script exit code is $ScriptExitCode."
    Write-Host ".............................................SCRIPT END.............................................";
}

Remove-Module -Name General -Force -ErrorAction SilentlyContinue | Out-Null;
Exit $ScriptExitCode;