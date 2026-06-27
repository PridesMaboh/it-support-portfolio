# Entra ID Conditional Access + MFA

## Project Goal
Configure a realistic set of Conditional Access policies in Microsoft Entra ID (Azure AD) to enforce MFA, block legacy authentication, and protect admin accounts — demonstrating identity and security skills relevant to 2nd line and above roles.

## Project Overview
This project uses the same Microsoft 365 Business Premium trial tenant as Project 01 (Intune + Autopilot Lab). It simulates the identity security posture of a small-to-medium UK organisation migrating to modern authentication.

Identity and Conditional Access come up frequently in IT support interviews because they underpin everything from MFA rollouts to "why can't I sign in?" tickets.

---

## Lab Environment

**Tenant:** Microsoft 365 Business Premium trial (same as Project 01)
> Includes Entra ID P1, which is required for Conditional Access policies.

**Test accounts configured:**
- `admin@<tenant>.onmicrosoft.com` — Global Administrator
- `user1@<tenant>.onmicrosoft.com` — Standard user (test target for policies)
- `newstarter@<tenant>.onmicrosoft.com` — Simulates a recently onboarded employee

**Security groups:**
- `CA-AllUsers` — all licensed users (policy target)
- `CA-Admins` — admin accounts (stricter policy target)
- `CA-Exclude` — break-glass / exclusion group (never locked out)

---

## Policies Configured

### Policy 1: Require MFA for All Users
**What it does:** Enforces MFA registration and sign-in for every user signing into any cloud app.

**Settings:**
- Users: All users (exclude `CA-Exclude` group)
- Cloud apps: All cloud apps
- Conditions: None (applies everywhere)
- Grant: Require multi-factor authentication

**Why it matters:** The single most impactful policy for reducing account compromise. Required for Cyber Essentials Plus and many UK public sector frameworks.

---

### Policy 2: Block Legacy Authentication
**What it does:** Blocks sign-in attempts using protocols that don't support MFA — IMAP, POP3, SMTP AUTH, older Office clients.

**Settings:**
- Users: All users (exclude `CA-Exclude`)
- Cloud apps: All cloud apps
- Conditions: Client apps = Exchange ActiveSync + Other clients
- Grant: Block access

**Why it matters:** Over 97% of password spray attacks use legacy auth. Blocking it is a quick security win and is standard practice in modern M365 tenants.

---

### Policy 3: Require MFA + Compliant Device for Admins
**What it does:** Admin accounts must satisfy both MFA and device compliance before signing into admin portals.

**Settings:**
- Users: `CA-Admins` group
- Cloud apps: Microsoft Admin Portals (Intune, Azure, M365 Admin)
- Conditions: None
- Grant: Require MFA **AND** require compliant device (Intune compliance policy from Project 01)

**Why it matters:** Admin accounts are the highest-value target. This policy means compromising a password alone is not sufficient — the attacker also needs a registered compliant device.

---

### Policy 4: Sign-in Risk Policy (Entra ID Protection)
**What it does:** Automatically requires MFA or blocks access when Entra ID detects a risky sign-in (e.g., sign-in from an unusual location or anonymous IP).

**Settings:**
- Users: All users (exclude `CA-Exclude`)
- Cloud apps: All cloud apps
- Conditions: Sign-in risk = Medium or High
- Grant: Require MFA (Medium risk) / Block (High risk)

**Why it matters:** Demonstrates understanding of risk-based authentication — a step beyond basic Conditional Access. Shows ability to use intelligence-driven security controls.

---

## Step-by-Step Build Plan

1. **Prepare the tenant**
   - Create security groups: `CA-AllUsers`, `CA-Admins`, `CA-Exclude`
   - Add a break-glass admin account to `CA-Exclude` (never lock yourself out)
   - Assign test users to appropriate groups

2. **Enable Security Defaults: OFF**
   - Security Defaults conflict with Conditional Access — must be disabled first
   - Document this step clearly (common source of confusion)

3. **Create Policy 1: Require MFA for All Users**
   - Set to Report-Only mode first to check impact
   - Review sign-in logs to confirm expected coverage
   - Switch to Enabled once validated

4. **Create Policy 2: Block Legacy Auth**
   - Test by attempting IMAP sign-in before and after enabling
   - Check Message Trace in Exchange Online to confirm blocks

5. **Create Policy 3: Admin MFA + Compliant Device**
   - Assign admin accounts to `CA-Admins` group
   - Reference the Intune compliance policy from Project 01
   - Test by signing into Intune admin center as an admin user

6. **Create Policy 4: Sign-in Risk**
   - Enable Entra ID Protection (included in Business Premium)
   - Configure User Risk and Sign-in Risk policies
   - Use the Tor Browser or VPN to simulate a risky sign-in for testing

7. **Review sign-in logs**
   - Check Entra ID sign-in logs to confirm policies are applying as expected
   - Screenshot the Conditional Access insight for each policy

---

## Evidence / Screenshot Checklist

- [ ] Security Defaults disabled (Entra ID > Properties)
- [ ] Security groups created and populated
- [ ] Policy 1: MFA for All Users — configuration screenshot
- [ ] Policy 1: Sign-in log showing MFA prompt applied
- [ ] Policy 2: Block Legacy Auth — configuration screenshot
- [ ] Policy 2: Block confirmed in sign-in logs (failure reason = "blocked by CA policy")
- [ ] Policy 3: Admin policy configuration screenshot
- [ ] Policy 4: Risk policy configuration
- [ ] Entra ID Protection dashboard screenshot
- [ ] Sign-in log entry showing risk-based MFA triggered

Store screenshots in `assets/03-entra-ca/` and reference them inline in this README.

---

## Key Concepts for Interview Preparation

| Topic | What to Know |
|-------|-------------|
| What is Conditional Access? | Policy engine that evaluates conditions (who, what app, what device, what risk) and grants/blocks access |
| Why block legacy auth? | Legacy protocols can't prompt for MFA, so attackers use them to bypass it |
| What is a break-glass account? | An emergency admin account excluded from all CA policies — used if you lock yourself out |
| Report-Only mode | Tests a policy's impact without enforcing it — always use before enabling new policies |
| MFA methods | Authenticator app push (most secure), SMS (least secure), FIDO2 key (phishing-resistant) |
| Named Locations | Can use IP ranges or country to restrict where sign-ins are allowed from |

---

## Tools & Technologies
- Microsoft Entra ID (Azure Active Directory)
- Entra ID Protection
- Conditional Access
- Microsoft 365 Business Premium trial
- Microsoft Authenticator (MFA)

---

## Current Status

| Phase | Status | Notes |
|-------|--------|-------|
| Research & design | Complete | All 4 policies planned and documented |
| Tenant preparation | Not Started | Uses same M365 trial as Project 01 |
| Policy creation | Not Started | Sequenced after Project 01 trial is running |
| Testing & validation | Not Started | |
| Evidence capture | Not Started | |

## Next Steps
- Start M365 Business Premium trial (coordinate with Project 01)
- Disable Security Defaults before creating any CA policies
- Build policies in Report-Only mode first, validate in sign-in logs, then enable
