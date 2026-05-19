# 𝐊𝐎𝐍𝐆 𝐏𝐚𝐧𝐞𝐥 Changelog

This file is a polished GitHub-facing version of the original `KP update log.rtf`. The full plain-text conversion is kept in `docs/KP_update_log_raw.txt` for historical detail.

## 9.04.16 - 2026-05-18

- Exported 𝐊𝐎𝐍𝐆 𝐏𝐚𝐧𝐞𝐥 procedure pages from `template.pxp` through Igor Pro.
- Reorganized the package into source files under `src/`, with `src/KongPanel.ipf` as the umbrella include file.
- Added `Load_KongPanel.ipf`, the recommended loader that compiles all panel action procedures before opening KP.
- Added `templates/KongPanel_Template_20260520.pxp`, a clean self-contained Igor experiment template for per-dataset use.
- Made `Kong_Igor_panel.ipf` self-contained, so opening the panel file also includes the required source files instead of creating a button-only shell.
- Using Codex assistance, rewrote and organically integrated the KP-used Nanonis loading routines that previously depended on KM macro into `KP_NanonisLoaders.ipf`.
- Removed the runtime dependency on Kohsaka Macro (KM) from the KP Nanonis `.3ds`, `.sxm`, and `.nsp` linecut, grid, and topography workflows.
- Updated the panel's visible KM cleanup button label from `KMExist` to `Clean`.
- Added source initialization for the global SI constants introduced in 9.04.13, so clean source installs also provide `q0`, `h`, `G0`, `muB`, `kB`, `eV`, `meV`, `m0`, and the historical `epslon0`.
- Added `src/KP_GlobalState.ipf` to restore root-level globals that were stored as experiment objects in `template.pxp`, so source installs recreate the graph/color/popup state variables and strings expected by older workflows.
- Added `docs/STARTUP_STATE.md` and `docs/STARTUP_STATE.html`, documenting the 29 root numeric globals, 9 root string globals, default values, startup entry point, and Igor validation commands.
- Added GitHub documentation, `.gitignore`, and code inventory notes.

## 9.04.15 - 2025-06-08

- Added simulation support for P(E) theory.
- Debug update in V2.

## 9.04.14 - 2025-05-22

- Added simulation support for the RCSJ model.

## 9.04.13 - 2025-05-19

- Added common elementary constants as global variables in SI units:
  - elementary charge: `q0`
  - Planck constant: `h`
  - conductance quantum: `G0 = e^2/h`
  - Bohr magneton: `muB`
  - Boltzmann constant: `kB`
  - electron volt: `eV`
  - millielectron volt: `meV`
  - electron mass: `m0`
- Added the `Tip Height Experiment` function group.
- Added voltage-divider rescaling utilities for `dI/dV` curves.
- Added batch linecut utilities for divider-corrected and unevenly spaced spectra.
- Added conversion from `I/V` curves to `dI/dV` by differentiation.
- Added `Gridtolinecut($grid,indexdim)` to extract spectra from a 3D wave and assemble a linecut.

## 9.04.12 - 2024-11-27

- Added lattice append tools for honeycomb, triangular, and square lattices.
- Removed the older line-draw mode.
- Added:
  - `Fitimagehoneycombc()`
  - `Fitimagetriangularc()`
  - `Fitimagesquarec()`

## 9.04.11 - 2024-11-25

- Added a honeycomb lattice simulator.

## 9.04.10 - 2024-11-23

- Added TBG and TTG lattice simulators.
- Added `CreateTriangularLatticeCoordinates(xx, yy, a, theta)` for honeycomb lattice position generation.

## 9.04.06 - 2024-07-30

- Added L-map support.

## 9.04.05 - 2024-07-14

- Upgraded the QPI simulator.
- Rotated the Fermi surface and correlation output by 45 degrees.

## 9.04.04 - 2024-07-08

- Upgraded FFT support in the Smart 3D displayer.
- Added selectable symmetrization mode.
- V2 fixed the close-window button.

## 9.04.03 - 2024-07-07

- Upgraded arbitrary linecuts in the Smart 3D displayer.

## 9.04.02 - 2024-07-07

- Added symmetrization tools.

## 9.04.01 - 2024-07-04

- Adapted the template for Igor Pro 9.04.
- Changed image trend removal from 2D fitting to 1D fitting mode.
- Fixed the QPI estimator label from `KF/G` to `lambda(a0)`.
- Rechecked quantities in the simulator.
- V2 enabled both 1D and 2D fitting for graph trend removal.

## Earlier History

The original log begins on 2021-09-17, with development notes going back to the first KP work in 2016. For older detailed entries, see `docs/KP_update_log_raw.txt`.

## Notes

The original RTF footer said that KP required launching the KM package to load `.sxm` and `.3ds` Nanonis files. That is no longer true for the KP panel workflows covered by `KP_NanonisLoaders.ipf`.
