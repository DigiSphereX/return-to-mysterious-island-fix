# Return to Mysterious Island – Windows 10/11 Crash Fix & Launcher

One-click fix & launcher that solves the game **crashing on startup**, **hanging**, and **mouse not working** on modern Windows 10 / 11.

![Status](https://img.shields.io/badge/status-working-green)
![Platform](https://img.shields.io/badge/Windows-10%20%2F%2011-blue)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

## The Problem

**Return to Mysterious Island** (2004, Kheops Studio engine) randomly **closes by itself a few seconds after launching** on modern Windows 10 / 11, and logs errors like:

```
Faulting application name: Game.exe, version: 1.0.3.2
Faulting module name:    Game.exe
Exception code:          0xc0000005   (Access Violation)
```

On some machines the window appears but the game **freezes / does not respond** (`Application Hang`), or the **mouse cursor is stuck** and cannot move inside the game.

### Root Cause

The game relies on the legacy **DirectDraw** API (deprecated by Microsoft years ago), and its **exclusive fullscreen mode** is no longer handled correctly by Windows 10 / 11:

| Mode | Result without this fix |
|---|---|
| `bFullScreen=1` (fullscreen) | Crash with `0xc0000005` within seconds |
| `bFullScreen=0` (windowed) | Freezes / hangs or broken rendering |
| `bCenterMouse=1` | Mouse cursor locked / cannot move |

The fix: a modern **DirectDraw wrapper** (`cnc-ddraw`) that intercepts all DirectDraw calls and presents the frames through Direct3D / OpenGL / Vulkan in a way that modern Windows handles properly.

---

## The Fix

This script performs **3 automatic steps**:

1. **Downloads and installs `cnc-ddraw`** into the game folder automatically (only if missing) → stops the crash and makes fullscreen work.
2. **Patches `config.ini`** automatically:
   - `bFullScreen=1` (the wrapper handles presentation safely)
   - `bCenterMouse = 0` (mouse moves freely)
   - `PATH=...datas` (points the data path to the correct game folder)
   - **Creates a backup** as `config.ini.bak`
3. **Launches the game** automatically (`RtMI.exe` or `Game.exe`) from the correct working directory.

## Requirements

- Windows 10 or Windows 11 (32/64-bit)
- PowerShell 5.1 or newer (built into Windows)
- Internet connection once (to download `cnc-ddraw` if not present)
- A complete copy of the game (any version) in a single folder

## How to Use

1. Download these two files and place them in the game folder (next to `Game.exe`):
   - `RTMI_Fix_and_Play.bat`
   - `rtmi-fix.ps1`
2. **Double-click** `RTMI_Fix_and_Play.bat`.
3. Wait for the three steps to finish — the game will start automatically.

You can also run the PowerShell script directly:

```powershell
# Normal run (downloads cnc-ddraw if needed, patches settings, launches the game)
powershell -ExecutionPolicy Bypass -File .\rtmi-fix.ps1

# Extra options:
#  -Force          Re-download and re-install cnc-ddraw even if ddraw.dll is present
#  -SkipInstall    Do not download anything, only patch settings and launch
powershell -ExecutionPolicy Bypass -File .\rtmi-fix.ps1 -Force
powershell -ExecutionPolicy Bypass -File .\rtmi-fix.ps1 -SkipInstall
```

## Troubleshooting

- **Fullscreen looks wrong / bad aspect ratio**: run `cnc-ddraw config.exe` in the game folder and adjust *Presentation* (Scaling / Aspect Ratio / Windowed-Borderless).
- **Cursor stuck after entering the game**: press `Ctrl+Tab` (wrapper cursor lock) or adjust the *Mouse* options in `cnc-ddraw config.exe`.
- **Game disappears when Alt+Tab**: in `cnc-ddraw config.exe` try toggling `Nonexclusive` or enabling *Windowed Borderless*.
- **Corrupted config.ini**: restore the backup `config.ini.bak` (or delete your changes) and run the fixer again.
- **Sound is broken / missing**: set the default audio device in the game options, or install OpenAL from `_Redist\oalinst.exe` if your copy ships it.

## Security & Antivirus Notes

- The download is pinned to a fixed release (`v7.1.0.0`) over **HTTPS** from the official repository, and the zip is **verified against a SHA256 hash** before it is extracted. If the checksum does not match, the script aborts.
- `cnc-ddraw`'s `ddraw.dll` is a *graphics wrapper* that hooks legacy DirectDraw calls. Some antivirus engines flag it heuristically as "suspicious" simply because it intercepts graphics APIs — this is a known false-positive of the tool, **not** a threat. If your AV quarantines it, allow-list the game folder.
- The script downloads nothing else and sends no data anywhere. You can review the entire source here.

## Repository Files

| File | Purpose |
|---|---|
| `RTMI_Fix_and_Play.bat` | The executable entry point (double-click) |
| `rtmi-fix.ps1` | The fix & launch logic |
| `README.md` | Documentation (this file) |

Note: this repository does **not** contain the game files themselves — bring your own copy. This project only ships the fix tool.

## How It Works Under the Hood

1. The 2004 game calls `LoadLibrary("ddraw.dll")`.
2. Windows looks for `ddraw.dll` in **the application folder first** → finds the `cnc-ddraw` copy.
3. The wrapper intercepts every DirectDraw call (surfaces, presentation, cursor, ...).
4. Frames are presented through **Direct3D 9 / OpenGL**, compatible with modern Windows, with safe fullscreen and mouse handling.

`cnc-ddraw` is an open-source project: [FunkyFr3sh/cnc-ddraw](https://github.com/FunkyFr3sh/cnc-ddraw)

## License

This script is licensed under the [MIT License](LICENSE). The `cnc-ddraw` tool has its own separate license.

---

*Problem discovered and fixed on Windows 11 25H2 with the GOG release of the game. Remember that the game itself is licensed to you and you need a legitimate copy.*