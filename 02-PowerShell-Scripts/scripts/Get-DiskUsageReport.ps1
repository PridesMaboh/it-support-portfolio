<#
.SYNOPSIS
    Reports disk usage for all local drives with low-space warnings.

.PARAMETER ThresholdPercent
    Percentage free space below which a warning is shown. Default: 15.

.EXAMPLE
    .\Get-DiskUsageReport.ps1
    .\Get-DiskUsageReport.ps1 -ThresholdPercent 20

.NOTES
    Author: Prides Fru Maboh
    Purpose: IT Support Portfolio – Project 02 (PowerShell Scripting)
    Tested on: Windows 11 22H2+
#>

#Requires -Version 5.1

param(
    [int]$ThresholdPercent = 15
)

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  DISK USAGE REPORT" -ForegroundColor Cyan
Write-Host "  Computer: $env:COMPUTERNAME" -ForegroundColor Cyan
Write-Host "  Date: $(Get-Date -Format 'dd/MM/yyyy HH:mm')" -ForegroundColor Cyan
Write-Host "  Warning threshold: <$ThresholdPercent% free" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$drives = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3"

if (-not $drives) {
    Write-Host "No fixed drives found." -ForegroundColor Yellow
    exit
}

$anyWarning = $false
foreach ($drive in $drives) {
    $totalGB = [math]::Round($drive.Size / 1GB, 2)
    $freeGB  = [math]::Round($drive.FreeSpace / 1GB, 2)
    $usedGB  = [math]::Round($totalGB - $freeGB, 2)
    $pctFree = if ($totalGB -gt 0) { [math]::Round(($freeGB / $totalGB) * 100, 1) } else { 0 }
    $pctUsed = 100 - $pctFree

    $colour = if ($pctFree -lt $ThresholdPercent) { 'Red'; $anyWarning = $true }
              elseif ($pctFree -lt ($ThresholdPercent + 10)) { 'Yellow' }
              else { 'Green' }

    $bar = '[' + ('=' * [math]::Round($pctUsed / 5)) + (' ' * (20 - [math]::Round($pctUsed / 5))) + ']'

    Write-Host "  Drive $($drive.DeviceID)" -ForegroundColor $colour -NoNewline
    Write-Host "  $bar $pctUsed% used  |  $freeGB GB free of $totalGB GB" -ForegroundColor $colour
}

if ($anyWarning) {
    Write-Host "`n  WARNING: One or more drives are below the $ThresholdPercent% free threshold." -ForegroundColor Red
} else {
    Write-Host "`n  All drives have adequate free space." -ForegroundColor Green
}

Write-Host ""
