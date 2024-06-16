
#region FUNCTIONS
# Function to download a file
function Download-File {
    param (
        [string]$url,
        [string]$output
    )
    Invoke-WebRequest -Uri $url -OutFile $output
}

function Make-Directory {
    param ( [string]$path )

    if (-not (Test-Path -Path $path -PathType Container)) {
        mkdir $path
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
    param(
        [string]$message
    )

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
        $currentPath = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine)
        $currentPath += ";%$newVariableName%"
        [System.Environment]::SetEnvironmentVariable("PATH", $currentPath, [System.EnvironmentVariableTarget]::Machine)
    }
}

function What-ToDo-Next {
    param( [string]$stepsResult="" )
    if (-not($stepsResult -eq "" -or $stepsResult -eq "`n")) {
        Write-Host "=========================================================================================="
        Write-Host "`n  # Results :"
        Write-Host "$WhatWasDoneMessage"
    }
    Write-Host "=========================================================================================="
    Write-Host "|| # TODOs :                                                                            ||"
    Write-Host "||  - Run to check for any updates : > clink update                                     ||"
    Write-Host "||  - Install downloaded font and Add it to cmder settings.                             ||"
    Write-Host "||  - Start cmder and Run 'flexprompt configure' to customize the prompt style.         ||"
    Write-Host "||  - Rename Cmder\vendor\conemu-maximus5\ConEmu.xml.bak to ConEmu.xml :                ||"
    Write-Host "||  - Complete nvm installation                                                         ||"
    Write-Host "=========================================================================================="
}
#endregion


#region SETUP THE CONTAINER DIRECTORY
# Set the download paths
$downloadPath = Prompt-Quesiton -message "Indicate the target directory (C:\[Container])"
$downloadPath = "C:\$downloadPath"
$personalEnvPath = Prompt-Quesiton -message "Indicate the personal env path directory (D:\[env])"
# $personalEnvPath = "D:\$personalEnvPath" 

# Create the download directory if it doesn't exist
if (!(Test-Path -Path $downloadPath)) {
    New-Item -ItemType Directory -Force -Path $downloadPath
}
#endregion

$WhatWasDoneMessage = ""

#region DOWNLOAD GIT
try {
    Write-Host "`nDownloading Git..."
    $gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.45.2.windows.1/Git-2.45.2-64-bit.exe"
    Download-File -url $gitUrl -output "$downloadPath\Git-2.45.2-64-bit.exe"
    $WhatWasDoneMessage = "$WhatWasDoneMessage    - Git was downloaded successfully, you need to install it manually :)`n"
}
catch {
    $WhatWasDoneMessage = "$WhatWasDoneMessage    - Git failed to download, try later :(`n"
}
#endregion

#region DOWNLOAD COMPOSER
try {
    Write-Host "`nDownloading Composer..."
    $composerUrl = "https://getcomposer.org/Composer-Setup.exe"
    Download-File -url $composerUrl -output "$downloadPath\Composer-Setup.exe"
    $WhatWasDoneMessage = "$WhatWasDoneMessage    - Composer was downloaded successfully, you need to install it manually :)`n"
}
catch {
    $WhatWasDoneMessage = "$WhatWasDoneMessage    - Composer failed to download, try later :(`n"
}
#endregion

#region SETUP CMDER
if (Test-Path -Path "$downloadPath\Cmder" -PathType Container) {
    Write-Host "The directory "$downloadPath\Cmder" already exists !!"
    $response = Prompt-YesOrNoWithDefault -message "Do you want to proceed?"
    if ($response -eq "no" -or $response -eq "n") {
        exit
    } else {
        # GARBAGE COLLECTION =====================================
        Remove-Item -Path "$downloadPath\Cmder" -Recurse -Force
    }
}

try {
    #region DOWNLOAD CMDER
    Write-Host "`nDownloading Cmder..."
    $cmderUrl = "https://github.com/cmderdev/cmder/releases/download/v1.3.25/cmder.zip"
    # $cmderUrl = "https://github.com/cmderdev/cmder/releases/download/v1.3.20/cmder_mini.zip" # TESTING
    Download-File -url $cmderUrl -output "$downloadPath\Cmder.zip"

    Write-Host "`nExtracting Cmder..."
    Extract-Zip -zipPath "$downloadPath\Cmder.zip" -extractPath "$downloadPath\Cmder"
    Remove-Item "$downloadPath\Cmder.zip"
    Copy-Item -Path "$PWD\config\ConEmu.xml" -Destination "$downloadPath\Cmder\vendor\conemu-maximus5\ConEmu.xml.bak" 

    Write-Host "`nCmder\vendor\git-for-windows\usr\bin and Cmder\vendor\bin were added to the PATH variable"
    Add-Env-Variable -newVariableName "linux_cmd" -newVariableValue "$downloadPath\Cmder\vendor\git-for-windows\usr\bin;$downloadPath\Cmder\vendor\bin" -updatePath 1
    #endregion
    
    #region ADD CUSTOM ALIASES
    Write-Host "`nAdding Custom Aliases..."
    # Get-Content -Path "$PWD\config\user_aliases.txt" | Add-Content -Path "$downloadPath\Cmder\config\user_aliases.cmd.bak"
    Copy-Item -Path "$PWD\config\user_aliases.cmd" -Destination "$downloadPath\Cmder\config\user_aliases.cmd.bak" 
    #endregion

    #region DOWNLOAD & SETUP FLEXPROMPT
    Write-Host "`nDownloading FlexPrompt..."
    # $flexPromptUrl = "https://github.com/AmrEldib/cmder-powerline-prompt/archive/master.zip"
    $flexPromptUrl = "https://github.com/chrisant996/clink-flex-prompt/releases/download/v0.17/clink-flex-prompt-0.17.zip"
    Download-File -url $flexPromptUrl -output "$downloadPath\flexprompt.zip"

    Write-Host "`nExtracting FlexPrompt..."
    Extract-Zip -zipPath "$downloadPath\flexprompt.zip" -extractPath "$downloadPath\Cmder\config"
    Remove-Item "$downloadPath\flexprompt.zip"
    Copy-Item -Path "$PWD\config\flexprompt_autoconfig.lua" -Destination "$downloadPath\Cmder\config"
    #endregion

    #region DOWNLOAD & SETUP Z
    Write-Host "`nDownloading Z..."
    # $zUrl = "https://raw.githubusercontent.com/rupa/z/master/z.sh"
    $zUrl = "https://github.com/skywind3000/z.lua/archive/refs/heads/master.zip"
    Download-File -url $zUrl -output "$downloadPath\z.zip"

    Write-Host "`nExtracting Z..."
    Extract-Zip -zipPath "$downloadPath\z.zip" -extractPath $downloadPath
    Copy-Item -Path "$downloadPath\z.lua-master\z.lua", "$downloadPath\z.lua-master\z.cmd" -Destination "$downloadPath\Cmder\vendor"
    Remove-Item "$downloadPath\z.zip", "$downloadPath\z.lua-master" -Recurse
    #endregion
    
    $WhatWasDoneMessage = "$WhatWasDoneMessage    - Cmder was successfully setup with (aliases, flexprompt, and z) :)`n"
}
catch {
    $WhatWasDoneMessage = "$WhatWasDoneMessage    - Issue with downloading/installing cmder :(`n"
}
#endregion

#region DOWNLOAD FONTS
try {
    Write-Host "`nDownloading Font..."
    $nfUrls = @(
        # "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS NF Regular.ttf",
        # "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS NF Bold.ttf",
        # "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS NF Italic.ttf",
        # "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS NF Bold Italic.ttf",
        
        "https://github.com/powerline/fonts/blob/master/AnonymousPro/Anonymice Powerline Bold Italic.ttf",
        "https://github.com/powerline/fonts/blob/master/AnonymousPro/Anonymice Powerline Bold.ttf",
        "https://github.com/powerline/fonts/blob/master/AnonymousPro/Anonymice Powerline Italic.ttf",
        "https://github.com/powerline/fonts/blob/master/AnonymousPro/Anonymice Powerline.ttf"
    )
    Make-Directory -path "$downloadPath\fonts"
    foreach ($url in $nfUrls) {
        $fileName = Split-Path $url -Leaf
        Download-File -url $url -output "$downloadPath\fonts\$fileName"
    }
    $WhatWasDoneMessage = "$WhatWasDoneMessage    - Fonts downloaded successfully :)`n"
}
catch {
    $WhatWasDoneMessage = "$WhatWasDoneMessage    - Fonts failed to download :(`n"
}
#endregion

#region DOWNLOAD MULTIPLE PHP VERSIONS
try {
    Write-Host "`nDownloading PHP versions..."
    $phpUrls = @(
        # "https://windows.php.net/downloads/releases/archives/php-5.6.9-Win32-VC11-x64.zip",
        # "https://windows.php.net/downloads/releases/archives/php-7.0.9-Win32-VC14-x64.zip",
        # "https://windows.php.net/downloads/releases/archives/php-7.1.9-Win32-VC14-x64.zip",
        # "https://windows.php.net/downloads/releases/archives/php-7.2.9-Win32-VC15-x64.zip",
        # "https://windows.php.net/downloads/releases/archives/php-7.3.9-Win32-VC15-x64.zip",
        # "https://windows.php.net/downloads/releases/archives/php-7.4.9-Win32-vc15-x64.zip",
        "https://windows.php.net/downloads/releases/archives/php-8.0.9-Win32-vs16-x64.zip",
        "https://windows.php.net/downloads/releases/archives/php-8.1.9-Win32-vs16-x64.zip",
        "https://windows.php.net/downloads/releases/archives/php-8.2.9-Win32-vs16-x64.zip",
        "https://windows.php.net/downloads/releases/php-8.3.8-Win32-vs16-x64.zip"
    )
    Make-Directory -path "$downloadPath\$personalEnvPath"
    Make-Directory -path "$downloadPath\$personalEnvPath\zip"
    Make-Directory -path "$downloadPath\$personalEnvPath\php"
    $phpIndex = -1
    $phpEnvVarName = ""
    foreach ($url in $phpUrls) {
        $fileName = Split-Path $url -Leaf
        $fileName = $fileName -replace ".zip", ""
        Download-File -url $url -output "$personalEnvPath\zip\$fileName"
        Extract-Zip -zipPath "$personalEnvPath\zip\$fileName" -extractPath "$personalEnvPath\php\$fileName"
        $phpEnvVarName = $phpIndex
        $phpIndex--
        if ($fileName -match "php-(\d+)\.(\d+)\.") {
            $majorVersion = $matches[1]
            $minorVersion = $matches[2]
            if ($minorVersion -eq '0') {
                $phpEnvVarName = $majorVersion
            } else {
                $phpEnvVarName = "$majorVersion$minorVersion"
            }
        }
        $phpEnvVarName = "php$phpEnvVarName"
        Add-Env-Variable -newVariableName $phpEnvVarName -newVariableValue "$personalEnvPath\php\$fileName" -updatePath 0
    }
    Add-Env-Variable -newVariableName "php_now" -newVariableValue "$downloadPath\$personalEnvPath\php\$fileName" -updatePath 1
    Remove-Item -Path "$downloadPath\$personalEnvPath\zip" -Recurse -Force
    $WhatWasDoneMessage = "$WhatWasDoneMessage    - PHP versions downloaded & setup successfully :)`n"
}
catch {
    $WhatWasDoneMessage = "$WhatWasDoneMessage    - PHP versions failed to download/setup :(`n"
}
#endregion

#region DOWNLOAD XDEBUG
try {
    Write-Host "`nDownloading XDEBUG..."
    $xdebugUrls = @(
        # "https://xdebug.org/files/php_xdebug-3.3.2-8.3-vs16-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-3.3.2-8.2-vs16-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-3.3.2-8.1-vs16-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-3.3.2-8.0-vs16-x86_64.dll",
        
        # "https://xdebug.org/files/php_xdebug-3.3.1-8.3-vs16-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-3.3.1-8.2-vs16-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-3.3.1-8.1-vs16-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-3.3.1-8.0-vs16-x86_64.dll",
        
        # "https://xdebug.org/files/php_xdebug-3.3.0-8.3-vs16-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-3.3.0-8.2-vs16-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-3.3.0-8.1-vs16-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-3.3.0-8.0-vs16-x86_64.dll",
        
        # "https://xdebug.org/files/php_xdebug-3.2.2-8.2-vs16-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-3.2.2-8.1-vs16-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-3.2.2-8.0-vs16-x86_64.dll",
        
        # "https://xdebug.org/files/php_xdebug-3.1.6-8.1-vs16-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-3.1.6-8.0-vs16-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-3.1.6-7.4-vc15-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-3.1.6-7.3-vc15-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-3.1.6-7.2-vc15-x86_64.dll",
        
        # "https://xdebug.org/files/php_xdebug-3.0.4-8.0-vs16-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-3.0.4-7.4-vc15-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-3.0.4-7.3-vc15-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-3.0.4-7.2-vc15-x86_64.dll",
    
        # "https://xdebug.org/files/php_xdebug-2.9.8-7.4-vc15-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-2.9.8-7.3-vc15-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-2.9.8-7.2-vc15-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-2.9.8-7.1-vc14-x86_64.dll",
    
        # "https://xdebug.org/files/php_xdebug-2.8.0-7.4-vc15-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-2.8.0-7.3-vc15-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-2.8.0-7.2-vc15-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-2.8.0-7.1-vc14-x86_64.dll",
        
        # "https://xdebug.org/files/php_xdebug-2.7.0-7.3-vc15-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-2.7.0-7.2-vc15-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-2.7.0-7.1-vc14-x86_64.dll",
    
        # "https://xdebug.org/files/php_xdebug-2.6.0-7.2-vc15-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-2.6.0-7.1-vc14-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-2.6.0-7.0-vc14-x86_64.dll",
        
        # "https://xdebug.org/files/php_xdebug-2.5.5-7.1-vc14-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-2.5.5-7.0-vc14-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-2.5.5-5.6-vc11-x86_64.dll",
        
        # "https://xdebug.org/files/php_xdebug-2.5.0-7.1-vc14-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-2.5.0-7.0-vc14-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-2.5.0-5.6-vc11-x86_64.dll",
        
        # "https://xdebug.org/files/php_xdebug-2.4.0-7.0-vc14-x86_64.dll",
        # "https://xdebug.org/files/php_xdebug-2.4.0-5.6-vc11-x86_64.dll",
        
        "https://xdebug.org/files/php_xdebug-2.3.3-5.6-vc11-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-2.3.2-5.6-vc11-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-2.3.1-5.6-vc11-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-2.3.0-5.6-vc11-x86_64.dll"
    )
    Make-Directory -path "$downloadPath\$personalEnvPath\xdebug"
    foreach ($url in $xdebugUrls) {
        $fileName = Split-Path $url -Leaf
        $outputPathXdebug = "$downloadPath\$personalEnvPath\xdebug\$fileName"
        if ($fileName -match "-(\d+\.\d+)-(vs|vc)") {
            $phpVersion = $matches[1]
            $phpVersionDir = "$downloadPath\$personalEnvPath\xdebug\$phpVersion"
            Make-Directory -path $phpVersionDir
            $outputPathXdebug = "$downloadPath\$personalEnvPath\xdebug\$phpVersion\$fileName"
        }
        Download-File -url $url -output $outputPathXdebug
    }
    $WhatWasDoneMessage = "$WhatWasDoneMessage    - XDEBUG versions downloaded & setup successfully :)`n"
}
catch {
    $WhatWasDoneMessage = "$WhatWasDoneMessage    - XDEBUG versions failed to download/setup :(`n"
}
#endregion

#region DOWNLOAD & INSTALL NVM
try {
    # check the GitHub releases page for the latest version
    Write-Host "`nDownloading NVM executable..."
    $nvmUrl = "https://github.com/coreybutler/nvm-windows/releases/download/1.1.12/nvm-setup.exe"
    Download-File -url $nvmUrl -output "$downloadPath\nvm-setup.exe"
    $WhatWasDoneMessage = "$WhatWasDoneMessage    - NVM was downloaded successfully, you need to install it manually :)`n"
}
catch {
    $WhatWasDoneMessage = "$WhatWasDoneMessage    - NVM failed to download, try later :(`n"
}
#endregion

#region DOWNLOAD AND INSTALL CHOCOLATEY
try {
    Write-Host "`nDownloading and installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1"))
    $WhatWasDoneMessage = "$WhatWasDoneMessage    - Chocolatey was installed successfully :)`n"
}
catch {
    $WhatWasDoneMessage = "$WhatWasDoneMessage    - Chocolatey failed to install, try later :(`n"
}
#endregion

#region WHAT TO DO NEXT
What-ToDo-Next
#endregion

Write-Host "`nAll tasks completed.`n`n"
