#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3
#pragma DefaultTab={3,20,4}

// Minimal Nanonis loaders used by Kong Panel.
// This keeps the KP auto linecut/grid/topography workflow independent of KM.
// The functions keep the original KP wave naming conventions so existing panel
// callbacks can continue to find topo, grid, and linecut data in root folders.

Static StrConstant KP_NANONIS_SETTINGS_DF = "settings"

Function/WAVE KP_LoadNanonisData(pathStr)
	String pathStr

	// Empty input opens Igor's native picker, matching the old KM-assisted flow.
	if (strlen(pathStr) == 0)
		GetFileFolderInfo/Q/Z=2
		if (V_Flag)
			return $""
		endif
		pathStr = S_path
	endif

	GetFileFolderInfo/Q/Z pathStr
	if (V_Flag)
		Print "**KP_LoadNanonisData: file or folder not found: " + pathStr
		return $""
	endif

	if (V_isAliasShortcut)
		return KP_LoadNanonisData(S_aliasPath)
	endif

	// Folder drops are loaded recursively; file drops branch by Nanonis extension.
	if (V_isFolder)
		return KP_LoadNanonisFolder(pathStr)
	endif

	if (!V_isFile)
		return $""
	endif

	String fileName = ParseFilePath(0, pathStr, ":", 1, 0)
	String fileNameNoExt = ParseFilePath(3, pathStr, ":", 0, 0)
	String extStr = LowerStr(ParseFilePath(4, pathStr, ":", 0, 0))
	String newDfName = KP_UniqueRootDataFolderName(fileNameNoExt)

	DFREF dfrSav = GetDataFolderDFR()
	NewDataFolder/O/S root:$newDfName
	String/G root:KP_LastLoadedDataFolder = newDfName
	KP_RecordLoadedFile(fileName)

	Wave/Z w
	strswitch (extStr)
		case "3ds":
			Wave/WAVE w3ds = KP_LoadNanonis3ds(pathStr)
			SetDataFolder dfrSav
			if (WaveExists(w3ds))
				return w3ds
			endif
			break
		case "sxm":
		case "nsp":
			Wave/WAVE wsxm = KP_LoadNanonisSxmNsp(pathStr)
			SetDataFolder dfrSav
			if (WaveExists(wsxm))
				return wsxm
			endif
			break
		default:
			Print "**KP_LoadNanonisData: unsupported extension for " + fileName
			break
	endswitch

	SetDataFolder dfrSav
	KillDataFolder/Z root:$newDfName
	return $""
End

Function/WAVE KP_LoadNanonisFolder(pathStr)
	String pathStr

	String pathName = UniqueName("KP_NanonisPath", 12, 0)
	NewPath/Q/Z $pathName, pathStr
	if (V_Flag)
		return $""
	endif

	Variable i, n
	n = ItemsInList(IndexedDir($pathName, -1, 0))
	for (i = 0; i < n; i += 1)
		KP_LoadNanonisData(IndexedDir($pathName, i, 1))
	endfor

	n = ItemsInList(IndexedFile($pathName, -1, "????"))
	for (i = 0; i < n; i += 1)
		String childPath = ParseFilePath(2, pathStr, ":", 0, 0) + IndexedFile($pathName, i, "????")
		KP_LoadNanonisData(childPath)
	endfor
	KillPath/Z $pathName
	return $""
End

Function/S KP_UniqueRootDataFolderName(baseName)
	String baseName

	String candidate = baseName
	Variable i = 1
	do
		if (!DataFolderExists("root:" + PossiblyQuoteName(candidate)))
			return candidate
		endif
		candidate = baseName + "_" + num2str(i)
		i += 1
	while (1)
End

Function/S KP_GetLastLoadedNanonisFolder()
	SVAR/Z last = root:KP_LastLoadedDataFolder
	if (SVAR_Exists(last) && strlen(last) && DataFolderExists("root:" + PossiblyQuoteName(last)))
		return last
	endif
	return StringFromList(ItemsInList(DataFolderList("*", ";", root:)) - 1, DataFolderList("*", ";", root:))
End

Function KP_RecordLoadedFile(fileName)
	String fileName

	Wave/T/Z fileNameWave = root:File_Name
	if (!WaveExists(fileNameWave))
		Make/N=0/T root:File_Name
		Wave/T fileNameWave = root:File_Name
	endif
	Variable n = DimSize(fileNameWave, 0)
	Redimension/N=(n + 1) fileNameWave
	fileNameWave[n] = fileName
End

Function KP_NanonisCleanup()
	// KM used this hook to unload itself. KP's local loader has no persistent hooks.
	return 0
End

Function/WAVE KP_LoadNanonis3ds(pathStr)
	String pathStr

	DFREF dfrSav = GetDataFolderDFR()
	NewDataFolder/O/S $KP_NANONIS_SETTINGS_DF
	STRUCT KP_Nanonis3dsHeader s
	// Header strings are parsed into a compact structure before GBLoadWave reads
	// the binary body, which keeps data loading independent of KM internals.
	KP_LoadNanonis3dsGetHeader(pathStr, s)

	SetDataFolder dfrSav
	Wave/WAVE resw = KP_LoadNanonis3dsGetData(pathStr, s)
	return resw
End

Static Function KP_LoadNanonis3dsGetHeader(pathStr, s)
	String pathStr
	STRUCT KP_Nanonis3dsHeader &s

	s.headerSize = KP_NanonisCommonGetHeader(pathStr)

	Variable xpnts, ypnts
	Variable xcenter, ycenter, xscale, yscale, angle
	SVAR/Z gridDim = 'Grid dim'
	SVAR/Z gridSettings = 'Grid settings'
	SVAR/Z fixedParam = 'Fixed parameters'
	SVAR/Z expParam = 'Experiment parameters'
	sscanf gridDim, "%d x %d", xpnts, ypnts
	sscanf gridSettings, "%f;%f;%f;%f;%f", xcenter, ycenter, xscale, yscale, angle

	s.xpnts = xpnts
	s.ypnts = ypnts
	s.zpnts = NumVarOrDefault("Points", NaN)
	s.xcenter = xcenter
	s.ycenter = ycenter
	s.xscale = xscale
	s.yscale = yscale
	s.angle = angle
	s.driveamp = NumVarOrDefault(":'Lock-in':Amplitude", NaN)
	s.modulated = StrVarOrDefault(":'Lock-in':'Modulated signal'", "")
	s.paramList = fixedParam + ";" + expParam
	s.chanList = StrVarOrDefault("Channels", "")
	Wave/Z s.mlsw = 'multiline settings'
End

Static Structure KP_Nanonis3dsHeader
	Variable xpnts, ypnts, zpnts
	Variable xcenter, ycenter, xscale, yscale, angle
	Variable driveamp
	String modulated
	String paramList
	String chanList
	Variable headerSize
	Wave mlsw
EndStructure

Static Function/WAVE KP_LoadNanonis3dsGetData(pathStr, s)
	String pathStr
	STRUCT KP_Nanonis3dsHeader &s

	String fileName = ParseFilePath(3, pathStr, ":", 0, 0)

	GBLoadWave/O/Q/N=KP_tmp3ds/T={2,4}/S=(s.headerSize)/W=1 pathStr
	Wave w = KP_tmp3ds0
	Redimension/N=(ItemsInList(s.paramList) + ItemsInList(s.chanList) * s.zpnts, s.xpnts, s.ypnts) w

	Wave stmw = KP_LoadNanonis3dsGetDataParam(w, fileName, s)
	Wave/T namew = KP_LoadNanonis3dsGetDataWaveNames(fileName, s.chanList)
	Wave/WAVE specw = KP_LoadNanonis3dsGetDataSpec(w, namew, s)

	if (GetKeyState(1) & 4)
		Make/N=(1 + numpnts(specw))/WAVE/FREE refw
		refw[0] = {stmw}
		refw[1,] = specw[p - 1]
	else
		Wave/WAVE avgw = KP_NanonisCommonDataAvg("_bwd")
		Make/N=(1 + numpnts(avgw))/WAVE/FREE refw
		refw[0] = {stmw}
		refw[1,] = avgw[p - 1]
	endif

	KillWaves/Z w
	return refw
End

Static Function/WAVE KP_LoadNanonis3dsGetDataParam(w, fileName, s)
	Wave w
	String fileName
	STRUCT KP_Nanonis3dsHeader &s

	Variable xIndex = WhichListItem("X (m)", s.paramList)
	Variable yIndex = WhichListItem("Y (m)", s.paramList)
	Variable zIndex = WhichListItem("Z (m)", s.paramList)

	DFREF dfrSav = GetDataFolderDFR()
	NewDataFolder/O/S pos

	Make/N=5/FREE xw = {-1, 1, 1, -1, -1}
	Make/N=5/FREE yw = {-1, -1, 1, 1, -1}
	Make/N=5 scan_x = ((xw * cos(s.angle / 180 * pi) + yw * sin(s.angle / 180 * pi)) * s.xscale / 2 + s.xcenter) * 1e10
	Make/N=5 scan_y = ((-xw * sin(s.angle / 180 * pi) + yw * cos(s.angle / 180 * pi)) * s.yscale / 2 + s.ycenter) * 1e10

	Make/N=(s.xpnts * s.ypnts) stspos_x = w[xIndex][mod(p, s.xpnts)][floor(p / s.ypnts)] * 1e10
	Make/N=(s.xpnts * s.ypnts) stspos_y = w[yIndex][mod(p, s.xpnts)][floor(p / s.ypnts)] * 1e10

	SetDataFolder dfrSav

	if (s.ypnts == 1)
		Make/N=(s.xpnts) $(fileName + "_Z")/WAVE=topow
		topow[] = w[zIndex][p] * 1e10
	else
		Make/N=(s.xpnts, s.ypnts) $(fileName + "_Z")/WAVE=topow
		MultiThread topow[][] = w[zIndex][p][q] * 1e10
	endif
	SetScale d WaveMin(topow), WaveMax(topow), "A", topow
	SetScale/P x (s.xcenter - s.xscale / 2 + s.xscale / s.xpnts / 2) * 1e10, s.xscale / s.xpnts * 1e10, "A", topow
	SetScale/P y (s.ycenter - s.yscale / 2 + s.yscale / s.ypnts / 2) * 1e10, s.yscale / s.ypnts * 1e10, "A", topow

	return topow
End

Static Function/WAVE KP_LoadNanonis3dsGetDataWaveNames(fileName, chanList)
	String fileName, chanList

	Make/N=(ItemsInList(chanList))/T/FREE namew
	String nameStr
	Variable i
	for (i = 0; i < ItemsInList(chanList); i += 1)
		nameStr = StringFromList(i, chanList)
		nameStr = ReplaceString(" (A)", nameStr, "")
		nameStr = ReplaceString(" (V)", nameStr, "")
		nameStr = ReplaceString(" omega", nameStr, "")
		nameStr = ReplaceString(" [bwd]", nameStr, "_bwd")
		nameStr = ReplaceString(" ", nameStr, "_")
		namew[i] = fileName + "_" + nameStr
	endfor
	return namew
End

Static Function/WAVE KP_LoadNanonis3dsGetDataSpec(w, namew, s)
	Wave w
	Wave/T namew
	STRUCT KP_Nanonis3dsHeader &s

	Variable startIndex = WhichListItem("Sweep Start", s.paramList)
	Variable endIndex = WhichListItem("Sweep End", s.paramList)
	Variable biasStart = w[startIndex][0][0]
	Variable biasEnd = w[endIndex][0][0]
	Variable nchan = ItemsInList(s.chanList)
	Variable nparam = ItemsInList(s.paramList)
	Variable i, v

	Make/N=(nchan)/FREE/WAVE refw
	for (i = 0; i < nchan; i += 1)
		Make/N=(s.xpnts, s.ypnts, s.zpnts) $namew[i]/WAVE=specw
		v = nparam + i * s.zpnts
		MultiThread specw[][][] = w[v + r][p][q]

		if (s.ypnts == 1)
			SetScale/I x, 0, s.xscale * 1e10, "A", specw
		else
			SetScale/P x (s.xcenter - s.xscale / 2 + s.xscale / s.xpnts / 2) * 1e10, s.xscale / s.xpnts * 1e10, "A", specw
			SetScale/P y (s.ycenter - s.yscale / 2 + s.yscale / s.ypnts / 2) * 1e10, s.yscale / s.ypnts * 1e10, "A", specw
		endif

		if (WaveExists(s.mlsw))
			KP_LoadNanonis3dsSetMLSBias(specw, s.mlsw)
		else
			SetScale/I z, biasStart * 1e3, biasEnd * 1e3, "mV", specw
			if (biasStart > biasEnd)
				Reverse/DIM=2 specw
			endif
		endif

		KP_NanonisCommonConversion(specw, driveamp=s.driveamp, modulated=s.modulated)
		refw[i] = specw
	endfor
	return refw
End

Static Function KP_LoadNanonis3dsSetMLSBias(specw, mlsw)
	Wave specw, mlsw

	Variable segIndex, segStart, segEnd, segSteps, energy, layer
	Variable i, last
	for (segIndex = 0, layer = 0; segIndex < DimSize(mlsw, 0); segIndex += 1)
		segStart = mlsw[segIndex][0]
		segEnd = mlsw[segIndex][1]
		segSteps = mlsw[segIndex][4]
		last = (segIndex == DimSize(mlsw, 0) - 1) ? segSteps : segSteps - 1
		for (i = 0; i < last; i += 1, layer += 1)
			energy = segStart + (segEnd - segStart) / (segSteps - 1) * i
			SetDimLabel 2, layer, $num2str(energy * 1e3), specw
		endfor
	endfor
End

Function/WAVE KP_LoadNanonis3dsGetMLSBias(srcw, dim)
	Wave srcw
	Variable dim

	Variable nz = DimSize(srcw, 2)
	if (dim == 1)
		Make/N=(nz)/FREE resw = str2num(GetDimLabel(srcw, 2, p))
	else
		Make/N=(nz)/FREE tbw = str2num(GetDimLabel(srcw, 2, p))
		Make/N=(nz + 1)/FREE resw = (tbw[p - 1] + tbw[p]) / 2
		resw[0] = tbw[0] * 2 - resw[1]
		resw[nz] = tbw[nz - 1] * 2 - resw[nz - 1]
	endif
	return resw
End

Function KP_LoadNanonis3dsIsMLSBias(w)
	Wave w
	return strlen(GetDimLabel(w, 2, 0)) > 0
End

Function KP_LoadNanonis3dsCopyMLSBias(srcw, destw)
	Wave srcw, destw

	Variable i, nz = DimSize(srcw, 2)
	for (i = 0; i < nz; i += 1)
		SetDimLabel 2, i, $GetDimLabel(srcw, 2, i), destw
	endfor
End

Function/WAVE KP_LoadNanonisSxmNsp(pathStr)
	String pathStr

	DFREF dfrSav = GetDataFolderDFR()
	NewDataFolder/O/S $KP_NANONIS_SETTINGS_DF
	STRUCT KP_NanonisSxmNspHeader s
	KP_LoadNanonisSxmNspGetHeader(pathStr, s)

	SetDataFolder dfrSav
	if (s.type == 0)
		Wave/WAVE sxm = KP_LoadNanonisSXMGetData(pathStr, s)
		return sxm
	elseif (s.type == 1)
		Wave nsp = KP_LoadNanonisNSPGetData(pathStr, s)
		return nsp
	endif
	return $""
End

Static Function KP_LoadNanonisSxmNspGetHeader(pathStr, s)
	String pathStr
	STRUCT KP_NanonisSxmNspHeader &s

	Variable refNum, subFolder
	Variable overwritten = 0
	String buffer, name
	DFREF dfrSav = GetDataFolderDFR()

	Open/R/T="????" refNum as pathStr
	FReadLine refNum, buffer
	do
		name = buffer[1, strlen(buffer) - 3]
		strswitch (name)
			case "Z-CONTROLLER":
				NewDataFolder/O/S $name
				KP_LoadNanonisSXMGetHeaderZC(refNum)
				SetDataFolder dfrSav
				break
			case "DATA_INFO":
				Wave/T s.chanInfo = KP_LoadNanonisSXMGetHeaderDI(pathStr, refNum)
				break
			default:
				Variable n = strsearch(name, ">", 0)
				subFolder = (n != -1)
				if (subFolder)
					if (!CmpStr(name[0, n - 1], "Z-Controller") && !overwritten)
						KillDataFolder/Z $"Z-CONTROLLER"
						overwritten = 1
					endif
					NewDataFolder/O/S $(name[0, n - 1])
					name = name[n + 1, strlen(name) - 1]
				endif
				FReadLine refNum, buffer
				KP_NanonisCommonVariableString(name, buffer[0, strlen(buffer) - 2])
				if (subFolder)
					SetDataFolder dfrSav
				endif
				break
		endswitch
		FReadLine refNum, buffer
	while (CmpStr(buffer, ":SCANIT_END:\r") && CmpStr(buffer, ":HEADER_END:\r"))

	if (NumVarOrDefault("NANONIS_VERSION", 0))
		s.type = 0
	elseif (NumVarOrDefault("SPECTRUM_VERSION", 0))
		s.type = 1
	endif

	s.headerSize = KP_LoadNanonisSxmNspGetHeaderEnd(refNum)
	Close refNum

	if (s.type == 0)
		KP_LoadNanonisSXMGetHeaderCvt(s)
	elseif (s.type == 1)
		KP_LoadNanonisNSPGetHeaderCvt(s)
	endif
End

Static Function KP_LoadNanonisSXMGetHeaderZC(refNum)
	Variable refNum

	Variable i
	String buffer
	FReadLine refNum, buffer
	String names = buffer[1, strlen(buffer) - 2]
	FReadLine refNum, buffer
	String values = buffer[1, strlen(buffer) - 2]
	for (i = 0; i < ItemsInList(names, "\t"); i += 1)
		KP_NanonisCommonVariableString(StringFromList(i, names, "\t"), StringFromList(i, values, "\t"))
	endfor
End

Static Function/WAVE KP_LoadNanonisSXMGetHeaderDI(pathStr, refNum)
	String pathStr
	Variable refNum

	String fileName = ParseFilePath(3, pathStr, ":", 0, 0)
	String s0, s1, s2, buffer
	Variable n

	Make/N=(0, 3)/T/FREE infow
	FReadLine refNum, buffer
	FReadLine refNum, buffer
	do
		n = DimSize(infow, 0)
		Redimension/N=(n + 1, -1) infow
		sscanf buffer, "%*[\t]%*[0-9]%*[\t]%s%*[\t]%s%*[\t]%s", s0, s1, s2
		infow[n][0] = fileName + "_" + ReplaceString(" ", s0, "_")
		infow[n][1] = s1
		infow[n][2] = s2
		FReadLine refNum, buffer
	while (CmpStr(buffer, "\r"))
	return infow
End

Static Function KP_LoadNanonisSxmNspGetHeaderEnd(refNum)
	Variable refNum

	Make/N=2/B/FREE tw
	do
		FBinRead/B=3/F=1 refNum, tw
		if (tw[0] == 0x1A && tw[1] == 0x04)
			break
		elseif (tw[1] == 0x1A)
			FStatus refNum
			FSetPos refNum, V_filePos - 1
		endif
	while (1)

	FStatus refNum
	return V_filePos
End

Static Function KP_LoadNanonisSXMGetHeaderCvt(s)
	STRUCT KP_NanonisSxmNspHeader &s

	SVAR REC_DATE, REC_TIME
	String dd, mm, yy
	sscanf REC_DATE, "%2s.%2s.%4s", dd, mm, yy
	String/G 'start time' = yy + "/" + mm + "/" + dd + " " + REC_TIME

	NVAR ACQ_TIME
	Variable/G 'acquisition time (s)' = ACQ_TIME

	SVAR SCAN_PIXELS, SCAN_RANGE, SCAN_OFFSET
	Variable/G '# pixels', '# lines'
	sscanf SCAN_PIXELS, "%d%d", '# pixels', '# lines'
	Variable/G 'width (m)', 'height (m)'
	sscanf SCAN_RANGE, "%f%f", 'width (m)', 'height (m)'
	Variable/G 'center x (m)', 'center y (m)'
	sscanf SCAN_OFFSET, "%f%f", 'center x (m)', 'center y (m)'

	NVAR SCAN_ANGLE
	Variable/G 'angle (deg)' = SCAN_ANGLE
	SVAR SCAN_DIR
	String/G direction = SCAN_DIR
	NVAR BIAS
	Variable/G 'bias (V)' = BIAS

	KillStrings/Z REC_DATE, REC_TIME, SCAN_PIXELS, SCAN_RANGE, SCAN_OFFSET, SCAN_DIR
	KillVariables/Z ACQ_TIME, SCAN_ANGLE, BIAS

	s.xpnts = '# pixels'
	s.ypnts = '# lines'
	s.xscale = 'width (m)' * 1e10
	s.yscale = 'height (m)' * 1e10
	s.xcenter = 'center x (m)' * 1e10
	s.ycenter = 'center y (m)' * 1e10
	s.direction = stringmatch(direction, "down")
End

Static Function KP_LoadNanonisNSPGetHeaderCvt(s)
	STRUCT KP_NanonisSxmNspHeader &s

	NVAR DATASIZEROWS, DATASIZECOLS, DELTA_f
	s.xpnts = DATASIZEROWS
	s.ypnts = DATASIZECOLS
	s.yscale = DELTA_f

	SVAR START_DATE, START_TIME, END_DATE, END_TIME
	Variable day, month, year, hour, minute, second
	sscanf START_DATE, "%d.%d.%d", day, month, year
	sscanf START_TIME, "%d:%d:%d", hour, minute, second
	s.starttime = date2secs(year, month, day) + hour * 3600 + minute * 60 + second
	sscanf END_DATE, "%d.%d.%d", day, month, year
	sscanf END_TIME, "%d:%d:%d", hour, minute, second
	s.endtime = date2secs(year, month, day) + hour * 3600 + minute * 60 + second
End

Static Structure KP_NanonisSxmNspHeader
	uint16 xpnts, ypnts
	Variable xcenter, ycenter, xscale, yscale
	uchar direction
	Variable starttime, endtime
	Variable headerSize
	uchar type
	Wave/T chanInfo
EndStructure

Static Function/WAVE KP_LoadNanonisSXMGetData(pathStr, s)
	String pathStr
	STRUCT KP_NanonisSxmNspHeader &s

	Variable chan, layer, nLayer
	String unit

	GBLoadWave/O/Q/N=KP_tmpsxm/T={2,4}/S=(s.headerSize)/W=1 pathStr
	Wave tw = KP_tmpsxm0

	for (chan = 0, nLayer = 0; chan < DimSize(s.chanInfo, 0); chan += 1)
		nLayer += CmpStr(s.chanInfo[chan][2], "both") ? 1 : 2
	endfor
	Redimension/N=(s.xpnts, s.ypnts, nLayer) tw

	if (s.direction)
		Reverse/DIM=1 tw
	endif

	Make/N=(nLayer)/WAVE/FREE refw
	for (layer = 0, chan = 0; layer < nLayer; layer += 1, chan += 1)
		unit = s.chanInfo[chan][1]
		String fwdName = s.chanInfo[chan][0]
		MatrixOP $fwdName/WAVE=topow = tw[][][layer]
		SetScale d, 0, 0, unit, topow
		Redimension/S topow
		refw[layer] = topow

		if (!CmpStr(s.chanInfo[chan][2], "both"))
			layer += 1
			String bwdName = s.chanInfo[chan][0] + "_bwd"
			MatrixOP $bwdName/WAVE=topow = tw[][][layer]
			SetScale d, 0, 0, unit, topow
			Reverse/DIM=0 topow
			Redimension/S topow
			refw[layer] = topow
		endif
	endfor

	for (layer = 0; layer < nLayer; layer += 1)
		Wave lw = refw[layer]
		SetScale/I x, s.xcenter - s.xscale / 2, s.xcenter + s.xscale / 2, "A", lw
		SetScale/I y, s.ycenter - s.yscale / 2, s.ycenter + s.yscale / 2, "A", lw
		strswitch (WaveUnits(lw, -1))
			case "m":
				FastOP lw = (1e10) * lw
				SetScale d, WaveMin(lw), WaveMax(lw), "A", lw
				break
			case "A":
				FastOP lw = (1e9) * lw
				SetScale d, WaveMin(lw), WaveMax(lw), "nA", lw
				break
			default:
				SetScale d, WaveMin(lw), WaveMax(lw), "", lw
		endswitch
	endfor

	KillWaves/Z tw
	return refw
End

Static Function/WAVE KP_LoadNanonisNSPGetData(pathStr, s)
	String pathStr
	STRUCT KP_NanonisSxmNspHeader &s

	GBLoadWave/O/Q/N=KP_tmpnsp/T={2,4}/S=(s.headerSize)/W=1 pathStr
	Wave tw = KP_tmpnsp0
	Redimension/N=(s.ypnts, s.xpnts) tw
	MatrixTranspose tw
	SetScale/I x, s.starttime, s.endtime, "dat", tw
	SetScale/P y, 0, s.yscale, "Hz", tw
	Rename tw $ParseFilePath(3, pathStr, ":", 0, 0)
	return tw
End

Function KP_NanonisCommonGetHeader(pathStr)
	String pathStr

	Variable refNum, subFolder, i
	String buffer, key, name, value
	DFREF dfrSav = GetDataFolderDFR()

	strswitch (LowerStr(ParseFilePath(4, pathStr, ":", 0, 0)))
		case "dat":
			key = "%[^\t]\t%[^\t]\t"
			break
		case "3ds":
			key = "%[^=]=%[^\r]\r"
			break
		default:
			return 0
	endswitch

	Open/R/T="????" refNum as pathStr
	FReadLine refNum, buffer
	do
		sscanf buffer, key, name, value
		i = strsearch(name, ">", 0)
		subFolder = (i != -1)
		if (subFolder)
			NewDataFolder/O/S $(name[0, i - 1])
			name = name[i + 1, strlen(name) - 1]
		endif

		if (strsearch(name, ",", 0) > -1)
			Make/N=(ItemsInList(value), 5)/O $"multiline settings"/WAVE=w
			for (i = 0; i < 5; i += 1)
				SetDimLabel 1, i, $StringFromList(i, name, ", "), w
				w[][i] = str2num(StringFromList(i, StringFromList(p, value), ","))
			endfor
		else
			KP_NanonisCommonVariableString(name, value)
		endif

		if (subFolder)
			SetDataFolder dfrSav
		endif

		FReadLine refNum, buffer
	while (strlen(buffer) != 1 && CmpStr(buffer, ":HEADER_END:\r"))

	FStatus refNum
	Close refNum
	return V_filePos
End

Function KP_NanonisCommonConversion(w, [driveamp, modulated])
	Wave w
	Variable driveamp
	String modulated

	if (GrepString(NameOfWave(w), "LI([RXY]|phi)"))
		if (numtype(driveamp) == 2)
			SetScale d, WaveMin(w), WaveMax(w), "A", w
			Print "CAUTION: lock-in settings missing. Conversion to nS is not done."
		elseif (!CmpStr(modulated, "Bias (V)"))
			FastOP w = (1e9 / driveamp) * w
			SetScale d, WaveMin(w), WaveMax(w), "nS", w
		elseif (!CmpStr(modulated, "Z (m)"))
			FastOP w = (1 / driveamp) * w
			SetScale d, WaveMin(w), WaveMax(w), "A/m", w
		else
			FastOP w = (1 / driveamp) * w
		endif
	elseif (GrepString(NameOfWave(w), "Bias"))
		FastOP w = (1e3) * w
		SetScale d, WaveMin(w), WaveMax(w), "mV", w
	elseif (GrepString(NameOfWave(w), "Current_PSD"))
		FastOP w = (1e15) * w
		SetScale d, WaveMin(w), WaveMax(w), "fA/sqrt(Hz)", w
	else
		FastOP w = (1e9) * w
		SetScale d, WaveMin(w), WaveMax(w), "nA", w
	endif
End

Function/WAVE KP_NanonisCommonDataAvg(bwdStr)
	String bwdStr

	String listStr = WaveList("*", ";", "")
	String name, avgName, subName
	Variable i, n
	Make/WAVE/N=0/FREE refw

	for (i = 0, n = ItemsInList(listStr); i < n; i += 1)
		name = StringFromList(i, listStr)
		if (!GrepString(name, bwdStr))
			continue
		endif
		Wave fwdw = $ReplaceString(bwdStr, name, "")
		Wave bwdw = $name
		Duplicate/O fwdw $(NameOfWave(fwdw) + "_sub")/WAVE=subw
		FastOP subw = fwdw - bwdw
		FastOP fwdw = (0.5) * fwdw + (0.5) * bwdw
		KillWaves/Z bwdw
		refw[numpnts(refw)] = fwdw
	endfor
	return refw
End

Function KP_NanonisCommonVariableString(name, value)
	String name, value

	Execute "SetIgorOption AllowLiberalNamesForVariables=1"
	if (strlen(value) == 0)
		String/G $name = ""
		return 0
	endif

	if (char2num(value[0]) == 32)
		do
			value = ReplaceString(" ", value, "", 1, 1)
		while (strlen(value) && char2num(value[0]) == 32)
	endif

	if (strlen(value) >= 2 && !CmpStr(value[0], "\"") && !CmpStr(value[strlen(value) - 1], "\""))
		value = ReplaceString("\"", value, "", 0, 1)
		value = RemoveEnding(value, "\"")
	endif

	if (GrepString(value, "[^0-9eE+-.]") || ItemsInList(value, ".") > 2)
		String/G $name = value
	else
		Variable/G $name = str2num(value)
	endif
End
