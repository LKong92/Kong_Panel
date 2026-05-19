#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
Function/Wave Rotxy(degree,x0,y0,Dis)
	variable degree
	variable x0
	variable y0
	variable Dis

	make/n=(2,2)/o rotatematrix
	rotatematrix={{cos(degree*pi/180),sin(degree*pi/180)},{-sin(degree*pi/180),cos(degree*pi/180)}}
	make/n=(2,1)/o xyinitial
	xyinitial={{x0,y0}}
	matrixmultiply rotatematrix,xyinitial
	killwaves rotatematrix xyinitial
	wave M_productw = $"M_product"
	if (Dis == 0)
	else
		Print "x_r = "+num2str(M_productw[0][0])
		Print "y_r = "+num2str(M_productw[1][0])

	endif
	return M_productw
end

Function ButtonProc_Newrotateproc(ctrlName) : ButtonControl
	String ctrlName
	Execute "Newrotateproc()"
end
//////
Proc Newrotateproc(name,theta1)
	String name = tpw()
	variable theta1
	Prompt name,"the name of the matrix to be rotated"
	Prompt theta1,"Angel (couterclockwise is positive), please only use value within -90 to 90"
	Newrotate(name,theta1)
end
//////
Function Newrotate(name,theta1)
	String name
	variable theta1 // counter clock-wise degree

	wave namew=$name
	variable theta
	theta = theta1*pi/180

	make/o/N=(dimsize(namew,0),dimsize(namew,1)) xgrid
	make/o/N=(dimsize(namew,0),dimsize(namew,1)) ygrid
	setscale/p x,dimoffset(namew,0),dimdelta(namew,0),"",xgrid
	setscale/p y,dimoffset(namew,1),dimdelta(namew,1),"",xgrid
	setscale/p x,dimoffset(namew,0),dimdelta(namew,0),"",ygrid
	setscale/p y,dimoffset(namew,1),dimdelta(namew,1),"",ygrid

	ygrid =sin(theta)*x + cos(theta)*y
	xgrid =cos(theta)*x - sin(theta)*y


	//** Scatter Data interpolation ******************
		string zzlf="zz_"+name
		duplicate/o namew $zzlf
		wave zzlfw = $zzlf
		Redimension/N=(dimsize(zzlfw,0)*dimsize(zzlfw,1)) zzlfw

		string xxlf="xx_"+name
		duplicate/o xgrid $xxlf
		wave xxlfw = $xxlf
		Redimension/N=(dimsize(xxlfw,0)*dimsize(xxlfw,1)) xxlfw

		string yylf="yy_"+name
		duplicate/o ygrid $yylf
		wave yylfw = $yylf
		Redimension/N=(dimsize(yylfw,0)*dimsize(yylfw,1)) yylfw

		//define the dimsize of the interpolated data. // this is valid only the theta1 within [-90,90]
		variable newsizex=round(dimsize(namew,0)*cos(abs(theta))+dimsize(namew,1)*sin(abs(theta)))
		variable newsizey=round(dimsize(namew,0)*sin(abs(theta))+dimsize(namew,1)*cos(abs(theta)))

		//** scatterinterp(xxlfw,yylfw,zzlfw,namew,factor)
			String outputLF = name+"_Rot"+num2str(theta1)
			Make/O/N=(dimsize(xxlfw,0),3) sampleTripletRT
			sampleTripletRT[][0]=xxlfw[p]
			sampleTripletRT[][1]=yylfw[p]
			sampleTripletRT[][2]=zzlfw[p]
			ImageInterpolate/RESL={newsizex,newsizey}/DEST=$outputLF voronoi sampleTripletRT

	//** Plot
		wave outputLFw = $outputLF
		func_NaN0(outputLFw)
		dilf(outputLFw)
end
/////////////
Function p2dtopeak_rot(name)
	string name
	wave n=$name
	variable xxx
	xxx=dimsize(n,0)*dimsize(n,1)
	make/o/N=(xxx) oneDtopo_rot
	variable i,j,k
	variable a,b
	i=0
	k=0
	do
		j=0
		do
			oneDtopo_rot[k]=n[i][j]
			j+=1
			k+=1
		while(j<dimsize(n,1))
		i+=1
	while(i<dimsize(n,0))
	//edit oneDtopo
end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// End
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////Initial procedure, now adapted to be function//////////////////////////////////////////////
proc tt(theta1,name)
	variable theta1 // angle to rotate counterclockwise
	string name //the data want to be rotated

	variable theta
	theta = theta1*pi/180

	make/o/N=(100,100) xgrid
	make/o/N=(100,100) ygrid

	•p2dtopeak(name)
	•duplicate/o oneDtopo zz;

	ygrid =sin(theta)*x + cos(theta)*y
	•p2dtopeak("ygrid")
	•duplicate/o oneDtopo yy;

	xgrid =cos(theta)*x - sin(theta)*y
	•p2dtopeak("xgrid")
	•duplicate/o oneDtopo xx;

	Make/O/N=(dimsize(xx,0),3) sampleTriplet
	sampleTriplet[][0]=xx[p]
	sampleTriplet[][1]=yy[p]
	sampleTriplet[][2]=zz[p]
	ImageInterpolate/RESL={200,200}/DEST=firstImage voronoi sampleTriplet

end



/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
//   An interactive GUI for contineously rotate matrix
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Controtate(ctrlName) : ButtonControl
	String ctrlName
	Execute "Controtate()"
end
Proc Controtate()
	variable/G theta_rt
	String/G name_rt = tpw()+"_INTER"
	//display;
	twoDinterpolatexycr(tpw(),50,50)
	string rotname = "rotc_"+name_rt
	duplicate/O $name_rt  $rotname
	//appendImage $rotname
	dilf($rotname)
	modifygraph width=400,height=400
	ModifyGraph width={Plan,1,bottom,left},height=0
	SetVariable setvar0 title="θ",size={100,20},value=theta_rt,proc=SetVarProc_Controtate
	SetVariable setvar0 limits={-360,360,0.5}
end
Function SetVarProc_Controtate(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	execute "Newrotateproccont()"
End

Proc Newrotateproccont()
	String name = name_rt
	variable theta1 = theta_rt
	Newrotatecont(name,theta1)
end
//////
Function Newrotatecont(name,theta1)
	String name
	variable theta1 // counter clock-wise degree

	wave namew=$name
	variable theta
	theta = theta1*pi/180

	make/o/N=(dimsize(namew,0),dimsize(namew,1)) xgrid
	make/o/N=(dimsize(namew,0),dimsize(namew,1)) ygrid

	setscale/p x,dimoffset(namew,0),dimdelta(namew,0),"",xgrid
	setscale/p y,dimoffset(namew,1),dimdelta(namew,1),"",xgrid
	setscale/p x,dimoffset(namew,0),dimdelta(namew,0),"",ygrid
	setscale/p y,dimoffset(namew,1),dimdelta(namew,1),"",ygrid
	ygrid =sin(theta)*x + cos(theta)*y
	xgrid =cos(theta)*x - sin(theta)*y


	//** Scatter Data interpolation ******************
		string zzlf="zz_"+name
		duplicate/o namew $zzlf
		wave zzlfw = $zzlf
		Redimension/N=(dimsize(zzlfw,0)*dimsize(zzlfw,1)) zzlfw

		string xxlf="xx_"+name
		duplicate/o xgrid $xxlf
		wave xxlfw = $xxlf
		Redimension/N=(dimsize(xxlfw,0)*dimsize(xxlfw,1)) xxlfw

		string yylf="yy_"+name
		duplicate/o ygrid $yylf
		wave yylfw = $yylf
		Redimension/N=(dimsize(yylfw,0)*dimsize(yylfw,1)) yylfw

		//define the dimsize of the interpolated data. // this is valid only the theta1 within [-90,90]
		//variable newsizex=round(dimsize(namew,0)*cos(abs(theta))+dimsize(namew,1)*sin(abs(theta)))
		//variable newsizey=round(dimsize(namew,0)*sin(abs(theta))+dimsize(namew,1)*cos(abs(theta)))

		//** scatterinterp(xxlfw,yylfw,zzlfw,namew,factor)
			String outputLF = "rotc_"+name
			Make/O/N=(dimsize(xxlfw,0),3) sampleTripletRT
			sampleTripletRT[][0]=xxlfw[p]
			sampleTripletRT[][1]=yylfw[p]
			sampleTripletRT[][2]=zzlfw[p]
			ImageInterpolate/RESL={4*dimsize(namew,0),4*dimsize(namew,0)}/DEST=$outputLF voronoi sampleTripletRT

	//** Plot
		wave outputLFw = $outputLF
		func_NaN0(outputLFw)
end

Function twoDinterpolatexycr(name,xpoint,ypoint)
	string name
	variable xpoint
	variable ypoint

	variable i
	variable j
	variable k
	variable sizex, sizey
	string curve1,curve2,curve11,curve22,name1,name2
	wave namew=$name
	sizex=dimsize(namew,0)
	sizey=dimsize(namew,1)
	i=0
	do
		curve1="curve1_"+num2str(i)
		curve11="curve1L_"+num2str(i)

		make/O/N=(sizey) $curve1
		wave curve1w = $curve1

		curve1w[]=namew[i][p]
		interpolate2/n=(ypoint) /t=1/Y=$curve11 $curve1
		killwaves curve1w
		i+=1
	while(i<sizex)
	name1=name+"1"
	make/O/N=(sizex,ypoint) $name1
	wave name1w = $name1
	makematrix2(name1,sizex,ypoint)
	//display;appendimage name1w

	j=0
	do
		curve2="curve2_"+num2str(j)
		curve22="curve2L_"+num2str(j)

		make/O/N=(sizex) $curve2
		wave curve2w = $curve2

		curve2w[]=name1w[p][j]
		interpolate2/n=(xpoint) /t=1/Y=$curve22 $curve2
		killwaves curve2w
		j+=1
	while(j<ypoint)
	name2=name+"_INTER"
	make/O/N=(xpoint,ypoint) $name2
	makematrix3(name2,xpoint,ypoint)
	setscale/I x,dimoffset($name,0),dimoffset($name,0)+dimdelta($name,0)*(dimsize($name,0)-1),""$name2
	setscale/I y,dimoffset($name,1),dimoffset($name,1)+dimdelta($name,1)*(dimsize($name,1)-1),""$name2
end
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
//   End of the GUI demo procedure
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Loadnewmk(ctrlName) : ButtonControl//"Load BNL Data in Folder"
	String ctrlName

	execute "setDataFolder Root:"
	Execute "Makegraphtable()"
	Execute "LoadDataFromNewmk()"
	Execute "Initialize_Global_Variables()"
End


Proc LoadDataFromNewmk(x,y)
	variable x=0
      variable y=8//y=1: current// y=8: dI/dV
      prompt x,"Column Number of x wave"
      prompt y,"Column Number of y wave"
      newpath /O tempPath
	String Pathname="tempPath"
	Variable  Loadn=ItemsInList(IndexedFile($PathName,-1,".dat"))
	//print IndexedFile($PathName,-1,".dat")
	Variable  DataNum
	String  savedDataFolder=getDataFolder(1)
	String 	Filename, FolderName
	String kstring
	Variable condition
	Variable n,m
	Variable index
	Variable firstnumfirst,firstnumlast,secondnumfirst,secondnumlast,i
	String datalist=IndexedFile($pathName, -1, ".dat")//For arrange data
	String objName
	if(wintype("Information_table")==0)
		DataNum=0
	endif
	if(winType("Information_table")==2)
		DataNum=Dimsize(File_Name,0)
	endif
		m=loadn-DataNum+1
		InSertPoints DataNum, m,File_Name
	string mat,matt
	n=DataNum


	Do
		Filename = stringfromlist(n-1, sortlist(datalist,";",16))//For arrange data
		//Filename=IndexedFile($PathName,n-1,".dat")
		//print FileName
		File_Name[n]=FileName
		//LoadWave/F={5,14,0}/D/K=1/L={0,71,0,0,0}/O/A=load/P=$PATHName Filename
                     LoadWave/G/D/A=load/K=1/L={0,0,0,x,1}/o/P=$PATHName Filename
                     LoadWave/G/D/A=load/K=1/L={0,0,0,y,1}/o/P=$PATHName Filename
		mat="sts"+num2str(n)
		matt="data"+num2str(n)

		Interpolate2/T=2/N=(dimsize(load0,0))/E=2/Y=$mat load0,load1
	       //Setscale/P x, dimoffset(load0,0),dimdelta(load0,0),"",load3
		//duplicate/o sts $mat
		duplicate/o $mat $matt
                 KillWaves  load0,load1
		n+=1
	While(n<=Loadn)
	setDataFolder $savedDataFolder
End
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////






Function ButtonProc_dataplotersts(ctrlName) : ButtonControl
	String ctrlName
	If(wintype("dataploter")==0)
		Execute "dataplotersts()"
		Else
			DoWindow/F dataploter
	Endif
End


Window dataplotersts() : Graph
	PauseUpdate; Silent 1		// building window...
	Display /W=(144,71,527,485)
	Appendtograph sts1
	//ModifyImage Data1 ctab= {*,*,PlanetEarth,0}
	//ModifyGraph wbRGB=(60928,60928,60928),gbRGB=(60928,60928,60928)
	ModifyGraph mirror=2
	ShowInfo
	ControlBar 74
	SetVariable varplot,pos={5,4},size={100,20},proc=setvarplotsts,title="Data"
	SetVariable varplot,fSize=14,limits={1,inf,1},value= gv_GroupNum
	//Button button0,pos={111,4},size={80,20},proc=ButtonProc_DisplayMat,title="Make Image"
	//Button button1,pos={270,4},size={35,20},proc=ButtonProc_MakeEDC,title="EDC"
	//Button button2,pos={309,4},size={35,20},proc=ButtonProc_MkMDC,title="MDC"
	//Button button3,pos={4,26},size={60,20},proc=ButtonProc_ConvertSingleData,title="Cvt data"
	//Button button4,pos={194,4},size={30,20},proc=ButtonProc_MatNkPlot,title="NK"
	//Button button5,pos={227,4},size={40,20},proc=ButtonProc_MatNorm,title="Norm"
	//Button Open_this_data,pos={67,26},size={100,20},proc=ButtonProc_open_onedata_pi,title="Open this data"
	//Button Rem_dataedc,pos={169,26},size={85,20},proc=ButtonProc_Remove_data_EDC,title="Subtract EDC"
	//Button but_rm_background,pos={256,26},size={115,20},proc=ButtonProc_Rm_simplebgnd_data,title="Remove backgrnd"
	//Button buttonfilter,pos={4,49},size={65,20},proc=ButtonFFTfilterdata,title="FFT filter"
	//Button buttonshowmain,pos={295,49},size={75,20},title="Main Panel",fStyle=16
	//Button buttonfftlist,pos={73,49},size={60,20},proc=ButtonProc_FFTlist,title="FFT list"
	//Button button6,pos={136,49},size={120,20},proc=ButtonProc_add_this_data,title="Combine this data"
	//Button buttonhelp,pos={351,3},size={25,20},proc=Button_Help_Data_ploter,title="\\K(65535,65535,65535)?"
	//Button buttonhelp,fSize=15,fStyle=16,fColor=(16385,16388,65535)
	ModifyGraph mirror=2
EndMacro


Function setvarplotsts(ctrlName,varNum,varStr,varName): SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
//	print ctrlName,varNum,varStr,varName
	Execute "plotrawsts()"
	//Execute "show_dos()"
End



Proc plotrawsts()
	String thedata
	String old_image,old_image_list
	String/G info
	Variable/G gv_GroupNum
	Variable i
	thedata="sts"+num2str(gv_GroupNum)
	old_image_list=WaveList("*", ";", "WIN:dataploterSTS")
	old_image=StringFromList(0,old_image_list)
	If(WaveExists($old_image)==1)
		RemoveFromGraph $old_image
	Endif
	If(WaveExists($thedata)==1)
		Appendtograph $thedata
		//ModifyImage $thedata ctab= {*,*,PlanetEarth,0}
	Endif
	info=File_Name[gv_GroupNum]
End
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
/////    Load two columes and then average those column for Y-wave
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
/////////////////////////////
//This is an old version, I replace it by a new one.
//
/////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

Function ButtonProc_Loadnewmk_ave(ctrlName) : ButtonControl//"Load BNL Data in Folder"
	String ctrlName

	execute "setDataFolder Root:"
	Execute "Makegraphtable()"
	Execute "LoadDataFromNewmk_ave()"
	Execute "Initialize_Global_Variables()"
End
Proc LoadDataFromNewmk_ave(x,y1,y2)
         variable x=0
         variable y1=2//y=1: current// y=2: dI/dV
         variable y2=7//y=1: current// y=2: dI/dV
         prompt x,"Column Number of x wave"
         prompt y1,"Column Number of y1 wave to ave"
         prompt y2,"Column Number of y2 wave to ave"
        newpath /O tempPath
	String Pathname="tempPath"
	Variable  Loadn=ItemsInList(IndexedFile($PathName,-1,".dat"))
	print IndexedFile($PathName,-1,".dat")
print "hahahahhahahahha"
print loadn

	Variable  DataNum
	String  savedDataFolder=getDataFolder(1)
	String 	Filename, FolderName
	String kstring
	Variable condition
	Variable n,m
	Variable index
	Variable firstnumfirst,firstnumlast,secondnumfirst,secondnumlast,i
	String objName
	if(wintype("Information_table")==0)
		DataNum=0
	endif
	if(winType("Information_table")==2)
		DataNum=Dimsize(File_Name,0)
	endif
		m=loadn-DataNum+1
		InSertPoints DataNum, m,File_Name
	string mat,matt
	n=DataNum
	Do
		Filename=IndexedFile($PathName,n-1,".dat")
		print FileName
		File_Name[n]=FileName
		//LoadWave/F={5,14,0}/D/K=1/L={0,71,0,0,0}/O/A=load/P=$PATHName Filename
                     LoadWave/G/D/A=load/K=1/L={0,0,0,x,1}/o/P=$PATHName Filename
                     LoadWave/G/D/A=load/K=1/L={0,0,0,y1,1}/o/P=$PATHName Filename
                     LoadWave/G/D/A=load/K=1/L={0,0,0,y2,1}/o/P=$PATHName Filename

		mat="sts"+num2str(n)
		matt="data"+num2str(n)
             duplicate/o load2 lll
             lll=(load1+load2)/2
		Interpolate2/T=2/N=(dimsize(load0,0))/E=2/Y=$mat load0,lll
	       //Setscale/P x, dimoffset(load0,0),dimdelta(load0,0),"",load3
		//duplicate/o sts $mat
		duplicate/o $mat $matt
                 KillWaves  load0,load1,load2,lll
		n+=1
	While(n<=Loadn)
setDataFolder $savedDataFolder
End
//////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
/////    Load two columes and then average those column for Y-wave
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
////     The new version
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////
//LOAD DATA and average the forward and backward data
//Also make the conducatance value correct, follow the setpoint,
//Assuming the First data point of the forward scan is the real setpoint
//So that the averaged data is scaled following this point.


Function ButtonProc_Loadnewmkfab(ctrlName) : ButtonControl//"Load BNL Data in Folder"
	String ctrlName

	execute "setDataFolder Root:"
	Execute "Makegraphtable()"
	Execute "LoadDataFromNewmkfab()"
	Execute "Initialize_Global_Variables()"
End


Proc LoadDataFromNewmkfab(x,y1,y2)
	variable x=0
    variable y1=5//y=1: current// y=8: dI/dV
    variable y2=10//y=1: current// y=8: dI/dV
    prompt x,"Column Number of x wave"
    prompt y1,"Column Number of y wave [Forward]"
    prompt y2,"Column Number of y wave [Backward]"

    newpath /O tempPath
	String Pathname="tempPath"
	Variable  Loadn=ItemsInList(IndexedFile($PathName,-1,".dat"))
	//print IndexedFile($PathName,-1,".dat")
	Variable  DataNum
	String  savedDataFolder=getDataFolder(1)
	String 	Filename, FolderName
	String kstring
	Variable condition
	Variable n,m
	Variable index
	Variable firstnumfirst,firstnumlast,secondnumfirst,secondnumlast,i
	String datalist=IndexedFile($pathName, -1, ".dat")//For arrange data
	String objName
	if(wintype("Information_table")==0)
		DataNum=0
	endif
	if(winType("Information_table")==2)
		DataNum=Dimsize(File_Name,0)
	endif
		m=loadn-DataNum+1
		InSertPoints DataNum, m,File_Name
	string mat,matt
	n=DataNum
	variable convfb


	Do
		Filename = stringfromlist(n-1, sortlist(datalist,";",16))//For arrange data
		//Filename=IndexedFile($PathName,n-1,".dat")
		//print FileName
		File_Name[n]=FileName
		//LoadWave/F={5,14,0}/D/K=1/L={0,71,0,0,0}/O/A=load/P=$PATHName Filename
        LoadWave/G/D/A=load/K=1/L={0,0,0,x,1}/o/P=$PATHName Filename
        LoadWave/G/D/A=load/K=1/L={0,0,0,y1,1}/o/P=$PATHName Filename
		LoadWave/G/D/A=load/K=1/L={0,0,0,y2,1}/o/P=$PATHName Filename

		duplicate/o load2 loadave

		loadave = load2 + load1

		convfb = loadave[0]/load1[0]
		loadave/=convfb                              //This is the normalization, assuming the first data point of forward scan is the true setpoint

		mat="sts"+num2str(n)
		matt="data"+num2str(n)

		//Interpolate2/T=2/N=(dimsize(load0,0))/E=2/Y=$mat load0,load1
	    //Setscale/P x, dimoffset(load0,0),dimdelta(load0,0),"",load3
		//duplicate/o sts $mat
		Interpolate2/T=2/N=(dimsize(load0,0))/E=2/Y=$mat load0,loadave

		duplicate/o $mat $matt
        KillWaves  load0,load1, load2, loadave
		n+=1
	While(n<=Loadn)
	setDataFolder $savedDataFolder
End
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////




Proc renormcut_ky(matname,factor)
	String matname
	Variable factor
	Prompt matname,"Enter the name of the cut"
	Prompt factor,"Enter the convertion factor (to divide)"
	PauseUpdate
	Silent 1
	Setscale/P y,dimoffset($matname,1)/factor,dimdelta($matname,1)/factor,""$matname
End

Function ButtonProc_LoadDA30(ctrlName) : ButtonControl//"Load SSRFDA30 in Folder"
	String ctrlName
	Execute "loadDA30_kly()"
End

Function ButtonProc_renormcuts_k(ctrlName) : ButtonControl
	String ctrlName
	Execute "renormcuts_k()"
End

Function ButtonProc_kly_mapping(ctrlName) : ButtonControl
	String ctrlName
	Execute "kly_mapping()"
End

Function ButtonProc_CVT2EK_pi_renorm(ctrlName) : ButtonControl
	String ctrlName
	Execute "CVT2EK_pi_renorm()"
End

Function ButtonProc_Kz_predict(ctrlName) : ButtonControl
	String ctrlName
	Execute " Kz_predict()"
End

Function ButtonProc_calculate_v0(ctrlName) : ButtonControl
	String ctrlName
	Execute " calculate_v0()"
End

Function ButtonProc_kly_Kzmap(ctrlName) : ButtonControl
	String ctrlName
	Execute "kly_Kzmap()"
End

Function ButtonProc_MBE1MLTime(ctrlName) : ButtonControl
	String ctrlName
	Execute "  MBE1MLTime()"
End
//********************************************************************************************************************************

	Proc kly_mapping(initial_angel,final_angel,map_delta,initial_index)
	Variable initial_angel
	variable final_angel
	Variable map_delta=1
	Variable initial_index=1
	Prompt initial_angel,"Polar of mapping begining"
	Prompt map_delta,"Polar delta"
	Prompt initial_index,"index of data begining"
	Prompt final_angel,"Polar of mapping ending"

	PauseUpdate
	Silent 1

	MakeImageTable();MakeCutTable()
	variable map_numcuts
	map_numcuts= dimsize(file_name,0)-1
	Redimension/N=(map_numcuts) ImageIndex,ImageIndex,Imagetheta,imagephi,wavest,waveed,waveetast,waveetaed,phiindex;
	imageindex=initial_index+p; imagephi=initial_angel+map_delta*p;phiindex=imagephi
	waveetaed=DimSize($("data"+num2str(initial_index)),0)-1
	waveed=DimSize($("data"+num2str(initial_index)),0)-1
	Generate_chunklist(0,initial_angel,final_angel,0)
	Make_allchunkcuts()
	allcuts(0,0)
	mat3d_pir()

	if(Wintype("mat3d_fs_ploter")==0)
		Execute "initmat3d()"
		Execute "mat3d_fs_ploter()"
		Execute "initmat3d()"
		Else
			Dowindow/F mat3d_fs_ploter
	Endif
End
Proc mat3d_pir()//scaling)
//	Variable scaling
//        Prompt scaling,"Did you already rescaled the energy?",popup "Yes;No"
	PauseUpdate
	Silent 1
	Variable/G SRC_vs_BNL
	Variable num_of_phi,delta_phi,first_phi,temp_delta_phi,last_phi,total_phi
	Variable total_theta,delta_theta,first_theta,last_theta,first_temp,last_temp
	Variable energy_0,delta_energy,total_energy,last_energy
	Variable i,j,k,j_index,i_start
	Variable phi
	String cutname
//	If(scalling==1)
//		Execute energy_ajust_pi()
//	Endif
	//Find the smallest separation in Phi, the first and the last phi
	first_phi=Phiindex[0]
	num_of_phi=dimsize(Phiindex,0)
	last_phi=Phiindex[num_of_phi-1]
	delta_phi=9999
	i=1
	Do
		temp_delta_phi=Phiindex[i]-Phiindex[i-1]
		If(temp_delta_phi<delta_phi)
			delta_phi=temp_delta_phi
		Endif
		i+=1
	While(i<num_of_phi)
	total_phi=floor((last_phi-first_phi)/delta_phi+1)
	//Find the smallest separation in theta, the first and the last theta
	last_theta=-9999
	i=0
	cutname="cut"+num2str(phiindex[0])
	first_theta=dimoffset($cutname,0)
	delta_theta=dimdelta($cutname,0)
	Do
		cutname="cut"+num2str(phiindex[i])
		first_temp=dimoffset($cutname,0)
		last_temp=first_temp+(dimsize($cutname,0)-1)*delta_theta
		If(first_temp<first_theta)
			first_theta=first_temp
		Endif
		If(last_temp>last_theta)
			last_theta=last_temp
		Endif
		i+=1
	While(i<num_of_phi)
	total_theta=floor((last_theta-first_theta)/delta_theta+1)
	//Find the scalling for the energy
	delta_energy=dimdelta($cutname,1)
	i=0
	cutname="cut"+num2str(phiindex[0])
	energy_0=dimoffset($cutname,1)
	last_energy=-9999
	Do
		cutname="cut"+num2str(phiindex[i])
		first_temp=dimoffset($cutname,1)
		last_temp=first_temp+(dimsize($cutname,1)-1)*delta_energy
		If(first_temp<energy_0)
			energy_0=first_temp
		Endif
		If(last_temp>last_energy)
			last_energy=last_temp
		Endif
		i+=1
	While(i<dimoffset($cutname,1))
	total_energy=floor((last_energy-energy_0)/delta_energy+1)
//	energy_0=dimoffset($cutname,1)
//	total_energy=dimsize($cutname,1)
//	delta_energy=dimdelta($cutname,1)
	//Copying the matrix elements
	If(SRC_vs_BNL==0)
		Make/O/N=(total_theta,total_energy,total_phi) mat3d
		setscale/p x,first_theta,delta_theta,"", mat3d
		setscale/p z,first_phi,delta_phi,"",mat3d
		setscale/p y,energy_0,delta_energy,"",mat3d
		mat3d[][][]=0
		j=0
		j_index=0
		Do
			phi=first_phi+j*delta_phi
			If(abs(phi-phiindex[j])<=0.0001)
				cutname="cut"+num2str(phiindex[j_index])
				first_temp=floor((dimoffset($cutname,1)-energy_0)/delta_energy)
				i_start=floor((dimoffset($cutname,0)-first_theta)/delta_theta)
				Make/O/N=(dimsize($cutname,0),total_energy) cut_temp
				cut_temp[][]=0
				i=0
				Do
					cut_temp[][i+first_temp]=$cutname[p][i]
					i+=1
				While(i<dimsize($cutname,1))
				i=0
				Do
					mat3d[i+i_start][][j]=cut_temp[i][q]
					i+=1
				While(i<dimsize($cutname,0))
				j_index+=1
			Endif
		j+=1
		While(j<total_phi)
	Endif
	If(SRC_vs_BNL==1)
		Make/O/N=(total_phi,total_energy,total_theta) mat3d
		setscale/p z,first_theta,delta_theta,"", mat3d
		setscale/p x,first_phi,delta_phi,"",mat3d
		setscale/p y,energy_0,delta_energy,"",mat3d
		mat3d[][][]=0
		j=0
		j_index=0
		Do
			phi=first_phi+j*delta_phi
			If(abs(phi-phiindex[j])<=0.0001)
				cutname="cut"+num2str(phiindex[j_index])
				first_temp=floor((dimoffset($cutname,1)-energy_0)/delta_energy)
				i_start=floor((dimoffset($cutname,0)-first_theta)/delta_theta)
				Make/O/N=(dimsize($cutname,0),total_energy) cut_temp
				cut_temp[][]=0
				i=0
				Do
					cut_temp[][i+first_temp]=$cutname[p][i]
					i+=1
				While(i<dimsize($cutname,1))
				i=0
				Do
					mat3d[j][][i+i_start]=cut_temp[i][q]
					i+=1
				While(i<dimsize($cutname,0))
				j_index+=1
			Endif
		j+=1
		While(j<total_phi)
	Endif
	Killwaves cut_temp
End

//********************************************************************************************************************************
Proc renormcuts_k(matname,which,factor)
	String matname = tpw()
	variable which
	Variable factor
	Prompt matname,"Enter the name of the cut"
	prompt which,"You want to renorm the kx or the ky?",popup "kx;ky;kz"
	Prompt factor,"Enter the convertion factor (to divide)"
	PauseUpdate
	Silent 1

	If(which==1)
	        Setscale/P x,dimoffset($matname,0)/factor,dimdelta($matname,0)/factor,""$matname
	  endif
	 if(which==2)
	    	Setscale/P y,dimoffset($matname,1)/factor,dimdelta($matname,1)/factor,""$matname
	 Endif
        if(which==3)
	    	Setscale/P Z,dimoffset($matname,2)/factor,dimdelta($matname,2)/factor,""$matname
	 Endif
	//** Error message, no stop but Continuing execution
		String msg
		Variable err
		msg=GetErrMessage(GetRTError(0),3);
		err=GetRTError(1)
		if (err != 0)
			//Print "Error in Demo: " + msg
			//Print "Continuing execution"
		endif
	//print "renormcuts_k("+matname+","+num2str(which)+","+num2str(factor)+")"
	print "renormcuts_k("+"\""+matname+"\""+","+num2str(which)+","+num2str(factor)+")"
End
//********************************************************************************************************************************
Proc CVT2EK_pi_renorm (oldmat,answ,fe,phi,factor)
       string oldmat
       Variable answ
       Variable fe=16.96
       Variable phi
       variable factor= 1
       Prompt oldmat,"Enter the matrix to transform"
	Prompt answ,"Do you want also to convert the energy?",popup "Yes;No"
	Prompt fe,"Enter the Fermi energy"
	Prompt phi,"Enter the manipulator angle (for V polarization only)"
	Prompt factor,"Enter the factors(pi/a) to renormlize Kx"

       PauseUpdate
	Silent 1
     	string newwavex,newwavez
	string lastwave
	string newmat
	variable/G SRC_vs_BNL
	variable x0,dx,delta,y0,dy
	variable i,j,KE
	variable oldx
	variable k0,kend,dk,k
	variable num_edc,num_mdc
	x0=dimoffset($oldmat,0)
	dx=dimdelta($oldmat,0)
	y0=dimoffset($oldmat,1)
	dy=dimdelta($oldmat,1)
	setscale/p x,x0,dx,"",$oldmat
	setscale/p y,y0,dy,"",$oldmat
	i=0
	num_edc=dimsize($oldmat,0)
	num_mdc=dimsize($oldmat,1)
	// We find the k values of the corresponding angles at various energies
	Do
		KE=y0+i*dy
		newwavex=oldmat+"_x"+Num2Str(i)
		newwavez=oldmat+"_z"+Num2Str(i)
		Make/O/N=(num_edc) $newwavex
		Make/O/N=(num_edc) $newwavez
		If(SRC_vs_BNL==0)
			$newwavex[]=Sqrt(KE)*0.51231*sin((x0+p*dx)*Pi/180)//*cos(phi*Pi/180)
			Else
				$newwavex[]=Sqrt(KE)*0.51231*sin((x0+p*dx)*Pi/180)*cos(phi*Pi/180)
		Endif
		$newwavez[]=$oldmat[p][i]
		i+=1
	While(i<dimsize($oldmat,1))
	//Now we find the appropriate dk and k values for an even spacing
	lastwave=oldmat+"_x"+Num2Str(dimsize($oldmat,1)-1)
	k0=$lastwave[0]
	kend=$lastwave[dimsize($oldmat,0)-1]
	dk=(kend-k0)/(dimsize($oldmat,0)-1)
	//Make the xwave evenly spaced and define a new matrix to image
	newmat=oldmat+"_k"
	Make/O/N=((dimsize($oldmat,0)),(dimsize($oldmat,1))) $newmat
	If(answ==1)
		y0-=fe
	Endif
	setscale/p x,k0,dk,"",$newmat
	setscale/p y,y0,dy,"",$newmat
	Setscale/P x,dimoffset($newmat,0)/factor,dimdelta($newmat,0)/factor,""$newmat
	Print "Making the final matrix"
	i=0
	Do
		If(mod(i,200)==0)
			Print i,"/",dimsize($oldmat,1)-1
		Endif
		newwavex=oldmat+"_x"+Num2Str(i)
		newwavez=oldmat+"_z"+Num2Str(i)
		func_CVT2EK_pi($newmat,$oldmat,$newwavex,$newwavez,k0,dk,i)
		i+=1
	While(i<dimsize($oldmat,1))
	Display
	Appendimage $newmat
	ModifyImage $newmat ctab= {*,*,grays,1}
	modifygraph width=150, height=150
	ResumeUpdate
	modifygraph width=0, height=0
	Showinfo
	i=0
	Do
		newwavex=oldmat+"_x"+Num2Str(i)
		newwavez=oldmat+"_z"+Num2Str(i)
		KillWaves $newwavex,$newwavez
		i+=1
	While(i<dimsize($oldmat,1))



	modifygraph width=350, height=400
	Label bottom "\\Z16k\\Bx\\M\\Z16 ";Label left "\\Z16Binding Energy\\M\\Z16 (\\F'symbol'\\F'arial'eV)"
	print "CVT2EK_pi_renorm ("+oldmat+","+num2str(answ)+","+num2str(fe)+","+num2str(phi)+","+num2str(factor)+")"
End
//********************************************************************************************************************************
Proc Kz_predict(C,v0,Delta_k)
    variable Delta_k
    variable v0=0
    variable C
    prompt Delta_k,"In-plane K (1/A)"
    prompt v0,"Inner potential - phi"// actually inner potential - work function
    prompt C,"Lattice constance of Z"

    make/o/n=800 Kz
    make/o/n=800 hv=p

    Kz=0.51199*sqrt(hv-3.81485*(delta_k)^2+V0)
    Kz=Kz/(pi/C)
    display Kz
    ModifyGraph grid(bottom)=1
    ModifyGraph grid(left)=1
    ModifyGraph lsize=1.5
    ModifyGraph rgb=(0,0,65280)
    ModifyGraph standoff=0
    showinfo
    print "Kz_predict("+num2str(C)+","+num2str(v0)+","+num2str(Delta_k)+")"
End
//********************************************************************************************************************************
Proc calculate_v0(kz15_minus_kzV0,Energy_Reference,Delta_k)
   variable kz15_minus_kzV0
   variable Energy_Reference
   variable Delta_k=0
    prompt kz15_minus_kzV0,"Kz(15meV,ER)-Kz(exp,ER)"
    prompt Energy_Reference,"Reference Energy to compare Kz"
    prompt Delta_k,"inplane K deviation from G"
    variable v0
    v0=((0.51199*sqrt(Energy_Reference-150.769*(Delta_k)^2+15)-kz15_minus_kzV0)/0.51199)^2-Energy_Reference+150.769*(Delta_k)^2
    print v0
End
//********************************************************************************************************************************
Proc kly_Kzmap(initial_energy,E_delta,Efi,Eff,phii,phif,map_numcuts,initial_index)
	Variable initial_energy
	Variable E_delta=2
	Variable initial_index=1
	Variable map_numcuts=0
	Variable Eff
	Variable Efi
	Variable phii
	Variable phif
	Prompt initial_energy,"Energy of mapping begining"
	Prompt E_delta,"Energy delta"
	Prompt initial_index,"index of data begining"
	Prompt map_numcuts,"number of energy cuts"
	Prompt Eff, "Ef of end data"
	Prompt Efi, "Ef of initial data"
	Prompt phif, "angel deviation of end data"
	Prompt phii, "angel deviation of initial data"

	PauseUpdate
	Silent 1

	make_table_hv_kz()
      map_numcuts =dimsize(file_name,0)-1
	Redimension/N=(map_numcuts) photonE4kz,photonE4kz,EFvals4kz,theta4kz,phi4kz,hvcuts4kz;
      photonE4kz=initial_energy+E_delta*p;
      hvcuts4kz="data"+num2str(initial_index+p);
      efvals4kz=Efi+(Eff-Efi)*p/(map_numcuts-1);
      phi4kz=-(phii+(phif-Phii)*p/(map_numcuts-1))

	CVT2K_vs_hv()

	Duplicate/O mat_khv mat3d

		if(Wintype("mat3d_fs_ploter")==0)
		Execute "initmat3d()"
		Execute "mat3d_fs_ploter()"
		Execute "initmat3d()"
		Else
			Dowindow/F mat3d_fs_ploter
	Endif
End
//********************************************************************************************************************************
Proc MBE1MLTime(Flux,SM,cM,NM,NT,ST,cT)//valid only self-confined growth mode and  with enough subordinate elemet
	variable Flux
	variable SM=2.83*2.83//default as Fe BCC Lattice
	variable cM=2.83//default as Fe BCC Lattice
	variable NM=2//default as Fe BCC Lattice
	variable NT=2//default as FeSe(129)
	variable ST=3.766*3.766//default as FeSe(129)
	variable cT=5.499//default as FeSe(129)
       Prompt Flux,"MainElement Flux(A/s)"
	Prompt SM,"MainElement inplaneArea1UC(A2)"
	Prompt cM,"MainElement Vertical-Length 1UC(A)"
	Prompt NM,"Main Element atom Number1UC"
	Prompt NT,"Targetstruc atom Number1UC"
	Prompt ST,"Targetstruc inplaneArea1UC(A2)"
	Prompt cT,"Targetstruc  Vertical-Length(A)"
	PauseUpdate
	Silent 1

       variable T
	variable thick
       variable Fluxnumber// Flux of main element present as atom number
	Fluxnumber=NM*Flux/(SM*cM)
	T=(NT/ST)/Fluxnumber
	thick= CT/T

	print "MBE grow 1 monolayer need"
	print T
	print "s"
	print "MBE growth rate is"
	print  thick
	print "A/s"
	print "Main Element atom number flux is"
	print   Fluxnumber
	print "number/s"

End
//-----------------------
proc makedata(thiswave)
	variable i
	string thiswave
	string iamawave
	variable isize, jsize,lsize
	string savename
	//movewave :DA_infowaves:$thiswave, :
	//setdatafolder :

	i=0
	isize=dimsize($thiswave, 0)
	jsize=dimsize($thiswave,1)
	lsize=dimsize($thiswave,2)
	do
		iamawave="data"+num2str(i+1)
		duplicate/o/R=[0,isize-1][0,jsize-1][i,i] $thiswave $iamawave
		Redimension/N=(-1,-1) $iamawave
	if (i<=8)
		savename="data"+"000"+num2str(i+1)+".txt"
	else
    	if(i>8 && i<=98)
    		savename="data"+"00"+num2str(i+1)+".txt"
    	else
       		if(i>98 && i<998)
       			savename="data"+"0"+num2str(i+1)+".txt"
       		else
       			savename="data"+num2str(i+1)+".txt"
			endif
		endif
	endif

	Save/G/W/P=home d$iamawave as savename

	killwaves $iamawave
	i+=1
	while(i<lsize)

end
//---------------------------
Proc LoadDataFromA1_KLY()

	Variable  Loadn=ItemsInList(IndexedFile(home,-1,".txt"))
	print IndexedFile(home,-1,".txt")
	Variable  DataNum
	String  savedDataFolder=getDataFolder(1)
	String 	Filename, FolderName
	String kstring
	Variable condition
	Variable n,m
	Variable index
	Variable firstnumfirst,firstnumlast,secondnumfirst,secondnumlast,i
	String objName
	if(wintype("Information_table")==0)
		DataNum=0
	endif
	if(winType("Information_table")==2)
		DataNum=Dimsize(File_Name,0)
	endif
		m=loadn-DataNum+1
		InSertPoints DataNum, m,File_Name
	string mat
	n=DataNum
	Do
		Filename=IndexedFile(home,n-1,".txt")
		print FileName
		File_Name[n]=FileName
		LoadWave /Q/J/L={0,0,1,0,0} /K=2  /O /N=tempStr /P=home Filename
		LoadWave /Q/G/L={0,1,0,1,0} /O /M/N=tempMat /P=home FileName
		LoadWave /Q/G/L={0,1,0,0,1} /O /N=XWave /P=home FileName
		mat="data"+num2str(n)
		Make/O/N=(dimsize(tempMat0,1),dimsize(tempMat0,0)) $mat
		$mat[][]=tempMat0[q][p]
		Setscale/P y,XWave0[0],XWave0[1]-XWave0[0],""$mat
		Center_detector($mat)//,0)
		n+=1
	While(n<=Loadn)
	setDataFolder $savedDataFolder
End
//--------------------------------------------------------
proc rescaleload(wavenames)
	variable i
	String wavenames
	string thiswave
	i=1
	do
		thiswave="Data"+num2str(i)

		setscale/P x,dimoffset($wavenames, 1),dimdelta($wavenames,1),""$thiswave
		setscale/P y,dimoffset($wavenames, 0),dimdelta($wavenames,0),""$thiswave
		i+=1
	while(i<dimsize(file_name,0))

end
//---------------------------------------------------------
proc loadDA30_kly(thiswave, data,mode)
	//execute makedata(thiswave)
	//execute "setDataFolder Root:"
	//Execute "Makegraphtable()"
	//execute "LoadDataFromA1()"
	//Execute "Initialize_Global_Variables()"
	string thiswave="chunkcube"
	prompt thiswave, "enter the name of 3DWave"
	string data="data"
	prompt data, "enter the dataname"
	variable mode
	Prompt mode,"Which kinds of 3D data?",popup "Deflector mapping; Manipulator mapping"
	variable i
	string iamawave
	variable isize, jsize,lsize
	string savename
	variable k
	string thiswavehaha
	if(mode==1)
		MoveWave :DA_infowaves:$thiswave, :
		setdatafolder :
	Endif
	if(mode==2)
		loadData/o/P=home
	Endif
	i=0
	isize=dimsize($thiswave, 0)
	jsize=dimsize($thiswave,1)
	lsize=dimsize($thiswave,2)
	do
		iamawave="data"+num2str(i+1)
		duplicate/o/R=(dimoffset($thiswave,0),(dimoffset($thiswave,0)+dimdelta($thiswave,0)*(dimsize($thiswave,0)-1)))(dimoffset($thiswave,1),(dimoffset($thiswave,1)+dimdelta($thiswave,1)*(dimsize($thiswave,1)-1)))[i,i] $thiswave $iamawave
		Redimension/N=(-1,-1) $iamawave
		if (i<=8)
			savename=data+"000"+num2str(i+1)+".txt"
		else
    		if(i>8 && i<=98)
    			savename=data+"00"+num2str(i+1)+".txt"
    		else
        		if(i>98 && i<998)
       				savename=data+"0"+num2str(i+1)+".txt"
       			else
       				savename=data+num2str(i+1)+".txt"
				endif
			endif
		endif

		Save/G/W/P=home d$iamawave as savename

		killwaves $iamawave
		i+=1
	while(i<lsize)
	execute "setDataFolder Root:"
	Execute "Makegraphtable()"
	execute "LoadDataFromA1_KLY()"
	Execute "Initialize_Global_Variables()"
	k=1
	do
		thiswavehaha="Data"+num2str(k)
		setscale/P x,dimoffset($thiswave, 1),dimdelta($thiswave,1),""$thiswavehaha
		setscale/P y,dimoffset($thiswave, 0),dimdelta($thiswave,0),""$thiswavehaha
		k+=1
	while(k<dimsize(file_name,0))

	Execute "dataploter()"
End
//------------------------------------
Function LHGap(hv)

	variable hv

	print -3689.43*EXP(-hv/33124.147)-41.59643*EXP(-hv/11.42736)-37.23405*EXP(-hv/61.46118)+3743.333

end
//------------------------------------
//to solve zero data points problem of DA30 high angle data

function ZeroTonum()//all data, search which points equal to 0 ,and then let them equal to the average value of corresponding MDC
	WAVE n
	string mat
	variable i
	variable j,sumn
	variable isize,jsize
	variable k
	k=1
	do
		mat="data"+num2str(k)
		Wave n=$mat
		wave p=file_name
		jsize=dimsize(n, 0)
		isize=dimsize(n,1)

		j=0
		do
			duplicate/O/R=[0,jsize-1][j,j] n thismdc
			sumn=sum(thismdc)/(2*jsize)
			if(sumn==0)
 			else
 				i=0
 				do
 					if (n[i][j]<1000)
 						n[i][j]=sumn
					endif
					i+=1
				while(i<jsize)
 			endif
			 j+=1
 		while(j<isize)
 		k+=1
	while(k<dimsize(p,0))
end
/////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_duplicatekly(ctrlName) : ButtonControl
	String ctrlName
	Execute "duplicatekly()"
	end

proc duplicatekly (mat,matd)
	string mat="imageforslicer"
	string matd=""
	prompt mat,"which one"
	prompt matd,"save as"

	duplicate/o $mat $matd
	display
	appendimage $matd
	SetAxis bottom -2.02836,0.7382051
	SetAxis left -0.5154803,0.1102821
	SetDrawEnv dash= 1
	SetDrawEnv xcoord= bottom,ycoord= left
	DrawLine -2.02836,0,0.7382051,0
	ModifyImage $matd ctab= {*,*,grays,1}
	modifygraph width=350, height=400
	Label bottom "\\Z16k\\Bx\\M\\Z16(1/Å) ";Label left "\\Z16Binding Energy\\M\\Z16 (\\F'symbol'\\F'arial'eV)"

end
//////////////////////////////////////////////
Function ButtonProc_bkremover(ctrlName) : ButtonControl
	String ctrlName
	Execute "bkremoverp()"
end
proc bkremoverp (thisdata,usewave)
	string thisdata=""
	string usewave=""
	prompt thisdata,"which one to handle"
	prompt usewave,"name of norm wave. Every EDC of Data will be substracte by Normwave."//Please choose wave from same data"
	bkremover(thisdata, usewave)
end


Function bkremover(thisdata, usewave)
	string thisdata
	string usewave
	prompt thisdata,"which one"
	prompt usewave,"norm wave"

	variable xsize, ysize
	variable i,j
	wave N=$thisdata
	wave M=$usewave
	ysize=dimsize(N,1)
	xsize=dimsize(N,0)
	i=0
	do
		j=0
		do
			N[i][j]-=M[j]
			j+=1
		while(j<ysize-1)
	i+=1
	while(i<xsize-1)
end


proc calibrationFS(cutnumber)

string thiswave
variable cutnumber
Variable amount
Variable old_0,delta_old
variable i
Execute "get_fermi_profile2()"

make/N=cutnumber/O calibration//data number
calibration=fermi_profile[0]-fermi_profile//choose first cut as fixed Fermi level.
i=1

do
thiswave="data"+num2str(i)
amount=calibration[i-1]
old_0=dimoffset($thiswave,1)
delta_old=dimdelta($thiswave,1)
setscale/p y (old_0+amount), delta_old, "", $thiswave
i+=1
while(i< cutnumber+1)//data number +1

Execute "kly_mapping()"

	String ctrlName
	Execute "ini_mat3dslicer()"
	Execute "openmat3dslicer()"
	Execute "Set_Hline_slice_control()"
	Execute "Set_Vline_slice_control()"
	Execute "Set_numcombslicer()"
	If(Wintype("Graph_imageforslicer")==0)
		Execute "Graph_imageforslicer()"
		Else
			Dowindow/F Graph_imageforslicer
	Endif
End


///////////////////////////////////////////////////////////////////////////////////////////////////////////
//     convert a CEM to I(kx,kz).
//
//
//////////////////////////////////////////////////////////////////////////////////////////////////
Proc CVT2K_vs_kz_2D(matname,BEmat,Vzero,kzgridfactor,LatticeC)
	//Variable slitorientation
	string matname=""
	variable BEmat
	Variable Vzero
	Variable kzgridfactor=3
	variable LatticeC
	//variable latticeC
      //Prompt slitorientation,"Slit orientation",popup "V;H"
	Prompt matname, "name of CEM to convert"
	Prompt BEmat, "Binding Energy of CEM"
	Prompt Vzero,"Enter V0"
	Prompt kzgridfactor,"How many times more points"
	Prompt LatticeC, "Enter Lattice Periodity along Kz"
	//Prompt lattieC, "Enter Lattice constance along Kz(A)"
	PauseUpdate;Silent 1
	String thisname
	Variable i
	Variable kzgridsize
	Variable firstkz,lastkz
	kzgridsize=Round(kzgridfactor*dimsize($matname,1))
	//Find the equivalent kz's for mat_khv
	Duplicate/O $matname mat_kkz1
	Make/O/N=(dimsize($matname,1)) lowestwave
	Make/O/N=(dimsize($matname,1)) highestwave
	lowestwave[]=NaN
	highestwave[]=NaN
	func_CVT2K_vs_kz_boundaries_2D($matname,mat_kkz1,EFvals4kz,lowestwave,highestwave,Vzero,BEmat)
	//Defining matrix with k-kz
	Wavestats/Q lowestwave
	firstkz=V_min
	Wavestats/Q highestwave
	lastkz=V_max
	Killwaves lowestwave,highestwave
	Make/O/N=(dimsize($matname,0),kzgridsize) mat_kz2D
	Setscale/P x,dimoffset($matname,0),dimdelta($matname,0),""mat_kz2D
	Setscale/I y, firstkz, lastkz,""mat_kz2D

	mat_kz2D[][]=NaN
	func_CVT2K_vs_kz_interp_2D($matname,mat_kz2D,mat_kkz1)

       Setscale/P y,dimoffset(mat_kz2D,1)/(pi/LatticeC),dimdelta(mat_kz2D,1)/(pi/LatticeC),""mat_kz2D
	display; appendimage mat_kz2D
	Label left "\\Z22\\F'times'k\\Bz\\M\\Z22\\F'times' (\\F'symbol'π\\F'times'/c)"
       Label bottom "\\Z22\\F'times'k\\Bx\\Z22 (Å\\S-1\\M\\F'times'\\Z22)"
       ModifyGraph grid(left)=1
//	killwaves mat_kkz1
End
///////////////////////////////////////////////////////////////////////////////
Function func_CVT2K_vs_kz_boundaries_2D(matkhv,matkkz1,EFwave,lowestwave,highestwave,Vzero,BEmat)
	Wave matkhv
	Wave matkkz1
	Wave EFwave
	Wave lowestwave
	Wave highestwave
	Variable Vzero
	variable BEmat
	PauseUpdate;Silent 1
	Variable i
	//Find the equivalent kz's for mat_khv and finding kz boundaries
	i=0
	Do
		matkkz1[][i]=0.51231*sqrt(BEmat+EFwave[i]+Vzero-((dimoffset(matkhv,0)+p*dimdelta(matkhv,0))/0.51231)^2)
		Make/O/N=(dimsize(matkhv,0)) thiscutkz
		Make/O/N=(dimsize(matkhv,0)) thiscut1NAN
		thiscut1NAN[]=matkhv[p][i]
		func_mat2d_1orNaN_2d(thiscut1NAN)
		thiscutkz[]=matkkz1[p][i]*thiscut1NAN[p]
		Wavestats/Q thiscutkz
		lowestwave[i]=V_min
		highestwave[i]=V_max
		i+=1
	While(i<dimsize(matkhv,1))
	killwaves	thiscutkz,thiscut1NAN
End
//*******************************************************************************************************************************
Function func_mat2d_1orNaN_2d(matname)
	Wave matname
	PauseUpdate;Silent 1
	Variable i,j
	i=0
	Do

			IF(mod(round(matname[i]),1)!=0)
				matname[i]=NaN
				Else
					matname[i]=1
			Endif

		i+=1
	While(i<dimsize(matname,0))
End

///////////////////
Function func_CVT2K_vs_kz_interp_2D(matkhv,matkkz,matkkz1)
	Wave matkhv
	Wave matkkz
	Wave matkkz1
	PauseUpdate;Silent 1
	Variable j
	Variable firstindex,lastindex
	Print "Begin interpolation"
	Make/O/N=(dimsize(matkhv,1)) thisIntensitywave
	Make/O/N=(dimsize(matkhv,1)) thiskzwave
	thisIntensitywave[]=NaN
	thiskzwave[]=NaN

		j=0 //loop on k
		Do
			thisIntensitywave[]=matkhv[j][p]
			thiskzwave[]=matkkz1[j][p]
			firstindex=Ceil((thiskzwave[0]-dimoffset(matkkz,1))/dimdelta(matkkz,1))
			lastindex=Ceil((thiskzwave[dimsize(thiskzwave,0)-1]-dimoffset(matkkz,1))/dimdelta(matkkz,1))
			matkkz[j][firstindex,lastindex]=interp(dimoffset(matkkz,1)+q*dimdelta(matkkz,1),thiskzwave,thisIntensitywave)
			j+=1
		While(j<dimsize(matkhv,0))

	killwaves	thisIntensitywave,thiskzwave
End

proc makeEDC_KLY()
	variable m
	variable n
	variable i
	m=dimsize(data1,1)
	n=dimsize(data1,0)
	i=0
	display
	do
		duplicate/O/R=[i,i][0,m] data1 $"EDC_K"+num2str(i)
		appendtograph $"EDC_K"+num2str(i)
		i+=1
	while(i<=n)
end


//****************************************************
//Please use this procedure after finished "map hv""-->mat3d"
//
//****************************************************
Function ButtonProc_Kz_predict2(ctrlName) : ButtonControl
	String ctrlName
	Execute " Kz_predict2()"
End

Function ButtonProc_CEM2DToKZ(ctrlName) : ButtonControl
	String ctrlName
	// Main-panel shortcut for converting the current CEM slice into kx-kz space.
	Execute "Kz_predict2()"
End
//****************************************************
Proc Kz_predict2()
	variable/G hvs
	variable/G V0=8.4
	variable/G c=6.4915
	variable/G endx
	variable/G a=3.4
	variable/G Ener=0
	//variable/G BE
	make/o/n=1000  Econst
	make/o/n=1000 Kx
	display Econst vs kx
	//variable/G step
	makeCEM()
	CVT2K_vs_kz_2D_2()
	appendimage  mat_kz2D
	modifygraph width=400, height=400
	ShowTools/A arrow
	ControlBar 60
	SetVariable setvar0 title="Ek (eV)",size={100,20},value=hvs,proc=SetVarProc_KZ_changehv
	SetVariable setvar1 title="V0 (eV)",size={120,20},value=V0,proc=SetVarProc_KZ_changeV0
	SetVariable setvar2 title="kxrange (A)",size={120,20},value=endx, proc=SetVarProc_KZ_changeendx
	SetVariable setvar3 title="c (A)",size={90,20},value=c, proc=SetVarProc_KZ_changeC
	SetVariable setvar4 title="a (A)",size={90,20},value=a, proc=SetVarProc_KZ_changea
	//SetVariable setvar5 title="step",size={90,20},value=step, proc=SetVarProc_step
	SetVariable setvar5 title="Binding Energy (meV)",size={200,20},value=Ener, proc=SetVarProc_Ener

	//Button button0 title="update",proc=ButtonProc_Kzpredictupdate
	SetAxis left 3,15
	SetAxis bottom -5,5
	ModifyGraph grid(left)=1
	ModifyGraph grid(bottom)=1
	ModifyGraph grid=1,nticks(left)=20
	ModifyGraph grid=1,nticks(bottom)=20
	Label bottom "\\Z13k\\Bx\\M \\Z13(\\F'symbol'π\\F'arial'/a)"
	Label left "\\Z13k\\BZ\\M \\Z13(\\F'symbol'π\\F'arial'/c)"
	SetVariable setvar3 limits={-inf,inf,0.1}
	SetVariable setvar2 limits={-inf,inf,0.1}
	SetVariable setvar1 limits={-inf,inf,0.1}
	SetVariable setvar4 limits={-inf,inf,0.1}
	SetVariable setvar5 limits={dimoffset(mat_khv,1)*1000,(dimoffset(mat_khv,1)+dimdelta(mat_khv,1)*(dimsize(mat_khv,1)-1)*1000),10}

	HideTools/A
	SetAxis/A
	ModifyGraph nticks(left)=5
	ModifyGraph nticks(bottom)=5
end
//****************************************************
//Function ButtonProc_Kzpredictupdate(ctrlName) : ButtonControl
	//String ctrlName
	//Wave Kzcons, kzx
	//NVAR hv, V0, c, startx,endx
	//Kzcons=0.51199*sqrt(hv-3.81485*(x)^2+V0)
	//kzx=startx+(endx-startx)*x/999
//End

 //****************************************************
Function SetVarProc_Ener(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	//NVAR hvs
	//hvs=varNum
	Execute "makeCEM()"
      Execute "CVT2K_vs_kz_2D_2()"

End
 //****************************************************
Function SetVarProc_KZ_changehv(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	//NVAR hvs
	//hvs=varNum
	Execute "adjustkz()"
End
//****************************************************
Function SetVarProc_KZ_changev0(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	//NVAR V0
	//V0=varNum
	Execute "adjustkz()"
	Execute "CVT2K_vs_kz_2D_2()"

End
//****************************************************
Function SetVarProc_KZ_changeC(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	//NVAR C
	//C=varNum
	Execute "adjustkz()"
	 Execute "CVT2K_vs_kz_2D_2()"

End
//****************************************************
Function SetVarProc_KZ_changea(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	//NVAR a
	//C=varNum
	Execute "adjustkz()"
       Execute "CVT2K_vs_kz_2D_2()"

End
//****************************************************
Function SetVarProc_KZ_changestartx(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	NVAR startx
	//startx=varNum
	Execute "adjustkz()"
End
//****************************************************
Function SetVarProc_KZ_changeendx(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	//NVAR endx
	//endx=varNum
	Execute "adjustkz()"
End
//****************************************************

Proc CVT2K_vs_kz_2D_2()
	//Variable slitorientation
	//string matname="mat3d_energy_plot"
	string matname
	variable BEmat
	Variable kzgridfactor=3
	//variable step
	//variable latticeC
      //Prompt slitorientation,"Slit orientation",popup "V;H"
	//Prompt matname, "name of CEM to convert"
	//Prompt BEmat, "Binding Energy of CEM"
	//Prompt Vzero,"Enter V0"
	//Prompt kzgridfactor,"How many times more points"
	//Prompt LatticeC, "Enter Lattice Periodity along Kz"
	//Prompt lattieC, "Enter Lattice constance along Kz(A)"
	PauseUpdate;Silent 1
	String thisname
	Variable i
	Variable kzgridsize
	Variable firstkz,lastkz
	matname="CEM"
	BEmat=Ener/1000
	//step=round(BE/1000-dimoffset(mat_khv,1))/dimdelta(mat_khv,1)

	//BEmat= dimoffset(mat_Khv,1)+step*dimdelta(mat_khv,1)
	   //   print  "Binding energy is"+num2str(BEmat*1000)+ "meV"

	kzgridsize=Round(kzgridfactor*dimsize($matname,1))
	//Find the equivalent kz's for mat_khv
	Duplicate/O $matname mat_kkz1
	Make/O/N=(dimsize($matname,1)) lowestwave
	Make/O/N=(dimsize($matname,1)) highestwave
	lowestwave[]=NaN
	highestwave[]=NaN
	func_CVT2K_vs_kz_boundaries_2D($matname,mat_kkz1,EFvals4kz,lowestwave,highestwave,V0,BEmat)
	//Defining matrix with k-kz
	Wavestats/Q lowestwave
	firstkz=V_min
	Wavestats/Q highestwave
	lastkz=V_max
	Killwaves lowestwave,highestwave
	Make/O/N=(dimsize($matname,0),kzgridsize) mat_kz2D
	Setscale/P x,dimoffset($matname,0),dimdelta($matname,0),""mat_kz2D
	Setscale/I y, firstkz, lastkz,""mat_kz2D

	mat_kz2D[][]=NaN
	func_CVT2K_vs_kz_interp_2D($matname,mat_kz2D,mat_kkz1)

       Setscale/P y,dimoffset(mat_kz2D,1)/(pi/c),dimdelta(mat_kz2D,1)/(pi/c),""mat_kz2D
       Setscale/P x,dimoffset(mat_kz2D,0)/(pi/a),dimdelta(mat_kz2D,0)/(pi/a),""mat_kz2D

	//display; appendimage mat_kz2D
	//Label left "\\Z22\\F'times'k\\Bz\\M\\Z22\\F'times' (\\F'symbol'π\\F'times'/c)"
       //Label bottom "\\Z22\\F'times'k\\Bx\\Z22 (Å\\S-1\\M\\F'times'\\Z22)"
       //ModifyGraph grid(left)=1
//	killwaves mat_kkz1
End
//****************************************************
Proc  adjustkz()
	kx=-endx+(2*endx)*p/999
	Econst=0.51231*sqrt(hvs-3.81008*(kx)^2+V0)
	Econst=Econst/(pi/C)
	kx=kx/(pi/a)
End
////////////////////////
proc makeCEM()
	variable step
	step=ceil((((Ener/1000)-dimoffset(mat_khv,1))/dimdelta(mat_khv,1)))
	make/o/N=(dimsize(mat_khv,0),dimsize(mat_khv,2)) CEM
	make/o/N=(dimsize(mat_khv,0),dimsize(mat_khv,2)) CEM1
	make/o/N=(dimsize(mat_khv,0),dimsize(mat_khv,2)) CEM2
	make/o/N=(dimsize(mat_khv,0),dimsize(mat_khv,2)) CEM3
	make/o/N=(dimsize(mat_khv,0),dimsize(mat_khv,2)) CEM4
	make/o/N=(dimsize(mat_khv,0),dimsize(mat_khv,2)) CEM5
	CEM1[][]=mat_khv[p][step-2][q]
	CEM2[][]=mat_khv[p][step-1][q]
	CEM3[][]=mat_khv[p][step][q]
	CEM4[][]=mat_khv[p][step+1][q]
	CEM5[][]=mat_khv[p][step+2][q]

	CEM=(CEM1+CEM2+cem3+cem4+cem5)/5
	killwaves, cem1,cem2,cem3,cem4,cem5

	Setscale/P x,dimoffset(mat_khv,0),dimdelta(mat_khv,0),""CEM
	Setscale/P y,dimoffset(mat_khv,1),dimdelta(mat_khv,1),""CEM
end

///////////////////////////////////
//Convert 2D data to 1D data, the order is, first fix p, run q; then p+1, run q
//////////////////////////////////
Function ButtonProc_p2dtopeak_proc(ctrlName) : ButtonControl
	String ctrlName
	Execute "p2dtopeak_proc()"
end

Proc p2dtopeak_proc(name)
	string name
	prompt name, "Name of the 2D wave, Now convert it to 1D "
	p2dtopeak(name)
end

Function p2dtopeak(name)
	string name
	wave n=$name
	variable xxx
	xxx=dimsize(n,0)*dimsize(n,1)
	make/o/N=(xxx) oneDtopo
	variable i,j,k
	variable a,b
	i=0
	k=0
	do
		j=0
		do
			oneDtopo[k]=n[i][j]
			j+=1
			k+=1
		while(j<dimsize(n,1))
		i+=1
	while(i<dimsize(n,0))
	edit oneDtopo
end




Function ButtonProc_tdtodc(ctrlName) : ButtonControl
	String ctrlName
	Execute "tdtodc()"
end

Proc tdtodc(name)
	string name
	prompt name, "Name of the 2D wave, Now convert it to 1D "
	tdtod($name)
end

Function tdtod(waven)
	wave waven
	string nw = "OneD_"+nameofWave(waven)
	duplicate/o waven $nw
	wave nww = $nw
	Redimension/N=(dimsize(waven,0)*dimsize(waven,1)) nww
	edit nww
end

////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_deletepoint(ctrlName) : ButtonControl
	String ctrlName
	Execute "DeletePdata()"
end
////////////////////////////////////////////////////////////////////////////////////////
//procedure deletepdata is writen to change the scale of data, if it is too big to handel in Igor, or you want to
//make specific dislay of the data. their are two Mode, First one is cutRange Mode, only Begining From startpoint range
//or Finished at endpoint range can be used. the second mode is hald slice mode, it can retain slice envery one slices.
//
//   stp==-1 means endpoints
//   select==0 means all of the data were selected.
////////////////////////////////////////////////////////////////////////////////////////
proc DeletePdata(name,flag,select,stp,edp,number2)
	string name="data"// batch name
	variable select// choose which data to deal with, if==0 means all
	variable flag //delete k demision(raw)=0 delete E demision(colum) =1
	variable stP, edP// delete from point(stp) to point(edP)
	variable  number2// number of cuts
	Prompt name,"Batch name"
	Prompt select,"which Data to handel(0 means handling all)"
	Prompt flag,"Please Select Mode",popup "cut K range;cut E range; halfslice K; halfslice E"//halfslice means delete slice by every one slice
	Prompt stp,"From points (Only for cutrange Mode)"
	Prompt edp,"To points (Only for cutrange Mode)"
	Prompt number2,"number of cuts (Only for handling all)"
	variable ff
	ff=flag-1
	if (ff==0)
		DPdata(name,select,ff,stp,edp,number2)
	endif
	if(ff==1)
		DPdata(name,select,ff,stp,edp,number2)
	endif
	if(ff==2)
		cuthalfall(name,ff,select,number2)
	endif
	if(ff==3)
 		cuthalfall(name,ff,select,number2)
	endif
	print "DeletePdata("+name+","+num2str(flag)+","+num2str(select)+","+num2str(stp)+","+num2str(edp)+","+num2str(number2)+")"
end
//////////////////////////////////////////////////////////////////////////////////////////
Function DPdata(name,select,flag,stp,edp,numbercut)//testing finished
	string name
	variable select// choose which data to deal with, if==0 means all
	variable flag //delete k demision(raw)=0 delete E demision(colum) =1
	variable stP, edP// delete from point(stp) to point(edP)
	variable numbercut // number of cuts
	String matname,dest
	variable j
	variable xstart,xend, ystart,yend
	variable times
	variable x1, x2, x3,x4, y1, y2, y3, y4

	if (select==0)
		j=0
		times=numbercut
	else
		j=select-1
		times=0
	endif


	do
		matname= name+num2str(j+1)
		dest="databig"+num2str(j+1)
		duplicate/o $matname $dest
		wave N=$matname
		//xstart=dimoffset(N,0)+dimdelta(N,0)*(stP)
		//xend=dimoffset(N,0)+dimdelta(N,0)*(edP)
		//ystart=dimoffset(N,1)+dimdelta(N,1)*(stP)
		//yend=dimoffset(N,1)+dimdelta(N,1)*(edP)
		//x1=(xend+dimdelta(N,0))
		x1=dimoffset(N,0)+(edp-stp)*dimdelta(N,0)
		x2=(dimoffset(N,0)+dimdelta(N,0)*(dimsize(N,0)-1))
		x3=dimoffset(N,0)
		//x4=(xstart-dimdelta(N,0))
		x4=x3+stp*dimdelta(N,0)
		//y1=(yend+dimdelta(N,1))
		y1=dimoffset(N,1)+(edp-stp)*dimdelta(N,1)
		y2=(dimoffset(N,1)+dimdelta(N,1)*(dimsize(N,1)-1))
		y3=dimoffset(N,1)
		//y4=(ystart-dimdelta(N,1))
		y4=y3+stp*dimdelta(N,1)

		if (edp==-1)
   			if(flag==0)
    			edp= dimsize(N,0)-1
    		endif
    		if(flag==1)
    			edp=dimsize(N,1)-1
    		endif
		endif

		if (flag==0)
  			if (stp==0)
  				DeletePoints/M=(flag) stp,(edp-stp), N

    			SetScale/I x x1,x2,"", N
   			else
   				DeletePoints/M=(flag) stp+1,(edp-stp), N

     			SetScale/I x x3,x4,"", N
    		endif
		endif

		if(flag==1)
			if (stp==0)
 				DeletePoints/M=(flag) stp,(edp-stp), N
   				SetScale/I y y1,y2,"", N
   			else
      			DeletePoints/M=(flag) stp+1,(edp-stp), N
     			SetScale/I y y3, y4,"", N
    		endif
		endif

		j+=1
	while(j<times)//end number of data
end
/////////////////////////////////
Function cuthalfall(name,flag,select,number2)//testing finished
	string name
	variable flag //half k (raw)=2 half E (colum) =3
	variable select// choose which data to deal with, if==0 means all
	variable  number2// number of cuts
	String matname,dest
	variable i,j
	variable xstart,xend, ystart,yend
	variable times
	variable slicenumber

	if (select==0)
		j=0
		times=number2
	else
		j=select-1
		times=0
	endif

	do
		matname= name+num2str(j+1)
		dest="databig"+num2str(j+1)
		duplicate/o $matname $dest
		wave N=$matname
		xstart=dimoffset(N,0)
		xend=xstart+dimdelta(N,0)*(dimsize(N,0)-1)
		ystart=dimoffset(N,1)
		yend=ystart+dimdelta(N,1)*(dimsize(N,1)-1)
		slicenumber= dimsize(N,(flag-2))

		i=0
		do
			DeletePoints/M=(flag-2) i,1, N
			i+=1
		while(i<(round(slicenumber/2)))// half of number of slices
		SetScale/I x xstart,xend,"", N
		SetScale/I y ystart,yend,"", N
		j+=1
	while(j<times)//end number of data
end

/////////////////////////
Function ButtonProc_Normdivide(ctrlName) : ButtonControl
	String ctrlName
	Execute "normlizeformap()"
	end
proc normlizeformap(normwave)
	string normwave=""
	Prompt normwave,"Name of NormCurve.Data will be divided by this curve."
	string mat
	variable i
	i=0
	do
		mat="data"+num2str(i+1)
		$mat/=$normwave[i]
		i+=1
	while(i<(dimsize(file_name,0)-1))
end

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_cutksmall(ctrlName) : ButtonControl
	String ctrlName
	Execute "cutksmall()"
	end
proc cutksmall(name,index)
	string name
	variable index
	variable point
	point=pcsr(A)
	DeletePdata(name,1,index,0,point,0)
end

Function ButtonProc_cutklarge(ctrlName) : ButtonControl
	String ctrlName
	Execute "cutklarge()"
	end
proc cutklarge(name,index)
	string name
	variable index
	variable point
	point=pcsr(A)
	DeletePdata(name,1,index,point,-1,0)
end

Function ButtonProc_cutElarge(ctrlName) : ButtonControl
	String ctrlName
	Execute "cutElarge()"
	end
proc cutElarge(name,index)
	string name
	variable index
	variable point
	point=qcsr(A)
	DeletePdata(name,2,index,point,-1,0)
end

Function ButtonProc_cutEsmall(ctrlName) : ButtonControl
	String ctrlName
	Execute "cutEsmall()"
	end
proc cutEsmall(name,index)
	string name
	variable index
	variable point
	point=qcsr(A)
	DeletePdata(name,2,index,0,point,0)
end
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_extending1D(ctrlName) : ButtonControl
	String ctrlName
	Execute "extending1D()"
	end
proc extending1D(name,point)
	string name
	variable point
	prompt name,"The curve you want ro extending"
	prompt point,"How many point you want to add (each side)"
	string named
	variable delta
	delta=dimdelta($name,0)
	named="large"+name
	make/o/N=(dimsize($name,0)+2*point) $named

	setscale/P x, dimoffset($name,0)-point*delta,delta,"",$named
	$named=1

	variable i
	i=0
	do
		$named[i+point]=$name[i]
		i+=1
	while(i<dimsize($name,0))
	display $named
end


Function ButtonProc_AuFitkly(ctrlName) : ButtonControl//"Convert All Data"
	String ctrlName
	Execute "AuFitkly ()"
End

Proc AuFitkly (Tem,j,choice)
	variable Tem=8.3
	variable j=0
	variable choice
	Prompt Tem,"Temperature(K)"
	Prompt j,"Number of data(J=0 means output All )"
	prompt choice,"Do you want to fix FP",	popup "yes;No"
	String thisdata
	string destwave
	string destwavedif
	String WindowName="DOS"
	String traces_on_graph,old_data
	Variable i
	string fit_info,width_info
	variable startx,starty,endx,endy
	variable EFtest
	Variable smooth1=5
	Variable smooth2=5
	Variable method=3
	Variable putongraph=1
	variable Pprofile
 	String thiscut_deriv
	Variable k
	variable fitfermiprofilelowrange,fitfermiprofilehighrange
	Variable newmin,newmax,newsize
	variable res
	variable EFfit
	string coe1,coe2,coe3,coe4
	variable condition
	string appendix
	string outputres,outputef1,outputef2


	If(wintype("dataploter")==0)
		Execute "dataploter()"
	Else
		DoWindow/F dataploter
	Endif
	//----------------------------------------show data plotor
	if(j==0)
		condition=dimsize(file_name,0)
	else
		condition=1
	endif

	if(choice==2)
		appendix="_Raw"
	else
	endif
	if(choice==1)
		appendix="_Fixed"
	else
	endif

	outputres="Resolution"+appendix
	outputef2="Ef_fit_2nd"+appendix
	outputef1="Ef_dif_1st"+appendix
	make/O/N=(dimsize(file_name,0)+1), $outputres
	make/O/N=(dimsize(file_name,0)+1), $outputef2
	make/O/N=(dimsize(file_name,0)+1), $outputef1
	edit $outputef1,$outputef2,$outputres

 	j=1
	do
 		thisdata="data"+num2str(j)
		//DoWindow  $WindowName
		//if( V_Flag== 0 )
			//Display as WindowName
			//DoWindow /C $(WindowName)
		//else
			//DoWindow  /F $(WindowName)
		//endif
		//traces_on_graph=TraceNamelist("DOS",";",1)
		//old_data=StringFromList(0,traces_on_graph)
		//if(WaveExists($old_data)==1)
			//removefromgraph $old_data
		//Endif
		//Showinfo

		destwave="density_of_states_data"+num2str(j)+appendix
		Make/O/N=(dimsize($thisdata,1)) $destwave
		Setscale/P x,dimoffset($thisdata,1),dimdelta($thisdata,1),""$destwave
		$destwave[]=0
		i=0
		Do
			$destwave[]+=$thisdata[i][p]
			i+=1
		While(i<dimsize($thisdata,0))
		$destwave[]/=dimsize($thisdata,0)
		//Appendtograph density_of_states
		//DoWindow  /F dataploter
		if(choice==2)
			display $destwave
		else
		endif
		//-------------------------------------------------make DOS wave

        destwavedif="density_of_states_dif"+num2str(j)
        Differentiate $destwave/D=$destwavedif
        CurveFit/M=2/W=0 gauss, $destwavedif/D
        Eftest=W_coef[2]

        Pprofile =round((EFtest-dimoffset($destwave,0))/(dimdelta($destwave,0)))
		//-------------------------------------------------find EF

		if(choice==1)
		////////////////////////////////////////////////////////////////////////////////////////////////////////////
			fitfermiprofilelowrange=Pprofile-round(0.03/(dimdelta($destwave,0)))
			fitfermiprofilehighrange=Pprofile+round(0.03/(dimdelta($destwave,0)))
			Make/O/N=(dimsize($thisdata,0)) fermi_profile
			Make/O/N=(dimsize($thisdata,0)) fermi_profile_x
			Setscale/P x,dimoffset($thisdata,0),dimdelta($thisdata,0),""fermi_profile
			Make/O/N=(dimsize($thisdata,1)) thiswave
			Setscale/P x,dimoffset($thisdata,1),dimdelta($thisdata,1),""thiswave
			fermi_profile_x[]=dimoffset($thisdata,0)+p*dimdelta($thisdata,0)
			thiscut_deriv=thisdata+"_1D"
			Duplicate/O $thisdata $thiscut_deriv
			i=0
			Do
				Make/O/N=(dimsize($thisdata,1)) thiswave
				Setscale/P x,dimoffset($thisdata,1),dimdelta($thisdata,1),""thiswave
				thiswave[]=$thisdata[k][p]
				Smooth/E=3/B=(smooth1) smooth2,thiswave
				Differentiate thiswave
				//		Smooth/E=3/B=(smooth1) smooth2,thiswave
				$thiscut_deriv[k][]=thiswave[q]
				IF(method==1)
					Wavestats/Q/R=[(fitfermiprofilelowrange),(fitfermiprofilehighrange)] thiswave
					fermi_profile[k]=V_minloc
				Endif
				IF(method==2)
					Smooth/E=3/B=(smooth1) smooth2,thiswave
					CurveFit/Q/NTHR=0/TBOX=0 lor  thiswave[(fitfermiprofilelowrange),(fitfermiprofilehighrange)] /D
					fermi_profile[k]=W_coef[2]
				Endif
				IF(method==3)
					Smooth/E=3/B=(smooth1) smooth2,thiswave
					CurveFit/Q/NTHR=0/TBOX=0 gauss  thiswave[fitfermiprofilelowrange,fitfermiprofilehighrange] /D
					fermi_profile[k]=W_coef[2]
				Endif
				k+=1
			While(k<dimsize($thiscut_deriv,0))
			If(putongraph==1)
				Appendtograph fermi_profile vs fermi_profile_x
			Endif
			Killwaves thiswave,$thiscut_deriv

	CurveFit/M=2/W=0 poly 10,  fermi_profile/D
	interpolate2/n=(dimsize($thisdata,0)) /t=1 fit_fermi_profile
//=================================================find fermi profile and interpolate it to right number of points.

	Wavestats/Q fit_fermi_profile
	newmin=Dimoffset($thisdata,1)-(EFtest-V_min)
	newmax=Dimoffset($thisdata,1)+Dimdelta($thisdata,1)*(Dimsize($thisdata,1)-1)-(V_max-EFtest)
	Newsize=1+Ceil((Newmax-newmin)/Dimdelta($thisdata,1))
	Make/O/N=(dimsize($thisdata,0),newsize) thenewmat
	thenewmat[][]=NaN
	Setscale/P x,dimoffset($thisdata,0),dimdelta($thisdata,0),""thenewmat
	Setscale/P y,newmin,dimdelta($thisdata,1),""thenewmat
	func_adjust_to_fp($thisdata,thenewmat,fit_fermi_profile,EFtest)
	Duplicate/O thenewmat $thisdata
	killwaves thenewmat

//===============================================fix fermi level.

       Make/O/N=(dimsize($thisdata,1)) $destwave
	Setscale/P x,dimoffset($thisdata,1),dimdelta($thisdata,1),""$destwave
	$destwave[]=0
	i=0
	Do
		$destwave[]+=$thisdata[i][p]
		i+=1
	While(i<dimsize($thisdata,0))
	$destwave[]/=dimsize($thisdata,0)
if(choice==1)
display $destwave
else
endif
//===============================================remake dos after fix fermi level
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
   else
   Pprofile=0
   endif

       startx=EFtest-0.08
	starty=$destwave(startx)
	endx=EFtest+0.08
	endy=$destwave(endx)

	Make/o/N=6/D/O Wfit			//the fit coeffecient wave.
	Wfit[0]=(startx+endx)/2		//fermi level.
	Wfit[1]=Tem					//fit temperature.
//	Wfit[2]=starty					//the Y value of the below Ef line when x=0
//	Wfit[3]=-abs((endy-starty)/(endx-startx))	//the slope of the below Ef line.
//	Wfit[4]=endy					//the Y value of the above Ef line when x=0
//	Wfit[5]=Wfit[3]				//the slope of the above Ef line.

	//just find Wfit
   //    wave W_coef
	CurveFit/Q line, $destwave(endx,endx+0.02)/D
//	CurveFit/Q line, dos(17.10,17.12)/D
	Wfit[4]=W_coef[0]
	Wfit[5]=W_coef[1]

	CurveFit/Q line, $destwave(startx-0.02,startx)/D
//	CurveFit/Q line, dos(16.065,17.08)/D
	Wfit[2]=W_coef[0]-Wfit[4]
	Wfit[3]=W_coef[1]-Wfit[5]

//	duplicate/o dos t_dos
//	differentiate t_dos
//	wavestats/q t_dos
//	wfit[0]=v_minloc
//	killwaves t_dos

	FuncFit/Q line_fermi Wfit $destwave(startx, endx) /D
	FuncFit/Q line_fermi Wfit $destwave(startx, endx) /D			//fitting two times has its advantage.


//	fit_info="E\BF\M="+num2str(floor(wfit[0]))+"."+stringfromlist(1,num2str(wfit[0]-floor(wfit[0])),".")+" eV\rT\BExp\M="+num2str(Tem)+" K\rT\BFit\M="+num2str(Wfit[1])+" K"
//	TextBox/C/N=fit_info  fit_info+"\r\r"+ "\F'Symbol'D\F'Arial'E\Btot\M="+num2str(.318*sqrt(Wfit[1]*Wfit[1]))+" meV" +"\r"+"\F'Symbol'D\F'Arial'E\Bins\M="+num2str(.318*sqrt(Wfit[1]*Wfit[1]-Tem*Tem))+" meV"

//print fit_info+"\r\r"+ "\F'Symbol'D\F'Arial'E\Btot\M="+num2str(.318*sqrt(Wfit[1]*Wfit[1]))+" meV" +"\r"+"\F'Symbol'D\F'Arial'E\Bins\M="+num2str(.318*sqrt(Wfit[1]*Wfit[1]-Tem*Tem))+" meV"
//print "The resolution at temperature T is defined as: the FWHM of the Gauss fitting of the derivative of fermi function."
	//wave tmp_ef_res
	res=.318*sqrt(Wfit[1]*Wfit[1]-Tem*Tem)
	EFfit=Wfit[0]


	$outputres[j]=res
	$outputef2[j]=EFfit
	$outputef1[j]=EFtest




	sprintf coe1,"%3.3f\r", res
	sprintf coe2,"%3.3f\r", EFtest
	sprintf coe3,"%3.3f\r", effit
	sprintf coe4,"%3.3f\r", j
	TextBox/C/N=text0/X=35.00/Y=30.00/A=MC "res(meV)"+Coe1+"Ef-dif(eV)"+coe2+"Ef-fit(eV)"+coe3+"Data:"+coe4

	//display  $destwave
	j+=1
	while(j<condition)
end


function line_fermi(Wfit,x)//function used to fit. Both below and above Ef are used lines, not constant.

	wave Wfit
	variable x

	return (Wfit[2]+Wfit[3]*x)/(exp((x-Wfit[0])/(1.38e-23*Wfit[1]/1.6e-19))+1)+Wfit[4]+Wfit[5]*x

end






////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////



proc Auall2 (Tem,j)
variable Tem
variable j
String thisdata
string destwave
string destwavedif
String WindowName="DOS"
String traces_on_graph,old_data
Variable i
string fit_info,width_info
variable startx,starty,endx,endy
variable EFtest
Variable smooth1=10
Variable smooth2=10
Variable method=3
Variable putongraph=1
 variable Pprofile
 String thiscut_deriv
Variable k
variable fitfermiprofilelowrange,fitfermiprofilehighrange
Variable newmin,newmax,newsize
variable res
variable EFfit
string coe1,coe2,coe3,coe4


If(wintype("dataploter")==0)
		Execute "dataploter()"
		Else
			DoWindow/F dataploter
	Endif
//----------------------------------------show data plotor


make/O/N=(dimsize(file_name,0)+1), Resolution
make/O/N=(dimsize(file_name,0)+1), Ef_fit
make/O/N=(dimsize(file_name,0)+1), Ef_dif
edit resolution,Ef_fit,Ef_dif

 //do
 	thisdata="data"+num2str(j)
	//DoWindow  $WindowName
	//if( V_Flag== 0 )
		//Display as WindowName
		//DoWindow /C $(WindowName)
	//else
		//DoWindow  /F $(WindowName)
	//endif
	//traces_on_graph=TraceNamelist("DOS",";",1)
	//old_data=StringFromList(0,traces_on_graph)
	//if(WaveExists($old_data)==1)
		//removefromgraph $old_data
	//Endif
	//Showinfo
	destwave="density_of_states"+num2str(j)
	Make/O/N=(dimsize($thisdata,1)) $destwave
	Setscale/P x,dimoffset($thisdata,1),dimdelta($thisdata,1),""$destwave
	$destwave[]=0
	i=0
	Do
		$destwave[]+=$thisdata[i][p]
		i+=1
	While(i<dimsize($thisdata,0))
	$destwave[]/=dimsize($thisdata,0)
	//Appendtograph density_of_states
	//DoWindow  /F dataploter
//-------------------------------------------------make DOS wave

            destwavedif="density_of_states_dif"+num2str(j)
             Differentiate $destwave/D=$destwavedif
            CurveFit/M=2/W=0 gauss, $destwavedif/D
              Eftest=W_coef[2]

              Pprofile =round((EFtest-dimoffset($destwave,0))/(dimdelta($destwave,0)))
//-------------------------------------------------find EF

	fitfermiprofilelowrange=Pprofile-round(0.03/(dimdelta($destwave,0)))
	fitfermiprofilehighrange=Pprofile+round(0.03/(dimdelta($destwave,0)))
	Make/O/N=(dimsize($thisdata,0)) fermi_profile
	Make/O/N=(dimsize($thisdata,0)) fermi_profile_x
	Setscale/P x,dimoffset($thisdata,0),dimdelta($thisdata,0),""fermi_profile
	Make/O/N=(dimsize($thisdata,1)) thiswave
	Setscale/P x,dimoffset($thisdata,1),dimdelta($thisdata,1),""thiswave
	fermi_profile_x[]=dimoffset($thisdata,0)+p*dimdelta($thisdata,0)
	thiscut_deriv=thisdata+"_1D"
	Duplicate/O $thisdata $thiscut_deriv
	i=0
	Do
		Make/O/N=(dimsize($thisdata,1)) thiswave
		Setscale/P x,dimoffset($thisdata,1),dimdelta($thisdata,1),""thiswave
		thiswave[]=$thisdata[k][p]
		Smooth/E=3/B=(smooth1) smooth2,thiswave
		Differentiate thiswave
//		Smooth/E=3/B=(smooth1) smooth2,thiswave
		$thiscut_deriv[k][]=thiswave[q]
		IF(method==1)
			Wavestats/Q/R=[(fitfermiprofilelowrange),(fitfermiprofilehighrange)] thiswave
			fermi_profile[k]=V_minloc
		Endif
		IF(method==2)
			Smooth/E=3/B=(smooth1) smooth2,thiswave
			CurveFit/Q/NTHR=0/TBOX=0 lor  thiswave[(fitfermiprofilelowrange),(fitfermiprofilehighrange)] /D
			fermi_profile[k]=W_coef[2]
		Endif
		IF(method==3)
			Smooth/E=3/B=(smooth1) smooth2,thiswave
			CurveFit/Q/NTHR=0/TBOX=0 gauss  thiswave[fitfermiprofilelowrange,fitfermiprofilehighrange] /D
			fermi_profile[k]=W_coef[2]
		Endif
		k+=1
	While(k<dimsize($thiscut_deriv,0))
	If(putongraph==1)
		Appendtograph fermi_profile vs fermi_profile_x
	Endif
	Killwaves thiswave,$thiscut_deriv

	CurveFit/M=2/W=0 poly_XOffset 10,  fermi_profile/D
	interpolate2/n=(dimsize($thisdata,0)) /t=1 fit_fermi_profile
//=================================================find fermi profile and interpolate it to right number of points.

	Wavestats/Q fit_fermi_profile
	newmin=Dimoffset($thisdata,1)-(EFtest-V_min)
	newmax=Dimoffset($thisdata,1)+Dimdelta($thisdata,1)*(Dimsize($thisdata,1)-1)-(V_max-EFtest)
	Newsize=1+Ceil((Newmax-newmin)/Dimdelta($thisdata,1))
	Make/O/N=(dimsize($thisdata,0),newsize) thenewmat
	thenewmat[][]=NaN
	Setscale/P x,dimoffset($thisdata,0),dimdelta($thisdata,0),""thenewmat
	Setscale/P y,newmin,dimdelta($thisdata,1),""thenewmat
	func_adjust_to_fp($thisdata,thenewmat,fit_fermi_profile,EFtest)
	Duplicate/O thenewmat $thisdata
	killwaves thenewmat

//===============================================fix fermi level.

       Make/O/N=(dimsize($thisdata,1)) $destwave
	Setscale/P x,dimoffset($thisdata,1),dimdelta($thisdata,1),""$destwave
	$destwave[]=0
	i=0
	Do
		$destwave[]+=$thisdata[i][p]
		i+=1
	While(i<dimsize($thisdata,0))
	$destwave[]/=dimsize($thisdata,0)

	display $destwave
//===============================================remake dos after fix fermi level


       startx=EFtest-0.08
	starty=$destwave(startx)
	endx=EFtest+0.08
	endy=$destwave(endx)

	Make/o/N=6/D/O Wfit			//the fit coeffecient wave.
	Wfit[0]=(startx+endx)/2		//fermi level.
	Wfit[1]=Tem					//fit temperature.
//	Wfit[2]=starty					//the Y value of the below Ef line when x=0
//	Wfit[3]=-abs((endy-starty)/(endx-startx))	//the slope of the below Ef line.
//	Wfit[4]=endy					//the Y value of the above Ef line when x=0
//	Wfit[5]=Wfit[3]				//the slope of the above Ef line.

	//just find Wfit
   //    wave W_coef
	CurveFit/Q line, $destwave(endx,endx+0.02)/D
//	CurveFit/Q line, dos(17.10,17.12)/D
	Wfit[4]=W_coef[0]
	Wfit[5]=W_coef[1]

	CurveFit/Q line, $destwave(startx-0.02,startx)/D
//	CurveFit/Q line, dos(16.065,17.08)/D
	Wfit[2]=W_coef[0]-Wfit[4]
	Wfit[3]=W_coef[1]-Wfit[5]

//	duplicate/o dos t_dos
//	differentiate t_dos
//	wavestats/q t_dos
//	wfit[0]=v_minloc
//	killwaves t_dos

	FuncFit/Q line_fermi Wfit $destwave(startx, endx) /D
	FuncFit/Q line_fermi Wfit $destwave(startx, endx) /D			//fitting two times has its advantage.


//	fit_info="E\BF\M="+num2str(floor(wfit[0]))+"."+stringfromlist(1,num2str(wfit[0]-floor(wfit[0])),".")+" eV\rT\BExp\M="+num2str(Tem)+" K\rT\BFit\M="+num2str(Wfit[1])+" K"
//	TextBox/C/N=fit_info  fit_info+"\r\r"+ "\F'Symbol'D\F'Arial'E\Btot\M="+num2str(.318*sqrt(Wfit[1]*Wfit[1]))+" meV" +"\r"+"\F'Symbol'D\F'Arial'E\Bins\M="+num2str(.318*sqrt(Wfit[1]*Wfit[1]-Tem*Tem))+" meV"

//print fit_info+"\r\r"+ "\F'Symbol'D\F'Arial'E\Btot\M="+num2str(.318*sqrt(Wfit[1]*Wfit[1]))+" meV" +"\r"+"\F'Symbol'D\F'Arial'E\Bins\M="+num2str(.318*sqrt(Wfit[1]*Wfit[1]-Tem*Tem))+" meV"
//print "The resolution at temperature T is defined as: the FWHM of the Gauss fitting of the derivative of fermi function."
	//wave tmp_ef_res
	res=.318*sqrt(Wfit[1]*Wfit[1]-Tem*Tem)
	EFfit=Wfit[0]

resolution[j]=res
Ef_fit[j]=EFfit
Ef_dif[j]=EFtest
sprintf coe1,"%3.3f\r", res
sprintf coe2,"%3.3f\r", EFtest
sprintf coe3,"%3.3f\r", effit
sprintf coe4,"%3.3f\r", j

TextBox/C/N=text0/A=MC "res:(meV)"+Coe1+"Ef-dif:(eV)"+coe2+"Ef-fit:(eV)"+coe3+"eV  Data:"+coe4


	//display  $destwave
//j+=1
//while(j<dimsize(file_name,0))


end

/////////////////////////////////////////////////////////////
//Selective area sum

Function ID_p(mat,upcurve,downcurve)
	string mat,upcurve,downcurve
	variable i,j,zx,zy,dx,dy,y,miny,maxy,number
	j=66
	wave n=$mat
	wave up=$upcurve
	wave Down=$downcurve

	Zx=dimoffset(n,0)
	Zy=dimoffset(n,1)
	Dx=dimdelta(n,0)
	Dy=dimdelta(n,1)
	duplicate/o n nD
	//nD=nan
	nd=0
	i=623
	number=0
	do
		miny=down[i-623]
		maxy=up[i-623]
      j=68

      do
      		y=Zy+j*Dy
      		if(y>=miny&&y<=maxy)
      			nD[i][j]=n[i][j]
        		number+=1
         	endif

      		j+=1
     	while(j<104)
  		i+=1
	while(i<747)

  	display
  	appendimage nD
  	print "number of points is ";print number
end
//////////////////../////////////////////////////////////
function Areaselect_p(upcurve,downcurve)
	string upcurve,downcurve
	variable i,j,zx,zy,dx,dy,y,miny,maxy,number

	string mat,matd
	variable k
	make/o/N=42 everageintensity
	edit  everageintensity

	k=0
	do
		mat="KzCut"+num2str(20+2*k)+"eV"
		matd="Area"+num2str(20+2*k)+"eV"

		wave n=$mat
		wave up=$upcurve
		wave Down=$downcurve

		Zx=dimoffset(n,0)
		Zy=dimoffset(n,1)
		Dx=dimdelta(n,0)
		Dy=dimdelta(n,1)
		duplicate/o n nD
		nD=0
		i=623
		number=0
		do
			miny=down[i-623]
			maxy=up[i-623]
         j=68

         do
         		y=Zy+j*Dy
         		if(y>=miny&&y<=maxy)
         			nD[i][j]=n[i][j]
          		number+=1
        		endif

         		j+=1
         	while(j<104)
  			i+=1
  		while(i<747)

  		duplicate/o nd $matd
  		display
  		appendimage $matd

 		variable l,m,total
		total=0
 		wave SA=$matd
 		l=0
 		do
 			m=0
 			do
  				total+=SA[l][m]
  				m+=1
  			while(m<dimsize(SA,1))
			l+=1
		while(l<dimsize(SA,0))

  		total/=number
  		everageintensity[k]=total

  		print total



  		K+=1
	while (K<42)
  	//display
  	//appendimage nD
  	//print "number of points is ";print number
end
////////////////////////////////////////
function ID_d(mat,upcurve,downcurve)
	string mat,upcurve,downcurve
	variable i,j,zx,zy,dx,dy,y,miny,maxy,number
	j=66
	wave n=$mat
	wave up=$upcurve
	wave Down=$downcurve

	Zx=dimoffset(n,0)
	Zy=dimoffset(n,1)
	Dx=dimdelta(n,0)
	Dy=dimdelta(n,1)
	duplicate/o n nD
	//nD=nan
	nd=0
	i=523
	number=0
	do
		miny=down[i-523]
		maxy=up[i-523]
      	j=78

      	do
      		y=Zy+j*Dy
       	if(y>=miny&&y<=maxy)
          	nD[i][j]=n[i][j]
          	number+=1
        	endif

        	j+=1
   		while(j<104)
  		i+=1
  	while(i<673)

  	display
  	appendimage nD
  	print "number of points is ";print number
end
//////////////////../////////////////////////////////////
function Areaselect_d(upcurve,downcurve)
	string upcurve,downcurve
	variable i,j,zx,zy,dx,dy,y,miny,maxy,number

	string mat,matd
	variable k
	make/o/N=42 everageintensity_d
	edit  everageintensity_d

	k=0
	do
		mat="KzCut"+num2str(20+2*k)+"eV"
		matd="Area"+num2str(20+2*k)+"eV_d"

		wave n=$mat
		wave up=$upcurve
		wave Down=$downcurve

		Zx=dimoffset(n,0)
		Zy=dimoffset(n,1)
		Dx=dimdelta(n,0)
		Dy=dimdelta(n,1)
		duplicate/o n nD
		nD=0
		i=523
		number=0
		do
			miny=down[i-523]
			maxy=up[i-523]
         j=78

         	do
        		y=Zy+j*Dy
          	if(y>=miny&&y<=maxy)
          		nD[i][j]=n[i][j]
          		number+=1
          	endif

          	j+=1
        	while(j<104)
  			i+=1
 		while(i<672)

  		duplicate/o nd $matd
  		display
  		appendimage $matd

 		variable l,m,total
		total=0
 		wave SA=$matd
 		l=0
 		do
 			m=0
 			do
  				total+=SA[l][m]
  				m+=1
  			while(m<dimsize(SA,1))
			l+=1
		while(l<dimsize(SA,0))

  		total/=number
  		everageintensity_d[k]=total

  		print total



  		K+=1
  while (K<42)
  //display
  //appendimage nD
  //print "number of points is ";print number
end



Function ButtonProc_symbands(ctrlName) : ButtonControl
	String ctrlName
	Execute "symbandsall()"
end

proc symbandsall(s,matname,point,flag)
	variable s
	string matname = tpw()
	variable point
	variable flag
	Prompt s,"Data Type",popup "Real;Complex"
	Prompt matname,"which matrix to symmetry"
	Prompt point,"The point as reference"
	Prompt flag,"Please Select Mode",popup "Reflect to right;Reflect to left"//halfslice means delete slice by every one slice
	if (s==1)
		symbands(matname,point,flag)
	else
	 symbands_cmplx(matname,point,flag)
	endif
end

proc symbands(matname,point,flag)
	string matname
	variable point
	variable flag
	Prompt matname,"which matrix to symmetry"
	Prompt point,"The point as reference"
	Prompt flag,"Please Select Mode",popup "Reflect to right;Reflect to left"//halfslice means delete slice by every one slice

	string destname
	duplicate/o $matname data1000
	destname="sym_"+matname
	if (flag==1)
		DeletePdata("data",1,1000,point,-1,0)
		make/o/n=((2*(dimsize(data1000,0)-1)+1),dimsize(data1000,1)) $destname
		symkrtr($destname,data1000)
 	else
 		DeletePdata("data",1,1000,0,point,0)
		make/o/n=((2*(dimsize(data1000,0)-1)+1),dimsize(data1000,1)) $destname
		symkrtl($destname,data1000)
	endif
		display;appendimage $destname
		killwaves data1000
end

function symkrtr(n,temp)
	wave n
	wave temp

	variable i,j
	j=0
	do
		i=0
		do
			if  (i<(dimsize(temp,0)-1))
				n[i][j]=temp[i][j]
			else
				n[i][j]=temp[((dimsize(temp,0)-1)-(i-dimsize(temp,0)+1))][j]
			endif
			i+=1
		while(i<dimsize(n,0))
		j+=1
	while (j<dimsize(n,1))
	setscale/p x, (dimoffset(temp,0)-(dimoffset(temp,0)+(dimsize(temp,0)-1)*dimdelta(temp,0))),dimdelta(temp,0),"",n
	setscale/p y, dimoffset(temp,1),dimdelta(temp,1),"",n

	//display; appendimage n
end

function symkrtl(n,temp)
	wave n
	wave temp

	variable i,j
	j=0
	do
		i=0
		do
			if  (i<(dimsize(temp,0)-1))
				n[i][j]=temp[(dimsize(temp,0)-1-i)][j]
			else
				n[i][j]=temp[i-dimsize(temp,0)][j]
			endif
			i+=1
		while(i<dimsize(n,0))
		j+=1
	while (j<dimsize(n,1))
	setscale/p x, (dimoffset(temp,0)-(dimoffset(temp,0)+(dimsize(temp,0)-1)*dimdelta(temp,0))),dimdelta(temp,0),"",n
	setscale/p y, dimoffset(temp,1),dimdelta(temp,1),"",n

	//display; appendimage n
end


/////////////////////////////
Function ButtonProc_symbands_cmplx(ctrlName) : ButtonControl
	String ctrlName
	Execute "symbands_cmplx()"
end


proc symbands_cmplx(matname,point,flag)
	string matname
	variable point
	variable flag
	Prompt matname,"which matrix to symmetry"
	Prompt point,"The point as reference"
	Prompt flag,"Please Select Mode",popup "Reflect to right;Reflect to left"//halfslice means delete slice by every one slice

	string destname
	duplicate/o $matname data1000
	destname="sym_"+matname
	if (flag==1)
		DeletePdata("data",1,1000,point,-1,0)
		make/c/o/n=((2*(dimsize(data1000,0)-1)+1),dimsize(data1000,1)) $destname
 		symkrtr_cmplx($destname,data1000)
	else
		DeletePdata("data",1,1000,0,point,0)
		make/c/o/n=((2*(dimsize(data1000,0)-1)+1),dimsize(data1000,1)) $destname
		symkrtl_cmplx($destname,data1000)
	endif
	display;appendimage $destname
	killwaves data1000
end

function symkrtr_cmplx(n,temp)
	wave/c n
	wave temp

	variable i,j
	j=0
	do
		i=0
		do
			if  (i<(dimsize(temp,0)-1))
				//n[i][j]=temp[i][j]
				n[i][j]=cmplx(real(temp[i][j]),imag(temp[i][j]))
			else
				n[i][j]=cmplx(real(temp[((dimsize(temp,0)-1)-(i-dimsize(temp,0)+1))][j]),imag(temp[((dimsize(temp,0)-1)-(i-dimsize(temp,0)+1))][j]))
			endif
			i+=1
		while(i<dimsize(n,0))
		j+=1
	while (j<dimsize(n,1))
	setscale/p x, (dimoffset(temp,0)-(dimoffset(temp,0)+(dimsize(temp,0)-1)*dimdelta(temp,0))),dimdelta(temp,0),"",n
	setscale/p y, dimoffset(temp,1),dimdelta(temp,1),"",n

	//display; appendimage n
end

function symkrtl_cmplx(n,temp)
	wave/c n
	wave temp

	variable i,j
	j=0
	do
		i=0
		do
			if  (i<(dimsize(temp,0)-1))
				n[i][j]=cmplx(real(temp[(dimsize(temp,0)-1-i)][j]),imag(temp[(dimsize(temp,0)-1-i)][j]))
			else
				n[i][j]=cmplx(real(temp[i-dimsize(temp,0)][j]),imag(temp[i-dimsize(temp,0)][j]))
			endif
			i+=1
		while(i<dimsize(n,0))
		j+=1
	while (j<dimsize(n,1))
	setscale/p x, (dimoffset(temp,0)-(dimoffset(temp,0)+(dimsize(temp,0)-1)*dimdelta(temp,0))),dimdelta(temp,0),"",n
	setscale/p y, dimoffset(temp,1),dimdelta(temp,1),"",n

//display; appendimage n
end

//***************************This is a stupid procedure*****
//I replace it by a smarter one
////////////////////////////////////////////////////////////
Function ButtonProc_reflecttrace(ctrlName) : ButtonControl
	String ctrlName
	Execute "reflectionwave()"
end

proc reflectionwave(mat,xvalue)
	string mat
	variable xvalue
	Prompt mat,"which matrix to reflect"
	Prompt xvalue,"x value of reference point"
	Silent 1;
		PauseUpdate


	string matd
	variable refp
	variable i

	variable endx,startx
	variable endp, startp,select

	matd=mat+"_reflect"
	endx=dimoffset($mat,0)+(dimsize($mat,0)-1)*dimdelta($mat,0)
	startx=dimoffset($mat,0)

	make/o/N=(2*dimsize($mat,0))  $matd

	refp=round((xvalue-dimoffset($mat,0))/dimdelta($mat,0))

	endp=round((endx-xvalue)/dimdelta($mat,0))
	startp=((xvalue-startx)/dimdelta($mat,0))
	if (endp>=startp)
		select=endp
	else
		select=startp
	endif
	i=0
	do
		$matd[refp-i]=$mat[refp+i]
		$matd[refp+i]=$mat[refp-i]
		i+=1
	while(i<select+1)
	setscale/P x, (xvalue-(refp-1)*dimdelta($mat,0)),dimdelta($mat,0),"",$matd
	zeronan(matd)

	display $matd
end

////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
Function ButtonProc_Rflwaves(ctrlName) : ButtonControl
	String ctrlName
	Execute " Rflwaves()"
end
//////////////////////////////////////////////////////////////////
Proc Rflwaves(name,a)
	string name = tpw()
	variable a
	Prompt name,"The wave name you want to do reflection"
	Prompt a,"Please Select Mode",popup "1D;2D X; 2D Y; 2D XY"
	if (a == 1)
		Reflecttrace(name)
		Print "This is the 1D trace mode"
	endif
	if (a == 2)
		reflectmatrix_X(name)
		Print "This is the 2D X mode"
	endif
	if (a == 3)
		reflectmatrix_Y(name)
		Print "This is the 2D Y mode"
	endif
	if (a == 4)
		reflectmatrix(name)
		Print "This is the 2D XY mode"
	endif

	Print "Rflwaves(\""+name+"\","+num2str(a)+")"
end

Proc Reflectmatrix_Y(name)
	String name

	string name2
	name2= name+"_RY"
	duplicate/o $name $name2
	$name2[][]=$name[p][dimsize($name,1)-q-1]

	CheckDisplayed $name2
	if (V_flag == 1)
		print "display;appendimage " + name2+";ModifyGraph width={Plan,1,bottom,left}"
	else
		display;appendimage $name2
		ModifyGraph width={Plan,1,bottom,left}
	endif
end


Proc Reflectmatrix_X(name)
	String name

	string name2
	name2= name+"_RX"
	duplicate/o $name $name2
	$name2[][]=$name[dimsize($name,0)-p-1][q]

	CheckDisplayed $name2
	if (V_flag == 1)
		print "display;appendimage " + name2+";ModifyGraph width={Plan,1,bottom,left}"
	else
		display;appendimage $name2
		ModifyGraph width={Plan,1,bottom,left}
	endif
end

Proc Reflectmatrix(name)
	String name

	string name2
	name2= name+"_R"
	duplicate/o $name $name2
	$name2[][]=$name[dimsize($name,0)-p-1][dimsize($name,1)-q-1]

	CheckDisplayed $name2
	if (V_flag == 1)
		print "display;appendimage " + name2+";ModifyGraph width={Plan,1,bottom,left}"
	else
		display;appendimage $name2
		ModifyGraph width={Plan,1,bottom,left}
	endif
end


Proc Reflecttrace(name)
	String name

	string name2
	name2= name+"_tR"
	duplicate/o $name $name2
	$name2[]=$name[dimsize($name,0)-p-1]

	CheckDisplayed $name2
	if (V_flag == 1)
		print "display " + name2
	else
		display $name2
	endif
end

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_length(ctrlName) : ButtonControl
	String ctrlName
	Execute "linel()"
end

proc linel()
	variable maa
	maa=sqrt((hcsr(A)-hcsr(B))^2+(vcsr(A)-vcsr(B))^2)
	print maa
end

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
///////                Padding two dimensional matrix                    ////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
Function ButtonProc_padmc(ctrlName) : ButtonControl
	String ctrlName
	Execute "padmc()"
end
Proc padmc(namew,factor)
	string namew
	variable factor = 2// how many time to enlarge the matrix
	Prompt namew,"wave to pad"
	Prompt factor,"How many time to enlarge dimsize"
	padm($namew,factor)
end

Function padm(namew,factor)
	wave namew
	variable factor// how many time to enlarge the matrix

	String name = nameofwave(namew)
	wave namew = $name
	String namepad = name+"_"+num2str(factor)+"pad"

	variable newdimsizex,newdimsizey,addlr_x,addlr_y,dimoffsetpadx,dimoffsetpady
	addlr_x = round((factor-1)*dimsize(namew,0)/2)
	addlr_y = round((factor-1)*dimsize(namew,1)/2)
	newdimsizex = 2*addlr_x+dimsize(namew,0)
	newdimsizey = 2*addlr_y+dimsize(namew,1)

	//make/N=(newdimsizex,newdimsizex)/o $namepad
	//wave namepadw=$namepad
	//namepadw = 0
	dimoffsetpadx=dimoffset(namew,0)-(addlr_x-1)*dimdelta(namew,0)
	dimoffsetpady=dimoffset(namew,1)-(addlr_y-1)*dimdelta(namew,1)

    duplicate/o namew $namepad
    wave namepadw=$namepad
	variable newstartP,newstartq
	newstartP = addlr_x +dimsize(namew,0)
	newstartQ = addlr_y +dimsize(namew,1)

    InsertPoints 0,addlr_x, namepadw
    InsertPoints newstartP,addlr_x, namepadw
    InsertPoints/M=1  0,addlr_y, namepadw
    InsertPoints/M=1 newstartQ,addlr_y, namepadw
    setscale/p x,dimoffsetpadx,dimdelta(namew,0),"",namepadw
    setscale/p y,dimoffsetpady,dimdelta(namew,1),"",namepadw

    di(namepadw)
end
/////////////////////////////////////////////////////////////////////////////
////////   End Padding  /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
////////   SLicing EDC and MDC  /////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
Function ButtonProc_sMDC(ctrlName) : ButtonControl
	String ctrlName
	Execute "sMDC()"
end

Proc sMDC(mat)
	string mat = tpw()
	slicesMDC($mat)
	color_edc()
end
Function slicesMDC(mat)
	wave mat
	string MDC
	string MDCC = nameofwave(mat)+"_MDC"
	variable i
	i=0
	do
		MDC=nameofwave(mat)+"_MDC"+num2str(i+1)
		make/n=(dimsize(mat,0))/o $MDC
		wave MDCw = $MDC
		setscale/p x,dimoffset(mat,0),dimdelta(mat,0),"",MDCw
		MDCw[]=mat[p][i]
		i+=1
	while(i<dimsize(mat,1))
	display
	displaymultiF(MDCC,1,dimsize(mat,1))
	ckfig(winname(0,1))
	wavestats/Q mat
	Constantoffset_nF(3*V_max/dimsize(mat,1),1)
	modifygraph width=300,height=500
	//ModifyGraph width=0,height=0
end

Function ButtonProc_sEDC(ctrlName) : ButtonControl
	String ctrlName
	Execute "sEDC()"
end

Proc sEDC(mat)
	string mat = tpw()
	slicesEDC($mat)
	color_edc()
end
Function slicesEDC(mat)
	wave mat
	string EDC
	string EDCC = nameofwave(mat)+"_EDC"
	variable i
	i=0
	do
		EDC=nameofwave(mat)+"_EDC"+num2str(i+1)
		make/n=(dimsize(mat,1))/o $EDC
		wave EDCw = $EDC
		setscale/p x,dimoffset(mat,1),dimdelta(mat,1),"",EDCw
		EDCw[]=mat[i][p]
		i+=1
	while(i<dimsize(mat,0))
	display
	displaymultiFedc(EDCC,1,dimsize(mat,0))
	ckfig(winname(0,1))
	wavestats/Q mat
	Constantoffset_nF(3*V_max/dimsize(mat,0),1)
	modifygraph width=300,height=500
	//ModifyGraph width=0,height=0
end
Function  displaymultiFedc(dataname,from,to)
	string dataname
	variable from
	variable to
	STRING  datan,datam
	variable i
	i=1
	do
		datan=dataname+num2str(i)
		WAVE datanw=$datan
		if (i<from)
		else
		appendtograph/VERT datanw
		endif
		i+=1
	while(i<(to+1))
end


Function ButtonProc_RDF(ctrlName) : ButtonControl
	String ctrlName
	Execute "RDF()"
end
Proc RDF(name,OP,OQ)
	string name = tpw()
	Variable OP = pcsr(A)
	variable OQ = qcsr(A)
	getpolaraveRcurve($name,OP,OQ)
end

Function getpolaraveRcurve(name,OP,OQ)
	wave name
	Variable OP
	variable OQ

	variable pp
	pp=dimsize(name,0)-op
	string ZoutI = "Polarave_"+nameofwave(name)
	string RDF = "RDF_"+nameofwave(name)
	make/N=(pp)/o $RDF
	wave RDFw = $RDF
	setscale/p x,0,dimdelta(name,0),"",RDFw

	variable i
	i=OP
	do
		Lineprofilefromcircle2(name,OP,OQ,i)
		wave ZoutIw = $ZoutI
		RDFw[i-op]=mean(ZoutIw)
		i+=1
	while(i<dimsize(name,0))
	killwaves ZoutIw
	wavestats/Q RDFw
	RDFw/=V_max
	display RDFw
	ckfig(winname(0,1))
end

Function Lineprofilefromcircle2(name,OP,OQ,RP)
	wave name
	Variable OP
	variable OQ
	variable RP

	variable RQ = OQ

	variable Ox = OP//pcsr(B)
	variable Oy = OQ//qcsr(B)

	//**Define the radium
	variable ax = RP//pcsr(A)
	variable ay = RQ//qcsr(A)

	variable rr = round(sqrt((ox-ax)^2+(oy-ay)^2))

	//**Define the circular trace
	variable xx, yy
		//(xx-ox)^2+(yy-oy)^2 = rr^2
		//yy = +-sqrt(rr^2 - (xx-ox)^2)+oy

	//**Define the  leftP (polar pi) and rightP (Polar 0)
	variable leftP,rightP
	leftP = round(ox - rr)
	rightP = round(ox +rr)

	variable/G pinorm_2dplot

	//**Create Z wave
	string ZoutI = "Polarave_"+nameofwave(name)
	variable num = abs(rightP-leftP)+1+(abs(rightP-leftP)+1-1)
	make/N=(num)/o $ZoutI
	wave ZoutIw =$ZoutI
	setscale/I x 0,2*pi,"",ZoutIw
	ZoutIw=nan

	//**Create Indicative X&Y wave
	string xwaveout = "Xout_"+nameofwave(name)
	string ywaveout = "Yout_"+nameofwave(name)
	make/N=(num)/O $ywaveout
	make/N=(num)/O $Xwaveout
	wave xwaveoutw = $xwaveout
	wave ywaveoutw = $ywaveout

	//**Build Z wave and X&Ywave [Upper half circle (counter-clockwise)]
	wave tpww = $nameofwave(name)
	variable i, qq,j
	i=rightp
	j=0
	do
		xx = i
		yy = sqrt(rr^2 - (xx-ox)^2)+oy
		qq = round(yy)
		if (qq >=0 && qq <dimsize(tpww,1))
			if(i>=0 && i <dimsize(tpww,0))
				ZoutIw[j] = tpww[i][qq]
			else
			endif
		else
			//ZoutIw[j] = nan
		endif
		xwaveoutw[j] = dimoffset(tpww,0)+xx*dimdelta(tpww,0)
		ywaveoutw[j] = dimoffset(tpww,1)+qq*dimdelta(tpww,1)
		j+=1
		i-=1
	while (i > leftp-1)

	//**[Continuing] Build Z wave and X&Ywave [Lower half circle (counter-clockwise)]
	j=0
	i=leftp+1
	do
		xx = i
		yy = -sqrt(rr^2 - (xx-ox)^2)+oy
		qq = round(yy)
		if (qq >=0 && qq <dimsize(tpww,1))
			if(i>=0 && i <dimsize(tpww,0))
				ZoutIw[abs(rightP-leftP)+1+j] = tpww[i][qq]
			else
			endif
		else
			//ZoutIw[abs(rightP-leftP)+1+j] = nan
		endif
		xwaveoutw[abs(rightP-leftP)+1+j] = dimoffset(tpww,0)+xx*dimdelta(tpww,0)
		ywaveoutw[abs(rightP-leftP)+1+j] = dimoffset(tpww,1)+qq*dimdelta(tpww,1)
		j+=1
		i+=1
	while (i < rightp+1)
	ZoutIw[dimsize(ZoutIw,0)-1] = ZoutIw[0]

	//** jump remover or not
	//variable/G removejump_2dp
	//variable/G removejumpmode_2dp
	//variable/G removejumpvalue_2dp
	//variable/G givenjumpcriteria_2dp

	//if (removejump_2dp == 2)
	//	autoremovejump1D(ZoutIw,removejumpmode_2dp,removejumpvalue_2dp,givenjumpcriteria_2dp)
	//endif

	//**Append Indicative X&Ywaves
	//checkDisplayed ywaveoutw
	//if(V_flag == 0)
	//	appendtograph ywaveoutw vs Xwaveoutw
	//	ModifyGraph/W=$winname(0,1) lsize($ywaveout)=1,rgb($ywaveout)=(3690,43690,43690),mode($ywaveout)=4	,lstyle($ywaveout)=7, mrkThick($ywaveout)=2,useMrkStrokeRGB($ywaveout)=1,mrkStrokeRGB($ywaveout)=(1,52428,26586),msize($ywaveout)=1
	//else
	//endif

	//**Append Zwaves
	//if(cmpstr(grabwinnonew(ZoutI),"") == 0)
	//	display ZoutIw
	//	ModifyGraph/W=$winname(0,1) lsize($ZoutI)=1,rgb($ZoutI)=(3690,43690,43690),mode($ZoutI)=4,lstyle($ZoutI)=7, mrkThick($ZoutI)=2,useMrkStrokeRGB($ZoutI)=1,mrkStrokeRGB($ZoutI)=(1,52428,26586)
		//Dowindow/F $winname(1,1)
		//tilewindows/WINS=WinList("*", ";","WIN:1")/R/A=(1,2)/w=(3,0,58,20)
	//else
	//endif

	//if(cmpstr(grabwinnonew(ZoutI),"") == 1)
	//	if(pinorm_2dplot == 1)
	//		Label/W=$grabwinnonew(ZoutI) left "\\Z16 θ (π)"
	//	endif
	//	if(pinorm_2dplot == 0)
	//		Label/W=$grabwinnonew(ZoutI) left ""
	//	endif
	//endif

	//**Do Polar plot the r = sin(2*tpw()[])
	//variable/G polar_L_2dplot
	//if (polar_L_2dplot == 2)
	//	Dopolarfig_nondis(ZoutI,"_calculated_",2)
	//endif

	//** pi-norm
	//if(pinorm_2dplot == 1)
	//	ZoutIw/=pi
	//	wavestats/Q ZoutIw
	//	ZoutIw-=V_min
	//endif

	//** Error message, no stop but Continuing execution
	String msg
	Variable err
	msg=GetErrMessage(GetRTError(0),3);
	err=GetRTError(1)
	if (err != 0)
		//Print "Error in Demo: " + msg
		//Print "Continuing execution"
	endif
end

Function ButtonProc_renameEDCMDC(ctrlName) : ButtonControl
	String ctrlName
	Execute " renameEDCMDC()"
	end
proc renameEDCMDC(num,name)
	variable num=16
	string name = "M100_"
	string name1,name2
	variable i
	i=0
	do
		name1=name+num2str(i)
		name2=name+"R"+num2str(i+1)
		duplicate/o $name1 $name2
		i+=1
	while(i<num)
	string namm
	namm=name+"R"
	displaymulti(namm,1,num)
end


Function ButtonProc_mulQPIr(ctrlName) : ButtonControl
	String ctrlName
	Execute " hahar()"
end
proc hahar(name,number,lattice,angle,point,dis)
	string name="data"
	variable number=dimsize(file_name,0)-1
	variable lattice=3.8
	variable angle=0
	variable point=801//odd number
	variable dis=0.1
	prompt name,"Batch Name"
	prompt number,"Data number"
	prompt lattice,"Lattice constance (A)"
	prompt angle,"angle of lattice to x+"
	prompt point,"Points of Interp FIlter"
	prompt dis,"size of display +- A-1"
	variable i
	i=1
	do
		allqpihahar(name,i,lattice,angle,point,dis)
		i+=1
	while(i<number+1)
	layoutqpir(number)
	layoutdatar(number)
	layoutc4r(number,dis)
end
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
// This Procedure {allqpi2()} is Multiple filtered QPI data.                                                                                                           //
// 1. A symmetric FFT was made by procedure FFTpro2()                                                                                                             //
// 2. The next we do Interp Filter on Modula of FFT.
// 3. We do C4 symmetrization on Dxy-ed data.  C4symFFT2()    // At the end, a Gauss depression Filter was applied.             //
// 4. We do Dxy symmetrization on FFT data. D2symetric2()                                                                                                        //
// 5. We do GAUSS FILTER for two times                                                                                                                                          //
//                                                                                                 //
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_allqpir(ctrlName) : ButtonControl
	String ctrlName
	Execute " allqpihahar()"
end
////////////////////////////////////////////////////////////////////////////////////////////////////////
proc allqpihahar(name,number,lattice,angle,point,dis)
	string name="data"
	variable number
	variable lattice=3.8
	variable angle=0
	variable point=801//odd number
	variable dis=0.1
	prompt name,"Batch Name"
	prompt number,"Data number"
	prompt lattice,"Lattice constance (A)"
	prompt angle,"angle of lattice to x+"
	prompt point,"Points of Interp FIlter"
	prompt dis,"size of display +- A-1"
 	allqpippr(name,number,lattice,angle,point)
 	allqpi2r(name,number,lattice,angle,point,dis)
end

////////////////////////////////////////////////////////////////////////////////////////////////////////
proc allqpi2r(name,number,lattice,angle,point,dis)
	string name="data"
	variable number
	variable lattice=3.8
	variable angle=0
	variable point=801//odd number
	variable dis=0.1
	prompt name,"Batch Name"
	prompt number,"Data number"
	prompt lattice,"Lattice constance (A)"
	prompt angle,"angle of lattice to x+"
	prompt point,"Points of Interp FIlter"
	prompt dis,"size of display +- A-1"


	string nameall,namefftsym,namefftsymd2,namefftsymd22,namec4,final,nammm,namefftsymrot
	variable centralnum
	nameall=name+num2str(number)
	namefftsym="datafftsym"+num2str(number)
	//namefftsymd2=namefftsym+"modulaD2"
	//namec4="fft4foldsym"+num2str(number)
	namefftsymd2="fft4foldsym"+num2str(number)
	namefftsymrot="rot"+num2str(angle)+"_"+namefftsymd2
	namec4="mD2"+namefftsymrot
	final="inter_"+namec4

	centralnum= (dimsize($namefftsym,0)-1)/2
	//namefftsymd22=namefftsymd2+"2"
	//FFTpro2(name,1,number,lattice,angle,1)
	//C4symFFT2(namefftsym,number,angle)
	//D2symetric2(namefftsymd2,centralnum,centralnum)
	//D2symetric2(namefftsymd2,centralnum,centralnum)
	//
	FFTpro2r(name,1,number,lattice,angle,1)
	C4symFFT2r(namefftsym,number,angle)

	nammm="fft"+namefftsym
	display;appendimage $nammm
	SetAxis left -dis,dis;DelayUpdate
	SetAxis bottom -dis,dis
	modifygraph width=200,height=200
	modifygraph width=0,height=0
	ModifyGraph width={Plan,1,bottom,left}
	Label left "\\Z12\\F'times'k\\B\\Z12y\\M\\Z12  (Å\\S-1\\M\\F'times'\\Z12)"
	Label bottom "\\Z12\\F'times'k\\B\\Z12x\\M\\Z12  (Å\\S-1\\M\\F'times'\\Z12)"
	ModifyImage $nammm ctab= {*,*,Grays,0}
	//D2symetric2(namefftsymd2,centralnum,centralnum)

	rot2d_pim(namefftsymd2,angle,0,0,1)

	D2symetric2r(namefftsymrot,centralnum,centralnum)
	Nan0(namec4)
	matrixfilter gauss $namec4
	matrixfilter gauss $namec4


	display;appendimage $namec4
	SetAxis left -dis,dis;DelayUpdate
	SetAxis bottom -dis,dis
	modifygraph width=200,height=200
	modifygraph width=0,height=0
	ModifyGraph width={Plan,1,bottom,left}
	Label left "\\Z12\\F'times'k\\B\\Z12y\\M\\Z12  (Å\\S-1\\M\\F'times'\\Z12)"
	Label bottom "\\Z12\\F'times'k\\B\\Z12x\\M\\Z12  (Å\\S-1\\M\\F'times'\\Z12)"
	ModifyImage $namec4 ctab= {*,*,ColdWarm,0}
	twoDinterpolate2r(namec4,point,point)
	//C4symFFT(namefftsymd22,number,0)
	SetAxis left -dis,dis;DelayUpdate
	SetAxis bottom -dis,dis
	modifygraph width=200,height=200
	modifygraph width=0,height=0
	ModifyGraph width={Plan,1,bottom,left}
	Label left "\\Z12\\F'times'k\\B\\Z12y\\M\\Z12  (Å\\S-1\\M\\F'times'\\Z12)"
	Label bottom "\\Z12\\F'times'k\\B\\Z12x\\M\\Z12  (Å\\S-1\\M\\F'times'\\Z12)"
	ModifyImage $final ctab= {*,*,ColdWarm,0}
end
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////
////////////////////////////////
proc allqpippr(name,number,lattice,angle,point)
	string name="data"
	variable number
	variable lattice=3.8
	variable angle=0
	variable point=801//odd number
	prompt name,"Batch Name"
	prompt number,"Data number"
	prompt lattice,"Lattice constance (A)"
	prompt angle,"angle of lattice to x+"
	prompt point,"Points of Interp FIlter"

	string nameall,namefftsym,namefftsymd2,namefftsymd22,namec4,final,namefftsymrot
	variable centralnum
	nameall=name+num2str(number)
	namefftsym="datafftsym"+num2str(number)
	//namefftsymd2=namefftsym+"modulaD2"
	//namec4="fft4foldsym"+num2str(number)
	namefftsymd2="fft4foldsym"+num2str(number)
	namefftsymrot="rot"+num2str(angle)+"_"+namefftsymd2
	namec4="mD2"+namefftsymrot
	final="inter_"+namec4

	centralnum= (dimsize($namefftsym,0)-1)/2
	//namefftsymd22=namefftsymd2+"2"
	//FFTpro2(name,1,number,lattice,angle,1)
	//C4symFFT2(namefftsym,number,angle)
	//D2symetric2(namefftsymd2,centralnum,centralnum)
	//D2symetric2(namefftsymd2,centralnum,centralnum)
	//
	FFTpro2r(name,1,number,lattice,angle,1)
	C4symFFT2r(namefftsym,number,angle)
	rot2d_pim(namefftsymd2,angle,0,0,1)

	//D2symetric2(namefftsymd2,centralnum,centralnum)
	D2symetric2r(namefftsymrot,centralnum,centralnum)
	//matrixfilter gauss $namec4
	//matrixfilter gauss $namec4
	//display;appendimage $namec4
	//SetAxis left -0.1,0.1;DelayUpdate
	//SetAxis bottom -0.1,0.1
	//modifygraph width=200,height=200
	//modifygraph width=0,height=0
	//ModifyGraph width={Plan,1,bottom,left}
	//Label left "\\Z12\\F'times'k\\B\\Z12y\\M\\Z12  (Å\\S-1\\M\\F'times'\\Z12)"
	//Label bottom "\\Z12\\F'times'k\\B\\Z12x\\M\\Z12  (Å\\S-1\\M\\F'times'\\Z12)"
	//ModifyImage $namec4 ctab= {*,*,ColdWarm,0}
	//twoDinterpolate2(namec4,point,point)
	//C4symFFT(namefftsymd22,number,0)
	//SetAxis left -0.1,0.1;DelayUpdate
	//SetAxis bottom -0.1,0.1
	//modifygraph width=200,height=200
	//modifygraph width=0,height=0
	//ModifyGraph width={Plan,1,bottom,left}
	//Label left "\\Z12\\F'times'k\\B\\Z12y\\M\\Z12  (Å\\S-1\\M\\F'times'\\Z12)"
	//Label bottom "\\Z12\\F'times'k\\B\\Z12x\\M\\Z12  (Å\\S-1\\M\\F'times'\\Z12)"
	//ModifyImage $final ctab= {*,*,ColdWarm,0}
end
///////////////////////////////////////////////////////////////////
proc layoutqpir(number)
	variable number
	variable i,j
	make/T/N=(number)/o textfft
	make/T/N=(number)/o textsym
	make/T/N=(number)/o textsyminter
	i=0
	j=0
	do
		textsyminter[number-1-i]=winname(j,1)
		textsym[number-1-i]=winname(j+1,1)
		textfft[number-1-i]=winname(j+2,1)
		i+=1
		j+=3
	while(i<number)
	//edit   textfft textsym textsyminter
	variable i1,i2,i3
	NewLayout/N=fft
	//s1=textfft[
	i1=0
	do
		AppendLayoutObject graph $textfft[i1]
		i1+=1
	while(i1<number)
	Tile
	NewLayout/N=sym
	//s1=textfft[
	i2=0
	do
		AppendLayoutObject graph $textsym[i2]
		i2+=1
	while(i2<number)
	Tile
	NewLayout/N=syminter
	//s1=textfft[
	i3=0
	do
		AppendLayoutObject graph $textsyminter[i3]
	i3+=1
	while(i3<number)
	Tile
end
////////////////////////////////////////////////////////////////////////////////////////////////////////
proc layoutdatar(number)
	variable number
	variable i,j,k
	string name
	i=1
	do
		name="data"+num2str(i)
		display;appendimage $name
		//SetAxis left -0.1,0.1;DelayUpdate
		//SetAxis bottom -0.1,0.1
		modifygraph width=200,height=200
		modifygraph width=0,height=0
		ModifyGraph width={Plan,1,bottom,left}
		Label left "\\Z12\\F'times'y  (Å\\S-1\\M\\F'times'\\Z12)"
		Label bottom "\\Z12\\F'times'x  (Å\\S-1\\M\\F'times'\\Z12)"
		ModifyImage $name ctab= {*,*,Grays,0}
		i+=1
	while(i<number+1)

	make/T/N=(number)/o qpimap
	j=0
	do
		qpimap[number-1-j]=winname(j,1)
		j+=1
	while(j<number)

	NewLayout/N=Map

	k=0
	do
		AppendLayoutObject graph $qpimap[k]
		k+=1
	while(k<number)
end
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
proc layoutc4r(number,dis)
	variable number
	variable dis
	variable i,j,k
	string name
	i=1
	do
		name="fft4foldsym"+num2str(i)
		display;appendimage $name
		SetAxis left -dis,dis;DelayUpdate
		SetAxis bottom -dis,dis
		modifygraph width=200,height=200
		modifygraph width=0,height=0
		ModifyGraph width={Plan,1,bottom,left}
		Label left "\\Z12\\F'times'y  (Å\\S-1\\M\\F'times'\\Z12)"
		Label bottom "\\Z12\\F'times'x  (Å\\S-1\\M\\F'times'\\Z12)"
		ModifyImage $name ctab= {*,*,Grays,0}
		i+=1
	while(i<number+1)

	make/T/N=(number)/o c4map
	j=0
	do
		c4map[number-1-j]=winname(j,1)
		j+=1
	while(j<number)

	NewLayout/N=C4sym

	k=0
	do
		AppendLayoutObject graph $c4map[k]
		k+=1
	while(k<number)
end
////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////
Proc FFTpro2r(mat,number,start,a,theta,unit)
	string mat="data"
	variable number=1//=dimsize(file_name, 0)-1
	//variable size=80
	variable start=1
	variable a=3.8
	variable theta=29.283
	variable unit
	prompt mat,"Name of Map Batch"
	prompt number, "Number of the Batch"
	//Prompt size,"Size of the Map  (A)"
	prompt start,"Start number of Batch"
	Prompt a,"lattice constance  (A)"
	Prompt theta,"angle between lattice and x+"
	prompt unit,"k-space unit", popup "A-1;pi/a"
	PauseUpdate
		Silent 1
	variable i
	string matorigin,matdest,matt
	i=0
	do
		matorigin=mat+num2str(i+start)
		//setscale/I x,0,size,"",$matorigin
		//setscale/I y,0,size,"",$matorigin
		matdest=matorigin+"_FFT"
		matt=mat+"FFTsym"+num2str(i+start)
		FFT/OUT=1/DEST=$matdest $matorigin
		FFTsymind2r(matdest)
		duplicate/o M $matt
		//display;appendimage $matt
		//$matt*=1-exp(-(x^2+y^2)/0.0001)

		i+=1
	while(i<number)
	//display;appendimage $matt
	if (unit==2)
		setscale/P x, dimoffset($matt,0)/(0.5/a),dimdelta($matt,0)/(0.5/a),"",$matt
		setscale/P y, dimoffset($matt,1)/(0.5/a),dimdelta($matt,1)/(0.5/a),"",$matt

		//Label bottom "\\Z20\\F'times'k\\B\\Z20x\\M\\Z20 (\F'symbol'p / \F'times'a)"
		//Label left "\\Z20\\F'times'k\\B\\Z20y\\M\\Z20 (\F'symbol'p / \F'times'a)"

		//SetAxis left -0.1,0.1;SetAxis bottom -0.1,0.1
		//ModifyGraph width={Plan,1,bottom,left}
		make/N=500/o linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
		setscale/I x, -8,8,"", linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
		linefft0=tan(theta*pi/180)*x
		linefft1=tan(theta*pi/180)*x+1/cos(theta*pi/180)
		linefft2=tan(theta*pi/180)*x+3/cos(theta*pi/180)
		linefft3=tan(theta*pi/180)*x-1/cos(theta*pi/180)
		linefft4=tan(theta*pi/180)*x-3/cos(theta*pi/180)
		linefft00=tan((theta+90)*pi/180)*x
		linefft5=tan((theta+90)*pi/180)*x+1/cos((theta+90)*pi/180)
		linefft6=tan((theta+90)*pi/180)*x+3/cos((theta+90)*pi/180)
		linefft7=tan((theta+90)*pi/180)*x-1/cos((theta+90)*pi/180)
		linefft8=tan((theta+90)*pi/180)*x-3/cos((theta+90)*pi/180)
		//append linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
	endif
	if (unit==1)
		setscale/P x, dimoffset($matt,0)/(0.5/a),dimdelta($matt,0)/(0.5/a),"",$matt
		setscale/P y, dimoffset($matt,1)/(0.5/a),dimdelta($matt,1)/(0.5/a),"",$matt

		setscale/P x, dimoffset($matt,0)*(pi/a),dimdelta($matt,0)*(pi/a),"",$matt
		setscale/P y, dimoffset($matt,1)*(pi/a),dimdelta($matt,1)*(pi/a),"",$matt

		//Label bottom "\\Z20\\F'times'k\\B\\Z20x\\M\\Z20  (Å\S-1\M\F'times'\Z20)"
		//Label left "\\Z20\\F'times'k\\B\\Z20y\\M\\Z20  (Å\S-1\M\F'times'\Z20)"

		//SetAxis left -0.1,0.1;SetAxis bottom -0.1,0.1
		//ModifyGraph width={Plan,1,bottom,left}
		make/N=500/o linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
		setscale/I x, -8,8,"", linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
		linefft0=tan(theta*pi/180)*x
		linefft1=tan(theta*pi/180)*x+1*(pi/a)/cos(theta*pi/180)
		linefft2=tan(theta*pi/180)*x+3*(pi/a)/cos(theta*pi/180)
		linefft3=tan(theta*pi/180)*x-1*(pi/a)/cos(theta*pi/180)
		linefft4=tan(theta*pi/180)*x-3*(pi/a)/cos(theta*pi/180)
		linefft00=tan((theta+90)*pi/180)*x
		linefft5=tan((theta+90)*pi/180)*x+1*(pi/a)/cos((theta+90)*pi/180)
		linefft6=tan((theta+90)*pi/180)*x+3*(pi/a)/cos((theta+90)*pi/180)
		linefft7=tan((theta+90)*pi/180)*x-1*(pi/a)/cos((theta+90)*pi/180)
		linefft8=tan((theta+90)*pi/180)*x-3*(pi/a)/cos((theta+90)*pi/180)
		//append linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
	endif
end

////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
Function FFTsymind2r(mat)
	string mat
	string mat1
	string matdest
	variable i,zp,zq,pp,p2,a,b,c
	//i=0
	//do
	mat1=mat
	//matdest=mat+"FFTsym"+num2str(i+1)
	wave N=$mat1
	//wave/C D=$matdest
	//zero position
	zp=-dimoffset(N,0)/dimdelta(N,0)+(dimsize(N,0)-1)
	zq=-dimoffset(N,1)/dimdelta(N,1)
	// New size

	make/C/o/N=(((dimsize(N,0)-1)*2+1),dimsize(N,1)) M

	pp=dimsize(N,0)-1
	do
		//pp=p+(dimsize($mat1,0)-1)
		p2=pp-(dimsize(N,0)-1)
		M[pp][]=cmplx(real(N[p2][q]),imag(N[p2][q]))
		pp+=1
	while(pp<dimsize(M,0))
	a=0
	do
		b=0
		do
			M[a][b]=cmplx(real(M[2*zp-a][2*zq-b]),imag(M[2*zp-a][2*zq-b]))
			//c=M[2*zp-a][2*zq-b]
			//M[a][b]=c
			b+=1
		while(b<dimsize(M,1))
		a+=1
	while(a<dimsize(N,0)-1)
	setscale/P y, dimoffset(N,1),dimdelta(N,1),"",M
	setscale/I x, -(dimoffset(N,0)+(dimsize(N,0)-1)*dimdelta(N,0)),(dimoffset(N,0)+(dimsize(N,0)-1)*dimdelta(N,0)),"",M
	//m[zp][zq]=m[0][0]
	//D=M
end
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
proc D2symetric2r(name2,centralx,centraly)
	string name2="datafftsym"
	variable centralx
	variable centraly
	prompt name2,"Data name"
	string name1,name
	name1="backup_"+name
	name="mD2"+name2
	make/o/N=(dimsize($name2,0),dimsize($name2,1)) $name
	$name=sqrt(real($name2)^2+imag($name2)^2)
	setscale/i x,dimoffset($name2,0),dimoffset($name2,0)+dimdelta($name2,0)*(dimsize($name2,0)-1),"",$name
	setscale/i y,dimoffset($name2,1),dimoffset($name2,1)+dimdelta($name2,1)*(dimsize($name2,1)-1),"",$name
	xreflectmatrix2r(name,centralx)
	yreflectmatrix2r(name,centraly)
	duplicate/o $name $name1
	$name*=2
	$name+=namex
	$name+=namey
	$name/=4
	//display;appendimage $name
	//Modifygraph width=300,height=300
	//Modifygraph width=0,height=0
	//ModifyGraph width={Plan,1,bottom,left}
	//SetAxis left -4,4;DelayUpdate
	//SetAxis bottom -4,4
	//ModifyImage $name ctab= {0,5.9e-08,BlueGreenOrange,0}
	//append linefft1 linefft2 linefft3 linefft4 linefft5 linefft6 linefft7 linefft8
	//Label left "\\Z20\\F'times'k\\B\\Z20y\\M\\Z20  (Å\\S-1\\M\\F'times'\\Z20)";DelayUpdate
	//Label bottom "\\Z20\\F'times'k\\B\\Z20y\\M\\Z20  (Å\\S-1\\M\\F'times'\\Z20)"
end
////////////////////////////////////////////////////////////////////////////////////////////////////////
Function xreflectmatrix2r(name,xpoint)
	string name
	variable xpoint
	variable xsize
	variable ysize
	wave N=$name
	//string namex
	xsize=dimsize($name,0)
	ysize=dimsize($name,1)
	//namex=name+"_xinverse"
	make/N=(xsize,ysize)/O namex
	variable i,j
	i=0
	do
		j=0
		do
			if (2*xpoint-j > xsize-1)
			else
				namex[j][i]=N[2*xpoint-j][i]
			endif
			j+=1
		while(j<xsize)
		i+=1
	while(i<ysize)
	setscale/i x,dimoffset(N,0),dimoffset(n,0)+dimdelta(n,0)*(dimsize(n,0)-1),"",namex
	setscale/i y,dimoffset(N,1),dimoffset(n,1)+dimdelta(n,1)*(dimsize(n,1)-1),"",namex
	//display;appendimage namex
end
////////////////////////////////////////////////////////////////////////////////////////////////////////
Function yreflectmatrix2r(name,ypoint)
	string name
	variable ypoint
	variable xsize
	variable ysize
	wave N=$name
	//string namex
	xsize=dimsize($name,0)
	ysize=dimsize($name,1)
	//namex=name+"_xinverse"
	make/N=(xsize,ysize)/O namey
	variable i,j
	i=0
	do
		j=0
		do
			if (2*ypoint-j > ysize-1)
			else
				namey[i][j]=N[i][2*ypoint-j]
			endif
			j+=1
		while(j<ysize)
		i+=1
	while(i<xsize)
	setscale/i x,dimoffset(N,0),dimoffset(n,0)+dimdelta(n,0)*(dimsize(n,0)-1),"",namey
	setscale/i y,dimoffset(N,1),dimoffset(n,1)+dimdelta(n,1)*(dimsize(n,1)-1),"",namey
	//display;appendimage namey
end
////////////////////////////////////////////////////////////////////////////////////////////////////////

proc C4symFFT2r(name,num,theta)
	string name="dataFFTsym"
	variable num
	variable theta=29.283
	Prompt theta,"angle between lattice and x+"
	//wave name
	//name=$nam
	string name1,name2,name3,name4,name5,name6
	make/o/n=(dimsize($name,0),dimsize($name,1)) namenorm
	setscale/p x dimoffset($name,0),dimdelta($name,0),"",namenorm
	setscale/p y dimoffset($name,1),dimdelta($name,1),"",namenorm
	namenorm=sqrt(real($name)^2+imag($name)^2)
	InsertPoints/M=1 dimsize($name,1),1, namenorm
	namenorm[][dimsize($name,1)]=namenorm[p][dimsize($name,1)-1]
	namenorm*=1-exp(-(x^2+y^2)/0.0001)

	string nammm
	nammm="fft"+name
	duplicate/o namenorm $nammm


	name1=name+num2str(1)
	name2=name+num2str(2)
	name3=name+num2str(3)
	name4=name+num2str(4)
	//name5=name+"4foldsym"
	imagerotate/A=0/O namenorm
	//duplicate/o namenorm  $name1
	duplicate/o namenorm  rtt1

	imagerotate/A=90/O namenorm
	//duplicate/o namenorm  $name2
	duplicate/o namenorm  rtt2

	imagerotate/A=90/O namenorm
	//duplicate/o namenorm  $name3
	duplicate/o namenorm  rtt3

	imagerotate/A=90/O namenorm
	//duplicate/o namenorm  $name4
	duplicate/o namenorm  rtt4
	name6="fft4foldsym"+num2str(num)

	duplicate/o namenorm  $name6

 	$name6=(rtt1+rtt2+rtt3+rtt4)/4
	//display;appendimage  $name6
	//ModifyGraph width={Plan,1,bottom,left}
	//Label bottom "\\Z12\\F'times'k\\B\\Z12x\\M\\Z12  (Å\S-1\M\F'times'\Z12)"
	//Label left "\\Z12\\F'times'k\\B\\Z12y\\M\\Z12  (Å\S-1\M\F'times'\Z12)"
	//SetAxis left -0.1,0.1;SetAxis bottom -0.1,0.1
	//ModifyGraph width={Plan,1,bottom,left}
	//make/N=500/o linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
	//setscale/I x, -8,8,"", linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
	//linefft0=tan(theta*pi/180)*x
	//linefft1=tan(theta*pi/180)*x+1/cos(theta*pi/180)
	//linefft2=tan(theta*pi/180)*x+3/cos(theta*pi/180)
	//linefft3=tan(theta*pi/180)*x-1/cos(theta*pi/180)
	//linefft4=tan(theta*pi/180)*x-3/cos(theta*pi/180)
	//linefft00=tan((theta+90)*pi/180)*x
	//linefft5=tan((theta+90)*pi/180)*x+1/cos((theta+90)*pi/180)
	//linefft6=tan((theta+90)*pi/180)*x+3/cos((theta+90)*pi/180)
	//linefft7=tan((theta+90)*pi/180)*x-1/cos((theta+90)*pi/180)
	//linefft8=tan((theta+90)*pi/180)*x-3/cos((theta+90)*pi/180)
	//**************//$name6*=1-exp(-(x^2+y^2)/0.0001)
	//append linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
	//ModifyImage $name6 ctab= {*,*,BlueGreenOrange,0}
	//matrixfilter avg $name6
	//matrixfilter avg $name6
	//matrixfilter avg $name6
	//matrixfilter avg $name6
	//modifygraph width=150,height=150
	//modifygraph width=0,height=0
	//ModifyGraph width={Plan,1,bottom,left}
end
////////////////////////////////////////////////////////////////////////////////////////////////////////
proc twoDinterpolate2r(name,xpoint,ypoint)
	string name=""
	variable xpoint
	variable ypoint
	prompt name,"Name of Raw Data"
	Prompt xpoint,"Point number of x you wanted "
	Prompt ypoint,"Point number of y you wanted "
	variable i,j,k
	variable sizex, sizey
	string curve1,curve2,curve11,curve22,name1,name2
	sizex=dimsize($name,0)
	sizey=dimsize($name,1)
	i=0
	do
		curve1="curve1_"+num2str(i)
		curve11="curve1L_"+num2str(i)
		make/O/N=(sizey) $curve1
		$curve1[]=$name[i][p]
		interpolate2/n=(ypoint) /t=1/Y=$curve11 $curve1
		i+=1
	while(i<sizex)
	name1=name+"1"
	make/O/N=(sizex,ypoint) $name1
	aamakematrix2r(name1,sizex,ypoint)
	j=0
	do
		curve2="curve2_"+num2str(j)
		curve22="curve2L_"+num2str(j)
		make/O/N=(sizex) $curve2
		$curve2[]=$name1[p][j]
		interpolate2/n=(xpoint) /t=1/Y=$curve22 $curve2
		j+=1
	while(j<ypoint)
	name2="Inter_"+name
	make/O/N=(xpoint,ypoint) $name2
	aamakematrix3r(name2,xpoint,ypoint)
	setscale/I x,dimoffset($name,0),dimoffset($name,0)+dimdelta($name,0)*(dimsize($name,0)-1),""$name2
	setscale/I y,dimoffset($name,1),dimoffset($name,1)+dimdelta($name,1)*(dimsize($name,1)-1),""$name2
	display;appendimage $name2
	ModifyGraph width={Plan,1,bottom,left}
end
////////////////////////////////////////////////////////////////////////////////////////////////////////
Function aamakematrix2r(namee,sizex,sizey)
	string namee
	variable sizex,sizey
	string wavenamec
	variable j,k
	wave N=$namee
	j=0
	do
		k=0
		do
			wavenamec="curve1L_"+num2str(j)
			wave M=$wavenamec
			N[j][k]=M[k]
			K+=1
		while(k<sizey)
		J+=1
	while(j<sizex)
end
////////////////////////////////////////////////////////////////////////////////////////////////////////
Function aamakematrix3r(namee,sizex,sizey)
	string namee
	variable sizex,sizey
	string wavenamec
	variable j,k
	wave N=$namee
	j=0
	do
		k=0
		do
			wavenamec="curve2L_"+num2str(j)
			wave M=$wavenamec
			N[k][j]=M[k]
			K+=1
		while(k<sizey)
		J+=1
	while(j<sizex)
end
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
// This Procedure {allqpi()} is Multiple filtered QPI data.                                                                                                                               //
// 1. A symmetric FFT was made by procedure FFTpro2()                                                                                                             //
// 2. We do Dxy symmetrization on FFT data. D2symetric2()                                                                                                        //
// 3. We do C4 symmetrization on Dxy-ed data.  C4symFFT2()    // At the end, a Gauss depression Filter was applied.             //
// 4. The next we do Interp Filter on multiple symmetrized data.                                                                                                   //
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////

//proc allqpi(name,number,lattice,angle,point)
//string name="data"
//variable number
//variable lattice=3.8
//variable angle=0
//variable point=801//odd number
//prompt name,"Batch Name"
//prompt number,"Data number"
//prompt lattice,"Lattice constance (A)"
//prompt angle,"angle of lattice to x+"
//prompt point,"Points of Interp FIlter"

//string nameall,namefftsym,namefftsymd2,namefftsymd22,namec4,final
//variable centralnum
//nameall=name+num2str(number)
//namefftsym="datafftsym"+num2str(number)
//namefftsymd2="modulaD2"+namefftsym
//namec4="fft4foldsym"+num2str(number)
//final="inter_"+namec4
//centralnum= (dimsize($namefftsym,0)-1)/2
        //////////////namefftsymd22=namefftsymd2+"2"
//FFTpro2(name,1,number,lattice,angle,1)
//D2symetric2(namefftsym,centralnum,centralnum)
//C4symFFT2(namefftsymd2,number,angle)
//twoDinterpolate2(namec4,point,point)
       ///////////C4symFFT(namefftsymd22,number,0)
//SetAxis left -0.18,0.18;DelayUpdate
//SetAxis bottom -0.18,0.18
//modifygraph width=200,height=200
//modifygraph width=0,height=0
//ModifyGraph width={Plan,1,bottom,left}
//Label left "\\Z12\\F'times'k\\B\\Z12y\\M\\Z12  (Å\\S-1\\M\\F'times'\\Z12)"
//Label bottom "\\Z12\\F'times'k\\B\\Z12x\\M\\Z12  (Å\\S-1\\M\\F'times'\\Z12)"
//ModifyImage $final ctab= {*,*,ColdWarm,0}
//end
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_mulQPI(ctrlName) : ButtonControl
	String ctrlName
	Execute " haha()"
end
proc haha(name,number,lattice,angle,point,dis,energystart,energydelta)
	string name="data"
	variable number=dimsize(file_name,0)-1
	variable lattice=4.1
	variable angle=45
	variable point=300//odd number
	variable dis=1.6
	variable energystart=-30
	variable energydelta=2
	prompt name,"Batch Name"
	prompt number,"Data number"
	prompt lattice,"Lattice constance (A)"
	prompt angle,"angle of lattice to x+"
	prompt point,"Points of Interp FIlter"
	prompt dis,"size of display +- A-1"
	variable i
	variable energy
	i=1
	do
		energy=energystart+(i-1)*energydelta
		allqpihaha(name,i,lattice,angle,point,dis,energy)
		//TextBox/C/N=text0/F=0/B=1 "\\F'Times New Roman'\\K(65535,0,0)\\Z18"+num2str(energy)
		i+=1
	while(i<number+1)
	layoutqpi(number)
	layoutdata(number)
	layoutc4(number,dis)
end
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
// This Procedure {allqpi2()} is Multiple filtered QPI data.                                                                                                           //
// 1. A symmetric FFT was made by procedure FFTpro2()                                                                                                             //
// 2. The next we do Interp Filter on Modula of FFT.
// 3. We do C4 symmetrization on Dxy-ed data.  C4symFFT2()    // At the end, a Gauss depression Filter was applied.             //
// 4. We do Dxy symmetrization on FFT data. D2symetric2()                                                                                                        //
// 5. We do GAUSS FILTER for two times                                                                                                                                          //
//                                                                                                 //
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_allqpi(ctrlName) : ButtonControl
	String ctrlName
	Execute " allqpihaha()"
end
////////////////////////////////////////////////////////////////////////////////////////////////////////
proc allqpihaha(name,number,lattice,angle,point,dis,energy)
	string name="data"
	variable number
	variable lattice=3.8
	variable angle=0
	variable point=801//odd number
	variable dis=0.1
	variable energy
	prompt name,"Batch Name"
	prompt number,"Data number"
	prompt lattice,"Lattice constance (A)"
	prompt angle,"angle of lattice to x+"
	prompt point,"Points of Interp FIlter"
	prompt dis,"size of display +- A-1"
 	allqpipp(name,number,lattice,angle,point)
 	allqpi2(name,number,lattice,angle,point,dis,energy)
end

////////////////////////////////////////////////////////////////////////////////////////////////////////
proc allqpi2(name,number,lattice,angle,point,dis,energy)
	string name="data"
	variable number
	variable lattice=3.8
	variable angle=0
	variable point=801//odd number
	variable dis=0.1
	variable energy
	prompt name,"Batch Name"
	prompt number,"Data number"
	prompt lattice,"Lattice constance (A)"
	prompt angle,"angle of lattice to x+"
	prompt point,"Points of Interp FIlter"
	prompt dis,"size of display +- A-1"


	string nameall,namefftsym,namefftsymd2,namefftsymd22,namec4,final,nammm
	variable centralnum
	nameall=name+num2str(number)
	namefftsym="datafftsym"+num2str(number)
	//namefftsymd2=namefftsym+"modulaD2"
	//namec4="fft4foldsym"+num2str(number)
	namefftsymd2="fft4foldsym"+num2str(number)
	namec4="modulaD2"+namefftsymd2
	final="inter_"+namec4
	centralnum= (dimsize($namefftsym,0)-1)/2
	//namefftsymd22=namefftsymd2+"2"
	//FFTpro2(name,1,number,lattice,angle,1)
	//C4symFFT2(namefftsym,number,angle)
	//D2symetric2(namefftsymd2,centralnum,centralnum)
	//D2symetric2(namefftsymd2,centralnum,centralnum)
	//
	FFTpro2(name,1,number,lattice,angle,1)
	C4symFFT2(namefftsym,number,angle)

	nammm="fft"+namefftsym
	display;appendimage $nammm
	ModifyImage $nammm ctab= {*,*,BlueGreenOrange,0}
	append linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
	ModifyGraph rgb=(0,0,0);ModifyGraph lstyle=7
	SetAxis left -dis,dis;DelayUpdate
	SetAxis bottom -dis,dis
	modifygraph width=400,height=400
	modifygraph width=0,height=0
	ModifyGraph width={Plan,1,bottom,left}
	Label left "\\Z12\\F'times'k\\B\\Z12y\\M\\Z12  (Å\\S-1\\M\\F'times'\\Z12)"
	Label bottom "\\Z12\\F'times'k\\B\\Z12x\\M\\Z12  (Å\\S-1\\M\\F'times'\\Z12)"
	TextBox/C/N=text0/F=0/B=1 "\\F'Times New Roman'\\K(65535,0,0)\\Z18"+num2str(energy)
	//ModifyImage $nammm ctab= {*,*,Grays,0}
	//D2symetric2(namefftsymd2,centralnum,centralnum)
	D2symetric2(namefftsymd2,centralnum,centralnum)
	matrixfilter gauss $namec4
	matrixfilter gauss $namec4


	display;appendimage $namec4
	append linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
	ModifyGraph rgb=(0,0,0);ModifyGraph lstyle=7
	SetAxis left -dis,dis;DelayUpdate
	SetAxis bottom -dis,dis
	modifygraph width=400,height=400
	modifygraph width=0,height=0
	ModifyGraph width={Plan,1,bottom,left}
	Label left "\\Z12\\F'times'k\\B\\Z12y\\M\\Z12  (Å\\S-1\\M\\F'times'\\Z12)"
	Label bottom "\\Z12\\F'times'k\\B\\Z12x\\M\\Z12  (Å\\S-1\\M\\F'times'\\Z12)"
	ModifyImage $namec4 ctab= {*,*,Grays256,0}
	TextBox/C/N=text0/F=0/B=1 "\\F'Times New Roman'\\K(65535,0,0)\\Z18"+num2str(energy)
	twoDinterpolate2(namec4,point,point)
	//C4symFFT(namefftsymd22,number,0)
	append linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
	ModifyGraph rgb=(0,0,0);ModifyGraph lstyle=7
	SetAxis left -dis,dis;DelayUpdate
	SetAxis bottom -dis,dis
	modifygraph width=400,height=400
	modifygraph width=0,height=0
	ModifyGraph width={Plan,1,bottom,left}
	Label left "\\Z12\\F'times'k\\B\\Z12y\\M\\Z12  (Å\\S-1\\M\\F'times'\\Z12)"
	Label bottom "\\Z12\\F'times'k\\B\\Z12x\\M\\Z12  (Å\\S-1\\M\\F'times'\\Z12)"
	TextBox/C/N=text0/F=0/B=1 "\\F'Times New Roman'\\K(65535,0,0)\\Z18"+num2str(energy)
	ModifyImage $final ctab= {*,*,bluegreenorange,0}
end
////////////////////////////////////////////////////////////////////////////////////////////////////////
proc layoutqpi(number)
	variable number
	variable i,j
	make/T/N=(number)/o textfft
	make/T/N=(number)/o textsym
	make/T/N=(number)/o textsyminter
	i=0
	j=0
	do
		textsyminter[number-1-i]=winname(j,1)
		textsym[number-1-i]=winname(j+1,1)
		textfft[number-1-i]=winname(j+2,1)
		i+=1
		j+=3
	while(i<number)
	//edit   textfft textsym textsyminter
	variable i1,i2,i3
	NewLayout/N=fft
	//s1=textfft[
	i1=0
	do
		AppendLayoutObject graph $textfft[i1]
		i1+=1
	while(i1<number)
	Tile
	NewLayout/N=sym
	//s1=textfft[
	i2=0
	do
		AppendLayoutObject graph $textsym[i2]
		i2+=1
	while(i2<number)
	Tile
	NewLayout/N=syminter
	//s1=textfft[
	i3=0
	do
		AppendLayoutObject graph $textsyminter[i3]
		i3+=1
	while(i3<number)
	Tile
end
////////////////////////////////////////////////////////////////////////////////////////////////////////
proc layoutdata(number)
	variable number
	variable energy
	variable i,j,k
	string name
	i=1
	do
		name="data"+num2str(i)
		display;appendimage $name
		ModifyImage $name ctab= {*,*,Mud,0}
		//SetAxis left -0.1,0.1;DelayUpdate
		//SetAxis bottom -0.1,0.1
		modifygraph width=400,height=400
		modifygraph width=0,height=0
		ModifyGraph width={Plan,1,bottom,left}
		Label left "\\Z12\\F'times'y  (Å\\S\\M\\F'times'\\Z12)"
		Label bottom "\\Z12\\F'times'x  (Å\\S\\M\\F'times'\\Z12)"
		//TextBox/C/N=text0/F=0/B=1 "\\F'Times New Roman'\\K(65535,0,0)\\Z18"+num2str(energy)
		//ModifyImage $name ctab= {*,*,Grays,0}
		i+=1
	while(i<number+1)

	make/T/N=(number)/o qpimap
	j=0
	do
		qpimap[number-1-j]=winname(j,1)
		j+=1
	while(j<number)

	NewLayout/N=Map

	k=0
	do
		AppendLayoutObject graph $qpimap[k]
		k+=1
	while(k<number)
end
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
proc layoutc4(number,dis)
	variable number
	variable dis
	variable energy
	variable i,j,k
	string name
	i=1
	do
		name="fft4foldsym"+num2str(i)
		display;appendimage $name
		ModifyImage $name ctab= {*,*,BlueGreenOrange,0}
		SetAxis left -dis,dis;DelayUpdate
		SetAxis bottom -dis,dis
		modifygraph width=400,height=400
		modifygraph width=0,height=0
		ModifyGraph width={Plan,1,bottom,left}
		Label left "\\Z12\\F'times'y  (Å\\S-1\\M\\F'times'\\Z12)"
		Label bottom "\\Z12\\F'times'x  (Å\\S-1\\M\\F'times'\\Z12)"
		//TextBox/C/N=text0/F=0/B=1 "\\F'Times New Roman'\\K(65535,0,0)\\Z18"+num2str(energy)
		//ModifyImage $name ctab= {*,*,Grays,0}
		i+=1
	while(i<number+1)

	make/T/N=(number)/o c4map
	j=0
	do
		c4map[number-1-j]=winname(j,1)
		j+=1
	while(j<number)

	NewLayout/N=C4sym

	k=0
	do
		AppendLayoutObject graph $c4map[k]
		k+=1
	while(k<number)
end
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////
////////////////////////////////
proc allqpipp(name,number,lattice,angle,point)
	string name="data"
	variable number
	variable lattice=3.8
	variable angle=0
	variable point=801//odd number
	prompt name,"Batch Name"
	prompt number,"Data number"
	prompt lattice,"Lattice constance (A)"
	prompt angle,"angle of lattice to x+"
	prompt point,"Points of Interp FIlter"

	string nameall,namefftsym,namefftsymd2,namefftsymd22,namec4,final
	variable centralnum
	nameall=name+num2str(number)
	namefftsym="datafftsym"+num2str(number)
	//namefftsymd2=namefftsym+"modulaD2"
	//namec4="fft4foldsym"+num2str(number)
	namefftsymd2="fft4foldsym"+num2str(number)
	namec4="modulaD2"+namefftsymd2
	final="inter_"+namec4
	centralnum= (dimsize($namefftsym,0)-1)/2
	//namefftsymd22=namefftsymd2+"2"
	//FFTpro2(name,1,number,lattice,angle,1)
	//C4symFFT2(namefftsym,number,angle)
	//D2symetric2(namefftsymd2,centralnum,centralnum)
	//D2symetric2(namefftsymd2,centralnum,centralnum)
	//
	FFTpro2(name,1,number,lattice,angle,1)
	C4symFFT2(namefftsym,number,angle)

	//D2symetric2(namefftsymd2,centralnum,centralnum)
	D2symetric2(namefftsymd2,centralnum,centralnum)
	matrixfilter gauss $namec4
	matrixfilter gauss $namec4
	//display;appendimage $namec4
	//SetAxis left -0.1,0.1;DelayUpdate
	//SetAxis bottom -0.1,0.1
	//modifygraph width=200,height=200
	//modifygraph width=0,height=0
	//ModifyGraph width={Plan,1,bottom,left}
	//Label left "\\Z12\\F'times'k\\B\\Z12y\\M\\Z12  (Å\\S-1\\M\\F'times'\\Z12)"
	//Label bottom "\\Z12\\F'times'k\\B\\Z12x\\M\\Z12  (Å\\S-1\\M\\F'times'\\Z12)"
	//ModifyImage $namec4 ctab= {*,*,ColdWarm,0}
	//twoDinterpolate2(namec4,point,point)
	//C4symFFT(namefftsymd22,number,0)
	//SetAxis left -0.1,0.1;DelayUpdate
	//SetAxis bottom -0.1,0.1
	//modifygraph width=200,height=200
	//modifygraph width=0,height=0
	//ModifyGraph width={Plan,1,bottom,left}
	//Label left "\\Z12\\F'times'k\\B\\Z12y\\M\\Z12  (Å\\S-1\\M\\F'times'\\Z12)"
	//Label bottom "\\Z12\\F'times'k\\B\\Z12x\\M\\Z12  (Å\\S-1\\M\\F'times'\\Z12)"
	//ModifyImage $final ctab= {*,*,ColdWarm,0}


////////////////////////////////////////////////////////////////////////////////////////////////////////
Proc FFTpro2(mat,number,start,a,theta,unit)
	string mat="data"
	variable number=1//=dimsize(file_name, 0)-1
	//variable size=80
	variable start=1
	variable a=3.8
	variable theta=29.283
	variable unit
	prompt mat,"Name of Map Batch"
	prompt number, "Number of the Batch"
	//Prompt size,"Size of the Map  (A)"
	prompt start,"Start number of Batch"
	Prompt a,"lattice constance  (A)"
	Prompt theta,"angle between lattice and x+"
	prompt unit,"k-space unit", popup "A-1;pi/a"
	PauseUpdate
		Silent 1
	variable i
	string matorigin,matdest,matt
	i=0
	do
		matorigin=mat+num2str(i+start)
		//setscale/I x,0,size,"",$matorigin
		//setscale/I y,0,size,"",$matorigin
		matdest=matorigin+"_FFT"
		matt=mat+"FFTsym"+num2str(i+start)
		FFT/OUT=1/DEST=$matdest $matorigin
		FFTsymind2(matdest)
		duplicate/o M $matt
		//display;appendimage $matt
		//$matt*=1-exp(-(x^2+y^2)/0.0001)

		i+=1
	while(i<number)
	//display;appendimage $matt
	if (unit==2)
		setscale/P x, dimoffset($matt,0)/(0.5/a),dimdelta($matt,0)/(0.5/a),"",$matt
		setscale/P y, dimoffset($matt,1)/(0.5/a),dimdelta($matt,1)/(0.5/a),"",$matt

		//Label bottom "\\Z20\\F'times'k\\B\\Z20x\\M\\Z20 (\F'symbol'p / \F'times'a)"
		//Label left "\\Z20\\F'times'k\\B\\Z20y\\M\\Z20 (\F'symbol'p / \F'times'a)"

		//SetAxis left -0.1,0.1;SetAxis bottom -0.1,0.1
		//ModifyGraph width={Plan,1,bottom,left}
		make/N=10/o linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
		setscale/I x, -8,8,"", linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
		linefft0=tan(theta*pi/180)*x
		linefft1=tan(theta*pi/180)*x+1/cos(theta*pi/180)
		linefft2=tan(theta*pi/180)*x+3/cos(theta*pi/180)
		linefft3=tan(theta*pi/180)*x-1/cos(theta*pi/180)
		linefft4=tan(theta*pi/180)*x-3/cos(theta*pi/180)
		linefft00=tan((theta+90)*pi/180)*x
		linefft5=tan((theta+90)*pi/180)*x+1/cos((theta+90)*pi/180)
		linefft6=tan((theta+90)*pi/180)*x+3/cos((theta+90)*pi/180)
		linefft7=tan((theta+90)*pi/180)*x-1/cos((theta+90)*pi/180)
		linefft8=tan((theta+90)*pi/180)*x-3/cos((theta+90)*pi/180)
		//append linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
	endif
	if (unit==1)
		setscale/P x, dimoffset($matt,0)/(0.5/a),dimdelta($matt,0)/(0.5/a),"",$matt
		setscale/P y, dimoffset($matt,1)/(0.5/a),dimdelta($matt,1)/(0.5/a),"",$matt

		setscale/P x, dimoffset($matt,0)*(pi/a),dimdelta($matt,0)*(pi/a),"",$matt
		setscale/P y, dimoffset($matt,1)*(pi/a),dimdelta($matt,1)*(pi/a),"",$matt

		//Label bottom "\\Z20\\F'times'k\\B\\Z20x\\M\\Z20  (Å\S-1\M\F'times'\Z20)"
		//Label left "\\Z20\\F'times'k\\B\\Z20y\\M\\Z20  (Å\S-1\M\F'times'\Z20)"

		//SetAxis left -0.1,0.1;SetAxis bottom -0.1,0.1
		//ModifyGraph width={Plan,1,bottom,left}
		make/N=500/o linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
		setscale/I x, -8,8,"", linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
		linefft0=tan(theta*pi/180)*x
		linefft1=tan(theta*pi/180)*x+1*(pi/a)/cos(theta*pi/180)
		linefft2=tan(theta*pi/180)*x+3*(pi/a)/cos(theta*pi/180)
		linefft3=tan(theta*pi/180)*x-1*(pi/a)/cos(theta*pi/180)
		linefft4=tan(theta*pi/180)*x-3*(pi/a)/cos(theta*pi/180)
		linefft00=tan((theta+90)*pi/180)*x
		linefft5=tan((theta+90)*pi/180)*x+1*(pi/a)/cos((theta+90)*pi/180)
		linefft6=tan((theta+90)*pi/180)*x+3*(pi/a)/cos((theta+90)*pi/180)
		linefft7=tan((theta+90)*pi/180)*x-1*(pi/a)/cos((theta+90)*pi/180)
		linefft8=tan((theta+90)*pi/180)*x-3*(pi/a)/cos((theta+90)*pi/180)
		//append linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
	endif
end

////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
Function FFTsymind2(mat)
	string mat
	string mat1
	string matdest
	variable i,zp,zq,pp,p2,a,b,c
	//i=0
	//do
	mat1=mat
	//matdest=mat+"FFTsym"+num2str(i+1)
	wave N=$mat1
	//wave/C D=$matdest
	//zero position
	zp=-dimoffset(N,0)/dimdelta(N,0)+(dimsize(N,0)-1)
	zq=-dimoffset(N,1)/dimdelta(N,1)
	// New size

	make/C/o/N=(((dimsize(N,0)-1)*2+1),dimsize(N,1)) M

	pp=dimsize(N,0)-1
	do
		//pp=p+(dimsize($mat1,0)-1)
		p2=pp-(dimsize(N,0)-1)
		M[pp][]=cmplx(real(N[p2][q]),imag(N[p2][q]))
		pp+=1
	while(pp<dimsize(M,0))
	a=0
	do
		b=0
		do
			M[a][b]=cmplx(real(M[2*zp-a][2*zq-b]),imag(M[2*zp-a][2*zq-b]))
			//c=M[2*zp-a][2*zq-b]
			//M[a][b]=c
			b+=1
		while(b<dimsize(M,1))
		a+=1
	while(a<dimsize(N,0)-1)
	setscale/P y, dimoffset(N,1),dimdelta(N,1),"",M
	setscale/I x, -(dimoffset(N,0)+(dimsize(N,0)-1)*dimdelta(N,0)),(dimoffset(N,0)+(dimsize(N,0)-1)*dimdelta(N,0)),"",M
	//m[zp][zq]=m[0][0]
	//D=M
end
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
proc D2symetric2(name2,centralx,centraly)
	string name2="datafftsym"
	variable centralx
	variable centraly
	prompt name2,"Data name"
	string name1,name
	name1="backup_"+name
	name="modulaD2"+name2
	make/o/N=(dimsize($name2,0),dimsize($name2,1)) $name
	$name=sqrt(real($name2)^2+imag($name2)^2)
	setscale/i x,dimoffset($name2,0),dimoffset($name2,0)+dimdelta($name2,0)*(dimsize($name2,0)-1),"",$name
	setscale/i y,dimoffset($name2,1),dimoffset($name2,1)+dimdelta($name2,1)*(dimsize($name2,1)-1),"",$name
	xreflectmatrix2(name,centralx)
	yreflectmatrix2(name,centraly)
	duplicate/o $name $name1
	$name*=2
	$name+=namex
	$name+=namey
	$name/=4
	//display;appendimage $name
	//Modifygraph width=300,height=300
	//Modifygraph width=0,height=0
	//ModifyGraph width={Plan,1,bottom,left}
	//SetAxis left -4,4;DelayUpdate
	//SetAxis bottom -4,4
	//ModifyImage $name ctab= {0,5.9e-08,BlueGreenOrange,0}
	//append linefft1 linefft2 linefft3 linefft4 linefft5 linefft6 linefft7 linefft8
	//Label left "\\Z20\\F'times'k\\B\\Z20y\\M\\Z20  (Å\\S-1\\M\\F'times'\\Z20)";DelayUpdate
	//Label bottom "\\Z20\\F'times'k\\B\\Z20y\\M\\Z20  (Å\\S-1\\M\\F'times'\\Z20)"
end
////////////////////////////////////////////////////////////////////////////////////////////////////////
Function xreflectmatrix2(name,xpoint)
	string name
	variable xpoint
	variable xsize
	variable ysize
	wave N=$name
	//string namex
	xsize=dimsize($name,0)
	ysize=dimsize($name,1)
	//namex=name+"_xinverse"
	make/N=(xsize,ysize)/O namex
	variable i,j
	i=0
	do
		j=0
		do
			if (2*xpoint-j > xsize-1)
			else
				namex[j][i]=N[2*xpoint-j][i]
			endif
			j+=1
		while(j<xsize)
		i+=1
	while(i<ysize)
	setscale/i x,dimoffset(N,0),dimoffset(n,0)+dimdelta(n,0)*(dimsize(n,0)-1),"",namex
	setscale/i y,dimoffset(N,1),dimoffset(n,1)+dimdelta(n,1)*(dimsize(n,1)-1),"",namex
	//display;appendimage namex
end
////////////////////////////////////////////////////////////////////////////////////////////////////////
Function yreflectmatrix2(name,ypoint)
	string name
	variable ypoint
	variable xsize
	variable ysize
	wave N=$name
	//string namex
	xsize=dimsize($name,0)
	ysize=dimsize($name,1)
	//namex=name+"_xinverse"
	make/N=(xsize,ysize)/O namey
	variable i,j
	i=0
	do
		j=0
		do
			if (2*ypoint-j > ysize-1)
			else
				namey[i][j]=N[i][2*ypoint-j]
			endif
			j+=1
		while(j<ysize)
		i+=1
	while(i<xsize)
	setscale/i x,dimoffset(N,0),dimoffset(n,0)+dimdelta(n,0)*(dimsize(n,0)-1),"",namey
	setscale/i y,dimoffset(N,1),dimoffset(n,1)+dimdelta(n,1)*(dimsize(n,1)-1),"",namey
	//display;appendimage namey
end
////////////////////////////////////////////////////////////////////////////////////////////////////////

proc C4symFFT2(name,num,theta)
	string name="dataFFTsym"
	variable num
	variable theta=29.283
	Prompt theta,"angle between lattice and x+"
	//wave name
	//name=$nam
	string name1,name2,name3,name4,name5,name6
	make/o/n=(dimsize($name,0),dimsize($name,1)) namenorm
	setscale/p x dimoffset($name,0),dimdelta($name,0),"",namenorm
	setscale/p y dimoffset($name,1),dimdelta($name,1),"",namenorm
	namenorm=sqrt(real($name)^2+imag($name)^2)
	InsertPoints/M=1 dimsize($name,1),1, namenorm
	namenorm[][dimsize($name,1)]=namenorm[p][dimsize($name,1)-1]
	namenorm*=1-exp(-(x^2+y^2)/0.005) // for 200nm 64 point map please choose sigma=0.0001

	string nammm
	nammm="fft"+name
	duplicate/o namenorm $nammm


	name1=name+num2str(1)
	name2=name+num2str(2)
	name3=name+num2str(3)
	name4=name+num2str(4)
	//name5=name+"4foldsym"
	imagerotate/A=0/O namenorm
	//duplicate/o namenorm  $name1
	duplicate/o namenorm  rtt1

	imagerotate/A=90/O namenorm
	//duplicate/o namenorm  $name2
	duplicate/o namenorm  rtt2

	imagerotate/A=90/O namenorm
	//duplicate/o namenorm  $name3
	duplicate/o namenorm  rtt3

	imagerotate/A=90/O namenorm
	//duplicate/o namenorm  $name4
	duplicate/o namenorm  rtt4
	name6="fft4foldsym"+num2str(num)

	duplicate/o namenorm  $name6

 	$name6=(rtt1+rtt2+rtt3+rtt4)/4
	//display;appendimage  $name6
	//ModifyGraph width={Plan,1,bottom,left}
	//Label bottom "\\Z12\\F'times'k\\B\\Z12x\\M\\Z12  (Å\S-1\M\F'times'\Z12)"
	//Label left "\\Z12\\F'times'k\\B\\Z12y\\M\\Z12  (Å\S-1\M\F'times'\Z12)"
	//SetAxis left -0.1,0.1;SetAxis bottom -0.1,0.1
	//ModifyGraph width={Plan,1,bottom,left}
	//make/N=500/o linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
	//setscale/I x, -8,8,"", linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
	//linefft0=tan(theta*pi/180)*x
	//linefft1=tan(theta*pi/180)*x+1/cos(theta*pi/180)
	//linefft2=tan(theta*pi/180)*x+3/cos(theta*pi/180)
	//linefft3=tan(theta*pi/180)*x-1/cos(theta*pi/180)
	//linefft4=tan(theta*pi/180)*x-3/cos(theta*pi/180)
	//linefft00=tan((theta+90)*pi/180)*x
	//linefft5=tan((theta+90)*pi/180)*x+1/cos((theta+90)*pi/180)
	//linefft6=tan((theta+90)*pi/180)*x+3/cos((theta+90)*pi/180)
	//linefft7=tan((theta+90)*pi/180)*x-1/cos((theta+90)*pi/180)
	//linefft8=tan((theta+90)*pi/180)*x-3/cos((theta+90)*pi/180)
	//**************//$name6*=1-exp(-(x^2+y^2)/0.0001)
	//append linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
	//ModifyImage $name6 ctab= {*,*,BlueGreenOrange,0}
	//matrixfilter avg $name6
	//matrixfilter avg $name6
	//matrixfilter avg $name6
	//matrixfilter avg $name6
	//modifygraph width=150,height=150
	//modifygraph width=0,height=0
	//ModifyGraph width={Plan,1,bottom,left}
end
////////////////////////////////////////////////////////////////////////////////////////////////////////
proc twoDinterpolate2(name,xpoint,ypoint)
	string name=""
	variable xpoint
	variable ypoint
	prompt name,"Name of Raw Data"
	Prompt xpoint,"Point number of x you wanted "
	Prompt ypoint,"Point number of y you wanted "
	variable i,j,k
	variable sizex, sizey
	string curve1,curve2,curve11,curve22,name1,name2
	sizex=dimsize($name,0)
	sizey=dimsize($name,1)
	i=0
	do
		curve1="curve1_"+num2str(i)
		curve11="curve1L_"+num2str(i)
		make/O/N=(sizey) $curve1
		$curve1[]=$name[i][p]
		interpolate2/n=(ypoint) /t=1/Y=$curve11 $curve1
		i+=1
	while(i<sizex)
	name1=name+"1"
	make/O/N=(sizex,ypoint) $name1
	aamakematrix2(name1,sizex,ypoint)
	j=0
	do
		curve2="curve2_"+num2str(j)
		curve22="curve2L_"+num2str(j)
		make/O/N=(sizex) $curve2
		$curve2[]=$name1[p][j]
		interpolate2/n=(xpoint) /t=1/Y=$curve22 $curve2
		j+=1
	while(j<ypoint)
	name2="Inter_"+name
	make/O/N=(xpoint,ypoint) $name2
	aamakematrix3(name2,xpoint,ypoint)
	setscale/I x,dimoffset($name,0),dimoffset($name,0)+dimdelta($name,0)*(dimsize($name,0)-1),""$name2
	setscale/I y,dimoffset($name,1),dimoffset($name,1)+dimdelta($name,1)*(dimsize($name,1)-1),""$name2
	display;appendimage $name2
	ModifyGraph width={Plan,1,bottom,left}
end
////////////////////////////////////////////////////////////////////////////////////////////////////////
Function aamakematrix2(namee,sizex,sizey)
	string namee
	variable sizex,sizey
	string wavenamec
	variable j,k
	wave N=$namee
	j=0
	do
		k=0
		do
			wavenamec="curve1L_"+num2str(j)
			wave M=$wavenamec
			N[j][k]=M[k]
			K+=1
		while(k<sizey)
		J+=1
	while(j<sizex)
end
////////////////////////////////////////////////////////////////////////////////////////////////////////
Function aamakematrix3(namee,sizex,sizey)
	string namee
	variable sizex,sizey
	string wavenamec
	variable j,k
	wave N=$namee
	j=0
	do
		k=0
		do
			wavenamec="curve2L_"+num2str(j)
			wave M=$wavenamec
			N[k][j]=M[k]
			K+=1
		while(k<sizey)
		J+=1
	while(j<sizex)
end
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////



Function ButtonProc_displaymulti(ctrlName) : ButtonControl
	String ctrlName
	Execute "displaymulti()"
end
//////////////////////////////////////////////////////
Proc displaymulti(dataname,from,to)
	string dataname="sts", datan,datam
	variable from = 1
	variable to //= dimsize(File_name,0)-1
	display
	displaymultiF(dataname,from,to)
end

Function  displaymultiF(dataname,from,to)
	string dataname
	variable from
	variable to

	STRING  datan,datam
	variable i
	i=1
	do
		datan=dataname+num2str(i)
		WAVE datanw=$datan
		if (i<from)
		else
		appendtograph datanw
		endif
		i+=1
	while(i<(to+1))

	wavestats/Q datanw
	//print nameofwave(datanw)
	//print V_max
	Constantoffset_nF(3*V_max/itemsInList(WaveList("*", ";","WIN:")),1)
	modifygraph width=300,height=500
end
//////////////////////////////////////////////////////

Function ButtonProc_map(ctrlName) : ButtonControl
	String ctrlName
	Execute "linkstsmap_P()"
end
Function ButtonProc_extractfromdos(ctrlName) : ButtonControl
	String ctrlName
	Execute "extractdatafromdos()"
end

Proc stsnorm(name)
	variable i,j
	string name
	string normcurve, dataname
	i=0
	do
		dataname= name+num2str(i+17)
		normcurve= name+num2str(i+1)
		j=0
		do
			$dataname[j]/=($normcurve[j]/(dimoffset($normcurve,0)+j*dimdelta($normcurve,0)))
			j+=1
		while(j<(dimsize($normcurve,0)-1))
		i+=1
	while(i<(dimsize(file_name,0)-1)/2)

end
////////////////
Function stsnormlize(namehaha,start)
	string namehaha
	variable start
	string name,mame
	variable i,j
	i=0
	do
		name=namehaha+num2str(i+start)
		mame=namehaha+num2str(i)
		wave n=$name
		wave m=$mame

		j=0
		do
			n[j]/=(m[j]*10^9/(dimoffset(m,0)+j*dimdelta(m,0)+1*10^(-1)))
			J+=1
		while(j<(dimsize(m,0)-1))
		i+=1
	while(i<(start))

end

Function stsnormlizesingle(namehaha,normhaha)
	string namehaha
	string normhaha
	//variable start
	//string name,mame
	variable j
	//i=0
	//do
	//name=namehaha+num2str(i+start)
	//mame=namehaha+num2str(i)
	wave n=$namehaha
	wave m=$normhaha
	duplicate/o n test
	j=0
	do
		test[j]=sqrt((m[j])^2/((dimoffset(m,0)+j*dimdelta(m,0))^2+(10^(-1))^2))
		n[j]/=test[j]
		J+=1
	while(j<(dimsize(m,0)-1))
//i+=1
//while(i<(start))
end




////////////////////
Proc make_dos()
	PauseUpdate; Silent 1
	String thisdata
 	String WindowName="DOS"
 	String traces_on_graph,old_data
 	Variable i
	thisdata="data"+num2str(gv_GroupNum)
	//DoWindow  $WindowName
	//if( V_Flag== 0 )
		//Display as WindowName
		//DoWindow /C $(WindowName)
	//else
		//DoWindow  /F $(WindowName)
	//endif
	traces_on_graph=TraceNamelist("DOS",";",1)
	old_data=StringFromList(0,traces_on_graph)
	//if(WaveExists($old_data)==1)
		//removefromgraph $old_data
	//Endif
	//Showinfo
	Make/O/N=(dimsize($thisdata,1)) density_of_states
	Setscale/P x,dimoffset($thisdata,1),dimdelta($thisdata,1),""density_of_states
	density_of_states[]=0
	i=0
	Do
		density_of_states[]+=$thisdata[i][p]
		i+=1
	While(i<dimsize($thisdata,0))
	density_of_states[]/=dimsize($thisdata,0)
	//Appendtograph density_of_states
	//DoWindow  /F dataploter
End
//////////////////////////////////////////////////////////////////
Proc extractdatafromdos()
	string sts
	gv_GroupNum=1
	Show_dos()
	display density_of_states
	do
		sts="sts"+num2str(gv_GroupNum)
		make_dos()
		duplicate/o density_of_states $sts
		gv_GroupNum+=1
	while(gv_GroupNum<(dimsize(file_name,0)))
end
//////////////////////////////////////////////////////

//////////////////////////////////////////////////////
Function ButtonProc_xplusall(ctrlName) : ButtonControl
	String ctrlName
	Execute " rescalex_plus()"
	end
///////////////////
Function ButtonProc_xmultisall(ctrlName) : ButtonControl
	String ctrlName
	Execute " rescalexmultiwhat()"
	end
/////////////////////////////
Proc rescalex_plus(name,num,amount)
	string name="sts"
	variable num=dimsize(file_name,0)-1
	variable amount
	string mat
	variable i
	i=1
	do
		mat=name+num2str(i)
		rescale_pi(mat,1,amount)
		i+=1
	while(i<num+1)
	print "rescalex_plus("+name+","+num2str(amount)+")"
end
////////////////////////////////////////////////////////
proc rescalexmultiwhat(name,num,amount)
	string name="sts"
	variable num=dimsize(file_name,0)-1
	variable amount
	string mat
	variable i
	i=1
	do
		mat=name+num2str(i)
		renormcuts_k(mat,1,1/amount)
		i+=1
	while(i<num+1)
//print "rescalexmultiwhat("+name+","+num2str(amount)+")"
end
/////////////////////////////////////////////////////////
Function ButtonProc_legend_dIdV_vs_V(ctrlName) : ButtonControl
	String ctrlName
	PauseUpdate
	Silent 1
	Label left "\\Z20\F'times'dI/dV (a.u.)";DelayUpdate
	Label bottom "\\Z20\F'times'Sample Bias\M\F'times'\Z20 (meV)"
End
////////////
Function ButtonProc_sizewaterfall(ctrlName) : ButtonControl
	String ctrlName
	PauseUpdate
	Silent 1

	modifygraph width=200, height=500
	modifygraph width=0, height=0
	modifygraph lsize=2
	ModifyGraph mirror=2
	ModifyGraph tick=2
End

////////////////////////
Function ButtonProc_sizeintenmap(ctrlName) : ButtonControl
	String ctrlName
	PauseUpdate
	Silent 1

	modifygraph width=250, height=500
	modifygraph width=0, height=0
	modifygraph lsize=2
	ModifyGraph mirror=2
	ModifyGraph tick=2
End

////////////////////////////////////////////////////////
Function ButtonProc_sizedos(ctrlName) : ButtonControl
	String ctrlName
	PauseUpdate
	Silent 1

	modifygraph lsize=1
	ModifyGraph mirror=2
	ModifyGraph tick=2
	//Label left "\\Z20\F'times'dI/dV (a.u.)";DelayUpdate
	//Label bottom "\\Z20\F'times'Sample Bias\M\F'times'\Z20 (meV)"
   //Label left "\\Z20\\F'times'dI/dV  (2e\\S2\\M\\Z20/h \\F'arial'\\Z12X\\Z20\\F'times'10\\S-3\\M\\Z20)"
   //Label bottom "\\Z20\\F'times'I\\B\\Z20t\\M\\Z20/V\\B\\Z20s\\M\\Z20  (2e\\S2\\M\\Z20/h \\F'arial'\\Z12X\\Z20\\F'times'10\\S-3\\M\\Z20)"

	Label left "\\Z20\\F'times'dI/dV  (2e\\S2\\M\\Z20/h)"
	Label bottom "\\Z20\\F'times'I\\B\\Z20t\\M\\Z20/V\\B\\Z20s\\M\\Z20  (2e\\S2\\M\\Z20/h)"

	modifygraph width=300, height=300
	modifygraph width=0, height=0

End

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
Function ButtonProc_sizemapauto(ctrlName) : ButtonControl
	String ctrlName
	PauseUpdate
	Silent 1
	String wn =winname(0,1)
	ModifyGraph width=300,height=300
	ModifyGraph margin(right)=86;
	ColorScale/C/N=text0/A=LC/X=101/Y=0/F=0 frame=0.00,image=$tpw()
	ModifyImage $tpw() ctab= {*,*,:Packages:NewColortable:Biploar_matlab,0}
	Dowindow/F $wn
	drawAction delete
	variable lenx = (dimsize($tpw(),0)-1)*dimdelta($tpw(),0)//+dimoffset($tpw(),0)
	variable leny = (dimsize($tpw(),1)-1)*dimdelta($tpw(),1)//+dimoffset($tpw(),1)
	//print lenx
	//print leny
	Dowindow/F $wn
	variable x1,x2,lenbar1,lenbar
	x1 = 0.75*lenx+dimoffset($tpw(),0)
	lenbar1 = round(0.2*lenx)
	if(lenbar1 > 10)
		lenbar = lenbar1+(round(lenbar1/10)-lenbar1/10)*10
	else
		lenbar = lenbar1
	endif
	X2 = 0.75*lenx+lenbar+dimoffset($tpw(),0)

	SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),linethick= 4.00
	DrawLine x1,0.06*leny+dimoffset($tpw(),1),x2,0.06*leny+dimoffset($tpw(),1)
	//print ">>>>>>>>>>>>>>>>>>>>>>>>"
	//print x1
	//print x2
	//print 0.06*leny+dimoffset($tpw(),1)
	//print 0.06*leny+dimoffset($tpw(),1)

	ModifyGraph noLabel=2
	ModifyGraph axThick=0

	string textv =num2str(round(lenbar))+" nm"
	SetDrawEnv xcoord= bottom,ycoord= left,textrgb= (65535,65535,65535),fstyle= 1,fsize= 20,textxjust= 1,textyjust= 1
	DrawText 0.85*lenx+dimoffset($tpw(),0),0.105*leny+dimoffset($tpw(),1),textv
	//modifygraph lsize=1
	//ModifyGraph mirror=2
	//ModifyGraph tick=2
	//ModifyGraph noLabel=2,axThick=2
	//modifygraph width=300, height=3000
	//modifygraph lsize=1
	//ModifyGraph mirror=2
	//ModifyGraph tick=2
	//Label left "\\Z20\F'times'dI/dV (a.u.)";DelayUpdate
	//Label bottom "\\Z20\F'times'Sample Bias\M\F'times'\Z20 (meV)"
	//modifygraph width=300, height=300
	//modifygraph width=0, height=0
End
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
Function ButtonProc_sizecurvenone(ctrlName) : ButtonControl
	String ctrlName
	PauseUpdate
	Silent 1
	string winn =winname(0,1)
	ModifyGraph axThick=0,noLabel=2
	Dowindow/F $winn
	drawAction delete
	//modifygraph lsize=1
	//ModifyGraph mirror=2
	//ModifyGraph tick=2
	//ModifyGraph noLabel=2,axThick=2
	//modifygraph width=300, height=3000
	//modifygraph lsize=1
	//ModifyGraph mirror=2
	//ModifyGraph tick=2
	//Label left "\\Z20\F'times'dI/dV (a.u.)";DelayUpdate
	//Label bottom "\\Z20\F'times'Sample Bias\M\F'times'\Z20 (meV)"
	//modifygraph width=300, height=300
	//modifygraph width=0, height=0
End
Function ButtonProc_sizecurve(ctrlName) : ButtonControl
	String ctrlName
	PauseUpdate
	Silent 1

	//modifygraph lsize=1
	ModifyGraph mirror=2
	ModifyGraph tick=2
	ModifyGraph noLabel=2,axThick=2
	//modifygraph width=300, height=3000
	//modifygraph lsize=1
	//ModifyGraph mirror=2
	//ModifyGraph tick=2
	//Label left "\\Z20\F'times'dI/dV (a.u.)";DelayUpdate
	//Label bottom "\\Z20\F'times'Sample Bias\M\F'times'\Z20 (meV)"
	//modifygraph width=300, height=300
	//modifygraph width=0, height=0
	//** Error message, no stop but Continuing execution
		String msg
		Variable err
		msg=GetErrMessage(GetRTError(0),3);
		err=GetRTError(1)
		if (err != 0)
			//Print "Error in Demo: " + msg
			//Print "Continuing execution"
		endif
End

Function ButtonProc_sizecurvelableon(ctrlName) : ButtonControl
	String ctrlName
	PauseUpdate
	Silent 1
	ModifyGraph noLabel=0
	//modifygraph lsize=1
	//ModifyGraph mirror=2
	//ModifyGraph tick=2
	//ModifyGraph noLabel=2,axThick=2
	//modifygraph width=300, height=3000
	//modifygraph lsize=1
	//ModifyGraph mirror=2
	//ModifyGraph tick=2
	//Label left "\\Z20\F'times'dI/dV (a.u.)";DelayUpdate
	//Label bottom "\\Z20\F'times'Sample Bias\M\F'times'\Z20 (meV)"
	//modifygraph width=300, height=300
	//modifygraph width=0, height=0
End

Function ButtonProc_sizecurveplan(ctrlName) : ButtonControl
	String ctrlName
	PauseUpdate
	Silent 1
	ModifyGraph width={Plan,1,bottom,left}
	//ModifyGraph noLabel=0
	//modifygraph lsize=1
	//ModifyGraph mirror=2
	//ModifyGraph tick=2
	//ModifyGraph noLabel=2,axThick=2
	//modifygraph width=300, height=3000
	//modifygraph lsize=1
	//ModifyGraph mirror=2
	//ModifyGraph tick=2
	//Label left "\\Z20\F'times'dI/dV (a.u.)";DelayUpdate
	//Label bottom "\\Z20\F'times'Sample Bias\M\F'times'\Z20 (meV)"
	//modifygraph width=300, height=300
	//modifygraph width=0, height=0
End

Function ButtonProc_sizecurveauto(ctrlName) : ButtonControl
	String ctrlName
	PauseUpdate
	Silent 1
	ModifyGraph width=0,height=0
	//ModifyGraph noLabel=0
	//modifygraph lsize=1
	//ModifyGraph mirror=2
	//ModifyGraph tick=2
	//ModifyGraph noLabel=2,axThick=2
	//modifygraph width=300, height=3000
	//modifygraph lsize=1
	//ModifyGraph mirror=2
	//ModifyGraph tick=2
	//Label left "\\Z20\F'times'dI/dV (a.u.)";DelayUpdate
	//Label bottom "\\Z20\F'times'Sample Bias\M\F'times'\Z20 (meV)"
	//modifygraph width=300, height=300
	//modifygraph width=0, height=0
End

Function ButtonProc_sizecurverect(ctrlName) : ButtonControl
	String ctrlName
	PauseUpdate
	Silent 1
	Modifygraph width=250, height=450	//ModifyGraph noLabel=0
	//modifygraph lsize=1
	//ModifyGraph mirror=2
	//ModifyGraph tick=2
	//ModifyGraph noLabel=2,axThick=2
	//modifygraph width=300, height=3000
	//modifygraph lsize=1
	//ModifyGraph mirror=2
	//ModifyGraph tick=2
	//Label left "\\Z20\F'times'dI/dV (a.u.)";DelayUpdate
	//Label bottom "\\Z20\F'times'Sample Bias\M\F'times'\Z20 (meV)"
	//modifygraph width=300, height=300
	//modifygraph width=0, height=0
End




////////////////////////////////////////////////////////
Function ButtonProc_legend_distance_vs_V(ctrlName) : ButtonControl
	String ctrlName
	PauseUpdate
	Silent 1
	Label left "\Z20\F'times'Distance (nm)";DelayUpdate
	Label bottom "\\Z20\F'times'Sample Bias\M\F'times'\Z20 (meV)"
End
////////////////////
Function ButtonProc_Linenorm(ctrlName) : ButtonControl
	String ctrlName
	Execute "normstsline()"
	end
/////////////////////
proc normstsline(mat)/////delete a line fitted all range
	string mat="sts"
	//variable ref
	Prompt Mat,"Name of the Batch"
	//Prompt ref,"Reference Points"

	variable initialy,delta
	string mat1,mat2,mat3
	variable i
	string haha
	i=1
	haha=mat+num2str(1)
	do
		mat1=mat+num2str(i)
		mat2="fit_"+mat1
		mat3= "cutline_L"
		//initialy=$mat1[ref]
		//initialy=$haha[ref]

		CurveFit/NTHR=0 line  $mat1 /D
		duplicate/o $mat2 cutline
		interpolate2/n=(dimsize($mat1,0)) /t=1 cutline
		$mat1-=$mat3
		//delta=initialy-$mat1[ref]
		//delta=initialy-$haha[ref]

		//$mat1+=delta
		i+=1
	while (i<(dimsize(file_name,0)))
end
////////
//CurveFit/NTHR=0 line  sts1 /D
//interpolate2/n=(dimsize(sts1,0)) /t=1 fit_sts2
//sts2-=fit_sts2_L
///////////////////////////////

//proc link3dmap(num)
//variable num

//variable i,j
//string mat
//make/o/n=(dimsize(sts1,0),num) mapsts
//i=0
//do
//j=0
//do
//mat="sts"+num2str(i+1)
//mapsts[j][i]=$mat[j]
//j+=1
//while(j<dimsize(sts1,0))
//i+=1
//while(i<num)
//setscale/P x, dimoffset(sts1,0),dimdelta(sts1,0),""mapsts
//end
//////////////////////////
proc linkstsmap_P(name,startnum,num)
	string name="STS"
	variable startnum = 1
	variable num//=dimsize(file_name,0)-1
	Prompt name,"Batch name"
	Prompt num,"Total number of STSs"
	Prompt startnum,"Make map start from which STS"

	linkstsmap(name,num,startnum)
	modifygraph width=250, height=450
	modifygraph width=0, height=0
end

Function linkstsmap(name,num,startnum)
	string name
	variable num
	variable startnum

	variable i,j
	string mat,mat0
	mat0=name+num2str(1)
	wave m=$mat0
	make/o/n=(dimsize(m,0),num) mapsts
	i=0
	do
		j=0
		do
			mat=name+num2str(i+startnum)
			wave n=$mat
			mapsts[j][i]=n[j]
			j+=1
		while(j<dimsize(m,0))
		i+=1
	while(i<num)
	setscale/P x, dimoffset(m,0),dimdelta(m,0),""mapsts
	display;appendimage mapsts
	modifygraph lsize=1
	ModifyGraph mirror=2
	ModifyGraph tick=2
	ModifyImage mapsts ctab= {*,*,VioletOrangeYellow,0}
	Label left "\Z20\F'times'Distance (Å\M\F'times'\Z20)";DelayUpdate
	Label bottom "\\Z20\F'times'Sample Bias\M\F'times'\Z20 (meV)"
	modifygraph width=250, height=450
	modifygraph width=0,height=0
	print "linkstsmap_P("+name+","+num2str(num)+","+num2str(startnum)+")"
end
//////
Function linkstsmap_factor(name,num,factor)
	string name
	variable num,factor
	variable i,j
	string mat,mat0
	mat0=name+num2str(1)
	wave m=$mat0
	make/o/n=(dimsize(m,0),((2^factor)*num-2^factor+1)) mapsts
	i=0
	do
		j=0
		do
			mat=name+num2str(i+1)
			wave n=$mat
			mapsts[j][i*2^(factor)]=n[j]
			j+=1
		while(j<dimsize(m,0))
		i+=1/(2^(factor))
	while(i<num)
	setscale/P x, dimoffset(m,0),dimdelta(m,0),""mapsts
	display;appendimage mapsts
end
////////////
Proc displaymulti_factor(dataname,from,to,factor)
	string dataname="sts", datan,datam
	variable from
	variable to
	variable i,j,factor
	i=1
	display
	do
		datan=dataname+num2str(i)
		if (i<from)
		else
			appendtograph $datan
		endif
		i+=1/2^(factor)
	while(i<(to))
end
//////////////////////////////////////
Function ButtonProc_InterpSTS(ctrlName) : ButtonControl
	String ctrlName
	Execute "interpsts()"
	end

proc interpsts(name,num,factor)
	string name="sts"
	variable num
	variable factor
	Prompt num,"Total number of STSs"
	Prompt factor,"Interpolate how many times?"


	string mati,mat,dest,
	variable i
	variable j
	j=1
	do
		i=0
		do
			mati=name+num2str(i+1)
			mat=name+num2str(i+1+1/2^(j-1))
			dest=name+num2str(i+1+0.5/2^(j-1))
			duplicate/o $mati $dest
			duplicate/o $mati awave
			duplicate/o $mati bwave

			awave=$mati
			bwave=$mat
			$dest=(awave+bwave)/2
			i+=1/(2^(j-1))
		//while(i<num-1)
		while(i<num)
		j+=1
	while(j<=factor)
	displaymulti_factor(name,1,num,factor)
	linkstsmap_factor(name,num,factor)
	modifygraph width=250, height=450
	modifygraph lsize=1
	ModifyGraph mirror=2
	ModifyGraph tick=2
	ModifyImage mapsts ctab= {*,*,VioletOrangeYellow,0}
	Label left "\Z20\F'times'Distance (Å\M\F'times'\Z20)";DelayUpdate
	Label bottom "\\Z20\F'times'Sample Bias\M\F'times'\Z20 (meV)"
	ModifyGraph width=0,height=0

	killwaves awave, bwave
	print "interpsts("+name+","+num2str(num)+","+num2str(factor)+")"
end
//////
Function ButtonProc_line2p(ctrlName) : ButtonControl
	String ctrlName
	Execute "linenorm2p()"
end
//////////////////////
proc linenorm2p(mat)
	string mat
	variable a,b
	make/o/n=(dimsize($mat,0)) line2p
	setscale/p x, dimoffset($mat,0),dimdelta($mat,0),""line2p
	a=(vcsr(B)-vcsr(A))/(hcsr(B)-hcsr(A))
	b=vcsr(b)-a*hcsr(b)
	line2p=a*x+b
	$mat-=line2P
end
////////////////////////////////////
Function ButtonProc_normwavemulti(ctrlName) : ButtonControl
	String ctrlName
	Execute "normrange()"
end

proc normrange(matname,totalnum,down,up)
	string matname="sts"
	variable totalnum
	variable up, down
	Prompt matname,"name of the Batch waves"
	Prompt totalnum,"numbers of the Batch"
	Prompt down,"Norm from"
	Prompt up,"Norm to"


	string mat
	variable i
	i=0
	do
		mat=matname+num2str(i+1)
		normwave(mat,down,up)

		i+=1
	while(i<totalnum)
	print  "normrange("+matname+","+num2str(totalnum)+","+num2str(down)+","+num2str(up)+")"
end
/////////////////////////
Function ButtonProc_renameall(ctrlName) : ButtonControl
	String ctrlName
	Execute "renameall()"
	end
proc renameall(mat,mat2,suf,totalnum)
	string mat="sts"
	string mat2="stsnorm"
	string suf=""
	variable totalnum
	Prompt mat,"name of the Batch waves"
	Prompt mat2,"Change to What?"
	Prompt totalnum,"numbers of the Batch"
	Prompt suf,"If you have a suffix,Please input"

	string matt,matt2
	variable i
	i=1
	do
		matt=mat+num2str(i)+suf
		//mat2="stsnormallrangecutline"+num2str(i)
		matt2=mat2+num2str(i)
		//mat2="stsr"+num2str(i)

		rename $matt $matt2
	i+=1
	while(i<totalnum+1)
	print "renameall("+mat+","+mat2+","+suf+","+num2str(totalnum)+")"
end


///////////////////////////
Function ButtonProc_Interpoint(ctrlName) : ButtonControl
	String ctrlName
	Execute "intercurve()"
end
proc intercurve(mat,totalnum,points)
	string mat="sts"
	variable totalnum
	variable points//=dimsize(sts1,0)
	Prompt mat,"name of the Batch waves"
	Prompt totalnum,"numbers of the Batch"
	Prompt Points,"How many points do you want"

	variable i
	string matt
	i=1
	do
		matt=mat+num2str(i)
		interpolate2/n=(Points) /t=1 $matt
		i+=1
	while(i<totalnum+1)
	print "intercurve("+mat+","+num2str(totalnum)+","+num2str(points)+")"
end


///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//**********Follow part is procedure to Analyse two compositions of a topograph

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
Function ButtonProc_Isolate2C(ctrlName) : ButtonControl
	String ctrlName
	Execute "AnaTeSe()"
	end


proc AnaTeSe(mat, largemat,i)
	string mat
	string largemat
	variable i
	prompt mat, "Name of the Matrix to statistics"
	Prompt largemat,"Name of the Matrix to find Reference"
	prompt i,"Do you want make isolate Map?",popup "Yes;No"
	if(i==1)
		checkupdown($mat,$largemat)
	endif
	if(i==2)
		checkupdown2($mat,$largemat)
	endif
end

function checkupdown2(N,large)
	wave N
	wave Large
	variable i,j
	variable numup
	variable numdown
	variable mid
	variable ratioup,ratiodown
	//wavestats/Q Large
	//mid=(V_min+V_max)/2
	make/o/N=(dimsize(large,0)*dimsize(large,1)) largefindmedian
	variable pp,ii,jj
	ii=0
	pp=0
	do
		jj=0
		do
			largefindmedian[pp]=large[ii][jj]
			pp+=1
			jj+=1
		while(jj<dimsize(large,1))
		ii+=1
	while(ii<dimsize(large,0))

	mid=Medianfinder(largefindmedian)
	print "Median value is"+num2str(mid)


	numup=0
	numdown=0
	i=0
	do
		j=0
		do
			if (N[i][j]<mid)
				numdown+=1
			endif
			if(N[i][j]>mid)
				numup+=1
			endif
			if(N[i][j]==mid)
				numdown+=0.5
				numup+=0.5
			endif
			J+=1
		while(J<dimsize(N,1))
		i+=1
	while(i<dimsize(N,0))
	ratioup=numup/(numdown+numup)
	ratiodown=numdown/(numdown+numup)
	print "Up number is"
	print numup
	print "Down number is"
	print numdown
	print "Ratio up/Down is"
	print Ratioup, ratiodown
end
//////////////////////////////////////////////////
Function/D Medianfinder(w) // Returns median value of wave w
	Wave w
	//Variable x1, x2 // range of interest
	Variable result
	Duplicate/o w, tempMedianWave // Make a clone of wave
	Sort tempMedianWave, tempMedianWave // Sort clone
	SetScale/P x 0,1,tempMedianWave
	result = tempMedianWave((numpnts(tempMedianWave)-1)/2)
	KillWaves tempMedianWave
	return result
End
////////

Function checkupdown(N,large)
	wave N
	wave Large

	variable i,j
	variable numup
	variable numdown
	variable mid
	variable ratioup,ratiodown
	//wavestats/Q Large
	make/o/N=(dimsize(large,0)*dimsize(large,1)) largefindmedian
	variable pp,ii,jj
	ii=0
	pp=0
	do
		jj=0
		do
			largefindmedian[pp]=large[ii][jj]
			pp+=1
			jj+=1
		while(jj<dimsize(large,1))
		ii+=1
	while(ii<dimsize(large,0))

	mid=Medianfinder(largefindmedian)
	print "Median value is"+num2str(mid)
	duplicate/o N up
	up=0
	setscale/P x,dimoffset(N,0), dimdelta(N,0) ,"",up
	setscale/P y,dimoffset(N,1), dimdelta(N,1) ,"",up

	duplicate/o N down
	down=0
	setscale/P x,dimoffset(N,0), dimdelta(N,0), "",down
	setscale/P y,dimoffset(N,1), dimdelta(N,1) ,"",down
	numup=0
	numdown=0
	i=0
	do
		j=0
		do
			if (N[i][j]<mid)
				numdown+=1
				down[i][j]+=1
			endif
			if(N[i][j]>mid)
				numup+=1
				up[i][j]+=1
			endif
			if(N[i][j]==mid)
				numdown+=0.5
				numup+=0.5
				down[i][j]+=0.5
				up[i][j]+=0.5
			endif
			j+=1
		while(J<dimsize(N,1))
		i+=1
	while(i<dimsize(N,0))
	ratioup=numup/(numdown+numup)
	ratiodown=numdown/(numdown+numup)
	print "Up number is"
	print numup
	print "Down number is"
	print numdown
	print "Ratio up/Down is"
	print Ratioup, ratiodown
	display;appendimage up
	ModifyGraph width=300,height=300
	ModifyGraph width=0,height=0
	ModifyGraph width={Plan,1,bottom,left}
	TextBox/C/N=text0/A=LT "\\Z16High Map H/L Rtio "+num2str(Ratioup)+"/"+num2str(Ratiodown)
	display;appendimage down
	ModifyGraph width=300,height=300
	ModifyGraph width=0,height=0
	ModifyGraph width={Plan,1,bottom,left}
	TextBox/C/N=text0/A=LT "\\Z16Low Map H/L Rtio "+num2str(Ratioup)+"/"+num2str(Ratiodown)
end

///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//**********End of Analyse two compositions of a topograph

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
Function ButtonProc_Constofftheset(ctrlName) : ButtonControl//"Special"
	String ctrlName
	Execute  "offtheset()"
End
proc offtheset(mat,delta,num)
	string mat="dest"
	variable delta
	variable num
	string matt
	variable i
	i=0
	do
		matt=mat+num2str(i+1)
		Modifygraph offset($matt)={0,0+delta*(i)}
		i+=1
	while(i<num)
end
///////////////////////////
Function ButtonProc_duplicatepart(ctrlName) : ButtonControl
	String ctrlName
	Execute "duplicatpart()"
	end
proc duplicatpart(mat,mat2,suf,x1,x2,totalnum)
	string mat="sts"
	string mat2="stsnorm"
	string suf=""
	variable totalnum
	variable x1
	variable x2
	Prompt mat,"name of the Batch waves"
	Prompt mat2,"duplicate to What?"
	Prompt totalnum,"numbers of the Batch"
	Prompt suf,"If you have a suffix,Please input"
	string matt,matt2
	variable i
	i=1
	do
		matt=mat+num2str(i)+suf
		//mat2="stsnormallrangecutline"+num2str(i)
		matt2=mat2+num2str(i)
		//mat2="stsr"+num2str(i)
		duplicate/o/R=(x1,x2) $matt $matt2
		I+=1
	while(i<totalnum+1)
	print "duplicateall("+mat+","+mat2+","+suf+","+num2str(totalnum)+")"
end
///////////////////////////
Function ButtonProc_duplicateall(ctrlName) : ButtonControl
	String ctrlName
	Execute "duplicateall()"
end

Proc duplicateall(mat,mat2,suf,totalnum)
	string mat="sts"
	string mat2="stsnorm"
	string suf=""
	variable totalnum
	Prompt mat,"name of the Batch waves"
	Prompt mat2,"duplicate to What?"
	Prompt totalnum,"numbers of the Batch"
	Prompt suf,"If you have a suffix,Please input"

	string matt,matt2
	variable i
	i=1
	do
		matt=mat+num2str(i)+suf
		//mat2="stsnormallrangecutline"+num2str(i)
		matt2=mat2+num2str(i)
		//mat2="stsr"+num2str(i)

		duplicate/o $matt $matt2
		i+=1
	while(i<totalnum+1)
	print "duplicateall("+mat+","+mat2+","+suf+","+num2str(totalnum)+")"
end
///////////////////////////
Function ButtonProc_2ndDall(ctrlName) : ButtonControl
	String ctrlName
	Execute " secondDall()"
end

proc secondDall(mat,suf,totalnum,smootht)
	string mat="sts"
	string mat2="stsnorm"
	string suf=""
	variable totalnum
	variable smootht=500
	Prompt mat,"name of the Batch waves"
	//Prompt mat2,"2nd Differentiate wave name"
	Prompt totalnum,"numbers of the Batch"
	Prompt suf,"If you have a suffix,Please input"
	Prompt smootht,"How many times smooth"

	string matt,matt2
	variable i
	mat2=mat+"_2ndD_"
	i=1
	do
		matt=mat+num2str(i)+suf
		//mat2="stsnormallrangecutline"+num2str(i)
		matt2=mat2+num2str(i)
		//mat2="stsr"+num2str(i)

		duplicate/o $matt $matt2
		smooth smootht, $matt2
		differentiate $matt2
		//smooth 5, $matt2
		differentiate $matt2
		$matt2*=-1
		i+=1
	while(i<totalnum+1)
	displaymulti(mat2,1,totalnum)
end
///////////////////////////
Function ButtonProc_smoothallmatrix(ctrlName) : ButtonControl
	String ctrlName
	Execute "smoothallmatrix()"
	end
proc smoothallmatrix(total,OldM,num,box)
	Variable total//=dimsize(File_name,0)-1
	string OldM="data"
	variable num = 5
	Variable box = 5

	string mm

	variable i
	i=1
	do
		mm=OldM+num2str(i)

		SmoothMat_k23(mm,num,box)
		i+=1
	while (i< total+1)
end

///////************************************************
Function ButtonProc_smoothall(ctrlName) : ButtonControl
	String ctrlName
	Execute "smoothall()"
	end
proc smoothall(mat,totalnum,t)
	string mat="sts"
	//string mat2="stsnorm"
	//string suf=""
	variable totalnum
	variable t=2
	Prompt mat,"name of the Batch waves"
	//Prompt mat2,"Change to What?"
	Prompt totalnum,"numbers of the Batch"
	//Prompt suf,"If you have a suffix,Please input"
	Prompt t,"smooth times"

	string matt//,matt2
	variable i
	i=1
	do
		matt=mat+num2str(i)
		//mat2="stsnormallrangecutline"+num2str(i)
		//matt2=mat2+num2str(i)
		//mat2="stsr"+num2str(i)

		smooth t, $matt
		i+=1
	while(i<totalnum+1)
	print "smoothall("+mat+","+num2str(totalnum)+","+num2str(t)+")"
end

///////////////////////////
Function ButtonProc_myall(ctrlName) : ButtonControl
	String ctrlName
	Execute "myall()"
end
proc myall(mat,totalnum,t)
	string mat="sts"
	//string mat2="stsnorm"
	//string suf=""
	variable totalnum= dimsize(file_name,0)-1
	variable t=(10^12*10^4/6.8)/(7.748*10^4)
	Prompt mat,"name of the Batch waves"
	//Prompt mat2,"Change to What?"
	Prompt totalnum,"numbers of the Batch"
	//Prompt suf,"If you have a suffix,Please input"
	Prompt t,"add how much"

	string matt//,matt2
	variable i
	i=1
	do
		matt=mat+num2str(i)
		//mat2="stsnormallrangecutline"+num2str(i)
		//matt2=mat2+num2str(i)
		//mat2="stsr"+num2str(i)

		$matt*=t
		i+=1
	while(i<totalnum+1)
	print "myall("+mat+","+num2str(totalnum)+","+num2str(t)+")"
end
//////////////////////////////////////////////////
Function ButtonProc_addyall(ctrlName) : ButtonControl
	String ctrlName
	Execute "addyall()"
end

proc addyall(mat,totalnum,t)
	string mat="sts"
	//string mat2="stsnorm"
	//string suf=""
	variable totalnum
	variable t
	Prompt mat,"name of the Batch waves"
	//Prompt mat2,"Change to What?"
	Prompt totalnum,"numbers of the Batch"
	//Prompt suf,"If you have a suffix,Please input"
	Prompt t,"add how much"

	string matt//,matt2
	variable i
	i=1
	do
		matt=mat+num2str(i)
		//mat2="stsnormallrangecutline"+num2str(i)
		//matt2=mat2+num2str(i)
		//mat2="stsr"+num2str(i)

		$matt+=t
		i+=1
	while(i<totalnum+1)
	print "addyall("+mat+","+num2str(totalnum)+","+num2str(t)+")"

end
///////////
Function ButtonProc_selectlinenorm(ctrlName) : ButtonControl
	String ctrlName
	Execute "selectlinenorm()"
end

proc selectlinenorm(mat,start,endd,num)
	string mat="sts"
	variable start
	variable endd
	variable num
	Prompt mat,"name of the Batch waves"
	Prompt num,"numbers of the Batch"
	Prompt start,"start point"
	Prompt endd,"end point"


	variable i,k,b
	string matt

	i=1
	do
		matt=mat+num2str(i)
		make/o/n=(dimsize($matt,0)) line2p
		setscale/p x, dimoffset($matt,0),dimdelta($matt,0),""line2p

		k=($matt[start]-$matt[endd]) /((dimoffset($matt,0)+start*dimdelta($matt,0))-(dimoffset($matt,0)+endd*dimdelta($matt,0)))
		b=$matt[start]-k*(dimoffset($matt,0)+start*dimdelta($matt,0))
		line2p=k*x+b
		$matt-=line2P
		i+=1
	while(i<num+1)

end
////////////////////////////////////////////////////////////
Function ButtonProc_Areacurve(ctrlName) : ButtonControl
	String ctrlName
	Execute "Areacurve()"
end

proc areacurve(matt,startx,endx,num)
	string matt="sts"
	variable startx=-9999999
	variable endx=-9999999
	variable num//=dimsize(File_name,0)
	Prompt matt,"Name of the Batch"
	Prompt startx,"start x value"
	Prompt endx,"end x value"
	Prompt num,"Number of the Batch"

	variable i ,k
	string mat
	make/o/n=(num) thiswavea
	i=1
	do
		mat=matt+num2str(i)
		if (startx==-9999999)
			k=area($mat)
		else
			k=area($mat,startx,endx)
		endif
		thiswavea[i-1]=k
		i+=1
	while(i<num+1)
	display thiswavea
	print "areacurve("+matt+","+num2str(startx)+","+num2str(endx)+","+num2str(num)+")"

end
/////////////////////////////////////
/////////////////////////////////////////////////////////////////////
Function ButtonProc_summul(ctrlName) : ButtonControl
	String ctrlName
	Execute "summul()"
end

proc summul(matt,from,to)
	string matt
	variable from
	variable to
	Prompt matt,"Name of the Batch"
	Prompt from,"Start index for sum"
	Prompt to,"End index for sum"


	variable i
	string mat
	duplicate/o sts1 addsts
	addsts=0

	i=1
	do
		mat=matt+num2str(from+i-1)
		addsts+=$mat
		//print num2str(from+i-1)
		i+=1
		//print num2str(from+i-1)
	while(i<(to-from+1))
	addsts/=(to-from+1)
	display addsts
	print "summul("+matt+","+num2str(from)+","+num2str(to)+")"
end

//////////////////////
Function ButtonProc_LFuModel(ctrlName) : ButtonControl
	String ctrlName
	Execute "makeu1u2()"
	print "makeu1u2()"
end

proc makeu1u2()
	variable/G u
	variable/G d
	variable/G k
	make/o/n=1000 u1
	make/o/n=1000 u2
	make/o/n=1000 u_mod

	setscale/I x, 0,3*k,"",u1
	setscale/I x, 0,3*k,"",u2
	setscale/I x, 0,3*k,"",u_mod

	display
	appendtograph u1 u2 u_mod
	Label bottom "\\Z20\\F'times'Distance (Å\\M\\F'times'\\Z20)"
	Label left "\\Z20\\F'times'Re(u)"
	Legend/C/N=text1/J/F=0 "\\Z18\\s(u1) u1\r\\s(u2) u2\r\\s(u_mod) |u1|\\S2\\M\\Z18+ |u2|\\S2"
	ModifyGraph lsize=2
	ModifyGraph rgb(u_mod)=(0,0,0)
	ModifyGraph rgb(u2)=(0,0,65535)

	remakeu1u2()
	modifygraph width=600, height=400

	ShowTools/A arrow
	ControlBar 60
	SetVariable setvar0 title="Ef",size={100,20},value=u,proc=SetVarProc_changeu
	SetVariable setvar1 title="\F'symbol'D\B0",size={100,20},value=d,proc=SetVarProc_changegap
	SetVariable setvar2 title="\F'symbol'x\B0",size={100,20},value=k,proc=SetVarProc_changecoherence
	ModifyGraph grid(left)=1
	ModifyGraph grid(bottom)=1
	ModifyGraph grid=1,nticks(left)=20
	ModifyGraph grid=1,nticks(bottom)=20
	SetVariable setvar0 limits={-inf,inf,0.1}
	SetVariable setvar1 limits={-inf,inf,0.1}
	SetVariable setvar2 limits={-inf,inf,1}
	HideTools/A
	SetAxis/A
	ModifyGraph nticks(left)=5
	ModifyGraph nticks(bottom)=5
end

Function SetVarProc_changeu(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	execute "remakeu1u2()"
end


Function SetVarProc_changegap(ctrlName,varNum,varStr,varName) : SetVariableControl
   String ctrlName
	Variable varNum
	String varStr
	String varName
	execute "remakeu1u2()"
end

Function SetVarProc_changecoherence(ctrlName,varNum,varStr,varName) : SetVariableControl
   String ctrlName
	Variable varNum
	String varStr
	String varName
	execute "remakeu1u2()"
end

Proc remakeu1u2()
	make/o/n=1000 u1
	make/o/n=1000 u2
	make/o/n=1000 u_mod

	setscale/I x, 0,3*k,"",u1
	setscale/I x, 0,3*k,"",u2
	setscale/I x, 0,3*k,"",u_mod


	u1=bessJ(0,(u/d)*x/k)*exp(-x/k+17.778/k)
	u2=bessJ(1,(u/d)*x/k)*exp(-x/k+17.778/k)
	u_mod= (bessJ(0,(u/d)*x/k)*exp(-x/k+17.778/k))^2+(bessJ(1,(u/d)*x/k)*exp(-x/k+17.778/k))^2
end

////////////////////////////

Function ButtonProc_normwavemulti2(ctrlName) : ButtonControl
	String ctrlName
	Execute "normrange2()"
end

proc normrange2(matname,totalnum,down,up,down2,up2)
	string matname="sts"
	variable totalnum
	variable up, down
	variable up2, down2
	Prompt matname,"name of the Batch waves"
	Prompt totalnum,"numbers of the Batch"
	Prompt down,"Norm from"
	Prompt up,"Norm to"


	string mat
	variable i
	i=0
	do
		mat=matname+num2str(i+1)
		normwave_2(mat,down,up,down2,up2)
		i+=1
	while(i<totalnum)
	print "normrange2("+matname+","+num2str(totalnum),+num2str(down)+","+num2str(up)+","+num2str(down2)+","+num2str(up2)+")"
end

Proc normwave_2(name,x_from,x_to,x_from2,x_to2)
	String name
	Variable x_from=-8.05 //75
	Variable x_to=1   //885
	variable x_from2
	variable x_to2
	Prompt name,"Enter the name of the matrix"
	Prompt x_from,"Normalize from:"
	Prompt x_to,"to:"
	PauseUpdate
	Silent 1
	Variable mean_value1
   Variable mean_value2
   Variable mean_value

	mean_value1=mean($name,x_from,x_to)
	mean_value2=mean($name,x_from2,x_to2)
	mean_value=(mean_value1+mean_value2)/2
	$name[]/=mean_value
	//print "normwave_2("+name+","+num2str(x_from)+","+num2str(x_to)+","+num2str(x_from2)+","+num2str(x_to2)+")"
End
/////////////////////////////////
Function ButtonProc_sigma(ctrlName) : ButtonControl/////this proc use to evaluate the data qualities.
	String ctrlName
	Execute "findsigmaofdata()"
end

proc findsigmaofdata(mat,num,x1,x2,x3,x4)
	string mat="sts"
	variable num
	variable x1
	variable x2
	variable x3=0
	variable x4=0
	prompt mat, "Batch name"
	prompt num, "Batch number"
	prompt X1, "Range 1 startx"
	prompt X2, "Range 1 endx"
	prompt X3, "Range 2 startx"
	prompt X4, "Range 2 starty"


	string mat2,matname,mat2_2,mat2_1
	mat2_2=mat+"_ave"
	mat2_1=mat+"_mi"

	duplicateall(mat,mat2_2,"",num)
	duplicateall(mat,mat2_1,"",num)

	make/o/n=(num+1) sigma
	sigma=nan
	//variable N
	variable i
	i=1
	do
		mat2= mat+"_ave"+num2str(i)
		matname=mat2_1+num2str(i)

		smooth 600, $mat2
		$matname-=$mat2
		$matname=$matname^2
		sigma[i]=(sum($matname,x1,x2)+sum($matname,x3,x4))/round((abs(x2-x1)+abs(X4-X3))/dimdelta($matname,0))
		sigma[i]=sqrt(sigma[i])

		i+=1
	while(i<num+1)
	edit sigma
	print "findsigmaofdata("+mat+","+num2str(num)+","+num2str(x1)+","+num2str(x2)+","+num2str(x3)+","+num2str(x4)+")"
end
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

/// this procedure is written to get fit information from multipeak fiting 2.0 package.

// before use this procedure you need set datafolder to fit folder

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_savefitdata(ctrlName) : ButtonControl
	String ctrlName
	Execute "savefitdata()"
End
proc savefitdata()
	//String savedDF = GetDataFolder(1)
	//String savedDF2 = GetDataFolder(0)
	//String savedDF3 = "root:"
	//setdatafolder root:
	variable peaknumber

	duplicate/o MPF2_ResultsListWave,fitdata
	//setdatafolder
	//peaknum = dimsize(MPF2_ResultsListWave,0)
	MoveWave fitdata, root:tempsavefit
	//MoveWave fitdata,:root:tempsavefit
	setdatafolder root:
	peaknumber=dimsize(tempsavefit,0)
	variable num
	string Peakposition
	string sigma_position
	string Peakheight
	string sigma_heigt
	string Peak_area
	string  sigma_area
	string FWHM
	string sigma_FWHM
	variable size
	string ref
	ref="peakposition"+num2str(peaknumber)
	num=1
	if(exists("peakposition1")==0)
		do
			Peakposition="Peakposition"+num2str(num)
			sigma_position="sigma_position"+num2str(num)
			Peakheight ="Peakheight"+num2str(num)
			sigma_heigt="sigma_heigt"+num2str(num)
			Peak_area="Peak_area"+num2str(num)
			sigma_area="sigma_area"+num2str(num)
			FWHM="FWHM"+num2str(num)
			sigma_FWHM="sigma_FWHM"+num2str(num)


			make/o/n=1 $Peakposition $Peakheight $Peak_area $FWHM
			make/o/n=1 $sigma_position $sigma_heigt $sigma_area $sigma_FWHM
			size=1
			edit $Peakposition $sigma_position $Peakheight $sigma_heigt $Peak_area $sigma_area $FWHM $sigma_FWHM

			num+=1
		while(num<peaknumber+1)
	else
		do
			Peakposition="Peakposition"+num2str(num)
			sigma_position="sigma_position"+num2str(num)
			Peakheight ="Peakheight"+num2str(num)
			sigma_heigt="sigma_heigt"+num2str(num)
			Peak_area="Peak_area"+num2str(num)
			sigma_area="sigma_area"+num2str(num)
			FWHM="FWHM"+num2str(num)
			sigma_FWHM="sigma_FWHM"+num2str(num)

			size=dimsize(peakposition1,0)
			Redimension/N=(size+1) $Peakposition $Peakheight $Peak_area $FWHM $sigma_position $sigma_heigt $sigma_area $sigma_FWHM
			num+=1
		while(num<peaknumber+1)
	endif




	variable i,j,k

	i=size-1
	num=1
	do

		Peakposition="Peakposition"+num2str(num)
		sigma_position="sigma_position"+num2str(num)
		Peakheight ="Peakheight"+num2str(num)
		sigma_heigt="sigma_heigt"+num2str(num)
		Peak_area="Peak_area"+num2str(num)
		sigma_area="sigma_area"+num2str(num)
		FWHM="FWHM"+num2str(num)
		sigma_FWHM="sigma_FWHM"+num2str(num)

		$Peakposition[i]=str2num(tempsavefit[num-1][2])

		tempsavefit[num-1][3]=replacestring("+/- ",tempsavefit[num-1][3],"")
		$sigma_position[i]=str2num(tempsavefit[num-1][3])

		$Peakheight[i]=str2num(tempsavefit[num-1][4])

		tempsavefit[num-1][5]=replacestring("+/- ",tempsavefit[num-1][5],"")
		$sigma_heigt[i]=str2num(tempsavefit[num-1][5])

		$Peak_area[i]=str2num(tempsavefit[num-1][6])


		tempsavefit[num-1][7]=replacestring("+/- ",tempsavefit[num-1][7],"")
		$sigma_area[i]=str2num(tempsavefit[num-1][7])

		$FWHM[i]=str2num(tempsavefit[num-1][8])

		tempsavefit[num-1][9]=replacestring("+/- ",tempsavefit[num-1][9],"")
		$sigma_FWHM[i]=str2num(tempsavefit[num-1][9])

		num+=1
	while(num<peaknumber+1)
	killwaves tempsavefit
	print "savefitdata()"
	print "setdatafolder root:packages:multipeakfit2:MPF_setfolder_"
end
//////////////////////////
///////////////////////////////////////////////////////////////////////////
proc savefitdata2()//single
	//String savedDF = GetDataFolder(1)
	//String savedDF2 = GetDataFolder(0)
	//String savedDF3 = "root:"
	//setdatafolder root:
	variable peaknumber

	duplicate/o MPF2_ResultsListWave,fitdata
	//setdatafolder
	//peaknum = dimsize(MPF2_ResultsListWave,0)
	MoveWave fitdata, root:tempsavefit
	//MoveWave fitdata,:root:tempsavefit
	setdatafolder root:
	peaknumber=dimsize(tempsavefit,0)
	variable num
	string Peakposition
	string sigma_position
	string Peakheight
	string sigma_heigt
	string Peak_area
	string  sigma_area
	string FWHM
	string sigma_FWHM

	num=1
	do
		Peakposition="Peakposition"+num2str(num)
		sigma_position="sigma_position "+num2str(num)
		Peakheight ="Peakheight "+num2str(num)
		sigma_heigt="sigma_heigt"+num2str(num)
		Peak_area="Peak_area"+num2str(num)
		sigma_area="sigma_area"+num2str(num)
		FWHM="FWHM"+num2str(num)
		sigma_FWHM="sigma_FWHM"+num2str(num)

		make/o/n=1 $Peakposition $Peakheight $Peak_area $FWHM
		make/o/t/n=1 $sigma_position $sigma_heigt $sigma_area $sigma_FWHM

		num+=1
	while(num<peaknumber+1)

	variable i,j,k

	i=0
	num=1
	do

		Peakposition="Peakposition"+num2str(num)
		sigma_position="sigma_position "+num2str(num)
		Peakheight ="Peakheight "+num2str(num)
		sigma_heigt="sigma_heigt"+num2str(num)
		Peak_area="Peak_area"+num2str(num)
		sigma_area="sigma_area"+num2str(num)
		FWHM="FWHM"+num2str(num)
		sigma_FWHM="sigma_FWHM"+num2str(num)

		$Peakposition[i]=str2num(tempsavefit[num-1][2])
		$sigma_position[i]=tempsavefit[num-1][3]
		$Peakheight[i]=str2num(tempsavefit[num-1][4])
		$sigma_heigt[i]=tempsavefit[num-1][5]
		$Peak_area[i]=str2num(tempsavefit[num-1][6])
		$sigma_area[i]=tempsavefit[num-1][7]
		$FWHM[i]=str2num(tempsavefit[num-1][8])
		$sigma_FWHM[i]=tempsavefit[num-1][9]
		edit $Peakposition $sigma_position $Peakheight $sigma_heigt $Peak_area $sigma_area $FWHM $sigma_FWHM
		num+=1
	while(num<peaknumber+1)
	killwaves tempsavefit

end
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Layoutmap(ctrlName) : ButtonControl
	String ctrlName
	Execute "layoutmap()"
end

proc layoutmap(select,matinput,times,box,size)
	variable select
	string matinput="data"
	variable times=5
	variable box=5
	variable size
	prompt select, "Mode",popup"Map;Atomic"
	prompt matinput, "Name"
	prompt times, "Smooth times"
	prompt Box, "Smooth Box"
	prompt Size, "Map Size"


	if (select==1)
		string mat1,mat0,mat2,mat3
		mat0=matinput+"_rot180"
		mat1=mat0+"VS"
		mat2=mat1+"HS"
		mat3=matinput+"_layout"


		rot2d_pi2(matinput,180,0,0,10)
		smoothmat_K2(mat0,times,box,1)
		smoothmat_K2(mat1,times,box,2)

		duplicate/o $mat2 $mat3
		display; appendimage $mat3
		ModifyImage $mat3 ctab= {*,*,Rainbow,1}
		modifygraph width=300,height=300
		modifygraph width=0,height=0
		ModifyGraph width={Plan,1,bottom,left}
		SetScale/I x 0,size,"", $mat3
		SetScale/I y 0,size,"", $mat3
		//Label left "\\Z18\\F'times'Size (nm)"
		//Label Bottom "\\Z18\\F'times'Size (nm)"
		//modifygraph lsize=1
		Label left "\\Z13\\F'times'Size (nm)"
		Label Bottom "\\Z13\\F'times'Size (nm)"
	else
		string mat1,mat0,mat2,mat3
		mat0=matinput+"_rot180"
		//mat1=mat0+"VS"
		//mat2=mat1+"HS"
		mat3=matinput+"_layout"


		rot2d_pi2(matinput,180,0,0,1)
		//smoothmat_K2(mat0,5,5,1)
		//smoothmat_K2(mat1,5,5,2)

		duplicate/o $mat0 $mat3
		display; appendimage $mat3
		//ModifyImage $mat3 ctab= {0.031253,0.15673,Rainbow,1}
		ModifyImage $mat3 ctab= {*,*,Mud,0}
		modifygraph width=300,height=300
		modifygraph width=0,height=0
		ModifyGraph width={Plan,1,bottom,left}
		SetScale/I x 0,size,"", $mat3
		SetScale/I y 0,size,"", $mat3
		Label left "\\Z13\\F'times'Size (nm)"
		Label Bottom "\\Z13\\F'times'Size (nm)"
	endif
	print "layoutmap("+num2str(select)+","+matinput+","+num2str(times)+","+num2str(box)+","+num2str(size)+")"
end




Proc rot2d_pi2(mat,angle,px,py,qualityfactor)
	String mat
	Variable angle
	Variable px=0
	Variable py=0
	Variable qualityfactor=10
	Prompt mat,"Enter the name of the matrix"
	Prompt angle,"Enter the rotation angle (degrees, clockwise)"
	Prompt px,"Enter the x value of the pivot point"
	Prompt py,"Enter the y value of the pivot point"
	Prompt qualityfactor,"Enter the quality factor"
	Pauseupdate; silent 1
	Variable x_0,x_last,delta_x,y_0,y_last,delta_y,total_x,total_y
	Variable new_xoffset,new_xlast,new_yoffset,new_ylast
	Variable top,bottom,left,right
	Variable newsize_x,newsize_y
	Variable new_delta
	Variable valuex,valuey
	Variable oldx,oldy
	Variable i,j
	String nnewmat,c_mat
	nnewmat=mat+"_"+"rot"+num2str(angle)
	x_0=dimoffset($mat,0)
	y_0=dimoffset($mat,1)
	delta_x=dimdelta($mat,0)
	delta_y=dimdelta($mat,1)
	total_x=dimsize($mat,0)
	total_y=dimsize($mat,1)
	x_last=x_0+delta_x*(total_x-1)
	y_last=y_0+delta_y*(total_y-1)
	//Find the borders of the new matrix
	i=0
	Do
		c_mat="cmat"+num2str(i)
		Make/O/N=2 $c_mat
		i+=1
	While(i<4)
	cmat2[0]=(x_last-px)*cos(angle*Pi/180)+(y_last-py)*sin(angle*Pi/180)+px		//upper right
	cmat2[1]=-(x_last-px)*sin(angle*Pi/180)+(y_last-py)*cos(angle*Pi/180)+py
	cmat1[0]=(x_last-px)*cos(angle*Pi/180)+(y_0-py)*sin(angle*Pi/180)+px		//bottom right
	cmat1[1]=-(x_last-px)*sin(angle*Pi/180)+(y_0-py)*cos(angle*Pi/180)+py
	cmat3[0]=(x_0-px)*cos(angle*Pi/180)+(y_last-py)*sin(angle*Pi/180)+px		//upper left
	cmat3[1]=-(x_0-px)*sin(angle*Pi/180)+(y_last-py)*cos(angle*Pi/180)+py
	cmat0[0]=(x_0-px)*cos(angle*Pi/180)+(y_0-py)*sin(angle*Pi/180)+px			//bottom left
	cmat0[1]=-(x_0-px)*sin(angle*Pi/180)+(y_0-py)*cos(angle*Pi/180)+py
	new_xoffset=cmat0[0]
	new_xlast=cmat0[0]
	new_yoffset=cmat0[1]
	new_ylast=cmat0[1]
	i=1
	Do
		c_mat="cmat"+num2str(i)
		If($c_mat[0]<new_xoffset)
			new_xoffset=$c_mat[0]
		Endif
		If($c_mat[0]>new_xlast)
			new_xlast=$c_mat[0]
		Endif
		If($c_mat[1]<new_yoffset)
			new_yoffset=$c_mat[1]
		Endif
		If($c_mat[1]>new_ylast)
			new_ylast=$c_mat[1]
		Endif
		i+=1
	While(i<4)
	//Set the scaling of the new matrix
	new_delta=sqrt((new_xlast-new_xoffset)*(new_ylast-new_yoffset)/(total_x*total_y))/qualityfactor
	newsize_x=Round((new_xlast-new_xoffset)/new_delta)
	newsize_y=Round((new_ylast-new_yoffset)/new_delta)
	Make/O/N=(newsize_x,newsize_y) $nnewmat
	Setscale/P x,new_xoffset,new_delta,"",$nnewmat
	Setscale/P y,new_yoffset,new_delta,"",$nnewmat
	//Filling the new matrix
	func_rot2d_pi($mat,$nnewmat,angle,px,py,new_delta,delta_x,delta_y,newsize_x,newsize_y,new_xoffset,new_yoffset,x_0,x_last,y_0,y_last)
	Killwaves cmat0
	Killwaves cmat1
	Killwaves cmat2
	Killwaves cmat3
	//Display
	//Appendimage $nnewmat
	//ModifyImage $nnewmat ctab= {*,*,Terrain,1}
End


Proc SmoothMat_k2(OldM,num,box,choice)//only for Vertical smooth at the moment
	string OldM,
	variable num,box,choice
	prompt OldM,"Input the matrix Name"
	prompt num,"how many times to be smoothed"
	prompt box,"Input the box width"
	prompt choice,"choose direciton",	popup "Vertical;Horizontal;Both"
	pauseupdate
	silent 1
	string mat,mat1
	if(choice==1)
		mat=OldM+"VS"
		duplicate/o $OldM,$mat
		func_SmoothMat_k($OldM,$mat,num,box,1)
		//Display
		//Appendimage $mat
		//Showinfo
		//ModifyImage $mat ctab= {*,*,Terrain,1}
//		show2dimage(mat)
	endif
	if(choice==2)
		mat=OldM+"HS"
		duplicate/o $OldM,$mat
		func_SmoothMat_k($OldM,$mat,num,box,2)
		//Display
		//Appendimage $mat
		//Showinfo
		//ModifyImage $mat ctab= {*,*,Terrain,1}
//		show2dimage(mat)
	endif
	if(choice==3)
		mat=OldM+"BS"
		duplicate/o $OldM thistemp
		func_SmoothMat_k($OldM,thistemp,num,box,1)
		func_SmoothMat_k(thistemp,$mat,num,box,2)
		//Display
		//Appendimage $mat
		//Showinfo
		//ModifyImage $mat ctab= {*,*,Terrain,1}
//		show2dimage(mat)
	endif
end
//////////////
////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
Function ButtonProc_fixline(ctrlName) : ButtonControl
	String ctrlName
	Execute " fixline()"
	end
proc fixline()
	print "fixmapline()"
end

Function fixmapline(name)
	string name
	variable delta
	variable line
	variable start
	variable enda
	wave n=$name
	variable i
	//NVAR gv_GroupNum
	//name="data"+num2str(gv_GroupNum)
	delta=2
	line=qcsr(A)
	start=pcsr(A)
	enda=pcsr(B)
	i=start
	do
		//$name[i][line]=$name[i][line+delta]/2+$name[i][line-delta]/2
		n[i][line]=n[i][line+delta]/2+n[i][line-delta]/2
		i+=1
	while(i<enda+1)
end

////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////
Function ButtonProc_fix_map(ctrlName) : ButtonControl
	String ctrlName
	Execute " fix_map()"
end
//////////////////////////////
Proc fix_map()
	string matasd
	matasd="data"+num2str(gv_GroupNum);$matasd[pcsr(A)][qcsr(A)]=$matasd[pcsr(A)-1][qcsr(A)-1];$matasd[pcsr(B)][qcsr(B)]=$matasd[pcsr(B)-1][qcsr(B)-1]
end



///////////////////////////////////
////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
Function ButtonProc_comparea(ctrlName) : ButtonControl
	String ctrlName
	Execute " compare()"
end

proc compare(name,num,batchnum,factor)
	string name="sts"
	variable num
	variable batchnum
	variable factor=3
	Prompt name,"Batch name"
	Prompt num,"Total number of One Set"
	Prompt batchnum,"How many sets Data"
	Prompt Factor,"Interpolate times"
	string haha
	variable start
	variable i,j
	i=0
	do
		start=1+i*num
		haha="mapd"+num2str(i+1)
		interpsts2(name,num,factor,haha,start)
		modifygraph width=250, height=450
		modifygraph width=0,height=0
		modifygraph lsize=1
		ModifyGraph mirror=2
		ModifyGraph tick=2
		ModifyImage $haha ctab= {*,*,VioletOrangeYellow,0}
		Label left "\Z20\F'times'Distance (Å\M\F'times'\Z20)";DelayUpdate
		Label bottom "\\Z20\F'times'Sample Bias\M\F'times'\Z20 (meV)"
		ModifyGraph width=0,height=0
		i+=1
	while(i<batchnum)

	j=1
	do
		displaymulti2(name,j,batchnum,num)
		modifygraph width=250, height=250
		modifygraph lsize=1
		ModifyGraph mirror=2
		ModifyGraph tick=2
		Label left "\\Z20\F'times'dI/dV (a.u.)";DelayUpdate
		Label bottom "\\Z20\F'times'Sample Bias\M\F'times'\Z20 (meV)"
		ModifyGraph width=0,height=0
		color_edc()
		Legend/C/N=text0/F=0/A=LT
		j+=	1
	while(j<num+1)
	print "compare("+name+","+num2str(num)+","+num2str(batchnum)+","+num2str(factor)+")"

end
////////////////////////////////////////////////////
//Single start selectable map
proc linkstsmap_P2(name,num,haha,start)
	string name="STS"
	variable num
	string haha
	variable start
	Prompt name,"Batch name"
	Prompt num,"Total number of STSs"
	linkstsmap2(name,num,haha,start)
end

function linkstsmap2(name,num,haha,start)
	string name
	variable num
	string haha
	variable start

	variable i,j
	string mat,mat0

		mat0=name+num2str(1)
	wave m=$mat0
	make/o/n=(dimsize(m,0),num) mapsts

	i=start
	do
		j=0
		do
			mat=name+num2str(i+1)
			wave n=$mat
			mapsts[j][i-start]=n[j]
			j+=1
		while(j<dimsize(m,0))
		i+=1
	while(i<num+start)
	setscale/P x, dimoffset(m,0),dimdelta(m,0),""mapsts
	display;appendimage mapsts
	rename mapsts $haha

end


///////////////////////////////

//interpolate start selectable map
proc interpsts2(name,num,factor,haha,start)
	string name="sts"
	variable num
	variable factor
	string haha
	variable start
	Prompt num,"Total number of STSs"
	Prompt factor,"Interpolate how many times?"
	Prompt haha,"rename to what"


	string mati,mat,dest
	variable i
	variable j
	j=1
	do
		i=start
		do
			mati=name+num2str(i)
			mat=name+num2str(i+1/2^(j-1))
			dest=name+num2str(i+0.5/2^(j-1))
			duplicate/o $mati $dest
			duplicate/o $mati awave
			duplicate/o $mati bwave

			awave=$mati
			bwave=$mat
			$dest=(awave+bwave)/2
			i+=1/(2^(j-1))
		while(i<num+start)


		J+=1

	while(j<=factor)
	//displaymulti_factor(name,1,num,factor)
	linkstsmap_factor2(name,num,factor,start)
	rename mapsts $haha
	killwaves awave, bwave
end

function linkstsmap_factor2(name,num,factor,start)
	string name
	variable num,factor,start
	variable i,j
	string mat,mat0
	mat0=name+num2str(1)
	wave m=$mat0
	make/o/n=(dimsize(m,0),((2^factor)*num-2^factor+1)) mapsts
	i=start
	do
		j=0
		do
			mat=name+num2str(i)
			wave n=$mat
			mapsts[j][(i-start)*2^(factor)]=n[j]
			j+=1
		while(j<dimsize(m,0))
		i+=1/(2^(factor))
	while(i<num+start)
	setscale/P x, dimoffset(m,0),dimdelta(m,0),""mapsts
	display;appendimage mapsts
end
///////////////////////////////////////////////////////
//display equal space (num) for batchnum lines

proc displaymulti2(dataname,from,batchnum,num)
	string dataname="sts", datan,datam
	variable from
	variable batchnum
	variable i,j
	variable num
	i=1

	display
	do
		datan=dataname+num2str(i)
		if (i<from)
			i+=1
		else
			appendtograph $datan
			i+=num
		endif
	while(i<(from+num*(batchnum-1)+1))

end

////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
Function ButtonProc_interpavedata(ctrlName) : ButtonControl
	String ctrlName
	Execute " interpavedata()"
end
proc interpavedata(from, to)
	variable from
	variable to
	prompt from,"Number begin"
	prompt to,"Number end"
	variable i
	string mat,mat1,mats
	i=from
	do
		mat="data"+num2str(i)
		mat1="data"+num2str(i+1)
		mats="data"+num2str(i-1)
		$mat=$mats/2+$mat1/2
		print mat+"=("+mat1+"+"+mats+")/2"
		i+=2
	while(i<to+1)
	print "interpavedata("+num2str(from)+","+num2str(to)+")"
end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///    Reference PRL 103, 107001 (2009)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_intereractionMBS(ctrlName) : ButtonControl
	String ctrlName
	Execute " eval2()"
	end
proc eval2(I,delta,kesai,Pf)// unit nm
	variable I
	variable delta=1.8//meV
	variable kesai=10//nm
	variable Pf=0.025//(A^-1)
	prompt I,"Inter-Vortex length (nm)"
	Prompt delta,"SC gap (meV)"
	Prompt kesai,"Coherent Length (nm)"
	Prompt Pf,"Fermi Wavevector (A^-1)"
	variable E,t
	E=(sqrt(2)*delta*10^3/((pi)^(3/2)))*(exp(-I/kesai)/(sqrt(pf*10*I)))
	t=6.626*10^(-34)/ E
	make/o/n=10000 EE
	setscale/I x, 5,50,""EE
	EE=(sqrt(2)*delta*10^3/((pi)^(3/2)))*(exp(-x/kesai)/(sqrt(pf*10*x)))
	make/o/n=10000 tt
	setscale/I x, 0,850,""tt
	tt=6.626*10^(-34)/ ((sqrt(2)*1.8*10^3/((pi)^(3/2)))*(exp(-x/kesai)/(sqrt(pf*10*x))))
	print "split energy is"+num2str(E)+"mue eV"

	print "Up limit times is"+num2str(t)+"s"
	display EE
	modifygraph width=300, height=300
	Label left "\\Z20\\F'times' Split Energy (\F'symbol'm\Z20\F'times'eV)"
	Label bottom "\\Z20\\F'times' Inter-Vortex Length (nm) "
	ModifyGraph tick=2,mirror=2
	modifygraph width=0, height=0
	TextBox/C/N=text0/F=0/A=LT "\F'TImes new roman'SC Gap  "+num2str(delta)+"meV"+"\rCohenrent  "+num2str(kesai)+"nm"+"\rk\BF\M\\F'TImes new roman'  "+num2str(pf)+"A\S-1\M\F'TImes new roman'"+"\r\K(65535,0,0)InterVortex  "+num2str(I)+"nm"+"\rTime  "+num2str(t)+"s"+"\rSplit  "+num2str(E)+"\F'symbol'm\F'times'eV"
	//appendtograph/R TT
	display TT
	modifygraph width=300, height=300
	Label left "\\Z20\\F'times' Up Limit Time (s)"
	Label bottom "\\Z20\\F'times' Inter-Vortex Length (nm) "
	ModifyGraph tick=2,mirror=2
	modifygraph width=0, height=0
	TextBox/C/N=text0/F=0/A=LT "\F'TImes new roman'SC Gap  "+num2str(delta)+"meV"+"\rCohenrent  "+num2str(kesai)+"nm"+"\rk\BF\M\\F'TImes new roman'  "+num2str(pf)+"A\S-1\M\F'TImes new roman'"+"\r\K(65535,0,0)InterVortex  "+num2str(I)+"nm"+"\rTime  "+num2str(t)+"s"+"\rSplit  "+num2str(E)+"\F'symbol'm\F'times'eV"

end



//This Part procedured for QPI. (3D Map)

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_IExy(ctrlName) : ButtonControl
	String ctrlName
	Execute " mapforSTM()"
end
Proc mapforSTM(num,name,suff,start,delta)
	variable num=dimsize(File_name,0)-1 //number of cuts.
	string name="data"
	string suff=""
	variable start=400
	variable delta=-6.7227
	PROMPT num,"Number of spatial Map"
	prompt name, "Name of Map"
	Prompt suff,"For smooth data use _VSHS"
	Prompt start,"Enrgy start (meV)"
	Prompt Delta,"Energy delta (meV)"

	//Variable size=10 //length of map
	//Prompt size,"Size of Map(nm)"
	variable/G Startforrotate
	variable/G deltaforrotate

	Startforrotate=Start
	deltaforrotate=delta

	string mapname
	string firstname
	firstname=name+num2str(1)+suff
	variable i
	i=1
	make/o/n=(dimsize($firstname,0),num,dimsize($firstname,1)) mat
	//setscale/I x, 0, size,"",mat
	//setscale/I Z, 0, size,"",mat
	setscale/P x, dimoffset($firstname,0), dimdelta($firstname,0),"",mat
	setscale/P Z, dimoffset($firstname,1), dimdelta($firstname,1),"",mat
	setscale/P y, start, delta,"",mat

	do
		mapname=name+num2str(i)+suff
		mat[][i-1][]=$mapname[p][r]
		i+=1
	while(i<=num)
	duplicate/o mat mat3d
end
////////////
Function ButtonProc_ExtractSTS(ctrlName) : ButtonControl
	String ctrlName
	Execute " ExtractSTS()"
	end
Proc ExtractSTS(xpoint,ypoint,name)
	variable xpoint=pcsr(A)
	variable ypoint=qcsr(A)
	string name="mat3d"
	Prompt xpoint,"P"
	Prompt ypoint,"Q"
	Prompt name,"Name of Map"


	string  endname
	variable i
	endname="stsextraction_"+num2str(xpoint)+"_"+num2str(ypoint)
	make/o/n=(dimsize($name,1)) stspoint
	i=0
	do
		stspoint[i]=$name[xpoint][i][ypoint]
		setscale/P x,dimoffset($name,1),dimdelta($name,1),"",stspoint
		i+=1
	while(i<dimsize($name,1))
	duplicate/o stspoint $endname
	display $endname
end



//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
//This is the part of Smart displayer, include 1D curve extractor,                      //
//layer displayer and slicer on two direction                                           //
//////////////////////////////////////////////////////////////////////////////////////////
//Logic of the mat3d wave is follow the order that [0: x] [1: dI/dV] [2: y]             //
//////////////////////////////////////////////////////////////////////////////////////////
//******************IMPORTANT***********************************************************//
//   To guarantee the procedure works well, you need                                    //
//			Rescale the x and y of slices as (0,a) before do dI/dV(x,y,E)                  //
//**************************************************************************************//
//////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_2DSTS(ctrlName) : ButtonControl
	String ctrlName
	execute "makeextra()"
end

Proc makeextra()
	//Display /W=(144,71,527,485)
	//Button button1,pos={10,81},size={120,20},proc=ButtonProc_readcsr,title="Read point"
	//variable Start
	//variable delta

	variable/G Pa
	variable/G Qa
	variable/G Ea
	//variable/G Vline
	//variable/G Hline
	Variable/G npa
	Variable/G nqa
	Variable/G smt
	variable/G rotatedegree
	variable/G rotatequality
	rotatequality=1

	make/o/n=(dimsize(mat3d,0),dimsize(mat3d,2)) pointimage
	make/o/n=(dimsize(mat3d,1)) spectra
	spectra[]=mat3d[Pa][p][Qa]


	make/o/N=(dimsize(mat3d,1),dimsize(mat3d,0)) linecutH
	make/o/N=(dimsize(mat3d,1),dimsize(mat3d,2)) linecutV
	setscale/p x dimoffset(mat3d,1),dimdelta(mat3d,1),"",linecutV;
	setscale/p y dimoffset(mat3d,2),dimdelta(mat3d,2),"",linecutV
	setscale/p x dimoffset(mat3d,1),dimdelta(mat3d,1),"",linecutH;
	setscale/p y dimoffset(mat3d,0),dimdelta(mat3d,0),"",linecutH

	display; appendimage  linecutH
	ModifyGraph tick=2,mirror=2
	modifygraph width=200,height=400
	//modifygraph width=0,height=0
	Label left "\\Z20\\F'times'Distance (nm)"
	Label bottom "\\Z20\\F'times'Energy (meV)"
	ModifyImage linecutH ctab= {*,*,VioletOrangeYellow,0}

	display; appendimage  linecutV
	ModifyGraph tick=2,mirror=2
	modifygraph width=200,height=400
	//modifygraph width=0,height=0
	Label left "\\Z20\\F'times'Distance (nm)"
	Label bottom "\\Z20\\F'times'Energy (meV)"
	ModifyImage linecutV ctab= {*,*,VioletOrangeYellow,0}

	makespec()

	variable numsliceh, numslicev,ii,jj
	string numslicehnam,numslicevnam
	numsliceh=dimsize(mat3d,0)
	numslicev=dimsize(mat3d,2)
	//wavestats/Q mat3d
	colorsetedc=5

	displaymulti("stslinecutH",1,numsliceh)
	constantoffset_n(4/numsliceh,1)
	color_edc()
	ModifyGraph lsize=2
	modifygraph width=200,height=400
	//modifygraph width=0,height=0

	displaymulti("stslinecutV",1,numslicev-1)
	constantoffset_n(4/numslicev,1)
	color_edc()
	ModifyGraph lsize=2
	modifygraph width=200,height=400
	//modifygraph width=0,height=0


	display spectra
	MAKE/O/N=100 qqq;qqq=Ea; wavestats/Q spectra;setscale/I x, v_min,V_max,""qqq ;appendtograph/VERT qqq
	ModifyGraph rgb(qqq)=(0,0,0);ModifyGraph lstyle(qqq)=8
	Label bottom "\\Z20\\F'times'Sample Bias (meV)"
	Label left "\\Z20\\F'times'dI/dV (a.u.)"
	ModifyGraph tick=2,mirror=2
	ModifyGraph Height=250,width=250
	//ModifyGraph Height=0,width=0


	display; appendimage  pointimage
	Label bottom "\\Z20\\F'times'Distance (nm)"
	Label left "\\Z20\\F'times'Distance (nm)"
	ModifyGraph Height=300,width=300
	//ModifyGraph Height=0,width=0
	ModifyImage pointimage ctab= {*,*,Mud,0}
	ModifyGraph width={Plan,1,bottom,left}
	Duplicate/O pointimage mat3d_energy_plot //this is for the Pierre's build-in slicer.


	MAKE/O/N=(dimsize(mat3d,0)) hhh;hhh=dimoffset(mat3d,2)+(nqa)*dimdelta(mat3d,2);
	setscale/p x,dimoffset(mat3d,0),dimdelta(mat3d,0),"",hhh
	appendtograph hhh


	MAKE/O/N=(dimsize(mat3d,2)) vvv;vvv=dimoffset(mat3d,0)+(npa)*dimdelta(mat3d,0);
	setscale/p x,dimoffset(mat3d,2),dimdelta(mat3d,2),"",vvv
	appendtograph/VERT vvv


	ShowInfo
	Cursor /I  A pointimage 0, 0


	reextractM()
	reextractL()

	reextractlinecutH()
	reextractlinecutV()

	ShowTools/A arrow
	ControlBar 60


	SetVariable setvar0 title="P",size={100,20},value=Pa,proc=SetVarProc_changeP
	SetVariable setvar1 title="Q",size={100,20},value=Qa,proc=SetVarProc_changeQ
	SetVariable setvar2 title="E (meV)",size={100,20},value=Ea,proc=SetVarProc_changeE
	SetVariable setvar3 title="H-linecut",size={100,20},value=nqa,proc=SetVarProc_changenqa
	SetVariable setvar4 title="V-linecut",size={100,20},value=npa,proc=SetVarProc_changenpa
	SetVariable setvar5 title="Smooth",size={100,20},value=smt,proc=SetVarProc_smt
	SetVariable setvar6 title="Rotate",size={100,20},value=rotatedegree,proc=SetVarProc_rotatedegree
	SetVariable setvar7 title="Quality",size={100,20},value=rotatequality,proc=SetVarProc_rotatequality



	SetVariable setvar0 limits={0,dimsize(pointimage,0)-1,1}
	SetVariable setvar1 limits={0,dimsize(pointimage,1)-1,1}
	SetVariable setvar2 limits={-inf,inf,dimdelta(mat3d,1)}
	//If delta <0;
	//	SetVariable setvar2 limits={(dimoffset(mat3d,1)+(dimsize(mat3d,1)-1)*dimdelta(mat3d,1)),dimoffset(mat3d,1),dimdelta(mat3d,1)}
	//If delta >0
	// SetVariable setvar2 limits={dimoffset(mat3d,1),(dimoffset(mat3d,1)+(dimsize(mat3d,1)-1)*dimdelta(mat3d,1)),dimdelta(mat3d,1)}
	SetVariable setvar3 limits={0,dimsize(pointimage,1)-1,1}
	SetVariable setvar4 limits={0,dimsize(pointimage,0)-1,1}
	SetVariable setvar5 limits={0,inf,1}
	SetVariable setvar6 limits={0,360,0.5}
	SetVariable setvar7 limits={1,inf,1}

	HideTools/A
	SetAxis/A
	ModifyGraph nticks(left)=5
	ModifyGraph nticks(bottom)=5
	tilewindows/WINS=WinList("*", ";","WIN:1")/R/w=(4,0,80,80)
	autoallfigure()
End


Function SetVarProc_changeP(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	execute "reextractL()"
	execute "movecur()"
	execute "adjustline()"
End




Function SetVarProc_changeQ(ctrlName,varNum,varStr,varName) : SetVariableControl
   String ctrlName
	Variable varNum
	String varStr
	String varName
	execute "reextractL()"
	execute "movecur()"
	execute "adjustline()"
End

Function SetVarProc_changeE(ctrlName,varNum,varStr,varName) : SetVariableControl
   String ctrlName
	Variable varNum
	String varStr
	String varName
	//NVAR Ea=Ea
	execute  "reextractM()"
	execute "adjustline()"
end

Function SetVarProc_changenqa(ctrlName,varNum,varStr,varName) : SetVariableControl
   String ctrlName
	Variable varNum
	String varStr
	String varName
	//NVAR Ea=Ea
	execute  "reextractlinecutH()"
	execute "adjustlineonimageH()"
end

Function SetVarProc_changenpa(ctrlName,varNum,varStr,varName) : SetVariableControl
   String ctrlName
	Variable varNum
	String varStr
	String varName
	//NVAR Ea=Ea
	execute  "reextractlinecutV()"
	execute "adjustlineonimageV()"
end

Function SetVarProc_smt(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	execute "csn()"
end

Function SetVarProc_rotatedegree(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	execute "rotatemap()"
	execute "csn()"
end

Function SetVarProc_rotatequality(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	execute "rotatemap()"
	execute "adjustlineonimageV()"
	execute "adjustlineonimageH()"
	execute "resetvarrange()"
	execute "csn()"
end

Proc resetvarrange()

	SetVariable setvar0 limits={0,dimsize(pointimage,0)-1,rotatequality}
	SetVariable setvar1 limits={0,dimsize(pointimage,1)-1,rotatequality}
	SetVariable setvar2 limits={-inf,inf,dimdelta(mat3d,1)}
	//If delta <0;
	//	SetVariable setvar2 limits={(dimoffset(mat3d,1)+(dimsize(mat3d,1)-1)*dimdelta(mat3d,1)),dimoffset(mat3d,1),dimdelta(mat3d,1)}
	//If delta >0
	// SetVariable setvar2 limits={dimoffset(mat3d,1),(dimoffset(mat3d,1)+(dimsize(mat3d,1)-1)*dimdelta(mat3d,1)),dimdelta(mat3d,1)}
	SetVariable setvar3 limits={0,dimsize(pointimage,1)-1,rotatequality}
	SetVariable setvar4 limits={0,dimsize(pointimage,0)-1,rotatequality}
	SetVariable setvar5 limits={0,inf,1}
	SetVariable setvar6 limits={0,360,0.5}
	SetVariable setvar7 limits={1,inf,1}

end

Proc rotatemap()
	string thisstring
	string namen
	variable len


	//linecutH[][]=mat3d[q][p][nqa]
	//linecutV[][]=mat3d[npa][p][q];
	//reextractL()
	//numslicehnam()
	//numslicevnam()

	thisstring="rot"+num2str(rotatedegree)+"_Data1"
	namen="rot"+num2str(rotatedegree)+"_Data"
	rotall("data",rotatedegree,rotatequality)
	len=(dimsize($thisstring,0)-1)*dimdelta($thisstring,0)
	setscaleall(len)
	mapforSTMff(dimsize(file_name,0)-1,namen,"",Startforrotate,deltaforrotate)
	make/o/n=(dimsize(mat3d,0),dimsize(mat3d,2)) pointimage
	make/o/n=(dimsize(mat3d,1)) spectra


	make/o/N=(dimsize(mat3d,1),dimsize(mat3d,0)) linecutH
	make/o/N=(dimsize(mat3d,1),dimsize(mat3d,2)) linecutV
	setscale/p x dimoffset(mat3d,1),dimdelta(mat3d,1),"",linecutV;
	setscale/p y dimoffset(mat3d,2),dimdelta(mat3d,2),"",linecutV
	setscale/p x dimoffset(mat3d,1),dimdelta(mat3d,1),"",linecutH;
	setscale/p y dimoffset(mat3d,0),dimdelta(mat3d,0),"",linecutH
	makespec()
	reextractM()
	setscale/p x,dimoffset(mat3d,0),dimdelta(mat3d,0),"",hhh
	setscale/p x,dimoffset(mat3d,2),dimdelta(mat3d,2),"",vvv
end

Function setscaleall(len)
	variable len
	String thisstring
	String filen
	variable i
	NVAR rotatedegree=rotatedegree
	filen="file_name"
	wave ff=$filen
	i=1
	do
		thisstring="rot"+num2str(rotatedegree)+"_Data"+num2str(i)
		wave res=$thisstring
		Setscale/I x, 0, len,"",res
		Setscale/I y, 0, len,"",res
		i+=1
	while(i<(dimsize(ff,0))-1)
end



Proc csn()
	linecutH[][]=mat3d[q][p][nqa]
	linecutV[][]=mat3d[npa][p][q];
	reextractL()
	numslicehnam()
	numslicevnam()
	if (smt !=0)
		smoothfast()
		linkstsmap_PqpiH("stslinecutH",dimsize(mat3d,0))
		linkstsmap_PqpiV("stslinecutV",dimsize(mat3d,2))
		smooth smt, spectra
	endif
	if (smt ==0)
		numslicehnam()
		numslicevnam()
	endif
end

Function smoothfast()
	variable i,j
	string mat, matt
	string mat3d
	NVAR smt=smt
	mat3d="mat3d"
	wave mm=$mat3d
	i=1
	do
		matt="stslinecutH"+num2str(i)
		wave n=$matt
		smooth smt, n
	i+=1
	while(i<dimsize(mm,0)+1)

	j=1
	do
		mat="stslinecutV"+num2str(j)
		wave m=$mat
		smooth smt, m
	j+=1
	while(j<dimsize(mm,2)+1)
end


Proc adjustlineonimageH()
	MAKE/O/N=(dimsize(mat3d,0)) hhh;hhh=dimoffset(mat3d,2)+nqa*dimdelta(mat3d,2);
	setscale/p x,dimoffset(mat3d,0),dimdelta(mat3d,0),"",hhh
end

Proc adjustlineonimageV()
	MAKE/O/N=(dimsize(mat3d,2)) vvv;vvv=dimoffset(mat3d,0)+npa*dimdelta(mat3d,0);
	setscale/p x,dimoffset(mat3d,2),dimdelta(mat3d,2),"",vvv
end


Proc adjustline()
	MAKE/O/N=100 qqq;qqq=Ea; wavestats/Q spectra;setscale/I x, v_min,V_max,""qqq ;//ModifyGraph rgb(qqq)=(0,0,0);ModifyGraph lstyle(qqq)=8
end

Proc reextractlinecutH()
	make/o/N=(dimsize(mat3d,1),dimsize(mat3d,0)) linecutH;
	setscale/p x dimoffset(mat3d,1),dimdelta(mat3d,1),"",linecutH
	setscale/p y dimoffset(mat3d,0),dimdelta(mat3d,0),"",linecutH
	linecutH[][]=mat3d[q][p][nqa];
	numslicehnam()
//***********************************************
	if (smt != 0)
		linkstsmap_PqpiH("stslinecutH",dimsize(mat3d,0)) //replot linecut after smooth
	endif
//***********************************************
end

Function/Wave numslicehnam()
	variable xx
	string numslicehnam,linecutH,mat3dn
	linecutH="linecutH"
	mat3dn="mat3d"
	wave mmm=$mat3dn

	xx=1
	do
		numslicehnam="stslinecutH"+num2str(xx)
		Wave n=$numslicehnam
		wave m=$linecutH
		n[]=m[p][xx-1]
//***********************************************
		nVAR ss=smt
		if (ss !=0)
			smooth ss, n
		endif
		Variable mean_value
		mean_value=mean(n,dimOffset(n,0),dimOffset(n,0)+dimDelta(n,0)*(dimsize(n,0)-1))
		n[]/=mean_value
//***********************************************
		xx+=1
	while(xx<dimsize(mmm,0)+1)
end


Proc reextractlinecutV()
	make/o/N=(dimsize(mat3d,1),dimsize(mat3d,2)) linecutV;
	setscale/p x dimoffset(mat3d,1),dimdelta(mat3d,1),"",linecutV;
	setscale/p y dimoffset(mat3d,2),dimdelta(mat3d,2),"",linecutV
	linecutV[][]=mat3d[npa][p][q];
	numslicevnam()
//***********************************************
	if (smt != 0)
		linkstsmap_PqpiV("stslinecutV",dimsize(mat3d,2)) //replot linecut after smooth
	endif
//***********************************************
end


Function/Wave numslicevnam()
	variable xx
	string numslicevnam,linecutv,mat3dn
	linecutV="linecutV"
	mat3dn="mat3d"
	wave mmm=$mat3dn
	xx=1
	do
		numsliceVnam="stslinecutV"+num2str(xx)
		Wave n=$numslicevnam
		wave m=$linecutV
		n[]=m[p][xx-1]
//***********************************************
		nVAR ss=smt
		if (ss !=0)
			smooth ss, n
		endif
		Variable mean_value
		mean_value=mean(n,dimOffset(n,0),dimOffset(n,0)+dimDelta(n,0)*(dimsize(n,0)-1))
		n[]/=mean_value
//***********************************************
		xx+=1
	while(xx<dimsize(mmm,2)+1)
end



Proc reextractM()
	make/o/n=(dimsize(mat3d,0),dimsize(mat3d,2)) pointimage
	setscale/P x, dimoffset(mat3d,0), dimdelta(mat3d,0),"",pointimage
	setscale/P y, dimoffset(mat3d,2), dimdelta(mat3d,2),"",pointimage

	pointimage[][]=mat3d[p][round((Ea-dimoffset(mat3d,1))/dimdelta(mat3d,1))][q]

end

Proc reextractL()
	make/o/n=(dimsize(mat3d,1)) spectra
	setscale/P x,dimoffset(mat3d,1),dimdelta(mat3d,1),"",spectra
	//variable i
	//i=0
	//do
	spectra[]=mat3d[Pa][p][Qa]
	//i+=1
	//while(i<dimsize(mat3d,1))
end

proc movecur()

	Cursor /I  A pointimage dimoffset(pointimage,0)+dimdelta(pointimage,0)*pa,dimoffset(pointimage,1)+dimdelta(pointimage,1)*Qa

end
//proc Vlinecutt()
//string name1
//string stsname
//variable ii
	//make/o/N=(dimsize(mat3d,1),dimsize(mat3d,2)) Vlinecut
	//name1="Vlinecut"+num2str(Vline)
	//vlinecut[][]=mat3d[Vline][p][q]
	//display;appendimage Vlinecut
	//modifygraph width=200,height=300
	//rename vlinecut name1
	//ii=0
	//do
	//stsname="stsex"+num2str(ii+1)
	//make/N=(dimsize(Vlinecut,0))  $stsname
	//$stsname[]=vlinecut[p][ii]
	//Ii+=1
	//while(Ii<dimsize(Vlinecut,1))
	//displaymulti("stsex",1,dimsize(Vlinecut,1))

//end
//proc Hlinecutt()
	//string name2
//string stsname2
//variable ii2
	//make/o/N=(dimsize(mat3d,1),dimsize(mat3d,0)) Hlinecut
	//name2="Hlinecut"+num2str(Hline)
	//Hlinecut[][]=mat3d[q][p][Hline]
	//display;appendimage Hlinecut
	//modifygraph width=200,height=300
	//rename vlinecut name1
	//ii2=0
	//do
	//stsname="stsexH"+num2str(ii2+1)
//	make/N=(dimsize(Hlinecut,0))  $stsname
	//$stsname[]=Hlinecut[p][ii2]
	//Ii2+=1
//	while(Ii<dimsize(Hlinecut,1))
	//displaymulti("stsexH",1,dimsize(Hlinecut,1))
//end
//////////////////////////////////////////////////////////////////////////////////////////
//***********************************************
proc linkstsmap_PqpiH(name,num)
	string name
	variable num
	linkstsmapH(name,num)
end

Function linkstsmapH(name,num)
	string name
	variable num
	variable i,j
	string mat,mat0
	mat0=name+num2str(1)
	wave m=$mat0
	//make/o/n=(dimsize(m,0),num) mapsts
	String linecutH
	linecutH="linecutH"
	i=0
	do
		j=0
		do
			mat=name+num2str(i+1)
			wave n=$mat
			wave hh=$linecutH
			hh[j][i]=n[j]
			j+=1
		while(j<dimsize(m,0))
		i+=1
	while(i<num)
end


Proc linkstsmap_PqpiV(name,num)
	string name
	variable num
	linkstsmapV(name,num)
end

Function linkstsmapV(name,num)
	string name
	variable num
	variable i,j
	string mat,mat0
	mat0=name+num2str(1)
	wave m=$mat0
	//make/o/n=(dimsize(m,0),num) mapsts
	String linecutV
	linecutV="linecutV"
	i=0
	do
		j=0
		do
			mat=name+num2str(i+1)
			wave n=$mat
			wave vv=$linecutV
			vv[j][i]=n[j]
			j+=1
		while(j<dimsize(m,0))
		i+=1
	while(i<num)
end
//***********************************************
Function makespec()

	variable numsliceh, numslicev,ii,jj
	string numslicehnam,numslicevnam,mat3d
	mat3d="mat3d"
	wave mat3dn=$mat3d
	numsliceh=dimsize(mat3dn,0)
	numslicev=dimsize(mat3dn,2)

	ii=1
	do
		numslicehnam="stslinecutH"+num2str(ii)
		make/o/N=(dimsize(mat3dn,1)) $numslicehnam
		wave numslicehnamn=$numslicehnam
		numslicehnamn=nan
		setscale/p x dimoffset(mat3dn,1),dimdelta(mat3dn,1),"",numslicehnamn;
		ii+=1
	while(ii<numsliceh+1)

	jj=1
	do
		numslicevnam="stslinecutv"+num2str(jj)
		make/o/N=(dimsize(mat3dn,1)) $numslicevnam
		wave numslicevnamn=$numslicevnam
		numslicevnamn=nan
		setscale/p x dimoffset(mat3dn,1),dimdelta(mat3dn,1),"",numslicevnamn;
		jj+=1
	while(jj<numslicev+1)
end

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
// END the QPI part
//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

Function ButtonProc_rotall(ctrlName) : ButtonControl
	String ctrlName
	Execute " rotall()"
end

Proc rotall(name,angle,Accuracy)
	string name="data"
	variable angle
	variable Accuracy=30
	prompt name,"Name of Batch"
	prompt angle,"clockwise"
	Prompt Accuracy,"Times"
	variable i
	string mat
	i=0
	do
		mat=name+num2str(i+1)
		rot2d_pimf(MAT,angle,0,0,Accuracy)
		i+=1
	while(i<(dimsize(file_name,0))-1)
end

Proc rot2d_pim(mat,angle,px,py,qualityfactor)
	String mat
	Variable angle
	Variable px=0
	Variable py=0
	Variable qualityfactor=10
	Prompt mat,"Enter the name of the matrix"
	Prompt angle,"Enter the rotation angle (degrees, clockwise)"
	Prompt px,"Enter the x value of the pivot point"
	Prompt py,"Enter the y value of the pivot point"
	Prompt qualityfactor,"Enter the quality factor"
	Pauseupdate; silent 1
	Variable x_0,x_last,delta_x,y_0,y_last,delta_y,total_x,total_y
	Variable new_xoffset,new_xlast,new_yoffset,new_ylast
	Variable top,bottom,left,right
	Variable newsize_x,newsize_y
	Variable new_delta
	Variable valuex,valuey
	Variable oldx,oldy
	Variable i,j
	String nnewmat,c_mat
	nnewmat="rot"+num2str(angle)+"_"+mat
	x_0=dimoffset($mat,0)
	y_0=dimoffset($mat,1)
	delta_x=dimdelta($mat,0)
	delta_y=dimdelta($mat,1)
	total_x=dimsize($mat,0)
	total_y=dimsize($mat,1)
	x_last=x_0+delta_x*(total_x-1)
	y_last=y_0+delta_y*(total_y-1)
	//Find the borders of the new matrix
	i=0
	Do
		c_mat="cmat"+num2str(i)
		Make/O/N=2 $c_mat
		i+=1
	While(i<4)
	cmat2[0]=(x_last-px)*cos(angle*Pi/180)+(y_last-py)*sin(angle*Pi/180)+px		//upper right
	cmat2[1]=-(x_last-px)*sin(angle*Pi/180)+(y_last-py)*cos(angle*Pi/180)+py
	cmat1[0]=(x_last-px)*cos(angle*Pi/180)+(y_0-py)*sin(angle*Pi/180)+px		//bottom right
	cmat1[1]=-(x_last-px)*sin(angle*Pi/180)+(y_0-py)*cos(angle*Pi/180)+py
	cmat3[0]=(x_0-px)*cos(angle*Pi/180)+(y_last-py)*sin(angle*Pi/180)+px		//upper left
	cmat3[1]=-(x_0-px)*sin(angle*Pi/180)+(y_last-py)*cos(angle*Pi/180)+py
	cmat0[0]=(x_0-px)*cos(angle*Pi/180)+(y_0-py)*sin(angle*Pi/180)+px			//bottom left
	cmat0[1]=-(x_0-px)*sin(angle*Pi/180)+(y_0-py)*cos(angle*Pi/180)+py
	new_xoffset=cmat0[0]
	new_xlast=cmat0[0]
	new_yoffset=cmat0[1]
	new_ylast=cmat0[1]
	i=1
	Do
		c_mat="cmat"+num2str(i)
		If($c_mat[0]<new_xoffset)
			new_xoffset=$c_mat[0]
		Endif
		If($c_mat[0]>new_xlast)
			new_xlast=$c_mat[0]
		Endif
		If($c_mat[1]<new_yoffset)
			new_yoffset=$c_mat[1]
		Endif
		If($c_mat[1]>new_ylast)
			new_ylast=$c_mat[1]
		Endif
		i+=1
	While(i<4)
	//Set the scaling of the new matrix
	new_delta=sqrt((new_xlast-new_xoffset)*(new_ylast-new_yoffset)/(total_x*total_y))/qualityfactor
	newsize_x=Round((new_xlast-new_xoffset)/new_delta)
	newsize_y=Round((new_ylast-new_yoffset)/new_delta)
	Make/O/N=(newsize_x,newsize_y) $nnewmat
	Setscale/P x,new_xoffset,new_delta,"",$nnewmat
	Setscale/P y,new_yoffset,new_delta,"",$nnewmat
	//Filling the new matrix
	func_rot2d_pi($mat,$nnewmat,angle,px,py,new_delta,delta_x,delta_y,newsize_x,newsize_y,new_xoffset,new_yoffset,x_0,x_last,y_0,y_last)
	Killwaves cmat0
	Killwaves cmat1
	Killwaves cmat2
	Killwaves cmat3
	//Display
	//Appendimage $nnewmat
	//ModifyImage $nnewmat ctab= {*,*,Terrain,1}
End
/////////////
Function ButtonProc_extracnumfromstr(ctrlName) : ButtonControl
	String ctrlName
	Execute " extracnumfromstr()"
	end

Proc extracnumfromstr(head,volt)
	string head="height1-"
	variable volt=5
	prompt head,"Head String to eliminate"
	prompt volt,"Set point volatage (meV)"
	//make/T/n=(dimsize(file_name,0)-1) stringwave
	duplicate/o file_name filename
	make/o/n=(dimsize(file_name,0)-1) current

	variable i
	i=1
	do
		filename[i]=replacestring(head,filename[i],"")
		current[i-1]=str2num(filename[i])
		i+=1
	while(i<dimsize(file_name,0))
	duplicate/o current sigmac
	sigmac=current*10^-12*10^12*100/(7.748*10^4*volt)
	edit filename current sigmac
end
///////////////////
Function ButtonProc_exwidth(ctrlName) : ButtonControl
	String ctrlName
	Execute " exwidth()"
end

Proc exwidth(num,mat,st,ed)
	variable num
	string mat="sts"
	variable st=pcsr(A)
	variable ed=pcsr(B)
	prompt num,"number of spectra"
	prompt mat,"name of Batch"
	prompt st,"From (point)"
	prompt ed,"To (point)"

	string matname
	string fitname
	variable i
	make/o/n=(num) widthappr
	make/o/n=(num) widthsigma

	i=1
	do
		matname=mat+num2str(i)
		fitname="fit_"+matname
		CurveFit/Q/M=2/W=0 gauss, $matname[st,ed]/D
		widthappr[i-1]=2*sqrt(ln(2))*W_coef[3]
		widthsigma[i-1]=W_sigma[3]
		display $matname $fitname
		ModifyGraph rgb($fitname)=(0,0,0)
		i+=1
	while(i<num+1)

	edit widthappr widthsigma
	display widthappr
	ErrorBars widthappr Y,wave=(widthsigma,widthsigma)
end
/////////////////////
Function ButtonProc_autoclbzero(ctrlName) : ButtonControl
	String ctrlName
	Execute " autoclbzero()"
end

proc autoclbzero(mat,num,left,right)
	string mat="sts"
	variable num =(dimsize(file_name,0)-1)
	variable left=pcsr(A)
	variable right=pcsr(B)
	Prompt mat,"name of Batch"
	Prompt num,"Number of Batch"
	Prompt left,"Fit From (Point)"
	Prompt right,"Fit To (Point)"
	variable i
	string matuse,dest
	variable height, pp
	make/o/N=(num) peakpclb
	make/o/N=(num) peakhclb
	i=1
	do
		matuse=mat+num2str(i)
		dest=mat+"CL"+num2str(i)
		CurveFit/Q/M=2/W=0 gauss, $matuse[left,right]/D
		height=W_coef[1]+W_coef[0]
		pp=W_coef[2]
		peakhclb[i-1]=height
		//wavestats/Q $matuse
		peakpclb[i-1]=W_coef[2]
		duplicate/o $matuse $dest
		setscale/P x,(dimoffset($matuse,0)-W_coef[2]),dimdelta($matuse,0),"",$dest
		i+=1
	while(i<num+1)
	edit  peakpclb peakhclb
	display peakpclb
	display peakhclb
	displaymulti(mat+"CL",1,num)
end
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
Function ButtonProc_addper(ctrlName) : ButtonControl
	String ctrlName
	Execute "addper()"
end
proc addper(mat,per,fromz,size)
	string mat="E3_"
	variable per=4
	variable fromz=0
	variable size=256
	prompt mat,"Source name"
	prompt per,"add how much curves"
	prompt fromz,"Source begin number"
	prompt size,"Numbers of source curve "

	variable i,j
	variable from, to
	string dest
	i=0
	j=1
	do
		from=fromz+i
		to=from+per-1
		dest="dest"+num2str(j)
		summul2(mat,from,to,mat)
		duplicate/o addsts $dest
		j+=1
		i+=per
		print "From "+num2str(from)+"  to  "+num2str(to)+"   i "+num2str(i)+"  name(j) "+num2str(j)
		//print to
		//print i
	while(i<size)
end

proc summul2(matt,from,to,name)
	string matt
	variable from
	variable to
	string name
	Prompt matt,"Name of the Batch"
	Prompt from,"Start index for sum"
	Prompt to,"End index for sum"

	string na
	variable i
	string mat
	na=name+num2str(1)
	duplicate/o $na addsts
	addsts=0

	i=1
	do
		mat=matt+num2str(from+i-1)
		addsts+=$mat
		//print num2str(from+i-1)
		i+=1
		//print num2str(from+i-1)
	while(i<(to-from+1))
	addsts/=(to-from+1)
	//display addsts
	//print "summul("+matt+","+num2str(from)+","+num2str(to)+")"
end

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////

Function ButtonProc_shift(ctrlName) : ButtonControl
	String ctrlName
	Execute " hshift()"
	end
proc hshift(mat, number,start,am,bm,colortype,Zfrom,Zto)
	string mat="dest"
	variable number=97
	variable start=1
	variable am=-0.05
	variable bm=-0.1
	string colortype="Rainbow"
	variable Zfrom=-0.2
	variable Zto=4
	prompt mat,"batch name"
	prompt number,"How many?"
	prompt start,"Start number"
	prompt am,"x offset"
	Prompt bm,"y offset"
	Prompt colortype,"Color Type"
	prompt Zfrom,"Zmin for color"
	Prompt Zto,"Zmax for color"
	PauseUpdate; Silent 1
	string matname
	variable i,amm,bmm
	i=0
	do
		amm=am*i
		bmm=bm*i
		matname=mat+num2str(i+start)
		ModifyGraph offset($matname)={amm,bmm}
		ModifyGraph zColor($matname)={$matname,Zfrom,Zto,Rainbow,1}
		i+=1
	while(i<number)
end
///////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
// The method is
//1. Linear substraction around a peak, [From, to]
//2. Wavestatus to find the x_position of Maxmimun
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
Function ButtonProc_gapdiis(ctrlName) : ButtonControl
	String ctrlName
	Execute " extrastsfrommap3d()"
end
proc extrastsfrommap3d(sizex,sizey,from,to)
	variable sizex=dimsize($tpw(),0)
	variable sizey=dimsize($tpw(),1)
	variable from=-25
	variable to=-5
	prompt sizex,"How many points Nx"
	prompt sizey,"How many points Ny"

	prompt from,"Start Energy value for search"
	prompt to,"End Energy value for search"
	PauseUpdate; Silent 1

	variable i,j,K
	string mat
	make/o/N=(sizex,sizey) gapsize2d
	//k=1
	//i=0
	//do
		//j=0
		//do
			//mat="sts"+num2str(k)
			//make/o/n=(dimsize(mat3d,1)) $mat
			//setscale/p x, dimoffset(mat3d,1),dimdelta(mat3d,1),""$mat
			//$mat[]=mat3d[i][p][j]
			//wavestats/Q/R = (from, to) $mat
			//gapsize2d[i][j]=abs(V_maxloc)
			//j+=1
			//K+=1
			//print k
		//while(j<size)
		//i+=1
	//while(i<size)
	extractgapbymax(from,to,sizex,sizey)
	display;appendimage gapsize2d

end

////////////////////
Function extractgapbymax(from,to,sizex,sizey)
	Variable from
	Variable to
	Variable sizex
	variable sizey

	String name
	String mat
	Variable k,i,j
	String gapsize2ds
	gapsize2ds="gapsize2d"
	Wave m=$gapsize2ds

	String mat3ds
	mat3ds="mat3d"
	Wave mat3d=$mat3ds

	String mat2,mat3


	Variable p1,p2
	p1=Round((from-dimoffset(mat3d,1))/dimdelta(mat3d,1))
	p2=Round((to-dimoffset(mat3d,1))/dimdelta(mat3d,1))
	k=1
	i=0
	do
		j=0
		do
			mat="sts"+num2str(k)
			mat3="fit_"+mat
			mat2="W_coef"
			make/o/n=(dimsize(mat3d,1)) $mat
			Wave n=$mat
			//Redimension/N=(dimsize(mat3d,1)) n
			setscale/p x, dimoffset(mat3d,1),dimdelta(mat3d,1),""n

			n[]=mat3d[i][p][j]

			CurveFit/Q/NTHR=0 line n[p1,p2] /D

			duplicate/o n n2
			duplicate/o n n3
			Wave W_coef=$mat2
			n2=W_coef[0]+W_coef[1]*x
			n=n3-n2


			wavestats/Q/R = (from, to) n



			m[i][j]=abs(V_maxloc)
			j+=1
			K+=1
			wave fitn=$mat3
			killwaves n
			killwaves fitn
			//print k
		while(j<sizey)
		i+=1
	while(i<sizex)
end
///////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
// The method is
//1. Guassian Fit around a single peak [From, to]
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////
Function ButtonProc_gapdiisGuassian(ctrlName) : ButtonControl
	String ctrlName
	Execute " extrastsfrommap3dGuassian()"
end
proc extrastsfrommap3dGuassian(sizex,sizey,from,to)
	variable sizex=dimsize($tpw(),0)
	variable sizey=dimsize($tpw(),1)
	variable from=-25
	variable to=-5
	prompt sizex,"How many points Nx"
	prompt sizey,"How many points Ny"

	prompt from,"Start Energy value for search"
	prompt to,"End Energy value for search"
	PauseUpdate; Silent 1

	variable i,j,K
	string mat
	make/o/N=(sizex,sizey) gapsize2d
	//k=1
	//i=0
	//do
		//j=0
		//do
			//mat="sts"+num2str(k)
			//make/o/n=(dimsize(mat3d,1)) $mat
			//setscale/p x, dimoffset(mat3d,1),dimdelta(mat3d,1),""$mat
			//$mat[]=mat3d[i][p][j]
			//wavestats/Q/R = (from, to) $mat
			//gapsize2d[i][j]=abs(V_maxloc)
			//j+=1
			//K+=1
			//print k
		//while(j<size)
		//i+=1
	//while(i<size)
	extractgapbymaxGuassian(from,to,sizex,sizey)
	display;appendimage gapsize2d

end
Function extractgapbymaxGuassian(from,to,sizex,sizey)
	Variable from
	Variable to
	Variable sizex
	variable sizey

	String name
	String mat
	Variable k,i,j
	String gapsize2ds
	gapsize2ds="gapsize2d"
	Wave m=$gapsize2ds

	String mat3ds
	mat3ds="mat3d"
	Wave mat3d=$mat3ds

	String mat2,mat3


	Variable p1,p2
	p1=Round((from-dimoffset(mat3d,1))/dimdelta(mat3d,1))
	p2=Round((to-dimoffset(mat3d,1))/dimdelta(mat3d,1))
	k=1
	i=0
	do
		j=0
		do
			mat="sts"+num2str(k)
			mat3="fit_"+mat
			mat2="W_coef"
			make/o/n=(dimsize(mat3d,1)) $mat
			Wave n=$mat
			//Redimension/N=(dimsize(mat3d,1)) n
			setscale/p x, dimoffset(mat3d,1),dimdelta(mat3d,1),""n

			n[]=mat3d[i][p][j]

			//CurveFit/Q/NTHR=0 line n[p1,p2] /D
			CurveFit/Q/W=2 gauss, n[p1,p2]/D

			//duplicate/o n n2
			//duplicate/o n n3
			Wave W_coef=$mat2
			//n2=W_coef[0]+W_coef[1]*x
			//n=n3-n2


			//wavestats/Q/R = (from, to) n



			m[i][j]=W_coef[2]
			j+=1
			K+=1
			wave fitn=$mat3
			killwaves n
			killwaves fitn
			//print k
		while(j<sizey)
		i+=1
	while(i<sizex)
end
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
//For Fit the superconducting gap
//algorithm:
//
//In the fine Grid, for example 100 x 100 spectra, it is not possible to run Dyne Fit for
//each spectra, which is a integral fitting and time consuming. So we develop two simple
//algorithm to extract the gap size, the first one is the "GapDis(2D)LS", which simply
//substract a linear backgroud around the target peak, and search the location of the peak.
//The second algorithm is the "GapDis(2D)G", the peak position is extracted by simple Guassian Fitting.
//********************************************************************************************************
//However,for some unconventinal superconductor, the gap spectrum may not be very well BCS-like. It leads
//to failure of the simple algorithm mentioned above. In this combined procedure, we Fit all the two peaks
//and make sure the gap size is extracted much more accurate.
//********************************************************************************************************
//1.The left and right peak are equally fitted by Guassian function, and also they are equally extracted by
//	linear background substraction. Before run the procedure, you need to determine the interested energy range
//	in advance by looking at the dI/dV spectrum. We now have Four value for the gap size of a spectrum.
//2.If the Guassian fitted results are in the range of interest, then we choose the gapsize as the average of
//	these two Guassian fititng results. If there is one fitting results scattering outside the range of interest,
//	We will choose the other one as the gap size value. If all of them are not in the range of interest, that means
// the spectrum do not have a sharp coherence peak or the gap size have huge variation that far deviates from your
//	estimation (this is the range of interest you choose at begining), in this case the fiting function can not give a
//	valid result, we then take the value form linear background substration method, and choose the gapsize as the
// average of the left and right.
//.............................................................................................................
//In the future, we can also incorporate second deriviative method for gap extraction.
//
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
Function ButtonProc_gapdiisGuassian2(ctrlName) : ButtonControl
	String ctrlName
	Execute " extrastsfrommap3dGuassian2()"
end
proc extrastsfrommap3dGuassian2(sizex,sizey,froml,tol,fromr,tor)
	variable sizex=dimsize($tpw(),0)
	variable sizey=dimsize($tpw(),1)
	variable froml=-2.85
	variable tol=-1.5
	variable fromr=1.5
	variable tor=3
	prompt sizex,"How many points Nx"
	prompt sizey,"How many points Ny"
	prompt froml,"Start -Energy value for search"
	prompt tol,"End -Energy value for search"
	prompt fromr,"Start +Energy value for search"
	prompt tor,"End +Energy value for search"
	PauseUpdate; Silent 1

	variable i,j,K
	string mat
	make/o/N=(sizex,sizey) gapsize2d
	extractgapbymaxGuassian2(froml,tol,fromr,tor,sizex,sizey)
	display;appendimage gapsize2d
	//** Error message, no stop but Continuing execution
		String msg
		Variable err
		msg=GetErrMessage(GetRTError(0),3);
		err=GetRTError(1)
		if (err != 0)
			Print "Error in Demo: " + msg
			Print "Continuing execution"
		endif
end

Function extractgapbymaxGuassian2(froml,tol,fromr,tor,sizex,sizey)
	Variable froml
	Variable tol
	Variable fromr
	Variable tor
	Variable sizex
	variable sizey

	String name
	String mat
	Variable k,i,j
	String gapsize2ds
	gapsize2ds="gapsize2d"
	Wave m=$gapsize2ds

	String mat3ds
	mat3ds="mat3d"
	Wave mat3d=$mat3ds

	String mat2,mat3


	Variable p1,p2
	p1=Round((froml-dimoffset(mat3d,1))/dimdelta(mat3d,1))
	p2=Round((tol-dimoffset(mat3d,1))/dimdelta(mat3d,1))
	Variable q1,q2
	q1=Round((fromr-dimoffset(mat3d,1))/dimdelta(mat3d,1))
	q2=Round((tor-dimoffset(mat3d,1))/dimdelta(mat3d,1))
	k=1
	i=0
	do
		j=0
		do
			mat="sts"+num2str(k)
			mat3="fit_"+mat
			mat2="W_coef"

			make/o/n=(dimsize(mat3d,1)) $mat
			Wave n=$mat
			setscale/p x, dimoffset(mat3d,1),dimdelta(mat3d,1),""n

			n[]=mat3d[i][p][j]

			smooth 5,n


			CurveFit/Q/W=2 gauss, n[p1,p2]/D
			Wave W_coefl=$mat2


			variable j1,j2,u1,u2

			j1=1
			j2=1

			variable leftc
			leftc=-W_coefl[2]
			if (leftc < -froml && leftc > -tol)
			else
				leftc=NAN
				j1=0
			endif

			CurveFit/Q/W=2 gauss, n[q1,q2]/D
			Wave W_coefr=$mat2
			variable rightc
			rightc=W_coefr[2]
			if (rightc > fromr && rightc < tor)
			else
				rightc=NAN
				j2=0
			endif




			CurveFit/Q/NTHR=0 line n[p1,p2] /D
			duplicate/o n n2
			duplicate/o n n3
			Wave W_coefll=$mat2
			n2=W_coefll[0]+W_coefll[1]*x
			n=n3-n2
			wavestats/Q/R = (froml, tol) n
			variable ll
			ll=abs(V_maxloc)


			CurveFit/Q/NTHR=0 line n[q1,q2] /D
			duplicate/o n n2
			duplicate/o n n3
			Wave W_coefrr=$mat2
			n2=W_coefrr[0]+W_coefrr[1]*x
			n=n3-n2
			wavestats/Q/R = (fromr, tor) n
			variable rr
			rr=abs(V_maxloc)


			if (j1 == 1 && j2 == 1)
				m[i][j]=(rightc+leftc)/2
			endif

			if (j1 == 0 && j2 == 1)
				m[i][j]=(rightc*2)/2
			endif

			if (j1 == 1 && j2 == 0)
				m[i][j]=(leftc*2)/2
			endif
			if (j1 == 0 && j2 == 0)
				m[i][j]=(ll+rr)/2
			endif

			j+=1
			K+=1
			wave fitn=$mat3
			killwaves n
			killwaves fitn
		while(j<sizey)
		i+=1
	while(i<sizex)
end

///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////



///////////////////////////////////////////////////////
//Get Gap distribution from linecut, mapsts window should be in active
//This is the linear background substraction method!!!!!
///////////////////////////////////////////////////////
Function ButtonProc_linecutgapdistrpp(ctrlName) : ButtonControl
	String ctrlName
	Execute " linecutgapdistr()"
end
proc linecutgapdistr(name, from,to,suffix)
	String name=tpw()
	variable from =-40
	variable to =0
	String suffix="left"

	String gapname
	gapname="gapwave"+suffix

	make/o/N=(dimsize($name,1)) $gapname
	Setscale/p x, dimoffset($name,1),dimdelta($name,1),"",$gapname
	String stsname
	Variable p1,p2
	p1=Round((from-dimoffset($name,0))/dimdelta($name,0))
	p2=Round((to-dimoffset($name,0))/dimdelta($name,0))
	String mat
	variable i
	i=0
	do
		stsname="gapsts"+num2str(i+1)
		mat="fit_"+stsname

		make/o/N=(dimsize($name,0)) $stsname
		setscale/p x, dimoffset($name,0),dimdelta($name,0),"",$stsname
		$stsname[]=$name[p][i]
		CurveFit/Q/NTHR=0 line $stsname[p1,p2] /D
		duplicate/o $stsname nn
		duplicate/o $stsname refwave
		refwave=W_coef[0]+W_coef[1]*x
		$stsname=nn-refwave
		wavestats/Q/R = (from, to) $stsname
		$gapname[i]=abs(V_maxloc)
		i+=1
		killwaves $mat
		killwaves $stsname
		killwaves refwave
		killwaves nn
	while (i<dimsize($name,1))
	String gapwavehist
	gapwavehist=gapname+"_Hist"

	AppendToGraph/VERT $gapname
	display $gapname
	Make/N=(dimdelta($name,0))/O $gapwavehist
	Histogram/B={5,0.5,60} $gapname,$gapwavehist//******change the parameters
	Display $gapwavehist
	modifygraph width=600, height=400
	modifygraph width=0, height=0
	ModifyGraph mode=5
	CurveFit/M=2/W=0/TBOX=768 gauss, $gapwavehist/D
	Print "	Histogram/B={5,0.5,60}" +gapname+","+gapwavehist
	if (from<0)
		$gapname*=-1
	endif
end
//////////////////////////////
proc gapdiis(mat,num)
	string mat
	variable num

	string matname
	variable i
	make/n=(num)/o gapsize
	i=0
	do
		matname=mat+num2str(i+1)
		wavestats/Q $matname
		gapsize[i]=abs(V_maxloc)
		i+=1
	while(i<num)
	gapsize=abs(gapsize)
end
///////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////

///////////////////////////////////////////////////////
//Get Gap distribution from linecut, mapsts window should be in active
//This is the 1D version of GCB [Guassian-combined] method !!!!!
/////////////////////////////////////////////////
Function ButtonProc_gapdiisGuassian3(ctrlName) : ButtonControl
	String ctrlName
	Execute " extrastsfrommap3dGuassian3()"
end
proc extrastsfrommap3dGuassian3(indicate,froml,tol,fromr,tor,flag)
	String indicate = "Must with 2D Linecut graph in active"
	variable froml=-3
	variable tol=-1
	variable fromr=1
	variable tor=3
	variable flag = 1
	Prompt indicate,"Notice!!! Before Launch"
	prompt froml,"Start -Energy value for search"
	prompt tol,"End -Energy value for search"
	prompt fromr,"Start +Energy value for search"
	prompt tor,"End +Energy value for search"
   prompt flag,"If you want individually display gapfit, input '1'"

	PauseUpdate; Silent 1


	String gapwave,name

	gapwave="gapsizefit"
	//Capturenamedd()
	name=tpw()
	make/o/N=(dimsize($name,1)) $gapwave
	Setscale/p x, dimoffset($name,1),dimdelta($name,1),"",$gapwave
	String stsname
	Variable p1,p2,q1,q2
	p1=Round((froml-dimoffset($name,0))/dimdelta($name,0))
	p2=Round((tol-dimoffset($name,0))/dimdelta($name,0))

	q1=Round((fromr-dimoffset($name,0))/dimdelta($name,0))
	q2=Round((tor-dimoffset($name,0))/dimdelta($name,0))

	extractgapbymaxGuassian3(froml,tol,fromr,tor,p1,p2,q1,q2,name)
	String gapwavehist
	gapwavehist=gapwave+"_Hist"

	AppendToGraph/VERT $gapwave
	if (flag ==1)
		display $gapwave
	else
	endif
	Make/N=(dimdelta($name,0))/O $gapwavehist
	Histogram/B={0.8,0.02,120} $gapwave,$gapwavehist//******change the parameters
	Display $gapwavehist
	modifygraph width=600, height=400
	modifygraph width=0, height=0
	ModifyGraph mode=5
	CurveFit/Q/M=2/W=0/TBOX=768 gauss, $gapwavehist/D
	Print "Histogram/B={0.8,0.02,120}" +gapwave+","+gapwavehist
	//Print "Display " + gapwavehistend
end

Function extractgapbymaxGuassian3(froml,tol,fromr,tor,p1,p2,q1,q2,namedd)
	Variable froml
	Variable tol
	Variable fromr
	Variable tor
	variable p1
	variable p2
	variable q1
	variable q2
	string namedd

	String name
	String mat
	Variable j,k
	String gapwave
	gapwave="gapsizefit"
	Wave m=$gapwave

	//SVAR topgraphimage=topgraphimage
	Wave mat3d=$namedd

	String mat2,mat3

		k=1
		j=0
		do
			mat="stsfit"+num2str(k)
			mat3="fit_"+mat
			mat2="W_coef"

			make/o/n=(dimsize(mat3d,0)) $mat
			Wave n=$mat
			setscale/p x, dimoffset(mat3d,0),dimdelta(mat3d,0),""n

			n[]=mat3d[p][j]
			//display n
			smooth 5,n


			CurveFit/Q/W=2 gauss, n[p1,p2]/D
			Wave W_coefl=$mat2


			variable j1,j2,u1,u2

			j1=1
			j2=1

			variable leftc
			leftc=-W_coefl[2]
			if (leftc < -froml && leftc > -tol)
			else
				leftc=NAN
				j1=0
			endif
			//print leftc

			CurveFit/Q/W=2 gauss, n[q1,q2]/D
			Wave W_coefr=$mat2
			variable rightc
			rightc=W_coefr[2]
			if (rightc > fromr && rightc < tor)
			else
				rightc=NAN
				j2=0
			endif
		    //print "rightc " + num2str(rightc)




			CurveFit/Q/NTHR=0 line n[p1,p2] /D
			duplicate/o n n2
			duplicate/o n n3
			Wave W_coefll=$mat2
			n2=W_coefll[0]+W_coefll[1]*x
			n=n3-n2
			wavestats/Q/R = (froml, tol) n
			variable ll
			ll=abs(V_maxloc)
			//print "ll " + num2str(ll)

			CurveFit/Q/NTHR=0 line n[q1,q2] /D
			duplicate/o n n2
			duplicate/o n n3
			Wave W_coefrr=$mat2
			n2=W_coefrr[0]+W_coefrr[1]*x
			n=n3-n2
			wavestats/Q/R = (fromr, tor) n
			variable rr
			rr=abs(V_maxloc)
			//print rr

			if (j1 == 1 && j2 == 1)
				m[j]=(rightc+leftc)/2
			endif

			if (j1 == 0 && j2 == 1)
				m[j]=(rightc*2)/2
			endif

			if (j1 == 1 && j2 == 0)
				m[j]=(leftc*2)/2
			endif
			if (j1 == 0 && j2 == 0)
				m[j]=(ll+rr)/2
			endif

			//print m[j]
			j+=1
			K+=1
			wave fitn=$mat3
			killwaves n
			killwaves fitn
		while(j<dimsize(mat3d,1))
		//while(j<10)
end
///////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
Function ButtonProc_twosetdifference(ctrlName) : ButtonControl
	String ctrlName
	Execute " twosetdifference()"
end
//////////////////////////////
proc twosetdifference(mat,num,start)
	string mat="sts"
	variable num=38
	variable start=1
	prompt mat,"Batch name"
	Prompt num,"Number of One set"
	prompt start,"Number of 1st Spectrum"
	variable i
	string matt,m,l
	i=0
	do
		matt=mat+num2str(i+start)
		m="difference"+num2str(i+1)
		l=mat+num2str(i+start+num)
		duplicate/o $matt $m
		$m= $matt-$l
		i+=1
	while(i<num)
end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
//////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
//////////////////////////////
///////////////////////////////////////////////////////////
//////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
//////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
//////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
//////////////////////////////
///////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
//////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
//////////////////////////////

Function ButtonProc_autodisplay(ctrlName) : ButtonControl
	String ctrlName
	Execute "autodisplay()"
end

///////
proc autodisplay(matname,datanumber,per,number,down,up,shift,size,multix)
	variable datanumber=1//data which
	variable per=4
	string matname="data"
	variable number=32
	variable down=-8
	variable up=8
	variable shift=0//meV// the x value add to scale to calibrate Ef
	variable size=4//nm
	variable multix=10
	prompt datanumber,"Number of DATA lincut"
	prompt per,"Average how many sts"
	prompt matname,"name of the data"
	prompt number,"How many stss?"
	prompt down,"Lowest energy for norm (meV)"
	prompt up,"Highest energy for norm (meV)"
	prompt shift," the meV value added to calibrate Ef"
	prompt size," length (nm)"
	prompt multix," rescale x axis, to multiply"




	string edcname,edcnamef
	edcname="E"+num2str(datanumber)+"_"
	gv_GroupNum=datanumber

	MakeEdc_pi(0,-1,1,1)
	addper(edcname,per,0,per*number-1)
	displaymulti("dest",1,number)
	//modifygraph width=250,height=600
	modifygraph width=200	,height=350
	modifygraph width=0,height=0
	rescalexmultiwhat("dest",number,multix)
	normrange("dest",number,down,up)
	//myall("dest",number,10^12)
	Constantoffset_n(0.3,1)
	modifygraph lsize=1
	ModifyGraph mirror=2
	ModifyGraph tick=2
	Label left "\\Z20\F'times'dI/dV (a.u.)";DelayUpdate
	Label bottom "\\Z20\F'times'Sample Bias\M\F'times'\Z20 (meV)"
	color_edc()
	rescalex_plus("dest",number,shift)
	smoothall("dest",number,10)
	string matdest,matdest2

	matdest="dest"+num2str(number)
	matdest2="dest"+num2str(number+1)
	string mapname
	mapname="linedata"+num2str(datanumber)
	duplicate/o $matdest $matdest2
	string mat2
	mat2="dest"+num2str(datanumber)+"_"
	renameall("dest",mat2,"",number+1)


	interpsts00(mat2,number,3,mapname)
	modifygraph width=200	,height=350
	modifygraph width=0,height=0
	setscale/I y 0,size,"",$mapname
	Label left "\Z20\F'times'Distance (nm)"


end

function linkstsmap_factor00(name,num,factor,mapname)
	string name
	variable num,factor
	string mapname
	variable i,j
	string mat,mat0
	mat0=name+num2str(1)
	wave m=$mat0
	make/o/n=(dimsize(m,0),((2^factor)*num-2^factor+1)) mapsts
	i=0
	do
		j=0
		do
			mat=name+num2str(i+1)
			wave n=$mat
			mapsts[j][i*2^(factor)]=n[j]
			j+=1
		while(j<dimsize(m,0))
		i+=1/(2^(factor))
	while(i<num)
	setscale/P x, dimoffset(m,0),dimdelta(m,0),""mapsts
	//display;appendimage mapsts
	//rename mapsts $mapname
end
/////////////////////////////////////////////////////
//interpsts00("dest",number,3,mapname)

proc interpsts00(name,num,factor,mapname)
	string name="sts"
	variable num
	variable factor
	string mapname
	//Prompt num,"Total number of STSs"
	//Prompt factor,"Interpolate how many times?"


	string mati,mat,dest,
	variable i
	variable j
	j=1
	do
		i=0
		do
			mati=name+num2str(i+1)
			mat=name+num2str(i+1+1/2^(j-1))
			dest=name+num2str(i+1+0.5/2^(j-1))
			duplicate/o $mati $dest
			duplicate/o $mati awave
			duplicate/o $mati bwave

			awave=$mati
			bwave=$mat
			$dest=(awave+bwave)/2
			i+=1/(2^(j-1))
		//while(i<num-1)
		while(i<num)

		J+=1

	while(j<=factor)
	//displaymulti_factor(name,1,num,factor)
	linkstsmap_factor00(name,num,factor,mapname)
	//modifygraph width=250, height=450
	duplicate/o mapsts $mapname
	display;appendimage $mapname
	modifygraph lsize=1
	ModifyGraph mirror=2
	ModifyGraph tick=2
	ModifyImage $mapname ctab= {*,*,VioletOrangeYellow,0}
	//Label left "\Z20\F'times'Distance (Å\M\F'times'\Z20)";DelayUpdate
	Label bottom "\\Z20\F'times'Sample Bias\M\F'times'\Z20 (meV)"
	//ModifyGraph width=0,height=0

	killwaves awave, bwave
	//print "interpsts("+name+","+num2str(num)+","+num2str(factor)+")"
end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
//////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
//////////////////////////////
///////////////////////////////////////////////////////////
//////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
//////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
//////////////////////////////////////////////////
Function ButtonProc_renamep(ctrlName) : ButtonControl
	String ctrlName
	Execute "renamep()"
end

proc renamep(mat,mat2,suf,start,endi)
	string mat="sts"
	string mat2="sts2_"
	string suf=""
	variable start=65
	variable endi
	Prompt mat,"name of the Batch waves"
	Prompt mat2,"Change to What?"
	Prompt start,"start of the Batch"
	Prompt endi,"end of the Batch"
	Prompt suf,"If you have a suffix,Please input"

	string matt,matt2
	variable i
	i=start
	do
		matt=mat+num2str(i)+suf
		//mat2="stsnormallrangecutline"+num2str(i)
		matt2=mat2+num2str(i-start+1)
		//mat2="stsr"+num2str(i)
		duplicate/o $matt $matt2
		i+=1
	while(i<endi+1)
	//print "renameall("+mat+","+mat2+","+suf+","+num2str(totalnum)+")"
end


///////////////////////////
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
//////////////////////////////
///////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
//////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////


/// This procedure is used with a dataset which each curve substrated by the first curve
Function ButtonProc_subsc(ctrlName) : ButtonControl
	String ctrlName
	Execute "subsc()"
end
proc subsc(name,num)
	string name="dest_"
	variable num=32
	variable i
	string namea
	string name1
	namea=name+"sub_"
	duplicateall(name,namea,"",num)
	string nameend
	i=0
	do
		nameend=namea+num2str(i+2)
		name1=namea+num2str(1)

		$nameend-=$name1
		i+=1
	while(i<num-1)
	displaymulti(namea,2,num)
	modifygraph lsize=1
	ModifyGraph mirror=2
	ModifyGraph tick=2
	Label left "\\Z20\F'times'dI/dV (a.u.)";DelayUpdate
	Label bottom "\\Z20\F'times'Sample Bias\M\F'times'\Z20 (meV)"
	ModifyGraph lsize=2
end

///

Function ButtonProc_displaytopog(ctrlName) : ButtonControl
	String ctrlName
	Execute "displaytopog()"
end
proc displaytopog(name,size)
	string name="data2"
	variable size=8
	setscale/I x, size,0,"",$name
	setscale/I y, 0,size,"",$name
	display ;appendimage $name
	ModifyImage $name ctab= {*,*,Mud,0}
	modifygraph width=300,height=300
	modifygraph width=0,height=0
	ModifyGraph width={Plan,1,bottom,left}
	Label left "\\Z13\\F'times'Size (nm)"
	Label Bottom "\\Z13\\F'times'Size (nm)"

end
/////////////////////////////////////////
//test2(20,29.283,0.41,-3.68,15)///////////////////////////////////////////////

/////////////////////////////////////////////////
Proc Capturenamedd()
	PauseUpdate
	Silent 1
	variable/G topgraphnum
	Variable/G topimagemin
	Variable/G topimagemax
	Variable/G minsetvar
	Variable/G maxsetvar
	Variable/G topimageminratio
	Variable/G topimagemaxratio
	String/G topgraphimage
	String/G topgraphname
	String/G topgraphcolor
	String/G topgraphcolorinv
	String thelist
	string thewinlist
	string iminfolist
	string colorinfolist1,colorinfolist
	string iminfo
	string minsetstr,maxsetstr
	Variable minsetvar,maxsetvar
	thelist=ImageNameList("",";")
	topgraphimage=StringFromList(topgraphnum, thelist , ";")
	thewinlist=winlist("*",";","")
	topgraphname=StringFromList(1, thewinlist , ";")

	print topgraphname
	print topgraphimage
	imagestats/Q $topgraphimage
	//topimagemin=V_min
	//topimagemax=V_max
	//iminfolist=ImageInfo(topgraphname,topgraphimage,0)
//	print iminfolist
	//iminfo=StringFromList(10, iminfolist , ";")
	//colorinfolist1=iminfo[18,strlen(iminfo)-2]
	//colorinfolist=colorinfolist1+","
	//minsetstr=StringFromList(0, colorinfolist , ",")
	//maxsetstr=StringFromList(1, colorinfolist , ",")
	//topgraphcolor=StringFromList(2, colorinfolist , ",")
	//topgraphcolorinv=StringFromList(3, colorinfolist , ",")
	//IF(cmpstr(minsetstr,"*")==0)
		//minsetvar=topimagemin
		//ELSE
			//minsetvar=str2num(minsetstr)
	//Endif
	//IF(cmpstr(maxsetstr,"*")==0)
		//maxsetvar=topimagemax
		//ELSE
			//maxsetvar=str2num(maxsetstr)
	//Endif
	//topimageminratio=(minsetvar-topimagemin)/(topimagemax-topimagemin)
	//topimagemaxratio=(maxsetvar-topimagemin)/(topimagemax-topimagemin)
	//slider topimagetop value=topimagemaxratio
	//slider topimagebot value=topimageminratio
	//IF(str2num(topgraphcolorinv)==0)
		//Popupmenu popupinvmatcolor mode=1
		//Else
			//Popupmenu popupinvmatcolor mode=2
	//Endif
End

///////////////////////////////////////////
proc testlattice(a,b,c,theta)
	variable a
	variable b
	variable c
	variable theta
	make/o/N=10/o linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
	setscale/I x, -8,8,"", linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
	linefft0=tan(theta*pi/180)*x+b
	linefft1=tan(theta*pi/180)*x+a*1/cos(theta*pi/180)+b
	linefft2=tan(theta*pi/180)*x+a*2/cos(theta*pi/180)+b
	linefft3=tan(theta*pi/180)*x+a*3/cos(theta*pi/180)+b
	linefft4=tan(theta*pi/180)*x+a*4/cos(theta*pi/180)+b
	linefft00=tan((theta+90)*pi/180)*x+c
	linefft5=tan((theta+90)*pi/180)*x+a*1/cos((theta+90)*pi/180)+c
	linefft6=tan((theta+90)*pi/180)*x+a*2/cos((theta+90)*pi/180)+c
	linefft7=tan((theta+90)*pi/180)*x+a*3/cos((theta+90)*pi/180)+c
	linefft8=tan((theta+90)*pi/180)*x+a*4/cos((theta+90)*pi/180)+c
	append linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

Function ButtonProc_findmaxBatch(ctrlName) : ButtonControl
	String ctrlName
	Execute "findmaxBatch()"
end
proc findmaxBatch(name,r1,r2)
	string name="sts"
	variable r1=-1
	variable r2=1
	prompt name, "Batch name"
	prompt r1, "Start x"
	prompt r2, "End x"

	string nn
	make/o/n=(dimsize(file_name,0)-1) maxinten
	variable i
	i=1
	do
		nn=name+num2str(i)
		WaveStats/Q/R=(r1,r2) $nn
		maxinten[i-1]=V_max
		i+=1
	while (i<dimsize(file_name,0)-1)
	WaveStats/Q maxinten
	print V_max
end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

Function ButtonProc_tempload(ctrlName) : ButtonControl
	String ctrlName
	Execute "tempload()"
end
proc tempload()
	setDataFolder Root:
	Makegraphtable()
	LoadDataFromNewmk(0,4)
	Initialize_Global_Variables()
	rescalexmultiwhat("sts",dimsize(file_name,0)-1,10)
	displaymulti("sts",1,dimsize(file_name,0)-1)
	print "vcsr(A)"
end
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
proc autoclbzero2(mat,num,left,right)
	string mat="sts"
	variable num =(dimsize(file_name,0)-1)
	variable left=pcsr(A)
	variable right=pcsr(B)
	Prompt mat,"name of Batch"
	Prompt num,"Number of Batch"
	Prompt left,"Fit From (Point)"
	Prompt right,"Fit To (Point)"
	variable i
	string matuse,dest
	variable height, pp
	make/o/N=(num) peakpclb
	make/o/N=(num) peakhclb
	i=1
	do
		matuse=mat+num2str(i)
		dest=mat+"CL"+num2str(i)
		CurveFit/Q/M=2/W=0 gauss, $matuse[left,right]/D
		height=W_coef[1]+W_coef[0]
		pp=W_coef[2]
		peakhclb[i-1]=height
		//wavestats/Q $matuse
		peakpclb[i-1]=W_coef[2]
		duplicate/o $matuse $dest
		setscale/P x,(dimoffset($matuse,0)-W_coef[2]),dimdelta($matuse,0),"",$dest
		i+=1
	while(i<num+1)
	//edit  peakpclb peakhclb
	//display peakpclb
	//display peakhclb
	//displaymulti(mat+"CL",1,num)
end
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_LiFeAsfindmiushift(ctrlName) : ButtonControl
	String ctrlName
	Execute "LiFeAsfindmiushift()"
end
Proc LiFeAsfindmiushift(length, combine, number,fits,fite)
	variable length
	variable combine=6
	variable number=32
	variable fits=282
	variable fite=341


	//autoclbzero2("dest1__2ndD_",32,533,593)



	autodisplay("data",1,combine,number,-30,70,0,length,100)
	secondDall("dest1_","",number,500)
	myall("dest1__2ndD_",number,100)
	Constantoffset_n(0.4,1)
	autoclbzero2("dest1__2ndD_",number,fits,fite)
	offtheset("fit_dest1__2ndD_",0.4,number)



	ModifyGraph rgb(fit_dest1__2ndD_1)=(0,0,0),rgb(fit_dest1__2ndD_2)=(0,0,0);DelayUpdate
	ModifyGraph rgb(fit_dest1__2ndD_3)=(0,0,0),rgb(fit_dest1__2ndD_4)=(0,0,0);DelayUpdate
	ModifyGraph rgb(fit_dest1__2ndD_5)=(0,0,0),rgb(fit_dest1__2ndD_6)=(0,0,0);DelayUpdate
	ModifyGraph rgb(fit_dest1__2ndD_7)=(0,0,0),rgb(fit_dest1__2ndD_8)=(0,0,0);DelayUpdate
	ModifyGraph rgb(fit_dest1__2ndD_9)=(0,0,0),rgb(fit_dest1__2ndD_10)=(0,0,0);DelayUpdate
	ModifyGraph rgb(fit_dest1__2ndD_11)=(0,0,0),rgb(fit_dest1__2ndD_12)=(0,0,0);DelayUpdate
	ModifyGraph rgb(fit_dest1__2ndD_13)=(0,0,0),rgb(fit_dest1__2ndD_14)=(0,0,0);DelayUpdate
	ModifyGraph rgb(fit_dest1__2ndD_15)=(0,0,0),rgb(fit_dest1__2ndD_16)=(0,0,0);DelayUpdate
	ModifyGraph rgb(fit_dest1__2ndD_17)=(0,0,0),rgb(fit_dest1__2ndD_18)=(0,0,0);DelayUpdate
	ModifyGraph rgb(fit_dest1__2ndD_19)=(0,0,0),rgb(fit_dest1__2ndD_20)=(0,0,0);DelayUpdate
	ModifyGraph rgb(fit_dest1__2ndD_21)=(0,0,0),rgb(fit_dest1__2ndD_22)=(0,0,0);DelayUpdate
	ModifyGraph rgb(fit_dest1__2ndD_23)=(0,0,0),rgb(fit_dest1__2ndD_24)=(0,0,0);DelayUpdate
	ModifyGraph rgb(fit_dest1__2ndD_25)=(0,0,0),rgb(fit_dest1__2ndD_26)=(0,0,0);DelayUpdate
	ModifyGraph rgb(fit_dest1__2ndD_27)=(0,0,0),rgb(fit_dest1__2ndD_28)=(0,0,0);DelayUpdate
	ModifyGraph rgb(fit_dest1__2ndD_29)=(0,0,0),rgb(fit_dest1__2ndD_30)=(0,0,0);DelayUpdate
	ModifyGraph rgb(fit_dest1__2ndD_31)=(0,0,0),rgb(fit_dest1__2ndD_32)=(0,0,0)


	duplicateall("dest1_","dest1ln","",32)
	selectlinenorm("dest1ln",150,498,32);
	duplicate/o dest1ln32 dest1ln33
	interpsts("dest1ln",32,3)
	SetAxis bottom -10,60
	setscale/I y, 0, length,"",  mapsts;setscale/I x, 0, length,"",  peakpclb;
	AppendToGraph/VERT peakpclb
	ModifyGraph mode=3,marker=51,msize=5,mrkThick=2
	display peakpclb
	ModifyGraph mode=3,marker=51,msize=5,mrkThick=2

end



//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//
//           Data Normalization, slope distraction of the topography
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

Function ButtonProc_slopedata(ctrlName) : ButtonControl
	String ctrlName
	Execute "slopedata()"
end

Function ButtonProc_slopedataall(ctrlName) : ButtonControl
	String ctrlName
	Execute "slopeall()"
end

Proc slopeall(mat,number)
	string mat = "data"
	variable number = dimsize(FIle_name,0)-1

	variable i
	string matt
	i=1
	do
		MATT=mat+num2str(i)
		slopedata(MATT)
		i+=1
	while (i< number+1)
end


proc slopedata(mat)
	string mat = tpw()
	Prompt mat,"name of the topograph"

	variable xpoint
	variable ypoint

	string matt
	matt="d_"+mat
	duplicate/o $mat $matt

	xpoint=dimsize($mat,0)
	ypoint=dimsize($mat,1)

	make/N=(xpoint)/o xave
	Xave=$mat[p][0]
	CurveFit/M=2/W=0 line, Xave/D
	Xave=W_coef[0]+W_coef[1]*x


	make/N=(ypoint)/o yave
	yave=$mat[0][p]
	CurveFit/M=2/W=0 line, yave/D
	yave=W_coef[0]+W_coef[1]*x


	ssx(mat,xave,ypoint)
	ssy(mat,yave,xpoint)


	display; appendimage $mat
end



Function ssx(namedata,ref,ypoint)
	string namedata
	wave ref
	variable ypoint

	variable i
	wave n=$namedata
	wave xwave=ref
	i=0
	do
		n[][i]-=xwave[p]
		i+=1
	while(i<ypoint)
end

Function ssy(namedata,ref,xpoint)
	string namedata
	wave ref
	variable xpoint

	variable i
	wave n=$namedata
	wave ywave=ref
	i=0
	do
		n[i][]-=ywave[q]
		i+=1
	while(i<xpoint)
end
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
// Data ploter2 change color
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

Function ButtonProc_dataploter2(ctrlName) : ButtonControl
	String ctrlName
	If(wintype("dataploter2")==0)
		Execute "dataploter2()"
		Else
			DoWindow/F dataploter2
	Endif
End
Window dataploter2() : Graph
	PauseUpdate; Silent 1		// building window...
	Display /W=(144,71,527,485)
	AppendImage Data1
	ModifyImage Data1 ctab= {*,*,mud,0}
	ModifyGraph wbRGB=(60928,60928,60928),gbRGB=(60928,60928,60928)
	ModifyGraph mirror=2
	ShowInfo
	ControlBar 74
	SetVariable varplot,pos={5,4},size={100,20},proc=setvarplot2,title="Data"
	SetVariable varplot,fSize=14,limits={1,inf,1},value= gv_GroupNum
	Button button0,pos={111,4},size={80,20},proc=ButtonProc_DisplayMat,title="Make Image"
	Button button1,pos={270,4},size={35,20},proc=ButtonProc_MakeEDC,title="EDC"
	Button button2,pos={309,4},size={35,20},proc=ButtonProc_MkMDC,title="MDC"
	Button button3,pos={4,26},size={60,20},proc=ButtonProc_ConvertSingleData,title="Cvt data"
	Button button4,pos={194,4},size={30,20},proc=ButtonProc_MatNkPlot,title="NK"
	Button button5,pos={227,4},size={40,20},proc=ButtonProc_MatNorm,title="Norm"
	Button Open_this_data,pos={67,26},size={100,20},proc=ButtonProc_open_onedata_pi,title="Open this data"
	Button Rem_dataedc,pos={169,26},size={85,20},proc=ButtonProc_Remove_data_EDC,title="Subtract EDC"
	Button but_rm_background,pos={256,26},size={115,20},proc=ButtonProc_Rm_simplebgnd_data,title="Remove backgrnd"
	Button buttonfilter,pos={4,49},size={65,20},proc=ButtonFFTfilterdata,title="FFT filter"
	Button buttonshowmain,pos={295,49},size={75,20},title="Main Panel",fStyle=16
	Button buttonfftlist,pos={73,49},size={60,20},proc=ButtonProc_FFTlist,title="FFT list"
	Button button6,pos={136,49},size={120,20},proc=ButtonProc_add_this_data,title="Combine this data"
	Button buttonhelp,pos={351,3},size={25,20},proc=Button_Help_Data_ploter,title="\\K(65535,65535,65535)?"
	Button buttonhelp,fSize=15,fStyle=16,fColor=(16385,16388,65535)
EndMacro
Function setvarplot2(ctrlName,varNum,varStr,varName): SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
//	print ctrlName,varNum,varStr,varName
	Execute "plotraw2()"
	//Execute "show_dos()"
End
Proc plotraw2()
	String thedata
	String old_image,old_image_list
	String/G info
	Variable/G gv_GroupNum
	Variable i
	thedata="data"+num2str(gv_GroupNum)
	old_image_list=ImageNameList("dataploter2",";")
	old_image=StringFromList(0,old_image_list)
	If(WaveExists($old_image)==1)
		Removeimage $old_image
	Endif
	If(WaveExists($thedata)==1)
		Appendimage $thedata
		ModifyImage $thedata ctab= {*,*,mud,0}
	Endif
	info=File_Name[gv_GroupNum]
End

Function ButtonProc_getslicerData(ctrlName) : ButtonControl
	String ctrlName
	Execute "Initialize_Global_Variables()"
	Execute "getslicerData()"
end

//duplicate/o Root:Grid001:Grid001_LI_Demod_1_Y Root:mat3draw

Proc getslicerData(name,a,b,c,xs,ys,Es,Ed)
	string name="mat3draw"
	variable a = 0
	variable b = 1
	variable c = 2
	variable xs = 40
	variable ys = 40
	variable Es = -100
	variable Ed = 2
	Prompt name, "Name of the 3D matrix"
	Prompt a, "X is which index in Matrix? Row (0); Coloum (1); Layer (2)"
	Prompt b, "Y is which index in Matrix? Row (0); Coloum (1); Layer (2)"
	Prompt c, "E is which index in Matrix? Row (0); Coloum (1); Layer (2)"
	Prompt xs, "x-size"
	Prompt ys, "y-size"
	Prompt Es, "Start Energy"
	Prompt Ed, "Energy delta"
	//String sx,sy,sE
	StartE = Es
	deltaE = Ed

	index_x=a
		if (index_x == 0)
			//sx = "x"
			setscale/I x,0,xs,"",$name

		endif
		if (index_x == 1)
			//sx = "y"
			setscale/I y,0,xs,"",$name
		endif
		if (index_x == 2)
			//sx = "z"
			setscale/I z,0,xs,"",$name
		endif

	index_y=b
		if (index_y == 0)
			//sy = "x"
			setscale/I x,0,ys,"",$name
		endif
		if (index_y == 1)
			//sy = "y"
			setscale/I y,0,ys,"",$name
		endif
		if (index_y == 2)
			//sy = "z"
			setscale/I z,0,ys,"",$name
		endif

	index_E=c
		if (index_E == 0)
			//sE = "x"
			setscale/P x,Es,Ed,"",$name
		endif
		if (index_E == 1)
			//sE = "y"
			setscale/P y,Es,Ed,"",$name
		endif
		if (index_E == 2)
			//sE = "z"
			setscale/P z,Es,Ed,"",$name
		endif

	//setscale/I sx,0,xs,"",$name
	//setscale/I sy,0,ys,"",$name
	//setscale/P sE,Es,Ed,"",$name
	String named
	named=name+"_D"
	Duplicate/O $name $named
	getslicerDataf(name)

end

Function getslicerDataf(name)
	String name
	String dataname
	Wave mat3dw=$name
	NVAR index_x=index_x
	NVAR index_y=index_y
	NVAR index_E=index_E
	Execute "setDataFolder Root:"
	Execute "Makegraphtable()"
	Execute "Initialize_Global_Variables()"
	String File_name
	File_name="File_name"
	Wave/T File_namew=$File_name
	Redimension/N=(dimsize(mat3dw,index_E)) File_namew
	File_namew="Slice Energy is "+num2str(dimoffset(mat3dw,index_E)+p*dimdelta(mat3dw,index_E))
	InsertPoints 0,1, File_namew
	Variable i
	i=1
	do
		dataname="data"+num2str(i)
		make/O/N=(dimsize(mat3dw,index_x),dimsize(mat3dw,index_y)) $dataname
		Wave datanamew=$dataname
		Setscale/I x, 0,(dimsize(mat3dw,index_x)-1)*dimdelta(mat3dw,index_x),"", datanamew
		Setscale/I y, 0,(dimsize(mat3dw,index_y)-1)*dimdelta(mat3dw,index_y),"", datanamew


		//Redimension/N=(dimsize(mat3dw,index_x),dimsize(mat3dw,index_y)) datanamew
		//Redimension/N=(1,1) datanamew
		//aa = dimoffset(mat3dw,index_E)+(i)*dimdelta(mat3dw,index_E)
		//bb = num2str(aa)
		//File_namew[i-1] = bb
		datanamew=mat3dw[p][q][i-1]
		i+=1
	While (i<dimsize(mat3dw,index_E)+1)

end
//***********************************************************************************************
//***********************************************************************************************
//***********************************************************************************************
//***********************************************************************************************
Function ButtonProc_setmatrixindex(ctrlName) : ButtonControl
	String ctrlName
	Execute "Initialize_Global_Variables()"
	Execute "setmatrixindex()"
end

Proc setmatrixindex(a,b,c)
	variable a =0
	variable b =1
	variable c =2
	Prompt a, "X is which index in Matrix? Row (0); Coloum (1); Layer (2)"
	Prompt b, "Y is which index in Matrix? Row (0); Coloum (1); Layer (2)"
	Prompt c, "E is which index in Matrix? Row (0); Coloum (1); Layer (2)"
	index_x = a
	index_y = b
	index_E = c
End

Function ButtonProc_IExyf(ctrlName) : ButtonControl
	String ctrlName
	Execute " mapforSTMf()"
end
Proc mapforSTMf(num,name,suff,start,delta)
	variable num//=dimsize(File_name,0)-1 //number of cuts.
	string name="data"
	string suff=""
	variable start //= StartE
	variable delta //= deltaE
	PROMPT num,"Number of spatial Map"
	prompt name, "Name of Map"
	Prompt suff,"For smooth data use _VSHS"
	Prompt start,"Enrgy start (meV)"
	Prompt Delta,"Energy delta (meV)"

	//Variable size=10 //length of map
	//Prompt size,"Size of Map(nm)"
	variable/G Startforrotate
	variable/G deltaforrotate

	Startforrotate=Start
	deltaforrotate=delta

	StartE = start
	deltaE = delta
	mapforSTMff(num,name,suff,start,delta)
End

Function mapforSTMff(num,name,suff,start,delta)
	variable num//number of cuts.
	string name
	string suff
	variable start
	variable delta

	string mapname
	string firstname
	firstname=name+num2str(1)+suff
	wave firstnamen=$firstname
	variable i
	i=1
	make/o/n=(dimsize(firstnamen,0),num,dimsize(firstnamen,1)) mat
	//setscale/I x, 0, size,"",mat
	//setscale/I Z, 0, size,"",mat
	setscale/P x, dimoffset(firstnamen,0), dimdelta(firstnamen,0),"",mat
	setscale/P Z, dimoffset(firstnamen,1), dimdelta(firstnamen,1),"",mat
	setscale/P y, start, delta,"",mat

	do
		mapname=name+num2str(i)+suff
		wave mapnamen=$mapname
		mat[][i-1][]=mapnamen[p][r]
		i+=1
	while(i<=num)
	duplicate/o mat mat3d
end




Function rot2d_pimf(mats,angle,px,py,qualityfactor)
	String mats
	Variable angle
	Variable px
	Variable py
	Variable qualityfactor

	Variable x_0,x_last,delta_x,y_0,y_last,delta_y,total_x,total_y
	Variable new_xoffset,new_xlast,new_yoffset,new_ylast
	Variable top,bottom,left,right
	Variable newsize_x,newsize_y
	Variable new_delta
	Variable valuex,valuey
	Variable oldx,oldy
	Variable i,j
	String nnewmat,c_mat
	nnewmat="rot"+num2str(angle)+"_"+mats
	wave mat=$mats
	x_0=dimoffset(mat,0)
	y_0=dimoffset(mat,1)
	delta_x=dimdelta(mat,0)
	delta_y=dimdelta(mat,1)
	total_x=dimsize(mat,0)
	total_y=dimsize(mat,1)
	x_last=x_0+delta_x*(total_x-1)
	y_last=y_0+delta_y*(total_y-1)
	//Find the borders of the new matrix
	i=0
	Do
		c_mat="cmat"+num2str(i)
		Make/O/N=2 $c_mat
		i+=1
	While(i<4)
	string cmat0,cmat1,cmat2,cmat3
		cmat0="cmat0";cmat1="cmat1";cmat2="cmat2";cmat3="cmat3"
		wave cmat0m=$cmat0;wave cmat1m=$cmat1;wave cmat2m=$cmat2;wave cmat3m=$cmat3
	cmat2m[0]=(x_last-px)*cos(angle*Pi/180)+(y_last-py)*sin(angle*Pi/180)+px		//upper right
	cmat2m[1]=-(x_last-px)*sin(angle*Pi/180)+(y_last-py)*cos(angle*Pi/180)+py
	cmat1m[0]=(x_last-px)*cos(angle*Pi/180)+(y_0-py)*sin(angle*Pi/180)+px		//bottom right
	cmat1m[1]=-(x_last-px)*sin(angle*Pi/180)+(y_0-py)*cos(angle*Pi/180)+py
	cmat3m[0]=(x_0-px)*cos(angle*Pi/180)+(y_last-py)*sin(angle*Pi/180)+px		//upper left
	cmat3m[1]=-(x_0-px)*sin(angle*Pi/180)+(y_last-py)*cos(angle*Pi/180)+py
	cmat0m[0]=(x_0-px)*cos(angle*Pi/180)+(y_0-py)*sin(angle*Pi/180)+px			//bottom left
	cmat0m[1]=-(x_0-px)*sin(angle*Pi/180)+(y_0-py)*cos(angle*Pi/180)+py
	new_xoffset=cmat0m[0]
	new_xlast=cmat0m[0]
	new_yoffset=cmat0m[1]
	new_ylast=cmat0m[1]
	i=1
	Do

		c_mat="cmat"+num2str(i)
		wave c_matm=$c_mat
		If(c_matm[0]<new_xoffset)
			new_xoffset=c_matm[0]
		Endif
		If(c_matm[0]>new_xlast)
			new_xlast=c_matm[0]
		Endif
		If(c_matm[1]<new_yoffset)
			new_yoffset=c_matm[1]
		Endif
		If(c_matm[1]>new_ylast)
			new_ylast=c_matm[1]
		Endif
		i+=1
	While(i<4)
	//Set the scaling of the new matrix
	new_delta=sqrt((new_xlast-new_xoffset)*(new_ylast-new_yoffset)/(total_x*total_y))/qualityfactor
	newsize_x=Round((new_xlast-new_xoffset)/new_delta)
	newsize_y=Round((new_ylast-new_yoffset)/new_delta)
	Make/O/N=(newsize_x,newsize_y) $nnewmat
	Setscale/P x,new_xoffset,new_delta,"",$nnewmat
	Setscale/P y,new_yoffset,new_delta,"",$nnewmat
	//Filling the new matrix
	func_rot2d_pi($mats,$nnewmat,angle,px,py,new_delta,delta_x,delta_y,newsize_x,newsize_y,new_xoffset,new_yoffset,x_0,x_last,y_0,y_last)
	Killwaves cmat0m
	Killwaves cmat1m
	Killwaves cmat2m
	Killwaves cmat3m
	//Display
	//Appendimage $nnewmat
	//ModifyImage $nnewmat ctab= {*,*,Terrain,1}
End
////////////////////////////////////////////////////////////////////////
Function ButtonProc_rescaleallpr(ctrlName) : ButtonControl
	String ctrlName
	Execute "rescaleallpr()"
end

Proc rescaleallpr(name,num,lenx,leny)
	String name = "data"
	variable num= dimsize(file_name,0)-1
	variable lenx = 40
	variable leny = 40
	Prompt name,"Batch name"
	Prompt num,"how many data"
	Prompt lenx,"x size"
	Prompt leny,"y size"
	rescaleall(name,num,lenx,leny)
end

Function rescaleall(name,num,lenx,leny)
	String name
	variable num
	variable lenx
	variable leny
	String thisstring
	String filen
	variable i
	//filen="file_name"
	//wave ff=$filen
	i=1
	do
		thisstring=name+num2str(i)
		wave res=$thisstring
		Setscale/I x, 0, lenx,"",res
		Setscale/I y, 0, leny,"",res
		i+=1
	while(i<num+1)
end
//////////////////////////////////////////////////////
Function ButtonProc_rescale(ctrlName) : ButtonControl
	String ctrlName
	Execute "rescale()"
	end

Proc rescale(sizex,sizey)
	Variable sizex
	Variable sizey

		Capturenamedd()
		Setscale/I x, 0, sizex,"",$topgraphimage;
		Setscale/I y, 0, sizey,"",$topgraphimage;
		ModifyGraph width={Plan,1,bottom,left}
		Print "rescale("+num2str(sizex)+","+num2str(sizey)+")"
End
/////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////


//**********************************************************************************************************************
//***********************                     **************************************************************************
//*********************** Scale uneven y-axis **************************************************************************
//***********************                     **************************************************************************
//**********************************************************************************************************************
//                                                                                                                     *
//**The Procedure is used to rescale a linecut (namemap) with uneven y-axis to be a even one                           *
//                                                                                                                     *
//**To use this procedure, you need to prepare a scaler, that is a 1D-wave (namecurve) with its value equal to the     *
//  uneven y-axis value of the linecut, make sure the correct one-to-one correspondance,  namecurve[p] --> namemap[q]  *
//                                                                                                                     *
//**The prepare the scaler, you should make sure ******* dimsize($namecurve,0)= dimsize($namemap,1) ********************
//                                                                                                                     *
//**you may encounter a situation that the y-axis is like "0.01,0.02,0.5,0.6,0.5", in this case you may need to        *
//  interpolate the "mapcorrect" to be a point number much larger than the original "namemap", please try "factor"     *
//                                                                                                                     *
//**********************************************************************************************************************
Function ButtonProc_rescalemapasa1dcurve(ctrlName) : ButtonControl
	String ctrlName
	Execute "rescalemapasa1dcurve()"
End
//**********************************************************************************************************************
Proc rescalemapasa1dcurve(namemap,namecurve,Howmany)
	String namemap = tpw()
	String namecurve = "temperature"
	variable Howmany = dimsize($tpw(),1)

	Prompt namemap, "The source map"
	Prompt namecurve, "The uneven y-axis wave"
	Prompt Howmany, "How many dimsize(y) you want"
	//factor =5
	NaN0(namemap)
	rescalemapasa1dcurveF(namemap,namecurve,Howmany)
	linkEDCs(namemap,namecurve,Howmany)
	//rescalemapasa1dcurveF(namemap,namecurve)
	//linkEDCs(namemap,namecurve)
	killEDCs(namemap)
	zeroNaN(namemap)
	zeroNaN("mapcorrect")
	string newname
	newname = "even_"+namemap
	string toexecut
	toexecut = "rename mapcorrect "+newname
	Execute toexecut
end

Function rescalemapasa1dcurveF(namemap,namecurve,factor)
	String namemap
	String namecurve
	Variable factor

	wave namemapw = $namemap
	wave namecurvew = $namecurve

	String slice
	variable i
	i=0
	do
		slice = "EDCmapsts"+num2str(i)
		make/o/n=(dimsize(namemapw,1)) $slice
		//make/o/n=743 $slice
		wave slicew = $slice

		String dest
		dest=slice+"_L"
		wave destw = $dest

		slicew[] = 	namemapw[i][p]
		//Interpolate2/T=1/N=(factor*dimsize(namemapw,1)) namecurvew,slicew;
		Interpolate2/T=1/N=(factor) namecurvew,slicew;

		i+=1

	while(i<dimsize(namemapw,0))
end

Function linkEDCs(namemap,namecurve,factor)
	string namemap
	String namecurve
	variable factor

	wave namemapw = $namemap
	wave namecurvew = $namecurve
	wavestats/Q namecurvew

	variable i,j

	//make/o/n=(dimsize(namemapw,0),factor*dimsize(namemapw,1)) mapcorrect
	make/o/n=(dimsize(namemapw,0),factor) mapcorrect
	setscale/p x, dimoffset(namemapw,0),dimdelta(namemapw,0),"",mapcorrect
	setscale/I y, V_min,V_max,"",mapcorrect

	String name

	i=0
	do
		name="EDCmapsts"+num2str(i)+"_L"
		wave namew = $name

		j=0
		do
			mapcorrect[i][j]=namew[j]
			j+=1
		while(j < dimsize(namew,0))
		i+=1

	while(i<dimsize(namemapw,0))
	display;appendimage mapcorrect
	ModifyImage mapcorrect ctab= {*,*,VioletOrangeYellow,0}
end

Function killEDCs(namemap)
	string namemap
	wave namemapw = $namemap

	variable i
	String name, name1

	i=0
	do
		name="EDCmapsts"+num2str(i)+"_L"
		name1="EDCmapsts"+num2str(i)

		wave namew = $name
		wave name1w = $name1

		killwaves namew name1w
		i+=1
	while(i<dimsize(namemapw,0))
END
//**********************************************************************************************************************
//**********************************************************************************************************************
//**********************************************************************************************************************
//**********************************************************************************************************************
//**********************************************************************************************************************
//**********************************************************************************************************************
//**********************************************************************************************************************
Function ButtonProc_appendVline(ctrlName) : ButtonControl
	String ctrlName
	Execute "appendVline()"
End
///////////////////////////////////////////////////////
proc appendVline(yvalue,yincre,xrange,numbers,flag)
	Variable yvalue = 0
	variable yincre =3.8
	variable xrange = 9
	Variable numbers = 7
	variable flag =1
	Prompt yvalue, "start y value"
	Prompt yincre, "increment of Y"
	Prompt xrange, "x size of the line"
	Prompt numbers, "How manys lines append"
	Prompt flag,"append [1] or not [0]"

	appendVlineF(yvalue,yincre,xrange,numbers,flag)
	print "appendVline("+num2str(yvalue)+","+num2str(yincre)+","+num2str(xrange)+","+num2str(numbers)+","+num2str(flag)+")"

End

Function appendVlineF(yvalue,yincre,xrange,numbers,flag)
	Variable yvalue
	variable yincre
	variable xrange
	Variable numbers
	variable flag

	variable i
	string linename
	i=1
	do
		linename="lines"+num2str(i)
		make/N=2/o $linename
		wave linenamew=$linename

		setscale/I x, -xrange,xrange,"",linenamew
		linenamew = yvalue + (i-1)*yincre
		if (flag==1)
			appendtoGraph linenamew
			ModifyGraph lstyle($linename)=1,rgb($linename)=(65535,65535,65535), lsize($linename)=0.2

		else
		endif
		i+=1
	while (i<numbers+1)
end

Function ButtonProc_savepic(ctrlName) : ButtonControl
	String ctrlName
   print "SavePICT/E=-9"
End


Function ButtonProc_exitkm(ctrlName) : ButtonControl
	String ctrlName
	Execute "exitkm()"
End
Proc exitkm()
	KP_NanonisCleanup()
End

/////////////////////////////////////////
//Fix the data Jump,
//Instruction Pump the csr A at the left edge of the jump,
//put the csr B at the right edge of the jump
//run ddd("")
//This procedure will fix one jump each time.
//******Cautious, this procedure should be used only with the wareness
//******that no unreasonable data manipulation introduced!!!!

//New Version
Function ButtonProc_dddautoremovejump1DC(ctrlName) : ButtonControl
	String ctrlName
	Execute "autoremovejump1Dc()"
End
Proc autoremovejump1Dc(name,mode,valueif2)
	string name = tpw()
	variable mode //1 for auto, 2 for specified value
	variable valueif2 = 2*pi //only active in Mode 2
	prompt name,"the name of wave"
	prompt mode,"Auto or Given",popup "Auto;Given"
	prompt valueif2,"The Given jump value, only active in Mode 2"
	autoremovejump1D($name,mode,valueif2)
end


//////Old Version
Function ButtonProc_ddd(ctrlName) : ButtonControl
	String ctrlName
	Print "ddd_ff(tpw())"
end
Proc ddd_ff(name)
	String name = tpw()
	ddd_f(name)
end
Function ddd_f(name)
	String name

	variable i
	variable p0
	variable p1
	variable aa
	variable bb
	aa=vcsr(A)
	bb=vcsr(b)

	p0=pcsr(A)
	p1=pcsr(B)
	i=pcsr(A)
	do
		wave nn=$name

		nn[i]+=(aa-bb)
		i+=1
	while(i<dimsize(nn,0))
	variable bbb
	bbb=vcsr(b)
	nn[pcsr(A),pcsr(B)]=aa+(bbb-aa)*(P-pcsr(A))/(pcsr(B)-pcsr(A))
	//nn[p0,p1]=aa
end


//*************************************************************************
//*************************************************************************
// This is a special linecut procedure for nonequal evergy range slice, but
// you want to link them to a linecut
// Condition: you need to make sure all the slice share same dimdelta
// Condition: current procedure only support two sets of energy range that the second one is shorter than the first one, this is usually happen when measure tip height dependet dI/dV
// To Use: tell the procedure the number of the first sts have shorter energy range, then go.
//*************************************************************************
//*************************************************************************
Function ButtonProc_mapaa(ctrlName) : ButtonControl
	String ctrlName
	Execute "linkstsmap_Paa()"
end

proc linkstsmap_Paa(name,startnum,num,numc)
	string name="STS"
	variable startnum = 1
	variable num//=dimsize(file_name,0)-1
	variable numc = 91
	Prompt name,"Batch name"
	Prompt num,"Total number of STSs"
	Prompt startnum,"Make map start from which STS"
	Prompt startnum,"Make map start from which STS"
	Prompt numc,"STS number for shrink range happens"

	linkstsmapaa(name,num,startnum,numc)
	modifygraph width=250, height=450
	modifygraph width=0, height=0
end

Function linkstsmapaa(name,num,startnum,numc)
	string name
	variable num
	variable startnum
	variable numc

	variable i,j
	string mat,mat0
	mat0=name+num2str(1)
	wave m=$mat0
	make/o/n=(dimsize(m,0),num) mapsts
	mapsts = nan
	variable tt

	string matc
	matc=name+num2str(numc)
	wave m2=$matc
	variable startpoint
	startpoint=(dimoffset(m2,0)-dimoffset(m,0))/dimdelta(m,0)
	print startpoint
	i=0
	do
		j=0
		do
			mat=name+num2str(i+startnum)
			wave n=$mat

			if (i<numc-1)
			mapsts[j][i]=n[j]
			else

			mapsts[j+startpoint][i]=n[j]
			endif

			if (i<numc-1)
			tt = dimsize(m,0)
			else
			//tt= dimsize(sts91,0)+1
			//tt= 501
			tt= dimsize(m2,0)
			//print tt
			endif

			j+=1
		//while(j<dimsize(m,0))
		while(j<tt)
		i+=1
	while(i<num)
	setscale/P x, dimoffset(m,0),dimdelta(m,0),""mapsts
	display;appendimage mapsts
	modifygraph lsize=1
	ModifyGraph mirror=2
	ModifyGraph tick=2
	ModifyImage mapsts ctab= {*,*,VioletOrangeYellow,0}
	Label left "\Z20\F'times'Distance (Å\M\F'times'\Z20)";DelayUpdate
	Label bottom "\\Z20\F'times'Sample Bias\M\F'times'\Z20 (meV)"
	modifygraph width=250, height=450
	modifygraph width=0,height=0
	print "linkstsmap_P("+"\""+name+"\""+","+num2str(num)+","+num2str(startnum)+num2str(numc)+")"
end


//*************************************************************************
//*************************************************************************
// This is a special linecut procedure for nonequal evergy range slice [applicable for 2 sets], but
// you want to link them to a linecut
// Condition: you need to make sure all the slice share same dimdelta
// Condition: current procedure only support two sets of energy range that the second one is shorter than the first one, this is usually happen when measure tip height dependet dI/dV
// To Use: tell the procedure the number of the two first sts have shorter energy range, then go.
//*************************************************************************
//*************************************************************************
Function ButtonProc_mapaa2(ctrlName) : ButtonControl
	String ctrlName
	Execute "linkstsmap_Paa2()"
end

proc linkstsmap_Paa2(name,startnum,num,numc,numc2)
	string name="STS"
	variable startnum = 1
	variable num//=dimsize(file_name,0)-1
	variable numc = 91
	variable numc2
	Prompt name,"Batch name"
	Prompt num,"Total number of STSs"
	Prompt startnum,"Make map start from which STS"
	Prompt startnum,"Make map start from which STS"
	Prompt numc,"STS number for shrink range happens (1st)"
	Prompt numc2,"STS number for shrink range happens (2nd)"

	linkstsmapaa2(name,num,startnum,numc,numc2)
	modifygraph width=250, height=450
	modifygraph width=0, height=0
end

Function linkstsmapaa2(name,num,startnum,numc,numc2)
	string name
	variable num
	variable startnum
	variable numc
	variable numc2

	variable i,j
	string mat,mat0
	mat0=name+num2str(1)
	wave m=$mat0
	make/o/n=(dimsize(m,0),num) mapsts
	mapsts = nan
	variable tt

	string matc
	matc=name+num2str(numc)
	wave m2=$matc
	variable startpoint
	startpoint=(dimoffset(m2,0)-dimoffset(m,0))/dimdelta(m,0)
	print startpoint


	string matc2
	matc2=name+num2str(numc2)
	wave m22=$matc2
	variable startpoint2
	startpoint2=(dimoffset(m22,0)-dimoffset(m,0))/dimdelta(m,0)
	print startpoint2


	i=0
	do
		j=0
		do
			mat=name+num2str(i+startnum)
			wave n=$mat

			if (i<numc-1)
			mapsts[j][i]=n[j]
			else

				if (i >=numc-1 && i<numc2-1)

				mapsts[j+startpoint][i]=n[j]

				else

				mapsts[j+startpoint2][i]=n[j]
				endif
			endif


			if (i<numc-1)
			tt = dimsize(m,0)
			else
			//tt= dimsize(sts91,0)+1
			//tt= 501
				if (i >=numc-1 && i<numc2-1)

				tt= dimsize(m2,0)

				else

				tt= dimsize(m22,0)
				endif

			//print tt
			endif

			j+=1
		//while(j<dimsize(m,0))
		while(j<tt)
		i+=1
	while(i<num)
	setscale/P x, dimoffset(m,0),dimdelta(m,0),""mapsts
	display;appendimage mapsts
	modifygraph lsize=1
	ModifyGraph mirror=2
	ModifyGraph tick=2
	ModifyImage mapsts ctab= {*,*,VioletOrangeYellow,0}
	Label left "\Z20\F'times'Distance (Å\M\F'times'\Z20)";DelayUpdate
	Label bottom "\\Z20\F'times'Sample Bias\M\F'times'\Z20 (meV)"
	modifygraph width=250, height=450
	modifygraph width=0,height=0
	print "linkstsmap_Paa2("+"\""+name+"\""+","+num2str(num)+","+num2str(startnum)+num2str(numc)+num2str(numc2)+")"
end


////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
//** Input the name of a 2D matrix, convert the x scale from
//** wavelength (nm) to Energy (eV)
//
//**This procedure works on interpolate data, the 2D matrix is the
//**matrix after removing uneven Y space.
//
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
Function ButtonProc_reorg2ndd(ctrlName) : ButtonControl
	String ctrlName
	Execute "reorg2ndd()"
end
proc reorg2ndd(name)
	string name
	Prompt name,"name of the matrix to be manipulated"
	slicemdc($name)
	string nameslice = name+"_mdc"
	dsd(nameslice,name)
end
Function slicemdc(name)
	wave name
	variable i
	string slicename
	i=0
	do
		slicename=nameofwave(name)+"_mdc"+num2str(i+1)
		make/o/N=(dimsize(name,0))  $slicename
		wave slicenamew = $slicename
		slicenamew[]=name[p][i]
		i+=1
	while (i<dimsize(name,1))
end
proc dsd(name,n2)
	string name
	string n2

	//Create destination X wave
	make/o/N=(dimsize($n2,0)) xvalue
	xvalue=dimoffset($n2,0)+dimdelta($n2,0)*p
	duplicate/o xvalue xev
	xev= 1239.8/xvalue // Xev is (eV), and xvalue is (nm)

	string sts
	string stsev,stsev2
	stsev2=name+"ev"
	variable i
	i=0
	do
		sts=name+num2str(i+1)
		stsev=name+"ev"+num2str(i+1)

		Interpolate2/T=2/N=(3*dimsize($sts,0))/E=2/Y=$stsev xev, $sts
		i+=1
	while (i<dimsize($n2,1))
	linkstsmap_Pev(stsev2,1,dimsize($n2,1))
	string map2ndname = n2+"_Xconverted"
	duplicate/o mapstsev $map2ndname
	killwaves mapstsev
	displaymulti(stsev2,1,dimsize($n2,1))
	SetAxis bottom 1.2,3
	di($map2ndname)
	setscale/p y,dimoffset($n2,1),dimdelta($n2,1),"",$map2ndname
	//rescalemapasa1dcurve("mapsts","aa",dimsize($n2,1))
	•Label bottom "Energy (eV)"
	•Label left "Temperature (K)"
	•ModifyGraph nticks=10,minor=1
	//•ModifyImage mapcorrect ctab= {0,30,VioletOrangeYellow,0}
	 SetAxis bottom 1.2,3
	 SetAxis left 2.5,294.5

end

proc linkstsmap_Pev(name,startnum,num)
	string name="STS"
	variable startnum = 1
	variable num//=dimsize(file_name,0)-1
	Prompt name,"Batch name"
	Prompt num,"Total number of STSs"
	Prompt startnum,"Make map start from which STS"
	linkstsmapev(name,num,startnum)
end
Function linkstsmapev(name,num,startnum)
	string name
	variable num
	variable startnum
	variable i,j
	string mat,mat0
	mat0=name+num2str(1)
	wave m=$mat0
	make/o/n=(dimsize(m,0),num) mapstsev
	i=0
	do
		j=0
		do
			mat=name+num2str(i+startnum)
			wave n=$mat
			mapstsev[j][i]=n[j]
			j+=1
		while(j<dimsize(m,0))
		i+=1
	while(i<num)
	setscale/P x, dimoffset(m,0),dimdelta(m,0),""mapstsev
end
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
//** Input the name of a sts batch, convert the x scale from
//** wavelength (nm) to Energy (eV),
//
//**This procedure works on raw sts
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
proc STSev(name,num)
	string name = "sts" // sts name
	variable num = dimsize(file_name,0)-1

	make/o/N=(dimsize(sts1,0)) xvalue
	xvalue=dimoffset(sts1,0)+dimdelta(sts1,0)*p
	duplicate/o xvalue xev
	xev= 1239.8/xvalue

	string stsev,stsev2
	stsev2=name+"evv"
	variable i
	string ssev

	i=0
	do
		ssev=name+num2str(i+1)
		stsev=stsev2+num2str(i+1)
		Interpolate2/T=2/N=(3*dimsize($ssev,0))/E=2/Y=$stsev xev, $ssev

		i+=1
	while (i<num)

	 displaymulti(stsev2,1,num)
	 SetAxis bottom 1.2,3
	 	•Label bottom "Energy (eV)"

end
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
//*********** Correct gate leak **************************
/////////////////////////////////////////////////////////////////////////////////////////////////////
// This procedure can make a 2D wave with each 1D curve has different x scale
// This is useful for example to a gate map, there is a small gate leak that makes each gate the bias
// is shifted a bit. In that case, we can extract the real zero bias by fitting the two coherent peak
// and calculate the average, then put the 1D wave contains the information of zero bias into correct2Dmapc()
//*****
// Before launch this procedure, please make sure the waterfall of the gatemap is on graph and active
//*****
// if the zero bias 1D wave can be extracted from the same waterfall, please use getZB(,,,) for the
// string input, if can not, you need to make the zero bias wave first, and put in the name.
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

Function ButtonProc_correct2Dmapc(ctrlName) : ButtonControl
	String ctrlName
	Execute "correct2Dmapc()"
end

proc correct2Dmapc(indicate,zbwavename)
	String Indicate = "Must with Waterfall graph in active"
	string zbwavename = "getZB(-3,-1,1,3)"
	Prompt Indicate,"Notice!!! Before Lauch"
	Prompt zbwavename,"please enter the name of a 1D wave containing the real zero bias voltage of different gate voltages, \rif this wave can be extracted from the same watefall, please enter \r \"getZB(l1,l2,r1,r2)\"\r l1, V(left,1)\r l2, V(left,2)\r r1, V(right,1)\r r2, V(right,2)"

	string aaaa
	aaaa = "correct2Dmap("+zbwavename+")"
	print aaaa
	if (str2num(StringByKey("getzb",zbwavename,"(")) == NaN)
		correct2Dmap($zbwavename)
	else
		//aaaa = "correct2Dmap("+zbwavename+")"
		Execute aaaa
	endif

end

Function correct2Dmap(zerobiaswave)
	wave zerobiaswave
	string mat =WaveList("*", ";","WIN:")
	variable num = itemsInList(mat)
	string winn = winname(0,1)
	string matuse,dest
	string mat1=stringfromList(0,mat)
	wave mat1w = $mat1
	string map2dz = mat1+"_2Dz"
	make/N=(dimsize(mat1w,0),num)/o $map2dz
	wave map2dzw = $map2dz

	string map2dx = mat1+"_2Dx"
	make/N=(dimsize(mat1w,0),num)/o $map2dx
	wave map2dxw = $map2dx
	variable i

	string map2dy = mat1+"_2Dy"
	make/N=(dimsize(mat1w,0),num)/o $map2dy
	wave map2dyw = $map2dy
	string batchname = replaceString("1",stringfromList(0,WaveList("*", ";","WIN:")),"")
	//wave biasshift = getbiasshiftwave(l1,l2,r1,r2)
	i=0
	do
		matuse=stringfromList(i,mat)
		wave matusew =$matuse
		map2dzw[][i]=matusew[p]
		map2dxw[][i]=(dimoffset(matusew,0)-zerobiaswave[i])+p*dimdelta(matusew,0)
		map2dyw[][i] = i
		dest="crt"+"_"+stringfromList(i,WaveList("*", ";","WIN:"))
		duplicate/o matusew $dest
		setscale/P x,(dimoffset($matuse,0)-zerobiaswave[i]),dimdelta($matuse,0),"",$dest
		i+=1
	while (i < num)
	//di(map2dzw)
	//di(map2dyw)
	//di(map2dxw)

		string name = mat1
		string outputLF = "correct_"+name
		string zzlf="zz_"+name
		duplicate/o map2dzw $zzlf
		wave zzlfw = $zzlf
		Redimension/N=(dimsize(zzlfw,0)*dimsize(zzlfw,1)) zzlfw

		string xxlf="xx_"+name
		duplicate/o map2dxw $xxlf
		wave xxlfw = $xxlf
		Redimension/N=(dimsize(xxlfw,0)*dimsize(xxlfw,1)) xxlfw

		string yylf="yy_"+name
		duplicate/o map2dyw $yylf
		wave yylfw = $yylf
		Redimension/N=(dimsize(yylfw,0)*dimsize(yylfw,1)) yylfw
		//edit zzlfw xxlfw yylfw


		//** scatterinterp(xxlfw,yylfw,zzlfw,namew,factor)

				Make/O/N=(dimsize(xxlfw,0),3) sampleTripletbias
				sampleTripletbias[][0]=xxlfw[p]
				sampleTripletbias[][1]=yylfw[p]
				sampleTripletbias[][2]=zzlfw[p]
				ImageInterpolate/RESL={(1.5*dimsize(mat1w,0)),(num)}/DEST=$outputLF voronoi sampleTripletbias

				killwaves sampleTripletbias xxlfw yylfw zzlfw
		//** Plot
			wave outputLFw = $outputLF
			//func_NaN0(outputLFw)
			di(outputLFw)
			modifygraph width=250, height=450
			modifygraph lsize=1
			ModifyGraph mirror=2
			ModifyGraph tick=2
			//ModifyImage outputLFw ctab= {*,*,VioletOrangeYellow,0}
			Label left "\Z20\F'times'Gate (V)";DelayUpdate
			Label bottom "\\Z20\F'times'Sample Bias\M\F'times'\Z20 (mV)"
			//TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "LF Correction"
			string mapsts = "mapsts"
			wave mapstsw = $mapsts
			setscale/p y,dimoffset(mapstsw,1),dimdelta(mapstsw,1),"",outputLFw
			//modifygraph width=0, height=0


	//** plot corrected waterfall
	string batchc = "crt"+"_"+batchname
	display
	displaymultiF(batchc,1,dimsize(outputLFw,1))
	ckfig(winname(0,1))
	wavestats/Q outputLFw
	Constantoffset_nF(3*V_max/dimsize(outputLFw,1),1)
	modifygraph width=250, height=450
	//modifygraph width=0, height=0
	execute "color_edc_more2()"


	//** Error message, no stop but Continuing execution
		String msg
		Variable err
		msg=GetErrMessage(GetRTError(0),3);
		err=GetRTError(1)
		if (err != 0)
			//Print "Error in Demo: " + msg
			//Print "Continuing execution"
		endif
end
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
Proc getzbc(l1,l2,r1,r2)
	variable l1
	variable l2
	variable r1
	variable r2
	prompt l1,"V (left,1)"
	prompt l2,"V (left,2)"
	prompt r1,"V (right,1)"
	prompt r1,"V (right,2)"
	getzb(l1,l2,r1,r2)
End


Function/wave getzb(l1,l2,r1,r2)
	variable l1
	variable l2
	variable r1
	variable r2
	string winn = winname(0,1)
	string mat =WaveList("*", ";","WIN:")
	string pleft="left"+"_"+stringfromList(0,mat)+"_p"
	string pright="right"+"_"+stringfromList(0,mat)+"_p"
	getpeakfromwaterfall(l1,l2,"left")
	getpeakfromwaterfall(r1,r2,"right")
	wave prightw = $pright
	wave pleftw = $pleft
	string rzerobiasp ="zerobias_"+stringfromList(0,mat)
	duplicate/o prightw $rzerobiasp
	wave rzerobiaspw=$rzerobiasp
	rzerobiaspw=(prightw+pleftw)/2
	killwaves prightw pleftw
	ed(rzerobiaspw)
	display rzerobiaspw
	print nameofwave(rzerobiaspw)
	Dowindow/F $winn

	return rzerobiaspw
End

Function getpeakfromwaterfall(left,right,ss)
	variable left
	variable right
	string ss
	string mat =WaveList("*", ";","WIN:")
	variable num = itemsInList(mat)
	string winn = winname(0,1)
	variable i
	string matuse,dest,W_coefs,ddd
	W_coefs = "W_coef"
	string peakpclb=ss+"_"+stringfromList(0,mat)+"_p"
	make/o/N=(num) $peakpclb
	wave peakpclbw = $peakpclb
	i=1
	do
		matuse=stringfromList(i-1,mat)
		ddd=ss+"_fit"+matuse
		//dest=ss+"_"+matuse
		wave matusew = $matuse
		Duplicate/o matusew $ddd
		wave dddw=$ddd
		CurveFit/Q/N=2/W=2 gauss, matusew(left,right)/D=$ddd
		killwaves dddw
		wave W_coef = $W_coefs
		peakpclbw[i-1]=W_coef[2]
		//duplicate/o matusew $dest
		//setscale/P x,(dimoffset($matuse,0)-W_coef[2]),dimdelta($matuse,0),"",$dest
		i+=1
	while(i<num+1)
	//ed(peakpclbw)
	Dowindow/F $winn
End

/////////////////////////////////////////////////////////////////////
//get peak
Function ButtonProc_getpeakfromwfc(ctrlName) : ButtonControl
	String ctrlName
	Execute "getpeakfromwaterfallc()"
end
Proc getpeakfromwaterfallc(l1,l2,ss)
	variable l1 = xcsr(A)
	variable l2 = xcsr(B)
	string ss ="Fit_"
	prompt l1,"V(left)"
	prompt l2,"V(right)"
	prompt ss,"name"
	getpeakfromwaterfall2(l1,l2,ss)
End

Function getpeakfromwaterfall2(left,right,ss)
	variable left
	variable right
	string ss
	string mat =WaveList("*", ";","WIN:")
	variable num = itemsInList(mat)
	string winn = winname(0,1)
	variable i
	string matuse,dest,W_coefs,ddd
	W_coefs = "W_coef"
	wave W_coef = $W_coefs
	string peakpclb=ss+"_"+stringfromList(0,mat)+"_p"
	make/o/N=(num) $peakpclb
	wave peakpclbw = $peakpclb

	string peakwclb=ss+"_"+stringfromList(0,mat)+"_w"
	make/o/N=(num) $peakwclb
	wave peakwclbw = $peakwclb
	i=1
	do
		matuse=stringfromList(i-1,mat)
		ddd=ss+"_fit"+matuse
		wave dddw=$ddd
		//dest=ss+"_"+matuse
		wave matusew = $matuse
		Duplicate/o matusew $ddd
		CurveFit/Q/N=2/W=2 gauss, matusew(left,right)/D=$ddd
		killwaves dddw
		peakpclbw[i-1]=W_coef[2]
		peakwclbw[i-1]=W_coef[3]
		//duplicate/o matusew $dest
		//setscale/P x,(dimoffset($matuse,0)-W_coef[2]),dimdelta($matuse,0),"",$dest
		i+=1
	while(i<num+1)
	edit peakpclbw peakwclbw
	ckfig(winname(0,2))
	display peakpclbw
	ckfig(winname(0,1))
	display peakwclbw
	ckfig(winname(0,1))
	Dowindow/F $winn
End
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
// End of correct gate leak
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
// remove linear background from a waterfall
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

Function ButtonProc_linenorm2pongraphc(ctrlName) : ButtonControl
	String ctrlName
	Execute "linenorm2pongraphc()"
	end

Proc linenorm2pongraphc(p1,p2)
	variable p1 = pcsr(A)
	variable p2 = pcsr(B)
	Prompt p1,"P_start"
	Prompt p2,"P_end"

	linenorm2pongraph(p1,p2)
End

Function linenorm2pongraph(p1,p2)
	variable p1
	variable p2

	string mat =WaveList("*", ";","WIN:")
	variable num = itemsInList(mat)
	string winn = winname(0,1)
	variable i
	string matuse
	i=0
	do
		matuse=stringfromList(i,mat)
		wave matusew = $matuse
		linenorm2pf(matusew,p1,p2)
		i+=1
	while(i < num)
end

Function linenorm2pf(mat,p1,p2)
	wave mat
	variable p1
	variable p2
	variable a,b
	make/o/n=(dimsize(mat,0)) line2p
	setscale/p x, dimoffset(mat,0),dimdelta(mat,0),"",line2p
	//a=(vcsr(B)-vcsr(A))/(hcsr(B)-hcsr(A))
	a=(mat[p2]-mat[p1])/((dimoffset(mat,0)+dimdelta(mat,0)*p2)-(dimoffset(mat,0)+dimdelta(mat,0)*p1))
	b=mat[p2]-a*(dimoffset(mat,0)+dimdelta(mat,0)*p2)
	line2p=a*x+b
	mat-=line2p
End
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
// End of remove linear background from a waterfall
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////


Function ButtonProc_convertG(ctrlName) : ButtonControl//"Load BNL Data in Folder"
	String ctrlName
	Execute "tta()"
End


proc tta(name,setpointv,currentwave)
	string name="data"
	variable setpointv = 10 // unit mV
	string currentwave = "wave1" // unit nA
	Prompt name,"Name of the data set"
	Prompt setpointv,"Voltage setpoint (mV)"
	Prompt currentwave,"The name of the wave of current (nA)"
	duplicate /o $currentwave setpointasG;
	setpointasG = 25.8131/(setpointv/($currentwave/1000));
	duplicate/o setpointasG nanonisdidv;
	linkstsmap_P(name,1,dimsize(file_name,0)-1)
	nanonisdidv[]=mapsts[0][p];
	display nanonisdidv;
	duplicate/O nanonisdidv ratiogn;
	ratiogn= nanonisdidv/setpointasG;
	display ratiogn;

	string nameconv
	nameconv = name+"conv"

	duplicateall(name,nameconv,"",dimsize(file_name,0)-1)
	variable i
	string dataname
	i=1
	do
	dataname=nameconv+num2str(i)
	$dataname/=ratiogn[i-1]
	i+=1
	while(i<dimsize(file_name,0))
	duplicate/o mapsts mapraw
	linkstsmap_P(nameconv,1,dimsize(file_name,0)-1)

end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//                             ##author## Lingyuan Kong 07/08/2023
//
//This procedure is used to extract the position of phase jump, creat phase jump line wave, and remove jump
//
//							     ** The algrithom is as follow **
//
//(1) The DATA_INPUT is the 2D matrix with x and y value scaled.
//(2) Recognize the direction of phase jumpping, doing FFT to the DATA_INPUT, and check which
//	  quadrant the maximum FFT peal exist. Depends on the results to choice the modes later
//(3) Slicing the DATA_INPUT to be MDCs.
//(4) Find phase jumpping P and X in each MDCs, by Function "findjumpslice()", the condtion for
//    For determine the jump, is based on the jumpheight in the DATA_INPUT, it can be tuned by
//	  the variable "jumpheight". findjumpslice() will generate dimsize(DATA_INPUT,1) numbers
//    horizental intermedia waves contain all the phase jumping position, both the P value and X
//    value are saved individually in different sets of waves following the sequence of MDCs.
//	  *On each phase jumpping point, both the upstair and down stair points are saved, at the wave
//    name, they are indicated by "h" or "l", respectively.
//    (4*) There is a intermedia steps for check the correctness of the code
//      Plot these horizental intermedia waves as Ywave vs Xwaves, these Ywaves are generated by
//	    converting the MDC index to Y value of the DATA_INPUT. The function is appendattractedmin_max()
//	    * This function is alway muted (by the parameter "killim"), and these intermedia horizental
//        waves are always killed at the ends, except set killim = 0 for compling test.
//(5) Add integer times of some value monotonically to different domain. This is helped by the intermedia
//    horizental waves extracted in step (4). The points in the intermedia wave difine the position in the
//    DATA_INPUT that are different by 1*value. The main difficulty to realize this code is to determine the
//    j position that the starting value increase by value in the MDC slice. The method is to make use of a
//    variable "count" to indicate, details see step (6).
//(6) Reorder those horizental intermedia waves into phase jumping line waves, by the function
//    reorganizedata().
//		<6-1> Create overcounted number of waves in each destination set. The real number is equal
//			  to the number of phase jumping line in the DATA_INPUT. All the destination waves
//            are initialized to be Nan.
//		<6-2> Put the value of intermedia waves into the destination waves.
//            *Outmost cycles "j" is on the Q of the DATA_INPUT, inner cycles "jjj" is no
//             dimsize(intermedia wave(j),0). That is dealling with each MDC labelled intermedia
//			   waves one by one.
//            *When put the value of intermedia waves into destination wave, check the position of
//			   the first Nan value by the function checkfirstNonnan(), and then put the value on the site.
//            *Indentify the j posiotn to increase the index of destination wave by the variable "count",
//			   the condition is to check the different of adjacent intermedia wave[0], when the different
//			   jump, the count will be added by 1. The threshhold is initialized by the half of the phase
//			   jumpping line spacing along MDC direction.
//			  *Remove redundant data points and redundant waves from the destination sets.
//			  *Count the number of waves in each destination set, and display or not (controlled by "don")
//            *kill the intermedia horizental waves (or not), controlled by "killim".
//		<6-3> Check error function, print error information without interup the function (muted).
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//UPDATE log 09/07-2023
//	  After add smartDisplay to Kong's Igor Panel, we removed the variable "don", instead use new functions
//	  ckfig() and cklayout() to check if it is should be displayed or not automatically. Also the di() in
//    Kong's Igor Panel was also updated, the internal codes can determine display or not to avoid redudant
//    displays. These features can also be applied to other codes, I can modify them later.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////   Main function   ////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_autormjump2DPro(ctrlName) : ButtonControl
	String ctrlName
	Execute "autormjump2DPro()"
end
Proc autormjump2DPro(name,jumpheight,killim,add1)
	String name ="aa"
	variable jumpheight = 3.01
	variable killim = 1// kill (1) or not kill (0) intermedia waves, that is the horizental waves from fit
	variable add1 = pi
	prompt name,"The DATA INPUT (must be a 2D matrix)"
	prompt jumpheight,"dZ threshhold for testing jumpping position"
	Prompt killim,"kill intermedia wave (1), or not (0)"
	Prompt add1,"unit of value add to data"
	autoromvejump2D(name,jumpheight,killim,add1)
end
////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function autoromvejump2D(name,jumpheight,killim,add1)
	String name
	variable jumpheight
	variable killim// kill (1) or not kill (0) intermedia waves, that is the horizental waves from fit
	variable add1

	Wave namew=$name
	String MDC=name+"_MDC"
	Make/o/N=(dimsize(namew,0)) $MDC
	Setscale/p x,dimoffset(namew,0),dimdelta(namew,0),"",$MDC
	Wave MDCw=$MDC

	////////////////////////////Select mode for different slanted data
	variable sel //select mode, 0 is 2/4 quadrant, 1 is first 1/3 quadrant.
	String selfft = MDC+"_FFT"
	wave selfftw = $selfft
	FFT/OUT=3/WINF=Hanning/DEST=$selfft  namew
	wavestats/Q $selfft
	//killwaves $selfft
	if (sign(V_maxColLoc) == -1)
		sel = 1
	endif
	if (sign(V_maxColLoc) == 1)
		sel = 0
	endif
	////////////////////////////Select mode for different slanted data


	variable ycor //scaled y value of the MDC slice label by i
	///////////////////////////////////////////////////////////////////////////////////
	//Start From here, let us find all the positions have a phase jump, MDC modes
	variable i
	i=0
	do
		MDCw[]=namew[p][i]
		ycor = dimoffset(namew,1)+i*dimdelta(namew,1)
		string mdcww = MDC+num2str(i)
		duplicate/o MDCw $mdcww
		//print ycor
		findjumpslice(MDCww,jumpheight)
		killwaves $MDCww
		//killwaves $mdc
		i+=1
	while (i < dimsize(namew,1))

	if (killim == 1)
	endif

	if (killim == 0)
		appendattractedmin_max(MDC,namew) // plot them (horizental waves)
	endif
	//////////////////////////////////////////////////////////////////////////////
	//to sequently remove the phase jump from the data input
	sftvfollowjump(MDC,namew,sel,add1)

	//Start From here, reorganize the extracted phase jump position to be phase jumping line
	reorganizedata(MDC,namew,50,sel,killim)
	tilewindows/WINS=WinList("*", ";","WIN:1")/R/w=(4,0,56,80)

End
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
Function findjumpslice(MDCww,jumpheight) //Locate the position of jump, use MDC to extract.
	String MDCww // MDC slice name
	variable jumpheight
	//String name // the name of the matrix
	wave MDCw=$MDCww
	variable i,different,countnum
	string plwave,xlwave,phwave,xhwave
	plwave="plwave"+MDCww
	xlwave="xlwave"+MDCww
	phwave="phwave"+MDCww
	xhwave="xhwave"+MDCww
	make/N=(dimsize(MDCw,0),0)/o $plwave
	make/N=(dimsize(MDCw,0),0)/o $xlwave
	make/N=(dimsize(MDCw,0),0)/o $phwave
	make/N=(dimsize(MDCw,0),0)/o $xhwave

	wave plwavew=$plwave
	wave xlwavew=$xlwave
	wave phwavew=$phwave
	wave xhwavew=$xhwave

	countnum=0
	i=0
	do
	different=MDCw[i+1]-MDCw[i]
	if (different < -jumpheight) //this is the selection condition
		countnum+=1

		plwavew[countnum-1]=i+1
		phwavew[countnum-1]=i
		xlwavew[countnum-1]=dimoffset(MDCw,0)+(i+1)*dimdelta(MDCw,0)
	    xhwavew[countnum-1]=dimoffset(MDCw,0)+(i)*dimdelta(MDCw,0)

	else
	endif
	i+=1
	while(i<dimsize(MDCw,0)-1)
	redimension/N=(countnum) plwavew,phwavew,xlwavew,xhwavew
	//edit plwavew,xlwavew,phwavew,xhwavew
End
///////////////////////////////////////////////////////////////////////////
Function appendattractedmin_max(MDC,namew) //plot the extracted positions.
	String MDC
	wave namew

	display
	variable i

	i=0
	do
		string mdcww = MDC+num2str(i)
		string plwave,xlwave,phwave,xhwave
		plwave="plwave"+MDCww
		xlwave="xlwave"+MDCww
		phwave="phwave"+MDCww
		xhwave="xhwave"+MDCww
		wave plwavew=$plwave
		wave xlwavew=$xlwave
		wave phwavew=$phwave
		wave xhwavew=$xhwave
		string ycor = "ycor"+MDC+num2str(i)
		make/o/N=(dimsize(plwavew,0)) $ycor
		wave ycorw=$ycor

		string ycorh = "ycorh"+MDC+num2str(i)
		make/o/N=(dimsize(plwavew,0)) $ycorh
		wave ycorhw=$ycorh

		ycorw=dimoffset(namew,1)+i*dimdelta(namew,1)


		ycorhw=ycorw
		appendtoGraph ycorw vs xlwavew
		ModifyGraph mode($ycor)=3,marker($ycor)=19,msize($ycor)=1
		appendtoGraph ycorhw vs xhwavew
		ModifyGraph mode($ycorh)=3,marker($ycorh)=19,msize($ycorh)=1,rgb($ycorh)=(0,0,65535)

	    i+=1

	while (i < dimsize(namew,1))
	ModifyGraph width={Plan,1,bottom,left}
	ckfig(winname(0,1))
end

//////////////////////////////////////////////////////////////////////////////////////////////
Function checkfirstNonnan(name)
	Wave name
	variable i,pp,qq
	i=0
	pp=0
	qq=nan
	do
		if(mod(Round(name[i]),1)!=0)
			pp+=1
			if(pp == 1)
			 qq=i
			else
			endif

		Endif

	i+=1
	while(i < dimsize(name,0))
	return qq
end
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//From multiple horizental waves to construct the slanted wave
Function reorganizedata(MDC,namew,initialnum,sel,killim)
	String MDC
	Wave namew
	variable initialnum //how many lines you want to initialy create
	variable sel //select mode, 0 is 2/4 quadrant, 1 is first 1/3 quadrant.
	variable killim// kill (1) or not kill (0) intermedia waves, that is the horizental waves from fit

	//*********** make initial NAN Matrix for reordered data
	variable k
	k=1
	string pl,ph,xl,xh,ly,lq
	do
		pl="pl"+MDC+num2str(k)
		xl="xl"+MDC+num2str(k)
		ph="ph"+MDC+num2str(k)
		xh="xh"+MDC+num2str(k)
		make/o/N=(dimsize(namew,0)) $pl
		make/o/N=(dimsize(namew,0)) $ph
		make/o/N=(dimsize(namew,0)) $xl
		make/o/N=(dimsize(namew,0)) $xh
		wave plw1=$pl
		wave phw1=$ph
		wave xlw1=$xl
		wave xhw1=$xh
		plw1=nan
		phw1=nan
		xlw1=nan
		xhw1=nan

		ly="ly"+MDC+num2str(k)
		lq="lq"+MDC+num2str(k)
		make/o/N=(dimsize(namew,0)) $ly
		make/o/N=(dimsize(namew,0)) $lq
		wave lyw1=$ly
		wave lqw1=$lq
		lyw1=nan
		lqw1=nan
	k+=1
	while (k<initialnum+1)   /// make initialnum sets of jumpping lines. this number can be modified
	//*********** End make initial nan Matrix

	//****Initialized parameters
	variable count //Count will add 1 when the first data point in the horizental data change index in the destination matrix
	count = 0
	variable j
	string plwave,xlwave,phwave,xhwave,phadv
	variable jjj,jj
	variable dif
	variable interdatacondition // the condition to increase Count, this value is "how many P shifted", this need to be tuned, for evenly spaced case we have this default value calculated as following
	String getinterdatacondition
	variable getic= dimsize(namew,1)
	variable getic2 = round(getic/2)
	getinterdatacondition ="phwave"+MDC+num2str(getic2)
	wave getinterdataconditionw=$getinterdatacondition
	interdatacondition = round(abs(getinterdataconditionw[0] - getinterdataconditionw[1])/2)
	//****End initialize parameters

	//*********** Mode#1 Reorganize data
	if(sel == 0)
		j=0
		do
			plwave="plwave"+MDC+num2str(j)
			xlwave="xlwave"+MDC+num2str(j)
			phwave="phwave"+MDC+num2str(j)
			phadv="phwave"+MDC+num2str(j+1)
			xhwave="xhwave"+MDC+num2str(j)
			wave xlwavew=$xlwave
			wave phwavew=$phwave
			wave phadvw=$phadv
			wave xhwavew=$xhwave
			wave plwavew=$plwave

			jjj=1
			if (j< dimsize(namew,1)-1)
				dif = phadvw[0]-phwavew[0]
			else
			endif
			//print "dif is "+num2str(dif)
			if (dif > interdatacondition)
					jj = jjj+count
					count+=1
				else
					jj= jjj+count
				endif
			//print "count is "+num2str(count)+" ; j is "+num2str(j)+" start is "+num2str(start)
			do
				pl="pl"+MDC+num2str(jj)
				//print "		"+pl
				wave plw=$pl
				//plw[j-start]=plwavew[jjj-1]
				plw[checkfirstNonnan(plw)]=plwavew[jjj-1]
				//print "				"+pl+"["+num2str(j-start)+"]="+plwave+"["+num2str(jjj-1)+"]"

				ph="ph"+MDC+num2str(jj)
				wave phw=$ph
				phw[checkfirstNonnan(phw)]=phwavew[jjj-1]

			    xl="xl"+MDC+num2str(jj)
				wave xlw=$xl
				xlw[checkfirstNonnan(xlw)]=xlwavew[jjj-1]

				xh="xh"+MDC+num2str(jj)
				wave xhw=$xh
				xhw[checkfirstNonnan(xhw)]=xhwavew[jjj-1]

				lq="lq"+MDC+num2str(jj)
				wave lqw=$lq
				lqw[checkfirstNonnan(lqw)]=j

				ly="ly"+MDC+num2str(jj)
				wave lyw=$ly
				lyw[checkfirstNonnan(lyw)]=dimoffset(namew,1)+dimdelta(namew,1)*j

				jjj+=1
				jj+=1
			while(jjj<dimsize(plwavew,0)+1)
			j+=1
			//if (dif > 0)
			//		start = j
				//print "start is "+num2str(start)
			//	else
			//endif
		while (j < dimsize(namew,1))
	endif
	//*********** End Mode#1 *************************//


	//*********** Mode#2 Reorganize data
	if(sel == 1)
		j=dimsize(namew,1)-1

		do
			plwave="plwave"+MDC+num2str(j)
			xlwave="xlwave"+MDC+num2str(j)
			phwave="phwave"+MDC+num2str(j)
			phadv="phwave"+MDC+num2str(j-1)
			xhwave="xhwave"+MDC+num2str(j)
			wave xlwavew=$xlwave
			wave phwavew=$phwave
			wave phadvw=$phadv
			wave xhwavew=$xhwave
			wave plwavew=$plwave

			jjj=1
			if (j > 0)
				dif = phadvw[0]-phwavew[0]
			else
			endif
				//print "dif is "+num2str(dif)
			if (dif > interdatacondition)
					jj = jjj+count
					count+=1
				else
					jj= jjj+count
				endif
				//print "count is "+num2str(count)+" ; j is "+num2str(j)//+" start is "+num2str(start)

			do
				pl="pl"+MDC+num2str(jj)
				//print "		"+pl
				wave plw=$pl
				//plw[j-start]=plwavew[jjj-1]
				plw[checkfirstNonnan(plw)]=plwavew[jjj-1]
				//print "				"+pl+"["+num2str(j-start)+"]="+plwave+"["+num2str(jjj-1)+"]"

				ph="ph"+MDC+num2str(jj)
				wave phw=$ph
				phw[checkfirstNonnan(phw)]=phwavew[jjj-1]

			    xl="xl"+MDC+num2str(jj)
				wave xlw=$xl
				xlw[checkfirstNonnan(xlw)]=xlwavew[jjj-1]

				xh="xh"+MDC+num2str(jj)
				wave xhw=$xh
				xhw[checkfirstNonnan(xhw)]=xhwavew[jjj-1]


				lq="lq"+MDC+num2str(jj)
				wave lqw=$lq
				lqw[checkfirstNonnan(lqw)]=j


				ly="ly"+MDC+num2str(jj)
				wave lyw=$ly
				lyw[checkfirstNonnan(lyw)]=dimoffset(namew,1)+dimdelta(namew,1)*j

				jjj+=1
				jj+=1
			while(jjj<dimsize(plwavew,0)+1)
			j-=1
			//if (dif > 0)
			//		start = j
				//print "start is "+num2str(start)
			//	else
			//endif
		while (j > -1)
	endif
	//*********** End Mode#2 *************************//

	//*********** Remove the redundant data points and kill redundant waves
	variable kk
	kk=1
	do
		pl="pl"+MDC+num2str(kk)
		xl="xl"+MDC+num2str(kk)
		ph="ph"+MDC+num2str(kk)
		xh="xh"+MDC+num2str(kk)
		wave plw1=$pl
		wave phw1=$ph
		wave xlw1=$xl
		wave xhw1=$xh
		ly="ly"+MDC+num2str(kk)
		lq="lq"+MDC+num2str(kk)
		wave lyw1=$ly
		wave lqw1=$lq

		redimension/N=(checkfirstNonnan(plw1)) plw1
		redimension/N=(checkfirstNonnan(phw1)) phw1
		redimension/N=(checkfirstNonnan(xlw1)) xlw1
		redimension/N=(checkfirstNonnan(xhw1)) xhw1
		redimension/N=(checkfirstNonnan(lyw1)) lyw1
		redimension/N=(checkfirstNonnan(lqw1)) lqw1
		if (dimsize(plw1,0) <2 )
			killwaves plw1
		endif
		if (dimsize(phw1,0) <2 )
			killwaves phw1
		endif
		if (dimsize(xlw1,0) <2 )
			killwaves xlw1
		endif
		if (dimsize(xhw1,0) <2 )
			killwaves xhw1
		endif
		if (dimsize(lyw1,0) <2 )
			killwaves lyw1
		endif
		if (dimsize(lqw1,0) <2 )
			killwaves lqw1
		endif
	kk+=1
	while (kk<initialnum+1)
	//*********** End Remove and kill


	//*********** Count the number of the slanted line
	String listofwaves
	variable nwaves_pl,nwaves_ph,nwaves_xl,nwaves_xh,nwaves_ly,nwaves_lq
	listofwaves = WaveList("pl"+MDC+"**", ";", "");
	nwaves_pl = ItemsInList(listofwaves)
	//print nwaves_pl
	listofwaves = WaveList("ph"+MDC+"**", ";", "");
	nwaves_ph = ItemsInList(listofwaves)
	//print nwaves_ph
	listofwaves = WaveList("xl"+MDC+"**", ";", "");
	nwaves_xl = ItemsInList(listofwaves)
	//print nwaves_xl
	listofwaves = WaveList("xh"+MDC+"**", ";", "");
	nwaves_xh = ItemsInList(listofwaves)
	//print nwaves_xh
	listofwaves = WaveList("ly"+MDC+"**", ";", "");
	nwaves_ly = ItemsInList(listofwaves)
	//print nwaves_ly
	listofwaves = WaveList("lq"+MDC+"**", ";", "");
	nwaves_lq = ItemsInList(listofwaves)
	//print nwaves_lq
	//*********** End Count


	//*********** Display
		display//;appendimage namew

		variable kkk
		kkk=1
		do
			pl="pl"+MDC+num2str(kkk)
			xl="xl"+MDC+num2str(kkk)
			ph="ph"+MDC+num2str(kkk)
			xh="xh"+MDC+num2str(kkk)
			wave plw1=$pl
			wave phw1=$ph
			wave xlw1=$xl
			wave xhw1=$xh
			ly="ly"+MDC+num2str(kkk)
			lq="lq"+MDC+num2str(kkk)
			wave lyw1=$ly
			wave lqw1=$lq
			appendtograph lqw1 vs plw1
			appendtograph lqw1 vs phw1
			ModifyGraph rgb($lq)=(0,0,65535)//,mode($lq)=3,marker($lq)=19,msize($lq)=1

			kkk+=1
		while (kkk<nwaves_ly+1)
		ModifyGraph width={Plan,1,bottom,left}
		Label Left "\\Z10Q";Label bottom "\\Z10P"
		TextBox/C/N=text1/F=0 MDC
		ckfig(winname(0,1))
		display
		appendimage namew
		kkk=1
		do
			pl="pl"+MDC+num2str(kkk)
			xl="xl"+MDC+num2str(kkk)
			ph="ph"+MDC+num2str(kkk)
			xh="xh"+MDC+num2str(kkk)
			wave plw1=$pl
			wave phw1=$ph
			wave xlw1=$xl
			wave xhw1=$xh
			ly="ly"+MDC+num2str(kkk)
			lq="lq"+MDC+num2str(kkk)
			wave lyw1=$ly
			wave lqw1=$lq
			appendtograph lyw1 vs xlw1
			appendtograph lyw1 vs xhw1
			ModifyGraph rgb($ly)=(0,0,65535)//,mode($ly)=3,marker($ly)=19,msize($ly)=1

			kkk+=1
		while (kkk<nwaves_ly+1)
		ModifyGraph width={Plan,1,bottom,left}
		Label Left "\\Z10Y";Label bottom "\\Z10X"
		TextBox/C/N=text1/F=0 MDC
		ckfig(winname(0,1))
	//*********** End Display

	//*********** Kill intermedia horizental waves
	if (killim == 1)
		variable kills
		kills=0
			do
				plwave="plwave"+MDC+num2str(kills)
				xlwave="xlwave"+MDC+num2str(kills)
				phwave="phwave"+MDC+num2str(kills)
				xhwave="xhwave"+MDC+num2str(kills)
				wave xlwavew=$xlwave
				wave phwavew=$phwave
				wave xhwavew=$xhwave
				wave plwavew=$plwave
				killwaves xlwavew
				killwaves phwavew
				killwaves xhwavew
				killwaves plwavew

				kills+=1
			while(kills < dimsize(namew,1))
	endif

	if (killim == 0)
	endif
	//*********** End Kill intermedia horizental waves


	//*********** Error message, no stop but Continuing execution
	String msg
	Variable err
	msg=GetErrMessage(GetRTError(0),3);
	err=GetRTError(1)
	//if (err != 0)
	//	Print "Error in Demo: " + msg
	//	Print "Continuing execution"
	//endif
	//*********** End Error message
end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function sftvfollowjump(MDC,namew,sel,increase) //Jumpping value remover
	String MDC
	Wave namew
	variable sel //select mode, 0 is 2/4 quadrant, 1 is first 1/3 quadrant.
	variable increase //the value to add sequencely to each domain

	String namec
	namec = MDC+"_shiftphase"
	duplicate/o namew $namec
	wave namecw = $namec

	//****Initialized parameters
	variable count //Count will add 1 when the first data point in the horizental data change index in the destination matrix
	count = 0
	variable j,ic,lic,ic2
	string plwave,pladv
	variable jjj,jj
	variable dif
	variable interdatacondition // the condition to increase Count, this value is "how many P shifted", this need to be tuned, for evenly spaced case we have this default value calculated as following
	String getinterdatacondition
	variable getic= dimsize(namew,1)
	variable getic2 = round(getic/2)
	getinterdatacondition ="phwave"+MDC+num2str(getic2)
	wave getinterdataconditionw=$getinterdatacondition
	interdatacondition = round(abs(getinterdataconditionw[0] - getinterdataconditionw[1])/2)
	//****End initialize parameters

	//*********** Mode#1 Reorganize data
	if(sel == 0)
		j=0
		do
			plwave="plwave"+MDC+num2str(j)
			pladv="plwave"+MDC+num2str(j+1)
			wave pladvw=$pladv
			wave plwavew=$plwave

			jjj=1
			if (j< dimsize(namew,1)-1)
				dif = pladvw[0]-plwavew[0]
			else
			endif
			if (dif > interdatacondition)
					jj = jjj+count
					count+=1
				else
					jj= jjj+count
			endif

			do
				ic = 0
				do
					if (jjj == 1)
						lic = 0
					else
						lic = plwavew[jjj-2]
					endif
					namecw[ic+lic][j] +=(jj-1)*increase
					ic+=1
				while (ic < plwavew[jjj-1]-lic)

				jjj+=1
				jj+=1
			while(jjj<dimsize(plwavew,0)+1)

			ic2=plwavew[dimsize(plwavew,0)-1]
			do
				namecw[ic2][j] +=(dimsize(plwavew,0)+count)*increase

				ic2+=1
			while (ic2 < dimsize(namew,0))

			j+=1
		while (j < dimsize(namew,1))
	endif
	//*********** End Mode#1 *************************//


	//*********** Mode#2 Reorganize data
	if(sel == 1)
		j=dimsize(namew,1)-1
		//make/o/N=100 shiftpy
		//shiftpy = nan

		do
			plwave="plwave"+MDC+num2str(j)
			pladv="plwave"+MDC+num2str(j-1)
			wave pladvw=$pladv
			wave plwavew=$plwave

			jjj=1
			if (j > 0)
				dif = pladvw[0]-plwavew[0]
			else
			endif
				//print "dif is "+num2str(dif)
			if (dif > interdatacondition)
					jj = jjj+count
					count+=1
					//shiftpy[checkfirstNonnan(shiftpy)]=j+1
					//print count
				else
					jj= jjj+count
			endif
				//print "count is "+num2str(count)+" ; j is "+num2str(j)//+" start is "+num2str(start)

			do
				ic = 0

				do
					if (jjj == 1)
						lic = 0
					else
						lic = plwavew[jjj-2]
					endif
					namecw[ic+lic][j] +=(jj-1)*increase
					ic+=1
				while (ic < plwavew[jjj-1]-lic)

				jjj+=1
				jj+=1
			while(jjj<dimsize(plwavew,0)+1)

			ic2=plwavew[dimsize(plwavew,0)-1]
			do
				namecw[ic2][j] +=(dimsize(plwavew,0)+count)*increase

				ic2+=1
			while (ic2 < dimsize(namew,0))

			j-=1
		while (j > -1)
	endif
	//*********** End Mode#2 *************************//

	di(namecw)


	//*********** Error message, no stop but Continuing execution
	String msg
	Variable err
	msg=GetErrMessage(GetRTError(0),3);
	err=GetRTError(1)
	//if (err != 0)
	//	Print "Error in Demo: " + msg
	//	Print "Continuing execution"
	//endif
	//*********** End Error message
end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////   End all this part   /////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////   Demo of the jump remover   //////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Demoautormjump2DPro(ctrlName) : ButtonControl
	String ctrlName
	Execute "Demoautormjump2DPro()"
end

Proc Demoautormjump2DPro()
	//String name ="aa"
	//variable jumpheight = 3.01
	//variable don = 1// 1,display;0,do not display
	//variable killim = 1// kill (1) or not kill (0) intermedia waves, that is the horizental waves from fit
	//variable add1 = pi
	//prompt name,"The DATA INPUT (must be a 2D matrix)"
	//prompt jumpheight,"dZ threshhold for testing jumpping position"
	//prompt don,"display (1) or not (0)"
	//Prompt killim,"kill intermedia wave (1), or not (0)"
	//Prompt add1,"unit of value add to data"

	Generatepjlmartrix(0.05,0.05,0.05,-0.05,40,1)
	autoromvejump2D("tgp1",3.01,1,pi)
	autoromvejump2D("tgp2",2.55,1,pi)
	Layout/T Graph7,Graph4,Graph6,Graph3,Graph5,Graph2,Graph0,Graph1
	cklayout(winname(0,4))
	Print "This is a demo to show how the jump remover works"
	Print "Two demo DATA INPUT were generated automatically"
	Print "The Function called is"
	Print "autoromvejump2D("+"\""+"tgp1\""+",3.01,1,pi)"
	Print "autoromvejump2D("+"\""+"tgp2\""+",2.55,1,pi)"
    di(tg)
    tilewindows/WINS=WinList("*", ";","WIN:1")/R/w=(4,0,55,80)


end
Proc Generatepjlmartrix(qx1,qy1,qx2,qy2,sigma,factor)
	variable qx1
	variable qy1
	variable qx2
	variable qy2
	variable sigma
	variable factor
	//prompt name,"Data name to manipulate"
	//prompt qx1,"lock-in q1 (x)"
	//prompt qy1,"lock-in q1 (y)"
	//prompt qx2,"lock-in q2 (x)"
	//prompt qy2,"lock-in q2 (y)"
	//prompt sigma,"lenght counted in real space"
	//prompt factor,"factor of the output, how many times the dimsize of original matrix"
	make/o/N=(200,200) tg
	tg = abs(cos(x/(pi))-cos(y/(pi)))
	String name ="tg"
	String nameFFT1,namec1,nameFFTfilter1,nameiff1,tphase1
	namec1 = name+"c1"
	nameFFT1 = name+"raw_FFT1"
	nameFFTfilter1 = nameFFT1+"filter1"
	nameiff1 = name+"ifft1"
	tphase1 = name+"p1"
	make/c/N=(dimsize($name,0),dimsize($name,1))/o $namec1
	setscale/p x,dimoffset($name,0),dimdelta($name,0),"",$namec1
	setscale/p y,dimoffset($name,1),dimdelta($name,1),"",$namec1
	$namec1=cmplx($name,0)*exp(cmplx(0,(qx1*x+qy1*y)))
	FFT/OUT=1/DEST=$nameFFT1  $namec1
	//Display;AppendImage $nameFFT1
	duplicate/o $nameFFT1 $nameFFTfilter1
	$nameFFTfilter1=$nameFFT1*exp((-x^2-y^2)/(2*(1/sigma)^2))/(sqrt(2*pi)*(1/sigma))
	IFFT/C/DEST=$nameiff1  $nameFFTfilter1
	//•di($nameFFTfilter1)
	duplicate/o $name $tphase1
	$tphase1=atan(imag($nameiff1)/real($nameiff1))
	String nameFFT2,namec2,nameFFTfilter2,nameiff2,tphase2
	namec2 = name+"c2"
	nameFFT2 = name+"raw_FFT2"
	nameFFTfilter2 = nameFFT2+"filter2"
	nameiff2 = name+"ifft2"
	tphase2 = name+"p2"
	make/c/N=(dimsize($name,0),dimsize($name,1))/o $namec2
	setscale/p x,dimoffset($name,0),dimdelta($name,0),"",$namec2
	setscale/p y,dimoffset($name,1),dimdelta($name,1),"",$namec2
	$namec2=cmplx($name,0)*exp(cmplx(0,(qx2*x+qy2*y)))
	FFT/OUT=1/DEST=$nameFFT2  $namec2
	//Display;AppendImage $nameFFT2
	duplicate/o $nameFFT2 $nameFFTfilter2
	$nameFFTfilter2=$nameFFT2*exp((-x^2-y^2)/(2*(1/sigma)^2))/(sqrt(2*pi)*(1/sigma))
	IFFT/C/DEST=$nameiff2  $nameFFTfilter2
	//•di($nameFFTfilter2)
	duplicate/o $name $tphase2
	$tphase2=atan(imag($nameiff2)/real($nameiff2))
	setscale/I x,0,2,"",$tphase1
	setscale/I y,0,2,"",$tphase1
	setscale/I x,0,2,"",$tphase2
	setscale/I y,0,2,"",$tphase2
	di($tphase2);di($tphase1)

	killwaves $namec1,$nameFFT1,$nameFFTfilter1,$namec2,$nameFFT2,$nameFFTfilter2
end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////   End Demo of the jump remover   //////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
//This procedure is to process the Gate Mapping data,
//From Gate map, to extract the peak position change along the gate voltage
//Two peaks can be choose
//We use 4th derivatives to enhance the signal
/////////////////////////////////////////////////////////////////////////////
// To begin with this procedure, please load the gate map data and normalized it properly,
// and then make one sts 4th derivatived, to find right1,right2,left1,left2
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
Function ButtonProc_gatemapextractpeak(ctrlName) : ButtonControl
	String ctrlName
	Execute "gatemapextractpeak()"
end


Proc gatemapextractpeak(number, right1,right2,left1,left2,vl,vh)
	variable number =(dimsize(file_name,0)-1)
	variable right1 =132
	variable right2 =161
	variable left1 = 41
	variable left2 = 74
	variable vl =18
	variable vh =-18
	Prompt number,"How many gate slices"
	Prompt right1,"right peak_small point"
	Prompt right2,"right peak_large point "
	Prompt left1,"left peak_small point"
	Prompt left2,"left peak_large point "
	prompt vl, "small gate voltage"
	prompt vh, "large gate voltage"


	secondDall2("sts","",number,500)
	secondDall2("sts_2ndd_","",number,500)
	autoclbzerogateuse("sts_2ndd__2ndd_",number,right1,right2)
	renameall("fit_sts_2ndd__2ndD_","fit_sts_2ndd__2ndD_right","",number)
	rename peakpclb peakright
	autoclbzerogateuse("sts_2ndd__2ndd_",number,left1,left2)
	renameall("fit_sts_2ndd__2ndD_","fit_sts_2ndd__2ndD_left","",number)
	rename peakpclb peakleft
	linkstsmap_P("sts_2ndd__2ndd_",number)
	rename mapsts map4nd
	linkstsmap_P("sts",number)
	rename mapsts mapraw
	setscale/I y, vl,vh,"",map4nd
	setscale/I y, vl,vh,"",mapraw
	setscale/I x, vl,vh,"",peakright
	setscale/I x, vl,vh,"",peakleft
	AppendToGraph/VERT peakleft
	AppendToGraph/VERT peakright
end

//////////////////////
proc secondDall2(mat,suf,totalnum,smootht)
	string mat="sts"
	string mat2="stsnorm"
	string suf=""
	variable totalnum
	variable smootht=500
	Prompt mat,"name of the Batch waves"
	//Prompt mat2,"2nd Differentiate wave name"
	Prompt totalnum,"numbers of the Batch"
	Prompt suf,"If you have a suffix,Please input"
	Prompt smootht,"How many times smooth"

	string matt,matt2
	variable i
	mat2=mat+"_2ndD_"
	i=1
	do
		matt=mat+num2str(i)+suf
		//mat2="stsnormallrangecutline"+num2str(i)
		matt2=mat2+num2str(i)
		//mat2="stsr"+num2str(i)

		duplicate/o $matt $matt2
		smooth smootht, $matt2
		differentiate $matt2
		//smooth 5, $matt2
		differentiate $matt2
		$matt2*=-1
		I+=1
	while(i<totalnum+1)
	//displaymulti(mat2,1,totalnum)
end
/////
proc autoclbzerogateuse(mat,num,left,right)
	string mat="sts"
	variable num =(dimsize(file_name,0)-1)
	variable left=pcsr(A)
	variable right=pcsr(B)
	Prompt mat,"name of Batch"
	Prompt num,"Number of Batch"
	Prompt left,"Fit From (Point)"
	Prompt right,"Fit To (Point)"
	variable i
	string matuse,dest
	variable height, pp
	make/o/N=(num) peakpclb
	//make/o/N=(num) peakhclb
	i=1
	do
		matuse=mat+num2str(i)
		//dest=mat+"CL"+num2str(i)
		CurveFit/Q/M=2/W=0 gauss, $matuse[left,right]/D
		height=W_coef[1]+W_coef[0]
		pp=W_coef[2]
		//peakhclb[i-1]=height
		//wavestats/Q $matuse
		peakpclb[i-1]=W_coef[2]
		//duplicate/o $matuse $dest
		//setscale/P x,(dimoffset($matuse,0)-W_coef[2]),dimdelta($matuse,0),"",$dest
		i+=1
	while(i<num+1)
	edit  peakpclb
	display peakpclb

end

Function ButtonProc_Loaddata2(ctrlName) : ButtonControl//"Load BNL Data in Folder"
	String ctrlName
	execute "setDataFolder Root:"
	Execute "Makegraphtable()"
	Execute "LoadDataalltypes2()"
	Execute "Initialize_Global_Variables()"
End

Proc LoadDataalltypes2()
	Silent 1;
	PauseUpdate
	Variable/G typeofdata
	If(typeofdata==1)
		LoadDataFromIgorFiles()
	Endif
	If(typeofdata==2)
		LoadDataFromtxt()
	Endif
	If(typeofdata==3)
		LoadDataFromdat()
	Endif
	If(typeofdata==4)
		LoadDataFromA1()
	Endif
	If(typeofdata==5)
		LoadDataFromasc()
	Endif
End

Proc LoadDataFromasc()
	newpath /O tempPath
	String Pathname="tempPath"
	Variable  Loadn=ItemsInList(IndexedFile($PathName,-1,".asc"))
	print IndexedFile($PathName,-1,".asc")
	Variable  DataNum
	String  savedDataFolder=getDataFolder(1)
	String 	Filename, FolderName
	String kstring
	Variable condition
	Variable n,m
	Variable index
	Variable firstnumfirst,firstnumlast,secondnumfirst,secondnumlast,i
	String datalist=IndexedFile($pathName, -1, ".asc")//For arrange data

	String objName
	if(wintype("Information_table")==0)
		DataNum=0
	endif
	if(winType("Information_table")==2)
		DataNum=Dimsize(File_Name,0)
	endif
		m=loadn-DataNum+1
		InSertPoints DataNum, m,File_Name
	string mat
	n=DataNum
	Do
		Filename = stringfromlist(n-1, sortlist(datalist,";",16))//For arrange data

		//Filename=IndexedFile($PathName,n-1,".asc")
		print FileName
		File_Name[n]=FileName
		LoadWave /Q/J/L={0,0,1,0,0} /K=2  /O /N=tempStr /P=$PATHName Filename
		LoadWave /Q/G/L={0,1,0,1,0} /O /M/N=tempMat /P=$PATHName FileName
		LoadWave /Q/G/L={0,1,0,0,1} /O /N=XWave /P=$PATHName FileName
		mat="data"+num2str(n)
		Make/O/N=(dimsize(tempMat0,1),dimsize(tempMat0,0)) $mat
		$mat[][]=tempMat0[q][p]
		Setscale/P y,XWave0[0],XWave0[1]-XWave0[0],""$mat
		Center_detector($mat)//,0)
		n+=1
	While(n<=Loadn)
	setDataFolder $savedDataFolder
End

/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
//
//Normal tip with a linear density of states: a*(-x)+b
//SC sample with Dyne function density of states
//
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
//
//Head and fitting command part of this procedure
//
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
Function ButtonProc_DyneFit(ctrlName) : ButtonControl
	String ctrlName
	Execute "STSFiTDyne()"
end
proc STSFiTDyne(mat,Db,gap,tem,gradient_tip,offset_tip)
	string mat="sts"
	variable Db=0.077//=Wfitdyne[0]//=0.1
	variable gap=1.5//=Wfitdyne[1]//=1.5
	variable tem=0.45//=Wfitdyne[2]//=0.45
	variable gradient_tip=-0.012//=Wfitdyne[3]//=0
	variable offset_tip=0.96//=Wfitdyne[4]//=1
	prompt mat,"Name of Fit data"
	prompt Db,"Dyne Broadening (meV)"
	prompt gap,"SC gap (meV)"
	prompt tem,"Temperature (K) Fix"
	prompt gradient_tip, "a_tip(slope)"
	prompt offset_tip,"b_tip(offset)"
	PauseUpdate
		Silent 1
	string matt
	matt="Dynefit_"+mat
	make/O/N=5 Wfitdyne
	variable/G ErangeDynefit
	Wfitdyne[0]=db
	Wfitdyne[1]=gap
	Wfitdyne[2]=tem
	Wfitdyne[3]=gradient_tip
	Wfitdyne[4]=offset_tip
	ErangeDynefit=2*abs(dimoffset($mat,0))
	Make/O/T/N=1 T_Constraintsdyne
	//T_Constraintsdyne= {"K0 > 0","K2 > 0","K2 < 1"}
	T_Constraintsdyne= {"K0 > 0"}

	FuncFit/Q/H="00100" scsc2 Wfitdyne $mat /C=T_Constraintsdyne
	make/o/n=(dimsize($mat,0)) $matt
	setscale/P x, dimoffset($mat,0),dimdelta($mat,0),""$matt
	$matt= scsc(Wfitdyne,x);differentiate $matt
	append $matt
	ModifyGraph lsize($matt)=2,rgb($matt)=(0,0,0)
	TextBox/C/N=text0 "\F'symbol'G\F'times' = "+num2str(wfitdyne[0])+" ± "+num2str(W_sigma[0])+" meV"+"\r\F'symbol'D\F'times'  = " +num2str(wfitdyne[1])+" ± "+num2str(W_sigma[1])+" meV"+"\rT  = " +num2str(wfitdyne[2])+" ± "+num2str(W_sigma[2])+" K"+"\ra(slope)  = " +num2str(wfitdyne[3])+" ± "+num2str(W_sigma[3])+"\rb(offset)  = " +num2str(wfitdyne[4])+" ± "+num2str(W_sigma[4])
	edit Wfitdyne W_sigma
end

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

// For integrated and then differentiated Fit.

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
Function scsc2(pw,yw,xw):FitFunc
	wave pw,yw,xw
	NVAR ErangeDynefit = ErangeDynefit
   variable/G Db=pw[0] //meV, dyne broadening
	variable/G deltaGs=pw[1]//meV, sample gap
	variable/G Tem=pw[2] //K, temperature
	Variable/G a=pw[3]
	variable/G b=pw[4]
	variable p
	p=0
	do
		variable/G evp=xw[p]
   		yw[p]=integrate1d(UserIntergrand2,-ErangeDynefit*2,ErangeDynefit*2,1)
    	p+=1
    while (p<dimsize(xw,0))
    differentiate yw
end
//////////////////////////////////////////////////////////////////////
Function UserIntergrand2(dE)//
	Variable dE
	variable ft//ft(E-eV)
	variable fs//fs(E)
	variable Nt//nt(E-eV)
	variable Ns//Ns(E)
	NVAR Db//=pw[0] //meV, dyne broadening
	NVAR eVp//meV, bias voltage
	NVAR deltaGs//=pw[1]//meV, sample gap
	NVAR Tem//=pw[3] //K, temperature
	NVAR a
	NVAR b
	ft=1/(exp((dE-eVp)/(0.086*Tem))+1)
	fs=1/(exp((dE)/(0.086*Tem))+1)
	Ns=real(sqrt(dE^2+db^2)/(cmplx(dE^2-db^2-deltags^2,-2*dE*db))^(1/2))//+As*exp(-(dE-ps)^2/bs)
	Nt=a*(dE-evp)+b
	return ((ft-fs)*Nt*Ns)
end

////////////////////////////////////////////////////////////////////////

//only for graph

////////////////////////////////////////////////////////////////////////
Function UserIntergrand(dE)//
	Variable dE
	variable ft//ft(E-eV)
	variable fs//fs(E)
	variable Nt//nt(E-eV)
	variable Ns//Ns(E)
	//variable deltavs
	NVAR Db//=pw[0] //meV, dyne broadening
	NVAR eVp//meV, bias voltage
	NVAR deltaGs//=pw[1]//meV, sample gap
	//NVAR deltaGt//=pw[2]//meV, tip gap
	//NVAR Kc=Kc //nm
	//NVAR rv=rv //nm
	NVAR Tem//=pw[3] //K, temperature
	//NVAR As//=pw[4]// amplitude SGS of sample
	//NVAR ps//=PW[4]//positions (meV) SGS of sample
	//NVAR bs//=pw[5]// width sgs of sample
	//NVAR At//=pw[6]// amplitude SGS of tip
	//NVAR pt//=PW[7]//positions (meV) SGS of tip
	//NVAR bt//=pw[8]// width sgs of tip
	NVAR a
	NVAR b
	ft=1/(exp((dE-eVp)/(0.086*Tem))+1)
	fs=1/(exp((dE)/(0.086*Tem))+1)
	//deltavt=deltagt*tanh(rv/Kc)
	//deltavs=deltags*tanh(rv/Kc)
	//Ns=abs(real(cmplx(dE,-db)/(cmplx(dE^2-db^2-deltags^2,-2*dE*db))^(1/2)))+As*exp(-(dE-ps)^2/bs)
	//Nt=abs(real(cmplx(dE-evp,-db)/(cmplx((dE-evp)^2-db^2-deltagt^2,-2*(dE-evp)*db))^(1/2)))+at*exp(-(dE-pt-evP)^2/bt)
	Ns=real(sqrt(dE^2+db^2)/(cmplx(dE^2-db^2-deltags^2,-2*dE*db))^(1/2))//+As*exp(-(dE-ps)^2/bs)
	//Nt=real(sqrt((dE-evp)^2+db^2)/(cmplx((dE-evp)^2-db^2-deltagt^2,-2*(dE-evp)*db))^(1/2))+at*exp(-(dE-pt-evP)^2/bt)
	Nt=a*(dE-evp)+b
	//Nt=1
	return ((ft-fs)*Nt*Ns)
end

Function scsc(pw,inx):FitFunc
	wave pw
	variable inx
	//wave yw
   NVAR ErangeDynefit =ErangeDynefit
   variable/G Db=pw[0] //meV, dyne broadening
	//wave eVp=xw //meV, bias voltage
	variable/G deltaGs=pw[1]//meV, sample gap
	//variable/G deltaGt=pw[2]//meV, tip gap
	//NVAR Kc=Kc //nm
	//NVAR rv=rv //nm
	variable/G Tem=pw[2] //K, temperature
	//variable/G As=pw[3]// amplitude SGS of sample
	//variable/G ps=PW[4]//positions (meV) SGS of sample
	//variable/G bs=pw[5]// width sgs of sample
	//variable/G At=pw[7]// amplitude SGS of tip
	//variable/G pt=PW[8]//positions (meV) SGS of tip
	//variable/G bt=pw[9]// width sgs of tip
	Variable/G a=pw[3]
	variable/G b=pw[4]
	variable/G evp=inx
	//variable/G haha=pw[5]
	return integrate1d(UserIntergrand,-ErangeDynefit*2,ErangeDynefit*2,0)//+haha
	//differentiate yw
end
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

// End of the Dyne fitting

/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////


//*********************************************************
//
//    This is a function for SC-SC tunneling simulatioon
//
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
//
//SC tip with Dyne density of states
//SC sample with Dyne function density of states
//
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
Function ButtonProc_DyneFitS(ctrlName) : ButtonControl
	String ctrlName
	Execute "STSFiTDyneS()"
end
proc STSFiTDyneS(mat,Db,gap,gapt,tem,gradient_tip,offset_tip)
	string mat="sts"
	variable Db=0.077//=Wfitdyne[0]//=0.1
	variable gap=1.5//=Wfitdyne[1]//=1.5
	variable gapt=1.5
	variable tem=0.45//=Wfitdyne[2]//=0.45
	variable gradient_tip=0//=Wfitdyne[3]//=0
	variable offset_tip=1//=Wfitdyne[4]//=1
	prompt mat,"Name of Fit data"
	prompt Db,"Dyne Broadening (meV)"
	prompt gap,"SC gap (meV)_sample"
	prompt gapt,"SC gap (meV)_tip"
	prompt tem,"Temperature (K) Fix"
	prompt gradient_tip, "a_tip(slope)"
	prompt offset_tip,"b_tip(offset)"
	PauseUpdate
		Silent 1
	string matt
	matt="Dynefit_"+mat
	make/O/N=6 Wfitdyne
	variable/G ErangeDynefit
	Wfitdyne[0]=db
	Wfitdyne[1]=gap
	Wfitdyne[2]=tem
	Wfitdyne[3]=gradient_tip
	Wfitdyne[4]=offset_tip
	Wfitdyne[5]=gapt

	ErangeDynefit=2*abs(dimoffset($mat,0))
	Make/O/T/N=1 T_Constraintsdyne
	T_Constraintsdyne= {"K0 > 0","K2 > 4"}
	//T_Constraintsdyne= {"K0 > 0"}

	FuncFit/Q/H="010111" scsc2S Wfitdyne $mat /C=T_Constraintsdyne
	make/o/n=(dimsize($mat,0)) $matt
	setscale/P x, dimoffset($mat,0),dimdelta($mat,0),""$matt
	$matt= scscS(Wfitdyne,x);differentiate $matt
	append $matt
	ModifyGraph lsize($matt)=2,rgb($matt)=(0,0,0)
	TextBox/C/N=text0 "\F'symbol'G\F'times' = "+num2str(wfitdyne[0])+" ± "+num2str(W_sigma[0])+" meV"+"\r\F'symbol'D\F'times'  = " +num2str(wfitdyne[1])+" ± "+num2str(W_sigma[1])+" meV"+"\rT  = " +num2str(wfitdyne[2])+" ± "+num2str(W_sigma[2])+" K"+"\ra(slope)  = " +num2str(wfitdyne[3])+" ± "+num2str(W_sigma[3])+"\rb(offset)  = " +num2str(wfitdyne[4])+" ± "+num2str(W_sigma[4])
	edit Wfitdyne W_sigma
end

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

// For integrated and then differentiated Fit.

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
Function scsc2S(pw,yw,xw):FitFunc
	wave pw,yw,xw
   NVAR ErangeDynefit = ErangeDynefit
   variable/G Db=pw[0] //meV, dyne broadening
	variable/G deltaGs=pw[1]//meV, sample gap
	variable/G Tem=pw[2] //K, temperature
	Variable/G a=pw[3]
	variable/G b=pw[4]
	variable/G deltaGt=pw[5]
	variable p
	p=0
	do
		variable/G evp=xw[p]
    	yw[p]=integrate1d(UserIntergrand2S,-ErangeDynefit*2,ErangeDynefit*2,1)
    	p+=1
    while (p<dimsize(xw,0))
    differentiate yw
end
//////////////////////////////////////////////////////////////////////
Function UserIntergrand2S(dE)//
	Variable dE
	variable ft//ft(E-eV)
	variable fs//fs(E)
	variable Nt//nt(E-eV)
	variable Ns//Ns(E)
	NVAR Db//=pw[0] //meV, dyne broadening
	NVAR eVp//meV, bias voltage
	NVAR deltaGs//=pw[1]//meV, sample gap
	NVAR deltaGt
	NVAR Tem//=pw[3] //K, temperature
	NVAR a
	NVAR b
	ft=1/(exp((dE-eVp)/(0.086*Tem))+1)
	fs=1/(exp((dE)/(0.086*Tem))+1)
	Ns=real(sqrt(dE^2+db^2)/(cmplx(dE^2-db^2-deltags^2,-2*dE*db))^(1/2))//+As*exp(-(dE-ps)^2/bs)
	//Nt=a*(dE-evp)+b
	Nt=(a*(dE-evp)+b)*(real(sqrt((dE-evP)^2+db^2)/(cmplx((dE-evp)^2-db^2-deltagt^2,-2*(dE-evp)*db))^(1/2)))
	return ((ft-fs)*Nt*Ns)
end

////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////

//only for graph

////////////////////////////////////////////////////////////////////////
Function UserIntergrandS(dE)//
	Variable dE
	variable ft//ft(E-eV)
	variable fs//fs(E)
	variable Nt//nt(E-eV)
	variable Ns//Ns(E)
	//variable deltavs
	NVAR Db//=pw[0] //meV, dyne broadening
	NVAR eVp//meV, bias voltage
	NVAR deltaGs//=pw[1]//meV, sample gap
	NVAR deltaGt//=pw[2]//meV, tip gap
	//NVAR Kc=Kc //nm
	//NVAR rv=rv //nm
	NVAR Tem//=pw[3] //K, temperature
	//NVAR As//=pw[4]// amplitude SGS of sample
	//NVAR ps//=PW[4]//positions (meV) SGS of sample
	//NVAR bs//=pw[5]// width sgs of sample
	//NVAR At//=pw[6]// amplitude SGS of tip
	//NVAR pt//=PW[7]//positions (meV) SGS of tip
	//NVAR bt//=pw[8]// width sgs of tip
	NVAR a
	NVAR b
	ft=1/(exp((dE-eVp)/(0.086*Tem))+1)
	fs=1/(exp((dE)/(0.086*Tem))+1)
	//deltavt=deltagt*tanh(rv/Kc)
	//deltavs=deltags*tanh(rv/Kc)
	//Ns=abs(real(cmplx(dE,-db)/(cmplx(dE^2-db^2-deltags^2,-2*dE*db))^(1/2)))+As*exp(-(dE-ps)^2/bs)
	//Nt=abs(real(cmplx(dE-evp,-db)/(cmplx((dE-evp)^2-db^2-deltagt^2,-2*(dE-evp)*db))^(1/2)))+at*exp(-(dE-pt-evP)^2/bt)
	Ns=real(sqrt(dE^2+db^2)/(cmplx(dE^2-db^2-deltags^2,-2*dE*db))^(1/2))//+As*exp(-(dE-ps)^2/bs)
	//Nt=real(sqrt((dE-evp)^2+db^2)/(cmplx((dE-evp)^2-db^2-deltagt^2,-2*(dE-evp)*db))^(1/2))+at*exp(-(dE-pt-evP)^2/bt)
	//Nt=a*(dE-evp)+b
	Nt=(a*(dE-evp)+b)*(real(sqrt((dE-evP)^2+db^2)/(cmplx((dE-evp)^2-db^2-deltagt^2,-2*(dE-evp)*db))^(1/2)))

	//Nt=1
	return ((ft-fs)*Nt*Ns)
end

Function scscS(pw,inx):FitFunc
	wave pw
	variable inx
	//wave yw
   NVAR ErangeDynefit =ErangeDynefit
   variable/G Db=pw[0] //meV, dyne broadening
	//wave eVp=xw //meV, bias voltage
	variable/G deltaGs=pw[1]//meV, sample gap
	//variable/G deltaGt=pw[2]//meV, tip gap
	//NVAR Kc=Kc //nm
	//NVAR rv=rv //nm
	variable/G Tem=pw[2] //K, temperature
	//variable/G As=pw[3]// amplitude SGS of sample
	//variable/G ps=PW[4]//positions (meV) SGS of sample
	//variable/G bs=pw[5]// width sgs of sample
	//variable/G At=pw[7]// amplitude SGS of tip
	//variable/G pt=PW[8]//positions (meV) SGS of tip
	//variable/G bt=pw[9]// width sgs of tip
	Variable/G a=pw[3]
	variable/G b=pw[4]
	variable/G deltaGt=pw[5]
	variable/G evp=inx
	//variable/G haha=pw[5]
	return integrate1d(UserIntergrands,-ErangeDynefit*2,ErangeDynefit*2,0)//+haha
	//differentiate yw
end

///////////////////////////////////////////////////////////////////////////////////
//To start, you need load the data slice, and rescale the slice properly
///////////////////////////////////////////////////////////////////////////////////
//To start, you need to get the fiting region of the two peaks at first
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
//This procedure is used to get two peak feature distribution from a grid data.
//The fitting procedure is a 4th deriviate based Gaussian fit.
//Please get a test gridsts and get 4th deri, and find the right1,right2,left1,left2
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
//After the procedure, you can also compare the correlation between the
//distribution matrix with the topograph, load the topograph data (notice:
//you should not load the topograph data before the procedure, you can only load after the procedure)
//and convert the topograph to 1D wave by using "Proc p2dtopeak_proc("data##")"
///////////////////////////////////////////////////////////////////////////////////
//Try, •display peakright vs onedtopo
//      •display peakleft vs onedtopo
//      •print StatsCorrelation(peakright , onedtopo)
//      •print StatsCorrelation(peakleft , onedtopo )
//That calculate the correlation coefficient of the two peaks with topography
///////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_gridextractpeak(ctrlName) : ButtonControl
	String ctrlName
	Execute "gridextractpeak()"
end
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
Proc gridextractpeak(start,delta,right1,right2,left1,left2)
	variable start =-100
	variable delta =1
	variable right1 =129
	variable right2 =161
	variable left1 = 41
	variable left2 = 74
	Prompt start,"(meV) The energy of first slice"
	Prompt delta,"(meV) energy step of slice set"
	Prompt right1,"right peak_small point"
	Prompt right2,"right peak_large point "
	Prompt left1,"left peak_small point"
	Prompt left2,"left peak_large point "

	variable a
	variable ptotal
	variable qtotal
	variable to
	a=dimsize(File_name,0)-1

	mapforSTM(a,"data","",start,delta)
	makeextra()

	ptotal= dimsize(pointimage,0)
	qtotal= dimsize(pointimage,1)
	to=ptotal*qtotal
	extractallsts(ptotal, qtotal, "mat3d")

	secondDall2("gridsts","",to,500)
	secondDall2("gridsts_2ndd_","",to,500)
	autoclbzerogateuse("gridsts_2ndd__2ndd_",to,right1,right2)
	renameall("fit_gridsts_2ndd__2ndD_","fit_gridsts_2ndd__2ndD_right","",to)
	rename peakpclb peakright
	autoclbzerogateuse("gridsts_2ndd__2ndd_",to,left1,left2)
	renameall("fit_gridsts_2ndd__2ndD_","fit_gridsts_2ndd__2ndD_left","",to)
	rename peakpclb peakleft

	peakp2d_proc("peakright")
	rename peak peak2Dright

	peakp2d_proc("peakleft")
	rename peak peak2Dleft

end


//////////////////////////////////
Function ButtonProc_peakp2d_proc(ctrlName) : ButtonControl
	String ctrlName
	Execute "peakp2d_proc()"
end

proc peakp2d_proc(name)
	string name
	prompt name, "Name of the 1D wave, Now convert it to 2D map"
	peakp2d(name)
end

Function peakp2d(name)
	string name
	variable k
	k=0
	string pointimage,aa,bb,cc
	pointimage="pointimage" //Name of the reference image
	aa="gridtostswave_p"//name of the wave containing P number reference for the 1d wave "$name"
	bb="gridtostswave_q"//name of the wave containing Q number reference for the 1d wave "$name"
	wave n=$pointimage
	wave d=$aa
	wave s=$bb
	wave ss=$name
	make/o/N=(dimsize(n,0),dimsize(n,1)) peak

	do
		variable a,b
		a=d[k+1]
		b=s[k+1]
		peak[a][b]=ss[k]
		k+=1
	while(k<dimsize(n,0)*dimsize(n,1))
	display;appendimage peak
end
//////////////////////////////////////////////////
//////////////////////////////////////////////////
//////////////////////////////////////////////////
//////////////////////////////////////////////////




//This procudure is for calculating how many steps required for jumping from Bias pad to Sample
Function ButtonProc_stepmove(ctrlName) : ButtonControl
	String ctrlName
	Execute "stepmove()"
end
Proc stepmove(ddx,ddy)
	variable ddx //nm
	variable ddy //nm
	Prompt ddx, "X vector to Jump (nm),    the length should with a '+/-' sign"
	Prompt ddy, "Y vector to Jump (nm),    the length should with a '+/-' sign"
	print "stepmove("+num2str(ddx)+","+num2str(ddy)+")"
	//("smy_x" means "movement in x direction (nm) when you click 1 step on -y piezo" )
	//("spy_x" means "movement in x direction (nm) when you click 1 step on +y piezo" )
	// The calibrated parameters are listed below, please change the value if the condition is different.

	// -y 1
	//**LN2 Parameter**// variable smy_x =14.07 //nm, LN2
	//**LN2 Parameter**// variable smy_y =-148.26//nm, LN2
	variable smy_x = 1.8295//-1.21 (TTG16)//=-0.7 (FTS05)//nm, LHe  **This is just an estimate
	variable smy_y = -68.6695//-69.35 (TTG16)//=-70.7965 (FTS05)//nm, LHe

	// -x 1
	//**LN2 Parameter**// variable smx_x = -60.59 //nm, LN2
	//**LN2 Parameter**// variable smx_y = -6.49 //nm, LN2
	variable smx_x = -19.931//-19.727 (TTG16)//= -27.56 (FTS05)//nm, LHe
	variable smx_y =  -1.243//-2.63 (TTG16)//= -1.49 (FTS05) //nm, LHe

	//+y 1
	//**LN2 Parameter**// variable spy_x = -9.61 //nm, LN2
	//**LN2 Parameter**// variable spy_y = 149.34 //nm, LN2
	variable spy_x = -2.34//-0.89 (TTG16)//= -7.373 (FTS05) //nm, LHe
	variable spy_y = 74.823//71.98 (TTG16)//= 74.645 (FTS05)//nm, LHe

	//+x 1
	//**LN2 Parameter**// variable spx_x = 50.86 //nm, LN2
	//**LN2 Parameter**// variable spx_y = 10.82 //nm, LN2
	variable spx_x = 19.5685//14.797 (TTG16)//= 8.7865 (FTS05)//nm, LHe
	variable spx_y = 1.135//3.615 (TTG16)//= 0 (FTS05)//nm, LHe

	variable step_x, step_y
	variable recalculx,recalculy

	if (ddy>0)
		if (ddx>0)
			//step_x*(spx_x)+step_y*(spy_x)=ddx
			//step_x*(spx_y)+step_y*(spy_y)=ddy
			step_x = (ddx*(spy_y)-ddy*(spy_x))/((spx_x)*(spy_y)-(spx_y)*(spy_x))
			step_y =(ddx*(spx_y)-ddy*(spx_x))/((spy_x)*(spx_y)-(spy_y)*(spx_x))
			print "should go +x "+num2str(step_x)+" steps."
			print "should go +y "+num2str(step_y)+" steps."

			recalculx=round(step_x)*spx_x+round(step_y)*spy_x
			recalculy=round(step_x)*spx_y+round(step_y)*spy_y
			print "After round(steps), recalculated x is "+num2str(recalculx)+" nm; recalculated y is "+num2str(recalculy)+" nm."
			print "x deviation is "+num2str(recalculx-ddx)+" nm; y deviation is "+num2str(recalculy-ddy)+" nm."

		endif
		if (ddx<0)
			step_x = (ddx*(spy_y)-ddy*(spy_x))/((smx_x)*(spy_y)-(smx_y)*(spy_x))
			step_y =(ddx*(smx_y)-ddy*(smx_x))/((spy_x)*(smx_y)-(spy_y)*(smx_x))
			print "should go -x "+num2str(step_x)+" steps."
			print "should go +y "+num2str(step_y)+" steps."

			recalculx=round(step_x)*smx_x+round(step_y)*spy_x
			recalculy=round(step_x)*smx_y+round(step_y)*spy_y
			print "After round(steps), recalculated x is "+num2str(recalculx)+" nm; recalculated y is "+num2str(recalculy)+" nm."
			print "x deviation is "+num2str(recalculx-ddx)+" nm; y deviation is "+num2str(recalculy-ddy)+" nm."

		endif
	endif

	if (ddy<0)
		if (ddx<0)
			step_x = (ddx*(smy_y)-ddy*(smy_x))/((smx_x)*(smy_y)-(smx_y)*(smy_x))
			step_y =(ddx*(smx_y)-ddy*(smx_x))/((smy_x)*(smx_y)-(smy_y)*(smx_x))
			print "should go -x "+num2str(step_x)+" steps."
			print "should go -y "+num2str(step_y)+" steps."

			recalculx=round(step_x)*smx_x+round(step_y)*smy_x
			recalculy=round(step_x)*smx_y+round(step_y)*smy_y
			print "After round(steps), recalculated x is "+num2str(recalculx)+" nm; recalculated y is "+num2str(recalculy)+" nm."
			print "x deviation is "+num2str(recalculx-ddx)+" nm; y deviation is "+num2str(recalculy-ddy)+" nm."

		endif
		if (ddx>0)
			step_x = (ddx*(smy_y)-ddy*(smy_x))/((spx_x)*(smy_y)-(spx_y)*(smy_x))
			step_y =(ddx*(spx_y)-ddy*(spx_x))/((smy_x)*(spx_y)-(smy_y)*(spx_x))
			print "should go +x "+num2str(step_x)+" steps."
			print "should go -y "+num2str(step_y)+" steps."

			recalculx=round(step_x)*spx_x+round(step_y)*smy_x
			recalculy=round(step_x)*spx_y+round(step_y)*smy_y
			print "After round(steps), recalculated x is "+num2str(recalculx)+" nm; recalculated y is "+num2str(recalculy)+" nm."
			print "x deviation is "+num2str(recalculx-ddx)+" nm; y deviation is "+num2str(recalculy-ddy)+" nm."
		endif
	endif
end

///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
//After do dI/dV(E,x,y) and plot 2D STS, you can run Extract sts all to get all the stss from the grid, titled by gridsts#
///////////////////////////////////////////////////////
Function ButtonProc_ExtractSTSall(ctrlName) : ButtonControl
	String ctrlName
	Execute " ExtractallSTS()"
end
///////////////////////////////////////////////////////
proc extractallsts(ptotal, qtotal, name)
	variable ptotal= dimsize(pointimage,0)
	variable qtotal= dimsize(pointimage,1)
	string name ="mat3d"
	variable i
	variable j,k
	string endname
	make/o/N=(ptotal*qtotal+1) gridtostswave_P
	make/o/N=(ptotal*qtotal+1) gridtostswave_Q
	make/o/N=(ptotal*qtotal+1) gridtostswave_K
	gridtostswave_P=nan
	gridtostswave_Q=nan
	gridtostswave_K=nan
	k=1
	i=0
	do
		j=0
		do
			endname="gridsts"+num2str(k)
			ExtractSTS2(i,j,name)
			duplicate/o stspoint $endname
			gridtostswave_K[k]=k
			gridtostswave_P[k]=i
			gridtostswave_Q[k]=j
			k+=1
			j+=1
		while (j<qtotal)
		i+=1
	while (i<ptotal)
	edit gridtostswave_K gridtostswave_P gridtostswave_Q
end
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
Function ExtractSTS2(xpoint,ypoint,name)
	variable xpoint//=pcsr(A)
	variable ypoint//=qcsr(A)
	string name//="mat3d"
	//Prompt xpoint,"P"
	//Prompt ypoint,"Q"
	//Prompt name,"Name of Map"

	wave N=$name
	string  endname
	variable i
	endname="stsextraction_"+num2str(xpoint)+"_"+num2str(ypoint)
	make/o/n=(dimsize($name,1)) stspoint
	i=0
	do
		stspoint[i]=N[xpoint][i][ypoint]
		setscale/P x,dimoffset($name,1),dimdelta($name,1),"",stspoint
		i+=1
	while(i<dimsize($name,1))
	//duplicate/o stspoint $endname
	//display $endname
end

///////////////////////////////////////////////////////////
//
//   From I(V) curve to dI/dV(V) curve by numerical differentiate
///////////////////////////////////////////////////////////
Function ButtonProc_diffeall(ctrlName) : ButtonControl
	String ctrlName
	Execute " diffeall()"
end

Proc diffeall(mat,totalnum,notes)
	String mat="sts"
	variable totalnum
	string notes = "Unit of I and V should be SI; Unit of converted dI/dV is e^2/h"
	Prompt mat,"Name of the Batch waves"
	Prompt totalnum,"Numbers of the Batch"

	string matt,matt2
	variable i
	i=1
	do
		matt=mat+num2str(i)
		//matt2=mat2+num2str(i)

		differentiate $matt
		$matt/=3.874e-05
	i+=1
	while(i<totalnum+1)
	//print "renameall("+mat+","+mat2+","+suf+","+num2str(totalnum)+")"
end


///////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_scalewave(ctrlName) : ButtonControl
	String ctrlName
	Execute "scalewaves()"
end

proc scalewaves(mode,name,s,Pvalue,xshouldbe)
	variable mode = 1
	string name = "sts"
	Variable s = 1
	variable Pvalue = 0
	variable xshouldbe = 0
	prompt mode,"Mode", popup "Direct input s; Calculate s by reference scaling"
	prompt name,"Wave to apply divider"
	Prompt s,"divider ratio"
	prompt Pvalue, "[Mode 2 only] Reference P point"
	prompt xshouldbe, "[Mode 2 only] Correct x value of the reference P point"

	if (mode == 1)
		scalewave($name,s)
	endif

	if (mode == 2)
		calculates(Pvalue,xshouldbe,$name)
	endif
end

Function scalewave(name,s)
	wave name
	Variable s  // 你可以自行更改

	// 获取点数 n 和当前 scale 范围
	Variable n = dimsize(name,0)
	Variable a = dimoffset(name,0)  // 获取当前最大x值

	// 计算新的 dx（缩放之后的点间距）
	Variable dxOld = dimdelta(name,0)
	Variable dxNew = dxOld * s

	// 设置新的 scale，使得中间点（坐标为0）保持不变
	// 中心点索引为 mid = floor(n/2)
	Variable mid = floor(n/2)
	SetScale/P x, -mid*dxNew, dxNew, name
end
/////////////////////////////////////////////////////////////////////////////////////////////

Function calculates(Pvalue,xshouldbe,name)
	variable Pvalue
	variable xshouldbe
	wave name

	Variable s

	Variable n = dimsize(name,0)

	Variable mid = floor(n/2)

	//variable scaledstart = -mid*dimdelta(name,0)*s

	//scaledstart+Pvalue*(dimdelta(name,0)*s) =  xshouldbe
	//(-mid*dimdelta(name,0)+Pvalue*dimdelta(name,0))*s =  xshouldbe

	s = (xshouldbe)/(-mid*dimdelta(name,0)+Pvalue*dimdelta(name,0))

	//return s
	scalewave(name,s)
end

/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_rescalegroupc(ctrlName) : ButtonControl
	String ctrlName
	Execute "rescalegroupc()"
end

Proc rescalegroupc(ratiowave,batchname,num,notes)
	string ratiowave = "divider_ratio"
	string batchname = "sts"
	variable num
	string notes = "Need to calculate divider ratio for each spectrum first"
	Prompt ratiowave,"Divider ratio wave"
	Prompt batchname,"Batch name"
	Prompt num,"Total spectra in Batch"
	rescalegroup($ratiowave,batchname,num)
end

Function rescalegroup(ratiowave,batchname,num)
	wave ratiowave
	string batchname
	variable num
	variable i
	string name

	string templatewave = batchname+num2str(1)

	i=0
	do
		name = batchname +num2str(i+1)

		scalewave($name,ratiowave[i])

		madewavebytemplate($name,$templatewave)
		i+=1
	while (i<num)

	string newname = "Interscale_"+batchname
	linkstsmap(newname,num,1)

end

///////////////////////////////////////////////////////////////////
Function ButtonProc_madewavebytemplate(ctrlName) : ButtonControl
	String ctrlName
	Execute "madewavebytemplatec()"
end

proc madewavebytemplatec(datawave,templatewave,notes)
	string datawave
	string templatewave
	string notes = "Reformat A as B"
	prompt datawave, "A wave"
	prompt templatewave, "B wave"
	madewavebytemplate2($datawave,$templatewave)
end

Function madewavebytemplate2(datawave,templatewave)
	wave datawave
	wave templatewave

	string newname = "Interscale_"+nameofwave(datawave)
	make/n=(dimsize(templatewave,0))/o $newname
	setscale/p x,dimoffset(templatewave,0),dimdelta(templatewave,0),"",$newname
	wave newnamew = $newname
	newnamew = nan

	variable xtemplate,pdata
	variable i
	i=0
	do
		xtemplate = dimoffset(newnamew,0)+i*dimdelta(newnamew,0)
		//xtemplate = dimoffset(datawave,0)+pdata*dimdelta(datawave,0)
		pdata = round((xtemplate-dimoffset(datawave,0))/(dimdelta(datawave,0)))

		if (pdata >= 0 && pdata <= dimsize(datawave,0)-1)

			newnamew[i] = datawave[pdata]
		else
		endif
		i+=1
	while (i<dimsize(templatewave,0))
	display datawave newnamew
end


Function madewavebytemplate(datawave,templatewave)
	wave datawave
	wave templatewave

	string newname = "Interscale_"+nameofwave(datawave)
	make/n=(dimsize(templatewave,0))/o $newname
	setscale/p x,dimoffset(templatewave,0),dimdelta(templatewave,0),"",$newname
	wave newnamew = $newname
	newnamew = nan

	variable xtemplate,pdata
	variable i
	i=0
	do
		xtemplate = dimoffset(newnamew,0)+i*dimdelta(newnamew,0)
		//xtemplate = dimoffset(datawave,0)+pdata*dimdelta(datawave,0)
		pdata = round((xtemplate-dimoffset(datawave,0))/(dimdelta(datawave,0)))

		if (pdata >= 0 && pdata <= dimsize(datawave,0)-1)

			newnamew[i] = datawave[pdata]
		else
		endif
		i+=1
	while (i<dimsize(templatewave,0))
	//display datawave newnamew
end
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_unevenlinep(ctrlName) : ButtonControl
	String ctrlName
	Execute "unevenlinepc()"
end

Proc unevenlinepc(batchname,templatewave,num)
	string batchname = "sts"
	string templatewave = "sts1"
	variable num
	prompt batchname, "Name of the batch"
	prompt templatewave, "Template wave"
	prompt num,"Total spectra in Batch"

	unevenlinep(batchname,templatewave,num)
end


Function unevenlinep(batchname,templatewave,num)
	string batchname
	string templatewave
	variable num
	variable i
	string name


	i=0
	do
		name = batchname +num2str(i+1)

		//scalewave($name,ratiowave[i])

		madewavebytemplate($name,$templatewave)
		i+=1
	while (i<num)

	string newname = "Interscale_"+batchname
	linkstsmap(newname,num,1)
end
