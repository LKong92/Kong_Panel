#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
Function ButtonProc_Cons3dplot(ctrlName) : ButtonControl
	String ctrlName
	Execute "d3d()"
End
Proc d3d(mat3dn,zn)
	string mat3dn
	variable zn = zn_cons
	Prompt mat3dn,"Name of the", popup getall3dwave()
	Prompt zn,"Index of the Energy"
	string/G mat3dn_cons = mat3dn
	variable/G zn_cons = zn //the Energy in which dimension?
	variable/G z_cons = (dimoffset($mat3dn_cons,zn_cons)+dimdelta($mat3dn_cons,zn_cons)*round((dimsize($mat3dn_cons,zn_cons)-1)/2)) //energy to show
	variable/G Znorm_cons
	//** Auto ordering layer index
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

	//** Scaling the layer to show
		string slicename = "Zslice_"+mat3dn_cons
		make/o/N=(dimsize($mat3dn_cons,xn),dimsize($mat3dn_cons,yn)) $slicename
		setscale/p x,dimoffset($mat3dn_cons,xn),dimdelta($mat3dn_cons,xn),"",$slicename
		setscale/p y,dimoffset($mat3dn_cons,yn),dimdelta($mat3dn_cons,yn),"",$slicename

	//** Generate the average curve
		variable Z_constp=(z_cons-dimoffset($mat3dn_cons,zn_cons))/dimdelta($mat3dn_cons,zn_cons)
		//Z_cons = dimoffset($mat3dn,zn)+dimdelta($mat3dn,zn)*(Z_constp)

		string singlespectra = "sgsg_"+mat3dn_cons
		//SumDimension/D=(xn)/DEST=wout $mat3dn;
		sumoned(singlespectra,mat3dn,zn)
		//duplicate/o wout1 $singlespectra
		//setscale/p x,dimoffset($mat3dn_cons,zn),dimdelta($mat3dn_cons,zn),"",$singlespectra
		//killwaves wout

		//display $singlespectra
		//print num2str(wavemin($singlespectra))+" "+num2str(wavemax($singlespectra))
		//wavestats  $singlespectra
		//wavestats wout1
		//make/o/n=(dimsize($mat3dn_cons,zn)) $singlespectra
		//setscale/p x,dimoffset($mat3dn_cons,zn),dimdelta($mat3dn_cons,zn),"",$singlespectra
		string Zpp = "Zpp_"+mat3dn_cons
		make/o/n=(2) $Zpp
		setscale/I x,wavemin($singlespectra),wavemax($singlespectra),"",$Zpp
		$Zpp=z_cons

	//** Generate layer image
		if(zn_cons == 0)
			$slicename[][]=$mat3dn_cons[Z_constp][p][q]
		endif
		if(zn_cons == 1)
			$slicename[][]=$mat3dn_cons[p][Z_constp][q]
		endif
		if(zn_cons == 2)
			$slicename[][]=$mat3dn_cons[p][q][Z_constp]
		endif

	//** Display layer image
		di2lf($slicename)
		func_zeroNaN($slicename)
		color3s_for3d($slicename,3)
		modifygraph width=300,height=300
		ModifyGraph width={Plan,1,bottom,left}
		SetAxis bottom dimoffset($slicename,0),dimoffset($slicename,0)+(dimsize($slicename,0)-1)*dimdelta($slicename,0)
		SetAxis left dimoffset($slicename,1),dimoffset($slicename,1)+(dimsize($slicename,1)-1)*dimdelta($slicename,1)

		if(stringmatch(mat3dn_cons,"*_I") == 1)
			Label left "\\Z16 I(r,V)"
		Endif
		if(stringmatch(mat3dn_cons,"*_Z_map") == 1)
			Label left "\\Z16 Z(r,V) = g(r,V)/g(r,-V)"
		Endif
		if(stringmatch(mat3dn_cons,"*_R_map") == 1)
			Label left "\\Z16 R(r,V) = |I(r,V)/I(r,-V)|"
		Endif
		if(stringmatch(mat3dn_cons,"*_Rho_map") == 1)
			Label left "\\Z16 ρ(r,V) = I(r,V)-I(r,-V) "
		Endif
		if(stringmatch(mat3dn_cons,"*_G") == 1)
			Label left "\\Z16 g(r,V)"
		Endif


	//** Display FFT of the layer image
		variable/G colorratio_consFFT =30
		f_for3d()
		String FFToutm = slicename+"_FFT"+"_Modula"
		String FFToutmsym =  slicename+"_FFT"+"_sym"
		duplicate/o $FFToutm $FFToutmsym

		//**Show subwindow***********************************************************************************\\
		display/N=ThreeDPlotFTslicewin; ModifyGraph margin(top)=72; modifygraph width=400,height=700
		Display/HOST=#/W=(0,0.05,1,0.55);
		appendimage $FFToutm
		ModifyImage $FFToutm ctab= {*,*,VioletOrangeYellow,1}
		ModifyGraph mirror=2,axThick=3
		ModifyGraph width={Plan,1,bottom,left}
		color3s_for3dinv($FFToutm,colorratio_consFFT)
		TextBox/C/N=text1a/F=0/A=RT/X=0.00/Y=0.00 "FT(kx,ky)"

		setActiveSubwindow ##;
		Display/HOST=#/W=(0,0.5,1,1);
		appendimage $FFToutmsym
		ModifyImage $FFToutmsym ctab= {*,*,VioletOrangeYellow,1}
		ModifyGraph mirror=2,axThick=3
		ModifyGraph width={Plan,1,bottom,left}
		color3s_for3dinv($FFToutmsym,colorratio_consFFT)
		TextBox/C/N=text1a/F=0/A=RT/X=0.00/Y=0.00 "Symmetrized FT(kx,ky)"

		setActiveSubwindow ##;

		SetVariable setvarz_csfftm title="σ",size={65,14},value=colorratio_consFFT,limits={1,inf,1},proc=SetVarProc_colorratio_consFFT,pos={188,3}
		variable/G symmode_3dplot = 1
		PopupMenu symMode bodyWidth=120 ,title="Sym.  Mode",fSize=10,proc=PopMenuProc_symmode_3dplot,value="Non;Octect(D4);M_dia;M_x;C4",pos={1,1}

		variable/G GBK2dornot_3dplot = 2
		variable/G GBK2dsigma_3dplot = 0.001
		PopupMenu GBK2dMode bodyWidth=120 ,title="Bkg.Rmv?",fSize=10,proc=PopMenuProc_bkgrmv2D_3dplot,value="Yes;No",mode=2, pos={1,22}
		SetVariable setvarz_GBK2d title="σ_bkg",size={100,14},value=GBK2dsigma_3dplot,limits={0.0001,inf,0.01},proc=SetVarProc_bkgrmv2D_3dplot,pos={188,25}


	//** Make subwindow to show average curve
		Dowindow/F $grabwin(slicename)
		ModifyGraph margin(bottom)=144
		Display/HOST=#/W=(0,0.7,1,1)  $singlespectra
		ModifyGraph/W=$(grabwin(slicename)+"#"+stringFromList(0,childWindowList(grabwin(slicename))))  rgb($singlespectra)=(52428,52428,52428)

		appendtoGraph/W=$(grabwin(slicename)+"#"+stringFromList(0,childWindowList(grabwin(slicename))))/VERT $Zpp
		ModifyGraph/W=$(grabwin(slicename)+"#"+stringFromList(0,childWindowList(grabwin(slicename)))) lsize($Zpp)=2,rgb($Zpp)=(0,0,0),nticks(bottom)=10,minor(bottom)=1
		SetActiveSubwindow ##
	//** SetVariable of Layer energy
		SetVariable setvarz_cons win=$grabwin(slicename),title="Z",size={65,14},value=z_cons,proc=SetVarProc_Cons3dplot
		SetVariable setvarz_cons win=$grabwin(slicename),limits={dimoffset($mat3dn_cons,zn_cons),(dimoffset($mat3dn_cons,zn_cons)+dimdelta($mat3dn_cons,zn_cons)*(dimsize($mat3dn_cons,zn_cons)-1)),dimdelta($mat3dn_cons,zn_cons)}

	//**PopoMenu of Normalization or not
		variable setnormcurrentitem
		if (Znorm_cons == 2)
			setnormcurrentitem = 2
		else
			setnormcurrentitem = 1
		endif
		PopupMenu popupnormornot win=$grabwin(slicename),pos={300,406},proc=PopMenuProc_Znormornot,value="No;Norm",mode=setnormcurrentitem //Yes is 2, No is 1

	//** Knob to launch linecut
		Button launchLinecut win=$grabwin(slicename),title="Launch Linecut",size={82,14},pos={70,1},fSize=10,proc=ButtonProc_Cons3dplotlc

	//** Cursor moving sts
		Cursor/W=$grabwin(slicename)/P/I/C=(1,65535,33232)/T=6 A $slicename 0,0
		//ShowInfo
		getsinglests($mat3dn_cons,0,0,zn_cons)

		string ssn = "sts_"+mat3dn_cons
		//display $ssn
		appendtoGraph/W=$(grabwin(slicename)+"#"+stringFromList(0,childWindowList(grabwin(slicename))))/R $ssn
		SetWindow $grabwin(slicename) hook(myHook)=myCursorMovedHook
		UpdateControls_3dp(slicename, "A", 0,0)

	//** Knob to launch MultiMap, <only happen when use g(r,V) map, and ZMap exist>
		string multiexist = mat3dn_cons+"_Z_map"
		if(stringmatch(mat3dn_cons,"*_G") == 1)
			if (waveexists($multiexist) == 1)
				Button launchMultiMap win=$grabwin(slicename),title="MultiMap",pos={1,445},size={60,15},fSize=10,proc=ButtonProc_Cons3dplotmulti
			endif
		Endif

	//** Button to lauch GapMap
		Button launchGapMap win=$grabwin(slicename),title="GapMap",pos={129,445},size={60,15},fSize=10,proc=ButtonProc_Cons3dplotgapmap
		variable/G l1_gapfit_3dplot = -3
		variable/G l2_gapfit_3dplot = -1
		variable/G r1_gapfit_3dplot = 1
		variable/G r2_gapfit_3dplot = 3
		variable/G mod_gapfit_3dplot = 1

	//** Knob to append T(r) or Δ(r)
		string appendvalue
		string gapmap = mat3dn_cons+"_Gap_map"
		if (waveexists($gapmap) == 1)
			appendvalue = "Remove;T(r);Δ(r)"
		else
			appendvalue = "Remove;T(r)"
		endif
		//PopupMenu appendtord win=$grabwin(slicename),pos={1,20},title="Append",proc=PopMenuProc_appendimage,value=appendvalue//appendvalue
		string winn = grabwinnonew(slicename)
		string exbody ="PopupMenu appendtord win="+winn+",value= \""+appendvalue+"\""+",pos={1,16},bodyWidth=25,title=\"Append\",proc=PopMenuProc_appendimage"
		execute exbody

	//** Knob to Calculate Shearing parameters
		Button Getshear win=$grabwin(slicename),title="Shear(V)",pos={193,445},size={60,15},fSize=10,proc=ButtonProc_Cons3dplotgetshear

	//** MultiFunctional FFT
		PopupMenu FFTMode win=$grabwin(slicename),bodyWidth=70,pos={1,250},title="",fSize=10,proc=PopMenuProc_FFTmode_3dplot,value="Magnitude;Phase;Real;Imaginary;Complex"
		PopupMenu FFTwindow win=$grabwin(slicename),bodyWidth=70,pos={1,270},title="",fSize=10,proc=PopMenuProc_FFTWin_3dplot,value="None;Hanning;Hamming;Bartlet;Blackman;KaiserBessel20;KaiserBessel25;KaiserBessel30"
		Button FFTgo win=$grabwin(slicename),title="Apply",pos={1,310},fSize=10,size={70,15},proc=ButtonProc_FFTapply_3dplot

		variable/G FFTmarque_3dplot = 1
		PopupMenu FFTmarque win=$grabwin(slicename),bodyWidth=70,pos={1,290},title="",fSize=10,proc=PopMenuProc_FFTmarquearea_3dplot,value="Whole;In Marquee"


		SetDrawEnv fillfgc= (39321,39319,1),linethick= 0.00;DrawRect -0.24,0.74,-0.0067,1.05;
		SetDrawEnv textrgb= (65535,65535,65535),fstyle= 1,fsize= 9;DrawText -0.166,0.783,"3D FFT"

	//** Multi 2D lock-in
		Button MultiLockin win=$grabwin(slicename), title="M-lockin",pos={65,445},size={60,15},fSize=10,proc=ButtonProc_2dlockinmultifft

	//** Lattice Segregation
		Button Latticesegregation win=$grabwin(slicename), title="Latt.Serg",pos={256,445},size={60,15},fSize=10,proc=ButtonProc_ls3dcons

	//** Select subgroup average dI/dV
		Button subavedidv win=$grabwin(slicename), title="Grp.dI/dV",pos={320,445},size={60,15},fSize=10,proc=ButtonProc_subavedidv

	//** SetColor style
		variable/G divcolor_cons = 0
		SetVariable setdiv_cons win=$grabwin(slicename),title="DivC",pos={1,75},size={65,14},value=divcolor_cons,limits={0,1,1},proc=SetVarProc_Cons3dplotdivc

	//** Turn off
		Button turnoffls3d title="BACK",size={45,18},valueColor=(0,0,0),fColor=(1,65535,33232),pos={356,1},proc=ButtonProc_lsturnoff3d

	//** make single spectra
		Button selecshowsp title="P",size={20,15},pos={279,407},fSize=10,proc=ButtonProc_selecshowsp

	//** Tile window
		tilewindows/WINS=grabwinnonew(slicename)/R/w=(3,0,83,85)/A=(1,1)
		tilewindows/WINS="ThreeDPlotFTslicewin"/R/w=(30,0,83,85)/A=(1,1)
		//tilewindows/WINS=WinList("*", ";","WIN:1")/R/w=(3,0,83,85)/A=(2,3)
		//Dowindow/F $grabwin(slicename)
end

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** {{{{{{{{{{ Interactive Cursor, to get 1D sts }}}}}}}}}}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function myCursorMovedHook(s)
	STRUCT WMWinHookStruct &s
	Variable statusCode= 0
	strswitch( s.eventName )
		case "cursormoved":
			// see "Members of WMWinHookStruct Used with cursormoved Code"
			UpdateControls_3dp(s.traceName, s.cursorName, s.pointNumber, s.yPointNumber)

			//Check if the FFT matrix exist
			string/G mat3dn_cons
			string fftslice = "Zslice_"+mat3dn_cons+"_FFT3d"
			wave fftslicew = $fftslice
			if (waveexists(fftslicew) == 0)
			else
				checkDisplayed/W=$grabwinnonew(fftslice) fftslicew
				if (V_flag == 1)
					UpdateControls_3dpf(s.traceName, s.cursorName, s.pointNumber, s.yPointNumber)
				endif
			endif

			break
	endswitch
	return statusCode
End

Function UpdateControls_3dp(traceName, cursorName, pointNumber, yPointNumber)
	String traceName, cursorName
	Variable pointNumber,yPointNumber
	string/G mat3dn_cons
	variable/G zn_cons
	variable/G pointNumberx_3dp = pointNumber
	variable/G PointNumbery_3dp = yPointNumber


	getsinglests($mat3dn_cons,pointNumber,yPointNumber,zn_cons)
	//string ssn = "sts_"+mat3dn_cons
	//wave ssnw =$ssn
	//string singlespectra = "sgsg_"+mat3dn_cons
	//wave singlespectraw=$singlespectra
	//singlespectraw = ssnw
	//print pointNumber
	//print yPointNumber


	//Update the FFT cursor if displayed
		string fftslice = "Zslice_"+mat3dn_cons+"_FFT3d"
		wave fftslicew = $fftslice

		if (waveexists(fftslicew) == 0)
		else
			checkDisplayed/W=$grabwinnonew(fftslice) fftslicew
			if (V_flag == 1)
				Cursor/W=$grabwin_sfft(fftslice)/P/I/C=(1,65535,33232)/T=6 A $fftslice pointNumberx_3dp,PointNumbery_3dp
			endif
		endif
End
Function getsinglests(name,pp,qq,zn)
	wave name
	variable pp
	variable qq
	variable zn
	//** Auto ordering layer index
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
	string ssn = "sts_"+nameofwave(name)
	make/N=(dimsize(name,zn))/O $ssn
	setscale/p x,dimoffset(name,zn),dimdelta(name,zn),"",$ssn
	wave ssnw = $ssn
	//** Generate sts
		if(zn == 0)
			ssnw[] = name[p][pp][qq]
		endif
		if(zn == 1)
			ssnw[] = name[pp][p][qq]
		endif
		if(zn == 2)
			ssnw[] = name[pp][qq][p]
		endif

	Variable mean_value
	mean_value=mean(ssnw,dimoffset(ssnw,0),(dimoffset(ssnw,0)+(dimsize(ssnw,0)-1)*dimdelta(ssnw,0)))
	ssnw[]/=mean_value
end

Function myCursorMovedHook2(s)
	STRUCT WMWinHookStruct &s
	string/G mat3dn_cons
	string slicename = "Zslice_"+mat3dn_cons

	UpdateControls_3dp(slicename,"A", s.pointNumber, s.yPointNumber)

End
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** {{{{{{{{{{ normalize 3D by sts }}}}}}}}}}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function PopMenuProc_Znormornot(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string/G mat3dn_cons
	variable/G zn_cons
	variable/G Znorm_cons

	Znorm_cons=popNum

	Norma3dmatrix($mat3dn_cons,zn_cons)

	//Update layer
		Cons3dplotc()

	//Update FFT
		f_for3d()
		String FFToutm = "Zslice_"+mat3dn_cons+ "_FFT"	+"_Modula"
		color3s_for3d($FFToutm,30)

	//Update 2d-lock-in if exist
		string flagexis2dlockin = "Zslice_"+mat3dn_cons+"_phi_A"
		if (cmpstr(grabwinnonew(flagexis2dlockin),"") == 0)
		else
			execute "Const2dlockinc()"
		endif

	//Update FFTfilter if exist
		string flagexisfilter = "Zslice_"+mat3dn_cons+"_ftd"
		if (cmpstr(grabwinnonew(flagexisfilter),"") == 0)
		else
			execute "Const2dfilterc()"
		endif

	//Update extracted 1D wave
		//STRUCT WMWinHookStruct s
		//myCursorMovedHook2(s)
		variable/G pointNumberx_3dp, PointNumbery_3dp
		string slicename = "Zslice_"+mat3dn_cons
		UpdateControls_3dp(slicename,"A",pointNumberx_3dp,PointNumbery_3dp)
end

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** {{{{{{{{{{ Dsiplay 3D matrix by selected layer:control function }}}}}}}}}}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function SetVarProc_Cons3dplot(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	removeappendimage()
	string/G mat3dn_cons = replacestring("Zslice_",tpw(),"")

	string barename = replaceString("_G",mat3dn_cons,"")
	string sliceI = "Zslice_"+barename+"_I"
	string sliceZ = "Zslice_"+mat3dn_cons+"_Z_map"
	string sliceR = "Zslice_"+mat3dn_cons+"_R_map"
	string sliceRho = "Zslice_"+mat3dn_cons+"_Rho_map"

	//Update layers
		Cons3dplotc()

	//Update the FFT matrix if displayed
		string fftslice = "Zslice_"+mat3dn_cons+"_FFT3d"
		wave fftslicew = $fftslice

		if (waveexists(fftslicew) == 0)
		else
			checkDisplayed/W=$grabwinnonew(fftslice) fftslicew
			if (V_flag == 1)
				Cons3dplotcf()
			endif
		endif

	//Update 2d-lock-in if exist
		string flagexis2dlockin
		flagexis2dlockin = "Zslice_"+mat3dn_cons+"_phi_A"
		if (cmpstr(grabwinnonew(flagexis2dlockin),"") == 0)
		else
			execute "Const2dlockinc()"
		endif

		flagexis2dlockin = sliceI+"_phi_A"
		if (cmpstr(grabwinnonew(flagexis2dlockin),"") == 0)
		else
			execute "Const2dlockinc()"
		endif

		flagexis2dlockin = sliceZ+"_phi_A"
		if (cmpstr(grabwinnonew(flagexis2dlockin),"") == 0)
		else
			execute "Const2dlockinc()"
		endif

		flagexis2dlockin = sliceR+"_phi_A"
		if (cmpstr(grabwinnonew(flagexis2dlockin),"") == 0)
		else
			execute "Const2dlockinc()"
		endif

		flagexis2dlockin = sliceRho+"_phi_A"
		if (cmpstr(grabwinnonew(flagexis2dlockin),"") == 0)
		else
			execute "Const2dlockinc()"
		endif

	//Update lattice segregation if exist
		string lscheck = "segmatrix_Zslice_"+mat3dn_cons
		if (cmpstr(grabwinchild(lscheck),"") == 0)
		else
			MDoLSegrereapply()
		endif

	//Update FFTfilter if exist
		string flagexisfilter
		flagexisfilter = "Zslice_"+mat3dn_cons+"_ftd"
		if (cmpstr(grabwinnonew(flagexisfilter),"") == 0)
		else
			execute "Const2dfilterc()"
		endif

		flagexisfilter = sliceI+"_ftd"
		if (cmpstr(grabwinnonew(flagexisfilter),"") == 0)
		else
			execute "Const2dfilterc()"
		endif

		flagexisfilter = sliceZ+"_ftd"
		if (cmpstr(grabwinnonew(flagexisfilter),"") == 0)
		else
			execute "Const2dfilterc()"
		endif

		flagexisfilter = sliceR+"_ftd"
		if (cmpstr(grabwinnonew(flagexisfilter),"") == 0)
		else
			execute "Const2dfilterc()"
		endif

		flagexisfilter = sliceRho+"_ftd"
		if (cmpstr(grabwinnonew(flagexisfilter),"") == 0)
		else
			execute "Const2dfilterc()"
		endif

		//** Error message, no stop but Continuing execution
		String msg
		Variable err
		msg=GetErrMessage(GetRTError(0),3);
		err=GetRTError(1)
		if (err != 0)
			//Print "Error in Demo: " + msg
			//Print "Continuing execution"
		endif

	//Update symmetrized FT if exist
		variable/G colorratio_consFFT
		variable/G symmode_3dplot
		string slicename = "Zslice_"+mat3dn_cons
		String FFToutm = slicename+"_FFT"+"_Modula"
		String FFToutmsym = slicename+"_FFT"+"_sym"
		duplicate/o $FFToutm $FFToutmsym

		if (symmode_3dplot == 2)
			D4_sym_3dplot($FFToutmsym)
			color3s_subfor3dFFT($FFToutmsym,colorratio_consFFT)
		endif

		if (symmode_3dplot == 3)
			Mdiag_sym_3dplot($FFToutmsym)
			color3s_subfor3dFFT($FFToutmsym,colorratio_consFFT)
		endif

		if (symmode_3dplot == 4)
			Mx_sym_3dplot($FFToutmsym)
			color3s_subfor3dFFT($FFToutmsym,colorratio_consFFT)
		endif

		if (symmode_3dplot == 5)
			C4_sym_3dplot($FFToutmsym)
			color3s_subfor3dFFT($FFToutmsym,colorratio_consFFT)
		endif




End

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** {{{{{{{{{{ Update layer }}}}}}}}}}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function Cons3dplotc()
	string/G mat3dn_cons
	variable/G zn_cons
	variable/G z_cons

	variable/G colorratio_consFFT
	wave mat3dnw = $mat3dn_cons
	variable Z_constp=(z_cons-dimoffset(mat3dnw,zn_cons))/dimdelta(mat3dnw,zn_cons)
	string bare3d
	string barename = replaceString("_G",mat3dn_cons,"")

	//** g(r,V)
	string slicename = "Zslice_"+mat3dn_cons
	wave slicenamew =$slicename

	if(zn_cons == 0)
		slicenamew[][]=mat3dnw[Z_constp][p][q]
	endif
	if(zn_cons == 1)
		slicenamew[][]=mat3dnw[p][Z_constp][q]
	endif
	if(zn_cons == 2)
		slicenamew[][]=mat3dnw[p][q][Z_constp]
	endif

	func_zeroNaN($slicename)

	variable/G divcolor_cons
	if (divcolor_cons == 1)
		wavestats/Q slicenamew
		variable rangls = max(abs(V_max),abs(V_min))
		ModifyImage/W=$grabwinchild(slicename) $slicename ctab= {-rangls,rangls,:Packages:NewColortable:dvg_seismic,0};
		ColorScale/W=$grabwinchild(slicename)/C/N=textcc/X=-21.00/Y=5.00/F=0 heightPct=30,nticks=5,minor=1,tickLen=1.00,image=$slicename//;ColorScale/W=$grabwinchild(Fexyd)/C/N=text0/F=0/A=MC/Y=-120 image=$Fexyd
	endif

	if (divcolor_cons == 0)
		color3s_for3d($slicename,3)
		ColorScale/K/N=textcc
	endif

	if (checkmultiopen(12) == 0)
	else
		color3s_for3dm($slicename,3)
	endif
	f_for3d()
	String FFToutm = "Zslice_"+mat3dn_cons+ "_FFT"	+"_Modula"
	color3s_subfor3dFFT($FFToutm,colorratio_consFFT)
	if (checkmultiopen(12) == 0)
	else
		color3s_for3dm($FFToutm,colorratio_consFFT)
	endif




	if (checkmultiopen(12) == 0)
	else
	//** I(r,V)
		bare3d = barename+"_I"
		string sliceI = "Zslice_"+bare3d
		//make/o/N=(dimsize($bare3d,xn),dimsize($bare3d,yn)) $sliceI
		//setscale/p x,dimoffset($bare3d,xn),dimdelta($bare3d,xn),"",$sliceI
		//setscale/p y,dimoffset($bare3d,yn),dimdelta($bare3d,yn),"",$sliceI
		wave sliceIw = $sliceI
		wave bare3dw = $bare3d
		if(zn_cons == 0)
			sliceIw[][]=bare3dw[Z_constp][p][q]
		endif
		if(zn_cons == 1)
			sliceIw[][]=bare3dw[p][Z_constp][q]
		endif
		if(zn_cons == 2)
			sliceIw[][]=bare3dw[p][q][Z_constp]
		endif

		func_zeroNaN(sliceIw)
		color3s_for3dm(sliceIw,3)
		f_for3dmulti($sliceI)
		String FFTI = sliceI+"_FFT"+"_Modula"
		color3s_for3dm($FFTI,30)
	//** Z(r,V)
		bare3d = mat3dn_cons+"_Z_map"
		string sliceZ = "Zslice_"+bare3d
		//make/o/N=(dimsize($bare3d,xn),dimsize($bare3d,yn)) $sliceZ
		//setscale/p x,dimoffset($bare3d,xn),dimdelta($bare3d,xn),"",$sliceZ
		//setscale/p y,dimoffset($bare3d,yn),dimdelta($bare3d,yn),"",$sliceZ
		wave sliceZw = $sliceZ
		wave bare3dw = $bare3d
		if(zn_cons == 0)
			sliceZw[][]=bare3dw[Z_constp][p][q]
		endif
		if(zn_cons == 1)
			sliceZw[][]=bare3dw[p][Z_constp][q]
		endif
		if(zn_cons == 2)
			sliceZw[][]=bare3dw[p][q][Z_constp]
		endif
		func_zeroNaN(sliceZw)
		color3s_for3dm(sliceZw,3)
		f_for3dmulti($sliceZ)
		String FFTZ = sliceZ+"_FFT"+"_Modula"
		color3s_for3dm($FFTZ,30)


	//** R(r,V)
		bare3d = mat3dn_cons+"_R_map"
		string sliceR = "Zslice_"+bare3d
		//make/o/N=(dimsize($bare3d,xn),dimsize($bare3d,yn)) $sliceR
		//setscale/p x,dimoffset($bare3d,xn),dimdelta($bare3d,xn),"",$sliceR
		//setscale/p y,dimoffset($bare3d,yn),dimdelta($bare3d,yn),"",$sliceR
		wave sliceRw = $sliceR
		wave bare3dw = $bare3d
		if(zn_cons == 0)
			sliceRw[][]=bare3dw[Z_constp][p][q]
		endif
		if(zn_cons == 1)
			sliceRw[][]=bare3dw[p][Z_constp][q]
		endif
		if(zn_cons == 2)
			sliceRw[][]=bare3dw[p][q][Z_constp]
		endif
		func_zeroNaN(sliceRw)
		color3s_for3dm(sliceRw,3)
		f_for3dmulti($sliceR)
		String FFTR = sliceR+"_FFT"+"_Modula"
		color3s_for3dm($FFTR,30)


	//** Rho(r,V)
		bare3d = mat3dn_cons+"_Rho_map"
		string sliceRho = "Zslice_"+bare3d
		//make/o/N=(dimsize($bare3d,xn),dimsize($bare3d,yn)) $sliceRho
		//setscale/p x,dimoffset($bare3d,xn),dimdelta($bare3d,xn),"",$sliceRho
		//setscale/p y,dimoffset($bare3d,yn),dimdelta($bare3d,yn),"",$sliceRho
		wave sliceRhow = $sliceRho
		wave bare3dw = $bare3d
		if(zn_cons == 0)
			sliceRhow[][]=bare3dw[Z_constp][p][q]
		endif
		if(zn_cons == 1)
			sliceRhow[][]=bare3dw[p][Z_constp][q]
		endif
		if(zn_cons == 2)
			sliceRhow[][]=bare3dw[p][q][Z_constp]
		endif
		func_zeroNaN(sliceRhow)
		color3s_for3dm(sliceRhow,3)
		f_for3dmulti($sliceRho)
		String FFTRho = sliceRho+"_FFT"+"_Modula"
		color3s_for3dm($FFTRho,30)
	endif




	//** Indicative line
	string Zpp = "Zpp_"+mat3dn_cons
	wave zppw = $zpp
	Zppw=z_cons
end
/////////////////////////////////////////////////////////////////////////////////////////////////
Function Norma3dmatrix(name,Zn)
	wave name
	variable zn

	variable/G Znorm_cons

	//** Auto ordering layer index
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


		string nname = "Raw_"+nameofwave(name)

		variable avefactor
		variable i,j,k

	if (Znorm_cons == 1)
		wave nnnamew=$nname
		name = nnnamew
	else

		if (waveexists($nname) == 1)
		else
			duplicate/o name $nname
		endif
		wave nnnamew=$nname
		name = nnnamew
		k=0
		do
			j=0
			do
				avefactor=0
				i=0
				do
					if(zn == 0)
						avefactor+=nnnamew[i][j][k]
					endif
					if(zn == 1)
						avefactor+=nnnamew[j][i][k]
					endif
					if(zn == 2)
						avefactor+=nnnamew[j][k][i]
					endif
					i+=1
				while(i<dimsize(name,zn))


				if(zn == 0)
					name[][j][k]/=(avefactor/dimsize(nnnamew,zn))
				endif
				if(zn == 1)
					name[j][][k]/=(avefactor/dimsize(nnnamew,zn))
				endif
				if(zn == 2)
					name[j][k][]/=(avefactor/dimsize(nnnamew,zn))
				endif

				j+=1
			while(j<dimsize(name,xn))
			k+=1
		while(k<dimsize(name,yn))
	endif
end


//** End First Stage
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&]
//** Start Second Stage



////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** {{{{{{{{{{ Launch arbitary Linecut extraction }}}}}}}}}}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Cons3dplotlc(ctrlName) : ButtonControl
	String ctrlName
	string/G mat3dn_cons
	variable/G zn_cons
	string slicename = "Zslice_"+mat3dn_cons

	variable/G angle_3dplot=0
	variable/G addY_3dplot=0
	variable/G addX_3dplot=0
	variable/G normornot_3dplot =1
	variable/G smornot_3dplot =0

	//** Auto ordering layer index
		make/o/N=3 ordernum ={0,1,2}
		ordernum=abs(ordernum-zn_cons)
		wavestats/Q ordernum
		ordernum={0,1,2}
		DeletePoints V_minloc,1, ordernum
		wavestats/Q ordernum
		variable xn = ordernum[V_minloc]
		variable yn = ordernum[V_maxloc]
		killwaves ordernum

	//** append H indicating line (Blue)
		variable qqs,qqe,pps,ppe,xxs,xxe,yys,yye
		variable Nx,Ny,Nz
		Nx = dimsize($mat3dn_cons,xn)
		Ny = dimsize($mat3dn_cons,yn)
		Nz = dimsize($mat3dn_cons,zn_cons)
		pps=findstartpp(mat3dn_cons,angle_3dplot,zn_cons,addY_3dplot)
		ppe=findendpp(mat3dn_cons,angle_3dplot,zn_cons,addY_3dplot)
		xxs = dimoffset($mat3dn_cons,xn)+pps*dimdelta($mat3dn_cons,xn)
		xxe = dimoffset($mat3dn_cons,xn)+ppe*dimdelta($mat3dn_cons,xn)
		qqs = round(tan(angle_3dplot*pi/180)*(pps-round(Nx/2))+round(Ny/2)+addY_3dplot)
		qqe = round(tan(angle_3dplot*pi/180)*(ppe-round(Nx/2))+round(Ny/2)+addY_3dplot)
		yys = dimoffset($mat3dn_cons,yn)+qqs*dimdelta($mat3dn_cons,yn)
		yye = dimoffset($mat3dn_cons,yn)+qqe*dimdelta($mat3dn_cons,yn)

		string linetest="linetest_"+mat3dn_cons
		make/N=2/o $linetest
		wave linetestw =$linetest
		linetestw={yys,yye}
		setscale/I x, xxs,xxe,"",linetestw
		appendtograph/W=$grabwin(slicename) linetestw
		ModifyGraph/W=$grabwin(slicename) lsize($linetest)=2,rgb($linetest)=(0,0,65535)

	//** append V indicating line (Green)**************
		variable qqsv,qqev,ppsv,ppev,xxsv,xxev,yysv,yyev
		qqsv=findstartqq(mat3dn_cons,angle_3dplot,zn_cons,addX_3dplot)
		qqev=findendqq(mat3dn_cons,angle_3dplot,zn_cons,addX_3dplot)
		yysv = dimoffset($mat3dn_cons,yn)+qqsv*dimdelta($mat3dn_cons,yn)
		yyev = dimoffset($mat3dn_cons,yn)+qqev*dimdelta($mat3dn_cons,yn)
		ppsv = round(tan(-angle_3dplot*pi/180)*(qqsv-round(Ny/2))+round(Nx/2)+addX_3dplot)
		ppev = round(tan(-angle_3dplot*pi/180)*(qqev-round(Ny/2))+round(Nx/2)+addX_3dplot)
		xxsv = dimoffset($mat3dn_cons,xn)+ppsv*dimdelta($mat3dn_cons,xn)
		xxev = dimoffset($mat3dn_cons,xn)+ppev*dimdelta($mat3dn_cons,xn)

		string linetestv="linetestv_"+mat3dn_cons
		make/N=2/o $linetestv
		wave linetestvw = $linetestv
		linetestvw={yysv,yyev}
		if(abs(angle_3dplot) < 0.1)
			setscale/I x, xxsv,1.0000001*xxsv,"",linetestvw
		else
			setscale/I x, xxsv,xxev,"",linetestvw
		endif
		appendtograph/W=$grabwin(slicename) linetestvw
		ModifyGraph/W=$grabwin(slicename) lsize($linetestv)=2,rgb($linetestv)=(16385,65535,41303)


	//**Extract LinecutH and make graph
		anglelinecutH(mat3dn_cons,angle_3dplot,zn_cons,addY_3dplot,normornot_3dplot,smornot_3dplot)
		string linecutH = "LH_"+mat3dn_cons

		//di($linecutH)
		//Modifygraph/W=$grabwinnonew(linecutH) width=250, height=450
		//PauseUpdate
		//Silent 1
		//ModifyGraph/W=$grabwinnonew(linecutH) axThick=3,axRGB=(0,0,65535),tlblRGB=(0,0,65535),alblRGB=(0,0,65535)


	//**Extract LinecutV and make graph
		anglelinecutV(mat3dn_cons,angle_3dplot,zn_cons,addX_3dplot,normornot_3dplot,smornot_3dplot)
		string linecutV = "LV_"+mat3dn_cons

		//di($linecutV)
		//Modifygraph/W=$grabwinnonew(linecutV) width=250, height=450
		//PauseUpdate
		//Silent 1
		//ModifyGraph/W=$grabwinnonew(linecutV) axThick=3,axRGB=(16385,65535,41303),tlblRGB=(16385,65535,41303),alblRGB=(16385,65535,41303)

	//**Calculate FT_y for LinecutH and LinecutV
		FFTL2_3dplot($linecutH)
		FFTL2_3dplot($linecutV)
		string FTy_linecutH = linecutH+ "_FTyM"
		string FTy_linecutV = linecutV+ "_FTyM"


	//**Show subwindow***********************************************************************************\\

		display/N=ThreeDPlotlinecutwin; ModifyGraph margin(top)=72; modifygraph width=800,height=400
		Display/HOST=#/W=(0,0.05,0.3,1);
		appendimage $linecutH
		ModifyImage $linecutH ctab= {*,*,VioletOrangeYellow,0}
		ModifyGraph mirror=2,axThick=3
		ModifyGraph axRGB=(0,0,65535),tlblRGB=(0,0,65535),alblRGB=(0,0,65535)
		TextBox/C/N=text1a/F=0/A=RT/X=0.00/Y=0.00 "g(E,x)"

		setActiveSubwindow ##;
		Display/HOST=#/W=(0.7,0.05,1,1);
		appendimage $linecutV
		ModifyImage $linecutV ctab= {*,*,VioletOrangeYellow,0}
		ModifyGraph mirror=2,axThick=3
		ModifyGraph axRGB=(1,39321,19939),tlblRGB=(1,39321,19939),alblRGB=(1,39321,19939)
		TextBox/C/N=text1a/F=0/A=RT/X=0.00/Y=0.00 "g(E,y)"

		setActiveSubwindow ##;
		Display/HOST=#/W=(0.25,0.05,0.75,0.53);
		appendimage $FTy_linecutH
		ModifyImage $FTy_linecutH ctab= {*,*,VioletOrangeYellow,1}
		ModifyGraph mirror=2,axThick=3,axRGB=(0,0,65535),tlblRGB=(0,0,65535),alblRGB=(0,0,65535)
		color3s_subfor3dFFT($FTy_linecutH,10)
		TextBox/C/N=text1a/F=0/A=RT/X=0.00/Y=0.00 "FT(kx,E)"


		setActiveSubwindow ##;
		Display/HOST=#/W=(0.25,0.52,0.75,1);
		appendimage $FTy_linecutV
		ModifyImage $FTy_linecutV ctab= {*,*,VioletOrangeYellow,1}
		ModifyGraph mirror=2,axThick=3,axRGB=(1,39321,19939),tlblRGB=(1,39321,19939),alblRGB=(1,39321,19939)
		color3s_subfor3dFFT($FTy_linecutV,10)
		TextBox/C/N=text1a/F=0/A=RT/X=0.00/Y=0.00 "FT(ky,E)"


		setActiveSubwindow ##;

	//**PopoMenu of Normalization or not
		//PopupMenu popupnormornot win=$grabwin(linecutV),title="Norm?",proc=PopMenuProc_normornot,value="Yes;No" //Yes is 1, No is 2
		PopupMenu popupnormornot win=ThreeDPlotlinecutwin,title="Norm?",proc=PopMenuProc_normornot,value="Yes;No" //Yes is 1, No is 2


	//**PopoMenu of FT_Y or not
		variable/G FTy_3dplot = 1
		PopupMenu popupFTYornot win=ThreeDPlotlinecutwin,title="FT_y?",proc=PopMenuProc_ftyornot,value="Yes;No",pos={450,1} //Yes is 1, No is 2
		variable/G Ftysigma_3dplot	= 10
		SetVariable popupFTYornotsigma win=ThreeDPlotlinecutwin,title="σ_H",value=Ftysigma_3dplot,proc=SetVarProc_ftyornotsigma,limits={0,inf,0.5},size={65,14},pos={421,18}
		variable/G Ftysigma2_3dplot	= 10
		SetVariable popupFTYornotsigma2 win=ThreeDPlotlinecutwin,title="σ_V",value=Ftysigma2_3dplot,proc=SetVarProc_ftyornotsigma2,limits={0,inf,0.5},size={65,14},pos={493,18}

		variable/G q0remove_3dplot = 2
		PopupMenu popupq0removeornot win=ThreeDPlotlinecutwin,title="Gaus_bkg?",proc=PopMenuProc_bkgornot,value="Yes;No", pos={645,1},mode=2 //Yes is 1, No is 2

		variable/G sigmaremover_3dplot = 0.01
		SetVariable popupq0removesigma win=ThreeDPlotlinecutwin,title="σ_Gaus",value=sigmaremover_3dplot,proc=SetVarProc_bkgornotsigma,limits={0.0001,inf,0.01},size={100,14},pos={650,18}


	//**SetVar of Smooth
		//SetVariable setvarsmooth3dplot win=$grabwin(linecutV),title="Smooth?",pos={1,21},size={88,14},value=smornot_3dplot,proc=SetVarProc_smornot_3dplot
		//SetVariable setvarsmooth3dplot win=$grabwin(linecutV),limits={0,inf,1}
		SetVariable setvarsmooth3dplot win=ThreeDPlotlinecutwin,title="Smooth?",pos={91,3},size={70,14},value=smornot_3dplot,proc=SetVarProc_smornot_3dplot,limits={0,inf,1}

	//**SetVar of Rotation
		SetVariable setvarangle win=ThreeDPlotlinecutwin,title="Rotate",size={65,14},value=angle_3dplot,proc=SetVarProc_rotate3dplot,pos={203,18}
		SetVariable setvarangle win=ThreeDPlotlinecutwin,limits={-89,89,1}

	//**SetVar of AddY [set the Yrange(angel) by auto search]
		SetVariable setaddY win=ThreeDPlotlinecutwin,title="LH",size={65,14},value=addY_3dplot,proc=SetVarProc_addY3dplot,pos={169,3}
		duplicate/o findrangeforangle_LH(mat3dn_cons,angle_3dplot,zn_cons) rotateYlimit
		SetVariable setaddY win=ThreeDPlotlinecutwin,limits={rotateYlimit[0],rotateYlimit[1],1}

	//**SetVar of AddX [set the Xrange(angel) by auto search]
		SetVariable setaddX win=ThreeDPlotlinecutwin,title="LV",size={65,14},value=addX_3dplot,proc=SetVarProc_addX3dplot,pos={236,3}
		duplicate/o findrangeforangle_LV(mat3dn_cons,angle_3dplot,zn_cons) rotateXlimit
		SetVariable setaddX win=ThreeDPlotlinecutwin,limits={rotateXlimit[0],rotateXlimit[1],1}



	//** Control of Advanced Modes
		popupmenu popselectmode3d win=ThreeDPlotlinecutwin,bodyWidth=65,proc=PopMenuProc_selmode3dplot,value="2Point;FreeHand;Circular",bodyWidth=68,pos={330,1}
		Button Bfreehandprofile3d win=ThreeDPlotlinecutwin, title="Go",proc=ButtonProc_L3dplotdo,fSize=11,size={30,10},pos={350,20}


	//** Turn off
		Button turnoffls3d valueColor=(0,0,0),fColor=(1,65535,33232),proc=ButtonProc_lsturnoff3d,title="X",size={25,18},pos={771,6}



	//** Tile window
		//tilewindows/WINS=grabwinnonew(linecutV)/R/w=(29.5,0,92,100)/A=(1,1)
		//tilewindows/WINS=grabwinnonew(linecutH)/R/w=(51,0,92,100)/A=(1,1)
		tilewindows/WINS="ThreeDPlotlinecutwin"/R/w=(29.5,0,92,100)/A=(1,1)
end


Function SetVarProc_ftyornotsigma(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	string/G mat3dn_cons
	variable/G zn_cons
	string slicename = "Zslice_"+mat3dn_cons
	variable/G angle_3dplot
	variable/G addY_3dplot
	variable/G addX_3dplot
	variable/G normornot_3dplot
	variable/G smornot_3dplot
	variable/G FTy_3dplot
	variable/G Ftysigma_3dplot
	variable/G Ftysigma2_3dplot

	string linecutH = "LH_"+mat3dn_cons
	string linecutV = "LV_"+mat3dn_cons
	string FTy_linecutH = linecutH+ "_FTyM"
	string FTy_linecutV = linecutV+ "_FTyM"



	if (FTy_3dplot == 1)
		FFTL2_3dplot($linecutH)
		color3s_subfor3dFFT($FTy_linecutH,Ftysigma_3dplot)
		FFTL2_3dplot($linecutV)
		color3s_subfor3dFFT($FTy_linecutV,Ftysigma2_3dplot)
	endif
end

Function SetVarProc_ftyornotsigma2(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	string/G mat3dn_cons
	variable/G zn_cons
	string slicename = "Zslice_"+mat3dn_cons
	variable/G angle_3dplot
	variable/G addY_3dplot
	variable/G addX_3dplot
	variable/G normornot_3dplot
	variable/G smornot_3dplot
	variable/G FTy_3dplot
	variable/G Ftysigma_3dplot
	variable/G Ftysigma2_3dplot

	string linecutH = "LH_"+mat3dn_cons
	string linecutV = "LV_"+mat3dn_cons
	string FTy_linecutH = linecutH+ "_FTyM"
	string FTy_linecutV = linecutV+ "_FTyM"



	if (FTy_3dplot == 1)
		FFTL2_3dplot($linecutH)
		color3s_subfor3dFFT($FTy_linecutH,Ftysigma_3dplot)
		FFTL2_3dplot($linecutV)
		color3s_subfor3dFFT($FTy_linecutV,Ftysigma2_3dplot)
	endif
end


Function PopMenuProc_bkgornot(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string/G mat3dn_cons
	variable/G zn_cons
	string slicename = "Zslice_"+mat3dn_cons
	variable/G angle_3dplot
	variable/G addY_3dplot
	variable/G addX_3dplot
	variable/G normornot_3dplot
	variable/G smornot_3dplot
	variable/G FTy_3dplot

	variable/G q0remove_3dplot


	q0remove_3dplot=popNum
	string linecutH = "LH_"+mat3dn_cons
	string linecutV = "LV_"+mat3dn_cons
	string FTy_linecutH = linecutH+ "_FTyM"
	string FTy_linecutV = linecutV+ "_FTyM"

	variable/G Ftysigma_3dplot

	if (FTy_3dplot == 1)
		FFTL2_3dplot($linecutH)
		color3s_subfor3dFFT($FTy_linecutH,Ftysigma_3dplot)
		FFTL2_3dplot($linecutV)
		color3s_subfor3dFFT($FTy_linecutH,Ftysigma_3dplot)
	endif
end

Function SetVarProc_bkgornotsigma(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	string/G mat3dn_cons
	variable/G zn_cons
	string slicename = "Zslice_"+mat3dn_cons
	variable/G angle_3dplot
	variable/G addY_3dplot
	variable/G addX_3dplot
	variable/G normornot_3dplot
	variable/G smornot_3dplot
	variable/G FTy_3dplot
	variable/G Ftysigma_3dplot
	variable/G Ftysigma2_3dplot

	string linecutH = "LH_"+mat3dn_cons
	string linecutV = "LV_"+mat3dn_cons
	string FTy_linecutH = linecutH+ "_FTyM"
	string FTy_linecutV = linecutV+ "_FTyM"



	if (FTy_3dplot == 1)
		FFTL2_3dplot($linecutH)
		color3s_subfor3dFFT($FTy_linecutH,Ftysigma_3dplot)
		FFTL2_3dplot($linecutV)
		color3s_subfor3dFFT($FTy_linecutV,Ftysigma2_3dplot)
	endif
end

Function PopMenuProc_ftyornot(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string/G mat3dn_cons
	variable/G zn_cons
	string slicename = "Zslice_"+mat3dn_cons
	variable/G angle_3dplot
	variable/G addY_3dplot
	variable/G addX_3dplot
	variable/G normornot_3dplot
	variable/G smornot_3dplot
	variable/G FTy_3dplot

	FTy_3dplot=popNum
	string linecutH = "LH_"+mat3dn_cons
	string linecutV = "LV_"+mat3dn_cons
	string FTy_linecutH = linecutH+ "_FTyM"
	string FTy_linecutV = linecutV+ "_FTyM"

	variable/G Ftysigma_3dplot

	if (FTy_3dplot == 1)
		FFTL2_3dplot($linecutH)
		color3s_subfor3dFFT($FTy_linecutH,Ftysigma_3dplot)
		FFTL2_3dplot($linecutV)
		color3s_subfor3dFFT($FTy_linecutH,Ftysigma_3dplot)
	endif
end

Function color3s_subfor3dFFT(name,tt)
	wave name
	variable tt

	if (sum(name)-mean(name) == 0)
	else
		gethistgram_npcolor(nameofwave(name))
		string W_coef = "W_coef"
		wave W_coefw = $W_coef
		variable sigma = sqrt(2)*W_coefw[3]

		wavestats/Q name
		variable lc,lh
		if (W_coefw[2]-0.5*tt*sigma >V_min)
			lc = W_coefw[2]-0.5*tt*sigma
		else
			lc =V_min
		endif
		if (W_coefw[2]+0.5*tt*sigma < V_max)
			lh = W_coefw[2]+0.5*tt*sigma
		else
			lh =V_max
		endif

		ModifyImage/W=$grabwinchild(nameofwave(name)) $nameofwave(name) ctab= {lc,lh,VioletOrangeYellow,1}
	endif
end

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//##000
//** 1D FT along y for the linecuts
Function FFTL2_3dplot(name)
	wave name
	func_NaN0(name)
	String FFTout,nameout
	variable pc,qc
		FFTout = nameofWave(name) + "_FTy"
		FFT/WINF=Hanning/ROWS/DEST=$FFTout cvtcmplx(name)
		Complextorealf_3dplot($FFTout)

		nameout =FFTout+"M"
		wave nameoutw = $nameout

		matrixtranspose nameoutw
		pc = round((-dimoffset(nameoutw,0))/dimdelta(nameoutw,0))
		qc=round((-dimoffset(nameoutw,1))/dimdelta(nameoutw,1))

		nameoutw[pc][] = mean(nameoutw)
		killwaves $FFTout

		variable/G q0remove_3dplot
		variable/G sigmaremover_3dplot
		if (q0remove_3dplot == 1)
			FTgremover_3dploty(nameoutw,sigmaremover_3dplot)
		endif
end

Function Complextorealf_3dplot(name1w)
	wave name1w
	string name
	string name1 = nameOfWave(name1w)
		name=name1+"M"
		make/o/N=(dimsize(name1w,0),dimsize(name1w,1)) $name
		wave namew = $name
		namew=sqrt(real(name1w)^2+imag(name1w)^2)
	setscale/i x,dimoffset(name1w,0),dimoffset(name1w,0)+dimdelta(name1w,0)*(dimsize(name1w,0)-1),"",namew
	setscale/i y,dimoffset(name1w,1),dimoffset(name1w,1)+dimdelta(name1w,1)*(dimsize(name1w,1)-1),"",namew
end

Function FTgremover_3dploty(name,sigma)
	wave name
	variable sigma
	duplicate/o name gmask
	make/n=4 gmaskpara
	gmaskpara = {0,1,0,sigma}
	gmask = 1-Gauss1D(gmaskpara,x)

	name *= gmask
	killwaves gmaskpara gmask
end


////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//** INTERACTING FUNCTIONAL: Control Function
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//##01
//** Control Function:Change addY,
//** Call to change LinecutH and change the indicative line
Function SetVarProc_addY3dplot(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	string/G mat3dn_cons
	variable/G zn_cons
	variable/G angle_3dplot
	variable/G addY_3dplot
	variable/G addX_3dplot
	variable/G normornot_3dplot
	variable/G smornot_3dplot


	anglelinecutH(mat3dn_cons,angle_3dplot,zn_cons,addY_3dplot,normornot_3dplot,smornot_3dplot)
	angleline_3dp()

	//
	//slicesMDC($linecutH)

	variable/G FTy_3dplot
	variable/G Ftysigma_3dplot
	variable/G Ftysigma2_3dplot

	string linecutH = "LH_"+mat3dn_cons
	string linecutV = "LV_"+mat3dn_cons
	string FTy_linecutH = linecutH+ "_FTyM"
	string FTy_linecutV = linecutV+ "_FTyM"

	if (FTy_3dplot == 1)
		FFTL2_3dplot($linecutH)
		color3s_subfor3dFFT($FTy_linecutH,Ftysigma_3dplot)
		FFTL2_3dplot($linecutV)
		color3s_subfor3dFFT($FTy_linecutV,Ftysigma2_3dplot)
	endif

	TextBox/W=$grabwinchild(linecutH)/K/N=text0





end
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//##02
//** Control Function:Change addX,
//** Call to change LinecutH and change the indicative line
Function SetVarProc_addX3dplot(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	string/G mat3dn_cons
	variable/G zn_cons
	variable/G angle_3dplot
	variable/G addY_3dplot
	variable/G addX_3dplot
	variable/G normornot_3dplot
	variable/G smornot_3dplot

	anglelinecutV(mat3dn_cons,angle_3dplot,zn_cons,addX_3dplot,normornot_3dplot,smornot_3dplot)
	angleline_3dp()

	variable/G FTy_3dplot
	variable/G Ftysigma_3dplot
	variable/G Ftysigma2_3dplot

	string linecutH = "LH_"+mat3dn_cons
	string linecutV = "LV_"+mat3dn_cons
	string FTy_linecutH = linecutH+ "_FTyM"
	string FTy_linecutV = linecutV+ "_FTyM"

	if (FTy_3dplot == 1)
		FFTL2_3dplot($linecutH)
		color3s_subfor3dFFT($FTy_linecutH,Ftysigma_3dplot)
		FFTL2_3dplot($linecutV)
		color3s_subfor3dFFT($FTy_linecutV,Ftysigma2_3dplot)
	endif

	//string linecutH = "LH_"+mat3dn_cons
	//slicesMDC($linecutH)
end

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//##03
//** Control Function:Change Rotation,
//** Call to change LinecutH, LinecutV and change the indicative line, and Setvariable range setaddX/setaddY
Function SetVarProc_rotate3dplot(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	string/G mat3dn_cons
	variable/G zn_cons
	variable/G angle_3dplot
	variable/G addY_3dplot
	variable/G addX_3dplot
	variable/G normornot_3dplot
	variable/G smornot_3dplot

	string slicename = "Zslice_"+mat3dn_cons

	//Update Linecut
		anglelinecutH(mat3dn_cons,angle_3dplot,zn_cons,addY_3dplot,normornot_3dplot,smornot_3dplot)
		anglelinecutV(mat3dn_cons,angle_3dplot,zn_cons,addX_3dplot,normornot_3dplot,smornot_3dplot)

	//Update indicative line
		angleline_3dp()

	//Reset the range for addY
		duplicate/o findrangeforangle_LH(mat3dn_cons,angle_3dplot,zn_cons) rotateYlimit
		SetVariable setaddY win=ThreeDPlotlinecutwin,limits={rotateYlimit[0],rotateYlimit[1],1}

	//Reset the range for addX
		duplicate/o findrangeforangle_LV(mat3dn_cons,angle_3dplot,zn_cons) rotateXlimit
		SetVariable setaddX win=ThreeDPlotlinecutwin,limits={rotateXlimit[0],rotateXlimit[1],1}

		//string linecutH = "LH_"+mat3dn_cons
		//slicesMDC($linecutH)

	variable/G FTy_3dplot
	variable/G Ftysigma_3dplot
	variable/G Ftysigma2_3dplot

	string linecutH = "LH_"+mat3dn_cons
	string linecutV = "LV_"+mat3dn_cons
	string FTy_linecutH = linecutH+ "_FTyM"
	string FTy_linecutV = linecutV+ "_FTyM"

	if (FTy_3dplot == 1)
		FFTL2_3dplot($linecutH)
		color3s_subfor3dFFT($FTy_linecutH,Ftysigma_3dplot)
		FFTL2_3dplot($linecutV)
		color3s_subfor3dFFT($FTy_linecutV,Ftysigma2_3dplot)
	endif

	TextBox/W=$grabwinchild(linecutH)/K/N=text0


end

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//##04
//** Control Function:Change Normalization or not,
//**
Function PopMenuProc_normornot(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string/G mat3dn_cons
	variable/G zn_cons
	string slicename = "Zslice_"+mat3dn_cons
	variable/G angle_3dplot
	variable/G addY_3dplot
	variable/G addX_3dplot
	variable/G normornot_3dplot
	variable/G smornot_3dplot
	normornot_3dplot=popNum
	//print normornot
	//String toexecute1,toexecute2,toexecute
	//topgraphcolorinv=num2str(popNum-1)
	string linecutH = "LH_"+mat3dn_cons
	wave linecutHw=$linecutH
	string linecutV = "LV_"+mat3dn_cons
	wave linecutVw=$linecutV
	string rawH = "Raw_"+linecutH
	wave rawHw=$rawH
	string rawV = "Raw_"+linecutV
	wave rawVw=$rawV

	if (normornot_3dplot == 1)
		Normalinecut($linecutH)
		Normalinecut($linecutV)
	endif
	if (normornot_3dplot == 2)
		if (waveexists(rawHw) == 1)
		linecutHw = rawHw
		endif
		if (waveexists(rawVw) == 1)
		linecutVw = rawVw
		endif
	endif

	variable/G FTy_3dplot
	variable/G Ftysigma_3dplot
	variable/G Ftysigma2_3dplot

	//string linecutH = "LH_"+mat3dn_cons
	//string linecutV = "LV_"+mat3dn_cons
	string FTy_linecutH = linecutH+ "_FTyM"
	string FTy_linecutV = linecutV+ "_FTyM"

	if (FTy_3dplot == 1)
		FFTL2_3dplot($linecutH)
		color3s_subfor3dFFT($FTy_linecutH,Ftysigma_3dplot)
		FFTL2_3dplot($linecutV)
		color3s_subfor3dFFT($FTy_linecutV,Ftysigma2_3dplot)
	endif

	//Execute toexecute
End

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//##05
//** Control Function:Change Smooth
//**
Function SetVarProc_smornot_3dplot(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	string/G mat3dn_cons
	variable/G zn_cons
	variable/G angle_3dplot
	variable/G addY_3dplot
	variable/G addX_3dplot
	variable/G normornot_3dplot
	variable/G smornot_3dplot


	anglelinecutH(mat3dn_cons,angle_3dplot,zn_cons,addY_3dplot,normornot_3dplot,smornot_3dplot)
	anglelinecutV(mat3dn_cons,angle_3dplot,zn_cons,addX_3dplot,normornot_3dplot,smornot_3dplot)

	variable/G FTy_3dplot
	variable/G Ftysigma_3dplot
	variable/G Ftysigma2_3dplot

	string linecutH = "LH_"+mat3dn_cons
	string linecutV = "LV_"+mat3dn_cons
	string FTy_linecutH = linecutH+ "_FTyM"
	string FTy_linecutV = linecutV+ "_FTyM"

	if (FTy_3dplot == 1)
		FFTL2_3dplot($linecutH)
		color3s_subfor3dFFT($FTy_linecutH,Ftysigma_3dplot)
		FFTL2_3dplot($linecutV)
		color3s_subfor3dFFT($FTy_linecutV,Ftysigma2_3dplot)
	endif

END

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//** INTERACTING FUNCTIONAL: Update indicative lines
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function angleline_3dp()
	string/G mat3dn_cons
	variable/G zn_cons
	string slicename = "Zslice_"+mat3dn_cons

	variable/G angle_3dplot
	variable/G addY_3dplot
	variable/G addX_3dplot

	//** Auto ordering layer index
		make/o/N=3 ordernum ={0,1,2}
		ordernum=abs(ordernum-zn_cons)
		wavestats/Q ordernum
		ordernum={0,1,2}
		DeletePoints V_minloc,1, ordernum
		wavestats/Q ordernum
		variable xn = ordernum[V_minloc]
		variable yn = ordernum[V_maxloc]
		killwaves ordernum

	//** The part for horizental line (blue)
		variable qqs,qqe,pps,ppe,xxs,xxe,yys,yye
		variable Nx,Ny,Nz
		Nx = dimsize($mat3dn_cons,xn)
		Ny = dimsize($mat3dn_cons,yn)
		Nz = dimsize($mat3dn_cons,zn_cons)
		pps=findstartpp(mat3dn_cons,angle_3dplot,zn_cons,addY_3dplot)
		ppe=findendpp(mat3dn_cons,angle_3dplot,zn_cons,addY_3dplot)
		xxs = dimoffset($mat3dn_cons,xn)+pps*dimdelta($mat3dn_cons,xn)
		xxe = dimoffset($mat3dn_cons,xn)+ppe*dimdelta($mat3dn_cons,xn)
		qqs = round(tan(angle_3dplot*pi/180)*(pps-round(Nx/2))+round(Ny/2)+addY_3dplot)
		qqe = round(tan(angle_3dplot*pi/180)*(ppe-round(Nx/2))+round(Ny/2)+addY_3dplot)
		yys = dimoffset($mat3dn_cons,yn)+qqs*dimdelta($mat3dn_cons,yn)
		yye = dimoffset($mat3dn_cons,yn)+qqe*dimdelta($mat3dn_cons,yn)

		string linetest="linetest_"+mat3dn_cons
		wave linetestw = $linetest
		//make/N=2/o linetest
		linetestw={yys,yye}
		setscale/I x, xxs,xxe,"",linetestw

	//** The part for vertical line (white)
		variable qqsv,qqev,ppsv,ppev,xxsv,xxev,yysv,yyev
		qqsv=findstartqq(mat3dn_cons,angle_3dplot,zn_cons,addX_3dplot)
		qqev=findendqq(mat3dn_cons,angle_3dplot,zn_cons,addX_3dplot)
		yysv = dimoffset($mat3dn_cons,yn)+qqsv*dimdelta($mat3dn_cons,yn)
		yyev = dimoffset($mat3dn_cons,yn)+qqev*dimdelta($mat3dn_cons,yn)
		ppsv = round(tan(-angle_3dplot*pi/180)*(qqsv-round(Ny/2))+round(Nx/2)+addX_3dplot)
		ppev = round(tan(-angle_3dplot*pi/180)*(qqev-round(Ny/2))+round(Nx/2)+addX_3dplot)
		xxsv = dimoffset($mat3dn_cons,xn)+ppsv*dimdelta($mat3dn_cons,xn)
		xxev = dimoffset($mat3dn_cons,xn)+ppev*dimdelta($mat3dn_cons,xn)

		string linetestv="linetestv_"+mat3dn_cons
		wave linetestvw = $linetestv
		//make/N=2/o linetest
		linetestvw={yysv,yyev}
		if(abs(angle_3dplot) < 0.1)
			setscale/I x, xxsv,1.0000001*xxsv,"",linetestvw
		else
			setscale/I x, xxsv,xxev,"",linetestvw
		endif
end

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//** INTERACTING FUNCTIONAL: Normalization or not
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
Proc Normalinecutc(name)
	String name = tpw()
	Normalinecut($name)
end
Function Normalinecut(name)
	wave name
	string nname = "Raw_"+nameofwave(name)
	duplicate/o name $nname
	wave nnnamew=$nname
	variable avefactor
	variable i,j
	j=0
	do
		avefactor=0
		i=0

		do
			avefactor+=nnnamew[i][j]
			i+=1
		while(i<dimsize(name,0))
		name[][j]/=(avefactor/dimsize(nnnamew,0))
		j+=1
	while(j<dimsize(name,1))
end

Function ButtonProc_Normalinecut(ctrlName) : ButtonControl
	String ctrlName
	Execute "Normalinecutc2()"
End
Proc Normalinecutc2(name,sel)
	String name = tpw()
	variable sel = 1
	prompt name,"The Name of Linecut"
	Prompt sel,"Mode",popup"along X;along Y"
	if(sel == 1)
		NormalinecutX($name)
	endif
	if(sel == 2)
		NormalinecutY($name)
	endif
end
Function NormalinecutX(name)
	wave name
	string nname = "Raw_"+nameofwave(name)
	duplicate/o name $nname
	wave nnnamew=$nname
	variable avefactor
	variable i,j
	j=0
	do
		avefactor=0
		i=0

		do
			avefactor+=nnnamew[i][j]
			i+=1
		while(i<dimsize(name,0))
		name[][j]/=(avefactor/dimsize(nnnamew,0))
		j+=1
	while(j<dimsize(name,1))
end

Function NormalinecutY(name)
	wave name
	string nname = "Raw_"+nameofwave(name)
	duplicate/o name $nname
	wave nnnamew=$nname
	variable avefactor
	variable i,j
	i=0
	do
		avefactor=0
		j=0

		do
			avefactor+=nnnamew[i][j]
			j+=1
		while(j<dimsize(name,1))
		name[i][]/=(avefactor/dimsize(nnnamew,1))
		i+=1
	while(j<dimsize(name,0))
end

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//** INTERACTING FUNCTIONAL: Smooth times update
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function smoothtimes(name)
	wave name
	string nname = "SRaw_"+nameofwave(name)
	duplicate/o name $nname
	wave nnnamew=$nname

	variable/G smornot_3dplot
	if (smornot_3dplot ==0)
		name=nnnamew
	else
		//variable avefactor
		variable i,j
		make/n=(dimsize(nnnamew,0))/o slicetemp
		name=nnnamew
		j=0
		do
			//avefactor=0
			//i=0

			//do
			slicetemp[]=nnnamew[p][j]
			smooth smornot_3dplot,slicetemp
			//	i+=1
			//while(i<dimsize(name,0))
			name[][j]= slicetemp[p]
			j+=1
		while(j<dimsize(name,1))
	endif

	killwaves slicetemp
end

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//** INTERACTING FUNCTIONAL: Extract rotated Horizental Linecut
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//%%%%%%%%%%%%** get rotated H-linecut, addY here is counted from center.
//%%%%%%%%%%%%** H-linecut can move in Y direction, addY is DQ(Int)
////////////////////////////////////////////////////////////////////////////////////////////////////////////

//*****************************************************
//## 01
//** Main Function
Function anglelinecutH(mat,angle,Zn,addY,normornot,smornot)
	String mat
	variable angle
	variable Zn
	variable addY
	variable normornot
	variable smornot
	//** Auto ordering layer index
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

	//** Initial layer dimsize
		wave matw = $mat
		variable Nx,Ny,Nz
		Nx = dimsize(matw,xn)
		Ny = dimsize(matw,yn)
		Nz = dimsize(matw,zn)
		variable pp, qq

	//** Determine Limit for Assignment Loop
		variable qqs,qqe,pps,ppe,xxs,xxe,yys,yye  //** qq = tan(angle*pi/180)*(pp-round(Nx/2))+round(Ny/2)+addY

		//** Determine the First and Last P when extracting the rotated Linecut
			pps=findstartpp(mat,angle,Zn,addY) //** First P at certain Rotation[angle] and shift[addY]
			ppe=findendpp(mat,angle,Zn,addY)   //** Last P at certain Rotation[angle] and shift[addY]

		//** Calculate Q and X, Y
			xxs = dimoffset(matw,xn)+pps*dimdelta(matw,xn)
			xxe = dimoffset(matw,xn)+ppe*dimdelta(matw,xn)
			qqs = round(tan(angle*pi/180)*(pps-round(Nx/2))+round(Ny/2)+addY)
			qqe = round(tan(angle*pi/180)*(ppe-round(Nx/2))+round(Ny/2)+addY)
			yys = dimoffset(matw,yn)+qqs*dimdelta(matw,yn)
			yye = dimoffset(matw,yn)+qqe*dimdelta(matw,yn)

		//** Calculate Linecut Scale
			variable len = sqrt((xxe-xxs)^2+(yye-yys)^2)
			string linecutH = "LH_"+mat
			make/N=(Nz,(ppe-pps+1))/o $linecutH
			wave linecutHw = $linecutH
			setscale/p x,dimoffset(matw,zn),dimdelta(matw,zn),"",linecutHw
			setscale/i y,xxs,xxs+len,"",linecutHw

	//** Extract value from 3D matrix
		//** The value assignment loop is runing along P
		variable i
		i=0
		pp=pps
		do
			qq= round(tan(angle*pi/180)*(pp-round(Nx/2))+round(Ny/2)+addY) //[Formula of Rotated HLine]
			//linecutHw[][i] = matw[pp][qq][p]
			if(zn == 0)
				linecutHw[][i] = matw[p][pp][qq]
			endif
			if(zn == 1)
				linecutHw[][i] = matw[pp][p][qq]
			endif
			if(zn == 2)
				linecutHw[][i] = matw[pp][qq][p]
			endif
			pp+=1
			i+=1
		while(pp < ppe+1)
		//di(linecutHw)

	//** Normalization
		if (normornot == 1)
			Normalinecut(linecutHw)
		endif

	//** Smooth
		//string smnname = "SRaw_"+nameofwave(linecutHw)
		//wave smnnamew = $smnname
		//if (smornot == 0)
		//	if (waveexists(smnnamew) == 1)
		//		linecutHw = smnnamew
		//	endif
		//else
		smoothtimes(linecutHw)
		//endif
end

//*****************************************************
//## 02
//** Determine the First P for assignment loop
Function findstartpp(mat,angle,Zn,addY)
	String mat
	variable angle
	variable Zn
	variable addY

	//** Auto ordering layer index
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

	//** Initial layer dimsize
		wave matw = $mat
		variable Nx,Ny,Nz
		Nx = dimsize(matw,xn)
		Ny = dimsize(matw,yn)
		Nz = dimsize(matw,zn)

	//** Search for the Start P
		variable pp, qq,pps
		variable i
		pps=nan
		i=0 //## Search from the smallest P [i.e. 0], calculate when Q is in range, that position is pps
		do
			qq = tan(angle*pi/180)*(i-round(Nx/2))+round(Ny/2)+addY //[Formula of Rotated HLine]
			//print qq
			if(round(qq) >= 0 && round(qq) <= Ny-1 ) //** condition of Q in range
				pps = i
				break
			endif
			i+=1
		while(i < Nx)
		return pps
end

//*****************************************************
//## 03
//** Determine the Last P for assignment loop
Function findendpp(mat,angle,Zn,addY)
	String mat
	variable angle
	variable Zn
	variable addY

	//** Auto ordering layer index
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

	//** Initial layer dimsize
		wave matw = $mat
		variable Nx,Ny,Nz
		Nx = dimsize(matw,xn)
		Ny = dimsize(matw,yn)
		Nz = dimsize(matw,zn)

	//** Search for the End P
		variable pp, qq,ppe
		variable i
		ppe=nan
		i=Nx-1 //## Search from the largest P, calculate when Q is in range, that position is ppe
		do
			qq = tan(angle*pi/180)*(i-round(Nx/2))+round(Ny/2)+addY //[Formula of Rotated HLine]
				//print qq
			if(round(qq) <= Ny-1 && round(qq) >= 0) //** condition of Q in range
				ppe = i
				break
			endif
			i-=1
		while(i >= 0)
		return ppe
end

//*****************************************************
//## 04
//** Find the addY Range for rotated H-Linecut
Function/Wave findrangeforangle_LH(mat,angle,Zn)
	String mat
	variable angle
	variable Zn

	//** Auto ordering layer index
		make/o/N=3 ordernum ={0,1,2}
		ordernum=abs(ordernum-zn)
		wavestats/Q ordernum
		ordernum={0,1,2}
		DeletePoints V_minloc,1, ordernum
		wavestats/Q ordernum
		variable xn = ordernum[V_minloc]
		variable yn = ordernum[V_maxloc]
		killwaves ordernum

	//** Search for high limit
		variable addY, addYmax, addYmin,body
		addY =0
		do
			body = mod(Round(findendpp(mat,angle,Zn,addY)),1)
			if (body != 0)
				addYmax = addY-1
				break
			endif
			addY+=1
		while(addY < 3*dimsize($mat,yn))

	//** Search for low limit
		addY =0
		do
			body = mod(Round(findendpp(mat,angle,Zn,addY)),1)
			if (body != 0)
				addYmin = addY+1
				break
			endif
			addY-=1
		while(addY >  -3*dimsize($mat,yn))

	//** Return the limit wave
		make/N=2/o Hcut_Vrange
		//print addYmin
		//print addYmax
		Hcut_Vrange={addYmin,addYmax}
		return Hcut_Vrange
end

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//** INTERACTING FUNCTIONAL: Extract rotated Vertical Linecut
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//%%%%%%%%%%%%** get rotated V-linecut, addX here is counted from center.
//%%%%%%%%%%%%** V-linecut can move in X direction, addX is DP(Int)
////////////////////////////////////////////////////////////////////////////////////////////////////////////

//*****************************************************
//## 01
//** Main Function
Function anglelinecutV(mat,angle,Zn,addX,normornot,smornot)
	String mat
	variable angle
	variable Zn
	variable addX
	variable normornot
	variable smornot
	//** Auto ordering layer index
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

	//** Initial layer dimsize
		wave matw = $mat
		variable Nx,Ny,Nz
		Nx = dimsize(matw,xn)
		Ny = dimsize(matw,yn)
		Nz = dimsize(matw,zn)
		variable pp, qq

	//** Determine Limit for Assignment Loop
		//## Play with vertical Line
		//## Logistically, we swap P and Q
		//## that mean, set Q as independent variable
		//## and check P the dependent variable

		//** Determine the First and Last Q for value assignment loop
			variable qqs,qqe,pps,ppe,xxs,xxe,yys,yye //pp = tan(angle*pi/180)*(qq-round(Ny/2))+round(Nx/2)+addX
			qqs=findstartqq(mat,angle,Zn,addX) //First Q
			qqe=findendqq(mat,angle,Zn,addX)   //Last Q

		//** Calculate P and X, Y
			yys = dimoffset(matw,yn)+qqs*dimdelta(matw,yn)
			yye = dimoffset(matw,yn)+qqe*dimdelta(matw,yn)
			pps = tan(-angle*pi/180)*(qqs-round(Ny/2))+round(Nx/2)+addX
			ppe = tan(-angle*pi/180)*(qqe-round(Ny/2))+round(Nx/2)+addX
			xxs = dimoffset(matw,xn)+pps*dimdelta(matw,xn)
			xxe = dimoffset(matw,xn)+ppe*dimdelta(matw,xn)


		//** Calculate linecut scale
			variable len = sqrt((xxe-xxs)^2+(yye-yys)^2)
			string linecutV = "LV_"+mat
			make/N=(Nz,(qqe-qqs+1))/o $linecutV
			wave linecutVw = $linecutV
			setscale/p x,dimoffset(matw,zn),dimdelta(matw,zn),"",linecutVw
			setscale/i y,yys,yys+len,"",linecutVw

	//** Extract value from 3D matrix
		//** The value assignment loop is runing along Q
		variable i
		i=0
		qq=qqs
		do
			//qq= round(tan(-angle*pi/180)*(pp-round(Nx/2))+round(Ny/2)+addY)
			pp = round(tan(-angle*pi/180)*(qq-round(Ny/2))+round(Nx/2)+addX) //[Formula of Rotated VLine]

			//linecutHw[][i] = matw[pp][qq][p]

			if(zn == 0)
				linecutVw[][i] = matw[p][pp][qq]
			endif
			if(zn == 1)
				linecutVw[][i] = matw[pp][p][qq]
			endif
			if(zn == 2)
				linecutVw[][i] = matw[pp][qq][p]
			endif
			qq+=1
			i+=1
		while(qq < qqe+1)
		//di(linecutHw)

	//** Normalization
		if (normornot == 1)
			Normalinecut(linecutVw)
		endif
	//** Smooth
		smoothtimes(linecutVw)

	//** Error message, no stop but Continuing execution
		String msg
		Variable err
		msg=GetErrMessage(GetRTError(0),3);
		err=GetRTError(1)
		//if (err != 0)
		//	Print "Error in Demo: " + msg
		//	Print "Continuing execution"
		//endif


end

//*****************************************************
//## 02
//** Determine the First Q for assignment loop
Function findstartqq(mat,angle,Zn,addX)
	String mat
	variable angle
	variable Zn
	variable addX

	//** Auto ordering layer index
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

	//** Initial layer dimsize
		wave matw = $mat
		variable Nx,Ny,Nz
		Nx = dimsize(matw,xn)
		Ny = dimsize(matw,yn)
		Nz = dimsize(matw,zn)

	//** Search for the Start Q
		variable pp, qq,qqs
		variable i
		qqs=nan
		i=0 //## Search from the smallest Q [i.e. 0], calculate when P is in range, that position is pps
		do
			pp = tan(-angle*pi/180)*(i-round(Ny/2))+round(Nx/2)+addX //[Formula of Rotated VLine]
			if(round(pp) >= 0 && round(pp) <= Nx-1 ) //Condition for P in range
				qqs = i
				break
			endif
			i+=1
		while(i < Ny)
		return qqs
end

//*****************************************************
//## 03
//** Determine the Last Q for assignment loop
Function findendqq(mat,angle,Zn,addX)
	String mat
	variable angle
	variable Zn
	variable addX

	//** Auto ordering layer index
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

	//** Initial layer dimsize
		wave matw = $mat
		variable Nx,Ny,Nz
		Nx = dimsize(matw,xn)
		Ny = dimsize(matw,yn)
		Nz = dimsize(matw,zn)

	//** Search for the End Q
		variable pp, qq,qqe
		variable i
		qqe=nan
		i=Nx-1 //## Search from the largest Q, calculate when P is in range, that position is pps
		do
			pp = tan(-angle*pi/180)*(i-round(Ny/2))+round(Nx/2)+addX //[Formula of Rotated VLine]
			//print qq
			if(round(pp) >= 0 && round(pp) <= Nx-1) //Condition for P in range
				qqe = i
				break
			endif
			i-=1
		while(i >= 0)
		return qqe
end

//*****************************************************
//## 04
//** Find the addX Range for rotated V-Linecut
Function/Wave findrangeforangle_LV(mat,angle,Zn)
	String mat
	variable angle
	variable Zn

	//** Auto ordering layer index
		make/o/N=3 ordernum ={0,1,2}
		ordernum=abs(ordernum-zn)
		wavestats/Q ordernum
		ordernum={0,1,2}
		DeletePoints V_minloc,1, ordernum
		wavestats/Q ordernum
		variable xn = ordernum[V_minloc]
		variable yn = ordernum[V_maxloc]
		killwaves ordernum

	//** High Limit
		variable addX, addXmax, addXmin,body
		addX =0
		do
			body = mod(Round(findendqq(mat,angle,Zn,addX)),1)
			if (body != 0)
				addXmax = addX-1
				break
			endif
			addX+=1
		while(addX < 3*dimsize($mat,xn))

	//** Low Limit
		addX =0
		do
			body = mod(Round(findendpp(mat,angle,Zn,addX)),1)
			if (body != 0)
				addXmin = addX+1
				break
			endif
			addX-=1
		while(addX >  -3*dimsize($mat,xn))

	//** Return Limit
		make/N=2/o Vcut_Vrange
		//print addYmin
		//print addYmax
		Vcut_Vrange={addXmin,addXmax}
		return Vcut_Vrange
end


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** Auxiliary Functions
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

//*****************************************************
//## 01
//** Special FFT
Function f_for3d()
	string/G mat3dn_cons
	string slicename = "Zslice_"+mat3dn_cons
	wave name=$slicename
	func_NaN0(name)
	String FFTout
	FFTout = nameofWave(name) + "_FFT"
	FFT/out=1/WINF=Hanning/DEST=$FFTout cvtcmplx(name)
	Complextorealf_for3d($FFTout,1)
	String FFToutm = FFTout+"_Modula"
	//ModifyImage $FFToutm ctab= {*,*,VioletOrangeYellow,1}
	//Print "FFTr("+nameofWave(name)+")"

	variable/G GBK2dornot_3dplot
	variable/G GBK2dsigma_3dplot
	if (GBK2dornot_3dplot == 1)
		FTguassianremover($FFToutm,GBK2dsigma_3dplot)
	endif
end
Function Complextorealf_for3d(name1w,select)
	wave name1w
	variable select
	string name
	string name1 = nameOfWave(name1w)

		name=name1+"_Modula"
		make/o/N=(dimsize(name1w,0),dimsize(name1w,1)) $name
		wave namew = $name
		namew=sqrt(real(name1w)^2+imag(name1w)^2)

	setscale/i x,dimoffset(name1w,0),dimoffset(name1w,0)+dimdelta(name1w,0)*(dimsize(name1w,0)-1),"",namew
	setscale/i y,dimoffset(name1w,1),dimoffset(name1w,1)+dimdelta(name1w,1)*(dimsize(name1w,1)-1),"",namew
	//dilf(namew)
end

//*****************************************************
//## 02
//** Special Color Range
Function color3s_for3d(name,tt)
	wave name
	variable tt
	gethistgram_npcolor(nameofwave(name))
	string W_coef = "W_coef"
	wave W_coefw = $W_coef
	variable sigma = sqrt(2)*W_coefw[3]

	wavestats/Q name
	variable lc,lh
	if (W_coefw[2]-0.5*tt*sigma >V_min)
		lc = W_coefw[2]-0.5*tt*sigma
	else
		lc =V_min
	endif
	if (W_coefw[2]+0.5*tt*sigma < V_max)
		lh = W_coefw[2]+0.5*tt*sigma
	else
		lh =V_max
	endif

	ModifyImage/W=$grabwinnonew(nameofwave(name)) $nameofwave(name) ctab= {lc,lh,VioletOrangeYellow,0}
	//PRINT num2str(W_coefw[2]-1.5*sigma)+" "+ num2str(W_coefw[2]+1.5*sigma)
	//print num2str(W_coefw[2])
	//display namehistw
end

Function color3s_for3dFFT(name,tt)
	wave name
	variable tt

	//if (sum(name)-mean(name) == 0 )
	//else
		gethistgram_npcolor(nameofwave(name))
		string W_coef = "W_coef"
		wave W_coefw = $W_coef
		variable sigma = sqrt(2)*W_coefw[3]

		wavestats/Q name
		variable lc,lh
		if (W_coefw[2]-0.5*tt*sigma >V_min)
			lc = W_coefw[2]-0.5*tt*sigma
		else
			lc =V_min
		endif
		if (W_coefw[2]+0.5*tt*sigma < V_max)
			lh = W_coefw[2]+0.5*tt*sigma
		else
			lh =V_max
		endif

		ModifyImage/W=$grabwinnonew(nameofwave(name)) $nameofwave(name) ctab= {lc,lh,VioletOrangeYellow,1}
	//endif
	//PRINT num2str(W_coefw[2]-1.5*sigma)+" "+ num2str(W_coefw[2]+1.5*sigma)
	//print num2str(W_coefw[2])
	//display namehistw
end

Function color3s_for3dinv(name,tt)
	wave name
	variable tt
	gethistgram_npcolor(nameofwave(name))
	string W_coef = "W_coef"
	wave W_coefw = $W_coef
	variable sigma = sqrt(2)*W_coefw[3]

	wavestats/Q name
	variable lc,lh
	if (W_coefw[2]-0.5*tt*sigma >V_min)
		lc = W_coefw[2]-0.5*tt*sigma
	else
		lc =V_min
	endif
	if (W_coefw[2]+0.5*tt*sigma < V_max)
		lh = W_coefw[2]+0.5*tt*sigma
	else
		lh =V_max
	endif

	ModifyImage/W=$grabwinnonew(nameofwave(name)) $nameofwave(name) ctab= {lc,lh,VioletOrangeYellow,1}
	//PRINT num2str(W_coefw[2]-1.5*sigma)+" "+ num2str(W_coefw[2]+1.5*sigma)
	//print num2str(W_coefw[2])
	//display namehistw
end

//*****************************************************
//## 03
//** Special Grabwindown with open new
Function/s grabwinnonew(name)
	string name
 	string fulllist = WinList("*", ";","WIN:1")
	string nn,waveong,cmdn,out
	out = ""
	variable i
	for(i=0; i<itemsinlist(fulllist); i +=1)
        nn= stringfromlist(i, fulllist)
        cmdn="WIN:"+nn
        waveong = stringfromlist(0,WaveList("*", ";",cmdn))  //Only detect the first element.
        if (CmpStr(name,waveong) == 0)
        	out = nn
        else
        endif
    endfor
    Return out
end

//*****************************************************
//## 04
//** Average out two dimensions for a 3D Matrix
Function ButtonProc_sumonedc(ctrlName) : ButtonControl
	String ctrlName
	Execute "sumonedc()"
end
Proc sumonedc(orin,dest,zn)
	string orin //Input 3D matrix
	string dest = "_Itg1D"//Output name
	variable zn
	prompt orin,"3D wave",popup getall3dwave()
	Prompt dest,"Suffix of averaged 1D wave"
	Prompt zn,"Dimension Index to retain"
	string dd = orin+dest
	sumoned(dd,orin,zn)
end
Function sumoned(dest,orin,zn)
	string dest //Output name
	string orin //Input 3D matrix
	variable zn //Index of your interesting dimension that keep in the end.

	//** Auto ordering layer index
		make/o/N=3 ordernum ={0,1,2}
		ordernum=abs(ordernum-zn)
		wavestats/Q ordernum
		ordernum={0,1,2}
		DeletePoints V_minloc,1, ordernum
		wavestats/Q ordernum
		variable xn = ordernum[V_minloc]
		variable yn = ordernum[V_maxloc]
		killwaves ordernum

	wave orinw = $orin
	make/N=(dimsize(orinw,zn))/o $dest
	wave destw = $dest
	destw=0
	variable i,j,k,addk,countnum=0

	variable is,ie,js,je
	variable/G FFTmarque_3dplot// 1 for whole, 2 for in marque
	if (FFTmarque_3dplot == 1)
		is = 0
		ie = dimsize(orinw,xn)
		js = 0
		je = dimsize(orinw,yn)
	endif
	if (FFTmarque_3dplot == 2)
		getmarquee/W=$winname(0,1) left, bottom
		variable p1,p2,q1,q2
		is = round((v_left-dimoffset($tpw(),0))/dimdelta($tpw(),0))
		ie = round((v_right-dimoffset($tpw(),0))/dimdelta($tpw(),0))+1
		js = round((v_bottom-dimoffset($tpw(),1))/dimdelta($tpw(),1))
		je = round((v_top-dimoffset($tpw(),1))/dimdelta($tpw(),1))+1
			//print is, ie ,js, je
			//print tpw()
	endif


	//if (mod(Round(mean(orinw)),1)!=0)
		i=is//round(dimsize(orinw,xn)/6)
		do
			j=js//round(dimsize(orinw,yn)/6)
			do
				if(zn== 0)
					destw[]+=orinw[p][i][j]
				endif
				if(zn== 1)
					destw[]+=orinw[i][p][j]
				endif
				if(zn== 2)
					//destw[]+=orinw[i][j][p]
				k=0
				addk=0
				do
					addk+=orinw[i][j][k]
					k+=1
				while(k<dimsize(orinw,zn))

				if(mod(Round(addk),1)!=0)
				else
					destw[]+=orinw[i][j][p]
					countnum+=1
				endif

				endif
				j+=1
			while(j<je)//*5/6)
			i+=1
		while(i<ie)//*5/6)
	//else
	//	i=0
	//	do
	//		j=0
	//		do
	//			if(zn== 0)
	//				destw[]+=orinw[p][i][j]
	//			endif
	//			if(zn== 1)
	//				destw[]+=orinw[i][p][j]
	//			endif
	//			if(zn== 2)
	//				destw[]+=orinw[i][j][p]
	//
	//			endif
	//			j+=1
	//		while(j<dimsize(orinw,yn))
	//		i+=1
	//	while(i<dimsize(orinw,xn))
	//endif
	variable mmm=mean(destw)
	destw/=mmm
	setscale/p x,dimoffset(orinw,zn),dimdelta(orinw,zn),"",destw
	//display destw
End

//*****************************************************
//## 05
//** Function to get a stringlist containing the name of
//** all the three dimensional data.
Function/S getall3dwave()
	variable num=itemsinList(WaveList("*",";",""))
	variable i
	string namewave = ""
	i=0
	do
		if(waveDims($stringfromlist(i,WaveList("*",";",""))) == 3)
		namewave+=stringfromlist(i,WaveList("*",";",""))+";"
		endif
		i+=1
	while(i<num)
	Return namewave
end

//*****************************************************
//## 06
//** Function to get a stringlist containing the name of
//** all the 2 dimensional data.
Function/S getall2dwave()
	variable num=itemsinList(WaveList("*",";",""))
	variable i
	string namewave = ""
	i=0
	do
		if(waveDims($stringfromlist(i,WaveList("*",";",""))) == 2)
		namewave+=stringfromlist(i,WaveList("*",";",""))+";"
		endif
		i+=1
	while(i<num)
	Return namewave
end

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//** 3D Advanced EMDC Mode
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

//#1 control of Advanced mode (select modes)
Function PopMenuProc_selmode3dplot(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr


	variable/G sel_L_3dplot
	sel_L_3dplot = popNum

	string/G mat3dn_cons
	string slicename = "Zslice_"+mat3dn_cons

	string/G mat3dn_cons //= mat3dn
	variable/G zn_cons//the Energy in which dimension?
	//** Auto ordering layer index
		variable zn =zn_cons
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
	string ZoutI

	if (sel_L_3dplot == 1) //Two Points Mode
		//Cursor/W=$winname(0,1)/P/I/C=(1,65535,33232)/T=6 A $tpw() 0,0
		//Cursor/W=$winname(0,1)/P/I/C=(0,65535,65535)/T=6 B $tpw() round(dimsize($tpw(),0)/2),round(dimsize($tpw(),1)/2)
		//SetWindow $winname(0,1) hook(myHook)=myCursorMovedHook3Dfdn
			Cursor/W=$grabwin(slicename)/P/I/C=(1,65535,33232)/T=6 A $slicename 0,0
			Cursor/W=$grabwin(slicename)/P/I/C=(0,65535,65535)/T=6 B $slicename round(dimsize($slicename,0)/2),round(dimsize($slicename,1)/2)
			SetWindow $grabwin(slicename) hook(myHook)=myCursorMovedHook3Dfdn

		//ZoutI = "ZoutI_"+mat3dn_cons
			ZoutI = "LH_"+mat3dn_cons
			Dowindow/F $grabwin(slicename)
		make/N =(dimsize($mat3dn_cons,zn),(abs(pcsr(B)-pcsr(A))+1))/o $ZoutI
		wave ZoutIw = $ZoutI
		ZoutIw = nan
		//di(ZoutIw)
		//Modifygraph width=250, height=450
		//tilewindows/WINS=grabwin(ZoutI)/R/w=(73,0,100,50)/A=(1,1)
	endif

	if (sel_L_3dplot == 2) //Free Hand Mode
		//Cursor/W=$winname(0,1)/P/I/C=(1,65535,33232)/T=6 A $tpw() 0,0
		//SetWindow $winname(0,1) hook(myHook)=myCursorMovedHook3Dfreehand
			Cursor/W=$grabwin(slicename)/P/I/C=(1,65535,33232)/T=6 A $slicename 0,0
			SetWindow $grabwin(slicename) hook(myHook)=myCursorMovedHook3Dfreehand

		//ZoutI = "ZoutI_"+mat3dn_cons
			ZoutI = "LH_"+mat3dn_cons
			Dowindow/F $grabwin(slicename)
		make/N =(dimsize($mat3dn_cons,zn),(abs(pcsr(B)-pcsr(A))+1))/o $ZoutI
		wave ZoutIw = $ZoutI
		ZoutIw = nan
		//di(ZoutIw)
		//Modifygraph width=250, height=450
		//tilewindows/WINS=grabwin(ZoutI)/R/w=(73,0,100,50)/A=(1,1)
		//** Error message, no stop but Continuing execution
		String msg
		Variable err
		msg=GetErrMessage(GetRTError(0),3);
		err=GetRTError(1)
		if (err != 0)
			//Print "Error in Demo: " + msg
			//Print "Continuing execution"
		endif
	endif

	if (sel_L_3dplot == 3) //Circle Mode
		//Cursor/W=$winname(0,1)/P/I/C=(1,65535,33232)/T=6 A $tpw() 0,round(dimsize($tpw(),1)/2)
		//Cursor/W=$winname(0,1)/P/I/C=(0,65535,65535)/T=6 B $tpw() round(dimsize($tpw(),0)/2),round(dimsize($tpw(),1)/2)
		//SetWindow $winname(0,1) hook(myHook)=myCursorMovedHook3Dcc
			Cursor/W=$grabwin(slicename)/P/I/C=(1,65535,33232)/T=6 A $slicename 0,round(dimsize($slicename,1)/2)
			Cursor/W=$grabwin(slicename)/P/I/C=(0,65535,65535)/T=6 B $slicename round(dimsize($slicename,0)/2),round(dimsize($slicename,1)/2)
			SetWindow $grabwin(slicename) hook(myHook)=myCursorMovedHook3Dcc

		//ZoutI = "ZoutI_"+mat3dn_cons
			ZoutI = "LH_"+mat3dn_cons
			Dowindow/F $grabwin(slicename)
		make/N =(dimsize($mat3dn_cons,zn),(abs(pcsr(B)-pcsr(A))+1))/o $ZoutI
		wave ZoutIw = $ZoutI
		ZoutIw = nan
		//di(ZoutIw)
		//Modifygraph width=250, height=450
		//tilewindows/WINS=grabwin(ZoutI)/R/w=(73,0,100,50)/A=(1,1)

	endif

end

//#2 Update freehand modes
Function ButtonProc_L3dplotdo(ctrlName) : ButtonControl
	String ctrlName
	Variable/G sel_L_3dplot

	makefreehandwave_3dplot()
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

////////////////////////////////////////////////////////////////////
//#3** (1): Two Points Method

//#3_01 Cursor Hook
Function myCursorMovedHook3Dfdn(s)
	STRUCT WMWinHookStruct &s
	Variable statusCode= 0
	strswitch( s.eventName )
		case "cursormoved":
			twopgetline3d()
			UpdateControls_3dp(s.traceName, s.cursorName, s.pointNumber, s.yPointNumber)
			break
	endswitch
	return statusCode
End

//#3_02 Hook Called: Extract Line profile from two points
//		{Note: this function will be called every time cursor moves}
FUnction twopgetline3d()
	variable dx = abs(pcsr(A) - pcsr(B))
	variable dy = abs(qcsr(A) - qcsr(B))
	if (dx > dy)
		twopgetline3dx()
	else
		twopgetline3dy()
	endif


	//** Normalization
		variable/G normornot_3dplot
		string/G mat3dn_cons
		string ZoutI = "LH_"+mat3dn_cons
		if (normornot_3dplot == 1)
			Normalinecut($ZoutI)
		endif

	variable/G FTy_3dplot
	variable/G Ftysigma_3dplot
	variable/G Ftysigma2_3dplot

	string linecutH = "LH_"+mat3dn_cons
	string linecutV = "LV_"+mat3dn_cons
	string FTy_linecutH = linecutH+ "_FTyM"
	string FTy_linecutV = linecutV+ "_FTyM"

	if (FTy_3dplot == 1)
		FFTL2_3dplot($linecutH)
		color3s_subfor3dFFT($FTy_linecutH,Ftysigma_3dplot)
		FFTL2_3dplot($linecutV)
		color3s_subfor3dFFT($FTy_linecutV,Ftysigma2_3dplot)
	endif
end

Function twopgetline3dx()
	variable k,b
	// define the line parameters
	k = (qcsr(A)-qcsr(B))/(pcsr(A)-pcsr(B))
	b = qcsr(A) - k*pcsr(A)


	string/G mat3dn_cons //= mat3dn
	variable/G zn_cons//the Energy in which dimension?
	//** Auto ordering layer index
		variable zn = zn_cons
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

	wave tpww = $mat3dn_cons
	//string ZoutI = "ZoutI_"+mat3dn_cons
	 string ZoutI = "LH_"+mat3dn_cons

	make/N =(dimsize($mat3dn_cons,zn),(abs(pcsr(B)-pcsr(A))+1))/o $ZoutI
	wave ZoutIw = $ZoutI

	variable i , yy, signw,signwq
	signw = pcsr(A) - pcsr(B)
	signwq=qcsr(A) - qcsr(B)
	variable xx1 = dimoffset(tpww,0)+dimdelta(tpww,0)*pcsr(A)
	variable xx2 = dimoffset(tpww,0)+dimdelta(tpww,0)*pcsr(B)
	variable yy1 = dimoffset(tpww,1)+dimdelta(tpww,1)*qcsr(A)
	variable yy2 = dimoffset(tpww,1)+dimdelta(tpww,1)*qcsr(B)
	variable len = sqrt((xx1-xx2)^2+(yy1-yy2)^2)

	//Make Z wave follow the two-point line
	i = pcsr(A)
	if (signw < 0)
		do
			yy = round(k*i+b)

			if(zn_cons == 0)
				ZoutIw[][i-pcsr(A)] = tpww[p][i][yy]
			endif
			if(zn_cons == 1)
				ZoutIw[][i-pcsr(A)] = tpww[i][p][yy]
			endif
			if(zn_cons == 2)
				ZoutIw[][i-pcsr(A)] = tpww[i][yy][p]
			endif

			//ZoutIw[i-pcsr(A)] = tpww[i][yy]
			i+=1
		while(i< pcsr(B)+1)
	endif

	variable j =pcsr(A)
	if (signw > 0)
		do
			yy = round(k*i+b)

			if(zn_cons == 0)
				ZoutIw[][j-pcsr(A)] = tpww[p][i][yy]
			endif
			if(zn_cons == 1)
				ZoutIw[][j-pcsr(A)] = tpww[i][p][yy]
			endif
			if(zn_cons == 2)
				ZoutIw[][j-pcsr(A)] = tpww[i][yy][p]
			endif

			//ZoutIw[j-pcsr(A)] = tpww[i][yy]
			j+=1
			i-=1
		while(i > pcsr(B)-1)
	endif

	if (signw == 0)
		i = qcsr(A)
		if (signwq < 0)
		do
			yy = round((i-b)/k)
			//ZoutIw[i-qcsr(A)] = tpww[yy][i]
			if(zn_cons == 0)
				ZoutIw[][i-qcsr(A)] = tpww[p][yy][i]
			endif
			if(zn_cons == 1)
				ZoutIw[][i-qcsr(A)] = tpww[yy][p][i]
			endif
			if(zn_cons == 2)
				ZoutIw[][i-qcsr(A)] = tpww[yy][i][p]
			endif
			i+=1
		while(i< qcsr(B)+1)
		endif

		j =qcsr(A)
		if (signwq > 0)
		do
			yy = round((i-b)/k)

			if(zn_cons == 0)
				ZoutIw[][i-qcsr(A)] = tpww[p][yy][i]
			endif
			if(zn_cons == 1)
				ZoutIw[][i-qcsr(A)] = tpww[yy][p][i]
			endif
			if(zn_cons == 2)
				ZoutIw[][i-qcsr(A)] = tpww[yy][i][p]
			endif

			//ZoutIw[j-qcsr(A)] = tpww[yy][i]
			j+=1
			i-=1
		while(i > qcsr(B)-1)
		endif
	endif
	setscale/I y,0,len, "",ZoutIw
	setscale/p x,dimoffset($mat3dn_cons,zn),dimdelta($mat3dn_cons,zn), "",ZoutIw



	//Make the X&Y wave for indication
	string xwaveout = "Xout_"+mat3dn_cons
	string ywaveout = "Yout_"+mat3dn_cons
	make/N=2/O $ywaveout
	make/N=2/O $Xwaveout
	wave xwaveoutw = $xwaveout
	wave ywaveoutw = $ywaveout
	ywaveoutw[0]=yy1
	ywaveoutw[1]=yy2
	xwaveoutw={xx1,xx2}

	//Append indicative Ywave vs Xwave if it is not on graph
	string slicename = "Zslice_"+mat3dn_cons
	checkDisplayed ywaveoutw
	if(V_flag == 0)
		appendtograph/W=$grabwinnonew(slicename) ywaveoutw vs Xwaveoutw
		ModifyGraph/W=$grabwinnonew(slicename) lsize($ywaveout)=1,rgb($ywaveout)=(3690,43690,43690),mode($ywaveout)=4	,lstyle($ywaveout)=7, mrkThick($ywaveout)=2,useMrkStrokeRGB($ywaveout)=1,mrkStrokeRGB($ywaveout)=(1,52428,26586),msize($ywaveout)=1
	else
	endif

	TextBox/W=$grabwinchild(ZoutI)/C/N=text0/F=0/A=LT/X=0.00/Y=0.00 "Two Points Mode"

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

Function twopgetline3dy()
	variable k,b
	// define the line parameters
	k = (pcsr(A)-pcsr(B))/(qcsr(A)-qcsr(B))
	b = pcsr(A) - k*qcsr(A)


	string/G mat3dn_cons //= mat3dn
	variable/G zn_cons//the Energy in which dimension?
	//** Auto ordering layer index
		variable zn = zn_cons
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

	wave tpww = $mat3dn_cons
	//string ZoutI = "ZoutI_"+mat3dn_cons
	string ZoutI = "LH_"+mat3dn_cons
	make/N =(dimsize($mat3dn_cons,zn),(abs(qcsr(B)-qcsr(A))+1))/o $ZoutI
	wave ZoutIw = $ZoutI

	variable i , yy, signw,signwq
	signw = qcsr(A) - qcsr(B)
	signwq=pcsr(A) - pcsr(B)
	variable xx1 = dimoffset(tpww,1)+dimdelta(tpww,1)*qcsr(A)
	variable xx2 = dimoffset(tpww,1)+dimdelta(tpww,1)*qcsr(B)
	variable yy1 = dimoffset(tpww,0)+dimdelta(tpww,0)*pcsr(A)
	variable yy2 = dimoffset(tpww,0)+dimdelta(tpww,0)*pcsr(B)
	variable len = sqrt((xx1-xx2)^2+(yy1-yy2)^2)

	//Make Z wave follow the two-point line
	i = qcsr(A)
	if (signw < 0)
		do
			yy = round(k*i+b)

			if(zn_cons == 0)
				ZoutIw[][i-qcsr(A)] = tpww[p][yy][i]
			endif
			if(zn_cons == 1)
				ZoutIw[][i-qcsr(A)] = tpww[yy][p][i]
			endif
			if(zn_cons == 2)
				ZoutIw[][i-qcsr(A)] = tpww[yy][i][p]
			endif

			//ZoutIw[i-pcsr(A)] = tpww[i][yy]
			i+=1
		while(i< qcsr(B)+1)
	endif

	variable j =qcsr(A)
	if (signw > 0)
		do
			yy = round(k*i+b)

			if(zn_cons == 0)
				ZoutIw[][j-qcsr(A)] = tpww[p][yy][i]
			endif
			if(zn_cons == 1)
				ZoutIw[][j-qcsr(A)] = tpww[yy][p][i]
			endif
			if(zn_cons == 2)
				ZoutIw[][j-qcsr(A)] = tpww[yy][i][p]
			endif

			//ZoutIw[j-pcsr(A)] = tpww[i][yy]
			j+=1
			i-=1
		while(i > qcsr(B)-1)
	endif

	if (signw == 0)
		i = pcsr(A)
		if (signwq < 0)
		do
			yy = round((i-b)/k)
			//ZoutIw[i-pcsr(A)] = tpww[i][yy]
			if(zn_cons == 0)
				ZoutIw[][i-pcsr(A)] = tpww[p][i][yy]
			endif
			if(zn_cons == 1)
				ZoutIw[][i-pcsr(A)] = tpww[i][p][yy]
			endif
			if(zn_cons == 2)
				ZoutIw[][i-pcsr(A)] = tpww[i][yy][p]
			endif
			i+=1
		while(i< pcsr(B)+1)
		endif

		j =pcsr(A)
		if (signwq > 0)
		do
			yy = round((i-b)/k)

			if(zn_cons == 0)
				ZoutIw[][i-pcsr(A)] = tpww[p][i][yy]
			endif
			if(zn_cons == 1)
				ZoutIw[][i-pcsr(A)] = tpww[i][p][yy]
			endif
			if(zn_cons == 2)
				ZoutIw[][i-pcsr(A)] = tpww[i][yy][p]
			endif

			//ZoutIw[j-qcsr(A)] = tpww[yy][i]
			j+=1
			i-=1
		while(i > pcsr(B)-1)
		endif
	endif
	setscale/I y,0,len, "",ZoutIw
	setscale/p x,dimoffset($mat3dn_cons,zn),dimdelta($mat3dn_cons,zn), "",ZoutIw



	//Make the X&Y wave for indication
	string xwaveout = "Xout_"+mat3dn_cons
	string ywaveout = "Yout_"+mat3dn_cons
	make/N=2/O $ywaveout
	make/N=2/O $Xwaveout
	wave xwaveoutw = $xwaveout
	wave ywaveoutw = $ywaveout
	ywaveoutw[0]=xx1
	ywaveoutw[1]=xx2
	xwaveoutw={yy1,yy2}

	//Append indicative Ywave vs Xwave if it is not on graph
	string slicename = "Zslice_"+mat3dn_cons
	checkDisplayed ywaveoutw
	if(V_flag == 0)
		appendtograph/W=$grabwinnonew(slicename) ywaveoutw vs Xwaveoutw
		ModifyGraph/W=$grabwinnonew(slicename) lsize($ywaveout)=1,rgb($ywaveout)=(3690,43690,43690),mode($ywaveout)=4	,lstyle($ywaveout)=7, mrkThick($ywaveout)=2,useMrkStrokeRGB($ywaveout)=1,mrkStrokeRGB($ywaveout)=(1,52428,26586),msize($ywaveout)=1
	else
	endif

	TextBox/W=$grabwinchild(ZoutI)/C/N=text0/F=0/A=LT/X=0.00/Y=0.00 "Two Points Mode"

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
////////////////////////////////////////////////////////////////////
//#3** (2): Free hand Mode

//#3_03 Cursor Hook
Function myCursorMovedHook3Dfreehand(s)
	STRUCT WMWinHookStruct &s
	Variable statusCode= 0
	strswitch( s.eventName )
		case "cursormoved":
			// see "Members of WMWinHookStruct Used with cursormoved Code"
			//UpdateControls_2df(s.traceName, s.cursorName, s.pointNumber, s.yPointNumber)
			UpdateControls_3df(s.traceName, s.cursorName, s.pointNumber, s.yPointNumber)
			UpdateControls_3dp(s.traceName, s.cursorName, s.pointNumber, s.yPointNumber)

			break
	endswitch
	return statusCode
End

//#3_04 Extract line profile by free hand draw
//		{Note: this function will be called every time cursor moves}
Function UpdateControls_3df(traceName, cursorName, pointNumber, yPointNumber)
	String traceName, cursorName
	Variable pointNumber,yPointNumber


	string/G mat3dn_cons //= mat3dn
	variable/G zn_cons//the Energy in which dimension?

	//** Auto ordering layer index
		variable zn = zn_cons
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

	wave tpww = $mat3dn_cons
	//pointNumber = pcsr(A)
	//ypointNumber = qcsr(A)

	//**Initialize indicative X&Y wave and [temporary profile Z wave]
	string xwaveout = "Xout_"+mat3dn_cons
	string ywaveout = "Yout_"+mat3dn_cons
	string zwave = "Zwave_"+mat3dn_cons
	if (waveexists($xwaveout) == 1)
	else
		make/n=(0)/o $xwaveout
		wave xwaveoutw = $xwaveout
	endif
	if (waveexists($ywaveout) == 1)
	else
		make/n=(0)/o $ywaveout
		wave ywaveoutw = $ywaveout
	endif
	if (waveexists($zwave) == 1)
	else
		make/n=(dimsize($mat3dn_cons,zn),1)/o $zwave
		wave zwavew = $zwave
		setscale/p x,dimoffset($mat3dn_cons,zn),dimdelta($mat3dn_cons,zn),"",zwavew
	endif

	wave zwavew = $zwave
	wave xwaveoutw = $xwaveout
	wave ywaveoutw = $ywaveout

	InsertPoints dimsize(xwaveoutw,0),1, xwaveoutw
	xwaveoutw[dimsize(xwaveoutw,0)-1]= dimoffset(tpww,0)+dimdelta(tpww,0)*pointNumber

	InsertPoints dimsize(ywaveoutw,0),1, ywaveoutw
	ywaveoutw[dimsize(ywaveoutw,0)-1]= dimoffset(tpww,1)+dimdelta(tpww,1)*ypointNumber

	if(dimsize(xwaveoutw,0) == 1)
	else
		InsertPoints/M=1 dimsize(zwavew,1),1, zwavew
	endif

	//make/N=(dimsize($mat3dn_cons,zn))/O test

	if(zn_cons == 0)
		zwavew[][dimsize(zwavew,1)-1]= tpww[p][pointNumber][ypointNumber]
	endif
	if(zn_cons == 1)
		zwavew[][dimsize(zwavew,1)-1]= tpww[pointNumber][p][ypointNumber]
	endif
	if(zn_cons == 2)
		zwavew[][dimsize(zwavew,1)-1]= tpww[pointNumber][ypointNumber][p]

		//test = tpww[pointNumber][ypointNumber][p]
		//zwavew[][dimsize(zwavew,0)-1]=test[p]
	endif
	//zwavew[dimsize(zwavew,0)-1]= tpww[pointNumber][ypointNumber]


	//**Checking auxiliary indicative wave defined in the "Go function" below
	string xwaveout2 = "Xout2_"+mat3dn_cons
	string ywaveout2 = "Yout2_"+mat3dn_cons
	checkDisplayed $ywaveout2
	if(V_flag == 0)
	else
		RemoveFromGraph $ywaveout2
	endif
		//## {Note} X&Ywave2 are introduced for defining the start curor hood of a new free hand draw
		//## {Note} See details in the Go function.

	//**Append Indicative X&Y wave if it is not on the graph
	string slicename = "Zslice_"+mat3dn_cons
	checkDisplayed ywaveoutw
	if(V_flag == 0)
		appendtograph/W=$grabwinnonew(slicename) ywaveoutw vs Xwaveoutw
		ModifyGraph/W=$grabwinnonew(slicename) lsize($ywaveout)=1,rgb($ywaveout)=(3690,43690,43690),mode($ywaveout)=4	,lstyle($ywaveout)=7, mrkThick($ywaveout)=2,useMrkStrokeRGB($ywaveout)=1,mrkStrokeRGB($ywaveout)=(1,52428,26586),msize($ywaveout)=1
	else
	endif



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

//#3_05 GO Function
//		{Note: this function Define the end of the free hand draw and set the next cursor hook call belong to new lineprofile}
Function makefreehandwave_3dplot()
	string/G mat3dn_cons //= mat3dn
	variable/G zn_cons//the Energy in which dimension?

	//** Auto ordering layer index
		variable zn = zn_cons
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

	wave tpww = $mat3dn_cons

	//** Create scattered Z wave from temporary Z wave]
	string zwave = "Zwave_"+mat3dn_cons
	wave zwavew = $zwave
	string zwaveout = "Zout_"+mat3dn_cons
	string xwaveout = "Xout_"+mat3dn_cons
	string ywaveout = "Yout_"+mat3dn_cons
	wave xwaveoutw = $xwaveout
	wave ywaveoutw = $ywaveout
	duplicate/O zwavew $zwaveout
	wave zwaveoutw = $zwaveout
	killwaves zwavew

	//** Calculate the trajectory distance of the free-hand-draw trace
	string trajdis = "trajdis_"+mat3dn_cons
	make/N=(dimsize($zwaveout,1))/o $trajdis
	wave trajdisw = $trajdis
	trajdisw[0] = 0

	//**calculate trajectory distance
		variable i,delta
		i = 1
		do
			delta = sqrt((xwaveoutw[i]-xwaveoutw[i-1])^2+(ywaveoutw[i]-ywaveoutw[i-1])^2)
			trajdisw[i] = delta+trajdisw[i-1]
			i+=1
		while (i< dimsize($zwaveout,1))


	//**From scattered Z wave and trajectory wave to make waveform Z wave
		//Interpolate2/T=1/N=(2*dimsize(Xwaveoutw,0))/E=2/Y=$ZoutI trajdisw, zwaveoutw
		//string ZoutI = "ZoutI_"+mat3dn_cons
			string ZoutI = "LH_"+mat3dn_cons
		func_NaN0(zwaveoutw)
		rescalemapasa1dcurveF(zwaveout,trajdis,5*dimsize(zwaveoutw,1))
		linkEDCs_nodis(zwaveout,trajdis,5*dimsize(zwaveoutw,1))
		killEDCs(zwaveout)
		string mapcorrect = "mapcorrect"
		wave mapcorrectw = $mapcorrect
		func_zeroNaN(mapcorrectw)
		duplicate/o mapcorrectw $ZoutI
		wave ZoutIw = $ZoutI
		killwaves mapcorrectw, zwaveoutw

			//duplicate/o zwaveoutw $ZoutI
			//killwaves zwaveoutw

	//**Create auxiliary indicative X&Ywave2
	string xwaveout2 = "Xout2_"+mat3dn_cons
	string ywaveout2 = "Yout2_"+mat3dn_cons
	duplicate/o xwaveoutw $xwaveout2
	duplicate/o ywaveoutw $ywaveout2
	wave xwaveout2w = $xwaveout2
	wave ywaveout2w = $ywaveout2
		//** {Note} In order to define new start of the indicative X&Ywave for a free hand drawing, it is important to
		//** {Note} set X&Y wave dimsize to be zero at this Go function, so that it cause a problem that after click the
		//** {Note} "Go" button, the current free hand draw is generated but the indicative lines disappear. In order to
		//** {Note} solve this problem, we introduced this auxiliary X&Ywave2 that before set the dimsize of XYwave to zero
		//** {Note} we transfer the information to the auxiliarys, remove the X&Ywave and append the X&Ywave2 with same format
		//** {Note} These auxiliarys will be remove and X&Ywave will be appended again when Cursor Hook runs in the next free hand draw.

	//**Remove indicative X&Ywave preparing for redefine the new start.
	string slicename = "Zslice_"+mat3dn_cons

	RemoveFromGraph/W=$grabwinnonew(slicename) $ywaveout

	//**Append auxiliary indicative X&Ywave2
	checkDisplayed ywaveout2w
	if(V_flag == 0)
		appendtograph/W=$grabwinnonew(slicename) ywaveout2w vs Xwaveout2w
		ModifyGraph/W=$grabwinnonew(slicename) lsize($ywaveout2)=1,rgb($ywaveout2)=(3690,43690,43690),mode($ywaveout2)=4,lstyle($ywaveout2)=7, mrkThick($ywaveout2)=2,useMrkStrokeRGB($ywaveout2)=1,mrkStrokeRGB($ywaveout2)=(1,52428,26586),msize($ywaveout2)=1
	else
	endif

	//**Reinitial the X&Ywave for the next free hand drawing
	deletePoints 0,dimsize($xwaveout,0), xwaveoutw
	deletePoints 0,dimsize($ywaveout,0), ywaveoutw
	TextBox/W=$grabwinchild(ZoutI)/C/N=text0/F=0/A=LT/X=0.00/Y=0.00 "Free Hand Mode"

	//** Normalization
		variable/G normornot_3dplot
		//string/G mat3dn_cons
		//string ZoutI = "LH_"+mat3dn_cons
		if (normornot_3dplot == 1)
			Normalinecut($ZoutI)
		endif

	variable/G FTy_3dplot
	variable/G Ftysigma_3dplot
	variable/G Ftysigma2_3dplot

	string linecutH = "LH_"+mat3dn_cons
	string linecutV = "LV_"+mat3dn_cons
	string FTy_linecutH = linecutH+ "_FTyM"
	string FTy_linecutV = linecutV+ "_FTyM"

	if (FTy_3dplot == 1)
		FFTL2_3dplot($linecutH)
		color3s_subfor3dFFT($FTy_linecutH,Ftysigma_3dplot)
		FFTL2_3dplot($linecutV)
		color3s_subfor3dFFT($FTy_linecutV,Ftysigma2_3dplot)
	endif
end

//#3_05_02 GO Function Called Interpolation fucntion
Function linkEDCs_nodis(namemap,namecurve,factor)
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
	//display;appendimage mapcorrect
	//ModifyImage mapcorrect ctab= {*,*,VioletOrangeYellow,0}
end

////////////////////////////////////////////////////////////////////
//#3** (3): Circular Mode

//#3_06 Cursor Hook
Function myCursorMovedHook3Dcc(s)
	STRUCT WMWinHookStruct &s
	Variable statusCode= 0
	strswitch( s.eventName )
		case "cursormoved":
			Lineprofilefromcircle3d()
			UpdateControls_3dp(s.traceName, s.cursorName, s.pointNumber, s.yPointNumber)
			break
	endswitch
	return statusCode
End

//#3_07 Extract line profile by Circular Mode
//		{Note: this function will be called every time cursor moves}
Function Lineprofilefromcircle3d()

	string/G mat3dn_cons //= mat3dn
	variable/G zn_cons//the Energy in which dimension?

	//** Auto ordering layer index
		variable zn = zn_cons
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

	//**Define the Origin
	variable Ox = pcsr(B)
	variable Oy = qcsr(B)

	//**Define the radium
	variable ax = pcsr(A)
	variable ay = qcsr(A)
	variable rr = round(sqrt((ox-ax)^2+(oy-ay)^2))

	//**Define the circular trace
	variable xx, yy
		//(xx-ox)^2+(yy-oy)^2 = rr^2
		//yy = +-sqrt(rr^2 - (xx-ox)^2)+oy

	//**Define the  leftP (polar pi) and rightP (Polar 0)
	variable leftP,rightP
	leftP = round(ox - rr)
	rightP = round(ox +rr)

	//**Create Z wave
	//string ZoutI = "ZoutI_"+mat3dn_cons
		string ZoutI = "LH_"+mat3dn_cons

	variable num = abs(rightP-leftP)+1+(abs(rightP-leftP)+1-1)
	make/N=(dimsize($mat3dn_cons,zn),num)/o $ZoutI
	wave ZoutIw =$ZoutI
	setscale/I y 0,2*pi,"",ZoutIw
	setscale/p x,dimoffset($mat3dn_cons,zn),dimdelta($mat3dn_cons,zn),"",ZoutIw
	ZoutIw=nan

	//**Create Indicative X&Y wave
	string xwaveout = "Xout_"+mat3dn_cons
	string ywaveout = "Yout_"+mat3dn_cons
	make/N=(num)/O $ywaveout
	make/N=(num)/O $Xwaveout
	wave xwaveoutw = $xwaveout
	wave ywaveoutw = $ywaveout

	//**Build Z wave and X&Ywave [Upper half circle (counter-clockwise)]
	string slicename = "Zslice_"+mat3dn_cons

	wave tpww = $mat3dn_cons
	variable i, qq,j
	i=rightp
	j=0
	do
		xx = i
		yy = sqrt(rr^2 - (xx-ox)^2)+oy
		qq = round(yy)
		if (qq >=0 && qq <dimsize($slicename,1))
			if(i>=0 && i <dimsize($slicename,0))
				//ZoutIw[j] = tpww[i][qq]
				if(zn_cons == 0)
					ZoutIw[][j] = tpww[p][i][qq]
				endif
				if(zn_cons == 1)
					ZoutIw[][j] = tpww[i][p][qq]
				endif
				if(zn_cons == 2)
					ZoutIw[][j] = tpww[i][qq][p]
				endif

			else
			endif
		else

			//if(j == rightp)
			//elseif (j == leftp)
			//else
			//	ZoutIw[][j] = nan
			//endif

		endif
		xwaveoutw[j] = dimoffset($slicename,0)+xx*dimdelta($slicename,0)
		ywaveoutw[j] = dimoffset($slicename,1)+qq*dimdelta($slicename,1)
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
		if (qq >=0 && qq <dimsize($slicename,1))
			if(i>=0 && i <dimsize($slicename,0))
				//ZoutIw[abs(rightP-leftP)+1+j] = tpww[i][qq]
				if(zn_cons == 0)
					ZoutIw[][abs(rightP-leftP)+1+j] = tpww[p][i][qq]
				endif
				if(zn_cons == 1)
					ZoutIw[][abs(rightP-leftP)+1+j] = tpww[i][p][qq]
				endif
				if(zn_cons == 2)
					ZoutIw[][abs(rightP-leftP)+1+j] = tpww[i][qq][p]
				endif

				else
			endif
		else

			//if(j == rightp)
			//elseif (j == leftp)
			//else
			//	ZoutIw[][abs(rightP-leftP)+1+j] = nan
			//endif

		endif
		xwaveoutw[abs(rightP-leftP)+1+j] = dimoffset($slicename,0)+xx*dimdelta($slicename,0)
		ywaveoutw[abs(rightP-leftP)+1+j] = dimoffset($slicename,1)+qq*dimdelta($slicename,1)
		j+=1
		i+=1
	while (i < rightp+1)
	ZoutIw[][dimsize(ZoutIw,0)-1] = ZoutIw[p][0]

	//**Append Indicative X&Ywaves
	checkDisplayed ywaveoutw
	if(V_flag == 0)
		appendtograph/W=$grabwin(slicename) ywaveoutw vs Xwaveoutw
		ModifyGraph/W=$grabwin(slicename) lsize($ywaveout)=1,rgb($ywaveout)=(3690,43690,43690),mode($ywaveout)=4	,lstyle($ywaveout)=7, mrkThick($ywaveout)=2,useMrkStrokeRGB($ywaveout)=1,mrkStrokeRGB($ywaveout)=(1,52428,26586),msize($ywaveout)=1
	else
	endif
	TextBox/W=$grabwinchild(ZoutI)/C/N=text0/F=0/A=LT/X=0.00/Y=0.00 "Circular Mode"


	//** Normalization
		variable/G normornot_3dplot
		//string/G mat3dn_cons
		//string ZoutI = "LH_"+mat3dn_cons
		if (normornot_3dplot == 1)
			Normalinecut($ZoutI)
		endif

	variable/G FTy_3dplot
	variable/G Ftysigma_3dplot
	variable/G Ftysigma2_3dplot

	string linecutH = "LH_"+mat3dn_cons
	string linecutV = "LV_"+mat3dn_cons
	string FTy_linecutH = linecutH+ "_FTyM"
	string FTy_linecutV = linecutV+ "_FTyM"

	if (FTy_3dplot == 1)
		FFTL2_3dplot($linecutH)
		color3s_subfor3dFFT($FTy_linecutH,Ftysigma_3dplot)
		FFTL2_3dplot($linecutV)
		color3s_subfor3dFFT($FTy_linecutV,Ftysigma2_3dplot)
	endif

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

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** {{{{{{{{{{ Multimap Function }}}}}}}}}}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//#1 Control Function
Function ButtonProc_Cons3dplotmulti(ctrlName) : ButtonControl
	String ctrlName
	string/G mat3dn_cons
	variable/G zn_cons
	variable/G z_cons

	variable Z_constp=(z_cons-dimoffset($mat3dn_cons,zn_cons))/dimdelta($mat3dn_cons,zn_cons)

	//variable/G multimap_3dplot
	//** Auto ordering layer index
		make/o/N=3 ordernum ={0,1,2}
		ordernum=abs(ordernum-zn_cons)
		wavestats/Q ordernum
		ordernum={0,1,2}
		DeletePoints V_minloc,1, ordernum
		wavestats/Q ordernum
		variable xn = ordernum[V_minloc]
		variable yn = ordernum[V_maxloc]
		killwaves ordernum

	string barename = replaceString("_G",mat3dn_cons,"")
	String bare3d

	//** g(r,V)
		bare3d = mat3dn_cons
		string sliceg = "Zslice_"+bare3d
		make/o/N=(dimsize($bare3d,xn),dimsize($bare3d,yn)) $sliceg
		setscale/p x,dimoffset($bare3d,xn),dimdelta($bare3d,xn),"",$sliceg
		setscale/p y,dimoffset($bare3d,yn),dimdelta($bare3d,yn),"",$sliceg
		wave slicegw = $sliceg
		wave bare3dw = $bare3d
		if(zn_cons == 0)
			slicegw[][]=bare3dw[Z_constp][p][q]
		endif
		if(zn_cons == 1)
			slicegw[][]=bare3dw[p][Z_constp][q]
		endif
		if(zn_cons == 2)
			slicegw[][]=bare3dw[p][q][Z_constp]
		endif
		f_for3dmulti($sliceg)
		String FFTg = sliceg+"_FFT"+"_Modula"

	//** T(r,V)
		string sliceT = barename+"_T"
		levelimage2($sliceT,10)
		f_for3dmulti($sliceT)
		String FFTT = sliceT+"_FFT"+"_Modula"

	//** I(r,V)
		bare3d = barename+"_I"
		string sliceI = "Zslice_"+bare3d
		make/o/N=(dimsize($bare3d,xn),dimsize($bare3d,yn)) $sliceI
		setscale/p x,dimoffset($bare3d,xn),dimdelta($bare3d,xn),"",$sliceI
		setscale/p y,dimoffset($bare3d,yn),dimdelta($bare3d,yn),"",$sliceI
		wave sliceIw = $sliceI
		wave bare3dw = $bare3d
		if(zn_cons == 0)
			sliceIw[][]=bare3dw[Z_constp][p][q]
		endif
		if(zn_cons == 1)
			sliceIw[][]=bare3dw[p][Z_constp][q]
		endif
		if(zn_cons == 2)
			sliceIw[][]=bare3dw[p][q][Z_constp]
		endif
		f_for3dmulti($sliceI)
		String FFTI = sliceI+"_FFT"+"_Modula"

	//** Z(r,V)
		bare3d = mat3dn_cons+"_Z_map"
		string sliceZ = "Zslice_"+bare3d
		make/o/N=(dimsize($bare3d,xn),dimsize($bare3d,yn)) $sliceZ
		setscale/p x,dimoffset($bare3d,xn),dimdelta($bare3d,xn),"",$sliceZ
		setscale/p y,dimoffset($bare3d,yn),dimdelta($bare3d,yn),"",$sliceZ
		wave sliceZw = $sliceZ
		wave bare3dw = $bare3d
		if(zn_cons == 0)
			sliceZw[][]=bare3dw[Z_constp][p][q]
		endif
		if(zn_cons == 1)
			sliceZw[][]=bare3dw[p][Z_constp][q]
		endif
		if(zn_cons == 2)
			sliceZw[][]=bare3dw[p][q][Z_constp]
		endif
		f_for3dmulti($sliceZ)
		String FFTZ = sliceZ+"_FFT"+"_Modula"

	//** R(r,V)
		bare3d = mat3dn_cons+"_R_map"
		string sliceR = "Zslice_"+bare3d
		make/o/N=(dimsize($bare3d,xn),dimsize($bare3d,yn)) $sliceR
		setscale/p x,dimoffset($bare3d,xn),dimdelta($bare3d,xn),"",$sliceR
		setscale/p y,dimoffset($bare3d,yn),dimdelta($bare3d,yn),"",$sliceR
		wave sliceRw = $sliceR
		wave bare3dw = $bare3d
		if(zn_cons == 0)
			sliceRw[][]=bare3dw[Z_constp][p][q]
		endif
		if(zn_cons == 1)
			sliceRw[][]=bare3dw[p][Z_constp][q]
		endif
		if(zn_cons == 2)
			sliceRw[][]=bare3dw[p][q][Z_constp]
		endif
		f_for3dmulti($sliceR)
		String FFTR = sliceR+"_FFT"+"_Modula"


	//** Rho(r,V)
		bare3d = mat3dn_cons+"_Rho_map"
		string sliceRho = "Zslice_"+bare3d
		make/o/N=(dimsize($bare3d,xn),dimsize($bare3d,yn)) $sliceRho
		setscale/p x,dimoffset($bare3d,xn),dimdelta($bare3d,xn),"",$sliceRho
		setscale/p y,dimoffset($bare3d,yn),dimdelta($bare3d,yn),"",$sliceRho
		wave sliceRhow = $sliceRho
		wave bare3dw = $bare3d
		if(zn_cons == 0)
			sliceRhow[][]=bare3dw[Z_constp][p][q]
		endif
		if(zn_cons == 1)
			sliceRhow[][]=bare3dw[p][Z_constp][q]
		endif
		if(zn_cons == 2)
			sliceRhow[][]=bare3dw[p][q][Z_constp]
		endif
		f_for3dmulti($sliceRho)
		String FFTRho = sliceRho+"_FFT"+"_Modula"
		//PauseUpdate
	//if (checkmultiopen(12) == 1)
	//else
		Display;modifygraph width=660,height=(4*660/3)

		Display/HOST=#/W=(0,0.05,0.3,0.3);appendimage $sliceg;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_for3dm($sliceg,3)
		setActiveSubwindow ##;Display/HOST=#/W=(0.3,0.05,0.6,0.3);appendimage $sliceT;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_for3dm($sliceT,3)
		setActiveSubwindow ##;Display/HOST=#/W=(0.6,0.05,0.9,0.3);appendimage $sliceI;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_for3dm($sliceI,3)
		setActiveSubwindow ##;Display/HOST=#/W=(0,0.25,0.3,0.5);appendimage $FFTg;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_for3dm($FFTg,30)
		setActiveSubwindow ##;Display/HOST=#/W=(0.3,0.25,0.6,0.5);appendimage $FFTT;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_for3dm($FFTT,30)
		setActiveSubwindow ##;Display/HOST=#/W=(0.6,0.25,0.9,0.5);appendimage $FFTI;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_for3dm($FFTI,30)

		setActiveSubwindow ##;Display/HOST=#/W=(0,0.5,0.3,0.75);appendimage $sliceZ;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_for3dm($sliceZ,3)
		setActiveSubwindow ##;Display/HOST=#/W=(0.3,0.5,0.6,0.75);appendimage $sliceR;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_for3dm($sliceR,3)
		setActiveSubwindow ##;Display/HOST=#/W=(0.6,0.5,0.9,0.75);appendimage $sliceRho;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_for3dm($sliceRho,3)
		setActiveSubwindow ##;Display/HOST=#/W=(0,0.7,0.3,0.95);appendimage $FFTZ;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_for3dm($FFTZ,30)
		setActiveSubwindow ##;Display/HOST=#/W=(0.3,0.7,0.6,0.95);appendimage $FFTR;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_for3dm($FFTR,30)
		setActiveSubwindow ##;Display/HOST=#/W=(0.6,0.7,0.9,0.95);appendimage $FFTRho;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_for3dm($FFTRho,30)
		setActiveSubwindow ##
		//ResumeUpdate
		ckfig_child(winname(0,1))
		TextBox/C/N=text0/F=0/A=MC/X=-29.00/Y=45.00 "\\Z16 g(r,V)"
		TextBox/C/N=text1/F=0/A=MC/X=1.00/Y=45.00 "\\Z16 T(r,V)"
		TextBox/C/N=text2/F=0/A=MC/X=31.00/Y=45.00 "\\Z16 I(r,V)"

		TextBox/C/N=text3/F=0/A=MC/X=-29.00/Y=0 "\\Z16 Z(r,V) = g(r,V)/g(r,-V)"
		TextBox/C/N=text4/F=0/A=MC/X=1.00/Y=0 "\\Z16 R(r,V) = |I(r,V)/I(r,-V)|"
		TextBox/C/N=text5/F=0/A=MC/X=31.00/Y=0 "\\Z16 ρ(r,V) = I(r,V)-I(r,-V) "

		//multimap_3dplot=checkmultiopen()

		tilewindows/WINS=winname(0,1)/R/w=(30,0,60,100)/A=(1,1)
	//endif
end

//#2 FFT by name
Function f_for3dmulti(name)
	wave name
	func_NaN0(name)
	String FFTout
	FFTout = nameofWave(name) + "_FFT"
	FFT/out=1/WINF=Hanning/DEST=$FFTout cvtcmplx(name)
	Complextorealf_for3d($FFTout,1)
end

//#3 Grab chidwindowname of a 2D wave
Function/s grabwinchild(name)
	string name
 	string fulllist = WinList("*", ";","WIN:1")
	string nn,waveong,cmdn,out,childchild
	out = ""
	variable i,j
	for(i=0; i<itemsinlist(fulllist); i +=1)
        nn= stringfromlist(i, fulllist)
        if(itemsInList(childWindowList(nn)) == 0)
        else
        	j=0
        	do
        		childchild = stringfromlist(j,childWindowList(nn))
        		cmdn="WIN:"+nn+"#"+childchild
        		//print cmdn
        		waveong = stringfromlist(0,WaveList("*", ";",cmdn))  //Only detect the first element.
        		if (CmpStr(name,waveong) == 0)
        			out = nn+"#"+childchild
        		else
        		endif

        	j+=1
        	while(j < itemsInList(childWindowList(nn)))

        endif
    endfor
    Return out
end

//#4 Special Color Range for childwindows
Function color3s_for3dm(name,tt)
	wave name
	variable tt
	gethistgram_npcolor(nameofwave(name))
	string W_coef = "W_coef"
	wave W_coefw = $W_coef
	variable sigma = sqrt(2)*W_coefw[3]

	wavestats/Q name
	variable lc,lh
	if (W_coefw[2]-0.5*tt*sigma >V_min)
		lc = W_coefw[2]-0.5*tt*sigma
	else
		lc =V_min
	endif
	if (W_coefw[2]+0.5*tt*sigma < V_max)
		lh = W_coefw[2]+0.5*tt*sigma
	else
		lh =V_max
	endif

	ModifyImage/W=$grabwinchild(nameofwave(name)) $nameofwave(name) ctab= {lc,lh,VioletOrangeYellow,0}
	//PRINT num2str(W_coefw[2]-1.5*sigma)+" "+ num2str(W_coefw[2]+1.5*sigma)
	//print num2str(W_coefw[2])
	//display namehistw
end



//#5 check if there is a window with 12 subwindow
Function checkmultiopen(num)
 	variable num
 	string fulllist = WinList("*", ";","WIN:1")
	string nn
	variable i,j
	variable out
	out = 0
	for(i=0; i<itemsinlist(fulllist); i +=1)
        nn= stringfromlist(i, fulllist)
        //print itemsInList(childWindowList(nn))
        if(itemsInList(childWindowList(nn)) == num)
        out +=1
        endif
    endfor
    Return out
end


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** {{{{{{{{{{ Incoporated Gap Map }}}}}}}}}}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** will only show up button when the 3D matrix put into 3D smart displayer is the g(r,V)
//** the indentification is the name with the ending character "_G", which was defined in
//** the loading procedure.
////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////
//#1 Gap Map Fitting, Control Button
Function ButtonProc_Cons3dplotgapmap(ctrlName) : ButtonControl
	String ctrlName
	execute "gapdisGua2_3dplotsel()"
	//string/G mat3dn_cons
	//variable/G zn_cons
	//variable/G Z_constp
	//string avec = "sgsg_"+mat3dn_cons
	//variable/G multimap_3dplot
	//** Auto ordering layer index
	//	make/o/N=3 ordernum ={0,1,2}
	//	ordernum=abs(ordernum-zn_cons)
	//	wavestats/Q ordernum
	//	ordernum={0,1,2}
	//	DeletePoints V_minloc,1, ordernum
	//	wavestats/Q ordernum
	//	variable xn = ordernum[V_minloc]
	//	variable yn = ordernum[V_maxloc]
	//	killwaves ordernum
	//Cursor/W=$grabwinchild(avec)/P/I/C=(1,65535,33232)/T=6 E $avec 0,0
	//Cursor/W=$grabwinchild(avec)/P/I/C=(1,65535,33232)/T=6 F $avec 0,0
	//Cursor/W=$grabwinchild(avec)/P/I/C=(1,65535,33232)/T=6 G $avec 0,0
	//Cursor/W=$grabwinchild(avec)/P/I/C=(1,65535,33232)/T=6 H $avec 0,0
end

//#2 Gap Map Fitting, select mode and set the indicative lines
Proc gapdisGua2_3dplotsel(sel,name,froml,tol,fromr,tor)
	variable sel = mod_gapfit_3dplot
	string name = mat3dn_cons// Input the name of 3d matrix g(r,V)
	variable froml=l1_gapfit_3dplot
	variable tol=l2_gapfit_3dplot
	variable fromr=r1_gapfit_3dplot
	variable tor=r2_gapfit_3dplot
	prompt sel,"Mode",popup "GCB(±);G(+);;G(-);L(+);L(-)"
	prompt Name,"name of the 3D matrix g(r,V)"
	prompt froml,"Start -Energy value for search"
	prompt tol,"End -Energy value for search"
	prompt fromr,"Start +Energy value for search"
	prompt tor,"End +Energy value for search"

	mod_gapfit_3dplot = sel
	l1_gapfit_3dplot = froml
	l2_gapfit_3dplot = tol
	r1_gapfit_3dplot = fromr
	r2_gapfit_3dplot = tor

	string FITl1 FITl2 FITr1 FITr2
	FITl1="l1_"+mat3dn_cons
	FITl2="l2_"+mat3dn_cons
	FITr2="r2_"+mat3dn_cons
	FITr1="r1_"+mat3dn_cons
	make/N=(2)/o $FITl1,$FITl2,$FITr1,$FITr2
	string avec = "sgsg_"+mat3dn_cons
	wavestats/Q $avec
	setscale/I x,V_min,V_max,"",$FITl1,$FITl2,$FITr1,$FITr2
	$FITl1 = froml
	$FITl2 = tol
	$FITr1 = fromr
	$FITr2 = tor
	//setActiveSubwindow $grabwinchild(avec)
	//setActiveSubwindow ##

	checkDisplayed $FITl1
	if (V_flag == 1)
		RemoveFromGraph/W=$grabwinchild(avec) $FITl1
	endif
	checkDisplayed $FITl2
	if (V_flag == 1)
		RemoveFromGraph/W=$grabwinchild(avec) $FITl2
	endif
	checkDisplayed $FITr1
	if (V_flag == 1)
		RemoveFromGraph/W=$grabwinchild(avec) $FITr1
	endif
	checkDisplayed $FITr2
	if (V_flag == 1)
		RemoveFromGraph/W=$grabwinchild(avec) $FITr2
	endif

	if (sel == 1) //GCB(±)
		appendtograph/W=$grabwinchild(avec)/VERT $FITl1
		appendtograph/W=$grabwinchild(avec)/VERT $FITl2
		appendtograph/W=$grabwinchild(avec)/VERT $FITr1
		appendtograph/W=$grabwinchild(avec)/VERT $FITr2
		ModifyGraph/W=$grabwinchild(avec) lstyle($FITl1)=8,rgb($FITl1)=(52428,52428,52428),lstyle($FITl2)=8,rgb($FITl2)=(52428,52428,52428),lstyle($FITr1)=8,rgb($FITr1)=(52428,52428,52428),lstyle($FITr2)=8,rgb($FITr2)=(52428,52428,52428)
		gapdisGua2_3dplot(name,froml,tol,fromr,tor)
	endif

	if (sel == 2) //G(+)
		appendtograph/W=$grabwinchild(avec)/VERT $FITr1
		appendtograph/W=$grabwinchild(avec)/VERT $FITr2
		ModifyGraph/W=$grabwinchild(avec) lstyle($FITr1)=8,rgb($FITr1)=(52428,52428,52428),lstyle($FITr2)=8,rgb($FITr2)=(52428,52428,52428)
		gapdisGua1_3dplot(name,fromr,tor)
	endif

	if (sel == 3) //G(-)
		appendtograph/W=$grabwinchild(avec)/VERT $FITl1
		appendtograph/W=$grabwinchild(avec)/VERT $FITl2
		ModifyGraph/W=$grabwinchild(avec) lstyle($FITl1)=8,rgb($FITl1)=(52428,52428,52428),lstyle($FITl2)=8,rgb($FITl2)=(52428,52428,52428)
		gapdisGua1_3dplot(name,froml,tol)
	endif

	if (sel == 4)//L(+)
		appendtograph/W=$grabwinchild(avec)/VERT $FITr1
		appendtograph/W=$grabwinchild(avec)/VERT $FITr2
		ModifyGraph/W=$grabwinchild(avec) lstyle($FITr1)=8,rgb($FITr1)=(52428,52428,52428),lstyle($FITr2)=8,rgb($FITr2)=(52428,52428,52428)
		gapdisLinear_3dplot(name,fromr,tor)
	endif

	if (sel == 5)//L(-)
		appendtograph/W=$grabwinchild(avec)/VERT $FITl1
		appendtograph/W=$grabwinchild(avec)/VERT $FITl2
		ModifyGraph/W=$grabwinchild(avec) lstyle($FITl1)=8,rgb($FITl1)=(52428,52428,52428),lstyle($FITl2)=8,rgb($FITl2)=(52428,52428,52428)
		gapdisLinear_3dplot(name,froml,tol)
	endif
end

//#3_01 GCB mode, extract and average the two coherent peaks
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//##### explanations
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

//#3_01_01 GCB mode <spare Button control>
Function ButtonProc_gapdisGua2_3dplot(ctrlName) : ButtonControl
	String ctrlName
	Execute "gapdiisGua2_3dplot()"
end

//#3_01_02 GCB mode <Procedure control layout>
proc gapdisGua2_3dplot(name,froml,tol,fromr,tor)
	string name // Input the name of 3d matrix g(r,V)
	variable froml
	variable tol
	variable fromr
	variable tor

	prompt froml,"Start -Energy value for search"
	prompt tol,"End -Energy value for search"
	prompt fromr,"Start +Energy value for search"
	prompt tor,"End +Energy value for search"
	//PauseUpdate; Silent 1

	variable/G zn_cons
	//** Auto ordering layer index
		variable zn = zn_cons
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

	string gapsize2d = name+"_Gap_map"
	variable sizex=dimsize($name,xn)
	variable sizey=dimsize($name,yn)
	//prompt sizex,"How many points Nx"
	//prompt sizey,"How many points Ny"
	make/o/N=(sizex,sizey) $gapsize2d
	setscale/p x,dimoffset($name,xn),dimdelta($name,xn),"", $gapsize2d
	setscale/p y,dimoffset($name,yn),dimdelta($name,yn),"", $gapsize2d
	gapdisGua2_3dplotf($name,froml,tol,fromr,tor)
	dilf($gapsize2d)
	modifyphasetopo()
	color3s_for3d($gapsize2d,3)
	execute "Conshist()"
	string wl = grabwinnonew(gapsize2d)+";"+grabwinnonew("Hist_"+gapsize2d)
	tilewindows/WINS=wl/R/w=(3,53,62.5,80)/A=(1,2)

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

//#3_01_03 GCB mode <Main Function>
Function gapdisGua2_3dplotf(namemat3d,froml,tol,fromr,tor)
	wave namemat3d // the 3D matrix g(r,v)
	Variable froml
	Variable tol
	Variable fromr
	Variable tor

	string/G mat3dn_cons
	string slicename = "Zslice_"+mat3dn_cons
	string sts = "sts_"+mat3dn_cons
	//print sts
	wave stsw = $sts
	variable/G zn_cons
	//** Auto ordering layer index
		variable zn = zn_cons
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

	variable sizex=dimsize(namemat3d,xn)
	variable sizey=dimsize(namemat3d,yn)

	String name
	String mat
	Variable k,i,j
	//String gapsize2ds
	//gapsize2ds="gapsize2d"
	//mat3ds="mat3d"

	String mat3ds = nameofwave(namemat3d)
	Wave mat3d=$mat3ds
	string gapsize2ds = mat3ds+"_Gap_map"
	Wave m=$gapsize2ds

	String mat2,mat3
	Variable p1,p2
	p1=Round((froml-dimoffset(mat3d,zn))/dimdelta(mat3d,zn))
	p2=Round((tol-dimoffset(mat3d,zn))/dimdelta(mat3d,zn))
	Variable q1,q2
	q1=Round((fromr-dimoffset(mat3d,zn))/dimdelta(mat3d,zn))
	q2=Round((tor-dimoffset(mat3d,zn))/dimdelta(mat3d,zn))
	k=1
	i=0
	do
		j=0
		do


			Cursor/W=$grabwin(slicename)/P/I/C=(1,65535,33232)/T=6 A $slicename i,j


			if(zn_cons == 0)
				stsw[] = namemat3d[p][i][j]
			endif
			if(zn_cons == 1)
				stsw[] = namemat3d[i][p][j]
			endif
			if(zn_cons == 2)
				stsw[] = namemat3d[i][j][p]
			endif

			//** Create Z-spectrum [the single STS]
			mat="sts"+num2str(k)
			mat3="fit_"+mat
			mat2="W_coef"
			make/o/n=(dimsize(mat3d,zn)) $mat
			Wave n=$mat
			setscale/p x, dimoffset(mat3d,zn),dimdelta(mat3d,zn),"",n
				//n[]=mat3d[i][p][j]
			if(zn_cons == 0)
				n[]=mat3d[p][i][j]
			endif
			if(zn_cons == 1)
				n[]=mat3d[i][p][j]
			endif
			if(zn_cons == 2)
				n[]=mat3d[i][j][p]
			endif

			//** Multifunctional fitting to the Z-spectrum
			smooth 5,n
				//*** Guassian Fit Left
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

				//*** Guassian Fit right
				CurveFit/Q/W=2 gauss, n[q1,q2]/D
				Wave W_coefr=$mat2
				variable rightc
				rightc=W_coefr[2]
				if (rightc > fromr && rightc < tor)
				else
					rightc=NAN
					j2=0
				endif

				//*** Linear substraction Fit left
				CurveFit/Q/NTHR=0 line n[p1,p2] /D
				duplicate/o n n2
				duplicate/o n n3
				Wave W_coefll=$mat2
				n2=W_coefll[0]+W_coefll[1]*x
				n=n3-n2
				wavestats/Q/R = (froml, tol) n
				variable ll
				ll=abs(V_maxloc)

				//*** Linear substraction Fit Right
				CurveFit/Q/NTHR=0 line n[q1,q2] /D
				duplicate/o n n2
				duplicate/o n n3
				Wave W_coefrr=$mat2
				n2=W_coefrr[0]+W_coefrr[1]*x
				n=n3-n2
				wavestats/Q/R = (fromr, tor) n
				variable rr
				rr=abs(V_maxloc)
			killwaves n
			wave fitn=$mat3
			killwaves n2,n3,W_coefrr,W_coefll,W_coefr
			killwaves fitn
			//*** Select a proper Fitting value
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
			//wave fitn=$mat3
			//killwaves n2,n3,W_coefrr,W_coefll,W_coefr
			//killwaves fitn
		while(j<sizey)
		i+=1
	while(i<sizex)
end

//#3_02_01 Linear substraction mode <control layout>
proc gapdisLinear_3dplot(name,from,to)
	string name // Input the name of 3d matrix g(r,V)
	variable from
	variable to
	prompt from,"Start -Energy value for search"
	prompt to,"End -Energy value for search"

	//PauseUpdate; Silent 1

	variable/G zn_cons
	//** Auto ordering layer index
		variable zn = zn_cons
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

	string gapsize2d = name+"_Gap_map"
	variable sizex=dimsize($name,xn)
	variable sizey=dimsize($name,yn)
	//prompt sizex,"How many points Nx"
	//prompt sizey,"How many points Ny"
	make/o/N=(sizex,sizey) $gapsize2d
	setscale/p x,dimoffset($name,xn),dimdelta($name,xn),"", $gapsize2d
	setscale/p y,dimoffset($name,yn),dimdelta($name,yn),"", $gapsize2d


	gapdisLinear_3dplotf($name,from,to)
	dilf($gapsize2d)
	modifyphasetopo()
	color3s_for3d($gapsize2d,3)
	execute "Conshist()"
	string wl = grabwinnonew(gapsize2d)+";"+grabwinnonew("Hist_"+gapsize2d)
	tilewindows/WINS=wl/R/w=(3,53,62.5,80)/A=(1,2)

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

//#3_02_02 Linear substraction mode <Main Function>
Function gapdisLinear_3dplotf(namemat3d,from,to)
	wave namemat3d // the 3D matrix g(r,v)
	Variable from
	Variable to

	//string/G mat3dn_cons
	variable/G zn_cons
	//** Auto ordering layer index
		variable zn = zn_cons
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

	variable sizex=dimsize(namemat3d,xn)
	variable sizey=dimsize(namemat3d,yn)

	//String name
	String mat
	Variable k,i,j

	String mat3ds = nameofwave(namemat3d)
	Wave mat3d=$mat3ds
	string gapsize2ds = mat3ds+"_Gap_map"
	Wave m=$gapsize2ds

	String mat2,mat3
	Variable p1,p2
	p1=Round((from-dimoffset(mat3d,zn))/dimdelta(mat3d,zn))
	p2=Round((to-dimoffset(mat3d,zn))/dimdelta(mat3d,zn))

	k=1
	i=0
	do
		j=0
		do
			mat="sts"+num2str(k)
			mat3="fit_"+mat
			mat2="W_coef"
			make/o/n=(dimsize(mat3d,zn)) $mat
			Wave n=$mat
			//Redimension/N=(dimsize(mat3d,1)) n
			setscale/p x, dimoffset(mat3d,zn),dimdelta(mat3d,zn),""n

			if(zn_cons == 0)
				n[]=mat3d[p][i][j]
			endif
			if(zn_cons == 1)
				n[]=mat3d[i][p][j]
			endif
			if(zn_cons == 2)
				n[]=mat3d[i][j][p]
			endif

			CurveFit/Q/NTHR=0 line n[p1,p2] /D

			duplicate/o n n2
			duplicate/o n n3
			Wave W_coef=$mat2
			n2=W_coef[0]+W_coef[1]*x
			n=n3-n2
			wavestats/Q/R = (from, to) n

			killwaves n
			wave fitn=$mat3
			killwaves n2,n3,W_coef
			killwaves fitn
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

//#3_03_01 Guassian  mode <Main Function>
Function ButtonProc_gapdisGua1_3dplot(ctrlName) : ButtonControl
	String ctrlName
	Execute "gapdiisGua1_3dplot()"
end

//#3_03_02 Guassian  mode <Control layout>
proc gapdisGua1_3dplot(name,froml,tol)
	string name // Input the name of 3d matrix g(r,V)
	variable froml
	variable tol
	prompt froml,"Start -Energy value for search"
	prompt tol,"End -Energy value for search"
	//PauseUpdate; Silent 1

	variable/G zn_cons
	//** Auto ordering layer index
		variable zn = zn_cons
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

	string gapsize2d = name+"_Gap_map"
	variable sizex=dimsize($name,xn)
	variable sizey=dimsize($name,yn)
	//prompt sizex,"How many points Nx"
	//prompt sizey,"How many points Ny"
	make/o/N=(sizex,sizey) $gapsize2d
	setscale/p x,dimoffset($name,xn),dimdelta($name,xn),"", $gapsize2d
	setscale/p y,dimoffset($name,yn),dimdelta($name,yn),"", $gapsize2d
	gapdisGua1_3dplotf($name,froml,tol)
	dilf($gapsize2d)
	modifyphasetopo()
	color3s_for3d($gapsize2d,3)
	execute "Conshist()"
	string wl = grabwinnonew(gapsize2d)+";"+grabwinnonew("Hist_"+gapsize2d)
	tilewindows/WINS=wl/R/w=(3,53,62.5,80)/A=(1,2)

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

//#3_03_03 Guassian  mode <Main Function>
Function gapdisGua1_3dplotf(namemat3d,from,to)
	wave namemat3d // the 3D matrix g(r,v)
	Variable from
	Variable to

	//string/G mat3dn_cons
	variable/G zn_cons
	//** Auto ordering layer index
		variable zn = zn_cons
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

	variable sizex=dimsize(namemat3d,xn)
	variable sizey=dimsize(namemat3d,yn)

	String name
	String mat
	Variable k,i,j
	//String gapsize2ds
	//gapsize2ds="gapsize2d"
	//mat3ds="mat3d"
	String mat3ds = nameofwave(namemat3d)
	Wave mat3d=$mat3ds
	string gapsize2ds = mat3ds+"_Gap_map"
	Wave m=$gapsize2ds
	String mat2,mat3
	Variable p1,p2
	p1=Round((from-dimoffset(mat3d,zn))/dimdelta(mat3d,zn))
	p2=Round((to-dimoffset(mat3d,zn))/dimdelta(mat3d,zn))
	k=1
	i=0
	do
		j=0
		do
			mat="sts"+num2str(k)
			mat3="fit_"+mat
			mat2="W_coef"
			make/o/n=(dimsize(mat3d,zn)) $mat
			Wave n=$mat
			//Redimension/N=(dimsize(mat3d,1)) n
			setscale/p x, dimoffset(mat3d,zn),dimdelta(mat3d,zn),"",n

			if(zn_cons == 0)
				n[]=mat3d[p][i][j]
			endif
			if(zn_cons == 1)
				n[]=mat3d[i][p][j]
			endif
			if(zn_cons == 2)
				n[]=mat3d[i][j][p]
			endif

			//CurveFit/Q/NTHR=0 line n[p1,p2] /D
			CurveFit/Q/W=2 gauss, n[p1,p2]/D

			//duplicate/o n n2
			//duplicate/o n n3
			Wave W_coef=$mat2
			//n2=W_coef[0]+W_coef[1]*x
			//n=n3-n2
			//wavestats/Q/R = (from, to) n
			m[i][j]=W_coef[2]
			killwaves n
			wave fitn=$mat3
			killwaves fitn
			killwaves W_coef
			j+=1
			K+=1
		while(j<sizey)
		i+=1
	while(i<sizex)
end

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** {{{{{{{{{{ Overlay T(r) and Δ(r) }}}}}}}}}}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function PopMenuProc_appendimage(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string/G mat3dn_cons


	string slicename = "Zslice_"+mat3dn_cons

	string appendvalue

	//Get Bare string
			//**This due to sometime the input 3dwave is not g(r,V)
		string barename
		//#case of R map
		if (stringmatch(mat3dn_cons,"*_R_map") == 1)
			barename = replaceString("_R_map",mat3dn_cons,"")
		//#case of Z map
		elseif (stringmatch(mat3dn_cons,"*_Z_map") == 1)
			barename = replaceString("_Z_map",mat3dn_cons,"")
		//#case of Rho map
		elseif (stringmatch(mat3dn_cons,"*_Rho_map") == 1)
			barename = replaceString("_Rho_map",mat3dn_cons,"")
		//#case of I map
		elseif (stringmatch(mat3dn_cons,"*_I") == 1)
			barename = replaceString("_I",mat3dn_cons,"")+"_G"
		elseif (stringmatch(mat3dn_cons,"*_G") == 1)
			barename = mat3dn_cons
		endif


	string gapmap = barename+"_Gap_map"

	if (waveexists($gapmap) == 1)
		appendvalue = "Remove;T(r);Δ(r)"
	else
		appendvalue = "Remove;T(r)"
	endif

	string winn = grabwinnonew(slicename)
	string exbody ="PopupMenu appendtord value= \""+appendvalue+"\""
	execute exbody
	string Tr = replaceString("_G",barename,"")+"_T"
	string dr = gapmap//mat3dn_cons+"_Gap_map"
	//print dr
	string listcheck = wavelist("*",";","Win:"+grabwinnonew(slicename))+"1"
	//print listcheck
	string W_coef = "W_coef"
	variable lc,lh
	variable sigma

	if (popNum == 1)
		if (cmpstr(StringByKey(tr,listcheck,";"),"") == 1)
			removeimage $Tr
		endif

		//print StringByKey(dr,listcheck,";")
		//print cmpstr(StringByKey(dr,listcheck,";"),"")

		if (cmpstr(StringByKey(dr,listcheck,";"),"") == 1)
			removeimage $dr
		endif
	endif

	if (popNum == 2)
		if (cmpstr(StringByKey(dr,listcheck,";"),"") == 1)
			removeimage $dr
		endif
		if (cmpstr(StringByKey(tr,listcheck,";"),"") == 1)
			removeimage $Tr
		endif
		Appendimage $Tr
		gethistgram_npcolor(Tr)
		wave W_coefw = $W_coef
		sigma = sqrt(2)*W_coefw[3]

		wavestats/Q $Tr
		if (W_coefw[2]-0.5*3*sigma >V_min)
			lc = W_coefw[2]-0.5*3*sigma
		else
			lc =V_min
		endif
		if (W_coefw[2]+0.5*3*sigma < V_max)
			lh = W_coefw[2]+0.5*3*sigma
		else
			lh =V_max
		endif

		ModifyImage $Tr ctab= {lc,lh,VioletOrangeYellow,0}
	endif

	if (popNum == 3)
		if (cmpstr(StringByKey(dr,listcheck,";"),"") == 1)
			removeimage $dr
		endif
		if (cmpstr(StringByKey(tr,listcheck,";"),"") == 1)
			removeimage $Tr
		endif
		Appendimage $dr
		gethistgram_npcolor(dr)
		wave W_coefw = $W_coef
		sigma = sqrt(2)*W_coefw[3]

		wavestats/Q $dr
		if (W_coefw[2]-0.5*3*sigma >V_min)
			lc = W_coefw[2]-0.5*3*sigma
		else
			lc =V_min
		endif
		if (W_coefw[2]+0.5*3*sigma < V_max)
			lh = W_coefw[2]+0.5*3*sigma
		else
			lh =V_max
		endif

		ModifyImage $dr ctab= {lc,lh,VioletOrangeYellow,0}

		//ModifyImage g2_006_G_Gap_map ctab= {*,*,VioletOrangeYellow,0}
	endif
end

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** {{{{{{{{{{ Extract Energy dependent Shearing parameters }}}}}}}}}}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//#0_1 PreFFT:control
Function ButtonProc_Cons3dplotgetshear(ctrlName) : ButtonControl
	String ctrlName
	string/G mat3dn_cons
	string slicename = "Zslice_"+mat3dn_cons
	ff_3dplot($slicename)
end

//#0_2 PreFFT: Main
Function ff_3dplot(name)
	wave name
	func_NaN0(name)
	String FFTout
	FFTout = nameofWave(name) + "_FFT"
	FFT/out=1/WINF=Hanning/DEST=$FFTout cvtcmplx(name)

	Complextorealf1($FFTout,1)
	String FFToutm = FFTout+"_Modula"
	twoDinterpolatexyFFT_3dplot(FFToutm,10*dimsize($FFTout,0),10*dimsize($FFTout,1))


	Button Map79 title="area A",proc=ButtonProc_GPAarea,pos={270,1}
	Button Map80 title="area B",proc=ButtonProc_GPBarea,pos={340,1}
	Button Map81 title="Box",proc=ButtonProc_appendboxonly,pos={180,1}
	Button MapGOSHEAR title="Get Shear",proc=ButtonProc_Gshear,pos={1,1},size={80,20}
	//ModifyGraph width=154,height=154
		String namec
		namec = "c_"+nameofwave(name)
		string FFToutm1 = FFToutm+"1"
		killwaves $FFTout $namec  $FFToutm1 //$FFToutm
end
//#0_2_01 PreFFT: Main_called
Function twoDinterpolatexyFFT_3dplot(name,xpoint,ypoint)
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

	CheckDisplayed $name2
	if (V_flag == 1)
		print "display;appendimage " + name2+";ModifyGraph width={Plan,1,bottom,left}"
	else
	endif
	killwindow $grabwin2(name2)
	dilf($name2)
	wavestats/Q $name2
	color3s($name2,30)
	tilewindows/WINS=winname(0,1)/R/A=(1,1)/w=(29.8,43,63,85)
end

////////////////////////////////////////////////////////////////////////////////
//#01_01 Grab Marquee [Q1]
Function ButtonProc_GpAarea(ctrlName) : ButtonControl
	String ctrlName
	make/N=4/o rangA_shear3dplot
	GetMarquee left, bottom
	rangA_shear3dplot={V_left,V_right,V_bottom,V_top}
	//print rangA_shear3dplot

	drawAction delete
	string rangB_shear3dplot = "rangB_shear3dplot"
	wave rangB_shear3dplotw = $rangB_shear3dplot
	if (waveexists(rangB_shear3dplotw) == 1)
		SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),fillpat= 0,linethick= 1.00;DelayUpdate
		DrawRect rangB_shear3dplotw[0],rangB_shear3dplotw[2],rangB_shear3dplotw[1],rangB_shear3dplotw[3]
	endif

	SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),fillpat= 0,linethick= 1.00;DelayUpdate
	DrawRect rangA_shear3dplot[0],rangA_shear3dplot[2],rangA_shear3dplot[1],rangA_shear3dplot[3]

	string/G mat3dn_cons
	string hookfftname =grabwinnonew("Zslice_"+mat3dn_cons+"_FFT_Modula")
	//print hookfftname
	drawAction/W=$hookfftname delete
	rangB_shear3dplot = "rangB_shear3dplot"
	wave rangB_shear3dplotw = $rangB_shear3dplot
	if (waveexists(rangB_shear3dplotw) == 1)
		SetDrawEnv/W=$hookfftname xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),fillpat= 0,linethick= 1.00;DelayUpdate
		DrawRect/W=$hookfftname rangB_shear3dplotw[0],rangB_shear3dplotw[2],rangB_shear3dplotw[1],rangB_shear3dplotw[3]
	endif

	SetDrawEnv/W=$hookfftname xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),fillpat= 0,linethick= 1.00;DelayUpdate
	DrawRect/W=$hookfftname rangA_shear3dplot[0],rangA_shear3dplot[2],rangA_shear3dplot[1],rangA_shear3dplot[3]
end

//#01_02 Grab Marquee [Q2]
Function ButtonProc_GpBarea(ctrlName) : ButtonControl
	String ctrlName
	make/N=4/o rangB_shear3dplot
	GetMarquee left, bottom
	rangB_shear3dplot={V_left,V_right,V_bottom,V_top}

	drawAction delete
	string rangA_shear3dplot = "rangA_shear3dplot"
	wave rangA_shear3dplotw = $rangA_shear3dplot
	if (waveexists(rangA_shear3dplotw) == 1)
		SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),fillpat= 0,linethick= 1.00;DelayUpdate
		DrawRect rangA_shear3dplotw[0],rangA_shear3dplotw[2],rangA_shear3dplotw[1],rangA_shear3dplotw[3]
	endif

	SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),fillpat= 0,linethick= 1.00;DelayUpdate
	DrawRect rangB_shear3dplot[0],rangB_shear3dplot[2],rangB_shear3dplot[1],rangB_shear3dplot[3]

	string/G mat3dn_cons
	string hookfftname =grabwinnonew("Zslice_"+mat3dn_cons+"_FFT_Modula")
	drawAction/W=$hookfftname  delete
	rangA_shear3dplot = "rangA_shear3dplot"
	wave rangA_shear3dplotw = $rangA_shear3dplot
	if (waveexists(rangA_shear3dplotw) == 1)
		SetDrawEnv/W=$hookfftname  xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),fillpat= 0,linethick= 1.00;DelayUpdate
		DrawRect/W=$hookfftname  rangA_shear3dplotw[0],rangA_shear3dplotw[2],rangA_shear3dplotw[1],rangA_shear3dplotw[3]
	endif

	SetDrawEnv/W=$hookfftname  xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),fillpat= 0,linethick= 1.00;DelayUpdate
	DrawRect/W=$hookfftname  rangB_shear3dplot[0],rangB_shear3dplot[2],rangB_shear3dplot[1],rangB_shear3dplot[3]
end

Function ButtonProc_appendboxonly(ctrlName) : ButtonControl
	String ctrlName
	//make/N=4/o rangA_shear3dplot
	//GetMarquee left, bottom
	//rangA_shear3dplot={V_left,V_right,V_bottom,V_top}
	//print rangA_shear3dplot

	drawAction delete
	string rangB_shear3dplot = "rangB_shear3dplot"
	wave rangB_shear3dplotw = $rangB_shear3dplot
	if (waveexists(rangB_shear3dplotw) == 1)
		SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),fillpat= 0,linethick= 1.00;DelayUpdate
		DrawRect rangB_shear3dplotw[0],rangB_shear3dplotw[2],rangB_shear3dplotw[1],rangB_shear3dplotw[3]
	endif

	string rangA_shear3dplot = "rangA_shear3dplot"
	wave rangA_shear3dplotw = $rangA_shear3dplot
	if (waveexists(rangA_shear3dplotw) == 1)
		SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),fillpat= 0,linethick= 1.00;DelayUpdate
		DrawRect rangA_shear3dplotw[0],rangA_shear3dplotw[2],rangA_shear3dplotw[1],rangA_shear3dplotw[3]
	endif

	end

////////////////////////////////////////////////////////////////////////////////
//#2_01 Extract Shearing:control
Function ButtonProc_Gshear(ctrlName) : ButtonControl
	String ctrlName
	string/G mat3dn_cons
	variable/G zn_cons
	variable/G z_cons
	variable Z_constp=(z_cons-dimoffset($mat3dn_cons,zn_cons))/dimdelta($mat3dn_cons,zn_cons)

	//** Indicative line
	string Zpp = "Zpp_"+mat3dn_cons
	wave zppw = $zpp

	//Set window function
	string win
	string/G FFTWin_3dplot
	if(cmpstr(FFTWin_3dplot,"None") == 0)
		win = ""
	elseif (cmpstr(FFTWin_3dplot,"") == 0)
	else
		win = "imagewindow/o "+FFTWin_3dplot+" FFTslicetemp"
	endif

	//** Auto ordering layer index
		variable zn = zn_cons
		make/o/N=3 ordernum ={0,1,2}
		ordernum=abs(ordernum-zn_cons)
		wavestats/Q ordernum
		ordernum={0,1,2}
		DeletePoints V_minloc,1, ordernum
		wavestats/Q ordernum
		variable xn = ordernum[V_minloc]
		variable yn = ordernum[V_maxloc]
		killwaves ordernum

	//** make layer wave
		string bare3d = mat3dn_cons
		string sliceg = "Zslice_"+bare3d
		make/o/N=(dimsize($bare3d,xn),dimsize($bare3d,yn)) $sliceg
		setscale/p x,dimoffset($bare3d,xn),dimdelta($bare3d,xn),"",$sliceg
		setscale/p y,dimoffset($bare3d,yn),dimdelta($bare3d,yn),"",$sliceg
		wave slicegw = $sliceg
		wave bare3dw = $bare3d

	//** Reference of Marquee range wave from "area A", "area B" button
		string rangA_shear3dplot = "rangA_shear3dplot"
		string rangB_shear3dplot = "rangB_shear3dplot"
		wave rangA_shear3dplotw = $rangA_shear3dplot
		wave rangB_shear3dplotw = $rangB_shear3dplot

	//** Q1 Q2 coordinate fitted through GpAarea() and GpBarea()
		//** Reference of the value generated by other functions before
		string Fitq2x =sliceg+"_getq2x"
		string Fitq2y =sliceg+"_getq2y"
		string Fitq1x =sliceg+"_getq1x"
		string Fitq1y =sliceg+"_getq1y"


		//** make the new wave to contain that data
		string q1xE = mat3dn_cons+"_q1xE"
		string q1yE = mat3dn_cons+"_q1yE"
		string q2xE = mat3dn_cons+"_q2xE"
		string q2yE = mat3dn_cons+"_q2yE"
		make/N=0/o $q1xE
		make/N=0/o $q1yE
		make/N=0/o $q2xE
		make/N=0/o $q2yE
		wave q1xEw = $q1xE
		wave q1yEw = $q1yE
		wave q2xEw = $q2xE
		wave q2yEw = $q2yE
			//edit q1xEw
	//**
		//** Reference of the value generated by other functions before
		string coefiniguer = sliceg+"_Fitresult"

		//** make the new wave to contain that data
		string qnorm = mat3dn_cons+"_qnorm_shear"
		string alpha = mat3dn_cons+"_alpha_shear"
		string shearP = mat3dn_cons+"_P_shear"
		string thetashear = mat3dn_cons+"_theta_shear"
		make/N=0/o $qnorm
		make/N=0/o $alpha
		make/N=0/o $shearP
		make/N=0/o $thetashear
		wave qnormw = $qnorm
		wave alphaw = $alpha
		wave shearPw = $shearP
		wave thetashearw = $thetashear
			//edit qnormw

		//** For topography data
		string q1xT = mat3dn_cons+"_q1xT"
		string q1yT = mat3dn_cons+"_q1yT"
		string q2xT = mat3dn_cons+"_q2xT"
		string q2yT = mat3dn_cons+"_q2yT"
		make/N=2/o $q1xT
		make/N=2/o $q1yT
		make/N=2/o $q2xT
		make/N=2/o $q2yT
		wave q1xTw = $q1xT
		wave q1yTw = $q1yT
		wave q2xTw = $q2xT
		wave q2yTw = $q2yT
		q1xTw =nan
		q1yTw =nan
		q2xTw =nan
		q2yTw =nan


		string qnormT = mat3dn_cons+"_qnorm_shearT"
		string alphaT = mat3dn_cons+"_alpha_shearT"
		string shearPT = mat3dn_cons+"_P_shearT"
		string thetashearT = mat3dn_cons+"_theta_shearT"
		make/N=2/o $qnormT
		make/N=2/o $alphaT
		make/N=2/o $shearPT
		make/N=2/o $thetashearT
		wave qnormTw = $qnormT
		wave alphaTw = $alphaT
		wave shearPTw = $shearPT
		wave thetashearTw = $thetashearT
		qnormTw = nan
		alphaTw = nan
		shearPTw = nan
		thetashearTw = nan

		//** For Gap Map

			string q1xG = mat3dn_cons+"_q1xG"
			string q1yG = mat3dn_cons+"_q1yG"
			string q2xG = mat3dn_cons+"_q2xG"
			string q2yG = mat3dn_cons+"_q2yG"
			make/N=2/o $q1xG
			make/N=2/o $q1yG
			make/N=2/o $q2xG
			make/N=2/o $q2yG
			wave q1xGw = $q1xG
			wave q1yGw = $q1yG
			wave q2xGw = $q2xG
			wave q2yGw = $q2yG
			q1xGw =nan
			q1yGw =nan
			q2xGw =nan
			q2yGw =nan


			string qnormG = mat3dn_cons+"_qnorm_shearG"
			string alphaG = mat3dn_cons+"_alpha_shearG"
			string shearPG = mat3dn_cons+"_P_shearG"
			string thetashearG = mat3dn_cons+"_theta_shearG"
			make/N=2/o $qnormG
			make/N=2/o $alphaG
			make/N=2/o $shearPG
			make/N=2/o $thetashearG
			wave qnormGw = $qnormG
			wave alphaGw = $alphaG
			wave shearPGw = $shearPG
			wave thetashearGw = $thetashearG
			qnormGw = nan
			alphaGw = nan
			shearPGw = nan
			thetashearGw = nan

	//Get Bare string
			//**This due to sometime the input 3dwave is not g(r,V)
		string barename
		variable ind = 0
		//#case of R map
		if (stringmatch(mat3dn_cons,"*_R_map") == 1)
			barename = replaceString("_R_map",mat3dn_cons,"")
			ind = 1
		//#case of Z map
		elseif (stringmatch(mat3dn_cons,"*_Z_map") == 1)
			barename = replaceString("_Z_map",mat3dn_cons,"")
			ind = 1
		//#case of Rho map
		elseif (stringmatch(mat3dn_cons,"*_Rho_map") == 1)
			barename = replaceString("_Rho_map",mat3dn_cons,"")
			ind = 1
		//#case of I map
		elseif (stringmatch(mat3dn_cons,"*_I") == 1)
			barename = replaceString("_I",mat3dn_cons,"")+"_G"
			ind = 1
		elseif (stringmatch(mat3dn_cons,"*_G") == 1)
			barename = mat3dn_cons
			ind = 1
		else
			ind = 0
		endif
		print "Bare Name is ["+barename+"]"
	//Display
	//if (checkmultiopen(12) == 1)
	//	else
			Display;modifygraph width=500,height=(4*500/3)
			Display/HOST=#/W=(0.01,0.01,0.51,0.25);appendTOGRAPH shearPw; Label left "\\Z16P";appendTOGRAPH shearPTw;ModifyGraph lstyle($shearPT)=7,rgb($shearPT)=(48059,48059,48059),lsize($shearP)=2,rgb($shearP)=(0,0,0),mode($shearP)=3,marker($shearP)=8,mrkThick($shearP)=1
			setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.01,1,0.25);appendTOGRAPH thetashearw; Label left "\\Z16θ(º)";TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "Shear Axis angle form +X";appendTOGRAPH thetashearTw;ModifyGraph lstyle($thetashearT)=7,rgb($thetashearT)=(48059,48059,48059);appendTOGRAPH thetashearGw;ModifyGraph mode($thetashearG)=4,rgb($thetashearG)=(32768,40777,65535),mode($thetashear)=3,marker($thetashear)=8
			setActiveSubwindow ##;Display/HOST=#/W=(0.01,0.25,0.51,0.5);appendTOGRAPH alphaw; Label left "\\Z16α(º)";TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "Lattice Axis angle form +X";appendTOGRAPH alphaTw;ModifyGraph lstyle($alphaT)=7,rgb($alphaT)=(48059,48059,48059);appendTOGRAPH alphaGw;ModifyGraph mode($alphaG)=4,rgb($alphaG)=(32768,40777,65535),mode($alpha)=3,marker($alpha)=8
			setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.25,1,0.5);appendTOGRAPH qnormw; Label left "\\Z16|q|";appendTOGRAPH qnormTw;ModifyGraph lstyle($qnormT)=7,rgb($qnormT)=(48059,48059,48059);appendTOGRAPH qnormGw;ModifyGraph mode($qnormG)=4,rgb($qnormG)=(32768,40777,65535)
			setActiveSubwindow ##;Display/HOST=#/W=(0.01,0.5,0.51,0.75);appendTOGRAPH q1xEw; Label left "\\Z16Q\B1\M\Z16(x)";appendTOGRAPH q1xTw;ModifyGraph lstyle($q1xT)=7,rgb($q1xT)=(48059,48059,48059);appendTOGRAPH q1xGw;ModifyGraph mode($q1xG)=4,rgb($q1xG)=(32768,40777,65535)
			setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.5,1,0.75);appendTOGRAPH q1yEw; Label left "\\Z16Q\B1\M\Z16(y)";appendTOGRAPH q1yTw;ModifyGraph lstyle($q1yT)=7,rgb($q1yT)=(48059,48059,48059);appendTOGRAPH q1yGw;ModifyGraph mode($q1yG)=4,rgb($q1yG)=(32768,40777,65535)
			setActiveSubwindow ##;Display/HOST=#/W=(0.01,0.75,0.51,1);appendTOGRAPH q2xEw; Label left "\\Z16Q\B2\M\Z16(x)";appendTOGRAPH q2xTw;ModifyGraph lstyle($q2xT)=7,rgb($q2xT)=(48059,48059,48059);appendTOGRAPH q2xGw;ModifyGraph mode($q2xG)=4,rgb($q2xG)=(32768,40777,65535)
			setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.75,1,1);appendTOGRAPH q2yEw; Label left "\\Z16Q\B2\M\Z16(y)";appendTOGRAPH q2yTw;ModifyGraph lstyle($q2yT)=7,rgb($q2yT)=(48059,48059,48059);appendTOGRAPH q2yGw;ModifyGraph mode($q2yG)=4,rgb($q2yG)=(32768,40777,65535)
			Legend/C/N=text0/J/F=0/A=RB "\\s("+q2yT+") T(r)\r\\s("+q2yG+") ∆(r)"
			setActiveSubwindow ##;
			tilewindows/WINS=winname(0,1)/R/w=(56,0,100,100)/A=(1,1)


			string gc = winname(0,1)+"#"+stringfromlist(0, ChildWindowList(winname(0,1)))
			appendTOGRAPH/W=$gc shearPGw;
			ModifyGraph/W=$gc mode($shearPG)=4,rgb($shearPG)=(32768,40777,65535)

			ckfig_child(winname(0,1))

			if (stringmatch(mat3dn_cons,"*_R_map") == 1)
				TextBox/C/N=text0/F=0/A=MT/X=0.00/Y=0.00 "\\Z16\\F'Arial Black'R(r,V) = I(r,V)/I(r,-V)"
			elseif (stringmatch(mat3dn_cons,"*_Z_map") == 1)
				TextBox/C/N=text0/F=0/A=MT/X=0.00/Y=0.00 "\\Z16\\F'Arial Black'Z(r,V) = g(r,V)/g(r,-V)"
			elseif (stringmatch(mat3dn_cons,"*_Rho_map") == 1)
				TextBox/C/N=text0/F=0/A=MT/X=0.00/Y=0.00 "\\Z16\\F'Arial Black'ρ(r,V) = I(r,V) - I(r,-V)"
			elseif (stringmatch(mat3dn_cons,"*_I") == 1)
				TextBox/C/N=text0/F=0/A=MT/X=0.00/Y=0.00 "\\Z16\\F'Arial Black'I(r,V)"
			elseif (stringmatch(mat3dn_cons,"*_G") == 1)
				TextBox/C/N=text0/F=0/A=MT/X=0.00/Y=0.00 "\\Z16\\F'Arial Black'g(r,V)"
			else
			endif

			//childWindowList(
			//Display;modifygraph width=500,height=(4*500/3)
			//Display/HOST=#/W=(0.01,0.01,0.51,0.25);appendTOGRAPH shearPw shearPTw shearPGw; Label left "\\Z16P";ModifyGraph lstyle($shearPT)=7,rgb($shearPT)=(48059,48059,48059),mode($shearPG)=4,rgb($shearPG)=(32768,40777,65535)
			//setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.01,1,0.25);appendTOGRAPH thetashearw thetashearTw thetashearGw; Label left "\\Z16θ(º)";TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "Shear Axis angle form +X";ModifyGraph lstyle($thetashearT)=7,rgb($thetashearT)=(48059,48059,48059),mode($thetashearG)=4,rgb($thetashearG)=(32768,40777,65535)
			//setActiveSubwindow ##;Display/HOST=#/W=(0.01,0.25,0.51,0.5);appendTOGRAPH alphaw alphaTw alphaGw; Label left "\\Z16α(º)";TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "Lattice Axis angle form +X";ModifyGraph lstyle($alphaT)=7,rgb($alphaT)=(48059,48059,48059), mode($alphaG)=4,rgb($alphaG)=(32768,40777,65535)
			//setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.25,1,0.5);appendTOGRAPH qnormw qnormTw qnormGw; Label left "\\Z16|q|";ModifyGraph lstyle($qnormT)=7,rgb($qnormT)=(48059,48059,48059), mode($qnormG)=4,rgb($qnormG)=(32768,40777,65535)
			//setActiveSubwindow ##;Display/HOST=#/W=(0.01,0.5,0.51,0.75);appendTOGRAPH q1xEw q1xTw q1xGw; Label left "\\Z16Q\B1\M\Z16(x)";ModifyGraph lstyle($q1xT)=7,rgb($q1xT)=(48059,48059,48059),mode($q1xG)=4,rgb($q1xG)=(32768,40777,65535)
			//setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.5,1,0.75);appendTOGRAPH q1yEw q1yTw q1yGw; Label left "\\Z16Q\B1\M\Z16(y)";ModifyGraph lstyle($q1yT)=7,rgb($q1yT)=(48059,48059,48059), mode($q1yG)=4,rgb($q1yG)=(32768,40777,65535)
			//setActiveSubwindow ##;Display/HOST=#/W=(0.01,0.75,0.51,1);appendTOGRAPH q2xEw q2xTw q2xGw; Label left "\\Z16Q\B2\M\Z16(x)";ModifyGraph lstyle($q2xT)=7,rgb($q2xT)=(48059,48059,48059), mode($q2xG)=4,rgb($q2xG)=(32768,40777,65535)
			//setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.75,1,1);appendTOGRAPH q2yEw q2yTw q2yGw; Label left "\\Z16Q\B2\M\Z16(y)";ModifyGraph lstyle($q2yT)=7,rgb($q2yT)=(48059,48059,48059), mode($q2yG)=4,rgb($q2yG)=(32768,40777,65535)
			//setActiveSubwindow ##;
			//tilewindows/WINS=winname(0,1)/R/w=(56,0,100,100)/A=(1,1)
	//endif
	string gggg = "Zslice_"+mat3dn_cons+"_FFT_Modula_INTER"
	Dowindow/F $grabwinnonew(gggg)

	//** Launch the loop
		variable i
		i=0
		do
			//Create the raw data slice
			if(zn_cons == 0)
				slicegw[][]=bare3dw[i][p][q]
			endif
			if(zn_cons == 1)
				slicegw[][]=bare3dw[p][i][q]
			endif
			if(zn_cons == 2)
				slicegw[][]=bare3dw[p][q][i]
			endif
			color3s_for3d(slicegw,3)
			Zppw=(dimoffset($bare3d,zn)+i*dimdelta($bare3d,zn))

			//Do FFT
			execute win
			ff_3dplotn($sliceg)

			//Grab the Q1 and Q2
			GpAarea(sliceg,rangA_shear3dplotw)
			GpBarea(sliceg,rangB_shear3dplotw)
			wave Fitq1xw = $Fitq1x
			wave Fitq1yw = $Fitq1y
			wave Fitq2xw = $Fitq2x
			wave Fitq2yw = $Fitq2y
			//Record the Q1 Q2 with a function of Energy
				//Q1x
				insertPoints dimsize(q1xEw,0),1,q1xEw
				//print  Fitq1xw[0]
				q1xEw[dimsize(q1xEw,0)-1] = Fitq1xw[0]
				if (abs(Fitq1xw[0])> abs(0.5*q1xEw[0]) && abs(Fitq1xw[0]) < abs(1.5*q1xEw[0]))
				else
					//Fitq1xw[0] = mean(q1xEw)
					//q1xEw[dimsize(q1xEw,0)-1] = Fitq1xw[0]
					Fitq1xw[0] = q1xEw[0]
					q1xEw[dimsize(q1xEw,0)-1] = q1xEw[0]
				endif

				//Q1y
				insertPoints dimsize(q1yEw,0),1,q1yEw
				q1yEw[dimsize(q1yEw,0)-1] = Fitq1yw[0]
				if (abs(Fitq1yw[0])> abs(0.5*q1yEw[0]) && abs(Fitq1yw[0]) < abs(1.5*q1yEw[0]))
				else
					//Fitq1yw[0] = mean(q1yEw)
					//q1yEw[dimsize(q1yEw,0)-1] = Fitq1yw[0]
					Fitq1yw[0] = q1yEw[0]
					q1yEw[dimsize(q1yEw,0)-1] = q1yEw[0]
				endif

				//Q2x
				insertPoints dimsize(q2xEw,0),1,q2xEw
				q2xEw[dimsize(q2xEw,0)-1] = Fitq2xw[0]
				if (abs(Fitq2xw[0])> abs(0.5*q2xEw[0]) && abs(Fitq2xw[0]) < abs(1.5*q2xEw[0]))
				else
					//Fitq2xw[0] = mean(q2xEw)
					//q2xEw[dimsize(q2xEw,0)-1] = Fitq2xw[0]
					Fitq2xw[0] = q2xEw[0]
					q2xEw[dimsize(q2xEw,0)-1] = q2xEw[0]
				endif

				//Q2y
				insertPoints dimsize(q2yEw,0),1,q2yEw
				q2yEw[dimsize(q2yEw,0)-1] = Fitq2yw[0]
				if (abs(Fitq2yw[0]) > abs(0.5*q2yEw[0]) && abs(Fitq2yw[0]) < abs(1.5*q2yEw[0]))
				else
					//Fitq2yw[0] = mean(q2yEw)
					//q2yEw[dimsize(q2yEw,0)-1] = Fitq2yw[0]
					Fitq2yw[0] = q2yEw[0]
					q2yEw[dimsize(q2yEw,0)-1] = q2yEw[0]
				endif

			//Run Shear Fitting
				C4sheargetpara_3dplot(sliceg)
				wave coefiniguerw = $coefiniguer

			//Record the shear coefficients with a function of Energy
				//qnormw
				insertPoints dimsize(qnormw,0),1,qnormw
				qnormw[dimsize(qnormw,0)-1] = coefiniguerw[0]
				//if (abs(coefiniguerw[0])> abs(0.5*qnormw[0]) && abs(coefiniguerw[0]) < abs(1.5*qnormw[0]))
				//else
					//coefiniguerw[0] = mean(qnormw)
					//qnormw[dimsize(qnormw,0)-1] = coefiniguerw[0]
					//**coefiniguerw[0] = qnormw[0]
					//**qnormw[dimsize(qnormw,0)-1] = qnormw[0]
					//qnormw[dimsize(qnormw,0)-1] = nan
				//endif

				//alphaw
				insertPoints dimsize(alphaw,0),1,alphaw
				alphaw[dimsize(alphaw,0)-1] = coefiniguerw[1]
				//if (coefiniguerw[1]> 0.5*alphaw[0] && coefiniguerw[1] < 1.5*alphaw[0])
				//else
					//coefiniguerw[1] = mean(alphaw)
					//alphaw[dimsize(alphaw,0)-1] = coefiniguerw[1]
					//**coefiniguerw[1] = alphaw[0]
					//**alphaw[dimsize(alphaw,0)-1] = alphaw[0]
				//	alphaw[dimsize(alphaw,0)-1] = nan
				//endif

				//shearPw
				insertPoints dimsize(shearPw,0),1,shearPw
				shearPw[dimsize(shearPw,0)-1] = abs(coefiniguerw[2])
				//if (shearPw[dimsize(shearPw,0)-1] > 0.4)
					//coefiniguerw[2] = mean(shearPw)
					//shearPw[dimsize(shearPw,0)-1] = coefiniguerw[2]
					//**coefiniguerw[2] = shearPw[0]
					//**shearPw[dimsize(shearPw,0)-1] = shearPw[0]
					//shearPw[dimsize(shearPw,0)-1] = nan
				//endif

				//thetashearw
				insertPoints dimsize(thetashearw,0),1,thetashearw
				thetashearw[dimsize(thetashearw,0)-1] = coefiniguerw[3]
				//if (coefiniguerw[3]> 0.5*thetashearw[0] && coefiniguerw[3] < 1.5*thetashearw[0])
				//else
					//coefiniguerw[3] = mean(thetashearw)
					//thetashearw[dimsize(thetashearw,0)-1] = coefiniguerw[3]
					//**coefiniguerw[3] = thetashearw[0]
					//**thetashearw[dimsize(thetashearw,0)-1] = thetashearw[0]
				//	thetashearw[dimsize(thetashearw,0)-1] = nan
				//endif
			i+=1
		while(i<dimsize($bare3d,zn))
		setscale/p x,dimoffset($mat3dn_cons,zn),dimdelta($mat3dn_cons,zn),"",qnormw,alphaw,shearPw,thetashearw,q1xEw,q1yEw,q2xEw,q2yEw


	//Calculte the Non-E-dependet lines
	if (ind == 1)
		//Calculate topo
			string toponame = replaceString("_G",barename,"")+"_T"
			//print toponame
			wave toponamew = $toponame
			slicegw = toponamew
			color3s_for3d(slicegw,3)

			//Do FFT
			execute win
			ff_3dplotn($sliceg)

			//Grab the Q1 and Q2
			GpAarea(sliceg,rangA_shear3dplotw)
			GpBarea(sliceg,rangB_shear3dplotw)
			wave Fitq1xw = $Fitq1x
			wave Fitq1yw = $Fitq1y
			wave Fitq2xw = $Fitq2x
			wave Fitq2yw = $Fitq2y

			q1xTw = Fitq1xw[0]
			q1yTw = Fitq1yw[0]
			q2xTw = Fitq2xw[0]
			q2yTw = Fitq2yw[0]

			C4sheargetpara_3dplot(sliceg)
			wave coefiniguerw = $coefiniguer

			qnormTw = coefiniguerw[0]
			alphaTw = coefiniguerw[1]
			shearPTw = abs(coefiniguerw[2])
			thetashearTw = coefiniguerw[3]


			setscale/I x,dimoffset($mat3dn_cons,zn),dimoffset($mat3dn_cons,zn)+(dimsize($mat3dn_cons,zn)-1)*dimdelta($mat3dn_cons,zn),"",q1xTw,q1yTw,q2xTw,q2yTw,qnormTw,alphaTw,shearPTw,thetashearTw

		//Calculate Gap map
		string gapmap = barename+"_Gap_map"
		if (waveexists($gapmap) == 1)
			wave gapmapw = $gapmap
			slicegw = gapmapw

			color3s_for3d(slicegw,3)

			//Do FFT
			execute win
			ff_3dplotn($sliceg)

			//Grab the Q1 and Q2
			GpAarea(sliceg,rangA_shear3dplotw)
			GpBarea(sliceg,rangB_shear3dplotw)
			wave Fitq1xw = $Fitq1x
			wave Fitq1yw = $Fitq1y
			wave Fitq2xw = $Fitq2x
			wave Fitq2yw = $Fitq2y

			q1xGw = Fitq1xw[0]
			q1yGw = Fitq1yw[0]
			q2xGw = Fitq2xw[0]
			q2yGw = Fitq2yw[0]

			C4sheargetpara_3dplot(sliceg)
			wave coefiniguerw = $coefiniguer
			qnormGw = coefiniguerw[0]
			alphaGw = coefiniguerw[1]
			shearPGw = abs(coefiniguerw[2])
			thetashearGw = coefiniguerw[3]
			setscale/I x,dimoffset($mat3dn_cons,zn),dimoffset($mat3dn_cons,zn)+(dimsize($mat3dn_cons,zn)-1)*dimdelta($mat3dn_cons,zn),"",qnormGw,alphaGw,shearPGw,thetashearGw,q1xGw,q2xGw,q1yGw,q2yGw
		endif
	endif
end

//#2_02 Extract Shearing:Main
Function C4sheargetpara_3dplot(name)
	String name
	//Given Initial value for global fitting
		variable alphaini = 45//c1: alpha [The vector q1 angle]  [0,pi/2]
		variable ppini = 0.1 //c2: pp [The X shear parameter]
		variable thetaini = 1 //c3: theta [the angle of X shear axis] [0,pi/2]
		variable qq = 0 //C0: the |q| can be fit by the procedure freely
		variable hold = 2 //Not holf |q|

	//Load the value of distorted Q1 (1st quandrant) and Q2 (2nd quandrant)
		variable qx1
		variable qy1
		variable qx2
		variable qy2
		variable tpi = 2*pi

		string cpicka = name+"_QA"
		string cpickb = name+"_QB"
		wave cpickaw = $cpicka
		wave cpickbw = $cpickb

		String qx1_Sdataset = name+"_sdqx1"
		String qy1_Sdataset = name+"_sdqy1"
		String qx2_Sdataset = name+"_sdqx2"
		String qy2_Sdataset = name+"_sdqy2"
		make/N=1/o $qx1_Sdataset,$qy1_Sdataset,$qx2_Sdataset,$qy2_Sdataset
		wave qx1_Sdatasetw = $qx1_Sdataset
		wave qy1_Sdatasetw = $qy1_Sdataset
		wave qx2_Sdatasetw = $qx2_Sdataset
		wave qy2_Sdatasetw = $qy2_Sdataset

		qx1_Sdatasetw[0] = cpickaw[0]*2*pi
		qy1_Sdatasetw[0] = cpickaw[1]*2*pi
		qx2_Sdatasetw[0] = cpickbw[0]*2*pi
		qy2_Sdatasetw[0] = cpickbw[1]*2*pi

	//The wave of dataset name, the single point wave have the value of q1x, q1y, q2x, q2y
		string DataSetsname = name+"_dsname"
		make/T/o/N=(4,2) $DataSetsname
		wave/T DataSetsnamew = $DataSetsname
		DataSetsnamew ={{qx1_Sdataset,qy1_Sdataset,qx2_Sdataset,qy2_Sdataset},{"_calculated_","_calculated_","_calculated_","_calculated_"}}

	//The wave of Fit function name
		string FitFname = name+"_FitFname"
		make/T/o/N=(4,1) $FitFname
		wave/T FitFnamew = $FitFname
		FitFnamew = {"Shear_q1x","Shear_q1y","Shear_q2x","Shear_q2y"} //Fit functions are listed below
			//edit DataSetsnamew
			//edit FitFnamew

	//The coef linkage wave, the row lable {q1x, q1y,q2x,q2y}, coloum lable {FitFunction posiotn, first, last, Numberofcoef, K0, K1, K2, K3}
		string cdslink = name+"_cdslink"
		make/o/N=(4,8) $cdslink
		wave cdslinkw = $cdslink
		cdslinkw = {{0,1,2,3},{0,1,2,3},{0,1,2,3},{4,4,4,4},{0,0,0,0},{1,1,1,1},{2,2,2,2},{3,3,3,3}}
			//4 Fit Function fit to 4 data waves, the coefs are linked for all the 4 data waves.
			//edit cdslinkw

	//The coef wave, input the initial and store the final fitted value.
		string coefinigue = name+"_coefinigue"
		make/o/N=(4,2) $coefinigue
		wave coefiniguew = $coefinigue
		SetDimLabel 1, 1, Hold, coefiniguew
		variable qqini
		if (hold == 1) //choice hold or not the |q|, hold
			if (qq == 0)
				qqini = sqrt(qx1_Sdatasetw[0]^2+qy1_Sdatasetw[0]^2)/2+ sqrt(qx2_Sdatasetw[0]^2+qy2_Sdatasetw[0]^2)/2
			else
				qqini = qq
			endif
		endif

		if (hold == 2) //not hold
			qqini= sqrt(qx1_Sdatasetw[0]^2+qy1_Sdatasetw[0]^2)/2+ sqrt(qx2_Sdatasetw[0]^2+qy2_Sdatasetw[0]^2)/2
		endif
		//c0: qq [the vector length]
		//c1: alpha [The vector q1 angle]  [0,pi/2]
		//variable alphaini = 45*pi/180
		//c2: pp [The X shear parameter]
		//variable ppini = 0.3
		//c3: theta [the angle of X shear axis] [0,pi/2]
		//variable thetaini = 30*pi/180
		STRING testi=Name+"_saveinitials"
		make/n=4/o $testi //Testiw store the initial guess value
		wave testiw =$testi
		testiw={qqini,alphaini*180/pi,ppini,thetaini*180/pi}
		if (hold == 1) //choice hold or not the |q|, hold
			coefiniguew = {{qqini,alphaini,ppini,thetaini},{1,0,0,0}}
		endif
		if (hold == 2) //not hold
			coefiniguew = {{qqini,alphaini,ppini,thetaini},{0,0,0,0}}
		endif
		//The value of coefiniguew will be rewrite after golbal fitting

	//The coef name wave
		string coefn = name+"_coefn"
		make/T/o/N=4 $coefn
		wave/T coefnw = $coefn
		coefnw = {"q_norm","alpha_vector","P_shear","theta_shear"}

	//The constrain wave
		string constrain = name+"_constrain"
		make/T/o/N=4 $constrain
		wave/T constrainw = $constrain
		string k0l,k0h
		k0l="K0 > "+num2str(0.95*qqini)
		k0h="K0 < "+num2str(1.05*qqini)

		if (hold == 2) //Not hold |q|
			constrainw = {k0l,k0h,"K1 >= 0","K1 <= 1.571","K2 > -0.5","K2 < 0.5","K3 >= -1.571","K3 <= 1.571"}
		endif
		if (hold == 1) //hold |q|
			constrainw = {"K1 >= 0","K1 <= 1.571","K2 > -0.5","K2 < 0.5","K3 >= -1.571","K3 <= 1.571"}
		endif

	//Do Global Fit
		DoNewGlobalFit(FitFnamew, DataSetsnamew, cdslinkw, coefiniguew, coefnw, constrainw,NewGFOptionQUIET, 1, 0)

	//Display the results
		//string/G mat3dn_cons
		//string hookfftname =grabwinnonew("Zslice_"+mat3dn_cons+"_FFT_Modula")
		//**/W=$hookfftname


		string coefiniguer = name+"_Fitresult"
		duplicate/o testiw $coefiniguer
		wave coefiniguerw=$coefiniguer

		//edit coefiniguew coefiniguerw testiw coefnw constrainw
		//cktable(winname(0,2))
		string FFTname=name+"_FFT_Modula_INTER"
		string Fitq1x =name+"_Fitq1x"
		string Fitq1y =name+"_Fitq1y"
		string Fitq2x =name+"_Fitq2x"
		string Fitq2y =name+"_Fitq2y"
		make/N=1/o $Fitq1x
		make/N=1/o $Fitq1y
		make/N=1/o $Fitq2x
		make/N=1/o $Fitq2y
		wave Fitq1xw = $Fitq1x
		wave Fitq1yw = $Fitq1y
		wave Fitq2xw = $Fitq2x
		wave Fitq2yw = $Fitq2y
		string FITY="FITY"
		string fitresult=name+"_Fitresult"
		duplicate/o root:packages:NewGlobalfit:$FITY root:$fitresult
		wave fitresultw = $fitresult
		Fitq1xw[0] = fitresultw[0]/(2*pi)
		Fitq1yw[0] = fitresultw[1]/(2*pi)
		Fitq2xw[0] = fitresultw[2]/(2*pi)
		Fitq2yw[0] = fitresultw[3]/(2*pi)
			//edit Fitq1xw Fitq1yw Fitq2xw Fitq2yw
			//print num2str(ckwaveonfig(grabwin(FFTname),Fitq1y))
			//print winname(0,1)
			//print Fitq1y
		if(ckwaveonfig(winname(0,1),Fitq1y)==0)
			appendtograph Fitq1yw vs Fitq1xw
			ModifyGraph mode($Fitq1y)=3,marker($Fitq1y)=8,rgb($Fitq1y)=(0,65535,65535), mrkThick($Fitq1y)=2
		endif
			//if(ckwaveonfig(grabwin(FFTname),Fitq2y)==0)
		if(ckwaveonfig(winname(0,1),Fitq2y)==0)
			appendtograph Fitq2yw vs Fitq2xw
			ModifyGraph mode($Fitq2y)=3,marker($Fitq2y)=8,rgb($Fitq2y)=(0,65535,65535), mrkThick($Fitq2y)=2
		endif

		string Gq1x =name+"_getq1x"
		string Gq1y =name+"_getq1y"
		make/N=1/o $Gq1x
		make/N=1/o $Gq1y
		wave Gq1xw = $Gq1x
		wave Gq1yw = $Gq1y
		if(ckwaveonfig(winname(0,1),Gq1y)==0)
			appendtograph Gq1yw vs Gq1xw
			ModifyGraph mode($Gq1y)=3,marker($Gq1y)=1,rgb($Gq1y)=(0,0,0), mrkThick($Gq1y)=1
		endif

		string Gq2x =name+"_getq2x"
		string Gq2y =name+"_getq2y"
		make/N=1/o $Gq2x
		make/N=1/o $Gq2y
		wave Gq2xw = $Gq2x
		wave Gq2yw = $Gq2y
		if(ckwaveonfig(winname(0,1),Gq2y)==0)
			appendtograph Gq2yw vs Gq2xw
			ModifyGraph mode($Gq2y)=3,marker($Gq2y)=1,rgb($Gq2y)=(0,0,0), mrkThick($Gq2y)=1
		endif
		//edit Gq1xw Gq1yw Gq2xw Gq2yw

		coefiniguerw[0]=coefiniguew[0][0]
		coefiniguerw[1]=coefiniguew[1][0]*180/pi
		coefiniguerw[2]=coefiniguew[2][0]
		coefiniguerw[3]=coefiniguew[3][0]*180/pi
end

//#2_03_01 Extract Shearing: Main called get Q1
Function/Wave GpAarea(nameraw,rangA)
	string nameraw //Name of the layer image
	wave rangA

	string name111 = nameraw+"_FFT_Modula_INTER"
	wave name111w = $name111
	String name1111 = name111+"_f"
	duplicate/o name111w $name1111
	wave name1111w=$name1111
	name1111w=nan;
	CurveFit/Q gauss2D name111w(rangA[0],rangA[1])(rangA[2],rangA[3]) /D=name1111w(rangA[0],rangA[1])(rangA[2],rangA[3]);

	variable xa_G, ya_G, wx,wy
	string W_coef = "W_coef"
	wave W_coefw = $W_coef
	xa_G = W_coefw[2]
	ya_G = W_coefw[4]
	wx = W_coefw[3]
	wy = W_coefw[5]
	String cpickas = nameraw+"_QA"
	make/N=4/o $cpickas
	wave cpicka = $cpickas
	cpicka[0] = xa_G
	cpicka[1] = ya_G
	cpicka[2] = wx
	cpicka[3] = wy
	string Fitq1x =nameraw+"_getq1x"
	string Fitq1y =nameraw+"_getq1y"
	make/N=1/o $Fitq1x
	make/N=1/o $Fitq1y
	wave Fitq1xw = $Fitq1x
	wave Fitq1yw = $Fitq1y
	Fitq1xw[0] = xa_G
	Fitq1yw[0] = ya_G
	if(ckwaveonfig(winname(0,1),Fitq1y)==0)
		appendtograph Fitq1yw vs Fitq1xw
		ModifyGraph mode=3,marker=1,rgb=(65535,65534,49151), mrkThick=1
	endif

	string/G mat3dn_cons
	string hookfftname =grabwinnonew("Zslice_"+mat3dn_cons+"_FFT_Modula")
	if(ckwaveonfig(winname(0,1),Fitq1y)==0)
		appendtograph/W=$hookfftname Fitq1yw vs Fitq1xw
		ModifyGraph/W=$hookfftname mode=3,marker=1,rgb=(65535,65534,49151), mrkThick=1
	endif
	Return cpicka
end

//#2_03_02 Extract Shearing: Main called get Q2
Function/Wave GpBarea(nameraw,rangB)
	string nameraw //Name of the layer image
	wave rangB

	string name111 = nameraw+"_FFT_Modula_INTER"
	wave name111w = $name111
	String name1111 = name111+"_f"
	duplicate/o name111w $name1111
	wave name1111w=$name1111
	name1111w=nan;
	CurveFit/Q gauss2D name111w(rangB[0],rangB[1])(rangB[2],rangB[3]) /D=name1111w(rangB[0],rangB[1])(rangB[2],rangB[3]);

	variable xa_G, ya_G, wx,wy
	string W_coef = "W_coef"
	wave W_coefw = $W_coef
	xa_G = W_coefw[2]
	ya_G = W_coefw[4]
	wx = W_coefw[3]
	wy = W_coefw[5]
	String cpickbs = nameraw+"_QB"
	make/N=4/o $cpickbs
	wave cpickb = $cpickbs
	cpickb[0] = xa_G
	cpickb[1] = ya_G
	cpickb[2] = wx
	cpickb[3] = wy
	//Print "Qb got. Qb = ("+num2str(xa_G)+","+num2str(ya_G)+")"
	//TextBox/C/N=text1/F=0/A=LB/X=0.00/Y=10.00 "Qb got. Qb = ("+num2str(xa_G)+","+num2str(ya_G)+")"
	string Fitq1x =nameraw+"_getq2x"
	string Fitq1y =nameraw+"_getq2y"
	make/N=1/o $Fitq1x
	make/N=1/o $Fitq1y
	wave Fitq1xw = $Fitq1x
	wave Fitq1yw = $Fitq1y
	Fitq1xw[0] = xa_G
	Fitq1yw[0] = ya_G
	if(ckwaveonfig(winname(0,1),Fitq1y)==0)
		appendtograph Fitq1yw vs Fitq1xw
		ModifyGraph mode=3,marker=1,rgb=(65535,65534,49151), mrkThick=1
	endif

	string/G mat3dn_cons
	string hookfftname =grabwinnonew("Zslice_"+mat3dn_cons+"_FFT_Modula")
	if(ckwaveonfig(winname(0,1),Fitq1y)==0)
		appendtograph/W=$hookfftname Fitq1yw vs Fitq1xw
		ModifyGraph/W=$hookfftname mode=3,marker=1,rgb=(65535,65534,49151), mrkThick=1
	endif

	Return cpickb
end

//#2_04_01 Extract Shearing: Main called Interoplate FFT without display
Function ff_3dplotn(name)
	wave name
	func_NaN0(name)
	String FFTout
	FFTout = nameofWave(name) + "_FFT"
	FFT/out=1/WINF=Hanning/DEST=$FFTout cvtcmplx(name)

	Complextorealf1($FFTout,1)
	String FFToutm = FFTout+"_Modula"
	twoDinterpolatexyFFT_3dplotn(FFToutm,10*dimsize($FFTout,0),10*dimsize($FFTout,1))
		String namec
		namec = "c_"+nameofwave(name)
		string FFToutm1 = FFToutm+"1"
		killwaves $FFTout $namec  $FFToutm1 //$FFToutm
end
//#2_04_02 Extract Shearing: Main called Interoplate FFT without display
Function twoDinterpolatexyFFT_3dplotn(name,xpoint,ypoint)
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

	//CheckDisplayed $name2
	//if (V_flag == 1)
	//	print "display;appendimage " + name2+";ModifyGraph width={Plan,1,bottom,left}"
	//else
	//endif
	//killwindow $grabwin2(name2)
	//dilf($name2)
	wavestats/Q $name2
	color3s($name2,30)
	//tilewindows/WINS=winname(0,1)/R/A=(1,1)/w=(29.8,43,63,85)
end


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** {{{{{{{{{{ Here is the start of 3D FFT player }}}}}}}}}}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function PopMenuProc_FFTmode_3dplot(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	String/G FFTWin_3dplot
	variable/G FFTmode_3dplot
	string/G mat3dn_cons
	variable/G zn_cons
	if (popNum == 1) //Magnitude
		FFTmode_3dplot = 3
	endif

	if (popNum == 2) //Phase
		FFTmode_3dplot = 5
	endif

	if (popNum == 3) //Real
		FFTmode_3dplot = 2
	endif

	if (popNum == 4) //Imaginary
		FFTmode_3dplot = nan
	endif

	if (popNum == 5) //Complex
		FFTmode_3dplot = 1
	endif

	variable/G FFTmarque_3dplot
	if (FFTmarque_3dplot == 1)
		DoFFT_3dplot()
	endif
	if (FFTmarque_3dplot == 2)
		DoFFT_3dplot_marquee()
		//string singlespectra = "sgsg_"+mat3dn_cons
		//sumoned(singlespectra,mat3dn_cons,zn_cons)
	endif
End


Function PopMenuProc_FFTwin_3dplot(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string/G mat3dn_cons
	String/G FFTWin_3dplot
	variable/G FFTmode_3dplot
	variable/G zn_cons

	FFTWin_3dplot = popStr

	variable/G FFTmarque_3dplot
	if (FFTmarque_3dplot == 1)
		DoFFT_3dplot()
	endif
	if (FFTmarque_3dplot == 2)
		DoFFT_3dplot_marquee()
		//string singlespectra = "sgsg_"+mat3dn_cons
		//sumoned(singlespectra,mat3dn_cons,zn_cons)
	endif
end
Function ButtonProc_FFTapply_3dplot(ctrlName) : ButtonControl
	String ctrlName

	variable/G FFTmarque_3dplot
	string/G mat3dn_cons
	variable/G zn_cons

	if (FFTmarque_3dplot == 1)
		DoFFT_3dplot()
	endif
	if (FFTmarque_3dplot == 2)
		DoFFT_3dplot_marquee()
		//string singlespectra = "sgsg_"+mat3dn_cons
		//sumoned(singlespectra,mat3dn_cons,zn_cons)
	endif
End



Function DoFFT_3dplot()
	String/G FFTWin_3dplot
	variable/G FFTmode_3dplot

	string/G mat3dn_cons
	wave mat3dw = $mat3dn_cons
	variable/G zn_cons

	variable/G symmode_3dplot
	variable/G GBK2dornot_3dplot
	variable/G GBK2dsigma_3dplot

	//** Auto ordering layer index
		variable zn = zn_cons
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

	string Mode
	string win

	//Set mode
	if(mod(FFTmode_3dplot,1) == 0)
		Mode = "/OUT="+num2str(FFTmode_3dplot)
	else
		Mode = "/OUT=1"
		//this is for imag mode rewrite
	endif

	//Set window
	if(cmpstr(FFTWin_3dplot,"None") == 0)
		win = ""
	elseif (cmpstr(FFTWin_3dplot,"") == 0)
	else
		win = "imagewindow/o "+FFTWin_3dplot+" FFTslicetemp"
	endif

	make/O/N=(dimsize($mat3dn_cons,xn),dimsize($mat3dn_cons,yn)) FFTslicetemp
	setscale/p x,dimoffset($mat3dn_cons,xn),dimdelta($mat3dn_cons,xn),"",FFTslicetemp
	setscale/p y,dimoffset($mat3dn_cons,yn),dimdelta($mat3dn_cons,yn),"",FFTslicetemp


	string FFT3dmatrix = mat3dn_cons+"_FFT3d"
	variable i


	string FFTout = "FFTdesttemp"
	string body
	body = "FFT"+Mode+"/DEST=FFTdesttemp cvtcmplx(FFTslicetemp)"

	//print body

	if(zn_cons == 0)
			make/O/N=(dimsize($mat3dn_cons,zn),dimsize($mat3dn_cons,xn),dimsize($mat3dn_cons,yn)) $FFT3dmatrix

			wave FFT3dmatrixw = $FFT3dmatrix

			i=0
			do
				FFTslicetemp[][] = mat3dw[i][p][q]
				func_naN0(FFTslicetemp)
				execute win
				execute body
				wave FFToutw = $FFTout


				if (GBK2dornot_3dplot == 1)
					FTguassianremover(FFToutw,GBK2dsigma_3dplot)
				endif


				if(mod(FFTmode_3dplot,1) == 0)

					if (dimsize(FFToutw,0) == dimsize(FFToutw,1))
						if (dimdelta(FFToutw,0) == dimdelta(FFToutw,1))

							if (symmode_3dplot == 2)
								D4_sym_3dplot(FFToutw)
							endif

							if (symmode_3dplot == 3)
								Mdiag_sym_3dplot(FFToutw)
							endif

							if (symmode_3dplot == 4)
								Mx_sym_3dplot(FFToutw)
							endif

							if (symmode_3dplot == 5)
								C4_sym_3dplot(FFToutw)
							endif
						endif
					endif

					FFT3dmatrixw[i][][] = FFToutw[p][q]
				else

					Complextoimag(FFToutw)
					if (dimsize(FFToutw,0) == dimsize(FFToutw,1))
						if (dimdelta(FFToutw,0) == dimdelta(FFToutw,1))

							if (symmode_3dplot == 2)
								D4_sym_3dplot(FFToutw)
							endif

							if (symmode_3dplot == 3)
								Mdiag_sym_3dplot(FFToutw)
							endif

							if (symmode_3dplot == 4)
								Mx_sym_3dplot(FFToutw)
							endif

							if (symmode_3dplot == 5)
								C4_sym_3dplot(FFToutw)
							endif
						endif
					endif

					FFT3dmatrixw[i][][] = FFToutw[p][q]
				endif
				i+=1
			while(i<dimsize($mat3dn_cons,zn))
			setscale/p x,dimoffset($mat3dn_cons,zn),dimdelta($mat3dn_cons,zn),"",$FFT3dmatrix
			setscale/p y,dimoffset(FFToutw,0),dimdelta(FFToutw,0),"",$FFT3dmatrix
			setscale/p z,dimoffset(FFToutw,1),dimdelta(FFToutw,1),"",$FFT3dmatrix
			killwaves FFToutw FFTslicetemp
	endif

	if(zn_cons == 1)
			make/O/N=(dimsize($mat3dn_cons,xn),dimsize($mat3dn_cons,zn),dimsize($mat3dn_cons,yn)) $FFT3dmatrix

			wave FFT3dmatrixw = $FFT3dmatrix

			i=0
			do
				FFTslicetemp[][] = mat3dw[p][i][q]
				func_naN0(FFTslicetemp)
				execute win
				execute body
				wave FFToutw = $FFTout

				if (GBK2dornot_3dplot == 1)
					FTguassianremover(FFToutw,GBK2dsigma_3dplot)
				endif



				if(mod(FFTmode_3dplot,1) == 0)

					if (dimsize(FFToutw,0) == dimsize(FFToutw,1))
						if (dimdelta(FFToutw,0) == dimdelta(FFToutw,1))

							if (symmode_3dplot == 2)
								D4_sym_3dplot(FFToutw)
							endif

							if (symmode_3dplot == 3)
								Mdiag_sym_3dplot(FFToutw)
							endif

							if (symmode_3dplot == 4)
								Mx_sym_3dplot(FFToutw)
							endif

							if (symmode_3dplot == 5)
								C4_sym_3dplot(FFToutw)
							endif
						endif
					endif

					FFT3dmatrixw[][i][] = FFToutw[p][q]
				else

					Complextoimag(FFToutw)
					if (dimsize(FFToutw,0) == dimsize(FFToutw,1))
						if (dimdelta(FFToutw,0) == dimdelta(FFToutw,1))

							if (symmode_3dplot == 2)
								D4_sym_3dplot(FFToutw)
							endif

							if (symmode_3dplot == 3)
								Mdiag_sym_3dplot(FFToutw)
							endif

							if (symmode_3dplot == 4)
								Mx_sym_3dplot(FFToutw)
							endif

							if (symmode_3dplot == 5)
								C4_sym_3dplot(FFToutw)
							endif
						endif
					endif


					FFT3dmatrixw[][i][] = FFToutw[p][q]
				endif
				i+=1
			while(i<dimsize($mat3dn_cons,zn))
			setscale/p x,dimoffset(FFToutw,0),dimdelta(FFToutw,0),"",$FFT3dmatrix
			setscale/p y,dimoffset($mat3dn_cons,zn),dimdelta($mat3dn_cons,zn),"",$FFT3dmatrix
			setscale/p z,dimoffset(FFToutw,1),dimdelta(FFToutw,1),"",$FFT3dmatrix
			killwaves FFToutw FFTslicetemp
	endif

	if(zn_cons == 2)
			make/O/N=(dimsize($mat3dn_cons,xn),dimsize($mat3dn_cons,yn),dimsize($mat3dn_cons,zn)) $FFT3dmatrix

			wave FFT3dmatrixw = $FFT3dmatrix

			i=0
			do
				FFTslicetemp[][] = mat3dw[p][q][i]
				func_naN0(FFTslicetemp)
				execute win
				execute body
				wave FFToutw = $FFTout

				if (GBK2dornot_3dplot == 1)
					FTguassianremover(FFToutw,GBK2dsigma_3dplot)
				endif

				if(mod(FFTmode_3dplot,1) == 0)

					if (dimsize(FFToutw,0) == dimsize(FFToutw,1))
						if (dimdelta(FFToutw,0) == dimdelta(FFToutw,1))

							if (symmode_3dplot == 2)
								D4_sym_3dplot(FFToutw)
							endif

							if (symmode_3dplot == 3)
								Mdiag_sym_3dplot(FFToutw)
							endif

							if (symmode_3dplot == 4)
								Mx_sym_3dplot(FFToutw)
							endif

							if (symmode_3dplot == 5)
								C4_sym_3dplot(FFToutw)
							endif
						endif
					endif

					FFT3dmatrixw[][][i] = FFToutw[p][q]
				else

					Complextoimag(FFToutw)

					if (dimsize(FFToutw,0) == dimsize(FFToutw,1))
						if (dimdelta(FFToutw,0) == dimdelta(FFToutw,1))

							if (symmode_3dplot == 2)
								D4_sym_3dplot(FFToutw)
							endif

							if (symmode_3dplot == 3)
								Mdiag_sym_3dplot(FFToutw)
							endif

							if (symmode_3dplot == 4)
								Mx_sym_3dplot(FFToutw)
							endif

							if (symmode_3dplot == 5)
								C4_sym_3dplot(FFToutw)
							endif
						endif
					endif

					FFT3dmatrixw[][][i] = FFToutw[p][q]
				endif
				i+=1
			while(i<dimsize($mat3dn_cons,zn))
			setscale/p x,dimoffset(FFToutw,0),dimdelta(FFToutw,0),"",$FFT3dmatrix
			setscale/p y,dimoffset(FFToutw,1),dimdelta(FFToutw,1),"",$FFT3dmatrix
			setscale/p z,dimoffset($mat3dn_cons,zn),dimdelta($mat3dn_cons,zn),"",$FFT3dmatrix
			//killwaves FFToutw FFTslicetemp
	endif

	execute "d3dfft()"
end


Function Complextoimag(name1w)
	wave name1w
	string name
	string name1 = nameOfWave(name1w)

	name=name1+"_Imag"
	make/o/N=(dimsize(name1w,0),dimsize(name1w,1)) $name
	wave namew = $name
	namew=imag(name1w)
	setscale/i x,dimoffset(name1w,0),dimoffset(name1w,0)+dimdelta(name1w,0)*(dimsize(name1w,0)-1),"",namew
	setscale/i y,dimoffset(name1w,1),dimoffset(name1w,1)+dimdelta(name1w,1)*(dimsize(name1w,1)-1),"",namew
	duplicate/o namew name1w
	killwaves namew
end

Proc d3dfft()
	string/G mat3dn_cons
	string mat3dn = mat3dn_cons+"_FFT3d"
	string mat3dn_consf = mat3dn
	variable/G zn_cons  //the Energy in which dimension?
	variable/G z_cons
	String/G FFTWin_3dplot
	variable/G FFTmode_3dplot
	variable/G colorratio_consFFT
	//** Auto ordering layer index
		variable zn = zn_cons
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

	//** Scaling the layer to show
		string slicename = "Zslice_"+mat3dn_consf
		make/o/N=(dimsize($mat3dn_consf,xn),dimsize($mat3dn_consf,yn)) $slicename
		setscale/p x,dimoffset($mat3dn_consf,xn),dimdelta($mat3dn_consf,xn),"",$slicename
		setscale/p y,dimoffset($mat3dn_consf,yn),dimdelta($mat3dn_consf,yn),"",$slicename

	//** Generate the average curve
		variable Z_constp=(z_cons-dimoffset($mat3dn_cons,zn_cons))/dimdelta($mat3dn_cons,zn_cons)

		string singlespectra = "sgsg_"+mat3dn_cons+"_FFT3d"
		sumoned(singlespectra,mat3dn_consf,zn)

		string Zpp = "Zpp_"+mat3dn_consf
		make/o/n=(2) $Zpp
		setscale/I x,wavemin($singlespectra),wavemax($singlespectra),"",$Zpp
		$Zpp=z_cons

	//** Generate layer image
		if(zn_cons == 0)
			$slicename[][]=$mat3dn_consf[Z_constp][p][q]
		endif
		if(zn_cons == 1)
			$slicename[][]=$mat3dn_consf[p][Z_constp][q]
		endif
		if(zn_cons == 2)
			$slicename[][]=$mat3dn_consf[p][q][Z_constp]
		endif

	//** Display layer image
		dilf($slicename)

		if (FFTmode_3dplot == 5)
			ModifyImage $slicename ctab= {*,*,VioletOrangeYellow,1}
		else
			color3s_for3dinv($slicename,colorratio_consFFT)
		endif
		modifygraph width=300,height=300
		ModifyGraph width={Plan,1,bottom,left}
		SetAxis bottom dimoffset($slicename,0),dimoffset($slicename,0)+(dimsize($slicename,0)-1)*dimdelta($slicename,0)
		SetAxis left dimoffset($slicename,1),dimoffset($slicename,1)+(dimsize($slicename,1)-1)*dimdelta($slicename,1)

	//** Make subwindow to show average curve
		Dowindow/F $grabwin(slicename)
		ModifyGraph margin(bottom)=144
		variable subn = itemsInList(childWindowList(grabwinnonew(slicename)))
		if (subn == 0)
		else
			killwindow $winname(0,1)+"#G0"
		endif
		Display/HOST=#/W=(0,0.7,1,1)  $singlespectra
		ModifyGraph/W=$(grabwin(slicename)+"#"+stringFromList(0,childWindowList(grabwin(slicename))))  rgb($singlespectra)=(52428,52428,52428)
		appendtoGraph/W=$(grabwin(slicename)+"#"+stringFromList(0,childWindowList(grabwin(slicename))))/VERT $Zpp
		ModifyGraph/W=$(grabwin(slicename)+"#"+stringFromList(0,childWindowList(grabwin(slicename)))) lsize($Zpp)=2,rgb($Zpp)=(0,0,0),nticks(bottom)=10,minor(bottom)=1
		SetActiveSubwindow ##
	//** SetVariable of Layer energy
		SetVariable setvarz_cons win=$grabwin(slicename),title="Z",size={65,14},value=z_cons,proc=SetVarProc_Cons3dplotf
		SetVariable setvarz_cons win=$grabwin(slicename),limits={dimoffset($mat3dn_consf,zn_cons),(dimoffset($mat3dn_consf,zn_cons)+dimdelta($mat3dn_consf,zn_cons)*(dimsize($mat3dn_consf,zn_cons)-1)),dimdelta($mat3dn_consf,zn_cons)}

	//** Knob to launch linecut
		Button launchLinecutf win=$grabwin(slicename),title="Linecut FFT",size={82,14},pos={70,1},fSize=10,proc=ButtonProc_Cons3dplotlcf

	//** Cursor moving sts
		Cursor/W=$grabwin(slicename)/P/I/C=(1,65535,33232)/T=6 A $slicename 0,0
		//ShowInfo
		getsinglestsf($mat3dn_consf,0,0,zn_cons)

		string ssn = "sts_"+mat3dn_consf
		//display $ssn
		appendtoGraph/W=$(grabwin(slicename)+"#"+stringFromList(0,childWindowList(grabwin(slicename))))/R $ssn
		SetWindow $grabwin(slicename) hook(myHook)=myCursorMovedHookf
		UpdateControls_3dpf(slicename, "A", 0,0)

	//** Knob to append Magnitude FFT

		PopupMenu appendtordf win=$grabwin(slicename),value="Remove;Magnitude" ,pos={1,16},bodyWidth=25,title="Append",proc=PopMenuProc_appendimagef

	//** Knob for jump remover
		variable/G jr_3dplot = 1
		PopupMenu jumpremoveon3d win=$grabwin(slicename),value="Jump remover Off;Jump remover On",bodyWidth=110,pos={1,315},proc=PopMenuProc_jumpremover3d
	//** PI NORM
		variable/G pinorm_3dplot = 0
		SetVariable pinorm_3d title="π norm",size={60,14},pos={49,334},value=pinorm_3dplot,proc=SetVarProc_pinorm_3dplot,limits={0,1,1}

	//** Set color scale
		SetVariable setvarz_csfft win=$grabwin(slicename),title="σ",size={65,14},pos={1,75},value=colorratio_consFFT,limits={1,inf,1},proc=SetVarProc_colorratio_consFFT

	//** Norm sts by average curve
		variable/G normfft_3dplot = 1
		PopupMenu stsnormfft win=$grabwin(slicename),value="Norm Off;Norm On",bodyWidth=110,pos={113,315},proc=PopMenuProc_stsnormfft


		Button sumZ win=$grabwin(slicename),title="Sum(E)",pos={2,92},size={50,14},fSize=10,proc=ButtonProc_SumlayerFFT3Dc
	//** Tile window
		tilewindows/Wins=grabwin(slicename)/R/w=(56.5,0,83,85)/A=(1,1)
		tilewindows/Wins=grabwin("Zslice_"+mat3dn_cons)/R/w=(3,0,83,85)/A=(1,1)
		//Dowindow/F $grabwin(slicename)
end

Function PopMenuProc_stsnormfft(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	variable/G jr_3dplot
	variable/G normfft_3dplot

	normfft_3dplot = popNum

	string/G mat3dn_cons
	string mat3dn = mat3dn_cons+"_FFT3d"
	string mat3dn_consf = mat3dn
	variable/G zn_cons  //the Energy in which dimension?
	variable/G z_cons
	getsinglestsf($mat3dn_consf,pcsr(A),qcsr(A),zn_cons)
end


Function SetVarProc_pinorm_3dplot(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G pinorm_3dplot

	variable/G jr_3dplot

	string/G mat3dn_cons
	string mat3dn = mat3dn_cons+"_FFT3d"
	string mat3dn_consf = mat3dn
	variable/G zn_cons  //the Energy in which dimension?
	variable/G z_cons
	getsinglestsf($mat3dn_consf,pcsr(A),qcsr(A),zn_cons)
end
//
Function PopMenuProc_jumpremover3d(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	variable/G jr_3dplot
	jr_3dplot = popNum

	string/G mat3dn_cons
	string mat3dn = mat3dn_cons+"_FFT3d"
	string mat3dn_consf = mat3dn
	variable/G zn_cons  //the Energy in which dimension?
	variable/G z_cons
	getsinglestsf($mat3dn_consf,pcsr(A),qcsr(A),zn_cons)
end

Function getsinglestsf(name,pp,qq,zn)
	wave name
	variable pp
	variable qq
	variable zn
	//** Auto ordering layer index
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
	string ssn = "sts_"+nameofwave(name)
	make/N=(dimsize(name,zn))/O $ssn
	setscale/p x,dimoffset(name,zn),dimdelta(name,zn),"",$ssn
	wave ssnw = $ssn
	//** Generate sts
		if(zn == 0)
			ssnw[] = name[p][pp][qq]
		endif
		if(zn == 1)
			ssnw[] = name[pp][p][qq]
		endif
		if(zn == 2)
			ssnw[] = name[pp][qq][p]
		endif
	//**
	variable/G jr_3dplot

	if(jr_3dplot == 2)
		autoremovejump1D(ssnw,2,2*pi,1.2*pi)
	endif
	variable/G pinorm_3dplot
	if (	pinorm_3dplot == 1)
		ssnw/=pi
		wavestats/Q ssnw
		ssnw-=V_min
		//Label/W=$grabwinchild() right "\\Z16 θ (π)"
	endif

	variable/G normfft_3dplot
	string/G mat3dn_cons
	string singlespectra = "sgsg_"+mat3dn_cons+"_FFT3d"
	wave singlespectraw = $singlespectra
	if(normfft_3dplot == 2)
		ssnw/=singlespectraw
	endif


end
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** {{{{{{{{{{ Dsiplay 3D matrix by selected layer:control function }}}}}}}}}}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function SetVarProc_Cons3dplotf(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	string/G mat3dn_cons
	string mat3dn = mat3dn_cons+"_FFT3d"
	string mat3dn_consf = mat3dn
	variable/G zn_cons  //the Energy in which dimension?
	variable/G z_cons

	Cons3dplotc()
	Cons3dplotcf()

End

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** {{{{{{{{{{ Update layer }}}}}}}}}}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function Cons3dplotcf()

	string/G mat3dn_cons
	string mat3dn = mat3dn_cons+"_FFT3d"
	string mat3dn_consf = mat3dn
	variable/G zn_cons  //the Energy in which dimension?
	variable/G z_cons

	variable/G colorratio_consFFT
	variable/G FFTmode_3dplot
	wave mat3dnw = $mat3dn_consf
	variable Z_constp=(z_cons-dimoffset(mat3dnw,zn_cons))/dimdelta(mat3dnw,zn_cons)


	string slicename = "Zslice_"+mat3dn_consf
	wave slicenamew =$slicename

	if(zn_cons == 0)
		slicenamew[][]=mat3dnw[Z_constp][p][q]
	endif
	if(zn_cons == 1)
		slicenamew[][]=mat3dnw[p][Z_constp][q]
	endif
	if(zn_cons == 2)
		slicenamew[][]=mat3dnw[p][q][Z_constp]
	endif

	if (FFTmode_3dplot == 5)
		ModifyImage $slicename ctab= {*,*,VioletOrangeYellow,0}
	else
		color3s_for3dinv($slicename,colorratio_consFFT)
	endif




	//** Indicative line
	string Zpp = "Zpp_"+mat3dn_consf
	wave zppw = $zpp
	Zppw=z_cons
end
/////////////////////////////////////////////////////////////////////////////////////////////////
Function myCursorMovedHookf(s)
	STRUCT WMWinHookStruct &s
	Variable statusCode= 0
	strswitch( s.eventName )
		case "cursormoved":
			// see "Members of WMWinHookStruct Used with cursormoved Code"
			UpdateControls_3dpf(s.traceName, s.cursorName, s.pointNumber, s.yPointNumber)
			UpdateControls_3dp(s.traceName, s.cursorName, s.pointNumber, s.yPointNumber)
			break
	endswitch
	return statusCode
End

Function UpdateControls_3dpf(traceName, cursorName, pointNumber, yPointNumber)
	String traceName, cursorName
	Variable pointNumber,yPointNumber
	string/G mat3dn_cons
	variable/G zn_cons
	variable/G pointNumberx_3dp = pointNumber
	variable/G PointNumbery_3dp = yPointNumber

	string/G mat3dn_cons
	string mat3dn = mat3dn_cons+"_FFT3d"
	string mat3dn_consf = mat3dn
	variable/G zn_cons  //the Energy in which dimension?
	variable/G z_cons
	getsinglestsf($mat3dn_consf,pointNumber,yPointNumber,zn_cons)

	//Update the FFT cursor if displayed
		string fftslice = "Zslice_"+mat3dn_cons
		wave fftslicew = $fftslice

		if (waveexists(fftslicew) == 0)
		else
			checkDisplayed/W=$grabwinnonew(fftslice) fftslicew
			if (V_flag == 1)
				Cursor/W=$grabwin(fftslice)/P/I/C=(1,65535,33232)/T=6 A $fftslice pointNumberx_3dp,PointNumbery_3dp
			endif
		endif
End


Function PopMenuProc_appendimagef(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string/G mat3dn_cons
	string mat3dn = mat3dn_cons+"_FFT_Modula"
	string mat3dn_consf = mat3dn
	variable/G zn_cons  //the Energy in which dimension?
	variable/G z_cons

	string slicename = "Zslice_"+mat3dn_consf
	string Tr = slicename

	string listcheck = wavelist("*",";","Win:"+grabwinnonew(slicename))+"1"
	//print listcheck
	string W_coef = "W_coef"
	variable lc,lh
	variable sigma

	if (popNum == 1)
		if (cmpstr(StringByKey(tr,listcheck,";"),"") == 1)
			removeimage $Tr
		endif
	endif
	if (popNum == 2)

		if (cmpstr(StringByKey(tr,listcheck,";"),"") == 1)
			removeimage $Tr
		endif
		Appendimage $Tr
		gethistgram_npcolor(Tr)
		wave W_coefw = $W_coef
		sigma = sqrt(2)*W_coefw[3]

		wavestats/Q $Tr
		if (W_coefw[2]-0.5*30*sigma >V_min)
			lc = W_coefw[2]-0.5*30*sigma
		else
			lc =V_min
		endif
		if (W_coefw[2]+0.5*30*sigma < V_max)
			lh = W_coefw[2]+0.5*30*sigma
		else
			lh =V_max
		endif

		ModifyImage $Tr ctab= {lc,lh,VioletOrangeYellow,0}
	endif
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

Function/s grabwin_sfft(name)
	string name
 	string fulllist = WinList("*", ";","WIN:1")
	string nn,waveong,cmdn,out
	out = ""
	variable i
	for(i=0; i<itemsinlist(fulllist); i +=1)
        nn= stringfromlist(i, fulllist)
        cmdn="WIN:"+nn
        waveong = stringfromlist(0,WaveList("*", ";",cmdn))  //Only detect the first element.
        if (CmpStr(name,waveong) == 0)
        	out = nn
        else
        endif
    endfor

    if (cmpstr(out,"") == 0)
    	if (exists(name) == 1)
    		wave namew = $name

    		di(namew)

    		out = winname(0,1)
			tilewindows/Wins=winname(0,1)/R/w=(55.5,0,83,40)/A=(1,1)
			Dowindow/F $winname(1,1)
    	endif
    endif
    Return out
end


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** {{{{{{{{{{ Launch arbitary Linecut extraction }}}}}}}}}}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Cons3dplotlcf(ctrlName) : ButtonControl
	String ctrlName
	string/G mat3dn_cons

	string mat3dn_consf = mat3dn_cons+"_FFT3d"


	variable/G zn_cons
	string slicename = "Zslice_"+mat3dn_consf

	variable/G angle_3dplot=0
	variable/G addY_3dplot=0
	variable/G addX_3dplot=0
	variable/G normornot_3dplot =1
	variable/G smornot_3dplot =0

	//** Auto ordering layer index
		make/o/N=3 ordernum ={0,1,2}
		ordernum=abs(ordernum-zn_cons)
		wavestats/Q ordernum
		ordernum={0,1,2}
		DeletePoints V_minloc,1, ordernum
		wavestats/Q ordernum
		variable xn = ordernum[V_minloc]
		variable yn = ordernum[V_maxloc]
		killwaves ordernum

	//** append H indicating line (Blue)
		variable qqs,qqe,pps,ppe,xxs,xxe,yys,yye
		variable Nx,Ny,Nz
		Nx = dimsize($mat3dn_consf,xn)
		Ny = dimsize($mat3dn_consf,yn)
		Nz = dimsize($mat3dn_consf,zn_cons)
		pps=findstartppf(mat3dn_consf,angle_3dplot,zn_cons,addY_3dplot)
		ppe=findendppf(mat3dn_consf,angle_3dplot,zn_cons,addY_3dplot)
		xxs = dimoffset($mat3dn_consf,xn)+pps*dimdelta($mat3dn_consf,xn)
		xxe = dimoffset($mat3dn_consf,xn)+ppe*dimdelta($mat3dn_consf,xn)
		qqs = round(tan(angle_3dplot*pi/180)*(pps-round(Nx/2))+round(Ny/2)+addY_3dplot)
		qqe = round(tan(angle_3dplot*pi/180)*(ppe-round(Nx/2))+round(Ny/2)+addY_3dplot)
		yys = dimoffset($mat3dn_consf,yn)+qqs*dimdelta($mat3dn_consf,yn)
		yye = dimoffset($mat3dn_consf,yn)+qqe*dimdelta($mat3dn_consf,yn)

		string linetest="linetest_"+mat3dn_consf
		make/N=2/o $linetest
		wave linetestw =$linetest
		linetestw={yys,yye}
		setscale/I x, xxs,xxe,"",linetestw
		appendtograph/W=$grabwin(slicename) linetestw
		ModifyGraph/W=$grabwin(slicename) lsize($linetest)=2,rgb($linetest)=(0,0,65535)

	//** append V indicating line (Green)**************
		variable qqsv,qqev,ppsv,ppev,xxsv,xxev,yysv,yyev
		qqsv=findstartqqf(mat3dn_consf,angle_3dplot,zn_cons,addX_3dplot)
		qqev=findendqqf(mat3dn_consf,angle_3dplot,zn_cons,addX_3dplot)
		yysv = dimoffset($mat3dn_consf,yn)+qqsv*dimdelta($mat3dn_consf,yn)
		yyev = dimoffset($mat3dn_consf,yn)+qqev*dimdelta($mat3dn_consf,yn)
		ppsv = round(tan(-angle_3dplot*pi/180)*(qqsv-round(Ny/2))+round(Nx/2)+addX_3dplot)
		ppev = round(tan(-angle_3dplot*pi/180)*(qqev-round(Ny/2))+round(Nx/2)+addX_3dplot)
		xxsv = dimoffset($mat3dn_consf,xn)+ppsv*dimdelta($mat3dn_consf,xn)
		xxev = dimoffset($mat3dn_consf,xn)+ppev*dimdelta($mat3dn_consf,xn)

		string linetestv="linetestv_"+mat3dn_consf
		make/N=2/o $linetestv
		wave linetestvw = $linetestv
		linetestvw={yysv,yyev}
		if(abs(angle_3dplot) < 0.1)
			if(addX_3dplot ==0)
				setscale/I x, 0,0.0000001,"",linetestvw
			else
				setscale/I x, xxsv,1.0000001*xxsv,"",linetestvw
			endif
		else
			setscale/I x, xxsv,xxev,"",linetestvw
		endif
		appendtograph/W=$grabwin(slicename) linetestvw
		ModifyGraph/W=$grabwin(slicename) lsize($linetestv)=2,rgb($linetestv)=(16385,65535,41303)

	//**SetVar of Rotation
		SetVariable setvarangle win=$grabwin(slicename),title="Rotate",size={65,14},value=angle_3dplot,proc=SetVarProc_rotate3dplotf,pos={159,1}
		SetVariable setvarangle win=$grabwin(slicename),limits={-89,89,1}

	//**SetVar of AddY [set the Yrange(angel) by auto search]
		SetVariable setaddY win=$grabwin(slicename),title="LH",size={65,14},value=addY_3dplot,proc=SetVarProc_addY3dplotf,pos={225,1}
		duplicate/o findrangeforangle_LHf(mat3dn_consf,angle_3dplot,zn_cons) rotateYlimit
		SetVariable setaddY win=$grabwin(slicename),limits={rotateYlimit[0],rotateYlimit[1],1}

	//**SetVar of AddX [set the Xrange(angel) by auto search]
		SetVariable setaddX win=$grabwin(slicename),title="LV",size={65,14},value=addX_3dplot,proc=SetVarProc_addX3dplotf,pos={292,1}
		duplicate/o findrangeforangle_LVf(mat3dn_consf,angle_3dplot,zn_cons) rotateXlimit
		SetVariable setaddX win=$grabwin(slicename),limits={rotateXlimit[0],rotateXlimit[1],1}

	//**Extract LinecutH and make graph
		anglelinecutHf(mat3dn_consf,angle_3dplot,zn_cons,addY_3dplot,normornot_3dplot,smornot_3dplot)
		string linecutH = "LH_"+mat3dn_consf
		di($linecutH)
		variable/G FFTmode_3dplot
		if (FFTmode_3dplot == 5)
			ModifyImage $linecutH ctab= {*,*,VioletOrangeYellow,1}
		else
			color3s_for3dFFT($linecutH,30)
		endif
		Modifygraph/W=$grabwinnonew(linecutH) width=400, height=200
		Label left "\\Z16\\F'times'\\f02E - E\\BF\\f00\\M\\F'times'\\Z16 (meV)"
		Label bottom "\\Z16\\f02k\\f00 (2π Å\\S\\Z10-1\\M\\Z16)"

		ModifyGraph/W=$grabwinnonew(linecutH) axThick=3,axRGB=(0,0,65535),tlblRGB=(0,0,65535),alblRGB=(0,0,65535)
		tilewindows/WINS=grabwinnonew(linecutH)/R/w=(56,34,100,100)/A=(1,1)
		//Modifygraph/W=$grabwinnonew(linecutH) width=0, height=0
		//slicesMDC($linecutH)

	//**Extract LinecutV and make graph
		anglelinecutVf(mat3dn_consf,angle_3dplot,zn_cons,addX_3dplot,normornot_3dplot,smornot_3dplot)
		string linecutV = "LV_"+mat3dn_consf
		di($linecutV)
		if (FFTmode_3dplot == 5)
			ModifyImage $linecutV ctab= {*,*,VioletOrangeYellow,1}
		else
			color3s_for3dFFT($linecutV,30)
		endif
		Modifygraph/W=$grabwinnonew(linecutV) width=400, height=200
		Label left "\\Z16\\F'times'\\f02E - E\\BF\\f00\\M\\F'times'\\Z16 (meV)"
		Label bottom "\\Z16\\f02k\\f00 (2π Å\\S\\Z10-1\\M\\Z16)"

		ModifyGraph/W=$grabwinnonew(linecutV) axThick=3,axRGB=(16385,65535,41303),tlblRGB=(16385,65535,41303),alblRGB=(16385,65535,41303)
		tilewindows/WINS=grabwinnonew(linecutV)/R/w=(56,0,100,30)/A=(1,1)



	//** Control of Advanced Modes
		popupmenu popselectmode3d win=$grabwin(slicename), pos={1,36},bodyWidth=65,proc=PopMenuProc_selmode3dplotf,value="2Point;FreeHand;Circular",bodyWidth=68
		Button Bfreehandprofile3d win=$grabwin(slicename), title="Go",proc=ButtonProc_L3dplotdof,size={30,15},fSize=11,pos={35,56}


	//** Tile window
		//tilewindows/WINS=WinList("*", ";","WIN:1")/R/w=(3,0,92,100)/A=(2,4)


end


////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//** INTERACTING FUNCTIONAL: Control Function
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//##01
//** Control Function:Change addY,
//** Call to change LinecutH and change the indicative line
Function SetVarProc_addY3dplotf(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	string/G mat3dn_cons
	variable/G zn_cons
	variable/G angle_3dplot
	variable/G addY_3dplot
	variable/G addX_3dplot
	variable/G normornot_3dplot
	variable/G smornot_3dplot

	string mat3dn_consf = mat3dn_cons+"_FFT3d"


	anglelinecutHf(mat3dn_consf,angle_3dplot,zn_cons,addY_3dplot,normornot_3dplot,smornot_3dplot)
	angleline_3dpf()
	//string linecutH = "LH_"+mat3dn_consf
	//slicesMDC($linecutH)
end
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//##02
//** Control Function:Change addX,
//** Call to change LinecutH and change the indicative line
Function SetVarProc_addX3dplotf(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	string/G mat3dn_cons
	variable/G zn_cons
	variable/G angle_3dplot
	variable/G addY_3dplot
	variable/G addX_3dplot
	variable/G normornot_3dplot
	variable/G smornot_3dplot

	string mat3dn_consf= mat3dn_cons+"_FFT3d"

	anglelinecutVf(mat3dn_consf,angle_3dplot,zn_cons,addX_3dplot,normornot_3dplot,smornot_3dplot)
	angleline_3dpf()
	//string linecutH = "LH_"+mat3dn_consf
	//slicesMDC($linecutH)
end

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//##03
//** Control Function:Change Rotation,
//** Call to change LinecutH, LinecutV and change the indicative line, and Setvariable range setaddX/setaddY
Function SetVarProc_rotate3dplotf(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	string/G mat3dn_cons
	variable/G zn_cons
	variable/G angle_3dplot
	variable/G addY_3dplot
	variable/G addX_3dplot
	variable/G normornot_3dplot
	variable/G smornot_3dplot

	string mat3dn_consf= mat3dn_cons+"_FFT3d"

	string slicename = "Zslice_"+mat3dn_consf

	//Update Linecut
		anglelinecutHf(mat3dn_consf,angle_3dplot,zn_cons,addY_3dplot,normornot_3dplot,smornot_3dplot)
		anglelinecutVf(mat3dn_consf,angle_3dplot,zn_cons,addX_3dplot,normornot_3dplot,smornot_3dplot)

	//Update indicative line
		angleline_3dpf()

	//Reset the range for addY
		duplicate/o findrangeforangle_LHf(mat3dn_consf,angle_3dplot,zn_cons) rotateYlimit
		SetVariable setaddY win=$grabwin(slicename),limits={rotateYlimit[0],rotateYlimit[1],1}

	//Reset the range for addX
		duplicate/o findrangeforangle_LVf(mat3dn_consf,angle_3dplot,zn_cons) rotateXlimit
		SetVariable setaddX win=$grabwin(slicename),limits={rotateXlimit[0],rotateXlimit[1],1}

		//string linecutH = "LH_"+mat3dn_consf
		//slicesMDC($linecutH)
end


////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//** INTERACTING FUNCTIONAL: Update indicative lines
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function angleline_3dpf()
	string/G mat3dn_cons
	variable/G zn_cons

	string mat3dn_consf= mat3dn_cons+"_FFT3d"

	string slicename = "Zslice_"+mat3dn_consf

	variable/G angle_3dplot
	variable/G addY_3dplot
	variable/G addX_3dplot

	//** Auto ordering layer index
		make/o/N=3 ordernum ={0,1,2}
		ordernum=abs(ordernum-zn_cons)
		wavestats/Q ordernum
		ordernum={0,1,2}
		DeletePoints V_minloc,1, ordernum
		wavestats/Q ordernum
		variable xn = ordernum[V_minloc]
		variable yn = ordernum[V_maxloc]
		killwaves ordernum

	//** The part for horizental line (blue)
		variable qqs,qqe,pps,ppe,xxs,xxe,yys,yye
		variable Nx,Ny,Nz
		Nx = dimsize($mat3dn_consf,xn)
		Ny = dimsize($mat3dn_consf,yn)
		Nz = dimsize($mat3dn_consf,zn_cons)
		pps=findstartppf(mat3dn_consf,angle_3dplot,zn_cons,addY_3dplot)
		ppe=findendppf(mat3dn_consf,angle_3dplot,zn_cons,addY_3dplot)
		xxs = dimoffset($mat3dn_consf,xn)+pps*dimdelta($mat3dn_consf,xn)
		xxe = dimoffset($mat3dn_consf,xn)+ppe*dimdelta($mat3dn_consf,xn)
		qqs = round(tan(angle_3dplot*pi/180)*(pps-round(Nx/2))+round(Ny/2)+addY_3dplot)
		qqe = round(tan(angle_3dplot*pi/180)*(ppe-round(Nx/2))+round(Ny/2)+addY_3dplot)
		yys = dimoffset($mat3dn_consf,yn)+qqs*dimdelta($mat3dn_consf,yn)
		yye = dimoffset($mat3dn_consf,yn)+qqe*dimdelta($mat3dn_consf,yn)

		string linetest="linetest_"+mat3dn_consf
		wave linetestw = $linetest
		//make/N=2/o linetest
		linetestw={yys,yye}
		setscale/I x, xxs,xxe,"",linetestw

	//** The part for vertical line (white)
		variable qqsv,qqev,ppsv,ppev,xxsv,xxev,yysv,yyev
		qqsv=findstartqqf(mat3dn_consf,angle_3dplot,zn_cons,addX_3dplot)
		qqev=findendqqf(mat3dn_consf,angle_3dplot,zn_cons,addX_3dplot)
		yysv = dimoffset($mat3dn_consf,yn)+qqsv*dimdelta($mat3dn_consf,yn)
		yyev = dimoffset($mat3dn_consf,yn)+qqev*dimdelta($mat3dn_consf,yn)
		ppsv = round(tan(-angle_3dplot*pi/180)*(qqsv-round(Ny/2))+round(Nx/2)+addX_3dplot)
		ppev = round(tan(-angle_3dplot*pi/180)*(qqev-round(Ny/2))+round(Nx/2)+addX_3dplot)
		xxsv = dimoffset($mat3dn_consf,xn)+ppsv*dimdelta($mat3dn_consf,xn)
		xxev = dimoffset($mat3dn_consf,xn)+ppev*dimdelta($mat3dn_consf,xn)

		string linetestv="linetestv_"+mat3dn_consf
		wave linetestvw = $linetestv
		//make/N=2/o linetest
		linetestvw={yysv,yyev}
		if(abs(angle_3dplot) < 0.1)
			if (addX_3dplot == 0)
				setscale/I x, xxsv,0.0000001,"",linetestvw
			else
				setscale/I x, xxsv,1.0000001*xxsv,"",linetestvw
			endif
		else
			setscale/I x, xxsv,xxev,"",linetestvw
		endif
end



////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//** INTERACTING FUNCTIONAL: Extract rotated Horizental Linecut
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//%%%%%%%%%%%%** get rotated H-linecut, addY here is counted from center.
//%%%%%%%%%%%%** H-linecut can move in Y direction, addY is DQ(Int)
////////////////////////////////////////////////////////////////////////////////////////////////////////////

//*****************************************************
//## 01
//** Main Function
Function anglelinecutHf(mat,angle,Zn,addY,normornot,smornot)
	String mat
	variable angle
	variable Zn
	variable addY
	variable normornot
	variable smornot
	//** Auto ordering layer index
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

	//** Initial layer dimsize
		wave matw = $mat
		variable Nx,Ny,Nz
		Nx = dimsize(matw,xn)
		Ny = dimsize(matw,yn)
		Nz = dimsize(matw,zn)
		variable pp, qq

	//** Determine Limit for Assignment Loop
		variable qqs,qqe,pps,ppe,xxs,xxe,yys,yye  //** qq = tan(angle*pi/180)*(pp-round(Nx/2))+round(Ny/2)+addY

		//** Determine the First and Last P when extracting the rotated Linecut
			pps=findstartppf(mat,angle,Zn,addY) //** First P at certain Rotation[angle] and shift[addY]
			ppe=findendppf(mat,angle,Zn,addY)   //** Last P at certain Rotation[angle] and shift[addY]

		//** Calculate Q and X, Y
			xxs = dimoffset(matw,xn)+pps*dimdelta(matw,xn)
			xxe = dimoffset(matw,xn)+ppe*dimdelta(matw,xn)
			qqs = round(tan(angle*pi/180)*(pps-round(Nx/2))+round(Ny/2)+addY)
			qqe = round(tan(angle*pi/180)*(ppe-round(Nx/2))+round(Ny/2)+addY)
			yys = dimoffset(matw,yn)+qqs*dimdelta(matw,yn)
			yye = dimoffset(matw,yn)+qqe*dimdelta(matw,yn)

		//** Calculate Linecut Scale
			variable len = sqrt((xxe-xxs)^2+(yye-yys)^2)
			string linecutH = "LH_"+mat
			//make/N=(Nz,(ppe-pps+1))/o $linecutH
			make/N=((ppe-pps+1),Nz)/o $linecutH
			wave linecutHw = $linecutH
			setscale/p y,dimoffset(matw,zn),dimdelta(matw,zn),"",linecutHw
			setscale/i x,xxs,xxs+len,"",linecutHw
	//** Extract value from 3D matrix
		//** The value assignment loop is runing along P
		variable i
		i=0
		pp=pps
		do
			qq= round(tan(angle*pi/180)*(pp-round(Nx/2))+round(Ny/2)+addY) //[Formula of Rotated HLine]
			//linecutHw[][i] = matw[pp][qq][p]
			if(zn == 0)
				linecutHw[i][] = matw[q][pp][qq]
			endif
			if(zn == 1)
				linecutHw[i][] = matw[pp][q][qq]
			endif
			if(zn == 2)
				linecutHw[i][] = matw[pp][qq][q]
			endif
			pp+=1
			i+=1
		while(pp < ppe+1)
		//di(linecutHw)

	//** Shift the zero for FFT linecut
	string slicename = "Zslice_"+mat
	wave slicenamew = $slicename
	variable kk = (yys-yye)/(xxs-xxe)
	variable bb = yys-kk*xxs
	variable zx,zy
	zx = -(bb*kk)/(kk^2+1)
	zy = bb/(kk^2+1)
	variable zp,zq
	zp = round((zx-dimoffset(slicenamew,0))/dimdelta(slicenamew,0))
	zq = round((zy-dimoffset(slicenamew,1))/dimdelta(slicenamew,1))
	variable dimoff = dimoffset(linecutHw,0)
	variable dimdel = dimdelta(linecutHw,0)
	variable correcteddimoffset = -(zp-pps)*dimdel
	setscale/p x,correcteddimoffset,dimdel,"",linecutHw
end

//*****************************************************
//## 02
//** Determine the First P for assignment loop
Function findstartppf(mat,angle,Zn,addY)
	String mat
	variable angle
	variable Zn
	variable addY

	//** Auto ordering layer index
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

	//** Initial layer dimsize
		wave matw = $mat
		variable Nx,Ny,Nz
		Nx = dimsize(matw,xn)
		Ny = dimsize(matw,yn)
		Nz = dimsize(matw,zn)

	//** Search for the Start P
		variable pp, qq,pps
		variable i
		pps=nan
		i=0 //## Search from the smallest P [i.e. 0], calculate when Q is in range, that position is pps
		do
			qq = tan(angle*pi/180)*(i-round(Nx/2))+round(Ny/2)+addY //[Formula of Rotated HLine]
			//print qq
			if(round(qq) >= 0 && round(qq) <= Ny-1 ) //** condition of Q in range
				pps = i
				break
			endif
			i+=1
		while(i < Nx)
		return pps
end

//*****************************************************
//## 03
//** Determine the Last P for assignment loop
Function findendppf(mat,angle,Zn,addY)
	String mat
	variable angle
	variable Zn
	variable addY

	//** Auto ordering layer index
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

	//** Initial layer dimsize
		wave matw = $mat
		variable Nx,Ny,Nz
		Nx = dimsize(matw,xn)
		Ny = dimsize(matw,yn)
		Nz = dimsize(matw,zn)

	//** Search for the End P
		variable pp, qq,ppe
		variable i
		ppe=nan
		i=Nx-1 //## Search from the largest P, calculate when Q is in range, that position is ppe
		do
			qq = tan(angle*pi/180)*(i-round(Nx/2))+round(Ny/2)+addY //[Formula of Rotated HLine]
				//print qq
			if(round(qq) <= Ny-1 && round(qq) >= 0) //** condition of Q in range
				ppe = i
				break
			endif
			i-=1
		while(i >= 0)
		return ppe
end

//*****************************************************
//## 04
//** Find the addY Range for rotated H-Linecut
Function/Wave findrangeforangle_LHf(mat,angle,Zn)
	String mat
	variable angle
	variable Zn

	//** Auto ordering layer index
		make/o/N=3 ordernum ={0,1,2}
		ordernum=abs(ordernum-zn)
		wavestats/Q ordernum
		ordernum={0,1,2}
		DeletePoints V_minloc,1, ordernum
		wavestats/Q ordernum
		variable xn = ordernum[V_minloc]
		variable yn = ordernum[V_maxloc]
		killwaves ordernum

	//** Search for high limit
		variable addY, addYmax, addYmin,body
		addY =0
		do
			body = mod(Round(findendppf(mat,angle,Zn,addY)),1)
			if (body != 0)
				addYmax = addY-1
				break
			endif
			addY+=1
		while(addY < 3*dimsize($mat,yn))

	//** Search for low limit
		addY =0
		do
			body = mod(Round(findendppf(mat,angle,Zn,addY)),1)
			if (body != 0)
				addYmin = addY+1
				break
			endif
			addY-=1
		while(addY >  -3*dimsize($mat,yn))

	//** Return the limit wave
		make/N=2/o Hcut_Vrange
		//print addYmin
		//print addYmax
		Hcut_Vrange={addYmin,addYmax}
		return Hcut_Vrange
end

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//** INTERACTING FUNCTIONAL: Extract rotated Vertical Linecut
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//%%%%%%%%%%%%** get rotated V-linecut, addX here is counted from center.
//%%%%%%%%%%%%** V-linecut can move in X direction, addX is DP(Int)
////////////////////////////////////////////////////////////////////////////////////////////////////////////

//*****************************************************
//## 01
//** Main Function
Function anglelinecutVf(mat,angle,Zn,addX,normornot,smornot)
	String mat
	variable angle
	variable Zn
	variable addX
	variable normornot
	variable smornot
	//** Auto ordering layer index
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

	//** Initial layer dimsize
		wave matw = $mat
		variable Nx,Ny,Nz
		Nx = dimsize(matw,xn)
		Ny = dimsize(matw,yn)
		Nz = dimsize(matw,zn)
		variable pp, qq

	//** Determine Limit for Assignment Loop
		//## Play with vertical Line
		//## Logistically, we swap P and Q
		//## that mean, set Q as independent variable
		//## and check P the dependent variable

		//** Determine the First and Last Q for value assignment loop
			variable qqs,qqe,pps,ppe,xxs,xxe,yys,yye //pp = tan(angle*pi/180)*(qq-round(Ny/2))+round(Nx/2)+addX
			qqs=findstartqqf(mat,angle,Zn,addX) //First Q
			qqe=findendqqf(mat,angle,Zn,addX)   //Last Q

		//** Calculate P and X, Y
			yys = dimoffset(matw,yn)+qqs*dimdelta(matw,yn)
			yye = dimoffset(matw,yn)+qqe*dimdelta(matw,yn)
			pps = tan(-angle*pi/180)*(qqs-round(Ny/2))+round(Nx/2)+addX
			ppe = tan(-angle*pi/180)*(qqe-round(Ny/2))+round(Nx/2)+addX
			xxs = dimoffset(matw,xn)+pps*dimdelta(matw,xn)
			xxe = dimoffset(matw,xn)+ppe*dimdelta(matw,xn)


		//** Calculate linecut scale
			variable len = sqrt((xxe-xxs)^2+(yye-yys)^2)
			string linecutV = "LV_"+mat
			make/N=((qqe-qqs+1),Nz)/o $linecutV
			wave linecutVw = $linecutV
			setscale/p y,dimoffset(matw,zn),dimdelta(matw,zn),"",linecutVw
			setscale/i x,yys,yys+len,"",linecutVw

	//** Extract value from 3D matrix
		//** The value assignment loop is runing along Q
		variable i
		i=0
		qq=qqs
		do
			//qq= round(tan(-angle*pi/180)*(pp-round(Nx/2))+round(Ny/2)+addY)
			pp = round(tan(-angle*pi/180)*(qq-round(Ny/2))+round(Nx/2)+addX) //[Formula of Rotated VLine]

			//linecutHw[][i] = matw[pp][qq][p]

			if(zn == 0)
				linecutVw[i][] = matw[q][pp][qq]
			endif
			if(zn == 1)
				linecutVw[i][] = matw[pp][q][qq]
			endif
			if(zn == 2)
				linecutVw[i][] = matw[pp][qq][q]
			endif
			qq+=1
			i+=1
		while(qq < qqe+1)
		//di(linecutHw)



	//** Shift the zero for FFT linecut
	string slicename = "Zslice_"+mat
	wave slicenamew = $slicename
	variable kk = (xxs-xxe)/(yys-yye)
	variable bb = xxs-kk*yys
	variable zx,zy
	zy = -(bb*kk)/(kk^2+1)
	zx = bb/(kk^2+1)
	variable zp,zq
	zp = round((zx-dimoffset(slicenamew,0))/dimdelta(slicenamew,0))
	zq = round((zy-dimoffset(slicenamew,1))/dimdelta(slicenamew,1))
	variable dimoff = dimoffset(linecutVw,0)
	variable dimdel = dimdelta(linecutVw,0)

	variable correcteddimoffset = -(zq-qqs)*dimdel
	setscale/p x,correcteddimoffset,dimdel,"",linecutVw
	//** Shift the zero for FFT linecut
	//string slicename = "Zslice_"+mat
	//wave slicenamew = $slicename
	//variable kk = (xxs-xxe)/(yys-yye)
	//variable bb = xxs-kk*yys
	//variable zx,zy
	//zy = -(bb*kk)/(kk^2+1)
	//zx = bb/(kk^2+1)
	//variable zp,zq
	//zp = round((zx-dimoffset(slicenamew,0))/dimdelta(slicenamew,0))
	//zq = round((zy-dimoffset(slicenamew,1))/dimdelta(slicenamew,1))

	//correcteddimoffset + dimdelta(linecutHw,0)*zp = 0
	//variable correcteddimoffset = -dimdelta(slicenamew,1)*zq
	//setscale/p x,correcteddimoffset,dimdelta(slicenamew,1),"",linecutVw

end

//*****************************************************
//## 02
//** Determine the First Q for assignment loop
Function findstartqqf(mat,angle,Zn,addX)
	String mat
	variable angle
	variable Zn
	variable addX

	//** Auto ordering layer index
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

	//** Initial layer dimsize
		wave matw = $mat
		variable Nx,Ny,Nz
		Nx = dimsize(matw,xn)
		Ny = dimsize(matw,yn)
		Nz = dimsize(matw,zn)

	//** Search for the Start Q
		variable pp, qq,qqs
		variable i
		qqs=nan
		i=0 //## Search from the smallest Q [i.e. 0], calculate when P is in range, that position is pps
		do
			pp = tan(-angle*pi/180)*(i-round(Ny/2))+round(Nx/2)+addX //[Formula of Rotated VLine]
			if(round(pp) >= 0 && round(pp) <= Nx-1 ) //Condition for P in range
				qqs = i
				break
			endif
			i+=1
		while(i < Ny)
		return qqs
end

//*****************************************************
//## 03
//** Determine the Last Q for assignment loop
Function findendqqf(mat,angle,Zn,addX)
	String mat
	variable angle
	variable Zn
	variable addX

	//** Auto ordering layer index
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

	//** Initial layer dimsize
		wave matw = $mat
		variable Nx,Ny,Nz
		Nx = dimsize(matw,xn)
		Ny = dimsize(matw,yn)
		Nz = dimsize(matw,zn)

	//** Search for the End Q
		variable pp, qq,qqe
		variable i
		qqe=nan
		i=Nx-1 //## Search from the largest Q, calculate when P is in range, that position is pps
		do
			pp = tan(-angle*pi/180)*(i-round(Ny/2))+round(Nx/2)+addX //[Formula of Rotated VLine]
			//print qq
			if(round(pp) >= 0 && round(pp) <= Nx-1) //Condition for P in range
				qqe = i
				break
			endif
			i-=1
		while(i >= 0)
		return qqe
end

//*****************************************************
//## 04
//** Find the addX Range for rotated V-Linecut
Function/Wave findrangeforangle_LVf(mat,angle,Zn)
	String mat
	variable angle
	variable Zn

	//** Auto ordering layer index
		make/o/N=3 ordernum ={0,1,2}
		ordernum=abs(ordernum-zn)
		wavestats/Q ordernum
		ordernum={0,1,2}
		DeletePoints V_minloc,1, ordernum
		wavestats/Q ordernum
		variable xn = ordernum[V_minloc]
		variable yn = ordernum[V_maxloc]
		killwaves ordernum

	//** High Limit
		variable addX, addXmax, addXmin,body
		addX =0
		do
			body = mod(Round(findendqqf(mat,angle,Zn,addX)),1)
			if (body != 0)
				addXmax = addX-1
				break
			endif
			addX+=1
		while(addX < 3*dimsize($mat,xn))

	//** Low Limit
		addX =0
		do
			body = mod(Round(findendppf(mat,angle,Zn,addX)),1)
			if (body != 0)
				addXmin = addX+1
				break
			endif
			addX-=1
		while(addX >  -3*dimsize($mat,xn))

	//** Return Limit
		make/N=2/o Vcut_Vrange
		//print addYmin
		//print addYmax
		Vcut_Vrange={addXmin,addXmax}
		return Vcut_Vrange
end


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** Auxiliary Functions
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////





//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//** 3D Advanced EMDC Mode
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

//#1 control of Advanced mode (select modes)
Function PopMenuProc_selmode3dplotf(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr


	variable/G sel_L_3dplot
	sel_L_3dplot = popNum


	string/G mat3dn_cons //= mat3dn
	variable/G zn_cons//the Energy in which dimension?

	string mat3dn_consf= mat3dn_cons+"_FFT3d"

	//** Auto ordering layer index
		variable zn =zn_cons
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
	string ZoutI
	variable/G FFTmode_3dplot
	if (sel_L_3dplot == 1) //Two Points Mode
		Cursor/W=$winname(0,1)/P/I/C=(1,65535,33232)/T=6 A $tpw() 0,0
		Cursor/W=$winname(0,1)/P/I/C=(0,65535,65535)/T=6 B $tpw() round(dimsize($tpw(),0)/2),round(dimsize($tpw(),1)/2)
		SetWindow $winname(0,1) hook(myHook)=myCursorMovedHook3Dfdnf

		ZoutI = "ZoutI_"+mat3dn_consf
		make/N =((abs(pcsr(B)-pcsr(A))+1),dimsize($mat3dn_consf,zn))/o $ZoutI
		wave ZoutIw = $ZoutI
		ZoutIw = nan
		di(ZoutIw)

		//tilewindows/WINS=grabwin(ZoutI)/R/w=(74,0,100,50)/A=(1,1)
		Modifygraph width=400, height=200
		Label left "\\Z16\\F'times'\\f02E - E\\BF\\f00\\M\\F'times'\\Z16 (meV)"
		Label bottom "\\Z16\\f02k\\f00 (2π Å\\S\\Z10-1\\M\\Z16)"
		tilewindows/WINS=grabwinnonew(ZoutI)/R/w=(56,64,100,100)/A=(1,1)
	endif

	if (sel_L_3dplot == 2) //Free Hand Mode
		Cursor/W=$winname(0,1)/P/I/C=(1,65535,33232)/T=6 A $tpw() 0,0
		SetWindow $winname(0,1) hook(myHook)=myCursorMovedHook3Dfreehandf

		ZoutI = "ZoutI_"+mat3dn_consf
		make/N =((abs(pcsr(B)-pcsr(A))+1),dimsize($mat3dn_consf,zn))/o $ZoutI
		wave ZoutIw = $ZoutI
		ZoutIw = nan
		di(ZoutIw)
		//Modifygraph width=450, height=250
		//tilewindows/WINS=grabwin(ZoutI)/R/w=(74,0,100,50)/A=(1,1)

		Modifygraph width=400, height=200
		Label left "\\Z16\\F'times'\\f02E - E\\BF\\f00\\M\\F'times'\\Z16 (meV)"
		Label bottom "\\Z16\\f02k\\f00 (2π Å\\S\\Z10-1\\M\\Z16)"
		tilewindows/WINS=grabwinnonew(ZoutI)/R/w=(56,64,100,100)/A=(1,1)
		//** Error message, no stop but Continuing execution
		String msg
		Variable err
		msg=GetErrMessage(GetRTError(0),3);
		err=GetRTError(1)
		if (err != 0)
			//Print "Error in Demo: " + msg
			//Print "Continuing execution"
		endif
	endif

	if (sel_L_3dplot == 3) //Circle Mode
		Cursor/W=$winname(0,1)/P/I/C=(1,65535,33232)/T=6 A $tpw() 0,round(dimsize($tpw(),1)/2)
		Cursor/W=$winname(0,1)/P/I/C=(0,65535,65535)/T=6 B $tpw() round(dimsize($tpw(),0)/2),round(dimsize($tpw(),1)/2)
		SetWindow $winname(0,1) hook(myHook)=myCursorMovedHook3Dccf

		ZoutI = "ZoutI_"+mat3dn_consf
		make/N =((abs(pcsr(B)-pcsr(A))+1),dimsize($mat3dn_consf,zn))/o $ZoutI
		wave ZoutIw = $ZoutI
		ZoutIw = nan
		di(ZoutIw)

		//Modifygraph width=450, height=250
		//tilewindows/WINS=grabwin(ZoutI)/R/w=(74,0,100,50)/A=(1,1)
		Modifygraph width=400, height=200
		Label left "\\Z16\\F'times'\\f02E - E\\BF\\f00\\M\\F'times'\\Z16 (meV)"
		Label bottom "\\Z16\\f02k\\f00 (2π Å\\S\\Z10-1\\M\\Z16)"
		tilewindows/WINS=grabwinnonew(ZoutI)/R/w=(56,64,100,100)/A=(1,1)
	endif

end

//#2 Update freehand modes
Function ButtonProc_L3dplotdof(ctrlName) : ButtonControl
	String ctrlName
	Variable/G sel_L_3dplot

	makefreehandwave_3dplotf()
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

////////////////////////////////////////////////////////////////////
//#3** (1): Two Points Method

//#3_01 Cursor Hook
Function myCursorMovedHook3Dfdnf(s)
	STRUCT WMWinHookStruct &s
	Variable statusCode= 0
	strswitch( s.eventName )
		case "cursormoved":
			twopgetline3df()
			UpdateControls_3dpf1(s.traceName, s.cursorName, s.pointNumber, s.yPointNumber)
			break
	endswitch
	return statusCode
End

Function UpdateControls_3dpf1(traceName, cursorName, pointNumber, yPointNumber)
	String traceName, cursorName
	Variable pointNumber,yPointNumber
	string/G mat3dn_cons
	variable/G zn_cons
	variable/G pointNumberx_3dp = pointNumber
	variable/G PointNumbery_3dp = yPointNumber

	string/G mat3dn_cons
	string mat3dn = mat3dn_cons+"_FFT3d"
	string mat3dn_consf = mat3dn
	variable/G zn_cons  //the Energy in which dimension?
	variable/G z_cons
	getsinglests($mat3dn_consf,pointNumber,yPointNumber,zn_cons)

End
//#3_02 Hook Called: Extract Line profile from two points
//		{Note: this function will be called every time cursor moves}
FUnction twopgetline3df()
	variable dx = abs(pcsr(A) - pcsr(B))
	variable dy = abs(qcsr(A) - qcsr(B))
	if (dx > dy)
		twopgetline3dxf()
	else
		twopgetline3dyf()
	endif
end

Function twopgetline3dxf()
	variable k,b
	// define the line parameters
	k = (qcsr(A)-qcsr(B))/(pcsr(A)-pcsr(B))
	b = qcsr(A) - k*pcsr(A)


	string/G mat3dn_cons //= mat3dn
	string mat3dn_consf= mat3dn_cons+"_FFT3d"

	variable/G zn_cons//the Energy in which dimension?
	//** Auto ordering layer index
		variable zn = zn_cons
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

	wave tpww = $mat3dn_consf
	string ZoutI = "ZoutI_"+mat3dn_consf
	make/N =((abs(pcsr(B)-pcsr(A))+1),dimsize($mat3dn_consf,zn))/o $ZoutI
	wave ZoutIw = $ZoutI

	variable i , yy, signw,signwq
	signw = pcsr(A) - pcsr(B)
	signwq=qcsr(A) - qcsr(B)
	variable xx1 = dimoffset(tpww,0)+dimdelta(tpww,0)*pcsr(A)
	variable xx2 = dimoffset(tpww,0)+dimdelta(tpww,0)*pcsr(B)
	variable yy1 = dimoffset(tpww,1)+dimdelta(tpww,1)*qcsr(A)
	variable yy2 = dimoffset(tpww,1)+dimdelta(tpww,1)*qcsr(B)
	variable len = sqrt((xx1-xx2)^2+(yy1-yy2)^2)

	//Make Z wave follow the two-point line
	i = pcsr(A)
	if (signw < 0)
		do
			yy = round(k*i+b)

			if(zn_cons == 0)
				ZoutIw[i-pcsr(A)][] = tpww[q][i][yy]
			endif
			if(zn_cons == 1)
				ZoutIw[i-pcsr(A)][] = tpww[i][q][yy]
			endif
			if(zn_cons == 2)
				ZoutIw[i-pcsr(A)][] = tpww[i][yy][q]
			endif

			//ZoutIw[i-pcsr(A)] = tpww[i][yy]
			i+=1
		while(i< pcsr(B)+1)
	endif

	variable j =pcsr(A)
	if (signw > 0)
		do
			yy = round(k*i+b)

			if(zn_cons == 0)
				ZoutIw[j-pcsr(A)][] = tpww[q][i][yy]
			endif
			if(zn_cons == 1)
				ZoutIw[j-pcsr(A)][] = tpww[i][q][yy]
			endif
			if(zn_cons == 2)
				ZoutIw[j-pcsr(A)][] = tpww[i][yy][q]
			endif

			//ZoutIw[j-pcsr(A)] = tpww[i][yy]
			j+=1
			i-=1
		while(i > pcsr(B)-1)
	endif

	if (signw == 0)
		i = qcsr(A)
		if (signwq < 0)
		do
			yy = round((i-b)/k)

			if(zn_cons == 0)
				ZoutIw[i-qcsr(A)][] = tpww[q][yy][i]
			endif
			if(zn_cons == 1)
				ZoutIw[i-qcsr(A)][] = tpww[yy][q][i]
			endif
			if(zn_cons == 2)
				ZoutIw[i-qcsr(A)][] = tpww[yy][i][q]
			endif

			i+=1
		while(i< qcsr(B)+1)
		endif

		j =qcsr(A)
		if (signwq > 0)
		do
			yy = round((i-b)/k)

			if(zn_cons == 0)
				ZoutIw[i-qcsr(A)][] = tpww[q][yy][i]
			endif
			if(zn_cons == 1)
				ZoutIw[i-qcsr(A)][] = tpww[yy][q][i]
			endif
			if(zn_cons == 2)
				ZoutIw[i-qcsr(A)][] = tpww[yy][i][q]
			endif

			//ZoutIw[j-qcsr(A)] = tpww[yy][i]
			j+=1
			i-=1
		while(i > qcsr(B)-1)
		endif
	endif
	setscale/I x,0,len, "",ZoutIw
	setscale/p y,dimoffset($mat3dn_consf,zn),dimdelta($mat3dn_consf,zn), "",ZoutIw



	//Make the X&Y wave for indication
	string xwaveout = "Xout_"+mat3dn_consf
	string ywaveout = "Yout_"+mat3dn_consf
	make/N=2/O $ywaveout
	make/N=2/O $Xwaveout
	wave xwaveoutw = $xwaveout
	wave ywaveoutw = $ywaveout
	ywaveoutw[0]=yy1
	ywaveoutw[1]=yy2
	xwaveoutw={xx1,xx2}

	//Append indicative Ywave vs Xwave if it is not on graph
	checkDisplayed ywaveoutw
	if(V_flag == 0)
		appendtograph ywaveoutw vs Xwaveoutw
		ModifyGraph/W=$winname(0,1) lsize($ywaveout)=1,rgb($ywaveout)=(3690,43690,43690),mode($ywaveout)=4	,lstyle($ywaveout)=7, mrkThick($ywaveout)=2,useMrkStrokeRGB($ywaveout)=1,mrkStrokeRGB($ywaveout)=(1,52428,26586),msize($ywaveout)=1
	else
	endif

	TextBox/W=$grabwinnonew(ZoutI)/C/N=text0/F=0/A=LT/X=0.00/Y=0.00 "Two Points Mode"

	variable/G FFTmode_3dplot
	if (FFTmode_3dplot == 5)
		ModifyImage $ZoutI ctab= {*,*,VioletOrangeYellow,1}
	else
		color3s_for3dFFT($ZoutI,30)
	endif

	//** Shift the zero for FFT linecut
	string slicename = "Zslice_"+mat3dn_consf
	wave slicenamew = $slicename
	variable kk,bb
	variable xxa,xxb,yya,yyb
	xxa = dimoffset(slicenamew,0)+pcsr(A)*dimdelta(slicenamew,0)
	xxb = dimoffset(slicenamew,0)+pcsr(B)*dimdelta(slicenamew,0)

	yya = dimoffset(slicenamew,1)+qcsr(A)*dimdelta(slicenamew,1)
	yyb = dimoffset(slicenamew,1)+qcsr(B)*dimdelta(slicenamew,1)

	kk = (yya-yyb)/(xxa-xxb)
	bb = yya - kk*xxa

	variable zx,zy
	zx = -(bb*kk)/(kk^2+1)
	zy = bb/(kk^2+1)
	variable zp,zq
	zp = round((zx-dimoffset(slicenamew,0))/dimdelta(slicenamew,0))
	zq = round((zy-dimoffset(slicenamew,1))/dimdelta(slicenamew,1))
	variable dimoff = dimoffset(ZoutIw,0)
	variable dimdel = dimdelta(ZoutIw,0)
	variable correcteddimoffset = -(zp-pcsr(A))*dimdel
	if(qcsr(A)==qcsr(b))
		setscale/p x,xxa,dimdel,"",ZoutIw
	else
		setscale/p x,correcteddimoffset,dimdel,"",ZoutIw
	endif
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

Function twopgetline3dyf()
	variable k,b
	// define the line parameters
	k = (pcsr(A)-pcsr(B))/(qcsr(A)-qcsr(B))
	b = pcsr(A) - k*qcsr(A)


	string/G mat3dn_cons //= mat3dn
	string mat3dn_consf= mat3dn_cons+"_FFT3d"

	variable/G zn_cons//the Energy in which dimension?
	//** Auto ordering layer index
		variable zn = zn_cons
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

	wave tpww = $mat3dn_consf
	string ZoutI = "ZoutI_"+mat3dn_consf
	make/N =((abs(qcsr(B)-qcsr(A))+1),dimsize($mat3dn_consf,zn))/o $ZoutI
	wave ZoutIw = $ZoutI

	variable i , yy, signw,signwq
	signw = qcsr(A) - qcsr(B)
	signwq=pcsr(A) - pcsr(B)
	variable xx1 = dimoffset(tpww,1)+dimdelta(tpww,1)*qcsr(A)
	variable xx2 = dimoffset(tpww,1)+dimdelta(tpww,1)*qcsr(B)
	variable yy1 = dimoffset(tpww,0)+dimdelta(tpww,0)*pcsr(A)
	variable yy2 = dimoffset(tpww,0)+dimdelta(tpww,0)*pcsr(B)
	variable len = sqrt((xx1-xx2)^2+(yy1-yy2)^2)

	//Make Z wave follow the two-point line
	i = qcsr(A)
	if (signw < 0)
		do
			yy = round(k*i+b)

			if(zn_cons == 0)
				ZoutIw[i-qcsr(A)][] = tpww[q][yy][i]
			endif
			if(zn_cons == 1)
				ZoutIw[i-qcsr(A)][] = tpww[yy][q][i]
			endif
			if(zn_cons == 2)
				ZoutIw[i-qcsr(A)][] = tpww[yy][i][q]
			endif

			//ZoutIw[i-pcsr(A)] = tpww[i][yy]
			i+=1
		while(i< qcsr(B)+1)
	endif

	variable j =qcsr(A)
	if (signw > 0)
		do
			yy = round(k*i+b)

			if(zn_cons == 0)
				ZoutIw[j-qcsr(A)][] = tpww[q][yy][i]
			endif
			if(zn_cons == 1)
				ZoutIw[j-qcsr(A)][] = tpww[yy][q][i]
			endif
			if(zn_cons == 2)
				ZoutIw[j-qcsr(A)][] = tpww[yy][i][q]
			endif

			//ZoutIw[j-pcsr(A)] = tpww[i][yy]
			j+=1
			i-=1
		while(i > qcsr(B)-1)
	endif

	if (signw == 0)
		i = pcsr(A)
		if (signwq < 0)
		do
			yy = round((i-b)/k)
			//ZoutIw[i-pcsr(A)] = tpww[i][yy]
			if(zn_cons == 0)
				ZoutIw[i-pcsr(A)][] = tpww[q][i][yy]
			endif
			if(zn_cons == 1)
				ZoutIw[i-pcsr(A)][] = tpww[i][q][yy]
			endif
			if(zn_cons == 2)
				ZoutIw[i-pcsr(A)][] = tpww[i][yy][q]
			endif
			i+=1
		while(i< pcsr(B)+1)
		endif

		j =pcsr(A)
		if (signwq > 0)
		do
			yy = round((i-b)/k)

			if(zn_cons == 0)
				ZoutIw[i-pcsr(A)][] = tpww[q][i][yy]
			endif
			if(zn_cons == 1)
				ZoutIw[i-pcsr(A)][] = tpww[i][q][yy]
			endif
			if(zn_cons == 2)
				ZoutIw[i-pcsr(A)][] = tpww[i][yy][q]
			endif

			//ZoutIw[j-qcsr(A)] = tpww[yy][i]
			j+=1
			i-=1
		while(i > pcsr(B)-1)
		endif
	endif
	setscale/I x,0,len, "",ZoutIw
	setscale/p y,dimoffset($mat3dn_consf,zn),dimdelta($mat3dn_consf,zn), "",ZoutIw



	//Make the X&Y wave for indication
	string xwaveout = "Xout_"+mat3dn_consf
	string ywaveout = "Yout_"+mat3dn_consf
	make/N=2/O $ywaveout
	make/N=2/O $Xwaveout
	wave xwaveoutw = $xwaveout
	wave ywaveoutw = $ywaveout
	ywaveoutw[0]=xx1
	ywaveoutw[1]=xx2
	xwaveoutw={yy1,yy2}

	//Append indicative Ywave vs Xwave if it is not on graph
	checkDisplayed ywaveoutw
	if(V_flag == 0)
		appendtograph ywaveoutw vs Xwaveoutw
		ModifyGraph/W=$winname(0,1) lsize($ywaveout)=1,rgb($ywaveout)=(3690,43690,43690),mode($ywaveout)=4	,lstyle($ywaveout)=7, mrkThick($ywaveout)=2,useMrkStrokeRGB($ywaveout)=1,mrkStrokeRGB($ywaveout)=(1,52428,26586),msize($ywaveout)=1
	else
	endif

	TextBox/W=$grabwinnonew(ZoutI)/C/N=text0/F=0/A=LT/X=0.00/Y=0.00 "Two Points Mode"

	variable/G FFTmode_3dplot
	if (FFTmode_3dplot == 5)
		ModifyImage $ZoutI ctab= {*,*,VioletOrangeYellow,1}
	else
		color3s_for3dFFT($ZoutI,30)
	endif

	//** Shift the zero for FFT linecut
	//string slicename = "Zslice_"+mat3dn_consf
	//wave slicenamew = $slicename
	//variable zx,zy
	//zx = -(b*k)/(k^2+1)
	//zy = b/(k^2+1)
	//variable zp,zq
	//zp = round((zx-dimoffset(slicenamew,0))/dimdelta(slicenamew,0))
	//zq = round((zy-dimoffset(slicenamew,1))/dimdelta(slicenamew,1))
	//variable dimoff = dimoffset(ZoutIw,0)
	//variable dimdel = dimdelta(ZoutIw,0)
	//variable correcteddimoffset = -(zq-qcsr(A))*dimdel
	//setscale/p x,correcteddimoffset,dimdel,"",ZoutIw

	//** Shift the zero for FFT linecut
	string slicename = "Zslice_"+mat3dn_consf
	wave slicenamew = $slicename
	variable kk,bb
	variable xxa,xxb,yya,yyb
	xxa = dimoffset(slicenamew,0)+pcsr(A)*dimdelta(slicenamew,0)
	xxb = dimoffset(slicenamew,0)+pcsr(B)*dimdelta(slicenamew,0)

	yya = dimoffset(slicenamew,1)+qcsr(A)*dimdelta(slicenamew,1)
	yyb = dimoffset(slicenamew,1)+qcsr(B)*dimdelta(slicenamew,1)

	kk = (xxa-xxb)/(yya-yyb)
	bb = xxa - kk*yya

	variable zx,zy
	zy = -(bb*kk)/(kk^2+1)
	zx = bb/(kk^2+1)
	variable zp,zq
	zp = round((zx-dimoffset(slicenamew,0))/dimdelta(slicenamew,0))
	zq = round((zy-dimoffset(slicenamew,1))/dimdelta(slicenamew,1))
	variable dimoff = dimoffset(ZoutIw,0)
	variable dimdel = dimdelta(ZoutIw,0)
	variable correcteddimoffset = -(zq-qcsr(A))*dimdel
	setscale/p x,correcteddimoffset,dimdel,"",ZoutIw

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
////////////////////////////////////////////////////////////////////
//#3** (2): Free hand Mode

//#3_03 Cursor Hook
Function myCursorMovedHook3Dfreehandf(s)
	STRUCT WMWinHookStruct &s
	Variable statusCode= 0
	strswitch( s.eventName )
		case "cursormoved":
			// see "Members of WMWinHookStruct Used with cursormoved Code"
			//UpdateControls_2df(s.traceName, s.cursorName, s.pointNumber, s.yPointNumber)
			UpdateControls_3dff(s.traceName, s.cursorName, s.pointNumber, s.yPointNumber)
			UpdateControls_3dpf1(s.traceName, s.cursorName, s.pointNumber, s.yPointNumber)

			break
	endswitch
	return statusCode
End

//#3_04 Extract line profile by free hand draw
//		{Note: this function will be called every time cursor moves}
Function UpdateControls_3dff(traceName, cursorName, pointNumber, yPointNumber)
	String traceName, cursorName
	Variable pointNumber,yPointNumber


	string/G mat3dn_cons //= mat3dn
	string mat3dn_consf= mat3dn_cons+"_FFT3d"

	variable/G zn_cons//the Energy in which dimension?

	//** Auto ordering layer index
		variable zn = zn_cons
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

	wave tpww = $mat3dn_consf
	//pointNumber = pcsr(A)
	//ypointNumber = qcsr(A)

	//**Initialize indicative X&Y wave and [temporary profile Z wave]
	string xwaveout = "Xout_"+mat3dn_consf
	string ywaveout = "Yout_"+mat3dn_consf
	string zwave = "Zwave_"+mat3dn_consf
	if (waveexists($xwaveout) == 1)
	else
		make/n=(0)/o $xwaveout
		wave xwaveoutw = $xwaveout
	endif
	if (waveexists($ywaveout) == 1)
	else
		make/n=(0)/o $ywaveout
		wave ywaveoutw = $ywaveout
	endif
	if (waveexists($zwave) == 1)
	else
		make/n=(1,dimsize($mat3dn_consf,zn))/o $zwave
		wave zwavew = $zwave
		setscale/p y,dimoffset($mat3dn_consf,zn),dimdelta($mat3dn_consf,zn),"",zwavew
	endif
	wave zwavew = $zwave
	wave xwaveoutw = $xwaveout
	wave ywaveoutw = $ywaveout

	InsertPoints dimsize(xwaveoutw,0),1, xwaveoutw
	xwaveoutw[dimsize(xwaveoutw,0)-1]= dimoffset(tpww,0)+dimdelta(tpww,0)*pointNumber

	InsertPoints dimsize(ywaveoutw,0),1, ywaveoutw
	ywaveoutw[dimsize(ywaveoutw,0)-1]= dimoffset(tpww,1)+dimdelta(tpww,1)*ypointNumber

	if(dimsize(xwaveoutw,0) == 1)
	else
		InsertPoints/M=0 dimsize(zwavew,0),1, zwavew
	endif

	//make/N=(dimsize($mat3dn_consf,zn))/O test

	if(zn_cons == 0)
		zwavew[dimsize(zwavew,0)-1][]= tpww[q][pointNumber][ypointNumber]
	endif
	if(zn_cons == 1)
		zwavew[dimsize(zwavew,0)-1][]= tpww[pointNumber][q][ypointNumber]
	endif
	if(zn_cons == 2)
		zwavew[dimsize(zwavew,0)-1][]= tpww[pointNumber][ypointNumber][q]

		//test = tpww[pointNumber][ypointNumber][p]
		//zwavew[][dimsize(zwavew,0)-1]=test[p]
	endif
	//zwavew[dimsize(zwavew,0)-1]= tpww[pointNumber][ypointNumber]


	//**Checking auxiliary indicative wave defined in the "Go function" below
	string xwaveout2 = "Xout2_"+mat3dn_consf
	string ywaveout2 = "Yout2_"+mat3dn_consf
	checkDisplayed $ywaveout2
	if(V_flag == 0)
	else
		RemoveFromGraph $ywaveout2
	endif
		//## {Note} X&Ywave2 are introduced for defining the start curor hood of a new free hand draw
		//## {Note} See details in the Go function.

	//**Append Indicative X&Y wave if it is not on the graph
	checkDisplayed ywaveoutw
	if(V_flag == 0)
		appendtograph ywaveoutw vs Xwaveoutw
		ModifyGraph/W=$winname(0,1) lsize($ywaveout)=1,rgb($ywaveout)=(3690,43690,43690),mode($ywaveout)=4	,lstyle($ywaveout)=7, mrkThick($ywaveout)=2,useMrkStrokeRGB($ywaveout)=1,mrkStrokeRGB($ywaveout)=(1,52428,26586),msize($ywaveout)=1
	else
	endif

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

//#3_05 GO Function
//		{Note: this function Define the end of the free hand draw and set the next cursor hook call belong to new lineprofile}
Function makefreehandwave_3dplotf()
	string/G mat3dn_cons //= mat3dn
	variable/G zn_cons//the Energy in which dimension?
	string mat3dn_consf= mat3dn_cons+"_FFT3d"

	//** Auto ordering layer index
		variable zn = zn_cons
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

	wave tpww = $mat3dn_consf

	//** Create scattered Z wave from temporary Z wave]
	string zwave = "Zwave_"+mat3dn_consf
	wave zwavew = $zwave
	string zwaveout = "Zout_"+mat3dn_consf
	string xwaveout = "Xout_"+mat3dn_consf
	string ywaveout = "Yout_"+mat3dn_consf
	wave xwaveoutw = $xwaveout
	wave ywaveoutw = $ywaveout
	duplicate/O zwavew $zwaveout
	wave zwaveoutw = $zwaveout
	killwaves zwavew

	//** Calculate the trajectory distance of the free-hand-draw trace
	string trajdis = "trajdis_"+mat3dn_consf
	make/N=(dimsize($zwaveout,0))/o $trajdis
	wave trajdisw = $trajdis
	trajdisw[0] = 0

	//**calculate trajectory distance
		variable i,delta
		i = 1
		do
			delta = sqrt((xwaveoutw[i]-xwaveoutw[i-1])^2+(ywaveoutw[i]-ywaveoutw[i-1])^2)
			trajdisw[i] = delta+trajdisw[i-1]
			i+=1
		while (i< dimsize($zwaveout,0))


	//**From scattered Z wave and trajectory wave to make waveform Z wave
		//Interpolate2/T=1/N=(2*dimsize(Xwaveoutw,0))/E=2/Y=$ZoutI trajdisw, zwaveoutw
		string ZoutI = "ZoutI_"+mat3dn_consf
		func_NaN0(zwaveoutw)
		rescalemapasa1dcurveFf(zwaveout,trajdis,5*dimsize(zwaveoutw,0))
		linkEDCs_nodisf(zwaveout,trajdis,5*dimsize(zwaveoutw,0))
		killEDCsf(zwaveout)
		string mapcorrect = "mapcorrect"
		wave mapcorrectw = $mapcorrect
		func_zeroNaN(mapcorrectw)
		duplicate/o mapcorrectw $ZoutI
		wave ZoutIw = $ZoutI
		killwaves mapcorrectw, zwaveoutw

			//duplicate/o zwaveoutw $ZoutI
			//killwaves zwaveoutw

	//**Create auxiliary indicative X&Ywave2
	string xwaveout2 = "Xout2_"+mat3dn_consf
	string ywaveout2 = "Yout2_"+mat3dn_consf
	duplicate/o xwaveoutw $xwaveout2
	duplicate/o ywaveoutw $ywaveout2
	wave xwaveout2w = $xwaveout2
	wave ywaveout2w = $ywaveout2
		//** {Note} In order to define new start of the indicative X&Ywave for a free hand drawing, it is important to
		//** {Note} set X&Y wave dimsize to be zero at this Go function, so that it cause a problem that after click the
		//** {Note} "Go" button, the current free hand draw is generated but the indicative lines disappear. In order to
		//** {Note} solve this problem, we introduced this auxiliary X&Ywave2 that before set the dimsize of XYwave to zero
		//** {Note} we transfer the information to the auxiliarys, remove the X&Ywave and append the X&Ywave2 with same format
		//** {Note} These auxiliarys will be remove and X&Ywave will be appended again when Cursor Hook runs in the next free hand draw.

	//**Remove indicative X&Ywave preparing for redefine the new start.
	RemoveFromGraph $ywaveout

	//**Append auxiliary indicative X&Ywave2
	checkDisplayed ywaveout2w
	if(V_flag == 0)
		appendtograph ywaveout2w vs Xwaveout2w
		ModifyGraph/W=$winname(0,1) lsize($ywaveout2)=1,rgb($ywaveout2)=(3690,43690,43690),mode($ywaveout2)=4,lstyle($ywaveout2)=7, mrkThick($ywaveout2)=2,useMrkStrokeRGB($ywaveout2)=1,mrkStrokeRGB($ywaveout2)=(1,52428,26586),msize($ywaveout2)=1
	else
	endif

	variable/G FFTmode_3dplot
	if (FFTmode_3dplot == 5)
		ModifyImage $ZoutI ctab= {*,*,VioletOrangeYellow,1}
	else
		color3s_for3dFFT($ZoutI,30)
	endif

	//**Reinitial the X&Ywave for the next free hand drawing
	deletePoints 0,dimsize($xwaveout,0), xwaveoutw
	deletePoints 0,dimsize($ywaveout,0), ywaveoutw
	TextBox/W=$grabwinnonew(ZoutI)/C/N=text0/F=0/A=LT/X=0.00/Y=0.00 "Free Hand Mode"
end

//#3_05_02 GO Function Called Interpolation fucntions
Function killEDCsf(namemap)
	string namemap
	wave namemapw = $namemap

	variable i
	String name, name1

	i=0
	do
		name="MDCmapsts"+num2str(i)+"_L"
		name1="MDCmapsts"+num2str(i)

		wave namew = $name
		wave name1w = $name1

		killwaves namew name1w
		i+=1
	while(i<dimsize(namemapw,1))
END
Function rescalemapasa1dcurveFf(namemap,namecurve,factor)
	String namemap
	String namecurve
	Variable factor

	wave namemapw = $namemap
	wave namecurvew = $namecurve

	String slice
	variable i
	i=0
	do
		slice = "MDCmapsts"+num2str(i)
		make/o/n=(dimsize(namemapw,0)) $slice
		//make/o/n=743 $slice
		wave slicew = $slice

		String dest
		dest=slice+"_L"
		wave destw = $dest

		slicew[] = 	namemapw[p][i]
		//Interpolate2/T=1/N=(factor*dimsize(namemapw,1)) namecurvew,slicew;
		Interpolate2/T=1/N=(factor) namecurvew,slicew;

		i+=1

	while(i<dimsize(namemapw,1))
end
Function linkEDCs_nodisf(namemap,namecurve,factor)
	string namemap
	String namecurve
	variable factor

	wave namemapw = $namemap
	wave namecurvew = $namecurve
	wavestats/Q namecurvew

	variable i,j

	//make/o/n=(dimsize(namemapw,0),factor*dimsize(namemapw,1)) mapcorrect
	make/o/n=(factor,dimsize(namemapw,1)) mapcorrect
	setscale/p y, dimoffset(namemapw,1),dimdelta(namemapw,1),"",mapcorrect
	setscale/I x, V_min,V_max,"",mapcorrect

	String name

	i=0
	do
		name="MDCmapsts"+num2str(i)+"_L"
		wave namew = $name

		j=0
		do
			mapcorrect[j][i]=namew[j]
			j+=1
		while(j < dimsize(namew,0))
		i+=1

	while(i<dimsize(namemapw,1))
	//display;appendimage mapcorrect
	//ModifyImage mapcorrect ctab= {*,*,VioletOrangeYellow,0}
end

////////////////////////////////////////////////////////////////////
//#3** (3): Circular Mode

//#3_06 Cursor Hook
Function myCursorMovedHook3Dccf(s)
	STRUCT WMWinHookStruct &s
	Variable statusCode= 0
	strswitch( s.eventName )
		case "cursormoved":
			Lineprofilefromcircle3df()
			UpdateControls_3dpf1(s.traceName, s.cursorName, s.pointNumber, s.yPointNumber)
			break
	endswitch
	return statusCode
End

//#3_07 Extract line profile by Circular Mode
//		{Note: this function will be called every time cursor moves}
Function Lineprofilefromcircle3df()

	string/G mat3dn_cons //= mat3dn
	variable/G zn_cons//the Energy in which dimension?
	string mat3dn_consf= mat3dn_cons+"_FFT3d"

	//** Auto ordering layer index
		variable zn = zn_cons
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

	//**Define the Origin
	variable Ox = pcsr(B)
	variable Oy = qcsr(B)

	//**Define the radium
	variable ax = pcsr(A)
	variable ay = qcsr(A)
	variable rr = round(sqrt((ox-ax)^2+(oy-ay)^2))

	//**Define the circular trace
	variable xx, yy
		//(xx-ox)^2+(yy-oy)^2 = rr^2
		//yy = +-sqrt(rr^2 - (xx-ox)^2)+oy

	//**Define the  leftP (polar pi) and rightP (Polar 0)
	variable leftP,rightP
	leftP = round(ox - rr)
	rightP = round(ox +rr)

	//**Create Z wave
	string ZoutI = "ZoutI_"+mat3dn_consf
	variable num = abs(rightP-leftP)+1+(abs(rightP-leftP)+1-1)
	make/N=(num,dimsize($mat3dn_consf,zn))/o $ZoutI
	wave ZoutIw =$ZoutI
	setscale/I x 0,2*pi,"",ZoutIw
	setscale/p y,dimoffset($mat3dn_consf,zn),dimdelta($mat3dn_consf,zn),"",ZoutIw
	ZoutIw=nan

	//**Create Indicative X&Y wave
	string xwaveout = "Xout_"+mat3dn_consf
	string ywaveout = "Yout_"+mat3dn_consf
	make/N=(num)/O $ywaveout
	make/N=(num)/O $Xwaveout
	wave xwaveoutw = $xwaveout
	wave ywaveoutw = $ywaveout

	//**Build Z wave and X&Ywave [Upper half circle (counter-clockwise)]
	string slicename = "Zslice_"+mat3dn_consf

	wave tpww = $mat3dn_consf
	variable i, qq,j
	i=rightp
	j=0
	do
		xx = i
		yy = sqrt(rr^2 - (xx-ox)^2)+oy
		qq = round(yy)
		if (qq >=0 && qq <dimsize($slicename,1))
			if(i>=0 && i <dimsize($slicename,0))
				//ZoutIw[j] = tpww[i][qq]
				if(zn_cons == 0)
					ZoutIw[j][] = tpww[q][i][qq]
				endif
				if(zn_cons == 1)
					ZoutIw[j][] = tpww[i][q][qq]
				endif
				if(zn_cons == 2)
					ZoutIw[j][] = tpww[i][qq][q]
				endif

			else
			endif
		else

			//if(j == rightp)
			//elseif (j == leftp)
			//else
			//	ZoutIw[][j] = nan
			//endif

		endif
		xwaveoutw[j] = dimoffset($slicename,0)+xx*dimdelta($slicename,0)
		ywaveoutw[j] = dimoffset($slicename,1)+qq*dimdelta($slicename,1)
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
		if (qq >=0 && qq <dimsize($slicename,1))
			if(i>=0 && i <dimsize($slicename,0))
				//ZoutIw[abs(rightP-leftP)+1+j] = tpww[i][qq]
				if(zn_cons == 0)
					ZoutIw[abs(rightP-leftP)+1+j][] = tpww[q][i][qq]
				endif
				if(zn_cons == 1)
					ZoutIw[abs(rightP-leftP)+1+j][] = tpww[i][q][qq]
				endif
				if(zn_cons == 2)
					ZoutIw[abs(rightP-leftP)+1+j][] = tpww[i][qq][q]
				endif

				else
			endif
		else

			//if(j == rightp)
			//elseif (j == leftp)
			//else
			//	ZoutIw[][abs(rightP-leftP)+1+j] = nan
			//endif

		endif
		xwaveoutw[abs(rightP-leftP)+1+j] = dimoffset($slicename,0)+xx*dimdelta($slicename,0)
		ywaveoutw[abs(rightP-leftP)+1+j] = dimoffset($slicename,1)+qq*dimdelta($slicename,1)
		j+=1
		i+=1
	while (i < rightp+1)
	ZoutIw[dimsize(ZoutIw,0)-1][] = ZoutIw[q][0]


	//**Append Indicative X&Ywaves
	checkDisplayed ywaveoutw
	if(V_flag == 0)
		appendtograph ywaveoutw vs Xwaveoutw
		ModifyGraph/W=$winname(0,1) lsize($ywaveout)=1,rgb($ywaveout)=(3690,43690,43690),mode($ywaveout)=4	,lstyle($ywaveout)=7, mrkThick($ywaveout)=2,useMrkStrokeRGB($ywaveout)=1,mrkStrokeRGB($ywaveout)=(1,52428,26586),msize($ywaveout)=1
	else
	endif
	TextBox/W=$grabwinnonew(ZoutI)/C/N=text0/F=0/A=LT/X=0.00/Y=0.00 "Circular Mode"
	variable/G FFTmode_3dplot
	if (FFTmode_3dplot == 5)
		ModifyImage $ZoutI ctab= {*,*,VioletOrangeYellow,1}
	else
		color3s_for3dFFT($ZoutI,30)
	endif
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

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** {{{{{{{{{{ Multiple 2D-lock-in }}}}}}}}}}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_2dlockinmultifft(ctrlName) : ButtonControl
	String ctrlName
	Execute "ffc3dp()"
End
Proc ffc3dp()
	string/G mat3dn_cons
	variable/G zn_cons
	variable/G z_cons
	String slicename = "Zslice_"+mat3dn_cons

	ff3dp($slicename)
	string aa="Zslice_" +mat3dn_cons+"_FFT_Modula_INTER"
	tilewindows/WINS=grabwinnonew(aa)/R/w=(29.5,0,83,85)/A=(1,1)

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
Function ff3dp(name)
	wave name
	func_NaN0(name)
	String FFTout
	FFTout = nameofWave(name) + "_FFT"
	FFT/PAD={3*dimsize(name,0),3*dimsize(name,1)}/out=1/WINF=Hanning/DEST=$FFTout cvtcmplx(name)

	Complextorealf13dp($FFTout,1)
	String FFToutm = FFTout+"_Modula"
	//di($FFToutm)
	twoDinterpolatexyFFT3dp(FFToutm,4*dimsize($FFTout,0),4*dimsize($FFTout,1))
	Modifygraph width=200,height=200
	//ShowInfo

	Button Map793d title="Get A",proc=ButtonProc_GPAc3dp
	Button Map803d title="Get B",proc=ButtonProc_GPBc3dp
	Button Symx123d title="2D lock-in",size={120,20},proc=ButtonProc_2dlockinmulti

	//killwaves
		String namec
		namec = "c_"+nameofwave(name)
		string FFToutm1 = FFToutm+"1"
		killwaves $FFTout $namec  $FFToutm1 //$FFToutm
end
Function Complextorealf13dp(name1w,select)
	wave name1w
	variable select
	string name
	string name1 = nameOfWave(name1w)
	if (select==1)
		name=name1+"_Modula"
		make/o/N=(dimsize(name1w,0),dimsize(name1w,1)) $name
		wave namew = $name
		namew=sqrt(real(name1w)^2+imag(name1w)^2)
	endif
	setscale/i x,dimoffset(name1w,0),dimoffset(name1w,0)+dimdelta(name1w,0)*(dimsize(name1w,0)-1),"",namew
	setscale/i y,dimoffset(name1w,1),dimoffset(name1w,1)+dimdelta(name1w,1)*(dimsize(name1w,1)-1),"",namew
end

Function twoDinterpolatexyFFT3dp(name,xpoint,ypoint)
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

	CheckDisplayed $name2
	if (V_flag == 1)
		print "display;appendimage " + name2+";ModifyGraph width={Plan,1,bottom,left}"
	else
	endif
	killwindow $grabwin2(name2)
	dilf($name2)
	wavestats/Q $name2
	color3s($name2,30)
end
///////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_GPAc3dp(ctrlName) : ButtonControl
	String ctrlName
	Execute "gpac3dp()"
end
Proc gpac3dp()
	string name="Zslice_" +mat3dn_cons+"_FFT_Modula_INTER"
	Gpa3dp(name)
End
Function/Wave GpA3dp(name111)
	String name111
	//string nameraw
	GetMarquee left, bottom

	wave name111w = $name111
	String name1111 = name111+"_f"
	duplicate/o name111w $name1111
	wave name1111w=$name1111
	name1111w=nan;
	//CurveFit/Q gauss2D name111w[pcsr(A),pcsr(b)][qcsr(A),qcsr(b)] /D=name1111w[pcsr(A),pcsr(b)][qcsr(A),qcsr(b)];
	CurveFit/Q gauss2D name111w(V_left,V_right)(V_bottom,V_top) /D=name1111w(V_left,V_right)(V_bottom,V_top);

	//AppendMatrixContour $name1111
	variable xa_G, ya_G, wx,wy
	string W_coef = "W_coef"
	wave W_coefw = $W_coef
	xa_G = W_coefw[2]
	ya_G = W_coefw[4]
	wx = W_coefw[3]
	wy = W_coefw[5]
	//Print "Coordiante (x,y) from Figure is ("+num2str(xa_G)+","+num2str(ya_G)+")."
	//SVAR namefftraw = $namefftraw
	String cpickas = "QA_in3dplot"
	//print cpickas
	make/N=4/o $cpickas
	wave cpicka = $cpickas
	cpicka[0] = xa_G
	cpicka[1] = ya_G
	cpicka[2] = wx
	cpicka[3] = wy
	//Print "Qa got. Qa = ("+num2str(xa_G)+","+num2str(ya_G)+")"
	TextBox/C/N=text0/F=0/A=LB/X=0.00/Y=0.00 "Qa got. Qa = ("+num2str(xa_G)+","+num2str(ya_G)+")"
	string Fitq1x ="getq1x"
	string Fitq1y ="getq1y"
	make/N=1/o $Fitq1x
	make/N=1/o $Fitq1y
	wave Fitq1xw = $Fitq1x
	wave Fitq1yw = $Fitq1y
	Fitq1xw[0] = xa_G
	Fitq1yw[0] = ya_G
	if(ckwaveonfig(winname(0,1),Fitq1y)==0)
		appendtograph Fitq1yw vs Fitq1xw
		ModifyGraph mode=3,marker=1,rgb=(65535,0,0), mrkThick=1
	endif
	Return cpicka
end
////////////////////////////////////////////////
Function ButtonProc_GpBc3dp(ctrlName) : ButtonControl
	String ctrlName
	Execute "gpbc3dp()"
end

Proc gpbc3dp()
	string name="Zslice_" +mat3dn_cons+"_FFT_Modula_INTER"
	GpB3dp(name)
End
Function/Wave GpB3dp(name111)
	String name111
	string nameraw
	wave name111w = $name111
	String name1111 = name111+"_f"
	duplicate/o name111w $name1111
	wave name1111w=$name1111
	name1111w=nan;
	GetMarquee left, bottom
	CurveFit/Q gauss2D name111w(V_left,V_right)(V_bottom,V_top) /D=name1111w(V_left,V_right)(V_bottom,V_top);


	variable xa_G, ya_G, wx,wy
	string W_coef = "W_coef"
	wave W_coefw = $W_coef
	xa_G = W_coefw[2]
	ya_G = W_coefw[4]
	wx = W_coefw[3]
	wy = W_coefw[5]
	//Print "Coordiante (x,y) from Figure is ("+num2str(xa_G)+","+num2str(ya_G)+")."
	//SVAR namefftraw = $namefftraw
	String cpickbs = "QB_in3dplot"
	make/N=4/o $cpickbs
	wave cpickb = $cpickbs
	cpickb[0] = xa_G
	cpickb[1] = ya_G
	cpickb[2] = wx
	cpickb[3] = wy
	//Print "Qb got. Qb = ("+num2str(xa_G)+","+num2str(ya_G)+")"
	TextBox/C/N=text1/F=0/A=LB/X=0.00/Y=10.00 "Qb got. Qb = ("+num2str(xa_G)+","+num2str(ya_G)+")"
	string Fitq1x ="getq2x"
	string Fitq1y ="getq2y"
	make/N=1/o $Fitq1x
	make/N=1/o $Fitq1y
	wave Fitq1xw = $Fitq1x
	wave Fitq1yw = $Fitq1y
	Fitq1xw[0] = xa_G
	Fitq1yw[0] = ya_G
	if(ckwaveonfig(winname(0,1),Fitq1y)==0)
		appendtograph Fitq1yw vs Fitq1xw
		ModifyGraph mode=3,marker=1,rgb=(65535,0,0), mrkThick=1
	endif
	Return cpickb
end

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_2dlockinmulti(ctrlName) : ButtonControl
	String ctrlName
	EXECUTE "t2dlockinmultic()"
end
proc t2dlockinmultic(sel)
	variable sel = 2
	prompt sel,"Which Q used?",popup,"Just Fitted;Global Q"
	variable/G sel_multiM_3Dplot = sel-1
	t2dlockinmulti(sel_multiM_3Dplot)

	string barename = replaceString("_G",mat3dn_cons,"")
	String bare3d

	//** g(r,V)
		bare3d = mat3dn_cons
		string sliceg = "Zslice_"+bare3d
	//** T(r,V)
		string sliceT = barename+"_T"

	//** I(r,V)
		bare3d = barename+"_I"
		string sliceI = "Zslice_"+bare3d
	//** Z(r,V)
		bare3d = mat3dn_cons+"_Z_map"
		string sliceZ = "Zslice_"+bare3d
	//** R(r,V)
		bare3d = mat3dn_cons+"_R_map"
		string sliceR = "Zslice_"+bare3d
	//** Rho(r,V)
		bare3d = mat3dn_cons+"_Rho_map"
		string sliceRho = "Zslice_"+bare3d


		string Gphase2 = sliceg+"_phi_B"
		string Gamp2 = sliceg+"_amp_B"
		string Gphase1 = sliceg+"_phi_A"
		string Gamp1 = sliceg+"_amp_A"

		string Tphase2 = sliceT+"_phi_B"
		string Tamp2 = sliceT+"_amp_B"
		string Tphase1 = sliceT+"_phi_A"
		string Tamp1 = sliceT+"_amp_A"

		string Iphase2 = sliceI+"_phi_B"
		string Iamp2 = sliceI+"_amp_B"
		string Iphase1 = sliceI+"_phi_A"
		string Iamp1 = sliceI+"_amp_A"

		string Zphase2 = sliceZ+"_phi_B"
		string Zamp2 = sliceZ+"_amp_B"
		string Zphase1 = sliceZ+"_phi_A"
		string Zamp1 = sliceZ+"_amp_A"

		string Rphase2 = sliceR+"_phi_B"
		string Ramp2 = sliceR+"_amp_B"
		string Rphase1 = sliceR+"_phi_A"
		string Ramp1 = sliceR+"_amp_A"

		string Rhophase2 = sliceRho+"_phi_B"
		string Rhoamp2 = sliceRho+"_amp_B"
		string Rhophase1 = sliceRho+"_phi_A"
		string Rhoamp1 = sliceRho+"_amp_A"

		Display;modifygraph width=550,height=(4*550/3)
		//** SetVariable of Layer energy
		SetVariable setvarz_consmli title="Z",size={65,14},value=z_cons,proc=SetVarProc_Cons3dplotmli
		SetVariable setvarz_consmli limits={dimoffset($mat3dn_cons,zn_cons),(dimoffset($mat3dn_cons,zn_cons)+dimdelta($mat3dn_cons,zn_cons)*(dimsize($mat3dn_cons,zn_cons)-1)),dimdelta($mat3dn_cons,zn_cons)}

		SetVariable setvarz_conavedia title="FWHM(r)",size={85,15},value=avedia_3dplot,proc=SetVarProc_avedia_3dplot

		SetVariable setvarz_conavedia2 title="Global Q?",size={85,15},value=sel_multiM_3Dplot,limits={0,1,1},proc=SetVarProc_avedia_3dplot


		Display/HOST=#/W=(0,0.05,0.3,0.3);appendimage $Gphase1;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $Gphase1 ctab= {-pi,pi,RainbowCycle,0};TextBox/C/N=text0/O=90/F=0/A=LC/X=-20.00/Y=0.00 "\\Z16Q\\BA"
		setActiveSubwindow ##;Display/HOST=#/W=(0.3,0.05,0.6,0.3);appendimage $Tphase1;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $Tphase1 ctab= {-pi,pi,RainbowCycle,0}
		setActiveSubwindow ##;Display/HOST=#/W=(0.6,0.05,0.9,0.3);appendimage $Iphase1;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $Iphase1 ctab= {-pi,pi,RainbowCycle,0}

		setActiveSubwindow ##;Display/HOST=#/W=(0,0.25,0.3,0.5);appendimage $Gphase2;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $Gphase2 ctab= {-pi,pi,RainbowCycle,0};;TextBox/C/N=text0/O=90/F=0/A=LC/X=-20.00/Y=0.00 "\\Z16Q\\BB"
		setActiveSubwindow ##;Display/HOST=#/W=(0.3,0.25,0.6,0.5);appendimage $Tphase2;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $Tphase2 ctab= {-pi,pi,RainbowCycle,0}
		setActiveSubwindow ##;Display/HOST=#/W=(0.6,0.25,0.9,0.5);appendimage $Iphase2;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $Iphase2 ctab= {-pi,pi,RainbowCycle,0}

		setActiveSubwindow ##;Display/HOST=#/W=(0,0.5,0.3,0.75);appendimage $Zphase1;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $Zphase1 ctab= {-pi,pi,RainbowCycle,0};TextBox/C/N=text0/O=90/F=0/A=LC/X=-20.00/Y=0.00 "\\Z16Q\\BA"
		setActiveSubwindow ##;Display/HOST=#/W=(0.3,0.5,0.6,0.75);appendimage $Rphase1;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $Rphase1 ctab= {-pi,pi,RainbowCycle,0}
		setActiveSubwindow ##;Display/HOST=#/W=(0.6,0.5,0.9,0.75);appendimage $Rhophase1;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $Rhophase1 ctab= {-pi,pi,RainbowCycle,0}

		setActiveSubwindow ##;Display/HOST=#/W=(0,0.7,0.3,0.95);appendimage $Zphase2;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $Zphase2 ctab= {-pi,pi,RainbowCycle,0};TextBox/C/N=text0/O=90/F=0/A=LC/X=-20.00/Y=0.00 "\\Z16Q\\BB"
		setActiveSubwindow ##;Display/HOST=#/W=(0.3,0.7,0.6,0.95);appendimage $Rphase2;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $Rphase2 ctab= {-pi,pi,RainbowCycle,0};ColorScale/C/N=text0/F=0/A=MB/X=0.00/Y=-40.00 vert=0,frame=0.00,image=$Rphase2
		setActiveSubwindow ##;Display/HOST=#/W=(0.6,0.7,0.9,0.95);appendimage $Rhophase2;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $Rhophase2 ctab= {-pi,pi,RainbowCycle,0}
		setActiveSubwindow ##
		//ResumeUpdate
		ckfig_child(winname(0,1))
		TextBox/C/N=text0/F=0/A=MC/X=-29.00/Y=45.00 "\\Z16 g(r,V)"
		TextBox/C/N=text1/F=0/A=MC/X=1.00/Y=45.00 "\\Z16 T(r,V)"
		TextBox/C/N=text2/F=0/A=MC/X=31.00/Y=45.00 "\\Z16 I(r,V)"

		TextBox/C/N=text3/F=0/A=MC/X=-29.00/Y=0 "\\Z16 Z(r,V) = g(r,V)/g(r,-V)"
		TextBox/C/N=text4/F=0/A=MC/X=1.00/Y=0 "\\Z16 R(r,V) = |I(r,V)/I(r,-V)|"
		TextBox/C/N=text5/F=0/A=MC/X=31.00/Y=0 "\\Z16 ρ(r,V) = I(r,V)-I(r,-V) "

		Display;modifygraph width=550,height=(4*550/3)
		//** SetVariable of Layer energy
		//SetVariable setvarz_consmli title="Z",size={65,14},value=z_cons,proc=SetVarProc_Cons3dplotmli
		//SetVariable setvarz_consmli limits={dimoffset($mat3dn_cons,zn_cons),(dimoffset($mat3dn_cons,zn_cons)+dimdelta($mat3dn_cons,zn_cons)*(dimsize($mat3dn_cons,zn_cons)-1)),dimdelta($mat3dn_cons,zn_cons)}

		//SetVariable setvarz_conavedia title="FWHM(r)",size={85,15},value=avedia_3dplot,proc=SetVarProc_avedia_3dplot

		Display/HOST=#/W=(0,0.05,0.3,0.3);appendimage $Gamp1;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;TextBox/C/N=text0/O=90/F=0/A=LC/X=-20.00/Y=0.00 "\\Z16Q\\BA";ModifyImage $Gamp1 ctab= {*,*,VioletOrangeYellow,0}
		setActiveSubwindow ##;Display/HOST=#/W=(0.3,0.05,0.6,0.3);appendimage $Tamp1;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $Tamp1 ctab= {*,*,VioletOrangeYellow,0}
		setActiveSubwindow ##;Display/HOST=#/W=(0.6,0.05,0.9,0.3);appendimage $Iamp1;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $Iamp1 ctab= {*,*,VioletOrangeYellow,0}

		setActiveSubwindow ##;Display/HOST=#/W=(0,0.25,0.3,0.5);appendimage $Gamp2;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;TextBox/C/N=text0/O=90/F=0/A=LC/X=-20.00/Y=0.00 "\\Z16Q\\BB";ModifyImage $Gamp2 ctab= {*,*,VioletOrangeYellow,0}
		setActiveSubwindow ##;Display/HOST=#/W=(0.3,0.25,0.6,0.5);appendimage $Tamp2;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $Tamp2 ctab= {*,*,VioletOrangeYellow,0}
		setActiveSubwindow ##;Display/HOST=#/W=(0.6,0.25,0.9,0.5);appendimage $Iamp2;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $Iamp2 ctab= {*,*,VioletOrangeYellow,0}

		setActiveSubwindow ##;Display/HOST=#/W=(0,0.5,0.3,0.75);appendimage $Zamp1;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;TextBox/C/N=text0/O=90/F=0/A=LC/X=-20.00/Y=0.00 "\\Z16Q\\BA";ModifyImage $Zamp1 ctab= {*,*,VioletOrangeYellow,0}
		setActiveSubwindow ##;Display/HOST=#/W=(0.3,0.5,0.6,0.75);appendimage $Ramp1;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $Ramp1 ctab= {*,*,VioletOrangeYellow,0}
		setActiveSubwindow ##;Display/HOST=#/W=(0.6,0.5,0.9,0.75);appendimage $Rhoamp1;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $Rhoamp1 ctab= {*,*,VioletOrangeYellow,0}

		setActiveSubwindow ##;Display/HOST=#/W=(0,0.7,0.3,0.95);appendimage $Zamp2;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;TextBox/C/N=text0/O=90/F=0/A=LC/X=-20.00/Y=0.00 "\\Z16Q\\BB";ModifyImage $Zamp2 ctab= {*,*,VioletOrangeYellow,0}
		setActiveSubwindow ##;Display/HOST=#/W=(0.3,0.7,0.6,0.95);appendimage $Ramp2;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ColorScale/C/N=text0/F=0/A=MB/X=0.00/Y=-40.00 vert=0,frame=0.00,image=$Ramp2;ModifyImage $Ramp2 ctab= {*,*,VioletOrangeYellow,0}
		setActiveSubwindow ##;Display/HOST=#/W=(0.6,0.7,0.9,0.95);appendimage $Rhoamp2;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $Rhoamp2 ctab= {*,*,VioletOrangeYellow,0}
		setActiveSubwindow ##
		//ResumeUpdate
		ckfig_child(winname(0,1))
		TextBox/C/N=text0/F=0/A=MC/X=-29.00/Y=45.00 "\\Z16 g(r,V)"
		TextBox/C/N=text1/F=0/A=MC/X=1.00/Y=45.00 "\\Z16 T(r,V)"
		TextBox/C/N=text2/F=0/A=MC/X=31.00/Y=45.00 "\\Z16 I(r,V)"

		TextBox/C/N=text3/F=0/A=MC/X=-29.00/Y=0 "\\Z16 Z(r,V) = g(r,V)/g(r,-V)"
		TextBox/C/N=text4/F=0/A=MC/X=1.00/Y=0 "\\Z16 R(r,V) = |I(r,V)/I(r,-V)|"
		TextBox/C/N=text5/F=0/A=MC/X=31.00/Y=0 "\\Z16 ρ(r,V) = I(r,V)-I(r,-V) "

		tilewindows/WINS=stringfromList(0,replaceString("#",grabwinchild(Rhophase1),";"))/R/w=(28.5,0,60,100)/A=(1,1)
		tilewindows/WINS=stringfromList(0,replaceString("#",grabwinchild(Rhoamp1),";"))/R/w=(64.5,0,100,100)/A=(1,1)
		tilewindows/WINS=grabwinnonew(sliceg)/R/w=(3,0,60,100)/A=(1,1)
end
Function t2dlockinmulti(sel)
	variable sel
	string/G mat3dn_cons
	variable/G zn_cons
	variable/G z_cons
	variable/G avedia_3dplot = 1.1*dimsize($mat3dn_cons,0)*dimdelta($mat3dn_cons,0)/2//**********************
	variable Z_constp=(z_cons-dimoffset($mat3dn_cons,zn_cons))/dimdelta($mat3dn_cons,zn_cons)

	string QA_in3dplot
	string QB_in3dplot
	if (sel == 1)
		QA_in3dplot="GlobalQA"
		QB_in3dplot="GlobalQB"
	endif
	if (sel == 0)
		QA_in3dplot="QA_in3dplot"
		QB_in3dplot="QB_in3dplot"
	endif
	wave QAw = $QA_in3dplot
	wave QBw = $QB_in3dplot

	//** Auto ordering layer index
		make/o/N=3 ordernum ={0,1,2}
		ordernum=abs(ordernum-zn_cons)
		wavestats/Q ordernum
		ordernum={0,1,2}
		DeletePoints V_minloc,1, ordernum
		wavestats/Q ordernum
		variable xn = ordernum[V_minloc]
		variable yn = ordernum[V_maxloc]
		killwaves ordernum

	string barename = replaceString("_G",mat3dn_cons,"")
	String bare3d

	//** g(r,V)
		bare3d = mat3dn_cons
		string sliceg = "Zslice_"+bare3d
		make/o/N=(dimsize($bare3d,xn),dimsize($bare3d,yn)) $sliceg
		setscale/p x,dimoffset($bare3d,xn),dimdelta($bare3d,xn),"",$sliceg
		setscale/p y,dimoffset($bare3d,yn),dimdelta($bare3d,yn),"",$sliceg
		wave slicegw = $sliceg
		wave bare3dw = $bare3d
		if(zn_cons == 0)
			slicegw[][]=bare3dw[Z_constp][p][q]
		endif
		if(zn_cons == 1)
			slicegw[][]=bare3dw[p][Z_constp][q]
		endif
		if(zn_cons == 2)
			slicegw[][]=bare3dw[p][q][Z_constp]
		endif
		//f_for3dmulti($sliceg)
		//String FFTg = sliceg+"_FFT"+"_Modula"
		lockinp3dp(sliceg,2*pi*QAw[0],2*pi*QAw[1],2*pi*QBw[0],2*pi*QBw[1],avedia_3dplot)
	//** T(r,V)
		string sliceT = barename+"_T"
		levelimage2($sliceT,10)
		//f_for3dmulti($sliceT)
		//String FFTT = sliceT+"_FFT"+"_Modula"
		lockinp3dp(sliceT,2*pi*QAw[0],2*pi*QAw[1],2*pi*QBw[0],2*pi*QBw[1],avedia_3dplot)

	//** I(r,V)
		bare3d = barename+"_I"
		string sliceI = "Zslice_"+bare3d
		make/o/N=(dimsize($bare3d,xn),dimsize($bare3d,yn)) $sliceI
		setscale/p x,dimoffset($bare3d,xn),dimdelta($bare3d,xn),"",$sliceI
		setscale/p y,dimoffset($bare3d,yn),dimdelta($bare3d,yn),"",$sliceI
		wave sliceIw = $sliceI
		wave bare3dw = $bare3d
		if(zn_cons == 0)
			sliceIw[][]=bare3dw[Z_constp][p][q]
		endif
		if(zn_cons == 1)
			sliceIw[][]=bare3dw[p][Z_constp][q]
		endif
		if(zn_cons == 2)
			sliceIw[][]=bare3dw[p][q][Z_constp]
		endif
		//f_for3dmulti($sliceI)
		//String FFTI = sliceI+"_FFT"+"_Modula"
		lockinp3dp(sliceI,2*pi*QAw[0],2*pi*QAw[1],2*pi*QBw[0],2*pi*QBw[1],avedia_3dplot)


	//** Z(r,V)
		bare3d = mat3dn_cons+"_Z_map"
		string sliceZ = "Zslice_"+bare3d
		make/o/N=(dimsize($bare3d,xn),dimsize($bare3d,yn)) $sliceZ
		setscale/p x,dimoffset($bare3d,xn),dimdelta($bare3d,xn),"",$sliceZ
		setscale/p y,dimoffset($bare3d,yn),dimdelta($bare3d,yn),"",$sliceZ
		wave sliceZw = $sliceZ
		wave bare3dw = $bare3d
		if(zn_cons == 0)
			sliceZw[][]=bare3dw[Z_constp][p][q]
		endif
		if(zn_cons == 1)
			sliceZw[][]=bare3dw[p][Z_constp][q]
		endif
		if(zn_cons == 2)
			sliceZw[][]=bare3dw[p][q][Z_constp]
		endif
		//f_for3dmulti($sliceZ)
		//String FFTZ = sliceZ+"_FFT"+"_Modula"

		lockinp3dp(sliceZ,2*pi*QAw[0],2*pi*QAw[1],2*pi*QBw[0],2*pi*QBw[1],avedia_3dplot)

	//** R(r,V)
		bare3d = mat3dn_cons+"_R_map"
		string sliceR = "Zslice_"+bare3d
		make/o/N=(dimsize($bare3d,xn),dimsize($bare3d,yn)) $sliceR
		setscale/p x,dimoffset($bare3d,xn),dimdelta($bare3d,xn),"",$sliceR
		setscale/p y,dimoffset($bare3d,yn),dimdelta($bare3d,yn),"",$sliceR
		wave sliceRw = $sliceR
		wave bare3dw = $bare3d
		if(zn_cons == 0)
			sliceRw[][]=bare3dw[Z_constp][p][q]
		endif
		if(zn_cons == 1)
			sliceRw[][]=bare3dw[p][Z_constp][q]
		endif
		if(zn_cons == 2)
			sliceRw[][]=bare3dw[p][q][Z_constp]
		endif
		//f_for3dmulti($sliceR)
		//String FFTR = sliceR+"_FFT"+"_Modula"
		lockinp3dp(sliceR,2*pi*QAw[0],2*pi*QAw[1],2*pi*QBw[0],2*pi*QBw[1],avedia_3dplot)


	//** Rho(r,V)
		bare3d = mat3dn_cons+"_Rho_map"
		string sliceRho = "Zslice_"+bare3d
		make/o/N=(dimsize($bare3d,xn),dimsize($bare3d,yn)) $sliceRho
		setscale/p x,dimoffset($bare3d,xn),dimdelta($bare3d,xn),"",$sliceRho
		setscale/p y,dimoffset($bare3d,yn),dimdelta($bare3d,yn),"",$sliceRho
		wave sliceRhow = $sliceRho
		wave bare3dw = $bare3d
		if(zn_cons == 0)
			sliceRhow[][]=bare3dw[Z_constp][p][q]
		endif
		if(zn_cons == 1)
			sliceRhow[][]=bare3dw[p][Z_constp][q]
		endif
		if(zn_cons == 2)
			sliceRhow[][]=bare3dw[p][q][Z_constp]
		endif
		//f_for3dmulti($sliceRho)
		//String FFTRho = sliceRho+"_FFT"+"_Modula"
		lockinp3dp(sliceRho,2*pi*QAw[0],2*pi*QAw[1],2*pi*QBw[0],2*pi*QBw[1],avedia_3dplot)
end


Function SetVarProc_Cons3dplotmli(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName


	string/G mat3dn_cons
	variable/G avedia_3dplot
	string barename = replaceString("_G",mat3dn_cons,"")

	variable/G sel_multiM_3Dplot
	variable sel = sel_multiM_3Dplot
	string QA_in3dplot
	string QB_in3dplot
	if (sel == 1)
		QA_in3dplot="GlobalQA"
		QB_in3dplot="GlobalQB"
	endif
	if (sel == 0)
		QA_in3dplot="QA_in3dplot"
		QB_in3dplot="QB_in3dplot"
	endif
	wave QAw = $QA_in3dplot
	wave QBw = $QB_in3dplot



	String bare3d
	variable/G z_cons

	//** Indicative line
	string Zpp = "Zpp_"+mat3dn_cons
	wave zppw = $zpp
	Zppw=z_cons

	//Update multi-2d-lock-in
	variable/G zn_cons
	variable Z_constp=(z_cons-dimoffset($mat3dn_cons,zn_cons))/dimdelta($mat3dn_cons,zn_cons)


	//** Auto ordering layer index
		make/o/N=3 ordernum ={0,1,2}
		ordernum=abs(ordernum-zn_cons)
		wavestats/Q ordernum
		ordernum={0,1,2}
		DeletePoints V_minloc,1, ordernum
		wavestats/Q ordernum
		variable xn = ordernum[V_minloc]
		variable yn = ordernum[V_maxloc]
		killwaves ordernum


	//** g(r,V)
		bare3d = mat3dn_cons
		string sliceg = "Zslice_"+bare3d
		make/o/N=(dimsize($bare3d,xn),dimsize($bare3d,yn)) $sliceg
		setscale/p x,dimoffset($bare3d,xn),dimdelta($bare3d,xn),"",$sliceg
		setscale/p y,dimoffset($bare3d,yn),dimdelta($bare3d,yn),"",$sliceg
		wave slicegw = $sliceg
		wave bare3dw = $bare3d
		if(zn_cons == 0)
			slicegw[][]=bare3dw[Z_constp][p][q]
		endif
		if(zn_cons == 1)
			slicegw[][]=bare3dw[p][Z_constp][q]
		endif
		if(zn_cons == 2)
			slicegw[][]=bare3dw[p][q][Z_constp]
		endif
		//f_for3dmulti($sliceg)
		//String FFTg = sliceg+"_FFT"+"_Modula"
		lockinp3dp(sliceg,2*pi*QAw[0],2*pi*QAw[1],2*pi*QBw[0],2*pi*QBw[1],avedia_3dplot)
	//** T(r,V)
		string sliceT = barename+"_T"
		levelimage2($sliceT,10)
		//f_for3dmulti($sliceT)
		//String FFTT = sliceT+"_FFT"+"_Modula"
		lockinp3dp(sliceT,2*pi*QAw[0],2*pi*QAw[1],2*pi*QBw[0],2*pi*QBw[1],avedia_3dplot)

	//** I(r,V)
		bare3d = barename+"_I"
		string sliceI = "Zslice_"+bare3d
		make/o/N=(dimsize($bare3d,xn),dimsize($bare3d,yn)) $sliceI
		setscale/p x,dimoffset($bare3d,xn),dimdelta($bare3d,xn),"",$sliceI
		setscale/p y,dimoffset($bare3d,yn),dimdelta($bare3d,yn),"",$sliceI
		wave sliceIw = $sliceI
		wave bare3dw = $bare3d
		if(zn_cons == 0)
			sliceIw[][]=bare3dw[Z_constp][p][q]
		endif
		if(zn_cons == 1)
			sliceIw[][]=bare3dw[p][Z_constp][q]
		endif
		if(zn_cons == 2)
			sliceIw[][]=bare3dw[p][q][Z_constp]
		endif
		//f_for3dmulti($sliceI)
		//String FFTI = sliceI+"_FFT"+"_Modula"
		lockinp3dp(sliceI,2*pi*QAw[0],2*pi*QAw[1],2*pi*QBw[0],2*pi*QBw[1],avedia_3dplot)


	//** Z(r,V)
		bare3d = mat3dn_cons+"_Z_map"
		string sliceZ = "Zslice_"+bare3d
		make/o/N=(dimsize($bare3d,xn),dimsize($bare3d,yn)) $sliceZ
		setscale/p x,dimoffset($bare3d,xn),dimdelta($bare3d,xn),"",$sliceZ
		setscale/p y,dimoffset($bare3d,yn),dimdelta($bare3d,yn),"",$sliceZ
		wave sliceZw = $sliceZ
		wave bare3dw = $bare3d
		if(zn_cons == 0)
			sliceZw[][]=bare3dw[Z_constp][p][q]
		endif
		if(zn_cons == 1)
			sliceZw[][]=bare3dw[p][Z_constp][q]
		endif
		if(zn_cons == 2)
			sliceZw[][]=bare3dw[p][q][Z_constp]
		endif
		//f_for3dmulti($sliceZ)
		//String FFTZ = sliceZ+"_FFT"+"_Modula"

		lockinp3dp(sliceZ,2*pi*QAw[0],2*pi*QAw[1],2*pi*QBw[0],2*pi*QBw[1],avedia_3dplot)

	//** R(r,V)
		bare3d = mat3dn_cons+"_R_map"
		string sliceR = "Zslice_"+bare3d
		make/o/N=(dimsize($bare3d,xn),dimsize($bare3d,yn)) $sliceR
		setscale/p x,dimoffset($bare3d,xn),dimdelta($bare3d,xn),"",$sliceR
		setscale/p y,dimoffset($bare3d,yn),dimdelta($bare3d,yn),"",$sliceR
		wave sliceRw = $sliceR
		wave bare3dw = $bare3d
		if(zn_cons == 0)
			sliceRw[][]=bare3dw[Z_constp][p][q]
		endif
		if(zn_cons == 1)
			sliceRw[][]=bare3dw[p][Z_constp][q]
		endif
		if(zn_cons == 2)
			sliceRw[][]=bare3dw[p][q][Z_constp]
		endif
		//f_for3dmulti($sliceR)
		//String FFTR = sliceR+"_FFT"+"_Modula"
		lockinp3dp(sliceR,2*pi*QAw[0],2*pi*QAw[1],2*pi*QBw[0],2*pi*QBw[1],avedia_3dplot)


	//** Rho(r,V)
		bare3d = mat3dn_cons+"_Rho_map"
		string sliceRho = "Zslice_"+bare3d
		make/o/N=(dimsize($bare3d,xn),dimsize($bare3d,yn)) $sliceRho
		setscale/p x,dimoffset($bare3d,xn),dimdelta($bare3d,xn),"",$sliceRho
		setscale/p y,dimoffset($bare3d,yn),dimdelta($bare3d,yn),"",$sliceRho
		wave sliceRhow = $sliceRho
		wave bare3dw = $bare3d
		if(zn_cons == 0)
			sliceRhow[][]=bare3dw[Z_constp][p][q]
		endif
		if(zn_cons == 1)
			sliceRhow[][]=bare3dw[p][Z_constp][q]
		endif
		if(zn_cons == 2)
			sliceRhow[][]=bare3dw[p][q][Z_constp]
		endif
		//f_for3dmulti($sliceRho)
		//String FFTRho = sliceRho+"_FFT"+"_Modula"
		lockinp3dp(sliceRho,2*pi*QAw[0],2*pi*QAw[1],2*pi*QBw[0],2*pi*QBw[1],avedia_3dplot)
end

Function SetVarProc_avedia_3dplot(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	string/G mat3dn_cons
	variable/G avedia_3dplot
	string barename = replaceString("_G",mat3dn_cons,"")


	variable/G sel_multiM_3Dplot
	variable sel = sel_multiM_3Dplot
	string QA_in3dplot
	string QB_in3dplot
	if (sel == 1)
		QA_in3dplot="GlobalQA"
		QB_in3dplot="GlobalQB"
	endif
	if (sel == 0)
		QA_in3dplot="QA_in3dplot"
		QB_in3dplot="QB_in3dplot"
	endif
	wave QAw = $QA_in3dplot
	wave QBw = $QB_in3dplot


	String bare3d

	//Update multi-2d-lock-in
	//** g(r,V)
		bare3d = mat3dn_cons
		string sliceg = "Zslice_"+bare3d
		lockinp3dp(sliceg,2*pi*QAw[0],2*pi*QAw[1],2*pi*QBw[0],2*pi*QBw[1],avedia_3dplot)
	//** T(r,V)
		string sliceT = barename+"_T"
		lockinp3dp(sliceT,2*pi*QAw[0],2*pi*QAw[1],2*pi*QBw[0],2*pi*QBw[1],avedia_3dplot)

	//** I(r,V)
		bare3d = barename+"_I"
		string sliceI = "Zslice_"+bare3d
		lockinp3dp(sliceI,2*pi*QAw[0],2*pi*QAw[1],2*pi*QBw[0],2*pi*QBw[1],avedia_3dplot)

	//** Z(r,V)
		bare3d = mat3dn_cons+"_Z_map"
		string sliceZ = "Zslice_"+bare3d
		lockinp3dp(sliceZ,2*pi*QAw[0],2*pi*QAw[1],2*pi*QBw[0],2*pi*QBw[1],avedia_3dplot)

	//** R(r,V)
		bare3d = mat3dn_cons+"_R_map"
		string sliceR = "Zslice_"+bare3d
		lockinp3dp(sliceR,2*pi*QAw[0],2*pi*QAw[1],2*pi*QBw[0],2*pi*QBw[1],avedia_3dplot)

	//** Rho(r,V)
		bare3d = mat3dn_cons+"_Rho_map"
		string sliceRho = "Zslice_"+bare3d
		lockinp3dp(sliceRho,2*pi*QAw[0],2*pi*QAw[1],2*pi*QBw[0],2*pi*QBw[1],avedia_3dplot)
end

Function lockinp3dp(name,qx1,qy1,qx2,qy2,avedia)
	String name    // the data to be manipulated
	variable qx1   // The FFT value of the vector, conversion (1/a), the scaled value directly readed from igor FFT image.
	variable qy1
	variable qx2
	variable qy2
	variable avedia //The FWHM in real space (guassian window)


	wave namew =  $name
	variable widthq
	widthq=(2*sqrt(ln(2)))/avedia

	//** Norm Data ********************************************
		String normdata = name+"_normdata"
		duplicate/o namew $normdata
		wave normdataw = $normdata
		normdataw = 1
		string normdataFFT = normdata+"_FFT"
		FFT/PAD={3*dimsize(namew,0),3*dimsize(namew,1)}/OUT=1/DEST=$normdataFFT  normdataw
		wave/c normdataFFTw = $normdataFFT

		normdataFFTw*=(sqrt(pi)*widthq)^(-1)*exp((-x^2-y^2)/(widthq^2))
		//normdataFFTw*=exp((-x^2-y^2)/(widthq^2))
		string normdataiff = normdata+"_IFF"
		IFFT/DEST=$normdataiff  normdataFFTw
		wave normdataiffw =$normdataiff
		unpadding(name,normdataiffw)
		string afternorm = normdataiff+"_up"
		wave afternormw = $afternorm

	//** Q_A ********************************************
	string tphase1,tamp1
	tphase1 = name+"_phi_A"
	tamp1 = name+"_amp_A"
		//****real part cosine
			String nameFFT1c,namec1c,nameFFTfilter1c,nameiff1c
			namec1c = name+"c1c"
			nameFFT1c = name+"raw_FFT1c"
			nameFFTfilter1c = nameFFT1c+"filter1c"
			nameiff1c = name+"ifft1c"
			duplicate/o namew $namec1c
			wave namec1cw = $namec1c
			namec1cw=namew*cos(qx1*x+qy1*y)
			FFT/PAD={3*dimsize(namew,0),3*dimsize(namew,1)}/OUT=1/DEST=$nameFFT1c  namec1cw
			wave/c nameFFT1cw = $nameFFT1c
			//di(nameFFT1cw)
			duplicate/c/o nameFFT1cw $nameFFTfilter1c
			wave/c nameFFTfilter1cw=$nameFFTfilter1c
			nameFFTfilter1cw=nameFFT1cw*(sqrt(pi)*widthq)^(-1)*exp((-x^2-y^2)/(widthq^2))
			//nameFFTfilter1cw=nameFFT1cw*exp((-x^2-y^2)/(widthq^2))

			IFFT/DEST=$nameiff1c  nameFFTfilter1cw
			wave nameiff1cw=$nameiff1c

			unpadding(name,nameiff1cw)
			string afterup1c = nameiff1c+"_up"
			wave afterup1cw = $afterup1c
			//di(afterup1cw)

		//****Imag part cosine
			String nameFFT1s,namec1s,nameFFTfilter1s,nameiff1s
			namec1s = name+"c1s"
			nameFFT1s = name+"raw_FFT1s"
			nameFFTfilter1s = nameFFT1s+"filter1s"
			nameiff1s = name+"ifft1s"
			duplicate/o namew $namec1s
			wave namec1sw = $namec1s
			namec1sw=namew*sin(qx1*x+qy1*y)
			FFT/PAD={3*dimsize(namew,0),3*dimsize(namew,1)}/OUT=1/DEST=$nameFFT1s  namec1sw
			wave/c nameFFT1sw = $nameFFT1s
			//di(nameFFT1sw)
			duplicate/c/o nameFFT1sw $nameFFTfilter1s
			wave/c nameFFTfilter1sw=$nameFFTfilter1s
			nameFFTfilter1sw=nameFFT1sw*(sqrt(pi)*widthq)^(-1)*exp((-x^2-y^2)/(widthq^2))
			//nameFFTfilter1sw=nameFFT1sw*exp((-x^2-y^2)/(widthq^2))
			IFFT/DEST=$nameiff1s  nameFFTfilter1sw
			wave nameiff1sw=$nameiff1s

			unpadding(name,nameiff1sw)
			string afterup1s = nameiff1s+"_up"
			wave afterup1sw = $afterup1s
			//di(afterup1sw)

	    //****calculate phase field theta1(r)
			duplicate/o namew $tphase1
			wave tphase1w = $tphase1
			//tphase1w=atan2(afterup1sw,afterup1cw)
			tphase1w=atan2(afterup1sw/afternormw,afterup1cw/afternormw)


		//****calculate amplitude field A1(r)
			duplicate/o namew $tamp1
			wave tamp1w = $tamp1
			tamp1w=sqrt((afterup1sw/afternormw)^2+(afterup1cw/afternormw)^2)
			//tamp1w=sqrt((afterup1sw)^2+(afterup1cw)^2)


	//** Q_B ********************************************
	string tphase2,tamp2
	tphase2 = name+"_phi_B"
	tamp2 = name+"_amp_B"

		//****real part cosine
			String nameFFT2c,namec2c,nameFFTfilter2c,nameiff2c
			namec2c = name+"c2c"
			nameFFT2c = name+"raw_FFT2c"
			nameFFTfilter2c = nameFFT2c+"filter2c"
			nameiff2c = name+"ifft2c"
			duplicate/o namew $namec2c
			wave namec2cw = $namec2c
			namec2cw=namew*cos(qx2*x+qy2*y)
			FFT/PAD={3*dimsize(namew,0),3*dimsize(namew,1)}/OUT=1/DEST=$nameFFT2c  namec2cw
			wave/c nameFFT2cw = $nameFFT2c
			//di(nameFFT2cw)
			duplicate/c/o nameFFT2cw $nameFFTfilter2c
			wave/c nameFFTfilter2cw=$nameFFTfilter2c
			nameFFTfilter2cw=nameFFT2cw*(sqrt(pi)*widthq)^(-1)*exp((-x^2-y^2)/(widthq^2))
			//nameFFTfilter2cw=nameFFT2cw*exp((-x^2-y^2)/(widthq^2))
			IFFT/DEST=$nameiff2c  nameFFTfilter2cw
			wave nameiff2cw=$nameiff2c

			unpadding(name,nameiff2cw)
			string afterup2c = nameiff2c+"_up"
			wave afterup2cw = $afterup2c
			//di(afterup2cw)

		//****Imag part cosine
			String nameFFT2s,namec2s,nameFFTfilter2s,nameiff2s
			namec2s = name+"c2s"
			nameFFT2s = name+"raw_FFT2s"
			nameFFTfilter2s = nameFFT2s+"filter2s"
			nameiff2s = name+"ifft2s"
			duplicate/o namew $namec2s
			wave namec2sw = $namec2s
			namec2sw=namew*sin(qx2*x+qy2*y)
			FFT/PAD={3*dimsize(namew,0),3*dimsize(namew,1)}/OUT=1/DEST=$nameFFT2s  namec2sw
			wave/c nameFFT2sw = $nameFFT2s
			//di(nameFFT2sw)
			duplicate/c/o nameFFT2sw $nameFFTfilter2s
			wave/c nameFFTfilter2sw=$nameFFTfilter2s
			nameFFTfilter2sw=nameFFT2sw*(sqrt(pi)*widthq)^(-1)*exp((-x^2-y^2)/(widthq^2))
			//nameFFTfilter2sw=nameFFT2sw*exp((-x^2-y^2)/(widthq^2))
			IFFT/DEST=$nameiff2s  nameFFTfilter2sw
			wave nameiff2sw=$nameiff2s

			unpadding(name,nameiff2sw)
			string afterup2s = nameiff2s+"_up"
			wave afterup2sw = $afterup2s
			//di(afterup2sw)

	    //****calculate phase field
			duplicate/o namew $tphase2
			wave tphase2w = $tphase2
			//tphase2w=atan2(afterup2sw,afterup2cw)
			tphase2w=atan2(afterup2sw/afternormw,afterup2cw/afternormw)

		//****calculate amplitude field A1(r)
			duplicate/o namew $tamp2
			wave tamp2w = $tamp2
			tamp2w=sqrt((afterup2sw/afternormw)^2+(afterup2cw/afternormw)^2)
			//tamp2w=sqrt((afterup2sw)^2+(afterup2cw)^2)

	//****calculate amplitude Anisotropy Field F(r)
		String Fmat = name+"_Fr"
			duplicate/o namew $Fmat
			wave Fmatw = $Fmat
			Fmatw=(tamp1w - tamp2w)/(tamp2w+tamp1w)
			//tamp2w=sqrt((afterup2sw)^2+(afterup2cw)^2)

end


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** {{{{{{{{{{ Lattice segregation  }}}}}}}}}}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_ls3dcons(ctrlName) : ButtonControl
	String ctrlName
	Execute "ffc3dpls()"
End
Proc ffc3dpls(topo)
	string topo =stringfromlist(0,getall2dwave())
	PROMPT topo,"Name of Topograph (The wave from which lattice location can be extracted)"
	string/G Topo_cons = topo
	string/G mat3dn_cons
	variable/G zn_cons
	variable/G z_cons
	String slicename = "Zslice_"+mat3dn_cons
	//string barename = replaceString("_G",mat3dn_cons,"")
	//string sliceT = barename+"_T"

	ff3dpls($topo,2)
	string aa=topo+"_FFT_Modula_INTER"
	tilewindows/WINS=grabwinnonew(aa)/R/w=(29.5,0,83,85)/A=(1,1)

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

Function ff3dpls(name,sel)
	wave name
	variable sel

	duplicate/o name named
	func_NaN0(named)
	String FFTout
	FFTout = nameofWave(name) + "_FFT"
	if (sel == 1)
		FFT/out=1/DEST=$FFTout cvtcmplx(named)
	endif
	if (sel == 2)
		duplicate/o named nametemp_fft
		imagewindow/O hanning nametemp_fft
		FFT/out=1/DEST=$FFTout cvtcmplx(nametemp_fft)
		killwaves nametemp_fft
	endif
	Complextorealf13dpls($FFTout,1)
	String FFToutm = FFTout+"_Modula"
	killwaves named
	twoDinterpolatexyFFT3dpls(FFToutm,10*dimsize($FFTout,0),10*dimsize($FFTout,1))
	Modifygraph width=200,height=200
	//ShowInfo

	Button Map793dls title="Get A",proc=ButtonProc_GPAc3dpls
	Button Map803dls title="Get B",proc=ButtonProc_GPBc3dpls
	Button Symx123dls title="Lattice Segregation",size={150,20},proc=ButtonProc_latticesergeon3d

	//killwaves
		String namec
		namec = "c_"+nameofwave(name)
		string FFToutm1 = FFToutm+"1"
		killwaves $FFTout $namec  $FFToutm1 //$FFToutm
end

Function Complextorealf13dpls(name1w,select)
	wave name1w
	variable select
	string name
	string name1 = nameOfWave(name1w)
	if (select==1)
		name=name1+"_Modula"
		make/o/N=(dimsize(name1w,0),dimsize(name1w,1)) $name
		wave namew = $name
		namew=sqrt(real(name1w)^2+imag(name1w)^2)
	endif
	setscale/i x,dimoffset(name1w,0),dimoffset(name1w,0)+dimdelta(name1w,0)*(dimsize(name1w,0)-1),"",namew
	setscale/i y,dimoffset(name1w,1),dimoffset(name1w,1)+dimdelta(name1w,1)*(dimsize(name1w,1)-1),"",namew
end

Function twoDinterpolatexyFFT3dpls(name,xpoint,ypoint)
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

	CheckDisplayed $name2
	if (V_flag == 1)
		print "display;appendimage " + name2+";ModifyGraph width={Plan,1,bottom,left}"
	else
	endif
	killwindow $grabwin2(name2)
	dilf($name2)
	wavestats/Q $name2
	color3s($name2,30)
end
///////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_GPAc3dpls(ctrlName) : ButtonControl
	String ctrlName
	Execute "gpac3dpls()"
end
Proc gpac3dpls()
	//string name="Zslice_" +mat3dn_cons+"_FFT_Modula_INTER"
	//string barename = replaceString("_G",mat3dn_cons,"")
	//string sliceT = barename+"_T"
	//string name = sliceT+"_FFT_Modula_INTER"
	string name = Topo_cons+"_FFT_Modula_INTER"
	Gpa3dpls(name)
End
Function/Wave GpA3dpls(name111)
	String name111
	//string nameraw
	GetMarquee left, bottom

	wave name111w = $name111
	String name1111 = name111+"_f"
	duplicate/o name111w $name1111
	wave name1111w=$name1111
	name1111w=nan;
	//CurveFit/Q gauss2D name111w[pcsr(A),pcsr(b)][qcsr(A),qcsr(b)] /D=name1111w[pcsr(A),pcsr(b)][qcsr(A),qcsr(b)];
	CurveFit/Q gauss2D name111w(V_left,V_right)(V_bottom,V_top) /D=name1111w(V_left,V_right)(V_bottom,V_top);

	//AppendMatrixContour $name1111
	variable xa_G, ya_G, wx,wy
	string W_coef = "W_coef"
	wave W_coefw = $W_coef
	xa_G = W_coefw[2]
	ya_G = W_coefw[4]
	wx = W_coefw[3]
	wy = W_coefw[5]
	//Print "Coordiante (x,y) from Figure is ("+num2str(xa_G)+","+num2str(ya_G)+")."
	//SVAR namefftraw = $namefftraw
	string/G mat3dn_cons
	//String slicename = "Zslice_"+mat3dn_cons
	//string barename = replaceString("_G",mat3dn_cons,"")
	//string sliceT = barename+"_T"
	string/G Topo_cons
	String cpickas = Topo_cons+"_QA"
		//print cpickas
	make/N=4/o $cpickas
	wave cpicka = $cpickas
	cpicka[0] = xa_G
	cpicka[1] = ya_G
	cpicka[2] = wx
	cpicka[3] = wy
	//Print "Qa got. Qa = ("+num2str(xa_G)+","+num2str(ya_G)+")"
	TextBox/C/N=text0/F=0/A=LB/X=0.00/Y=0.00 "Qa got. Qa = ("+num2str(xa_G)+","+num2str(ya_G)+")"
	string Fitq1x ="getq1x"
	string Fitq1y ="getq1y"
	make/N=1/o $Fitq1x
	make/N=1/o $Fitq1y
	wave Fitq1xw = $Fitq1x
	wave Fitq1yw = $Fitq1y
	Fitq1xw[0] = xa_G
	Fitq1yw[0] = ya_G
	if(ckwaveonfig(winname(0,1),Fitq1y)==0)
		appendtograph Fitq1yw vs Fitq1xw
		ModifyGraph mode=3,marker=1,rgb=(65535,0,0), mrkThick=1
	endif
	Return cpicka
end
////////////////////////////////////////////////
Function ButtonProc_GpBc3dpls(ctrlName) : ButtonControl
	String ctrlName
	Execute "gpbc3dpls()"
end

Proc gpbc3dpls()
	//string name="Zslice_" +mat3dn_cons+"_FFT_Modula_INTER"
	//string barename = replaceString("_G",mat3dn_cons,"")
	//string sliceT = barename+"_T"
	//string name = sliceT+"_FFT_Modula_INTER"
	string name = Topo_cons+"_FFT_Modula_INTER"
	GpB3dpls(name)
End
Function/Wave GpB3dpls(name111)
	String name111
	string nameraw
	wave name111w = $name111
	String name1111 = name111+"_f"
	duplicate/o name111w $name1111
	wave name1111w=$name1111
	name1111w=nan;
	GetMarquee left, bottom
	CurveFit/Q gauss2D name111w(V_left,V_right)(V_bottom,V_top) /D=name1111w(V_left,V_right)(V_bottom,V_top);


	variable xa_G, ya_G, wx,wy
	string W_coef = "W_coef"
	wave W_coefw = $W_coef
	xa_G = W_coefw[2]
	ya_G = W_coefw[4]
	wx = W_coefw[3]
	wy = W_coefw[5]
	//Print "Coordiante (x,y) from Figure is ("+num2str(xa_G)+","+num2str(ya_G)+")."
	//SVAR namefftraw = $namefftraw
	string/G mat3dn_cons
	//String slicename = "Zslice_"+mat3dn_cons
	//string barename = replaceString("_G",mat3dn_cons,"")
	//string sliceT = barename+"_T"
	string/G Topo_cons
	String cpickbs = Topo_cons+"_QB"
	//String cpickbs = "QB_in3dplotls"
	make/N=4/o $cpickbs
	wave cpickb = $cpickbs
	cpickb[0] = xa_G
	cpickb[1] = ya_G
	cpickb[2] = wx
	cpickb[3] = wy
	//Print "Qb got. Qb = ("+num2str(xa_G)+","+num2str(ya_G)+")"
	TextBox/C/N=text1/F=0/A=LB/X=0.00/Y=10.00 "Qb got. Qb = ("+num2str(xa_G)+","+num2str(ya_G)+")"
	string Fitq1x ="getq2x"
	string Fitq1y ="getq2y"
	make/N=1/o $Fitq1x
	make/N=1/o $Fitq1y
	wave Fitq1xw = $Fitq1x
	wave Fitq1yw = $Fitq1y
	Fitq1xw[0] = xa_G
	Fitq1yw[0] = ya_G
	if(ckwaveonfig(winname(0,1),Fitq1y)==0)
		appendtograph Fitq1yw vs Fitq1xw
		ModifyGraph mode=3,marker=1,rgb=(65535,0,0), mrkThick=1
	endif
	Return cpickb
end

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_latticesergeon3d(ctrlName) : ButtonControl
	String ctrlName
	string/G mat3dn_cons
	variable/G zn_cons
	variable/G z_cons
	variable/G avedia_3dplot = 1.1*dimsize($mat3dn_cons,0)*dimdelta($mat3dn_cons,0)/2//**********************
	variable Z_constp=(z_cons-dimoffset($mat3dn_cons,zn_cons))/dimdelta($mat3dn_cons,zn_cons)
	string/G Topo_cons

	string barename = replaceString("_G",mat3dn_cons,"")
	//string sliceT = barename+"_T"
	String cpickas = Topo_cons+"_QA"
	String cpickbs = Topo_cons+"_QB"

	string QA_in3dplot=cpickas
	wave QAw = $QA_in3dplot
	string QB_in3dplot=cpickbs
	wave QBw = $QB_in3dplot

	//** Auto ordering layer index
		make/o/N=3 ordernum ={0,1,2}
		ordernum=abs(ordernum-zn_cons)
		wavestats/Q ordernum
		ordernum={0,1,2}
		DeletePoints V_minloc,1, ordernum
		wavestats/Q ordernum
		variable xn = ordernum[V_minloc]
		variable yn = ordernum[V_maxloc]
		killwaves ordernum

	String bare3d
	//** g(r,V)
		bare3d = mat3dn_cons
		string sliceg = "Zslice_"+mat3dn_cons
		make/o/N=(dimsize($bare3d,xn),dimsize($bare3d,yn)) $sliceg
		setscale/p x,dimoffset($bare3d,xn),dimdelta($bare3d,xn),"",$sliceg
		setscale/p y,dimoffset($bare3d,yn),dimdelta($bare3d,yn),"",$sliceg
		wave slicegw = $sliceg
		wave bare3dw = $bare3d
		if(zn_cons == 0)
			slicegw[][]=bare3dw[Z_constp][p][q]
		endif
		if(zn_cons == 1)
			slicegw[][]=bare3dw[p][Z_constp][q]
		endif
		if(zn_cons == 2)
			slicegw[][]=bare3dw[p][q][Z_constp]
		endif
		//f_for3dmulti($sliceg)
		//String FFTg = sliceg+"_FFT"+"_Modula"
		LS22(sliceg,Topo_cons)
		string graphname ="Getref_"+topo_cons
		string graphname1 ="Segregated_"+sliceg
		Modifygraph/W=$graphname width=500*0.8,height=650*0.7
		tilewindows/WINS=graphname/R/w=(3,53,100,100)/A=(1,1)
		tilewindows/WINS=graphname1/R/w=(30,0,100,100)/A=(1,1)
		tilewindows/WINS=winname(0,2)/R/w=(30,72,53,100)/A=(1,1)

	string slicename = "Zslice_"+mat3dn_cons
	variable/G contour_3dplot = 0
	SetVariable appendmatrix win=$grabwinnonew(slicename), title="Ctr",size={65,14},value=contour_3dplot,limits={0,1,1},proc=SetVarProc_appendmatrix,pos={1,91}
end

Function SetVarProc_appendmatrix(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/G contour_3dplot

	string/G mat3dn_cons
	variable/G zn_cons
	variable/G z_cons
	//variable/G avedia_3dplot = 1.1*dimsize($mat3dn_cons,0)*dimdelta($mat3dn_cons,0)/2//**********************
	//variable Z_constp=(z_cons-dimoffset($mat3dn_cons,zn_cons))/dimdelta($mat3dn_cons,zn_cons)
	//string/G Topo_cons

	string barename = replaceString("_G",mat3dn_cons,"")
	string coutourname = "fit_"+barename+"_T_ftd"
	if (contour_3dplot == 0)
	//AppendMatrixContour fit_g2_003_T_ftd;ModifyContour fit_g2_003_T_ftd autoLevels={0.5,0.5,11}
		RemoveContour $coutourname
		//** Error message, no stop but Continuing execution
		String msg
		Variable err
		msg=GetErrMessage(GetRTError(0),3);
		err=GetRTError(1)
		if (err != 0)
			//Print "Error in Demo: " + msg
			//Print "Continuing execution"
		endif
	endif
	if (contour_3dplot == 1)
		AppendMatrixContour $coutourname;ModifyContour $coutourname autoLevels={0.5,0.5,11}
	endif

end

Function color3s_for3dm2(name,tt)
	wave name
	variable tt
	gethistgram_npcolor(nameofwave(name))
	string W_coef = "W_coef"
	wave W_coefw = $W_coef
	variable sigma = sqrt(2)*W_coefw[3]

	wavestats/Q name
	variable lc,lh
	if (W_coefw[2]-0.5*tt*sigma >V_min)
		lc = W_coefw[2]-0.5*tt*sigma
	else
		lc =V_min
	endif
	if (W_coefw[2]+0.5*tt*sigma < V_max)
		lh = W_coefw[2]+0.5*tt*sigma
	else
		lh =V_max
	endif

	ModifyImage/W=$grabwinchild2(nameofwave(name)) $nameofwave(name) ctab= {lc,lh,VioletOrangeYellow,0}
	//PRINT num2str(W_coefw[2]-1.5*sigma)+" "+ num2str(W_coefw[2]+1.5*sigma)
	//print num2str(W_coefw[2])
	//display namehistw
end
Function/s grabwinchild2(name)
	string name
 	string fulllist = WinList("*", ";","WIN:1")
	string nn,waveong,cmdn,out,childchild
	out = ""
	variable i,j
	for(i=0; i<itemsinlist(fulllist); i +=1)
        nn= stringfromlist(i, fulllist)
        if(itemsInList(childWindowList(nn)) == 0)
        else
        	j=0
        	do
        		childchild = stringfromlist(j,childWindowList(nn))
        		cmdn="WIN:"+nn+"#"+childchild
        		//print cmdn
        		waveong = stringfromlist(1,WaveList("*", ";",cmdn))  //Only detect the first element.
        		if (CmpStr(name,waveong) == 0)
        			out = nn+"#"+childchild
        		else
        		endif
        	j+=1
        	while(j < itemsInList(childWindowList(nn)))

        endif
    endfor
    Return out
end


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** {{{{{{{{{{ MultiFunctional FFT with in a Marquee  }}}}}}}}}}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function PopMenuProc_FFTmarquearea_3dplot(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	drawAction delete

	variable/G FFTmarque_3dplot
	FFTmarque_3dplot = popNum // 1 for whole, 2 for in marque
	if (FFTmarque_3dplot == 1)
		DoFFT_3dplot()
	endif
	if (FFTmarque_3dplot == 2)
		DoFFT_3dplot_marquee()
	endif
End

Function Frommarqueegetsubmatrix(name)
	string name
	getmarquee/W=$winname(0,1) left, bottom
	variable p1,p2,q1,q2
	string/G mat3dn_cons
	string slicename = "Zslice_"+mat3dn_cons
	p1 = round((v_left-dimoffset($name,0))/dimdelta($name,0))
	p2 = round((v_right-dimoffset($name,0))/dimdelta($name,0))
	q1 = round((v_bottom-dimoffset($name,1))/dimdelta($name,1))
	q2 = round((v_top-dimoffset($name,1))/dimdelta($name,1))

	//print p1,p2,q1,q2
	duplicate/o $name ttop
	duplicate/o $name tempmean
	func_NaN0(tempmean)
	variable meanv=mean(tempmean)
	killwaves tempmean
	variable i,j
	i=0
	do
		j=0
		do
			if(i >= p1 && i <= p2 && j >= q1 && j <= q2)
			else
				 ttop[i][j]=meanv
			endif
			j+=1
		while (j<dimsize(ttop,1))
	i+=1
	while(i<dimsize(ttop,0))


	make/N=4/o PartialFFTsel
	PartialFFTsel={V_left,V_right,V_bottom,V_top}

	drawAction delete

	if (waveexists(PartialFFTsel) == 1)
		SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),fillpat= 0,linethick= 1.00;DelayUpdate
		DrawRect PartialFFTsel[0],PartialFFTsel[2],PartialFFTsel[1],PartialFFTsel[3]
	endif
end

Function DoFFT_3dplot_marquee()
	String/G FFTWin_3dplot
	variable/G FFTmode_3dplot

	string/G mat3dn_cons
	wave mat3dw = $mat3dn_cons
	variable/G zn_cons

	//** Auto ordering layer index
		variable zn = zn_cons
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

	string Mode
	string win

	//Set mode
	if(mod(FFTmode_3dplot,1) == 0)
		Mode = "/OUT="+num2str(FFTmode_3dplot)
	else
		Mode = "/OUT=1"
		//this is for imag mode rewrite
	endif

	//Set window
	if(cmpstr(FFTWin_3dplot,"None") == 0)
		win = ""
	elseif (cmpstr(FFTWin_3dplot,"") == 0)
	else
		win = "imagewindow/o "+FFTWin_3dplot+" FFTslicetemp"
	endif

	make/O/N=(dimsize($mat3dn_cons,xn),dimsize($mat3dn_cons,yn)) FFTslicetemp
	setscale/p x,dimoffset($mat3dn_cons,xn),dimdelta($mat3dn_cons,xn),"",FFTslicetemp
	setscale/p y,dimoffset($mat3dn_cons,yn),dimdelta($mat3dn_cons,yn),"",FFTslicetemp

	duplicate/o FFTslicetemp FFTslicetemp2
	string ttop

	string FFT3dmatrix = mat3dn_cons+"_FFT3d"
	variable i


	string FFTout = "FFTdesttemp"
	string body
	body = "FFT"+Mode+"/DEST=FFTdesttemp cvtcmplx(FFTslicetemp)"

	//print body

	if(zn_cons == 0)
			make/O/N=(dimsize($mat3dn_cons,zn),dimsize($mat3dn_cons,xn),dimsize($mat3dn_cons,yn)) $FFT3dmatrix

			wave FFT3dmatrixw = $FFT3dmatrix

			i=0
			do
				FFTslicetemp2[][] = mat3dw[i][p][q]
				frommarqueegetsubmatrix("FFTslicetemp2")
				ttop="ttop"
				wave ttopw = $ttop
				FFTslicetemp = ttopw
				func_naN0(FFTslicetemp)
				execute win
				execute body
				wave FFToutw = $FFTout
				if(mod(FFTmode_3dplot,1) == 0)
					FFT3dmatrixw[i][][] = FFToutw[p][q]
				else
					Complextoimag(FFToutw)
					FFT3dmatrixw[i][][] = FFToutw[p][q]
				endif
				i+=1
			while(i<dimsize($mat3dn_cons,zn))
			setscale/p x,dimoffset($mat3dn_cons,zn),dimdelta($mat3dn_cons,zn),"",$FFT3dmatrix
			setscale/p y,dimoffset(FFToutw,0),dimdelta(FFToutw,0),"",$FFT3dmatrix
			setscale/p z,dimoffset(FFToutw,1),dimdelta(FFToutw,1),"",$FFT3dmatrix
			killwaves FFToutw FFTslicetemp
	endif

	if(zn_cons == 1)
			make/O/N=(dimsize($mat3dn_cons,xn),dimsize($mat3dn_cons,zn),dimsize($mat3dn_cons,yn)) $FFT3dmatrix

			wave FFT3dmatrixw = $FFT3dmatrix

			i=0
			do
				FFTslicetemp2[][] = mat3dw[p][i][q]
				frommarqueegetsubmatrix("FFTslicetemp2")
				ttop="ttop"
				wave ttopw = $ttop
				FFTslicetemp = ttopw
				func_naN0(FFTslicetemp)
				//FFTslicetemp[][] = mat3dw[p][i][q]
				execute win
				execute body
				wave FFToutw = $FFTout
				if(mod(FFTmode_3dplot,1) == 0)
					FFT3dmatrixw[][i][] = FFToutw[p][q]
				else
					Complextoimag(FFToutw)
					FFT3dmatrixw[][i][] = FFToutw[p][q]
				endif
				i+=1
			while(i<dimsize($mat3dn_cons,zn))
			setscale/p x,dimoffset(FFToutw,0),dimdelta(FFToutw,0),"",$FFT3dmatrix
			setscale/p y,dimoffset($mat3dn_cons,zn),dimdelta($mat3dn_cons,zn),"",$FFT3dmatrix
			setscale/p z,dimoffset(FFToutw,1),dimdelta(FFToutw,1),"",$FFT3dmatrix
			killwaves FFToutw FFTslicetemp
	endif

	if(zn_cons == 2)
			make/O/N=(dimsize($mat3dn_cons,xn),dimsize($mat3dn_cons,yn),dimsize($mat3dn_cons,zn)) $FFT3dmatrix

			wave FFT3dmatrixw = $FFT3dmatrix

			i=0
			do
				FFTslicetemp2[][] = mat3dw[p][q][i]
				frommarqueegetsubmatrix("FFTslicetemp2")
				ttop="ttop"
				wave ttopw = $ttop
				FFTslicetemp = ttopw
				func_naN0(FFTslicetemp)
				//FFTslicetemp[][] = mat3dw[p][q][i]
				execute win
				execute body
				wave FFToutw = $FFTout
				if(mod(FFTmode_3dplot,1) == 0)
					FFT3dmatrixw[][][i] = FFToutw[p][q]
				else
					Complextoimag(FFToutw)
					FFT3dmatrixw[][][i] = FFToutw[p][q]
				endif
				i+=1
			while(i<dimsize($mat3dn_cons,zn))
			setscale/p x,dimoffset(FFToutw,0),dimdelta(FFToutw,0),"",$FFT3dmatrix
			setscale/p y,dimoffset(FFToutw,1),dimdelta(FFToutw,1),"",$FFT3dmatrix
			setscale/p z,dimoffset($mat3dn_cons,zn),dimdelta($mat3dn_cons,zn),"",$FFT3dmatrix
			//killwaves FFToutw FFTslicetemp
	endif
	killwaves ttopw
	execute "d3dfft()"
end

///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Fmarqueegetsub(ctrlName) : ButtonControl
	String ctrlName
	Execute "Frommarqueegetsubmatrixsc()"
end
Proc Frommarqueegetsubmatrixsc(name)
	string name = tpw()
	prompt name,"Wave name to put marquee"
	Frommarqueegetsubmatrixs(name)
end
Function Frommarqueegetsubmatrixs(name)
	string name
	di($name)
	getmarquee/W=$winname(0,1) left, bottom
	variable p1,p2,q1,q2


	p1 = round((v_left-dimoffset($name,0))/dimdelta($name,0))
	p2 = round((v_right-dimoffset($name,0))/dimdelta($name,0))
	q1 = round((v_bottom-dimoffset($name,1))/dimdelta($name,1))
	q2 = round((v_top-dimoffset($name,1))/dimdelta($name,1))

	//print p1,p2,q1,q2
	duplicate/o $name ttop
	duplicate/o $name tempmean
	//func_NaN0(tempmean)
	variable meanv=mean(tempmean)
	killwaves tempmean
	variable i,j
	i=0
	do
		j=0
		do
			if(i >= p1 && i <= p2 && j >= q1 && j <= q2)
			else
				 ttop[i][j]=nan
			endif
			j+=1
		while (j<dimsize(ttop,1))
	i+=1
	while(i<dimsize(ttop,0))


	make/N=4/o PartialFFTsel
	PartialFFTsel={V_left,V_right,V_bottom,V_top}

	drawAction delete

	if (waveexists(PartialFFTsel) == 1)
		SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),fillpat= 0,linethick= 1.00;DelayUpdate
		DrawRect PartialFFTsel[0],PartialFFTsel[2],PartialFFTsel[1],PartialFFTsel[3]
	endif
	string nameout = "SelectA_"+name
	duplicate/o ttop $nameout
	wave nameoutw = $nameout
	di(nameoutw)
	Button b1 pos={1,1},size={120,20},title="Calculate average",proc=ButtonProc_ave


	killwaves ttop
end
Function ButtonProc_ave(ctrlName) : ButtonControl
	String ctrlName
	Print "Average value of the Marquee area is " + num2str(ave_inmarque())
end
Function ave_inmarque()
	wave name = $tpw()
	variable i,j
	variable ave = 0
	variable count = 0
	variable suma = 0

	i=0
	do
		j=0
		do
			if(mod(Round(name[i][j]),1)!=0)
			else
				suma += name[i][j]
				count += 1
			Endif
			j+=1
		while (j<dimsize(name,1))
		i+=1
	while (i<dimsize(name,0))
	ave =  suma/count
	return ave
end
///////////////////////////////////////////////////////////////////////////////////


Function ButtonProc_selecshowsp(ctrlName) : ButtonControl
	String ctrlName
	execute "maf()"
end
proc maf()
	variable a = pcsr(A)
	variable b = qcsr(A)
	string name = "sts_"+num2str(a)+"_"+num2str(b)
	string nameo = "sts_"+mat3dn_cons

	duplicate/o $nameo $name;
	display $name;
	normwave(name,-15,15);
	smooth 2,$name;
	SetAxis left -0.15,*;
	SetAxis bottom -14.9,14.9;
	ModifyGraph lsize=2,rgb=(0,0,0);
	modifygraph width=300,height=130
	ModifyGraph mirror=2
	ModifyGraph tick=2
	ModifyGraph noLabel=2,axThick=2
	tilewindows/WINS=winname(0,1)/R/w=(40,0,83,85)/A=(1,1)
end

Function ButtonProc_lsturnoff3d(ctrlName) : ButtonControl
	String ctrlName

	string/G topo_cons
	string/G mat3dn_cons

	//string matnew = stringfromlist(0,mat3dn_cons,"_")+"_"+stringfromlist(1,mat3dn_cons,"_")+"_"+stringfromlist(2,mat3dn_cons,"_")
	//string win2 = "graph"+num2str(str2num(replaceString("graph",winname(0,1),""))+1)
	killwindow $winname(0,1)
	killwindow ThreeDPlotFTslicewin

	//killwindow $win2
	//mat3dn_cons = matnew
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

Function removeappendimage()
	Variable popNum = 1

	string/G mat3dn_cons


	string slicename = "Zslice_"+mat3dn_cons

	string appendvalue

	//Get Bare string
			//**This due to sometime the input 3dwave is not g(r,V)
		string barename
		//#case of R map
		if (stringmatch(mat3dn_cons,"*_R_map") == 1)
			barename = replaceString("_R_map",mat3dn_cons,"")
		//#case of Z map
		elseif (stringmatch(mat3dn_cons,"*_Z_map") == 1)
			barename = replaceString("_Z_map",mat3dn_cons,"")
		//#case of Rho map
		elseif (stringmatch(mat3dn_cons,"*_Rho_map") == 1)
			barename = replaceString("_Rho_map",mat3dn_cons,"")
		//#case of I map
		elseif (stringmatch(mat3dn_cons,"*_I") == 1)
			barename = replaceString("_I",mat3dn_cons,"")+"_G"
		elseif (stringmatch(mat3dn_cons,"*_G") == 1)
			barename = mat3dn_cons
		endif


	string gapmap = barename+"_Gap_map"

	if (waveexists($gapmap) == 1)
		appendvalue = "Remove;T(r);Δ(r)"
	else
		appendvalue = "Remove;T(r)"
	endif
	string winn = grabwinnonew(slicename)
	string exbody ="PopupMenu appendtord value= \""+appendvalue+"\""
	execute exbody
	string Tr = replaceString("_G",barename,"")+"_T"
	string dr = gapmap//mat3dn_cons+"_Gap_map"
	//print dr
	string listcheck = wavelist("*",";","Win:"+grabwinnonew(slicename))+"1"
	//print listcheck
	string W_coef = "W_coef"
	variable lc,lh
	variable sigma

	if (popNum == 1)
		if (cmpstr(StringByKey(tr,listcheck,";"),"") == 1)
			removeimage $Tr
		endif

		//print StringByKey(dr,listcheck,";")
		//print cmpstr(StringByKey(dr,listcheck,";"),"")

		if (cmpstr(StringByKey(dr,listcheck,";"),"") == 1)
			removeimage $dr
		endif
	endif
end

Function SetVarProc_Cons3dplotdivc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/G divcolor_cons
	if (divcolor_cons == 1)
		wavestats/Q $tpw()
		variable rangls = max(abs(V_max),abs(V_min))
		ModifyImage/W=$grabwinchild(tpw()) $tpw() ctab= {-rangls,rangls,:Packages:NewColortable:dvg_seismic,0};
		ColorScale/W=$grabwinchild(tpw())/C/N=textcc/X=-21.00/Y=5.00/F=0 heightPct=30,nticks=5,minor=1,tickLen=1.00,image=$tpw()//;ColorScale/W=$grabwinchild(Fexyd)/C/N=text0/F=0/A=MC/Y=-120 image=$Fexyd
	endif

	if (divcolor_cons == 0)
		ModifyImage $stringfromlist(0,wavelist("*",";","win:"+winname(0,1))) ctab= {*,*,VioletOrangeYellow,0}
		//PRINT stringfromlist(0,wavelist("*",";","win:"+winname(0,1)))
		//color3s_for3d($tpw(),3)
		ColorScale/K/N=textcc
	endif
end

Function SetVarProc_colorratio_consFFT(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G colorratio_consFFT
	string/G mat3dn_cons
	string slicename = "Zslice_"+mat3dn_cons
	String FFToutm = slicename+"_FFT"+"_Modula"
	String FFToutmsym = slicename+"_FFT"+"_sym"


	color3s_subfor3dFFT($FFToutm,colorratio_consFFT)
	color3s_subfor3dFFT($FFToutmsym,colorratio_consFFT)
End

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** {{{{{{{{{{ Select area average dI/dV curve  }}}}}}}}}}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

Function ButtonProc_subavedidv(ctrlName) : ButtonControl
	String ctrlName
	Execute "comparehotandcoldc()"
End

Proc comparehotandcoldc(name,prefwave,thresh)
	string name = stringfromlist(0,getall3dwave())// 3D wave the STS come from
	string Prefwave =name+"_Gap_map"// the gap map
	variable thresh =0.2// threshold for defining a lattice position (max=1)
	Prompt name,"3D wave G(r,E) the STS come from"
	Prompt Prefwave,"Gap map"
	prompt thresh,"Threshold for defining a sublattice"
	string gaptrend = name+"_gaptrend"
	duplicate/o $prefwave $gaptrend
	levelimage2($gaptrend,10)
	wavestats/Q $gaptrend
	$gaptrend/=((V_max-V_min)/2)
	comparehotandcold(name,gaptrend,thresh)
end

Function comparehotandcold(name,prefwave,thresh)
	string name // 3D wave the STS come from
	string Prefwave // trend remove and value normalized gap map
	variable thresh // threshold for defining a lattice position (max=1)

	string coldname = prefwave+"_cold"
	string hotname = prefwave+"_hot"
	Selnumavests_p(name,prefwave,thresh,hotname)
	Selnumavests_n(name,prefwave,-thresh,coldname)

	string segmatrixhot = "Hotspot_"+name
	string segmatrixcold = "Coldspot_"+name

	string polarize = Prefwave+"_hmcoverhpc"
	duplicate/o $coldname $polarize
	wave polarizew = $polarize
	string ratio = Prefwave+"_hoverc"
	duplicate/o $coldname $ratio
	wave ratiow = $ratio
	wave coldnamew = $coldname
	wave hotnamew = $hotname
	ratiow = hotnamew/coldnamew
	polarizew = 100*(hotnamew-coldnamew)/(coldnamew+hotnamew)



	display/N=hotcoldcompare_makeitlonglonglong
	modifygraph width=400,height=600

	//Display/HOST=#/W=(0,0.05,0.4,0.5);appendimage $segmatrixhot;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $segmatrixhot ctab= {-1,1,VioletOrangeYellow,0}
	//setActiveSubwindow ##;Display/HOST=#/W=(0.45,0.05,0.85,0.5);appendimage $segmatrixcold;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $segmatrixcold ctab= {-1,1,VioletOrangeYellow,0}//;AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {0, 0.5, 1};ModifyGraph rgb=(65535,65535,65535)
	//setActiveSubwindow ##;Display/HOST=#/W=(0,0.5,1,1);appendtograph $coldname;appendtograph $hotname;ModifyGraph rgb($coldname)=(0,0,0);ModifyGraph lsize=2

	Display/HOST=#/W=(0,0.05,0.4,0.33);appendimage $segmatrixhot;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $segmatrixhot ctab= {-1,1,VioletOrangeYellow,0}
	setActiveSubwindow ##;Display/HOST=#/W=(0.45,0.05,0.85,0.33);appendimage $segmatrixcold;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $segmatrixcold ctab= {-1,1,VioletOrangeYellow,0}//;AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {0, 0.5, 1};ModifyGraph rgb=(65535,65535,65535)
	setActiveSubwindow ##;Display/HOST=#/W=(0,0.33,1,0.66);appendtograph $coldname;appendtograph $hotname;ModifyGraph rgb($coldname)=(0,0,0);ModifyGraph lsize=2;TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "\\Z16\\s("+coldname+") Fe II\n\\s("+hotname+") Fe I";Label left "\\Z16dI/dV (a.u.)";Label bottom "\\Z16 Energy (meV) "
	setActiveSubwindow ##;Display/HOST=#/W=(0,0.66,1,0.99);appendtograph polarizew;appendtograph/R ratiow;ModifyGraph lsize=2;•ModifyGraph rgb($ratio)=(0,0,65535);ModifyGraph axRGB(right)=(0,0,65535),tlblRGB(right)=(0,0,65535),alblRGB(right)=(0,0,65535);ModifyGraph axThick(left)=2,axRGB(left)=(52428,1,1),tlblRGB(left)=(52428,1,1),alblRGB(left)=(52428,1,1);Label right "\\Z16 g(Fe-I)/g(Fe-II)";Label left "\\Z10 [g(Fe-I)-g(Fe-II)]/[g(Fe-I)+g(Fe-II)] (%)";ModifyGraph axThick(right)=2;Legend/C/N=text0/J/F=0/A=RB/X=0.00/Y=0.00 "\\Z12\\s("+polarize+") P([I-II]/[I+II])\r\\s("+Ratio+") Ratio(I/II)"
	setActiveSubwindow ##;
	TextBox/C/N=text0/F=0/A=LT/X=20.00/Y=3.00 "\\Z16 ∆(Fe-I)"
	TextBox/C/N=text1/F=0/A=LT/X=67.00/Y=3.00 "\\Z16 ∆(Fe-II)"
	variable/G thresh_cmp = thresh
	String/G name_cmp = name
	string/G prefwave_cmp = prefwave
	SetVariable setCthershold win=hotcoldcompare_makeitlonglonglong, title="Thres",size={120,20},value=thresh_cmp,limits={0,1,0.05},proc=SetVarProc_thresh_cmp
	tilewindows/WINS=winname(0,1)/R/w=(30,0,83,85)/A=(1,1)
end

Function SetVarProc_thresh_cmp(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G thresh_cmp
	String/G name_cmp
	string/G prefwave_cmp

	string coldname = prefwave_cmp+"_cold"
	string hotname = prefwave_cmp+"_hot"
	Selnumavests_p(name_cmp,prefwave_cmp,thresh_cmp,hotname)
	Selnumavests_n(name_cmp,prefwave_cmp,-thresh_cmp,coldname)


	string polarize = prefwave_cmp+"_hmcoverhpc"
	duplicate/o $coldname $polarize
	wave polarizew = $polarize
	string ratio = prefwave_cmp+"_hoverc"
	duplicate/o $coldname $ratio
	wave ratiow = $ratio
	wave coldnamew = $coldname
	wave hotnamew = $hotname
	ratiow = hotnamew/coldnamew
	polarizew = 100*(hotnamew-coldnamew)/(coldnamew+hotnamew)
end


Function Selnumavests_p(name,prefwave,thresh,stsname)
	string name // 3D wave the STS come from
	string Prefwave // 2D wave from which simulated lattice can be extracted
	variable thresh // threshold for defining a lattice position (max=1)
	string stsname

	wave namew = $name
	wave Prefwavew = $Prefwave

	//** Create selected area Matrix, the mask is defined by prefwave
		make/n=(dimsize(namew,2))/o $stsname
		wave stsnamew = $stsname
		setscale/p x,dimoffset(namew,2),dimdelta(namew,2),"",stsnamew
		stsnamew = 0
		string segmatrix = "Hotspot_"+name
		make/o/N=(dimsize($Prefwave,0),dimsize($Prefwave,1)) $segmatrix
		setscale/p x, dimoffset($Prefwave,0),dimdelta($Prefwave,0),"",$segmatrix
		setscale/p y, dimoffset($Prefwave,1),dimdelta($Prefwave,1),"",$segmatrix
		wave segmatrixw = $segmatrix
		segmatrixw=nan
		//variable meanvalue=mean(namew)
		variable i,j,times
		times=0
		i=0
		do
			j=0
			do
				if (Prefwavew[i][j]>thresh) //|| Prefwave2w[i][j]>thresh)
					stsnamew[] += namew[i][j][p]
					segmatrixw[i][j] = Prefwavew[i][j]
					times+=1
				endif
			j+=1
			while(j<dimsize(Prefwavew,1))
		i+=1
		while(i<dimsize(Prefwavew,0))
	stsnamew/=times
	//display stsnamew
	//** Error message, no stop but Continuing execution
		//String msg
		//Variable err
		//msg=GetErrMessage(GetRTError(0),3);
		//err=GetRTError(1)
		//if (err != 0)
			//Print "Error in Demo: " + msg
			//Print "Continuing execution"
		//endif
end


Function Selnumavests_n(name,prefwave,thresh,stsname)
	string name // 3D wave the STS come from
	string Prefwave // 2D wave from which simulated lattice can be extracted
	variable thresh // threshold for defining a lattice position (max=1)
	string stsname

	wave namew = $name
	wave Prefwavew = $Prefwave

	//** Create selected area Matrix, the mask is defined by prefwave
		make/n=(dimsize(namew,2))/o $stsname
		wave stsnamew = $stsname
		setscale/p x,dimoffset(namew,2),dimdelta(namew,2),"",stsnamew
		stsnamew = 0
		string segmatrix = "Coldspot_"+name
		make/o/N=(dimsize($Prefwave,0),dimsize($Prefwave,1)) $segmatrix
		setscale/p x, dimoffset($Prefwave,0),dimdelta($Prefwave,0),"",$segmatrix
		setscale/p y, dimoffset($Prefwave,1),dimdelta($Prefwave,1),"",$segmatrix
		wave segmatrixw = $segmatrix
		segmatrixw=nan
		//variable meanvalue=mean(namew)
		variable i,j,times
		times=0
		i=0
		do
			j=0
			do
				if (Prefwavew[i][j]<thresh) //|| Prefwave2w[i][j]>thresh)
					stsnamew[] += namew[i][j][p]
					segmatrixw[i][j] = Prefwavew[i][j]

					times+=1
				endif
			j+=1
			while(j<dimsize(Prefwavew,1))
		i+=1
		while(i<dimsize(Prefwavew,0))
	stsnamew/=times
	//display stsnamew
	//** Error message, no stop but Continuing execution
		//String msg
		//Variable err
		//msg=GetErrMessage(GetRTError(0),3);
		//err=GetRTError(1)
		//if (err != 0)
			//Print "Error in Demo: " + msg
			//Print "Continuing execution"
		//endif
end

Function ButtonProc_SumlayerFFT3Dc2(ctrlName) : ButtonControl
	String ctrlName
	execute "SumlayerFFT3D2()"
end
Proc SumlayerFFT3D2(name,startE,endE,sel)
	string name
	variable startE
	variable endE
	variable sel
	prompt name,"3D wave",popup,getall3dwave()
	prompt sel,"All range?",popup,"Yes;No"
	if (sel == 1)
		startE = dimoffset($name,2)
		endE = dimoffset($name,2)+dimdelta($name,2)*(dimsize($name,2)-1)
	endif

	SumlayerFFT3D($name,startE,endE)
end



Function ButtonProc_SumlayerFFT3Dc(ctrlName) : ButtonControl
	String ctrlName
	execute "SumlayerFFT3Dc()"
end

Proc SumlayerFFT3Dc(name,startE,endE)
	string name=mat3dn_cons+"_FFT3d"
	variable startE = dimoffset($mat3dn_cons+"_FFT3d",2)
	variable endE = dimoffset($mat3dn_cons+"_FFT3d",2)+dimdelta($mat3dn_cons+"_FFT3d",2)*(dimsize($mat3dn_cons+"_FFT3d",2)-1)
	SumlayerFFT3D($name,startE,endE)
end

Function SumlayerFFT3D(name,startE,endE)
	wave name
	variable startE,endE

	variable startn = round((startE-dimoffset(name,2))/dimdelta(name,2))
	variable endn = round((endE-dimoffset(name,2))/dimdelta(name,2))

	print "Integrate point range from "+num2str(startn)+" to "+num2str(endn)

	string ss = nameofWave(name)+"_integ"
	make/N=(dimsize(name,0),dimsize(name,1))/o $ss
	wave ssw = $ss
	ssw = 0
	variable i
	i=startn
	do
		ssw[][]+=name[p][q][i]
		i+=1
	while (i<endn+1)


	ssw/=dimsize(name,2)
	setscale/p x,dimoffset(name,0),dimdelta(name,0),"",ssw
	setscale/p y,dimoffset(name,1),dimdelta(name,1),"",ssw

	//Display
	d(ssw)
	ModifyGraph noLabel=0
	ModifyGraph axThick=1
	wavestats/Q $tpw()
	variable vv
	if(abs(V_max) > abs(V_min))
		vv = abs(V_max)
	else
		vv = abs(V_min)
	endif
	ModifyImage $tpw() ctab= {-vv,vv,root:Packages:NewColortable:dvg_seismic,1}
	//ColorScale/K/N=text0
	variable/G colormin_ind = -vv
	variable/G colormax_ind = vv
	variable/G colorinver_ind = 1
	string color=stringfromlist(2,stringByKey("RECREATION",imageinfo("",tpw(),0)),",")
	string colorinv=stringfromlist(3,stringByKey("RECREATION",imageinfo("",tpw(),0)),",")

	string exe
	exe = "ModifyImage $tpw() ctab= {-1,1,"+color+","+colorinv
	execute exe
	variable/G colormin_ind = -1
	variable/G colormax_ind = 1

end

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
//** Part of symmetrized QPI
/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
Function PopMenuProc_bkgrmv2D_3dplot(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	String/G FFTWin_3dplot
	variable/G FFTmode_3dplot
	string/G mat3dn_cons
	variable/G zn_cons

	variable/G GBK2dornot_3dplot
	variable/G GBK2dsigma_3dplot

	GBK2dornot_3dplot = popNum

		f_for3d()

	//** Turn automatically the symmetrized FFT
	variable/G symmode_3dplot
	variable/G colorratio_consFFT

	string slicename = "Zslice_"+mat3dn_cons
	String FFToutm = slicename+"_FFT"+"_Modula"
	String FFToutmsym = slicename+"_FFT"+"_sym"
	duplicate/o $FFToutm $FFToutmsym

	if (symmode_3dplot == 2)
		D4_sym_3dplot($FFToutmsym)
	endif

	if (symmode_3dplot == 3)
		Mdiag_sym_3dplot($FFToutmsym)
	endif

	if (symmode_3dplot == 4)
		Mx_sym_3dplot($FFToutmsym)
	endif

	if (symmode_3dplot == 5)
		C4_sym_3dplot($FFToutmsym)
	endif

	color3s_subfor3dFFT($FFToutmsym,colorratio_consFFT)

end


Function SetVarProc_bkgrmv2D_3dplot(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName


	String/G FFTWin_3dplot
	variable/G FFTmode_3dplot
	string/G mat3dn_cons
	variable/G zn_cons

	variable/G GBK2dornot_3dplot
	variable/G GBK2dsigma_3dplot

	GBK2dsigma_3dplot = varNum

		f_for3d()

	//** Turn automatically the symmetrized FFT
	variable/G symmode_3dplot
	variable/G colorratio_consFFT

	string slicename = "Zslice_"+mat3dn_cons
	String FFToutm = slicename+"_FFT"+"_Modula"
	String FFToutmsym = slicename+"_FFT"+"_sym"
	duplicate/o $FFToutm $FFToutmsym

	if (symmode_3dplot == 2)
		D4_sym_3dplot($FFToutmsym)
	endif

	if (symmode_3dplot == 3)
		Mdiag_sym_3dplot($FFToutmsym)
	endif

	if (symmode_3dplot == 4)
		Mx_sym_3dplot($FFToutmsym)
	endif

	if (symmode_3dplot == 5)
		C4_sym_3dplot($FFToutmsym)
	endif

	color3s_subfor3dFFT($FFToutmsym,colorratio_consFFT)
End



Function PopMenuProc_symmode_3dplot(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	String/G FFTWin_3dplot
	variable/G FFTmode_3dplot
	string/G mat3dn_cons
	variable/G zn_cons

	variable/G symmode_3dplot
	symmode_3dplot = popNum
	variable/G colorratio_consFFT

	string slicename = "Zslice_"+mat3dn_cons
	String FFToutm = slicename+"_FFT"+"_Modula"
	String FFToutmsym = slicename+"_FFT"+"_sym"
	duplicate/o $FFToutm $FFToutmsym

	if (symmode_3dplot == 2)
		D4_sym_3dplot($FFToutmsym)
	endif

	if (symmode_3dplot == 3)
		Mdiag_sym_3dplot($FFToutmsym)
	endif

	if (symmode_3dplot == 4)
		Mx_sym_3dplot($FFToutmsym)
	endif

	if (symmode_3dplot == 5)
		C4_sym_3dplot($FFToutmsym)
	endif

	color3s_subfor3dFFT($FFToutmsym,colorratio_consFFT)
End


Function C4_sym_3dplot(name)
	wave name

	variable pc,qc
	pc = round((-dimoffset(name,0))/dimdelta(name,0))
	qc = round((-dimoffset(name,1))/dimdelta(name,1))

	string name_C4 = nameofwave(name)+"_C4"
	duplicate/o name $name_C4
	wave name_C4w = $name_C4
	make/o/n=2 M_product
	wave M_product = $"M_product"

	variable i,j
	i=0
	do
		j=0
		do
			calculateRC(i,j,pc,qc,90)
			if (M_product[0] >= 0 && M_product[0] < dimsize(name,0))
				if (M_product[1] >= 0 && M_product[1] < dimsize(name,1))
					multithread name_C4w[i][j]+= name[M_product[0]][M_product[1]]
				else
					name_C4w[i][j]+= name[i][j]
				endif
			else
				name_C4w[i][j]+= name[i][j]
			endif

			name_C4w[i][j]/=2

			j+=1
		while (j<dimsize(name,1))
		i+=1
	while (i<dimsize(name,0))
	name = name_C4w
	killwaves name_C4w
end

Function Mdiag_sym_3dplot(name)
	wave name
	string name_Md = nameofwave(name)+"_Md"
	duplicate/o name $name_Md
	wave name_Mdw = $name_Md

	matrixtranspose name_Mdw
	name_Mdw +=name
	name_Mdw/=2
	name = name_Mdw
	killwaves name_Mdw
end

Function Mx_sym_3dplot(name)
	wave name
	variable pc,qc
	pc = round((-dimoffset(name,0))/dimdelta(name,0))
	qc=round((-dimoffset(name,1))/dimdelta(name,1))

	string name_mx = nameofwave(name)+"_mx"
	duplicate/o name $name_mx
	wave name_mxw = $name_mx

	variable distance

	variable j

		j=0
		do
			distance = j-qc

			if (qc-distance >= 0 && qc-distance < dimsize(name,1))
				name_mxw[][j] += name[p][qc-distance]
			else
				name_mxw[][j] += name[p][j]
			endif

			j+=1
		while (j<dimsize(name,1))

	name_mxw/=2

	name = name_mxw
	killwaves name_mxw
end

Function D4_sym_3dplot(name)
	wave name

	//Do Mx first
	variable pc,qc
	pc = round((-dimoffset(name,0))/dimdelta(name,0))
	qc=round((-dimoffset(name,1))/dimdelta(name,1))

	string name_mx = nameofwave(name)+"_mx"
	duplicate/o name $name_mx
	wave name_mxw = $name_mx

	variable distance

	variable j

		j=0
		do
			distance = j-qc

			if (qc-distance >= 0 && qc-distance < dimsize(name,1))
				name_mxw[][j] += name[p][qc-distance]
			else
				name_mxw[][j] += name[p][j]
			endif

			j+=1
		while (j<dimsize(name,1))

	name_mxw/=2

	string name_D4 = nameofwave(name)+"_D4"
	duplicate/o name_mxw $name_D4
	wave name_D4w = $name_D4

	matrixtranspose name_D4w
	name_D4w +=name_mxw
	name_D4w/=2
	name = name_D4w
	killwaves name_mxw name_D4w
end