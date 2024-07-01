
. ./functions.ps1


Write-Host "`nThis will setup your env with (Git, Xampp, Composer, NVM, Chocolatey, Cmder, PHP, XDebug)`n"

#region ANSWER QUESTIONS FOR WHICH STEPS TO EXECUTE
$StepsQuestions = [ordered]@{
   GIT = [PSCustomObject]@{ Question = "- Download Git ?"; Answer = "no" }
   XAMPP = [PSCustomObject]@{ Question = "- Download Xampp ?"; Answer = "no" }
   COMPOSER = [PSCustomObject]@{ Question = "- Download Composer ?"; Answer = "no" }
   NVM = [PSCustomObject]@{ Question = "- Download Nvm ?"; Answer = "no" }
   CHOCO = [PSCustomObject]@{ Question = "- Download Chocolatey ?"; Answer = "no" }
   TOOLS = [PSCustomObject]@{ Question = "- Download TOOLS (eza, delta, bat, less) ?"; Answer = "no" }
   CMDER = [PSCustomObject]@{ Question = "- Download & Configure Cmder ?"; Answer = "no" }
   FONTS = [PSCustomObject]@{ Question = "- Download Nerd Fonts "; Answer = "no" }
   PHP = [PSCustomObject]@{ Question = "- Download PHP versions "; Answer = "no" }
   XDEBUG = [PSCustomObject]@{ Question = "- Download XDebug "; Answer = "no" }
}

foreach ($key in $StepsQuestions.Keys) {
    $q = $StepsQuestions[$key]
    $q.Answer = Prompt-YesOrNoWithDefault -message $q.Question -defaultOption "yes"
}
#endregion

$WhatWasDoneMessages = @()
$WhatToDoNext = @()

#region SETUP THE CONTAINER DIRECTORY
do {
    $downloadPath = Prompt-Quesiton -message "`nIndicate the target directory (ex: C:\Container)"
    $partitions = Get-Partition | Where-Object { $_.DriveLetter -match "[A-Za-z]" } | Select-Object -ExpandProperty DriveLetter
    $partitionsLetters = $partitions -join ""
    if (-not $downloadPath -or $downloadPath -eq "" ) {
        $downloadPath = "C:\__Container"
        break
    } elseif (-not ($downloadPath -match "^[$partitionsLetters]:\\.{3,20}$")) {
        Write-Host "`n- Not a valid directory :( " -BackgroundColor Yellow -ForegroundColor Black
    }
} while (-not ($downloadPath -match "^[$partitionsLetters]:\\.{3,20}$"))
Write-Host "`n- Your working directory is $downloadPath :) " -BackgroundColor Green -ForegroundColor Black
Start-Sleep -Seconds 2

$WhatToDoNext += [PSCustomObject]@{
    Message = "- Your container path is '$downloadPath'"
    ForegroundColor = "Black"
    BackgroundColor = "Gray"
}

$overrideExistingEnvVars = Prompt-YesOrNoWithDefault -message "`nWould you like to override the existing environment variables"

# Create the download directory if it doesn't exist
if (!(Test-Path -Path $downloadPath)) {
    New-Item -ItemType Directory -Force -Path $downloadPath
}
#endregion


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
            Message = "- Git failed to download, try again :("
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
            Message = "- Xampp failed to download, try again :("
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
            Message = "- Composer failed to download, try again :("
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
            Message = "- NVM failed to download, try again :("
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
            Message = "- Chocolatey failed to install, try again :("
            ForegroundColor = "Black"
            BackgroundColor = "Red"
        }
    }
}
#endregion

#region DOWNLOAD AND SETUP EZA, DELTA, BAT, LESS
if ($StepsQuestions["TOOLS"].Answer -eq "yes") {
    try {
        Make-Directory -path "$downloadPath\env"
        Make-Directory -path "$downloadPath\env\tools"
        $tools = @()
        #region DOWNLOAD & SETUP EZA
        Write-Host "`nDownloading & Extracting EZA (better ls)..."
        $ezaUrl = "https://github.com/eza-community/eza/releases/download/v0.18.19/eza.exe_x86_64-pc-windows-gnu.zip"
        Download-File -url $ezaUrl -output "$downloadPath\eza.zip"

        Extract-Zip -zipPath "$downloadPath\eza.zip" -extractPath "$downloadPath\env\tools\eza"
        $tools += "$downloadPath\env\tools\eza"
        Remove-Item "$downloadPath\eza.zip"
        #endregion

        #region DOWNLOAD & SETUP DELTA
        Write-Host "`nDownloading & Extracting DELTA  (better git diff)..."
        $deltaUrl = "https://github.com/dandavison/delta/releases/download/0.15.0/delta-0.15.0-x86_64-pc-windows-msvc.zip"
        Download-File -url $deltaUrl -output "$downloadPath\delta.zip"

        Extract-Zip -zipPath "$downloadPath\delta.zip" -extractPath "$downloadPath\env\tools"
        $directories = Get-ChildItem -Path "$downloadPath\env\tools" -Directory -ErrorAction SilentlyContinue -Force | Where-Object { $_.Name -match 'delta' }
        $deltaPath = ($directories | Select-Object -First 1).FullName
        Rename-Item -Path $deltaPath -NewName "delta"
        $tools += "$downloadPath\env\tools\delta"
        Remove-Item "$downloadPath\delta.zip"
        #endregion

        #region DOWNLOAD & SETUP BAT
        Write-Host "`nDownloading & Extracting BAT (better cat)..."
        $batUrl = "https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-v0.24.0-x86_64-pc-windows-msvc.zip"
        Download-File -url $batUrl -output "$downloadPath\bat.zip"

        Extract-Zip -zipPath "$downloadPath\bat.zip" -extractPath "$downloadPath\env\tools"
        $directories = Get-ChildItem -Path "$downloadPath\env\tools" -Directory -ErrorAction SilentlyContinue -Force | Where-Object { $_.Name -match 'bat' }
        $batPath = ($directories | Select-Object -First 1).FullName
        Rename-Item -Path $batPath -NewName "bat"
        $tools += "$downloadPath\env\tools\bat"
        Remove-Item "$downloadPath\bat.zip"
        #endregion

        #region DOWNLOAD & RELACE LESS
        Write-Host "`nDownloading & Extracting LESS..."
        $lessUrl = "https://github.com/jftuga/less-Windows/releases/download/less-v643/less-arm64.zip"
        Download-File -url $lessUrl -output "$downloadPath\less.zip"

        Extract-Zip -zipPath "$downloadPath\less.zip" -extractPath "$downloadPath\env\tools\less"
        $tools += "$downloadPath\env\tools\less"
        Remove-Item "$downloadPath\less.zip"
        #endregion

        $tools = $tools -join ";"
        Add-Env-Variable -newVariableName "tools" -newVariableValue $tools -updatePath 1 -overrideExistingEnvVars $overrideExistingEnvVars
        $WhatWasDoneMessages += [PSCustomObject]@{
            Message = "- Tools (eza, delta, bat, less) downloaded & configured successfully :)"
            ForegroundColor = "Black"
            BackgroundColor = "Green"
        }
    }
    catch {
        $WhatWasDoneMessages += [PSCustomObject]@{
            Message = "- One of the tools (eza, delta, bat, less) failed to download, try again :("
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
                $WhatWasDoneMessages = Setup-Cmder -downloadPath $downloadPath -WhatWasDoneMessages $WhatWasDoneMessages -overrideExistingEnvVars $overrideExistingEnvVars
            }
        } else {
            $WhatWasDoneMessages = Setup-Cmder -downloadPath $downloadPath -WhatWasDoneMessages $WhatWasDoneMessages -overrideExistingEnvVars $overrideExistingEnvVars
        }
        $WhatToDoNext += [PSCustomObject]@{
            Message = "- Start cmder and Run to check for any updates : > clink update                     "
            ForegroundColor = "Black"
            BackgroundColor = "Gray"
        }
        $WhatToDoNext += [PSCustomObject]@{
            Message = "- Start cmder and Run 'flexprompt configure' to customize the prompt style.         "
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
            Message = "- Install downloaded font and Add it to cmder settings.                             "
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
        Make-Directory -path "$downloadPath\env"
        Make-Directory -path "$downloadPath\env\zip"
        Make-Directory -path "$downloadPath\env\php_stuff"
        Make-Directory -path "$downloadPath\env\php_stuff\php"
        foreach ($url in $phpUrls) {
            $fileNameZip = Split-Path $url -Leaf
            $fileName = $fileNameZip -replace ".zip", ""
            Download-File -url $url -output "$downloadPath\env\zip\$fileNameZip"
            Extract-Zip -zipPath "$downloadPath\env\zip\$fileNameZip" -extractPath "$downloadPath\env\php_stuff\php\$fileName"
            Copy-Item -Path "$downloadPath\env\php_stuff\php\$fileName\php.ini-development" -Destination "$downloadPath\env\php_stuff\php\$fileName\php.ini"
            if ($fileName -match "php-(\d+)\.(\d+)\.") {
                $majorVersion = $matches[1]
                $minorVersion = $matches[2]
                if ($minorVersion -eq '0') {
                    $phpEnvVarName = $majorVersion
                } else {
                    $phpEnvVarName = "$majorVersion$minorVersion"
                }
                $phpEnvVarName = "php$phpEnvVarName"
                Add-Env-Variable -newVariableName $phpEnvVarName -newVariableValue "$downloadPath\env\php_stuff\php\$fileName" -updatePath 0 -overrideExistingEnvVars $overrideExistingEnvVars
            }
        }

        $VcUrls = @(
            "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe",
            "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe"
        )
        foreach ($url in $VcUrls) {
            $fileName = Split-Path $url -Leaf
            Download-File -url $url -output "$downloadPath\env\$fileName"
        }
        Remove-Item -Path "$downloadPath\env\zip" -Recurse -Force

        # phpcs, phpcbf, phpmd, phpstan, phpfixer
        $phpTools = @(
            @{ name = "phpcs"; url = "https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar" }
            @{ name = "phpcbf"; url = "https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar" }
            @{ name = "phpmd"; url = "https://github.com/phpmd/phpmd/releases/download/2.15.0/phpmd.phar" }
            @{ name = "phpstan"; url = "https://github.com/phpstan/phpstan/releases/download/1.11.5/phpstan.phar" }
            @{ name = "phpcsfixer"; url = "https://github.com/PHP-CS-Fixer/PHP-CS-Fixer/releases/download/v3.59.3/php-cs-fixer.phar" }
        )
        Make-Directory -path "$downloadPath\env\php_stuff\tools"
        foreach ($phpTool in $phpTools) {
            $url = $phpTool.url 
            $path = "$downloadPath\env\php_stuff\tools" 
            $fileName = $phpTool.name

            Download-File -url $url -output "$path\$fileName.phar"
            $batString = @"
            @echo OFF
            :: in case DelayedExpansion is on and a path contains ! 
            setlocal DISABLEDELAYEDEXPANSION
            php "%~dp0$fileName.phar" %*
"@
            $batString = $batString -replace "\ {4,}"
            Add-Content -Path "$path\$fileName.bat" -Value $batString
        }

        $WhatWasDoneMessages += [PSCustomObject]@{
            Message = "- PHP versions (& Tools) were downloaded & setup successfully :)"
            ForegroundColor = "Black"
            BackgroundColor = "Green"
        }
        $WhatToDoNext += [PSCustomObject]@{
            Message = "- Your PHP path is '$downloadPath\env\php_stuff\php'"
            ForegroundColor = "Black"
            BackgroundColor = "Gray"
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
        Make-Directory -path "$downloadPath\env"
        Make-Directory -path "$downloadPath\env\php_stuff"
        Make-Directory -path "$downloadPath\env\php_stuff\xdebug"
        $phpVersionsWithXdebug = @()
        foreach ($url in $xdebugUrls) {
            $fileName = Split-Path $url -Leaf
            if ($fileName -match "-(\d+\.\d+)-(vs|vc)") {
                $phpVersion = $matches[1]
                Make-Directory -path "$downloadPath\env\php_stuff\xdebug\$phpVersion"
                $outputPathXdebug = "$downloadPath\env\php_stuff\xdebug\$phpVersion\$fileName"
                Download-File -url $url -output $outputPathXdebug

                $phpPaths = Get-ChildItem -Path "$downloadPath\env\php_stuff\php" -Directory | Select-Object -ExpandProperty Name
                if ($phpPaths.Count -gt 0) {
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
                                Add-Content -Path "$downloadPath\env\php_stuff\php\$phpPath\php.ini" -Value $xDebugConfig
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
        $WhatToDoNext += [PSCustomObject]@{
            Message = "- Your XDebug path is '$downloadPath\env\php_stuff\xdebug'"
            ForegroundColor = "Black"
            BackgroundColor = "Gray"
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
