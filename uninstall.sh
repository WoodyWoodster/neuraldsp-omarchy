#!/usr/bin/env bash
#
# neuraldsp-omarchy uninstall.sh — remove deployed files.
# Prefix + installers + catalog stay unless --purge is passed.
set -euo pipefail

PURGE=0
[[ "${1:-}" == "--purge" ]] && PURGE=1
HOME_DIR="${NEURALDSP_HOME:-$HOME/.local/share/neuraldsp}"
MENU_JSONC="$HOME/.config/omarchy/extensions/omarchy-menu.jsonc"
HYPR_MAIN="$HOME/.config/hypr/hyprland.lua"

log() { printf 'uninstall: %s\n' "$*"; }

log "removing launchers ..."
rm -f "$HOME"/.local/share/applications/neuraldsp-*.desktop

if [[ -f "$MENU_JSONC" ]]; then
  python3 - "$MENU_JSONC" <<'EOF'
import json, os, shutil, sys, time
path = sys.argv[1]
try:
    with open(path) as fh:
        data = json.load(fh)
except Exception as e:
    print(f"uninstall: WARNING: could not parse menu file: {e}; left untouched")
    sys.exit(0)
new = {k: v for k, v in data.items() if k != "guitar" and not k.startswith("guitar.")}
if new != data:
    shutil.copy2(path, f"{path}.bak.{int(time.time())}")
    with open(path, "w") as fh:
        json.dump(new, fh, indent=2)
        fh.write("\n")
    print("uninstall: removed Guitar rows from menu")
else:
    print("uninstall: no Guitar rows in menu")
EOF
fi

if [[ -f "$HYPR_MAIN" ]] && grep -q 'require("hypr.neuraldsp")' "$HYPR_MAIN"; then
  cp "$HYPR_MAIN" "$HYPR_MAIN.bak.$(date +%s)"
  sed -i '/require("hypr.neuraldsp")/d' "$HYPR_MAIN"
  log "removed require from hyprland.lua (backup kept)"
fi

rm -f "$HOME/.config/hypr/neuraldsp.lua" "$HOME/.local/bin/neuraldsp" "$HOME_DIR/menu-base.json"

if [[ "$PURGE" == 1 ]]; then
  rm -rf "$HOME_DIR"
  log "purged $HOME_DIR (prefix, installers, catalog, logs)"
else
  log "kept $HOME_DIR (prefix, installers, catalog, logs). Re-run install.sh anytime; pass --purge to remove everything."
fi
