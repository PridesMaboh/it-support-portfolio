<#
.SYNOPSIS
    Generates a quick system health report for IT support diagnostics.

.DESCRIPTION
    Outputs a structured summary of the local machine: OS version, RAM, uptime,
    disk usage, and current logged-in user. Useful as a first-run diagnostic
    when picking up a support ticket or connecting remotely.

.EXAMPLE
    .\Get-SystemHealthReport.ps1

.NOTES
    Author: Prides Fru Maboh
    Purpose: IT Support Portfolio – Project 02 (PowerShell Scripting)
    Tested on: Windows 11 22H2+
#>

#Requires -Version 5.1

function Get-SystemHealthReport {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  SYSTEM HEALTH REPORT" -ForegroundColor Cyan
    Write-Host "  $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan

    # --- OS & Computer Info ---
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $cs = Get-CimInstance -ClassName Win32_ComputerSystem

    Write-Host "SYSTEM" -ForegroundColor Yellow
    Write-Host "  Computer Name : $($env:COMPUTERNAME)"
    Write-Host "  Manufacturer  : $($cs.Manufacturer)"
    Write-Host "  Model         : $($cs.Model)"
    Write-Host "  OS            : $($os.Caption)"
    Write-Host "  Build         : $($os.BuildNumber)"
    Write-Host "  Architecture  : $($os.OSArchitecture)"

    # --- Uptime ---
    $uptime = (Get-Date) - $os.LastBootUpTime
    Write-Host "`nUPTIME" -ForegroundColor Yellow
    Write-Host "  Last Boot     : $($os.LastBootUpTime.ToString('dd/MM/yyyy HH:mm'))"
    Write-Host "  Uptime        : $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m"

    # --- Current User ---
    $currentUser = (Get-CimInstance -ClassName Win32_ComputerSystem).UserName
    Write-Host "`nCURRENT USER" -ForegroundColor Yellow
    Write-Host "  Logged In As  : $(if ($currentUser) { $currentUser } else { 'No interactive session' })"

    # --- RAM ---
    $totalRAM  = [math]::Round($cs.TotalPhysicalMemory / 1GB, 2)
    $freeRAM   = [math]::Round($os.FreePhysicalMemory / 1MB / 1024, 2)
    $usedRAM   = [math]::Round($totalRAM - $freeRAM, 2)
    $ramPct    = [math]::Round(($usedRAM / $totalRAM) * 100, 0)

    Write-Host "`nMEMORY" -ForegroundColor Yellow
    Write-Host "  Total RAM     : $totalRAM GB"
    Write-Host "  Used          : $usedRAM GB ($ramPct%)"
    Write-Host "  Free          : $freeRAM GB"

    # --- Disk ---
    Write-Host "`nDISK USAGE" -ForegroundColor Yellow
    $drives = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3"
    foreach ($drive in $drives) {
        $totalGB = [math]::Round($drive.Size / 1GB, 1)
        $freeGB  = [math]::Round($drive.FreeSpace / 1GB, 1)
        $usedGB  = [math]::Round($totalGB - $freeGB, 1)
        $pctFree = [math]::Round(($freeGB / $totalGB) * 100, 0)
        $colour  = if ($pctFree -lt 10) { 'Red' } elseif ($pctFree -lt 20) { 'Yellow' } else { 'Green' }
        Write-Host "  Drive $($drive.DeviceID)  Total: $totalGB GB  Used: $usedGB GB  Free: $freeGB GB ($pctFree% free)" -ForegroundColor $colour
    }

    Write-Host "`n========================================`n" -ForegroundColor Cyan
}

Get-SystemHealthReport
