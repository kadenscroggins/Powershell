$quota = 20480 # MB
$group = 'example@groups.example.com'

gam update group $group clear member
Write-Host "$group members cleared"

if (Test-Path '.\users.csv') {
    Remove-Item '.\users.csv'
    Write-Host 'users.csv deleted'
}

[string[]]$messages = gam report users filter "accounts:used_quota_in_mb>$quota" fields accounts:used_quota_in_mb

$messages = $messages[1..($messages.Length - 1)]
foreach ($line in $messages) {
    $columns = $line.Split("@")
    if (Test-Path '.\users.csv') {
        Add-Content '.\users.csv' $columns[0]
    }
    else {
        New-Item '.\users.csv'
        Add-Content '.\users.csv' 'email'
        Add-Content '.\users.csv' $columns[0]
    }
}

Write-Host 'users.csv created'

gam csv .\users.csv gam update group $group add member user ~email
Write-Host "$group updated with all users who have more than $quota MB used"

Pause