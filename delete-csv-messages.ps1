[string[]]$ids = Get-Content -Path ".\ids.csv"
foreach ($line in $ids) {
    $command = ("gam all users delete messages query rfc822msgid:" + $line + " doit")
    # Uncomment the second line to run the commands
    Write-Output $command
    #Invoke-Expression -Command $command
}