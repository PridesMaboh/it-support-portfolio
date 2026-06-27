# PowerShell Scripting for IT Support

## Project Goal
Build a library of practical PowerShell scripts that automate real IT support tasks — system health checks, user account management, software reporting, and endpoint diagnostics. Each script is documented with a real-world use case and expected output.

## Why PowerShell Matters for IT Support
Most 2nd line and deskside support roles expect engineers to read, modify, and run PowerShell scripts for:
- Automating repetitive tasks (password resets, account unlocks, software checks)
- Gathering system information quickly without clicking through GUIs
- Integrating with Microsoft 365, Intune, and Entra ID via the Graph API
- Producing reports for managers or audit trails

---

## Scripts in This Collection

| Script | Use Case | Category |
|--------|----------|----------|
| `Get-SystemHealthReport.ps1` | Generates a quick system summary: OS, RAM, disk, uptime | Diagnostics |
| `Get-InstalledSoftware.ps1` | Lists all installed applications with version numbers | Asset Management |
| `Test-NetworkConnectivity.ps1` | Tests DNS, gateway, and internet connectivity with structured output | Networking |
| `Get-LocalAdminMembers.ps1` | Lists members of the local Administrators group | Security Audit |
| `Get-FailedLoginEvents.ps1` | Queries the Security event log for failed login attempts (Event ID 4625) | Security Audit |
| `Set-NewUserEnvironment.ps1` | Creates a local user, sets a temporary password, and adds to a group | User Management |
| `Get-DiskUsageReport.ps1` | Reports disk usage per drive with free space warnings | Diagnostics |

---

## Script Documentation

---

### `Get-SystemHealthReport.ps1`

**Use case:** First thing an IT engineer runs when picking up a ticket or connecting to a machine remotely. Gives a structured snapshot without digging through multiple menus.

**Output includes:**
- Computer name, OS version, build number
- Total and available RAM
- Uptime (since last reboot)
- Disk space per logical drive
- Current logged-in user

**Real-world value:** Faster than opening System Properties, Task Manager, and File Explorer separately. Useful for documenting a machine's state before and after work.

---

### `Get-InstalledSoftware.ps1`

**Use case:** Software audit before a refresh, checking if a required app is installed, or verifying a deployment succeeded before closing a ticket.

**Output includes:**
- Display name, version, publisher, install date
- Sorted alphabetically, exported as CSV option

**Real-world value:** Avoids relying on Add/Remove Programs (which misses some installs). Reads from both 64-bit and 32-bit registry hives.

---

### `Test-NetworkConnectivity.ps1`

**Use case:** Network troubleshooting — quickly test whether a connectivity issue is at DNS, gateway, or internet level, rather than just running a single ping.

**Tests performed:**
1. Local gateway reachability (ping)
2. DNS resolution (resolves a known hostname)
3. Internet connectivity (HTTPS test to a reliable endpoint)
4. Internal DNS (resolves internal hostname if specified)

**Real-world value:** Structured output means you can rule out each layer systematically — useful for documenting what was tested and when.

---

### `Get-LocalAdminMembers.ps1`

**Use case:** Security audit or before/after comparison when troubleshooting privilege escalation. Check which accounts are local admins on a machine.

**Real-world value:** Quick way to catch unexpected admin accounts (leftover test accounts, temp admin grants that were never removed) during an audit or site visit.

---

### `Get-FailedLoginEvents.ps1`

**Use case:** A user says "my account keeps getting locked" — this script checks the local Security log for Event ID 4625 (failed logon) and 4740 (account lockout) to identify the source.

**Output includes:**
- Timestamp, account name, logon type, source IP/workstation
- Filterable by time range and account name

**Real-world value:** Much faster than manually scrolling Event Viewer. Commonly asked about in 2nd line interviews ("how would you troubleshoot an account lockout?").

---

### `Set-NewUserEnvironment.ps1`

**Use case:** Setting up a new local user account on a machine — either for a new starter or for a temporary/test account during troubleshooting.

**Actions:**
- Creates a local user with a specified username
- Sets a temporary password (forces change on next login)
- Optionally adds to a local group (e.g., Remote Desktop Users)
- Outputs confirmation of each step

**Real-world value:** Demonstrates understanding of user management without needing AD — useful in SME environments where not everything is domain-joined.

---

### `Get-DiskUsageReport.ps1`

**Use case:** Pre-emptive disk monitoring. Flag drives that are under a specified free-space threshold (e.g., less than 10% free).

**Output includes:**
- Drive letter, total size, used space, free space (GB and %)
- Colour-coded warning if below threshold (red in console)

**Real-world value:** Proactive monitoring skill — shows you think beyond reactive ticket work.

---

## Evidence Checklist

- [ ] Each script runs without errors on a Windows 11 machine
- [ ] Screenshot of `Get-SystemHealthReport.ps1` output in a PowerShell console
- [ ] Screenshot of `Get-InstalledSoftware.ps1` output (table view)
- [ ] Screenshot of `Test-NetworkConnectivity.ps1` showing pass/fail on each test
- [ ] Screenshot of `Get-FailedLoginEvents.ps1` output (even with no events — shows it ran)
- [ ] Screenshot of `Set-NewUserEnvironment.ps1` creating a test user
- [ ] CSV export example from at least one script

Store screenshots in `assets/02-powershell/` and link them inline in this README.

---

## Tools & Technologies
- PowerShell 5.1 / PowerShell 7+
- Windows 11
- Windows Event Log
- Registry (for software inventory)
- WMI / CIM (for system info)

---

## Current Status

| Phase | Status | Notes |
|-------|--------|-------|
| Script design & use cases | Complete | All 7 scripts planned with documented rationale |
| Script writing | Complete | All scripts written and saved in `scripts/` |
| Testing | In Progress | Running on Windows 11 test machine |
| Evidence capture | Not Started | Screenshots to be added during testing |
| Write-up | Not Started | Inline screenshots and notes to follow testing |

## Next Steps
- Test each script on the Windows 11 VM used in Project 01
- Capture console screenshots as evidence
- Export a CSV from `Get-InstalledSoftware.ps1` and commit it as a sample output
- Note any errors or quirks encountered (good interview content)
