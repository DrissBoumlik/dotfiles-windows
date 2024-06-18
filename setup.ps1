
. ./functions.ps1

function Setup-Cmder {
    param ( [string]$downloadPath, [PSCustomObject]$WhatWasDoneMessages = @() )
    #region DOWNLOAD CMDER
    Write-Host "`nDownloading & Extracting Cmder..."
    $cmderUrl = "https://github.com/cmderdev/cmder/releases/download/v1.3.25/cmder.zip"
    # $cmderUrl = "https://github.com/cmderdev/cmder/releases/download/v1.3.20/cmder_mini.zip" # TESTING
    Download-File -url $cmderUrl -output "$downloadPath\Cmder.zip"

    Extract-Zip -zipPath "$downloadPath\Cmder.zip" -extractPath "$downloadPath\Cmder"
    Remove-Item "$downloadPath\Cmder.zip"

    Add-Env-Variable -newVariableName "linux_cmd" -newVariableValue "$downloadPath\Cmder\vendor\git-for-windows\usr\bin;$downloadPath\Cmder\vendor\bin" -updatePath 1
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

    #region DOWNLOAD & SETUP Z
    Write-Host "`nDownloading & Extracting Z..."
    $zUrl = "https://github.com/skywind3000/z.lua/archive/refs/heads/master.zip"
    Download-File -url $zUrl -output "$downloadPath\z.zip"

    Extract-Zip -zipPath "$downloadPath\z.zip" -extractPath $downloadPath
    Copy-Item -Path "$downloadPath\z.lua-master\z.lua", "$downloadPath\z.lua-master\z.cmd" -Destination "$downloadPath\Cmder\vendor"
    Remove-Item "$downloadPath\z.zip", "$downloadPath\z.lua-master" -Recurse
    #endregion
    $WhatWasDoneMessages += [PSCustomObject]@{
        Message = "- Cmder\vendor\git-for-windows\usr\bin and Cmder\vendor\bin were added to the PATH variable"
        ForegroundColor = "Black"
        BackgroundColor = "Green"
    }
    $WhatWasDoneMessages += [PSCustomObject]@{
        Message = "- Cmder was successfully setup with (flexprompt, and z) :)"
        ForegroundColor = "Black"
        BackgroundColor = "Green"
    }
    return $WhatWasDoneMessages
}

#region SETUP THE CONTAINER DIRECTORY
# Set the download paths
$downloadPath = Prompt-Quesiton -message "Indicate the target directory (C:\[Container])"
$downloadPath = "C:\$downloadPath"
$personalEnvPath = Prompt-Quesiton -message "Indicate the personal env path directory (C:\[Container]\[env])"
# $personalEnvPath = "D:\$personalEnvPath" 

# Create the download directory if it doesn't exist
if (!(Test-Path -Path $downloadPath)) {
    New-Item -ItemType Directory -Force -Path $downloadPath
}
#endregion

$WhatWasDoneMessages = @()

#region DOWNLOAD GIT
try {
    Write-Host "`nDownloading Git..."
    $gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.45.2.windows.1/Git-2.45.2-64-bit.exe"
    Download-File -url $gitUrl -output "$downloadPath\1-Git-2.45.2-64-bit.exe"
    $WhatWasDoneMessages += [PSCustomObject]@{
        Message = "- Git was downloaded successfully, you need to install it manually :)"
        ForegroundColor = "Black"
        BackgroundColor = "Green"
    }
}
catch {
    $WhatWasDoneMessages += [PSCustomObject]@{
        Message = "- Git failed to download, try later :("
        ForegroundColor = "Black"
        BackgroundColor = "Red"
    }
}
#endregion

#region DOWNLOAD XAMPP
try {
    Write-Host "`nDownloading Xampp..."
    $XamppUrl = "https://deac-fra.dl.sourceforge.net/project/xampp/XAMPP%20Windows/8.2.12/xampp-windows-x64-8.2.12-0-VS16-installer.exe?viasf=1"
    Download-File -url $XamppUrl -output "$downloadPath\2-xampp-windows-x64-8.2.12-0-VS16-installer.exe"
    $WhatWasDoneMessages += [PSCustomObject]@{
        Message = "- Xampp was downloaded successfully, you need to install it manually :)"
        ForegroundColor = "Black"
        BackgroundColor = "Green"
    }
}
catch {
    $WhatWasDoneMessages += [PSCustomObject]@{
        Message = "- Xampp failed to download, try later :("
        ForegroundColor = "Black"
        BackgroundColor = "Red"
    }
}
#endregion

#region DOWNLOAD COMPOSER
try {
    Write-Host "`nDownloading Composer..."
    $composerUrl = "https://getcomposer.org/Composer-Setup.exe"
    Download-File -url $composerUrl -output "$downloadPath\3-Composer-Setup.exe"
    
    # Copy composer version 1 to the composer path
    Copy-Item -Path "$PWD\composer-v1" -Destination "C:\composer\v1" -Recurse
    Update-Path-Env-Variable -newVariableName "$downloadPath\composer\v1" -isVarName 0

    $WhatWasDoneMessages += [PSCustomObject]@{
        Message = "- Composer was downloaded successfully, you need to install it manually :)"
        ForegroundColor = "Black"
        BackgroundColor = "Green"
    }
}
catch {
    $WhatWasDoneMessages += [PSCustomObject]@{
        Message = "- Composer failed to download, try later :("
        ForegroundColor = "Black"
        BackgroundColor = "Red"
    }
}
#endregion

#region SETUP CMDER
try {
    if (Test-Path -Path "$downloadPath\Cmder" -PathType Container) {
        Write-Host "The directory "$downloadPath\Cmder" already exists !!"
        $response = Prompt-YesOrNoWithDefault -message "Do you want to proceed?"
        if ($response -eq "yes" -or $response -eq "y") {
            # GARBAGE COLLECTION =====================================
            Remove-Item -Path "$downloadPath\Cmder" -Recurse -Force
            $WhatWasDoneMessages = Setup-Cmder -downloadPath $downloadPath -WhatWasDoneMessages $WhatWasDoneMessages
        }
    } else {
        $WhatWasDoneMessages = Setup-Cmder -downloadPath $downloadPath -WhatWasDoneMessages $WhatWasDoneMessages
    }
}
catch {
    $WhatWasDoneMessages += [PSCustomObject]@{
        Message = "- Issue with downloading/installing cmder :("
        ForegroundColor = "Black"
        BackgroundColor = "Red"
    }
}
#endregion

#region DOWNLOAD FONTS
try {
    Write-Host "`nDownloading Font..."
    $nfUrls = @(
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS NF Regular.ttf",
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS NF Bold.ttf",
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS NF Italic.ttf",
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS NF Bold Italic.ttf",
        
        "https://github.com/powerline/fonts/raw/master/AnonymousPro/Anonymice Powerline Bold Italic.ttf",
        "https://github.com/powerline/fonts/raw/master/AnonymousPro/Anonymice Powerline Bold.ttf",
        "https://github.com/powerline/fonts/raw/master/AnonymousPro/Anonymice Powerline Italic.ttf",
        "https://github.com/powerline/fonts/raw/master/AnonymousPro/Anonymice Powerline.ttf"
    )
    Make-Directory -path "$downloadPath\fonts"
    foreach ($url in $nfUrls) {
        $fileName = Split-Path $url -Leaf
        Download-File -url $url -output "$downloadPath\fonts\$fileName"
    }
    $WhatWasDoneMessages += [PSCustomObject]@{
        Message = "- Fonts downloaded successfully :)"
        ForegroundColor = "Black"
        BackgroundColor = "Green"
    }
}
catch {
    $WhatWasDoneMessages += [PSCustomObject]@{
        Message = "- Fonts failed to download :("
        ForegroundColor = "Black"
        BackgroundColor = "Red"
    }
}
#endregion

#region DOWNLOAD MULTIPLE PHP VERSIONS
try {
    Write-Host "`nDownloading PHP versions..."
    $phpUrls = @(
        "https://windows.php.net/downloads/releases/archives/php-5.6.9-Win32-VC11-x64.zip",
        "https://windows.php.net/downloads/releases/archives/php-7.0.9-Win32-VC14-x64.zip",
        "https://windows.php.net/downloads/releases/archives/php-7.1.9-Win32-VC14-x64.zip",
        "https://windows.php.net/downloads/releases/archives/php-7.2.9-Win32-VC15-x64.zip",
        "https://windows.php.net/downloads/releases/archives/php-7.3.9-Win32-VC15-x64.zip",
        "https://windows.php.net/downloads/releases/archives/php-7.4.9-Win32-vc15-x64.zip",
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
        Download-File -url $url -output "$downloadPath\$personalEnvPath\zip\$fileName"
        Extract-Zip -zipPath "$downloadPath\$personalEnvPath\zip\$fileName" -extractPath "$downloadPath\$personalEnvPath\php\$fileName"
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
        Add-Env-Variable -newVariableName $phpEnvVarName -newVariableValue "$downloadPath\$personalEnvPath\php\$fileName" -updatePath 0
    }
    Remove-Item -Path "$downloadPath\$personalEnvPath\zip" -Recurse -Force
    $WhatWasDoneMessages += [PSCustomObject]@{
        Message = "- PHP versions downloaded & setup successfully :)"
        ForegroundColor = "Black"
        BackgroundColor = "Green"
    }
}
catch {
    $WhatWasDoneMessages += [PSCustomObject]@{
        Message = "- PHP versions failed to download/setup :("
        ForegroundColor = "Black"
        BackgroundColor = "Red"
    }
}
#endregion

#region DOWNLOAD XDEBUG
try {
    Write-Host "`nDownloading XDEBUG..."
    $xdebugUrls = @(
        "https://xdebug.org/files/php_xdebug-3.3.2-8.3-vs16-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-3.3.2-8.2-vs16-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-3.3.2-8.1-vs16-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-3.3.2-8.0-vs16-x86_64.dll",
        
        "https://xdebug.org/files/php_xdebug-3.3.1-8.3-vs16-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-3.3.1-8.2-vs16-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-3.3.1-8.1-vs16-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-3.3.1-8.0-vs16-x86_64.dll",
        
        "https://xdebug.org/files/php_xdebug-3.3.0-8.3-vs16-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-3.3.0-8.2-vs16-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-3.3.0-8.1-vs16-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-3.3.0-8.0-vs16-x86_64.dll",
        
        "https://xdebug.org/files/php_xdebug-3.2.2-8.2-vs16-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-3.2.2-8.1-vs16-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-3.2.2-8.0-vs16-x86_64.dll",
        
        "https://xdebug.org/files/php_xdebug-3.1.6-8.1-vs16-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-3.1.6-8.0-vs16-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-3.1.6-7.4-vc15-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-3.1.6-7.3-vc15-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-3.1.6-7.2-vc15-x86_64.dll",
        
        "https://xdebug.org/files/php_xdebug-3.0.4-8.0-vs16-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-3.0.4-7.4-vc15-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-3.0.4-7.3-vc15-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-3.0.4-7.2-vc15-x86_64.dll",
    
        "https://xdebug.org/files/php_xdebug-2.9.8-7.4-vc15-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-2.9.8-7.3-vc15-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-2.9.8-7.2-vc15-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-2.9.8-7.1-vc14-x86_64.dll",
    
        "https://xdebug.org/files/php_xdebug-2.8.0-7.4-vc15-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-2.8.0-7.3-vc15-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-2.8.0-7.2-vc15-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-2.8.0-7.1-vc14-x86_64.dll",
        
        "https://xdebug.org/files/php_xdebug-2.7.0-7.3-vc15-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-2.7.0-7.2-vc15-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-2.7.0-7.1-vc14-x86_64.dll",
    
        "https://xdebug.org/files/php_xdebug-2.6.0-7.2-vc15-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-2.6.0-7.1-vc14-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-2.6.0-7.0-vc14-x86_64.dll",
        
        "https://xdebug.org/files/php_xdebug-2.5.5-7.1-vc14-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-2.5.5-7.0-vc14-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-2.5.5-5.6-vc11-x86_64.dll",
        
        "https://xdebug.org/files/php_xdebug-2.5.0-7.1-vc14-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-2.5.0-7.0-vc14-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-2.5.0-5.6-vc11-x86_64.dll",
        
        "https://xdebug.org/files/php_xdebug-2.4.0-7.0-vc14-x86_64.dll",
        "https://xdebug.org/files/php_xdebug-2.4.0-5.6-vc11-x86_64.dll",
        
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
    $WhatWasDoneMessages += [PSCustomObject]@{
        Message = "- XDEBUG versions downloaded & setup successfully :)"
        ForegroundColor = "Black"
        BackgroundColor = "Green"
    }
}
catch {
    $WhatWasDoneMessages += [PSCustomObject]@{
        Message = "- XDEBUG versions failed to download/setup :("
        ForegroundColor = "Black"
        BackgroundColor = "Red"
    }
}
#endregion

#region DOWNLOAD & INSTALL NVM
try {
    # check the GitHub releases page for the latest version
    Write-Host "`nDownloading NVM executable..."
    $nvmUrl = "https://github.com/coreybutler/nvm-windows/releases/download/1.1.12/nvm-setup.exe"
    Download-File -url $nvmUrl -output "$downloadPath\nvm-setup.exe"
    $WhatWasDoneMessages += [PSCustomObject]@{
        Message = "- NVM was downloaded successfully, you need to install it manually :)"
        ForegroundColor = "Black"
        BackgroundColor = "Green"
    }
}
catch {
    $WhatWasDoneMessages += [PSCustomObject]@{
        Message = "- NVM failed to download, try later :("
        ForegroundColor = "Black"
        BackgroundColor = "Red"
    }
}
#endregion

#region DOWNLOAD AND INSTALL CHOCOLATEY
try {
    Write-Host "`nDownloading and installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1"))
    $WhatWasDoneMessages += [PSCustomObject]@{
        Message = "- Chocolatey was installed successfully :)"
        ForegroundColor = "Black"
        BackgroundColor = "Green"
    }
}
catch {
    $WhatWasDoneMessages += [PSCustomObject]@{
        Message = "- Chocolatey failed to install, try later :("
        ForegroundColor = "Black"
        BackgroundColor = "Red"
    }
}
#endregion

#region WHAT TO DO NEXT
What-ToDo-Next -WhatWasDoneMessages $WhatWasDoneMessages
#endregion

Write-Host "`nAll tasks completed.`n`n"
