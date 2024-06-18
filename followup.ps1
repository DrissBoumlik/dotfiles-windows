
. ./functions.ps1

#region COPY CMDER CONFIG & ALIASES
$response = Prompt-YesOrNoWithDefault -message "Did you already start cmder?"
if ($response -eq "yes" -or $response -eq "y") {
    $downloadPath = Prompt-Quesiton -message "Indicate the target directory (C:\[Container])"
    $downloadPath = "C:\$downloadPath"
    Copy-Item -Path "$PWD\config\ConEmu.xml" -Destination "$downloadPath\Cmder\vendor\conemu-maximus5\ConEmu.xml" 
    Get-Content -Path "$PWD\config\user_aliases.cmd" | Add-Content -Path "$downloadPath\Cmder\config\user_aliases.cmd"
        Write-Host "`nConEmu.xml & user_aliases.cmd were added to Cmder successfully :)"
} else {
    Write-Host "You should start cmder before continuing..."
}
#endregion

#region ADD PHP ENVIRONMENT VARIABLE TO THE PATH
$response = Prompt-YesOrNoWithDefault -message "Did you already install Xampp & Composer?"
if ($response -eq "yes" -or $response -eq "y") {
    $directories = Get-ChildItem -Path "C:\" -Directory -ErrorAction SilentlyContinue -Force | Where-Object { $_.Name -match 'xampp' }
    if ($directories.Count -gt 0) {
        $xamppPath = ($directories | Select-Object -First 1).FullName
        Add-Env-Variable -newVariableName "php_now" -newVariableValue "$xamppPath\php" -updatePath 1
        Write-Host "`nThe 'php_now' variable was successfully added to the PATH :)"
    } else {
        Write-Host "No XAMPP directories found. :("
    }
} else {
    Write-Host "You should install Xampp & Composer before continuing..."
    exit
}
#endregion

Write-Host "`nAll tasks completed.`n`n"
