<#
.SYNOPSIS
    Queries the Security event log for failed logon attempts and account lockouts.

.DESCRIPTION
    Searches for Event ID 4625 (failed logon) and Event ID 4740 (account lockout)
    to help troubleshoot "account keeps locking out" tickets. Commonly asked about
    in IT support interviews.

.PARAMETER Hours
    How many hours back to search. Default: 24.

.PARAMETER Username
    Optional: Filter results to a specific account name.

.EXAMPLE
    .\Get-FailedLoginEvents.ps1
    .\Get-FailedLoginEvents.ps1 -Hours 48 -Username "jsmith"

.NOTES
    Author: Prides Fru Maboh
    Purpose: IT Support Portfolio – Project 02 (PowerShell Scripting)
    Requires: Run as Administrator (Security log access)
    Tested on: Windows 11 22H2+
#>

#Requires -Version 5.1
#Requires -RunAsAdministrator

param(
    [int]$Hours = 24,
    [string]$Username
)

$startTime = (Get-Date).AddHours(-$Hours)

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  FAILED LOGIN / LOCKOUT REPORT" -ForegroundColor Cyan
Write-Host "  Last $Hours hours ($($startTime.ToString('dd/MM/yyyy HH:mm')) onwards)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Event ID 4625 = Failed logon
# Event ID 4740 = Account lockout
$eventIDs = @(4625, 4740)

try {
    $events = Get-WinEvent -FilterHashtable @{
        LogName   = 'Security'
        Id        = $eventIDs
        StartTime = $startTime
    } -ErrorAction Stop
} catch [System.Exception] {
    if ($_.Exception.Message -like '*No events*') {
        Write-Host "No failed login or lockout events found in the last $Hours hours." -ForegroundColor Green
        exit 0
    }
    throw
}

$results = foreach ($event in $events) {
    $xml = [xml]$event.ToXml()
    $data = $xml.Event.EventData.Data

    $accountName = ($data | Where-Object { $_.Name -eq 'TargetUserName' }).'#text'
    $workstation  = ($data | Where-Object { $_.Name -eq 'WorkstationName' }).'#text'
    $ipAddress    = ($data | Where-Object { $_.Name -eq 'IpAddress' }).'#text'
    $logonType    = ($data | Where-Object { $_.Name -eq 'LogonType' }).'#text'

    [PSCustomObject]@{
        Time        = $event.TimeCreated.ToString('dd/MM/yyyy HH:mm:ss')
        EventID     = $event.Id
        Type        = if ($event.Id -eq 4625) { 'Failed Logon' } else { 'Account Lockout' }
        Account     = $accountName
        Workstation = $workstation
        SourceIP    = $ipAddress
        LogonType   = $logonType
    }
}

if ($Username) {
    $results = $results | Where-Object { $_.Account -like "*$Username*" }
}

if ($results) {
    $results | Format-Table -AutoSize
    Write-Host "Total events: $($results.Count)" -ForegroundColor Yellow

    # Group by account for quick overview
    Write-Host "`nFailed attempts by account:" -ForegroundColor Cyan
    $results | Group-Object Account | Sort-Object Count -Descending |
        Select-Object Name, Count | Format-Table -AutoSize
} else {
    Write-Host "No events matched the specified criteria." -ForegroundColor Green
}
