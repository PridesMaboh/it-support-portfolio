<#
.SYNOPSIS
    Lists all installed software on the local machine.

.DESCRIPTION
    Reads from both 64-bit and 32-bit registry hives to produce a complete
    list of installed applications. Can output to console or export to CSV.

.PARAMETER ExportCSV
    If specified, exports results to a CSV file at the given path.

.EXAMPLE
    .\Get-InstalledSoftware.ps1
    .\Get-InstalledSoftware.ps1 -ExportCSV "C:\Temp\software_report.csv"

.NOTES
    Author: Prides Fru Maboh
    Purpose: IT Support Portfolio – Project 02 (PowerShell Scripting)
    Tested on: Windows 11 22H2+
#>

#Requires -Version 5.1

param(
    [string]$ExportCSV
)

$registryPaths = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
)

Write-Host "`nCollecting installed software..." -ForegroundColor Cyan

$software = foreach ($path in $registryPaths) {
    if (Test-Path $path) {
        Get-ItemProperty -Path $path -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -and $_.DisplayName -ne '' } |
        Select-Object DisplayName, DisplayVersion, Publisher,
            @{ Name = 'InstallDate'; Expression = {
                if ($_.InstallDate -match '^\d{8}$') {
                    [datetime]::ParseExact($_.InstallDate, 'yyyyMMdd', $null).ToString('dd/MM/yyyy')
                } else { $_.InstallDate }
            }}
    }
}

$sorted = $software | Sort-Object DisplayName -Unique

Write-Host "Found $($sorted.Count) applications.`n" -ForegroundColor Green
$sorted | Format-Table -AutoSize

if ($ExportCSV) {
    $sorted | Export-Csv -Path $ExportCSV -NoTypeInformation -Encoding UTF8
    Write-Host "Exported to: $ExportCSV" -ForegroundColor Green
}
