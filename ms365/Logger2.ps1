$LogDirectory = ".\Logs" # Directory to save logs to
$LogNamePrefix = "microsoft-license-sync" # Name of file before -$LogDate.log
$LogDate = Get-Date -Uformat %s # Epoch timestamp (Seconds since Jan 1 1970)
$LogFile = "$LogDirectory\$LogNamePrefix-$LogDate.log" # Full path to log file
$LogCount = 5 # Number of logs to save
$LogLevel = "INFO" # Level of logs to write
$LogLevels = ("DEBUG","INFO","WARN","ERROR","FATAL") # Available levels

# Save array of LogEntry to file
Function Write-Log {
    [CmdletBinding()]Param(
    [Parameter(Mandatory=$True)][string]$Message,
    [Parameter(Mandatory=$False)][String]$Level = "DEBUG"
    )

    if ($LogLevels.IndexOf($Level) -lt $LogLevels.IndexOf($LogLevel)) {
        return
    }

    Add-Content -Path $LogFile -Value "[$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))][$($Level)] $($Message)"
}

Function Remove-OldLogs {
    # Get all files in log dierctory, filter to only log files, sort by name (effectively sorting by timestamp)
    $OldLogs = Get-ChildItem $LogDirectory | Where-Object { $_.Name -match "microsoft-license-sync-[0-9]+\.log"} | Sort-Object Name
    # Delete extra logs
    if ($OldLogs.Length -gt $LogCount - 1) {
        $RemoveCount = $OldLogs.Length - $LogCount
        for ($i=0; $i -lt $RemoveCount; $i++) {
            Remove-Item -Path $OldLogs[$i]
        }
    }
}
