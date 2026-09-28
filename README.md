# 🛡️ Pi-hole Policy

[![CI](https://github.com/AetherScope-Dev/pihole-policy/actions/workflows/ci.yml/badge.svg)](https://github.com/AetherScope-Dev/pihole-policy/actions/workflows/ci.yml)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPL--3.0-blue.svg)](LICENSE)
[![Pi-hole v6](https://img.shields.io/badge/Pi--hole-v6-blue.svg)](https://pi-hole.net/)
[![Version](https://img.shields.io/badge/version-1.0.0-brightgreen.svg)](CHANGELOG.md)

**Pi-hole Policy** is a centralized policy-as-code framework for deploying and maintaining consistent DNS filtering across **Pi-hole v6** systems.

It provides reusable **Standard** and **Hardened** security baselines, automated policy synchronization, and safe reconciliation of managed subscriptions without replacing local Pi-hole configuration. Upstream feeds remain sourced directly from their original publishers and are refreshed through Pi-hole Gravity.

The project is intended for homelabs, small businesses, MSP-style deployments, and other environments where multiple Pi-hole instances need a consistent, auditable DNS security posture.

---

## 📑 Table of contents

- [What this does](#-what-this-does)
- [Why use this?](#-why-use-this)
- [Policy tiers](#-policy-tiers)
  - [Standard](#-standard)
  - [Hardened](#-hardened)
- [Quick start](#-quick-start)
- [What happens after installation?](#-what-happens-after-installation)
- [Architecture](#-architecture)
- [Repository layout](#-repository-layout)
- [Verify a deployment](#-verify-a-deployment)
- [Change policy tiers](#-change-policy-tiers)
- [Client-specific exceptions](#-client-specific-exceptions)
- [Troubleshooting](#-troubleshooting)
- [Quality controls](#-quality-controls)
- [Safety model](#-safety-model)
- [Upstream projects](#-upstream-projects)
- [Licensing & attribution](#-licensing--attribution)
- [Contributing](#-contributing)
- [Releases](#-releases)
- [Maintainer](#-maintainer)
- [Disclaimer](#-disclaimer)

---

## ✨ What this does

- Provides **Standard** and **Hardened** DNS filtering baselines
- Synchronizes policy across multiple Pi-hole deployments
- Preserves site-specific local allow/deny rules
- Tags policy-managed subscriptions for safe reconciliation
- Pulls upstream feeds directly from their original publishers
- Removes stale policy-managed subscriptions when manifests change
- Runs `pihole updateGravity` after policy reconciliation
- Keeps the repository lightweight by storing policy manifests instead of copied upstream datasets

---

## 🧭 Why use this?

| Approach | Central policy | Automatic reconciliation | Preserves local exceptions | Pulls upstream directly | Tiered security posture |
|---|:---:|:---:|:---:|:---:|:---:|
| Manual Pi-hole configuration | ❌ | ❌ | ✅ | ✅ | ❌ |
| Backup / restore workflow | ⚠️ | ❌ | ⚠️ | ✅ | ❌ |
| Plain blocklist repository | ⚠️ | ❌ | ✅ | ⚠️ | ❌ |
| **AetherScope Pi-hole Policy** | ✅ | ✅ | ✅ | ✅ | ✅ |

Pi-hole Policy provides repeatable configuration across multiple systems without requiring full database cloning or destructive configuration replacement.

---

## 🧱 Policy tiers

### 🟢 Standard

Recommended for most deployments.

Designed to provide strong privacy, ad/tracker blocking, and threat protection with relatively low operational friction.

Includes:

- HaGeZi **Multi Pro**
- HaGeZi **Threat Intelligence Feeds (TIF)**
- HaGeZi **Dynamic DNS Abuse**
- HaGeZi **Referral Allowlist**

**Best fit:** homes, small businesses, general client deployments, and environments where reliability matters more than maximum filtering aggressiveness.

---

### 🔴 Hardened

For environments where a stricter DNS security posture is desired and occasional false positives are acceptable.

Includes everything below:

- HaGeZi **Multi Ultimate**
- HaGeZi **Threat Intelligence Feeds (TIF)**
- HaGeZi **Dynamic DNS Abuse**
- HaGeZi **Badware Hoster**
- HaGeZi **Most Abused TLDs**
- HaGeZi **DoH / VPN / Tor / Proxy Bypass**
- HaGeZi **Newly Registered Domains (NRD)** — rolling 35-day coverage
- HaGeZi **Referral Allowlist**

> ⚠️ **Hardened is intentionally aggressive.** It can block legitimate newly registered domains, shared hosting infrastructure, VPN/proxy services, and legitimate domains under high-abuse TLDs. Deploy it where that tradeoff is intentional.

### Tier comparison

| Capability | Standard | Hardened |
|---|:---:|:---:|
| Ads / trackers / telemetry | ✅ | ✅ |
| Malware / phishing / C2 intelligence | ✅ | ✅ |
| Dynamic DNS abuse | ✅ | ✅ |
| Referral compatibility allowlist | ✅ | ✅ |
| Maximum HaGeZi privacy tier | — | ✅ |
| Badware-host blocking | — | ✅ |
| High-abuse TLD blocking | — | ✅ |
| DoH / VPN / Tor / proxy bypass blocking | — | ✅ |
| 35-day newly registered domain coverage | — | ✅ |
| False-positive risk | Lower | Higher |
| Recommended default | ✅ | Only when intentional |

---

## 🚀 Quick start

### 1. Download the installer

```bash
curl -fsSL https://raw.githubusercontent.com/AetherScope-Dev/pihole-policy/main/scripts/install.sh \
  -o /tmp/pihole-policy-install.sh
```

### 2. Review it (Optional)

```bash
less /tmp/pihole-policy-install.sh
```

Press `q` to exit `less`.

### 3. Install a policy tier

#### Standard

```bash
sudo bash /tmp/pihole-policy-install.sh standard
```

#### Hardened

```bash
sudo bash /tmp/pihole-policy-install.sh hardened
```

That's it. ✅

---

## 🔄 What happens after installation?

The installer:

1. 📥 Downloads the selected manifests from this repository
2. 🗃️ Adds or updates the managed Pi-hole subscriptions
3. 🧹 Removes stale subscriptions previously managed by this policy
4. 🛑 Leaves unrelated client-specific subscriptions alone
5. 🧷 Leaves local exact/regex allow and deny rules alone
6. 💾 Saves the selected tier under `/etc/pihole-policy/tier`
7. ⏰ Creates a daily synchronization job
8. 🌍 Runs `pihole updateGravity`

By default, client policy reconciliation runs daily at:

```text
04:15 local time
```

---

## 🗺️ Architecture

```text
┌──────────────────────────────────┐
│   AetherScope Pi-hole Policy     │
│            GitHub Repo           │
└─────────────────┬────────────────┘
                  │
                  │  Policy manifests only
                  │
        ┌─────────┴─────────┐
        │                   │
        ▼                   ▼
  Standard Client     Hardened Client
        │                   │
        └─────────┬─────────┘
                  │
                  ▼
            Pi-hole Gravity
                  │
                  ▼
       Original upstream feeds
          downloaded directly
```

The repository acts as the **policy control plane**.

It does **not** republish millions of upstream domains. Each client still downloads the configured feeds directly from the upstream providers.

---

## 📂 Repository layout

```text
manifests/
├── standard-block.txt
├── standard-allow.txt
├── hardened-block.txt
└── hardened-allow.txt

scripts/
├── install.sh
├── sync-policy.sh
└── verify.sh

docs/
└── CLIENT-DEPLOYMENT.md
```

### 📋 Manifests

The manifest files define which upstream subscriptions belong to each policy tier.

### ⚙️ Scripts

- `install.sh` — bootstraps a new client
- `sync-policy.sh` — reconciles the client against the selected policy
- `verify.sh` — displays the installed tier, managed subscriptions, scheduler, and Pi-hole status

### 📚 Documentation

See:

[docs/CLIENT-DEPLOYMENT.md](docs/CLIENT-DEPLOYMENT.md)

for the full deployment cookbook.

---

## ✅ Verify a deployment

Download the verification script:

```bash
curl -fsSL https://raw.githubusercontent.com/AetherScope-Dev/pihole-policy/main/scripts/verify.sh \
  -o /tmp/pihole-policy-verify.sh
```

Run it:

```bash
sudo bash /tmp/pihole-policy-verify.sh
```

---

## 🔁 Change policy tiers

Switch to Standard:

```bash
sudo /usr/local/sbin/pihole-policy-sync standard
```

Switch to Hardened:

```bash
sudo /usr/local/sbin/pihole-policy-sync hardened
```

The selected tier is persisted automatically.

---

## 🧩 Client-specific exceptions

Local exceptions should remain **local**.

If a legitimate domain is blocked for one client, add the exception through that client's Pi-hole UI or CLI rather than weakening the shared baseline for every deployment.

Example:

```bash
pihole query example.com
```

Use the result to determine which list or rule caused the block before adding an exception.

---

## 🔍 Troubleshooting

### Force a policy sync

```bash
sudo /usr/local/sbin/pihole-policy-sync
```

### View the sync log

```bash
sudo tail -100 /var/log/pihole-policy-sync.log
```

### View policy-managed subscriptions

```bash
sudo pihole-FTL sqlite3 -header -column /etc/pihole/gravity.db \
"SELECT type,enabled,address,comment
 FROM adlist
 WHERE comment LIKE '[AetherScope policy:%'
 ORDER BY type,address;"
```

### Check Pi-hole status

```bash
pihole status
```

---

## 🧪 Quality controls

Every push and pull request is checked automatically with GitHub Actions.

| Check | Purpose |
|---|---|
| ShellCheck | Lints all Bash scripts for common correctness and portability problems |
| Manifest formatting | Rejects empty manifests, duplicate URLs, and non-HTTPS entries |
| Upstream URL validation | Confirms every configured feed can still be reached |
| Tag-driven releases | Tags matching `v*` can automatically publish GitHub releases |

See [CHANGELOG.md](CHANGELOG.md), [CONTRIBUTING.md](CONTRIBUTING.md), and [SECURITY.md](SECURITY.md) for project maintenance details.

---

## 🛡️ Safety model

This project is intentionally designed to avoid replacing a client's entire Pi-hole configuration.

- Requires **Pi-hole v6**
- Preserves unrelated adlists
- Preserves local exact/regex domain rules
- Reconciles only rows tagged with `[AetherScope policy:...]`
- Pulls blocklists directly from upstream providers
- Keeps the central repository lightweight and auditable
- Makes aggressive controls opt-in through the Hardened tier

---

## 🌐 Upstream projects

This policy currently relies primarily on:

- [HaGeZi DNS Blocklists](https://github.com/hagezi/dns-blocklists)
- [HaGeZi Newly Registered Domains (NRD)](https://github.com/hagezi/nrd)
- [Pi-hole](https://github.com/pi-hole/pi-hole)

Huge credit to the maintainers of those projects and to the upstream threat-intelligence and filtering sources they aggregate.

This repository does not claim authorship or ownership of third-party blocklist content.

---

## ⚖️ Licensing & attribution

This repository's original code, scripts, documentation, and policy framework are released under the **GNU General Public License v3.0 (GPL-3.0)**. See [LICENSE](LICENSE).

The upstream blocklists referenced by this project remain governed by **their own licenses and terms**. In particular, HaGeZi's DNS blocklist repository is also distributed under GPL-3.0 and aggregates data from numerous upstream sources with their own licensing and attribution requirements.

This project intentionally stores **references to upstream feeds rather than republishing their full contents**, helping preserve upstream attribution, update cadence, and licensing boundaries.

If you redistribute or materially modify third-party content, review the applicable upstream licenses directly.

---

## 🤝 Contributing

Pull requests and issue reports are welcome. GitHub issue templates are included for bugs and feature requests.

See [CONTRIBUTING.md](CONTRIBUTING.md) before proposing manifest or script changes.

When changing a manifest:

- Test the list first
- Document why it belongs in Standard or Hardened
- Note meaningful false-positive or usability risk
- Prefer original upstream URLs
- Avoid redundant lists already covered by the selected HaGeZi tier

---

## 📦 Releases

The initial public baseline is documented as **v1.0.0** in [CHANGELOG.md](CHANGELOG.md).

The repository includes a release workflow: pushing a Git tag such as `v1.0.0` will create the corresponding GitHub Release automatically.

---

## 👤 Maintainer

Pi-hole Policy is developed and maintained by [AetherScope-Dev](https://github.com/AetherScope-Dev).

If Pi-hole Policy is useful to you, consider giving the repository a ⭐. Stars help other Pi-hole, homelab, and self-hosted users discover the project.

Copyright © 2026 AetherScope-Dev

---

## 📌 Disclaimer

DNS filtering reduces exposure to unwanted and malicious domains, but it is not a substitute for endpoint security, patching, MFA, browser protections, network segmentation, backups, or user awareness.

No blocklist is perfect. False positives and false negatives are expected, particularly with aggressive feeds such as NRD, badware-hosting, and abused-TLD lists.
