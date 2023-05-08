# To run this script, pull an up to date inactive user report
# and name it 'inactive_users.csv' and run this file

$group = 'groupname@example.com'
$blocklist = @( # Users to block from being added to inactive-user-warning
    'username'
)

if (Test-Path '.\all_users.csv') {
    Remove-Item '.\all_users.csv'
    Write-Host 'all_users.csv deleted'
}
gam print users > all_users.csv
Write-Host 'all_users.csv created'


$inactive_users = Get-Content .\inactive_users.csv
$inactive_users = $inactive_users[1..($inactive_users.Length - 1)] # Remove first element

$all_users = Get-Content .\all_users.csv
$all_users = $all_users[1..($all_users.Length - 1)] # Remove first element

$all_users_hash = @{}
foreach ($user in $all_users) {
    $all_users_hash.Add($user, $user)
}

$user_update = [System.Collections.ArrayList]@()
for ($i = 0; $i -lt $inactive_users.Length; $i++) {
    if ($blocklist.Contains($inactive_users[$i])) {
        # do nothing
    }
    elseif ($all_users_hash.ContainsKey("" + $inactive_users[$i] + "@nsuok.edu")) {
        $user_update.Add($inactive_users[$i]) | Out-Null
    }
    $progress = ($i / $inactive_users.Length) * 100
    Write-Progress -Activity "Comparing CSVs" -Status ("" + [int]$progress + "%") -PercentComplete $progress
}
$user_update = @('email') + $user_update # Prepend header to list

if (Test-Path '.\user_update.csv') {
    Remove-Item '.\user_update.csv'
    Write-Host 'user_update.csv deleted'
}
$user_update | Out-File -FilePath .\user_update.csv
Write-Host 'user_update.csv created'

gam update group $group clear member
Write-Host "$group members cleared"

gam csv .\user_update.csv gam update group $group add member user ~email
Write-Host "$group updated"
