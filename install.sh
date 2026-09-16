#!/usr/bin/env bash
#
# neuraldsp-omarchy install.sh — packages, deploy, Wine prefix, PipeASIO, iLok.
# Safe to re-run after `omarchy update` or a Wine upgrade.
set -euo pipefail

if (( EUID == 0 )); then
  printf 'install: error: run as your user, not root — a root Wine prefix cannot be used from the desktop\n' >&2
  exit 1
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="$HOME/.local/bin/neuraldsp"
HYPR_DIR="$HOME/.config/hypr"
HYPR_MAIN="$HYPR_DIR/hyprland.lua"
HYPR_TARGET="$HYPR_DIR/neuraldsp.lua"
HOME_DIR="${NEURALDSP_HOME:-$HOME/.local/share/neuraldsp}"

log() { printf 'install: %s\n' "$*"; }

pkg_missing() {
  local p
  for p in "$@"; do
    pacman -Q "$p" &>/dev/null || return 0
  done
  return 1
}

log "packages (skips whatever is already installed) ..."
PKGS=(wine-staging wine-gecko wine-mono winetricks curl unzip python 7zip msitools realtime-privileges)
if pkg_missing "${PKGS[@]}"; then
  omarchy pkg add "${PKGS[@]}"
else
  log "repo packages already present"
fi
if pkg_missing pipeasio; then
  omarchy pkg aur add pipeasio
else
  log "pipeasio already present"
fi
if id -nG "$USER" 2>/dev/null | tr ' ' '\n' | grep -qx realtime; then
  log "user already in the realtime group"
else
  log "adding $USER to the realtime group (takes effect on next login) ..."
  sudo usermod -aG realtime "$USER"
fi

if [[ -e "$HOME_DIR" && ! -w "$HOME_DIR" ]]; then
  log "taking ownership of $HOME_DIR (a previous install ran as root) ..."
  sudo chown -R "$USER:$USER" "$HOME_DIR"
fi
if [[ -e "$BIN" && ! -w "$BIN" ]]; then
  sudo chown "$USER:$USER" "$BIN"
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

log "Wine prefix, DXVK, PipeASIO, iLok (first run takes a few minutes; repeats are cached) ..."
"$BIN" sync

log "health check ..."
"$BIN" doctor || true
log "done. Next: neuraldsp add  (Ctrl-C when downloads are staged)  →  neuraldsp sync"
