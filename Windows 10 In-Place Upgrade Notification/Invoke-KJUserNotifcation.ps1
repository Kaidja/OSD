Start-Process -FilePath """$PSScriptRoot\UI++64.exe""" -ArgumentList "/config:""$PSScriptRoot\UpgradeInProgress.xml""" -PassThru -Wait
