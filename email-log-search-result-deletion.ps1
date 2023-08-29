# Can be used to get the deletion commands for a lot of messages with different message IDs
# if they are all in the same CSV file from a Google Admin Email Log Search CSV export
$batch_path = '.\gam-batch-log-search-results-deletion.txt'
[System.Collections.ArrayList]$messages = Get-Content -Path ".\LogSearchResults.csv"
Write-Output "Removing first line: $($messages[0])"
$messages.RemoveAt(0)
$command_set = New-Object System.Collections.Generic.HashSet[String]
foreach ($line in $messages) {
    $columns = $line.Split(",")
    $command = ("gam user " + $columns[8].Replace("`"","") + " delete messages query rfc822msgid:" + $columns[0].Replace("`"","") + " doit")
    if ($columns[8] -like "*exampledomain.com*") {
        $command_set.Add($command) | Out-Null
    }
}

$command_set | out-file $batch_path -Encoding UTF8
Write-Host "Deleting $($command_set.Count) emails"
gam batch $batch_path
Remove-Item $batch_path
