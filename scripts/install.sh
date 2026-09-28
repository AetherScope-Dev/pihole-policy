#!/usr/bin/env bash
set -euo pipefail

BASE_URL="https://raw.githubusercontent.com/AetherScope-Dev/pihole-policy/main"
INSTALL_PATH="/usr/local/sbin/pihole-policy-sync"
CONFIG_DIR="/etc/pihole-policy"
CRON_FILE="/etc/cron.d/pihole-policy"

if [[ ${EUID} -ne 0 ]]; then
  echo "Run as root: sudo bash $0 standard|hardened" >&2
  exit 1
fi

TIER="${1:-}"
case "$TIER" in
  standard|hardened) ;;
  *) echo "Usage: sudo bash $0 standard|hardened" >&2; exit 1 ;;
esac

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required." >&2
  exit 1
fi

if ! command -v pihole >/dev/null 2>&1; then
  echo "Pi-hole does not appear to be installed." >&2
  exit 1
fi

mkdir -p "$CONFIG_DIR"

curl -fsSL "$BASE_URL/scripts/sync-policy.sh" -o "$INSTALL_PATH"
chmod 0755 "$INSTALL_PATH"
printf '%s\n' "$TIER" > "$CONFIG_DIR/tier"

cat > "$CRON_FILE" <<'EOF'
# AetherScope centralized Pi-hole policy reconciliation
15 4 * * * root /usr/local/sbin/pihole-policy-sync >>/var/log/pihole-policy-sync.log 2>&1
EOF
chmod 0644 "$CRON_FILE"

echo "Installed policy tier: $TIER"
echo "Daily sync: 04:15 local time"
echo "Running initial reconciliation..."
"$INSTALL_PATH" "$TIER"
