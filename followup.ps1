
. ./functions.ps1

$response = Prompt-YesOrNoWithDefault -message "Did you already start cmder?"
if ($response -eq "no" -or $response -eq "n") {
    Write-Host "You should start cmder before continuing..."
    exit
}

Copy-Item -Path "$downloadPath\Cmder\vendor\conemu-maximus5\ConEmu.xml.bak" -Destination "$downloadPath\Cmder\vendor\conemu-maximus5\ConEmu.xml" 
Copy-Item -Path "$downloadPath\Cmder\config\user_aliases.cmd.bak" -Destination "$downloadPath\Cmder\config\user_aliases.cmd" 
