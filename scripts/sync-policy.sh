#!/usr/bin/env bash
set -euo pipefail

BASE_URL="https://raw.githubusercontent.com/AetherScope-Dev/pihole-policy/main"
DB="/etc/pihole/gravity.db"
CONFIG_DIR="/etc/pihole-policy"
TIER_FILE="$CONFIG_DIR/tier"
TAG_PREFIX="[AetherScope policy:"

if [[ ${EUID} -ne 0 ]]; then
  echo "Run as root (sudo)." >&2
  exit 1
fi

if ! command -v pihole >/dev/null 2>&1 || ! command -v pihole-FTL >/dev/null 2>&1; then
  echo "Pi-hole commands not found." >&2
  exit 1
fi

if [[ ! -f "$DB" ]]; then
  echo "Pi-hole gravity database not found: $DB" >&2
  exit 1
fi

if [[ -n "${1:-}" ]]; then
  TIER="$1"
elif [[ -f "$TIER_FILE" ]]; then
  TIER="$(tr -d '[:space:]' < "$TIER_FILE")"
else
  echo "No tier configured. Use: $0 standard|hardened" >&2
  exit 1
fi

case "$TIER" in
  standard|hardened) ;;
  *) echo "Tier must be standard or hardened." >&2; exit 1 ;;
esac

# Pi-hole v6 stores subscribed allow/block lists in adlist using a type column.
if ! pihole-FTL sqlite3 "$DB" "PRAGMA table_info(adlist);" | grep -q '|type|'; then
  echo "This policy requires Pi-hole v6 (adlist type column not found)." >&2
  exit 1
fi

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

curl -fsSL "$BASE_URL/manifests/${TIER}-block.txt" -o "$TMPDIR/block.txt"
curl -fsSL "$BASE_URL/manifests/${TIER}-allow.txt" -o "$TMPDIR/allow.txt"

clean_manifest() {
  grep -Ev '^[[:space:]]*(#|$)' "$1" | sed 's/[[:space:]]*$//'
}

mapfile -t BLOCKS < <(clean_manifest "$TMPDIR/block.txt")
mapfile -t ALLOWS < <(clean_manifest "$TMPDIR/allow.txt")

if (( ${#BLOCKS[@]} == 0 )); then
  echo "Refusing to apply an empty block manifest." >&2
  exit 1
fi

sql_escape() {
  printf "%s" "$1" | sed "s/'/''/g"
}

COMMENT="${TAG_PREFIX}${TIER}] managed from GitHub"
COMMENT_SQL="$(sql_escape "$COMMENT")"

# Upsert desired policy entries. Existing matching URLs are adopted into policy management.
for url in "${BLOCKS[@]}"; do
  u="$(sql_escape "$url")"
  pihole-FTL sqlite3 "$DB" "INSERT INTO adlist(address,enabled,comment,type) VALUES('$u',1,'$COMMENT_SQL',0) ON CONFLICT(address,type) DO UPDATE SET enabled=1,comment='$COMMENT_SQL';"
done

for url in "${ALLOWS[@]}"; do
  u="$(sql_escape "$url")"
  pihole-FTL sqlite3 "$DB" "INSERT INTO adlist(address,enabled,comment,type) VALUES('$u',1,'$COMMENT_SQL',1) ON CONFLICT(address,type) DO UPDATE SET enabled=1,comment='$COMMENT_SQL';"
done

# Build the desired URL set and remove only stale rows previously managed by this policy.
ALL_URLS=("${BLOCKS[@]}" "${ALLOWS[@]}")
IN_CLAUSE=""
for url in "${ALL_URLS[@]}"; do
  u="$(sql_escape "$url")"
  if [[ -n "$IN_CLAUSE" ]]; then IN_CLAUSE+=","; fi
  IN_CLAUSE+="'$u'"
done

pihole-FTL sqlite3 "$DB" "DELETE FROM adlist WHERE comment LIKE '[AetherScope policy:%' AND address NOT IN ($IN_CLAUSE);"

mkdir -p "$CONFIG_DIR"
printf '%s\n' "$TIER" > "$TIER_FILE"

echo "Applied Pi-hole policy tier: $TIER"
echo "Block subscriptions: ${#BLOCKS[@]}"
echo "Allow subscriptions: ${#ALLOWS[@]}"
echo "Refreshing Gravity..."
pihole updateGravity
