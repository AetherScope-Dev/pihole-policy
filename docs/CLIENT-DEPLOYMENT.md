# Client Deployment Cookbook

## Prerequisites

- Pi-hole v6
- Internet access to GitHub raw content and the configured upstream list providers
- `curl`
- Root/sudo access

## Choose a tier

### Standard
Use for most client environments. It prioritizes strong privacy/threat blocking with fewer false positives.

### Hardened
Use when a client explicitly accepts a more restrictive DNS posture. It includes NRD, badware-hosting, abused-TLD, and DNS-bypass controls that can block legitimate services.

## Install

Download and inspect:

```bash
curl -fsSL https://raw.githubusercontent.com/AetherScope-Dev/pihole-policy/main/scripts/install.sh -o /tmp/pihole-policy-install.sh
less /tmp/pihole-policy-install.sh
```

Standard:

```bash
sudo bash /tmp/pihole-policy-install.sh standard
```

Hardened:

```bash
sudo bash /tmp/pihole-policy-install.sh hardened
```

## Verify

```bash
curl -fsSL https://raw.githubusercontent.com/AetherScope-Dev/pihole-policy/main/scripts/verify.sh -o /tmp/pihole-policy-verify.sh
sudo bash /tmp/pihole-policy-verify.sh
```

## Change tiers

```bash
sudo /usr/local/sbin/pihole-policy-sync standard
```

or:

```bash
sudo /usr/local/sbin/pihole-policy-sync hardened
```

The selected tier is persisted in `/etc/pihole-policy/tier`.

## Daily operation

The installer creates:

```text
/etc/cron.d/pihole-policy
```

with a daily 04:15 reconciliation. The sync:

1. Downloads the selected block/allow manifests from this repository.
2. Adds or updates policy-managed Pi-hole subscriptions.
3. Removes stale subscriptions previously tagged as policy-managed.
4. Leaves unrelated client-specific subscriptions and local domain rules alone.
5. Runs `pihole updateGravity`.

## Client-specific exceptions

Use the Pi-hole UI or CLI for local exact/regex allow and deny rules. They are not managed by this repository and remain client-specific.

Because Pi-hole allow rules have higher priority than subscribed deny lists, local exceptions are the preferred way to handle a legitimate domain blocked by an aggressive feed.

## Troubleshooting

Show policy-managed subscriptions:

```bash
sudo pihole-FTL sqlite3 -header -column /etc/pihole/gravity.db "SELECT type,enabled,address,comment FROM adlist WHERE comment LIKE '[AetherScope policy:%' ORDER BY type,address;"
```

Force a sync:

```bash
sudo /usr/local/sbin/pihole-policy-sync
```

Inspect the sync log:

```bash
sudo tail -100 /var/log/pihole-policy-sync.log
```

Check a domain:

```bash
pihole query example.com
```

## Uninstall policy management

Remove the scheduler and sync client:

```bash
sudo rm -f /etc/cron.d/pihole-policy /usr/local/sbin/pihole-policy-sync
```

This intentionally does not remove policy-managed list entries automatically. Review them first, then remove unwanted subscriptions through Pi-hole or the database.
