# Pi-hole Policy

Centralized Pi-hole policy for repeatable Pi-hole deployments. Client systems subscribe to policy manifests here while Pi-hole Gravity downloads the actual upstream feeds directly from their publishers.

## Tiers

### Standard
Strong default for general client deployments with lower operational friction.

- HaGeZi Multi Pro
- HaGeZi Threat Intelligence Feeds (TIF)
- HaGeZi Dynamic DNS abuse
- HaGeZi Referral Allowlist

### Hardened
Aggressive security/privacy baseline for environments where occasional false positives are acceptable.

- HaGeZi Multi Ultimate
- HaGeZi TIF
- HaGeZi Dynamic DNS abuse
- HaGeZi Badware Hoster
- HaGeZi Most Abused TLDs
- HaGeZi DoH/VPN/Tor/Proxy Bypass
- HaGeZi NRD rolling 35-day coverage
- HaGeZi Referral Allowlist

> Hardened can block legitimate newly registered domains, shared hosting infrastructure, VPN/proxy services, and domains under high-abuse TLDs. Deploy it intentionally.

## Layout

```text
manifests/
  standard-block.txt
  standard-allow.txt
  hardened-block.txt
  hardened-allow.txt
scripts/
  install.sh
  sync-policy.sh
  verify.sh
docs/
  CLIENT-DEPLOYMENT.md
```

## Quick start

Review the installer first:

```bash
curl -fsSL https://raw.githubusercontent.com/AetherScope-Dev/pihole-policy/main/scripts/install.sh -o /tmp/pihole-policy-install.sh
less /tmp/pihole-policy-install.sh
```

Install Standard:

```bash
sudo bash /tmp/pihole-policy-install.sh standard
```

Install Hardened:

```bash
sudo bash /tmp/pihole-policy-install.sh hardened
```

The installer configures a daily policy reconciliation at 04:15 local time. The sync updates Pi-hole's subscribed list configuration and then runs `pihole updateGravity`.

## Safety model

- Requires Pi-hole v6 because subscribed allowlists are used.
- Does not replace the client's entire Pi-hole database.
- Preserves unrelated client-specific adlists and local domain rules.
- Only adlist rows tagged `[AetherScope policy:...]` are reconciled/removed.
- Upstream lists are fetched directly from their publishers.
- The repository contains policy manifests, not republished multi-million-domain feeds.

## Upstreams

Primary feeds are maintained by [HaGeZi DNS Blocklists](https://github.com/hagezi/dns-blocklists) and [HaGeZi NRD](https://github.com/hagezi/nrd).

