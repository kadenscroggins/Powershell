$User1 = Read-Host "User 1 (User to copy access from)"
$User2 = Read-Host "User 2 (User to be granted access)"

$User1Groups = Get-ADPrincipalGroupMembership $user1 | Get-ADGroup -Properties * | select name
$User2Groups = Get-ADPrincipalGroupMembership $user2 | Get-ADGroup -Properties * | select name

Write-Output "$User1 Groups:"
Write-Output $User1Groups | Format-Table -HideTableHeaders

Write-Output "$User2 Groups:"
Write-Output $User2Groups | Format-Table -HideTableHeaders

$OutputGroups = [System.Collections.ArrayList]@()

foreach($group in $User1Groups)
{
    if ($User2Groups -match $group) { continue }
    else { $OutputGroups.Add($group) | out-null }
}

Write-Output "Groups present on $User1 but missing on ${User2}:"
Write-Output $OutputGroups | Format-Table -HideTableHeaders

$FormattedOutputGroups = ""
foreach($group in $OutputGroups)
{
    $FormattedOutputGroups += $group.name
    $FormattedOutputGroups += ";"
}

Write-Output "Formatted for AD input:`n$FormattedOutputGroups`n"

Pause