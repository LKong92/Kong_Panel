# Code Inventory

## Source of Truth

The source in `src/` was exported from:

- `Template_kly_2025_06_08/template.pxp`

The export was performed through Igor Pro, using procedure text export for real procedure pages and `WinRecreation("Kong_Igor_panel", 0)` for the panel window.

For Ver. 9.04.17, the author-provided Moiré STM procedure code and the `SMap8` panel changes from the manually updated packaged PXP were synchronized into the source tree on 2026-08-04.

The matching self-contained experiment is distributed as `templates/KongPanel_Template_20260804.pxp` (SHA-256: `c4ecb6d8d23df999cd50ffee7e6b3f87f95b8b84c92628da962aa11638ac0403`).

For Ver. 9.04.18, the author-provided `KongPanel.pxp` was inspected on 2026-11-20. Its `OMICRON Matrix Loader` procedure page matches the v1.4 loader implementation used for the source release, and its panel recreation identifies Ver. 9.04.18 dated 2026-11-20. The matching self-contained experiment is `templates/KongPanel_Template_20261120.pxp` (SHA-256: `9ae1bc029cce99940f97343bf3236220984ef02981da889dd49f8457ef0f18a6`).

## Exported KP Source Files

The GitHub package keeps the KP-specific Igor Pro files in `src/`:

- `KongPanel.ipf`
- `Load_KongPanel.ipf`
- `Kong_Igor_panel.ipf`
- `KP_ColorTables.ipf`
- `KP_GlobalState.ipf`
- `KP_NewColorTables.itx`
- `KP_NanonisLoaders.ipf`
- `OmicronMatrixLoader.ipf`
- `Procedure.ipf`
- `ModelingTunneling.ipf`
- `General_Simu.ipf`
- `Moire_STM_Topography_Simulator.ipf`
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
- `OmicronMatrixLoader.ipf` adds `Data -> Load Waves -> Load OMICRON Matrix`, with grid, topography-folder, and spectra-folder entry points.

## Custom Color Tables

- `KP_ColorTables.ipf` provides `KP_EnsureNewColorTables()`.
- `KP_NewColorTables.itx` is the Igor Text export of the 47 custom color-table waves formerly stored inside the template experiment.
- `Kong_Igor_panel.ipf` includes `KP_ColorTables` and calls `KP_EnsureNewColorTables()` before creating the panel, so a clean experiment can rebuild `root:Packages:NewColortable`.
- Any GitHub release or ZIP archive must include `KP_NewColorTables.itx` next to the `.ipf` files, preferably in the same `KongPanel` or `src` folder.

## Startup Global State

- `KP_GlobalState.ipf` provides `KP_EnsureStartupGlobals()`.
- `Kong_Igor_panel.ipf` calls `KP_EnsureStartupGlobals()` before `NewPanel`, after `KP_EnsureNewColorTables()`.
- The source release recreates root-level globals that were saved as Igor experiment objects in `Template_kly_2025_06_08/template.pxp`.
- `KP_EnsurePhysicalConstants()` creates `q0`, `h`, `G0`, `muB`, `kB`, `eV`, `meV`, `m0`, and the historical `epslon0`.
- `KP_EnsureTemplateRootGlobals()` creates the missing graph/color/popup compatibility variables and strings, including `topgraphnum`, `topimagemin`, `topimagemax`, `colorsetedc`, `colorsetedc2`, `colorsetedc3`, `colorinverseedc`, `colorindexuser`, `zn_cons`, `topgraphimage`, `topgraphname`, `topgraphcolor`, `topgraphcolorinv`, `topgraphcolor1`, and `S_info`.
- The complete list of 29 root numeric globals and 9 root string globals is documented in `docs/STARTUP_STATE.md` and `docs/STARTUP_STATE.html`.

## Generated Function Book

The function reference was generated from all `src/*.ipf` files with `scripts/build_function_book.py`.

- `docs/FUNCTION_BOOK.html`: color-coded browser manual.
- `docs/FUNCTION_INDEX.md`: Markdown index suitable for GitHub browsing.
- `docs/assets/kong_panel_main.png`: main 𝐊𝐎𝐍𝐆 𝐏𝐚𝐧𝐞𝐥 image for use in the GitHub README and panel guide.
- `docs/PANEL_GUIDE.html`: main-panel image plus button-to-procedure guide.
- `docs/PANEL_GUIDE.md`: Markdown version of the panel guide.
- `docs/STARTUP_STATE.html`: browser-readable startup-state compatibility note.
- `docs/STARTUP_STATE.md`: Markdown startup-state compatibility note.
- `docs/OMICRON_MATRIX_LOADER.html`: browser-readable OMICRON MATRIX loader guide.
- `docs/OMICRON_MATRIX_LOADER.md`: Markdown OMICRON MATRIX loader guide.
- `docs/function_catalog.json`: machine-readable catalog.
- `docs/panel_catalog.json`: machine-readable panel/control catalog.

The current function catalog contains 3243 entries from 28 IPF files, including `Function`, `Proc`, `Window`, `Macro`, and `Menu` definitions. It is organized by workflow and entry role rather than by IPF file. The panel catalog contains parsed main-panel and secondary-panel controls, including visible titles, action procedures, source locations, and reconstructed panel positions where available.

## Verification Notes

- `rg` confirms there are no remaining `KMLoadData`, `KMloadData`, or `KMExit` calls in `src/`.
- Igor Pro was able to scan and compile the new source package after `src/` was synced into Igor's User Procedures folder.
- Clean-Igor startup validation returned 47 custom color-table waves and confirmed that `topgraphnum`, `colorsetedc3`, `G0`, `epslon0`, `topgraphcolor`, and `S_info` are available after `Kong_Igor_panel()` opens.
- Static catalog validation found 24 OMICRON loader definitions with no duplicate definitions inside the module and no collisions with the existing KP source files.
- Compiling inside the original exported PXP can hit duplicate definitions such as `imtb`, because both the old PXP procedure pages and the new `src/` package are loaded at the same time. Use a clean experiment/session for this source package.
