#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
Function SaveGraph2()
	String curr=GetDataFolder(1)
	SetDataFolder root:
	String wNamelist,wName,gName,expName,s0=""
	gName=WinName(0,1)
	expName=Igorinfo(1)
	pathinfo home
	s0+=S_Path+expName+".pxp"
	s0+="\r@\r"
	s0+=gname
	s0+="\r@\r"
	GetWindow kwTopWin,wavelist
	variable i,n
	Wave/T wList=W_WaveList
	n=DimSize(wList,0)
	for(i=0;i<n;i+=1)
		wName=wList[i][1]
		s0+=wName+";"
	endfor
	s0+="\r@\r"
	String procText=WinRecreation(gName,2)
	procText=SetWaveNameinProcText(wList,procText)
	s0+=procText
	PutScrapText s0
	KillWaves wList
	SetDataFolder curr
end

Function/S SetWaveNameinProcText(wList,procText)
	Wave/T wList
	String procText
	String s0=procText,s1,s2
	Variable i,n=Dimsize(wList,0)
	for(i=0;i<n;i+=1)
		s1=wList[i][2]
		s0=ReplaceString(s1, s0, PossiblyQuoteName(wList[i][0]))
	endfor
	return s0
End

Function LoadGraph()
	String s0=GetScrapText()
	String filePath=StringFromList(0,s0,"@")
	String nGraph=StringFromList(1,s0,"@")
	String dataInfo=StringFromList(2,s0,"@")
	String gRec=StringFromList(3,s0,"@")
	if(strlen(nGraph)==0)
		Abort "First Save a Graph!"
	endif
	filePath=filePath[0,strlen(filePath)-2]
	dataInfo=dataInfo[1,strlen(dataInfo)-2]
	Variable n=ItemsInList(dataInfo),i
	String wName,path,fullp
	Variable pos
	String curr=GetDataFolder(1)
	SetDataFolder root:
	nGraph=nGraph[1,strlen(nGraph)-2]
	NewDataFolder/O/S $nGraph
	for(i=0;i<n;i+=1)
		path=StringFromList(i,dataInfo)
		pos=StrSearch(path,":",inf,1)
		wName=path[pos+1,strlen(path)]
		wName=RemoveSingleQuote(wName)
		path=path[0,pos]
		LoadData/Q/S=path/O/J=wName filePath
	endfor
	n=ItemsInList(grec,"\r")
	String cmd,s1,s2,s3,s4=""
	Variable j,n1
	for(i=3;i<n-1;i+=1)
		cmd=StringFromList(i,grec,"\r")
		if(StrSearch(cmd,"String",0)!=-1||StrSearch(cmd,"SetDataFolder",0)!=-1)
			continue
		endif
		if(StrSearch(cmd,"Append",0)!=-1)
			cmd=RebuildAppendCmd(cmd)
		endif
		Execute cmd
	endfor
End

Function/S RemoveSingleQuote(s0)
	string s0
	Variable pos=StrSearch(s0,"'",0)
	if(-1!=pos)
		s0=s0[1,strlen(s0)-2]
	endif
	return s0
End

Function/S RebuildAppendCmd(cmd)
	String cmd
	Variable i,n,pos
	String s0,s1,s2,s3=""
	pos=StrSearch(cmd," ",0)
	s0=cmd[0,pos-1]
	s1=cmd[pos,strlen(cmd)]
	n=ItemsInList(s1,",")
	for(i=0;i<n;i+=1)
		s2=StringFromList(i,s1,",")
		s3=s3+s2+","
	endfor
	s3=s3[0,strlen(s3)-2]
	return s0+" "+s3
End

Menu "TransferGraph"
	"SaveGraph",/Q
	"LoadGraph",/Q
End
