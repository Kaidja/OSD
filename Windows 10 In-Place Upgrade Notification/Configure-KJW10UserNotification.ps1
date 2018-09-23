Param(
    [String]$ScheduledTaskName = 'KJ - Windows 10 In-Place Upgrade Notification',
    [Switch]$Add,
    [Switch]$Remove
)


Function Get-KJLogDirectory
{
  Try{

    $TS = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction Stop
      $LogDir = $TS.Value("_SMSTSLogPath")
    
  }
  Catch{
    $LogDir = $env:TEMP
  }

  Return $LogDir
}

Function Initialize-SMSTSENV
{

    Try{
        New-Object -ComObject "Microsoft.SMS.TSEnvironment"
    }
    Catch{
        Write-Output $Error[0]
    }
}

#########################################################   SCRIPT ENTRY POINT #########################################################
$LogDirectory = Get-KJLogDirectory
$TSEnvironment = Initialize-SMSTSENV
$LogFile = "$LogDirectory\KJ-$($MyInvocation.MyCommand.Name).log"
$ScheduledTaskFolder = "C:\Program Files\KJ Windows 10 Upgrade Notification"

Start-Transcript -Path $LogFile

If($Add){
    
    Write-Output -InputObject "Importing $ScheduledTaskName"
    
    Try{
        New-Item -Path $ScheduledTaskFolder -ItemType Directory -ErrorAction STOP -Force
        Copy-Item -Path .\Content\* -Destination $ScheduledTaskFolder -Verbose -Force -ErrorAction STOP

        $ScheduledTask = Get-Content -Path .\W10Notification.xml -ErrorAction STOP | Out-String
        Register-ScheduledTask -Xml $ScheduledTask -TaskName $ScheduledTaskName -ErrorAction STOP
    }
    Catch{
        Write-Output -InputObject $Error[0]
    }
}

If($Remove){
    Write-Output -InputObject "Removing $ScheduledTaskName"
    Unregister-ScheduledTask -TaskName $ScheduledTaskName -Confirm:$false
}

Stop-Transcript
