# Can be used to get the deletion commands for a lot of messages with different message IDs
# if they are all in the same CSV file from a Google Admin Email Log Search CSV export

[string[]]$messages = Get-Content -Path ".\LogSearchResults.csv"
foreach ($line in $messages) {
    $columns = $line.Split(",")
    $command = ("gam user " + $columns[8].Replace("`"","") + " delete messages query rfc822msgid:" + $columns[0].Replace("`"","") + " doit")
    
    # Uncomment the second line to run the commands
    Write-Output $command
    #Invoke-Expression -Command $command
}
