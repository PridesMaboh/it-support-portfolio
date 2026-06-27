<#
.SYNOPSIS
    Tests network connectivity layer by layer: gateway, DNS, and internet.

.DESCRIPTION
    Structured connectivity test that goes beyond a single ping. Tests each
    network layer separately to pinpoint where a connectivity problem lies.

.PARAMETER InternalHostname
    Optional: An internal hostname to test DNS resolution against (e.g. a DC or file server).

.EXAMPLE
    .\Test-NetworkConnectivity.ps1
    .\Test-NetworkConnectivity.ps1 -InternalHostname "fileserver01"

.NOTES
    Author: Prides Fru Maboh
    Purpose: IT Support Portfolio – Project 02 (PowerShell Scripting)
    Tested on: Windows 11 22H2+
#>

#Requires -Version 5.1

param(
    [string]$InternalHostname
)

function Test-Step {
    param([string]$Description, [scriptblock]$Test)
    Write-Host "  Testing: $Description..." -NoNewline
    try {
        $result = & $Test
        if ($result) {
            Write-Host " PASS" -ForegroundColor Green
            return $true
        } else {
            Write-Host " FAIL" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host " ERROR: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  NETWORK CONNECTIVITY TEST" -ForegroundColor Cyan
Write-Host "  $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 1. Get default gateway
$gateway = (Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway } | Select-Object -First 1).IPv4DefaultGateway.NextHop
Write-Host "Default Gateway: $(if ($gateway) { $gateway } else { 'Not found' })" -ForegroundColor Yellow

$results = @{}

# 2. Ping gateway
$results['Gateway'] = Test-Step "Default gateway ($gateway)" {
    if (-not $gateway) { return $false }
    Test-Connection -ComputerName $gateway -Count 2 -Quiet -ErrorAction Stop
}

# 3. DNS resolution (public hostname)
$results['DNS'] = Test-Step "DNS resolution (resolve google.com)" {
    $null = [System.Net.Dns]::GetHostAddresses('google.com')
    $true
}

# 4. Internet HTTPS
$results['Internet'] = Test-Step "Internet connectivity (HTTPS to 1.1.1.1)" {
    $r = Invoke-WebRequest -Uri 'https://1.1.1.1' -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    $r.StatusCode -eq 200
}

# 5. Internal DNS (optional)
if ($InternalHostname) {
    $results['InternalDNS'] = Test-Step "Internal DNS resolution ($InternalHostname)" {
        $null = [System.Net.Dns]::GetHostAddresses($InternalHostname)
        $true
    }
}

# Summary
Write-Host "`n--- SUMMARY ---" -ForegroundColor Cyan
foreach ($key in $results.Keys) {
    $status = if ($results[$key]) { "PASS" } else { "FAIL" }
    $colour = if ($results[$key]) { "Green" } else { "Red" }
    Write-Host "  $key : $status" -ForegroundColor $colour
}

# Diagnosis hint
if (-not $results['Gateway']) {
    Write-Host "`nDiagnosis: Cannot reach gateway. Check physical connection, NIC, or DHCP." -ForegroundColor Yellow
} elseif (-not $results['DNS']) {
    Write-Host "`nDiagnosis: Gateway reachable but DNS failing. Check DNS server settings." -ForegroundColor Yellow
} elseif (-not $results['Internet']) {
    Write-Host "`nDiagnosis: DNS works but internet unreachable. Check firewall or ISP." -ForegroundColor Yellow
} else {
    Write-Host "`nDiagnosis: All tests passed. Network connectivity is healthy." -ForegroundColor Green
}

Write-Host ""
