<#
=========================================================================

Name: Build
Description: Packages DayZ SA project into PBOs via pboProject by Mikero

Author: Wardog (wrdg)
Credits: Jacob_Mango (DSSignFile method instead of pboProject key assign)

=========================================================================
#>

. "$PSScriptRoot\userconfig.ps1" # IMPORT USER CONFIG VARIABLES

# DO NOT CHANGE THESE VARIABLES
$OUTPUT_DIR = "$PROJECT_DRIVE\$OUTPUT_DIR\"
$MOD_PROJECT_LINK = "$PROJECT_DRIVE\$PROJECT_PREFIX\"
$PROJECT_SRC = "$PSScriptRoot\src\"
$MISSING_MIKERO_TOOLS = $false
$MIKEROS_TOOLS_REQ = @(
    "Rapify",
    "MakePbo",
    "DeWss",
    "pboProject"
)

# CHECKS FOR MIKERO'S TOOLS
foreach ($tool in $MIKEROS_TOOLS_REQ) {
    $toolPath = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Mikero\$tool" -Name "exe" -ErrorAction SilentlyContinue).exe # CHECK NEW REGISTRY KEY
    if (![bool]$toolPath) {
        $toolPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Mikero\$tool" -Name "exe" -ErrorAction SilentlyContinue).exe # CHECK OLD REGISTRY KEY

        if (![bool]$toolPath -or !(Test-Path $toolPath)) {
            $MISSING_MIKERO_TOOLS = $true
            Write-Host "Missing Required Tool: $tool" -ForegroundColor Red
        }
    }

    if ($tool -eq "pboProject") {
        $PBOPROJECT_EXECUTABLE = $toolPath
    }
}

if ($MISSING_MIKERO_TOOLS) {
    Write-Host "`nDownload and install the tools from Mikero's site: https://mikero.bytex.digital/Downloads/"
    Exit 1
}

# CHECK FOR DAYZ TOOLS
$DAYZ_TOOLS_PATH = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Bohemia Interactive\Dayz Tools" -Name "path" -ErrorAction SilentlyContinue).path # CHECK NEW REGISTRY KEY
if (![bool]$DAYZ_TOOLS_PATH) {
    if (![bool]$DAYZ_TOOLS_PATH -or !(Test-Path $DAYZ_TOOLS_PATH)) {
        Write-Host "Missing DayZ Tools!" -ForegroundColor Red

        Start-Process "steam://install/830640" # ATTEMPT TO INSTALL DAYZ TOOLS
        Write-Host "`nAttempting to install DayZ Tools via Steam..."
        Exit 1
    }
}

# PROJECT REQUIREMENTS CHECK
if (![bool]$PROJECT_DRIVE -or !(Test-Path $PROJECT_DRIVE)) {
    Write-Host "Project Drive could NOT be found!" -ForegroundColor Red
    Exit 1
}

$PRIVATE_KEY_PATH = Resolve-Path -Path $PRIVATE_KEY_PATH -ErrorAction SilentlyContinue # RESOLVE TO ABSOLUTE PATH
if ([bool]$PRIVATE_KEY_PATH -or !(Test-Path $PRIVATE_KEY_PATH -ErrorAction Stop)) {
    Write-Host "Private key could NOT be found!" -ForegroundColor Red
    Exit 1
}

$PUBLIC_KEY_PATH = Resolve-Path -Path $PUBLIC_KEY_PATH -ErrorAction SilentlyContinue
if ([bool]$PUBLIC_KEY_PATH -or !(Test-Path $PUBLIC_KEY_PATH -ErrorAction Stop)) {
    Write-Host "Public key could NOT be found!" -ForegroundColor Red
    Exit 1
}

$DSSIGNFILE_EXECUTABLE = "$DAYZ_TOOLS_PATH\Bin\DsUtils\DSSignFile.exe"
if (!(Test-Path $DSSIGNFILE_EXECUTABLE)) {
    Write-Host "DSSignFile could NOT be found!" -ForegroundColor Red
    Exit 1
}

# CREATE SYMBOLIC LINK TO PROJECT DRIVE
if (![bool]$MOD_PROJECT_LINK -or !(Test-Path $MOD_PROJECT_LINK)) {
    $PROJECT_SRC = Resolve-Path -Path $PROJECT_SRC -ErrorAction SilentlyContinue
    Write-Host "Creating symbolic link for '$PROJECT_PREFIX' to the project drive..."
    Invoke-Expression "CMD /C MKLINK /J $MOD_PROJECT_LINK $PROJECT_SRC" -ErrorAction Stop | Out-Null
}

Remove-Item $OUTPUT_DIR -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue # REMOVE OLD CONTENTS FIRST

if ($MOD_PROJECT_LINK -and (Test-Path $MOD_PROJECT_LINK -ErrorAction Stop)) {
    Write-Host "Packaging '$PROJECT_PREFIX'... " -NoNewline
    New-Item -ItemType Directory -Force -Path $OUTPUT_DIR | Out-Null # CREATE OUTPUT DIRECTORY IF NON-EXISTENT
    $PBOPROJECT_PROCESS = Start-Process -FilePath $PBOPROJECT_EXECUTABLE -ArgumentList "$MOD_PROJECT_LINK", "-Mod=$OUTPUT_DIR", "-F", "-P", "-Engine=dayz", "-Key", "+Clean", "+Restore" -PassThru -Wait -ErrorAction Stop

    if ($PBOPROJECT_PROCESS.ExitCode -eq 0) {
        Write-Host "success!" -ForegroundColor Green

        if ([bool]$PUBLIC_KEY_PATH -and (Test-Path $PUBLIC_KEY_PATH)) {
            Get-ChildItem -Path "$OUTPUT_DIR\Addons\*" -Include *.pbo | ForEach-Object {
                Write-Host "Signing '$($_.Name)'... " -NoNewline
                $SIGNFILE_PROCESS = Start-Process -FilePath $DSSIGNFILE_EXECUTABLE -ArgumentList "$PRIVATE_KEY_PATH", "$_" -PassThru -Wait -ErrorAction Stop # SIGN EACH PBO

                if ($SIGNFILE_PROCESS.ExitCode -eq 0) {
                    Write-Host "success!" -ForegroundColor Green
                    return # HONESTLY THIS IS DUMB, THIS IS HOW YOU GO TO THE TOP OF A LOOP IN FOREACH-OBJECT, WHY NOT 'CONTINUE'?
                }

                Write-Host "fail!" -ForegroundColor Red
            }

            # COPY OVER THE PUBLIC KEY
            New-Item -ItemType Directory -Force -Path "$OUTPUT_DIR\Keys" | Out-Null
            Copy-Item $PUBLIC_KEY_PATH -Destination "$OUTPUT_DIR\Keys" | Out-Null
        }

        if ($REVEAL_COMPLETE) {
            Invoke-Item $MOD_PROJECT_LINK -ErrorAction SilentlyContinue
        }

        switch ($LAUNCH_AFTER_BUILD) {
            1 {
                Invoke-Expression ".\launchoffline.ps1"
            }
            2 {
                Invoke-Expression ".\launchlocalmp.ps1"
            }
        }
    }
    else {
        Write-Host "fail!`nAn error occured with pboProject! Check the packing/bin logs in '$PROJECT_DRIVE\Temp\'" -ForegroundColor Red
        Invoke-Item "$PROJECT_DRIVE\Temp\" -ErrorAction SilentlyContinue
        Exit 1
    }
}