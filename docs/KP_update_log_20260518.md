# KP Update Log - 2026-05-18

## Ver. 9.04.16

- Prepared 𝑲𝑶𝑵𝑮 Panel as a GitHub-ready Igor Pro source package.
- Exported the working 𝑲𝑶𝑵𝑮 Panel code from the original `template.pxp` through Igor Pro and organized the source into `src/`.
- Added `Load_KongPanel.ipf` as the recommended loader so that all panel action procedures are compiled before the panel opens.
- Made `Kong_Igor_panel.ipf` self-contained; opening this panel file now also includes all required KP procedure files.
- Using Codex assistance, rewrote the Nanonis loading routines that KP previously borrowed from KM macro and integrated them into `KP_NanonisLoaders.ipf`.
- KP can now load the KP-used Nanonis `.3ds`, `.sxm`, and `.nsp` workflows without requiring the KM package at runtime.
- Updated `AutoNanislinecut`, `autoloadgrid`, and topography extraction paths to call the KP-local Nanonis loader.
- Added source initialization for the global SI constants `q0`, `h`, `G0`, `muB`, `kB`, `eV`, `meV`, `m0`, and the historical `epslon0`, so clean source installs provide the same modeling constants.
- Added `KP_GlobalState.ipf` for source restoration of root-level globals preserved in `template.pxp`, including graph/color/popup state variables and strings used by older KP workflows.
- Added `STARTUP_STATE.md/html` to document the startup restoration in detail: 29 root numeric globals, 9 root string globals, default values, source entry point, and clean-Igor validation commands.
- Added README, changelog, code inventory, and Git ignore rules for GitHub release.
