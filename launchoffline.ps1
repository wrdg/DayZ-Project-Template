<#
=========================================================================

Name: LaunchOffline
Description: Launches the DayZ client in offline with the compiled mod

Author: Wardog (wrdg)

=========================================================================
#>

. "$PSScriptRoot\userconfig.ps1" # IMPORT USER CONFIG VARIABLES

Stop-Process -Name "DayZ_x64" -Force -ErrorAction SilentlyContinue

if (![bool]$OFFLINE_MISSION_PATH -or !(Test-Path $OFFLINE_MISSION_PATH -ErrorAction Stop)) {
    Write-Host "Cannot locate offline mission directory!" -ForegroundColor Red
    Exit 1
}

if ($CLEAR_LOGS_AUTOMATIC){
    Invoke-Expression ".\clearlogs.ps1"
}

Remove-Item "$OFFLINE_MISSION_PATH\storage_-1" -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue

if ((Test-Path $DAYZ_ROOT_PATH)) {
    Push-Location $DAYZ_ROOT_PATH
    Write-Host "Starting DayZ Client in Offline Mode..."
    Start-Process -FilePath "$($DAYZ_ROOT_PATH)\DayZ_x64.exe" -ArgumentList "-mission=$OFFLINE_MISSION_PATH", "-nosplash", "-noPause", "-noBenchmark", "-filePatching", "-doLogs", "-scriptDebug=true", "'-mod=$PROJECT_DRIVE\$OUTPUT_DIR\;$ADDITIONAL_MODS'"
    Pop-Location
}