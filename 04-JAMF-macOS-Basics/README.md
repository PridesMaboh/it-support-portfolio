# JAMF / macOS Fundamentals

## Project Goal
Understand the core concepts of Apple device management using JAMF Pro — demonstrating awareness of macOS endpoint management alongside the Microsoft-focused skills in Projects 01–03. This broadens the portfolio to cover mixed-OS environments, which is common in UK tech companies and agencies.

## Why This Project?
Many IT support roles in London and the South East — particularly in media, fintech, legal, and creative industries — run mixed Mac/Windows estates. Being able to speak to JAMF, MDM profiles, and macOS management makes a candidate stand out from Windows-only applicants.

---

## Lab Environment

**JAMF Pro:** JAMF offers a free 90-day trial at jamf.com/try-jamf-pro/

**Test device options:**
- A physical Mac (even an older model running macOS Ventura or Sonoma)
- A Mac VM (VMware Fusion or Parallels on Apple Silicon; UTM for M-series Macs)

**Target macOS version:** macOS Sonoma 14.x (Ventura 13.x also supported)

---

## Core Concepts Covered

### 1. Enrolling a Mac into JAMF
**Method:** Automated Device Enrolment (ADE) via Apple Business Manager, OR manual enrolment via the JAMF enrolment URL.

For this lab, manual enrolment is used (ADE requires Apple Business Manager, which requires a registered business — not needed for a portfolio lab).

**Enrolment steps:**
1. Log into JAMF Pro → Computers → Enrolment
2. Generate an enrolment URL
3. On the Mac: open the URL in Safari, download and install the MDM profile
4. Confirm the Mac appears in JAMF Pro's computer inventory

---

### 2. Computer Inventory
Once enrolled, JAMF automatically collects:
- Hardware details (model, serial number, RAM, storage)
- OS version
- Installed applications
- User and group information

**Key JAMF Pro views to explore:**
- Computers → All Computers → select a device → Hardware, Storage, Applications tabs
- Smart Groups — dynamic groups based on criteria (e.g., "all Macs on macOS < 14.0")

---

### 3. Configuration Profiles (Equivalent to Intune Config Profiles)
JAMF uses configuration profiles (`.mobileconfig` files) to push settings to Macs. These are equivalent to Intune configuration profiles for Windows.

**Profiles built in this lab:**

| Profile | Settings Applied |
|---------|-----------------|
| Security Baseline | Require password, screen lock timeout, disable automatic login |
| Software Update | Set macOS update deadline, enable automatic security patches |
| Restrictions | Disable iCloud Drive for organisational Macs |

**Steps:**
1. JAMF Pro → Computers → Configuration Profiles → New
2. Select a payload (e.g., Passcode, Security & Privacy, Software Update)
3. Configure settings, set scope (all enrolled Macs), save and deploy

---

### 4. Policies (Software Deployment & Scripts)
JAMF Policies are the equivalent of Intune Win32 apps or PowerShell scripts — they run actions on enrolled Macs.

**Policies built in this lab:**

| Policy | Trigger | Action |
|--------|---------|--------|
| Install Google Chrome | Enrolment Complete | Deploy Chrome PKG via Jamf-managed package |
| Run macOS Health Script | Weekly | Shell script to check disk usage and report |

**Basic shell script used:**
```bash
#!/bin/bash
# JAMF-deployed health check script
df -h /
echo "Uptime: $(uptime)"
echo "macOS Version: $(sw_vers -productVersion)"
```

---

### 5. Key Differences: JAMF vs Intune

| Feature | Microsoft Intune | JAMF Pro |
|---------|-----------------|----------|
| Primary platform | Windows, iOS/Android | macOS, iOS |
| Enrolment | Autopilot / ADE / manual | ADE / manual URL |
| Config management | Configuration Profiles | Configuration Profiles (.mobileconfig) |
| Software deployment | Win32 apps, LOB apps | Packages (PKG/DMG), App Catalog |
| Scripting | PowerShell | Bash / Python / zsh |
| Compliance | Intune Compliance Policies | JAMF Compliance Reporter |
| Integration | Native M365 / Entra ID | Can integrate with Entra ID via JAMF Connect |

---

## Evidence / Screenshot Checklist

- [ ] Mac enrolled in JAMF Pro (Computers list screenshot)
- [ ] Computer inventory record (Hardware tab)
- [ ] Configuration profile created and deployed (Security Baseline)
- [ ] Profile visible on Mac: System Settings → Privacy & Security → Profiles
- [ ] Policy created (software install or script)
- [ ] Policy log showing successful execution
- [ ] Smart Group example (e.g., "Macs below minimum OS version")

Store screenshots in `assets/04-jamf-macos/`

---

## Key Concepts for Interview Preparation

| Topic | What to Know |
|-------|-------------|
| What is JAMF Pro? | Enterprise Apple device management platform; the leading MDM for Mac in UK enterprise |
| MDM profile | A signed XML file (`.mobileconfig`) that applies settings to a Mac via the MDM framework |
| Smart Groups | Dynamic device groups in JAMF based on hardware/software criteria — auto-update as devices change |
| JAMF Connect | Integrates JAMF with Entra ID for SSO and account provisioning on Macs (replaces directory binding) |
| ADE vs manual | ADE (via Apple Business Manager) is the enterprise standard — ties device to org before first boot |
| Package deployment | JAMF uses `.pkg` files for software; can use Composer or AutoPkg to build them |

---

## Tools & Technologies
- JAMF Pro (trial)
- Apple macOS Sonoma
- MDM (Mobile Device Management)
- Bash scripting
- Apple Business Manager concepts

---

## Current Status

| Phase | Status | Notes |
|-------|--------|-------|
| Research & concept mapping | Complete | Intune vs JAMF comparison documented |
| JAMF trial setup | Not Started | Trial available at jamf.com |
| Lab build | Not Started | Requires Mac hardware or VM |
| Evidence capture | Not Started | |

## Next Steps
- Start JAMF Pro 90-day trial when ready
- Enrol the MacBook (or a macOS VM) into the trial tenant
- Build at least one configuration profile and one policy as evidence
- Compare the experience to Intune (good interview discussion point)
