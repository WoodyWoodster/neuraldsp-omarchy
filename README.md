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
- An iLok account (the free iLok License Manager is auto-downloaded)

## Quickstart

```bash
./install.sh        # packages, deploy, Hyprland hook, health check
neuraldsp add       # opens neuraldsp.com/downloads + staging folder: log in, download
neuraldsp add ~/Downloads/Archetype*.exe   # stage installer(s)
neuraldsp sync      # iLok prerequisite, run installers, refresh launchers + menu
```

Then open titles from the Guitar menu or Super+Space.

## Commands

| Command            | What it does |
|--------------------|--------------|
| `add [files]`      | Stage installer(s); bare `add` opens downloads + staging folder |
| `sync [--force]`   | iLok, staged installers, rescan, launchers, menu (idempotent) |
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
- **iLok download fails:** `sync` falls back to manual staging —
  `neuraldsp add <iLokInstaller>` from https://www.ilok.com.
- **Window rules:** matched broadly on Neural/Archetype class/title; tighten
  `hypr/neuraldsp.lua` against `hyprctl clients` output for your titles.

## Uninstall

```bash
./uninstall.sh          # remove launchers, menu rows, Hyprland hook; keep data
./uninstall.sh --purge  # also delete prefix, installers, catalog, logs
```

## Notes for publishers

- No licensed binaries, prefix dumps, or personal `apps.json` in the repo.
- Neural DSP does not officially support Linux; this is a community Wine
  wrapper, not affiliated with Neural DSP, Focusrite, PACE, or Omarchy.
- Support matrix: XWayland required (Wine runs with the X11 driver),
  per-title PipeASIO selection on first run.
