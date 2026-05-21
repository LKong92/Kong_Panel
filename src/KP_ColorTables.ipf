#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3
#pragma DefaultTab={3,20,4}

Static Constant KP_EXPECTED_COLOR_TABLES = 47
Static StrConstant KP_COLOR_TABLE_FILE = "KP_NewColorTables.itx"

// Public entry point used by Kong_Igor_panel().
// It restores the color waves that were embedded in the old template experiment.
Function KP_EnsureNewColorTables()
	DFREF dfrSav = GetDataFolderDFR()
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:NewColortable
	SetDataFolder root:Packages:NewColortable

	if (KP_HaveNewColorTables())
		SetDataFolder dfrSav
		return 1
	endif

	// Try the common install layouts used by the GitHub source package.
	String basePath = SpecialDirPath("Igor Pro User Files", 0, 0, 0)
	Variable loaded = KP_LoadNewColorTablesFrom(basePath + "User Procedures:KongPanel:")
	if (!loaded)
		loaded = KP_LoadNewColorTablesFrom(basePath + "User Procedures:src:")
	endif
	if (!loaded)
		loaded = KP_LoadNewColorTablesFrom(basePath + "User Procedures:")
	endif
	if (!loaded)
		// Try looking in the same folder as this procedure file.
		String thisProcFileFullPath = FunctionPath("")
		if (strlen(thisProcFileFullPath) > 0)
			// Strip off the file name from the full path
			String thisProcFileDirectory = ParseFilePath(1, thisProcFileFullPath, ":", 1, 0)
			loaded = KP_LoadNewColorTablesFrom(thisProcFileDirectory)
		endif
	endif

	SetDataFolder dfrSav
	if (!loaded)
		DoAlert 0, "KP_NewColorTables.itx was not found. Put it next to Load_KongPanel.ipf, or keep the source folder as User Procedures:KongPanel: or User Procedures:src:."
	endif
	return loaded
End

Static Function KP_HaveNewColorTables()
	if (!DataFolderExists("root:Packages:NewColortable"))
		return 0
	endif

	Variable count = ItemsInList(WaveList("*", ";", "", root:Packages:NewColortable:))
	Variable hasRequired = WaveExists(root:Packages:NewColortable:Cividis)
	hasRequired = hasRequired && WaveExists(root:Packages:NewColortable:dvg_seismic)
	hasRequired = hasRequired && WaveExists(root:Packages:NewColortable:Viridis)
	return count >= KP_EXPECTED_COLOR_TABLES && hasRequired
End

Static Function KP_LoadNewColorTablesFrom(folderPath)
	String folderPath

	// LoadWave/T preserves the Igor Text wave definitions exported from template.pxp.
	NewPath/O/Q/Z KPNewColorTablePath, folderPath
	if (V_Flag != 0)
		return 0
	endif
	
	// Test that the destination file exists.
	GetFileFolderInfo/P=KPNewColorTablePath/Z/Q KP_COLOR_TABLE_FILE
	if (V_Flag != 0)
		return 0
	endif	

	SetDataFolder root:Packages:NewColortable
	LoadWave/T/O/Q/P=KPNewColorTablePath KP_COLOR_TABLE_FILE
	return KP_HaveNewColorTables()
End
