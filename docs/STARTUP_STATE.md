# Startup State Restored from `template.pxp`

This note documents the non-code Igor objects that were present in `Template_kly_2025_06_08/template.pxp` and are now recreated by the source release.

## Why This Exists

The GitHub release is source based: the panel is loaded from `src/*.ipf` files and the color tables are loaded from `KP_NewColorTables.itx`. A clean Igor experiment does not automatically contain root-level globals that were previously saved as experiment objects inside `template.pxp`.

Some older 𝐊𝐎𝐍𝐆 𝐏𝐚𝐧𝐞𝐥 display, graph-color, popup, and modeling workflows assume these globals already exist. To keep the source release compatible with those workflows, `src/KP_GlobalState.ipf` now recreates the required root-level variables and strings when the main panel starts.

## Startup Entry Point

`Kong_Igor_panel()` calls startup restoration before `NewPanel`:

```igorpro
KP_EnsureNewColorTables()
KP_EnsureStartupGlobals()
NewPanel ...
```

`KP_EnsureStartupGlobals()` runs:

- `KP_EnsurePhysicalConstants()`: creates common SI constants in `root:`.
- `KP_EnsureTemplateRootGlobals()`: creates missing graph/color/popup state globals copied from `template.pxp`.

Template root globals are created only when missing, so existing analysis state in an active experiment is not reset.

## Physical Constants

These variables are created in `root:` for command-line calculations and modeling routines.

| Variable | Default value | Meaning |
|---|---:|---|
| `q0` | `1.602176634e-19` | Elementary charge, C |
| `h` | `6.62607015e-34` | Planck constant, J s |
| `G0` | `3.87404586493e-5` | Conductance quantum `e^2/h`, S |
| `muB` | `9.2740100783e-24` | Bohr magneton, J/T |
| `kB` | `1.380649e-23` | Boltzmann constant, J/K |
| `eV` | `1.602176634e-19` | Electron volt, J |
| `meV` | `1.602176634e-22` | Millielectron volt, J |
| `m0` | `9.1093837015e-31` | Electron mass, kg |
| `epslon0` | `8.8541878128e-12` | Vacuum permittivity, F/m. The historical spelling `epslon0` is preserved for compatibility. |

## Template Numeric Globals

These numeric globals were read from the root data folder of `template.pxp` and are recreated by `KP_EnsureTemplateRootGlobals()`.

| Variable | Default value | Typical use |
|---|---:|---|
| `topgraphnum` | `0` | Active graph/image index used by display helper controls. |
| `topimagemin` | `3.39009e-35` | Stored lower color-scale bound for top image display. |
| `topimagemax` | `4747.39` | Stored upper color-scale bound for top image display. |
| `topimageminratio` | `2.38308e-44` | Stored lower color-scale ratio for top image display. |
| `topimagemaxratio` | `0.0432301` | Stored upper color-scale ratio for top image display. |
| `colorsetedc` | `5` | Color-table popup/index state for EDC or graph coloring workflows. |
| `colorsetedc2` | `6` | Secondary color-table popup/index state. |
| `colorinverseedc` | `1` | Inverted-color flag for EDC or graph coloring workflows. |
| `topgraphnum1` | `0` | Secondary active graph/image index used by related display helpers. |
| `topimagemin1` | `0.0234619` | Secondary lower image color-scale bound. |
| `topimagemax1` | `0.120291` | Secondary upper image color-scale bound. |
| `topimageminratio1` | `0` | Secondary lower color-scale ratio. |
| `topimagemaxratio1` | `1` | Secondary upper color-scale ratio. |
| `colorindexuser` | `1` | User color-index selector state. |
| `colorsetedc3` | `47` | Custom color-table selector state; matches the 47 KP color tables. |
| `typeofdata` | `4` | Data-type selector state used by panel and loader branches. |
| `minsetvar` | `0` | Stored minimum value from display/format controls. |
| `maxsetvar` | `0` | Stored maximum value from display/format controls. |
| `zn_cons` | `2` | 3D matrix Z/energy-plane selector used by smart display and graph controls. |
| `V_Flag` | `0` | Branch flag retained for compatibility with older procedures. |

## Template String Globals

These string globals were read from the root data folder of `template.pxp` and are recreated by `KP_EnsureTemplateRootGlobals()`.

| String | Default value | Typical use |
|---|---|---|
| `topgraphimage` | `Zslice_g2_padFFT_Modula` | Stored image-wave name for active graph display workflows. |
| `topgraphname` | `Graph11` | Stored graph/window name used by graph helper routines. |
| `topgraphcolor` | `root:Packages:NewColortable:dvg_bwr_20_95_c54` | Stored color table path for the active image. |
| `topgraphcolorinv` | `0` | Stored inverse-color flag as a string. |
| `topgraphimage1` | empty string | Secondary stored image-wave name. |
| `topgraphname1` | empty string | Secondary stored graph/window name. |
| `topgraphcolor1` | `Rainbow256` | Secondary stored color-table name. |
| `topgraphcolorinv1` | `0` | Secondary inverse-color flag as a string. |
| `S_info` | `ProcGlobal#KMFileOpenHook;` | Preserved Igor hook information string from the template experiment. |

## Validation Commands

After compiling `Load_KongPanel` in a clean Igor experiment and running `Kong_Igor_panel()`, the following checks should succeed:

```igorpro
print ItemsInList(WaveList("*",";","",root:Packages:NewColortable:))
// Expected: 47

print topgraphnum, colorsetedc3, G0, epslon0
// Expected: 0  47  3.87405e-05  8.85419e-12

print topgraphcolor, S_info
// Expected: root:Packages:NewColortable:dvg_bwr_20_95_c54  ProcGlobal#KMFileOpenHook;
```

The current source release was validated in a clean Igor Pro 9 experiment with these checks.
