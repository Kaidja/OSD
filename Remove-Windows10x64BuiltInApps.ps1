<# 
.Synopsis
    This script removes Windows 10 Built-in application during OSD.
.DESCRIPTION
    This script requires that you add additional Boot Image components.
    Boot Image components in MDT:
        -   DISM Cmdlets
        -	.NET Framework
        -	Windows PowerShell
        -	Storage Management Cmdlets

    Boot Image components in SCCM:
        - 
#>
Function Initialize-SMSTSENV
{

    Try{
        New-Object -ComObject "Microsoft.SMS.TSEnvironment"
    }
    Catch{
        Write-Output $Error[0]
    }
}

Function Get-Win10AppxProvisioningPackages
{
    Param(
        $Name,
        $WIMPath
    )

    Try{
        $ProvisioningPackage = Get-AppxProvisionedPackage -Path $WIMPath | Where-Object Displayname -EQ $Name
    }
    Catch{
        Write-Output $Error[0]
    }

    Return $ProvisioningPackage
}

Function Remove-Win10AppxProvisioningPackages
{
    Param(
        $Name,
        $WIMPath
    )

    Try{
        Write-Output -InputObject "---Removing Provisioning Package: $Name"

        $App = Get-Win10AppxProvisioningPackages -Name $Name -WIMPath $WIMPath
        If($App){
            Remove-AppxProvisionedPackage -PackageName $App.PackageName -Path $WIMPath -ErrorAction STOP
        }
        Else{
            Write-Output -InputObject '--No such Appx Provisioning Package'
        }
    }
    Catch{
        Write-Output $Error[0]
    }
}

Function Get-WIMOfflineLocation
{
    
      $Drives = Get-Volume | Where-Object {-not [String]::IsNullOrWhiteSpace($PSItem.DriveLetter) } | 
        Where-Object {$PSItem.DriveType -eq 'Fixed'} | 
            Where-Object {$PSItem.DriveLetter -ne 'X'}
      
      $Drives | Where-Object { 
            Test-Path "$($PSItem.DriveLetter):\Windows\System32"} | 
                ForEach-Object { $OfflinePath = "$($PSItem.DriveLetter):\" }
      
      Write-Output $OfflinePath
}

############## SCRIPT ENTRY POINT #######################

$TSEnvironment = Initialize-SMSTSENV
$LogPath = If($TSEnvironment.Value('LogPath')){$TSEnvironment.Value('LogPath')} Else{$TSEnvironment.Value("_SMSTSLogPath")}
$LogFile = "$LogPath\Remove-Windows10x64-BuiltInApps.log"

Start-Transcript -Path $LogFile
Write-Output $LogFile

#Application to keep. 
$AppsToKeep = @(
    'Microsoft.StorePurchaseApp',
    'Microsoft.WindowsStore',
    'Microsoft.WindowsCalculator',
    'Microsoft.MicrosoftStickyNotes',
    'Microsoft.Windows.Photos',
    'Microsoft.ZuneVideo'
    ) 

Write-Output "Getting Offline Path"
$WIMOfflineLocation = Get-WIMOfflineLocation
Write-Output "Offline Path: $WIMOfflineLocation"

$WIMApps = Get-AppxProvisionedPackage -Path $WIMOfflineLocation
foreach($App in $WImApps){

        If($App.Displayname -in $AppsToKeep){
            Write-Output "We do not remove Application: $($App.Displayname)"
        }
        Else{
        
            Write-Output "Processing Application: $($App.Displayname)"
            Remove-Win10AppxProvisioningPackages -Name $App.Displayname -WIMPath $WIMOfflineLocation

        }
}


#### STOP Transcript
Stop-Transcript

#Export Apps to a CSV file
#Get-AppxPackage -PackageTypeFilter Bundle | Select-Object -Property Name,PackageFullName | Export-Csv -Path C:\Users\Kaido\Desktop\Windows10BuiltINApps.csv -NoTypeInformation