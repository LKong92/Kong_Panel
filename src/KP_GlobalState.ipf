#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3
#pragma DefaultTab={3,20,4}

Function KP_EnsureRootGlobalVariable(name, defaultValue)
	String name
	Variable defaultValue

	String path = "root:" + name
	NVAR/Z existing = $path
	if (!NVAR_Exists(existing))
		Variable/G $path = defaultValue
	endif
End

Function KP_EnsureRootGlobalString(name, defaultValue)
	String name
	String defaultValue

	String path = "root:" + name
	SVAR/Z existing = $path
	if (!SVAR_Exists(existing))
		String/G $path = defaultValue
	endif
End

Function KP_EnsurePhysicalConstants()
	// Common SI constants used by modeling and command-line calculations.
	Variable/G root:q0 = 1.602176634e-19		// elementary charge [C]
	Variable/G root:h = 6.62607015e-34		// Planck constant [J s]
	Variable/G root:G0 = 3.87404586493e-5	// conductance quantum e^2/h [S]
	Variable/G root:muB = 9.2740100783e-24	// Bohr magneton [J/T]
	Variable/G root:kB = 1.380649e-23		// Boltzmann constant [J/K]
	Variable/G root:eV = 1.602176634e-19	// electron volt [J]
	Variable/G root:meV = 1.602176634e-22	// millielectron volt [J]
	Variable/G root:m0 = 9.1093837015e-31	// electron mass [kg]
	Variable/G root:epslon0 = 8.8541878128e-12	// vacuum permittivity [F/m]; keeps the historical KP spelling
End

Function KP_EnsureTemplateRootGlobals()
	// Recreate root-level globals that were saved in template.pxp but are not carried by source files.
	KP_EnsureRootGlobalVariable("topgraphnum", 0)
	KP_EnsureRootGlobalVariable("topimagemin", 3.39009e-35)
	KP_EnsureRootGlobalVariable("topimagemax", 4747.39)
	KP_EnsureRootGlobalVariable("topimageminratio", 2.38308e-44)
	KP_EnsureRootGlobalVariable("topimagemaxratio", 0.0432301)
	KP_EnsureRootGlobalVariable("colorsetedc", 5)
	KP_EnsureRootGlobalVariable("colorsetedc2", 6)
	KP_EnsureRootGlobalVariable("colorinverseedc", 1)
	KP_EnsureRootGlobalVariable("topgraphnum1", 0)
	KP_EnsureRootGlobalVariable("topimagemin1", 0.0234619)
	KP_EnsureRootGlobalVariable("topimagemax1", 0.120291)
	KP_EnsureRootGlobalVariable("topimageminratio1", 0)
	KP_EnsureRootGlobalVariable("topimagemaxratio1", 1)
	KP_EnsureRootGlobalVariable("colorindexuser", 1)
	KP_EnsureRootGlobalVariable("colorsetedc3", 47)
	KP_EnsureRootGlobalVariable("typeofdata", 4)
	KP_EnsureRootGlobalVariable("minsetvar", 0)
	KP_EnsureRootGlobalVariable("maxsetvar", 0)
	KP_EnsureRootGlobalVariable("zn_cons", 2)
	KP_EnsureRootGlobalVariable("V_Flag", 0)

	KP_EnsureRootGlobalString("topgraphimage", "Zslice_g2_padFFT_Modula")
	KP_EnsureRootGlobalString("topgraphname", "Graph11")
	KP_EnsureRootGlobalString("topgraphcolor", "root:Packages:NewColortable:dvg_bwr_20_95_c54")
	KP_EnsureRootGlobalString("topgraphcolorinv", "0")
	KP_EnsureRootGlobalString("topgraphimage1", "")
	KP_EnsureRootGlobalString("topgraphname1", "")
	KP_EnsureRootGlobalString("topgraphcolor1", "Rainbow256")
	KP_EnsureRootGlobalString("topgraphcolorinv1", "0")
	KP_EnsureRootGlobalString("S_info", "ProcGlobal#KMFileOpenHook;")
End

Function KP_EnsureStartupGlobals()
	KP_EnsurePhysicalConstants()
	KP_EnsureTemplateRootGlobals()
End
