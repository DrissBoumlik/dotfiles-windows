
#region FUNCTIONS
# Function to download a file
$ProgressPreference = 'SilentlyContinue'
function Download-File {
    param ( [string]$url, [string]$output )
    Invoke-WebRequest -Uri $url -OutFile $output
}

function Make-Directory {
    param ( [string]$path )

    if (-not (Test-Path -Path $path -PathType Container)) {
        mkdir $path | Out-Null
    }
}

# Function to extract a zip file
function Extract-Zip {
    param ( [string]$zipPath, [string]$extractPath )
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $extractPath)
}

# Function to prompt
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
    param(
        [string]$newVariableName,
        [string]$newVariableValue,
        [boolean]$updatePath = 0
    )

    [System.Environment]::SetEnvironmentVariable($newVariableName, $newVariableValue, [System.EnvironmentVariableTarget]::Machine)
    if ($updatePath -eq 1) {
        Update-Path-Env-Variable -newVariableName $newVariableName
    }
}

function Update-Path-Env-Variable {
    param( [string]$newVariableName, [boolean]$isVarName = 1 )
    $currentPath = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine)
    if ($isVarName -eq 1) {
        $currentPath += ";%$newVariableName%"
    } else {
        $currentPath += ";$newVariableName"
    }
   
    [System.Environment]::SetEnvironmentVariable("PATH", $currentPath, [System.EnvironmentVariableTarget]::Machine)
}

function What-ToDo-Next {
    param( [PSCustomObject]$WhatWasDoneMessages = @() )

    if ($WhatWasDoneMessages.Count -gt 0) {
        Write-Host "=========================================================================================="
        Write-Host "`n  # Results :"
        foreach ($msg in $WhatWasDoneMessages) {
            $message = $msg.Message
            Write-Host "    $message" -ForegroundColor $msg.ForegroundColor -BackgroundColor $msg.BackgroundColor
        }
    }
    Write-Host "=========================================================================================="
    Write-Host "|| # TODOs :                                                                            ||"
    Write-Host "||  - Start cmder and Run to check for any updates : > clink update                     ||"
    Write-Host "||  - Start cmder and Run 'flexprompt configure' to customize the prompt style.         ||"
    Write-Host "||  - Install downloaded font and Add it to cmder settings.                             ||"
    Write-Host "||  - Run ./followup.ps1 for additional cmder configuration                             ||"
    Write-Host "=========================================================================================="
}
#endregion