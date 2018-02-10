Function Get-LogDirectory
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

Function Disable-Windows10ConsumerExperience
{
    #Set policy reg keys to disable the ConsumerExperience.
    $RegistryPath = "HKLM:\Software\Policies\Microsoft\Windows\CloudContent"
    If(!(Test-Path $RegistryPath)){
        New-Item -Path $RegistryPath -Force
    }
   
    New-ItemProperty -Path $RegistryPath -Name DisableWindowsConsumerFeatures -Value '1' -PropertyType DWORD -Force

}

################ Script Entry Point ###############################

$LogDirectory = Get-LogDirectory
Start-Transcript -Path "$LogDirectory\Disable-Windows10ConsumerExperience.log"

Disable-Windows10ConsumerExperience

Stop-Transcript

