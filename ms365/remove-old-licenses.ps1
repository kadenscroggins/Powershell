# Ensure PS7 is running
if ($PSVersionTable.PSVersion.Major -ne 7) {
    Write-Host "Please run this script with PowerShell version 7! Version detected:" $PSVersionTable.PSVersion
    exit -1
}

# Load Credentials and connect to Microsoft
$credentials = Get-Content -Raw -Path .\Secrets\credentials.json | ConvertFrom-Json
$client_secret_credential = New-Object `
    -TypeName System.Management.Automation.PSCredential `
    -ArgumentList `
        $credentials.client_id, `
        (ConvertTo-SecureString $credentials.client_secret -AsPlainText -Force)
Connect-MgGraph -TenantId $credentials.tenant_id -ClientSecretCredential $client_secret_credential -NoWelcome

# Build license to assign and disable unused plans
$license_sku = Get-MgSubscribedSku -All | Where-Object SkuPartNumber -eq "License_SkuPartNumber"

# Pull users from Entra
Write-Host "Getting Users"
$entra_users = Get-MgUser -All -Filter "assignedLicenses/any(x:x/skuId eq $($license_sku.SkuId))" -Property @("Id", "UserPrincipalName", "LicenseAssignmentStates") `
    -ConsistencyLevel eventual -CountVariable licensed_user_count
Write-Host "Found $licensed_user_count licensed users"

# Get CSV of currently eligible users for office licenses from file
$csv_users = Import-Csv ".\current.csv"
$csv_user_set = New-Object System.Collections.Generic.HashSet[String]
foreach ($user in $csv_users) {
    $csv_user_set.Add($user.INSTITUTION_EMAIL) | Out-Null
}

Write-Host "Checking Licenses"
$LicenseKeepCount = 0
$LicenseRemoveCount = 0
Set-Content -Path .\removed_licenses.csv -Value "UserPrincipalName,LicenseStatus"
foreach ($user in $entra_users) {
    $is_current_user = $user.UserPrincipalName -in $csv_user_set
    if ($is_current_user) {
        $LicenseKeepCount++
    }
    else {
        $LicenseRemoveCount++
        Set-MgUserLicense -UserId $user.Id -AddLicenses @() -RemoveLicenses @($license_sku.SkuId)
        Add-Content -Path .\removed_licenses.csv -Value "$($user.UserPrincipalName),remove"
    }
}

Write-Host "Keep $LicenseKeepCount Remove $LicenseRemoveCount"
Write-Host "CSV: $($csv_user_set.Count), Entra: $($entra_users.Length)"

Pause
