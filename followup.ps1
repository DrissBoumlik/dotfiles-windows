
. ./functions.ps1

$overrideExistingEnvVars = Prompt-YesOrNoWithDefault -message "`nWould you like to override the existing environment variables"

#region ADD DELTA TO GIT CONFIG
$response = Prompt-YesOrNoWithDefault -message "`nDid you already install git?"
if ($response -eq "yes" -or $response -eq "y") {
    $deltaGitConfig = @"

    # DELTA CONFIG FOR git diff
    [core]
        pager = delta

    [interactive]
        diffFilter = delta --color-only

    [delta]
        navigate = true    
        # use n and N to move between diff sections
        features = collared-trogon
        side-by-side = true
        line-numbers = true
        line-numbers-left-format = ""
        line-numbers-right-format = "│ "

        # delta detects terminal colors automatically; set one of these to disable auto-detection
        # dark = true
        # light = true

    [merge]
        conflictstyle = diff3

    [diff]
        colorMoved = default
"@
    $deltaGitConfig = $deltaGitConfig -replace "\ +"
    Add-Content -Path "~/.gitconfig" -Value $deltaGitConfig

    Write-Host "`n- Delta was added to ~/.gitconfig successfully :)" -ForegroundColor Black -BackgroundColor Green
} else {
    Write-Host "`n- You should install git before continuing..." -ForegroundColor Black -BackgroundColor Yellow
}
#endregion

#region COPY CMDER CONFIG & ALIASES
$response = Prompt-YesOrNoWithDefault -message "Did you already start cmder?"
if ($response -eq "yes" -or $response -eq "y") {
    $downloadPath = Prompt-Quesiton -message "`nIndicate the target directory (C:\[Container])"
    $downloadPath = "C:\$downloadPath"
    Copy-Item -Path "$PWD\config\ConEmu.xml" -Destination "$downloadPath\Cmder\vendor\conemu-maximus5\ConEmu.xml" 
    Get-Content -Path "$PWD\config\user_aliases.cmd" | Add-Content -Path "$downloadPath\Cmder\config\user_aliases.cmd"

    Make-Directory "$downloadPath\env\tools"
    Copy-Item -Path "$PWD\config\set-env.bat" -Destination "$downloadPath\env\tools\set-env.bat"
    Add-Content "setvar=""$downloadPath\env\tools\set-env.bat"" `$1 `$2 && RefreshEnv.cmd" -Path "$downloadPath\Cmder\config\user_aliases.cmd"
    $directories = Get-ChildItem -Path "C:\" -Directory -ErrorAction SilentlyContinue -Force | Where-Object { $_.Name -match 'xampp' }
    if ($directories.Count -gt 0) {
        $xamppPath = ($directories | Select-Object -First 1).FullName
        Add-Content "phpxmp=""$xamppPath\php\php.exe"" $*" -Path "$downloadPath\Cmder\config\user_aliases.cmd"
    }
    $phpPaths = Get-ChildItem -Path "$downloadPath\env\php_stuff\php" -Directory | Select-Object -ExpandProperty Name
    if ($phpPaths.Count -gt 0) {
        foreach ($phpPath in $phpPaths) {
            if ($phpPath -match "php-(\d+)\.(\d+)\.") {
                $majorVersion = $matches[1]
                $minorVersion = $matches[2]
                if ($minorVersion -eq '0') {
                    $phpVersion = $majorVersion
                } else {
                    $phpVersion = "$majorVersion$minorVersion"
                }
                Add-Content "php$phpVersion=""$downloadPath\env\php_stuff\php\$phpPath\php.exe"" $*" -Path "$downloadPath\Cmder\config\user_aliases.cmd"
            }
        }
    }
    
    $phpToolsPaths = Get-ChildItem -Path "$downloadPath\env\php_stuff\tools" -File -Filter "*.phar"
    if ($phpToolsPaths.Count -gt 0) {
        foreach ($phpToolPath in $phpToolsPaths) {
            $fileName = $phpToolPath.BaseName
            Add-Content "$fileName=php ""$downloadPath\env\php_stuff\tools\$fileName.phar"" $*" -Path "$downloadPath\Cmder\config\user_aliases.cmd"
        }
    }

    
    $response = Prompt-YesOrNoWithDefault -message "Did you download less?"
    if ($response -eq "yes" -or $response -eq "y") {
        $lessCmderPath = "Cmder\vendor\git-for-windows\usr\bin"
        Move-Item -Path "$downloadPath\$lessCmderPath\less.exe" -Destination "$downloadPath\$lessCmderPath\less.exe.bak"
        Move-Item -Path "$downloadPath\$lessCmderPath\lesskey.exe" -Destination "$downloadPath\$lessCmderPath\lesskey.exe.bak"
        Copy-Item "$downloadPath\env\tools\less\less.exe", "$downloadPath\env\tools\less\lesskey.exe" -Destination "$downloadPath\$lessCmderPath\"
        Write-Host "`n- Less was replaced in 'Cmder\vendor\git-for-windows\usr\bin'" -ForegroundColor Black -BackgroundColor Green
    }

    Write-Host "`n- ConEmu.xml & user_aliases.cmd were added to Cmder successfully :)" -ForegroundColor Black -BackgroundColor Green
} else {
    Write-Host "`n- You should start cmder before continuing..." -ForegroundColor Black -BackgroundColor Yellow
}
#endregion

#region ADD PHP ENVIRONMENT VARIABLE TO THE PATH
$response = Prompt-YesOrNoWithDefault -message "`nDid you already install Xampp & Composer?"
if ($response -eq "yes" -or $response -eq "y") {
    $directories = Get-ChildItem -Path "C:\" -Directory -ErrorAction SilentlyContinue -Force | Where-Object { $_.Name -match 'xampp' }
    if ($directories.Count -gt 0) {
        $xamppPath = ($directories | Select-Object -First 1).FullName
        Update-Path-Env-Variable -variableName  "$xamppPath\php" -isVarName 0 -remove 1
        Add-Env-Variable -newVariableName "phpxmp" -newVariableValue "$xamppPath\php" -updatePath 0 -overrideExistingEnvVars $overrideExistingEnvVars
        Add-Env-Variable -newVariableName "php_now" -newVariableValue "$xamppPath\php" -updatePath 1 -overrideExistingEnvVars $overrideExistingEnvVars
        Add-Env-Variable -newVariableName "mysql_stuff" -newVariableValue "$xamppPath\mysql\bin" -updatePath 1 -overrideExistingEnvVars $overrideExistingEnvVars
        # Copy composer version 1 to the composer path
        Copy-Item -Path "$PWD\composer-v1" -Destination "C:\composer\v1" -Recurse
        Update-Path-Env-Variable -variableName "C:\composer\v1" -isVarName 0

        Write-Host "`nThe 'php_now', 'mysql_stuff' & 'phpxmp' 'composer1' variables were successfully added to the PATH :)" -ForegroundColor Black -BackgroundColor Green
    } else {
        Write-Host "`nNo XAMPP directories found. :(" -ForegroundColor Black -BackgroundColor Yellow
    }
} else {
    Write-Host "`nYou should install Xampp & Composer before continuing..." -ForegroundColor Black -BackgroundColor Yellow
    exit
}
#endregion

Write-Host "`nAll tasks completed.`n`n"
