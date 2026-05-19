# 𝐊𝐎𝐍𝐆 𝐏𝐚𝐧𝐞𝐥 Guide

This guide maps the main panel controls to their Igor action procedures and wrapped commands. The HTML version, `PANEL_GUIDE.html`, is the preferred browsing format because it keeps the panel sections in a fixed navigation index.

![𝐊𝐎𝐍𝐆 𝐏𝐚𝐧𝐞𝐥 main interface](assets/kong_panel_main.png)

- Main panel controls: 396
- Main panel sections: 41
- Window/panel definitions: 106

## ARPES

### `PeakvsGate`

- Summary: `PeakvsGate` runs `gatemapextractpeak()` through `ButtonProc_gatemapextractpeak`. extracts values, metadata, cursor information, or derived waves.
- Control: `PeakvsGate` `Button`
- Action: `ButtonProc_gatemapextractpeak` -> `gatemapextractpeak()`
- Source: `Kong_Igor_panel.ipf:551`

### `EMDC`

- Summary: `EMDC` runs `EMDC_ini()` through `ButtonProc_EMDC`. Interactive Igor procedure for ARPES-style loading, plotting, or momentum conversion.
- Control: `button97` `Button`
- Action: `ButtonProc_EMDC` -> `EMDC_ini()`
- Source: `Kong_Igor_panel.ipf:753`

### `map kz`

- Summary: `map kz` runs `kly_Kzmap()` through `ButtonProc_kly_Kzmap`. Interactive Igor procedure for linecut, slice, or region extraction; matrix resampling, scaling, or reshaping; ARPES-style loading, plotting, or momentum conversion.
- Control: `lykongmap2` `Button`
- Action: `ButtonProc_kly_Kzmap` -> `kly_Kzmap()`
- Source: `Kong_Igor_panel.ipf:527`

### `PeakvsGrid`

- Summary: `PeakvsGrid` runs `gridextractpeak()` through `ButtonProc_gridextractpeak`. extracts values, metadata, cursor information, or derived waves.
- Control: `PKvsGrid` `Button`
- Action: `ButtonProc_gridextractpeak` -> `gridextractpeak()`
- Source: `Kong_Igor_panel.ipf:553`

### `map kxky`

- Summary: `map kxky` runs `kly_mapping()` through `ButtonProc_kly_mapping`. Interactive Igor procedure for linecut, slice, or region extraction; matrix resampling, scaling, or reshaping; graph display, formatting, or window management.
- Control: `lykongmap` `Button`
- Action: `ButtonProc_kly_mapping` -> `kly_mapping()`
- Source: `Kong_Igor_panel.ipf:521`

### `Au Fit`

- Summary: `Au Fit` calls `ButtonProc_AuFitkly`. fits or extracts spectral/peak parameters.
- Control: `AuFit` `Button`
- Action: `ButtonProc_AuFitkly`
- Source: `Kong_Igor_panel.ipf:533`

### `kz/V before`

- Summary: `kz/V before` runs `Kz_predict()` through `ButtonProc_Kz_predict`. displays waves, images, contours, or graph overlays.
- Control: `button02` `Button`
- Action: `ButtonProc_Kz_predict` -> `Kz_predict()`
- Source: `Kong_Igor_panel.ipf:525`

### `Mat3D`

- Summary: `Mat3D` runs `mat3d_pi()` through `ButtonProc_mat3d_pi`. Begining of Pierre's macros Usage: run interactively from Igor or from a panel callback.
- Control: `button_mat3d_pi` `Button`
- Action: `ButtonProc_mat3d_pi` -> `mat3d_pi()`
- Source: `Kong_Igor_panel.ipf:228`

### `1chunkcut`

- Summary: `1chunkcut` runs `Make_onechunkcut()` through `ButtonProc_Make_onechunkcut`. creates new waves, maps, figures, or simulation data.
- Control: `button66` `Button`
- Action: `ButtonProc_Make_onechunkcut` -> `Make_onechunkcut()`
- Source: `Kong_Igor_panel.ipf:420`

### `Table`

- Summary: `Table` runs `make_table_hv_kz()` through `ButtonProc_make_table_hv_kz`. creates new waves, maps, figures, or simulation data.
- Control: `button75` `Button`
- Action: `ButtonProc_make_table_hv_kz` -> `make_table_hv_kz()`
- Source: `Kong_Igor_panel.ipf:464`

### `-->Plot`

- Summary: `-->Plot` runs `initmat3d()` through `ButtonProc_mat3dfsploter`. Interactive Igor procedure for matrix resampling, scaling, or reshaping; Igor wave/matrix/cube data operation.
- Control: `button5` `Button`
- Action: `ButtonProc_mat3dfsploter` -> `initmat3d()`
- Source: `Kong_Igor_panel.ipf:230`

### `All Ckts`

- Summary: `All Ckts` runs `Make_allchunkcuts()` through `ButtonProc_Make_allchunkcuts`. creates new waves, maps, figures, or simulation data.
- Control: `button67` `Button`
- Action: `ButtonProc_Make_allchunkcuts` -> `Make_allchunkcuts()`
- Source: `Kong_Igor_panel.ipf:422`

### `-->Plot`

- Summary: `-->Plot` runs `initmat3d()` through `ButtonProc_mat3dfsploter`. Interactive Igor procedure for matrix resampling, scaling, or reshaping; Igor wave/matrix/cube data operation.
- Control: `button81` `Button`
- Action: `ButtonProc_mat3dfsploter` -> `initmat3d()`
- Source: `Kong_Igor_panel.ipf:476`

### `Mat3dk`

- Summary: `Mat3dk` runs `mat3dk_pi()` through `ButtonProc_mat3dk_pi`. Interactive Igor procedure for ARPES-style loading, plotting, or momentum conversion; Igor wave/matrix/cube data operation.
- Control: `button27` `Button`
- Action: `ButtonProc_mat3dk_pi` -> `mat3dk_pi()`
- Source: `Kong_Igor_panel.ipf:270`

### `Mat3dk`

- Summary: `Mat3dk` runs `make_mat3dk()` through `ButtonProc_make_mat3dk`. creates new waves, maps, figures, or simulation data.
- Control: `button63` `Button`
- Action: `ButtonProc_make_mat3dk` -> `make_mat3dk()`
- Source: `Kong_Igor_panel.ipf:414`

### `->Plot`

- Summary: `->Plot` runs `initmat3dk()` through `ButtonProc_mat3dkfsploter`. Interactive Igor procedure for matrix resampling, scaling, or reshaping; Igor wave/matrix/cube data operation.
- Control: `button22` `Button`
- Action: `ButtonProc_mat3dkfsploter` -> `initmat3dk()`
- Source: `Kong_Igor_panel.ipf:256`

### `Q`

- Summary: `Q` runs `mat3dkrot()` through `ButtonProc_mat3dkrot`. applies geometric correction or extracts deformation/strain information.
- Control: `button85` `Button`
- Action: `ButtonProc_mat3dkrot` -> `mat3dkrot()`
- Source: `Kong_Igor_panel.ipf:484`

### `µ-shift LFA`

- Summary: `µ-shift LFA` runs `LiFeAsfindmiushift()` through `ButtonProc_LiFeAsfindmiushift`. Interactive Igor procedure for FFT, QPI, phase, or lock-in analysis; smoothing, normalization, or background removal; graph display, formatting, or window management.
- Control: `button04` `Button`
- Action: `ButtonProc_LiFeAsfindmiushift` -> `LiFeAsfindmiushift()`
- Source: `Kong_Igor_panel.ipf:567`

### `Rescale k`

- Summary: `Rescale k` runs `renormcuts_k()` through `ButtonProc_renormcuts_k`. smooths, normalizes, or removes background/trend components.
- Control: `button00` `Button`
- Action: `ButtonProc_renormcuts_k` -> `renormcuts_k()`
- Source: `Kong_Igor_panel.ipf:523`

### `θ to k`

- Summary: `θ to k` runs `CVT2EK_pi_renorm()` through `ButtonProc_CVT2EK_pi_renorm`. smooths, normalizes, or removes background/trend components.
- Control: `button01` `Button`
- Action: `ButtonProc_CVT2EK_pi_renorm` -> `CVT2EK_pi_renorm()`
- Source: `Kong_Igor_panel.ipf:561`

### `kz/V after`

- Summary: `kz/V after` runs `Kz_predict2()` through `ButtonProc_Kz_predict2`. displays waves, images, contours, or graph overlays.
- Control: `MBEkly2` `Button`
- Action: `ButtonProc_Kz_predict2` -> `Kz_predict2()`
- Source: `Kong_Igor_panel.ipf:531`

### `Mk List`

- Summary: `Mk List` runs `Generate_chunklist()` through `ButtonProc_Generate_chunklist`. creates new waves, maps, figures, or simulation data.
- Control: `button68` `Button`
- Action: `ButtonProc_Generate_chunklist` -> `Generate_chunklist()`
- Source: `Kong_Igor_panel.ipf:424`

### `3dVD`

- Summary: `3dVD` runs `mat3dVD_pi()` through `ButtonProc_mat3dVD_pi`. Interactive Igor procedure for smoothing, normalization, or background removal; Igor wave/matrix/cube data operation.
- Control: `button24` `Button`
- Action: `ButtonProc_mat3dVD_pi` -> `mat3dVD_pi()`
- Source: `Kong_Igor_panel.ipf:260`

### `Map hv`

- Summary: `Map hv` runs `CVT2K_vs_hv()` through `ButtonProc_CVT2K_vs_hv`. Interactive Igor procedure for linecut, slice, or region extraction; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management.
- Control: `button76` `Button`
- Action: `ButtonProc_CVT2K_vs_hv` -> `CVT2K_vs_hv()`
- Source: `Kong_Igor_panel.ipf:466`

### `C`

- Summary: `C` runs `mat3dVC_pi()` through `ButtonProc_mat3dVC_pi`. Interactive Igor procedure for smoothing, normalization, or background removal; Igor wave/matrix/cube data operation.
- Control: `button112` `Button`
- Action: `ButtonProc_mat3dVC_pi` -> `mat3dVC_pi()`
- Source: `Kong_Igor_panel.ipf:513`

### `-->Plot`

- Summary: `-->Plot` runs `initmat3dVD()` through `ButtonProc_mat3dVDfsploter`. Interactive Igor procedure for matrix resampling, scaling, or reshaping; Igor wave/matrix/cube data operation.
- Control: `button30` `Button`
- Action: `ButtonProc_mat3dVDfsploter` -> `initmat3dVD()`
- Source: `Kong_Igor_panel.ipf:272`

### `-->mat3d`

- Summary: `-->mat3d` calls `ButtonDuplicate_hvmat3d`. copies, duplicates, or renames Igor waves/traces.
- Control: `button78` `Button`
- Action: `ButtonDuplicate_hvmat3d`
- Source: `Kong_Igor_panel.ipf:470`

### `Mat3dkVD`

- Summary: `Mat3dkVD` runs `mat3dkVD_pi()` through `ButtonProc_mat3dkVD_pi`. Interactive Igor procedure for ARPES-style loading, plotting, or momentum conversion; Igor wave/matrix/cube data operation.
- Control: `button25` `Button`
- Action: `ButtonProc_mat3dkVD_pi` -> `mat3dkVD_pi()`
- Source: `Kong_Igor_panel.ipf:262`

### `Mat3dkVD`

- Summary: `Mat3dkVD` runs `make_mat3dkVD()` through `ButtonProc_make_mat3dkVD`. creates new waves, maps, figures, or simulation data.
- Control: `button64` `Button`
- Action: `ButtonProc_make_mat3dkVD` -> `make_mat3dkVD()`
- Source: `Kong_Igor_panel.ipf:416`

### `VD`

- Summary: `VD` runs `mat3dVD_pi()` through `ButtonProc_mat3dVD_pi`. Interactive Igor procedure for smoothing, normalization, or background removal; Igor wave/matrix/cube data operation.
- Control: `button80` `Button`
- Action: `ButtonProc_mat3dVD_pi` -> `mat3dVD_pi()`
- Source: `Kong_Igor_panel.ipf:474`

### `C`

- Summary: `C` runs `mat3dVC_pi()` through `ButtonProc_mat3dVC_pi`. Interactive Igor procedure for smoothing, normalization, or background removal; Igor wave/matrix/cube data operation.
- Control: `button114` `Button`
- Action: `ButtonProc_mat3dVC_pi` -> `mat3dVC_pi()`
- Source: `Kong_Igor_panel.ipf:517`

### `->Plot`

- Summary: `->Plot` runs `initmat3dkVD()` through `ButtonProc_mat3dkVDfsploter`. Interactive Igor procedure for matrix resampling, scaling, or reshaping; Igor wave/matrix/cube data operation.
- Control: `button26` `Button`
- Action: `ButtonProc_mat3dkVDfsploter` -> `initmat3dkVD()`
- Source: `Kong_Igor_panel.ipf:264`

### `-->Plot`

- Summary: `-->Plot` runs `initmat3dVD()` through `ButtonProc_mat3dVDfsploter`. Interactive Igor procedure for matrix resampling, scaling, or reshaping; Igor wave/matrix/cube data operation.
- Control: `button82` `Button`
- Action: `ButtonProc_mat3dVDfsploter` -> `initmat3dVD()`
- Source: `Kong_Igor_panel.ipf:478`

### `Q`

- Summary: `Q` runs `mat3dkVDrot()` through `ButtonProc_mat3dkVDrot`. applies geometric correction or extracts deformation/strain information.
- Control: `button86` `Button`
- Action: `ButtonProc_mat3dkVDrot` -> `mat3dkVDrot()`
- Source: `Kong_Igor_panel.ipf:487`

### `Max in Batch`

- Summary: `Max in Batch` runs `findmaxBatch()` through `ButtonProc_findmaxBatch`. Interactive Igor procedure for Igor wave/matrix/cube data operation.
- Control: `Map51` `Button`
- Action: `ButtonProc_findmaxBatch` -> `findmaxBatch()`
- Source: `Kong_Igor_panel.ipf:541`

### `Norm for map`

- Summary: `Norm for map` runs `normlizeformap()` through `ButtonProc_Normdivide`. smooths, normalizes, or removes background/trend components.
- Control: `Normformap` `Button`
- Action: `ButtonProc_Normdivide` -> `normlizeformap()`
- Source: `Kong_Igor_panel.ipf:535`

### `CEM kz`

- Summary: `CEM kz` runs `Kz_predict2()` through `ButtonProc_CEM2DToKZ`. displays waves, images, contours, or graph overlays.
- Control: `button116` `Button`
- Action: `ButtonProc_CEM2DToKZ` -> `Kz_predict2()`
- Source: `Kong_Igor_panel.ipf:537`

### `Subtset`

- Summary: `Subtset` runs `subsc()` through `ButtonProc_subsc`. Interactive Igor procedure for symmetry or reflection processing; graph display, formatting, or window management.
- Control: `Normline2p3` `Button`
- Action: `ButtonProc_subsc` -> `subsc()`
- Source: `Kong_Igor_panel.ipf:563`

### `Deriv1`

- Summary: `Deriv1` runs `deriv_1chunkcut()` through `ButtonProc_deriv_1chunkcut`. Interactive Igor procedure for linecut, slice, or region extraction; smoothing, normalization, or background removal.
- Control: `button69` `Button`
- Action: `ButtonProc_deriv_1chunkcut` -> `deriv_1chunkcut()`
- Source: `Kong_Igor_panel.ipf:426`

### `Deriv all`

- Summary: `Deriv all` runs `deriv_allchunkcut()` through `ButtonProc_deriv_allchunkcut`. Interactive Igor procedure for linecut, slice, or region extraction; smoothing, normalization, or background removal.
- Control: `button70` `Button`
- Action: `ButtonProc_deriv_allchunkcut` -> `deriv_allchunkcut()`
- Source: `Kong_Igor_panel.ipf:428`

### `3dHD`

- Summary: `3dHD` runs `mat3dHD_pi()` through `ButtonProc_mat3dHD_pi`. Interactive Igor procedure for smoothing, normalization, or background removal; Igor wave/matrix/cube data operation.
- Control: `but_mat3dHD` `Button`
- Action: `ButtonProc_mat3dHD_pi` -> `mat3dHD_pi()`
- Source: `Kong_Igor_panel.ipf:296`

### `Map kz`

- Summary: `Map kz` runs `CVT2K_vs_kz()` through `ButtonProc_CVT2K_vs_kz`. hv mapping project Usage: run from Igor with parameters slitorientation, Vzero, kzgridfactor.
- Control: `button77` `Button`
- Action: `ButtonProc_CVT2K_vs_kz` -> `CVT2K_vs_kz()`
- Source: `Kong_Igor_panel.ipf:468`

### `C`

- Summary: `C` runs `mat3dHC_pi()` through `ButtonProc_mat3dHC_pi`. Interactive Igor procedure for smoothing, normalization, or background removal; Igor wave/matrix/cube data operation.
- Control: `button113` `Button`
- Action: `ButtonProc_mat3dHC_pi` -> `mat3dHC_pi()`
- Source: `Kong_Igor_panel.ipf:515`

### `-->mat3d`

- Summary: `-->mat3d` calls `ButtonDuplicate_kzmat3d`. copies, duplicates, or renames Igor waves/traces.
- Control: `button79` `Button`
- Action: `ButtonDuplicate_kzmat3d`
- Source: `Kong_Igor_panel.ipf:472`

### `-->Plot`

- Summary: `-->Plot` runs `initmat3dHD()` through `ButtonProc_mat3dHDfsploter`. Interactive Igor procedure for matrix resampling, scaling, or reshaping; Igor wave/matrix/cube data operation.
- Control: `button44` `Button`
- Action: `ButtonProc_mat3dHDfsploter` -> `initmat3dHD()`
- Source: `Kong_Igor_panel.ipf:274`

### `HD`

- Summary: `HD` runs `mat3dHD_pi()` through `ButtonProc_mat3dHD_pi`. Interactive Igor procedure for smoothing, normalization, or background removal; Igor wave/matrix/cube data operation.
- Control: `button83` `Button`
- Action: `ButtonProc_mat3dHD_pi` -> `mat3dHD_pi()`
- Source: `Kong_Igor_panel.ipf:480`

### `C`

- Summary: `C` runs `mat3dHC_pi()` through `ButtonProc_mat3dHC_pi`. Interactive Igor procedure for smoothing, normalization, or background removal; Igor wave/matrix/cube data operation.
- Control: `button115` `Button`
- Action: `ButtonProc_mat3dHC_pi` -> `mat3dHC_pi()`
- Source: `Kong_Igor_panel.ipf:519`

### `->Plot`

- Summary: `->Plot` runs `initmat3dkHD()` through `ButtonProc_mat3dkHDfsploter`. Interactive Igor procedure for matrix resampling, scaling, or reshaping; Igor wave/matrix/cube data operation.
- Control: `button46` `Button`
- Action: `ButtonProc_mat3dkHDfsploter` -> `initmat3dkHD()`
- Source: `Kong_Igor_panel.ipf:268`

### `-->Plot`

- Summary: `-->Plot` runs `initmat3dHD()` through `ButtonProc_mat3dHDfsploter`. Interactive Igor procedure for matrix resampling, scaling, or reshaping; Igor wave/matrix/cube data operation.
- Control: `button84` `Button`
- Action: `ButtonProc_mat3dHDfsploter` -> `initmat3dHD()`
- Source: `Kong_Igor_panel.ipf:482`

### `Q`

- Summary: `Q` runs `mat3dkHDrot()` through `ButtonProc_mat3dkHDrot`. applies geometric correction or extracts deformation/strain information.
- Control: `button87` `Button`
- Action: `ButtonProc_mat3dkHDrot` -> `mat3dkHDrot()`
- Source: `Kong_Igor_panel.ipf:490`

### `Mat3dkHD`

- Summary: `Mat3dkHD` runs `mat3dkHD_pi()` through `ButtonProc_mat3dkHD_pi`. Interactive Igor procedure for ARPES-style loading, plotting, or momentum conversion; Igor wave/matrix/cube data operation.
- Control: `button45` `Button`
- Action: `ButtonProc_mat3dkHD_pi` -> `mat3dkHD_pi()`
- Source: `Kong_Igor_panel.ipf:266`

### `Mat3dkHD`

- Summary: `Mat3dkHD` runs `make_mat3dkHD()` through `ButtonProc_make_mat3dkHD`. creates new waves, maps, figures, or simulation data.
- Control: `button65` `Button`
- Action: `ButtonProc_make_mat3dkHD` -> `make_mat3dkHD()`
- Source: `Kong_Igor_panel.ipf:418`

### `Offset The`

- Summary: `Offset The` runs `offtheset()` through `ButtonProc_Constofftheset`. performs Fourier, filtering, phase, or lock-in processing.
- Control: `button03` `Button`
- Action: `ButtonProc_Constofftheset` -> `offtheset()`
- Source: `Kong_Igor_panel.ipf:565`

### `MBE_1MLTime`

- Summary: `MBE_1MLTime` runs `MBE1MLTime()` through `ButtonProc_MBE1MLTime`. Interactive Igor procedure for lattice, moire, or twist-angle simulation/analysis.
- Control: `MBEkly1` `Button`
- Action: `ButtonProc_MBE1MLTime` -> `MBE1MLTime()`
- Source: `Kong_Igor_panel.ipf:529`

### `BKG remover`

- Summary: `BKG remover` runs `bkremoverp()` through `ButtonProc_bkremover`. removes waves/windows/data points or cleans intermediate state.
- Control: `Normformap1` `Button`
- Action: `ButtonProc_bkremover` -> `bkremoverp()`
- Source: `Kong_Igor_panel.ipf:539`

### `Sym hv`

- Summary: `Sym hv` runs `symmat3dhv()` through `ButtonProc_symmat3dhv`. applies symmetry, mirror, or reflection operations.
- Control: `button111` `Button`
- Action: `ButtonProc_symmat3dhv` -> `symmat3dhv()`
- Source: `Kong_Igor_panel.ipf:511`

### `θ2k`

- Summary: `θ2k` runs `CVT2EK_exact1cut()` through `ButtonProc_CVT2EK_exact1cut`. Interactive Igor procedure for linecut, slice, or region extraction; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management.
- Control: `button108` `Button`
- Action: `ButtonProc_CVT2EK_exact1cut` -> `CVT2EK_exact1cut()`
- Source: `Kong_Igor_panel.ipf:434`

### `θ to k`

- Summary: `θ to k` runs `CVT2EK_pi()` through `ButtonProc_CVT2EK`. Interactive Igor procedure for matrix resampling, scaling, or reshaping; ARPES-style loading, plotting, or momentum conversion; Igor wave/matrix/cube data operation.
- Control: `button100` `Button`
- Action: `ButtonProc_CVT2EK` -> `CVT2EK_pi()`
- Source: `Kong_Igor_panel.ipf:559`

### `Cut Image`

- Summary: `Cut Image` calls `ButtonProc_Makecutimage`. creates new waves, maps, figures, or simulation data.
- Control: `button_Generatecut` `Button`
- Action: `ButtonProc_Makecutimage` -> `Makecutimage_pi()`
- Source: `Kong_Igor_panel.ipf:226`

### `All cuts`

- Summary: `All cuts` runs `allcuts()` through `ButtonProc_allcuts`. Interactive Igor procedure for linecut, slice, or region extraction; graph display, formatting, or window management.
- Control: `button32` `Button`
- Action: `ButtonProc_allcuts` -> `allcuts()`
- Source: `Kong_Igor_panel.ipf:280`

### `Angle Cvter FS`

- Summary: `Angle Cvter FS` runs `anglemode_converter_fs()` through `ButtonProc_angmodeconverterfs`. Interactive Igor procedure for linecut, slice, or region extraction.
- Control: `button71` `Button`
- Action: `ButtonProc_angmodeconverterfs` -> `anglemode_converter_fs()`
- Source: `Kong_Igor_panel.ipf:430`

### `Interp`

- Summary: `Interp` runs `Interpmat3D()` through `ButtonProcInterp3D`. hv mapping project end Purpose: resamples, rescales, pads, or changes wave dimensions.
- Control: `button88` `Button`
- Action: `ButtonProcInterp3D` -> `Interpmat3D()`
- Source: `Kong_Igor_panel.ipf:493`

### `Jump Cal`

- Summary: `Jump Cal` runs `stepmove()` through `ButtonProc_stepmove`. Interactive Igor procedure for lattice, moire, or twist-angle simulation/analysis.
- Control: `Jumpcal` `Button`
- Action: `ButtonProc_stepmove` -> `stepmove()`
- Source: `Kong_Igor_panel.ipf:728`


## Ver. 9.04.16 (Date: 05/18/2026)

### `Initialize`

- Summary: `Initialize` runs `mainpanelinitalize()` through `ButtonProc_mainpanelinitalize`. Interactive Igor procedure for FFT, QPI, phase, or lock-in analysis; linecut, slice, or region extraction; smoothing, normalization, or background removal.
- Control: `buttonini` `Button`
- Action: `ButtonProc_mainpanelinitalize` -> `mainpanelinitalize()`
- Source: `Kong_Igor_panel.ipf:392`

### `Data_type`

- Summary: `Data_type` calls `PopMenuProc`. Panel callback/helper in Pierre's Template.ipf.
- Control: `Data_type` `PopupMenu`
- Action: `PopMenuProc`
- Source: `Kong_Igor_panel.ipf:304`

### `LD 2D`

- Summary: `LD 2D` calls `ButtonProc_Loaddata2`. loads data or launches an automatic loading workflow.
- Control: `button_LoadAll` `Button`
- Action: `ButtonProc_Loaddata2` -> `Makegraphtable()`
- Source: `Kong_Igor_panel.ipf:543`

### `KILL / Graphs`

- Summary: `KILL / Graphs` runs `killags()` through `ButtonProc_killags`. removes waves/windows/data points or cleans intermediate state.
- Control: `DeletePoints5` `Button`
- Action: `ButtonProc_killags` -> `killags()`
- Source: `Kong_Igor_panel.ipf:725`

### `LDA30`

- Summary: `LDA30` runs `loadDA30_kly()` through `ButtonProc_LoadDA30`. loads data or launches an automatic loading workflow.
- Control: `button_LoadDA30SSRF` `Button`
- Action: `ButtonProc_LoadDA30` -> `loadDA30_kly()`
- Source: `Kong_Igor_panel.ipf:545`


## Gap Map

### `Ploter`

- Summary: `Ploter` runs `dataploter()` through `ButtonProc_dataploter`. displays waves, images, contours, or graph overlays.
- Control: `button3` `Button`
- Action: `ButtonProc_dataploter` -> `dataploter()`
- Source: `Kong_Igor_panel.ipf:547`

### `P2`

- Summary: `P2` runs `dataploter2()` through `ButtonProc_dataploter2`. displays waves, images, contours, or graph overlays.
- Control: `button05` `Button`
- Action: `ButtonProc_dataploter2` -> `dataploter2()`
- Source: `Kong_Igor_panel.ipf:549`

### `2D_G`

- Summary: `2D_G` runs `extrastsfrommap3dGuassian()` through `ButtonProc_gapdiisGuassian`. Interactive Igor procedure for linecut, slice, or region extraction; matrix resampling, scaling, or reshaping; spectroscopy, superconducting-gap, or vortex-model analysis.
- Control: `Map75` `Button`
- Action: `ButtonProc_gapdiisGuassian` -> `extrastsfrommap3dGuassian()`
- Source: `Kong_Igor_panel.ipf:666`

### `2D_LS`

- Summary: `2D_LS` runs `extrastsfrommap3d()` through `ButtonProc_gapdiis`. Interactive Igor procedure for linecut, slice, or region extraction; matrix resampling, scaling, or reshaping; spectroscopy, superconducting-gap, or vortex-model analysis.
- Control: `Map32` `Button`
- Action: `ButtonProc_gapdiis` -> `extrastsfrommap3d()`
- Source: `Kong_Igor_panel.ipf:635`

### `2D_GCB`

- Summary: `2D_GCB` runs `extrastsfrommap3dGuassian2()` through `ButtonProc_gapdiisGuassian2`. Interactive Igor procedure for linecut, slice, or region extraction; spectroscopy, superconducting-gap, or vortex-model analysis; graph display, formatting, or window management.
- Control: `Map76` `Button`
- Action: `ButtonProc_gapdiisGuassian2` -> `extrastsfrommap3dGuassian2()`
- Source: `Kong_Igor_panel.ipf:668`

### `1D_LS`

- Summary: `1D_LS` runs `linecutgapdistr()` through `ButtonProc_linecutgapdistrpp`. displays waves, images, contours, or graph overlays.
- Control: `Map63` `Button`
- Action: `ButtonProc_linecutgapdistrpp` -> `linecutgapdistr()`
- Source: `Kong_Igor_panel.ipf:661`


## Lattice Simu

### `CtG`

- Summary: `CtG` runs `tta()` through `ButtonProc_convertG`. Interactive Igor procedure for Nanonis/STM data loading or map conversion; graph display, formatting, or window management; Igor wave/matrix/cube data operation.
- Control: `Map77` `Button`
- Action: `ButtonProc_convertG` -> `tta()`
- Source: `Kong_Igor_panel.ipf:731`

### `LtE`

- Summary: `LtE` runs `reorg2ndd()` through `ButtonProc_reorg2ndd`. Interactive Igor procedure for linecut, slice, or region extraction; ARPES-style loading, plotting, or momentum conversion; Igor wave/matrix/cube data operation.
- Control: `Map82` `Button`
- Action: `ButtonProc_reorg2ndd` -> `reorg2ndd()`
- Source: `Kong_Igor_panel.ipf:733`

### `Multi.Order`

- Summary: `Multi.Order` runs `SumCompOrder()` through `ButtonProc_SumCompOrder`. combines many waves/slices into a map, linecut, or averaged output.
- Control: `Map60cpr12` `Button`
- Action: `ButtonProc_SumCompOrder` -> `SumCompOrder()`
- Source: `Kong_Igor_panel.ipf:863`


## Convert Nanonis

### `3D to 2Ds / (Grid Map)`

- Summary: `3D to 2Ds / (Grid Map)` runs `Initialize_Global_Variables()` through `ButtonProc_getslicerData`. Interactive Igor procedure for symmetry or reflection processing; ARPES-style loading, plotting, or momentum conversion; Igor wave/matrix/cube data operation.
- Control: `Map59` `Button`
- Action: `ButtonProc_getslicerData` -> `Initialize_Global_Variables()`
- Source: `Kong_Igor_panel.ipf:557`

### `Reorder 2D / (Grid Linecut)`

- Summary: `Reorder 2D / (Grid Linecut)` runs `extract3dslinecut()` through `ButtonProc_extract3dslinecut`. extracts values, metadata, cursor information, or derived waves.
- Control: `Map61` `Button`
- Action: `ButtonProc_extract3dslinecut` -> `extract3dslinecut()`
- Source: `Kong_Igor_panel.ipf:657`

### `2D to 1Ds / (Grid Linecut)`

- Summary: `2D to 1Ds / (Grid Linecut)` runs `slice1ddpro()` through `ButtonProc_slice1ddpro`. Interactive Igor procedure for Nanonis/STM data loading or map conversion; linecut, slice, or region extraction; Igor wave/matrix/cube data operation.
- Control: `Map62` `Button`
- Action: `ButtonProc_slice1ddpro` -> `slice1ddpro()`
- Source: `Kong_Igor_panel.ipf:659`


## Quick Format

### `Old`

- Summary: `Old` runs `Makelatticedata()` through `ButtonProc_Makelatticedata`. creates new waves, maps, figures, or simulation data.
- Control: `Map69` `Button`
- Action: `ButtonProc_Makelatticedata` -> `Makelatticedata()`
- Source: `Kong_Igor_panel.ipf:670`

### `dI/dV`

- Summary: `dI/dV` calls `ButtonProc_legend_dIdV_vs_V`. displays waves, images, contours, or graph overlays.
- Control: `Symx5` `Button`
- Action: `ButtonProc_legend_dIdV_vs_V`
- Source: `Kong_Igor_panel.ipf:869`

### `d/V`

- Summary: `d/V` calls `ButtonProc_legend_distance_vs_V`. displays waves, images, contours, or graph overlays.
- Control: `Symx6` `Button`
- Action: `ButtonProc_legend_distance_vs_V`
- Source: `Kong_Igor_panel.ipf:871`

### `2e2/h`

- Summary: `2e2/h` calls `ButtonProc_sizedos`. Panel button callback for symmetry or reflection processing; spectroscopy, superconducting-gap, or vortex-model analysis; graph display, formatting, or window management.
- Control: `Map06` `Button`
- Action: `ButtonProc_sizedos`
- Source: `Kong_Igor_panel.ipf:873`

### `Draw lines`

- Summary: `Draw lines` runs `appendVline()` through `ButtonProc_appendVline`. displays waves, images, contours, or graph overlays.
- Control: `Map66` `Button`
- Action: `ButtonProc_appendVline` -> `appendVline()`
- Source: `Kong_Igor_panel.ipf:1048`

### `Format`

- Summary: `Format` calls `ButtonProc_sizecurve`. Panel button callback for symmetry or reflection processing; linecut, slice, or region extraction; graph display, formatting, or window management.
- Control: `Map39` `Button`
- Action: `ButtonProc_sizecurve`
- Source: `Kong_Igor_panel.ipf:875`

### `Gr-lat`

- Summary: `Gr-lat` runs `Fitimagehoneycombc()` through `ButtonProc_Fitimagehoneycombc`. fits or extracts spectral/peak parameters.
- Control: `Map08` `Button`
- Action: `ButtonProc_Fitimagehoneycombc` -> `Fitimagehoneycombc()`
- Source: `Kong_Igor_panel.ipf:1050`

### `Tri`

- Summary: `Tri` runs `Fitimagetriangularc()` through `ButtonProc_Fitimagetriangularc`. fits or extracts spectral/peak parameters.
- Control: `Map34` `Button`
- Action: `ButtonProc_Fitimagetriangularc` -> `Fitimagetriangularc()`
- Source: `Kong_Igor_panel.ipf:1052`

### `Sq`

- Summary: `Sq` runs `Fitimagesquarec()` through `ButtonProc_Fitimagesquarec`. fits or extracts spectral/peak parameters.
- Control: `Map35` `Button`
- Action: `ButtonProc_Fitimagesquarec` -> `Fitimagesquarec()`
- Source: `Kong_Igor_panel.ipf:1054`

### `Label on`

- Summary: `Label on` calls `ButtonProc_sizecurvelableon`. Panel button callback for symmetry or reflection processing; graph display, formatting, or window management.
- Control: `Map92` `Button`
- Action: `ButtonProc_sizecurvelableon`
- Source: `Kong_Igor_panel.ipf:879`

### `None`

- Summary: `None` calls `ButtonProc_sizecurvenone`. Panel button callback for symmetry or reflection processing; graph display, formatting, or window management.
- Control: `Map91` `Button`
- Action: `ButtonProc_sizecurvenone`
- Source: `Kong_Igor_panel.ipf:877`


## Smart Displayer

### `2D Multifunc. Displayer`

- Summary: `2D Multifunc. Displayer` runs `Smart2DEMDC()` through `ButtonProc_Smart2DEMDC`. Interactive Igor procedure for symmetry or reflection processing; matrix resampling, scaling, or reshaping; ARPES-style loading, plotting, or momentum conversion.
- Control: `button62` `Button`
- Action: `ButtonProc_Smart2DEMDC` -> `Smart2DEMDC()`
- Source: `Kong_Igor_panel.ipf:709`

### `3D Multifunc. Displayer`

- Summary: `3D Multifunc. Displayer` runs `d3d()` through `ButtonProc_Cons3dplot`. Interactive Igor procedure for linecut, slice, or region extraction; matrix resampling, scaling, or reshaping; smoothing, normalization, or background removal.
- Control: `Map88` `Button`
- Action: `ButtonProc_Cons3dplot` -> `d3d()`
- Source: `Kong_Igor_panel.ipf:745`


## Get Information

### `1D_GCB`

- Summary: `1D_GCB` runs `extrastsfrommap3dGuassian3()` through `ButtonProc_gapdiisGuassian3`. Interactive Igor procedure for linecut, slice, or region extraction; matrix resampling, scaling, or reshaping; spectroscopy, superconducting-gap, or vortex-model analysis.
- Control: `Map70` `Button`
- Action: `ButtonProc_gapdiisGuassian3` -> `extrastsfrommap3dGuassian3()`
- Source: `Kong_Igor_panel.ipf:672`

### `Point reader`

- Summary: `Point reader` runs `Point_reader()` through `ButtonProc_showpntreader`. extracts values, metadata, cursor information, or derived waves.
- Control: `buttonpntreader` `Button`
- Action: `ButtonProc_showpntreader` -> `Point_reader()`
- Source: `Kong_Igor_panel.ipf:1026`

### `Making FS`

- Summary: `Making FS` runs `Table_Notthesepoints()` through `ButtonProc_making_fsH`. Interactive Igor procedure for graph display, formatting, or window management.
- Control: `button33` `Button`
- Action: `ButtonProc_making_fsH` -> `Table_Notthesepoints()`
- Source: `Kong_Igor_panel.ipf:358`

### `Making FS`

- Summary: `Making FS` runs `Table_Notthesepoints()` through `ButtonProc_making_fs2f`. Interactive Igor procedure for graph display, formatting, or window management.
- Control: `button35` `Button`
- Action: `ButtonProc_making_fs2f` -> `Table_Notthesepoints()`
- Source: `Kong_Igor_panel.ipf:360`

### `Get Peak / 2D Gaussian`

- Summary: `Get Peak / 2D Gaussian` runs `gpc()` through `ButtonProc_GPc`. Interactive Igor procedure for FFT, QPI, phase, or lock-in analysis.
- Control: `Getp` `Button`
- Action: `ButtonProc_GPc` -> `gpc()`
- Source: `Kong_Igor_panel.ipf:1028`

### `Get Peak / 1D multi`

- Summary: `Get Peak / 1D multi` runs `getpeakfromwaterfallc()` through `ButtonProc_getpeakfromwfc`. extracts values, metadata, cursor information, or derived waves.
- Control: `Getp1` `Button`
- Action: `ButtonProc_getpeakfromwfc` -> `getpeakfromwaterfallc()`
- Source: `Kong_Igor_panel.ipf:1030`

### `MultiPeak 1D`

- Summary: `MultiPeak 1D` runs `t2nddpeakc()` through `ButtonProc_t2nddpeakc`. fits or extracts spectral/peak parameters.
- Control: `button28` `Button`
- Action: `ButtonProc_t2nddpeakc` -> `t2nddpeakc()`
- Source: `Kong_Igor_panel.ipf:757`

### `Image FS`

- Summary: `Image FS` runs `ini_image_fs2f()` through `ButtonProc_image_fs2f`. Interactive Igor procedure for geometric correction, rotation, shear, drift, or strain analysis; lattice, moire, or twist-angle simulation/analysis.
- Control: `for_image_fs2f` `Button`
- Action: `ButtonProc_image_fs2f` -> `ini_image_fs2f()`
- Source: `Kong_Igor_panel.ipf:364`

### `Image FS`

- Summary: `Image FS` runs `ini_image_fsHex()` through `ButtonProc_image_fsHEX`. Interactive Igor procedure for geometric correction, rotation, shear, drift, or strain analysis; lattice, moire, or twist-angle simulation/analysis; ARPES-style loading, plotting, or momentum conversion.
- Control: `for_image_fsH` `Button`
- Action: `ButtonProc_image_fsHEX` -> `ini_image_fsHex()`
- Source: `Kong_Igor_panel.ipf:366`

### `Auto Histogram`

- Summary: `Auto Histogram` runs `Conshist()` through `ButtonProc_Conshist`. Interactive Igor procedure for graph display, formatting, or window management.
- Control: `Getp2` `Button`
- Action: `ButtonProc_Conshist` -> `Conshist()`
- Source: `Kong_Igor_panel.ipf:1032`

### `Auto / GateMp`

- Summary: `Auto / GateMp` runs `gatemapauto()` through `ButtonProc_autogatemap`. Interactive Igor procedure for Nanonis/STM data loading or map conversion; symmetry or reflection processing; linecut, slice, or region extraction.
- Control: `KMExist3` `Button`
- Action: `ButtonProc_autogatemap` -> `gatemapauto()`
- Source: `Kong_Igor_panel.ipf:817`

### `d(*)`

- Summary: `d(*)` calls `ButtonProc_Showfigind`. ## New and Smarter version of Auto display figure##
- Control: `Symx26` `Button`
- Action: `ButtonProc_Showfigind`
- Source: `Kong_Igor_panel.ipf:1034`

### `RDF`

- Summary: `RDF` runs `RDF()` through `ButtonProc_RDF`. Interactive Igor procedure in Miscellaneous_Codes.ipf.
- Control: `Symx16` `Button`
- Action: `ButtonProc_RDF` -> `RDF()`
- Source: `Kong_Igor_panel.ipf:1036`

### `Length`

- Summary: `Length` runs `linel()` through `ButtonProc_length`. Interactive Igor procedure for matrix resampling, scaling, or reshaping; Igor wave/matrix/cube data operation.
- Control: `Symx8` `Button`
- Action: `ButtonProc_length` -> `linel()`
- Source: `Kong_Igor_panel.ipf:1038`

### `Csr Tracor`

- Summary: `Csr Tracor` calls `ButtonProc_Csrtracor1`. Contour tracor by cursor
- Control: `Getp3` `Button`
- Action: `ButtonProc_Csrtracor1`
- Source: `Kong_Igor_panel.ipf:1040`

### `tab_matrices`

- Summary: `tab_matrices` calls `TabProc_main`. Panel callback/helper for symmetry or reflection processing; ARPES-style loading, plotting, or momentum conversion.
- Control: `tab_matrices` `TabControl`
- Action: `TabProc_main`
- Source: `Kong_Igor_panel.ipf:308`

### `Peng's Curvature`

- Summary: `Peng's Curvature` calls `ButtonProc_curv_Zhang`. Panel button callback for linecut, slice, or region extraction; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management.
- Control: `button93` `Button`
- Action: `ButtonProc_curv_Zhang`
- Source: `Kong_Igor_panel.ipf:503`

### `Smooth`

- Summary: `Smooth` calls `ButtonProc_smoothmat_k`. smooths, normalizes, or removes background/trend components.
- Control: `button36` `Button`
- Action: `ButtonProc_smoothmat_k` -> `smoothmat_k()`
- Source: `Kong_Igor_panel.ipf:284`

### `Sym EDC`

- Summary: `Sym EDC` runs `sym_one_edc()` through `ButtonProc_sym_one_edc`. applies symmetry, mirror, or reflection operations.
- Control: `but_sym_edc` `Button`
- Action: `ButtonProc_sym_one_edc` -> `sym_one_edc()`
- Source: `Kong_Igor_panel.ipf:302`

### `Normwave`

- Summary: `Normwave` runs `normwave()` through `ButtonProc_normwave`. smooths, normalizes, or removes background/trend components.
- Control: `button34` `Button`
- Action: `ButtonProc_normwave` -> `normwave()`
- Source: `Kong_Igor_panel.ipf:282`

### `Copy all traces`

- Summary: `Copy all traces` runs `Copytraces()` through `ButtonProc_Copytraces`. copies, duplicates, or renames Igor waves/traces.
- Control: `button_copy_traces` `Button`
- Action: `ButtonProc_Copytraces` -> `Copytraces()`
- Source: `Kong_Igor_panel.ipf:306`

### `Capture`

- Summary: `Capture` runs `Capturename()` through `ButtonProc_Capturename`. $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Image color scale Purpose: copies, duplicates, or renames Igor waves/traces.
- Control: `button74` `Button`
- Action: `ButtonProc_Capturename` -> `Capturename()`
- Source: `Kong_Igor_panel.ipf:436`

### `popupmatcolor`

- Summary: `popupmatcolor` calls `PopMenuProc_colormat`. Panel popup-menu callback for linecut, slice, or region extraction; graph display, formatting, or window management.
- Control: `popupmatcolor` `PopupMenu`
- Action: `PopMenuProc_colormat`
- Source: `Kong_Igor_panel.ipf:457`

### `#`

- Summary: `#` is a static panel control. Static input/display control; no action procedure is attached.
- Control: `setvargrnum` `SetVariable`
- Action: ``
- Source: `Kong_Igor_panel.ipf:438`

### `Int. vs KE`

- Summary: `Int. vs KE` calls `ButtonProc_legend_int_vs_KE`. Panel button callback for graph display, formatting, or window management.
- Control: `buttonintke` `Button`
- Action: `ButtonProc_legend_int_vs_KE`
- Source: `Kong_Igor_panel.ipf:340`

### `Int. vs BE`

- Summary: `Int. vs BE` calls `ButtonProc_legend_int_vs_BE`. Peng Zhang curvature end
- Control: `buttonintbe` `Button`
- Action: `ButtonProc_legend_int_vs_BE`
- Source: `Kong_Igor_panel.ipf:338`

### `2nd derivative`

- Summary: `2nd derivative` calls `ButtonProc_derivmat`. Panel button callback for linecut, slice, or region extraction.
- Control: `button21` `Button`
- Action: `ButtonProc_derivmat` -> `derivmat()`
- Source: `Kong_Igor_panel.ipf:254`

### `File 2 wave`

- Summary: `File 2 wave` runs `file2wave()` through `ButtonProc_file2wave`. saves, exports, or converts data between files and Igor waves.
- Control: `button12` `Button`
- Action: `ButtonProc_file2wave` -> `file2wave()`
- Source: `Kong_Igor_panel.ipf:238`

### `Wave 2 file`

- Summary: `Wave 2 file` runs `wave2file()` through `ButtonProc_wave2file`. saves, exports, or converts data between files and Igor waves.
- Control: `button13` `Button`
- Action: `ButtonProc_wave2file` -> `wave2file()`
- Source: `Kong_Igor_panel.ipf:240`

### `0 to NaN`

- Summary: `0 to NaN` calls `ButtonProc_zeronan`. Panel button callback for linecut, slice, or region extraction.
- Control: `button2001` `Button`
- Action: `ButtonProc_zeronan` -> `ZeroNaN()`
- Source: `Kong_Igor_panel.ipf:278`

### `ackground remover`

- Summary: `ackground remover` runs `background_remover()` through `ButtonProc_openbkgndremover`. smooths, normalizes, or removes background/trend components.
- Control: `button58` `Button`
- Action: `ButtonProc_openbkgndremover` -> `background_remover()`
- Source: `Kong_Igor_panel.ipf:388`

### `Equivalent waves`

- Summary: `Equivalent waves` runs `transform2equiv_waves()` through `ButtonProc_trans2equiv_waves`. combines many waves/slices into a map, linecut, or averaged output.
- Control: `button59` `Button`
- Action: `ButtonProc_trans2equiv_waves` -> `transform2equiv_waves()`
- Source: `Kong_Igor_panel.ipf:390`

### `Cap#G*`

- Summary: `Cap#G*` runs `Capturename_child()` through `ButtonProc_Capturename_child`. copies, duplicates, or renames Igor waves/traces.
- Control: `buttoncg` `Button`
- Action: `ButtonProc_Capturename_child` -> `Capturename_child()`
- Source: `Kong_Igor_panel.ipf:982`

### `popuptest1`

- Summary: `popuptest1` calls `PopMenuProc_colormatmore2`. Panel popup-menu callback for linecut, slice, or region extraction; graph display, formatting, or window management.
- Control: `popuptest1` `PopupMenu`
- Action: `PopMenuProc_colormatmore2`
- Source: `Kong_Igor_panel.ipf:707`

### `FFT`

- Summary: `FFT` runs `colorFFT()` through `ButtonProc_colorFFT`. performs Fourier, filtering, phase, or lock-in processing.
- Control: `button96` `Button`
- Action: `ButtonProc_colorFFT` -> `colorFFT()`
- Source: `Kong_Igor_panel.ipf:698`

### `BE vs θ`

- Summary: `BE vs θ` calls `ButtonProc_legend_BE_vs_angle`. Panel button callback for graph display, formatting, or window management.
- Control: `buttonbeangle` `Button`
- Action: `ButtonProc_legend_BE_vs_angle`
- Source: `Kong_Igor_panel.ipf:342`

### `KE vs θ`

- Summary: `KE vs θ` calls `ButtonProc_legend_KE_vs_angle`. Panel button callback for graph display, formatting, or window management.
- Control: `buttonKEangle` `Button`
- Action: `ButtonProc_legend_KE_vs_angle`
- Source: `Kong_Igor_panel.ipf:344`

### `Rotate image`

- Summary: `Rotate image` runs `rot2d_pi()` through `ButtonProc_rot2d_pi`. applies geometric correction or extracts deformation/strain information.
- Control: `button23` `Button`
- Action: `ButtonProc_rot2d_pi` -> `rot2d_pi()`
- Source: `Kong_Igor_panel.ipf:258`

### `NaN to 0`

- Summary: `NaN to 0` calls `ButtonProc_nan0`. Panel button callback for linecut, slice, or region extraction.
- Control: `button20` `Button`
- Action: `ButtonProc_nan0` -> `Nan0()`
- Source: `Kong_Igor_panel.ipf:252`

### `Wave2file (no kill)`

- Summary: `Wave2file (no kill)` runs `wave2filenokill()` through `ButtonProc_wave2filenokill`. saves, exports, or converts data between files and Igor waves.
- Control: `button15` `Button`
- Action: `ButtonProc_wave2filenokill` -> `wave2filenokill()`
- Source: `Kong_Igor_panel.ipf:242`

### `E-Resolution`

- Summary: `E-Resolution` runs `findEres()` through `ButtonProc_findEres`. Interactive Igor procedure for ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management; Igor wave/matrix/cube data operation.
- Control: `button94` `Button`
- Action: `ButtonProc_findEres` -> `findEres()`
- Source: `Kong_Igor_panel.ipf:506`

### `topimagetop`

- Summary: `topimagetop` calls `SliderProc_topmax`. Panel callback/helper for linecut, slice, or region extraction; graph display, formatting, or window management.
- Control: `topimagetop` `Slider`
- Action: `SliderProc_topmax`
- Source: `Kong_Igor_panel.ipf:441`

### `BE vs Momentum (ώ/a)`

- Summary: `BE vs Momentum (ώ/a)` calls `ButtonProc_legendBEvsmompia`. Panel button callback for symmetry or reflection processing; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management.
- Control: `buttonBEvsmom_pi` `Button`
- Action: `ButtonProc_legendBEvsmompia`
- Source: `Kong_Igor_panel.ipf:346`

### `(mat)^n`

- Summary: `(mat)^n` runs `mat_n_pi()` through `ButtonProc_mat_n_pi`. Interactive Igor procedure for graph display, formatting, or window management; Igor wave/matrix/cube data operation.
- Control: `button19` `Button`
- Action: `ButtonProc_mat_n_pi` -> `mat_n_pi()`
- Source: `Kong_Igor_panel.ipf:250`

### `Ln(mat)`

- Summary: `Ln(mat)` runs `ln_mat_pi()` through `ButtonProc_ln_mat_pi`. Interactive Igor procedure for graph display, formatting, or window management; Igor wave/matrix/cube data operation.
- Control: `button18` `Button`
- Action: `ButtonProc_ln_mat_pi` -> `ln_mat_pi()`
- Source: `Kong_Igor_panel.ipf:248`

### `NaN0mat3d`

- Summary: `NaN0mat3d` runs `NaN0mat3d()` through `ButtonProc_NaN0mat3d`. Interactive Igor procedure for Igor wave/matrix/cube data operation.
- Control: `button43` `Button`
- Action: `ButtonProc_NaN0mat3d` -> `NaN0mat3d()`
- Source: `Kong_Igor_panel.ipf:294`

### `BE vs Momentum (√Ö)`

- Summary: `BE vs Momentum (√Ö)` calls `ButtonProc_legendBEvsmomang`. Panel button callback for ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management.
- Control: `buttonBEvsmom_pi1` `Button`
- Action: `ButtonProc_legendBEvsmomang`
- Source: `Kong_Igor_panel.ipf:349`

### `Norm matrix`

- Summary: `Norm matrix` runs `normcut()` through `ButtonProc_normcut`. smooths, normalizes, or removes background/trend components.
- Control: `button41` `Button`
- Action: `ButtonProc_normcut` -> `normcut()`
- Source: `Kong_Igor_panel.ipf:368`

### `Fermi P`

- Summary: `Fermi P` runs `get_fermi_profile()` through `ButtonProc_get_fermi_profile`. extracts values, metadata, cursor information, or derived waves.
- Control: `button42` `Button`
- Action: `ButtonProc_get_fermi_profile` -> `get_fermi_profile()`
- Source: `Kong_Igor_panel.ipf:370`

### `EDC`

- Summary: `EDC` runs `Remove_simplebgnd_edc()` through `ButtonProc_Rm_simplebgnd_edc`. removes waves/windows/data points or cleans intermediate state.
- Control: `but_rm_simpleedc` `Button`
- Action: `ButtonProc_Rm_simplebgnd_edc` -> `Remove_simplebgnd_edc()`
- Source: `Kong_Igor_panel.ipf:298`

### `Matrix`

- Summary: `Matrix` runs `Remove_simplebgnd_mat()` through `ButtonProc_Rm_simplebgnd_mat`. removes waves/windows/data points or cleans intermediate state.
- Control: `but_rm_mat` `Button`
- Action: `ButtonProc_Rm_simplebgnd_mat` -> `Remove_simplebgnd_mat()`
- Source: `Kong_Igor_panel.ipf:300`

### `popupthicks_inout`

- Summary: `popupthicks_inout` calls `PopMenuProc_6`. Panel popup-menu callback for graph display, formatting, or window management.
- Control: `popupthicks_inout` `PopupMenu`
- Action: `PopMenuProc_6`
- Source: `Kong_Igor_panel.ipf:356`

### `topimagebot`

- Summary: `topimagebot` calls `SliderProc_topmin`. Panel callback/helper for linecut, slice, or region extraction; graph display, formatting, or window management.
- Control: `topimagebot` `Slider`
- Action: `SliderProc_topmin`
- Source: `Kong_Igor_panel.ipf:444`

### `Divide by FD`

- Summary: `Divide by FD` runs `dividematrixbyfermi()` through `ButtonProc_dividematrixbyfermi`. displays waves, images, contours, or graph overlays.
- Control: `button50` `Button`
- Action: `ButtonProc_dividematrixbyfermi` -> `dividematrixbyfermi()`
- Source: `Kong_Igor_panel.ipf:378`

### `Keep +`

- Summary: `Keep +` runs `keep_positive()` through `ButtonProc_keep_positive`. Interactive Igor procedure for Igor wave/matrix/cube data operation.
- Control: `button51` `Button`
- Action: `ButtonProc_keep_positive` -> `keep_positive()`
- Source: `Kong_Igor_panel.ipf:380`

### `Keep -`

- Summary: `Keep -` runs `keep_negative()` through `ButtonProc_keep_negative`. Interactive Igor procedure for Igor wave/matrix/cube data operation.
- Control: `button52` `Button`
- Action: `ButtonProc_keep_negative` -> `keep_negative()`
- Source: `Kong_Igor_panel.ipf:382`

### `A axises`

- Summary: `A axises` calls `Button_set_auto_axis`. Panel callback/helper for graph display, formatting, or window management.
- Control: `button90` `Button`
- Action: `Button_set_auto_axis`
- Source: `Kong_Igor_panel.ipf:497`

### `mirror_onoff`

- Summary: `mirror_onoff` calls `PopMenuProc_mirroronoff`. applies symmetry, mirror, or reflection operations.
- Control: `mirror_onoff` `PopupMenu`
- Action: `PopMenuProc_mirroronoff`
- Source: `Kong_Igor_panel.ipf:354`


## Fix Data

### `Topo`

- Summary: `Topo` calls `ButtonProc_sizemapauto`. Panel button callback for matrix resampling, scaling, or reshaping; graph display, formatting, or window management.
- Control: `Map00` `Button`
- Action: `ButtonProc_sizemapauto`
- Source: `Kong_Igor_panel.ipf:887`

### `axis`

- Summary: `axis` runs `Drawarrowc()` through `ButtonProc_Drawarrowy`. Interactive Igor procedure for graph display, formatting, or window management.
- Control: `Symx33` `Button`
- Action: `ButtonProc_Drawarrowy` -> `Drawarrowc()`
- Source: `Kong_Igor_panel.ipf:996`

### `Pt`

- Summary: `Pt` runs `fix_map()` through `ButtonProc_fix_map`. Interactive Igor procedure in Miscellaneous_Codes.ipf.
- Control: `Symx02` `Button`
- Action: `ButtonProc_fix_map` -> `fix_map()`
- Source: `Kong_Igor_panel.ipf:713`

### `Copy TB`

- Summary: `Copy TB` runs `copy_circles_2f()` through `ButtonProc_copy_circles2f`. copies, duplicates, or renames Igor waves/traces.
- Control: `for_copy_TB2f` `Button`
- Action: `ButtonProc_copy_circles2f` -> `copy_circles_2f()`
- Source: `Kong_Igor_panel.ipf:362`

### `Plan`

- Summary: `Plan` calls `ButtonProc_sizecurveplan`. Panel button callback for symmetry or reflection processing; graph display, formatting, or window management.
- Control: `Map93` `Button`
- Action: `ButtonProc_sizecurveplan`
- Source: `Kong_Igor_panel.ipf:881`

### `Auto`

- Summary: `Auto` calls `ButtonProc_sizecurveauto`. Panel button callback for symmetry or reflection processing; graph display, formatting, or window management.
- Control: `Map94` `Button`
- Action: `ButtonProc_sizecurveauto`
- Source: `Kong_Igor_panel.ipf:883`

### `Rect`

- Summary: `Rect` calls `ButtonProc_sizecurverect`. Panel button callback for symmetry or reflection processing; graph display, formatting, or window management.
- Control: `Map95` `Button`
- Action: `ButtonProc_sizecurverect`
- Source: `Kong_Igor_panel.ipf:885`

### `Clean`

- Summary: `Clean` runs `exitkm()` through `ButtonProc_exitkm`. Interactive Igor procedure for Nanonis/STM data loading or map conversion.
- Control: `KMExist` `Button`
- Action: `ButtonProc_exitkm` -> `exitkm()`
- Source: `Kong_Igor_panel.ipf:663`

### `Jump1D`

- Summary: `Jump1D` runs `autoremovejump1Dc()` through `ButtonProc_dddautoremovejump1DC`. removes waves/windows/data points or cleans intermediate state.
- Control: `Symx07` `Button`
- Action: `ButtonProc_dddautoremovejump1DC` -> `autoremovejump1Dc()`
- Source: `Kong_Igor_panel.ipf:711`

### `Sgl.`

- Summary: `Sgl.` calls `ButtonProc_ddd`. Old Version
- Control: `Symx18` `Button`
- Action: `ButtonProc_ddd`
- Source: `Kong_Igor_panel.ipf:759`


## Matrix Engineer

### `Jump 2D`

- Summary: `Jump 2D` runs `cnfyjc()` through `ButtonProc_cnfyjc`. Interactive Igor procedure for FFT, QPI, phase, or lock-in analysis; geometric correction, rotation, shear, drift, or strain analysis; smoothing, normalization, or background removal.
- Control: `Symx08` `Button`
- Action: `ButtonProc_cnfyjc` -> `cnfyjc()`
- Source: `Kong_Igor_panel.ipf:715`

### `Line`

- Summary: `Line` runs `fixline()` through `ButtonProc_fixline`. Interactive Igor procedure in Miscellaneous_Codes.ipf.
- Control: `Symx04` `Button`
- Action: `ButtonProc_fixline` -> `fixline()`
- Source: `Kong_Igor_panel.ipf:717`

### `DeletePoints`

- Summary: `DeletePoints` runs `DeletePdata()` through `ButtonProc_deletepoint`. make specific dislay of the data.
- Control: `DeletePoints` `Button`
- Action: `ButtonProc_deletepoint` -> `DeletePdata()`
- Source: `Kong_Igor_panel.ipf:889`

### `Auto / Linecut`

- Summary: `Auto / Linecut` runs `AutoNanislinecut()` through `ButtonProc_AutoNanislinecut`. Interactive Igor procedure for Nanonis/STM data loading or map conversion; FFT, QPI, phase, or lock-in analysis; linecut, slice, or region extraction.
- Control: `KMExist1` `Button`
- Action: `ButtonProc_AutoNanislinecut` -> `AutoNanislinecut()`
- Source: `Kong_Igor_panel.ipf:831`

### `Topo`

- Summary: `Topo` runs `ExtacttopoafterKM()` through `ButtonProc_autotopo`. Interactive Igor procedure for Nanonis/STM data loading or map conversion; linecut, slice, or region extraction; Igor wave/matrix/cube data operation.
- Control: `KMExist4` `Button`
- Action: `ButtonProc_autotopo` -> `ExtacttopoafterKM()`
- Source: `Kong_Igor_panel.ipf:833`

### `Auto / GridMp`

- Summary: `Auto / GridMp` runs `autoloadgrid()` through `ButtonProc_autoloadgrid`. loads data or launches an automatic loading workflow.
- Control: `KMExist2` `Button`
- Action: `ButtonProc_autoloadgrid` -> `autoloadgrid()`
- Source: `Kong_Igor_panel.ipf:819`

### `Fix Gate Leak`

- Summary: `Fix Gate Leak` runs `correct2Dmapc()` through `ButtonProc_correct2Dmapc`. Interactive Igor procedure for Nanonis/STM data loading or map conversion; linecut, slice, or region extraction; graph display, formatting, or window management.
- Control: `Symx10` `Button`
- Action: `ButtonProc_correct2Dmapc` -> `correct2Dmapc()`
- Source: `Kong_Igor_panel.ipf:719`

### `k-`

- Summary: `k-` runs `cutksmall()` through `ButtonProc_cutksmall`. Interactive Igor procedure for linecut, slice, or region extraction.
- Control: `DeletePoints1` `Button`
- Action: `ButtonProc_cutksmall` -> `cutksmall()`
- Source: `Kong_Igor_panel.ipf:895`

### `k+`

- Summary: `k+` runs `cutklarge()` through `ButtonProc_cutklarge`. Interactive Igor procedure for linecut, slice, or region extraction.
- Control: `DeletePoints2` `Button`
- Action: `ButtonProc_cutklarge` -> `cutklarge()`
- Source: `Kong_Igor_panel.ipf:897`

### `E-`

- Summary: `E-` runs `cutEsmall()` through `ButtonProc_cutEsmall`. Interactive Igor procedure for linecut, slice, or region extraction.
- Control: `DeletePoints3` `Button`
- Action: `ButtonProc_cutEsmall` -> `cutEsmall()`
- Source: `Kong_Igor_panel.ipf:899`

### `E+`

- Summary: `E+` runs `cutElarge()` through `ButtonProc_cutElarge`. Interactive Igor procedure for linecut, slice, or region extraction.
- Control: `DeletePoints4` `Button`
- Action: `ButtonProc_cutElarge` -> `cutElarge()`
- Source: `Kong_Igor_panel.ipf:901`

### `ZR / ho`

- Summary: `ZR / ho` runs `Z_R_Rhomapc()` through `ButtonProc_Z_R_Rhomapc`. Interactive Igor procedure for Nanonis/STM data loading or map conversion; linecut, slice, or region extraction; Igor wave/matrix/cube data operation.
- Control: `KMExist5` `Button`
- Action: `ButtonProc_Z_R_Rhomapc` -> `Z_R_Rhomapc()`
- Source: `Kong_Igor_panel.ipf:835`

### `Rmv. Fig Trend`

- Summary: `Rmv. Fig Trend` runs `Conslevel()` through `ButtonProc_Conslevel`. Interactive Igor procedure for graph display, formatting, or window management; Igor wave/matrix/cube data operation.
- Control: `Symx11` `Button`
- Action: `ButtonProc_Conslevel` -> `Conslevel()`
- Source: `Kong_Igor_panel.ipf:723`

### `Reflection`

- Summary: `Reflection` runs `Rflwaves()` through `ButtonProc_Rflwaves`. combines many waves/slices into a map, linecut, or averaged output.
- Control: `Symx7` `Button`
- Action: `ButtonProc_Rflwaves` -> `Rflwaves()`
- Source: `Kong_Igor_panel.ipf:893`

### `Slope`

- Summary: `Slope` runs `slopedata()` through `ButtonProc_slopedata`. Interactive Igor procedure for Nanonis/STM data loading or map conversion; graph display, formatting, or window management.
- Control: `Map56` `Button`
- Action: `ButtonProc_slopedata` -> `slopedata()`
- Source: `Kong_Igor_panel.ipf:905`

### `all`

- Summary: `all` runs `slopeall()` through `ButtonProc_slopedataall`. Interactive Igor procedure in Miscellaneous_Codes.ipf.
- Control: `Map65` `Button`
- Action: `ButtonProc_slopedataall` -> `slopeall()`
- Source: `Kong_Igor_panel.ipf:919`

### `Pad 2D`

- Summary: `Pad 2D` runs `padmc()` through `ButtonProc_padmc`. resamples, rescales, pads, or changes wave dimensions.
- Control: `Pad2D` `Button`
- Action: `ButtonProc_padmc` -> `padmc()`
- Source: `Kong_Igor_panel.ipf:927`

### `1D`

- Summary: `1D` runs `extending1D()` through `ButtonProc_extending1D`. displays waves, images, contours, or graph overlays.
- Control: `PAD_1D` `Button`
- Action: `ButtonProc_extending1D` -> `extending1D()`
- Source: `Kong_Igor_panel.ipf:903`

### `Shear`

- Summary: `Shear` runs `rotatedshearc()` through `ButtonProc_rotatedshearc`. applies geometric correction or extracts deformation/strain information.
- Control: `Map87` `Button`
- Action: `ButtonProc_rotatedshearc` -> `rotatedshearc()`
- Source: `Kong_Igor_panel.ipf:931`

### `Demo`

- Summary: `Demo` runs `Demo_rotatedshear()` through `ButtonProc_rotatedsheard`. applies geometric correction or extracts deformation/strain information.
- Control: `Map86` `Button`
- Action: `ButtonProc_rotatedsheard` -> `Demo_rotatedshear()`
- Source: `Kong_Igor_panel.ipf:929`

### `Cmplx2Rl`

- Summary: `Cmplx2Rl` runs `Complextoreal()` through `ButtonProc_Complextoreal`. Interactive Igor procedure for FFT, QPI, phase, or lock-in analysis; graph display, formatting, or window management; Igor wave/matrix/cube data operation.
- Control: `Map41` `Button`
- Action: `ButtonProc_Complextoreal` -> `Complextoreal()`
- Source: `Kong_Igor_panel.ipf:911`

### `σ`

- Summary: `σ` runs `coloarrangec()` through `SetVarProc_changeds`. Interactive Igor procedure for linecut, slice, or region extraction; graph display, formatting, or window management; Igor wave/matrix/cube data operation.
- Control: `setvargrnum1` `SetVariable`
- Action: `SetVarProc_changeds` -> `coloarrangec()`
- Source: `Kong_Igor_panel.ipf:700`

### `dvg_bwr_20_95_c54`

- Summary: `dvg_bwr_20_95_c54` calls `SetVarProc_colormatmorevv`. Panel set-variable callback for graph display, formatting, or window management.
- Control: `setvarsetciu` `SetVariable`
- Action: `SetVarProc_colormatmorevv`
- Source: `Kong_Igor_panel.ipf:735`

### `?`

- Summary: `?` runs `Help_tab_Misc()` through `Button_Help_tab_Misc`. Igor window/panel recreation routine for geometric correction, rotation, shear, drift, or strain analysis; smoothing, normalization, or background removal; graph display, formatting, or window management.
- Control: `buttonhelptools4` `Button`
- Action: `Button_Help_tab_Misc` -> `Help_tab_Misc()`
- Source: `Kong_Igor_panel.ipf:401`

### `Sm_BS`

- Summary: `Sm_BS` runs `SmoothMat_k23()` through `ButtonProc_SmoothMat_k23`. smooths, normalizes, or removes background/trend components.
- Control: `button53` `Button`
- Action: `ButtonProc_SmoothMat_k23` -> `SmoothMat_k23()`
- Source: `Kong_Igor_panel.ipf:555`

### `Cb all`

- Summary: `Cb all` runs `combineall()` through `ButtonProc_combineall`. combines many waves/slices into a map, linecut, or averaged output.
- Control: `button8` `Button`
- Action: `ButtonProc_combineall` -> `combineall()`
- Source: `Kong_Igor_panel.ipf:236`

### `Equiv. mat`

- Summary: `Equiv. mat` runs `transform2equiv_mat()` through `ButtonProc_trans2equiv_mat`. Interactive Igor procedure for Igor wave/matrix/cube data operation.
- Control: `button4` `Button`
- Action: `ButtonProc_trans2equiv_mat` -> `transform2equiv_mat()`
- Source: `Kong_Igor_panel.ipf:404`

### `?`

- Summary: `?` runs `Help_tab_matrices()` through `Button_Help_tab_matrices`. Igor window/panel recreation routine for symmetry or reflection processing; geometric correction, rotation, shear, drift, or strain analysis; smoothing, normalization, or background removal.
- Control: `buttonhelptools1` `Button`
- Action: `Button_Help_tab_matrices` -> `Help_tab_matrices()`
- Source: `Kong_Igor_panel.ipf:395`

### `?`

- Summary: `?` runs `help_tab_traces()` through `Button_help_tab_traces`. Igor window/panel recreation routine for symmetry or reflection processing; geometric correction, rotation, shear, drift, or strain analysis; smoothing, normalization, or background removal.
- Control: `buttonhelptools2` `Button`
- Action: `Button_help_tab_traces` -> `help_tab_traces()`
- Source: `Kong_Igor_panel.ipf:398`

### `Rotate`

- Summary: `Rotate` runs `rot_vector()` through `ButtonProc_rot_vector`. applies geometric correction or extracts deformation/strain information.
- Control: `button47` `Button`
- Action: `ButtonProc_rot_vector` -> `rot_vector()`
- Source: `Kong_Igor_panel.ipf:372`

### `Divide by FD`

- Summary: `Divide by FD` runs `dividewavebyfermi()` through `ButtonProc_dividewavebyfermi`. displays waves, images, contours, or graph overlays.
- Control: `button49` `Button`
- Action: `ButtonProc_dividewavebyfermi` -> `dividewavebyfermi()`
- Source: `Kong_Igor_panel.ipf:376`

### `Interp NxN`

- Summary: `Interp NxN` runs `twoDinterpolatexy()` through `ButtonProc_twoDinterpolatel`. displays waves, images, contours, or graph overlays.
- Control: `Map40` `Button`
- Action: `ButtonProc_twoDinterpolatel` -> `twoDinterpolatexy()`
- Source: `Kong_Igor_panel.ipf:909`

### `all`

- Summary: `all` runs `interp2Dall()` through `ButtonProc_twoDlinterp2Dall`. resamples, rescales, pads, or changes wave dimensions.
- Control: `Map68` `Button`
- Action: `ButtonProc_twoDlinterp2Dall` -> `interp2Dall()`
- Source: `Kong_Igor_panel.ipf:921`

### `Y`

- Summary: `Y` runs `twoDinterpy()` through `ButtonProc_twoDinterpy`. displays waves, images, contours, or graph overlays.
- Control: `Map53` `Button`
- Action: `ButtonProc_twoDinterpy` -> `twoDinterpy()`
- Source: `Kong_Igor_panel.ipf:913`

### `popupinvmatcolor`

- Summary: `popupinvmatcolor` calls `PopMenuProc_colormatinv`. Panel popup-menu callback for linecut, slice, or region extraction; matrix resampling, scaling, or reshaping; graph display, formatting, or window management.
- Control: `popupinvmatcolor` `PopupMenu`
- Action: `PopMenuProc_colormatinv`
- Source: `Kong_Igor_panel.ipf:459`

### `Color`

- Summary: `Color` runs `color_edc()` through `ButtonProc_color_edc`. Interactive Igor procedure for matrix resampling, scaling, or reshaping; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management.
- Control: `coloredcnow` `Button`
- Action: `ButtonProc_color_edc` -> `color_edc()`
- Source: `Kong_Igor_panel.ipf:329`

### `edccolorset`

- Summary: `edccolorset` calls `PopMenuProc_1`. Panel popup-menu callback for ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management.
- Control: `edccolorset` `PopupMenu`
- Action: `PopMenuProc_1`
- Source: `Kong_Igor_panel.ipf:333`

### `Give area`

- Summary: `Give area` runs `give_area()` through `ButtonProc_give_area`. Interactive Igor procedure for Nanonis/STM data loading or map conversion; smoothing, normalization, or background removal; lattice, moire, or twist-angle simulation/analysis.
- Control: `button37` `Button`
- Action: `ButtonProc_give_area` -> `give_area()`
- Source: `Kong_Igor_panel.ipf:286`

### `V-`

- Summary: `V-` runs `finddispersion_min()` through `ButtonProc_finddispersion_min`. displays waves, images, contours, or graph overlays.
- Control: `button38` `Button`
- Action: `ButtonProc_finddispersion_min` -> `finddispersion_min()`
- Source: `Kong_Igor_panel.ipf:288`

### `H-`

- Summary: `H-` runs `finddispersionHD_min()` through `ButtonProc_finddispersionHD_min`. displays waves, images, contours, or graph overlays.
- Control: `button39` `Button`
- Action: `ButtonProc_finddispersionHD_min` -> `finddispersionHD_min()`
- Source: `Kong_Igor_panel.ipf:290`

### `V+`

- Summary: `V+` runs `finddispersion_plus()` through `ButtonProc_finddispersion_plus`. displays waves, images, contours, or graph overlays.
- Control: `button55` `Button`
- Action: `ButtonProc_finddispersion_plus` -> `finddispersion_plus()`
- Source: `Kong_Igor_panel.ipf:384`

### `H+`

- Summary: `H+` runs `finddispersionHD_plus()` through `ButtonProc_finddispersionHDplus`. displays waves, images, contours, or graph overlays.
- Control: `button56` `Button`
- Action: `ButtonProc_finddispersionHDplus` -> `finddispersionHD_plus()`
- Source: `Kong_Igor_panel.ipf:386`

### `UnevenY`

- Summary: `UnevenY` runs `rescalemapasa1dcurve()` through `ButtonProc_rescalemapasa1dcurve`. resamples, rescales, pads, or changes wave dimensions.
- Control: `Map64` `Button`
- Action: `ButtonProc_rescalemapasa1dcurve` -> `rescalemapasa1dcurve()`
- Source: `Kong_Igor_panel.ipf:917`

### `Rot`

- Summary: `Rot` runs `Newrotateproc()` through `ButtonProc_Newrotateproc`. applies geometric correction or extracts deformation/strain information.
- Control: `Rotate2` `Button`
- Action: `ButtonProc_Newrotateproc` -> `Newrotateproc()`
- Source: `Kong_Igor_panel.ipf:925`

### `adj`

- Summary: `adj` runs `Controtate()` through `ButtonProc_Controtate`. applies geometric correction or extracts deformation/strain information.
- Control: `Rotate3` `Button`
- Action: `ButtonProc_Controtate` -> `Controtate()`
- Source: `Kong_Igor_panel.ipf:933`

### `Cb krange`

- Summary: `Cb krange` runs `comb_krange()` through `ButtonProc_comb_krange`. Interactive Igor procedure for matrix resampling, scaling, or reshaping; Igor wave/matrix/cube data operation.
- Control: `button7` `Button`
- Action: `ButtonProc_comb_krange` -> `comb_krange()`
- Source: `Kong_Igor_panel.ipf:234`

### `inversecoloredc`

- Summary: `inversecoloredc` calls `PopMenuProc_2`. Panel popup-menu callback for ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management.
- Control: `inversecoloredc` `PopupMenu`
- Action: `PopMenuProc_2`
- Source: `Kong_Igor_panel.ipf:331`

### `Cycle Color`

- Summary: `Cycle Color` runs `cyclecolorwavec()` through `ButtonProc_cyclecolorwavec`. combines many waves/slices into a map, linecut, or averaged output.
- Control: `b98` `Button`
- Action: `ButtonProc_cyclecolorwavec` -> `cyclecolorwavec()`
- Source: `Kong_Igor_panel.ipf:975`

### `Smooth`

- Summary: `Smooth` runs `SmoothMat_k23()` through `ButtonProc_SmoothMat_k23`. smooths, normalizes, or removes background/trend components.
- Control: `Map6` `Button`
- Action: `ButtonProc_SmoothMat_k23` -> `SmoothMat_k23()`
- Source: `Kong_Igor_panel.ipf:915`

### `Norm Matrix`

- Summary: `Norm Matrix` runs `Normalinecutc2()` through `ButtonProc_Normalinecut`. smooths, normalizes, or removes background/trend components.
- Control: `Symx14` `Button`
- Action: `ButtonProc_Normalinecut` -> `Normalinecutc2()`
- Source: `Kong_Igor_panel.ipf:941`

### `Color`

- Summary: `Color` runs `color_edc_more2()` through `ButtonProc_color_edc_more2`. Interactive Igor procedure for matrix resampling, scaling, or reshaping; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management.
- Control: `C` `Button`
- Action: `ButtonProc_color_edc_more2` -> `color_edc_more2()`
- Source: `Kong_Igor_panel.ipf:705`

### `popuptest`

- Summary: `popuptest` calls `PopMenuProc_more2`. end check if a wave on the graph
- Control: `popuptest` `PopupMenu`
- Action: `PopMenuProc_more2`
- Source: `Kong_Igor_panel.ipf:703`

### `New-stepsize`

- Summary: `New-stepsize` runs `new_stepsize()` through `ButtonProc_new_step`. Interactive Igor procedure for matrix resampling, scaling, or reshaping; Igor wave/matrix/cube data operation.
- Control: `button31` `Button`
- Action: `ButtonProc_new_step` -> `new_stepsize()`
- Source: `Kong_Igor_panel.ipf:276`

### `AVG_tool`

- Summary: `AVG_tool` runs `AVG_ini()` through `ButtonProcAVG_tool`. Interactive Igor procedure in Pierre's Template.ipf.
- Control: `button95` `Button`
- Action: `ButtonProcAVG_tool` -> `AVG_ini()`
- Source: `Kong_Igor_panel.ipf:509`

### `Bands table`

- Summary: `Bands table` runs `Point_reader()` through `ButtonProc_showpntreader`. extracts values, metadata, cursor information, or derived waves.
- Control: `button40` `Button`
- Action: `ButtonProc_showpntreader` -> `Point_reader()`
- Source: `Kong_Igor_panel.ipf:292`

### `Cb range`

- Summary: `Cb range` runs `combine_range()` through `ButtonProc_combine_range`. combines many waves/slices into a map, linecut, or averaged output.
- Control: `button6` `Button`
- Action: `ButtonProc_combine_range` -> `combine_range()`
- Source: `Kong_Igor_panel.ipf:232`

### `Symx`

- Summary: `Symx` runs `symbandsall()` through `ButtonProc_symbands`. applies symmetry, mirror, or reflection operations.
- Control: `Symx` `Button`
- Action: `ButtonProc_symbands` -> `symbandsall()`
- Source: `Kong_Igor_panel.ipf:891`

### `2to1`

- Summary: `2to1` runs `tdtodc()` through `ButtonProc_tdtodc`. Interactive Igor procedure for Igor wave/matrix/cube data operation.
- Control: `Map58` `Button`
- Action: `ButtonProc_tdtodc` -> `tdtodc()`
- Source: `Kong_Igor_panel.ipf:907`

### `Resl.`

- Summary: `Resl.` runs `rescale()` through `ButtonProc_rescale`. resamples, rescales, pads, or changes wave dimensions.
- Control: `Map05` `Button`
- Action: `ButtonProc_rescale` -> `rescale()`
- Source: `Kong_Igor_panel.ipf:923`

### `A`

- Summary: `A` calls `Button_image_auto_up`. Panel callback/helper for linecut, slice, or region extraction; graph display, formatting, or window management.
- Control: `button_a_up` `Button`
- Action: `Button_image_auto_up`
- Source: `Kong_Igor_panel.ipf:446`

### `0`

- Summary: `0` calls `Button_image_0_up`. Panel callback/helper for linecut, slice, or region extraction; graph display, formatting, or window management.
- Control: `button_0_up` `Button`
- Action: `Button_image_0_up`
- Source: `Kong_Igor_panel.ipf:450`

### `E-comb`

- Summary: `E-comb` runs `new_eres_pi()` through `ButtonProc_new_eres_pi`. Interactive Igor procedure for matrix resampling, scaling, or reshaping; Igor wave/matrix/cube data operation.
- Control: `button16` `Button`
- Action: `ButtonProc_new_eres_pi` -> `new_eres_pi()`
- Source: `Kong_Igor_panel.ipf:244`

### `M-comb`

- Summary: `M-comb` runs `new_kres_pi()` through `ButtonProc_new_kres_pi`. Interactive Igor procedure for matrix resampling, scaling, or reshaping; Igor wave/matrix/cube data operation.
- Control: `button17` `Button`
- Action: `ButtonProc_new_kres_pi` -> `new_kres_pi()`
- Source: `Kong_Igor_panel.ipf:246`

### `Partial by Marquee`

- Summary: `Partial by Marquee` runs `Frommarqueegetsubmatrixsc()` through `ButtonProc_Fmarqueegetsub`. Interactive Igor procedure for linecut, slice, or region extraction; Igor wave/matrix/cube data operation.
- Control: `Symx21` `Button`
- Action: `ButtonProc_Fmarqueegetsub` -> `Frommarqueegetsubmatrixsc()`
- Source: `Kong_Igor_panel.ipf:943`

### `Auto`

- Summary: `Auto` calls `Button_image_auto_both`. Panel callback/helper for linecut, slice, or region extraction; graph display, formatting, or window management.
- Control: `button_a_both` `Button`
- Action: `Button_image_auto_both`
- Source: `Kong_Igor_panel.ipf:454`

### `It3/1`

- Summary: `It3/1` runs `sumonedc()` through `ButtonProc_sumonedc`. combines many waves/slices into a map, linecut, or averaged output.
- Control: `Symx13` `Button`
- Action: `ButtonProc_sumonedc` -> `sumonedc()`
- Source: `Kong_Igor_panel.ipf:939`

### `It3/2`

- Summary: `It3/2` calls `ButtonProc_SumlayerFFT3Dc2`. performs Fourier, filtering, phase, or lock-in processing.
- Control: `Symx29` `Button`
- Action: `ButtonProc_SumlayerFFT3Dc2`
- Source: `Kong_Igor_panel.ipf:947`

### `It2/1`

- Summary: `It2/1` runs `sum2dlinecutc()` through `ButtonProc_sum2dlinecutc`. combines many waves/slices into a map, linecut, or averaged output.
- Control: `Symx27` `Button`
- Action: `ButtonProc_sum2dlinecutc` -> `sum2dlinecutc()`
- Source: `Kong_Igor_panel.ipf:945`

### `RGB2Int`

- Summary: `RGB2Int` runs `Intensity_digimage()` through `ButtonProc_RGBimagetoIntensity`. displays waves, images, contours, or graph overlays.
- Control: `button61` `Button`
- Action: `ButtonProc_RGBimagetoIntensity` -> `Intensity_digimage()`
- Source: `Kong_Igor_panel.ipf:410`

### `It3 to linecut`

- Summary: `It3 to linecut` runs `Gridtolinecutc()` through `ButtonProc_Gridtolinecutc`. Interactive Igor procedure for Nanonis/STM data loading or map conversion; linecut, slice, or region extraction; graph display, formatting, or window management.
- Control: `Symx36` `Button`
- Action: `ButtonProc_Gridtolinecutc` -> `Gridtolinecutc()`
- Source: `Kong_Igor_panel.ipf:1056`

### `A`

- Summary: `A` calls `Button_image_auto_down`. Panel callback/helper for linecut, slice, or region extraction; graph display, formatting, or window management.
- Control: `button_a_down` `Button`
- Action: `Button_image_auto_down`
- Source: `Kong_Igor_panel.ipf:448`

### `0`

- Summary: `0` calls `Button_image_0_down`. Panel callback/helper for linecut, slice, or region extraction; graph display, formatting, or window management.
- Control: `button_0_down` `Button`
- Action: `Button_image_0_down`
- Source: `Kong_Igor_panel.ipf:452`

### `EF line (EDC)`

- Summary: `EF line (EDC)` runs `put_fermi_edc()` through `ButtonProc_put_fermi_edc`. Interactive Igor procedure for ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management; Igor wave/matrix/cube data operation.
- Control: `buttonefedc` `Button`
- Action: `ButtonProc_put_fermi_edc` -> `put_fermi_edc()`
- Source: `Kong_Igor_panel.ipf:325`

### `ConstOff`

- Summary: `ConstOff` calls `ButtonProc_ConstOffset`. Panel button callback for linecut, slice, or region extraction.
- Control: `button14` `Button`
- Action: `ButtonProc_ConstOffset` -> `constantoffset_n()`
- Source: `Kong_Igor_panel.ipf:224`

### `ShiftNsym`

- Summary: `ShiftNsym` runs `Shift_and_sym_edc_matrix_far()` through `ButtonProc_shiftNsym`. applies symmetry, mirror, or reflection operations.
- Control: `button72` `Button`
- Action: `ButtonProc_shiftNsym` -> `Shift_and_sym_edc_matrix_far()`
- Source: `Kong_Igor_panel.ipf:432`

### `CoarseM`

- Summary: `CoarseM` runs `shrinkmatrixbystepsc()` through `ButtonProc_shrinkmatrixbysteps`. Interactive Igor procedure for graph display, formatting, or window management; Igor wave/matrix/cube data operation.
- Control: `Symx32` `Button`
- Action: `ButtonProc_shrinkmatrixbysteps` -> `shrinkmatrixbystepsc()`
- Source: `Kong_Igor_panel.ipf:973`

### `EDC`

- Summary: `EDC` runs `sEDC()` through `ButtonProc_sEDC`. Interactive Igor procedure for linecut, slice, or region extraction; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management.
- Control: `Symx05` `Button`
- Action: `ButtonProc_sEDC` -> `sEDC()`
- Source: `Kong_Igor_panel.ipf:935`

### `MDC`

- Summary: `MDC` runs `sMDC()` through `ButtonProc_sMDC`. Interactive Igor procedure for linecut, slice, or region extraction; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management.
- Control: `Symx09` `Button`
- Action: `ButtonProc_sMDC` -> `sMDC()`
- Source: `Kong_Igor_panel.ipf:937`


## General / nearby controls

### `SpectrumBlack`

- Summary: `SpectrumBlack` runs `colormatmorevvline()` through `SetVarProc_colormatmorevvline`. Function for matrix resampling, scaling, or reshaping; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management.
- Control: `setvarsetciu1` `SetVariable`
- Action: `SetVarProc_colormatmorevvline` -> `colormatmorevvline()`
- Source: `Kong_Igor_panel.ipf:739`

### `CutNaNedges`

- Summary: `CutNaNedges` runs `CutNaNedges()` through `ButtonProcCutNaNedges`. Begining of Pierre's macros Usage: run from Igor with parameters matname.
- Control: `button89` `Button`
- Action: `ButtonProcCutNaNedges` -> `CutNaNedges()`
- Source: `Kong_Igor_panel.ipf:495`

### `Fix FP 1`

- Summary: `Fix FP 1` runs `adjust_to_fp()` through `Button_adjust_to_fp`. Interactive Igor procedure for matrix resampling, scaling, or reshaping; ARPES-style loading, plotting, or momentum conversion; Igor wave/matrix/cube data operation.
- Control: `button91` `Button`
- Action: `Button_adjust_to_fp` -> `adjust_to_fp()`
- Source: `Kong_Igor_panel.ipf:499`

### `All`

- Summary: `All` runs `adjust_all_to_fp()` through `Button_adjust_all_to_fp`. Interactive Igor procedure for ARPES-style loading, plotting, or momentum conversion.
- Control: `button92` `Button`
- Action: `Button_adjust_all_to_fp` -> `adjust_all_to_fp()`
- Source: `Kong_Igor_panel.ipf:501`

### `Flip`

- Summary: `Flip` runs `Flip_digimage()` through `ButtonProc_FlipRGBimage`. displays waves, images, contours, or graph overlays.
- Control: `button10` `Button`
- Action: `ButtonProc_FlipRGBimage` -> `Flip_digimage()`
- Source: `Kong_Igor_panel.ipf:406`

### `Image2RGB`

- Summary: `Image2RGB` runs `color_digimage()` through `ButtonProc_RGBimagetoRGB`. displays waves, images, contours, or graph overlays.
- Control: `button60` `Button`
- Action: `ButtonProc_RGBimagetoRGB` -> `color_digimage()`
- Source: `Kong_Igor_panel.ipf:408`

### `EF line (image)`

- Summary: `EF line (image)` runs `put_fermi_image()` through `ButtonProc_put_fermi_image`. Interactive Igor procedure for matrix resampling, scaling, or reshaping; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management.
- Control: `buttonEFimage` `Button`
- Action: `ButtonProc_put_fermi_image` -> `put_fermi_image()`
- Source: `Kong_Igor_panel.ipf:327`

### `Symetrize EDC mat`

- Summary: `Symetrize EDC mat` runs `sym_edc_matrix_far()` through `ButtonProc_sym_edc_matrix`. applies symmetry, mirror, or reflection operations.
- Control: `button48` `Button`
- Action: `ButtonProc_sym_edc_matrix` -> `sym_edc_matrix_far()`
- Source: `Kong_Igor_panel.ipf:374`

### `Extract Image Data From Paper`

- Summary: `Extract Image Data From Paper` runs `Intensity_digimage2()` through `ButtonProc_RGBimagetoIntensity2`. displays waves, images, contours, or graph overlays.
- Control: `button73` `Button`
- Action: `ButtonProc_RGBimagetoIntensity2` -> `Intensity_digimage2()`
- Source: `Kong_Igor_panel.ipf:743`


## Complex Fit

### `FFT`

- Summary: `FFT` runs `FFTrc()` through `ButtonProc_FFTr`. performs Fourier, filtering, phase, or lock-in processing.
- Control: `Line2D3` `Button`
- Action: `ButtonProc_FFTr` -> `FFTrc()`
- Source: `Kong_Igor_panel.ipf:686`

### `Reader_Mpk2.0`

- Summary: `Reader_Mpk2.0` runs `savefitdata()` through `ButtonProc_savefitdata`. saves, exports, or converts data between files and Igor waves.
- Control: `Map12` `Button`
- Action: `ButtonProc_savefitdata` -> `savefitdata()`
- Source: `Kong_Igor_panel.ipf:605`

### `BCS_Dyne Fit`

- Summary: `BCS_Dyne Fit` runs `STSFiTDyne()` through `ButtonProc_DyneFit`. fits or extracts spectral/peak parameters.
- Control: `Normline2p1` `Button`
- Action: `ButtonProc_DyneFit` -> `STSFiTDyne()`
- Source: `Kong_Igor_panel.ipf:639`

### `SC-SC Fit`

- Summary: `SC-SC Fit` runs `STSFiTDyneS()` through `ButtonProc_DyneFitS`. fits or extracts spectral/peak parameters.
- Control: `Normline2p2` `Button`
- Action: `ButtonProc_DyneFitS` -> `STSFiTDyneS()`
- Source: `Kong_Igor_panel.ipf:643`


## Load individual STS

### `Intra`

- Summary: `Intra` runs `interpavedata()` through `ButtonProc_interpavedata`. resamples, rescales, pads, or changes wave dimensions.
- Control: `Symx9` `Button`
- Action: `ButtonProc_interpavedata` -> `interpavedata()`
- Source: `Kong_Igor_panel.ipf:611`

### `Ld_Nnis`

- Summary: `Ld_Nnis` calls `ButtonProc_Loadnewmk`. End of the GUI demo procedure Purpose: loads data or launches an automatic loading workflow.
- Control: `Symx0` `Button`
- Action: `ButtonProc_Loadnewmk` -> `Makegraphtable()`
- Source: `Kong_Igor_panel.ipf:627`

### `AverSlice (R9)`

- Summary: `AverSlice (R9)` runs `addper()` through `ButtonProc_addper`. Interactive Igor procedure in Miscellaneous_Codes.ipf.
- Control: `Map30` `Button`
- Action: `ButtonProc_addper` -> `addper()`
- Source: `Kong_Igor_panel.ipf:631`


## Normalization

### `ExSTS`

- Summary: `ExSTS` runs `extractdatafromdos()` through `ButtonProc_extractfromdos`. extracts values, metadata, cursor information, or derived waves.
- Control: `Symx2` `Button`
- Action: `ButtonProc_extractfromdos` -> `extractdatafromdos()`
- Source: `Kong_Igor_panel.ipf:575`

### `LnNorm FitAll`

- Summary: `LnNorm FitAll` runs `normstsline()` through `ButtonProc_Linenorm`. smooths, normalizes, or removes background/trend components.
- Control: `Map1` `Button`
- Action: `ButtonProc_Linenorm` -> `normstsline()`
- Source: `Kong_Igor_panel.ipf:579`

### `Ave`

- Summary: `Ave` calls `ButtonProc_Loadnewmkfab`. loads data or launches an automatic loading workflow.
- Control: `Symx06` `Button`
- Action: `ButtonProc_Loadnewmkfab` -> `Makegraphtable()`
- Source: `Kong_Igor_panel.ipf:647`

### `P`

- Summary: `P` runs `dataplotersts()` through `ButtonProc_dataplotersts`. displays waves, images, contours, or graph overlays.
- Control: `Symx01` `Button`
- Action: `ButtonProc_dataplotersts` -> `dataplotersts()`
- Source: `Kong_Igor_panel.ipf:629`

### `Old LnNorm2P`

- Summary: `Old LnNorm2P` runs `linenorm2p()` through `ButtonProc_line2p`. smooths, normalizes, or removes background/trend components.
- Control: `Normline2p` `Button`
- Action: `ButtonProc_line2p` -> `linenorm2p()`
- Source: `Kong_Igor_panel.ipf:581`

### `A`

- Summary: `A` runs `autodisplay()` through `ButtonProc_autodisplay`. displays waves, images, contours, or graph overlays.
- Control: `Symx03` `Button`
- Action: `ButtonProc_autodisplay` -> `autodisplay()`
- Source: `Kong_Igor_panel.ipf:641`

### `LnBkg (frm graph)`

- Summary: `LnBkg (frm graph)` runs `linenorm2pongraphc()` through `ButtonProc_linenorm2pongraphc`. smooths, normalizes, or removes background/trend components.
- Control: `Normline2p4` `Button`
- Action: `ButtonProc_linenorm2pongraphc` -> `linenorm2pongraphc()`
- Source: `Kong_Igor_panel.ipf:721`


## Matrix Operation (Old)

### `Rename`

- Summary: `Rename` runs `renameall()` through `ButtonProc_renameall`. copies, duplicates, or renames Igor waves/traces.
- Control: `Map15` `Button`
- Action: `ButtonProc_renameall` -> `renameall()`
- Source: `Kong_Igor_panel.ipf:609`

### `Partial`

- Summary: `Partial` runs `renamep()` through `ButtonProc_renamep`. copies, duplicates, or renames Igor waves/traces.
- Control: `Map37` `Button`
- Action: `ButtonProc_renamep` -> `renamep()`
- Source: `Kong_Igor_panel.ipf:645`

### `all`

- Summary: `all` runs `selectlinenorm()` through `ButtonProc_selectlinenorm`. smooths, normalizes, or removes background/trend components.
- Control: `Map03` `Button`
- Action: `ButtonProc_selectlinenorm` -> `selectlinenorm()`
- Source: `Kong_Igor_panel.ipf:593`

### `Interpolate All`

- Summary: `Interpolate All` runs `intercurve()` through `ButtonProc_Interpoint`. Interactive Igor procedure for Nanonis/STM data loading or map conversion; matrix resampling, scaling, or reshaping; graph display, formatting, or window management.
- Control: `Map7` `Button`
- Action: `ButtonProc_Interpoint` -> `intercurve()`
- Source: `Kong_Igor_panel.ipf:585`

### `Dup All`

- Summary: `Dup All` runs `duplicateall()` through `ButtonProc_duplicateall`. copies, duplicates, or renames Igor waves/traces.
- Control: `Map9` `Button`
- Action: `ButtonProc_duplicateall` -> `duplicateall()`
- Source: `Kong_Igor_panel.ipf:589`

### `x1~x2`

- Summary: `x1~x2` runs `duplicatpart()` through `ButtonProc_duplicatepart`. Interactive Igor procedure for linecut, slice, or region extraction; smoothing, normalization, or background removal; Igor wave/matrix/cube data operation.
- Control: `Map4` `Button`
- Action: `ButtonProc_duplicatepart` -> `duplicatpart()`
- Source: `Kong_Igor_panel.ipf:649`

### `Smt All`

- Summary: `Smt All` runs `smoothall()` through `ButtonProc_smoothall`. smooths, normalizes, or removes background/trend components.
- Control: `Map0` `Button`
- Action: `ButtonProc_smoothall` -> `smoothall()`
- Source: `Kong_Igor_panel.ipf:653`


## FFT Smart

### `Line@2D(2)`

- Summary: `Line@2D(2)` runs `FFTL2c()` through `ButtonProc_linecutFFT`. performs Fourier, filtering, phase, or lock-in processing.
- Control: `Line2D2` `Button`
- Action: `ButtonProc_linecutFFT` -> `FFTL2c()`
- Source: `Kong_Igor_panel.ipf:682`

### `(1)`

- Summary: `(1)` runs `linecutFFT()` through `ButtonProc_linecutFFT2`. performs Fourier, filtering, phase, or lock-in processing.
- Control: `Rotate4` `Button`
- Action: `ButtonProc_linecutFFT2` -> `linecutFFT()`
- Source: `Kong_Igor_panel.ipf:684`

### `Q`

- Summary: `Q` runs `peakIndi()` through `ButtonProc_peakIndi`. fits or extracts spectral/peak parameters.
- Control: `Symx35` `Button`
- Action: `ButtonProc_peakIndi` -> `peakIndi()`
- Source: `Kong_Igor_panel.ipf:1000`


## FFT Engineer

### `Launch`

- Summary: `Launch` runs `ffc()` through `ButtonProc_ffc`. Interactive Igor procedure for FFT, QPI, phase, or lock-in analysis; linecut, slice, or region extraction; matrix resampling, scaling, or reshaping.
- Control: `Map78` `Button`
- Action: `ButtonProc_ffc` -> `ffc()`
- Source: `Kong_Igor_panel.ipf:690`

### `getA`

- Summary: `getA` runs `gpac()` through `ButtonProc_GPAc`. Interactive Igor procedure for FFT, QPI, phase, or lock-in analysis; graph display, formatting, or window management; Igor wave/matrix/cube data operation.
- Control: `Map79` `Button`
- Action: `ButtonProc_GPAc` -> `gpac()`
- Source: `Kong_Igor_panel.ipf:692`

### `(2D)`

- Summary: `(2D)` runs `smoothallmatrix()` through `ButtonProc_smoothallmatrix`. smooths, normalizes, or removes background/trend components.
- Control: `Map45` `Button`
- Action: `ButtonProc_smoothallmatrix` -> `smoothallmatrix()`
- Source: `Kong_Igor_panel.ipf:688`

### `dI/dV(E,x,y)`

- Summary: `dI/dV(E,x,y)` runs `mapforSTMf()` through `ButtonProc_IExyf`. Interactive Igor procedure for linecut, slice, or region extraction; geometric correction, rotation, shear, drift, or strain analysis; smoothing, normalization, or background removal.
- Control: `Map22` `Button`
- Action: `ButtonProc_IExyf` -> `mapforSTMf()`
- Source: `Kong_Igor_panel.ipf:619`

### `getB`

- Summary: `getB` runs `gpbc()` through `ButtonProc_GpBc`. Interactive Igor procedure for FFT, QPI, phase, or lock-in analysis; graph display, formatting, or window management; Igor wave/matrix/cube data operation.
- Control: `Map80` `Button`
- Action: `ButtonProc_GpBc` -> `gpbc()`
- Source: `Kong_Igor_panel.ipf:694`


## Basic Display

### `NumNorm_SR`

- Summary: `NumNorm_SR` runs `normrange()` through `ButtonProc_normwavemulti`. smooths, normalizes, or removes background/trend components.
- Control: `Map5` `Button`
- Action: `ButtonProc_normwavemulti` -> `normrange()`
- Source: `Kong_Igor_panel.ipf:583`

### `Display Waterfall`

- Summary: `Display Waterfall` runs `displaymulti()` through `ButtonProc_displaymulti`. displays waves, images, contours, or graph overlays.
- Control: `Symx1` `Button`
- Action: `ButtonProc_displaymulti` -> `displaymulti()`
- Source: `Kong_Igor_panel.ipf:573`

### `NormNum_TR`

- Summary: `NormNum_TR` runs `normrange2()` through `ButtonProc_normwavemulti2`. smooths, normalizes, or removes background/trend components.
- Control: `Map10` `Button`
- Action: `ButtonProc_normwavemulti2` -> `normrange2()`
- Source: `Kong_Igor_panel.ipf:601`

### `Linecut`

- Summary: `Linecut` runs `linkstsmap_P()` through `ButtonProc_map`. i+=1 while(i<num) setscale/P x, dimoffset(sts1,0),dimdelta(sts1,0),""mapsts end Purpose: combines many waves/slices into a map, linecut, or averaged output.
- Control: `SMap` `Button`
- Action: `ButtonProc_map` -> `linkstsmap_P()`
- Source: `Kong_Igor_panel.ipf:674`

### `Lc1`

- Summary: `Lc1` runs `linkstsmap_Paa()` through `ButtonProc_mapaa`. combines many waves/slices into a map, linecut, or averaged output.
- Control: `SMap1` `Button`
- Action: `ButtonProc_mapaa` -> `linkstsmap_Paa()`
- Source: `Kong_Igor_panel.ipf:676`

### `2`

- Summary: `2` runs `linkstsmap_Paa2()` through `ButtonProc_mapaa2`. combines many waves/slices into a map, linecut, or averaged output.
- Control: `SMap2` `Button`
- Action: `ButtonProc_mapaa2` -> `linkstsmap_Paa2()`
- Source: `Kong_Igor_panel.ipf:680`

### `InterpL`

- Summary: `InterpL` runs `interpsts()` through `ButtonProc_InterpSTS`. resamples, rescales, pads, or changes wave dimensions.
- Control: `Map3` `Button`
- Action: `ButtonProc_InterpSTS` -> `interpsts()`
- Source: `Kong_Igor_panel.ipf:678`


## Cube

### `Area All`

- Summary: `Area All` calls `ButtonProc_Areacurve`. Panel button callback for linecut, slice, or region extraction.
- Control: `Map01` `Button`
- Action: `ButtonProc_Areacurve` -> `Areacurve()`
- Source: `Kong_Igor_panel.ipf:595`

### `Rsclall`

- Summary: `Rsclall` runs `rescaleallpr()` through `ButtonProc_rescaleallpr`. resamples, rescales, pads, or changes wave dimensions.
- Control: `Map04` `Button`
- Action: `ButtonProc_rescaleallpr` -> `rescaleallpr()`
- Source: `Kong_Igor_panel.ipf:655`

### `ExtractSTS`

- Summary: `ExtractSTS` runs `ExtractSTS()` through `ButtonProc_ExtractSTS`. extracts values, metadata, cursor information, or derived waves.
- Control: `Map20` `Button`
- Action: `ButtonProc_ExtractSTS` -> `ExtractSTS()`
- Source: `Kong_Igor_panel.ipf:615`

### `all`

- Summary: `all` calls `ButtonProc_ExtractSTSall`. After do dI/dV(E,x,y) and plot 2D STS, you can run Extract sts all to get all the stss from the grid, titled by gridsts# Purpose: extracts values, metadata, cursor information, or derived waves.
- Control: `Map57` `Button`
- Action: `ButtonProc_ExtractSTSall` -> `ExtractallSTS()`
- Source: `Kong_Igor_panel.ipf:651`

### `2D STS`

- Summary: `2D STS` calls `ButtonProc_2DSTS`. Logic of the mat3d wave is follow the order that [0: x] [1: dI/dV] [2: y] IMPORTANT To guarantee the procedure works well, you need Rescale the x and y of slices as (0,a) before do dI/dV(x,y,E)
- Control: `Map21` `Button`
- Action: `ButtonProc_2DSTS`
- Source: `Kong_Igor_panel.ipf:617`

### `2ndDif All`

- Summary: `2ndDif All` runs `secondDall()` through `ButtonProc_2ndDall`. Interactive Igor procedure for linecut, slice, or region extraction; smoothing, normalization, or background removal; graph display, formatting, or window management.
- Control: `Map07` `Button`
- Action: `ButtonProc_2ndDall` -> `secondDall()`
- Source: `Kong_Igor_panel.ipf:599`


## FFT Filter

### `QC4`

- Summary: `QC4` runs `FTc()` through `ButtonProc_FTc`. Interactive Igor procedure for FFT, QPI, phase, or lock-in analysis; graph display, formatting, or window management; Igor wave/matrix/cube data operation.
- Control: `Map81` `Button`
- Action: `ButtonProc_FTc` -> `FTc()`
- Source: `Kong_Igor_panel.ipf:761`

### `LP`

- Summary: `LP` runs `FTclp()` through `ButtonProc_FTclp`. Interactive Igor procedure for FFT, QPI, phase, or lock-in analysis; graph display, formatting, or window management; Igor wave/matrix/cube data operation.
- Control: `Map97` `Button`
- Action: `ButtonProc_FTclp` -> `FTclp()`
- Source: `Kong_Igor_panel.ipf:772`


## LF drift

### `Y`

- Summary: `Y` runs `FTlinecutc()` through `ButtonProc_FTlinecutc`. Interactive Igor procedure for FFT, QPI, phase, or lock-in analysis; linecut, slice, or region extraction; matrix resampling, scaling, or reshaping.
- Control: `Map90` `Button`
- Action: `ButtonProc_FTlinecutc` -> `FTlinecutc()`
- Source: `Kong_Igor_panel.ipf:774`

### `2D`

- Summary: `2D` runs `LawlerFujita()` through `ButtonProc_LF`. Interactive Igor procedure for FFT, QPI, phase, or lock-in analysis; geometric correction, rotation, shear, drift, or strain analysis; graph display, formatting, or window management.
- Control: `Symx23` `Button`
- Action: `ButtonProc_LF` -> `LawlerFujita()`
- Source: `Kong_Igor_panel.ipf:837`

### `3D`

- Summary: `3D` runs `LFtc()` through `ButtonProc_LFtc`. Interactive Igor procedure for Nanonis/STM data loading or map conversion; linecut, slice, or region extraction; geometric correction, rotation, shear, drift, or strain analysis.
- Control: `Symx22` `Button`
- Action: `ButtonProc_LFtc` -> `LFtc()`
- Source: `Kong_Igor_panel.ipf:839`

### `Cal. Tensor`

- Summary: `Cal. Tensor` runs `Strainanalysisc()` through `ButtonProc_Strainanalysisc`. applies geometric correction or extracts deformation/strain information.
- Control: `Symx34` `Button`
- Action: `ButtonProc_Strainanalysisc` -> `Strainanalysisc()`
- Source: `Kong_Igor_panel.ipf:998`


## MultiSet (Old)

### `VMap`

- Summary: `VMap` runs `layoutmap()` through `ButtonProc_Layoutmap`. Interactive Igor procedure for matrix resampling, scaling, or reshaping; geometric correction, rotation, shear, drift, or strain analysis; smoothing, normalization, or background removal.
- Control: `Map13` `Button`
- Action: `ButtonProc_Layoutmap` -> `layoutmap()`
- Source: `Kong_Igor_panel.ipf:571`

### `Two set Diffe`

- Summary: `Two set Diffe` runs `twosetdifference()` through `ButtonProc_twosetdifference`. displays waves, images, contours, or graph overlays.
- Control: `Map33` `Button`
- Action: `ButtonProc_twosetdifference` -> `twosetdifference()`
- Source: `Kong_Igor_panel.ipf:637`

### `SumTrace`

- Summary: `SumTrace` runs `summul()` through `ButtonProc_summul`. combines many waves/slices into a map, linecut, or averaged output.
- Control: `Map02` `Button`
- Action: `ButtonProc_summul` -> `summul()`
- Source: `Kong_Igor_panel.ipf:597`

### `Ratio`

- Summary: `Ratio` runs `AnaTeSe()` through `ButtonProc_Isolate2C`. Interactive Igor procedure for Igor wave/matrix/cube data operation.
- Control: `Map8` `Button`
- Action: `ButtonProc_Isolate2C` -> `AnaTeSe()`
- Source: `Kong_Igor_panel.ipf:587`

### `Offset`

- Summary: `Offset` runs `hshift()` through `ButtonProc_shift`. Interactive Igor procedure for graph display, formatting, or window management; Igor wave/matrix/cube data operation.
- Control: `Map31` `Button`
- Action: `ButtonProc_shift` -> `hshift()`
- Source: `Kong_Igor_panel.ipf:633`

### `Comp_MultiSet`

- Summary: `Comp_MultiSet` runs `compare()` through `ButtonProc_comparea`. Interactive Igor procedure for symmetry or reflection processing; matrix resampling, scaling, or reshaping; ARPES-style loading, plotting, or momentum conversion.
- Control: `Map14` `Button`
- Action: `ButtonProc_comparea` -> `compare()`
- Source: `Kong_Igor_panel.ipf:607`

### `V+`

- Summary: `V+` runs `rescalex_plus()` through `ButtonProc_xplusall`. resamples, rescales, pads, or changes wave dimensions.
- Control: `Symx3` `Button`
- Action: `ButtonProc_xplusall` -> `rescalex_plus()`
- Source: `Kong_Igor_panel.ipf:569`

### `V*`

- Summary: `V*` runs `rescalexmultiwhat()` through `ButtonProc_xmultisall`. resamples, rescales, pads, or changes wave dimensions.
- Control: `Symx4` `Button`
- Action: `ButtonProc_xmultisall` -> `rescalexmultiwhat()`
- Source: `Kong_Igor_panel.ipf:577`

### `Y+`

- Summary: `Y+` runs `addyall()` through `ButtonProc_addyall`. Interactive Igor procedure for linecut, slice, or region extraction; smoothing, normalization, or background removal; Igor wave/matrix/cube data operation.
- Control: `Map2` `Button`
- Action: `ButtonProc_addyall` -> `addyall()`
- Source: `Kong_Igor_panel.ipf:591`

### `Y*`

- Summary: `Y*` runs `myall()` through `ButtonProc_myall`. Interactive Igor procedure for linecut, slice, or region extraction; smoothing, normalization, or background removal; Igor wave/matrix/cube data operation.
- Control: `Map16` `Button`
- Action: `ButtonProc_myall` -> `myall()`
- Source: `Kong_Igor_panel.ipf:613`

### `Data_sigma`

- Summary: `Data_sigma` runs `findsigmaofdata()` through `ButtonProc_sigma`. Interactive Igor procedure for smoothing, normalization, or background removal.
- Control: `Map11` `Button`
- Action: `ButtonProc_sigma` -> `findsigmaofdata()`
- Source: `Kong_Igor_panel.ipf:603`

### `Rscl.*/`

- Summary: `Rscl.*/` runs `renormcuts_k()` through `ButtonProc_renormcuts_k`. smooths, normalizes, or removes background/trend components.
- Control: `Symx15` `Button`
- Action: `ButtonProc_renormcuts_k` -> `renormcuts_k()`
- Source: `Kong_Igor_panel.ipf:751`

### `Rscl.+-`

- Summary: `Rscl.+-` runs `rescale_pi()` through `ButtonProc_rescale_pi`. resamples, rescales, pads, or changes wave dimensions.
- Control: `Symx17` `Button`
- Action: `ButtonProc_rescale_pi` -> `rescale_pi()`
- Source: `Kong_Igor_panel.ipf:755`

### `Individual Shift`

- Summary: `Individual Shift` runs `autoclbzero()` through `ButtonProc_autoclbzero`. Interactive Igor procedure for matrix resampling, scaling, or reshaping; graph display, formatting, or window management; Igor wave/matrix/cube data operation.
- Control: `Map24` `Button`
- Action: `ButtonProc_autoclbzero` -> `autoclbzero()`
- Source: `Kong_Igor_panel.ipf:623`


## PDW Domain Map

### `Calculate Pplarization`

- Summary: `Calculate Pplarization` runs `findpolarizationc()` through `ButtonProc_findpolarizationc`. Interactive Igor procedure for FFT, QPI, phase, or lock-in analysis; spectroscopy, superconducting-gap, or vortex-model analysis.
- Control: `Map60` `Button`
- Action: `ButtonProc_findpolarizationc` -> `findpolarizationc()`
- Source: `Kong_Igor_panel.ipf:855`


## C4 Shearing

### `Coef`

- Summary: `Coef` runs `C4sheargetparac()` through `ButtonProc_C4sheargetparac`. applies geometric correction or extracts deformation/strain information.
- Control: `Map84` `Button`
- Action: `ButtonProc_C4sheargetparac` -> `C4sheargetparac()`
- Source: `Kong_Igor_panel.ipf:696`

### `Go`

- Summary: `Go` runs `C4shearcorrectc()` through `ButtonProc_C4shearcorrectc`. applies geometric correction or extracts deformation/strain information.
- Control: `Map85` `Button`
- Action: `ButtonProc_C4shearcorrectc` -> `C4shearcorrectc()`
- Source: `Kong_Igor_panel.ipf:747`

### `Go3D`

- Summary: `Go3D` runs `Shearmat3d()` through `ButtonProc_Shearmat3d`. applies geometric correction or extracts deformation/strain information.
- Control: `Map89` `Button`
- Action: `ButtonProc_Shearmat3d` -> `Shearmat3d()`
- Source: `Kong_Igor_panel.ipf:749`


## 2D Lock-in

### `ε`

- Summary: `ε` runs `cal_strainbyshearc()` through `ButtonProc_cal_strainbyshearc`. applies geometric correction or extracts deformation/strain information.
- Control: `Symx31` `Button`
- Action: `ButtonProc_cal_strainbyshearc` -> `cal_strainbyshearc()`
- Source: `Kong_Igor_panel.ipf:959`

### `Lckin/Ftd`

- Summary: `Lckin/Ftd` runs `t2dlockinandFilter()` through `ButtonProc_t2dlockinandFilter`. performs Fourier, filtering, phase, or lock-in processing.
- Control: `Symx24` `Button`
- Action: `ButtonProc_t2dlockinandFilter` -> `t2dlockinandFilter()`
- Source: `Kong_Igor_panel.ipf:857`

### `Old`

- Summary: `Old` runs `t2dlockin()` through `ButtonProc_t2dlockin`. performs Fourier, filtering, phase, or lock-in processing.
- Control: `Symx12` `Button`
- Action: `ButtonProc_t2dlockin` -> `t2dlockin()`
- Source: `Kong_Igor_panel.ipf:859`

### `Cr`

- Summary: `Cr` runs `Correct2Dlockinampc()` through `ButtonProc_Correct2DlockinampcoutInd`. performs Fourier, filtering, phase, or lock-in processing.
- Control: `Symx25` `Button`
- Action: `ButtonProc_Correct2DlockinampcoutInd` -> `Correct2Dlockinampc()`
- Source: `Kong_Igor_panel.ipf:861`


## Curve Info Extraction

### `Extract_dI/dV`

- Summary: `Extract_dI/dV` runs `extracnumfromstr()` through `ButtonProc_extracnumfromstr`. Interactive Igor procedure for Igor wave/matrix/cube data operation.
- Control: `Map19` `Button`
- Action: `ButtonProc_extracnumfromstr` -> `extracnumfromstr()`
- Source: `Kong_Igor_panel.ipf:625`


## Move Window Tech.

### `PreFFT`

- Summary: `PreFFT` runs `doampfftforphase()` through `ButtonProc_doampfftforphase`. performs Fourier, filtering, phase, or lock-in processing.
- Control: `Map71` `Button`
- Action: `ButtonProc_doampfftforphase` -> `doampfftforphase()`
- Source: `Kong_Igor_panel.ipf:841`

### `getA`

- Summary: `getA` runs `pickupPA()` through `ButtonProc_pickupPA`. Interactive Igor procedure for Nanonis/STM data loading or map conversion; FFT, QPI, phase, or lock-in analysis; matrix resampling, scaling, or reshaping.
- Control: `Map72` `Button`
- Action: `ButtonProc_pickupPA` -> `pickupPA()`
- Source: `Kong_Igor_panel.ipf:843`

### `getB`

- Summary: `getB` runs `pickupPB()` through `ButtonProc_pickupPB`. Interactive Igor procedure for Nanonis/STM data loading or map conversion; FFT, QPI, phase, or lock-in analysis; matrix resampling, scaling, or reshaping.
- Control: `Map73` `Button`
- Action: `ButtonProc_pickupPB` -> `pickupPB()`
- Source: `Kong_Igor_panel.ipf:845`

### `Phase DIF of 2`

- Summary: `Phase DIF of 2` runs `PhaseMap()` through `ButtonProc_PhaseMap`. performs Fourier, filtering, phase, or lock-in processing.
- Control: `Map74` `Button`
- Action: `ButtonProc_PhaseMap` -> `PhaseMap()`
- Source: `Kong_Igor_panel.ipf:847`

### `FixBnd`

- Summary: `FixBnd` runs `correctboundPhMapc()` through `ButtonProc_PhaseMapcorrectbd`. Interactive Igor procedure for FFT, QPI, phase, or lock-in analysis; spectroscopy, superconducting-gap, or vortex-model analysis; Igor wave/matrix/cube data operation.
- Control: `Map83` `Button`
- Action: `ButtonProc_PhaseMapcorrectbd` -> `correctboundPhMapc()`
- Source: `Kong_Igor_panel.ipf:849`


## /

### `Extract_Width`

- Summary: `Extract_Width` runs `exwidth()` through `ButtonProc_exwidth`. Interactive Igor procedure for graph display, formatting, or window management; Igor wave/matrix/cube data operation.
- Control: `Map23` `Button`
- Action: `ButtonProc_exwidth` -> `exwidth()`
- Source: `Kong_Igor_panel.ipf:621`

### `RCSJ Model`

- Summary: `RCSJ Model` runs `RCSJc()` through `ButtonProc_RCSJ`. Interactive Igor procedure for matrix resampling, scaling, or reshaping; smoothing, normalization, or background removal; graph display, formatting, or window management.
- Control: `SMap9` `Button`
- Action: `ButtonProc_RCSJ` -> `RCSJc()`
- Source: `Kong_Igor_panel.ipf:1068`


## Segregation

### `Self`

- Summary: `Self` calls `ButtonProc_LS`. #I.2 Single 2D wave segregation [Do Segregation to itself]
- Control: `Symx19` `Button`
- Action: `ButtonProc_LS`
- Source: `Kong_Igor_panel.ipf:949`

### `Other`

- Summary: `Other` calls `ButtonProc_LS2`. #I.2 Single 2D wave segregation [Do Segregation to other wave]
- Control: `Symx20` `Button`
- Action: `ButtonProc_LS2`
- Source: `Kong_Igor_panel.ipf:951`


## PR-QPI

### `Do it`

- Summary: `Do it` calls `ButtonProc_DBD_PRQPI`. $ Defect bound state Phase referenced QPI to extract $ superconducting pair phase $ Ref.
- Control: `Symx28` `Button`
- Action: `ButtonProc_DBD_PRQPI`
- Source: `Kong_Igor_panel.ipf:953`

### `Go`

- Summary: `Go` runs `makelatticec()` through `ButtonProc_makelatticec`. creates new waves, maps, figures, or simulation data.
- Control: `Symx30` `Button`
- Action: `ButtonProc_makelatticec` -> `makelatticec()`
- Source: `Kong_Igor_panel.ipf:955`


## Tip Height Experiment

### `P(E) Theory`

- Summary: `P(E) Theory` runs `CalculateP0Ec()` through `ButtonProc_CalculateP0Ec`. Interactive Igor procedure for graph display, formatting, or window management.
- Control: `SMap0` `Button`
- Action: `ButtonProc_CalculateP0Ec` -> `CalculateP0Ec()`
- Source: `Kong_Igor_panel.ipf:1070`

### `Differentiate I/V`

- Summary: `Differentiate I/V` runs `diffeall()` through `ButtonProc_diffeall`. displays waves, images, contours, or graph overlays.
- Control: `Map38` `Button`
- Action: `ButtonProc_diffeall` -> `diffeall()`
- Source: `Kong_Igor_panel.ipf:1058`

### `Apply divider (single)`

- Summary: `Apply divider (single)` runs `scalewaves()` through `ButtonProc_scalewave`. resamples, rescales, pads, or changes wave dimensions.
- Control: `Map42` `Button`
- Action: `ButtonProc_scalewave` -> `scalewaves()`
- Source: `Kong_Igor_panel.ipf:1060`

### `Linecut with divider`

- Summary: `Linecut with divider` runs `rescalegroupc()` through `ButtonProc_rescalegroupc`. resamples, rescales, pads, or changes wave dimensions.
- Control: `Map43` `Button`
- Action: `ButtonProc_rescalegroupc` -> `rescalegroupc()`
- Source: `Kong_Igor_panel.ipf:1062`

### `Format wave A as B`

- Summary: `Format wave A as B` runs `madewavebytemplatec()` through `ButtonProc_madewavebytemplate`. combines many waves/slices into a map, linecut, or averaged output.
- Control: `Map46` `Button`
- Action: `ButtonProc_madewavebytemplate` -> `madewavebytemplatec()`
- Source: `Kong_Igor_panel.ipf:1066`

### `Linecut from Random`

- Summary: `Linecut from Random` runs `unevenlinepc()` through `ButtonProc_unevenlinep`. Interactive Igor procedure for Igor wave/matrix/cube data operation.
- Control: `Map44` `Button`
- Action: `ButtonProc_unevenlinep` -> `unevenlinepc()`
- Source: `Kong_Igor_panel.ipf:1064`


## General Simu

### `Temp convolve`

- Summary: `Temp convolve` runs `convolvetempc()` through `ButtonProc_convolvetempc`. Interactive Igor procedure for symmetry or reflection processing; graph display, formatting, or window management; Igor wave/matrix/cube data operation.
- Control: `SMap3` `Button`
- Action: `ButtonProc_convolvetempc` -> `convolvetempc()`
- Source: `Kong_Igor_panel.ipf:1002`

### `T-conv batch`

- Summary: `T-conv batch` runs `convallc()` through `ButtonProc_convallc`. Interactive Igor procedure in General_Simu.ipf.
- Control: `SMap4` `Button`
- Action: `ButtonProc_convallc` -> `convallc()`
- Source: `Kong_Igor_panel.ipf:1007`

### `TBG`

- Summary: `TBG` runs `TBGsimu()` through `ButtonProc_TBGsimu`. Interactive Igor procedure for symmetry or reflection processing; lattice, moire, or twist-angle simulation/analysis; graph display, formatting, or window management.
- Control: `SMap5` `Button`
- Action: `ButtonProc_TBGsimu` -> `TBGsimu()`
- Source: `Kong_Igor_panel.ipf:1042`

### `TTG`

- Summary: `TTG` runs `TTGsimu()` through `ButtonProc_TTGsimu`. Interactive Igor procedure for lattice, moire, or twist-angle simulation/analysis; Igor wave/matrix/cube data operation.
- Control: `SMap6` `Button`
- Action: `ButtonProc_TTGsimu` -> `TTGsimu()`
- Source: `Kong_Igor_panel.ipf:1044`

### `A(honeycomb)`

- Summary: `A(honeycomb)` runs `Ahoneycombc()` through `ButtonProc_Honeycomb`. Interactive Igor procedure for matrix resampling, scaling, or reshaping; lattice, moire, or twist-angle simulation/analysis.
- Control: `SMap7` `Button`
- Action: `ButtonProc_Honeycomb` -> `Ahoneycombc()`
- Source: `Kong_Igor_panel.ipf:1046`

### `Demo: Trace Slanted Jumping Line`

- Summary: `Demo: Trace Slanted Jumping Line` runs `Demoautormjump2DPro()` through `ButtonProc_Demoautormjump2DPro`. Interactive Igor procedure for graph display, formatting, or window management; Igor wave/matrix/cube data operation.
- Control: `Jump1` `Button`
- Action: `ButtonProc_Demoautormjump2DPro` -> `Demoautormjump2DPro()`
- Source: `Kong_Igor_panel.ipf:803`

### `Plot_{A(k,ω)}`

- Summary: `Plot_{A(k,ω)}` runs `d3dsimu()` through `ButtonProc_d3dsimu`. Interactive Igor procedure for Nanonis/STM data loading or map conversion; linecut, slice, or region extraction; matrix resampling, scaling, or reshaping.
- Control: `Theo3` `Button`
- Action: `ButtonProc_d3dsimu` -> `d3dsimu()`
- Source: `Kong_Igor_panel.ipf:984`


## PDW Related Simu.

### `PDW Linecut`

- Summary: `PDW Linecut` runs `SimuPDW1Dc()` through `ButtonProc_SimuPDW1Dc`. Interactive Igor procedure for Igor wave/matrix/cube data operation.
- Control: `Map60cpr09` `Button`
- Action: `ButtonProc_SimuPDW1Dc` -> `SimuPDW1Dc()`
- Source: `Kong_Igor_panel.ipf:865`

### `OLD`

- Summary: `OLD` runs `simupdwwithw()` through `ButtonProc_simupdwwithw`. Interactive Igor procedure for Nanonis/STM data loading or map conversion; FFT, QPI, phase, or lock-in analysis; linecut, slice, or region extraction.
- Control: `Map60cpr13` `Button`
- Action: `ButtonProc_simupdwwithw` -> `simupdwwithw()`
- Source: `Kong_Igor_panel.ipf:867`

### `Topo. Defect`

- Summary: `Topo. Defect` runs `SIMUtopodefectc()` through `ButtonProc_SIMUtopodefectc`. Interactive Igor procedure for Nanonis/STM data loading or map conversion; FFT, QPI, phase, or lock-in analysis; smoothing, normalization, or background removal.
- Control: `Map60cpr10` `Button`
- Action: `ButtonProc_SIMUtopodefectc` -> `SIMUtopodefectc()`
- Source: `Kong_Igor_panel.ipf:851`

### `FeSC FS`

- Summary: `FeSC FS` calls `ButtonProc_FeSC_normal`. TB FeSC Fermi Surface Purpose: smooths, normalizes, or removes background/trend components.
- Control: `Map60cpr11` `Button`
- Action: `ButtonProc_FeSC_normal`
- Source: `Kong_Igor_panel.ipf:853`

### `2D PDM with 2 Gap`

- Summary: `2D PDM with 2 Gap` calls `ButtonProc_choiceparameterc`. Simulation of 2D gap modulation with 2 gaps
- Control: `Map60cpr21` `Button`
- Action: `ButtonProc_choiceparameterc`
- Source: `Kong_Igor_panel.ipf:1004`


## QPI Range Estimate

### `vortex pair`

- Summary: `vortex pair` runs `vortexantivortexsimuc()` through `ButtonProc_vortexantivortexsimuc`. Interactive Igor procedure for FFT, QPI, phase, or lock-in analysis; spectroscopy, superconducting-gap, or vortex-model analysis.
- Control: `Map60cpr16` `Button`
- Action: `ButtonProc_vortexantivortexsimuc` -> `vortexantivortexsimuc()`
- Source: `Kong_Igor_panel.ipf:977`

### `Rnu_{ / m i}= nu_{ / m j}`

- Summary: `Rnu_{ / m i}= nu_{ / m j}` calls `ButtonProc_calculateRCc`. Panel button callback for symmetry or reflection processing; linecut, slice, or region extraction.
- Control: `sym_c5` `Button`
- Action: `ButtonProc_calculateRCc`
- Source: `Kong_Igor_panel.ipf:1011`


## Symmetrization

### `C4`

- Summary: `C4` calls `ButtonProc_C4_symc`. ####.
- Control: `sym_c4` `Button`
- Action: `ButtonProc_C4_symc`
- Source: `Kong_Igor_panel.ipf:1009`

### `M_dia`

- Summary: `M_dia` calls `ButtonProc_Mdiag_symc`. ####.
- Control: `sym_c6` `Button`
- Action: `ButtonProc_Mdiag_symc`
- Source: `Kong_Igor_panel.ipf:1014`

### `M_offdia`

- Summary: `M_offdia` calls `ButtonProc_Moffdiag_symc`. ####.
- Control: `sym_c7` `Button`
- Action: `ButtonProc_Moffdiag_symc`
- Source: `Kong_Igor_panel.ipf:1016`

### `{ / m NbSe}_{2}`

- Summary: `{ / m NbSe}_{2}` runs `simuCDWc()` through `ButtonProc_simuCDWc`. Interactive Igor procedure for FFT, QPI, phase, or lock-in analysis; symmetry or reflection processing; matrix resampling, scaling, or reshaping.
- Control: `Map60cpr19` `Button`
- Action: `ButtonProc_simuCDWc` -> `simuCDWc()`
- Source: `Kong_Igor_panel.ipf:992`

### `D4`

- Summary: `D4` calls `ButtonProc_D4_symc`. 1: Mx Mdiag; Mx Moffdiag; My Mdiag; My Moffdiag; 2: C4 Mx; C4 My; 3: C4 Moffdiag; C4 Mdiag We use method 1 Purpose: applies symmetry, mirror, or reflection operations.
- Control: `sym_c0` `Button`
- Action: `ButtonProc_D4_symc`
- Source: `Kong_Igor_panel.ipf:1022`

### `Mx`

- Summary: `Mx` calls `ButtonProc_Mx_symc`. ####.
- Control: `sym_c9` `Button`
- Action: `ButtonProc_Mx_symc`
- Source: `Kong_Igor_panel.ipf:1020`

### `My`

- Summary: `My` calls `ButtonProc_My_symc`. ####.
- Control: `sym_c8` `Button`
- Action: `ButtonProc_My_symc`
- Source: `Kong_Igor_panel.ipf:1018`

### `Sym. All`

- Summary: `Sym. All` runs `symmetrizeQPIdallc()` through `ButtonProc_symmetrizeQPIdallc`. applies symmetry, mirror, or reflection operations.
- Control: `sym_c1` `Button`
- Action: `ButtonProc_symmetrizeQPIdallc` -> `symmetrizeQPIdallc()`
- Source: `Kong_Igor_panel.ipf:1024`


## Modeling

### `MBS Split`

- Summary: `MBS Split` runs `eval2()` through `ButtonProc_intereractionMBS`. Interactive Igor procedure for symmetry or reflection processing; matrix resampling, scaling, or reshaping; spectroscopy, superconducting-gap, or vortex-model analysis.
- Control: `Map17` `Button`
- Action: `ButtonProc_intereractionMBS` -> `eval2()`
- Source: `Kong_Igor_panel.ipf:779`

### `Cal. Matrix H(k)`

- Summary: `Cal. Matrix H(k)` runs `automatrixTC()` through `ButtonProc_automatrixTC`. Interactive Igor procedure for Igor wave/matrix/cube data operation.
- Control: `Theo1` `Button`
- Action: `ButtonProc_automatrixTC` -> `automatrixTC()`
- Source: `Kong_Igor_panel.ipf:770`

### `Profile`

- Summary: `Profile` runs `makeu1u2()` through `ButtonProc_LFuModel`. creates new waves, maps, figures, or simulation data.
- Control: `Map09` `Button`
- Action: `ButtonProc_LFuModel` -> `makeu1u2()`
- Source: `Kong_Igor_panel.ipf:777`

### `CdGM`

- Summary: `CdGM` runs `CdGM_Dirac_singlevortex()` through `ButtonProc_CdGMDirac`. displays waves, images, contours, or graph overlays.
- Control: `Map48` `Button`
- Action: `ButtonProc_CdGMDirac` -> `CdGM_Dirac_singlevortex()`
- Source: `Kong_Igor_panel.ipf:797`

### `FeSC-A(ω,k)+LDOS+QPI / Two bands TB`

- Summary: `FeSC-A(ω,k)+LDOS+QPI / Two bands TB` calls `ButtonProc_QPISIMUNew`. New simultaneous simulation of Spectral function of QPI 2 band tight-binding model Gamma hole & M electron
- Control: `Theo2` `Button`
- Action: `ButtonProc_QPISIMUNew`
- Source: `Kong_Igor_panel.ipf:979`

### `LL`

- Summary: `LL` runs `calculateLLNewc()` through `ButtonProc_predictLL`. Interactive Igor procedure for ARPES-style loading, plotting, or momentum conversion.
- Control: `Map18` `Button`
- Action: `ButtonProc_predictLL` -> `calculateLLNewc()`
- Source: `Kong_Igor_panel.ipf:781`

### `LL DOS`

- Summary: `LL DOS` runs `makeLLspectra()` through `ButtonProc_LLDOS`. creates new waves, maps, figures, or simulation data.
- Control: `Map47` `Button`
- Action: `ButtonProc_LLDOS` -> `makeLLspectra()`
- Source: `Kong_Igor_panel.ipf:795`


## Triangle Lattice

### `TB_Cprt`

- Summary: `TB_Cprt` runs `tbmodel()` through `ButtonProc_tbmodel`. runs a model/simulation workflow and produces calculated spectra, bands, or maps.
- Control: `Map26` `Button`
- Action: `ButtonProc_tbmodel` -> `tbmodel()`
- Source: `Kong_Igor_panel.ipf:785`

### `TB_FeSC`

- Summary: `TB_FeSC` runs `fourbandmodel()` through `ButtonProc_tbmodelIBSC`. Interactive Igor procedure for Nanonis/STM data loading or map conversion; matrix resampling, scaling, or reshaping; lattice, moire, or twist-angle simulation/analysis.
- Control: `Map49` `Button`
- Action: `ButtonProc_tbmodelIBSC` -> `fourbandmodel()`
- Source: `Kong_Igor_panel.ipf:799`

### `Fano`

- Summary: `Fano` runs `fanoline()` through `ButtonProc_fanoline`. Interactive Igor procedure for matrix resampling, scaling, or reshaping; graph display, formatting, or window management; Igor wave/matrix/cube data operation.
- Control: `Map50` `Button`
- Action: `ButtonProc_fanoline` -> `fanoline()`
- Source: `Kong_Igor_panel.ipf:801`

### `TBG Twist angle Map`

- Summary: `TBG Twist angle Map` runs `FFTTwistanglemap()` through `ButtonProc_FFTTwistanglemap`. Pre-FFT Purpose: performs Fourier, filtering, phase, or lock-in processing.
- Control: `Map60cpr14` `Button`
- Action: `ButtonProc_FFTTwistanglemap` -> `FFTTwistanglemap()`
- Source: `Kong_Igor_panel.ipf:957`

### `Band abinitio`

- Summary: `Band abinitio` runs `calculateband()` through `ButtonProc_calculateband`. Interactive Igor procedure in Models.ipf.
- Control: `Map36` `Button`
- Action: `ButtonProc_calculateband` -> `calculateband()`
- Source: `Kong_Igor_panel.ipf:793`

### `dSC`

- Summary: `dSC` runs `plotdgap()` through `ButtonProc_dscgap`. displays waves, images, contours, or graph overlays.
- Control: `Map25` `Button`
- Action: `ButtonProc_dscgap` -> `plotdgap()`
- Source: `Kong_Igor_panel.ipf:783`

### `CPR`

- Summary: `CPR` runs `nonsinodal()` through `ButtonProc_nonsinodal`. Interactive Igor procedure for Nanonis/STM data loading or map conversion; linecut, slice, or region extraction; matrix resampling, scaling, or reshaping.
- Control: `Map60cpr` `Button`
- Action: `ButtonProc_nonsinodal` -> `nonsinodal()`
- Source: `Kong_Igor_panel.ipf:815`

### `Moiré λ`

- Summary: `Moiré λ` runs `calculateMoireLc()` through `ButtonProc_calculateMoireLc`. Interactive Igor procedure for lattice, moire, or twist-angle simulation/analysis; graph display, formatting, or window management.
- Control: `Map60cpr18` `Button`
- Action: `ButtonProc_calculateMoireLc` -> `calculateMoireLc()`
- Source: `Kong_Igor_panel.ipf:990`

### `BCSVortex line`

- Summary: `BCSVortex line` runs `DyneModbyvortex()` through `ButtonProc_Svortex`. fits or extracts spectral/peak parameters.
- Control: `Map27` `Button`
- Action: `ButtonProc_Svortex` -> `DyneModbyvortex()`
- Source: `Kong_Igor_panel.ipf:787`

### `Stripe@FFT`

- Summary: `Stripe@FFT` runs `FFTstripesimulationc()` through `ButtonProc_FFTstripesimulationc`. performs Fourier, filtering, phase, or lock-in processing.
- Control: `Map60cpr17` `Button`
- Action: `ButtonProc_FFTstripesimulationc` -> `FFTstripesimulationc()`
- Source: `Kong_Igor_panel.ipf:988`


## Adjust on Graph

### `Smooth`

- Summary: `Smooth` runs `Consmoo()` through `ButtonProc_Consmoo`. Interactive Igor procedure for graph display, formatting, or window management.
- Control: `Map52` `Button`
- Action: `ButtonProc_Consmoo` -> `Consmoo()`
- Source: `Kong_Igor_panel.ipf:961`

### `Z_color`

- Summary: `Z_color` calls `ButtonProc_Zcoloro`. Part I: from color table
- Control: `Map99` `Button`
- Action: `ButtonProc_Zcoloro`
- Source: `Kong_Igor_panel.ipf:963`

### `OffsetXY`

- Summary: `OffsetXY` runs `Consoffset()` through `ButtonProc_Consoffset`. Interactive Igor procedure for graph display, formatting, or window management; Igor wave/matrix/cube data operation.
- Control: `Map67` `Button`
- Action: `ButtonProc_Consoffset` -> `Consoffset()`
- Source: `Kong_Igor_panel.ipf:967`

### `LThick`

- Summary: `LThick` runs `Conslinethick()` through `ButtonProc_Conslinethick`. Interactive Igor procedure for graph display, formatting, or window management; Igor wave/matrix/cube data operation.
- Control: `Map96` `Button`
- Action: `ButtonProc_Conslinethick` -> `Conslinethick()`
- Source: `Kong_Igor_panel.ipf:965`

### `active all`

- Summary: `active all` runs `Consoffsetx()` through `ButtonProc_Consactiveall`. Interactive Igor procedure for graph display, formatting, or window management; Igor wave/matrix/cube data operation.
- Control: `Map98` `Button`
- Action: `ButtonProc_Consactiveall` -> `Consoffsetx()`
- Source: `Kong_Igor_panel.ipf:969`

### `Vector Field Plot`

- Summary: `Vector Field Plot` runs `makevectorfieldc()` through `ButtonProc_makevectorfield`. creates new waves, maps, figures, or simulation data.
- Control: `Map60cpr15` `Button`
- Action: `ButtonProc_makevectorfield` -> `makevectorfieldc()`
- Source: `Kong_Igor_panel.ipf:971`


## MZM Scaling

### `2D`

- Summary: `2D` runs `Batchscalingoure()` through `ButtonProc_Batchscalingoure`. Interactive Igor procedure for Nanonis/STM data loading or map conversion.
- Control: `Map55` `Button`
- Action: `ButtonProc_Batchscalingoure` -> `Batchscalingoure()`
- Source: `Kong_Igor_panel.ipf:768`

### `Ind. S/Vortex`

- Summary: `Ind. S/Vortex` runs `indivlinecut()` through `ButtonProc_S_Svortexindiv`. displays waves, images, contours, or graph overlays.
- Control: `Map29` `Button`
- Action: `ButtonProc_S_Svortexindiv` -> `indivlinecut()`
- Source: `Kong_Igor_panel.ipf:791`

### `S/Vortex Ln`

- Summary: `S/Vortex Ln` runs `automultiSV()` through `ButtonProc_S_Svortex`. Interactive Igor procedure for Nanonis/STM data loading or map conversion; linecut, slice, or region extraction; spectroscopy, superconducting-gap, or vortex-model analysis.
- Control: `Map28` `Button`
- Action: `ButtonProc_S_Svortex` -> `automultiSV()`
- Source: `Kong_Igor_panel.ipf:789`

### `∆(1UC-FeSe)`

- Summary: `∆(1UC-FeSe)` runs `oneUCFeSegapsimu()` through `ButtonProc_oneUCFeSegapsimu`. Interactive Igor procedure for spectroscopy, superconducting-gap, or vortex-model analysis; graph display, formatting, or window management.
- Control: `Map60cpr20` `Button`
- Action: `ButtonProc_oneUCFeSegapsimu` -> `oneUCFeSegapsimu()`
- Source: `Kong_Igor_panel.ipf:994`

### `Scal.+Poison`

- Summary: `Scal.+Poison` runs `Batchscaling()` through `ButtonProc_MZMscaling_poison`. Interactive Igor procedure for Nanonis/STM data loading or map conversion; graph display, formatting, or window management; Igor wave/matrix/cube data operation.
- Control: `Map54` `Button`
- Action: `ButtonProc_MZMscaling_poison` -> `Batchscaling()`
- Source: `Kong_Igor_panel.ipf:766`

### `FeSC(M k.p)`

- Summary: `FeSC(M k.p)` calls `ButtonProc_PRB_98_214503_n`. This is the simulation of normal bands in PRB 98,214503 (2018) This is the eignevalue of equation (1)
- Control: `Map60cpr1` `Button`
- Action: `ButtonProc_PRB_98_214503_n`
- Source: `Kong_Igor_panel.ipf:811`

### `FeSC(Γ k.p)`

- Summary: `FeSC(Γ k.p)` calls `ButtonProc_fourbandkpFeSC`. Gamma kp model used in Nat.
- Control: `Map60cpr2` `Button`
- Action: `ButtonProc_fourbandkpFeSC`
- Source: `Kong_Igor_panel.ipf:813`


## Haldane Model

### `Haldane Model`

- Summary: `Haldane Model` calls `ButtonProc_HaldaneCons`. Interactive Tuning Purpose: runs a model/simulation workflow and produces calculated spectra, bands, or maps.
- Control: `Map60cpr5` `Button`
- Action: `ButtonProc_HaldaneCons`
- Source: `Kong_Igor_panel.ipf:805`

### `A(k,ω)`

- Summary: `A(k,ω)` calls `ButtonProc_HaldaneA`. Build Haldane Spectral Function Purpose: runs a model/simulation workflow and produces calculated spectra, bands, or maps.
- Control: `Map60cpr3` `Button`
- Action: `ButtonProc_HaldaneA`
- Source: `Kong_Igor_panel.ipf:807`


## Chiral Majorana mode (QH+SC=TSC)

### `Qi-Hughes-Zhang`

- Summary: `Qi-Hughes-Zhang` runs `Cons_QHZcut2c()` through `ButtonProc_QHZ`. runs a model/simulation workflow and produces calculated spectra, bands, or maps.
- Control: `Map60cpr7` `Button`
- Action: `ButtonProc_QHZ` -> `Cons_QHZcut2c()`
- Source: `Kong_Igor_panel.ipf:823`

### `Qi-Wu-Zhang`

- Summary: `Qi-Wu-Zhang` calls `ButtonProc_QWZCons`. #02 Interactive Link Purpose: runs a model/simulation workflow and produces calculated spectra, bands, or maps.
- Control: `Map60cpr6` `Button`
- Action: `ButtonProc_QWZCons`
- Source: `Kong_Igor_panel.ipf:821`

### `Ω(k)`

- Summary: `Ω(k)` calls `ButtonProc_HaldaneBC`. Calculate Berry Curvature Purpose: runs a model/simulation workflow and produces calculated spectra, bands, or maps.
- Control: `Map60cpr4` `Button`
- Action: `ButtonProc_HaldaneBC`
- Source: `Kong_Igor_panel.ipf:809`

### `*(Slab)`

- Summary: `*(Slab)` calls `ButtonProc_Solveedgestate_QHZc`. runs a model/simulation workflow and produces calculated spectra, bands, or maps.
- Control: `Map60cpr8` `Button`
- Action: `ButtonProc_Solveedgestate_QHZc`
- Source: `Kong_Igor_panel.ipf:827`

### `*(LDOS)`

- Summary: `*(LDOS)` calls `ButtonProc_QHZLDOSCall`. Calculate the LDOS of Edge mode, continue slab calculation Calculate Egienvalue index resolved LDOS Purpose: runs a model/simulation workflow and produces calculated spectra, bands, or maps.
- Control: `Map60cpr9` `Button`
- Action: `ButtonProc_QHZLDOSCall`
- Source: `Kong_Igor_panel.ipf:825`

### `*(A[k,ω,L])`

- Summary: `*(A[k,ω,L])` calls `ButtonProc_QHZslabcutc`. Calculate the Spectral function with layer weight Purpose: runs a model/simulation workflow and produces calculated spectra, bands, or maps.
- Control: `Map60cpr0` `Button`
- Action: `ButtonProc_QHZslabcutc`
- Source: `Kong_Igor_panel.ipf:829`


## Internal Panels and Secondary Windows

### `Curvature_panel()`

- Workflow group: ARPES Template and Momentum Conversion
- Purpose: Curvature panel Usage: call `Curvature_panel()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; writes or exports data; reads or updates panel controls.
- Source: `Pierre's Template.ipf:12264`

### `EMDC_Visualizer_Control()`

- Workflow group: ARPES Template and Momentum Conversion
- Purpose: Igor window/panel recreation routine for linecut, slice, or region extraction; smoothing, normalization, or background removal; ARPES-style loading, plotting, or momentum conversion. Purpose: updates parameters, controls, scales, or display state. Usage: call `EMDC_Visualizer_Control()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; smooths wave data; reads or updates panel controls.
- Source: `Pierre's Template.ipf:11506`

### `Help_EDC()`

- Workflow group: ARPES Template and Momentum Conversion
- Purpose: Igor window/panel recreation routine for linecut, slice, or region extraction; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management. Usage: call `Help_EDC()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10529`

### `Help_EDC_data()`

- Workflow group: ARPES Template and Momentum Conversion
- Purpose: Igor window/panel recreation routine for linecut, slice, or region extraction; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management. Usage: call `Help_EDC_data()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10354`

### `Help_Fermi_Profile()`

- Workflow group: ARPES Template and Momentum Conversion
- Purpose: Igor window/panel recreation routine for linecut, slice, or region extraction; smoothing, normalization, or background removal; ARPES-style loading, plotting, or momentum conversion. Usage: call `Help_Fermi_Profile()` to recreate or bring up the Igor window/panel. Code behavior: creates output waves; opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; smooths wave data; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10964`

### `Help_MDC()`

- Workflow group: ARPES Template and Momentum Conversion
- Purpose: Igor window/panel recreation routine for linecut, slice, or region extraction; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management. Usage: call `Help_MDC()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10579`

### `Help_MDC_Data_ploter()`

- Workflow group: ARPES Template and Momentum Conversion
- Purpose: Igor window/panel recreation routine for linecut, slice, or region extraction; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management. Purpose: displays waves, images, contours, or graph overlays. Usage: call `Help_MDC_Data_ploter()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10402`

### `Help_MDC_EDC()`

- Workflow group: ARPES Template and Momentum Conversion
- Purpose: Igor window/panel recreation routine for ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management. Usage: call `Help_MDC_EDC()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10505`

### `Help_MDCfit()`

- Workflow group: ARPES Template and Momentum Conversion
- Purpose: Igor window/panel recreation routine for linecut, slice, or region extraction; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management. Purpose: fits or extracts spectral/peak parameters. Usage: call `Help_MDCfit()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10632`

### `Help_Plot_EDC()`

- Workflow group: ARPES Template and Momentum Conversion
- Purpose: Igor window/panel recreation routine for ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management; Igor wave/matrix/cube data operation. Purpose: displays waves, images, contours, or graph overlays. Usage: call `Help_Plot_EDC()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10602`

### `Help_Plot_MDC()`

- Workflow group: ARPES Template and Momentum Conversion
- Purpose: Igor window/panel recreation routine for ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management; Igor wave/matrix/cube data operation. Purpose: displays waves, images, contours, or graph overlays. Usage: call `Help_Plot_MDC()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10617`

### `Help_subtract_EDC_Dploter()`

- Workflow group: ARPES Template and Momentum Conversion
- Purpose: Igor window/panel recreation routine for smoothing, normalization, or background removal; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management. Purpose: displays waves, images, contours, or graph overlays. Usage: call `Help_subtract_EDC_Dploter()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10491`

### `Help_symetrize_EDC_mat()`

- Workflow group: ARPES Template and Momentum Conversion
- Purpose: Igor window/panel recreation routine for symmetry or reflection processing; matrix resampling, scaling, or reshaping; ARPES-style loading, plotting, or momentum conversion. Purpose: applies symmetry, mirror, or reflection operations. Usage: call `Help_symetrize_EDC_mat()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:11301`

### `image_fs_ploter()`

- Workflow group: ARPES Template and Momentum Conversion
- Purpose: Igor window/panel recreation routine for symmetry or reflection processing; graph display, formatting, or window management. Purpose: displays waves, images, contours, or graph overlays. Usage: call `image_fs_ploter()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls. Main internal calls: `rgb()`, `lstyle()`, `lsize()`, `lSize()`, `lStyle()`, `manTick()`.
- Source: `Pierre's Template.ipf:24625`

### `image_fs_ploter2f()`

- Workflow group: ARPES Template and Momentum Conversion
- Purpose: Igor window/panel recreation routine for symmetry or reflection processing; graph display, formatting, or window management. Purpose: displays waves, images, contours, or graph overlays. Usage: call `image_fs_ploter2f()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls. Main internal calls: `lSize()`, `lStyle()`, `rgb()`, `manTick()`, `manMinor()`.
- Source: `Pierre's Template.ipf:24772`

### `image_fs_ploterHex()`

- Workflow group: ARPES Template and Momentum Conversion
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management. Purpose: displays waves, images, contours, or graph overlays. Usage: call `image_fs_ploterHex()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls. Main internal calls: `lStyle()`, `rgb()`, `manTick()`, `manMinor()`.
- Source: `Pierre's Template.ipf:33463`

### `making_fs()`

- Workflow group: ARPES Template and Momentum Conversion
- Purpose: Igor window/panel recreation routine for symmetry or reflection processing; geometric correction, rotation, shear, drift, or strain analysis; ARPES-style loading, plotting, or momentum conversion. Usage: call `making_fs()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls. Main internal calls: `mode()`, `marker()`, `lSize()`, `lStyle()`, `rgb()`, `msize()`.
- Source: `Pierre's Template.ipf:24471`

### `making_fs2f()`

- Workflow group: ARPES Template and Momentum Conversion
- Purpose: Igor window/panel recreation routine for symmetry or reflection processing; geometric correction, rotation, shear, drift, or strain analysis; ARPES-style loading, plotting, or momentum conversion. Usage: call `making_fs2f()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls. Main internal calls: `mode()`, `marker()`, `lSize()`, `lStyle()`, `rgb()`, `msize()`.
- Source: `Pierre's Template.ipf:33307`

### `making_fsHEX()`

- Workflow group: ARPES Template and Momentum Conversion
- Purpose: Igor window/panel recreation routine for geometric correction, rotation, shear, drift, or strain analysis; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management. Usage: call `making_fsHEX()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls. Main internal calls: `mode()`, `marker()`, `lStyle()`, `rgb()`, `msize()`, `manTick()`.
- Source: `Pierre's Template.ipf:32827`

### `mat3d_fs_ploter()`

- Workflow group: ARPES Template and Momentum Conversion
- Purpose: Igor window/panel recreation routine for symmetry or reflection processing; graph display, formatting, or window management; Igor wave/matrix/cube data operation. Purpose: displays waves, images, contours, or graph overlays. Usage: call `mat3d_fs_ploter()` to recreate or bring up the Igor window/panel. Code behavior: creates output waves; opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:24333`

### `mat3dHD_fs_ploter()`

- Workflow group: ARPES Template and Momentum Conversion
- Purpose: Igor window/panel recreation routine for symmetry or reflection processing; graph display, formatting, or window management; Igor wave/matrix/cube data operation. Purpose: displays waves, images, contours, or graph overlays. Usage: call `mat3dHD_fs_ploter()` to recreate or bring up the Igor window/panel. Code behavior: creates output waves; opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:24379`

### `mat3dk_fs_ploter()`

- Workflow group: ARPES Template and Momentum Conversion
- Purpose: Igor window/panel recreation routine for symmetry or reflection processing; graph display, formatting, or window management; Igor wave/matrix/cube data operation. Purpose: displays waves, images, contours, or graph overlays. Usage: call `mat3dk_fs_ploter()` to recreate or bring up the Igor window/panel. Code behavior: creates output waves; opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:24402`

### `mat3dkHD_fs_ploter()`

- Workflow group: ARPES Template and Momentum Conversion
- Purpose: Igor window/panel recreation routine for symmetry or reflection processing; graph display, formatting, or window management; Igor wave/matrix/cube data operation. Purpose: displays waves, images, contours, or graph overlays. Usage: call `mat3dkHD_fs_ploter()` to recreate or bring up the Igor window/panel. Code behavior: creates output waves; opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:24448`

### `mat3dkVD_fs_ploter()`

- Workflow group: ARPES Template and Momentum Conversion
- Purpose: Igor window/panel recreation routine for symmetry or reflection processing; graph display, formatting, or window management; Igor wave/matrix/cube data operation. Purpose: displays waves, images, contours, or graph overlays. Usage: call `mat3dkVD_fs_ploter()` to recreate or bring up the Igor window/panel. Code behavior: creates output waves; opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:24425`

### `mat3dVD_fs_ploter()`

- Workflow group: ARPES Template and Momentum Conversion
- Purpose: Igor window/panel recreation routine for symmetry or reflection processing; graph display, formatting, or window management; Igor wave/matrix/cube data operation. Purpose: displays waves, images, contours, or graph overlays. Usage: call `mat3dVD_fs_ploter()` to recreate or bring up the Igor window/panel. Code behavior: creates output waves; opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:24356`

### `Help_FFT_filter()`

- Workflow group: FFT, QPI, Fourier Filters, Phase, and Lock-In
- Purpose: Igor window/panel recreation routine for FFT, QPI, phase, or lock-in analysis; graph display, formatting, or window management. Purpose: performs Fourier, filtering, phase, or lock-in processing. Usage: call `Help_FFT_filter()` to recreate or bring up the Igor window/panel. Code behavior: performs Fourier-transform or inverse-transform operations; opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10376`

### `AVG_graph()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management; Igor wave/matrix/cube data operation. Usage: call `AVG_graph()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; reads or updates panel controls.
- Source: `Pierre's Template.ipf:12748`

### `background_remover()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for symmetry or reflection processing; smoothing, normalization, or background removal; spectroscopy, superconducting-gap, or vortex-model analysis. Purpose: smooths, normalizes, or removes background/trend components. Usage: call `background_remover()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; writes or exports data; reads or updates panel controls.
- Source: `Pierre's Template.ipf:9221`

### `background_remover_1()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for symmetry or reflection processing; smoothing, normalization, or background removal; ARPES-style loading, plotting, or momentum conversion. Purpose: smooths, normalizes, or removes background/trend components. Usage: call `background_remover_1()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; writes or exports data; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10658`

### `Curv_Panel()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management; Igor wave/matrix/cube data operation. Usage: call `Curv_Panel()` to recreate or bring up the Igor window/panel. Code behavior: reads or updates panel controls.
- Source: `Pierre's Template.ipf:13597`

### `Data_Analysis_BNL()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for geometric correction, rotation, shear, drift, or strain analysis; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management. Usage: call `Data_Analysis_BNL()` to recreate or bring up the Igor window/panel. Code behavior: performs Fourier-transform or inverse-transform operations; opens or updates graph/image displays; smooths wave data; loads data from files or paths; writes or exports data. Main internal calls: `txt()`, `dat()`, `asc()`, `tabLabel()`.
- Source: `Pierre's Template.ipf:155`

### `dataploter()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for FFT, QPI, phase, or lock-in analysis; symmetry or reflection processing; smoothing, normalization, or background removal. Purpose: displays waves, images, contours, or graph overlays. Usage: call `dataploter()` to recreate or bring up the Igor window/panel. Code behavior: performs Fourier-transform or inverse-transform operations; creates output waves; opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; loads data from files or paths.
- Source: `Pierre's Template.ipf:36`

### `dataploter2()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for FFT, QPI, phase, or lock-in analysis; symmetry or reflection processing; smoothing, normalization, or background removal. Purpose: displays waves, images, contours, or graph overlays. Usage: call `dataploter2()` to recreate or bring up the Igor window/panel. Code behavior: performs Fourier-transform or inverse-transform operations; creates output waves; opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; loads data from files or paths.
- Source: `Miscellaneous_Codes.ipf:9644`

### `dataplotersts()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for FFT, QPI, phase, or lock-in analysis; symmetry or reflection processing; smoothing, normalization, or background removal. Purpose: displays waves, images, contours, or graph overlays. Usage: call `dataplotersts()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Miscellaneous_Codes.ipf:389`

### `EMDC_multiDisplay()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management. Purpose: displays waves, images, contours, or graph overlays. Usage: call `EMDC_multiDisplay()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations.
- Source: `Pierre's Template.ipf:11922`

### `Graph3()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management. Usage: call `Graph3()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays.
- Source: `Procedure.ipf:281`

### `Graph_imageforslicer()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for symmetry or reflection processing; linecut, slice, or region extraction; matrix resampling, scaling, or reshaping. Usage: call `Graph_imageforslicer()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:24312`

### `Graph_zoomforCsrSlicer()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for symmetry or reflection processing; linecut, slice, or region extraction; graph display, formatting, or window management. Usage: call `Graph_zoomforCsrSlicer()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations. Main internal calls: `mode()`, `marker()`, `lSize()`, `lStyle()`, `rgb()`, `msize()`.
- Source: `Pierre's Template.ipf:25707`

### `Help_0_to_NaN()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management; Igor wave/matrix/cube data operation. Usage: call `Help_0_to_NaN()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10832`

### `Help_2nd_derivative()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for smoothing, normalization, or background removal; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management. Usage: call `Help_2nd_derivative()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10842`

### `Help_Append_pnts()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management. Purpose: displays waves, images, contours, or graph overlays. Usage: call `Help_Append_pnts()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:11117`

### `HELP_background_remover()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for smoothing, normalization, or background removal; graph display, formatting, or window management; Igor wave/matrix/cube data operation. Purpose: smooths, normalizes, or removes background/trend components. Usage: call `HELP_background_remover()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:9248`

### `help_bad_slices()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for linecut, slice, or region extraction; matrix resampling, scaling, or reshaping; smoothing, normalization, or background removal. Usage: call `help_bad_slices()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; integrates wave data; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10100`

### `Help_Bkgndremover_Add_pnt()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for smoothing, normalization, or background removal; graph display, formatting, or window management. Purpose: smooths, normalizes, or removes background/trend components. Usage: call `Help_Bkgndremover_Add_pnt()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:11330`

### `Help_Bkgndremover_Bkgnd_in()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for smoothing, normalization, or background removal; graph display, formatting, or window management; Igor wave/matrix/cube data operation. Purpose: smooths, normalizes, or removes background/trend components. Usage: call `Help_Bkgndremover_Bkgnd_in()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:11344`

### `Help_bkgndremover_Delete_pnt()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for smoothing, normalization, or background removal; graph display, formatting, or window management. Purpose: smooths, normalizes, or removes background/trend components. Usage: call `Help_bkgndremover_Delete_pnt()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:11361`

### `Help_bkgndremover_Save_backgnd()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for smoothing, normalization, or background removal; graph display, formatting, or window management; Igor wave/matrix/cube data operation. Purpose: smooths, normalizes, or removes background/trend components. Usage: call `Help_bkgndremover_Save_backgnd()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; writes or exports data; reads or updates panel controls.
- Source: `Pierre's Template.ipf:11374`

### `Help_bkgndremover_Save_result()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for smoothing, normalization, or background removal; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management. Purpose: smooths, normalizes, or removes background/trend components. Usage: call `Help_bkgndremover_Save_result()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; writes or exports data; reads or updates panel controls.
- Source: `Pierre's Template.ipf:11388`

### `Help_Bkgndremover_Wave_in()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for linecut, slice, or region extraction; smoothing, normalization, or background removal; graph display, formatting, or window management. Purpose: smooths, normalizes, or removes background/trend components. Usage: call `Help_Bkgndremover_Wave_in()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:11315`

### `Help_Change_stepsize()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for matrix resampling, scaling, or reshaping; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management. Usage: call `Help_Change_stepsize()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; writes or exports data; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10861`

### `Help_channel_spacing()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for linecut, slice, or region extraction; graph display, formatting, or window management. Usage: call `Help_channel_spacing()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10115`

### `Help_Cmbdata()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for smoothing, normalization, or background removal; graph display, formatting, or window management; Igor wave/matrix/cube data operation. Usage: call `Help_Cmbdata()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10126`

### `Help_Combine_all()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management; Igor wave/matrix/cube data operation. Purpose: combines many waves/slices into a map, linecut, or averaged output. Usage: call `Help_Combine_all()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10883`

### `Help_Combine_krange()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management; Igor wave/matrix/cube data operation. Purpose: combines many waves/slices into a map, linecut, or averaged output. Usage: call `Help_Combine_krange()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10900`

### `Help_Combine_range()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management; Igor wave/matrix/cube data operation. Purpose: combines many waves/slices into a map, linecut, or averaged output. Usage: call `Help_Combine_range()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10922`

### `Help_Combine_this_data()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management. Purpose: combines many waves/slices into a map, linecut, or averaged output. Usage: call `Help_Combine_this_data()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10313`

### `help_convert_all_data()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for smoothing, normalization, or background removal; graph display, formatting, or window management. Usage: call `help_convert_all_data()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10147`

### `Help_Cvt_data()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for smoothing, normalization, or background removal; graph display, formatting, or window management. Usage: call `Help_Cvt_data()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10326`

### `Help_data()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for spectroscopy, superconducting-gap, or vortex-model analysis; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management. Usage: call `Help_data()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10337`

### `Help_Data_ploter()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for FFT, QPI, phase, or lock-in analysis; smoothing, normalization, or background removal; ARPES-style loading, plotting, or momentum conversion. Purpose: displays waves, images, contours, or graph overlays. Usage: call `Help_Data_ploter()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10157`

### `Help_Data_type()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management. Usage: call `Help_Data_type()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10196`

### `Help_Delete_all()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management; Igor wave/matrix/cube data operation. Purpose: removes waves/windows/data points or cleans intermediate state. Usage: call `Help_Delete_all()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:11132`

### `Help_Delete_last()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management. Purpose: removes waves/windows/data points or cleans intermediate state. Usage: call `Help_Delete_last()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:11148`

### `Help_Divide_by_FD()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for smoothing, normalization, or background removal; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management. Purpose: displays waves, images, contours, or graph overlays. Usage: call `Help_Divide_by_FD()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10942`

### `Help_Equiv_mat()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management; Igor wave/matrix/cube data operation. Usage: call `Help_Equiv_mat()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10954`

### `Help_FFT_list()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for FFT, QPI, phase, or lock-in analysis; smoothing, normalization, or background removal; graph display, formatting, or window management. Purpose: performs Fourier, filtering, phase, or lock-in processing. Usage: call `Help_FFT_list()` to recreate or bring up the Igor window/panel. Code behavior: performs Fourier-transform or inverse-transform operations; opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; loads data from files or paths; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10206`

### `Help_Find_kF()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for linecut, slice, or region extraction; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management. Usage: call `Help_Find_kF()` to recreate or bring up the Igor window/panel. Code behavior: duplicates or stages waves for downstream processing; opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls; cleans up waves/windows or brings an existing window forward.
- Source: `Pierre's Template.ipf:10552`

### `Help_Initialize()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for FFT, QPI, phase, or lock-in analysis; linecut, slice, or region extraction; smoothing, normalization, or background removal. Usage: call `Help_Initialize()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; smooths wave data; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10226`

### `Help_Keep_minus()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management; Igor wave/matrix/cube data operation. Usage: call `Help_Keep_minus()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10978`

### `Help_Keep_plus()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management; Igor wave/matrix/cube data operation. Usage: call `Help_Keep_plus()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10991`

### `Help_Ln_mat()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management; Igor wave/matrix/cube data operation. Usage: call `Help_Ln_mat()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:11004`

### `Help_Load()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management. Usage: call `Help_Load()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10239`

### `Help_Make_image_data_ploter()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management. Purpose: displays waves, images, contours, or graph overlays. Usage: call `Help_Make_image_data_ploter()` to recreate or bring up the Igor window/panel. Code behavior: creates output waves; opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10390`

### `Help_mat_exp_n()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management; Igor wave/matrix/cube data operation. Usage: call `Help_mat_exp_n()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:11014`

### `Help_NaN0mat3d()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management; Igor wave/matrix/cube data operation. Usage: call `Help_NaN0mat3d()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:11024`

### `Help_NaN_to_0()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management; Igor wave/matrix/cube data operation. Usage: call `Help_NaN_to_0()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:11035`

### `Help_New_band()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management; Igor wave/matrix/cube data operation. Usage: call `Help_New_band()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:11164`

### `Help_NK()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for smoothing, normalization, or background removal; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management. Usage: call `Help_NK()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; loads data from files or paths; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10424`

### `Help_Norm()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for smoothing, normalization, or background removal; graph display, formatting, or window management. Purpose: smooths, normalizes, or removes background/trend components. Usage: call `Help_Norm()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10447`

### `Help_Norm_matrix()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for smoothing, normalization, or background removal; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management. Purpose: smooths, normalizes, or removes background/trend components. Usage: call `Help_Norm_matrix()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:11045`

### `Help_Not_these_points()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for symmetry or reflection processing; spectroscopy, superconducting-gap, or vortex-model analysis; ARPES-style loading, plotting, or momentum conversion. Usage: call `Help_Not_these_points()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:11055`

### `Help_num_of_band()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management; Igor wave/matrix/cube data operation. Usage: call `Help_num_of_band()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:11180`

### `Help_Open_data()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for FFT, QPI, phase, or lock-in analysis; linecut, slice, or region extraction; smoothing, normalization, or background removal. Usage: call `Help_Open_data()` to recreate or bring up the Igor window/panel. Code behavior: performs Fourier-transform or inverse-transform operations; opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; loads data from files or paths; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10254`

### `Help_Open_select()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management; Igor wave/matrix/cube data operation. Usage: call `Help_Open_select()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; loads data from files or paths; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10284`

### `Help_Open_this_data()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management. Usage: call `Help_Open_this_data()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; loads data from files or paths; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10459`

### `Help_Plot_Point_reader()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management. Purpose: extracts values, metadata, cursor information, or derived waves. Usage: call `Help_Plot_Point_reader()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:11198`

### `Help_Point_reader()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management. Purpose: extracts values, metadata, cursor information, or derived waves. Usage: call `Help_Point_reader()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:11088`

### `Help_Point_reader_Show_table()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management; Igor wave/matrix/cube data operation. Purpose: extracts values, metadata, cursor information, or derived waves. Usage: call `Help_Point_reader_Show_table()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:11241`

### `Help_Point_reader_Sort()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management; Igor wave/matrix/cube data operation. Purpose: extracts values, metadata, cursor information, or derived waves. Usage: call `Help_Point_reader_Sort()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:11257`

### `Help_raw_data()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: ????????????????????????????????????????????????????????????????????????????????????????????????????? ????????????????????????????????????????????????????????????????????????????????????????????????????? ???????????????????????????????????????????????????????? Usage: call `Help_raw_data()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:9378`

### `Help_Read_point()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management; Igor wave/matrix/cube data operation. Purpose: extracts values, metadata, cursor information, or derived waves. Usage: call `Help_Read_point()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:11216`

### `Help_Remove_background_Dploter()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for smoothing, normalization, or background removal; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management. Purpose: displays waves, images, contours, or graph overlays. Usage: call `Help_Remove_background_Dploter()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; loads data from files or paths; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10472`

### `Help_Rotate_image()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for Nanonis/STM data loading or map conversion; geometric correction, rotation, shear, drift, or strain analysis; graph display, formatting, or window management. Purpose: applies geometric correction or extracts deformation/strain information. Usage: call `Help_Rotate_image()` to recreate or bring up the Igor window/panel. Code behavior: creates output waves; opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:11272`

### `Help_Smooth_factor()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for smoothing, normalization, or background removal; graph display, formatting, or window management. Purpose: smooths, normalizes, or removes background/trend components. Usage: call `Help_Smooth_factor()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; smooths wave data; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10297`

### `Help_Smooth_mat()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for smoothing, normalization, or background removal; graph display, formatting, or window management; Igor wave/matrix/cube data operation. Purpose: smooths, normalizes, or removes background/trend components. Usage: call `Help_Smooth_mat()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; smooths wave data; reads or updates panel controls.
- Source: `Pierre's Template.ipf:11287`

### `Help_tab_matrices()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for symmetry or reflection processing; geometric correction, rotation, shear, drift, or strain analysis; smoothing, normalization, or background removal. Usage: call `Help_tab_matrices()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10707`

### `Help_tab_Misc()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for geometric correction, rotation, shear, drift, or strain analysis; smoothing, normalization, or background removal; graph display, formatting, or window management. Usage: call `Help_tab_Misc()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10811`

### `Help_tab_Presentation()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for symmetry or reflection processing; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management. Usage: call `Help_tab_Presentation()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10785`

### `help_tab_traces()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for symmetry or reflection processing; geometric correction, rotation, shear, drift, or strain analysis; smoothing, normalization, or background removal. Usage: call `help_tab_traces()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10759`

### `Help_Tools()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management. Usage: call `Help_Tools()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:10685`

### `Mat3d_slicer()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for symmetry or reflection processing; linecut, slice, or region extraction; smoothing, normalization, or background removal. Usage: call `Mat3d_slicer()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls. Main internal calls: `margin()`.
- Source: `Pierre's Template.ipf:24595`

### `movie_maker()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: NOTE: Global variables are stored in a new data folder called "movie_maker" The data folder that is created can cause problems when loading data because of the way Pierre's macro loads data. The data folder MUST be killed before any more data is loaded. If you Usage: call `movie_maker()` to recreate or bring up the Igor window/panel. Code behavior: creates output waves; duplicates or stages waves for downstream processing; opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; creates, switches, or removes Igor data folders. Main internal calls: `movie_maker_startup_warning()`, `do_movie_maker_image()`, `doInsetYesNo()`.
- Source: `Pierre's Template.ipf:36350`

### `movie_maker_startup_warning()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for graph display, formatting, or window management; Igor wave/matrix/cube data operation. Usage: call `movie_maker_startup_warning()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls.
- Source: `Pierre's Template.ipf:36702`

### `Point_reader()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for smoothing, normalization, or background removal; graph display, formatting, or window management. Purpose: extracts values, metadata, cursor information, or derived waves. Usage: call `Point_reader()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; reads or updates panel controls.
- Source: `Pierre's Template.ipf:64`

### `predict_cuts()`

- Workflow group: Smart Display, Graph Formatting, and Figure Tools
- Purpose: Igor window/panel recreation routine for symmetry or reflection processing; linecut, slice, or region extraction; graph display, formatting, or window management. Purpose: displays waves, images, contours, or graph overlays. Usage: call `predict_cuts()` to recreate or bring up the Igor window/panel. Code behavior: opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; reads or updates panel controls. Main internal calls: `lSize()`, `lStyle()`, `rgb()`, `lblMargin()`, `manTick()`, `manMinor()`.
- Source: `Pierre's Template.ipf:24218`

### `Kong_Igor_panel()`

- Workflow group: Start Here: Main Panel, Menus, and Window Entries
- Purpose: Igor window/panel recreation routine for geometric correction, rotation, shear, drift, or strain analysis; ARPES-style loading, plotting, or momentum conversion; graph display, formatting, or window management. Usage: call `Kong_Igor_panel()` to recreate or bring up the Igor window/panel. Code behavior: performs Fourier-transform or inverse-transform operations; opens or updates graph/image displays; formats graph axes, labels, colors, or annotations; smooths wave data; differentiates wave data. Main internal calls: `KP_EnsureNewColorTables()`, `KP_EnsureStartupGlobals()`, `txt()`, `dat()`, `asc()`, `tabLabel()`.
- Source: `Kong_Igor_panel.ipf:32`

