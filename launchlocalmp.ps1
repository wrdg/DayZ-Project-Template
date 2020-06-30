<#
=========================================================================

Name: LaunchLocalMP
Description: Launches the DayZ client and server with the compiled mod

Author: Wardog (wrdg)

=========================================================================
#>

. "$PSScriptRoot\userconfig.ps1" # IMPORT USER CONFIG VARIABLES

Stop-Process -Name "DayZ_x64" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "DayZServer_x64" -Force -ErrorAction SilentlyContinue

if ($CLEAR_LOGS_AUTOMATIC){
    Invoke-Expression ".\clearlogs.ps1"
}

if ((Test-Path $LOCAL_DAYZ_SERVER_PATH)) {
    Write-Host "Starting DayZ Server..."
    Start-Process -FilePath "$($LOCAL_DAYZ_SERVER_PATH)\DayZServer_x64.exe" -ArgumentList "-config=serverDZ.cfg", "-profiles=$SERVER_PROFILE_PATH", "-port=2302", "-dologs", "-adminlog", "-freezecheck", "-scrAllowFileWrite", "'-mod=$PROJECT_DRIVE\$OUTPUT_DIR;$ADDITIONAL_MODS'"
}

if ([bool]$PUBLIC_KEY_PATH -and (Test-Path $PUBLIC_KEY_PATH)) {
    Copy-Item $PUBLIC_KEY_PATH -Destination "$($LOCAL_DAYZ_SERVER_PATH)\keys" | Out-Null
}

if ((Test-Path $DAYZ_ROOT_PATH)) {
    Push-Location $DAYZ_ROOT_PATH
    Write-Host "Starting DayZ Client..."
    Start-Process -FilePath "$($DAYZ_ROOT_PATH)\DayZ_BE.exe" -ArgumentList "-connect=127.0.0.1", "-port=2302", "-nosplash", "-noPause", "-noBenchmark", "-doLogs", "-scriptDebug=true", "'-mod=$PROJECT_DRIVE\$OUTPUT_DIR;$ADDITIONAL_MODS'"
    Pop-Location
}