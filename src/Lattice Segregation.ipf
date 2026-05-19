#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
//###########################################################################//
//###########################################################################//
//###########################################################################//
//###########################################################################//
//###########################################################################//
//**                   Lattice Segregation for Single 2D wave
//###########################################################################//
//###########################################################################//

//#1: Raw data do polynominal plan substraction
//#2: Do FFT filter automatically
//#3: Use 2D FitFunction <latticefit> to get phase
//#4: Use Fit result rebuild simulated lattice
//#5: The sublattice position can be selected by the peak posiotn of simulation
//#6: Pick up several segregated lattice under Coarse data status
//#7: Do scatter data point imageinterpolatation
//###########################################################################//
//###########################################################################//
//###########################################################################//
//###########################################################################//


//***************************************************************************//
//***************************************************************************//
//***************************************************************************//
//****************************      I.Body       ****************************//
//***************************************************************************//
//***************************************************************************//
//***************************************************************************//

//#I.2 Single 2D wave segregation [Do Segregation to itself]
Function ButtonProc_LS(ctrlName) : ButtonControl
	String ctrlName
	LS()
End
Function LS()
	string src //This is the 2D wave to be segregated
	string topo //This is the 2D wave to extract simulated sublattices
	String/G namefftraw
	src = namefftraw
	topo = namefftraw
	variable avedia =abs(dimdelta($topo,0)*(dimsize($topo,0)-1))/2
	//* Remove image trends
		levelimage2($topo,10)
	//* Make FFT filtered Image for 2D FunFit
		FTconsls($topo,avedia)
	//* Build simulated lattice
		SimlatticebyFit(Topo)
	//* Do Lattice segregation
		MDoLSegre(Src,Topo)
end

//#I.2 Single 2D wave segregation [Do Segregation to other wave]
Function ButtonProc_LS2(ctrlName) : ButtonControl
	String ctrlName
	execute "LSc2()"
End
Proc LSc2(src,topo)
	string src = stringfromList(0,wavelist("*",";","Win:"+winname(1,1)))//This is the 2D wave to be segregated
	string topo = namefftraw
	Prompt src,"Source Wave [Data]"
	Prompt topo,"Location wave [Topograph]"
	LS22(src,topo)
end
Function LS22(src,topo)
	string src //This is the 2D wave to be segregated
	string topo //This is the 2D wave to extract simulated sublattices
	//String/G namefftraw
	//src = namefftraw
	//topo = namefftraw
	variable avedia =abs(dimdelta($topo,0)*(dimsize($topo,0)-1))/2
	//* Remove image trends
		levelimage2($topo,10)
	//* Make FFT filtered Image for 2D FunFit
		FTconsls($topo,avedia)
	//* Build simulated lattice
		SimlatticebyFit(Topo)
	//* Do Lattice segregation
		MDoLSegre(Src,Topo)
end

//***************************************************************************//
//***************************************************************************//
//***************************************************************************//
//*************************      II.FT Filter    ****************************//
//***************************************************************************//
//***************************************************************************//
//***************************************************************************//

//#II.1 Special FT Filter for LS package
Function FTconsls(name,avedia)
	wave name
	variable avedia

	String cpickbs = nameofwave(name)+"_QB"
	String cpickas = nameofwave(name)+"_QA"
	wave cpickb = $cpickbs
	wave cpicka = $cpickas

	string namefft = nameofwave(name)+"_padFFT"
	variable widtha,widthb
	FFT/PAD={3*dimsize(name,0),3*dimsize(name,1)}/OUT=1/DEST=$namefft name;

	widtha=(2*sqrt(ln(2)))/avedia
	widthb=widtha

	variable FWHMAx,FWHMAy,FWHMAave,FWHMBx,FWHMBy,FWHMBave,FWHM_real
	FWHMAx = cpicka[2]*2*sqrt(ln(2))
	FWHMAy = cpicka[3]*2*sqrt(ln(2))
	FWHMAave = (cpicka[2]+cpicka[3])*2*sqrt(ln(2))/2
	FWHMBx = cpickb[2]*2*sqrt(ln(2))
	FWHMBy = cpickb[3]*2*sqrt(ln(2))
	FWHMBave = (cpickb[2]+cpickb[3])*2*sqrt(ln(2))/2
	FWHM_real = 2*sqrt(ln(2))*4/(cpicka[2]+cpicka[3]+cpickb[2]+cpickb[3])


	wave/C namefftw = $namefft
	namefftw*=(sqrt(pi)*widtha)^(-1)*exp(-((x-cpicka[0])^2+(y-cpicka[1])^2)/(widtha^2))+(sqrt(pi)*widthb)^(-1)*exp(-((x-cpickb[0])^2+(y-cpickb[1])^2)/(widthb^2))

	String nameffti = namefft+"i"
	IFFT/DEST=$nameffti  namefftw;
	wave namefftiw = $nameffti

	//unpadding the data
	unpadding(nameofwave(name),namefftiw)
	string npd=nameffti+"_up"
	string nn = nameofwave(name)+"_ftd"
	//make/o/N=(dimsize(name,0),dimsize(name,1)) $nn
	duplicate/o $npd $nn
	wave nnw = $nn
	wave npdw = $npd
	killwaves npdw


	//** Error message, no stop but Continuing execution
		String msg
		Variable err
		msg=GetErrMessage(GetRTError(0),3);
		err=GetRTError(1)
		if (err != 0)
			//Print "Error in Demo: " + msg
			//Print "Continuing execution"
		endif
END

//***************************************************************************//
//***************************************************************************//
//***************************************************************************//
//***********************   III.Simulate Lattice ****************************//
//***************************************************************************//
//***************************************************************************//
//***************************************************************************//

//#III.1 Simulate Lattice Body
Function SimlatticebyFit(name)
	string name // The name of experimental data [From this wave to extract]
				// usually this is the topography
	string nameftd = name+"_ftd" // name of FFT filtered image for Fit


	//* Pointing to the wave containing Vector information
		//This was created during the FFT engineering Launch before
		String cpickbs = name+"_QB"
		String cpickas = name+"_QA"
		wave cpickb = $cpickbs
		wave cpicka = $cpickas

	//* Define the quantity used in 2D FunFit, and give initial value
		variable z0
		variable A0
		variable Q1x
		variable Q1y
		variable Q2x
		variable Q2y
		variable phi1
		variable phi2

		wavestats/Q $nameftd

		z0 = mean($nameftd)
		A0 = abs(V_max-V_min)/2
		Q1x = cpicka[0]*2*pi
		Q1y = cpicka[1]*2*pi
		Q2x = cpickb[0]*2*pi
		Q2y = cpickb[1]*2*pi
		phi1 = 0
		phi2 = 0
			//di2($nameftd)
			//Dowindow/F $grabwinnonew(nameftd)

	//* Do 2D FunFit on the Filtered Image "$nameftd"
		//* Auxiliary wave for notes
		Make/N=8/O/T W_coefLabel
		Make/N=8/O W_coefHold
		W_coefHold = {0,0,1,1,1,1,0,0}
		W_coefLabel = {"Z0","A0","Q1x","Q1y","Q2x","Q2y","Phi1","phi2"}

		//* Make Coef wave for Fit
		Make/D/N=8/O W_coefLS
		W_coefLS = {Z0,A0,Q1x,Q1y,Q2x,Q2y,Phi1,phi2}

		//* Fit Filtered Image by Function "Latticefit"
		FuncFitMD/Q/H="00111100" latticefit W_coefLS $nameftd /D

		//* Normalize fit result for Contour plot
		string ContourZwave = "fit_"+nameftd //This is the output wave when use flag /D in FuncFitMD
		wave ContourZwavew = $ContourZwave
		ContourZwavew-=mean(ContourZwavew)
		wavestats/Q ContourZwavew
		ContourZwavew/=V_max

		//* Show table of the extracted parameters
		edit W_coefLabel W_coefLS W_coefHold
		cktable(winname(0,2))

	//* Make Simulated Lattice (Normalized to [-1,1])
		string SeLattice="SeLattice"+name
		string FeXLattice="FeXLattice"+name
		string FeYLattice="FeYLattice"+name
		string FeXYLattice="FeXYLattice"+name

		Duplicate/o $name $SeLattice
		Duplicate/o $name $FeXLattice
		Duplicate/o $name $FeYLattice
		Duplicate/o $name $FeXYLattice

		wave SeLatticew = $SeLattice
		wave FeXLatticew = $FeXLattice
		wave FeYLatticew = $FeYLattice
		wave FeXYLatticew = $FeXYLattice

		//* Se lattice just follows the fitting
		SeLatticew = sign(W_coefLS[1])*(cos(x*W_coefLS[2]+y*W_coefLS[3]+W_coefLS[6]) + cos(x*W_coefLS[4]+y*W_coefLS[5]+W_coefLS[7]))/2

		//* Fe X lattice shift pi phase along X (Q1)
		FeXLatticew = sign(W_coefLS[1])*(cos(x*W_coefLS[2]+y*W_coefLS[3]+W_coefLS[6]+pi) + cos(x*W_coefLS[4]+y*W_coefLS[5]+W_coefLS[7]))/2

		//* Fe Y lattice shift pi phase along Y (Q2)
		FeYLatticew = sign(W_coefLS[1])*(cos(x*W_coefLS[2]+y*W_coefLS[3]+W_coefLS[6]) + cos(x*W_coefLS[4]+y*W_coefLS[5]+W_coefLS[7]+pi))/2

		//* Fe XY count both X and Y
		FeXYLatticew = abs(FeXLatticew)

	//* Plot Windown
		string graphname ="Getref_"+name
		display/N=$graphname;modifygraph width=500,height=650

		Display/HOST=#/W=(0,0.05,0.5,0.4);appendimage $name;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_for3dm($name,3);AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {0, 0.5, 1};ModifyGraph rgb=(65535,65535,65535)
		setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.05,1,0.4);appendimage $nameftd;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_for3dm($nameftd,3);AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {0, 0.5, 1};ModifyGraph rgb=(65535,65535,65535)

		setActiveSubwindow ##;Display/HOST=#/W=(0,0.35,0.5,0.7);appendimage SeLatticew;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_for3dmLS(SeLatticew,3);AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {0, 0.5, 1};ModifyGraph rgb=(65535,65535,65535)
		setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.35,1,0.7);appendimage FeXYLatticew;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_for3dmLS(FeXYLatticew,30);AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {0, 0.5, 1};ModifyGraph rgb=(65535,65535,65535)

		setActiveSubwindow ##;Display/HOST=#/W=(0,0.65,0.5,1);appendimage FeXLatticew;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_for3dmLS(FeXLatticew,3);AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {0, 0.5, 1};ModifyGraph rgb=(65535,65535,65535)
		setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.65,1,1);appendimage FeYLatticew;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_for3dmLS(FeYLatticew,3);AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {0, 0.5, 1};ModifyGraph rgb=(65535,65535,65535)

		setActiveSubwindow ##;
		ckfig_child(winname(0,1))

		TextBox/C/N=text0/O=90/F=0/A=MC/X=-43/Y=29 "\\Z16T(r) (exp.)"
		TextBox/C/N=text1/O=90/F=0/A=MC/X=7/Y=29 "\\Z16T(r) (FT filtered)"

		TextBox/C/N=text2/O=90/F=0/A=MC/X=-43/Y=-1 "\\Z16Se (Simu.)"
		TextBox/C/N=text3/O=90/F=0/A=MC/X=7/Y=-1 "\\Z16Fe(x,y) (Simu.)"

		TextBox/C/N=text4/O=90/F=0/A=MC/X=-43/Y=-31 "\\Z16Fe(x)  (Simu.)"
		TextBox/C/N=text5/O=90/F=0/A=MC/X=7/Y=-31 "\\Z16Fe(y) (Simu.)"

		TextBox/C/N=text6/F=0/B=1/A=MT/X=0.00/Y=3.00 "\\Z16 Lattice Segregation [Extract Sublattice Positions]"

	//* Interactively tuning the contourplot
		variable/G cts_ls = 0 //Contour level start
		variable/G cte_ls = 0.5 //Contour level end
		variable/G ctn_ls = 1 //Contour level number
		String/G name_ls = name //The topograph name
		SetVariable setC0 win =$graphname, title="Start",size={120,20},value=cts_ls,limits={0,1,0.05},proc=SetVarProc_lsstart
		SetVariable setCe win =$graphname, title="End",size={120,20},value=cte_ls,limits={cts_ls,1,0.05},proc=SetVarProc_lsend
		SetVariable setCn win =$graphname, title="Num",size={120,20},value=ctn_ls,limits={0,inf,1},proc=SetVarProc_lsN

	//* Tile Window
		tilewindows/WINS=graphname/R/w=(3,0,100,100)/A=(1,1)
		//di(SeLatticew)
		//di(FeXLatticew)
		//di(FeYLatticew)
		//di(FeXYLatticew)

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

//#III.2 Interactively tuning the contourplot [Contour level start]
Function SetVarProc_lsstart(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G cts_ls
	variable/G cte_ls
	variable/G ctn_ls
	String/G name_ls

	string ContourZwave = "fit_"+name_ls+"_ftd"
	string graphname ="Getref_"+name_ls

	SetVariable setCe win =$graphname, title="End",size={120,20},value=cte_ls,limits={cts_ls,1,0.05},proc=SetVarProc_lsend

	string chidname0 = graphname+"#G0"
	string chidname1 = graphname+"#G1"
	string chidname2 = graphname+"#G2"
	string chidname3 = graphname+"#G3"
	string chidname4 = graphname+"#G4"
	string chidname5 = graphname+"#G5"

	ModifyContour/W=$chidname0 $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};
	ModifyGraph/W=$chidname0 rgb=(65535,65535,65535)

	ModifyContour/W=$chidname1 $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};
	ModifyGraph/W=$chidname1 rgb=(65535,65535,65535)

	ModifyContour/W=$chidname2 $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};
	ModifyGraph/W=$chidname2 rgb=(65535,65535,65535)

	ModifyContour/W=$chidname3 $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};
	ModifyGraph/W=$chidname3 rgb=(65535,65535,65535)

	ModifyContour/W=$chidname4 $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};
	ModifyGraph/W=$chidname4 rgb=(65535,65535,65535)

	ModifyContour/W=$chidname5 $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};
	ModifyGraph/W=$chidname5 rgb=(65535,65535,65535)
End

//#III.3 Interactively tuning the contourplot [Contour level end]
Function SetVarProc_lsend(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G cts_ls
	variable/G cte_ls
	variable/G ctn_ls
	String/G name_ls

	string ContourZwave = "fit_"+name_ls+"_ftd"
	string graphname ="Getref_"+name_ls

	//SetVariable setCe win =$graphname, title="End",size={120,20},value=cte_ls,limits={cts_ls,1,0.05},proc=SetVarProc_lsend

	string chidname0 = graphname+"#G0"
	string chidname1 = graphname+"#G1"
	string chidname2 = graphname+"#G2"
	string chidname3 = graphname+"#G3"
	string chidname4 = graphname+"#G4"
	string chidname5 = graphname+"#G5"

	ModifyContour/W=$chidname0 $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};
	ModifyGraph/W=$chidname0 rgb=(65535,65535,65535)

	ModifyContour/W=$chidname1 $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};
	ModifyGraph/W=$chidname1 rgb=(65535,65535,65535)

	ModifyContour/W=$chidname2 $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};
	ModifyGraph/W=$chidname2 rgb=(65535,65535,65535)

	ModifyContour/W=$chidname3 $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};
	ModifyGraph/W=$chidname3 rgb=(65535,65535,65535)

	ModifyContour/W=$chidname4 $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};
	ModifyGraph/W=$chidname4 rgb=(65535,65535,65535)

	ModifyContour/W=$chidname5 $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};
	ModifyGraph/W=$chidname5 rgb=(65535,65535,65535)
End

//#III.4 Interactively tuning the contourplot [Contour level Number]
Function SetVarProc_lsn(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G cts_ls
	variable/G cte_ls
	variable/G ctn_ls
	String/G name_ls

	string ContourZwave = "fit_"+name_ls+"_ftd"
	string graphname ="Getref_"+name_ls

	SetVariable setCe win =$graphname, title="End",size={120,20},value=cte_ls,limits={cts_ls,1,0.05},proc=SetVarProc_lsend

	string chidname0 = graphname+"#G0"
	string chidname1 = graphname+"#G1"
	string chidname2 = graphname+"#G2"
	string chidname3 = graphname+"#G3"
	string chidname4 = graphname+"#G4"
	string chidname5 = graphname+"#G5"

	ModifyContour/W=$chidname0 $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};
	ModifyGraph/W=$chidname0 rgb=(65535,65535,65535)

	ModifyContour/W=$chidname1 $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};
	ModifyGraph/W=$chidname1 rgb=(65535,65535,65535)

	ModifyContour/W=$chidname2 $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};
	ModifyGraph/W=$chidname2 rgb=(65535,65535,65535)

	ModifyContour/W=$chidname3 $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};
	ModifyGraph/W=$chidname3 rgb=(65535,65535,65535)

	ModifyContour/W=$chidname4 $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};
	ModifyGraph/W=$chidname4 rgb=(65535,65535,65535)

	ModifyContour/W=$chidname5 $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};
	ModifyGraph/W=$chidname5 rgb=(65535,65535,65535)
End

//#III.5 FitFunction for Cos(q*r+phi)
Function latticefit(w,x,y) : FitFunc
	Wave w
	Variable x
	Variable y

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x,y) = z0+A*(cos(x*Q1x+y*Q1y+phi1) + cos(x*Q2x+y*Q2y+phi2))/2
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 2
	//CurveFitDialog/ x
	//CurveFitDialog/ y
	//CurveFitDialog/ Coefficients 8
	//CurveFitDialog/ w[0] = z0
	//CurveFitDialog/ w[1] = A
	//CurveFitDialog/ w[2] = Q1x
	//CurveFitDialog/ w[3] = Q1y
	//CurveFitDialog/ w[4] = Q2x
	//CurveFitDialog/ w[5] = Q2y
	//CurveFitDialog/ w[6] = Phi1
	//CurveFitDialog/ w[7] = Phi2
	return w[0]+w[1]*(cos(x*w[2]+y*w[3]+w[6]) + cos(x*w[4]+y*w[5]+w[7]))/2
End


//***************************************************************************//
//***************************************************************************//
//***************************************************************************//
//***********************    IV.Do Segregation   ****************************//
//***************************************************************************//
//***************************************************************************//
//***************************************************************************//

//#IV.1 Body Function
Function MDoLSegre(Src,Topo)
	string src //The 2D wave to be segregated
	string topo //The 2D wave from which to extract the sublattice

	variable/G thresh_ls=0.9 //the threshold to define the lattice position, max = 1
	string/G src_ls = src
	variable/G FFTwindow = 0
	variable/G normfftq = 0
	//* Do lattice segregation
		string SeLattice="SeLattice"+Topo
		string FeXLattice="FeXLattice"+Topo
		string FeYLattice="FeYLattice"+Topo
		string FeXYLattice="FeXYLattice"+Topo

		//* main functional codes for segregation
		DoLSegre(Src,SeLattice,thresh_ls,1)
		//DoLSegre(Src,FeXYLattice,thresh_ls,1)
		DoLSegreXY(Src,FeXLattice,FeYLattice,thresh_ls,1)
		DoLSegre(Src,FeXLattice,thresh_ls,1)
		DoLSegre(Src,FeYLattice,thresh_ls,1)

		string Se_outputLs = "sg_"+SeLattice+"_"+Src
		string FeXY_outputLs = "sg_"+FeXYLattice+"_"+Src
		string FeX_outputLs = "sg_"+FeXLattice+"_"+Src
		string FeY_outputLs = "sg_"+FeYLattice+"_"+Src

	//* Calculate X and Y difference
		wave FeX_outputLsw = $FeX_outputLs
		wave FeY_outputLsw = $FeY_outputLs
		string Fexyd = "Fexyd_"+FeXYLattice+"_"+Src
		duplicate/o FeY_outputLsw $Fexyd
		wave Fexydw = $Fexyd
		Fexydw = FeX_outputLsw-FeY_outputLsw

		//* Calculate averaged difference
		variable xydi,xydj,xydcount,xydave
			xydcount = 0
			xydi = 0
			do
				xydj = 0
				do
					if(mod(Round(Fexydw[xydi][xydj]),1)!=0)
					else
						xydave+=abs(Fexydw[xydi][xydj])
						xydcount+=1
					endif
					xydj+=1
				while(xydj < dimsize(Fexydw,1))
				xydi+=1
			while(xydi < dimsize(Fexydw,0))
			xydave/=xydcount

	//* Pointing to one example of scattered wave (just after extraction)
		string segmatrix = "segmatrix_"+Src

	//* Duplicate the source wave for display
		string srcd=src+"_d"
		duplicate/o $src $srcd

	//* Do FFT for the segregated lattice
		FFTrls($Se_outputLs,FFTwindow+1)
		FFTrls($FeXY_outputLs,FFTwindow+1)
		FFTrls($FeX_outputLs,FFTwindow+1)
		FFTrls($FeY_outputLs,FFTwindow+1)
		FFTrls($srcd,FFTwindow+1)

		String srcFFToutm = srcd + "_FFT"+"_Modula"
		String SeFFToutm = Se_outputLs + "_FFT"+"_Modula"
		String FeXYFFToutm = FeXY_outputLs + "_FFT"+"_Modula"
		String FeXFFToutm = FeX_outputLs + "_FFT"+"_Modula"
		String FeYFFToutm = FeY_outputLs + "_FFT"+"_Modula"
		wave srcFFToutmw = $srcFFToutm
		wave SeFFToutmw = $SeFFToutm
		wave FeXYFFToutmw = $FeXYFFToutm
		wave FeXFFToutmw = $FeXFFToutm
		wave FeYFFToutmw = $FeYFFToutm



	//* Pointing to the Vector wave and make a X vs Y pair for display
		String cpickbs = topo+"_QB"
		String cpickas = topo+"_QA"
		wave cpickb = $cpickbs
		wave cpicka = $cpickas

		string q1nx = "q1nx_"+topo
		string q1ny = "q1ny_"+topo
		string q2nx = "q2nx_"+topo
		string q2ny = "q2ny_"+topo
		make/o/N=1 $q1nx
		make/o/N=1 $q1ny
		make/o/N=1 $q2nx
		make/o/N=1 $q2ny
		wave q1nxw = $q1nx
		wave q1nyw = $q1ny
		wave q2nxw = $q2nx
		wave q2nyw = $q2ny

		q1nxw = cpicka[0]
		q1nyw = cpicka[1]
		q2nxw = cpickb[0]
		q2nyw = cpickb[1]

	//* Creat FFT Intensity wave at Q1 and Q2
		string QAint = "QAint_"+src
		string QBint = "QBint_"+src
		make/n=5/o $QAint
		make/n=5/o $QBint
		wave QAintw = $QAint
		wave QBintw = $QBint
		variable ai0,ai1,ai2,ai3,ai4
		variable aj0,aj1,aj2,aj3,aj4

		variable bi0,bi1,bi2,bi3,bi4
		variable bj0,bj1,bj2,bj3,bj4

		//For QA
			ai0=round((cpicka[0]-dimoffset($srcFFToutm,0))/dimdelta($srcFFToutm,0))
			aj0=round((cpicka[1]-dimoffset($srcFFToutm,1))/dimdelta($srcFFToutm,1))
			QAintw[0] = srcFFToutmw[ai0][aj0]///srcFFToutmw[ai0][aj0]

			ai1=round((cpicka[0]-dimoffset($SeFFToutm,0))/dimdelta($SeFFToutm,0))
			aj1=round((cpicka[1]-dimoffset($SeFFToutm,1))/dimdelta($SeFFToutm,1))
			QAintw[1] = SeFFToutmw[ai1][aj1]///srcFFToutmw[ai0][aj0]

			ai2=round((cpicka[0]-dimoffset($FeXYFFToutm,0))/dimdelta($FeXYFFToutm,0))
			aj2=round((cpicka[1]-dimoffset($FeXYFFToutm,1))/dimdelta($FeXYFFToutm,1))
			QAintw[2] = FeXYFFToutmw[ai2][aj2]///srcFFToutmw[ai0][aj0]

			ai3=round((cpicka[0]-dimoffset($FeXFFToutm,0))/dimdelta($FeXFFToutm,0))
			aj3=round((cpicka[1]-dimoffset($FeXFFToutm,1))/dimdelta($FeXFFToutm,1))
			QAintw[3] = FeXFFToutmw[ai3][aj3]///srcFFToutmw[ai0][aj0]

			ai4=round((cpicka[0]-dimoffset($FeYFFToutm,0))/dimdelta($FeYFFToutm,0))
			aj4=round((cpicka[1]-dimoffset($FeYFFToutm,1))/dimdelta($FeYFFToutm,1))
			QAintw[4] = FeXFFToutmw[ai4][aj4]///srcFFToutmw[ai0][aj0]

			if (normfftq == 1)
				QAintw/=srcFFToutmw[ai0][aj0]
			else
			endif


		//For QB
			bi0=round((cpickb[0]-dimoffset($srcFFToutm,0))/dimdelta($srcFFToutm,0))
			bj0=round((cpickb[1]-dimoffset($srcFFToutm,1))/dimdelta($srcFFToutm,1))
			QBintw[0] = srcFFToutmw[bi0][bj0]///srcFFToutmw[bi0][bj0]

			bi1=round((cpickb[0]-dimoffset($SeFFToutm,0))/dimdelta($SeFFToutm,0))
			bj1=round((cpickb[1]-dimoffset($SeFFToutm,1))/dimdelta($SeFFToutm,1))
			Qbintw[1] = SeFFToutmw[bi1][bj1]///srcFFToutmw[bi0][bj0]

			bi2=round((cpickb[0]-dimoffset($FeXYFFToutm,0))/dimdelta($FeXYFFToutm,0))
			bj2=round((cpickb[1]-dimoffset($FeXYFFToutm,1))/dimdelta($FeXYFFToutm,1))
			Qbintw[2] = FeXYFFToutmw[bi2][bj2]///srcFFToutmw[bi0][bj0]

			bi3=round((cpickb[0]-dimoffset($FeXFFToutm,0))/dimdelta($FeXFFToutm,0))
			bj3=round((cpickb[1]-dimoffset($FeXFFToutm,1))/dimdelta($FeXFFToutm,1))
			Qbintw[3] = FeXFFToutmw[bi3][bj3]///srcFFToutmw[bi0][bj0]

			bi4=round((cpickb[0]-dimoffset($FeYFFToutm,0))/dimdelta($FeYFFToutm,0))
			bj4=round((cpickb[1]-dimoffset($FeYFFToutm,1))/dimdelta($FeYFFToutm,1))
			Qbintw[4] = FeXFFToutmw[bi4][bj4]///srcFFToutmw[bi0][bj0]

			if (normfftq == 1)
				Qbintw/=srcFFToutmw[bi0][bj0]
			else
			endif
		//Ticks wave
			string tickwavesT = "tickt_"+src
			make/o/T/N=5 $tickwavesT
			wave/T tickwavesTw = $tickwavesT
			tickwavesTw = {"Raw","Se","FeXY","FeX","FeY"}
			string tickwavesn = "tickn_"+src
			make/o/N=5 $tickwavesn
			wave tickwavesnw = $tickwavesn
			tickwavesnw = {0,1,2,3,4}

	//* Display
		string graphname ="Segregated_"+src
		display/N=$graphname;modifygraph width=900,height=650

		string ContourZwave = "fit_"+topo+"_ftd"
		variable/G cts_ls = 0.65 //Contour level start
		variable/G cte_ls =0.65//Contour level end
		variable/G ctn_ls = 0 //Contour level number
		String/G name_ls //The topograph name
		String/G name_lss = src //the source wave name

		Display/HOST=#/W=(0,0.05,0.3,0.4);appendimage $Srcd;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_for3dm($srcd,3);AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};ModifyGraph rgb=(65535,65535,65535)
		setActiveSubwindow ##;Display/HOST=#/W=(0.2,0.05,0.5,0.4);appendimage $srcFFToutm;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_for3dmf($srcFFToutm,30);appendtograph q1nyw vs q1nxw;appendtograph q2nyw vs q2nxw;ModifyGraph mode=3,marker=8,rgb=(1,65535,33232),mrkThick=1,msize=4
		setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.05,0.8,0.4);appendimage $Se_outputLs;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_followtopo($Se_outputLs,3,$src);//;color3s_for3dm($nameftd,3);AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {0, 0.5, 1};ModifyGraph rgb=(65535,65535,65535)
		setActiveSubwindow ##;Display/HOST=#/W=(0.7,0.05,1,0.4);appendimage $SeFFToutm;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_followtopof($SeFFToutm,30,$srcFFToutm);appendtograph q1nyw vs q1nxw;appendtograph q2nyw vs q2nxw;ModifyGraph mode=3,marker=8,rgb=(1,65535,33232),mrkThick=0.5,msize=4//;color3s_for3dm($nameftd,3);AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {0, 0.5, 1};ModifyGraph rgb=(65535,65535,65535)

		setActiveSubwindow ##;Display/HOST=#/W=(0,0.35,0.3,0.7);appendimage $FeX_outputLs;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_followtopo($FeX_outputLs,3,$src)//;color3s_for3dmLS(SeLatticew,3);AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {0, 0.5, 1};ModifyGraph rgb=(65535,65535,65535)
		setActiveSubwindow ##;Display/HOST=#/W=(0.2,0.35,0.5,0.7);appendimage $FeXFFToutm;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_followtopof($FeXFFToutm,30,$srcFFToutm);appendtograph q1nyw vs q1nxw;appendtograph q2nyw vs q2nxw;ModifyGraph mode=3,marker=8,rgb=(1,65535,33232),mrkThick=0.5,msize=4//;color3s_for3dmLS(FeXYLatticew,30);AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {0, 0.5, 1};ModifyGraph rgb=(65535,65535,65535)
		setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.35,0.8,0.7);appendimage $FeY_outputLs;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_followtopo($FeY_outputLs,3,$src)//;color3s_for3dmLS(FeXYLatticew,30);AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {0, 0.5, 1};ModifyGraph rgb=(65535,65535,65535)
		setActiveSubwindow ##;Display/HOST=#/W=(0.7,0.35,1,0.7);appendimage $FeYFFToutm;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_followtopof($FeYFFToutm,30,$srcFFToutm);appendtograph q1nyw vs q1nxw;appendtograph q2nyw vs q2nxw;ModifyGraph mode=3,marker=8,rgb=(1,65535,33232),mrkThick=0.5,msize=4//;color3s_for3dmLS(FeXYLatticew,30);AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {0, 0.5, 1};ModifyGraph rgb=(65535,65535,65535)

		setActiveSubwindow ##;Display/HOST=#/W=(0,0.65,0.3,1);appendimage $FeXY_outputLs;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_followtopo($FeXY_outputLs,3,$src);AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};ModifyGraph rgb=(65535,65535,65535)//;color3s_for3dmLS(FeXLatticew,3);AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {0, 0.5, 1};ModifyGraph rgb=(65535,65535,65535)
		setActiveSubwindow ##;Display/HOST=#/W=(0.2,0.65,0.5,1);appendimage $FeXYFFToutm;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_followtopof($FeXYFFToutm,30,$srcFFToutm);appendtograph q1nyw vs q1nxw;appendtograph q2nyw vs q2nxw;ModifyGraph mode=3,marker=8,rgb=(1,65535,33232),mrkThick=0.5,lstyle=8,msize=4//;color3s_for3dmLS(FeYLatticew,3);AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {0, 0.5, 1};ModifyGraph rgb=(65535,65535,65535)
		setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.65,0.8,1);appendimage $segmatrix;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $segmatrix ctab= {*,*,VioletOrangeYellow,0}//;color3s_for3dmLS(FeYLatticew,3);AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {0, 0.5, 1};ModifyGraph rgb=(65535,65535,65535)
		setActiveSubwindow ##;Display/HOST=#/W=(0.78,0.65,1,1) Qbintw Qaintw;ModifyGraph userticks(bottom)={tickwavesnw,tickwavestw},mode=4,marker=7,mrkThick=2,rgb($Qbint)=(0,0,65535);Legend/C/N=text0/F=0/B=1/A=MT;Label left "\\Z16FFT Magnitude (a.u.)"//ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0//;color3s_for3dmLS(FeYLatticew,3);AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {0, 0.5, 1};ModifyGraph rgb=(65535,65535,65535)

		wavestats/Q $Fexyd
		variable rangls = max(abs(V_max),abs(V_min))
		setActiveSubwindow ##;Display/HOST=#/W=(0.37,0.43,0.57,0.63);appendimage $Fexyd;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $Fexyd ctab= {-rangls,rangls,:Packages:NewColortable:dvg_seismic,0};ColorScale/C/N=text0/F=0/A=MC/Y=-120 image=$Fexyd

		setActiveSubwindow ##;
		ckfig_child(winname(0,1))

		TextBox/C/N=text0/O=90/F=0/A=MC/X=-46/Y=29 "\\Z16Raw Data (exp.)"
		TextBox/C/N=text1/O=90/F=0/A=MC/X=4/Y=29 "\\Z16Se (Extracted)"

		TextBox/C/N=text2/O=90/F=0/A=MC/X=-46/Y=-1 "\\Z16Fe(x)  (Extracted)"
		TextBox/C/N=text3/O=90/F=0/A=MC/X=4/Y=-1 "\\Z16Fe(y) (Extracted)"

		TextBox/C/N=text4/O=90/F=0/A=MC/X=-46/Y=-31 "\\Z16Fe(x,y) (Extracted)"
		TextBox/C/N=text5/O=90/F=0/A=MC/X=4/Y=-31 "\\Z16Threshold Window"

		TextBox/C/N=text6/F=0/B=1/A=MT/X=0.00/Y=3.00 "\\Z16 Lattice Segregation [Extracted Sublattices]"
		TextBox/C/N=text7/F=0/B=1/A=MT/X=-3/Y=42 "\\Z10 Fe(x)-Fe(y)"

		TextBox/C/N=text8/F=0/B=1/A=MT/X=-4.5/Y=61 "\\Z10 X"
		TextBox/C/N=text9/F=0/B=1/A=MT/X=-4.5/Y=71 "\\Z10 Y"

	//* Interactively tuning the threshold
		SetVariable setThreshold win =$graphname, title="Threshold",size={120,20},value=thresh_ls,limits={0,1,0.01},proc=SetVarProc_lsthresh,pos={1,1}

	//* Interactively tuning the contourplot

		SetVariable setC0s win =$graphname, title="Start",size={120,20},value=cts_ls,limits={0,1,0.05},proc=SetVarProc_lsstarts,pos={131,1}
		SetVariable setCes win =$graphname, title="End",size={120,20},value=cte_ls,limits={cts_ls,1,0.05},proc=SetVarProc_lsends,pos={261,1}
		SetVariable setCns win =$graphname, title="Num",size={120,20},value=ctn_ls,limits={0,inf,1},proc=SetVarProc_lsNs,pos={386,1}

	//* Change FFT Mode
		SetVariable setfftwindowls win =$graphname, title="FFTWindow",size={120,20},value=FFTwindow,limits={0,1,1},proc=SetVarProc_lsFFTwindow,pos={520,1}

	//* Change FFT curvenorm
		SetVariable setnormfftqls win =$graphname, title="NormFFT",size={100,20},value=normfftq,limits={0,1,1},proc=SetVarProc_lsnormfftq,pos={650,1}

	//* Display the X-Y average value
		variable/G xydave_ls = 	xydave
		string exe="ValDisplay valdisp0 value= xydave_ls,pos={398,380},title=\"Dif\",size={60,13}"
		execute exe
	//* Turn off
		Button turnoff title="X",fSize=15,fstyle=1,size={20,18},valueColor=(0,0,0),fColor=(1,65535,33232),pos={875,5},proc=ButtonProc_lsturnoff

	//* Make segregated 3D Grid
		Button threedsl title="Make3D",fsize=10,size={50,12},pos={750,1},proc=ButtonProc_Lsmatrix3d

	//* Do segregated lattice 3dDisplayer
		string/G mat3dn_cons
		string mat3dafterls_Se = mat3dn_cons+"_Se"
		string mat3dafterls_FeX = mat3dn_cons+"_FeX"
		string mat3dafterls_FeY = mat3dn_cons+"_FeY"
		string mat3dafterls_FeXY = mat3dn_cons+"_FeXY"
		string mat3dafterls_Fedif = mat3dn_cons+"_Fedif"
		string valuels = mat3dafterls_Se+";"+mat3dafterls_FeX+";"+mat3dafterls_FeY+";"+mat3dafterls_FeXY+";"+mat3dafterls_FeDif

		string bodyshow3d = "PopupMenu popupshow3d pos={300,406},pos={750,14},proc=PopMenuProc_Lsmatrix3d,value="+"\""+valuels+"\""
		//PopupMenu popupshow3d pos={300,406},proc=PopMenuProc_Lsmatrix3d,value=valuels
		execute bodyshow3d
	//* Tilewindow
		tilewindows/WINS=graphname/R/w=(36,0,100,100)/A=(1,1)
end

Function ButtonProc_lsturnoff(ctrlName) : ButtonControl
	String ctrlName

	string/G topo_cons
	string/G mat3dn_cons
	string graphname ="Getref_"+topo_cons
	string sliceg = "Zslice_"+mat3dn_cons
	string graphname1 ="Segregated_"+sliceg

	killwindow $graphname
	killwindow $graphname1
	killwindow $winname(0,2)
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

//#IV.2 Control threshold
Function SetVarProc_lsthresh(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	MDoLSegrereapply()
end
Function MDoLSegrereapply()
	variable/G thresh_ls
	string/G src_ls
	string/G name_ls
	string src = src_ls
	string topo = name_ls
	variable/G FFTwindow

	string SeLattice="SeLattice"+topo
	string FeXLattice="FeXLattice"+topo
	string FeYLattice="FeYLattice"+topo
	string FeXYLattice="FeXYLattice"+topo

	DoLSegre(Src,SeLattice,thresh_ls,1)
	//DoLSegre(Src,FeXYLattice,thresh_ls,1)
	DoLSegreXY(Src,FeXLattice,FeYLattice,thresh_ls,1)
	DoLSegre(Src,FeXLattice,thresh_ls,1)
	DoLSegre(Src,FeYLattice,thresh_ls,1)

	string Se_outputLs = "sg_"+SeLattice+"_"+Src
	string FeXY_outputLs = "sg_"+FeXYLattice+"_"+Src
	string FeX_outputLs = "sg_"+FeXLattice+"_"+Src
	string FeY_outputLs = "sg_"+FeYLattice+"_"+Src
	string segmatrix = "segmatrix_"+Src

	//* Calculate X and Y difference
		wave FeX_outputLsw = $FeX_outputLs
		wave FeY_outputLsw = $FeY_outputLs
		string Fexyd = "Fexyd_"+FeXYLattice+"_"+Src
		duplicate/o FeY_outputLsw $Fexyd
		wave Fexydw = $Fexyd
		Fexydw = FeX_outputLsw-FeY_outputLsw

		//* Calculate averaged difference
		variable xydi,xydj,xydcount,xydave
			xydcount = 0
			xydi = 0
			do
				xydj = 0
				do
					if(mod(Round(Fexydw[xydi][xydj]),1)!=0)
					else
						xydave+=abs(Fexydw[xydi][xydj])
						xydcount+=1
					endif
					xydj+=1
				while(xydj < dimsize(Fexydw,1))
				xydi+=1
			while(xydi < dimsize(Fexydw,0))

		variable/G xydave_ls=xydave/xydcount


	string srcd=src+"_d"
	duplicate/o $src $srcd

	FFTrls($Se_outputLs,FFTwindow+1)
	FFTrls($FeXY_outputLs,FFTwindow+1)
	FFTrls($FeX_outputLs,FFTwindow+1)
	FFTrls($FeY_outputLs,FFTwindow+1)
	FFTrls($srcd,FFTwindow+1)

	String srcFFToutm = srcd + "_FFT"+"_Modula"
	String SeFFToutm = Se_outputLs + "_FFT"+"_Modula"
	String FeXYFFToutm = FeXY_outputLs + "_FFT"+"_Modula"
	String FeXFFToutm = FeX_outputLs + "_FFT"+"_Modula"
	String FeYFFToutm = FeY_outputLs + "_FFT"+"_Modula"
	wave srcFFToutmw = $srcFFToutm
	wave SeFFToutmw = $SeFFToutm
	wave FeXYFFToutmw = $FeXYFFToutm
	wave FeXFFToutmw = $FeXFFToutm
	wave FeYFFToutmw = $FeYFFToutm

	String cpickbs = topo+"_QB"
	String cpickas = topo+"_QA"
	wave cpickb = $cpickbs
	wave cpicka = $cpickas

	string QAint = "QAint_"+src
	string QBint = "QBint_"+src
	make/n=5/o $QAint
	make/n=5/o $QBint
	wave QAintw = $QAint
	wave QBintw = $QBint
	variable ai0,ai1,ai2,ai3,ai4
	variable aj0,aj1,aj2,aj3,aj4

	variable bi0,bi1,bi2,bi3,bi4
	variable bj0,bj1,bj2,bj3,bj4

	variable/G normfftq
	//For QA
			ai0=round((cpicka[0]-dimoffset($srcFFToutm,0))/dimdelta($srcFFToutm,0))
			aj0=round((cpicka[1]-dimoffset($srcFFToutm,1))/dimdelta($srcFFToutm,1))
			QAintw[0] = srcFFToutmw[ai0][aj0]///srcFFToutmw[ai0][aj0]

			ai1=round((cpicka[0]-dimoffset($SeFFToutm,0))/dimdelta($SeFFToutm,0))
			aj1=round((cpicka[1]-dimoffset($SeFFToutm,1))/dimdelta($SeFFToutm,1))
			QAintw[1] = SeFFToutmw[ai1][aj1]///srcFFToutmw[ai0][aj0]

			ai2=round((cpicka[0]-dimoffset($FeXYFFToutm,0))/dimdelta($FeXYFFToutm,0))
			aj2=round((cpicka[1]-dimoffset($FeXYFFToutm,1))/dimdelta($FeXYFFToutm,1))
			QAintw[2] = FeXYFFToutmw[ai2][aj2]///srcFFToutmw[ai0][aj0]

			ai3=round((cpicka[0]-dimoffset($FeXFFToutm,0))/dimdelta($FeXFFToutm,0))
			aj3=round((cpicka[1]-dimoffset($FeXFFToutm,1))/dimdelta($FeXFFToutm,1))
			QAintw[3] = FeXFFToutmw[ai3][aj3]///srcFFToutmw[ai0][aj0]

			ai4=round((cpicka[0]-dimoffset($FeYFFToutm,0))/dimdelta($FeYFFToutm,0))
			aj4=round((cpicka[1]-dimoffset($FeYFFToutm,1))/dimdelta($FeYFFToutm,1))
			QAintw[4] = FeXFFToutmw[ai4][aj4]///srcFFToutmw[ai0][aj0]

			if (normfftq == 1)
				QAintw/=srcFFToutmw[ai0][aj0]
			else
			endif


		//For QB
			bi0=round((cpickb[0]-dimoffset($srcFFToutm,0))/dimdelta($srcFFToutm,0))
			bj0=round((cpickb[1]-dimoffset($srcFFToutm,1))/dimdelta($srcFFToutm,1))
			QBintw[0] = srcFFToutmw[bi0][bj0]///srcFFToutmw[bi0][bj0]

			bi1=round((cpickb[0]-dimoffset($SeFFToutm,0))/dimdelta($SeFFToutm,0))
			bj1=round((cpickb[1]-dimoffset($SeFFToutm,1))/dimdelta($SeFFToutm,1))
			Qbintw[1] = SeFFToutmw[bi1][bj1]///srcFFToutmw[bi0][bj0]

			bi2=round((cpickb[0]-dimoffset($FeXYFFToutm,0))/dimdelta($FeXYFFToutm,0))
			bj2=round((cpickb[1]-dimoffset($FeXYFFToutm,1))/dimdelta($FeXYFFToutm,1))
			Qbintw[2] = FeXYFFToutmw[bi2][bj2]///srcFFToutmw[bi0][bj0]

			bi3=round((cpickb[0]-dimoffset($FeXFFToutm,0))/dimdelta($FeXFFToutm,0))
			bj3=round((cpickb[1]-dimoffset($FeXFFToutm,1))/dimdelta($FeXFFToutm,1))
			Qbintw[3] = FeXFFToutmw[bi3][bj3]///srcFFToutmw[bi0][bj0]

			bi4=round((cpickb[0]-dimoffset($FeYFFToutm,0))/dimdelta($FeYFFToutm,0))
			bj4=round((cpickb[1]-dimoffset($FeYFFToutm,1))/dimdelta($FeYFFToutm,1))
			Qbintw[4] = FeXFFToutmw[bi4][bj4]///srcFFToutmw[bi0][bj0]

			if (normfftq == 1)
				Qbintw/=srcFFToutmw[bi0][bj0]
			else
			endif

	color3s_for3dm2($srcd,3)
	color3s_for3dmf($srcFFToutm,30)
	color3s_followtopo($Se_outputLs,3,$src)
	color3s_followtopof($SeFFToutm,30,$srcFFToutm)
	color3s_followtopo($FeX_outputLs,3,$src)
	color3s_followtopof($FeXFFToutm,30,$srcFFToutm)
	color3s_followtopo($FeY_outputLs,3,$src)
	color3s_followtopof($FeYFFToutm,30,$srcFFToutm)
	//color3s_followtopo($FeXY_outputLs,3,$src)
	color3s_followtopo2($FeXY_outputLs,3,$src)

	color3s_followtopof($FeXYFFToutm,30,$srcFFToutm)

	wavestats/Q $Fexyd
	variable rangls = max(abs(V_max),abs(V_min))
	ModifyImage/W=$grabwinchild(Fexyd) $Fexyd ctab= {-rangls,rangls,:Packages:NewColortable:dvg_seismic,0};ColorScale/W=$grabwinchild(Fexyd)/C/N=text0/F=0/A=MC/Y=-120 image=$Fexyd
end

Function SetVarProc_lsnormfftq(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G thresh_ls
	string/G src_ls
	string/G name_ls
	string src = src_ls
	string topo = name_ls
	variable/G FFTwindow

	string SeLattice="SeLattice"+topo
	string FeXLattice="FeXLattice"+topo
	string FeYLattice="FeYLattice"+topo
	string FeXYLattice="FeXYLattice"+topo

	string Se_outputLs = "sg_"+SeLattice+"_"+Src
	string FeXY_outputLs = "sg_"+FeXYLattice+"_"+Src
	string FeX_outputLs = "sg_"+FeXLattice+"_"+Src
	string FeY_outputLs = "sg_"+FeYLattice+"_"+Src
	string segmatrix = "segmatrix_"+Src

	string srcd=src+"_d"

	String srcFFToutm = srcd + "_FFT"+"_Modula"
	String SeFFToutm = Se_outputLs + "_FFT"+"_Modula"
	String FeXYFFToutm = FeXY_outputLs + "_FFT"+"_Modula"
	String FeXFFToutm = FeX_outputLs + "_FFT"+"_Modula"
	String FeYFFToutm = FeY_outputLs + "_FFT"+"_Modula"
	wave srcFFToutmw = $srcFFToutm
	wave SeFFToutmw = $SeFFToutm
	wave FeXYFFToutmw = $FeXYFFToutm
	wave FeXFFToutmw = $FeXFFToutm
	wave FeYFFToutmw = $FeYFFToutm

	String cpickbs = topo+"_QB"
	String cpickas = topo+"_QA"
	wave cpickb = $cpickbs
	wave cpicka = $cpickas

	string QAint = "QAint_"+src
	string QBint = "QBint_"+src
	make/n=5/o $QAint
	make/n=5/o $QBint
	wave QAintw = $QAint
	wave QBintw = $QBint
	variable ai0,ai1,ai2,ai3,ai4
	variable aj0,aj1,aj2,aj3,aj4

	variable bi0,bi1,bi2,bi3,bi4
	variable bj0,bj1,bj2,bj3,bj4

	variable/G normfftq
	//For QA
			ai0=round((cpicka[0]-dimoffset($srcFFToutm,0))/dimdelta($srcFFToutm,0))
			aj0=round((cpicka[1]-dimoffset($srcFFToutm,1))/dimdelta($srcFFToutm,1))
			QAintw[0] = srcFFToutmw[ai0][aj0]///srcFFToutmw[ai0][aj0]

			ai1=round((cpicka[0]-dimoffset($SeFFToutm,0))/dimdelta($SeFFToutm,0))
			aj1=round((cpicka[1]-dimoffset($SeFFToutm,1))/dimdelta($SeFFToutm,1))
			QAintw[1] = SeFFToutmw[ai1][aj1]///srcFFToutmw[ai0][aj0]

			ai2=round((cpicka[0]-dimoffset($FeXYFFToutm,0))/dimdelta($FeXYFFToutm,0))
			aj2=round((cpicka[1]-dimoffset($FeXYFFToutm,1))/dimdelta($FeXYFFToutm,1))
			QAintw[2] = FeXYFFToutmw[ai2][aj2]///srcFFToutmw[ai0][aj0]

			ai3=round((cpicka[0]-dimoffset($FeXFFToutm,0))/dimdelta($FeXFFToutm,0))
			aj3=round((cpicka[1]-dimoffset($FeXFFToutm,1))/dimdelta($FeXFFToutm,1))
			QAintw[3] = FeXFFToutmw[ai3][aj3]///srcFFToutmw[ai0][aj0]

			ai4=round((cpicka[0]-dimoffset($FeYFFToutm,0))/dimdelta($FeYFFToutm,0))
			aj4=round((cpicka[1]-dimoffset($FeYFFToutm,1))/dimdelta($FeYFFToutm,1))
			QAintw[4] = FeXFFToutmw[ai4][aj4]///srcFFToutmw[ai0][aj0]

			if (normfftq == 1)
				QAintw/=srcFFToutmw[ai0][aj0]
			else
			endif


		//For QB
			bi0=round((cpickb[0]-dimoffset($srcFFToutm,0))/dimdelta($srcFFToutm,0))
			bj0=round((cpickb[1]-dimoffset($srcFFToutm,1))/dimdelta($srcFFToutm,1))
			QBintw[0] = srcFFToutmw[bi0][bj0]///srcFFToutmw[bi0][bj0]

			bi1=round((cpickb[0]-dimoffset($SeFFToutm,0))/dimdelta($SeFFToutm,0))
			bj1=round((cpickb[1]-dimoffset($SeFFToutm,1))/dimdelta($SeFFToutm,1))
			Qbintw[1] = SeFFToutmw[bi1][bj1]///srcFFToutmw[bi0][bj0]

			bi2=round((cpickb[0]-dimoffset($FeXYFFToutm,0))/dimdelta($FeXYFFToutm,0))
			bj2=round((cpickb[1]-dimoffset($FeXYFFToutm,1))/dimdelta($FeXYFFToutm,1))
			Qbintw[2] = FeXYFFToutmw[bi2][bj2]///srcFFToutmw[bi0][bj0]

			bi3=round((cpickb[0]-dimoffset($FeXFFToutm,0))/dimdelta($FeXFFToutm,0))
			bj3=round((cpickb[1]-dimoffset($FeXFFToutm,1))/dimdelta($FeXFFToutm,1))
			Qbintw[3] = FeXFFToutmw[bi3][bj3]///srcFFToutmw[bi0][bj0]

			bi4=round((cpickb[0]-dimoffset($FeYFFToutm,0))/dimdelta($FeYFFToutm,0))
			bj4=round((cpickb[1]-dimoffset($FeYFFToutm,1))/dimdelta($FeYFFToutm,1))
			Qbintw[4] = FeXFFToutmw[bi4][bj4]///srcFFToutmw[bi0][bj0]

			if (normfftq == 1)
				Qbintw/=srcFFToutmw[bi0][bj0]
			else
			endif
end

Function SetVarProc_lsFFTwindow(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	MDoLSegrereapplyfftmode()
end
Function MDoLSegrereapplyfftmode()
	variable/G thresh_ls
	string/G src_ls
	string/G name_ls
	string src = src_ls
	string topo = name_ls
	variable/G FFTwindow

	string SeLattice="SeLattice"+topo
	string FeXLattice="FeXLattice"+topo
	string FeYLattice="FeYLattice"+topo
	string FeXYLattice="FeXYLattice"+topo

	string Se_outputLs = "sg_"+SeLattice+"_"+Src
	string FeXY_outputLs = "sg_"+FeXYLattice+"_"+Src
	string FeX_outputLs = "sg_"+FeXLattice+"_"+Src
	string FeY_outputLs = "sg_"+FeYLattice+"_"+Src
	string segmatrix = "segmatrix_"+Src

	string srcd=src+"_d"

	FFTrls($Se_outputLs,FFTwindow+1)
	FFTrls($FeXY_outputLs,FFTwindow+1)
	FFTrls($FeX_outputLs,FFTwindow+1)
	FFTrls($FeY_outputLs,FFTwindow+1)
	FFTrls($srcd,FFTwindow+1)

	String srcFFToutm = srcd + "_FFT"+"_Modula"
	String SeFFToutm = Se_outputLs + "_FFT"+"_Modula"
	String FeXYFFToutm = FeXY_outputLs + "_FFT"+"_Modula"
	String FeXFFToutm = FeX_outputLs + "_FFT"+"_Modula"
	String FeYFFToutm = FeY_outputLs + "_FFT"+"_Modula"
	wave srcFFToutmw = $srcFFToutm
	wave SeFFToutmw = $SeFFToutm
	wave FeXYFFToutmw = $FeXYFFToutm
	wave FeXFFToutmw = $FeXFFToutm
	wave FeYFFToutmw = $FeYFFToutm

	String cpickbs = topo+"_QB"
	String cpickas = topo+"_QA"
	wave cpickb = $cpickbs
	wave cpicka = $cpickas

	string QAint = "QAint_"+src
	string QBint = "QBint_"+src
	make/n=5/o $QAint
	make/n=5/o $QBint
	wave QAintw = $QAint
	wave QBintw = $QBint
	variable ai0,ai1,ai2,ai3,ai4
	variable aj0,aj1,aj2,aj3,aj4

	variable bi0,bi1,bi2,bi3,bi4
	variable bj0,bj1,bj2,bj3,bj4

	variable/G normfftq
	//For QA
			ai0=round((cpicka[0]-dimoffset($srcFFToutm,0))/dimdelta($srcFFToutm,0))
			aj0=round((cpicka[1]-dimoffset($srcFFToutm,1))/dimdelta($srcFFToutm,1))
			QAintw[0] = srcFFToutmw[ai0][aj0]///srcFFToutmw[ai0][aj0]

			ai1=round((cpicka[0]-dimoffset($SeFFToutm,0))/dimdelta($SeFFToutm,0))
			aj1=round((cpicka[1]-dimoffset($SeFFToutm,1))/dimdelta($SeFFToutm,1))
			QAintw[1] = SeFFToutmw[ai1][aj1]///srcFFToutmw[ai0][aj0]

			ai2=round((cpicka[0]-dimoffset($FeXYFFToutm,0))/dimdelta($FeXYFFToutm,0))
			aj2=round((cpicka[1]-dimoffset($FeXYFFToutm,1))/dimdelta($FeXYFFToutm,1))
			QAintw[2] = FeXYFFToutmw[ai2][aj2]///srcFFToutmw[ai0][aj0]

			ai3=round((cpicka[0]-dimoffset($FeXFFToutm,0))/dimdelta($FeXFFToutm,0))
			aj3=round((cpicka[1]-dimoffset($FeXFFToutm,1))/dimdelta($FeXFFToutm,1))
			QAintw[3] = FeXFFToutmw[ai3][aj3]///srcFFToutmw[ai0][aj0]

			ai4=round((cpicka[0]-dimoffset($FeYFFToutm,0))/dimdelta($FeYFFToutm,0))
			aj4=round((cpicka[1]-dimoffset($FeYFFToutm,1))/dimdelta($FeYFFToutm,1))
			QAintw[4] = FeXFFToutmw[ai4][aj4]///srcFFToutmw[ai0][aj0]

			if (normfftq == 1)
				QAintw/=srcFFToutmw[ai0][aj0]
			else
			endif


		//For QB
			bi0=round((cpickb[0]-dimoffset($srcFFToutm,0))/dimdelta($srcFFToutm,0))
			bj0=round((cpickb[1]-dimoffset($srcFFToutm,1))/dimdelta($srcFFToutm,1))
			QBintw[0] = srcFFToutmw[bi0][bj0]///srcFFToutmw[bi0][bj0]

			bi1=round((cpickb[0]-dimoffset($SeFFToutm,0))/dimdelta($SeFFToutm,0))
			bj1=round((cpickb[1]-dimoffset($SeFFToutm,1))/dimdelta($SeFFToutm,1))
			Qbintw[1] = SeFFToutmw[bi1][bj1]///srcFFToutmw[bi0][bj0]

			bi2=round((cpickb[0]-dimoffset($FeXYFFToutm,0))/dimdelta($FeXYFFToutm,0))
			bj2=round((cpickb[1]-dimoffset($FeXYFFToutm,1))/dimdelta($FeXYFFToutm,1))
			Qbintw[2] = FeXYFFToutmw[bi2][bj2]///srcFFToutmw[bi0][bj0]

			bi3=round((cpickb[0]-dimoffset($FeXFFToutm,0))/dimdelta($FeXFFToutm,0))
			bj3=round((cpickb[1]-dimoffset($FeXFFToutm,1))/dimdelta($FeXFFToutm,1))
			Qbintw[3] = FeXFFToutmw[bi3][bj3]///srcFFToutmw[bi0][bj0]

			bi4=round((cpickb[0]-dimoffset($FeYFFToutm,0))/dimdelta($FeYFFToutm,0))
			bj4=round((cpickb[1]-dimoffset($FeYFFToutm,1))/dimdelta($FeYFFToutm,1))
			Qbintw[4] = FeXFFToutmw[bi4][bj4]///srcFFToutmw[bi0][bj0]

			if (normfftq == 1)
				Qbintw/=srcFFToutmw[bi0][bj0]
			else
			endif

	color3s_for3dm2($srcd,3)
	color3s_for3dmf($srcFFToutm,30)
	color3s_followtopo($Se_outputLs,3,$src)
	color3s_followtopof($SeFFToutm,30,$srcFFToutm)
	color3s_followtopo($FeX_outputLs,3,$src)
	color3s_followtopof($FeXFFToutm,30,$srcFFToutm)
	color3s_followtopo($FeY_outputLs,3,$src)
	color3s_followtopof($FeYFFToutm,30,$srcFFToutm)
	//color3s_followtopo($FeXY_outputLs,3,$src)
	color3s_followtopo2($FeXY_outputLs,3,$src)

	color3s_followtopof($FeXYFFToutm,30,$srcFFToutm)
end

Function SetVarProc_lsns(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G cts_ls
	variable/G cte_ls
	variable/G ctn_ls
	String/G name_ls
	String/G name_lss

	string ContourZwave = "fit_"+name_ls+"_ftd"
	string graphname ="Segregated_"+name_lss

	SetVariable setCes win =$graphname, title="End",size={120,20},value=cte_ls,limits={cts_ls,1,0.05},proc=SetVarProc_lsends
	string chidname0 = graphname+"#G0"

	ModifyContour/W=$chidname0 $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};
	ModifyGraph/W=$chidname0 rgb=(65535,65535,65535)

	string chidname8 = graphname+"#G8"

	ModifyContour/W=$chidname8 $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};
	ModifyGraph/W=$chidname8 rgb=(65535,65535,65535)
End

Function SetVarProc_lsstarts(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G cts_ls
	variable/G cte_ls
	variable/G ctn_ls
	String/G name_ls
	String/G name_lss

	string ContourZwave = "fit_"+name_ls+"_ftd"
	string graphname ="Segregated_"+name_lss

	SetVariable setCes win =$graphname, title="End",size={120,20},value=cte_ls,limits={cts_ls,1,0.05},proc=SetVarProc_lsends
	string chidname0 = graphname+"#G0"

	ModifyContour/W=$chidname0 $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};
	ModifyGraph/W=$chidname0 rgb=(65535,65535,65535)

	string chidname8 = graphname+"#G8"

	ModifyContour/W=$chidname8 $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};
	ModifyGraph/W=$chidname8 rgb=(65535,65535,65535)
End

Function SetVarProc_lsends(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G cts_ls
	variable/G cte_ls
	variable/G ctn_ls
	String/G name_ls
	String/G name_lss

	string ContourZwave = "fit_"+name_ls+"_ftd"
	string graphname ="Segregated_"+name_lss

	SetVariable setCes win =$graphname, title="End",size={120,20},value=cte_ls,limits={cts_ls,1,0.05},proc=SetVarProc_lsends

	string chidname0 = graphname+"#G0"

	ModifyContour/W=$chidname0 $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};
	ModifyGraph/W=$chidname0 rgb=(65535,65535,65535)

	string chidname8 = graphname+"#G8"

	ModifyContour/W=$chidname8 $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};
	ModifyGraph/W=$chidname8 rgb=(65535,65535,65535)
End




//#IV.3_1 Special FFT Function
Function FFTrls(name,sel)
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
	Complextorealfls($FFTout,1)
	String FFToutm = FFTout+"_Modula"
	killwaves named
	//color3sfft($tpw(),30)
	//Print "FFTr("+nameofWave(name)+")"
end

//#IV.3_2 Special FFT Function (called)
Function Complextorealfls(name1w,select)
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
	if (select==2)
		name=name1+"_real"
		make/o/N=(dimsize(name1w,0),dimsize(name1w,1)) $name
		wave namew = $name
		namew=real(name1w)
	endif
	if (select==3)
		name=name1+"_Imag"
		make/o/N=(dimsize(name1w,0),dimsize(name1w,1)) $name
		wave namew = $name
		namew=imag(name1w)
	endif
	setscale/i x,dimoffset(name1w,0),dimoffset(name1w,0)+dimdelta(name1w,0)*(dimsize(name1w,0)-1),"",namew
	setscale/i y,dimoffset(name1w,1),dimoffset(name1w,1)+dimdelta(name1w,1)*(dimsize(name1w,1)-1),"",namew
	//dilf(namew)
end

//#IV.4 Main Functional Codes
Function DoLSegre(name,prefwave,thresh,mode)
	string name // 2D wave to be segregated
	string Prefwave // 2D wave from which simulated lattice can be extracted
	variable thresh // threshold for defining a lattice position (max=1)
	variable mode //  (= 1 is Scatter imageinterpolate mode, more modes to be added)

	wave namew = $name
	wave Prefwavew = $Prefwave

	//string Prefwave2
	//wave Prefwave2w = $Prefwave2

	string outputLs = "sg_"+Prefwave+"_"+name

	//** Create selected area Matrix, the mask is defined by prefwave
		string segmatrix = "segmatrix_"+name
		make/o/N=(dimsize($name,0),dimsize($name,1)) $segmatrix
		setscale/p x, dimoffset($name,0),dimdelta($name,0),"",$segmatrix
		setscale/p y, dimoffset($name,1),dimdelta($name,1),"",$segmatrix
		wave segmatrixw = $segmatrix
		segmatrixw=nan
		variable meanvalue=mean(namew)
		variable i,j
		i=0
		do
			j=0
			do
				if (Prefwavew[i][j]>thresh) //|| Prefwave2w[i][j]>thresh)
					segmatrixw[i][j] = namew[i][j]
				//else
					//segmatrixw[i][j] = meanvalue
				endif
			j+=1
			while(j<dimsize($name,1))
		i+=1
		while(i<dimsize($name,0))

	//** Remove NaN Data Point
	  //* Method 1 (ImageInterpolate voronoi)
		If (mode == 1)
			string xx = "xx_"+name+"_"+prefwave
			string yy = "yy_"+name+"_"+prefwave
			string zz = "zz_"+name+"_"+prefwave
			make/o/n=0 $xx
			make/o/n=0 $yy
			make/o/n=0 $zz
			wave xxw = $xx
			wave yyw = $yy
			wave zzw = $zz

			variable i1,j1
			i1=0
			do
				j1=0
				do
					if(mod(Round(segmatrixw[i1][j1]),1)!=0)
					else
						InsertPoints dimsize(xxw,0),1, xxw
						xxw[dimsize(xxw,0)-1]=dimoffset(segmatrixw,0)+i1*dimdelta(segmatrixw,0)
						InsertPoints dimsize(yyw,0),1, yyw
						yyw[dimsize(yyw,0)-1]=dimoffset(segmatrixw,1)+j1*dimdelta(segmatrixw,1)
						InsertPoints dimsize(zzw,0),1, zzw
						zzw[dimsize(zzw,0)-1]=segmatrixw[i1][j1]
					endif

					j1+=1
				while(j1<dimsize(segmatrixw,1))
				i1+=1
			while(i1<dimsize(segmatrixw,0))

			Make/O/N=(dimsize(xxw,0),3) TripletLS
			TripletLS[][0]=xxw[p]
			TripletLS[][1]=yyw[p]
			TripletLS[][2]=zzw[p]
			ImageInterpolate/RESL={(dimsize(segmatrixw,0)),(dimsize(segmatrixw,1))}/DEST=$outputLs voronoi TripletLS
			killwaves zzw TripletLS
			//killwaves xxw yyw
		endif

	//func_NaN0($outputLs)
	//killwaves segmatrixw
	//di(segmatrixw)
	//di($outputLs)
	//wavestats/Q $name
	//ModifyImage $outputLs ctab= {V_min,V_max,VioletOrangeYellow,0}

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

//#IV.4 Main Functional Codes (special case for FeXY)
Function DoLSegreXY(name,prefwave,prefwave2,thresh,mode)
	string name // 2D wave to be segregated
	string Prefwave // extracted simu. lattice
	string Prefwave2// extracted simu. lattice #2
	variable thresh // threshold for defining a lattice position (max=1)
	variable mode //  (= 1 is Scatter imageinterpolate mode, more modes to be added)

	wave namew = $name
	wave Prefwavew = $Prefwave
	wave Prefwave2w = $Prefwave2

	String/G name_ls
	//string outputLs = "sg_"+Prefwave+"_"+name
	string outputLs = "sg_"+"FeXYLattice"+name_ls+"_"+name

	//** Create selected area Matrix, the mask is defined by prefwave
		string segmatrix = "segmatrix_"+name
		make/o/N=(dimsize($name,0),dimsize($name,1)) $segmatrix
		setscale/p x, dimoffset($name,0),dimdelta($name,0),"",$segmatrix
		setscale/p y, dimoffset($name,1),dimdelta($name,1),"",$segmatrix
		wave segmatrixw = $segmatrix
		segmatrixw=nan
		variable meanvalue=mean(namew)
		variable i,j
		i=0
		do
			j=0
			do
				if (Prefwavew[i][j]>thresh || Prefwave2w[i][j]>thresh)
					segmatrixw[i][j] = namew[i][j]
				//else
					//segmatrixw[i][j] = meanvalue
				endif
			j+=1
			while(j<dimsize($name,1))
		i+=1
		while(i<dimsize($name,0))

	//** Remove NaN Data Point
	  //* Method 1 (ImageInterpolate voronoi)
		If (mode == 1)
			string xx = "xx_"+name+"_"+"FeXYLattice"+name_ls
			string yy = "yy_"+name+"_"+"FeXYLattice"+name_ls
			string zz = "zz_"+name+"_"+"FeXYLattice"+name_ls
			make/o/n=0 $xx
			make/o/n=0 $yy
			make/o/n=0 $zz
			wave xxw = $xx
			wave yyw = $yy
			wave zzw = $zz

			variable i1,j1
			i1=0
			do
				j1=0
				do
					if(mod(Round(segmatrixw[i1][j1]),1)!=0)
					else
						InsertPoints dimsize(xxw,0),1, xxw
						xxw[dimsize(xxw,0)-1]=dimoffset(segmatrixw,0)+i1*dimdelta(segmatrixw,0)
						InsertPoints dimsize(yyw,0),1, yyw
						yyw[dimsize(yyw,0)-1]=dimoffset(segmatrixw,1)+j1*dimdelta(segmatrixw,1)
						InsertPoints dimsize(zzw,0),1, zzw
						zzw[dimsize(zzw,0)-1]=segmatrixw[i1][j1]
					endif

					j1+=1
				while(j1<dimsize(segmatrixw,1))
				i1+=1
			while(i1<dimsize(segmatrixw,0))

			Make/O/N=(dimsize(xxw,0),3) TripletLS
			TripletLS[][0]=xxw[p]
			TripletLS[][1]=yyw[p]
			TripletLS[][2]=zzw[p]
			ImageInterpolate/RESL={(dimsize(segmatrixw,0)),(dimsize(segmatrixw,1))}/DEST=$outputLs voronoi TripletLS
			killwaves zzw TripletLS
			//killwaves xxw yyw
		endif

	//func_NaN0($outputLs)
	//killwaves segmatrixw
	//di(segmatrixw)
	//di($outputLs)
	//wavestats/Q $name
	//ModifyImage $outputLs ctab= {V_min,V_max,VioletOrangeYellow,0}

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

//***************************************************************************//
//***************************************************************************//
//***************************************************************************//
//***********************    V.Auxiliary Functions **************************//
//***************************************************************************//
//***************************************************************************//
//***************************************************************************//
Function color3s_followtopo(name,tt,topo)
	wave name
	variable tt
	wave topo
	gethistgram_npcolor(nameofwave(topo))
	string W_coef = "W_coef"
	wave W_coefw = $W_coef
	variable sigma = sqrt(2)*W_coefw[3]

	wavestats/Q topo
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
end
Function color3s_followtopo2(name,tt,topo)
	wave name
	variable tt
	wave topo
	gethistgram_npcolor(nameofwave(topo))
	string W_coef = "W_coef"
	wave W_coefw = $W_coef
	variable sigma = sqrt(2)*W_coefw[3]

	wavestats/Q topo
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
end
Function color3s_followtopof(name,tt,topo)
	wave name
	variable tt
	wave topo
	gethistgram_npcolor(nameofwave(topo))
	string W_coef = "W_coef"
	wave W_coefw = $W_coef
	variable sigma = sqrt(2)*W_coefw[3]

	wavestats/Q topo
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
end

Function color3s_for3dmf(name,tt)
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

	ModifyImage/W=$grabwinchild(nameofwave(name)) $nameofwave(name) ctab= {lc,lh,VioletOrangeYellow,1}
	//PRINT num2str(W_coefw[2]-1.5*sigma)+" "+ num2str(W_coefw[2]+1.5*sigma)
	//print num2str(W_coefw[2])
	//display namehistw
end

Function color3s_for3dmLS(name,tt)
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

	ModifyImage/W=$grabwinchild(nameofwave(name)) $nameofwave(name) ctab= {*,*,BlueGreenOrange,0}
	//PRINT num2str(W_coefw[2]-1.5*sigma)+" "+ num2str(W_coefw[2]+1.5*sigma)
	//print num2str(W_coefw[2])
	//display namehistw
end

//***************************************************************************//
//***************************************************************************//
//***************************************************************************//
//**********   V.Lattice segregation on the whole 3D matrix  ****************//
//***************************************************************************//
//***************************************************************************//
//***************************************************************************//

Function ButtonProc_Lsmatrix3d(ctrlName) : ButtonControl
	String ctrlName
	Execute "Lsmatrix3d()"
End
Proc Lsmatrix3d(indicate,mat3dn,refwave)
	String indicate="Please do reference segregation First by 3D smart Displayer"
	string mat3dn = mat3dn_cons// stringfromList(0,getall3dwave())// name of the mat3d to be sheared = "g2_001_G"
	string refwave = replaceString("_G",mat3dn,"_T")
	//variable factor = 1.5
	Prompt indicate,"Indication"
	prompt mat3dn,"The 3D matrix to Segregated"
	prompt refwave,"The 2D shape reference matrix [Topography]"
	//prompt factor,"Scatter Interp factor (must be the same as refwave shear)"

	Lsmatrix3dall(mat3dn,refwave,1)
end

Function Lsmatrix3dall(mat3dn,refwave,factor)
	string mat3dn // name of the mat3d to be sheared = "g2_001_G"
	string refwave // name of the shear reference wave = "g2_001_T"  string barename = replaceString("_G",mat3dn,"_T")
	variable factor

	variable/G thresh_ls
	Print "Threshold Used is "+num2str(thresh_ls)
	string slicename = "s_"+mat3dn
	wave mat3dnw = $mat3dn
	make/N=(dimsize(mat3dnw,0),dimsize(mat3dnw,1))/o $slicename
	setscale/p x,dimoffset(mat3dnw,0),dimdelta(mat3dnw,0),"",$slicename
	setscale/p y,dimoffset(mat3dnw,1),dimdelta(mat3dnw,1),"",$slicename
	wave slicenamew = $slicename

	//string outslice = "Shearcorrected_"+refwave
	//wave outslicew = $outslice

	variable znum = dimsize(mat3dnw,2)

	string SeLattice="SeLattice"+refwave
	string FeXLattice="FeXLattice"+refwave
	string FeYLattice="FeYLattice"+refwave
	string FeXYLattice="FeXYLattice"+refwave

	//name of segregated output
	string Se_outputLs = "sg_"+SeLattice+"_"+nameofwave(slicenamew)
	string FeXY_outputLs = "sg_"+FeXYLattice+"_"+nameofwave(slicenamew)
	string FeX_outputLs = "sg_"+FeXLattice+"_"+nameofwave(slicenamew)
	string FeY_outputLs = "sg_"+FeYLattice+"_"+nameofwave(slicenamew)
		//string segmatrix = "segmatrix_"+nameofwave(slicenamew)

	//name of prep segregated out
	string zslice = "Zslice_"+mat3dn
	string Se_outputLsp = "sg_"+SeLattice+"_"+zslice
	string FeXY_outputLsp = "sg_"+FeXYLattice+"_"+zslice
	string FeX_outputLsp = "sg_"+FeXLattice+"_"+zslice
	string FeY_outputLsp = "sg_"+FeYLattice+"_"+zslice
	wave Se_outputLspw = $Se_outputLsp
	wave FeXY_outputLspw = $FeXY_outputLsp
	wave FeX_outputLspw = $FeX_outputLsp
	wave FeY_outputLspw = $FeY_outputLsp

	//print Se_outputLsp
	string mat3dafterls_Se = mat3dn+"_Se"
	make/N=(dimsize(Se_outputLspw,0),dimsize(Se_outputLspw,1),dimsize(mat3dnw,2))/o $mat3dafterls_Se
	setscale/p x,dimoffset(Se_outputLspw,0),dimdelta(Se_outputLspw,0),"",$mat3dafterls_Se
	setscale/p y,dimoffset(Se_outputLspw,1),dimdelta(Se_outputLspw,1),"",$mat3dafterls_Se
	setscale/p z,dimoffset(mat3dnw,2),dimdelta(mat3dnw,2),"",$mat3dafterls_Se
	wave mat3dafterls_Sew = $mat3dafterls_Se

	string mat3dafterls_FeX = mat3dn+"_FeX"
	make/N=(dimsize(FeX_outputLspw,0),dimsize(FeX_outputLspw,1),dimsize(mat3dnw,2))/o $mat3dafterls_FeX
	setscale/p x,dimoffset(FeX_outputLspw,0),dimdelta(FeX_outputLspw,0),"",$mat3dafterls_FeX
	setscale/p y,dimoffset(FeX_outputLspw,1),dimdelta(FeX_outputLspw,1),"",$mat3dafterls_FeX
	setscale/p z,dimoffset(mat3dnw,2),dimdelta(mat3dnw,2),"",$mat3dafterls_FeX
	wave mat3dafterls_FeXw = $mat3dafterls_FeX

	string mat3dafterls_FeY = mat3dn+"_FeY"
	make/N=(dimsize(FeY_outputLspw,0),dimsize(FeY_outputLspw,1),dimsize(mat3dnw,2))/o $mat3dafterls_FeY
	setscale/p x,dimoffset(FeY_outputLspw,0),dimdelta(FeY_outputLspw,0),"",$mat3dafterls_FeY
	setscale/p y,dimoffset(FeY_outputLspw,1),dimdelta(FeY_outputLspw,1),"",$mat3dafterls_FeY
	setscale/p z,dimoffset(mat3dnw,2),dimdelta(mat3dnw,2),"",$mat3dafterls_FeY
	wave mat3dafterls_FeYw = $mat3dafterls_FeY

	string mat3dafterls_FeXY = mat3dn+"_FeXY"
	make/N=(dimsize(FeXY_outputLspw,0),dimsize(FeXY_outputLspw,1),dimsize(mat3dnw,2))/o $mat3dafterls_FeXY
	setscale/p x,dimoffset(FeXY_outputLspw,0),dimdelta(FeXY_outputLspw,0),"",$mat3dafterls_FeXY
	setscale/p y,dimoffset(FeXY_outputLspw,1),dimdelta(FeXY_outputLspw,1),"",$mat3dafterls_FeXY
	setscale/p z,dimoffset(mat3dnw,2),dimdelta(mat3dnw,2),"",$mat3dafterls_FeXY
	wave mat3dafterls_FeXYw = $mat3dafterls_FeXY

	string mat3dafterls_FeDif = mat3dn+"_FeDif"
	make/N=(dimsize(FeY_outputLspw,0),dimsize(FeY_outputLspw,1),dimsize(mat3dnw,2))/o $mat3dafterls_FeDif
	setscale/p x,dimoffset(FeY_outputLspw,0),dimdelta(FeY_outputLspw,0),"",$mat3dafterls_FeDif
	setscale/p y,dimoffset(FeY_outputLspw,1),dimdelta(FeY_outputLspw,1),"",$mat3dafterls_FeDif
	setscale/p z,dimoffset(mat3dnw,2),dimdelta(mat3dnw,2),"",$mat3dafterls_FeDif
	wave mat3dafterls_FeDifw = $mat3dafterls_FeDif


	variable i = 0
	do
		slicenamew[][] = mat3dnw[p][q][i]

		DoLSegre(nameofwave(slicenamew),SeLattice,thresh_ls,1)
		//DoLSegre(Src,FeXYLattice,thresh_ls,1)
		DoLSegreXY(nameofwave(slicenamew),FeXLattice,FeYLattice,thresh_ls,1)
		DoLSegre(nameofwave(slicenamew),FeXLattice,thresh_ls,1)
		DoLSegre(nameofwave(slicenamew),FeYLattice,thresh_ls,1)
		wave Se_outputLsw = $Se_outputLs
		wave FeXY_outputLsw = $FeXY_outputLs
		wave FeX_outputLsw = $FeX_outputLs
		wave FeY_outputLsw = $FeY_outputLs
		//func_nan0(Se_outputLsw)
		//func_nan0(FeX_outputLsw)
		//func_nan0(FeY_outputLsw)
		//func_nan0(FeXY_outputLsw)

		mat3dafterls_Sew[][][i]=Se_outputLsw[p][q]
		mat3dafterls_FeXw[][][i]=FeX_outputLsw[p][q]
		mat3dafterls_FeYw[][][i]=FeY_outputLsw[p][q]
		mat3dafterls_FeXYw[][][i]=FeXY_outputLsw[p][q]


		i+=1
	while(i<znum)
	mat3dafterls_FeDifw=mat3dafterls_FeXw-mat3dafterls_FeYw

	Print "Derived 3D Subalttice Grid name:"
	print mat3dafterls_Se, mat3dafterls_FeX, mat3dafterls_FeY, mat3dafterls_FeXY
end

Function PopMenuProc_Lsmatrix3d(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string body = "d3d(\""+popStr+"\",2)"
	//print body
	execute body
end

