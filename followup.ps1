
. ./functions.ps1

$response = Prompt-YesOrNoWithDefault -message "Did you already start cmder?"
if ($response -eq "no" -or $response -eq "n") {
    Write-Host "You should start cmder before continuing..."
    exit
}

$downloadPath = Prompt-Quesiton -message "Indicate the target directory (C:\[Container])"
$downloadPath = "C:\$downloadPath"

Copy-Item -Path "$PWD\config\ConEmu.xml" -Destination "$downloadPath\Cmder\vendor\conemu-maximus5\ConEmu.xml" 
Get-Content -Path "$PWD\config\user_aliases.cmd" | Add-Content -Path "$downloadPath\Cmder\config\user_aliases.cmd"