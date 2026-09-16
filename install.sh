#!/usr/bin/env bash
#
# neuraldsp-omarchy install.sh — deploy the repo to user paths (idempotent).
# Safe to re-run after `omarchy update` or a Wine upgrade.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="$HOME/.local/bin/neuraldsp"
HYPR_DIR="$HOME/.config/hypr"
HYPR_MAIN="$HYPR_DIR/hyprland.lua"
HYPR_TARGET="$HYPR_DIR/neuraldsp.lua"
HOME_DIR="${NEURALDSP_HOME:-$HOME/.local/share/neuraldsp}"

log() { printf 'install: %s\n' "$*"; }

log "packages (skips whatever is already installed) ..."
omarchy pkg add wine-staging winetricks curl unzip python
omarchy pkg aur add pipeasio
omarchy pkg add realtime-privileges
if id -nG "$USER" 2>/dev/null | tr ' ' '\n' | grep -qx realtime; then
  log "user already in the realtime group"
else
  log "adding $USER to the realtime group (takes effect on next login) ..."
  sudo usermod -aG realtime "$USER"
fi

log "deploying files ..."
mkdir -p "$HOME/.local/bin" "$HOME_DIR/installers" "$HOME_DIR/logs" "$HYPR_DIR"
cp "$REPO_DIR/bin/neuraldsp" "$BIN"
chmod +x "$BIN"
cp "$REPO_DIR/hypr/neuraldsp.lua" "$HYPR_TARGET"
cp "$REPO_DIR/menu/guitar-base.json" "$HOME_DIR/menu-base.json"

if [[ -f "$HYPR_MAIN" ]]; then
  if grep -q 'require("hypr.neuraldsp")' "$HYPR_MAIN"; then
    log "hyprland.lua already requires hypr.neuraldsp"
  else
    cp "$HYPR_MAIN" "$HYPR_MAIN.bak.$(date +%s)"
    printf '\nrequire("hypr.neuraldsp")\n' >>"$HYPR_MAIN"
    log 'appended require("hypr.neuraldsp") to hyprland.lua (backup kept)'
  fi
else
  log "WARNING: $HYPR_MAIN not found — create it and add require(\"hypr.neuraldsp\")"
fi

log "health check ..."
"$BIN" doctor || true
log "done. Next: neuraldsp add  →  neuraldsp sync"
