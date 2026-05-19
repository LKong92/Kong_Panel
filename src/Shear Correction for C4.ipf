#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#include <Global Fit 2>
//#################################################################################//
//                   Shear Correction Codes for C4-symmetric topography            //
//#################################################################################//

/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
//******         Global Fiting procedure to get the Shear parameters         ******//
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

//*********************************************************************************//
//** Before run this procedure, should use universal PreFFT and GetA/GetB to get **//
//** the information of the name of matrix to be corrected and sheared vector    **//
//** coordinates automatically, the FFT image is on the top                      **//
//*********************************************************************************//
//**      GetA is on the 1st quandrant, GetB should be on the 2nd Quandrant      **//
//*********************************************************************************//
//** Then we separate it to two steps,                                            *//
//** (1) Click "Fit Shear" to call C4sheargetpara(), this will fit the FFT Q1, Q2 *//
//**     to get the shear parameter. Maybe need multiple tries to fit good        *//
//** (2) Click "Go" to call C4shearcorrect(), calculate the correction matrix and *//
//**     get the corrected X and Y wave, do scatter data points interpolation     *//
//*********************************************************************************//
Function ButtonProc_C4sheargetparac(ctrlName) : ButtonControl
	String ctrlName
	Execute "C4sheargetparac()"
end
Proc C4sheargetparac(alphaini,ppini,thetaini,qq,hold)
	variable alphaini = 45//c1: alpha [The vector q1 angle]  [0,pi/2]
	variable ppini = 0.1 //c2: pp [The X shear parameter]
	variable thetaini = 1 //c3: theta [the angle of X shear axis] [0,pi/2]
	variable qq = 0 //C0: the |q|
	variable hold = 2
	Prompt alphaini,"α (Ideal vector angle from +x in degree)"
	Prompt ppini,"P (X shear parameter)"
	Prompt thetaini,"θ (Shear axis angle from +x in degree)"
	Prompt qq,"|q| (vector norm of the ideal lattice. ##Note## this should be real value, the length directly read from FFT should be multipied by 2pi. #This value affects only choose Hold |q| and put a non-zero value, other wise, the |q| will be automatically given by q1 and q2#)"
	Prompt hold,"Hold ideal |q| ?",popup "Yes;No"
	variable alphao = alphaini*pi/180
	variable thetao = thetaini*pi/180
	string name = namefftraw
	di2lf($namefftraw)
	string fftdata = name+"_FFT_Modula_INTER"
		//variable widthq=(2*sqrt(ln(2)))/avedia
	String wn =grabwin(fftdata)
	Dowindow/F $wn
	C4sheargetpara(name,alphao,ppini,thetao,qq,hold)
	print "C4sheargetparac("+num2str(alphaini)+","+num2str(ppini)+","+num2str(thetaini)+","+num2str(qq)+","+num2str(hold)+")"
	Print "in order of (α,P,θ,|q|,hold)"
	ContinitialShearFit()


	ModifyGraph/W=$grabwin(fftdata) width={Plan,1,bottom,left},height=0
	tilewindows/WINS=WinList("*", ";","WIN:3")/R/A=(2,2)/w=(3,0,68,100)


end
Function C4sheargetpara(name,alphaini,ppini,thetaini,qq,hold)
	String name
	variable alphaini //c1: alpha [The vector q1 angle]  [0,pi/2]
	variable ppini //c2: pp [The X shear parameter]
	variable thetaini //c3: theta [the angle of X shear axis] [0,pi/2]
	variable qq //c0: the vector norm of ideal q
	variable hold // select the mode for Hold |q| (1), not Hold (2)

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
		string coefiniguer = name+"_Fitresult"
		duplicate/o testiw $coefiniguer
		wave coefiniguerw=$coefiniguer

		edit coefiniguew coefiniguerw testiw coefnw constrainw
		cktable(winname(0,2))
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
			ModifyGraph mode($Gq1y)=3,marker($Gq1y)=1,rgb($Gq1y)=(65535,65535,0), mrkThick($Gq1y)=1
		endif

		string Gq2x =name+"_getq2x"
		string Gq2y =name+"_getq2y"
		make/N=1/o $Gq2x
		make/N=1/o $Gq2y
		wave Gq2xw = $Gq2x
		wave Gq2yw = $Gq2y
		if(ckwaveonfig(winname(0,1),Gq2y)==0)
			appendtograph Gq2yw vs Gq2xw
			ModifyGraph mode($Gq2y)=3,marker($Gq2y)=1,rgb($Gq2y)=(65535,65535,0), mrkThick($Gq2y)=1
		endif
		//edit Gq1xw Gq1yw Gq2xw Gq2yw

		coefiniguerw[0]=coefiniguew[0][0]
		coefiniguerw[1]=coefiniguew[1][0]*180/pi
		coefiniguerw[2]=coefiniguew[2][0]
		coefiniguerw[3]=coefiniguew[3][0]*180/pi
end

/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
//******                       Correct the shear image                       ******//
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_C4shearcorrectc(ctrlName) : ButtonControl
	String ctrlName
	Execute "C4shearcorrectc()"
end
Proc C4shearcorrectc(name,factor)
	string name = namefftraw
	variable factor = 1.5
	C4shearcorrect(name,factor)
end
Function C4shearcorrect(name,factor)
	String name
	variable factor

	string coefinigue = name+"_coefinigue"
	wave coefiniguew = $coefinigue

	//Make 2D rotational Matrix with angle -θ, and its matrix inverse
		wave namew = $name
		string rotatem = name+"_rotateM"
		make/N = (2,2)/o $rotatem
		wave rotatemw= $rotatem
		rotatemw={{cos(coefiniguew[3]),-sin(coefiniguew[3])},{sin(coefiniguew[3]),cos(coefiniguew[3])}}
		string rotatemi = name+"_rotateMi"
		Matrixinverse rotatemw
		string M_inverse="M_inverse"
		wave M_inversew = $M_inverse
		duplicate/o M_inversew $rotatemi
		wave rotatemiw= $rotatemi

	//Make X shear Matrix and its inverse
		string shearXm = name+"_shearXm"
		make/N = (2,2)/o $shearXm
		wave shearXmw= $shearXm
		shearXmw={{1,0},{coefiniguew[2],1}}
		string shearXmi = name+"_shearXmi"
		Matrixinverse shearXmw
		duplicate/o M_inversew $shearXmi
		wave shearXmiw= $shearXmi

	//Convert the coordinate to be corrected value
		string cw = "OCW_"+name // The 2x1 matrix of original coordinate on each pixel.
		make/N=2/o $cw
		wave cww = $cw

		string Xc = "Xc_"+name
		string Yc = "Yc_"+name
		duplicate/o namew $Xc
		duplicate/o namew $Yc
		wave Xcw = $Xc
		wave Ycw = $Yc
		Xcw = nan
		Ycw = nan

		variable i,j
		i=0
		do
			j=0
			do
				cww[0]=dimoffset(namew,0)+dimdelta(namew,0)*i
				cww[1]=dimoffset(namew,1)+dimdelta(namew,1)*j
				matrixop/o correctedr =  rotatemiw x shearXmiw x rotatemw x cww
				Xcw[i][j] = correctedr[0]
				Ycw[i][j] = correctedr[1]
				j+=1
			while(j<dimsize(namew,1))
			i+=1
		while(i<dimsize(namew,0))
		//dilf(Xcw)
		//dilf(Ycw)

	//** Scatter Data interpolation ******************
		string zzlf="zz_"+name
		duplicate/o namew $zzlf
		wave zzlfw = $zzlf
		Redimension/N=(dimsize(zzlfw,0)*dimsize(zzlfw,1)) zzlfw

		string xxlf="xx_"+name
		duplicate/o Xcw $xxlf
		wave xxlfw = $xxlf
		Redimension/N=(dimsize(xxlfw,0)*dimsize(xxlfw,1)) xxlfw

		string yylf="yy_"+name
		duplicate/o Ycw $yylf
		wave yylfw = $yylf
		Redimension/N=(dimsize(yylfw,0)*dimsize(yylfw,1)) yylfw

		//** scatterinterp(xxlfw,yylfw,zzlfw,namew,factor)
			String outputLF = "Shearcorrected_"+name
			Make/O/N=(dimsize(xxlfw,0),3) sampleTripletLF
			sampleTripletLF[][0]=xxlfw[p]
			sampleTripletLF[][1]=yylfw[p]
			sampleTripletLF[][2]=zzlfw[p]
			ImageInterpolate/RESL={(factor*dimsize(namew,0)),(factor*dimsize(namew,1))}/DEST=$outputLF voronoi sampleTripletLF

	//** Plot
		wave outputLFw = $outputLF
		func_NaN0(outputLFw)

		//string fftdata = name+"_FFT_Modula_INTER"
		//variable widthq=(2*sqrt(ln(2)))/avedia
		//String wn =grabwin(fftdata)
		//Dowindow/F $wn
		//HideInfo
		//cursor/K A
		//cursor/K B
		//ModifyGraph/W=$grabwin(fftdata) width={Plan,1,bottom,left},height=0


		di2lf(outputLFw)
		Label left "\\Z15Shear Corrected Image"
		tilewindows/WINS=grabwin(outputLF)/R/A=(1,1)/w=(36,50,68,100)

end
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////   Fit function q1x   ///////////////////////////////////////////////////
Function Shear_q1x(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = (qq*cos(alpha)+pp*qq*sin(theta)*cos(theta-alpha))+x
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 4
	//CurveFitDialog/ w[0] = qq
	//CurveFitDialog/ w[1] = alpha
	//CurveFitDialog/ w[2] = pp
	//CurveFitDialog/ w[3] = theta

	return (w[0]*cos(w[1])+w[2]*w[0]*sin(w[3])*cos(w[3]-w[1]))+x
End
////////////////////////   Fit function q1y   ///////////////////////////////////////////////////
Function Shear_q1y(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = (qq*sin(alpha)-pp*qq*cos(theta)*cos(theta-alpha))+x
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 4
	//CurveFitDialog/ w[0] = qq
	//CurveFitDialog/ w[1] = alpha
	//CurveFitDialog/ w[2] = pp
	//CurveFitDialog/ w[3] = theta

	return (w[0]*sin(w[1])-w[2]*w[0]*cos(w[3])*cos(w[3]-w[1]))+x
End
////////////////////////   Fit function q2x   ///////////////////////////////////////////////////
Function shear_q2x(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = (qq*cos(alpha+pi/2)+pp*qq*sin(theta)*cos(theta-(alpha+pi/2)))+x
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 4
	//CurveFitDialog/ w[0] = qq
	//CurveFitDialog/ w[1] = alpha
	//CurveFitDialog/ w[2] = pp
	//CurveFitDialog/ w[3] = theta

	return (w[0]*cos(w[1]+pi/2)+w[2]*w[0]*sin(w[3])*cos(w[3]-(w[1]+pi/2)))+x
End

////////////////////////   Fit function q2y   ///////////////////////////////////////////////////
Function shear_q2y(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = (qq*sin(alpha+pi/2)-pp*qq*cos(theta)*cos(theta-(alpha+pi/2)))+x
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 4
	//CurveFitDialog/ w[0] = qq
	//CurveFitDialog/ w[1] = alpha
	//CurveFitDialog/ w[2] = pp
	//CurveFitDialog/ w[3] = theta

	return (w[0]*sin(w[1]+pi/2)-w[2]*w[0]*cos(w[3])*cos(w[3]-(w[1]+pi/2)))+x
End
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
//******                  End of Correct the shear image                     ******//
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
//******                     Make a shear rotated image                      ******//
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
//*********************************************************************************//
//** This procedure is used to make sheared image with the shear axis rotated +θ **//
//** from the +x axis. The formula is (x_sheared,y_sheared)^T = R(-θ)^-1 x S x R(-θ) x (x',y')^T
Function ButtonProc_rotatedsheard(ctrlName) : ButtonControl
	String ctrlName
	Execute "Demo_rotatedshear()"
end
Proc Demo_rotatedshear(pp,theta)
	variable pp
	variable theta
	prompt pp,"P (X shear coef)"
	prompt theta,"θ (Shear axis angle from +x in degree)"
	make/N=(100,100)/o srtmatrix
	srtmatrix = abs(cos(x/(pi/2))-cos(y/(pi/2)))
	dilf(srtmatrix)
	rotatedshear("srtmatrix",pp,theta)
	Print "shear coef P = "+num2str(pp)
	Print "Shear axis angle θ = "+num2str(theta)
end

Function ButtonProc_rotatedshearc(ctrlName) : ButtonControl
	String ctrlName
	Execute "rotatedshearc()"
end
Proc rotatedshearc(name,pp,theta)
	String name = tpw()
	variable pp
	variable theta
	Prompt name,"Name of the wave to be manipulated"
	prompt pp,"P (X shear coef)"
	prompt theta,"θ (Shear axis angle from +x in degree)"
	rotatedshear(name,pp,theta)
	Print "rotatedshear("+"\""+name+"\","+num2str(pp)+","+num2str(theta)+")"
end

Function rotatedshear(name,pp,theta)
	String name
	variable pp
	variable theta
	//Prompt name,"Name of the wave to be manipulated"
	//prompt pp,"P (X shear coef)"
	//prompt theta,"θ (Shear axis angle from +x in degree)"
	variable theta1= theta*pi/180
	wave namew = $name

	//Make 2D rotational Matrix with angle -θ, and its matrix inverse
		wave namew = $name
		string rotatem = name+"_rotateM"
		make/N = (2,2)/o $rotatem
		wave rotatemw= $rotatem
		rotatemw={{cos(theta1),-sin(theta1)},{sin(theta1),cos(theta1)}}
		string rotatemi = name+"_rotateMi"
		Matrixinverse rotatemw
		string M_inverse="M_inverse"
		wave M_inversew = $M_inverse
		duplicate/o M_inversew $rotatemi
		wave rotatemiw= $rotatemi

	//Make X shear Matrix and its inverse
		string shearXm = name+"_shearXm"
		make/N = (2,2)/o $shearXm
		wave shearXmw= $shearXm
		shearXmw={{1,0},{pp,1}}
		string shearXmi = name+"_shearXmi"
		Matrixinverse shearXmw
		duplicate/o M_inversew $shearXmi
		wave shearXmiw= $shearXmi

	//Convert the coordinate to be corrected value
		string cw = "OCW_"+name // The 2x1 matrix of original coordinate on each pixel.
		make/N=2/o $cw
		wave cww = $cw

		string Xc = "Xc_"+name
		string Yc = "Yc_"+name
		duplicate/o namew $Xc
		duplicate/o namew $Yc
		wave Xcw = $Xc
		wave Ycw = $Yc
		Xcw = nan
		Ycw = nan

		variable i,j
		i=0
		do
			j=0
			do
				cww[0]=dimoffset(namew,0)+dimdelta(namew,0)*i
				cww[1]=dimoffset(namew,1)+dimdelta(namew,1)*j
				matrixop/o fakecc =  rotatemiw x shearXmw x rotatemw x cww
				Xcw[i][j] = fakecc[0]
				Ycw[i][j] = fakecc[1]
				j+=1
			while(j<dimsize(namew,1))
			i+=1
		while(i<dimsize(namew,0))
		//dilf(Xcw)
		//dilf(Ycw)

	//** Scatter Data interpolation ******************
		string zzlf="zz_"+name
		duplicate/o namew $zzlf
		wave zzlfw = $zzlf
		Redimension/N=(dimsize(zzlfw,0)*dimsize(zzlfw,1)) zzlfw

		string xxlf="xx_"+name
		duplicate/o Xcw $xxlf
		wave xxlfw = $xxlf
		Redimension/N=(dimsize(xxlfw,0)*dimsize(xxlfw,1)) xxlfw

		string yylf="yy_"+name
		duplicate/o Ycw $yylf
		wave yylfw = $yylf
		Redimension/N=(dimsize(yylfw,0)*dimsize(yylfw,1)) yylfw

		//** scatterinterp(xxlfw,yylfw,zzlfw,namew,factor)
			String outputLF = "RSheared_"+name
			Make/O/N=(dimsize(xxlfw,0),3) sampleTripletLF
			sampleTripletLF[][0]=xxlfw[p]
			sampleTripletLF[][1]=yylfw[p]
			sampleTripletLF[][2]=zzlfw[p]
			ImageInterpolate/RESL={(dimsize(namew,0)),(dimsize(namew,1))}/DEST=$outputLF voronoi sampleTripletLF

	//** Plot
		wave outputLFw = $outputLF
		func_NaN0(outputLFw)
		dilf(outputLFw)
		killwaves sampleTripletLF xxlfw yylfw zzlfw Xcw Ycw shearXmiw shearXmw rotatemw rotatemiw cww M_inversew fakecc
end
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
//******                     End of Make a shear rotated image               ******//
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
//*********************************************************************************//


/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
//******                 Make a only X-Sheared image                         ******//
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
//*********************************************************************************//
Function ButtonProc_makeshearXimagec(ctrlName) : ButtonControl
	String ctrlName
	Execute "makeshearXimagec()"
end
Proc makeshearXimagec(pp,name,factor)
	variable pp
	wave name
	variable factor
	Prompt pp,"X shear parameter"
	Prompt name,"name of the wave to be sheared"
	prompt factor,"interpolate factor"
	makeshearXimage(pp,name,factor)
end
Function makeshearXimage(pp,name,factor)
	variable pp
	wave name
	variable factor

	string shearM = "shearM"
	make/o/N=2 $shearM
	wave shearMw = $shearM
	shearMw={{1,0},{pp,1}}

	string Xc = "Xc_"+nameofwave(name)
	string Yc = "Yc_"+nameofwave(name)
	duplicate/o name $Xc
	duplicate/o name $Yc
	wave Xcw = $Xc
	wave Ycw = $Yc
	Xcw = nan
	Ycw = nan

	string cw = "OCW_"+nameofwave(name)
	make/N=2/o $cw
	wave cww = $cw
	variable i,j
	//wave convertc
	i=0
	do
		j=0
		do
		cww[0]=dimoffset(name,0)+dimdelta(name,0)*i
		cww[1]=dimoffset(name,1)+dimdelta(name,1)*j
		matrixop/o convertc = shearMw x cww
		//convertc[0] = cww[0]+pp*cww[1]
		//convertc[1] = cww[1]
		//print num2str(convertc[0])+","+num2str(convertc[1])

		Xcw[i][j] = convertc[0]
		Ycw[i][j] = convertc[1]
		j+=1
		while(j<dimsize(name,1))
	i+=1
	while(i<dimsize(name,0))
	//dilf(Xcw)
	//dilf(Ycw)

	//** Scatter Data interpolation ******************

		string zzlf="zz_"+nameofWave(name)
		duplicate/o name $zzlf
		wave zzlfw = $zzlf
		Redimension/N=(dimsize(zzlfw,0)*dimsize(zzlfw,1)) zzlfw

		string xxlf="xx_"+nameofWave(name)
		duplicate/o Xcw $xxlf
		wave xxlfw = $xxlf
		Redimension/N=(dimsize(xxlfw,0)*dimsize(xxlfw,1)) xxlfw

		string yylf="yy_"+nameofWave(name)
		duplicate/o Ycw $yylf
		wave yylfw = $yylf
		Redimension/N=(dimsize(yylfw,0)*dimsize(yylfw,1)) yylfw

		//** scatterinterp(xxlfw,yylfw,zzlfw,namew,factor)
				String outputLF = "Shear_"+nameofwave(name)
				Make/O/N=(dimsize(xxlfw,0),3) sampleTripletLF
				sampleTripletLF[][0]=xxlfw[p]
				sampleTripletLF[][1]=yylfw[p]
				sampleTripletLF[][2]=zzlfw[p]
				ImageInterpolate/RESL={(factor*dimsize(name,0)),(factor*dimsize(name,1))}/DEST=$outputLF voronoi sampleTripletLF

		//** Plot
			wave outputLFw = $outputLF
			func_NaN0(outputLFw)
			//dilf(outputLFw)
end

/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
//   An interactive GUI to contineously tuning the Coef trial for Shear Fitting
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
//*********************************************************************************//
//** To run this GUI, you need to finish PreFFT, getA, getB, and Fit Coeff
//** Then click the "c" button will lead to a interactive button on the FFT image
//** Please check the value change in Table while tuning the value of the button
//** After get the local minimum wanted, just click "GO".
//** This is helpful for change the fitting local minimum
//*********************************************************************************//
Function ButtonProc_ContinitialShearFit(ctrlName) : ButtonControl
	String ctrlName
	Execute "ContinitialShearFit()"
End
Proc ContinitialShearFit()
	string coefinigue = namefftraw+"_coefinigue"
	variable/G theta_sfit = round($coefinigue[3][0]*180/pi)
	variable/G alpha_sfit = round($coefinigue[1][0]*180/pi)
	variable/G pp_sfit = $coefinigue[2][0]
	string dow = namefftraw+"_FFT_Modula_INTER"
	string constrain = namefftraw+"_constrain"
	Dowindow/F $grabtable(constrain)
	Dowindow/F $grabwin(dow)
	//display;
	ModifyGraph margin(top)=45
	SetVariable setvar0 title="θ \r(trial)\r[degree]",size={100,20},value=theta_sfit,proc=SetVarProc_ciShearFit
	SetVariable setvar1 title="α \r(trial)\r[degree]",size={100,20},value=alpha_sfit,proc=SetVarProc_ciShearFit
	SetVariable setvar2 title="P \r(trial)",size={100,20},value=pp_sfit,proc=SetVarProc_ciShearFit
	SetVariable setvar0 pos={70,1};SetVariable setvar1 pos={280,1};SetVariable setvar2 pos={490,1}
	SetVariable setvar0 limits={-360,360,0.5},labelBack=(65535,65535,65535),pos={150,50}
	SetVariable setvar1 limits={-360,360,0.5},labelBack=(65535,65535,65535),pos={280,50}
	SetVariable setvar2 limits={-2,2,0.05},labelBack=(65535,65535,65535),pos={400,50}
end
Function SetVarProc_ciShearFit(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	execute "CisFitc()"
End
Proc CisFitc()
	variable alphao = alpha_sfit*pi/180
	variable thetao = theta_sfit*pi/180
	C4sheargetpara2(namefftraw,alphao,pp_sfit,thetao,0,2)
end
Function C4sheargetpara2(name,alphaini,ppini,thetaini,qq,hold)
	String name
	variable alphaini //c1: alpha [The vector q1 angle]  [0,pi/2]
	variable ppini //c2: pp [The X shear parameter]
	variable thetaini //c3: theta [the angle of X shear axis] [0,pi/2]
	variable qq //c0: the vector norm of ideal q
	variable hold // select the mode for Hold |q| (1), not Hold (2)

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
		//K0: |q| [the vector length]
		//K1: α [The vector q1 angle]  [0,pi/2]
		//variable alphaini = 45*pi/180
		//K2: P [The X shear parameter]
		//variable ppini = 0.3
		//K3: θ [the angle of X shear axis] [0,pi/2]
		//variable thetaini = 30*pi/180
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
		//if(ckwaveonfig(winname(0,1),Fitq1y)==0)
		//	appendtograph Fitq1yw vs Fitq1xw
		//	ModifyGraph mode=3,marker=8,rgb=(0,65535,65535), mrkThick=2
		//endif
			//if(ckwaveonfig(grabwin(FFTname),Fitq2y)==0)
		//if(ckwaveonfig(winname(0,1),Fitq2y)==0)
		//	appendtograph Fitq2yw vs Fitq2xw
		//	ModifyGraph mode=3,marker=8,rgb=(0,65535,65535), mrkThick=2
		//endif
		coefiniguerw[0]=coefiniguew[0][0]
		coefiniguerw[1]=coefiniguew[1][0]*180/pi
		coefiniguerw[2]=coefiniguew[2][0]
		coefiniguerw[3]=coefiniguew[3][0]*180/pi
		//print "tt"
end

/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
//   End of the GUI demo procedure
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////




/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
//   A quick Template procedure to make an interactive GUI
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
Proc calccshearparameter()
	variable/G theta1
	variable/G alpha1
	variable/G pp1
	display;
	SetVariable setvar0 title="theta",size={100,20},value=theta1,proc=SetVarProc_caclcshearx
	SetVariable setvar1 title="alpha",size={100,20},value=alpha1,proc=SetVarProc_caclcshearx
	SetVariable setvar2 title="pp1",size={100,20},value=pp1,proc=SetVarProc_caclcshearx
	SetVariable setvar0 limits={-360,360,1}
	SetVariable setvar1 limits={-360,360,1}
	SetVariable setvar2 limits={-2,2,0.05}
end
Function SetVarProc_caclcshearx(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	execute "caclcshearxc()"
End
Proc caclcshearxc()
	caclcshearx(theta1,alpha1,pp1)
end
Function caclcshearx(theta1,alpha1,pp1)
	variable theta1
	variable alpha1
	variable pp1
end
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
//   End of the GUI demo procedure
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
//   Shear Correction on the whole 3D matrix
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Shearmat3d(ctrlName) : ButtonControl
	String ctrlName
	Execute "Shearmat3d()"
End
Proc Shearmat3d(indicate,mat3dn,refwave,factor)
	String indicate="Please Do shear correction on reference 2D wave First"
	string mat3dn = stringfromList(0,getall3dwave())// name of the mat3d to be sheared = "g2_001_G"
	string refwave = replaceString("_G",mat3dn,"_T")
	variable factor = 1.5
	Prompt indicate,"Indication"
	prompt mat3dn,"The 3D matrix to be sheared"
	prompt refwave,"The 2D reference matrix"
	prompt factor,"Scatter Interp factor (must be the same as refwave shear)"

	shearall(mat3dn,refwave,factor)
end

Function shearall(mat3dn,refwave,factor)
	string mat3dn // name of the mat3d to be sheared = "g2_001_G"
	string refwave // name of the shear reference wave = "g2_001_T"  string barename = replaceString("_G",mat3dn,"_T")
	variable factor

	string slicename = "s_"+mat3dn
	wave mat3dnw = $mat3dn
	make/N=(dimsize(mat3dnw,0),dimsize(mat3dnw,1))/o $slicename
	setscale/p x,dimoffset(mat3dnw,0),dimdelta(mat3dnw,0),"",$slicename
	setscale/p y,dimoffset(mat3dnw,1),dimdelta(mat3dnw,1),"",$slicename
	wave slicenamew = $slicename


	string outslice = "Shearcorrected_"+refwave
	wave outslicew = $outslice


	string mat3daftershear = mat3dn+"S"
	make/N=(dimsize(outslicew,0),dimsize(outslicew,1),dimsize(mat3dnw,2))/o $mat3daftershear
	setscale/p x,dimoffset(outslicew,0),dimdelta(outslicew,0),"",$mat3daftershear
	setscale/p y,dimoffset(outslicew,1),dimdelta(outslicew,1),"",$mat3daftershear
	setscale/p z,dimoffset(mat3dnw,2),dimdelta(mat3dnw,2),"",$mat3daftershear
	wave mat3daftershearw = $mat3daftershear

	variable znum = dimsize(mat3dnw,2)
	variable i = 0
	do
		slicenamew[][] = mat3dnw[p][q][i]
		//DPdata2(slicename,1,19,-1,0)
		//C4shearcorrect2(slicename,1)


		//** Scatter Data interpolation ******************
		string zzlf="zz_"+slicename
		duplicate/o slicenamew $zzlf
		wave zzlfw = $zzlf
		Redimension/N=(dimsize(zzlfw,0)*dimsize(zzlfw,1)) zzlfw

		string xxlf="xx_"+refwave
		wave xxlfw = $xxlf

		string yylf="yy_"+refwave
		wave yylfw = $yylf

		//** scatterinterp(xxlfw,yylfw,zzlfw,namew,factor)
			String outputLF = "sc_"+slicename
			Make/O/N=(dimsize(xxlfw,0),3) sampleTripletLF
			sampleTripletLF[][0]=xxlfw[p]
			sampleTripletLF[][1]=yylfw[p]
			sampleTripletLF[][2]=zzlfw[p]
			ImageInterpolate/RESL={(factor*dimsize(slicenamew,0)),(factor*dimsize(slicenamew,1))}/DEST=$outputLF voronoi sampleTripletLF
			wave outputLFw = $outputLF
			func_zeroNaN(outputLFw)
			mat3daftershearw[][][i]=outputLFw[p][q]
		//print i
		i+=1
	while(i<znum)
	print mat3daftershear
end



Function DPdata2(name,flag,stp,edp,numbercut)//testing finished
	string name
	variable flag //delete k demision(raw)=0 delete E demision(colum) =1
	variable stP, edP// delete from point(stp) to point(edP)
	variable numbercut // number of cuts
	String matname,dest
	variable j
	variable xstart,xend, ystart,yend
	//variable times
	variable x1, x2, x3,x4, y1, y2, y3, y4

		matname= name//+num2str(j+1)
		dest="databig_"+name
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
end

/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
// Calculate lattice strain (a-b)/a after shear
// The lattice can be at arbitary angle compare to the shear axis
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_cal_strainbyshearc(ctrlName) : ButtonControl
	String ctrlName
	Execute "cal_strainbyshearc()"
end

Proc cal_strainbyshearc(angleoff,sh)
	variable angleoff // degree
	variable sh = 0.1 // shear strength
	prompt angleoff, "The angle from shear axis-X to one of the lattice axis (˚)###### it always equal to α-θ [lattice Q angle - shear axis angle] "
	prompt sh, "Shear strength"
	cal_strainbyshear(angleoff,sh)
end


Function cal_strainbyshear(angleoff,sh)
	variable angleoff // degree
	variable sh // shear strength

	variable angleoffpi= angleoff*pi/180
	variable angleoff90pi = (90-angleoff)*pi/180

	// Define A B C coordinate

	variable Ax_f,Ay_f,Bx_f,By_f,Cx_f,Cy_f
	variable Ax,Ay,Bx,By,Cx,Cy

		//Point A
		Ax = 0
		Ay = 0

		shearxy(Ax,Ay,sh,0)
		wave M_productw = $"M_product"
		Ax_f = M_productw[0][0]
		Ay_f = M_productw[1][0]


		//Point B
		Bx = cos(angleoffpi)
		By = sin(angleoffpi)

		shearxy(Bx,By,sh,0)
		wave M_productw = $"M_product"
		Bx_f = M_productw[0][0]
		By_f = M_productw[1][0]


		//Point C
		Cx = cos(angleoff90pi)
		Cy = sin(angleoff90pi)

		shearxy(Cx,Cy,sh,0)
		wave M_productw = $"M_product"
		Cx_f = M_productw[0][0]
		Cy_f = M_productw[1][0]

	//Calculate the length after rotate
		variable x_rotated, y_rotated

		x_rotated = sqrt((Ax_f-Bx_f)^2+(Ay_f-By_f)^2)
		y_rotated = sqrt((Ax_f-Cx_f)^2+(Ay_f-Cy_f)^2)

	//Calculate strain
		variable strain_shear
		strain_shear = 100*abs(y_rotated-x_rotated)/max(y_rotated,x_rotated)

	print "X lattice length is "+num2str(x_rotated)+"; Y lattice length is "+num2str(y_rotated)  +"; Strain is "+num2str(strain_shear)+" %"
end

Function/Wave shearxy(x0,y0,sh,Dis)
	variable x0
	variable y0
	variable sh
	variable Dis

	make/n=(2,2)/o shearmatrix
	shearmatrix={{1,0},{sh,1}}
	make/n=(2,1)/o xyinitial
	xyinitial={{x0,y0}}
	matrixmultiply shearmatrix,xyinitial
	killwaves shearmatrix xyinitial
	wave M_productw = $"M_product"
	if (Dis == 0)
	else
		Print "x_r = "+num2str(M_productw[0][0])
		Print "y_r = "+num2str(M_productw[1][0])

	endif
	return M_productw
end



/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
//   END of Shear Correction on the whole 3D matrix
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////