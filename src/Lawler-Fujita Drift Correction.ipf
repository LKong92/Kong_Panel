#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
//************************************************************************************************************//
//*//////////////////////////////////////////////////////////////////////////////////////////////////////////*//
//*//////////////////////////////////////////////////////////////////////////////////////////////////////////*//
//*//////////////////////////////////////////////////////////////////////////////////////////////////////////*//
//*//////////////////////////////////////////////////////////////////////////////////////////////////////////*//
//*//////////////////////////////////////////////////////////////////////////////////////////////////////////*//
//*//////////////////////////////////////////////////////////////////////////////////////////////////////////*//
//*                                    Lawler-Fujita drift correction                                        *//
//*//////////////////////////////////////////////////////////////////////////////////////////////////////////*//
//*//////////////////////////////////////////////////////////////////////////////////////////////////////////*//
//*//////////////////////////////////////////////////////////////////////////////////////////////////////////*//
//*//////////////////////////////////////////////////////////////////////////////////////////////////////////*//
//*//////////////////////////////////////////////////////////////////////////////////////////////////////////*//
//*//////////////////////////////////////////////////////////////////////////////////////////////////////////*//
//************************************************************************************************************//
//** How to use?
//** (1) Display the Raw image "di(DATA_INPUT)"
//** (2) Click PrepFFT to call "ffc()", make a demonstrating FFT image
//** (3) Pick up the coordiante of Q_A and Q_b
//**     *Put cursor A & B, at left-bottom and right-top corner around the FFT peak in the 1st quandrant, click
//**     *GetA to call "gpac()", the procedure will save the cooridnate of Q_A by 2D Gaussian Fit. Repeat this
//**     *operation around Q_B, click GetB.
//** (4) Click LF button, to run the main procedure. The real space FFT is needed.
//************************************************************************************************************//

Function ButtonProc_LF(ctrlName) : ButtonControl
	String ctrlName
	Execute "LawlerFujita()"
End

Proc LawlerFujita(avedia,condA,condB,factor,sel)
	variable avedia = dimsize($namefftraw,0)*dimdelta($namefftraw,0)/2
	variable factor = 2
	variable condA = 1 //
	variable condB = 1 //
	variable sel = 2
	prompt avedia,"The FWHM in real space (guassian window)"
	prompt factor,"factor of the output, how many times the dimsize of original matrix"
	prompt condA, "the threshold for determine a jump for vector A, in portion of pi "
	Prompt condB, "the threshold for determine a jump for vector B, in portion of pi "
	prompt sel,"Which Q?",popup,"Global;Just Fitted"

	String name = namefftraw  //	name,"Data name to manipulate"

	string fftdata = name+"_FFT_Modula_INTER"
	if (cmpstr(grabwinnonew(fftdata),"") == 0)
	else
		Dowindow/K $grabwinnonew(fftdata)
	endif
	if (cmpstr(grabwinnonew(name),"") == 0)
	else
		Dowindow/K $grabwinnonew(name)
	endif

	variable/G sel_t2dlkQglobal = sel

	//** Get Q1 & Q2
		variable qx1
		variable qy1
		variable qx2
		variable qy2
		variable tpi = 2*pi
		//prompt qx1,"lock-in q1 (x)"
		//prompt qy1,"lock-in q1 (y)"
		//prompt qx2,"lock-in q2 (x)"
		//prompt qy2,"lock-in q2 (y)"
		string cpicka
		string cpickb
		if (sel == 2)
			cpicka = name+"_QA"
			cpickb = name+"_QB"
		endif
		if (sel == 1)
			cpicka = "GlobalQA"
			cpickb = "GlobalQB"
		endif
		qx1 = $cpicka[0]*tpi
		qy1 = $cpicka[1]*tpi
		qx2 = $cpickb[0]*tpi
		qy2 = $cpickb[1]*tpi
		Print "*** QA = (2pi*"+num2str($cpicka[0])+",2pi*"+num2str($cpicka[1])+")"
		Print "*** QB = (2pi*"+num2str($cpickb[0])+",2pi*"+num2str($cpickb[1])+")"
		Print "*** Real space diameter (FWHM) is set to be "+num2str(avedia)+", as shown in the figure."

	//string prefft = name+"_FFT_Modula_INTER"
	//Dowindow/B $grabwinnonew(prefft)

	//** Main Function
		LF(name,qx1,qy1,qx2,qy2,avedia,condA,condB,factor)

	//Dowindow/F $grabwinnonew(prefft)

	//** Draw figure of filtered partial FFT
		//string fftdata = name+"_FFT_Modula_INTER"
		//variable widthq=(2*sqrt(ln(2)))/avedia
		//String wn =grabwin(fftdata)
		//ModifyGraph/W=$grabwin(fftdata) width={Plan,1,bottom,left},height=0
		//SetDrawEnv/W=$grabwin(fftdata) xcoord= bottom,ycoord= left,linefgc= (0,0,0),dash= 0,linethick= 1.00,fillpat= 0,linefgc= (65535,65535,65535)
		//DrawOval/W=$grabwin(fftdata) -2*sqrt(ln(2))*widthq/2,-2*sqrt(ln(2))*widthq/2,+2*sqrt(ln(2))*widthq/2,+2*sqrt(ln(2))*widthq/2

	//** Draw Data Input and draw Guassian window
		//di2lf($name)
		//Dowindow/F $grabwin2(name)
		//Label left "Raw Data"
		//variable xrange = abs((dimsize($name, 0))*dimdelta($name, 0))
		//variable xs = dimoffset($name, 0)+xrange -(Xrange*0.02+avedia)
		//variable yrange = abs((dimsize($name, 1))*dimdelta($name, 1))
		//variable ys = yrange*0.02
		//SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),dash= 7,linethick= 3.00,fillpat= 0;
		//DrawOval xs,dimoffset($name,1)+ys,xs+avedia,dimoffset($name,1)+ys+avedia

	//** tile window
		//tilewindows/WINS=WinList("*", ";","WIN:3")/R/w=(4,0,66,100)
		//tilewindows/WINS=WinList("*", ";","WIN:1")/R/A=(4,3)/w=(3,0,50,100)
		print "LawlerFujita("+num2str(avedia)+","+num2str(condA)+","+num2str(condB)+","+num2str(factor)+")"
		//Print ""
	//** Error message, no stop but Continuing execution
		String msg
		Variable err
		msg=GetErrMessage(GetRTError(0),3);
		err=GetRTError(1)
		if (err != 0)
			Print "Error in Demo: " + msg
			Print "Continuing execution"
		endif
		string inforwaveLF = "inforwaveLF_"+name
		make/o/N=3 $inforwaveLF
		$inforwaveLF[0] = avedia
		$inforwaveLF[1] = factor
		$inforwaveLF[2] = condA
		$inforwaveLF[3] = condB
		Dosubwindisplay(name,avedia)
		ConstLF()
end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////** Main Function
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function LF(name,qx1,qy1,qx2,qy2,avedia,condA,condB,factor)
	String name    // the data to be manipulated
	variable qx1   // The FFT value of the vector, conversion (1/a), the scaled value directly readed from igor FFT image.
	variable qy1
	variable qx2
	variable qy2
	variable avedia //The FWHM in real space (guassian window)
	variable condA //the threshold for determine a jump for vector A, in portion of pi
	variable condB //the threshold for determine a jump for vector B, in portion of pi
	variable factor

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
		string normdataiff = normdata+"_IFF"
		IFFT/DEST=$normdataiff  normdataFFTw
		wave normdataiffw =$normdataiff
		unpadding(name,normdataiffw)
		string afternorm = normdataiff+"_up"
		wave afternormw = $afternorm

	//** Q_A ********************************************
	string tphase1
	tphase1 = name+"_phi_A"
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

			//jump2pi(tphase1w)
			//jump2piY(tphase1w)
			//jump2piX(tphase1w)
			//**$$$$$$$$$$$$$$$$$$$$$ di2lf(tphase1w)
			//**$$$$$$$$$$$$$$$$$$$$$ TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "θ\BA"
			cnfyj(tphase1w,condA*pi,2*pi)


	//** Q_B ********************************************
	string tphase2
	tphase2 = name+"_phi_B"
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

			//jump2pi(tphase2w)
			//jump2piY(tphase2w)
			//jump2piX(tphase2w)
			//**$$$$$$$$$$$$$$$$$$$$$ di2lf(tphase2w)
			//**$$$$$$$$$$$$$$$$$$$$$ TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "θ\BB"
			cnfyj(tphase2w,condB*pi,2*pi)

	//****************************************************************************
		String tpc1,tpc2
		tpc1 = tphase1+"_corrected"
		tpc2 = tphase2+"_corrected"
		wave tpc1w = $tpc1
		wave tpc2w = $tpc2

	//** Calculate displacement field ********************************************
		String ux,uy,ox,oy,outputLF
		ux =  name+"_ux"
		uy =  name+"_uy"
		ox =  name+"_ox"
		oy =  name+"_oy"
		outputLF = "LF_"+name

		duplicate/o namew $ux
		duplicate/o namew $uy
		wave uxw = $ux
		wave uyw = $uy
		uxw = (qy2*tpc1w-qy1*tpc2w)/(qx1*qy2-qy1*qx2)
		uyw = (-qx2*tpc1w+qx1*tpc2w)/(qx1*qy2-qy1*qx2) //these are displacement field

		//**$$$$$$$$$$$$$$$$$$$$$ di2lf(uxw)
		//**$$$$$$$$$$$$$$$$$$$$$ TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "u\S'\M\Bx"

		//**$$$$$$$$$$$$$$$$$$$$$ di2lf(uyw)
		//**$$$$$$$$$$$$$$$$$$$$$ TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "u\S'\M\By"


		duplicate/o namew $ox
		duplicate/o namew $oy
		wave oxw = $ox
		wave oyw = $oy
		oxw[][]= dimoffset(namew,0)+dimdelta(namew,0)*p
		oyw[][]= dimoffset(namew,1)+dimdelta(namew,1)*q

		oxw+=uxw
		oyw+=uyw //these are corrected coordinate

	//** Scatter Data interpolation ******************

		string zzlf="zz_"+name
		duplicate/o namew $zzlf
		wave zzlfw = $zzlf
		Redimension/N=(dimsize(zzlfw,0)*dimsize(zzlfw,1)) zzlfw

		string xxlf="xx_"+name
		duplicate/o oxw $xxlf
		wave xxlfw = $xxlf
		Redimension/N=(dimsize(xxlfw,0)*dimsize(xxlfw,1)) xxlfw

		string yylf="yy_"+name
		duplicate/o oyw $yylf
		wave yylfw = $yylf
		Redimension/N=(dimsize(yylfw,0)*dimsize(yylfw,1)) yylfw

				//string oneDtopo2 = "oneDtopo2"
				//wave oneDtopo2w = $oneDtopo2
				//p2dtopeak2(name);
				//string zzlf="zz_"+name
				//duplicate/o oneDtopo2w $zzlf;
				//wave zzlfw = $zzlf
				//p2dtopeak2(ox);
				//string xxlf="xx_"+name
				//duplicate/o oneDtopo2w $xxlf;
				//wave xxlfw = $xxlf
				//p2dtopeak2(oy);
				//string yylf="yy_"+name
				//duplicate/o oneDtopo2w $yylf;
				//wave yylfw = $yylf


		//** scatterinterp(xxlfw,yylfw,zzlfw,namew,factor)

				Make/O/N=(dimsize(xxlfw,0),3) sampleTripletLF
				sampleTripletLF[][0]=xxlfw[p]
				sampleTripletLF[][1]=yylfw[p]
				sampleTripletLF[][2]=zzlfw[p]
				ImageInterpolate/RESL={(factor*dimsize(namew,0)),(factor*dimsize(namew,1))}/DEST=$outputLF voronoi sampleTripletLF


		//** Plot
			wave outputLFw = $outputLF
			//func_NaN0(outputLFw)
			//**$$$$$$$$$$$$$$$$$$$$$ di2lf(outputLFw)
			//TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "LF Correction"
			//**$$$$$$$$$$$$$$$$$$$$$ Label left "LF Correction"

			//edit xxlfw yylfw zzlfw
			//cktable(winname(0,2))
			//**$$$$$$$$$$$$$$$$$$$$$ di2lf(nameiff1cw)
			//**$$$$$$$$$$$$$$$$$$$$$ TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "Filtered FFT(real,Q\BA\M)"

		//killwaves
		killwaves sampleTripletLF zzlfw oxw oyw afterup2sw nameiff2sw nameFFTfilter2sw nameFFT2sw namec2sw afterup2cw nameiff2cw namec2cw nameFFT2cw nameFFTfilter2cw afternormw normdataiffw normdataFFTw normdataw namec1cw nameFFT1cw nameFFTfilter1cw afterup1cw namec1sw nameFFT1sw nameFFTfilter1sw nameiff1sw afterup1sw
end
///////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////
Function unpadding(name,winput)
	string name // name of the original image which contain the original dimsize before padding
	wave winput // the padded wave
	wave namew =$name
	string source = nameofwave(winput)
	string nn = source+"_up"
	make/o/N=(dimsize(namew,0),dimsize(namew,1)) $nn
	wave nnw = $nn

	variable i,j
	i=0
	do
		j=0
		do
			nnw[i][j] = winput[i][j]
			j+=1
		while (j<dimsize(namew,1))
		i+=1
	while (i<dimsize(namew,0))
	setscale/p x, dimoffset(namew,0),dimdelta(namew,0),"",nnw
	setscale/p y, dimoffset(namew,1),dimdelta(namew,1),"",nnw
end
//////////////////////////////////////////////////////////////////////////////


//*****************************************************************************
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//************************ Jump Remover Version 3 *****************************
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
//****************************  Main Function  ********************************
///////////////////////////////////////////////////////////////////////////////
Function ButtonProc_cnfyjc(ctrlName) : ButtonControl
	String ctrlName
	Execute "cnfyjc()"
end

Proc cnfyjc(namew,add,cond)
	String namew = tpw()
	variable add = 2*pi
	variable cond = add/2
	Prompt namew,"Name of the wave to be manipulated"
	Prompt cond, "Threshold for dinstinguish a jump" // normally it is equal to add/2
	Prompt add, "the theoretical phase difference at the jump"
	cnfyj($namew,cond,add)
end

Function cnfyj(namew,cond,add)
	wave namew
	variable cond // pi, the jump height threshold to define a jump, usually it can be set as add/2
	variable add // 2pi, the theoretical phase difference at the jump

 //Make a matrix which contains the MDC jumps, but among the MDCs, the phase
 //     relationship is incorrect
	variable i,j
	i=0
	do
		findysjump(namew,cond,add,i)
		i+=1
	while (i< dimsize(namew,1))
	linkstsmapjr("jpy0_"+nameofwave(namew),namew)
	string jcm = "jc_"+nameofwave(namew)
	wave jcmw = $jcm // the 2D MDC jump matrix

 //Calculate the phase jump of the first EDC, use the value to scales MDCs
	findxsjump(namew,cond,add)
	string jx0 = "jpx0_"+nameofwave(namew)
	wave jx0w = $jx0 //the phase jump in the first EDC

 //Correct the phase difference between MDCs
	j=0
	do
		jcmw[,][j] += jx0w[j]
		j+=1
	while (j<dimsize(namew,1))

 // Remove the artifact that pi-pi = 10^-7
	minorbugremove(jcmw)

 //	Correct Namerw
	string namewr = nameofwave(namew)+"_Corrected"
	duplicate/o namew $namewr
	wave namewrw = $namewr
	namewrw+=jcmw
	//**$$$$$$$$$$$$$$$$$ dilf(namewrw)
	//**$$$$$$$$$$$$$$$$$ Label Left "Corrected θ\B"+nameofwave(namew)[9]
	//print "cnfyj("+nameofwave(namew)+","+num2str(cond/(pi))+"*pi,"+num2str(add)+")"

	string xs = "xs_"+nameofwave(namew)
	//wave xsw
	string ys = "ys_"+nameofwave(namew)
	//wave ysw =
	//string jc = "jc_"+nameofwave(namew)
	//wave jcw
	string jpxs = "jpxs_"+nameofwave(namew)
	//wave jpxsw
	string jpys = "jpys_"+nameofwave(namew)
	//wave jpysw
	string jpx0 = "jpx0_"+nameofwave(namew)
	killwaves $xs $ys $jpxs $jpys $jpx0
end
///////////////////////////////////////////////////////////////////////////////
//*****************************      MDCs      ********************************
///////////////////////////////////////////////////////////////////////////////
///Get phases of the Row [i], the intra-MDC phase relationship are correct, but
///inter-MDC phase is not correct, it will be corrected by EDC procedure later.
Function findysjump(namew,cond,add,i)
	wave namew
	variable cond // pi, the jump height threshold to define a jump, usually it can be set as add/2
	variable add // 2pi, the theoretical phase difference at the jump
	variable i

	string xs,jpxs
	xs = "ys_"+nameofwave(namew)
	jpxs = "jpys_"+nameofwave(namew)
	make/o/N=(dimsize(namew,0)) $xs
	make/o/N=(dimsize(namew,0)) $jpxs

 //Get the p position of where the jump happpens, Jump position wave **jpxsw**
	wave xsw = $xs
	wave jpxsw = $jpxs
	xsw[] = namew[p][i]  // the MDC[i]
	//display xsw
	jpxsw = nan
	jpxsw[0] = 0 // This is Jump position wave, the wave only have the P value where the jump appears
	variable j,dif
	variable tend
	j=0
	do
		dif = xsw[j+1]-xsw[j]
		if (dif > cond)
			jpxsw[checkfirstNonnan(jpxsw)]= j+1
		endif
		if (dif < -cond)
			jpxsw[checkfirstNonnan(jpxsw)]= -(j+1) // the sign indicates the jump is upstair or downstair, the absolute value indicate the position in P.
		endif
		j+=1
	while (j < dimsize(namew,0)-1)
	redimension/N=(checkfirstNonnan(jpxsw)) jpxsw //delete redundant data points which is nan

 //Check if the last point of the EDC is a phase jumpping point
	if (abs(jpxsw[dimsize(jpxsw,0)-1]) == dimsize(namew,0)-1)
		tend = 1 //if so, let tend = 1
	else
		tend = 0 //if not, let tend = 0, and add a point at the end of jpxsw, and let it equal to the last P of the EDC
		InsertPoints dimsize(jpxsw,0),1, jpxsw
		jpxsw[dimsize(jpxsw,0)-1] = dimsize(namew,0)-1
	endif

 //Make phase compensation wave	**jpx0w**
	string jpx0 = "jpy0_"+nameofwave(namew)+num2str(i)
	make/o/N=(dimsize(namew,0)) $jpx0
	wave jpx0w = $jpx0 //This is the compensation wave
	jpx0w = nan

	variable ic,ref

	//The jump location wave **jpxsw** divide compensation wave **jpx0w** to be several different sector, in each sector the compensation wave have same value

	//First Sector,
		ic = 0 //This is the first sector
		//To test if the value of first sector should have finite compensation
		//***********************
		if (namew[0][0] < -0.5)// may need to tune this parameter
		//***********************
			jpx0w[abs(jpxsw[ic]),abs(jpxsw[ic+1])-1] = add //If the condition hold, add initial compensation to the first sector.
			ref = jpx0w[abs(jpxsw[ic+1])-1] //ref is used for the next sector, value will be added or substracted by "add" from the ref, depends on downstair or upstair respectively.
		else
			jpx0w[abs(jpxsw[ic]),abs(jpxsw[ic+1])-1] = 0 //If not hold, initial compensation is zero.
			ref = jpx0w[abs(jpxsw[ic+1])-1]
		endif

	//Following Sector,
		ic = 1
		do
			//***************************************************** The last sector
			if (ic+1 > dimsize(jpxsw,0)-1)
				if (tend == 0) //The last point is not a jumpping position
					jpx0w[dimsize(namew,0)-1] = jpx0w[dimsize(namew,0)-2]
				endif
				if (tend == 1) //The last point is a jumpping position
					jpx0w[dimsize(namew,0)-1] = ref-sign(jpxsw[ic])*add
				endif
			//***************************************************** Other intermedia sectors
			else
				jpx0w[abs(jpxsw[ic]),abs(jpxsw[ic+1])-1] = ref-sign(jpxsw[ic])*add
				ref = jpx0w[abs(jpxsw[ic+1])-1]
			endif
			ic+=1
		while (ic < dimsize(jpxsw,0))
	//edit jpx0w
end
///////////////////////////////////////////////////////////////////////////////
//*****************************   link 2D Map   *******************************
///////////////////////////////////////////////////////////////////////////////
Function linkstsmapjr(name,wn)
	string name
	wave wn

	variable i
	string mat,jc
	//mat0=name+num2str(1)
	jc="jc_"+nameofwave(wn)
	//wave m=$mat0
	make/o/n=(dimsize(wn,0),dimsize(wn,1)) $jc
	wave jcw = $jc
	i=0
	do
		mat=name+num2str(i)
		wave n=$mat

		jcw[][i]= n[p]
		killwaves n
		i+=1
	while(i<dimsize(wn,1))
	setscale/P x, dimoffset(wn,0),dimdelta(wn,0),"",jcw
	setscale/P y, dimoffset(wn,1),dimdelta(wn,1),"",jcw
	//**$$$$$$$$$$$$$$$$$ dilf(jcw)
	//**$$$$$$$$$$$$$$$$$ Label Left "Compensation θ\B"+nameofwave(wn)[9]

end
Function minorbugremove(namew)
	wave namew
	variable i,j
	i=0
		do
		j=0
		do
			if (abs(namew[i][j]) < 10^-5)
				namew[i][j] =0
			endif
			j+=1
		while (j< dimsize(namew,1))
		i+=1
	while (i< dimsize(namew,0))
end

///////////////////////////////////////////////////////////////////////////////
//*****************************    First EDC    *******************************
///////////////////////////////////////////////////////////////////////////////
///check the phase of the first coloum, they are the start phase of each row
Function findxsjump (namew,cond,add)
	wave namew
	variable cond // pi, the jump height threshold to define a jump
	variable add // 2pi, the theoretical phase difference at the jump

	string xs,jpxs
	xs = "xs_"+nameofwave(namew)
	jpxs = "jpxs_"+nameofwave(namew)
	make/o/N=(dimsize(namew,1)) $xs
	make/o/N=(dimsize(namew,1)) $jpxs

 //Get the p position of where the jump happpens, Jump position wave **jpxsw**
	wave xsw = $xs
	wave jpxsw = $jpxs
	xsw[] = namew[0][p] // the EDC[0]
	//display xsw
	jpxsw = nan
	jpxsw[0] = 0 // This is Jump position wave, the wave only have the P value where the jump appears
	variable j,dif,tend
	j=0
	do
		dif = xsw[j+1]-xsw[j]
		if (dif > cond)
			jpxsw[checkfirstNonnan(jpxsw)]= j+1
		endif
		if (dif < -cond)
			jpxsw[checkfirstNonnan(jpxsw)]= -(j+1) // the sign indicates the jump is upstair or downstair, the absolute value indicate the position in P.
		endif
		j+=1
	while (j < dimsize(namew,1)-1)
	redimension/N=(checkfirstNonnan(jpxsw)) jpxsw  //delete redundant data points which is nan

 //Check if the last point of the EDC is a phase jumpping point
	if (abs(jpxsw[dimsize(jpxsw,0)-1]) == dimsize(namew,0)-1)
		tend = 1 //if so, let tend = 1
	else
		tend = 0 //if not, let tend = 0, and add a point at the end of jpxsw, and let it equal to the last P of the EDC
		InsertPoints dimsize(jpxsw,0),1, jpxsw
		jpxsw[dimsize(jpxsw,0)-1] = dimsize(namew,1)-1
	endif

 //Make phase compensation wave
	string jpx0 = "jpx0_"+nameofwave(namew)
	make/o/N=(dimsize(namew,1)) $jpx0
	wave jpx0w = $jpx0 //This is the compensation wave
	jpx0w = nan

	variable ic,ref

	//The jump location wave **jpxsw** divide compensation wave **jpx0w** to be several different sector, in each sector the compensation wave have same value


	//First Sector,
	    ic = 0  //This is the first sector
	    //To test if the value of first sector should have finite compensation
		//***********************
		if (namew[0][0] < -0.5)// may need to tune this parameter
		//***********************
			jpx0w[abs(jpxsw[ic]),abs(jpxsw[ic+1])-1] = add //If the condition hold, add initial compensation to the first sector.
			ref = jpx0w[abs(jpxsw[ic+1])-1] //ref is used for the next sector, value will be added or substracted by "add" from the ref, depends on downstair or upstair respectively.
		else
			jpx0w[abs(jpxsw[ic]),abs(jpxsw[ic+1])-1] = 0 //If not hold, initial compensation is zero.
			ref = jpx0w[abs(jpxsw[ic+1])-1]
		endif

	//Following Sector,
		ic = 1
		do
			//***************************************************** The last sector
			if (ic+1 > dimsize(jpxsw,0)-1)
				if (tend == 0) //The last point is not a jumpping position
					jpx0w[dimsize(namew,1)-1] = jpx0w[dimsize(namew,1)-2]
				endif
				if (tend == 1) //The last point is a jumpping position
					jpx0w[dimsize(namew,1)-1] = ref-sign(jpxsw[ic])*add
				endif
			//***************************************************** Other intermedia sectors
			else
				jpx0w[abs(jpxsw[ic]),abs(jpxsw[ic+1])-1] = ref-sign(jpxsw[ic])*add
				ref = jpx0w[abs(jpxsw[ic+1])-1]
			endif
		ic+=1
	while (ic < dimsize(jpxsw,0))

	//edit jpx0w
end
//#############################################################################
//************************ End Jump Remover Version 3 *************************
//#############################################################################





//*****************************************************************************
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//************************ Jump Remover Version 2 *****************************
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
//****************************  Main Function  ********************************
///////////////////////////////////////////////////////////////////////////////
Function jprm(namew,cond,jump)
	wave namew
	variable cond //=pi
	variable jump //=2*pi

	// Make initial wave
	variable k
	k=0
	string jumppoint,addvalue,addvaluem1
	do
		jumppoint="jp_"+nameofwave(namew)+num2str(k)
		addvalue="av_"+nameofwave(namew)+num2str(k)

		make/o/N=(dimsize(namew,0)) $jumppoint
		make/o/N=(dimsize(namew,0)) $addvalue

		wave jumppointw=$jumppoint
		wave addvaluew=$addvalue
		jumppointw = nan
		addvaluew = nan
		k+=1
	while (k<dimsize(namew,1))

	variable iv
	if (namew[0][0] < 0 )
		iv = 1
	else
		iv = 0
	endif

	print iv

	variable i,j,p_add
	j=0
	do
		jumppoint="jp_"+nameofwave(namew)+num2str(j)
		addvalue="av_"+nameofwave(namew)+num2str(j)
		addvaluem1="av_"+nameofwave(namew)+num2str(j-1)
		wave jumppointw=$jumppoint
		wave addvaluew=$addvalue

		jumppointw[0] = 0
		if (j == 0)
	 		addvaluew[0] = iv*jump
	 	endif

	 	if (j > 0)
	 		wave addvaluem1w=$addvaluem1
	 	 	addvaluew[0] = addvaluem1w[0]
	 		if (namew[0][j]-namew[0][j-1] > cond)
	 	 		addvaluew[0] = addvaluem1w[0]-jump
	 	 	endif
	 	 	if (namew[0][j]-namew[0][j-1] < -cond)
	 	 		addvaluew[0] = addvaluem1w[0]+jump
	 	 	endif
	 	endif

	 	i=1
	 	do
	 		if (namew[i][j] - namew[i-1][j] > cond )
	 			jumppointw[checkfirstNonnan(jumppointw)]=i
	 			p_add = checkfirstNonnan(addvaluew)-1
	 			addvaluew[checkfirstNonnan(addvaluew)]=addvaluew[p_add]-jump
	 			if (abs(addvaluew[checkfirstNonnan(addvaluew)-1]) < 10^-5)
	 				addvaluew[checkfirstNonnan(addvaluew)-1] = 0
	 			endif

	 		endif

	 		if (namew[i][j] - namew[i-1][j] < -cond )
	 			jumppointw[checkfirstNonnan(jumppointw)]=i
	 			p_add = checkfirstNonnan(addvaluew)-1
	 			addvaluew[checkfirstNonnan(addvaluew)]=addvaluew[p_add]+jump
	 			if (abs(addvaluew[checkfirstNonnan(addvaluew)-1]) < 10^-5)
	 				addvaluew[checkfirstNonnan(addvaluew)-1] = 0
	 			endif
	 		endif

			i+=1
		while(i < dimsize(namew,0))
		jumppointw[checkfirstNonnan(jumppointw)]=dimsize(namew,0)-1
		redimension/N=(checkfirstNonnan(jumppointw)) jumppointw
		redimension/N=(checkfirstNonnan(addvaluew)) addvaluew

		j+=1
	while(j < dimsize(namew,1))

	reorgjump(namew,cond,jump,"jp_"+nameofwave(namew),"av_"+nameofwave(namew))
end
Function reorgjump(namew,cond,jump,jumppoin,addvalu)
	wave namew
	variable cond //=pi
	variable jump //=2*pi
	string jumppoin
	string addvalu

	string jumppoint,addvalue
	variable j,ic,i
	j=0
	do
		jumppoint = jumppoin + num2str(j)
		addvalue = addvalu + num2str(j)
		wave jumppointw=$jumppoint
		wave addvaluew=$addvalue

		if(dimsize(jumppointw,0) > 2 )
			ic = 1
			do
				i = jumppointw[ic-1]
				do
					namew[i][j]+=addvaluew[ic-1]

					i+=1
				while (i< jumppointw[ic])
				ic+=1
			while(ic < dimsize(jumppointw,0))
		endif

		if(dimsize(jumppointw,0) == 2 )
			ic = 1
			do
				i = jumppointw[ic-1]
				do
					namew[i][j]+=addvaluew[ic-1]

					i+=1
				while (i< jumppointw[ic])
				ic+=1
			while(ic < dimsize(jumppointw,0))

			namew[jumppointw[1]][j]+=addvaluew[0]
		endif

		j+=1
	while(j<dimsize(namew,1))
end
//#############################################################################
//************************ End Jump Remover Version 2 *************************
//#############################################################################

///////////////////////////////////////////////////////////////////////////////////////////////
//Function scatterinterp(xxlfw,yylfw,zzlfw,namew,factor)
//	wave xxlfw
//	wave yylfw
//	wave zzlfw
//	wave namew
//	variable factor
//	String outputLF = nameofWave(namew)+"_LF"
//	Make/O/N=(dimsize(xxlfw,0),3) sampleTripletLF
//	sampleTripletLF[][0]=xxlfw[p]
//	sampleTripletLF[][1]=yylfw[p]
//	sampleTripletLF[][2]=zzlfw[p]
//	ImageInterpolate/RESL={(factor*dimsize(namew,0)),(factor*dimsize(namew,1))}/DEST=$outputLF voronoi sampleTripletLF
//end
///////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////
//Function p2dtopeak2(name)
//	string name
//	wave n=$name
//	variable xxx
//	xxx=dimsize(n,0)*dimsize(n,1)
//	make/o/N=(xxx) oneDtopo2
//	variable i,j,k
//	variable a,b
//	i=0
//	k=0
//	do
//		j=0
//		do
//			oneDtopo2[k]=n[i][j]
//			j+=1
//			k+=1
//		while(j<dimsize(n,1))
//		i+=1
//	while(i<dimsize(n,0))
//end
//////////////////////////////////////////////////////////////////////////////

//*****************************************************************************
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//************************ Jump Remover Version 1 *****************************
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
//****************************  Main Function  ********************************
///////////////////////////////////////////////////////////////////////////////
Function jump2pi(namew)
	wave namew
	variable i,j
	i=0
	do
		j=0
		do
		if(namew[i][j] < 0)
			namew[i][j]+=2*pi
		endif

		if(namew[i][j] > 5.81)
			namew[i][j]-=2*pi
		endif


			j+=1
		while(j<dimsize(namew,1))
		i+=1
	while(i< dimsize(namew,0))
end
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

Function jump2piY(namew)
	wave namew
	variable i,j
	i=1
	do
		j=1
		do
			if(namew[i][j] - namew[i][j-1] < pi) //|| namew[i][j] - namew[i-1][j] < pi)
				namew[i][j]+=2*pi
			endif


			if(namew[i][j] - namew[i][j-1] > pi) //|| namew[i][j] - namew[i-1][j] > pi)
				namew[i][j]-=2*pi
			endif

			j+=1
		while(j<dimsize(namew,1))
		i+=1
	while(i< dimsize(namew,0))

	j=1
	do
		if(namew[0][j]-namew[0][j-1] < pi) //|| namew[0][j]-namew[1][j] < pi)
			namew[0][j]+=2*pi
		endif

		if(namew[0][j]-namew[0][j-1] > pi) //|| namew[0][j]-namew[1][j] > pi)
			namew[0][j]-=2*pi
		endif
	j+=1
	while(j<dimsize(namew,1))


	i=1
	do
		if(namew[i][0]-namew[i-1][0] < pi) //|| namew[i][0]-namew[i][1] < pi)
			namew[i][0]+=2*pi
		endif

		if(namew[i][0]-namew[i-1][0] > pi) //|| namew[i][0]-namew[i][1] > pi)
			namew[i][0]-=2*pi
		endif
	i+=1
	while(j<dimsize(namew,0))

end

//////////////////////////////////////////////////////////////////////////////
Function jump2piX(namew)
	wave namew
	variable i,j
	i=1
	do
		j=1
		do
			if( namew[i][j] - namew[i-1][j] < pi)
				namew[i][j]+=2*pi
			endif


			if(namew[i][j] - namew[i-1][j] > pi)
				namew[i][j]-=2*pi
			endif

			j+=1
		while(j<dimsize(namew,1))
		i+=1
	while(i< dimsize(namew,0))

	j=1
	do
		if( namew[0][j]-namew[1][j] < pi)
			namew[0][j]+=2*pi
		endif

		if( namew[0][j]-namew[1][j] > pi)
			namew[0][j]-=2*pi
		endif
	j+=1
	while(j<dimsize(namew,1))


	i=1
	do
		if(namew[i][0]-namew[i-1][0] < pi) //|| namew[i][0]-namew[i][1] < pi)
			namew[i][0]+=2*pi
		endif

		if(namew[i][0]-namew[i-1][0] > pi) //|| namew[i][0]-namew[i][1] > pi)
			namew[i][0]-=2*pi
		endif
	i+=1
	while(j<dimsize(namew,0))

end


//#############################################################################
//************************ End Jump Remover Version 1 *************************
//#############################################################################
Function fflf(name)
	wave name
	func_NaN0(name)
	String FFTout
	FFTout = nameofWave(name) + "_FFT"
	FFT/out=1/WINF=Hanning/DEST=$FFTout cvtcmplx(name)
	Complextorealf1($FFTout,1)
	String FFToutm = FFTout+"_Modula"
	//di($FFToutm)
	twoDinterpolatexyflf(FFToutm,10*dimsize($FFTout,0),10*dimsize($FFTout,1))
end
Function twoDinterpolatexyflf(name,xpoint,ypoint)
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
	dilf($name2)
	color3slf($name2)
end

Function color3slf(name)
	wave name
	wavestats/Q name
	String namehist = nameofwave(name)+"_hist"
	Make/N=2000/O $namehist
	wave namehistw = $namehist
	Histogram/B={V_min,(V_max-V_min)/2000,2000} name,namehistw
	wavestats/Q namehistw


	K2 = V_maxloc;
	CurveFit/H="0010"/Q gauss namehistw /D
	string W_coef = "W_coef"
	wave W_coefw = $W_coef
	variable sigma = sqrt(2)*W_coefw[3]

	wavestats/Q name
	variable lc,lh
	if (W_coefw[2]-50*sigma >V_min)
		lc = W_coefw[2]-50*sigma
	else
		lc =V_min
	endif
	if (W_coefw[2]+50*sigma < V_max)
		lh = W_coefw[2]+50*sigma
	else
		lh =V_max
	endif

	ModifyImage $nameofwave(name) ctab= {lc,lh,VioletOrangeYellow,0}
	//PRINT num2str(W_coefw[2]-1.5*sigma)+" "+ num2str(W_coefw[2]+1.5*sigma)
	//print num2str(W_coefw[2])
	//display namehistw
end

/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
//   An interactive GUI to tune the Avedia for LF correction
//** you need to run LF normally before use this part
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_ConstLF(ctrlName) : ButtonControl
	String ctrlName
	Execute "ConstLF()"
End
Proc ConstLF()
	string inforwaveLF = "inforwaveLF_"+namefftraw
	variable/G avedia_LF = $inforwaveLF[0]
	variable/G condA_LF	= $inforwaveLF[2]
	variable/G factor_LF = $inforwaveLF[1]
	string dowin = namefftraw
	string nn = "LFInteractiveMultiWin"
	//Dowindow/F $grabwin(dowin)
	SetVariable setvar0 win = $nn, title="FWHM(r)",size={110,20},value=avedia_LF,proc=SetVarProc_ConstLF
	SetVariable setvar1 win = $nn, title="Cond",size={80,20},value=condA_LF,proc=SetVarProc_ConstLF,limits={1,inf,0.1}
	SetVariable setvar2 win = $nn, title="factor",size={80,20},value=factor_LF,proc=SetVarProc_ConstLF,limits={1,inf,1}

	Button turnoffls3d title="BACK",size={45,18},valueColor=(0,0,0),fColor=(1,65535,33232),proc=ButtonProc_lsturnoff3d,pos={1000,1}
	Button setvar3 title="Strain Analysis",proc=ButtonProc_Strainanalysisc,size={120,18},pos={878,1}

	//SetVariable setvar0 limits={0,dimsize($namefftraw,0)*dimdelta($namefftraw,0),dimsize($namefftraw,0)*dimdelta($namefftraw,0)/100}

	variable increment1 =(dimsize($namefftraw,0))*dimdelta($namefftraw,0)/20
	variable increment
	if (increment1 < 1 && increment1 > 0.1)
		increment=increment1+(round(increment1*10)-increment1*10)/10
	endif
	if(increment1<= 0.1)
		increment = 0.1
	endif
	if (increment1 >=1)
		increment = round(increment1)
	endif
	SetVariable setvar0 win = $nn, limits={0.01,inf,increment}
end
Function SetVarProc_ConstLF(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	execute "LawlerFujita2()"
End
Proc LawlerFujita2()
	variable avedia = avedia_LF
	variable condA = condA_LF //
	variable condB = condA_LF //
	String name = namefftraw  //	name,"Data name to manipulate"
	string inforwaveLF = "inforwaveLF_"+namefftraw
	$inforwaveLF[0] = avedia_LF
	$inforwaveLF[1] = factor_LF
	$inforwaveLF[2] = condA_LF
	$inforwaveLF[3] = condA_LF

	variable factor = factor_LF
	//** Get Q1 & Q2
		variable qx1
		variable qy1
		variable qx2
		variable qy2
		variable tpi = 2*pi
		string cpicka = name+"_QA"
		string cpickb = name+"_QB"
		qx1 = $cpicka[0]*tpi
		qy1 = $cpicka[1]*tpi
		qx2 = $cpickb[0]*tpi
		qy2 = $cpickb[1]*tpi


	//** Main Function
		LF(name,qx1,qy1,qx2,qy2,avedia,condA,condB,factor)

		string nn
		nn = grabwinchild(name)
		variable xrange = abs((dimsize($name, 0))*dimdelta($name, 0))
		variable xs = dimoffset($name, 0)+xrange -(Xrange*0.02+avedia)
		variable yrange = abs((dimsize($name, 1))*dimdelta($name, 1))
		//variable ys = dimoffset(nnw, 1)+(yrange*0.02)
		variable ys = yrange*0.02
		drawAction/W=$nn delete
		SetDrawEnv/W=$nn xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),dash= 7,linethick= 3.00,fillpat= 0;
		//DrawOval xs,ys,xs+avedia,ys+avedia
		DrawOval/W=$nn xs,dimoffset($name,1)+ys,xs+avedia,dimoffset($name,1)+ys+avedia

	//string dowin = namefftraw+"_ux"
	//Dowindow/F $grabwin(dowin)
	//** tile window
		//tilewindows/WINS=WinList("*", ";","WIN:3")/R/w=(4,0,66,100)
		//tilewindows/WINS=WinList("*", ";","WIN:3")/R/w=(3,0,59,100)
		//print "LawlerFujita("+num2str(avedia)+","+num2str(condA)+","+num2str(condB)+","+num2str(factor)+")"
		//Print ""

	 //** Draw figure of filtered partial FFT
		//String FFTimage = name+"_FFT_Modula_INTER"
		//nn = grabwinchild(FFTimage)

		//variable widthq=(2*sqrt(ln(2)))/avedia
		//ModifyGraph/W=$grabwin(fftdata) width={Plan,1,bottom,left},height=0
			//DrawAction/W=$nn delete
			//SetDrawEnv/W=$nn xcoord= bottom,ycoord= left,linefgc= (0,0,0),dash= 0,linethick= 1.00,fillpat= 0,linefgc= (65535,0,0)
			//DrawOval/W=$nn -2*sqrt(ln(2))*widthq/2,-2*sqrt(ln(2))*widthq/2,+2*sqrt(ln(2))*widthq/2,+2*sqrt(ln(2))*widthq/2
		//DrawAction delete
		//SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (0,0,0),dash= 0,linethick= 1.00,fillpat= 0,linefgc= (65535,0,0)
		//DrawOval -2*sqrt(ln(2))*widthq/2,-2*sqrt(ln(2))*widthq/2,+2*sqrt(ln(2))*widthq/2,+2*sqrt(ln(2))*widthq/2

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
Function Dosubwindisplay(name,avedia)
	string name
	variable avedia
	string tphase1 = name+"_phi_A"
	String jc1="jc_"+tphase1
	string namewr1 = tphase1+"_Corrected"

	string tphase2 = name+"_phi_B"
	String jc2="jc_"+tphase2
	string namewr2 = tphase2+"_Corrected"

	string ux =  name+"_ux"
	string uy =  name+"_uy"

	string padded = name+"ifft1c"
	String FFTimage = name+"_FFT_Modula_INTER"
	string outputLF = "LF_"+name

	Display/N=LFInteractiveMultiWin;modifygraph width=1000,height=800

		Display/HOST=#/W=(0,0.05,0.25,0.38);appendimage $name;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $name ctab= {*,*,VioletOrangeYellow,0}//;AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};ModifyGraph rgb=(65535,65535,65535)
		setActiveSubwindow ##;Display/HOST=#/W=(0.25,0.05,0.5,0.38);appendimage $outputLF;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $outputLF ctab= {*,*,VioletOrangeYellow,0}//;color3s_for3dmf($srcFFToutm,30);appendtograph q1nyw vs q1nxw;appendtograph q2nyw vs q2nxw;ModifyGraph mode=3,marker=8,rgb=(1,65535,33232),mrkThick=1,msize=4
		setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.05,0.75,0.38);appendimage $ux;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $ux ctab= {*,*,VioletOrangeYellow,0}//;color3s_for3dm($Se_outputLs,3,$src);//;color3s_for3dm($nameftd,3);AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {0, 0.5, 1};ModifyGraph rgb=(65535,65535,65535)
		setActiveSubwindow ##;Display/HOST=#/W=(0.75,0.05,1,0.38);appendimage $uy;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $uy ctab= {*,*,VioletOrangeYellow,0}//;color3s_for3dm($SeFFToutm,30,$srcFFToutm);appendtograph q1nyw vs q1nxw;appendtograph q2nyw vs q2nxw;ModifyGraph mode=3,marker=8,rgb=(1,65535,33232),mrkThick=0.5,msize=4//;color3s_for3dm($nameftd,3);AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {0, 0.5, 1};ModifyGraph rgb=(65535,65535,65535)

		setActiveSubwindow ##;Display/HOST=#/W=(0,0.35,0.25,0.68);appendimage $FFTimage;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_for3dmf($FFTimage,300)//ModifyImage $FFTimage ctab= {*,*,VioletOrangeYellow,0}
		setActiveSubwindow ##;Display/HOST=#/W=(0.25,0.35,0.5,0.68);appendimage $tphase1;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $tphase1 ctab= {*,*,VioletOrangeYellow,0}
		setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.35,0.75,0.68);appendimage $jc1;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $jc1 ctab= {*,*,VioletOrangeYellow,0}
		setActiveSubwindow ##;Display/HOST=#/W=(0.75,0.35,1,0.68);appendimage $namewr1;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $namewr1 ctab= {*,*,VioletOrangeYellow,0}

		setActiveSubwindow ##;Display/HOST=#/W=(0,0.66,0.25,1);appendimage $padded;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $padded ctab= {*,*,VioletOrangeYellow,0}
		setActiveSubwindow ##;Display/HOST=#/W=(0.25,0.66,0.5,1);appendimage $tphase2;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $tphase2 ctab= {*,*,VioletOrangeYellow,0}//color3s_for3dm($tphase2,3)
		setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.66,0.75,1);appendimage $jc2;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $jc2 ctab= {*,*,VioletOrangeYellow,0}//color3s_for3dm($jc2,3)
		setActiveSubwindow ##;Display/HOST=#/W=(0.75,0.66,1,1);appendimage $namewr2;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $namewr2 ctab= {*,*,VioletOrangeYellow,0}//color3s_for3dm($namewr2,3)

		setActiveSubwindow ##;modifygraph width=1050,height=800

		//** Draw window on FFT
		variable widthq=(2*sqrt(ln(2)))/avedia
		String wn = grabwinchild(FFTimage)
		SetDrawEnv/W=$wn xcoord= bottom,ycoord= left,linefgc= (0,0,0),dash= 0,linethick= 1.00,fillpat= 0,linefgc= (65535,0,0)
		DrawOval/W=$wn -2*sqrt(ln(2))*widthq/2,-2*sqrt(ln(2))*widthq/2,+2*sqrt(ln(2))*widthq/2,+2*sqrt(ln(2))*widthq/2
		string Fitq1x = name+"_getq1x"
		string Fitq1y = name+"_getq1y"
		appendtograph/W=$wn $Fitq1y vs $Fitq1x
		string Fitq2x = name+"_getq2x"
		string Fitq2y = name+"_getq2y"
		appendtograph/W=$wn $Fitq2y vs $Fitq2x
		ModifyGraph/W=$wn mode=3,marker=1,rgb=(0,0,65535), mrkThick=1


		//** Draw window on data
		wn = grabwinchild(name)
		variable xrange = abs((dimsize($name, 0))*dimdelta($name, 0))
		variable xs = dimoffset($name, 0)+xrange -(Xrange*0.02+avedia)
		variable yrange = abs((dimsize($name, 1))*dimdelta($name, 1))
		//variable ys = dimoffset(nnw, 1)+(yrange*0.02)
		variable ys = yrange*0.02
		SetDrawEnv/W=$wn xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),dash= 7,linethick= 3.00,fillpat= 0;
		DrawOval/W=$wn xs,dimoffset($name,1)+ys,xs+avedia,dimoffset($name,1)+ys+avedia




		TextBox/C/N=text0/F=0/A=LT/X=12/Y=4 "\Z16Raw Data"
		TextBox/C/N=text1/F=0/A=LT/X=32/Y=4 "\Z16Lawler-Fujita Correction"
		TextBox/C/N=text2/F=0/A=LT/X=64/Y=4 "\Z16u(x)"
		TextBox/C/N=text3/F=0/A=LT/X=89.5/Y=4 "\Z16u(y)"

		TextBox/C/N=text4/F=0/A=LT/X=14/Y=34 "\Z16FFT"
		TextBox/C/N=text5/F=0/A=LT/X=39/Y=34 "\\Z16\\$WMTEX$ \\theta_{A} \\$/WMTEX$"
 		TextBox/C/N=text6/F=0/A=LT/X=56.8/Y=34 "\\Z16\\$WMTEX$ \\theta_{A} \\$/WMTEX$ [jump compensation]"
		TextBox/C/N=text7/F=0/A=LT/X=86/Y=34 "\\Z16Corrected \\$WMTEX$ \\theta_{A} \\$/WMTEX$"

		TextBox/C/N=text8/F=0/A=LT/X=8/Y=64 "\Z16IFFT Before depad"
		TextBox/C/N=text9/F=0/A=LT/X=39/Y=64 "\\Z16\\$WMTEX$ \\theta_{B} \\$/WMTEX$"
 		TextBox/C/N=text10/F=0/A=LT/X=56.8/Y=64 "\\Z16\\$WMTEX$ \\theta_{B} \\$/WMTEX$ [jump compensation]"
		TextBox/C/N=text11/F=0/A=LT/X=86/Y=64 "\\Z16Corrected \\$WMTEX$ \\theta_{B} \\$/WMTEX$"

		TextBox/C/N=text12/F=0/A=MT/X=0/Y=0 name

		TextBox/C/N=text13/F=0/A=LT/X=5/Y=96  "\\Z16** FWHM =\\$WMTEX$ 2\\sqrt(2\\ln2\\) \\$/WMTEX$\\$WMTEX$ \\sigma \\$/WMTEX$"
		TextBox/C/N=text14/F=0/A=LT/X=65/Y=96   "\\Z16** Requirement for LF algorithm validity: \\$WMTEX$\frac{1}{\sigma} << Q_{Bragg} $/WMTEX$"
		tilewindows/WINS=winname(0,1)/R/w=(3,0,83,85)/A=(1,1)
end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                     The procedure for 2D lock-in technique
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_t2dlockin(ctrlName) : ButtonControl
	String ctrlName
	Execute "t2dlockin()"
End

Proc t2dlockin(avedia)
	variable avedia = dimsize($namefftraw,0)*dimdelta($namefftraw,0)/2
	prompt avedia,"The FWHM in real space (guassian window)"
	String name = namefftraw  //	name,"Data name to manipulate"
	variable/G
	//** Get Q1 & Q2
		variable qx1
		variable qy1
		variable qx2
		variable qy2
		variable tpi = 2*pi

		string cpicka = name+"_QA"
		string cpickb = name+"_QB"
		qx1 = $cpicka[0]*tpi
		qy1 = $cpicka[1]*tpi
		qx2 = $cpickb[0]*tpi
		qy2 = $cpickb[1]*tpi
		Print "*** QA = (2pi*"+num2str($cpicka[0])+",2pi*"+num2str($cpicka[1])+")"
		Print "*** QB = (2pi*"+num2str($cpickb[0])+",2pi*"+num2str($cpickb[1])+")"
		Print "*** Real space diameter (FWHM) is set to be "+num2str(avedia)+", as shown in the figure."


	//** Main Function
		lockinp(name,qx1,qy1,qx2,qy2,avedia)
		//LF(name,qx1=qx1,qy1=qy1,qx2=qx2,qy2=qy2,avedia=avedia,condA=condA,condB=condB,factor=factor)

	//** Draw Data Input and draw Guassian window
		//dilf($name)
		Dowindow/F $grabwin2(name)
		modifyphasetopo()

		//TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "Raw Data"
		Label left "Raw Data"
		variable xrange = abs((dimsize($name, 0))*dimdelta($name, 0))
		variable xs = dimoffset($name, 0)+xrange -(Xrange*0.02+avedia)
		variable yrange = abs((dimsize($name, 1))*dimdelta($name, 1))
		//variable ys = dimoffset(nnw, 1)+(yrange*0.02)
		variable ys = dimoffset($name, 1)+yrange*0.02
		SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),dash= 7,linethick= 3.00,fillpat= 0;
		DrawOval xs,ys,xs+avedia,ys+avedia

	//** tile window
		//tilewindows/WINS=WinList("*", ";","WIN:3")/R/w=(4,0,66,100)
		tilewindows/WINS=WinList("*", ";","WIN:1")/R/w=(3,0,83,85)/A=(2,3)
		print "t2dlockin("+num2str(avedia)+")"
		Print ""



    //** Draw figure of filtered partial FFT
		string fftdata = name+"_FFT_Modula_INTER"
		variable widthq=(2*sqrt(ln(2)))/avedia
		String wn =grabwin(fftdata)
		Dowindow/F $wn
		modifygraph width=250,height=250
		tilewindows/WINS=grabwin(tpw())/R/w=(82.5,0,100,20)/A=(1,1)
		//color3s($fftdata,30)
		TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "Filtered FFT(real,Q\BA\M)"
		ModifyGraph noLabel=2,axThick=0
		SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (0,0,0),dash= 0,linethick= 1.00,fillpat= 0,linefgc= (65535,65535,65535)
		DrawOval -2*sqrt(ln(2))*widthq/2,-2*sqrt(ln(2))*widthq/2,+2*sqrt(ln(2))*widthq/2,+2*sqrt(ln(2))*widthq/2

	//** Error message, no stop but Continuing execution
		String msg
		Variable err
		msg=GetErrMessage(GetRTError(0),3);
		err=GetRTError(1)
		if (err != 0)
			Print "Error in Demo: " + msg
			Print "Continuing execution"
		endif

	////////////////////////////////////////////////////////// waiting for modify later from adjust
		string inforwaveLF = "inforwavelockin_"+name
		make/o/N=3 $inforwaveLF
		$inforwaveLF[0] = avedia

		Const2dlockin()

end
end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////** Main Function
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function lockinp(name,qx1,qy1,qx2,qy2,avedia)
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




	//****Organized display
		dilf(tphase1w)
			TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "θ\BA"
			//cnfyj(tphase1w,condA*pi,2*pi)
			modifyphase()
		dilf(tphase2w)
			TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "θ\BB"
			//cnfyj(tphase2w,condB*pi,2*pi)
			modifyphase()
		dilf(Fmatw)
			TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "F\BA-B\M(r)"
			//cnfyj(tphase1w,condA*pi,2*pi)
			modifyphasefr()
		dilf(tamp1w)
			TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "|A\BQ\BA\M|(r)"
			//cnfyj(tphase1w,condA*pi,2*pi)
			modifyphasetopo()
		dilf(tamp2w)
			TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "|A\BQ\BB\M|(r)"
			//cnfyj(tphase1w,condA*pi,2*pi)
			modifyphasetopo()

end
///////////////////////////////////////////////////////////////////////////////////////////////

Function modifyphase()
	String wn =winname(0,1)
	ModifyGraph width=300,height=300
	ModifyGraph margin(right)=86;
	ColorScale/C/N=text0/A=LC/X=101/Y=0/F=0 frame=0.00,image=$tpw()
	ModifyImage $tpw() ctab= {*,*,RainbowCycle,0}
	Dowindow/F $wn
	drawAction delete
	variable lenx = (dimsize($tpw(),0)-1)*dimdelta($tpw(),0)
	variable leny = (dimsize($tpw(),1)-1)*dimdelta($tpw(),1)
	Dowindow/F $wn
	variable x1,x2,lenbar1,lenbar
	x1 = dimoffset($tpw(),0)+0.75*lenx
	lenbar1 = round(0.2*lenx)
	if(lenbar1 > 10)
		lenbar = lenbar1+(round(lenbar1/10)-lenbar1/10)*10
	else
		lenbar = lenbar1
	endif
	X2 = 0.75*lenx+lenbar+dimoffset($tpw(),0)

	SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),linethick= 4.00
	DrawLine x1,0.06*leny+dimoffset($tpw(),1),x2,0.06*leny+dimoffset($tpw(),1)


	ModifyGraph noLabel=2
	ModifyGraph axThick=0
	ModifyImage $tpw() ctab= {-pi,pi,RainbowCycle,0}
	string textv =num2str(round(lenbar))+" nm"
	SetDrawEnv xcoord= bottom,ycoord= left,textrgb= (65535,65535,65535),fstyle= 1,fsize= 20,textxjust= 1,textyjust= 1
	DrawText 0.85*lenx+dimoffset($tpw(),0),0.105*leny+dimoffset($tpw(),1),textv
end

Function modifyphasetopo()
	String wn =winname(0,1)
	ModifyGraph width=300,height=300
	ModifyGraph margin(right)=86;
	ColorScale/C/N=text0/A=LC/X=101/Y=0/F=0 frame=0.00,image=$tpw()
	ModifyImage $tpw() ctab= {*,*,VioletOrangeYellow,0}
	Dowindow/F $wn
	drawAction delete
	variable lenx = (dimsize($tpw(),0)-1)*dimdelta($tpw(),0)
	variable leny = (dimsize($tpw(),1)-1)*dimdelta($tpw(),1)
	Dowindow/F $wn
	variable x1,x2,lenbar1,lenbar
	x1 = dimoffset($tpw(),0)+0.75*lenx
	lenbar1 = round(0.2*lenx)
	if(lenbar1 > 10)
		lenbar = lenbar1+(round(lenbar1/10)-lenbar1/10)*10
	else
		lenbar = lenbar1
	endif
	X2 = 0.75*lenx+lenbar+dimoffset($tpw(),0)

	SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),linethick= 4.00
	DrawLine x1,0.06*leny+dimoffset($tpw(),1),x2,0.06*leny+dimoffset($tpw(),1)


	ModifyGraph noLabel=2
	ModifyGraph axThick=0

	string textv =num2str(round(lenbar))+" nm"
	SetDrawEnv xcoord= bottom,ycoord= left,textrgb= (65535,65535,65535),fstyle= 1,fsize= 20,textxjust= 1,textyjust= 1
	DrawText 0.85*lenx+dimoffset($tpw(),0),0.105*leny+dimoffset($tpw(),1),textv
	//color3s_for3d($tpw(),3)
end

Function modifyphasefr()
	String wn =winname(0,1)
	ModifyGraph width=300,height=300
	ModifyGraph margin(right)=86;
	ColorScale/C/N=text0/A=LC/X=101/Y=0/F=0 frame=0.00,image=$tpw()
	ModifyImage $tpw() ctab= {-1,1,:Packages:NewColortable:dvg_LKong3,0}
	Dowindow/F $wn
	drawAction delete
	variable lenx = (dimsize($tpw(),0)-1)*dimdelta($tpw(),0)
	variable leny = (dimsize($tpw(),1)-1)*dimdelta($tpw(),1)
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

	SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (0,0,0),linethick= 4.00
	DrawLine x1,0.06*leny+dimoffset($tpw(),1),x2,0.06*leny+dimoffset($tpw(),1)


	ModifyGraph noLabel=2
	ModifyGraph axThick=0

	string textv =num2str(round(lenbar))+" nm"
	SetDrawEnv xcoord= bottom,ycoord= left,textrgb= (0,0,0),fstyle= 1,fsize= 20,textxjust= 1,textyjust= 1
	DrawText 0.85*lenx+dimoffset($tpw(),0),0.105*leny+dimoffset($tpw(),1),textv
end


//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
// Interactive tuning
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//   continuely tuning 2D-lock-in avedia
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Const2dlockin(ctrlName) : ButtonControl
	String ctrlName
	Execute "Const2dlockin()"
End
Proc Const2dlockin()
	string inforwaveLF = "inforwavelockin_"+namefftraw
	variable/G avelockin_cons =$inforwaveLF[0]
	//Dowindow/F $grabwin(namefftraw)
	SetVariable setvaravedia win=$grabwin(namefftraw),title="FWHM(l)",size={100,20},value=avelockin_cons,proc=SetVarProc_Const2dlockin
	//SetVariable setvar5 pos={200,1}

	variable increment1 =(dimsize($namefftraw,0))*dimdelta($namefftraw,0)/20
	variable increment
	if (increment1 < 1 && increment1 > 0.1)
		increment=increment1+(round(increment1*10)-increment1*10)/10
	endif
	if(increment1<= 0.1)
		increment = 0.1
	endif
	if (increment1 >=1)
		increment = round(increment1)
	endif
	SetVariable setvaravedia win=$grabwin(namefftraw),limits={0,inf,increment}
end
Function SetVarProc_Const2dlockin(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	execute "Const2dlockinc()"
End
Proc Const2dlockinc()
	//string allname=WaveList("*", ";","WIN:")
	//variable num = itemsInList(WaveList("*", ";","WIN:"))
	//string name
	//variable i
	string name = namefftraw

	//** Get Q1 & Q2
		variable qx1
		variable qy1
		variable qx2
		variable qy2
		variable tpi = 2*pi

		string cpicka = name+"_QA"
		string cpickb = name+"_QB"
		qx1 = $cpicka[0]*tpi
		qy1 = $cpicka[1]*tpi
		qx2 = $cpickb[0]*tpi
		qy2 = $cpickb[1]*tpi

		lockinp2(name,qx1,qy1,qx2,qy2,avelockin_cons)

	//** Draw Data Input and draw Guassian window
		variable avedia = avelockin_cons
		DrawAction/W=$grabwin(name) delete
		variable xrange = abs((dimsize($name, 0))*dimdelta($name, 0))
		variable xs = dimoffset($name, 0)+xrange -(Xrange*0.02+avedia)
		variable yrange = abs((dimsize($name, 1))*dimdelta($name, 1))
		//variable ys = dimoffset(nnw, 1)+(yrange*0.02)
		variable ys = dimoffset($name, 1)+yrange*0.02
		SetDrawEnv/W=$grabwin(name) xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),dash= 7,linethick= 3.00,fillpat= 0;
		DrawOval/W=$grabwin(name) xs,ys,xs+avedia,ys+avedia

	 //** Draw figure of filtered partial FFT
		string fftdata = name+"_FFT_Modula_INTER"
		variable widthq=(2*sqrt(ln(2)))/avedia
		String wn =grabwin(fftdata)
		DrawAction/W=$grabwin(fftdata) delete
		//print grabwin(fftdata)
		SetDrawEnv/W=$grabwin(fftdata) xcoord= bottom,ycoord= left,linefgc= (0,0,0),dash= 0,linethick= 1.00,fillpat= 0,linefgc= (65535,65535,65535)
		DrawOval/W=$grabwin(fftdata) -2*sqrt(ln(2))*widthq/2,-2*sqrt(ln(2))*widthq/2,+2*sqrt(ln(2))*widthq/2,+2*sqrt(ln(2))*widthq/2



end
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//   End of continuely tuning line thickness on the graph
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function lockinp2(name,qx1,qy1,qx2,qy2,avedia)
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
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//*****************************************************************************
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//************************ LF correction for 3D wave **************************
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//*****************************************************************************
Function ButtonProc_LFtc(ctrlName) : ButtonControl
	String ctrlName
	Execute "LFtc()"
End
Proc LFtc(ind1,ind2,ind3,scrwave,XX,YY)
	string ind1 ="LF corrrect all Z slices of a 3D wave"
	string ind2 ="Find XX and YY wave first before start"
	string ind3 ="XX & YY usually extracted from Topo"
	string scrwave = stringfromlist(0,getall3dwave())
	string XX
	string YY
	Prompt ind1,"Tip #1"
	Prompt ind2,"Tip #2"
	Prompt ind3,"Tip #3"
	prompt scrwave,"The 3D wave"
	prompt XX,"LF XX wave"
	prompt XX,"LF YY wave"
	LFt($scrwave,$XX,$YY)
end

Function LFt(scrwave,XX,YY)
	wave scrwave
	wave XX
	wave YY

	string final="LF_"+nameofwave(scrwave)
	duplicate/o scrwave $final
	wave finalw = $final

	make/o/N=(dimsize(scrwave,0),dimsize(scrwave,1)) temp
	string outputLF = "outputLFall"
	variable i
	i=0
	do
		temp[][] =  finalw[p][q][i]
		duplicate/o temp temp1
		Redimension/N=(dimsize(temp,0)*dimsize(temp,1)) temp1

		Make/O/N=(dimsize(XX,0),3) sampleTripletLFall
		sampleTripletLFall[][0]=XX[p]
		sampleTripletLFall[][1]=YY[p]
		sampleTripletLFall[][2]=temp1[p]
		ImageInterpolate/RESL={(dimsize(scrwave,0)),(dimsize(scrwave,1))}/DEST=$outputLF voronoi sampleTripletLFall
		wave outputLFw = $outputLF
		//print mean(outputLFw)
		//func_nantonoise(outputLFw)
		finalw[][][i] = outputLFw[p][q]
		i+=1
	while (i < dimsize(scrwave,2))
	killwaves sampleTripletLFall temp temp1 outputLFw
end
Function func_nantonoise(matname)
	Wave matname
	Variable i,j
	i=0
	Do
		j=0
		Do
			if(mod(Round(matname[i][j]),1)!=0)
				matname[i][j]=0//gammaNoise(0.001)
			Endif
			j+=1
		While(j<dimsize(matname,1))
		i+=1
	While(i<dimsize(matname,0))
End

//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                     The procedure for New 2D lock-in and Filter together
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************
Function ButtonProc_t2dlockinandFilter(ctrlName) : ButtonControl
	String ctrlName
	Execute "t2dlockinandFilter()"
End
Proc t2dlockinandFilter(name,avedia,sel)
	String name = namefftraw
	variable avedia = dimsize($namefftraw,0)*dimdelta($namefftraw,0)/2
	variable sel = 2
	prompt name,"Matrix input; default is the matrix grabbed by \"Launch\""
	prompt avedia,"The FWHM in real space (guassian window)"
	prompt sel,"Which Q?",popup,"Global;Just Fitted"

	variable/G sel_t2dlkQglobal = sel

	variable/G
	//** Get Q1 & Q2
		variable qx1
		variable qy1
		variable qx2
		variable qy2
		variable tpi = 2*pi

		string cpicka
		string cpickb
		if (sel == 2)
			cpicka = name+"_QA"
			cpickb = name+"_QB"
		endif
		if (sel == 1)
			cpicka = "GlobalQA"
			cpickb = "GlobalQB"
		endif

		qx1 = $cpicka[0]*tpi
		qy1 = $cpicka[1]*tpi
		qx2 = $cpickb[0]*tpi
		qy2 = $cpickb[1]*tpi
		Print "*** QA = (2pi*"+num2str($cpicka[0])+",2pi*"+num2str($cpicka[1])+")"
		Print "*** QB = (2pi*"+num2str($cpickb[0])+",2pi*"+num2str($cpickb[1])+")"

		variable qax,qay,qbx,qby
		qax = $cpicka[0]
		qay = $cpicka[1]
		qbx = $cpickb[0]
		qby = $cpickb[1]
		lockinpnew(name,qx1,qy1,qx2,qy2,avedia)
		FTnew($name,avedia,qax,qay,qbx,qby)
		Dowindow2dlockinandfilter(name,avedia,qax,qay,qbx,qby)

		variable/G avedia_lckiftd = avedia
		variable/G qax_lckiftd = qax
		variable/G qay_lckiftd = qay
		variable/G qbx_lckiftd = qbx
		variable/G qby_lckiftd = qby
		Const2dlockinftd()
end

Function Const2dlockinftd()
	variable/G avedia_lckiftd
	variable/G qax_lckiftd
	variable/G qay_lckiftd
	variable/G qbx_lckiftd
	variable/G qby_lckiftd
	string/G namefftraw
	string subw = "TwoDlockinInteractiveMultiWin"
	SetVariable setvaravedia win=$subw,size={100,20},value=avedia_lckiftd,proc=SetVarProc_Const2dlockinftd,title="FWHM(L)",pos={52,40}
	//SetVariable setvar5 pos={200,1}
	variable increment1 =(dimsize($namefftraw,0))*dimdelta($namefftraw,0)/20
	variable increment
	if (increment1 < 1 && increment1 > 0.1)
		increment=increment1+(round(increment1*10)-increment1*10)/10
	endif
	if(increment1<= 0.1)
		increment = 0.1
	endif
	if (increment1 >=1)
		increment = round(increment1)
	endif
	SetVariable setvaravedia win=$subw,limits={0,inf,increment}

	SetVariable setvarqax win=$subw,size={100,20},value=qax_lckiftd,proc=SetVarProc_Const2dlockinftd,limits={-inf,inf,qax_lckiftd/200},title="Q\\BA\\M(x)",pos={346,865}
	SetVariable setvarqay win=$subw,size={100,20},value=qay_lckiftd,proc=SetVarProc_Const2dlockinftd,limits={-inf,inf,qax_lckiftd/200},title="Q\\BA\\M(y)",pos={456,786}
	SetVariable setvarqbx win=$subw,size={100,20},value=qbx_lckiftd,proc=SetVarProc_Const2dlockinftd,limits={-inf,inf,qax_lckiftd/200},title="Q\\BB\\M(x)",pos={623,865}
	SetVariable setvarqby win=$subw,size={100,20},value=qby_lckiftd,proc=SetVarProc_Const2dlockinftd,limits={-inf,inf,qax_lckiftd/200},title="Q\\BB\\M(y)",pos={745,786}
	Button saveq title="Save Q",fsize=10,size={50,12},proc=ButtonProc__SQConst2dlockinftd,pos={750,865}
	Button correctamp title="Correct Amp",fsize=10,size={100,12},proc=ButtonProc_Correct2Dlockinampcoutc,pos={750,2}
	Button turnoffls3d title="BACK",size={45,18},valueColor=(0,0,0),fColor=(1,65535,33232),pos={855,1},proc=ButtonProc_lsturnoff3d

	variable/G doLFcorrect = 0
	SetVariable setLF win=$subw, value=doLFcorrect,limits={0,1,1},title="Do \rLF?",size={50,14},pos={812,856},proc=SetVarProc_Const2dlockinftd2
end
Function ButtonProc__SQConst2dlockinftd(ctrlName) : ButtonControl
	String ctrlName
	variable/G qax_lckiftd
	variable/G qay_lckiftd
	variable/G qbx_lckiftd
	variable/G qby_lckiftd

	make/n=(2)/o GlobalQA
	make/n=(2)/o GlobalQB
	GlobalQA[0] = qax_lckiftd
	GlobalQA[1] = qay_lckiftd
	GlobalQB[0] = qbx_lckiftd
	GlobalQB[1] = qby_lckiftd
end
Function SetVarProc_Const2dlockinftd(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	execute "Const2dlockincftd()"

	Variable/G doLFcorrect
	variable/G avedia_lckiftd

	string/G namefftraw
	string 	outputLF = "LF_"+namefftraw

		variable qx1
		variable qy1
		variable qx2
		variable qy2
		variable tpi = 2*pi
		string cpicka = namefftraw+"_QA"
		string cpickb = namefftraw+"_QB"
		wave cpickaw = $cpicka
		wave cpickbw = $cpickb

		qx1 = cpickaw[0]*tpi
		qy1 = cpickaw[1]*tpi
		qx2 = cpickbw[0]*tpi
		qy2 = cpickbw[1]*tpi


	if (doLFcorrect == 1)
		LF(namefftraw,qx1,qy1,qx2,qy2,avedia_lckiftd,1,1,1)
		//di($outputLF)
	else
	endif

End

Proc Const2dlockincftd()
	variable/G avedia_lckiftd
	variable/G qax_lckiftd
	variable/G qay_lckiftd
	variable/G qbx_lckiftd
	variable/G qby_lckiftd
	string name = namefftraw

	lockinpnew(namefftraw,2*pi*qax_lckiftd,2*pi*qay_lckiftd,2*pi*qbx_lckiftd,2*pi*qby_lckiftd,avedia_lckiftd)
	FTnew($namefftraw,avedia_lckiftd,qax_lckiftd,qay_lckiftd,qbx_lckiftd,qby_lckiftd)

	//string indi_qax = "indi_qax"
	//string indi_qay = "indi_qay"
	//string indi_qbx = "indi_qbx"
	//string indi_qby = "indi_qby"

	indi_qax[0] = qax_lckiftd
	indi_qay[0] = qay_lckiftd
	indi_qbx[0] = qbx_lckiftd
	indi_qby[0] = qby_lckiftd

	string cpicka = name+"_QA"
	string cpickb = name+"_QB"
	$cpicka[0] = qax_lckiftd
	$cpicka[1] = qay_lckiftd
	$cpickb[0] = qbx_lckiftd
	$cpickb[1] = qby_lckiftd

	string get1x = name + "_getq1x"
	string get1y = name + "_getq1y"
	string get2x = name + "_getq2x"
	string get2y = name + "_getq2y"
	$get1x[0] = qax_lckiftd
	$get1y[0] = qay_lckiftd
	$get2x[0] = qbx_lckiftd
	$get2y[0] = qby_lckiftd


		variable avedia = avedia_lckiftd
		variable qax = qax_lckiftd
		variable qay = qay_lckiftd
		variable qbx = qbx_lckiftd
		variable qby = qby_lckiftd

		string subwinname = "TwoDlockinInteractiveMultiWin#G0"
		DrawAction/W=$subwinname delete
		variable xrange = abs((dimsize($name, 0))*dimdelta($name, 0))
		variable xs = dimoffset($name, 0)+xrange -(Xrange*0.02+avedia)
		variable yrange = abs((dimsize($name, 1))*dimdelta($name, 1))
		variable ys = dimoffset($name, 1)+yrange*0.02
		SetDrawEnv/W=$subwinname xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),dash= 7,linethick= 3.00,fillpat= 0;
		DrawOval/W=$subwinname xs,ys,xs+avedia,ys+avedia

		String wn2 ="TwoDlockinInteractiveMultiWin#G9"
		variable widtha = (2*sqrt(ln(2)))/avedia
		variable widthb = (2*sqrt(ln(2)))/avedia
		DrawAction/W=$wn2 delete
		SetDrawEnv/W=$wn2 xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),dash= 7,linethick= 1.00,fillpat= 0;
		variable qax1,qay1,qax2,qay2,qamx1,qamy1,qamx2,qamy2
		variable qbx1,qby1,qbx2,qby2,qbmx1,qbmy1,qbmx2,qbmy2
		qax1 = qax-2*sqrt(ln(2))*widtha/2
		qay1 = qay-2*sqrt(ln(2))*widtha/2
		qax2 = qax+2*sqrt(ln(2))*widtha/2
		qay2 = qay+2*sqrt(ln(2))*widtha/2

		qamx1 = -qax-2*sqrt(ln(2))*widtha/2
		qamy1 = -qay-2*sqrt(ln(2))*widtha/2
		qamx2 = -qax+2*sqrt(ln(2))*widtha/2
		qamy2 = -qay+2*sqrt(ln(2))*widtha/2

		qbx1 = qbx-2*sqrt(ln(2))*widtha/2
		qby1 = qby-2*sqrt(ln(2))*widtha/2
		qbx2 = qbx+2*sqrt(ln(2))*widtha/2
		qby2 = qby+2*sqrt(ln(2))*widtha/2

		qbmx1 = -qbx-2*sqrt(ln(2))*widtha/2
		qbmy1 = -qby-2*sqrt(ln(2))*widtha/2
		qbmx2 = -qbx+2*sqrt(ln(2))*widtha/2
		qbmy2 = -qby+2*sqrt(ln(2))*widtha/2
		DrawOval/W=$wn2 qax1,qay1,qax2,qay2
		SetDrawEnv/W=$wn2 xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),dash= 7,linethick= 1.00,fillpat= 0;
		DrawOval/W=$wn2 qamx1,qamy1,qamx2,qamy2
		SetDrawEnv/W=$wn2 xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),dash= 7,linethick= 1.00,fillpat= 0;
		DrawOval/W=$wn2 qbx1,qby1,qbx2,qby2
		SetDrawEnv/W=$wn2 xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),dash= 7,linethick= 1.00,fillpat= 0;
		DrawOval/W=$wn2 qbmx1,qbmy1,qbmx2,qbmy2
end


Function Dowindow2dlockinandfilter(name,avedia,qax,qay,qbx,qby)
	string name
	variable avedia,qax,qay,qbx,qby

	string tphase2,tamp2
	tphase2 = name+"_phi_B"
	tamp2 = name+"_amp_B"

	string tphase1,tamp1
	tphase1 = name+"_phi_A"
	tamp1 = name+"_amp_A"

	String Fmat = name+"_Fr"

	string nn1 = name+"_ftdQAQB"
	string nn2 = name+"_ftdQA"
	string nn3 = name+"_ftdQB"
	string fftdata = name+"_FFT_Modula_INTER"

	string ffttemp1 = "ffttemp1"

	Display/N=TwoDlockinInteractiveMultiWin;modifygraph width=900,height=900
	tilewindows/WINS=winname(0,1)/R/A=(1,1)/w=(3,0,50,100)
	Display/HOST=#/W=(0,0.05,0.33,0.33);appendimage $name;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "\Z16Raw(r)";modifyphasetoponew()//ModifyImage $name ctab= {*,*,VioletOrangeYellow,0}//;AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};ModifyGraph rgb=(65535,65535,65535)
		setActiveSubwindow ##;Display/HOST=#/W=(0.31,0.05,0.64,0.33);appendimage $tamp1;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "\Z16|A\BQ\BA\M\Z16|(r)";modifyphasetoponew()
		setActiveSubwindow ##;Display/HOST=#/W=(0.63,0.05,0.96,0.33);appendimage $tamp2;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "\Z16|A\BQ\BB\M\Z16|(r)";modifyphasetoponew()//ModifyImage $ux ctab= {*,*,VioletOrangeYellow,0}//;color3s_for3dm($Se_outputLs,3,$src);//;color3s_for3dm($nameftd,3);AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {0, 0.5, 1};ModifyGraph rgb=(65535,65535,65535)

		setActiveSubwindow ##;Display/HOST=#/W=(0,0.3,0.33,0.58);appendimage $Fmat;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "\Z16F\BA-B\M\Z16(r)";modifyphasefrnew()
		setActiveSubwindow ##;Display/HOST=#/W=(0.31,0.3,0.64,0.58);appendimage $tphase1;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "\\Z16\\$WMTEX$ \theta_{(Q_{A})}(r) \\$/WMTEX$";modifyphasenew()//ModifyImage $tphase1 ctab= {*,*,VioletOrangeYellow,0}
		setActiveSubwindow ##;Display/HOST=#/W=(0.63,0.3,0.96,0.58);appendimage $tphase2;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "\\Z16\\$WMTEX$ \theta_{(Q_{B})}(r) \\$/WMTEX$";modifyphasenew()//ModifyImage $jc1 ctab= {*,*,VioletOrangeYellow,0}

		setActiveSubwindow ##;Display/HOST=#/W=(0,0.55,0.33,0.83);appendimage $nn1;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "\\Z16\\$WMTEX$ Raw_{(Q_{A},Q_{B})}(r) \\$/WMTEX$";modifyphasetoponew()//ModifyImage $padded ctab= {*,*,VioletOrangeYellow,0}
		setActiveSubwindow ##;Display/HOST=#/W=(0.31,0.55,0.64,0.83);appendimage $nn2;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "\\Z16\\$WMTEX$ Raw_{(Q_{A})}(r) \\$/WMTEX$";modifyphasetoponew()//ModifyImage $tphase2 ctab= {*,*,VioletOrangeYellow,0}//color3s_for3dm($tphase2,3)
		setActiveSubwindow ##;Display/HOST=#/W=(0.63,0.55,0.96,0.83);appendimage $nn3;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "\\Z16\\$WMTEX$ Raw_{(Q_{B})}(r) \\$/WMTEX$";modifyphasetoponew()//ModifyImage $jc2 ctab= {*,*,VioletOrangeYellow,0}//color3s_for3dm($jc2,3)

		setActiveSubwindow ##;Display/HOST=#/W=(0,0.8,0.2,1);appendimage $fftdata;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;color3s_for3dmf($fftdata,300)//ModifyImage $padded ctab= {*,*,VioletOrangeYellow,0}
		setActiveSubwindow ##;Display/HOST=#/W=(0.2,0.8,0.4,1);appendimage $ffttemp1;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $ffttemp1 ctab= {*,*,VioletOrangeYellow,1}//color3s_for3dmf($ffttemp1,300)//ModifyImage $padded ctab= {*,*,VioletOrangeYellow,0}

		setActiveSubwindow ##;Display/HOST=#/W=(0.3,0.8,0.5,1);appendimage $ffttemp1;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $ffttemp1 ctab= {*,*,VioletOrangeYellow,1}//ModifyImage $padded ctab= {*,*,VioletOrangeYellow,0}
		SetAxis bottom qax-0.2*abs(sqrt(qax^2+qay^2)),qax+0.2*abs(sqrt(qax^2+qay^2))
		SetAxis left qay-0.2*abs(sqrt(qax^2+qay^2)),qay+0.2*abs(sqrt(qax^2+qay^2))

		setActiveSubwindow ##;Display/HOST=#/W=(0.6,0.8,0.8,1);appendimage $ffttemp1;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;ModifyImage $ffttemp1 ctab= {*,*,VioletOrangeYellow,1}
		SetAxis bottom qbx-0.2*abs(sqrt(qbx^2+qby^2)),qbx+0.2*abs(sqrt(qbx^2+qby^2))
		SetAxis left qby-0.2*abs(sqrt(qbx^2+qby^2)),qby+0.2*abs(sqrt(qbx^2+qby^2))
		//print qbx-0.2*abs(sqrt(qbx^2+qby^2)),qbx+0.2*abs(sqrt(qbx^2+qby^2)),qby-0.2*abs(sqrt(qbx^2+qby^2)),qby+0.2*abs(sqrt(qbx^2+qby^2))

		setActiveSubwindow ##
		String wn3 ="TwoDlockinInteractiveMultiWin#G11"
		String wn4 ="TwoDlockinInteractiveMultiWin#G12"

		make/N=1/o indi_qax,indi_qay,indi_qbx,indi_qby
		indi_qax = qax
		indi_qay = qay
		indi_qbx = qbx
		indi_qby = qby
		appendtograph/W=$wn3 indi_qay vs indi_qax;ModifyGraph/W=$wn3 mode=3,marker=1,msize=5,mrkThick=2
		appendtograph/W=$wn4 indi_qby vs indi_qbx;ModifyGraph/W=$wn4 mode=3,marker=1,msize=5,mrkThick=2



		//** Draw real space window on Raw data
		string subwinname = "TwoDlockinInteractiveMultiWin#G0"
		variable xrange = abs((dimsize($name, 0))*dimdelta($name, 0))
		variable xs = dimoffset($name, 0)+xrange -(Xrange*0.02+avedia)
		variable yrange = abs((dimsize($name, 1))*dimdelta($name, 1))
		variable ys = dimoffset($name, 1)+yrange*0.02
		SetDrawEnv/W=$subwinname xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),dash= 7,linethick= 3.00,fillpat= 0;
		DrawOval/W=$subwinname xs,ys,xs+avedia,ys+avedia

		//** Draw FFT space window
		String wn2 ="TwoDlockinInteractiveMultiWin#G9"
		//variable widthq=(2*sqrt(ln(2)))/avedia
		//SetDrawEnv/W=$wn2 xcoord= bottom,ycoord= left,linefgc= (0,0,0),dash= 0,linethick= 1.00,fillpat= 0,linefgc= (65535,65535,65535)
		//DrawOval/W=$wn2 -2*sqrt(ln(2))*widthq/2,-2*sqrt(ln(2))*widthq/2,+2*sqrt(ln(2))*widthq/2,+2*sqrt(ln(2))*widthq/2
		variable widtha = (2*sqrt(ln(2)))/avedia
		variable widthb = (2*sqrt(ln(2)))/avedia
		SetDrawEnv/W=$wn2 xcoord= bottom,ycoord= left,linefgc= (0,0,65535),dash= 7,linethick= 1.00,fillpat= 0;
		variable qax1,qay1,qax2,qay2,qamx1,qamy1,qamx2,qamy2
		variable qbx1,qby1,qbx2,qby2,qbmx1,qbmy1,qbmx2,qbmy2
		qax1 = qax-2*sqrt(ln(2))*widtha/2
		qay1 = qay-2*sqrt(ln(2))*widtha/2
		qax2 = qax+2*sqrt(ln(2))*widtha/2
		qay2 = qay+2*sqrt(ln(2))*widtha/2

		qamx1 = -qax-2*sqrt(ln(2))*widtha/2
		qamy1 = -qay-2*sqrt(ln(2))*widtha/2
		qamx2 = -qax+2*sqrt(ln(2))*widtha/2
		qamy2 = -qay+2*sqrt(ln(2))*widtha/2

		qbx1 = qbx-2*sqrt(ln(2))*widtha/2
		qby1 = qby-2*sqrt(ln(2))*widtha/2
		qbx2 = qbx+2*sqrt(ln(2))*widtha/2
		qby2 = qby+2*sqrt(ln(2))*widtha/2

		qbmx1 = -qbx-2*sqrt(ln(2))*widtha/2
		qbmy1 = -qby-2*sqrt(ln(2))*widtha/2
		qbmx2 = -qbx+2*sqrt(ln(2))*widtha/2
		qbmy2 = -qby+2*sqrt(ln(2))*widtha/2
		DrawOval/W=$wn2 qax1,qay1,qax2,qay2
		SetDrawEnv/W=$wn2 xcoord= bottom,ycoord= left,linefgc= (0,0,65535),dash= 7,linethick= 1.00,fillpat= 0;
		DrawOval/W=$wn2 qamx1,qamy1,qamx2,qamy2
		SetDrawEnv/W=$wn2 xcoord= bottom,ycoord= left,linefgc= (0,0,65535),dash= 7,linethick= 1.00,fillpat= 0;
		DrawOval/W=$wn2 qbx1,qby1,qbx2,qby2
		SetDrawEnv/W=$wn2 xcoord= bottom,ycoord= left,linefgc= (0,0,65535),dash= 7,linethick= 1.00,fillpat= 0;
		DrawOval/W=$wn2 qbmx1,qbmy1,qbmx2,qbmy2

		String wn ="TwoDlockinInteractiveMultiWin#G10"
		TextBox/W=$wn/C/N=text0/F=0/X=0.00/Y=0.00 "Filtered FFT"
		SetDrawEnv/W=$wn xcoord= bottom,ycoord= left;DelayUpdate
		DrawText/W=$wn 1.2*qax,1.2*qay,"Q\\BA"
		SetDrawEnv/W=$wn xcoord= bottom,ycoord= left;DelayUpdate
		DrawText/W=$wn 1.2*qbx,1.2*qby,"Q\\BB"


		TextBox/W=$"TwoDlockinInteractiveMultiWin"/C/N=text0/F=0/A=MT/X=0/Y=1 "2D Lock-in and IFFT Filter: "+name
		TextBox/W=$"TwoDlockinInteractiveMultiWin"/C/N=text1/F=0/A=MT/X=-6/Y=80 "\Z12Q\BA\M\Z12 (Pad x3 FFT)"
		TextBox/W=$"TwoDlockinInteractiveMultiWin"/C/N=text2/F=0/A=MT/X=25/Y=80 "\Z12Q\BB\M\Z12 (Pad x3 FFT)"
		TextBox/W=$"TwoDlockinInteractiveMultiWin"/C/N=text3/F=0/A=LT/X=5/Y=96  "\\Z16** FWHM =\\$WMTEX$ 2\\sqrt(2\\ln2\\) \\$/WMTEX$\\$WMTEX$ \\sigma \\$/WMTEX$"
end

Function FTnew(name,avedia,qax,qay,qbx,qby)
	wave name
	variable avedia,qax,qay,qbx,qby

	variable widtha = (2*sqrt(ln(2)))/avedia
	variable widthb = (2*sqrt(ln(2)))/avedia
	string namefft = nameofwave(name)+"_padFFT"
	String nameffti = namefft+"i"
	string npd=nameffti+"_up"

	//** Do Pad FFT (complex)
		FFT/PAD={3*dimsize(name,0),3*dimsize(name,1)}/OUT=1/DEST=$namefft name;

	//** Apply filter and DO IFFT (real)
		Duplicate/C/o $namefft ffttemp1 //** QA & QB
		Duplicate/C/o $namefft ffttemp2 //** QA
		Duplicate/C/o $namefft ffttemp3 //** QB

		//FTD for both QA and QB
			ffttemp1*=(sqrt(pi)*widtha)^(-1)*exp(-((x-qax)^2+(y-qay)^2)/(widtha^2))+(sqrt(pi)*widthb)^(-1)*exp(-((x-qbx)^2+(y-qby)^2)/(widthb^2))
			IFFT/DEST=$nameffti  ffttemp1;
			unpadding(nameofwave(name),$nameffti)
			string nn1 = nameofwave(name)+"_ftdQAQB"
			duplicate/o $npd $nn1

		//FTD for both QA
			ffttemp2*=(sqrt(pi)*widtha)^(-1)*exp(-((x-qax)^2+(y-qay)^2)/(widtha^2))//+(sqrt(pi)*widthb)^(-1)*exp(-((x-qbx)^2+(y-qby)^2)/(widthb^2))
			IFFT/DEST=$nameffti  ffttemp2;
			unpadding(nameofwave(name),$nameffti)
			string nn2 = nameofwave(name)+"_ftdQA"
			duplicate/o $npd $nn2

		//FTD for both QB
			ffttemp3*=(sqrt(pi)*widthb)^(-1)*exp(-((x-qbx)^2+(y-qby)^2)/(widthb^2))
			IFFT/DEST=$nameffti  ffttemp3;
			unpadding(nameofwave(name),$nameffti)
			string nn3 = nameofwave(name)+"_ftdQB"
			duplicate/o $npd $nn3

	killwaves $npd ffttemp2 ffttemp3 $namefft

	//string inforwaveLF = "inforwavefilter_"+nameofwave(name)
	//make/o/N=1 $inforwaveLF
	//wave inforwaveLFw = $inforwaveLF
	//inforwaveLFw[0] = avedia

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

Function lockinpnew(name,qx1,qy1,qx2,qy2,avedia)
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

Function modifyphasenew()
	String wn =winname(0,1)
	//ModifyGraph width=300,height=300
	//ModifyGraph margin(right)=86;
	ColorScale/C/N=text0/A=LC/X=101/Y=0/F=0 frame=0.00,image=$tpw()
	ModifyImage $tpw() ctab= {*,*,RainbowCycle,0}
	Dowindow/F $wn
	drawAction delete
	variable lenx = (dimsize($tpw(),0)-1)*dimdelta($tpw(),0)
	variable leny = (dimsize($tpw(),1)-1)*dimdelta($tpw(),1)
	Dowindow/F $wn
	variable x1,x2,lenbar1,lenbar
	x1 = dimoffset($tpw(),0)+0.75*lenx
	lenbar1 = round(0.2*lenx)
	if(lenbar1 > 10)
		lenbar = lenbar1+(round(lenbar1/10)-lenbar1/10)*10
	else
		lenbar = lenbar1
	endif
	X2 = 0.75*lenx+lenbar+dimoffset($tpw(),0)

	SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),linethick= 4.00
	DrawLine x1,0.06*leny+dimoffset($tpw(),1),x2,0.06*leny+dimoffset($tpw(),1)


	ModifyGraph noLabel=2
	ModifyGraph axThick=0
	ModifyImage $tpw() ctab= {-pi,pi,RainbowCycle,0}
	string textv =num2str(round(lenbar))+" Å"
	SetDrawEnv xcoord= bottom,ycoord= left,textrgb= (65535,65535,65535),fstyle= 1,fsize= 15,textxjust= 1,textyjust= 1
	DrawText 0.85*lenx+dimoffset($tpw(),0),0.105*leny+dimoffset($tpw(),1),textv
end

Function modifyphasetoponew()
	String wn =winname(0,1)
	//ModifyGraph width=300,height=300
	//ModifyGraph margin(right)=86;
	ColorScale/C/N=text0/A=LC/X=101/Y=0/F=0 frame=0.00,image=$tpw()
	ModifyImage $tpw() ctab= {*,*,VioletOrangeYellow,0}
	Dowindow/F $wn
	drawAction delete
	variable lenx = (dimsize($tpw(),0)-1)*dimdelta($tpw(),0)
	variable leny = (dimsize($tpw(),1)-1)*dimdelta($tpw(),1)
	Dowindow/F $wn
	variable x1,x2,lenbar1,lenbar
	x1 = dimoffset($tpw(),0)+0.75*lenx
	lenbar1 = round(0.2*lenx)
	if(lenbar1 > 10)
		lenbar = lenbar1+(round(lenbar1/10)-lenbar1/10)*10
	else
		lenbar = lenbar1
	endif
	X2 = 0.75*lenx+lenbar+dimoffset($tpw(),0)

	SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),linethick= 4.00
	DrawLine x1,0.06*leny+dimoffset($tpw(),1),x2,0.06*leny+dimoffset($tpw(),1)


	ModifyGraph noLabel=2
	ModifyGraph axThick=0

	string textv =num2str(round(lenbar))+" Å"
	SetDrawEnv xcoord= bottom,ycoord= left,textrgb= (65535,65535,65535),fstyle= 1,fsize= 15,textxjust= 1,textyjust= 1
	DrawText 0.85*lenx+dimoffset($tpw(),0),0.105*leny+dimoffset($tpw(),1),textv
	//color3s_for3d($tpw(),3)
end

Function modifyphasefrnew()
	String wn =winname(0,1)
	//ModifyGraph width=300,height=300
	//ModifyGraph margin(right)=86;
	ColorScale/C/N=text0/A=LC/X=101/Y=0/F=0 frame=0.00,image=$tpw()
	ModifyImage $tpw() ctab= {-1,1,:Packages:NewColortable:dvg_LKong3,0}
	Dowindow/F $wn
	drawAction delete
	variable lenx = (dimsize($tpw(),0)-1)*dimdelta($tpw(),0)
	variable leny = (dimsize($tpw(),1)-1)*dimdelta($tpw(),1)
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

	SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (0,0,0),linethick= 4.00
	DrawLine x1,0.06*leny+dimoffset($tpw(),1),x2,0.06*leny+dimoffset($tpw(),1)


	ModifyGraph noLabel=2
	ModifyGraph axThick=0

	string textv =num2str(round(lenbar))+" Å"
	SetDrawEnv xcoord= bottom,ycoord= left,textrgb= (0,0,0),fstyle= 1,fsize= 15,textxjust= 1,textyjust= 1
	DrawText 0.85*lenx+dimoffset($tpw(),0),0.105*leny+dimoffset($tpw(),1),textv
end
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//****** Moving window reference Convert 2D lock-in amp to be absolute *********
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Correct2Dlockinampcoutc(ctrlName) : ButtonControl
	String ctrlName
	Execute "Correct2Dlockinampcout()"
End

Proc Correct2Dlockinampcout()
	string scr
	variable angle
	variable windowsize

	scr = namefftraw

		//** Get Q1 & Q2
		string cpicka
		string cpickb
		if (sel_t2dlkQglobal == 2)
			cpicka = scr+"_QA"
			cpickb = scr+"_QB"
		endif
		if (sel_t2dlkQglobal == 1)
			cpicka = "GlobalQA"
			cpickb = "GlobalQB"
		endif

		variable qax,qay,qbx,qby
		qax = $cpicka[0]
		qay = $cpicka[1]
		qbx = $cpickb[0]
		qby = $cpickb[1]

		angle = atan2(qay,qax)*180/pi
		windowsize = 1/(sqrt(qax^2+qay^2))
		//print angle, windowsize

	Correct2Dlockinampc("","",scr,angle,windowsize)
end

Function ButtonProc_Correct2DlockinampcoutInd(ctrlName) : ButtonControl
	String ctrlName
	Execute "Correct2Dlockinampc()"
End
Proc Correct2Dlockinampc(ind,ind2,scr,angle,windowsize)
	string ind = "Convert relative amplitude to absolute"
	String Ind2 = "Run 2D-lock-in before this Proc"
	string scr = namefftraw
	variable angle
	variable windowsize = 3.8
	prompt ind,"Indication"
	prompt ind2,"Indication"
	prompt scr,"Name of gap map"
	prompt angle,"angle of QA (°)"
	prompt windowsize,"window size (Usually it equal to lamda)"

	string lockinphaseA = scr+"_amp_A"
	string lockinphaseB = scr+"_amp_B"

	Correct2Dlockinamp($scr,angle,windowsize)

	string lockA = lockinphaseA+"_C"
	string lockB = lockinphaseB+"_C"

	string ABratio = scr+"_ABRatio"
	string ABratioabs = scr+"_ABRabs"


	display/N=t2Dlockinampcorrection;modifygraph width=570,height=550*3/2
	tilewindows/WINS=winname(0,1)/R/A=(1,1)/w=(62.5,0,100,100)
	Display/HOST=#/W=(0,0.05*3/4,0.5,0.3*3/4)//;appendimage phasehalf;ModifyGraph mirror=2;ModifyImage phasehalf ctab= {-3.14,3.14,RainbowCycle,0};ModifyGraph width={Plan,1,bottom,left};ColorScale/C/N=text0/F=0/B=1/A=RC/X=-20.00/Y=0.00 image=phasehalf;ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;ColorScale/C/N=text0 frame=0.00//;Label bottom "\\Z16X          \t \t\t\t\t\t\t\t\tΓ\t\t\t\t\t\t\t\t\t          X"
		string histn1 = "Hist_"+"ampabs_QA"
		appendtograph $histn1
		ModifyGraph rgb=(0,0,0)
		ModifyGraph mode=5
		Label left "\\Z15Probability (%)"
		ModifyGraph mirror=2
		ModifyGraph tick=2
		ModifyGraph noLabel=0,axThick=2


	setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.05*3/4,1,0.3*3/4)//;appendimage phasesingle;ModifyGraph mirror=2;ModifyImage phasesingle ctab= {-3.14,3.14,RainbowCycle,0};ModifyGraph width={Plan,1,bottom,left};ColorScale/C/N=text0/F=0/B=1/A=RC/X=-20.00/Y=0.00 image=phasesingle;ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;ColorScale/C/N=text0 frame=0.00//;Label bottom "\\Z16M          \t \t\t\t\t\t\t\t\tΓ\t\t\t\t\t\t\t\t\t          M"
		string histn2 = "Hist_"+"ampabs_QB"
		appendtograph $histn2
		ModifyGraph rgb=(0,0,0)
		ModifyGraph mode=5
		Label left "\\Z15Probability (%)"
		ModifyGraph mirror=2
		ModifyGraph tick=2
		ModifyGraph noLabel=0,axThick=2

	setActiveSubwindow ##;Display/HOST=#/W=(0,0.3*3/4,0.5,0.55*3/4)//;appendimage amphalf;ModifyGraph mirror=2;ModifyImage amphalf ctab= {*,*,VioletOrangeYellow,0};ModifyGraph width={Plan,1,bottom,left};ColorScale/C/N=text0/F=0/B=1/A=RC/X=-22.5/Y=0.00 image=amphalf;ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;ColorScale/C/N=text0 frame=0.00//;Label bottom "\\Z16M          \t \t\t\t\t\t\t\t\tΓ\t\t\t\t\t\t\t\t\t          M"
		string histn3 = "Hist_"+lockinphaseA
		appendtograph $histn3
		ModifyGraph rgb=(0,0,0)
		ModifyGraph mode=5
		Label left "\\Z15Probability (%)"
		ModifyGraph mirror=2
		ModifyGraph tick=2
		ModifyGraph noLabel=0,axThick=2


	setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.3*3/4,1,0.55*3/4)//;appendimage ampsingle;ModifyGraph mirror=2;ModifyImage ampsingle ctab= {*,*,VioletOrangeYellow,0};ModifyGraph width={Plan,1,bottom,left};ColorScale/C/N=text0/F=0/B=1/A=RC/X=-22.5/Y=0.00 image=ampsingle;ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;ColorScale/C/N=text0 frame=0.00//;Label bottom "\\Z16M          \t \t\t\t\t\t\t\t\tΓ\t\t\t\t\t\t\t\t\t          M"
		string histn4 = "Hist_"+lockinphaseB
		appendtograph $histn4
		ModifyGraph rgb=(0,0,0)
		ModifyGraph mode=5
		Label left "\\Z15Probability (%)"
		ModifyGraph mirror=2
		ModifyGraph tick=2
		ModifyGraph noLabel=0,axThick=2



	setActiveSubwindow ##;Display/HOST=#/W=(0,0.42,0.3,0.72);appendimage $lockA;ModifyGraph mirror=2;ModifyImage $lockA ctab= {*,*,VioletOrangeYellow,0};ModifyGraph width={Plan,1,bottom,left};modifyphasetoponew()//ColorScale/C/N=text0/F=0/B=1/A=RC/X=-20.00/Y=0.00 ctab= {*,*,VioletOrangeYellow,0};ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;ColorScale/C/N=text0 frame=0.00//;Label bottom "\\Z16X
	setActiveSubwindow ##;Display/HOST=#/W=(0.45,0.42,0.75,0.72);appendimage $lockB;ModifyGraph mirror=2;ModifyImage $lockB ctab= {*,*,VioletOrangeYellow,0};ModifyGraph width={Plan,1,bottom,left};modifyphasetoponew()//ColorScale/C/N=text0/F=0/B=1/A=RC/X=-20.00/Y=0.00 ctab= {*,*,VioletOrangeYellow,0};ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;ColorScale/C/N=text0 frame=0.00//;Label bottom "\\Z16X

	setActiveSubwindow ##;Display/HOST=#/W=(0,0.7,0.3,1);appendimage $ABratio;ModifyGraph mirror=2;ModifyGraph width={Plan,1,bottom,left};modifyphasenew();ModifyImage $ABratio ctab= {-1,1,root:Packages:NewColortable:dvg_seismic,1}//;ModifyImage $ABratio ctab= {*,*,VioletOrangeYellow,0};ColorScale/C/N=text0/F=0/B=1/A=RC/X=-20.00/Y=0.00 ctab= {*,*,VioletOrangeYellow,0};ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;ColorScale/C/N=text0 frame=0.00//;Label bottom "\\Z16X
	setActiveSubwindow ##;Display/HOST=#/W=(0.45,0.7,0.75,1);appendimage $ABratioabs;ModifyGraph mirror=2;ModifyImage $ABratioabs ctab= {*,*,VioletOrangeYellow,0};ModifyGraph width={Plan,1,bottom,left};modifyphasetoponew()//ColorScale/C/N=text0/F=0/B=1/A=RC/X=-20.00/Y=0.00 ctab= {*,*,VioletOrangeYellow,0};ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;ColorScale/C/N=text0 frame=0.00//;Label bottom "\\Z16X



	setActiveSubwindow ##;

	TextBox/C/N=text0/F=0/A=LT/B=1/X=12/Y=2 "\\Z16\\$WMTEX$  |A_{Q_{A}}|\\$/WMTEX$ [Moving window]"
	TextBox/C/N=text1/F=0/A=LT/B=1/X=62/Y=2 "\\Z16\\$WMTEX$  |A_{Q_{B}}|\\$/WMTEX$ [Moving window]"
	TextBox/C/N=text2/F=0/A=LT/B=1/X=16/Y=20.8 "\\Z16\\$WMTEX$  |A_{Q_{A}}|\\$/WMTEX$ [2D lock-in]"
	TextBox/C/N=text3/F=0/A=LT/B=1/X=66/Y=20.8 "\\Z16\\$WMTEX$  |A_{Q_{B}}|\\$/WMTEX$ [2D lock-in]"

	TextBox/C/N=text4/F=0/A=LT/B=1/X=13/Y=41 "\\Z16\\$WMTEX$  |A_{Q_{A}}|(r)\\$/WMTEX$ [value Corrt.]"
	TextBox/C/N=text5/F=0/A=LT/B=1/X=57.5/Y=41 "\\Z16\\$WMTEX$  |A_{Q_{B}}|(r)\\$/WMTEX$ [value Corrt.]"

	TextBox/C/N=text6/F=0/A=LT/B=1/X=21/Y=67.5  "\\Z16\\$WMTEX$  \frac{|A_{Q_{A}}|-|A_{Q_{B}}|}{|A_{Q_{A}}|+|A_{Q_{B}}|}\\$/WMTEX$ "
	TextBox/C/N=text7/F=0/A=LT/B=1/X=65.5/Y=67.5 "\\Z16\\$WMTEX$  |\frac{|A_{Q_{A}}|-|A_{Q_{B}}|}{|A_{Q_{A}}|+|A_{Q_{B}}|}| $/WMTEX$"

	TextBox/C/N=text8/F=0/A=LT/B=1/X=31.00/Y=24.00 "\\$WMTEX$ C_{A_{Q_{A}}} \\$/WMTEX$ = "+num2str(A_convert)
	TextBox/C/N=text9/F=0/A=LT/B=1/X=80.00/Y=24.00 "\\$WMTEX$ C_{A_{Q_{B}}} \\$/WMTEX$ = "+num2str(B_convert)
	TextBox/C/N=text10/F=0/B=1/A=MB/X=0.00/Y=0.00 "\\Z18 Domain: Imbalance between \\$WMTEX$ |A_{Q_{A}}|,|A_{Q_{B}}| \\$/WMTEX$"

	wavestats/Q $lockA
	variable/G colormin_ampabs = V_min
	variable/G colormax_ampabs = V_max
	SetVariable setCmin size={100,20},value=colormin_ampabs,proc=SetVarProc_Const2dlockininampabs,limits={-inf,inf,(V_max-V_min)/50},title="C_Min",pos={240,556}
	SetVariable setCmax size={100,20},value=colormax_ampabs,proc=SetVarProc_Const2dlockininampabs,limits={-inf,inf,(V_max-V_min)/50},title="C_Max",pos={240,572}
	Button turnoffls3d title="BACK",size={45,18},valueColor=(0,0,0),fColor=(1,65535,33232),pos={520,1},proc=ButtonProc_lsturnoff3d
	ckfig_child(winname(0,1))
end

Function SetVarProc_Const2dlockininampabs(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/G colormin_ampabs
	variable/G colormax_ampabs
	string/G namefftraw

	string lockA = namefftraw+"_amp_A_C"
	string lockB = namefftraw+"_amp_B_C"
	ModifyImage/W=t2Dlockinampcorrection#G4 $lockA ctab= {colormin_ampabs,colormax_ampabs,VioletOrangeYellow,0}
	ModifyImage/W=t2Dlockinampcorrection#G5 $lockB ctab= {colormin_ampabs,colormax_ampabs,VioletOrangeYellow,0}
End


Function Correct2Dlockinamp(scr,angle,windowsize)
	wave scr
	variable angle
	variable windowsize

	String ampabs_LH = "ampabs_LH"

	//** QA
		variable angleA = angle
		getabsamp(scr,angleA,windowsize)
		wave ampabs_LHw = $ampabs_LH
		duplicate/o ampabs_LHw ampabs_QA
		variable QA_absamp_mean = mean(ampabs_QA)/2

	//** QB
		variable angleB = angle-90
		getabsamp(scr,angleB,windowsize)
		wave ampabs_LHw = $ampabs_LH
		duplicate/o ampabs_LHw ampabs_QB
		variable QB_absamp_mean = mean(ampabs_QB)/2

	gethistgram_absamp("ampabs_QA")
	gethistgram_absamp("ampabs_QB")

	string lockinphaseA = nameofwave(scr)+"_amp_A"
	string lockinphaseB = nameofwave(scr)+"_amp_B"
	gethistgram_absamp(lockinphaseA)
	gethistgram_absamp(lockinphaseB)

	wave lockinphaseAw = $lockinphaseA
	wave lockinphaseBw = $lockinphaseB

	string lockA = lockinphaseA+"_C"
	string lockB = lockinphaseB+"_C"
	duplicate/o lockinphaseAw $lockA
	duplicate/o lockinphaseBw $lockB
	wave lockAw = $lockA
	wave lockBw = $lockB

	variable/G A_convert = (QA_absamp_mean/mean(lockinphaseAw))
	variable/G B_convert = (QB_absamp_mean/mean(lockinphaseBw))

	//lockAw *= A_convert
	//lockBw *= B_convert

	variable ave_convert = (A_convert+B_convert)/2
	lockAw *= ave_convert
	lockBw *= ave_convert

	string ABratio = nameofwave(scr)+"_ABRatio"
	string ABratioabs = nameofwave(scr)+"_ABRabs"
	duplicate/o lockAw $ABratio
	duplicate/o lockAw $ABratioabs
	wave ABratiow = $ABratio
	wave ABratioabsw = $ABratioabs
	ABratiow = (lockAw - lockBw)/(lockAw + lockBw)
	ABratioabsw = abs(ABratiow)
end


Function gethistgram_absamp(name)
	string name
	string histn = "Hist_"+name
	make/o/N=1000 $histn
	wavestats/Q $name
	variable Vmax = V_max
	Variable Vmin = V_min
	variable mdian = median($name)
	Histogram/B={(mdian-(Vmax-Vmin)/2),(V_max-V_min)/1000,1000} $name,$histn
	duplicate/o $histn fithttemp
	CurveFit/Q gauss, $histn/D=fithttemp
	killwaves fithttemp
	string W_coef="W_coef"
	wave W_coefw = $W_coef
	variable coverratio //(0,1]
	coverratio = (2*5*W_coefw[3])/(Vmax-Vmin)
	Histogram/B={(mdian-coverratio*(Vmax-Vmin)/2),coverratio*(V_max-V_min)/200,200} $name,$histn

	wave histnw = $histn
	variable sumhis=sum($histn)
	histnw/=sumhis
	histnw*=100

	//dichis($histn)
	//CurveFit/Q gauss, $histn/D//=fithttemp
	//TextBox/C/N=text0 "X0 = "+num2str(W_coefw[2])+"\rσ = "+num2str(W_coefw[3]/sqrt(2))+"\rFWHM = "+num2str(2*sqrt(ln(2))*W_coefw[3])

	Return coverratio
end

////////////////////////////////////////////////////////////////////////
//** Moving window Procedure to extract correct amplitude
////////////////////////////////////////////////////////////////////////
Function getabsamp(scr,angle,windowsize)
	wave scr
	variable angle
	variable windowsize

	//** Make Temp 3D wave
		//(The reason owing to I adopt from a 3D wave procedure, and too lazy to reduce the dimension)
		string temp3d = nameofWave(scr)+"_3dtemp"
		make/N=(dimsize(scr,0),dimsize(scr,1),1)/o $temp3d
		setscale/p x,dimoffset(scr,0),dimdelta(scr,0),"",$temp3d
		setscale/p y,dimoffset(scr,1),dimdelta(scr,1),"",$temp3d
		wave temp3dw = $temp3d
		temp3dw[][][0] = scr[p][q]

		//%% temp3d == mat3dn_cons
		//%% angle == angle_3dplot
		//%% Zn_cons == 2

	//** Given angle, get X and Y offset range, limits={addY_3dplot_L,addY_3dplot_H,1}
		duplicate/o findrangeforangle_LH(nameofwave(temp3dw),angle,2) absamp_rotateYlimits
		variable addY_3dplot_H = absamp_rotateYlimits[1]
		variable addY_3dplot_L = absamp_rotateYlimits[0]

		//duplicate/o findrangeforangle_LV(nameofwave(temp3dw),angle,2) absamp_rotateXlimits
		//variable addX_3dplot_H  =  absamp_rotateXlimits[1]
		//variable addX_3dplot_L  =  absamp_rotateXlimits[0]


	//** Quantity
		variable winnum,i,j,dif
		make/n=0/o ampabs_LH
		//make/n=0/o ampabs_LV

	//** For H linecut (The line along angle direction)
		string linecutH_absamp="linecutH_absamp"
		variable addY
		addY = addY_3dplot_L
		do
			anglelinecutH_absamp(temp3d,angle,2,addY)
			wave linecutH_absampw = $linecutH_absamp

			winnum = round(windowsize/dimdelta(linecutH_absampw,1))

			i=0
			do
				make/N=(winnum)/o windiwLH_absamp
				//windiwLH_absamp =0.23
				//** make window wave
				j=0
				do
					if(i+j > dimsize(linecutH_absampw,1)-1)
						windiwLH_absamp[j] = nan
					else
						windiwLH_absamp[j] = linecutH_absampw[0][i+j]
					endif
					j+=1
				while (j<winnum)


				wavestats/Q windiwLH_absamp
				dif = abs(V_max-V_min)
				InsertPoints dimsize(ampabs_LH,0),1, ampabs_LH
				ampabs_LH[dimsize(ampabs_LH,0)-1] = dif

				i+=1
			while(i < dimsize(linecutH_absampw,1))//-winnum)
			addY+=1
		while(addY<addY_3dplot_H+1)
		removezerop(ampabs_LH)
		//print  "The amplitude along LH direction is " +num2str(mean(ampabs_LH)/2)
		//print  "The amplitude along LH direction is " +num2str(meanexceptzero(ampabs_LH)/2)

	killwaves temp3dw windiwLH_absamp absamp_rotateYlimits
end

Function meanexceptzero(name)
	wave name
	variable i,count,sumn,meann
	i=0
	count =0
	sumn=0
	do
		if (name[i] == 0)
		else
			sumn+=name[i]
			count+=1
		endif
		i+=1
	while (i<dimsize(name,0))
	meann = sumn/count
	return meann
end

Function removezerop(name)
	wave name
	variable i
	i=0

	make/n=0/o nametempremove0
	do
		if (name[i] == 0)
		else
			InsertPoints dimsize(nametempremove0,0),1, nametempremove0
			nametempremove0[dimsize(nametempremove0,0)-1] = name[i]

		endif
		i+=1
	while (i<dimsize(name,0))

	duplicate/o nametempremove0 $nameofwave(name)
	killwaves nametempremove0
end

Function anglelinecutH_absamp(mat,angle,Zn,addY)
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
		duplicate/o $linecutH linecutH_absamp
		killwaves $linecutH
end

Function anglelinecutV_absamp(mat,angle,Zn,addX)
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

		duplicate/o $linecutV linecutV_absamp
		killwaves $linecutV
end

Function SetVarProc_Const2dlockinftd2(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	Variable/G doLFcorrect
	variable/G avedia_lckiftd

	string/G namefftraw
	string 	outputLF = "LF_"+namefftraw

		variable qx1
		variable qy1
		variable qx2
		variable qy2
		variable tpi = 2*pi
		string cpicka = namefftraw+"_QA"
		string cpickb = namefftraw+"_QB"
		wave cpickaw = $cpicka
		wave cpickbw = $cpickb

		qx1 = cpickaw[0]*tpi
		qy1 = cpickaw[1]*tpi
		qx2 = cpickbw[0]*tpi
		qy2 = cpickbw[1]*tpi


	if (doLFcorrect == 1)
		LF(namefftraw,qx1,qy1,qx2,qy2,avedia_lckiftd,1,1,1)
		di($outputLF)
		modifygraph width=500,height=500
	endif
end

//******************************************************************************************************
//******************************************************************************************************
//## STRAIN ANALYSIS
//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************
Function ButtonProc_Strainanalysisc(ctrlName) : ButtonControl
	String ctrlName
	Execute "Strainanalysisc()"
end
Proc Strainanalysisc(uxt,uyt,order,mothername,selqmode)
	string uxt = namefftraw+"_ux"
	string uyt = namefftraw+"_uy"
	variable order = 2
	string mothername = namefftraw
	variable selqmode = 2
	prompt uxt,"name of the displacement matrix ux"
	prompt uyt,"name of the displacement matrix uy"
	prompt order,"Polynimal order for BKremove"
	prompt mothername,"name of the topography"
	prompt selqmode,"Which Q?",popup,"Global;Just Fitted"


		//** Get Q1
		variable qx1
		variable qy1

		string/G namefftraw
		string cpicka
		if (selqmode == 2) // just fitted when do lauch
			cpicka = namefftraw+"_QA"
		endif
		if (selqmode == 1) // Global Q saved
			cpicka = "GlobalQA"
		endif
		qx1 = $cpicka[0]*2*pi
		qy1 = $cpicka[1]*2*pi

	//** Lattice angle get
		//# Se-Se lattice on topo
			variable theta = atan2(qy1,qx1)*180/pi // extract from the QA [Launch the FFT engineering or Global saved value]
			variable/G theta_lattice = theta


	//prompt frame2ornot,"Calculate the 45˚ frame",popup,"No,Yes"

	Strainanalysis($uxt,$uyt,order,mothername,selqmode,1,theta)

	// Leveled raw displacement matrix
		string ulevelx = uxt + "_level"
		string ulevely = uyt + "_level"


	// Displacement matrix projected to Se-Se lattice
		string uthetax = ulevelx+"_theta"
		string uthetay = ulevely+"_theta"


	// Displacement matrix projected to Fe-Fe lattice
		string uthetax45 = ulevelx+"_theta45"
		string uthetay45 = ulevely+"_theta45"


	//** Strain matrix along Se-Se (x/y) or Fe-Fe (a/b)
		String elpxx, elpxy, elpyx, elpyy, elpaa, elpab, elpba, elpbb
		elpxx = mothername+"_elpson_xx"
		elpxy = mothername+"_elpson_xy"
		elpyx = mothername+"_elpson_yx"
		elpyy = mothername+"_elpson_yy"
		elpaa = mothername+"_elpson_aa"
		elpab = mothername+"_elpson_ab"
		elpba = mothername+"_elpson_ba"
		elpbb = mothername+"_elpson_bb"


		string xB1g,xA1g, aB1g, aA1g
		xB1g = mothername+"_x_B1g"
		xA1g = mothername+"_x_A1g"
		aB1g = mothername+"_a_B1g"
		aA1g = mothername+"_a_A1g"


	variable x1,x2,y1,y2
	x1=dimoffset($uxt,0)
	x2=dimoffset($uxt,0)+dimdelta($uxt,0)*(dimsize($uxt,0)-1)
	y1=dimoffset($uxt,1)
	y2=dimoffset($uxt,1)+dimdelta($uxt,1)*(dimsize($uxt,1)-1)


	//ColorScale/C/N=text0 notation=1,lblLatPos=-62,lblMargin=66,lblRot=90;ColorScale/C/N=text0 "(%)"

	Display/N=StrainanalysismultiWin;modifygraph width=1450,height=900

		//Row #1
		Display/HOST=#/W=(0,0.05,0.16,0.3)
		appendimage $elpxx;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;
		TextBox/C/N=text1/F=0/A=MT/X=0.00/Y=-10 "\\Z12\\$WMTEX$  \\epsilon_{xx} = \\partial[\\delta u_{x}(r)]/\\partial x\\$/WMTEX$"
		mdg_strain1(74,1)
		SetAxis bottom x1,x2;SetAxis left y1,y2
		ColorScale/C/N=text0 notation=1

		setActiveSubwindow ##;//Display/HOST=#/W=(0.25,0.05,0.5,0.38);
		Display/HOST=#/W=(0.16,0.05,0.32,0.3);
		appendimage $uthetax;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;
		TextBox/C/N=text1/F=0/A=MT/X=0.00/Y=-10 "\\Z12\\$WMTEX$ \\delta u_{x}(r) \\$/WMTEX$: Se-Se (\\$WMTEX$ x/y \\$/WMTEX$)"
		mdg_strain1(97,0)
		SetAxis bottom x1,x2;SetAxis left y1,y2

		setActiveSubwindow ##;//Display/HOST=#/W=(0.5,0.05,0.75,0.38);
		Display/HOST=#/W=(0.32,0.05,0.48,0.3);
		appendimage $uxt;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;
		TextBox/C/N=text1/F=0/A=MT/X=0.00/Y=-10 "\\Z12\\$WMTEX$ \\ u_{L_{X}}(r) \\$/WMTEX$: Image (\\$WMTEX$ L_{X}/L_{Y} \\$/WMTEX$)"
		mdg_strain1(105,0)
		SetAxis bottom x1,x2;SetAxis left y1,y2

		setActiveSubwindow ##;
		Display/HOST=#/W=(0.48,0.05,0.64,0.3);
		appendimage $ulevelx;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;
		TextBox/C/N=text1/F=0/A=MT/X=0.00/Y=-10 "\\Z12\\$WMTEX$ \\ \\delta u_{L_{X}}(r) \\$/WMTEX$: Image (\\$WMTEX$ L_{X}/L_{Y} \\$/WMTEX$)"
		mdg_strain1(105,0)
		SetAxis bottom x1,x2;SetAxis left y1,y2


		setActiveSubwindow ##;
		Display/HOST=#/W=(0.64,0.05,0.8,0.3);
		appendimage $uthetax45;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;
		TextBox/C/N=text1/F=0/A=MT/X=0.00/Y=-10 "\\Z12\\$WMTEX$ \\delta u_{a}(r) \\$/WMTEX$: Fe-Fe (\\$WMTEX$ a/b \\$/WMTEX$)"
		mdg_strain1(97,0)
		SetAxis bottom x1,x2;SetAxis left y1,y2

		setActiveSubwindow ##;
		Display/HOST=#/W=(0.8,0.05,0.96,0.3);
		appendimage $elpaa;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;
		TextBox/C/N=text1/F=0/A=MT/X=0.00/Y=-10 "\\Z12\\$WMTEX$  \\epsilon_{aa} = \\partial[\\delta u_{a}(r)]/\\partial a\\$/WMTEX$"
		mdg_strain1(74,1)
		SetAxis bottom x1,x2;SetAxis left y1,y2
		ColorScale/C/N=text0 notation=1


		//Row #2
		setActiveSubwindow ##;
		Display/HOST=#/W=(0,0.28,0.16,0.53)
		appendimage $elpyy;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;
		TextBox/C/N=text1/F=0/A=MT/X=0.00/Y=-10 "\\Z12\\$WMTEX$  \\epsilon_{yy} = \\partial[\\delta u_{y}(r)]/\\partial y\\$/WMTEX$"
		mdg_strain1(74,1)
		SetAxis bottom x1,x2;SetAxis left y1,y2
		ColorScale/C/N=text0 notation=1

		setActiveSubwindow ##;
		Display/HOST=#/W=(0.16,0.28,0.32,0.53);
		appendimage $uthetay;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;
		TextBox/C/N=text1/F=0/A=MT/X=0.00/Y=-10 "\\Z12\\$WMTEX$ \\delta u_{y}(r) \\$/WMTEX$: Se-Se (\\$WMTEX$ x/y \\$/WMTEX$)"
		mdg_strain1(97,0)
		SetAxis bottom x1,x2;SetAxis left y1,y2

		setActiveSubwindow ##;
		Display/HOST=#/W=(0.32,0.28,0.48,0.53);
		appendimage $uyt;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;
		TextBox/C/N=text1/F=0/A=MT/X=0.00/Y=-10 "\\Z12\\$WMTEX$ \\ u_{L_{Y}}(r) \\$/WMTEX$: Image (\\$WMTEX$ L_{X}/L_{Y} \\$/WMTEX$)"
		mdg_strain1(105,0)
		SetAxis bottom x1,x2;SetAxis left y1,y2


		setActiveSubwindow ##;
		Display/HOST=#/W=(0.48,0.28,0.64,0.53);
		appendimage $ulevely;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;
		TextBox/C/N=text1/F=0/A=MT/X=0.00/Y=-10 "\\Z12\\$WMTEX$ \\ \\delta u_{L_{Y}}(r) \\$/WMTEX$: Image (\\$WMTEX$ L_{X}/L_{Y} \\$/WMTEX$)"
		mdg_strain1(105,0)
		SetAxis bottom x1,x2;SetAxis left y1,y2

		setActiveSubwindow ##;
		Display/HOST=#/W=(0.64,0.28,0.8,0.53);
		appendimage $uthetay45;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;
		TextBox/C/N=text1/F=0/A=MT/X=0.00/Y=-10 "\\Z12\\$WMTEX$ \\delta u_{b}(r) \\$/WMTEX$: Fe-Fe (\\$WMTEX$ a/b \\$/WMTEX$)"
		mdg_strain1(97,0)
		SetAxis bottom x1,x2;SetAxis left y1,y2

		setActiveSubwindow ##;
		Display/HOST=#/W=(0.8,0.28,0.96,0.53);
		appendimage $elpbb;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;
		TextBox/C/N=text1/F=0/A=MT/X=0.00/Y=-10 "\\Z12\\$WMTEX$  \\epsilon_{bb} = \\partial[\\delta u_{b}(r)]/\\partial b\\$/WMTEX$"
		mdg_strain1(74,1)
		SetAxis bottom x1,x2;SetAxis left y1,y2
		ColorScale/C/N=text0 notation=1


		//Row #3
		setActiveSubwindow ##;
		Display/HOST=#/W=(0,0.51,0.16,0.76)
		appendimage $elpxy;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;
		TextBox/C/N=text1/F=0/A=MT/X=0.00/Y=-13 "\\Z12\\$WMTEX$  \\epsilon_{xy} = \\frac{1}{2}\\left\{ \\frac{\\partial [\delta u_{x}(r)]}{\\partial y} + \\frac{\\partial [\delta u_{y}(r)]}{\\partial x}       \\right\} \\$/WMTEX$: \\$WMTEX$ B_{2g}^{Se} \\$/WMTEX$"
		mdg_strain1(21,1)
		SetAxis bottom x1,x2;SetAxis left y1,y2
		ColorScale/C/N=text0 notation=1

		setActiveSubwindow ##;
		Display/HOST=#/W=(0.16,0.51,0.32,0.76);
		appendimage $xB1g;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;
		TextBox/C/N=text1/F=0/A=MT/X=0.00/Y=-10 "\\Z12\\$WMTEX$   U_{Se} =   \\frac{1}{2}(\\epsilon_{xx}-\\epsilon_{yy}) \\$/WMTEX$: \\$WMTEX$ B^{Se}_{1g} \\$/WMTEX$"
		mdg_strain1(24,1)
		SetAxis bottom x1,x2;SetAxis left y1,y2
		ColorScale/C/N=text0 notation=1

		setActiveSubwindow ##;
		Display/HOST=#/W=(0.32,0.51,0.48,0.76);
		appendimage $xA1g;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;
		TextBox/C/N=text1/F=0/A=MT/X=0.00/Y=-10 "\\Z12\\$WMTEX$   C_{Se} =   \\frac{1}{2}(\\epsilon_{xx}+\\epsilon_{yy}) \\$/WMTEX$: \\$WMTEX$ A^{Se}_{1g} \\$/WMTEX$"
		mdg_strain1(19,1)
		SetAxis bottom x1,x2;SetAxis left y1,y2
		ColorScale/C/N=text0 notation=1

		setActiveSubwindow ##;
		Display/HOST=#/W=(0.48,0.51,0.64,0.76);
		appendimage $aA1g;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;
		TextBox/C/N=text1/F=0/A=MT/X=0.00/Y=-10 "\\Z12\\$WMTEX$   C_{Fe} =   \\frac{1}{2}(\\epsilon_{aa}+\\epsilon_{bb}) \\$/WMTEX$: \\$WMTEX$ A^{Fe}_{1g} \\$/WMTEX$"
		mdg_strain1(19,1)
		SetAxis bottom x1,x2;SetAxis left y1,y2
		ColorScale/C/N=text0 notation=1

		setActiveSubwindow ##;
		Display/HOST=#/W=(0.64,0.51,0.8,0.76);
		appendimage $aB1g;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;
		TextBox/C/N=text1/F=0/A=MT/X=0.00/Y=-10 "\\Z12\\$WMTEX$   U_{Fe} =   \\frac{1}{2}(\\epsilon_{aa}-\\epsilon_{bb}) \\$/WMTEX$: \\$WMTEX$ B^{Fe}_{1g} \\$/WMTEX$"
		mdg_strain1(21,1)
		SetAxis bottom x1,x2;SetAxis left y1,y2
		ColorScale/C/N=text0 notation=1

		setActiveSubwindow ##;
		Display/HOST=#/W=(0.8,0.51,0.96,0.76);
		appendimage $elpab;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;
		TextBox/C/N=text1/F=0/A=MT/X=0.00/Y=-13 "\\Z12\\$WMTEX$  \\epsilon_{ab} = \\frac{1}{2}\\left\{ \\frac{\\partial [\delta u_{a}(r)]}{\\partial b} + \\frac{\\partial [\delta u_{b}(r)]}{\\partial a}       \\right\} \\$/WMTEX$: \\$WMTEX$ B_{2g}^{Fe} \\$/WMTEX$"
		mdg_strain1(24,1)
		SetAxis bottom x1,x2;SetAxis left y1,y2
		ColorScale/C/N=text0 notation=1


		string dxy, dx2my2, dx2py2
		dxy = mothername+"_B2g_angle"
		dx2my2 = mothername+"_B1g_angle"
		dx2py2 = mothername+"_A1g_angle"
		make/n=90/o $dxy,$dx2my2,$dx2py2
		setscale/i x, 0.5-theta_lattice,89.5-theta_lattice,"",$dxy,$dx2my2,$dx2py2

		//Row #4
		setActiveSubwindow ##;
		Display/HOST=#/W=(0,0.74,0.32,0.99)
		appendtograph $dxy,$dx2my2,$dx2py2
		ModifyGraph manTick(bottom)={0,45,0,0},manMinor(bottom)={0,50}
		ModifyGraph grid(bottom)=2,gridHair(bottom)=1
		ModifyGraph mode=4,marker=8,msize=6,mrkThick=3,rgb($dxy)=(0,0,65535),rgb($dx2py2)=(0,0,0),mirror=2
		TextBox/C/N=text0/J/F=0/A=MT/X=0.00/Y=0.00 "\\Z12\r \\K(0,0,65535)\\$WMTEX$ \\left|\\epsilon(B_{2g})\\right|_{max}\\$/WMTEX$: \\$WMTEX$ d_{xy} \\$/WMTEX$";DelayUpdate
		AppendText/N=text0 " \\K(65535,0,0)\\$WMTEX$ \\left|\\epsilon(B_{1g})\\right|_{max}\\$/WMTEX$: \\$WMTEX$ d_{x^{2}-y^{2}} \\$/WMTEX$";DelayUpdate
		AppendText/N=text0 "\\K(0,0,0) \\$WMTEX$ \\left|\\epsilon(A_{1g})\\right|_{max}\\$/WMTEX$: \\$WMTEX$ s_{x^{2}+y^{2}} \\$/WMTEX$"
		Label bottom "\\Z12\\$WMTEX$ \\theta-\\theta_{Se-Se} \\$/WMTEX$ (º)"

		make/o/n=2 indicator_strainana
		variable t1,t2,t3,b1,b2,b3
		wavestats/Q $dxy
		t1 = V_max
		b1 = V_min
		wavestats/Q $dx2my2
		t2 = V_max
		b2 = V_min
		wavestats/Q $dx2py2
		t3 = V_max
		b3 = V_min
		variable t,b
		t = max(t1,t2,t3,b1,b2,b3)
		b = min(t1,t2,t3,b1,b2,b3)
		setscale/i x, t,b,"",indicator_strainana
		indicator_strainana = theta-theta
		Appendtograph/VERT indicator_strainana
		ModifyGraph lstyle(indicator_strainana)=9,lsize(indicator_strainana)=3,rgb(indicator_strainana)=(1,52428,26586)

		//setActiveSubwindow ##;
		//Display/HOST=#/W=(0.16,0.74,0.32,0.99);

		setActiveSubwindow ##;
		Display/HOST=#/W=(0.32,0.74,0.48,0.99);
		TextBox/C/N=text0/F=0/A=MC/X=10.00/Y=0.00 "\\Z16\\$WMTEX$ A_{1g}^{Se} = A_{1g}^{Fe}   \\$/WMTEX$\r\r\\$WMTEX$ B_{1g}^{Se} = B_{2g}^{Fe}   \\$/WMTEX$\r";DelayUpdate
		AppendText "\\$WMTEX$ B_{2g}^{Se} = -B_{1g}^{Fe}   \\$/WMTEX$"


		//setActiveSubwindow ##;
		//Display/HOST=#/W=(0.48,0.74,0.64,0.99);

		setActiveSubwindow ##;
		Display/HOST=#/W=(0.64,0.74,0.8,0.99);
		appendimage $mothername;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;
		TextBox/C/N=text1/F=0/A=MT/X=0.00/Y=-10 "\\Z12\\$WMTEX$  T(r) \\$/WMTEX$"
		mdg_strain1(105,0)
		SetAxis bottom x1,x2;SetAxis left y1,y2
		ColorScale/C/N=text0 notation=1
		ModifyGraph mirror=2,nticks=0,axThick=3,noLabel=0
		Label left "\\Z14\\$WMTEX$ L_{Y} \\$/WMTEX$ (Image axis)"
		Label bottom "\\Z14\\$WMTEX$ L_{X} \\$/WMTEX$ (Image axis)"


		//setActiveSubwindow ##;
		//Display/HOST=#/W=(0.8,0.74,0.96,0.99);

		setActiveSubwindow ##;
		SetDrawEnv xcoord= axrel,ycoord= axrel,fillpat= 0,linethick= 3.00;DrawRect 0.346,0.041,0.508,0.497

		Drawarrow(0.89,0.9,theta_lattice,0.05)

		variable/G frame2ornot_strainana = 1
		variable/G order_strainaan = order
		variable/G selqmode_strainaan = selqmode
		variable/G theta_strainaan = theta_lattice
		initialcontrolforstrainan()
end

Function initialcontrolforstrainan()
	variable/G frame2ornot_strainana
	variable/G order_strainaan
	variable/G selqmode_strainaan
	variable/G theta_strainaan

	SetVariable setvar1 win=StrainanalysismultiWin,size={125,20},value=order_strainaan,proc=SetVarProc_Constsrain,limits={0,10,1},title="Order of Polynomial"
	SetVariable setvar2 win=StrainanalysismultiWin,size={100,20},value=frame2ornot_strainana,proc=SetVarProc_Constsrain,limits={0,1,1},title="Fe-Fe Frame?"
	popupmenu setvar3 win=StrainanalysismultiWin,size={100,20},proc=PopMenuProc_Constsrain,title="Q mode",value="Global;Just Fitted",mode=2
	SetVariable setvar4 win=StrainanalysismultiWin,size={100,20},value=theta_strainaan,proc=SetVarProc_Constsrain,limits={-45,145,2},title="θ(˚)"
	Button setvar5 win=StrainanalysismultiWin, title="Caculate ε(θ)",fSize=10,proc=ButtonProc_Strain_anglec,pos={340,860},size={100,20}
	Button setvar6 win=StrainanalysismultiWin, title="θ = θ(Se-Se)",fSize=10,proc=ButtonProc_StrainFTtheta,size={80,15},pos={390,16}
	Button turnoffls3d title="BACK",valueColor=(0,0,0),fColor=(1,65535,33232),proc=ButtonProc_lsturnoff3d,pos={1400,1},size={45,18}

	variable/G avedia_LF

	SetVariable setvar0 win = StrainanalysismultiWin, title="FWHM(r)",size={110,20},value=avedia_LF,proc=SetVarProc_ConstLFstrain,pos={775,680}


	SetVariable setvar1 pos={2,1}
	SetVariable setvar2 pos={137,1}
	PopupMenu setvar3 pos={247,1}
	SetVariable setvar4 pos={387,1}
end

Function SetVarProc_ConstLFstrain(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	execute "LawlerFujita2()"
	setActiveSubwindow ##;
	//** Error message, no stop but Continuing execution
		String msg
		Variable err
		msg=GetErrMessage(GetRTError(0),3);
		err=GetRTError(1)

	string/G namefftraw
	variable/G order_strainaan
	variable/G selqmode_strainaan
	variable/G frame2ornot_strainana
	variable/G theta_strainaan

	string uxt = namefftraw+"_ux"
	string uyt = namefftraw+"_uy"
	drawAction/W=StrainanalysismultiWin delete
	SetDrawEnv xcoord= axrel,ycoord= axrel,fillpat= 0,linethick= 3.00;DrawRect 0.346,0.041,0.508,0.497
	Drawarrow(0.89,0.9,theta_strainaan,0.05)
	Strainanalysis($uxt,$uyt,order_strainaan,namefftraw,selqmode_strainaan,frame2ornot_strainana,theta_strainaan)

	mdg_strain2(74,1,0)
	mdg_strain2(97,0,1)
	mdg_strain2(105,0,2)
	mdg_strain2(105,0,3)

	mdg_strain2(74,1,6)
	mdg_strain2(97,0,7)
	mdg_strain2(105,0,8)
	mdg_strain2(105,0,9)

	mdg_strain2(21,1,12)
	mdg_strain2(24,1,13)
	mdg_strain2(19,1,14)

	If (frame2ornot_strainana == 0)
	else
		mdg_strain2(97,0,4)
		mdg_strain2(74,1,5)
		mdg_strain2(97,0,10)
		mdg_strain2(74,1,11)
		mdg_strain2(19,1,15)
		mdg_strain2(21,1,16)
		mdg_strain2(24,1,17)
	endif

	string ulevelx = uxt+"_level"
	string ulevely = uyt+"_level"
	string uthetax45 = ulevelx+"_theta45"
	string uthetay45 =ulevely+"_theta45"
	wave uthetax45w = $uthetax45
	wave uthetay45w = $uthetay45

	String elpaa, elpab, elpba, elpbb, aB1g, aA1g
	elpaa = namefftraw+"_elpson_aa"
	wave elpaaw = $elpaa
	elpab = namefftraw+"_elpson_ab"
	wave elpabw = $elpab
	elpba = namefftraw+"_elpson_ba"
	wave elpbaw = $elpba
	elpbb = namefftraw+"_elpson_bb"
	wave elpbbw = $elpbb
	aB1g = namefftraw+"_a_B1g"
	wave aB1gw = $aB1g
	aA1g = namefftraw+"_a_A1g"
	wave aA1gw = $aA1g
	if (frame2ornot_strainana == 0)
		elpaaw = nan
		elpabw = nan
		elpbaw = nan
		elpbbw = nan
		aB1gw = nan
		aA1gw = nan
		uthetax45w = nan
		uthetay45w = nan
	endif

	string dxy, dx2my2, dx2py2
		dxy = namefftraw+"_B2g_angle"
		dx2my2 = namefftraw+"_B1g_angle"
		dx2py2 = namefftraw+"_A1g_angle"
	make/o/n=2 indicator_strainana
		variable t1,t2,t3,b1,b2,b3
		wavestats/Q $dxy
		t1 = V_max
		b1 = V_min
		wavestats/Q $dx2my2
		t2 = V_max
		b2 = V_min
		wavestats/Q $dx2py2
		t3 = V_max
		b3 = V_min
		variable t,b
		t = max(t1,t2,t3,b1,b2,b3)
		b = min(t1,t2,t3,b1,b2,b3)
		setscale/i x, t,b,"",indicator_strainana
		variable/G theta_lattice
		indicator_strainana = theta_strainaan-theta_lattice
End

Function ButtonProc_StrainFTtheta(ctrlName) : ButtonControl
	String ctrlName

	variable/G frame2ornot_strainana
	variable/G order_strainaan
	variable/G selqmode_strainaan
	variable/G theta_strainaan
	variable/G theta_lattice
	setActiveSubwindow ##;
	//** Error message, no stop but Continuing execution
		String msg
		Variable err
		msg=GetErrMessage(GetRTError(0),3);
		err=GetRTError(1)
	theta_strainaan = theta_lattice
	string/G namefftraw

	string uxt = namefftraw+"_ux"
	string uyt = namefftraw+"_uy"

	drawAction/W=StrainanalysismultiWin delete
	SetDrawEnv xcoord= axrel,ycoord= axrel,fillpat= 0,linethick= 3.00;DrawRect 0.346,0.041,0.508,0.497
	Drawarrow(0.89,0.9,theta_strainaan,0.05)
	Strainanalysis($uxt,$uyt,order_strainaan,namefftraw,selqmode_strainaan,frame2ornot_strainana,theta_strainaan)
	mdg_strain2(74,1,0)
	mdg_strain2(97,0,1)
	mdg_strain2(105,0,2)
	mdg_strain2(105,0,3)

	mdg_strain2(74,1,6)
	mdg_strain2(97,0,7)
	mdg_strain2(105,0,8)
	mdg_strain2(105,0,9)

	mdg_strain2(21,1,12)
	mdg_strain2(24,1,13)
	mdg_strain2(19,1,14)

	If (frame2ornot_strainana == 0)
	else
		mdg_strain2(97,0,4)
		mdg_strain2(74,1,5)
		mdg_strain2(97,0,10)
		mdg_strain2(74,1,11)
		mdg_strain2(19,1,15)
		mdg_strain2(21,1,16)
		mdg_strain2(24,1,17)
	endif

	string ulevelx = uxt+"_level"
	string ulevely = uyt+"_level"
	string uthetax45 = ulevelx+"_theta45"
	string uthetay45 =ulevely+"_theta45"
	wave uthetax45w = $uthetax45
	wave uthetay45w = $uthetay45

	String elpaa, elpab, elpba, elpbb, aB1g, aA1g
	elpaa = namefftraw+"_elpson_aa"
	wave elpaaw = $elpaa
	elpab = namefftraw+"_elpson_ab"
	wave elpabw = $elpab
	elpba = namefftraw+"_elpson_ba"
	wave elpbaw = $elpba
	elpbb = namefftraw+"_elpson_bb"
	wave elpbbw = $elpbb
	aB1g = namefftraw+"_a_B1g"
	wave aB1gw = $aB1g
	aA1g = namefftraw+"_a_A1g"
	wave aA1gw = $aA1g
	if (frame2ornot_strainana == 0)
		elpaaw = nan
		elpabw = nan
		elpbaw = nan
		elpbbw = nan
		aB1gw = nan
		aA1gw = nan
		uthetax45w = nan
		uthetay45w = nan
	endif

	string dxy, dx2my2, dx2py2
		dxy = namefftraw+"_B2g_angle"
		dx2my2 = namefftraw+"_B1g_angle"
		dx2py2 = namefftraw+"_A1g_angle"
	make/o/n=2 indicator_strainana
		variable t1,t2,t3,b1,b2,b3
		wavestats/Q $dxy
		t1 = V_max
		b1 = V_min
		wavestats/Q $dx2my2
		t2 = V_max
		b2 = V_min
		wavestats/Q $dx2py2
		t3 = V_max
		b3 = V_min
		variable t,b
		t = max(t1,t2,t3,b1,b2,b3)
		b = min(t1,t2,t3,b1,b2,b3)
		setscale/i x, t,b,"",indicator_strainana
		variable/G theta_lattice
		indicator_strainana = theta_strainaan-theta_lattice
end

Function PopMenuProc_Constsrain(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	variable/G frame2ornot_strainana
	variable/G order_strainaan
	variable/G selqmode_strainaan
	variable/G theta_strainaan

	string/G namefftraw
	setActiveSubwindow ##;
	//** Error message, no stop but Continuing execution
		String msg
		Variable err
		msg=GetErrMessage(GetRTError(0),3);
		err=GetRTError(1)
	selqmode_strainaan = popNum
	string uxt = namefftraw+"_ux"
	string uyt = namefftraw+"_uy"
	drawAction/W=StrainanalysismultiWin delete
	SetDrawEnv xcoord= axrel,ycoord= axrel,fillpat= 0,linethick= 3.00;DrawRect 0.346,0.041,0.508,0.497
	Drawarrow(0.89,0.9,theta_strainaan,0.05)
	Strainanalysis($uxt,$uyt,order_strainaan,namefftraw,selqmode_strainaan,frame2ornot_strainana,theta_strainaan)


	mdg_strain2(74,1,0)
	mdg_strain2(97,0,1)
	mdg_strain2(105,0,2)
	mdg_strain2(105,0,3)

	mdg_strain2(74,1,6)
	mdg_strain2(97,0,7)
	mdg_strain2(105,0,8)
	mdg_strain2(105,0,9)

	mdg_strain2(21,1,12)
	mdg_strain2(24,1,13)
	mdg_strain2(19,1,14)

	If (frame2ornot_strainana == 0)
	else
		mdg_strain2(97,0,4)
		mdg_strain2(74,1,5)
		mdg_strain2(97,0,10)
		mdg_strain2(74,1,11)
		mdg_strain2(19,1,15)
		mdg_strain2(21,1,16)
		mdg_strain2(24,1,17)
	endif

	string ulevelx = uxt+"_level"
	string ulevely = uyt+"_level"
	string uthetax45 = ulevelx+"_theta45"
	string uthetay45 =ulevely+"_theta45"
	wave uthetax45w = $uthetax45
	wave uthetay45w = $uthetay45

	String elpaa, elpab, elpba, elpbb, aB1g, aA1g
	elpaa = namefftraw+"_elpson_aa"
	wave elpaaw = $elpaa
	elpab = namefftraw+"_elpson_ab"
	wave elpabw = $elpab
	elpba = namefftraw+"_elpson_ba"
	wave elpbaw = $elpba
	elpbb = namefftraw+"_elpson_bb"
	wave elpbbw = $elpbb
	aB1g = namefftraw+"_a_B1g"
	wave aB1gw = $aB1g
	aA1g = namefftraw+"_a_A1g"
	wave aA1gw = $aA1g
	if (frame2ornot_strainana == 0)
		elpaaw = nan
		elpabw = nan
		elpbaw = nan
		elpbbw = nan
		aB1gw = nan
		aA1gw = nan
		uthetax45w = nan
		uthetay45w = nan
	endif

	string dxy, dx2my2, dx2py2
		dxy = namefftraw+"_B2g_angle"
		dx2my2 = namefftraw+"_B1g_angle"
		dx2py2 = namefftraw+"_A1g_angle"
	make/o/n=2 indicator_strainana
		variable t1,t2,t3,b1,b2,b3
		wavestats/Q $dxy
		t1 = V_max
		b1 = V_min
		wavestats/Q $dx2my2
		t2 = V_max
		b2 = V_min
		wavestats/Q $dx2py2
		t3 = V_max
		b3 = V_min
		variable t,b
		t = max(t1,t2,t3,b1,b2,b3)
		b = min(t1,t2,t3,b1,b2,b3)
		setscale/i x, t,b,"",indicator_strainana
		variable/G theta_lattice
		indicator_strainana = theta_strainaan-theta_lattice
end

Function SetVarProc_Constsrain(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	string/G namefftraw
	variable/G order_strainaan
	variable/G selqmode_strainaan
	variable/G frame2ornot_strainana
	variable/G theta_strainaan
	setActiveSubwindow ##;
	//** Error message, no stop but Continuing execution
		String msg
		Variable err
		msg=GetErrMessage(GetRTError(0),3);
		err=GetRTError(1)
	string uxt = namefftraw+"_ux"
	string uyt = namefftraw+"_uy"
	drawAction/W=StrainanalysismultiWin delete
	SetDrawEnv xcoord= axrel,ycoord= axrel,fillpat= 0,linethick= 3.00;DrawRect 0.346,0.041,0.508,0.497
	Drawarrow(0.89,0.9,theta_strainaan,0.05)
	Strainanalysis($uxt,$uyt,order_strainaan,namefftraw,selqmode_strainaan,frame2ornot_strainana,theta_strainaan)

	mdg_strain2(74,1,0)
	mdg_strain2(97,0,1)
	mdg_strain2(105,0,2)
	mdg_strain2(105,0,3)

	mdg_strain2(74,1,6)
	mdg_strain2(97,0,7)
	mdg_strain2(105,0,8)
	mdg_strain2(105,0,9)

	mdg_strain2(21,1,12)
	mdg_strain2(24,1,13)
	mdg_strain2(19,1,14)

	If (frame2ornot_strainana == 0)
	else
		mdg_strain2(97,0,4)
		mdg_strain2(74,1,5)
		mdg_strain2(97,0,10)
		mdg_strain2(74,1,11)
		mdg_strain2(19,1,15)
		mdg_strain2(21,1,16)
		mdg_strain2(24,1,17)
	endif

	string ulevelx = uxt+"_level"
	string ulevely = uyt+"_level"
	string uthetax45 = ulevelx+"_theta45"
	string uthetay45 =ulevely+"_theta45"
	wave uthetax45w = $uthetax45
	wave uthetay45w = $uthetay45

	String elpaa, elpab, elpba, elpbb, aB1g, aA1g
	elpaa = namefftraw+"_elpson_aa"
	wave elpaaw = $elpaa
	elpab = namefftraw+"_elpson_ab"
	wave elpabw = $elpab
	elpba = namefftraw+"_elpson_ba"
	wave elpbaw = $elpba
	elpbb = namefftraw+"_elpson_bb"
	wave elpbbw = $elpbb
	aB1g = namefftraw+"_a_B1g"
	wave aB1gw = $aB1g
	aA1g = namefftraw+"_a_A1g"
	wave aA1gw = $aA1g
	if (frame2ornot_strainana == 0)
		elpaaw = nan
		elpabw = nan
		elpbaw = nan
		elpbbw = nan
		aB1gw = nan
		aA1gw = nan
		uthetax45w = nan
		uthetay45w = nan
	endif

	string dxy, dx2my2, dx2py2
		dxy = namefftraw+"_B2g_angle"
		dx2my2 = namefftraw+"_B1g_angle"
		dx2py2 = namefftraw+"_A1g_angle"
	make/o/n=2 indicator_strainana
		variable t1,t2,t3,b1,b2,b3
		wavestats/Q $dxy
		t1 = V_max
		b1 = V_min
		wavestats/Q $dx2my2
		t2 = V_max
		b2 = V_min
		wavestats/Q $dx2py2
		t3 = V_max
		b3 = V_min
		variable t,b
		t = max(t1,t2,t3,b1,b2,b3)
		b = min(t1,t2,t3,b1,b2,b3)
		setscale/i x, t,b,"",indicator_strainana
		variable/G theta_lattice
		indicator_strainana = theta_strainaan-theta_lattice

end

Function mdg_strain2(index,divornot,num)
	variable index
	variable divornot
	variable num //subwindow number

	String wn =winname(0,1)

	string subwinname = wn+"#G"+num2str(num)
	string name = stringfromlist(0,WaveList("*", ";","WIN:"+subwinname))

	ColorScale/C/N=text0/A=LC/X=101/Y=0/F=0 frame=0.00,image=$name

	variable numnew = itemsInList(WaveList("*", ";", "", root:Packages:NewColortable:))
	string topgraphcolor_m2, topgraphcolor
	if(index < numnew)
		topgraphcolor_m2=stringfromList(index,WaveList("*", ";", "", root:Packages:NewColortable:))
		topgraphcolor = "root:Packages:NewColortable:"+topgraphcolor_m2
	else
		topgraphcolor_m2=stringfromList(index-numnew,CtabList())
		topgraphcolor = topgraphcolor_m2
	endif

	string toexecute
	variable vm
	if (divornot == 0)
		toexecute="Modifyimage/w="+subwinname+" "+name+" ctab= {*,*,"+topgraphcolor+",0}"
	else
		wavestats/Q $name
		//vm =max(abs(V_min),abs(V_max))
		vm = (abs(V_min)+abs(V_max))/2
		toexecute="Modifyimage/w="+subwinname+" "+name+" ctab= {"+num2str(-vm)+","+num2str(vm)+","+topgraphcolor+",0}"

	endif
	Execute toexecute
	//print toexecute
end

//******************************************************************************************************
//******************************************************************************************************
//## MAIN FUNCTION
//******************************************************************************************************
//******************************************************************************************************
Function Strainanalysis(ux,uy,order,mothername,selqmode,frame2ornot,theta)
	wave ux // bare displacement matrix Ux
	wave uy // bare displacement matrix Uy
	variable order //polynomial order to remove background
	string mothername //name of the topography
	variable selqmode //prompt sel,"Which Q?",popup,"Global;Just Fitted"
	variable frame2ornot // whether or not calculate the second frame, =1 yes; =0 No
	variable theta //angle of the lattice in topo \degree
	//** leveled displacement image (input is the raw displacement matrix)
		umatrixsubbackground(ux,uy,order)
			string ulevelx = nameofwave(ux)+"_level"
			string ulevely = nameofwave(uy)+"_level"
			wave ulevelxw = $ulevelx
			wave ulevelyw = $ulevely


	variable theta45 = -45+theta
	//** Displacement matrix after project to axis at theta (input is leveled displacement matrix)
		//# Project to Se-Se
			projectstrainmatrix(ulevelxw,ulevelyw,theta)
				string uthetax = nameofwave(ulevelxw)+"_theta"
				string uthetay = nameofwave(ulevelyw)+"_theta"
				wave uthetaxw = $uthetax
				wave uthetayw = $uthetay

		//# Project to Fe-Fe
		if (frame2ornot ==1)

			projectstrainmatrix45(ulevelxw,ulevelyw,theta45)
				string uthetax45 = nameofwave(ulevelxw)+"_theta45"
				string uthetay45 = nameofwave(ulevelyw)+"_theta45"
				wave uthetax45w = $uthetax45
				wave uthetay45w = $uthetay45
		endif

	//** Rotation
		//# Rotate Se-Se lattice (x-axis) to image X-axis for ux/uy
			Newrotate_forstrain(nameofwave(uthetaxw),-theta)
				String output_ux = nameofwave(uthetaxw)+"_Rot"
				wave output_uxw = $output_ux
			Newrotate_forstrain(nameofwave(uthetayw),-theta)
				String output_uy = nameofwave(uthetayw)+"_Rot"
				wave output_uyw = $output_uy

		//# Rotate Fe-Fe lattice (a-axis) to image X-axis for ua/ub
		if (frame2ornot ==1)
			Newrotate_forstrain(nameofwave(uthetax45w),-theta45)
				String output_ua = nameofwave(uthetax45w)+"_Rot"
				wave output_uaw = $output_ua
			Newrotate_forstrain(nameofwave(uthetay45w),-theta45)
				String output_ub = nameofwave(uthetay45w)+"_Rot"
				wave output_ubw = $output_ub
		endif

	//** Calculate Strain
		//# derivative for ux matrix along x-axis and y-axis
			differentiatealongx(output_uxw)
				string elpsionxx = nameofwave(output_uxw)+"_epxx"
				string elpsionxy = nameofwave(output_uxw)+"_epxy"
				wave elpsionxxw = $elpsionxx
				wave elpsionxyw = $elpsionxy
		//# derivative for uy matrix along x-axis and y-axis
			differentiatealongy(output_uyw)
				string elpsionyx = nameofwave(output_uyw)+"_epyx"
				string elpsionyy = nameofwave(output_uyw)+"_epyy"
				wave elpsionyxw = $elpsionyx
				wave elpsionyyw = $elpsionyy

		if (frame2ornot ==1)
		//# derivative for ua matrix along a-axis and b-axis
			differentiatealonga(output_uaw)
				string elpsionaa = nameofwave(output_uaw)+"_epaa"
				string elpsionab = nameofwave(output_uaw)+"_epab"
				wave elpsionaaw = $elpsionaa
				wave elpsionabw = $elpsionab
		//# derivative for ub matrix along a-axis and b-axis
			differentiatealongb(output_ubw)
				string elpsionba = nameofwave(output_ubw)+"_epba"
				string elpsionbb = nameofwave(output_ubw)+"_epbb"
				wave elpsionbaw = $elpsionba
				wave elpsionbbw = $elpsionbb
		endif


	//** Rotate Back
		//# Rotate Se-Se lattice strain elpson_xx back
			Newrotate_forstrainback(nameofwave(elpsionxxw),theta)
				String output_elpsxx = nameofwave(elpsionxxw)+"_Rotback"
				wave output_elpsxxw = $output_elpsxx
				//output_elpsxxw *= 100
		//# Rotate Se-Se lattice strain elpson_xy back
			Newrotate_forstrainback(nameofwave(elpsionxyw),theta)
				String output_elpsxy = nameofwave(elpsionxyw)+"_Rotback"
				wave output_elpsxyw = $output_elpsxy
				//output_elpsxyw *= 100
		//# Rotate Se-Se lattice strain elpson_yx back
			Newrotate_forstrainback(nameofwave(elpsionyxw),theta)
				String output_elpsyx = nameofwave(elpsionyxw)+"_Rotback"
				wave output_elpsyxw = $output_elpsyx
				//output_elpsyxw *= 100
		//# Rotate Se-Se lattice strain elpson_yx back
			Newrotate_forstrainback(nameofwave(elpsionyyw),theta)
				String output_elpsyy = nameofwave(elpsionyyw)+"_Rotback"
				wave output_elpsyyw = $output_elpsyy
				//output_elpsyyw *= 100

		if (frame2ornot ==1)
		//# Rotate Fe-Fe lattice strain elpson_aa back
			Newrotate_forstrainback(nameofwave(elpsionaaw),theta45)
				String output_elpsaa = nameofwave(elpsionaaw)+"_Rotback"
				wave output_elpsaaw = $output_elpsaa
				//output_elpsaaw *= 100
		//# Rotate Fe-Fe lattice strain elpson_ab back
			Newrotate_forstrainback(nameofwave(elpsionabw),theta45)
				String output_elpsab = nameofwave(elpsionabw)+"_Rotback"
				wave output_elpsabw = $output_elpsab
				//output_elpsabw *= 100
		//# Rotate Fe-Fe lattice strain elpson_ba back
			Newrotate_forstrainback(nameofwave(elpsionbaw),theta45)
				String output_elpsba = nameofwave(elpsionbaw)+"_Rotback"
				wave output_elpsbaw = $output_elpsba
				//output_elpsbaw *= 100
		//# Rotate Fe-Fe lattice strain elpson_bb back
			Newrotate_forstrainback(nameofwave(elpsionbbw),theta45)
				String output_elpsbb = nameofwave(elpsionbbw)+"_Rotback"
				wave output_elpsbbw = $output_elpsbb
				//output_elpsbbw *= 100
		endif

	//** Rename and calculate strain matrix
		//# Rename the partial differential matrix
			String elpxx, elpxy, elpyx, elpyy, elpaa, elpab, elpba, elpbb
			elpxx = mothername+"_elpson_xx"
			elpxy = mothername+"_elpson_xy"
			elpyx = mothername+"_elpson_yx"
			elpyy = mothername+"_elpson_yy"
			elpaa = mothername+"_elpson_aa"
			elpab = mothername+"_elpson_ab"
			elpba = mothername+"_elpson_ba"
			elpbb = mothername+"_elpson_bb"
			duplicate/o output_elpsxxw $elpxx
			duplicate/o output_elpsxyw $elpxy
			duplicate/o output_elpsyxw $elpyx
			duplicate/o output_elpsyyw $elpyy
			wave elpxxw = $elpxx
			wave elpyyw = $elpyy

		if (frame2ornot ==1)
			duplicate/o output_elpsaaw $elpaa
			duplicate/o output_elpsabw $elpab
			duplicate/o output_elpsbaw $elpba
			duplicate/o output_elpsbbw $elpbb
			wave elpaaw = $elpaa
			wave elpbbw = $elpbb
		endif

		//# Calculate the shearing matrix (B2g mode)
			wave elpxyw = $elpxy
			elpxyw = 0.5*(output_elpsxyw+output_elpsyxw) // d_{xy}
			wave elpyxw = $elpyx
			elpyxw = 0.5*(output_elpsxyw+output_elpsyxw) // d_{yx}

		if (frame2ornot ==1)
			wave elpabw = $elpab
			elpabw = 0.5*(output_elpsabw+output_elpsbaw) //d_{ab}
			wave elpbaw = $elpba
			elpbaw = 0.5*(output_elpsbaw+output_elpsabw) //d_{ba}
		endif

		//# Calculate the A1g and B1g mode
			string xB1g,xA1g, aB1g, aA1g
			xB1g = mothername+"_x_B1g"
			xA1g = mothername+"_x_A1g"
			aB1g = mothername+"_a_B1g"
			aA1g = mothername+"_a_A1g"
			duplicate/o output_elpsxxw $xB1g
			duplicate/o output_elpsxxw $xA1g
			wave xB1gw = $xB1g
			xB1gw = 0.5*(elpxxw-elpyyw) //d_{x2-y2}
			wave xA1gw = $xA1g
			xA1gw = 0.5*(elpxxw+elpyyw) //d_{x2+y2}

		if (frame2ornot ==1)
			duplicate/o output_elpsaaw $aB1g
			duplicate/o output_elpsaaw $aA1g
			wave aB1gw = $aB1g
			aB1gw = 0.5*(elpaaw-elpbbw) //d_{a2-b2}
			wave aA1gw = $aA1g
			aA1gw = 0.5*(elpaaw+elpbbw) //d_{a2+b2}
		endif



	//** killwaves
		//# kill rotated projected displacement matrix: ux uy ua ub
		//# kill rotated strain matrix: εxx εxy εyx εyy εaa εab εba εbb
		//# kill final duplicated strain matrix: εxx εxy εyx εyy εaa εab εba εbb
			killwaves output_uxw output_uyw elpsionxxw elpsionxyw elpsionyxw elpsionyyw output_elpsxxw output_elpsxyw output_elpsyxw output_elpsyyw

		if (frame2ornot ==1)
			killwaves output_uaw output_ubw elpsionaaw elpsionabw elpsionbaw elpsionbbw output_elpsaaw output_elpsabw output_elpsbaw output_elpsbbw
		endif
End

//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************

///////////////////////////////////////////////////////////////////
//** Kernel#01 ** Function for remove polynomial background
///////////////////////////////////////////////////////////////////
Function umatrixsubbackground(ux,uy,order)
	wave ux
	wave uy
	variable order // =2

	string ulevelx = nameofwave(ux)+"_level"
	string ulevely = nameofwave(uy)+"_level"

	duplicate/o ux $ulevelx
	duplicate/o uy $ulevely

	wave ulevelxw = $ulevelx
	wave ulevelyw = $ulevely

	if (order == 0)
		ulevelxw = ux
		ulevelyw = uy
	else
		string destfit = "levelfit_"+nameofWave(ux)
		duplicate/O ux $destfit
		wave destfitw = $destfit
		CurveFit/Q/W=0 poly2D order, ux/D = destfitw
		ulevelxw -= destfitw
		killwaves destfitw

		destfit = "levelfit_"+nameofWave(uy)
		duplicate/O uy $destfit
		wave destfitw = $destfit
		CurveFit/Q/W=0 poly2D order, uy/D = destfitw
		ulevelyw -= destfitw
		killwaves destfitw
	endif
	//di(ulevelxw)
	//di(ulevelyw)
end

///////////////////////////////////////////////////////////////////
//** Kernel#02 ** Function for Project matrix to arbitary axis
///////////////////////////////////////////////////////////////////
Function projectstrainmatrix(ux,uy,theta)
	wave ux
	wave uy
	variable theta //degree

	string uthetax = nameofwave(ux)+"_theta"
	string uthetay = nameofwave(uy)+"_theta"

	duplicate/o ux $uthetax,$uthetay

	wave uthetaxw = $uthetax
	wave uthetayw = $uthetay

	variable i,j
	i=0
	do
		j=0
		do
			uthetaxw[i][j] = ux[i][j]*cos(theta*pi/180)+uy[i][j]*cos((90-theta)*pi/180)
			uthetayw[i][j] = ux[i][j]*cos((theta+90)*pi/180)+uy[i][j]*cos(theta*pi/180)
			j+=1
		while (j<dimsize(ux,1))
		i+=1
	while (i<dimsize(ux,0))
	//di(uthetaxw)
	//di(uthetayw)
end

///////////////////////////////////////////////////////////////////
//** Kernel#03 ** Function for Project matrix to arbitary axis +45
///////////////////////////////////////////////////////////////////
Function projectstrainmatrix45(ux,uy,theta)
	wave ux
	wave uy
	variable theta //degree

	string uthetax = nameofwave(ux)+"_theta45"
	string uthetay = nameofwave(uy)+"_theta45"

	duplicate/o ux $uthetax,$uthetay

	wave uthetaxw = $uthetax
	wave uthetayw = $uthetay

	variable i,j
	i=0
	do
		j=0
		do
			uthetaxw[i][j] = ux[i][j]*cos(theta*pi/180)+uy[i][j]*cos((90-theta)*pi/180)
			uthetayw[i][j] = ux[i][j]*cos((theta+90)*pi/180)+uy[i][j]*cos(theta*pi/180)
			j+=1
		while (j<dimsize(ux,1))
		i+=1
	while (i<dimsize(ux,0))
	//di(uthetaxw)
	//di(uthetayw)
end


///////////////////////////////////////////////////////////////////
//** Kernel#04 ** Function for Rotate the matrix
///////////////////////////////////////////////////////////////////
Function Newrotate_forstrain(name,theta1)
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

			String outputLF = name+"_Rot"
			Make/O/N=(dimsize(xxlfw,0),3) sampleTripletRT
			sampleTripletRT[][0]=xxlfw[p]
			sampleTripletRT[][1]=yylfw[p]
			sampleTripletRT[][2]=zzlfw[p]
			ImageInterpolate/RESL={newsizex,newsizey}/DEST=$outputLF voronoi sampleTripletRT

	killwaves $xxlf $yylf $zzlf xgrid ygrid

	//di($outputLF)
end


///////////////////////////////////////////////////////////////////
//** Kernel#05 ** Function for ux derivative
///////////////////////////////////////////////////////////////////
Function differentiatealongx(name)
	wave name
	variable i,j

	string elpsionxx = nameofwave(name)+"_epxx"
	string elpsionxy = nameofwave(name)+"_epxy"
	duplicate/o name $elpsionxx
	duplicate/o name $elpsionxy
	wave elpsionxxw = $elpsionxx
	wave elpsionxyw = $elpsionxy


	i=1
	do
		j=1
		do
			elpsionxxw[i][j] = (name[i][j] - name[i-1][j])/dimdelta(name,0)
			elpsionxyw[i][j] = (name[i][j] - name[i][j-1])/dimdelta(name,1)

			j+=1
		while (j<dimsize(name,1))
		i+=1
	while (i<dimsize(name,0))
	//di(elpsionxxw)
	//di(elpsionxyw)
end

///////////////////////////////////////////////////////////////////
//** Kernel#06 ** Function for uy derivative
///////////////////////////////////////////////////////////////////
Function differentiatealongy(name)
	wave name
	variable i,j

	string elpsionyx = nameofwave(name)+"_epyx"
	string elpsionyy = nameofwave(name)+"_epyy"
	duplicate/o name $elpsionyx
	duplicate/o name $elpsionyy
	wave elpsionyxw = $elpsionyx
	wave elpsionyyw = $elpsionyy

	i=1
	do
		j=1
		do
			elpsionyxw[i][j] = (name[i][j] - name[i-1][j])/dimdelta(name,0)
			elpsionyyw[i][j] = (name[i][j] - name[i][j-1])/dimdelta(name,1)

			j+=1
		while (j<dimsize(name,1))
		i+=1
	while (i<dimsize(name,0))
	//di(elpsionyxw)
	//di(elpsionyyw)
end

///////////////////////////////////////////////////////////////////
//** Kernel#07 ** Function for ua derivative
///////////////////////////////////////////////////////////////////
Function differentiatealonga(name)
	wave name
	variable i,j

	string elpsionaa = nameofwave(name)+"_epaa"
	string elpsionab = nameofwave(name)+"_epab"
	duplicate/o name $elpsionaa
	duplicate/o name $elpsionab
	wave elpsionaaw = $elpsionaa
	wave elpsionabw = $elpsionab


	i=1
	do
		j=1
		do
			elpsionaaw[i][j] = (name[i][j] - name[i-1][j])/dimdelta(name,0)
			elpsionabw[i][j] = (name[i][j] - name[i][j-1])/dimdelta(name,1)

			j+=1
		while (j<dimsize(name,1))
		i+=1
	while (i<dimsize(name,0))
	//di(elpsionaaw)
	//di(elpsionabw)
end

///////////////////////////////////////////////////////////////////
//** Kernel#08 ** Function for ub derivative
///////////////////////////////////////////////////////////////////
Function differentiatealongb(name)
	wave name
	variable i,j

	string elpsionba = nameofwave(name)+"_epba"
	string elpsionbb = nameofwave(name)+"_epbb"
	duplicate/o name $elpsionba
	duplicate/o name $elpsionbb
	wave elpsionbaw = $elpsionba
	wave elpsionbbw = $elpsionbb


	i=1
	do
		j=1
		do
			elpsionbaw[i][j] = (name[i][j] - name[i-1][j])/dimdelta(name,0)
			elpsionbbw[i][j] = (name[i][j] - name[i][j-1])/dimdelta(name,1)

			j+=1
		while (j<dimsize(name,1))
		i+=1
	while (i<dimsize(name,0))
	//di(elpsionbaw)
	//di(elpsionbbw)
end

///////////////////////////////////////////////////////////////////
//** Kernel#09 ** Function for Rotate the matrix back
///////////////////////////////////////////////////////////////////
Function Newrotate_forstrainback(name,theta1)
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

			String outputLF = name+"_Rotback"
			Make/O/N=(dimsize(xxlfw,0),3) sampleTripletRT
			sampleTripletRT[][0]=xxlfw[p]
			sampleTripletRT[][1]=yylfw[p]
			sampleTripletRT[][2]=zzlfw[p]
			ImageInterpolate/RESL={newsizex,newsizey}/DEST=$outputLF voronoi sampleTripletRT

	killwaves $xxlf $yylf $zzlf xgrid ygrid

	//di($outputLF)
end

///////////////////////////////////////////////////////////////////
//** Kernel#10 ** Color style
///////////////////////////////////////////////////////////////////
Function mdg_strain1(index,divornot)
	variable index
	variable divornot

	String wn =winname(0,1)
	ColorScale/C/N=text0/A=LC/X=101/Y=0/F=0 frame=0.00,image=$tpw()

	variable numnew = itemsInList(WaveList("*", ";", "", root:Packages:NewColortable:))
	string topgraphcolor_m2, topgraphcolor
	if(index < numnew)
		topgraphcolor_m2=stringfromList(index,WaveList("*", ";", "", root:Packages:NewColortable:))
		topgraphcolor = "root:Packages:NewColortable:"+topgraphcolor_m2
	else
		topgraphcolor_m2=stringfromList(index-numnew,CtabList())
		topgraphcolor = topgraphcolor_m2
	endif

	string toexecute
	variable vm
	if (divornot == 0)
		toexecute="Modifyimage $tpw() ctab= {*,*,"+topgraphcolor+",0}"
	else
		wavestats/Q $tpw()
		//vm =max(abs(V_min),abs(V_max))
		vm = (abs(V_min)+abs(V_max))/2
		toexecute="Modifyimage $tpw() ctab= {"+num2str(-vm)+","+num2str(vm)+","+topgraphcolor+",0}"
		///w=$grabwinchild(tpw())
	endif
	Execute toexecute
	//print toexecute

	//ModifyImage $tpw() ctab= {*,*,VioletOrangeYellow,0}
	Dowindow/F $wn
	drawAction delete
	variable lenx = (dimsize($tpw(),0)-1)*dimdelta($tpw(),0)
	variable leny = (dimsize($tpw(),1)-1)*dimdelta($tpw(),1)
	Dowindow/F $wn
	variable x1,x2,lenbar1,lenbar
	x1 = dimoffset($tpw(),0)+0.75*lenx
	lenbar1 = round(0.2*lenx)
	if(lenbar1 > 10)
		lenbar = lenbar1+(round(lenbar1/10)-lenbar1/10)*10
	else
		lenbar = lenbar1
	endif
	X2 = 0.75*lenx+lenbar+dimoffset($tpw(),0)

	SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),linethick= 4.00
	DrawLine x1,0.06*leny+dimoffset($tpw(),1),x2,0.06*leny+dimoffset($tpw(),1)


	ModifyGraph noLabel=2
	ModifyGraph axThick=0

	string textv =num2str(round(lenbar))+" Å"
	SetDrawEnv xcoord= bottom,ycoord= left,textrgb= (65535,65535,65535),fstyle= 1,fsize= 15,textxjust= 1,textyjust= 1
	DrawText 0.85*lenx+dimoffset($tpw(),0),0.105*leny+dimoffset($tpw(),1),textv
	//color3s_for3d($tpw(),3)

end
//******************************************************************************************************
//******************************************************************************************************

//******************************************************************************************************
//******************************************************************************************************
//## ANGULAR DEPENDENT FUNCTION
//******************************************************************************************************
//******************************************************************************************************
Function ButtonProc_Strain_anglec(ctrlName) : ButtonControl
	String ctrlName

	variable/G frame2ornot_strainana
	variable/G order_strainaan
	variable/G selqmode_strainaan
	variable/G theta_strainaan

	string/G namefftraw

	string uxt = namefftraw+"_ux"
	string uyt = namefftraw+"_uy"

	Strain_angle($uxt,$uyt,order_strainaan,namefftraw,selqmode_strainaan)
	string dxy, dx2my2, dx2py2
		dxy = namefftraw+"_B2g_angle"
		dx2my2 = namefftraw+"_B1g_angle"
		dx2py2 = namefftraw+"_A1g_angle"
	make/o/n=2 indicator_strainana
		variable t1,t2,t3,b1,b2,b3
		wavestats/Q $dxy
		t1 = V_max
		b1 = V_min
		wavestats/Q $dx2my2
		t2 = V_max
		b2 = V_min
		wavestats/Q $dx2py2
		t3 = V_max
		b3 = V_min
		variable t,b
		t = max(t1,t2,t3,b1,b2,b3)
		b = min(t1,t2,t3,b1,b2,b3)
		setscale/i x, t,b,"",indicator_strainana
		variable/G theta_lattice
		indicator_strainana = theta_strainaan-theta_lattice
end



Function Strain_angle(ux,uy,order,mothername,selqmode)
	wave ux // bare displacement matrix Ux
	wave uy // bare displacement matrix Uy
	variable order //polynomial order to remove background
	string mothername //name of the topography
	variable selqmode //prompt sel,"Which Q?",popup,"Global;Just Fitted"
	//** leveled displacement image (input is the raw displacement matrix)
		umatrixsubbackground_c(ux,uy,order)
			string ulevelx = nameofwave(ux)+"_level_c"
			string ulevely = nameofwave(uy)+"_level_c"
			wave ulevelxw = $ulevelx
			wave ulevelyw = $ulevely


	//** Get Q1
		variable qx1
		variable qy1

		string/G namefftraw
		string cpicka
		if (selqmode == 2) // just fitted when do lauch
			cpicka = namefftraw+"_QA"
		endif
		if (selqmode == 1) // Global Q saved
			cpicka = "GlobalQA"
		endif
		wave cpickaw = $cpicka
		qx1 = cpickaw[0]*2*pi
		qy1 = cpickaw[1]*2*pi

	//** Lattice angle get
		//# Se-Se lattice on topo
		variable theta0 = atan2(qy1,qx1)*180/pi // extract from the QA [Launch the FFT engineering or Global saved value]

	string dxy, dx2my2, dx2py2
	dxy = mothername+"_B2g_angle"
	dx2my2 = mothername+"_B1g_angle"
	dx2py2 = mothername+"_A1g_angle"
	make/n=90/o $dxy,$dx2my2,$dx2py2
	wave dxyw =$dxy
	wave dx2my2w =$dx2my2
	wave dx2py2w =$dx2py2
	setscale/i x, 0.5-theta0,89.5-theta0,"",dxyw, dx2my2w, dx2py2w

	variable vv
	variable theta,i

	//variable/G theta_lattice
	//** Lattice angle get
		//# Se-Se lattice on topo
		theta = 0.5
		i=0
		do
			Print i,"/",(90)-1
		//** Displacement matrix after project to axis at theta (input is leveled displacement matrix)
		//# Project to Se-Se
			projectstrainmatrix_c(ulevelxw,ulevelyw,theta)
				string uthetax = nameofwave(ulevelxw)+"_theta_c"
				string uthetay = nameofwave(ulevelyw)+"_theta_c"
				wave uthetaxw = $uthetax
				wave uthetayw = $uthetay

		//** Rotation
		//# Rotate Se-Se lattice (x-axis) to image X-axis for ux/uy
			Newrotate_forstrain_c(nameofwave(uthetaxw),-theta)
				String output_ux = nameofwave(uthetaxw)+"_Rot"
				wave output_uxw = $output_ux
			Newrotate_forstrain_c(nameofwave(uthetayw),-theta)
				String output_uy = nameofwave(uthetayw)+"_Rot"
				wave output_uyw = $output_uy

		//** Calculate Strain
		//# derivative for ux matrix along x-axis and y-axis
			differentiatealongx(output_uxw)
				string elpsionxx = nameofwave(output_uxw)+"_epxx"
				string elpsionxy = nameofwave(output_uxw)+"_epxy"
				wave elpsionxxw = $elpsionxx
				wave elpsionxyw = $elpsionxy
		//# derivative for uy matrix along x-axis and y-axis
			differentiatealongy(output_uyw)
				string elpsionyx = nameofwave(output_uyw)+"_epyx"
				string elpsionyy = nameofwave(output_uyw)+"_epyy"
				wave elpsionyxw = $elpsionyx
				wave elpsionyyw = $elpsionyy

		//** Rename and calculate strain matrix
		//# Calculate the shearing matrix (B2g mode)
			String elpxy
			elpxy = mothername+"_elpson_xy_c"
			duplicate/o elpsionxyw $elpxy

			wave elpxyw = $elpxy
			elpxyw = 0.5*(elpsionxyw+elpsionyxw) // d_{xy}

		//# Calculate the A1g and B1g mode
			string xB1g,xA1g, aB1g, aA1g
			xB1g = mothername+"_x_B1g_c"
			xA1g = mothername+"_x_A1g_c"
			duplicate/o elpsionxxw $xB1g
			duplicate/o elpsionxxw $xA1g

			wave xB1gw = $xB1g
			xB1gw = 0.5*(elpsionxxw-elpsionyyw) //d_{x2-y2}

			wave xA1gw = $xA1g
			xA1gw = 0.5*(elpsionxxw+elpsionyyw) //d_{x2+y2}


		//# Calculate V_max
			wavestats/Q elpxyw
			vv=max(abs(V_max),abs(V_min))
			dxyw[i] = vv
			//dxyw[i]=countaverage(elpxyw)
			//dxyw[i]=countaveragetop10(elpxyw)

			wavestats/Q xB1gw
			vv=max(abs(V_max),abs(V_min))
			dx2my2w[i] = vv
			//dx2my2w[i]=countaverage(xB1gw)
			//dx2my2w[i]=countaveragetop10(xB1gw)

			wavestats/Q xA1gw
			vv=max(abs(V_max),abs(V_min))
			dx2py2w[i] = vv
			//dx2py2w[i]=countaverage(xA1gw)
			//dx2py2w[i]=countaveragetop10(xA1gw)

			theta+=1
			i+=1
		while(i<90)


	//** killwaves
		//# kill rotated projected displacement matrix: ux uy ua ub
			killwaves output_uxw output_uyw
		//# kill rotated strain matrix: εxx εxy εyx εyy εaa εab εba εbb
			killwaves elpsionxxw elpsionxyw elpsionyxw elpsionyyw



	//display dxyw dx2my2w dx2py2w
	//ModifyGraph manTick(bottom)={0,45,0,0},manMinor(bottom)={0,50}
	//ModifyGraph grid(bottom)=2,gridHair(bottom)=1
	//ModifyGraph mode=4,marker=8,msize=6,mrkThick=3,rgb(ttt_B2g)=(0,0,65535),rgb(ttt_A1g)=(0,0,0)


End

Function Newrotate_forstrain_c(name,theta1)
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
		variable newsizex=round((dimsize(namew,0)*cos(abs(theta))+dimsize(namew,1)*sin(abs(theta))))
		variable newsizey=round((dimsize(namew,0)*sin(abs(theta))+dimsize(namew,1)*cos(abs(theta))))

			String outputLF = name+"_Rot"
			Make/O/N=(dimsize(xxlfw,0),3) sampleTripletRT
			sampleTripletRT[][0]=xxlfw[p]
			sampleTripletRT[][1]=yylfw[p]
			sampleTripletRT[][2]=zzlfw[p]
			ImageInterpolate/RESL={newsizex,newsizey}/DEST=$outputLF voronoi sampleTripletRT

	killwaves $xxlf $yylf $zzlf xgrid ygrid

	//di($outputLF)
end

Function projectstrainmatrix_c(ux,uy,theta)
	wave ux
	wave uy
	variable theta //degree

	string uthetax = nameofwave(ux)+"_theta_c"
	string uthetay = nameofwave(uy)+"_theta_c"

	duplicate/o ux $uthetax,$uthetay

	wave uthetaxw = $uthetax
	wave uthetayw = $uthetay

	variable i,j
	i=0
	do
		j=0
		do
			uthetaxw[i][j] = ux[i][j]*cos(theta*pi/180)+uy[i][j]*cos((90-theta)*pi/180)
			uthetayw[i][j] = ux[i][j]*cos((theta+90)*pi/180)+uy[i][j]*cos(theta*pi/180)
			j+=1
		while (j<dimsize(ux,1))
		i+=1
	while (i<dimsize(ux,0))
	//di(uthetaxw)
	//di(uthetayw)
end

Function umatrixsubbackground_c(ux,uy,order)
	wave ux
	wave uy
	variable order // =2

	string ulevelx = nameofwave(ux)+"_level_c"
	string ulevely = nameofwave(uy)+"_level_c"

	duplicate/o ux $ulevelx
	duplicate/o uy $ulevely

	wave ulevelxw = $ulevelx
	wave ulevelyw = $ulevely

	if (order == 0)
		ulevelxw = ux
		ulevelyw = uy
	else
		string destfit = "levelfit_"+nameofWave(ux)
		duplicate/O ux $destfit
		wave destfitw = $destfit
		CurveFit/Q/W=0 poly2D order, ux/D = destfitw
		ulevelxw -= destfitw
		killwaves destfitw

		destfit = "levelfit_"+nameofWave(uy)
		duplicate/O uy $destfit
		wave destfitw = $destfit
		CurveFit/Q/W=0 poly2D order, uy/D = destfitw
		ulevelyw -= destfitw
		killwaves destfitw
	endif
	//di(ulevelxw)
	//di(ulevelyw)
end

Function countaverage(mat)
	wave mat
	variable value,count, ave
	value = 0
	count = 0
	variable i,j
	i=0
	do
		j=0
		do
			if(mod(Round(mat[i][j]),1)!=0)
			else
				value+=abs(mat[i][j])
				count+=1
			endif
			j+=1
		while (j<dimsize(mat,1))
		i+=1
	while (i<dimsize(mat,0))
	ave = value/count
	return ave
end

function countaveragetop10(mat)
	wave mat
	variable value,count, ave
	value = 0
	count = 0
	variable i,j
	wavestats/Q mat

	i=0
	do
		j=0
		do
			if(mat[i][j]> V_max*0.98)

				value+=abs(mat[i][j])
				count+=1
			endif
			j+=1
		while (j<dimsize(mat,1))
		i+=1
	while (i<dimsize(mat,0))
	ave = value/count
	return ave
end