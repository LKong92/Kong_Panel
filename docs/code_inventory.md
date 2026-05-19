# Code Inventory

## Source of Truth

The source in `src/` was exported from:

- `Template_kly_2025_06_08/template.pxp`

The export was performed through Igor Pro, using procedure text export for real procedure pages and `WinRecreation("Kong_Igor_panel", 0)` for the panel window.

## Exported KP Source Files

The GitHub package keeps the KP-specific Igor Pro files in `src/`:

- `KongPanel.ipf`
- `Load_KongPanel.ipf`
- `Kong_Igor_panel.ipf`
- `KP_ColorTables.ipf`
- `KP_NewColorTables.itx`
- `KP_NanonisLoaders.ipf`
- `Procedure.ipf`
- `ModelingTunneling.ipf`
- `General_Simu.ipf`
- `Miscellaneous_Codes.ipf`
- `SmartDisplay.ipf`
- `Smart_3D_Viewer_New.ipf`
- `Map_the_phase_difference_between_two_image.ipf`
- `FFT.ipf`
- `Pierre's Template.ipf`
- `UNISOKU3dscutextract.ipf`
- `Models.ipf`
- `Symmetrization.ipf`
- `Lattice Segregation.ipf`
- `PR_QPI.ipf`
- `transfergraph.ipf`
- `MultipeakforLinecut.ipf`
- `Lawler-Fujita Drift Correction.ipf`
- `Shear Correction for C4.ipf`
- `Triangle Lattice_Graphene_like.ipf`
- `MatrixCalculation.ipf`

## External Igor Includes

These are treated as Igor/WaveMetrics-provided procedure files and are not vendored:

- `Resize Controls`
- `Peak AutoFind`
- `Global Fit 2`

## KM Dependency Review

Only the Nanonis loading path was needed from KM for current KP panel workflows.

Relevant KP call sites before cleanup:

- `UNISOKU3dscutextract.ipf`: `AutoNanislinecut`
- `UNISOKU3dscutextract.ipf`: `autoloadgrid`
- `UNISOKU3dscutextract.ipf`: `ExtacttopoafterKM`
- `Miscellaneous_Codes.ipf`: `exitkm`

Relevant KM files reviewed:

- `KM/func/KM Load Data.ipf`
- `KM/file loaders/Load Nanonis 3ds.ipf`
- `KM/file loaders/Load Nanonis sxm nsp.ipf`
- `KM/file loaders/Load Nanonis dat.ipf`
- `KM/func/KM Constants.ipf`

KP now uses `KP_NanonisLoaders.ipf` instead of `KMLoadData()` and `KMExit()`.

## Loader Entry Points

- `Load_KongPanel.ipf` is the recommended file to include from a clean Igor experiment.
- `Kong_Igor_panel.ipf` is also self-contained now: it includes all action-procedure files before defining the panel window, so opening the panel file does not create a button-only shell.
- `KongPanel.ipf` remains as a compatibility umbrella that includes `Kong_Igor_panel.ipf`.

## Custom Color Tables

- `KP_ColorTables.ipf` provides `KP_EnsureNewColorTables()`.
- `KP_NewColorTables.itx` is the Igor Text export of the 47 custom color-table waves formerly stored inside the template experiment.
- `Kong_Igor_panel.ipf` includes `KP_ColorTables` and calls `KP_EnsureNewColorTables()` before creating the panel, so a clean experiment can rebuild `root:Packages:NewColortable`.
- Any GitHub release or ZIP archive must include `KP_NewColorTables.itx` next to the `.ipf` files, preferably in the same `KongPanel` or `src` folder.

## Generated Function Book

The function reference was generated from all `src/*.ipf` files with `scripts/build_function_book.py`.

- `docs/FUNCTION_BOOK.html`: color-coded browser manual.
- `docs/FUNCTION_INDEX.md`: Markdown index suitable for GitHub browsing.
- `docs/assets/kong_panel_main.png`: main 𝑲𝑶𝑵𝑮 Panel image for use in the GitHub README and panel guide.
- `docs/PANEL_GUIDE.html`: main-panel image plus button-to-procedure guide.
- `docs/PANEL_GUIDE.md`: Markdown version of the panel guide.
- `docs/function_catalog.json`: machine-readable catalog.
- `docs/panel_catalog.json`: machine-readable panel/control catalog.

The current function catalog contains 3203 entries from 25 IPF files, including `Function`, `Proc`, `Window`, `Macro`, and `Menu` definitions. It is organized by workflow and entry role rather than by IPF file. The panel catalog contains parsed main-panel and secondary-panel controls, including visible titles, action procedures, source locations, and reconstructed panel positions where available.

## Verification Notes

- `rg` confirms there are no remaining `KMLoadData`, `KMloadData`, or `KMExit` calls in `src/`.
- Igor Pro was able to scan and compile the new source package after `src/` was synced into Igor's User Procedures folder.
- Compiling inside the original exported PXP can hit duplicate definitions such as `imtb`, because both the old PXP procedure pages and the new `src/` package are loaded at the same time. Use a clean experiment/session for this source package.
