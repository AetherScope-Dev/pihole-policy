# 🛡️ Pi-hole Policy

A centralized, reusable policy framework for **Pi-hole v6** deployments.

This repository lets you define a DNS-filtering baseline once, publish it through GitHub, and keep client Pi-holes synchronized automatically. Clients pull the policy manifests from this repo, while Pi-hole Gravity downloads the actual upstream blocklists directly from their original publishers.

> 💡 **Goal:** make Pi-hole deployments consistent, repeatable, easy to maintain, and easy to explain to clients.

---

## ✨ What this does

- Provides **Standard** and **Hardened** DNS policy tiers
- Keeps client Pi-holes synchronized automatically
- Preserves client-specific local allow/deny rules
- Tags policy-managed subscriptions so they can be safely reconciled
- Keeps upstream feeds sourced directly from their original publishers
- Removes stale policy-managed subscriptions when the manifest changes
- Runs `pihole updateGravity` after policy reconciliation
- Avoids distributing giant copied blocklists through this repository

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

---

## 🚀 Quick start

### 1. Download the installer

```bash
curl -fsSL https://raw.githubusercontent.com/AetherScope-Dev/pihole-policy/main/scripts/install.sh \
  -o /tmp/pihole-policy-install.sh
```

### 2. Review it

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
              ┌──────────────────────────────┐
              │  AetherScope Pi-hole Policy │
              │          GitHub Repo          │
              └──────────────┬───────────────┘
                             │
                Policy manifests only
                             │
                 ┌───────────┴───────────┐
                 │                       │
                 ▼                       ▼
          🟢 Standard Client       🔴 Hardened Client
                 │                       │
                 └───────────┬───────────┘
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

Pull requests and issue reports are welcome.

When changing a manifest:

- Test the list first
- Document why it belongs in Standard or Hardened
- Note meaningful false-positive or usability risk
- Prefer original upstream URLs
- Avoid redundant lists already covered by the selected HaGeZi tier

---

## 📌 Disclaimer

DNS filtering reduces exposure to unwanted and malicious domains, but it is not a substitute for endpoint security, patching, MFA, browser protections, network segmentation, backups, or user awareness.

No blocklist is perfect. False positives and false negatives are expected, particularly with aggressive feeds such as NRD, badware-hosting, and abused-TLD lists.
