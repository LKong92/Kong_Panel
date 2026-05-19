#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
Function ButtonProc_extract3dslinecut(ctrlName) : ButtonControl
	String ctrlName
	Execute "extract3dslinecut()"
end

Proc extract3dslinecut(name)
	String name
	Prompt name,"Data name from nanonis"

	duplicate/o $name linecut3dsa
    make/O/N=(dimsize($name,2),dimsize($name,0)) linecut3dsa
    setscale/p x, dimoffset($name,2),dimdelta($name,2),linecut3dsa
	setscale/p y, dimoffset($name,0),dimdelta($name,0),linecut3dsa
	linecut3dsa=$name[q][0][p]
	//display;appendimage linecut3ds

End


Function ButtonProc_slice1ddpro(ctrlName) : ButtonControl
	String ctrlName
	Execute "slice1ddpro()"
end

Proc slice1ddpro(matt)
	String matt="linecut3dsa"
	slice1dd(matt)
end

Function slice1dd(matt)
	string matt
	Variable i
	wave n=$matt

	variable number
	number= dimsize(n,1)

	string stsname
	i=1
	do
		stsname="sts"+num2str(i)
		make/N=(dimsize(n,0))/o $stsname

		wave nn=$stsname
		setscale/p x, dimoffset(n,0),dimdelta(n,0),"",nn
		nn=n[p][i-1]
		i+=1
	while (i<number+1)
end
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//This procedure used to automatically plot linecut from nanonis 3ds
//the datafolder is coverted to the subdatafolder
//Before launching this procedure, select a Nanonis .3ds file when prompted.
//This procedure will call the load procedure and retrieve the dI/dV and Height data from the subfolder to root:
//and automatically read the length scale and energy scale of the linecut.
//We defined some global variable, that allow user to reuse the procedure in one .pxp
//Only the first time use this procedure will call load procedure.
//If you are not the first time use this procedure, it will call the Killallgraph function to make sure layout correctly
//If you want to do SC gap fitting, please choose Advanced, if not just set that value to anynumber except "1", e.g. "0"
//There are several parameters we do not put on the head of procedure, that if you want to
//change, you need open the code to modify the Kernel.
//For example, the smooth time for reference normalization; the font size for figure plot,
//the gap fiting range, the lattice constant,....
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
Function ButtonProc_AutoNanislinecut(ctrlName) : ButtonControl
	String ctrlName
	Execute "AutoNanislinecut()"
end

Proc initialg()
	variable/G cktimesforAutol
	cktimesforAutol = 0
end
Proc initialgl()
	variable/G loadforAutol
	loadforAutol = 0
end

Proc AutoNanislinecut(FFTp,partial1,partial2,AorB,flag,flag2,flag3)
	Variable FFTp = 24
	variable partial1 = 0
	variable partial2 = 0
	String AorB = "A"
	variable flag =0
	variable flag2 = 0
	variable flag3 = 0
	Prompt FFTp, "the P number of the FFT peak, where to pick the phase difference"
	Prompt partial1, "the Q Start of interested region of the linecut"
	Prompt partial2, "the Q End of interested region of the linecut"
	Prompt AorB, "A or B"
	Prompt flag, "Do you want advanced gap analysis (gap extraction & gapsize/Z-height correlation analysis)? Yes[1]/No[0]; \rIf yes, the fitting parameters need to be adjusted inside the codes"
	Prompt flag2, "Do you want normalized correlation ? Yes[1]/No[0]; \rIf yes, the smooth number for [Normalization reference curve] need to be adjusted inside the codes"
	Prompt flag3, "Do you want FFT phase analysis? Yes[1]/No[0];\rIf yes, the P value of FFT peak needs to be adjusted inside the codes"

	variable ashift
	//Prompt ashift, "The offset of Drawing lattice line."

	////////////////////////////////////////////////////To make sure everytime rerun the Auto linecut, the previous graph can be close automatically, in order to make the layout correct.
	If (exists("cktimesforAutol") ==0)
		initialg()
	else
	endif
	if (cktimesforAutol == 0)
	else
		KillAllGraphs()
	endif
	////////////////////////////////////////////////////
	If (partial2 == 0)
	else
		if(mod(partial2-partial1,2) == 0)
		partial2+=1
		else
		endif
	endif

	////////////////////////////////////////////////////Load Data
	If (exists("loadforAutol") ==0)
		initialgl()
	else
	endif

	if (loadforAutol == 0)
		getFileFolderInfo/Q
		KP_LoadNanonisData(S_path)
		loadforAutol+=1
		string/G s_p
		s_p = S_path

	else
	endif
	////////////////////////////////////////////////////



	////////////////////////////// some variables for plot the figures
	variable fontsizee = 9//**** the size of the lable
	String fontsizees
	if (fontsizee < 10)
		fontsizees = "0"+num2str(fontsizee)
	else
		fontsizees = num2str(fontsizee)
	endif

	variable lableoffset = 10//**** offset the label
	//////////////////////////////

	//Prompt tname,"Nanonis Name of the 3ds"
	string tname
	tname=KP_GetLastLoadedNanonisFolder() // Grab the Nanonis name of 3ds from the last loaded data folder.

	string ttname
	ttname="root:"+tname
	SetDataFolder ttname
	string wname
	wname=tname+"_LI_Demod_1_Y";
	//**duplicate/o $wname $tname
	duplicate/o $wname root:$tname
	String zname
	zname=tname+"_Z"
	string Znamea
	Znamea=tname+"_Za"
	duplicate/o $zname root:$znamea
	SetDataFolder root:

	extract3dslinecut(tname)

	if (partial2 == 0)
		partial2 = (dimsize(linecut3dsa,1)-1)
		partial1 = 0
	else
	endif

	duplicate/o/R=[0,dimsize(linecut3dsa,0)][partial1,partial2] linecut3dsa linecut3ds
	slice1ddpro("linecut3ds")
	variable totalnum=dimsize(linecut3ds,1)
	variable xstart=dimoffset(linecut3ds,0)
	variable xend=dimoffset(linecut3ds,0)+(dimsize(linecut3ds,0)-1)*dimdelta(linecut3ds,0)
	variable length = (dimsize(linecut3ds,1)-1)*dimdelta(linecut3ds,1)

	normrange("sts",totalnum,xstart,xend)
	smoothall("sts",totalnum,2)

	displaymulti("sts",1,totalnum)
	modifygraph width=250, height=450
	modifygraph width=0,height=0
	modifygraph lsize=1
	ModifyGraph mirror=2
	ModifyGraph tick=2
	Label left "\Z"+fontsizees+"\F'times'dI/dV (a.u.)";
	Label bottom "\Z"+fontsizees+"\F'times'Sample Bias\M\F'times'"+"\Z"+fontsizees+" (meV)"
	ModifyGraph fSize=6,tick=2
	ModifyGraph lblMargin=lableoffset

	variable shiftt
	shiftt=0.1*64/totalnum
	Constantoffset_n(shiftt,1)
	color_edc()

	linkstsmap_P("sts",1,totalnum)

	setscale/p y,dimoffset(linecut3ds,1),dimdelta(linecut3ds,1),"",mapsts
	setscale/p x,dimoffset(linecut3ds,1),dimdelta(linecut3ds,1),"",$znamea
	string znamed
	znamed=zname+"_d"
	duplicate/o $Znamea $znamed
	duplicate/o/R=[partial1,partial2] $Znamea $zname
	setscale/p x,dimoffset(mapsts,1),dimdelta(mapsts,1),"",$zname
	wavestats/Q $zname
	$zname-=V_min
	wavestats/Q $zname
	append/VERT/T $zname
	SetAxis top V_max-3*(V_max-V_min),*
	Label Left "\Z"+fontsizees+"\F'times'Distance (Å\M\F'times'"+"\Z"+fontsizees+")";DelayUpdate
	Label Top "\Z"+fontsizees+"\F'times'Tip Z-height (nm)"
	Label bottom "\Z"+fontsizees+"\F'times'Sample Bias\M\F'times'"+"\Z"+fontsizees+" (meV)"
	ModifyGraph lblMargin=lableoffset
	ModifyGraph fSize=6,tick=2
	///......................................................
	///From here this is advanced part to analysis SC gapsize
	///......................................................
	If (flag==1)


		variable numatoms
		variable lx //*************************[need adjust] this is the lattice constant along the line
		//lx = 3.8
		lx=length/FFTp
		print "converted lattice constance equal to "+num2str(lx)
		numatoms= round(length/lx)


		extrastsfrommap3dGuassian3(-3,-1,1,3,0) //*************************[need adjust] Fit the gap by GCB method
		print "statscorrelation(gapsizefit,$zname)" // Calculate the correlation coefficent
		print statscorrelation(gapsizefit,$zname)

		dowindow/F graph1
		findpeak/N/Q gapsizefit
		ashift=V_PeakLoc
		appendVline(ashift,lx,xend,numatoms,1) // Draw line on the linecut

		display $zname;append/R gapsizefit //simutannously display gap and height
		ModifyGraph rgb(gapsizefit)=(0,0,0)
		//Legend/C/N=text0/J/F=0/A=RB "\\s($zname)"+ zname+"\r\\s(gapsizefit) gapsizefit\r"
		TextBox/C/N=text1/F=0/B=1/A=LT "Pearson's Correlation\rR = "+num2str(statscorrelation(gapsizefit,$zname))
		Label Bottom "\Z"+fontsizees+"\F'times'Distance (Å\M\F'times'"+"\Z"+fontsizees+")";DelayUpdate
		Label Right "\Z"+fontsizees+"\F'times'Gap size (meV)"
		Label Left "\Z"+fontsizees+"\F'times'Tip Z-height (nm)"
		ModifyGraph fSize=6,tick=2
		ModifyGraph axRGB(left)=(65535,0,0),tlblRGB(left)=(65535,0,0),alblRGB(left)=(65535,0,0)
		ModifyGraph lblMargin=lableoffset

			Getaxis/Q RIGHT
			variable rrwlen1,rrwlen2
			rrwlen1=V_min
			rrwlen2=V_max

			Getaxis/Q Left
			variable lrwlen1,lrwlen2
			lrwlen1=V_min
			lrwlen2=V_max

			Getaxis/Q Bottom
			variable brwlen1,brwlen2
			brwlen1=V_min
			brwlen2=V_max



			variable rr
			String rawname
			rr=1
			do
				rawname="lines"+num2str(rr)
				append/VERT $rawname
				ModifyGraph rgb($rawname)=(0,0,65535),lstyle($rawname)=1,lsize($rawname)=0.2
				rr+=1
			while (rr<numatoms+1)
			SetAxis right rrwlen1,rrwlen2
			SetAxis left lrwlen1,lrwlen2
			SetAxis bottom brwlen1,brwlen2


		string destwave1
		destWave1="M_jointHistogram_origin"
		jointHistogram/BINS={10,10} $zname, gapsizefit //Joint Histogram
		duplicate/o M_jointHistogram $destwave1
		display;appendimage $destWave1
		print "jointHistogram/DEST="+destwave1+"/BINS={15,15} "+Zname+","+"gapsizefit"
		Modifygraph width=300,height=300
		Modifygraph width=0,height=0
		//Label Bottom "\Z"+fontsizees+"\F'times'Tip Z-height (nm)"
		//Label Left "\Z"+fontsizees+"\F'times'Gap size (meV)"
		//ModifyGraph fSize=6,tick=2
		//ModifyGraph lblMargin=lableoffset
		ModifyGraph noLabel=2,axThick=0


	else
	endif
	///......................................................

	///********************************Make curvature plot
	variable/g T_EDCT=5
	variable/g T_EDCW=5
	variable/g T_EDCF=.1
	variable/g t_EDCFi=.01
	variable/g T_MDCT=5
	variable/g T_MDCW=5
	variable/g T_MDCF=.1
	variable/g t_MDCFi=.01
	variable/g T_twoDF=.01
	variable/g T_twoDFi=.001
	variable/g T_twoDW=1
	variable/g T_2dUPdate=0
	string/g T_curv_data_STR

	string/g T_curv_data_STR
	string temp
	temp=“mapsts”
	T_curv_data_STR=temp
	EDCCurv()
	MDCcurv()
	twoDcurv()

	Curv_Panel()
	string ctrlName
	string/g t_curv_data_str
	string data=t_curv_data_str+"_curvh"
	idisp($data)
	append/VERT/T $zname
	wavestats/Q $zname
	SetAxis top V_max-3*(V_max-V_min),*
	modifygraph lsize=1
	ModifyGraph tick=2
	Label left "\Z"+fontsizees+"\F'times'Distance (Å\M\F'times'"+"\Z"+fontsizees+")";DelayUpdate
	Label bottom "\Z"+fontsizees+"\F'times'Sample Bias\M\F'times'"+"\Z"+fontsizees+" (meV)"
	Label top "\Z"+fontsizees+"\F'times'Tip Z-height (nm)"
	modifygraph width=250, height=450
	modifygraph width=0,height=0
	ModifyGraph fSize=6,tick=2
	ModifyGraph lblMargin=lableoffset


	///......................................................
	///From here this is advanced part to analysis SC gapsize
	///......................................................
	If (flag==1)
		appendVline(ashift,lx,xend,numatoms,1)
	else
	endif
	///......................................................


	///********************************************************Normalized correlation
	If (flag2==1 && flag == 1)
		Duplicate/o gapsizefit gapsizefit_ref
		Duplicate/o gapsizefit gapsizefit_norm
 		Smooth 200, gapsizefit_ref  //***************** Smooth number can be change
 		//Smooth 100, gapsizefit_ref
 		gapsizefit_norm = gapsizefit/gapsizefit_ref



 		String zname_ref
 		zname_ref = zname +"_ref"
 		string zname_norm
 		zname_norm = zname +"_norm"

 		Duplicate/o $zname $zname_norm

 		$zname_norm +=1
 		Duplicate/o $zname_norm $zname_ref
 		Duplicate/o $zname_norm Znamenormt

		Smooth 200, $zname_ref //***************** Smooth number can be change
 		//Smooth 100, $zname_ref
 		$zname_norm = Znamenormt / $zname_ref

 		print "statscorrelation(gapsizefit_norm,$zname_norm)" // Calculate the correlation coefficent
		print statscorrelation(gapsizefit_norm,$zname_norm)
 		display $zname_norm;append/R gapsizefit_norm //simutannously display the normalized gap and height
		ModifyGraph rgb(gapsizefit_norm)=(0,0,0)
		//Legend/C/N=text0/F=0/A=RB "\\s($zname_norm)"+zname_norm+"\r\\s(gapsizefit_norm) gapsizefit_norm"
		TextBox/C/N=text1/F=0/B=1/A=LT "Pearson's Correlation\rR = "+num2str(statscorrelation(gapsizefit_norm,$zname_norm))
		Label Bottom "\Z"+fontsizees+"\F'times'Distance (Å\M\F'times'"+"\Z"+fontsizees+")";DelayUpdate
		Label Right "\Z"+fontsizees+"\F'times'Normalized Gap (a.u.)"
		Label Left "\Z"+fontsizees+"\F'times'Normalized Z (a.u.)"
		ModifyGraph fSize=6,tick=2
		ModifyGraph axRGB(left)=(65535,0,0),tlblRGB(left)=(65535,0,0),alblRGB(left)=(65535,0,0)
		ModifyGraph lblMargin=lableoffset

			Getaxis/Q RIGHT
			variable rrlen1,rrlen2
			rrlen1=V_min
			rrlen2=V_max

			Getaxis/Q Left
			variable lrlen1,lrlen2
			lrlen1=V_min
			lrlen2=V_max

			Getaxis/Q Bottom
			variable brlen1,brlen2
			brlen1=V_min
			brlen2=V_max

			variable nn
			String normname

			nn=1
			do
				normname="lines"+num2str(nn)
				append/VERT $normname
				ModifyGraph rgb($normname)=(0,0,65535),lstyle($normname)=1,lsize($normname)=0.2
				nn+=1
			while (nn<numatoms+1)
			SetAxis right rrlen1,rrlen2
			SetAxis left lrlen1,lrlen2
			SetAxis bottom brlen1,brlen2


		string destwave2
		destWave2="M_jointHistogram_norm"
		jointHistogram/BINS={10,10} $zname_norm, gapsizefit_norm //Joint Histogram of the normalized gap and height
		duplicate/o M_jointHistogram $destwave2
		display;appendimage $destWave2
		print "jointHistogram/DEST="+destwave2+"/BINS={15,15} "+Zname_norm+","+"gapsizefit_norm"
		Modifygraph width=300,height=300
		Modifygraph width=0,height=0
		//Label Bottom "\Z"+fontsizees+"\F'times'Tip Z-height (nm)"
		//Label Left "\Z"+fontsizees+"\F'times'Gap size (meV)"
		//ModifyGraph fSize=6,tick=2
		//ModifyGraph lblMargin=lableoffset
		ModifyGraph noLabel=2,axThick=0
	else
	endif
	Print ""
	Print "AutoNanislinecut("+num2str(FFTp)+","+num2str(partial1)+","+num2str(partial2)+","+AorB+","+num2str(flag)+","+num2str(flag2)+","+num2str(flag3)+")"


	/////////////////////////////////////////////////////////////
 	/////////////////////////////////////////////////////////////
 	/////////////////////////////////////////////////////////////
 	//FFT part to extract the phase difference
 	/////////////////////////////////////////////////////////////
 	/////////////////////////////////////////////////////////////
 	/////////////////////////////////////////////////////////////
 	If (flag3==1 && flag == 1)

 		variable pointt //*********** this is the P value of the interesting FFT peak
 		pointt = FFTp  //******************* change this for different dataset
 		/////////////////////////////////////////////////////////

 		FFT/OUT=3/DEST=M_FFT_Amplitude  gapsizefit;
 		duplicate/o M_FFT_Amplitude FFT_Amp_gapsizefit
 		FFT_Amp_gapsizefit[0] = nan

 		variable xmarker
 		xmarker = dimoffset(FFT_Amp_gapsizefit,0)+dimdelta(FFT_Amp_gapsizefit,0)*pointt

 		make/N=1/o marker_gapA
 		Setscale/p x,xmarker,1,"",marker_gapA
 		marker_gapA = FFT_Amp_gapsizefit[pointt]

 		If (flag2==1)
 			FFT/OUT=3/DEST=M_FFT_Amplitude  gapsizefit_norm;
 			duplicate/o M_FFT_Amplitude FFT_Amp_gapsizefit_norm
			FFT_Amp_gapsizefit_norm[0] = nan

			make/N=1/o marker_gapNA
 			Setscale/p x,xmarker,1,"",marker_gapNA
 			marker_gapNA = FFT_Amp_gapsizefit_norm[pointt]

		else
		endif

		display FFT_Amp_gapsizefit; append marker_gapA
		ModifyGraph mode(marker_gapA)=3,marker(marker_gapA)=0,msize(marker_gapA)=5
		ModifyGraph lblMargin=lableoffset

		If (flag2==1)
			append/R FFT_Amp_gapsizefit_norm
			append/R marker_gapNA
			ModifyGraph mode(marker_gapNA)=3,marker(marker_gapNA)=0,msize(marker_gapNA)=5
			ModifyGraph lblMargin=lableoffset
		else
		endif

		Label Bottom "\Z"+fontsizees+"\F'times'1/L (Å\S\F'times'-1\M\F'times'"+"\Z"+fontsizees+")";DelayUpdate
		Label Left "\Z"+fontsizees+"\F'times'gap_amp (Raw)"
		ModifyGraph fSize=6,tick=2
		ModifyGraph lblMargin=lableoffset

		If (flag2==1)
			Label Right "\Z"+fontsizees+"\F'times'gap_amp (Norm)"
			ModifyGraph fSize=6,tick=2
			//Legend/C/N=text0/F=0
			ModifyGraph rgb(FFT_Amp_gapsizefit_norm)=(0,0,0)
			ModifyGraph rgb(marker_gapNA)=(0,0,0)
			ModifyGraph axRGB(left)=(65535,0,0),tlblRGB(left)=(65535,0,0),alblRGB(left)=(65535,0,0)
 			ModifyGraph lblMargin=lableoffset

 		else
 		endif
 		/////////////////////////////////////////////////////////////
		FFT/OUT=3/DEST=M_FFT_Amplitude  $zname;
		String FFTampzname
		FFTampzname = "FFT_Amp_"+zname
		duplicate/o M_FFT_Amplitude $FFTampzname
		$FFTampzname[0] = nan

		make/N=1/o marker_ZA
 		Setscale/p x,xmarker,1,"",marker_ZA
 		marker_ZA = $FFTampzname[pointt]



		If (flag2==1)
		FFT/OUT=3/DEST=M_FFT_Amplitude  $zname_norm;
		String FFTampzname_norm
		FFTampzname_norm = "FFT_Amp_"+zname_norm
		duplicate/o M_FFT_Amplitude $FFTampzname_norm
		$FFTampzname_norm[0] = nan

		make/N=1/o marker_ZNA
 		Setscale/p x,xmarker,1,"",marker_ZNA
 		marker_ZNA = $FFTampzname_norm[pointt]

		else
		endif

		display $FFTampzname; ; append marker_ZA
		ModifyGraph mode(marker_ZA)=3,marker(marker_ZA)=0,msize(marker_ZA)=5
		ModifyGraph lblMargin=lableoffset


		If (flag2==1)
			append/R $FFTampzname_norm
			append/R marker_ZNA
			ModifyGraph mode(marker_ZNA)=3,marker(marker_ZNA)=0,msize(marker_ZNA)=5
			ModifyGraph lblMargin=lableoffset

		else
		endif

		Label Bottom "\Z"+fontsizees+"\F'times'1/L (Å\S\F'times'-1\M\F'times'"+"\Z"+fontsizees+")";DelayUpdate
		Label Left "\Z"+fontsizees+"\F'times'Z_amp (Raw)"
		ModifyGraph fSize=6,tick=2
		ModifyGraph lblMargin=lableoffset

		If (flag2==1)
			Label Right "\Z"+fontsizees+"\F'times'Z_amp (Norm)"
			ModifyGraph fSize=6,tick=2
			//Legend/C/N=text0/F=0
			ModifyGraph rgb($FFTampzname_norm)=(0,0,0)
			ModifyGraph rgb(marker_ZNA)=(0,0,0)
			ModifyGraph axRGB(left)=(65535,0,0),tlblRGB(left)=(65535,0,0),alblRGB(left)=(65535,0,0)
			ModifyGraph lblMargin=lableoffset

		else
		endif
		/////////////////////////////////////////////////////////////
		FFT/OUT=5/DEST=M_FFT_Phase  gapsizefit;
 		duplicate/o M_FFT_Phase FFT_p_gapsizefit
 		FFT_p_gapsizefit[0] = nan

 		make/N=1/o marker_gapp
 		Setscale/p x,xmarker,1,"",marker_gapp
 		marker_gapp = FFT_p_gapsizefit[pointt]

 		If (flag2==1)
 			FFT/OUT=5/DEST=M_FFT_Phase  gapsizefit_norm;
 			duplicate/o M_FFT_Phase FFT_p_gapsizefit_norm
			FFT_p_gapsizefit_norm[0] = nan

			make/N=1/o marker_gapNp
 			Setscale/p x,xmarker,1,"",marker_gapNp
 			marker_gapNp = FFT_p_gapsizefit_norm[pointt]
		else
		endif


		display FFT_p_gapsizefit; append marker_gapp
		ModifyGraph mode(marker_gapp)=3,marker(marker_gapp)=0,msize(marker_gapp)=5
		ModifyGraph lblMargin=lableoffset

		If (flag2==1)
			append/R FFT_p_gapsizefit_norm
			append/R marker_gapNp
			ModifyGraph mode(marker_gapNp)=3,marker(marker_gapNp)=0,msize(marker_gapNp)=5
			ModifyGraph lblMargin=lableoffset

		else
		endif

		Label Bottom "\Z"+fontsizees+"\F'times'1/L (Å\S\F'times'-1\M\F'times'"+"\Z"+fontsizees+")";DelayUpdate
		Label Left "\Z"+fontsizees+"\F'times'gap_phs (Raw)"
		ModifyGraph fSize=6,tick=2
		ModifyGraph lblMargin=lableoffset

		If (flag2==1)
			Label Right "\Z"+fontsizees+"\F'times'gap_phs (Norm)"
			ModifyGraph fSize=6,tick=2
			//Legend/C/N=text0/F=0
			ModifyGraph rgb(FFT_p_gapsizefit_norm)=(0,0,0)
			ModifyGraph rgb(marker_gapNp)=(0,0,0)
			ModifyGraph axRGB(left)=(65535,0,0),tlblRGB(left)=(65535,0,0),alblRGB(left)=(65535,0,0)
			ModifyGraph lblMargin=lableoffset

		else
		endif

		/////////////////////////////////////////////////////////////
		FFT/OUT=5/DEST=M_FFT_Phase  $zname;
		String FFTpzname
		FFTpzname = "FFT_p_"+zname
		duplicate/o M_FFT_Phase $FFTpzname
		$FFTpzname[0] = nan

		make/N=1/o marker_Zp
 		Setscale/p x,xmarker,1,"",marker_Zp
 		marker_Zp = $FFTpzname[pointt]


		If (flag2==1)
			FFT/OUT=5/DEST=M_FFT_Phase  $zname_norm;
			String FFTpzname_norm
			FFTpzname_norm = "FFT_p_"+zname_norm
			duplicate/o M_FFT_Phase $FFTpzname_norm
			$FFTpzname_norm[0] = nan

			make/N=1/o marker_ZNp
 			Setscale/p x,xmarker,1,"",marker_ZNp
 			marker_ZNp = $FFTpzname_norm[pointt]
		else
		endif

		display $FFTpzname; append marker_Zp
		ModifyGraph mode(marker_Zp)=3,marker(marker_Zp)=0,msize(marker_Zp)=5
		ModifyGraph lblMargin=lableoffset

		If (flag2==1)
			append/R $FFTpzname_norm
			append/R marker_ZNp
			ModifyGraph mode(marker_ZNp)=3,marker(marker_ZNp)=0,msize(marker_ZNp)=5
			ModifyGraph lblMargin=lableoffset

		else
		endif

		Label Bottom "\Z"+fontsizees+"\F'times'1/L (Å\S\F'times'-1\M\F'times'"+"\Z"+fontsizees+")";DelayUpdate
		Label Left "\Z"+fontsizees+"\F'times'Z_phs (Raw)"
		ModifyGraph fSize=6,tick=2
		ModifyGraph lblMargin=lableoffset

		If (flag2==1)
			Label Right "\Z"+fontsizees+"\F'times'Z_phs (Norm)"
			ModifyGraph fSize=6,tick=2
			//Legend/C/N=text0/F=0
			ModifyGraph rgb($FFTpzname_norm)=(0,0,0)
			ModifyGraph rgb(marker_ZNp)=(0,0,0)
			ModifyGraph axRGB(left)=(65535,0,0),tlblRGB(left)=(65535,0,0),alblRGB(left)=(65535,0,0)
			ModifyGraph lblMargin=lableoffset

		else
		endif

		variable difphaseraw
		if (abs(marker_gapp[0]*180/pi-marker_Zp[0]*180/pi) < 180)
			difphaseraw = abs(marker_gapp[0]*180/pi-marker_Zp[0]*180/pi)
		else
			difphaseraw = 360 - abs(marker_gapp[0]*180/pi-marker_Zp[0]*180/pi)
		endif

		print ""
		print ""
		Print "//*********************************************************//"
		Print "//****************Phase Analysis Report********************//"
		Print "//*********************************************************//"
		Print "//**The feature peak position: P = "+num2str(pointt)+" **********************//"
		Print "//**The feature peak Value: x = "+num2str(xmarker)+" Å-1 ***************//"
		Print "//**************** 1st Raw Data ***************************//"
		Print "//** Z(phase) = "+num2str(marker_Zp[0]*180/pi)+" degree ****************************//"
		Print "//** Gap(phase) = "+num2str(marker_gapp[0]*180/pi)+" degree ***************************//"
		Print "//** difference = "+num2str(difphaseraw)+" degree ***************************//"

		display FFT_p_gapsizefit; append/R $FFTpzname
		Label Bottom "\Z"+fontsizees+"\F'times'1/L (Å\S\F'times'-1\M\F'times'"+"\Z"+fontsizees+")";DelayUpdate
		Label Left "\Z"+fontsizees+"\F'times'gap_phs (Raw)"
		Label Right "\Z"+fontsizees+"\F'times'Z_phs (Raw)"
		ModifyGraph fSize=6,tick=2
		ModifyGraph rgb(FFT_p_gapsizefit)=(0,0,0)
		ModifyGraph axRGB(right)=(65535,0,0),tlblRGB(right)=(65535,0,0),alblRGB(right)=(65535,0,0)
		append marker_gapp
		ModifyGraph rgb(marker_gapp)=(0,0,0)
		ModifyGraph mode(marker_gapp)=3,marker(marker_gapp)=0,msize(marker_gapp)=5
		append/R marker_Zp
		ModifyGraph mode(marker_Zp)=3,marker(marker_Zp)=0,msize(marker_Zp)=5
		TextBox/C/N=text0/A=RT "The feature peak position: P = "+num2str(pointt)+"\rThe feature peak Value: x = "+num2str(xmarker)+" Å-1\rd(phase)_raw = "+num2str(difphaseraw)+" degree"
		ModifyGraph lblMargin=lableoffset

		If (flag2==1)
			variable difphasenorm
			if (abs(marker_gapNp[0]*180/pi-marker_ZNp[0]*180/pi) < 180)
				difphasenorm = abs(marker_gapNp[0]*180/pi-marker_ZNp[0]*180/pi)
			else
				difphasenorm = 360 - abs(marker_gapNp[0]*180/pi-marker_ZNp[0]*180/pi)
			endif
			Print "//**************** 2nd Normalized Data ********************//"
			Print "//** Z(phase) = "+num2str(marker_ZNp[0]*180/pi)+" degree *****************************//"
			Print "//** Gap(phase) = "+num2str(marker_gapNp[0]*180/pi)+" degree ****************************//"
			Print "//** difference = "+num2str(difphasenorm)+" degree ***************************//"
			Print "//*********************************************************//"
			display FFT_p_gapsizefit_norm; append/R $FFTpzname_norm
			Label Bottom "\Z"+fontsizees+"\F'times'1/L (Å\S\F'times'-1\M\F'times'"+"\Z"+fontsizees+")";DelayUpdate
			Label Left "\Z"+fontsizees+"\F'times'gap_phs (Norm)"
			Label Right "\Z"+fontsizees+"\F'times'Z_phs (Norm)"
			ModifyGraph fSize=6,tick=2
			ModifyGraph rgb(FFT_p_gapsizefit_norm)=(0,0,0)
			ModifyGraph axRGB(right)=(65535,0,0),tlblRGB(right)=(65535,0,0),alblRGB(right)=(65535,0,0)
			append marker_gapNp
			ModifyGraph rgb(marker_gapNp)=(0,0,0)
			ModifyGraph mode(marker_gapNp)=3,marker(marker_gapNp)=0,msize(marker_gapNp)=5
			append/R marker_ZNp
			ModifyGraph mode(marker_ZNp)=3,marker(marker_ZNp)=0,msize(marker_ZNp)=5
			TextBox/C/N=text0/A=RT "The feature peak position: P = "+num2str(pointt)+"\rThe feature peak Value: x = "+num2str(xmarker)+" Å-1\rd(phase)_norm = "+num2str(difphasenorm)+" degree"
			ModifyGraph lblMargin=lableoffset

		else
		endif


		///////////////////////////////////do layout//////////////////////////////////////////

		if (flag2 == 1)
		•Preferences 1 //The preference is not incorporate in procedure,
					   // we "capture-preference" the window size and zoom setting for layout,
					   //but in order to use that we delibrately turn on the preference before plot layout,
					   //also we do not want the preference influenc other code, we turn it off at the end.
		•layout;LayoutPageAction size(-1)=(959, 540), margins(-1)=(0, 0, 0, 0)
		•AppendToLayout/T Graph0
		•ModifyLayout width(Graph0)=140,height(Graph0)=250
		•AppendToLayout/T Graph1
		•ModifyLayout left(Graph1)=144,top(Graph1)=0,width(Graph1)=140,height(Graph1)=250
		•ModifyLayout top(Graph1)=3
		•AppendToLayout/T mapsts_CurvH_plot
		•ModifyLayout width(mapsts_CurvH_plot)=140,height(mapsts_CurvH_plot)=250
		•ModifyLayout left(mapsts_CurvH_plot)=288,top(mapsts_CurvH_plot)=3
		•AppendToLayout/T Graph8
		•ModifyLayout left(Graph8)=432,width(Graph8)=238,height(Graph8)=125
		•AppendToLayout/T Graph7
		•ModifyLayout width(Graph7)=238,height(Graph7)=125
		•ModifyLayout left(Graph7)=670
		•AppendToLayout/T Graph10
		•ModifyLayout width(Graph10)=238,height(Graph10)=125
		•ModifyLayout left(Graph10)=432,top(Graph10)=128
		•AppendToLayout/T Graph9
		•ModifyLayout width(Graph9)=238,height(Graph9)=125
		•ModifyLayout left(Graph9)=670,top(Graph9)=128
		•AppendToLayout/T Graph3
		•ModifyLayout width(Graph3)=452,height(Graph3)=122
		•ModifyLayout top(Graph3)=245,height(Graph3)=144
		•AppendToLayout/T Graph5
		•ModifyLayout width(Graph5)=452,height(Graph5)=144
		•ModifyLayout top(Graph5)=378
		•AppendToLayout/T Graph4
		•ModifyLayout left(Graph4)=-30,top(Graph4)=352,width(Graph4)=100,height(Graph4)=72
		•AppendToLayout/T Graph6
		•ModifyLayout left(Graph6)=-30,top(Graph6)=490,width(Graph6)=100,height(Graph6)=72
		•AppendToLayout/T Graph11
		•ModifyLayout width(Graph11)=472,height(Graph11)=130
		•ModifyLayout left(Graph11)=454,top(Graph11)=256
		•AppendToLayout/T Graph12;
		•ModifyLayout width(Graph12)=472,height(Graph12)=130,left(Graph12)=454,top(Graph12)=367
		•ModifyLayout frame=0,trans=1
		•TextBox/C/N=text0/A=RB/X=0.00/Y=4.00 "\\Z18"+tname+"/ 100 pA/ 300 mK/ X"+AorB
		String pathn
		pathn = StringByKey("Macintosh HD:Users:lingyuan:Library:Mobile Documents:com~apple~CloudDocs:Majorana TSC Project:05.Caltech",s_p)

		TextBox/C/N=text1/A=RB/X=0.00/Y=0 "\\Z14"+ReplaceString(":",pathn," / ")
		cktimesforAutol+=1
		else
		endif
		/////////////////////////////////////////////////////////////
	else
	endif
	Preferences 0
	If (flag2==1)
	SavePICT/O/P=home/E=-5/B=360
	Print ""
	Print "dowindow/F layout0; SavePICT/O/P=home/E=-5/B=360"
	dowindow/F graph1
	appendVline(ashift,lx,xend,numatoms,0)
	dowindow/F layout0
	else
	endif
	KP_NanonisCleanup()
end






//***************************************************************************************************************************************
//***************************************************************************************************************************************
//This procedure do autoloading and plot of the GridMap data from nanonis.
//It can automatically load data and read the dim value of the grid data.
//The Nanonis loading is handled by KP_LoadNanonisData, so this no longer requires the KM package.
//***************************************************************************************************************************************
//***************************************************************************************************************************************
Function ButtonProc_autoloadgrid(ctrlName) : ButtonControl
	String ctrlName
	Execute "autoloadgrid()"
end

Proc autoloadgrid()

	//If (exists("loadforAutol") ==0)
	//	initialgl()
	//else
	//endif
	////////////////////////////////////////////////////To make sure everytime rerun the Auto linecut, the previous graph can be close automatically, in order to make the layout correct.
	//If (exists("cktimesforAutol") ==0)
	//	initialg()
	//else
	//endif
	//if (cktimesforAutol == 0)
	//else
	//	KillAllGraphs()
	//endif
	////////////////////////////////////////////////////

	//if (loadforAutol == 0)
	getFileFolderInfo/Q
	KP_LoadNanonisData(S_path)
	//loadforAutol+=1
	string/G s_p
	s_p = S_path

	//else
	//endif

	//Prompt tname,"Nanonis Name of the 3ds"
	string tname
	tname=KP_GetLastLoadedNanonisFolder() // Grab the Nanonis name of 3ds from the last loaded data folder.

	string ttname
	ttname="root:"+tname
	SetDataFolder ttname

	string wname
	wname=tname+"_LI_Demod_1_Y";
	string wnamea
	wnamea=tname+"_G";
	duplicate/o $wname root:$wnamea

	String zname
	zname=tname+"_Z"
	string Znamea
	Znamea=tname+"_T"
	duplicate/o $zname root:$znamea

	string iname
	iname=tname+"_Current"
	string inamea
	inamea=tname+"_I";
	duplicate/o $iname root:$inamea

	SetDataFolder root:
	//** The old version is inactive
		//Initialize_Global_Variables()
		//getslicerData(tname,0,1,2,dimsize($znamea,0)*dimdelta($znamea,0),dimsize($znamea,1)*dimdelta($znamea,1),dimoffset($tname,2),dimdelta($tname,2))
		//mapforSTMf(dimsize(File_name,0)-1,"data","",StartE,deltaE)
		//makeextra()
	//** This is the new version of 3d plotter
		variable/G zn_cons =2
		Z_R_Rhomap($wnamea,$inamea,zn_cons)
		d3d(wnamea,zn_cons)
	//cktimesforAutol+=1
	killDataFolder $ttname
	KP_NanonisCleanup()
end
//******************************************************************
//******************************************************************
//******************************************************************
//** If the matrix is symmetric in energy, at loading automatically
//** calculate the Z map R map and ρ map, L map
Function ButtonProc_Z_R_Rhomapc(ctrlName) : ButtonControl
	String ctrlName
	Execute "Z_R_Rhomapc()"
end
Proc Z_R_Rhomapc(wg,wi,zn_consl)
	string wg = stringfromlist(0,getall3dwave())
	string wi = stringfromlist(1,getall3dwave())
	variable zn_consl = 2
	prompt wg,"Name of G matrix (3D)"
	prompt wi,"Name of I matrix (3D)"
	prompt zn_consl,"Index of Energy"
	Z_R_Rhomap($wg,$wi,zn_consl)
end
Function Z_R_Rhomap(wg,wi,zn_consl)
	wave wg
	wave wi
	variable zn_consl
	variable/G zn_cons = zn_consl
	//** Z(r,V) = g(r,V)/g(r,-V)
	//** R(r,V) = I(r,V)/I(r,-V)
	//** ρ(r,V) = I(r,V)-I(r,-V)
	//** L(r,V) = g(r,V)/[I(r,V)/V]

	//** Auto ordering layer index
		variable zn = zn_consl
		make/o/N=3 ordernum ={0,1,2}
		ordernum=abs(ordernum-zn)
		wavestats/Q ordernum
		ordernum={0,1,2}
		DeletePoints V_minloc,1, ordernum
		wavestats/Q ordernum
		variable xn = ordernum[V_minloc]
		variable yn = ordernum[V_maxloc]
		killwaves ordernum
		//print num2str(xn)+" "+num2str(yn)
	variable znstart = dimoffset(wg,zn)
	variable zndelta = dimdelta(wg,zn)

	//znstart + p*zndelta = 0, p should a int
	variable ptest = -znstart/zndelta
	string Zmap = nameofwave(wg)+"_Z_map"
	string Rmap = nameofwave(wg)+"_R_map"
	string Rhomap = nameofwave(wg)+"_Rho_map"
	string Lmap = nameofwave(wg)+"_L_map"

	variable i
	//print ptest
	//print mod(ptest,1)
	variable symmetrici
	//-(dimoffset(wg,zn)+i*dimdelta(wg,zn))=dimoffset(wg,zn)+symmetrici*dimdelta(wg,zn)

	print "Check for symmetric energy: the calculated step for 0 meV is "+num2str(ptest)
	print "The judgments should be zero, the calculated value is: "+num2str(abs(mod(ptest,1)))


		if(zn_consl == 0)
			make/O/N=(dimsize(wg,zn),dimsize(wg,xn),dimsize(wg,yn)) $Zmap
			setscale/p x,dimoffset(wg,zn),dimdelta(wg,zn),"",$Zmap
			setscale/p y,dimoffset(wg,xn),dimdelta(wg,xn),"",$Zmap
			setscale/p z,dimoffset(wg,yn),dimdelta(wg,yn),"",$Zmap
			duplicate/O $Zmap $Rmap
			duplicate/O $Zmap $Rhomap

			duplicate/O $Zmap $Lmap
			wave Lmapw = $Lmap

			Lmapw[][][]= wg[p][q][r]/(wi[p][q][r]/(dimoffset(wg,0)+p*dimdelta(wg,0)))


			//make/O/N=((ptest+1),dimsize(wg,xn),dimsize(wg,yn)) $Rmap
			//make/O/N=((ptest+1),dimsize(wg,xn),dimsize(wg,yn)) $Rhomap
			wave Zmapw = $zmap
			wave Rmapw = $rmap
			wave Rhomapw = $Rhomap

			//Zmapw[0][][] = wg[ptest][p][q]
			//Rmapw[0][][] = wi[ptest][p][q]
			//Rhomapw[0][][] = wi[ptest][p][q]
			//i=1
			i=0
			do
				symmetrici =(-(dimoffset(wg,zn)+i*dimdelta(wg,zn))-dimoffset(wg,zn))/dimdelta(wg,zn)
				if (symmetrici < 0 || symmetrici >= dimsize(wg,zn))
					Zmapw[][][i] = gammaNoise(0.001)
					Rmapw[][][i] = gammaNoise(0.001)
					Rhomapw[][][i] = gammaNoise(0.001)
				else
					Zmapw[i][][] = wg[i][p][q]/wg[symmetrici][p][q]
					Rmapw[i][][] = wi[i][p][q]/wi[symmetrici][p][q]
					Rhomapw[i][][] = wi[i][p][q]-wi[symmetrici][p][q]
				endif

				i+=1
			while(i<dimsize(wg,zn))

			//Rhomapw[-dimoffset(wg,zn)/dimdelta(wg,zn)][][] = abs(Rhomapw[-dimoffset(wg,zn)/dimdelta(wg,zn)+1][0][0]/2) + abs(Rhomapw[-dimoffset(wg,zn)/dimdelta(wg,zn)-1][0][0]/2)
		endif
		if(zn_consl == 1)
			make/O/N=(dimsize(wg,xn),dimsize(wg,zn),dimsize(wg,yn)) $Zmap
			setscale/p y,dimoffset(wg,zn),dimdelta(wg,zn),"",$Zmap
			setscale/p x,dimoffset(wg,xn),dimdelta(wg,xn),"",$Zmap
			setscale/p z,dimoffset(wg,yn),dimdelta(wg,yn),"",$Zmap
			duplicate/O $Zmap $Rmap
			duplicate/O $Zmap $Rhomap

			duplicate/O $Zmap $Lmap
			wave Lmapw = $Lmap

			Lmapw[][][]= wg[p][q][r]/(wi[p][q][r]/(dimoffset(wg,1)+q*dimdelta(wg,1)))

			//make/O/N=(dimsize(wg,xn),(ptest+1),dimsize(wg,yn)) $Rmap
			//make/O/N=(dimsize(wg,xn),(ptest+1),dimsize(wg,yn)) $Rhomap
			wave Zmapw = $zmap
			wave Rmapw = $rmap
			wave Rhomapw = $Rhomap

			//Zmapw[][0][] = wg[p][ptest][q]
			//Rmapw[][0][] = wi[p][ptest][q]
			//Rhomapw[][0][] = wi[p][ptest][q]
			//i=1
			i=0
			do
				symmetrici =(-(dimoffset(wg,zn)+i*dimdelta(wg,zn))-dimoffset(wg,zn))/dimdelta(wg,zn)
				if (symmetrici < 0 || symmetrici >= dimsize(wg,zn))
					Zmapw[][][i] = gammaNoise(0.001)
					Rmapw[][][i] = gammaNoise(0.001)
					Rhomapw[][][i] = gammaNoise(0.001)
				else
					Zmapw[][i][] = wg[p][i][q]/wg[p][symmetrici][q]
					Rmapw[][i][] = wi[p][i][q]/wi[p][symmetrici][q]
					Rhomapw[][i][] = wi[p][i][q]-wi[p][symmetrici][q]
				endif
				i+=1
			while(i<dimsize(wg,zn))

			//Rhomapw[][-dimoffset(wg,zn)/dimdelta(wg,zn)][] = abs(Rhomapw[0][-dimoffset(wg,zn)/dimdelta(wg,zn)+1][0]/2) + abs(Rhomapw[0][-dimoffset(wg,zn)/dimdelta(wg,zn)-1][0]/2)

		endif
		if(zn_consl == 2)
			make/O/N=(dimsize(wg,xn),dimsize(wg,yn),dimsize(wg,zn)) $Zmap
			setscale/p z,dimoffset(wg,zn),dimdelta(wg,zn),"",$Zmap
			setscale/p x,dimoffset(wg,xn),dimdelta(wg,xn),"",$Zmap
			setscale/p y,dimoffset(wg,yn),dimdelta(wg,yn),"",$Zmap
			duplicate/O $Zmap $Rmap
			duplicate/O $Zmap $Rhomap

			duplicate/O $Zmap $Lmap
			wave Lmapw = $Lmap

			Lmapw[][][]= wg[p][q][r]/(wi[p][q][r]/(dimoffset(wg,2)+r*dimdelta(wg,2)))

			//make/O/N=(dimsize(wg,xn),dimsize(wg,yn),(ptest+1)) $Rmap
			//make/O/N=(dimsize(wg,xn),dimsize(wg,yn),(ptest+1)) $Rhomap
			wave Zmapw = $zmap
			wave Rmapw = $rmap
			wave Rhomapw = $Rhomap

			//Zmapw[][][0] = wg[p][q][ptest]
			//Rmapw[][][0] = wi[p][q][ptest]
			//Rhomapw[][][0] = wi[p][q][ptest]
			//i=1
			i=0
			do
				symmetrici =(-(dimoffset(wg,zn)+i*dimdelta(wg,zn))-dimoffset(wg,zn))/dimdelta(wg,zn)
				if (symmetrici < 0 || symmetrici >= dimsize(wg,zn))
					Zmapw[][][i] = gammaNoise(0.001)
					Rmapw[][][i] = gammaNoise(0.001)
					Rhomapw[][][i] = gammaNoise(0.001)
				else
					Zmapw[][][i] = wg[p][q][i]/wg[p][q][symmetrici]
					Rmapw[][][i] = wi[p][q][i]/wi[p][q][symmetrici]
					Rhomapw[][][i] = wi[p][q][i]-wi[p][q][symmetrici]
				endif
				i+=1
			while(i<dimsize(wg,zn))
			Zmapw[][][-dimoffset(wg,zn)/dimdelta(wg,zn)]+=gammaNoise(0.001)
			Rmapw[][][-dimoffset(wg,zn)/dimdelta(wg,zn)]+=gammaNoise(0.001)
			Rhomapw[][][-dimoffset(wg,zn)/dimdelta(wg,zn)]+=gammaNoise(0.001)

			//Rhomapw[][][-dimoffset(wg,zn)/dimdelta(wg,zn)] = abs(Rhomapw[0][0][-dimoffset(wg,zn)/dimdelta(wg,zn)+1]/2) + abs(Rhomapw[0][0][-dimoffset(wg,zn)/dimdelta(wg,zn)-1]/2)
		endif

	if (abs(mod(ptest,1)) < 10^-3)
	else
		print "Energy asymmetric, Z(r,V), R(r,V), and ρ(r,V) are approximate, L(r,V) is precise"
	endif
end
//***************************************************************************************************************************************
//***************************************************************************************************************************************


//***************************************************************************************************************************************
//***************************************************************************************************************************************
//***************************************************************************************************************************************
// Auto Gate map
//***************************************************************************************************************************************
//***************************************************************************************************************************************
//***************************************************************************************************************************************
//***************************************************************************************************************************************
Function ButtonProc_autogatemap(ctrlName) : ButtonControl
	String ctrlName
	Execute "gatemapauto()"
end
Proc gatemapauto(x,y,gate, evenornot,Interpnum)
	variable x=0
    variable y=8//y=1: current// y=8: dI/dV
    Variable gate=3
    variable evenornot = 1
    variable Interpnum =300
	prompt x,"Column Number of x wave"
    prompt y,"Column Number of y wave"
    Prompt gate,"Column number for gate"
    prompt evenornot,"Gate even spacing?",popup"Yes;No"
    Prompt Interpnum,"If gate is not even spacing, how many points you want to interpolate"

    setDataFolder Root:
	Makegraphtable()
    LoadDataFromNewmkgate(x,y,gate)
    Initialize_Global_Variables()
    linkstsmapgate("gate_",dimsize(File_Name,0)-1,1)
    make/N=(dimsize(File_Name,0)-1)/o gatewave
    gatewave[]=gatemat[0][p]
    rescalexmultiwhat("sts",dimsize(file_name,0)-1,1000)
    normrange("sts",dimsize(File_Name,0)-1,dimoffset(sts1,0),dimoffset(sts1,0)+(dimsize(sts1,0)-1)*dimdelta(sts1,0))

    if(evenornot == 1)
    linkstsmap("sts",dimsize(File_Name,0)-1,1)
    setscale/p y, gatewave[0],(gatewave[1]-gatewave[0]),"",mapsts
    modifygraph width=250, height=450
	modifygraph width=0, height=0
	modifygraph lsize=1
	ModifyGraph mirror=2
	ModifyGraph tick=2
	ModifyImage mapsts ctab= {*,*,VioletOrangeYellow,0}
	Label left "\Z20\F'times'Gate (V)";DelayUpdate
	Label bottom "\\Z20\F'times'Sample Bias\M\F'times'\Z20 (meV)"
    endif
    if(evenornot == 2)
    linkstsmapgl("sts",dimsize(File_Name,0)-1,1)
    rescalemapasa1dcurve("mapsts","gatewave",Interpnum)
    modifygraph width=250, height=450
	modifygraph width=0, height=0
	modifygraph lsize=1
	ModifyGraph mirror=2
	ModifyGraph tick=2
	ModifyImage even_mapsts ctab= {*,*,VioletOrangeYellow,0}
	Label left "\Z20\F'times'Gate (V)";DelayUpdate
	Label bottom "\\Z20\F'times'Sample Bias\M\F'times'\Z20 (mV)"
    endif

    killwaves gatemat, gatewave
end
Proc LoadDataFromNewmkgate(x,y,gate)
	variable x=0
    variable y=5//y=1: current// y=8: dI/dV
    Variable gate=3 //

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
	string mat,matt,matg
	n=DataNum


	Do
		Filename = stringfromlist(n-1, sortlist(datalist,";",16))//For arrange data
		//Filename=IndexedFile($PathName,n-1,".dat")
		//print FileName
		File_Name[n]=FileName
		//LoadWave/F={5,14,0}/D/K=1/L={0,71,0,0,0}/O/A=load/P=$PATHName Filename
                     LoadWave/G/D/A=load/K=1/L={0,0,0,x,1}/o/P=$PATHName Filename
                     LoadWave/G/D/A=load/K=1/L={0,0,0,y,1}/o/P=$PATHName Filename
                     LoadWave/G/D/A=load/K=1/L={0,0,0,gate,1}/o/P=$PATHName Filename

		mat="sts"+num2str(n)
		matt="data"+num2str(n)
		matg="gate_"+num2str(n)
		Interpolate2/T=2/N=(dimsize(load0,0))/E=2/Y=$mat load0,load1
	       //Setscale/P x, dimoffset(load0,0),dimdelta(load0,0),"",load3
		//duplicate/o sts $mat
		duplicate/o $mat $matt
		duplicate/o	load2 $matg
        KillWaves  load0,load1,load2
		n+=1
	While(n<=Loadn)
	setDataFolder $savedDataFolder
End

Function linkstsmapgate(name,num,startnum)
	string name
	variable num
	variable startnum

	variable i,j
	string mat,mat0
	mat0=name+num2str(1)
	wave m=$mat0
	make/o/n=(dimsize(m,0),num) gatemat
	i=0
	do
		j=0
		do
			mat=name+num2str(i+startnum)
			wave n=$mat
			gatemat[j][i]=n[j]
			killwaves n
			j+=1
		while(j<dimsize(m,0))
		i+=1
	while(i<num)
	setscale/P x, dimoffset(m,0),dimdelta(m,0),"",gatemat
end

Function linkstsmapgl(name,num,startnum)
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
end

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
// Extract Topo after KP loads .sxm/.nsp.
// The data even number are bwd, and odd number are fwd
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_autotopo(ctrlName) : ButtonControl
	String ctrlName
	Execute "ExtacttopoafterKM()"
end

Proc ExtacttopoafterKM()
	string foldern
	string fwd,bwd,fwddata,bwddata
	variable i,j,numc1,numc2

	if (itemsInList(DataFolderList("*",";", root:)) <= 1)
		getFileFolderInfo/Q
		if (!V_Flag)
			KP_LoadNanonisData(S_path)
		endif
	endif

	numc1 = itemsInList(wavelist("data*",";","",root:))
	if (numc1 == 0)
	else
		i=0
		do
			fwd=stringfromlist(0,wavelist("data*",";","",root:))
			killwaves $fwd
	//		msg=GetErrMessage(GetRTError(0),3);
	//		err=GetRTError(1)
			i+=1
		while (i<numc1)
	endif

	i=1
	do
		foldern = StringFromList(i, DataFolderList("*",";", root:))
		fwd = "root:"+foldern+":"+foldern+"_Z"
		bwd = "root:"+foldern+":"+foldern+"_Z_bwd"

		numc1 = itemsInList(wavelist("data*",";","",root:))+1
		numc2 = itemsInList(wavelist("data*",";","",root:))+2
		fwddata = "root:data"+num2str(numc1)
		bwddata = "root:data"+num2str(numc2)

		duplicate/o $fwd $fwddata
		duplicate/o $bwd $bwddata
		i+=1
	while(i< itemsInList(DataFolderList("*",";", root:)))


	//** Error message, no stop but Continuing execution
		String msg
		Variable err
		msg=GetErrMessage(GetRTError(0),3);
		err=GetRTError(1)
		if (err != 0)
		//	Print "Error in Demo: " + msg
		//	Print "Continuing execution"
		endif
end
