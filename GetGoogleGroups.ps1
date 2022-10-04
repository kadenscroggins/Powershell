# Draw the list of current users from Google API
$group = $args[0]
$group_members = gam print group-members group $group
$group_members = $group_members[1..($group_members.Length-1)] # Strip column headers

# Create .\allowlists folder if it doesn't exist
$allowlist_folder = ".\allowlists"
if (!(Test-Path $allowlist_folder)) {
    New-Item -ItemType Directory -Path $allowlist_folder
}

# Create allowlist file if it doesn't exist
$allowlist_file = ".\allowlists\$group.allowlist"
if (!(Test-Path $allowlist_file)) {
    New-Item -ItemType File -Path $allowlist_file
}

# Create .\CSVs folder if it doesn't exist
$csv_folder = ".\CSVs"
if (!(Test-Path $csv_folder)) {
    New-Item -ItemType Directory -Path $csv_folder
}

# Generate filtered list of emails
$emails = [System.Collections.ArrayList]@()
$emails.Add("`"email`"") | Out-Null # File header, necessary for GoogleGroupSync.ps1
[string[]]$allowlist = Get-Content -Path $allowlist_file # Allowlist of permitted users

foreach ($line in $group_members) {
    $columns = $line.Split(",")

    if ($columns[2] -in $allowlist) {
        #Write-Output ("PASS ALLOWLIST " + $columns[2])
        continue
    }

    elseif ($columns[3] -ne "MEMBER") {
        #Write-Output ("PASS " + $columns[3] + " " + $columns[2])
        continue
    }

    $emails.Add($columns[2]) | Out-Null
}

# Save to file
$emails | Out-File -FilePath .\CSVs\$group