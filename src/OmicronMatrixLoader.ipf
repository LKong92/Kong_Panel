#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3
#pragma IgorVersion=9.00
#pragma DefaultTab={3,20,4}

// Version 1.4: grid, folder Z topographs, and folder 1D voltage spectra.
// Based on the user-supplied grid loader; native Igor 9, no Python at runtime.
// MATRIX format definitions adapted from access2theMatrix 0.4.4 (BSD).

Menu "Load Waves"
    Submenu "Load OMICRON Matrix"
        "Load Grid: all channels", MatrixLoadGrid()
        "Load Topology: folder", MatrixLoadTopologyGraph()
        "Load Spectra: folder", MatrixLoadSpectra()
    End
End

Structure MX9Meta
    String parameters
    String transferTypes
    String transferValues
    String wantedChannel
    String channelUnit
    String wantedFile
    Variable channelID
    Variable found
EndStructure

// Main entry point. With no arguments, opens a file picker.
// All outputs go directly in root. The current data folder is unchanged.
Function MatrixLoadGrid([filePath, biasAscending, flipX])
    String filePath
    Variable biasAscending, flipX
    if (ParamIsDefault(filePath))
        filePath = ""
    endif
    if (ParamIsDefault(biasAscending))
        biasAscending = 1
    endif
    if (ParamIsDefault(flipX))
        flipX = 1
    endif
    Variable refNum
    if (strlen(filePath) == 0)
        Open/D/R/F="MATRIX channel files (all extensions):.*;"/M="Choose a MATRIX grid channel, e.g. --39_1.I(V)_mtrx" refNum
        filePath = S_fileName
        if (strlen(filePath) == 0)
            return 0
        endif
    endif
    // Resolve path through Open/FStatus (works with Mac and Windows paths).
    Open/R refNum as filePath
    FStatus refNum
    String folder = S_path, selected = S_fileName
    Close refNum
    Variable sep = strsearch(selected, "--", Inf, 1)
    Variable dot = strsearch(selected, ".", sep + 2)
    if (sep < 0 || dot < 0 || !StringMatch(selected, "*(V)_mtrx"))
        Abort "Select a channel result file such as --39_1.I(V)_mtrx, not _0001.mtrx."
    endif
    String stem = selected[0, dot], runID = selected[sep+2, dot-1]
    // Check before entering the channel-reader try/catch: one concise alert,
    // with the full path in history instead of a truncated path in the alert.
    String requiredName = selected[0,sep-1] + "_0001.mtrx"
    Variable parameterRef
    Open/R/Z parameterRef as (folder + requiredName)
    if (V_flag != 0)
        Print "Missing MATRIX companion parameter file: " + folder + requiredName
        Print "Use the original acquisition folder, or copy the matching parameter chain and all desired channel files into this folder."
        Abort "Missing companion parameter file:\r" + requiredName + "\r\rKeep it beside the channel files, or select the channel in the original acquisition folder."
    endif
    Close parameterRef
    String symbolicPath = UniqueName("MX9Files", 12, 0)
    NewPath/Q $symbolicPath, folder
    String allFiles = IndexedFile($symbolicPath, -1, "????")
    KillPath $symbolicPath
    String files = "", item
    Variable i, count = 0
    for (i=0; i<ItemsInList(allFiles); i+=1)
        item = StringFromList(i, allFiles)
        if (strsearch(item, stem, 0) == 0 && StringMatch(item, "*(V)_mtrx"))
            files += item + ";"
            count += 1
        endif
    endfor
    files = SortList(files)
    if (count == 0)
        Abort "No matching voltage-grid channels found."
    endif
    // Read and validate ALL channels before creating any permanent waves.
    Make/FREE/WAVE/N=(count) prepared
    Make/FREE/T/N=(count) channelNames
    Variable readError
    for (i=0; i<count; i+=1)
        item = StringFromList(i, files)
        try
            WAVE one = MX9ReadGrid(folder, item, biasAscending, flipX)
            AbortOnRTE
        catch
            readError = GetRTError(1)
            // MX9ReadGrid already shows its specific Abort message. Do not
            // display a second generic alert for the same failure.
            Print "MATRIX channel read stopped: " + item + ". No output waves were created."
            if (readError != 0)
                Print "Runtime detail: " + GetErrMessage(readError)
            endif
            return -1
        endtry
        if (!WaveExists(one))
            Abort "No grid returned for " + item
        endif
        prepared[i] = one
        // "I" is an Igor built-in function: use safe, descriptive wave names.
        channelNames[i] = CleanupName(item[dot+1, strlen(item)-9], 0) + "_3D"
        if (strlen(channelNames[i]) == 0)
            Abort "Invalid channel name."
        endif
        Variable j, dim
        for (j=0; j<i; j+=1)
            if (cmpstr(channelNames[j], channelNames[i]) == 0)
                Abort "Channel names collide after Igor name conversion."
            endif
        endfor
        WAVE first = prepared[0]
        for (dim=0; dim<3; dim+=1)
            if (DimSize(one, dim) != DimSize(first, dim) || DimOffset(one, dim) != DimOffset(first, dim) || DimDelta(one, dim) != DimDelta(first, dim))
                Abort "Channel coordinates differ; no combined grid was imported."
            endif
        endfor
    endfor
    String resultName = MX9RootPrefix(runID, channelNames)
    String destination = "root:" + resultName + "_"
    for (i=0; i<count; i+=1)
        WAVE one = prepared[i]
        Duplicate one, $(destination + channelNames[i])
        WAVE/Z stored = $(destination + channelNames[i])
        if (!WaveExists(stored))
            Abort "Could not create output wave. Incomplete output set with prefix: " + destination
        endif
    endfor
    WAVE first = prepared[0]
    Make/D/N=(DimSize(first,0)) $(destination + "xAxis")
    Make/D/N=(DimSize(first,1)) $(destination + "yAxis")
    Make/D/N=(DimSize(first,2)) $(destination + "biasAxis")
    WAVE xa = $(destination + "xAxis"), ya = $(destination + "yAxis"), va = $(destination + "biasAxis")
    xa = DimOffset(first,0) + p*DimDelta(first,0)
    ya = DimOffset(first,1) + p*DimDelta(first,1)
    va = DimOffset(first,2) + p*DimDelta(first,2)
    SetScale d, 0, 0, "m", xa, ya
    SetScale d, 0, 0, "V", va
    Make/T/N=(count,3) $(destination + "channels")
    WAVE/T summary = $(destination + "channels")
    SetDimLabel 1, 0, WaveName, summary
    SetDimLabel 1, 1, DataUnit, summary
    SetDimLabel 1, 2, SourceFile, summary
    for (i=0; i<count; i+=1)
        WAVE one = prepared[i]
        summary[i][0] = resultName + "_" + channelNames[i]
        summary[i][1] = WaveUnits(one,-1)
        summary[i][2] = folder + StringFromList(i,files)
    endfor
    Print "MATRIX grid imported directly into root; wave prefix: " + resultName + "_"
    Print "Channels: " + num2istr(count) + "; dimensions [x][y][bias]: " + num2istr(DimSize(first,0)) + " x " + num2istr(DimSize(first,1)) + " x " + num2istr(DimSize(first,2))
    Print "Axes: x/y in m, bias in V. I is in A; Aux channels retain their recorded units."
    Print "Spatial coordinates use the WSxM local inclusive-extent convention."
    return count
End

// Reserve a common suffix for the entire output set. Check root explicitly,
// even if the command is run while another data folder is current.
Function/S MX9RootPrefix(runID, channelNames)
    String runID
    WAVE/T channelNames
    String base = "Matrix_" + CleanupName(runID, 0) + "_"
    String suffixes = "xAxis;yAxis;biasAxis;channels;"
    String candidate, waveName
    Variable i, serial = 0, collision
    for (i=0; i<numpnts(channelNames); i+=1)
        suffixes += channelNames[i] + ";"
    endfor
    do
        candidate = base + num2istr(serial)
        collision = 0
        for (i=0; i<ItemsInList(suffixes); i+=1)
            waveName = candidate + "_" + StringFromList(i,suffixes)
            if (strlen(waveName)>31)
                Abort "The generated wave name exceeds Igor's 31-character limit: " + waveName
            endif
            if (Exists("root:"+waveName) || DataFolderExists("root:"+waveName))
                collision = 1
                break
            endif
        endfor
        serial += 1
    while (collision)
    return candidate
End

Function/WAVE MX9ReadGrid(folder, filename, biasAscending, flipX)
    String folder, filename
    Variable biasAscending, flipX
    Variable sep = strsearch(filename,"--",Inf,1)
    Variable dot = strsearch(filename,".",sep+2)
    String channel = filename[dot+1, strlen(filename)-6]
    STRUCT MX9Meta meta
    meta.parameters = ""
    meta.transferTypes = ""
    meta.transferValues = ""
    meta.wantedChannel = channel
    meta.channelUnit = ""
    meta.wantedFile = filename
    meta.channelID = -1
    meta.found = 0
    String chainBase = folder + filename[0,sep-1]
    String chainFile, bytes
    Variable link = 1, pos, endPos
    do
        sprintf chainFile, "%s_%04d.mtrx", chainBase, link
        bytes = MX9ReadFile(chainFile, 1)
        if (strlen(bytes) == 0)
            Abort "Missing parameter chain or file reference: " + chainFile + ". Keep _0001.mtrx and subsequent chain links beside the channel files."
        endif
        MX9CheckMagic(bytes)
        pos = 12
        do
            endPos = MX9ParamBlock(bytes, pos, strlen(bytes), meta)
            pos = endPos
        while (pos < strlen(bytes) && !meta.found)
        link += 1
    while (!meta.found)
    if (cmpstr(StringByKey("Device1Unit",meta.parameters,"=","\r"),"Volt")!=0)
        Abort "This grid loader supports voltage on Spectroscopy Device 1 only."
    endif
    Variable points = MX9Required(meta.parameters,"XYScanner.Points")
    Variable lines = MX9Required(meta.parameters,"XYScanner.Lines")
    Variable subX = MX9Required(meta.parameters,"XYScanner.Subgrid_X")
    Variable subY = MX9Required(meta.parameters,"XYScanner.Subgrid_Y")
    Variable width = MX9Required(meta.parameters,"XYScanner.Width")
    Variable height = MX9Required(meta.parameters,"XYScanner.Height")
    Variable nz = MX9Required(meta.parameters,"Spectroscopy.Device_1_Points")
    Variable startV = MX9Required(meta.parameters,"Spectroscopy.Device_1_Start")
    Variable endV = MX9Required(meta.parameters,"Spectroscopy.Device_1_End")
    if (MX9Required(meta.parameters,"XYScanner.Enable_Subgrid") != 1)
        Abort "This is not a volume CITS subgrid file: " + filename
    endif
    if (MX9Required(meta.parameters,"Spectroscopy.Enable_Device_1_Ramp_Reversal") != 0 || MX9Required(meta.parameters,"Spectroscopy.Device_1_Repetitions") != 1)
        Abort "Ramp reversal/repeated sweeps are not supported by this loader version."
    endif
    if (MX9Required(meta.parameters,"XYScanner.Y_Retrace") != 0)
        Abort "Up/down grids require separate output waves; this loader supports forward/up only."
    endif
    if (MX9Required(meta.parameters,"XYScanner.X_Retrace") != 0 && MX9Required(meta.parameters,"XYScanner.Subgrid_Match_Mode") != 1)
        Abort "Backward or interleaved spatial spectra are not supported by this loader version."
    endif
    if (points<1 || lines<1 || subX<1 || subY<1 || nz<2 || width<=0 || height<=0 || startV==endV)
        Abort "Invalid or degenerate grid dimensions."
    endif
    Variable nx = ceil(points/subX), ny = ceil(lines/subY)
    if (nx<2 || ny<2)
        Abort "This loader requires at least 2 x 2 spatial grid points."
    endif
    bytes = MX9ReadFile(folder + filename, 0)
    MX9CheckMagic(bytes)
    Variable dataOffset=-1, dataCount=-1, declaredCount=-1
    MX9DataBlocks(bytes, 12, strlen(bytes), dataOffset, dataCount, declaredCount)
    if (dataOffset<0 || dataCount != nx*ny*nz || declaredCount != dataCount)
        Abort "Incomplete grid or unsupported payload: sample count does not equal nx*ny*nBias. " + filename
    endif
    WAVE raw = StringToUnsignedByteWave(bytes[dataOffset,dataOffset+4*dataCount-1])
    Redimension/E=1/I/N=(dataCount) raw
    // Igor 9 supported Mac/Windows processors are little-endian.
    String id = num2istr(meta.channelID)
    String transfer = StringByKey(id,meta.transferTypes,"=","\r")
    Variable factor, offset = MX9Required(meta.transferValues,id+".Offset")
    if (cmpstr(transfer,"TFF_Linear1D") == 0)
        factor = 1/MX9Required(meta.transferValues,id+".Factor")
    elseif (cmpstr(transfer,"TFF_MultiLinear1D") == 0)
        factor = (MX9Required(meta.transferValues,id+".Raw_1")-MX9Required(meta.transferValues,id+".PreOffset"))/(MX9Required(meta.transferValues,id+".NeutralFactor")*MX9Required(meta.transferValues,id+".PreFactor"))
    else
        Abort "Unknown MATRIX channel transfer function: " + transfer
    endif
    if (numtype(factor) != 0 || factor == 0 || strlen(meta.channelUnit)==0)
        Abort "Invalid channel calibration."
    endif
    Variable reverseV = biasAscending && startV>endV
    Make/FREE/D/N=(nx,ny,nz) result
    // Raw order: bias fastest, then acquired x, then y.
    // result dimension 0 is x, dimension 1 is y, dimension 2 is bias.
    result = (raw[((q*nx)+(flipX ? nx-1-p : p))*nz+(reverseV ? nz-1-r : r)]-offset)*factor
    Variable firstV = reverseV ? endV : startV
    Variable lastV = reverseV ? startV : endV
    SetScale/I x, 0, width, "m", result
    SetScale/I y, 0, height, "m", result
    SetScale/I z, firstV, lastV, "V", result
    String signalUnit = meta.channelUnit
    SetScale d, 0, 0, signalUnit, result
    String annotation = "Source="+folder+filename+"\rChannel="+channel+"\r"
    annotation += "Dimensions=x,y,bias\rSpatialConvention=WSxM_local_inclusive_extent\r"
    annotation += "FlipX="+num2istr(flipX!=0)+"\rBiasAscending="+num2istr(biasAscending!=0)+"\r"
    annotation += "FirstAcquiredBiasPointPreserved=1\rTrace=forward/up,trace\r"
    annotation += "Calibration="+transfer+"\r"+meta.parameters
    Note result, annotation
    return result
End

Function/S MX9ReadFile(filePath, missingOK)
    String filePath
    Variable missingOK
    Variable refNum
    Open/R/Z refNum as filePath
    if (V_flag != 0)
        if (missingOK)
            return ""
        endif
        Abort "Cannot read " + filePath
    endif
    FStatus refNum
    Variable n = V_logEOF
    if (n<12 || n>1.5e9)
        Close refNum
        Abort "Invalid or oversized MATRIX file."
    endif
    String bytes = PadString("",n,0)
    try
        FBinRead refNum, bytes
    catch
        Variable err = GetRTError(1)
        Close refNum
        Abort "Failed while reading MATRIX file."
    endtry
    Close refNum
    return bytes
End

Function MX9CheckMagic(bytes)
    String &bytes
    if (cmpstr(bytes[0,11],"ONTMATRX0101") != 0)
        Abort "Unsupported MATRIX file signature (expected ONTMATRX0101)."
    endif
End

Function MX9Need(bytes, pos, n)
    String &bytes
    Variable pos, n
    if (pos<0 || n<0 || pos+n>strlen(bytes))
        Abort "Truncated or malformed MATRIX block."
    endif
End

Function MX9U32(bytes, pos)
    String &bytes
    Variable &pos
    MX9Need(bytes,pos,4)
    Variable value = (char2num(bytes[pos]) & 255)+256*(char2num(bytes[pos+1]) & 255)+65536*(char2num(bytes[pos+2]) & 255)+16777216*(char2num(bytes[pos+3]) & 255)
    pos += 4
    return value
End

Function/S MX9String(bytes, pos)
    String &bytes
    Variable &pos
    Variable n = MX9U32(bytes,pos)*2
    MX9Need(bytes,pos,n)
    if (n==0)
        return ""
    endif
    String value = ConvertTextEncoding(bytes[pos,pos+n-1],101,1,1,2)
    pos += n
    return value
End

Function/S MX9Value(bytes, pos, skip)
    String &bytes
    Variable &pos
    Variable skip
    pos += skip
    MX9Need(bytes,pos,4)
    String tag = bytes[pos,pos+3], value
    Variable number
    pos += 4
    strswitch(tag)
        case "LOOB":
        case "GNOL":
            number = MX9U32(bytes,pos)
            if (cmpstr(tag,"GNOL")==0 && number>=2147483648)
                number -= 4294967296
            endif
            break
        case "BUOD":
            MX9Need(bytes,pos,8)
            WAVE binary = StringToUnsignedByteWave(bytes[pos,pos+7])
            Redimension/E=1/D/N=1 binary
            number = binary[0]
            pos += 8
            break
        case "GRTS":
            return MX9String(bytes,pos)
        default:
            Abort "Unknown MATRIX parameter type: " + tag
    endswitch
    sprintf value,"%.17g",number
    return value
End

Function MX9Required(map, key)
    String map, key
    String item = StringByKey(key,map,"=","\r")
    Variable value = str2num(item)
    if (strlen(item)==0 || numtype(value)!=0)
        Abort "Missing/invalid MATRIX metadata: " + key
    endif
    return value
End

Function MX9ParamBlock(bytes, start, limit, meta)
    String &bytes
    Variable start, limit
    STRUCT MX9Meta &meta
    MX9Need(bytes,start,8)
    String tag = bytes[start,start+3]
    Variable pos=start+4, size=MX9U32(bytes,pos)
    Variable noTimestamp = WhichListItem(tag,"REFX;NACS;TCID;SCHC;TSNI;SXNC;LNEG;")>=0
    Variable body=pos+8*(!noTimestamp), finish=body+size
    if (finish>limit || finish<=start)
        Print "MATRIX block diagnostic:", tag, start, size, body, finish, limit
        Abort "Invalid MATRIX parameter block length."
    endif
    Variable i,j,n1,n2,key
    String element,property,unit,value,name,id,discard
    strswitch(tag)
        case "APEE":
            pos=body+4
            n1=MX9U32(bytes,pos)
            for (i=0;i<n1;i+=1)
                element=MX9String(bytes,pos)
                n2=MX9U32(bytes,pos)
                for (j=0;j<n2;j+=1)
                    property=MX9String(bytes,pos)
                    unit=MX9String(bytes,pos)
                    value=MX9Value(bytes,pos,4)
                    meta.parameters=ReplaceStringByKey(element+"."+property,meta.parameters,value,"=","\r",1)
                    if (cmpstr(element+"."+property,"Spectroscopy.Device_1_Start")==0 && cmpstr(unit,"Volt")!=0)
                        // Keep the unit for validation at the selected BREF, not at earlier measurements.
                        meta.parameters=ReplaceStringByKey("Device1Unit",meta.parameters,unit,"=","\r",1)
                    elseif (cmpstr(element+"."+property,"Spectroscopy.Device_1_Start")==0)
                        meta.parameters=ReplaceStringByKey("Device1Unit",meta.parameters,"Volt","=","\r",1)
                    endif
                    if (cmpstr(element+"."+property,"Spectroscopy.Device_2_Start")==0)
                        meta.parameters=ReplaceStringByKey("Device2Unit",meta.parameters,unit,"=","\r",1)
                    endif
                endfor
            endfor
            break
        case "DOMP":
            pos=body+4
            element=MX9String(bytes,pos)
            property=MX9String(bytes,pos)
            unit=MX9String(bytes,pos)
            value=MX9Value(bytes,pos,4)
            meta.parameters=ReplaceStringByKey(element+"."+property,meta.parameters,value,"=","\r",1)
            if (cmpstr(element+"."+property,"Spectroscopy.Device_1_Start")==0)
                meta.parameters=ReplaceStringByKey("Device1Unit",meta.parameters,unit,"=","\r",1)
            endif
            if (cmpstr(element+"."+property,"Spectroscopy.Device_2_Start")==0)
                meta.parameters=ReplaceStringByKey("Device2Unit",meta.parameters,unit,"=","\r",1)
            endif
            break
        case "YSCC":
            pos=body+4
            do
                pos=MX9ParamBlock(bytes,pos,finish,meta)
            while (pos<finish && !meta.found)
            break
        case "TCID":
            pos=body+8
            n1=MX9U32(bytes,pos)
            for (i=0;i<n1;i+=1)
                pos+=16
                discard=MX9String(bytes,pos)
                discard=MX9String(bytes,pos)
            endfor
            n1=MX9U32(bytes,pos)
            for (i=0;i<n1;i+=1)
                pos+=4
                key=MX9U32(bytes,pos)
                pos+=8
                name=MX9String(bytes,pos)
                unit=MX9String(bytes,pos)
                if (cmpstr(name,meta.wantedChannel)==0 && key>meta.channelID)
                    meta.channelID=key
                    meta.channelUnit=unit
                endif
            endfor
            // Remaining DICT entries are descriptors, not conversion factors.
            break
        case "REFX":
            pos=body
            do
                pos+=4
                key=MX9U32(bytes,pos)
                id=num2istr(key)
                name=MX9String(bytes,pos)
                unit=MX9String(bytes,pos)
                meta.transferTypes=ReplaceStringByKey(id,meta.transferTypes,name,"=","\r",1)
                n1=MX9U32(bytes,pos)
                for (i=0;i<n1;i+=1)
                    property=MX9String(bytes,pos)
                    value=MX9Value(bytes,pos,0)
                    meta.transferValues=ReplaceStringByKey(id+"."+property,meta.transferValues,value,"=","\r",1)
                endfor
            while (pos<finish)
            break
        case "FERB":
            pos=body+4
            name=MX9String(bytes,pos)
            if (cmpstr(name,meta.wantedFile)==0)
                meta.found=1
            endif
            break
    endswitch
    return finish
End

// Compatibility wrapper used by the unchanged grid loader.
Function MX9DataBlocks(bytes, start, limit, dataOffset, dataCount, declaredCount)
    String &bytes
    Variable start, limit
    Variable &dataOffset, &dataCount, &declaredCount
    Variable fullCount=-1
    MX9DataBlocksFull(bytes,start,limit,dataOffset,dataCount,declaredCount,fullCount)
End

Function MX9DataBlocksFull(bytes, start, limit, dataOffset, dataCount, declaredCount, fullCount)
    String &bytes
    Variable start, limit
    Variable &dataOffset, &dataCount, &declaredCount, &fullCount
    Variable pos=start, size, body, finish, child
    String tag, dataType
    do
        MX9Need(bytes,pos,8)
        tag=bytes[pos,pos+3]
        pos+=4
        size=MX9U32(bytes,pos)
        body=pos
        finish=body+size
        if (cmpstr(tag,"CSED")!=0 && cmpstr(tag,"ATAD")!=0)
            finish+=8
        endif
        if (finish>limit || finish<=start)
            Abort "Truncated MATRIX sample block."
        endif
        strswitch(tag)
            case "TLKB":
                MX9DataBlocksFull(bytes,body+12,finish,dataOffset,dataCount,declaredCount,fullCount)
                break
            case "CSED":
                child=body+20
                fullCount=MX9U32(bytes,child)
                declaredCount=MX9U32(bytes,child)
                dataType=MX9String(bytes,child)
                if (cmpstr(dataType,"SI32")!=0)
                    Abort "Unsupported MATRIX sample type: " + dataType
                endif
                break
            case "ATAD":
                if (dataOffset>=0 || mod(size,4)!=0)
                    Abort "Unsupported multiple or malformed DATA payloads."
                endif
                dataOffset=body
                dataCount=size/4
                break
        endswitch
        pos=finish
    while (pos<limit)
End

// Folder loader for Z topographs. Each acquired direction is a separate 2D
// double wave in root:DataN. Missing pixels in stopped scans remain NaN.
Function MatrixLoadTopologyGraph([folderPath, includeRetrace, flipX])
    String folderPath
    Variable includeRetrace, flipX
    if (ParamIsDefault(folderPath))
        folderPath = ""
    endif
    if (ParamIsDefault(includeRetrace))
        includeRetrace = 1
    endif
    if (ParamIsDefault(flipX))
        flipX = 0
    endif
    String pathName = UniqueName("MX9TopoPath", 12, 0)
    if (strlen(folderPath) == 0)
        NewPath/Q/M="Choose the folder containing Z_mtrx files and their _0001.mtrx parameters" $pathName
    else
        NewPath/Q/Z $pathName, folderPath
    endif
    if (V_flag != 0)
        return 0
    endif
    PathInfo $pathName
    String folder = S_path
    String allFiles = IndexedFile($pathName, -1, "????")
    KillPath $pathName
    String files = "", filename
    Variable i, j
    for (i=0; i<ItemsInList(allFiles); i+=1)
        filename = StringFromList(i, allFiles)
        if (StringMatch(filename, "*.Z_mtrx"))
            files += filename + ";"
        endif
    endfor
    files = SortList(files)
    Variable fileCount = ItemsInList(files)
    if (fileCount == 0)
        DoAlert 0, "No .Z_mtrx files were found in the selected folder."
        return 0
    endif
    Make/FREE/T/N=0 nameLog, fileLog
    Variable nextData = 1, importedFiles = 0, failedFiles = 0, partialFiles = 0
    Variable readError, row, isPartial
    String errorText, waveName, sourceNote
    for (i=0; i<fileCount; i+=1)
        filename = StringFromList(i, files)
        errorText = ""
        isPartial = 0
        Make/FREE/T/N=4 directions
        try
            WAVE/WAVE images = MX9ReadTopographs(folder, filename, includeRetrace, flipX, directions, isPartial, errorText)
            AbortOnRTE
        catch
            readError = GetRTError(1)
            failedFiles += 1
            Print "Skipped MATRIX topograph: " + filename
            if (readError != 0)
                Print "Reason: " + GetErrMessage(readError)
            endif
            continue
        endtry
        if (strlen(errorText)>0 || numpnts(images)==0)
            failedFiles += 1
            Print "Skipped MATRIX topograph: " + filename + "; " + errorText
            continue
        endif
        for (j=0; j<numpnts(images); j+=1)
            WAVE oneImage = images[j]
            waveName = MX9NextDataName(nextData)
            Duplicate oneImage, $("root:" + waveName)
            row = numpnts(nameLog)
            InsertPoints row, 1, nameLog, fileLog
            nameLog[row] = waveName
            fileLog[row] = filename
            Print waveName + " <- " + filename + " [" + directions[j] + "]"
        endfor
        importedFiles += 1
        partialFiles += isPartial
        if (isPartial)
            Print "Incomplete scan: unacquired pixels remain NaN; original pixel spacing is preserved."
        endif
    endfor
    if (numpnts(nameLog)>0)
        MX9TopoShowSourceTable(nameLog, fileLog, folder)
    endif
    Print "MATRIX topographs: " + num2istr(importedFiles) + " files -> " + num2istr(numpnts(nameLog)) + " root Data waves; " + num2istr(partialFiles) + " incomplete files; " + num2istr(failedFiles) + " skipped files."
    Print "XY: local image coordinates in m, pixel centers, field width/nx and height/ny spacing. Z: calibrated recorded unit."
    return numpnts(nameLog)
End

Function/S MX9NextDataName(nextData)
    Variable &nextData
    String candidate
    do
        candidate = "Data" + num2istr(nextData)
        nextData += 1
    while (Exists("root:"+candidate) || DataFolderExists("root:"+candidate))
    return candidate
End

Function MX9TopoShowSourceTable(nameLog, fileLog, folder)
    WAVE/T nameLog, fileLog
    String folder
    if (!MX9SpectraListSlotOK("root:File_Name"))
        Abort "File_Name is occupied by a non-text object. Rename that object before importing topographs."
    endif
    MX9SpectraArchiveList("root:File_Name", "File_Name_Backup")
    Variable serial=0
    String namesPath, filesPath
    do
        namesPath = "root:File_Name"
        filesPath = "root:TopoSourceFiles" + num2istr(serial)
        serial += 1
    while (Exists(filesPath) || DataFolderExists(filesPath))
    Duplicate nameLog, $namesPath
    Duplicate fileLog, $filesPath
    WAVE/T names = $namesPath, sources = $filesPath
    String annotation = "SourceFolder=" + folder + "\rColumns=WaveName,SourceFileName\rDirection=See the Note of the corresponding Data wave\r"
    Note names, annotation
    Note sources, annotation
    String tableName = UniqueName("MatrixTopoSources", 6, 0)
    Edit/N=$tableName/W=(60,80,1000,520) names, sources as "MATRIX topographs: Wave name -> source file"
    ModifyTable width(names)=140, width(sources)=720
End

// Returns a free wave-reference wave. Expected input problems are returned
// in errorText so a bad file does not interrupt the remaining folder batch.
Function/WAVE MX9ReadTopographs(folder, filename, includeRetrace, flipX, directions, isPartial, errorText)
    String folder, filename
    Variable includeRetrace, flipX
    WAVE/T directions
    Variable &isPartial
    String &errorText
    Make/FREE/WAVE/N=0 images
    errorText = ""
    isPartial = 0
    Variable sep = strsearch(filename,"--",Inf,1)
    Variable dot = strsearch(filename,".",sep+2)
    if (sep<0 || dot<0 || cmpstr(filename[dot+1,strlen(filename)-1],"Z_mtrx")!=0)
        errorText = "Not a MATRIX Z topograph filename."
        return images
    endif
    STRUCT MX9Meta meta
    meta.parameters = ""
    meta.transferTypes = ""
    meta.transferValues = ""
    meta.wantedChannel = "Z"
    meta.channelUnit = ""
    meta.wantedFile = filename
    meta.channelID = -1
    meta.found = 0
    String chainBase = folder + filename[0,sep-1]
    String chainFile, bytes
    Variable link=1, pos
    do
        sprintf chainFile, "%s_%04d.mtrx", chainBase, link
        bytes = MX9ReadFile(chainFile, 1)
        if (strlen(bytes)==0)
            errorText = "Missing parameter chain or BREF: " + chainFile
            return images
        endif
        MX9CheckMagic(bytes)
        pos=12
        do
            pos=MX9ParamBlock(bytes,pos,strlen(bytes),meta)
        while (pos<strlen(bytes) && !meta.found)
        link+=1
    while (!meta.found)
    Variable nx=MX9Required(meta.parameters,"XYScanner.Points")
    Variable ny=MX9Required(meta.parameters,"XYScanner.Lines")
    Variable width=MX9Required(meta.parameters,"XYScanner.Width")
    Variable height=MX9Required(meta.parameters,"XYScanner.Height")
    Variable xr=MX9Required(meta.parameters,"XYScanner.X_Retrace")
    Variable yr=MX9Required(meta.parameters,"XYScanner.Y_Retrace")
    if (nx<2 || ny<2 || nx!=floor(nx) || ny!=floor(ny) || width<=0 || height<=0 || (xr!=0 && xr!=1) || (yr!=0 && yr!=1))
        errorText = "Invalid image dimensions or scan-direction flags."
        return images
    endif
    bytes=MX9ReadFile(folder+filename,0)
    MX9CheckMagic(bytes)
    Variable dataOffset=-1, dataCount=-1, declaredCount=-1, fullCount=-1
    MX9DataBlocksFull(bytes,12,strlen(bytes),dataOffset,dataCount,declaredCount,fullCount)
    Variable expected=nx*ny*(1+xr)*(1+yr)
    if (dataOffset<0 || dataCount<1 || dataCount!=declaredCount || dataCount>expected || fullCount!=expected)
        errorText = "Payload size does not match the recorded image geometry."
        return images
    endif
    isPartial = dataCount<expected
    WAVE raw=StringToUnsignedByteWave(bytes[dataOffset,dataOffset+4*dataCount-1])
    Redimension/E=1/I/N=(dataCount) raw
    String id=num2istr(meta.channelID)
    String transfer=StringByKey(id,meta.transferTypes,"=","\r")
    Variable factor, offset=MX9Required(meta.transferValues,id+".Offset")
    if (cmpstr(transfer,"TFF_Linear1D")==0)
        factor=1/MX9Required(meta.transferValues,id+".Factor")
    elseif (cmpstr(transfer,"TFF_MultiLinear1D")==0)
        factor=(MX9Required(meta.transferValues,id+".Raw_1")-MX9Required(meta.transferValues,id+".PreOffset"))/(MX9Required(meta.transferValues,id+".NeutralFactor")*MX9Required(meta.transferValues,id+".PreFactor"))
    else
        errorText="Unsupported Z transfer function: " + transfer
        return images
    endif
    if (numtype(factor)!=0 || factor==0 || strlen(meta.channelUnit)==0)
        errorText="Invalid Z calibration."
        return images
    endif
    Variable dx,dy,n=0,rowSize=nx*(1+xr),startIndex,validPixels,completeRows,remainder,available
    String direction,signalUnit=meta.channelUnit,annotation
    // Direction order: forward/up, backward/up, forward/down, backward/down.
    for (dy=0;dy<=yr;dy+=1)
        for (dx=0;dx<=xr;dx+=1)
            if (!includeRetrace && (dx || dy))
                continue
            endif
            startIndex=dy*ny*rowSize+dx*nx
            if (startIndex>=dataCount)
                continue
            endif
            Make/FREE/D/N=(nx,ny) result
            // First store raw indices, then calibrate acquired samples only.
            result=startIndex+(dy ? ny-1-q : q)*rowSize+(dx ? nx-1-(flipX ? nx-1-p : p) : (flipX ? nx-1-p : p))
            result=result[p][q]<dataCount ? (raw[min(result[p][q],dataCount-1)]-offset)*factor : NaN
            // Image edges are 0..Width and 0..Height; scales mark pixel centers.
            SetScale/P x,width/(2*nx),width/nx,"m",result
            SetScale/P y,height/(2*ny),height/ny,"m",result
            SetScale d,0,0,signalUnit,result
            direction=SelectString(dx,"forward","backward")+"/"+SelectString(dy,"up","down")
            available=max(0,min(dataCount-dy*ny*rowSize,ny*rowSize))
            completeRows=floor(available/rowSize)
            remainder=mod(available,rowSize)
            validPixels=completeRows*nx+max(0,min(nx,remainder-dx*nx))
            annotation="Source="+folder+filename+"\rSourceFile="+filename+"\rChannel=Z\rTrace="+direction+"\r"
            annotation+="Dimensions=x,y\rSpatialConvention=local_image_pixel_centers\rXYAlignment=trace_and_retrace_on_same_local_axes\r"
            annotation+="FlipX="+num2istr(flipX!=0)+"\rIncompleteFile="+num2istr(isPartial)+"\rAcquiredPixels="+num2istr(validPixels)+"\r"
            annotation+="UnacquiredPixels=NaN\rCalibration="+transfer+"\rOffsetsAndAngle=recorded_below_not_applied_to_local_axes\r"+meta.parameters
            Note result,annotation
            Redimension/N=(n+1) images
            images[n]=result
            directions[n]=direction
            n+=1
        endfor
    endfor
    Redimension/N=(n) directions
    return images
End

// Folder loader for independent voltage spectra, directly into root:STS1 etc.
// File_Name and STS_SourceFiles describe the latest successful batch.
Function MatrixLoadSpectra([folderPath, biasAscending, includeRetrace])
    String folderPath
    Variable biasAscending, includeRetrace
    if (ParamIsDefault(folderPath))
        folderPath=""
    endif
    if (ParamIsDefault(biasAscending))
        biasAscending=1
    endif
    if (ParamIsDefault(includeRetrace))
        includeRetrace=1
    endif
    String pathName=UniqueName("MX9SpectraPath",12,0)
    if (strlen(folderPath)==0)
        NewPath/Q/M="Choose the folder containing (V)_mtrx spectra and matching _0001.mtrx parameters" $pathName
    else
        NewPath/Q/Z $pathName,folderPath
    endif
    if (V_flag!=0)
        return 0
    endif
    PathInfo $pathName
    String folder=S_path,allFiles=IndexedFile($pathName,-1,"????")
    KillPath $pathName
    String files="",filename,waveName,errorText
    Variable i,j
    for (i=0;i<ItemsInList(allFiles);i+=1)
        filename=StringFromList(i,allFiles)
        if (StringMatch(filename,"*(V)_mtrx"))
            files+=filename+";"
        endif
    endfor
    // Ignore the filename's '--' sign: run 3 precedes run 10.
    files=SortList(files,";",80)
    if (ItemsInList(files)==0)
        DoAlert 0,"No (V)_mtrx files were found in the selected folder."
        return 0
    endif
    // An existing text list can be archived safely; other object types cannot.
    if (!MX9SpectraListSlotOK("root:File_Name") || !MX9SpectraListSlotOK("root:STS_SourceFiles"))
        Abort "File_Name or STS_SourceFiles is occupied by a non-text object. Rename that object before importing spectra."
    endif
    Make/FREE/T/N=0 nameLog,fileLog
    Variable nextSTS=1,importedFiles=0,skippedFiles=0,partialFiles=0,isPartial,readError,row
    for (i=0;i<ItemsInList(files);i+=1)
        filename=StringFromList(i,files)
        errorText=""
        isPartial=0
        Make/FREE/T/N=2 directions
        try
            WAVE/WAVE curves=MX9ReadSpectra(folder,filename,biasAscending,includeRetrace,directions,isPartial,errorText)
            AbortOnRTE
        catch
            readError=GetRTError(1)
            skippedFiles+=1
            Print "Skipped MATRIX spectrum: "+filename
            if (readError!=0)
                Print "Reason: "+GetErrMessage(readError)
            endif
            continue
        endtry
        if (strlen(errorText)>0 || numpnts(curves)==0)
            skippedFiles+=1
            Print "Skipped MATRIX spectrum: "+filename+"; "+errorText
            continue
        endif
        for (j=0;j<numpnts(curves);j+=1)
            WAVE oneCurve=curves[j]
            waveName=MX9NextSTSName(nextSTS)
            Duplicate oneCurve,$("root:"+waveName)
            row=numpnts(nameLog)
            InsertPoints row,1,nameLog,fileLog
            nameLog[row]=waveName
            fileLog[row]=filename
            Print waveName+" <- "+filename+" ["+directions[j]+"]"
        endfor
        importedFiles+=1
        partialFiles+=isPartial
    endfor
    if (numpnts(nameLog)>0)
        MX9SpectraShowSourceTable(nameLog,fileLog,folder)
    endif
    Print "MATRIX spectra: "+num2istr(importedFiles)+" files -> "+num2istr(numpnts(nameLog))+" root STS waves; "+num2istr(partialFiles)+" incomplete files; "+num2istr(skippedFiles)+" skipped files."
    Print "Bias: V. Signal: calibrated recorded unit. Unacquired samples remain NaN."
    return numpnts(nameLog)
End

Function/S MX9NextSTSName(nextSTS)
    Variable &nextSTS
    String candidate
    do
        candidate="STS"+num2istr(nextSTS)
        nextSTS+=1
    while (Exists("root:"+candidate) || DataFolderExists("root:"+candidate))
    return candidate
End

Function MX9SpectraListSlotOK(fullName)
    String fullName
    if (!Exists(fullName) && !DataFolderExists(fullName))
        return 1
    endif
    WAVE/Z/T existing=$fullName
    return WaveExists(existing)
End

// Rename the previous list, retaining its contents and existing table references.
Function MX9SpectraArchiveList(fullName,baseName)
    String fullName,baseName
    WAVE/Z/T previous=$fullName
    if (!WaveExists(previous))
        return 0
    endif
    Variable serial=1
    String backupName
    do
        backupName=baseName+num2istr(serial)
        serial+=1
    while (Exists("root:"+backupName) || DataFolderExists("root:"+backupName))
    Rename previous,$backupName
    Print "Previous list preserved as root:"+backupName
    return 1
End

Function MX9SpectraShowSourceTable(nameLog,fileLog,folder)
    WAVE/T nameLog,fileLog
    String folder
    MX9SpectraArchiveList("root:File_Name","File_Name_Backup")
    MX9SpectraArchiveList("root:STS_SourceFiles","STS_SourceFiles_Backup")
    Duplicate nameLog,root:File_Name
    Duplicate fileLog,root:STS_SourceFiles
    WAVE/T names=root:File_Name,sources=root:STS_SourceFiles
    String annotation="Loader=MatrixLoadSpectra\rSourceFolder="+folder+"\rColumns=WaveName,SourceFileName\rBatch=latest successful import\rDirection=See STS Wave Note, Trace\r"
    Note names,annotation
    Note sources,annotation
    String tableName=UniqueName("MatrixSpectraSources",6,0)
    Edit/N=$tableName/W=(60,80,1000,520) names,sources as "MATRIX spectra: STS name -> source file"
    ModifyTable width(names)=140,width(sources)=720
End

// One file contains one stored trace/retrace pair. Unknown multi-curve layouts
// are rejected instead of being silently resized or combined.
Function/WAVE MX9ReadSpectra(folder,filename,biasAscending,includeRetrace,directions,isPartial,errorText)
    String folder,filename
    Variable biasAscending,includeRetrace
    WAVE/T directions
    Variable &isPartial
    String &errorText
    Make/FREE/WAVE/N=0 curves
    errorText=""
    isPartial=0
    Variable sep=strsearch(filename,"--",Inf,1),dot=strsearch(filename,".",sep+2)
    if (sep<0 || dot<0 || !StringMatch(filename,"*(V)_mtrx"))
        errorText="Not a MATRIX voltage-spectrum filename."
        return curves
    endif
    STRUCT MX9Meta meta
    meta.parameters=""
    meta.transferTypes=""
    meta.transferValues=""
    meta.wantedChannel=filename[dot+1,strlen(filename)-6]
    meta.channelUnit=""
    meta.wantedFile=filename
    meta.channelID=-1
    meta.found=0
    String chainBase=folder+filename[0,sep-1],chainFile,bytes
    Variable link=1,pos
    do
        sprintf chainFile,"%s_%04d.mtrx",chainBase,link
        bytes=MX9ReadFile(chainFile,1)
        if (strlen(bytes)==0)
            errorText="Missing parameter chain or BREF: "+chainFile
            return curves
        endif
        MX9CheckMagic(bytes)
        pos=12
        do
            pos=MX9ParamBlock(bytes,pos,strlen(bytes),meta)
        while (pos<strlen(bytes) && !meta.found)
        link+=1
    while (!meta.found)
    if (MX9Required(meta.parameters,"XYScanner.Enable_Subgrid")!=0)
        errorText="Spatial grid; use Load Grid instead."
        return curves
    endif
    Variable device=0
    if (cmpstr(StringByKey("Device1Unit",meta.parameters,"=","\r"),"Volt")==0)
        device=1
    elseif (cmpstr(StringByKey("Device2Unit",meta.parameters,"=","\r"),"Volt")==0)
        device=2
    endif
    if (device==0)
        errorText="No voltage spectroscopy device was identified."
        return curves
    endif
    String deviceKey="Spectroscopy.Device_"+num2istr(device)
    Variable n=MX9Required(meta.parameters,deviceKey+"_Points")
    Variable startV=MX9Required(meta.parameters,deviceKey+"_Start")
    Variable endV=MX9Required(meta.parameters,deviceKey+"_End")
    Variable reversal=MX9Required(meta.parameters,"Spectroscopy.Enable_Device_"+num2istr(device)+"_Ramp_Reversal")
    if (n<2 || n!=floor(n) || startV==endV || (reversal!=0 && reversal!=1))
        errorText="Invalid voltage points, endpoints or reversal flag."
        return curves
    endif
    bytes=MX9ReadFile(folder+filename,0)
    MX9CheckMagic(bytes)
    Variable dataOffset=-1,dataCount=-1,declaredCount=-1,fullCount=-1,expected=n*(1+reversal)
    MX9DataBlocksFull(bytes,12,strlen(bytes),dataOffset,dataCount,declaredCount,fullCount)
    if (dataOffset<0 || dataCount<1 || dataCount!=declaredCount || dataCount>expected || fullCount!=expected)
        errorText="Payload is not a single recorded voltage trace/retrace pair."
        return curves
    endif
    isPartial=dataCount<expected
    WAVE raw=StringToUnsignedByteWave(bytes[dataOffset,dataOffset+4*dataCount-1])
    Redimension/E=1/I/N=(dataCount) raw
    String id=num2istr(meta.channelID),transfer=StringByKey(id,meta.transferTypes,"=","\r")
    Variable factor,offset=MX9Required(meta.transferValues,id+".Offset")
    if (cmpstr(transfer,"TFF_Linear1D")==0)
        factor=1/MX9Required(meta.transferValues,id+".Factor")
    elseif (cmpstr(transfer,"TFF_MultiLinear1D")==0)
        factor=(MX9Required(meta.transferValues,id+".Raw_1")-MX9Required(meta.transferValues,id+".PreOffset"))/(MX9Required(meta.transferValues,id+".NeutralFactor")*MX9Required(meta.transferValues,id+".PreFactor"))
    else
        errorText="Unsupported transfer function: "+transfer
        return curves
    endif
    if (numtype(factor)!=0 || factor==0 || strlen(meta.channelUnit)==0)
        errorText="Invalid spectrum calibration."
        return curves
    endif
    Variable sweep,index=0,rawStart,firstV,lastV,reverseV,validPoints
    String direction,annotation,signalUnit=meta.channelUnit
    for (sweep=0;sweep<=reversal;sweep+=1)
        rawStart=sweep*n
        if ((sweep && !includeRetrace) || rawStart>=dataCount)
            continue
        endif
        firstV=sweep ? endV : startV
        lastV=sweep ? startV : endV
        reverseV=biasAscending && firstV>lastV
        Make/FREE/D/N=(n) result
        result=rawStart+(reverseV ? n-1-p : p)
        result=result[p]<dataCount ? (raw[min(result[p],dataCount-1)]-offset)*factor : NaN
        SetScale/I x,(reverseV ? lastV : firstV),(reverseV ? firstV : lastV),"V",result
        SetScale d,0,0,signalUnit,result
        direction=SelectString(sweep,"trace","retrace")
        validPoints=min(n,dataCount-rawStart)
        annotation="Source="+folder+filename+"\rSourceFile="+filename+"\rChannel="+meta.wantedChannel+"\rTrace="+direction+"\r"
        annotation+="Dimensions=bias\rVoltageDevice="+num2istr(device)+"\rBiasAscending="+num2istr(biasAscending!=0)+"\r"
        annotation+="IncompleteFile="+num2istr(isPartial)+"\rAcquiredPoints="+num2istr(validPoints)+"\rUnacquiredPoints=NaN\r"
        annotation+="Calibration="+transfer+"\r"+meta.parameters
        Note result,annotation
        Redimension/N=(index+1) curves
        curves[index]=result
        directions[index]=direction
        index+=1
    endfor
    Redimension/N=(index) directions
    return curves
End
