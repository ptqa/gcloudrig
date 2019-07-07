# gcloudrig-boot.ps1
#

Function Write-Status {
  Param(
    [parameter(Mandatory=$true,ValueFromPipeLine=$true)] [String] $Text,
    [String] $Sev = "INFO"
  )
  # this goes to the serial console
  "$Sev $Text" | Write-Output
  New-GcLogEntry -Severity "$Sev" -LogName gcloudrig-install -TextPayload "$Text"
}

Function Update-GcloudRigModule {
  if (Get-GceMetadata -Path "project/attributes" | Select-String $SetupScriptUrlAttribute) {
    $SetupScriptUrl=(Get-GceMetadata -Path project/attributes/$SetupScriptUrlAttribute)

    & gsutil cp $SetupScriptUrl "$Env:Temp\gcloudrig.psm1"
    if (Test-Path "$Env:Temp\gcloudrig.psm1") {
      New-Item -ItemType directory -Path "$Env:ProgramFiles\WindowsPowerShell\Modules\gCloudRig" -Force
      Copy-Item "$Env:Temp\gcloudrig.psm1" -Destination "$Env:ProgramFiles\WindowsPowerShell\Modules\gCloudRig\" -Force
    }
  }
}


## Main
Write-Status -Sev DEBUG "gcloudrig-boot.ps1 started"

# these need to match globals.sh
$GCRLABEL="gcloudrig"
$GamesDiskName="gcloudrig-games"
$SetupScriptUrlAttribute="gcloudrig-setup-script-gcs-url"

Update-GcloudRigModule 
if (Get-Module -ListAvailable -Name gCloudRig) {
  Import-Module gCloudRig
  Invoke-SoftwareSetupFromBoot
}
Mount-GamesDisk

Write-Status -Sev DEBUG "gcloudrig-boot.ps1 finished"
