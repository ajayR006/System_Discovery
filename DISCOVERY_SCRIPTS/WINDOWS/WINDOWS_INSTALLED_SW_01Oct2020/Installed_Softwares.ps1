#Requires -Version 3.0
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
    #$dt=Get-Date -Format "ddd MMM dd HH:mm:ss yyyy";
    $dt=Get-Date -Format "dd-MM-yyyy HH:mm:ss";
    $dtArr=$dt.split(" ");
    $tempdt=$dtArr[-1];
    $tempdt=(get-culture).Name + " " + $tempdt;
    $dtArr[-1]=$tempdt;
    $strdt=""
    $dtArr | Foreach {$strdt += $_ + " "};
    $strdt=$strdt.Trim();
    #$StatusLogString=$strdt;
    $StatusLogString=$dt;
    $StatusLogString=$StatusLogString + "," + $Service_Function;
    #$StatusLogString=$StatusLogString + ","  + "Script_Version-" + $Version;
    $StatusLogString=$StatusLogString + $Version;
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
	Clear-Content $LogPath;
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
            
            $ipv4=$null;$ipv6=$null;$vimout=$null;$nulla=$null;
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

            #$My_StatusLogString = UpdateStatusLog -Service_Function "SOFTWARE_DISCOVERY" -Version $ScriptVersion -IP_Address $ipv4[0] -Log_Type "Info" -Log_Message "Script Start";
            $My_StatusLogString = UpdateStatusLog -Service_Function "INSTALLED_SW" -IP_Address $ipv4[0] -Log_Type "Info" -Log_Message "Script Start";
            Add-Content -Path $My_StatusLogPath -Value $My_StatusLogString -Encoding UTF8 -ErrorAction Stop;
            start-sleep -Milliseconds 100;
            Writeto-Log -TypeOfComment Info -Comment "First update in Status log." -LogPath $LogPath;
            Writeto-Log -TypeOfComment Info -Comment $My_StatusLogString -LogPath $LogPath;

            Writeto-Log -TypeOfComment Info -Comment "Processing..." -LogPath $LogPath;
            $myJob=start-job -name PSProduct -ScriptBlock {
                gwmi win32_product;
                };

            $i_counter=1;
            while($i_counter -le 120)
            {
                if($MyJob.state -ne "Completed")
                {
                    start-sleep -Seconds 5;
                    $i_counter++;
                }
                else {
                    break;
                }
                
            }
            if($i_counter -gt 120)
            {
                Writeto-Log -TypeOfComment Error -Comment "Unable to get product list in 10 mins." -LogPath $LogPath;
                $MyJob | Stop-job -Confirm:$false -ErrorAction SilentlyContinue;
                $MyJob | Remove-job -Force -Confirm:$false -ErrorAction Stop;
                throw "Unable to get product list in 10 mins.";
            }

            Killer-Time-Checker -TimeOutinMinutes $SelfTimer -StartTime $ScriptStartTime;
            Killer-Resource-Check;

            $vimout = $vimout + '{"DESCRIPTOR":"INSTALLED_SW","IPADDRESS":"' + $ipv4[0] + '","VALUES":["HOSTNAME|' + $sysName + '"],"ITERATION":[';
            $installedProducts = $MyJob | Receive-Job -keep;
            $productInfo = $installedProducts | Select Name,Version,InstallDate,Description;
            #foreach($temp in $productInfo)
            #{
            #    $year=$temp.InstallDate.Substring(0,4);
            #    $month=$temp.InstallDate.Substring(4,2);
            #    switch ($month)
            #    {
            #        "01" { $month="Jan";break; }
            #        "02" { $month="Feb";break; }
            #        "03" { $month="Mar";break; }
            #        "04" { $month="Apr";break; }
            #        "05" { $month="May";break; }
            #        "06" { $month="Jun";break; }
            #        "07" { $month="Jul";break; }
            #        "08" { $month="Aug";break; }
            #        "09" { $month="Sep";break; }
            #        "10" { $month="Oct";break; }
            #        "11" { $month="Dec";break; }
            #        "12" { $month="Dec";break; }
            #
            #    }
            #    $dt=$temp.Installdate.SubString(6,2);
            #    $temp.InstallDate = $dt + "-" + $month + "-" +$year;
            #}

            # entered by vimal kumar
            foreach ($sw in $productInfo)
            {
               $nm = $sw.Name;
               $ver = $sw.Version;
               $dtt = $sw.InstallDate;
               $desc = $sw.Description;
               if ($nm -eq $null)
               {  $nulla = 'ok'; }
               else
               {
                  #write-host '{"SOFTWARENAME":"' $nm '","SWVERSION":"' $ver '","ARCHITECTURE":"'$arc '","INSTALLEDDT":"'$dt '"},' | Out-File C:\JAM\instSW_data.csv -Append -Force
                  $vimout = $vimout + '{"NAME":"' + $nm + '","VERSION":"' + $ver + '","INSTALLDATE":"' + $dtt + '","DESCRIPTION":"' + $desc + '"},' ;
                  #write-host '{"DESCRIPTOR": "INSTALLED_SW","IPADDRESS": "ipp","VALUES":["HOSTNAME|host"],"ITERATION": [{"SOFTWARENAME": "'+$nm+'","SWVERSION": "'$sw.DisplayVersion'","ARCHITECTURE": "'$sw.Publisher'","INSTALLEDDT": "'$sw.InstallDate'"]}'
               }
             }
             $vimout = $vimout + ']}' ;
             #$vimout |Out-File C:\JAM\instSW_data.csv
            # end
            
            #$productInfo | ConvertTo-Csv | Out-file $OutPath -Force -Encoding utf8 -ErrorAction Stop;
            
            #$(import-csv $OutPath) | ConvertTo-Json | Out-file $($OutPath.Replace(".Csv",".Json")) -Encoding utf8; 
            $vimout | Out-file $($OutPath.Replace(".Csv",".Json")) -Encoding utf8;
            start-sleep -Milliseconds 100;
            Writeto-Log -TypeOfComment Info -Comment "Clearing Temporary files." -LogPath $LogPAth;
            Remove-Item -Path $OutPath -Force -Confirm:$false -ErrorAction SilentlyContinue | Out-null;

            #$My_StatusLogString = UpdateStatusLog -Service_Function "SOFTWARE_DISCOVERY" -Version $ScriptVersion -IP_Address $ipv4[0] -Log_Type "Success" -Log_Message "Script execution successful";
            $My_StatusLogString = UpdateStatusLog -Service_Function "INSTALLED_SW" -IP_Address $ipv4[0] -Log_Type "Success" -Log_Message "Script execution successful";
            Add-Content -Path $My_StatusLogPath -Value $My_StatusLogString -Encoding UTF8 -ErrorAction Stop;
            start-sleep -Milliseconds 100;
            Writeto-Log -TypeOfComment Info -Comment "Second update in Status log." -LogPath $LogPath;
            Writeto-Log -TypeOfComment Info -Comment $My_StatusLogString -LogPath $LogPath;

            #$My_StatusLogString = UpdateStatusLog -Service_Function "SOFTWARE_DISCOVERY" -Version $ScriptVersion -IP_Address $ipv4[0] -Log_Type "Info" -Log_Message "Script output generated";
            $My_StatusLogString = UpdateStatusLog -Service_Function "INSTALLED_SW" -IP_Address $ipv4[0] -Log_Type "Info" -Log_Message "Script output generated";
            Add-Content -Path $My_StatusLogPath -Value $My_StatusLogString -Encoding UTF8 -ErrorAction Stop;
            start-sleep -Milliseconds 100;
            Writeto-Log -TypeOfComment Info -Comment "Third update in Status log." -LogPath $LogPath;
            Writeto-Log -TypeOfComment Info -Comment $My_StatusLogString -LogPath $LogPath;

            #inserted by Vimal kumar
            $My_StatusLogString = UpdateStatusLog -Service_Function "INSTALLED_SW" -IP_Address $ipv4[0] -Log_Type "Info" -Log_Message "script_version-2.0";
            Add-Content -Path $My_StatusLogPath -Value $My_StatusLogString -Encoding UTF8 -ErrorAction Stop;
            start-sleep -Milliseconds 100;
            Writeto-Log -TypeOfComment Info -Comment "Third update in Status log." -LogPath $LogPath;
            Writeto-Log -TypeOfComment Info -Comment $My_StatusLogString -LogPath $LogPath;
            #end

            $ScriptExitCode=0;
            Writeto-Log -TypeOfComment Info -Comment "Script exit code is $ScriptExitCode." -LogPath $LogPAth;
        }
        catch
        {
            Writeto-Log -TypeOfComment Error -Comment "Abnormal termination." -LogPath $LogPath;
            Writeto-Log -TypeOfComment Error -Comment $("On line number '" + $error[0].invocationinfo.ScriptLinenumber +"'.") -LogPath $LogPath -EchoDisplayOff;
            Writeto-Log -TypeOfComment Error -Comment $("Code error '" + $error[0].invocationinfo.Line.trim() +"'.") -LogPath $LogPath -EchoDisplayOff;
            Writeto-Log -TypeOfComment Error -Comment $("Exception details '" + $error[0].exception +"'.") -LogPath $LogPath -EchoDisplayOff;
            
            #$My_StatusLogString = UpdateStatusLog -Service_Function "SOFTWARE_DISCOVERY" -Version $ScriptVersion -IP_Address $ipv4[0] -Log_Type "Failure" -Log_Message "Script execution failure";
            $My_StatusLogString = UpdateStatusLog -Service_Function "INSTALLED_SW" -IP_Address $ipv4[0] -Log_Type "Failure" -Log_Message "Script execution failure";
            Add-Content -Path $My_StatusLogPath -Value $My_StatusLogString -Encoding UTF8 -ErrorAction Stop;
            start-Sleep -Milliseconds 100;
            Writeto-Log -TypeOfComment Info -Comment "Second update in Status log." -LogPath $LogPath;
            Writeto-Log -TypeOfComment Info -Comment $My_StatusLogString -LogPath $LogPath;
        
            #$My_StatusLogString = UpdateStatusLog -Service_Function "SOFTWARE_DISCOVERY" -Version $ScriptVersion -IP_Address $ipv4[0] -Log_Type "Info" -Log_Message "Script output uncertain";
            $My_StatusLogString = UpdateStatusLog -Service_Function "INSTALLED_SW" -IP_Address $ipv4[0] -Log_Type "Info" -Log_Message "Script output uncertain";
            Add-Content -Path $My_StatusLogPath -Value $My_StatusLogString -Encoding UTF8 -ErrorAction Stop;
            start-Sleep -Milliseconds 100;
            Writeto-Log -TypeOfComment Info -Comment "Third update in Status log." -LogPath $LogPath;
            Writeto-Log -TypeOfComment Info -Comment $My_StatusLogString -LogPath $LogPath;

	    #inserted by Vimal kumar
            $My_StatusLogString = UpdateStatusLog -Service_Function "INSTALLED_SW" -IP_Address $ipv4[0] -Log_Type "Info" -Log_Message "script_version-2.0";
            Add-Content -Path $My_StatusLogPath -Value $My_StatusLogString -Encoding UTF8 -ErrorAction Stop;
            start-sleep -Milliseconds 100;
            Writeto-Log -TypeOfComment Info -Comment "Third update in Status log." -LogPath $LogPath;
            Writeto-Log -TypeOfComment Info -Comment $My_StatusLogString -LogPath $LogPath;
            #end
            
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

get-job | Stop-job -ErrorAction SilentlyContinue;
get-job| Remove-job -ErrorAction SilentlyContinue;
Remove-Module -Name General -Force -ErrorAction SilentlyContinue | Out-Null;
Exit $ScriptExitCode;