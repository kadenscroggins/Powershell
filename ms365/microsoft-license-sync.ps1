Param(
    [Parameter(Mandatory = $True)]
    [string]$Path
)

# Used for logging
. .\Logger2.ps1

# Ensure PS7 is running
if ($PSVersionTable.PSVersion.Major -ne 7) {
    Write-Log "Please run this script with PowerShell version 7! Version detected: $($PSVersionTable.PSVersion)" "FATAL"
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

# Attributes to pull for each user from Entra
$attributes = @(
    "AccountEnabled",
    "OnPremisesImmutableId",
    "DisplayName",
    "UserPrincipalName",
    "Mail",
    "GivenName",
    "Surname",
    "LicenseAssignmentStates",
    "Id"
)

# Build license to assign and disable unused plans
$license_sku = Get-MgSubscribedSku -All | Where-Object SkuPartNumber -eq "Name_Of_SkuPartNumber"
$disabled_plans = $license_sku.ServicePlans | Where-Object ServicePlanName -in (
    "List",
    "Of",
    "Disabled",
    "License",
    "Service",
    "Plans"
) | Select-Object -ExpandProperty ServicePlanId
$student_license = @(
    @{
        SkuId = $license_sku.SkuId
        DisabledPlans = $disabled_plans
    }
)

# License Users
$database_users_csv = Import-Csv $Path
ForEach ($user in $database_users_csv) {
    try {
        $user = $user
        $license_sku = $license_sku

        # Trim EVERYTHING. Paranoia.
        $user.FIRSTNAME = $user.FIRSTNAME.Trim()
        $user.LASTNAME = $user.LASTNAME.Trim()
        $user.MIDDLENAME = $user.MIDDLENAME.Trim()
        $user.DISPLAYNAME = $user.DISPLAYNAME.Trim()
        $user.INSTITUTION_EMAIL = $user.INSTITUTION_EMAIL.Trim()
        $user.INSTITUTION_USERID = $user.INSTITUTION_USERID.Trim()
        $user.IMMUTABLEID = $user.IMMUTABLEID.Trim()

        Write-Log "Processing user: $($user.DisplayName)" "INFO"

        # Check if user exists in AD
        $ad_user = Get-ADUser -Filter "sAMAccountName -eq '$($user.INSTITUTION_USERID)'"
        if ($ad_user) {
            Write-Log "$($ad_user.sAMAccountName) exists in AD. Continuing!" "DEBUG"
        }
        else {
            Write-Log "$($user.INSTITUTION_USERID) not found in AD. Skipping!" "WARN"
            Continue
        }

        # Check if user exists in Entra / O365 / MS365 / Whatever they're calling it now.
        $entra_user = Get-MgUser -Filter "startsWith(UserPrincipalName, '$($user.INSTITUTION_EMAIL)')" `
            -ConsistencyLevel eventual -Top 1 -Property $attributes
        if ($entra_user) {
            Write-Log "$($entra_user.UserPrincipalName) exists in Entra. Continuing!" "DEBUG"
        }
        else {
            Write-Log "$($user.INSTITUTION_EMAIL) not found in Entra. Creating!" "INFO"
            $entra_user = New-MgUser `
                            -UserPrincipalName $user.INSTITUTION_EMAIL `
                            -OnPremisesImmutableId $user.IMMUTABLEID `
                            -DisplayName $user.DISPLAYNAME `
                            -GivenName $user.FIRSTNAME `
                            -Surname $user.LASTNAME `
                            -UsageLocation "US" `
                            -AccountEnabled `
                            -MailNickname $user.INSTITUTION_USERID
        }

        # Update Display Name
        if ($entra_user.DisplayName -ne $user.DisplayName) {
            Write-Log "Display name incorrect. Updating from $($entra_user.DisplayName) to $($user.DisplayName)" "INFO"
            Update-MgUser -UserId $entra_user.Id -DisplayName $user.DisplayName
        }
        else {
            Write-Log "Display name '$($entra_user.DisplayName)' is correct. Continuing!" "DEBUG"
        }

        # Update UDC ID / Immutable ID
        if ($entra_user.OnPremisesImmutableId -ne $user.IMMUTABLEID) {
            Write-Log "Immutable ID is incorrect. Updating from $($entra_user.OnPremisesImmutableId) to $($user.IMMUTABLEID)" "WARN"
            Update-MgUser -UserId $entra_user.Id -OnPremisesImmutableId $user.IMMUTABLEID
        }
        else {
            Write-Log "Immutable ID is correct: $($entra_user.OnPremisesImmutableId)" "DEBUG"
        }

        # Update BlockCredential
        if ($ad_user.Enabled -ne $entra_user.AccountEnabled) {
            Write-Log "AD user enabled status is $($ad_user.Enabled) but Entra user enabled status is $($entra_user.AccountEnabled). Updating Entra user to match!" "INFO"
            Update-MgUser -UserId $entra_user.Id -AccountEnabled:($ad_user.Enabled) # AccountEnabled is not a boolean. It is a switch parameter. WTF?
        }
        else {
            Write-Log "AD user and Entra user enabled status are both $($entra_user.AccountEnabled)" "DEBUG"
        }

        Write-Log "Student License SkuId: $($student_license.SkuId)" "DEBUG"
        Write-Log "User's current license SkuIds: $($entra_user.LicenseAssignmentStates.SkuId)" "DEBUG"


        # Update License
        if ($student_license.SkuId -in $entra_user.LicenseAssignmentStates.SkuId) {
            Write-Log "User is licensed for $($student_license.SkuId) - continuing!" "DEBUG"
        }
        else {
            Write-Log "Licensing user for $($student_license.SkuId)" "INFO"
            Set-MgUserLicense -UserId $entra_user.Id -AddLicenses $student_license -RemoveLicenses @()
        } 

        Write-Log "Finished processing user: $($user.DisplayName)" "DEBUG"
    }
    catch {
        Write-Log "An error occurred: $_`n`n$($_.ScriptStackTrace)" "ERROR"
    }
}

Remove-OldLogs

Exit
