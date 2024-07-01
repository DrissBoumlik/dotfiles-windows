
$ProgressPreference = 'SilentlyContinue'
function Download-File {
    param ( [string]$url, [string]$output )
    Invoke-WebRequest -Uri $url -OutFile $output
}

function Setup-Cmder {
    param ( [string]$downloadPath, [PSCustomObject]$WhatWasDoneMessages = @(), $overrideExistingEnvVars = "no" )
    #region DOWNLOAD CMDER
    Write-Host "`nDownloading & Extracting Cmder..."
    $cmderUrl = "https://github.com/cmderdev/cmder/releases/download/v1.3.25/cmder.zip"
    # $cmderUrl = "https://github.com/cmderdev/cmder/releases/download/v1.3.20/cmder_mini.zip" # TESTING
    Download-File -url $cmderUrl -output "$downloadPath\Cmder.zip"

    Extract-Zip -zipPath "$downloadPath\Cmder.zip" -extractPath "$downloadPath\Cmder"
    Remove-Item "$downloadPath\Cmder.zip"

    $cmderStuff = @(
        "$downloadPath\Cmder\vendor\git-for-windows\usr\bin",
        "$downloadPath\Cmder\vendor\bin",
        "$downloadPath\Cmder\vendor",
        "$downloadPath\Cmder\bin",
        "$downloadPath\Cmder"
    )
    $cmderStuff = $cmderStuff -join ";"
    Add-Env-Variable -newVariableName "cmder_stuff" -newVariableValue $cmderStuff -updatePath 1 -overrideExistingEnvVars $overrideExistingEnvVars
    #endregion

    #region DOWNLOAD & SETUP FLEXPROMPT
    Write-Host "`nDownloading & Extracting FlexPrompt..."
    # $flexPromptUrl = "https://github.com/AmrEldib/cmder-powerline-prompt/archive/master.zip"
    $flexPromptUrl = "https://github.com/chrisant996/clink-flex-prompt/releases/download/v0.17/clink-flex-prompt-0.17.zip"
    Download-File -url $flexPromptUrl -output "$downloadPath\flexprompt.zip"

    Extract-Zip -zipPath "$downloadPath\flexprompt.zip" -extractPath "$downloadPath\Cmder\config"
    Copy-Item -Path "$PWD\config\flexprompt_autoconfig.lua" -Destination "$downloadPath\Cmder\config"
    Remove-Item "$downloadPath\flexprompt.zip"
    #endregion

    #region DOWNLOAD & SETUP Z / ZOXIDE
    Write-Host "`nDownloading & Extracting Z..."
    $zUrl = "https://github.com/skywind3000/z.lua/archive/refs/heads/master.zip"
    Download-File -url $zUrl -output "$downloadPath\z.zip"

    Extract-Zip -zipPath "$downloadPath\z.zip" -extractPath $downloadPath
    Copy-Item -Path "$downloadPath\z.lua-master\z.lua", "$downloadPath\z.lua-master\z.cmd" -Destination "$downloadPath\Cmder\vendor"
    Remove-Item "$downloadPath\z.zip", "$downloadPath\z.lua-master" -Recurse
    #endregion
    
    #region DOWNLOAD & SETUP FZF
    Write-Host "`nDownloading & Extracting FZF..."
    $fzfUrl = "https://github.com/junegunn/fzf/releases/download/0.53.0/fzf-0.53.0-windows_amd64.zip"
    Download-File -url $fzfUrl -output "$downloadPath\fzf.zip"

    Extract-Zip -zipPath "$downloadPath\fzf.zip" -extractPath $downloadPath
    Copy-Item -Path "$downloadPath\fzf.exe" -Destination "$downloadPath\Cmder\bin"
    Copy-Item -Path "$downloadPath\fzf.exe" -Destination "$downloadPath\Cmder\vendor\bin"
    Remove-Item "$downloadPath\fzf.zip", "$downloadPath\fzf.exe" -Recurse
    #endregion
    
    $WhatWasDoneMessages += [PSCustomObject]@{
        Message = "- Cmder paths were added to the PATH variable"
        ForegroundColor = "Black"
        BackgroundColor = "Green"
    }
    $WhatWasDoneMessages += [PSCustomObject]@{
        Message = "- Cmder was successfully setup with (flexprompt, fzf and z) :)"
        ForegroundColor = "Black"
        BackgroundColor = "Green"
    }
    return $WhatWasDoneMessages
}

function Add-Alias-To-Cmder {
    param ( [string]$alias, [string]$downloadPath )
    $aliasFilePath = "$downloadPath\Cmder\config\user_aliases.cmd"
    Add-Content $alias -Path $aliasFilePath
}

function Make-Directory {
    param ( [string]$path )

    if (-not (Test-Path -Path $path -PathType Container)) {
        mkdir $path | Out-Null
    }
}

function Extract-Zip {
    param ( [string]$zipPath, [string]$extractPath )
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $extractPath)
}

function Prompt-YesOrNoWithDefault {
    param(
        [string]$message = "Do you want to continue? (yes/no)",
        [ValidateSet("yes", "no")]
        [string]$defaultOption = "no"
    )

    $promptMessage = "$message (Default: $defaultOption)"
    $response = Read-Host $promptMessage

    if ($response -eq "" -or $response -eq $defaultOption) {
        return $defaultOption
    } elseif ($response -eq "yes" -or $response -eq "y") {
        return "yes"
    } elseif ($response -eq "no" -or $response -eq "n") {
        return "no"
    } else {
        Write-Host "Invalid input. Please enter 'yes' or 'no'."
        return Prompt-YesOrNoWithDefault -message $message -defaultOption $defaultOption
    }
}

function Prompt-Quesiton {
    param( [string]$message )

    $promptMessage = "$message "
    $response = Read-Host $promptMessage
    
    return $response
}

function Add-Env-Variable {
    param( [string]$newVariableName, [string]$newVariableValue,
        [boolean]$updatePath = 0, $overrideExistingEnvVars = "no" )
    
    $existingVariableName = [System.Environment]::GetEnvironmentVariable($newVariableName, [System.EnvironmentVariableTarget]::Machine)
    if ($existingVariableName -eq $null -or $overrideExistingEnvVars -eq "yes") {
        [System.Environment]::SetEnvironmentVariable($newVariableName, $newVariableValue, [System.EnvironmentVariableTarget]::Machine)
    }

    if ($updatePath -eq 1) {
        Update-Path-Env-Variable -variableName $newVariableName
    }
}

function Update-Path-Env-Variable {
    param( [string]$variableName, [boolean]$isVarName = 1, [boolean]$remove = 0 )
    $currentPath = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine)
    if ($remove -eq 1) {
        $pathArray = $currentPath -split ";"
        if ($isVarName -eq 1) {
            $newPathArray = $pathArray | Where-Object { $_ -ne "%$variableName%" }
        } else {
            $newPathArray = $pathArray | Where-Object { $_ -ne "$variableName" }
        }
        $currentPath = ($newPathArray -join ";")
    } else {
        if ($isVarName -eq 1) {
            $currentPath += ";%$variableName%"
        } else {
            $currentPath += ";$variableName"
        }
    }
    [System.Environment]::SetEnvironmentVariable("PATH", $currentPath, [System.EnvironmentVariableTarget]::Machine)
}

function What-ToDo-Next {
    param( [PSCustomObject]$WhatWasDoneMessages = @(), [PSCustomObject]$WhatToDoNext = @() )

    if ($WhatWasDoneMessages.Count -gt 0) {
        Write-Host "`n==========================================================================================`n"
        Write-Host "   # Results :"
        foreach ($msg in $WhatWasDoneMessages) {
            $message = $msg.Message
            Write-Host "    $message " -ForegroundColor $msg.ForegroundColor -BackgroundColor $msg.BackgroundColor
        }
    }
    Write-Host "`n==========================================================================================`n"
    Write-Host "   # TODOs :"
    
    if ($WhatToDoNext.Count -gt 0) {
        foreach ($msg in $WhatToDoNext) {
            $message = $msg.Message
            Write-Host "    $message " -ForegroundColor $msg.ForegroundColor -BackgroundColor $msg.BackgroundColor
        }
    }
    
    Write-Host "    - Run ./followup.ps1 when you're done for additional cmder configuration"
    Write-Host "`n==========================================================================================`n"
    Write-Host "`nAll tasks completed.`n`n"
}
