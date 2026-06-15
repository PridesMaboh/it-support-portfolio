# Intune + Autopilot Lab

## Project Goal
Build a realistic Microsoft Intune and Windows Autopilot lab environment to demonstrate modern endpoint management, device enrolment, and configuration capabilities.

## Project Overview
This project simulates a real-world scenario where an organisation is moving from traditional imaging to a modern, cloud-native deployment model using Microsoft Intune and Windows Autopilot.

## What This Project Demonstrates
- Device enrolment using Windows Autopilot (user-driven mode)
- Configuration of Intune compliance policies and configuration profiles
- Application deployment and management
- Security baselines and endpoint protection basics
- Documentation and operational processes suitable for 1st/2nd/3rd line support roles

---

## Lab Environment

**Tenant:** Microsoft 365 Business Premium 30-day free trial (includes Intune + Entra ID P1, sufficient for Autopilot, compliance policies, configuration profiles, and Conditional Access).

> Note: the Microsoft 365 Developer Program's free E5 sandbox now requires an active Visual Studio Enterprise subscription, so it isn't used here — the Business Premium trial covers everything this lab and Project 03 (Conditional Access) need.

**Test device:** A Windows 11 virtual machine (Hyper-V Gen 2, with virtual TPM enabled — required for Autopilot hardware hash generation and compliance checks). VirtualBox can also work but vTPM support is more limited; Hyper-V is recommended if your Windows edition supports it (Pro/Enterprise/Education).

**Admin tools used:**
- Microsoft Intune admin center (intune.microsoft.com)
- Microsoft Entra admin center (entra.microsoft.com)
- PowerShell (`Get-WindowsAutopilotInfo` script for hardware hash extraction)
- Win32 Content Prep Tool (`IntuneWinAppUtil.exe`) for app packaging

---

## Lab Scenario

**"New Starter Device Provisioning – TechCorp UK"**

A new employee is joining the IT-supported business unit. Instead of building and imaging a laptop manually, IT registers the device for Autopilot ahead of time. On first boot, the device automatically enrols into Intune, applies the organisation's branding, security baseline, and required apps, and the user signs in with their own credentials — no IT intervention needed at the desk.

This mirrors the "device deployment / IMAC" and "endpoint management" responsibilities listed in 2nd line and deskside support job descriptions.

---

## Step-by-Step Build Plan

1. **Tenant setup**
   - Sign up for the M365 Business Premium trial
   - Create a test user (e.g. `newstarter@<tenant>.onmicrosoft.com`) and a security group (e.g. `Autopilot-Devices`)
   - Confirm Intune and Entra ID P1 licenses are active

2. **Register the device with Autopilot**
   - Build the Windows 11 VM (Hyper-V Gen 2, vTPM enabled, not yet through OOBE)
   - Boot to the out-of-box experience, press `Shift+F10` for a command prompt
   - Run `Get-WindowsAutopilotInfo -Online` (or export a CSV and import manually) to register the device's hardware hash to the tenant

3. **Create an Autopilot deployment profile**
   - User-driven mode, Entra ID join
   - Disable the privacy and license agreement screens, set the OOBE language/region as appropriate
   - Assign the profile to the `Autopilot-Devices` group

4. **Configure the Enrollment Status Page (ESP)**
   - Show progress to the user during setup
   - Block device use until required apps and profiles are installed
   - Set a timeout and define what happens if it's exceeded

5. **Build configuration profiles**
   - Security baseline (or a custom profile covering Windows Update rings, Microsoft Defender settings)
   - A branding/personalisation profile (lock screen image, wallpaper)
   - Windows Hello for Business or basic sign-in policy

6. **Build a compliance policy**
   - Require BitLocker
   - Require a minimum password length / Windows Hello
   - Set a non-compliance action (e.g. mark device non-compliant, notify user)

7. **Package and deploy an application**
   - Use `IntuneWinAppUtil.exe` to package a small app (e.g. 7-Zip or Notepad++) as a `.intunewin` file
   - Create a Win32 app in Intune with install/uninstall commands and detection rules
   - Assign as "Required" to the `Autopilot-Devices` group

8. **Run the end-to-end test**
   - Reset the VM back to OOBE
   - Boot through Autopilot: confirm branding, ESP progress, app installation, and final sign-in
   - Confirm the device appears in Intune as enrolled and compliant

9. **Capture evidence throughout** (see checklist below)

10. **Write up troubleshooting notes** — anything that didn't work first time is genuinely useful content for interviews

---

## Evidence / Screenshot Checklist

- [ ] Device registered in Windows Autopilot (Devices list)
- [ ] Autopilot deployment profile configuration
- [ ] ESP configuration
- [ ] Compliance policy configuration and assignment
- [ ] Configuration profile(s) configuration and assignment
- [ ] Win32 app packaging command/output
- [ ] App deployment status in Intune (install succeeded)
- [ ] OOBE walkthrough on the test device (a few key screens)
- [ ] Final device record in Intune showing "Enrolled" and "Compliant"

Store screenshots in `assets/01-intune-autopilot/` and reference them inline in this README as each section is completed.

---

## Known Limitations & Challenges

- Trial tenant is time-boxed to 30 days — sequence this lab and Project 03 to both fit inside that window
- VM-based Autopilot has quirks vs. physical hardware (vTPM must be explicitly enabled in VM settings; some OEM-specific Autopilot features won't apply)
- Business Premium trial may rate-limit certain bulk operations — note any throttling encountered

---

## Tools & Technologies Used
- Microsoft Intune
- Windows Autopilot
- Microsoft Entra ID
- Windows 11
- PowerShell

---

## Current Status

| Phase | Status | Notes |
|---|---|---|
| Project Setup | Complete | Scope, scenario, and build plan defined |
| Research & Planning | Complete | Licensing route confirmed (M365 Business Premium trial) |
| Lab Build | Not Started | Pending trial tenant start |
| Documentation | Not Started | Evidence checklist prepared, to be filled in during build |

## Next Steps
- Start the M365 Business Premium trial when ready to run this lab and Project 03 together
- Work through the build plan above in order, capturing evidence at each step
- Replace this status table with completed checkboxes and screenshots as work progresses
