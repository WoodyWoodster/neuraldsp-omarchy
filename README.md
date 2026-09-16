# neuraldsp-omarchy

Neural DSP **standalone** apps as first-class Omarchy citizens: isolated Wine
prefix, PipeASIO straight into PipeWire, auto-detected titles, Hyprland window
rules, and a Guitar submenu — Super+Space finds Gojira like a native app.

Tested on Omarchy/Arch + PipeWire + Scarlett 2i2 Gen 4. Interface-agnostic:
any class-compliant USB device works, and apps always open with or without
hardware plugged in (mix in your DAW later).

## How it fits

```
Guitar → interface → PipeWire ⇄ PipeASIO ⇄ Wine prefix → standalone .exe
Omarchy menu / Super+Space → neuraldsp launch → Hyprland rules (opaque, floating)
```

The standalone `.exe` runs in Wine. PipeASIO is the ASIO device inside that
prefix talking directly to PipeWire — the low-latency path. WineASIO/JACK is
skipped. No `alsa-scarlett-gui`, no Focusrite Control, no OS mixer.

## Prerequisites

- Omarchy (Arch) with PipeWire running (default)
- A Neural DSP account with licensed plugins (installers are yours; the repo
  never bundles or downloads them)
- An iLok account. `./install.sh` silently installs the free License Manager
  (download URL is public; no credentials are ever handled) and opens it once
  so you can sign in yourself on ilok.com.

## Quickstart

```bash
./install.sh        # as your user (not sudo): packages, prefix, PipeASIO, silent iLok, Hyprland hook
neuraldsp add       # opens neuraldsp.com/downloads, watches ~/Downloads, stages finished installers
neuraldsp sync      # run staged titles, refresh launchers + menu
```

First `./install.sh` is the slow one (Wine prefix + vcrun + DXVK). Re-runs skip installed packages and reuse `~/.cache/winetricks` plus a cached iLok zip under `~/.cache/neuraldsp/` (survives `--purge`).

Then open titles from the Guitar menu or Super+Space.

## Commands

| Command            | What it does |
|--------------------|--------------|
| `add [files]`      | Stage installer(s); bare `add` opens downloads and watches `~/Downloads` until Ctrl-C |
| `sync [--force]`   | Silent-install iLok if needed, open License Manager once for sign-in, run staged installers, rescan, launchers, menu |
| `launch <name>`    | Open a standalone (fuzzy match); `launch ilok` opens iLok |
| `list [--json]`    | Show installed standalones |
| `doctor`           | Check prefix, PipeASIO, iLok, realtime, PipeWire |

Env overrides: `NEURALDSP_HOME`, `NEURALDSP_PREFIX`, `NEURALDSP_INSTALLERS`,
`PIPEWIRE_QUANTUM` (default `128/48000` on launch), `WINEDEBUG`.

## First-run audio

In each title's audio settings, pick **PipeASIO** as the device, your guitar
input, and your headphone output. That setting persists in the prefix.

## Troubleshooting

- **No sound / wrong device:** re-open the title's audio settings, confirm
  PipeASIO is selected; run `neuraldsp doctor`.
- **Interface shows as a USB stick:** fresh Scarlett 3rd/4th Gen units ship in
  MSD ("Easy Start") mode — hold **48V while powering on** once to disable it.
  One-time only, never blocks launching.
- **Unresponsive plugin GUI:** this repo runs standalones (Wine 11 + DXVK via
  `winetricks`), not yabridge VSTs — if a window misbehaves, check
  `~/.local/share/neuraldsp/logs/<title>.log`.
- **Xruns under load:** make sure you're in the `realtime` group (re-login
  after install) and try a larger `PIPEWIRE_QUANTUM`, e.g. `256/48000`.
- **iLok installer wizard appeared:** close it. `sync` extracts
  `PACE License Support Win64.msi` and runs `msiexec /qn` — it should
  never open InstallShield. Re-run `neuraldsp sync` as your user (not sudo).
- **iLok download fails:** `sync` falls back to manual staging —
  `neuraldsp add <iLokInstaller>` from https://www.ilok.com.
- **iLok never asked you to sign in:** run `neuraldsp sync` (or
  `neuraldsp launch ilok`). Sign-in is always in License Manager — this
  tool never stores or submits iLok passwords. If the one-time prompt
  already fired, remove `~/.local/share/neuraldsp/.ilok-signin-prompted`
  and re-run `sync` to open it again.
- **Window rules:** matched broadly on Neural/Archetype class/title; tighten
  `hypr/neuraldsp.lua` against `hyprctl clients` output for your titles.

## Uninstall

```bash
./uninstall.sh          # remove launchers, menu rows, Hyprland hook; keep data
./uninstall.sh --purge  # also delete prefix, installers, catalog, logs
```

## Disclaimer

Community Wine wrapper for Omarchy, not a Neural DSP, Focusrite, PACE, or
official Omarchy product. Neural DSP doesn't support Linux. The repo never
ships licensed installers, prefix dumps, or a personal `apps.json`. Wine
needs XWayland; iLok sign-in stays in License Manager.
