#!/usr/bin/env bash
set -euo pipefail

DB="/etc/pihole/gravity.db"
TIER_FILE="/etc/pihole-policy/tier"

if [[ ${EUID} -ne 0 ]]; then
  echo "Run as root (sudo)." >&2
  exit 1
fi

echo "Configured tier:"
if [[ -f "$TIER_FILE" ]]; then
  cat "$TIER_FILE"
else
  echo "(not configured)"
fi

echo
echo "Managed subscriptions:"
pihole-FTL sqlite3 -header -column "$DB" "SELECT CASE type WHEN 0 THEN 'BLOCK' WHEN 1 THEN 'ALLOW' ELSE printf('TYPE-%d',type) END AS kind, enabled, address, comment FROM adlist WHERE comment LIKE '[AetherScope policy:%' ORDER BY type,address;"

echo
echo "Cron:"
if [[ -f /etc/cron.d/pihole-policy ]]; then
  cat /etc/cron.d/pihole-policy
else
  echo "(not installed)"
fi

echo
echo "Pi-hole status:"
pihole status
