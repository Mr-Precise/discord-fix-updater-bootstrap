#!/usr/bin/env bash
set -e

APPARMOR_DIR="/etc/apparmor.d"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FILES=(
  "discord-canary"
  "discord-ptb"
  "discord-development"
)

echo "Checking AppArmor..."

if ! command -v apparmor_parser >/dev/null 2>&1; then
  echo "apparmor_parser not found. Is AppArmor installed?"
  exit 1
fi

# Get AppArmor version (ohh the joys of version parsing)
# Проверяем версию AppArmor (ох опять парсер версий, ну что ж)
AA_VER=$(apparmor_parser --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)
MAJOR=$(echo "$AA_VER" | cut -d. -f1)

echo "Detected AppArmor version: $AA_VER"

if [ "$MAJOR" -ge 4 ]; then
  echo "AppArmor 4 or higher detected. Nothing to fix."
  exit 0
fi

if [ "$MAJOR" -lt 2 ]; then
  echo "Unknown AppArmor version. Aborting."
  exit 1
fi

echo "Applying profile for:"

for file in "${FILES[@]}"; do
  SRC="$SCRIPT_DIR/$file"
  DST="$APPARMOR_DIR/$file"

  if [ ! -f "$SRC" ]; then
    echo "Missing file: $SRC"
    continue
  fi

  echo "--> $file"
  cp "$SRC" "$DST"
done

echo "Done."
echo "Recommended to restart or reload AppArmor:"
echo "sudo systemctl reload apparmor"
