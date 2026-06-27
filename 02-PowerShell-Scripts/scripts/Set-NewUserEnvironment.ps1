<#
.SYNOPSIS
    Creates a new local user account with a temporary password and optional group membership.

.DESCRIPTION
    Automates new-starter local account setup: creates the user, sets a temporary
    password (forced change on first login), and optionally adds them to a local group.
    Useful in SME environments or on standalone machines not joined to a domain.

.PARAMETER Username
    The username for the new local account (e.g. "jsmith").

.PARAMETER DisplayName
    The full display name shown in Windows (e.g. "John Smith").

.PARAMETER TempPassword
    The temporary password to set. User will be required to change it on first login.

.PARAMETER AddToGroup
    Optional: Name of a local group to add the user to (e.g. "Remote Desktop Users").

.EXAMPLE
    .\Set-NewUserEnvironment.ps1 -Username "jsmith" -DisplayName "John Smith" -TempPassword "TempPass123!"
    .\Set-NewUserEnvironment.ps1 -Username "jsmith" -DisplayName "John Smith" -TempPassword "TempPass123!" -AddToGroup "Remote Desktop Users"

.NOTES
    Author: Prides Fru Maboh
    Purpose: IT Support Portfolio – Project 02 (PowerShell Scripting)
    Requires: Run as Administrator
    Tested on: Windows 11 22H2+
#>

#Requires -Version 5.1
#Requires -RunAsAdministrator

param(
    [Parameter(Mandatory)]
    [string]$Username,

    [Parameter(Mandatory)]
    [string]$DisplayName,

    [Parameter(Mandatory)]
    [string]$TempPassword,

    [string]$AddToGroup
)

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  NEW USER SETUP" -ForegroundColor Cyan
Write-Host "  Computer: $env:COMPUTERNAME" -ForegroundColor Cyan
Write-Host "  Date: $(Get-Date -Format 'dd/MM/yyyy HH:mm')" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if user already exists
if (Get-LocalUser -Name $Username -ErrorAction SilentlyContinue) {
    Write-Host "ERROR: A local user named '$Username' already exists on this machine." -ForegroundColor Red
    Write-Host "       Choose a different username or remove the existing account first." -ForegroundColor Yellow
    exit 1
}

# Create the user
try {
    $securePassword = ConvertTo-SecureString $TempPassword -AsPlainText -Force
    New-LocalUser `
        -Name $Username `
        -FullName $DisplayName `
        -Password $securePassword `
        -PasswordNeverExpires $false `
        -UserMayNotChangePassword $false `
        -AccountNeverExpires `
        -Description "Created by IT Support on $(Get-Date -Format 'dd/MM/yyyy')" `
        -ErrorAction Stop | Out-Null

    Write-Host "  [OK] User '$Username' ($DisplayName) created." -ForegroundColor Green
} catch {
    Write-Host "  [FAIL] Could not create user: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Force password change on next login
try {
    $user = [ADSI]"WinNT://$env:COMPUTERNAME/$Username,user"
    $user.PasswordExpired = 1
    $user.SetInfo()
    Write-Host "  [OK] Password set to expire — user must change on first login." -ForegroundColor Green
} catch {
    Write-Host "  [WARN] Could not force password change: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Add to group (optional)
if ($AddToGroup) {
    try {
        Add-LocalGroupMember -Group $AddToGroup -Member $Username -ErrorAction Stop
        Write-Host "  [OK] Added '$Username' to group '$AddToGroup'." -ForegroundColor Green
    } catch {
        Write-Host "  [WARN] Could not add to group '$AddToGroup': $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Summary
Write-Host "`n--- ACCOUNT SUMMARY ---" -ForegroundColor Cyan
Write-Host "  Username     : $Username"
Write-Host "  Display Name : $DisplayName"
Write-Host "  Password     : Temporary (must change on first login)"
if ($AddToGroup) { Write-Host "  Group        : $AddToGroup" }
Write-Host "`n  Action: Ask the user to sign in and change their password before use.`n" -ForegroundColor Yellow
