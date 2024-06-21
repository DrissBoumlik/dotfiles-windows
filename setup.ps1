
. ./functions.ps1


#region Answer Questions for which steps to execute
$StepsQuestions = [ordered]@{
   GIT = [PSCustomObject]@{ Question = "- Download Git ?"; Answer = "no" }
   XAMPP = [PSCustomObject]@{ Question = "- Download Xampp ?"; Answer = "no" }
   COMPOSER = [PSCustomObject]@{ Question = "- Download Composer ?"; Answer = "no" }
   NVM = [PSCustomObject]@{ Question = "- Download Nvm ?"; Answer = "no" }
   CHOCO = [PSCustomObject]@{ Question = "- Download Chocolatey ?"; Answer = "no" }
   CMDER = [PSCustomObject]@{ Question = "- Download & Configure Cmder ?"; Answer = "no" }
   FONTS = [PSCustomObject]@{ Question = "- Download Nerd Fonts "; Answer = "no" }
   PHP = [PSCustomObject]@{ Question = "- Download PHP versions "; Answer = "no" }
   XDEBUG = [PSCustomObject]@{ Question = "- Download XDebug "; Answer = "no" }
}

foreach ($key in $StepsQuestions.Keys) {
    $q = $StepsQuestions[$key]
    $q.Answer = Prompt-YesOrNoWithDefault -message $q.Question
}
#endregion

#region SETUP THE CONTAINER DIRECTORY
# Set the download paths
$downloadPath = Prompt-Quesiton -message "Indicate the target directory (C:\[Container])"
$downloadPath = "C:\$downloadPath"
$personalEnvPath = "env"

# Create the download directory if it doesn't exist
if (!(Test-Path -Path $downloadPath)) {
    New-Item -ItemType Directory -Force -Path $downloadPath
}
#endregion

$WhatWasDoneMessages = @()
$WhatToDoNext = @()

#region DOWNLOAD GIT
if ($StepsQuestions["GIT"].Answer -eq "yes") {
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
}
#endregion

#region DOWNLOAD XAMPP
if ($StepsQuestions["XAMPP"].Answer -eq "yes") {
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
}
#endregion

#region DOWNLOAD COMPOSER
if ($StepsQuestions["COMPOSER"].Answer -eq "yes") {
    try {
        Write-Host "`nDownloading Composer..."
        $composerUrl = "https://getcomposer.org/Composer-Setup.exe"
        Download-File -url $composerUrl -output "$downloadPath\3-Composer-Setup.exe"

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
}
#endregion

#region DOWNLOAD & INSTALL NVM
if ($StepsQuestions["NVM"].Answer -eq "yes") {
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
}
#endregion

#region DOWNLOAD AND INSTALL CHOCOLATEY
if ($StepsQuestions["CHOCO"].Answer -eq "yes") {
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
}
#endregion

#region SETUP CMDER
if ($StepsQuestions["CMDER"].Answer -eq "yes") {
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
        $WhatToDoNext += [PSCustomObject]@{
            Message = "||  - Start cmder and Run to check for any updates : > clink update                     ||"
            ForegroundColor = "Black"
            BackgroundColor = "Gray"
        }
        $WhatToDoNext += [PSCustomObject]@{
            Message = "||  - Start cmder and Run 'flexprompt configure' to customize the prompt style.         ||"
            ForegroundColor = "Black"
            BackgroundColor = "Gray"
        }
    }
    catch {
        $WhatWasDoneMessages += [PSCustomObject]@{
            Message = "- Issue with downloading/installing cmder :("
            ForegroundColor = "Black"
            BackgroundColor = "Red"
        }
    }
}
#endregion

#region DOWNLOAD FONTS
if ($StepsQuestions["FONTS"].Answer -eq "yes") {
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
        $WhatToDoNext += [PSCustomObject]@{
            Message = "||  - Install downloaded font and Add it to cmder settings.                             ||"
            ForegroundColor = "Black"
            BackgroundColor = "Gray"
        }
    }
    catch {
        $WhatWasDoneMessages += [PSCustomObject]@{
            Message = "- Fonts failed to download :("
            ForegroundColor = "Black"
            BackgroundColor = "Red"
        }
    }
}
#endregion

#region DOWNLOAD MULTIPLE PHP VERSIONS
if ($StepsQuestions["PHP"].Answer -eq "yes") {
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
        $phpPaths = @()
        Make-Directory -path "$downloadPath\$personalEnvPath"
        Make-Directory -path "$downloadPath\$personalEnvPath\zip"
        Make-Directory -path "$downloadPath\$personalEnvPath\php"
        foreach ($url in $phpUrls) {
            $fileNameZip = Split-Path $url -Leaf
            $fileName = $fileNameZip -replace ".zip", ""
            Download-File -url $url -output "$downloadPath\$personalEnvPath\zip\$fileNameZip"
            Extract-Zip -zipPath "$downloadPath\$personalEnvPath\zip\$fileNameZip" -extractPath "$downloadPath\$personalEnvPath\php\$fileName"
            $phpPaths += "$downloadPath\$personalEnvPath\php\$fileName"
            Copy-Item -Path "$downloadPath\$personalEnvPath\php\$fileName\php.ini-development" -Destination "$downloadPath\$personalEnvPath\php\$fileName\php.ini"
            if ($fileName -match "php-(\d+)\.(\d+)\.") {
                $majorVersion = $matches[1]
                $minorVersion = $matches[2]
                if ($minorVersion -eq '0') {
                    $phpEnvVarName = $majorVersion
                } else {
                    $phpEnvVarName = "$majorVersion$minorVersion"
                }
                $phpEnvVarName = "php$phpEnvVarName"
                Add-Env-Variable -newVariableName $phpEnvVarName -newVariableValue "$downloadPath\$personalEnvPath\php\$fileName" -updatePath 0
            }
        }

        $VcUrls = @(
            "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe",
            "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe"
        )
        foreach ($url in $VcUrls) {
            $fileName = Split-Path $url -Leaf
            Download-File -url $url -output "$downloadPath\$personalEnvPath\$fileName"
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
}
#endregion

#region DOWNLOAD XDEBUG
if ($StepsQuestions["XDEBUG"].Answer -eq "yes") {
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
        $phpVersionsWithXdebug = @()
        foreach ($url in $xdebugUrls) {
            $fileName = Split-Path $url -Leaf
            if ($fileName -match "-(\d+\.\d+)-(vs|vc)") {
                $phpVersion = $matches[1]
                Make-Directory -path "$downloadPath\$personalEnvPath\xdebug\$phpVersion"
                $outputPathXdebug = "$downloadPath\$personalEnvPath\xdebug\$phpVersion\$fileName"
                Download-File -url $url -output $outputPathXdebug

                if ($StepsQuestions["PHP"].Answer -eq "yes") {
                    $xDebugConfig = @"

                    [xdebug]
                    zend_extension="$outputPathXdebug"
                    xdebug.remote_enable=1
                    xdebug.remote_host=127.0.0.1
                    xdebug.remote_port=9000
"@
                    if ($fileName -match "php_xdebug-([\d\.]+)") {
                        $xDebugVersion = $matches[1]
                        if ($xDebugVersion -like "3.*") {
                            $xDebugConfig = @"

                                [xdebug]
                                zend_extension="$outputPathXdebug"
                                xdebug.mode=debug
                                xdebug.client_host=127.0.0.1
                                xdebug.client_port=9003
"@
                        }
                    }

                    foreach ($phpPath in $phpPaths) {
                        if ($phpPath -like "*$phpVersion*") {
                            if (-not($phpVersionsWithXdebug -contains $phpVersion)) {
                                $phpVersionsWithXdebug += $phpVersion
                                $xDebugConfig = $xDebugConfig -replace "\ +"
                                Add-Content -Path "$phpPath\php.ini" -Value $xDebugConfig
                                break
                            }
                        }
                    }
                }
            }
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
}
#endregion

#region WHAT TO DO NEXT
What-ToDo-Next -WhatWasDoneMessages $WhatWasDoneMessages -WhatToDoNext $WhatToDoNext
#endregion

Write-Host "`nAll tasks completed.`n`n"
