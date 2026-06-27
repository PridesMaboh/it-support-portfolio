<#
.SYNOPSIS
    Lists all members of the local Administrators group.

.DESCRIPTION
    Useful for security audits and checking for unexpected privileged accounts
    before or after support work on a machine.

.EXAMPLE
    .\Get-LocalAdminMembers.ps1

.NOTES
    Author: Prides Fru Maboh
    Purpose: IT Support Portfolio – Project 02 (PowerShell Scripting)
    Tested on: Windows 11 22H2+
#>

#Requires -Version 5.1

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  LOCAL ADMINISTRATORS GROUP MEMBERS" -ForegroundColor Cyan
Write-Host "  Computer: $env:COMPUTERNAME" -ForegroundColor Cyan
Write-Host "  Date: $(Get-Date -Format 'dd/MM/yyyy HH:mm')" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

try {
    $members = Get-LocalGroupMember -Group "Administrators" -ErrorAction Stop |
        Select-Object Name, ObjectClass, PrincipalSource

    if ($members) {
        $members | Format-Table -AutoSize
        Write-Host "Total members: $($members.Count)" -ForegroundColor Yellow

        # Flag non-standard members
        $unexpected = $members | Where-Object {
            $_.Name -notmatch 'Administrator$' -and
            $_.Name -notmatch 'Domain Admins' -and
            $_.ObjectClass -eq 'User'
        }
        if ($unexpected) {
            Write-Host "`nNote: The following user accounts may warrant review:" -ForegroundColor Yellow
            $unexpected | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Yellow }
        }
    } else {
        Write-Host "No members found (unexpected — at least the built-in Administrator should appear)." -ForegroundColor Red
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "This script may need to run as Administrator." -ForegroundColor Yellow
}

Write-Host ""
