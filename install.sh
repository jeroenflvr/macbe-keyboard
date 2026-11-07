#!/usr/bin/env bash
# Install the Mac-style Belgian keyboard layout for KDE Plasma (Wayland).
#
# Usage:
#   ./install.sh [--variant swapped|basic] [--alt any|right]
#   ./install.sh --uninstall
#
# Defaults: --variant swapped (VM on a Mac), --alt any (either Option key works)
set -euo pipefail

VARIANT="swapped"
ALT="any"
UNINSTALL=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --variant)   VARIANT="$2"; shift 2 ;;
    --alt)       ALT="$2"; shift 2 ;;
    --uninstall) UNINSTALL=1; shift ;;
    -h|--help)   sed -n '2,9p' "$0"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XKB_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/xkb/symbols"
TARGET="$XKB_DIR/macbe"

# Find kwriteconfig (Plasma 6, falls back to Plasma 5)
KWRITE="$(command -v kwriteconfig6 || command -v kwriteconfig5 || true)"
if [[ -z "$KWRITE" ]]; then
  echo "kwriteconfig6/kwriteconfig5 not found. Is KDE Plasma installed?" >&2
  exit 1
fi

kx() { "$KWRITE" --file kxkbrc --group Layout --key "$1" "$2"; }

reload() {
  # Ask KWin to reload the keyboard config; harmless if nobody is listening
  dbus-send --session --type=signal /Layouts org.kde.keyboard.reloadConfig 2>/dev/null || true
}

if [[ $UNINSTALL -eq 1 ]]; then
  rm -f "$TARGET"
  kx LayoutList be
  kx VariantList ""
  kx Options ""
  reload
  echo "Removed macbe and switched back to the standard Belgian layout."
  echo "Log out and back in if the change hasn't taken effect."
  exit 0
fi

case "$VARIANT" in
  basic|swapped) ;;
  *) echo "--variant must be 'basic' or 'swapped'" >&2; exit 1 ;;
esac
case "$ALT" in
  any)   LV3="lv3:alt_switch" ;;
  right) LV3="lv3:ralt_switch" ;;
  *) echo "--alt must be 'any' or 'right'" >&2; exit 1 ;;
esac

mkdir -p "$XKB_DIR"
install -m 644 "$SRC_DIR/symbols/macbe" "$TARGET"
echo "Installed $TARGET"

# Check that the layout compiles before switching to it
VARIANT_ARG=""
[[ "$VARIANT" == "swapped" ]] && VARIANT_ARG="swapped"
if command -v xkbcli >/dev/null; then
  if xkbcli compile-keymap --layout macbe --variant "$VARIANT_ARG" --options "$LV3" >/dev/null; then
    echo "Layout compiles OK"
  else
    echo "Layout failed to compile; kxkbrc left unchanged." >&2
    exit 1
  fi
else
  echo "xkbcli not found, skipping check (sudo apt install libxkbcommon-tools)"
fi

kx Use true
kx LayoutList macbe
kx VariantList "$VARIANT_ARG"
kx ResetOldOptions true
kx Options "$LV3"
reload

echo "Configured: layout macbe${VARIANT_ARG:+($VARIANT_ARG)}, 3rd level: $LV3"
echo "If keys don't change right away, log out and back in."
