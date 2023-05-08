if (Test-Path '.\users-and-storage.csv') {
    Remove-Item '.\users-and-storage.csv'
    Write-Host 'users-and-storage.csv deleted'
    New-Item '.\users-and-storage.csv'
    Write-Host 'users-and-storage.csv created'
}
else {
    New-Item '.\users-and-storage.csv'
    Write-Host 'users-and-storage.csv created'
}

[string[]]$users = gam report users fields accounts:used_quota_in_mb
foreach ($user in $users) {
    $fields = $user.Split(",")
    Add-Content '.\users-and-storage.csv' ($fields[0] + "," + $fields[2])
}
