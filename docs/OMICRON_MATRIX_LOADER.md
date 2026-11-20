# OMICRON MATRIX Loader Guide

Kong Panel Ver. 9.04.18 includes a native Igor Pro 9 loader for OMICRON MATRIX acquisition files. It parses MATRIX parameter chains and channel payloads directly in Igor; Python is not required at runtime.

## Menu

Open the loader from:

`Data -> Load Waves -> Load OMICRON Matrix`

The submenu provides three workflows:

| Command | Igor entry point | Use |
|---|---|---|
| Load Grid: all channels | `MatrixLoadGrid()` | Load a voltage-grid channel and all matching grid channels |
| Load Topology: folder | `MatrixLoadTopologyGraph()` | Batch-load Z topographs from one acquisition folder |
| Load Spectra: folder | `MatrixLoadSpectra()` | Batch-load independent voltage spectra |

## Voltage grids

Choose a channel result such as `--39_1.I(V)_mtrx`. The matching `_0001.mtrx` parameter chain and all selected acquisition channel files must remain together in the original folder.

The loader validates every matching channel before creating permanent output. Successful imports create a collision-safe `root:Matrix_<run>_<serial>_` group containing:

- one calibrated 3D wave per channel;
- `xAxis` and `yAxis` waves in metres;
- `biasAxis` in volts;
- a text `channels` table recording wave names, units, and source files;
- wave notes containing acquisition parameters and calibration metadata.

Grid loading currently supports voltage on Spectroscopy Device 1, a single forward/up subgrid acquisition, no ramp reversal, and one repetition. Unsupported scan layouts abort explicitly instead of silently reordering ambiguous data.

## Topography folders

Choose a folder containing `*.Z_mtrx` files and the matching parameter-chain files. Each acquired direction is written as a separate `root:DataN` 2D wave. By default trace/retrace directions are included; the function arguments can control retrace import and x-axis flipping.

Output wave notes record the source file, direction, spatial convention, calibration, acquisition parameters, and whether the scan was incomplete. Pixels not acquired before an interrupted scan remain `NaN`. `root:File_Name` and a collision-safe `root:TopoSourceFilesN` table map each `DataN` wave to its file; an older text `File_Name` list is archived first.

## Independent spectra folders

Choose a folder containing `*(V)_mtrx` spectra and their matching parameter-chain files. Curves are written as collision-safe `root:STSN` waves. Bias is scaled in volts, signal data uses the recorded calibrated unit, and the default orientation is ascending bias.

Trace and retrace are stored as separate waves when available and requested. `root:File_Name` and `root:STS_SourceFiles` describe the latest successful batch; existing text lists are archived rather than overwritten. Unacquired points in incomplete spectra remain `NaN`.

## Programmatic use

```igor
MatrixLoadGrid(filePath=path, biasAscending=1, flipX=1)
MatrixLoadTopologyGraph(folderPath=folder, includeRetrace=1, flipX=0)
MatrixLoadSpectra(folderPath=folder, biasAscending=1, includeRetrace=1)
```

When the optional path is omitted, Igor opens the corresponding file or folder picker.

## Data integrity and current limits

- MATRIX magic, block bounds, parameter chains, payload sizes, sample type, calibration, dimensions, and generated names are validated.
- Supported sample payloads are signed 32-bit MATRIX samples with supported linear or multilinear transfer functions.
- Missing companion files and unsupported acquisition layouts produce explicit history messages or aborts.
- Incomplete topographs and spectra preserve their original geometry and mark unacquired data as `NaN`.
- The loader does not guess how to combine unknown multi-curve layouts, interleaved spatial spectra, or unsupported reversal/repetition modes.

Source: `src/OmicronMatrixLoader.ipf`.
