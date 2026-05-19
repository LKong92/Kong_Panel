#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//****************  Triangle lattice map the twist angle
//****************  Moving window technique
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////

Function ButtonProc_FFTTwistanglemap(ctrlName) : ButtonControl
	String ctrlName
	Execute "FFTTwistanglemap()"
end
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
//** Pre-FFT
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
Proc FFTTwistanglemap(name,Notes)
	String name = tpw()
	String notes = "The Topograph must be with unit nm"
	prompt name,"Name of wave to extract twist angle map"
	prompt notes,"Note"
	String/G anglemap
	anglemap =  name
	FFTranglemap($anglemap)
end
Function FFTranglemap(name)
	wave name

		duplicate/o name named
		func_NaN0(named)
		String FFTout
		FFTout = nameofWave(name) + "_FFT"

		FFT/out=3/DEST=$FFTout cvtcmplx(named)

		di($FFTout)
		color3sfft($tpw(),3)
		modifygraph width=350,height=350
		killwaves named

		Button geta title="Get A",proc=ButtonProc_GPAtwist
		Button getb title="Get B",proc=ButtonProc_GPBtwist
		Button getc title="Get C",proc=ButtonProc_GPctwist
		Button Calculate title="Go twist angle map",proc=ButtonProc_twistanglemap,pos={179,1},size={150,20}

end

Function FFTranglemap2(name)
	wave name

		duplicate/o name named
		func_NaN0(named)
		String FFTout
		FFTout = nameofWave(name) + "_FFT"

		FFT/out=3/DEST=$FFTout cvtcmplx(named)
		killwaves named
end

///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
//** Get the area for FFT peak fit
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////

Function ButtonProc_GPAtwist(ctrlName) : ButtonControl
	String ctrlName
	Execute "gpac_twist()"
end
Proc gpac_twist()
	Gpa_twist()
End
Function GpA_twist()
	getmarquee/W=$winname(0,1) left, bottom

	make/N=4/o PartialFFTselA
	PartialFFTselA={V_left,V_right,V_bottom,V_top}

	variable aveinverlen = sqrt(((V_left+V_right)/2)^2+((V_top+V_bottom)/2)^2)
	variable/G twistangle_latticelen1 = 2/(aveinverlen*sqrt(3))

	if (waveexists(PartialFFTselA) == 1)
		SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (0,0,0),fillpat= 0,linethick= 1.00;DelayUpdate
		DrawRect PartialFFTselA[0],PartialFFTselA[2],PartialFFTselA[1],PartialFFTselA[3]
	endif
end
///////////////////////////////////////////////////////////////////
Function ButtonProc_GPBtwist(ctrlName) : ButtonControl
	String ctrlName
	Execute "gpbc_twist()"
end

Proc gpbc_twist()
	GpB_twist()
End
Function GpB_twist()
	getmarquee/W=$winname(0,1) left, bottom

	make/N=4/o PartialFFTselB
	PartialFFTselB={V_left,V_right,V_bottom,V_top}

	variable aveinverlen = sqrt(((V_left+V_right)/2)^2+((V_top+V_bottom)/2)^2)
	variable/G twistangle_latticelen2 = 2/(aveinverlen*sqrt(3))

	if (waveexists(PartialFFTselB) == 1)
		SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (0,0,0),fillpat= 0,linethick= 1.00;DelayUpdate
		DrawRect PartialFFTselB[0],PartialFFTselB[2],PartialFFTselB[1],PartialFFTselB[3]
	endif
end
///////////////////////////////////////////////////////////////////
Function ButtonProc_GPCtwist(ctrlName) : ButtonControl
	String ctrlName
	Execute "gpCc_twist()"
end

Proc gpCc_twist()
	GpC_twist()
End
Function GpC_twist()
	getmarquee/W=$winname(0,1) left, bottom

	make/N=4/o PartialFFTselC
	PartialFFTselC={V_left,V_right,V_bottom,V_top}

	variable aveinverlen = sqrt(((V_left+V_right)/2)^2+((V_top+V_bottom)/2)^2)
	variable/G twistangle_latticelen3 = 2/(aveinverlen*sqrt(3))

	if (waveexists(PartialFFTselC) == 1)
		SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (0,0,0),fillpat= 0,linethick= 1.00;DelayUpdate
		DrawRect PartialFFTselC[0],PartialFFTselC[2],PartialFFTselC[1],PartialFFTselC[3]
	endif
end

///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
//** Read out the twist angle
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////

Function SWFFTgettwistangle(nameFFT)
	String nameFFT //"name of FFT of window image"
	String PartialFFTselA = "PartialFFTselA"
	String PartialFFTselB = "PartialFFTselB"
	String PartialFFTselC = "PartialFFTselC"

	variable AA = GpA_twistgofit(nameFFT,$PartialFFTselA)
	variable BB = GpB_twistgofit(nameFFT,$PartialFFTselB)
	variable CC = GpC_twistgofit(nameFFT,$PartialFFTselC)

	variable aveinverlen = (AA + BB + CC)/3
	variable avelatticelen = 2/(aveinverlen*sqrt(3))
	variable twistangle = 0.246*180/(pi*avelatticelen)
	//print aveinverlen
	//print avelatticelen
	make/n=(2)/o estimatetwsitstrain
	estimatetwsitstrain[0] = abs(AA-BB)/(AA+BB)
	estimatetwsitstrain[1] = atan2(AA,BB)

	return twistangle
end



Function GpA_twistgofit(nameFFT,marqueewave)
	String nameFFT
	wave marqueewave

	wave nameFFTw = $nameFFT
	String nametemp = nameFFT+"_f"
	duplicate/o nameFFTw $nametemp
	wave nametempw=$nametemp
	nametempw=nan;
	CurveFit/Q gauss2D nameFFTw(marqueewave[0],marqueewave[1])(marqueewave[2],marqueewave[3]) /D=nametempw(marqueewave[0],marqueewave[1])(marqueewave[2],marqueewave[3]);

	variable xa_G, ya_G, wx,wy
	string W_coef = "W_coef"
	wave W_coefw = $W_coef
	xa_G = W_coefw[2]
	ya_G = W_coefw[4]
	wx = W_coefw[3]
	wy = W_coefw[5]
	killwaves nametempw
	variable recilen = sqrt(xa_G^2+ya_G^2)
	Return recilen
end

Function GpB_twistgofit(nameFFT,marqueewave)
	String nameFFT
	wave marqueewave

	wave nameFFTw = $nameFFT
	String nametemp = nameFFT+"_f"
	duplicate/o nameFFTw $nametemp
	wave nametempw=$nametemp
	nametempw=nan;
	CurveFit/Q gauss2D nameFFTw(marqueewave[0],marqueewave[1])(marqueewave[2],marqueewave[3]) /D=nametempw(marqueewave[0],marqueewave[1])(marqueewave[2],marqueewave[3]);

	variable xa_G, ya_G, wx,wy
	string W_coef = "W_coef"
	wave W_coefw = $W_coef
	xa_G = W_coefw[2]
	ya_G = W_coefw[4]
	wx = W_coefw[3]
	wy = W_coefw[5]
	killwaves nametempw
	variable recilen = sqrt(xa_G^2+ya_G^2)
	Return recilen
end

Function GpC_twistgofit(nameFFT,marqueewave)
	String nameFFT
	wave marqueewave

	wave nameFFTw = $nameFFT
	String nametemp = nameFFT+"_f"
	duplicate/o nameFFTw $nametemp
	wave nametempw=$nametemp
	nametempw=nan;
	CurveFit/Q gauss2D nameFFTw(marqueewave[0],marqueewave[1])(marqueewave[2],marqueewave[3]) /D=nametempw(marqueewave[0],marqueewave[1])(marqueewave[2],marqueewave[3]);

	variable xa_G, ya_G, wx,wy
	string W_coef = "W_coef"
	wave W_coefw = $W_coef
	xa_G = W_coefw[2]
	ya_G = W_coefw[4]
	wx = W_coefw[3]
	wy = W_coefw[5]
	killwaves nametempw
	variable recilen = sqrt(xa_G^2+ya_G^2)
	Return recilen
end
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
//** Main Function
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
Function ButtonProc_twistanglemap(ctrlName) : ButtonControl
	String ctrlName
	Execute "twistanglemap_3qave()"
end
Proc twistanglemap_3qave(name2,size,threshold)
	String name2 = anglemap
	Variable size = 10*(twistangle_latticelen3+twistangle_latticelen2+twistangle_latticelen1)/3
	variable threshold = 2
	Prompt name2,"name of the topography"
	Prompt size,"Move window length (nm)"
	prompt threshold,"Threshold for twist angle (˚)"

	variable size1
	size1=1+round(size/dimdelta($name2,0))

	if(mod(size1,2) == 0)
	else
		size1+=1
	endif
	makechunkdatatamap(name2,size1,threshold)
end


Function makechunkdatatamap(name2,size1,threshold)
	String name2
	Variable size1
	variable threshold


	Wave topm=$name2

	variable Fulldimsizex = dimsize(topm,0)
	variable Fulldimsizey = dimsize(topm,1)
	variable i,j

	variable destdimx, destdimy

	destdimx=Fulldimsizex-size1+1
	destdimy=Fulldimsizey-size1+1

	make/o/N=(destdimx,destdimy) Twistanglemap //Map of phase of A FFT peak of gap map
	//Corrected scale is
	setscale/I x, dimoffset(topm,0)+dimdelta(topm,0)*(-1+size1/2) , (dimoffset(topm,0)+(dimsize(topm,0)-size1/2)*dimdelta(topm,0)),"",Twistanglemap
	setscale/I y, dimoffset(topm,1)+dimdelta(topm,1)*(-1+size1/2) , (dimoffset(topm,1)+(dimsize(topm,1)-size1/2)*dimdelta(topm,1)),"",Twistanglemap
	duplicate/o Twistanglemap Twiststrain
	duplicate/o Twistanglemap Twiststrainangle

	i=0
	do /// Sweep along y direction
			Print i,"/",(Fulldimsizey-size1+1)-1


		j=0
		do /// sweep along x direction
			duplicate/o/R=[j,j+size1-1][i,i+size1-1] topm topmw

			//Do Phase FFT on the subgap data
			FFTranglemap2(topmw)
			string subgapFFT = "topmw_FFT"
			Twistanglemap[j][i]=SWFFTgettwistangle(subgapFFT)
			if (Twistanglemap[j][i] > threshold)
				Twistanglemap[j][i] = nan
			else
			endif
			wave estimatetwsitstrain = $"estimatetwsitstrain"
			Twiststrain[j][i] = estimatetwsitstrain[0]
			Twiststrainangle[j][i] = estimatetwsitstrain[1]

			j+=1
		while(j<(Fulldimsizex-size1+1))
		i+=1
	while (i<(Fulldimsizey-size1+1))

	di(Twiststrain)
	ModifyGraph margin(right)=90
	ColorScale/C/N=text0/F=0/A=RB/X=-50.00/Y=10.00 frame=0.00,image=Twiststrain;
	ColorScale/C/N=text0 "\\Z16  Strain"

	di(Twiststrainangle)
	ModifyGraph margin(right)=90
	ColorScale/C/N=text0/F=0/A=RB/X=-50.00/Y=10.00 frame=0.00,image=Twiststrainangle;
	ColorScale/C/N=text0 "\\Z16  Strain angle"

	di(Twistanglemap)
	ModifyGraph margin(right)=90
	modifygraph width=400,height=400
	ModifyImage Twistanglemap ctab= {*,*,:Packages:NewColortable:gist_ncar,0}
	ColorScale/C/N=text0/F=0/A=RB/X=-30.00/Y=10.00 frame=0.00,image=Twistanglemap;
	ColorScale/C/N=text0 "\\Z16  Twist angle (º)"
End


///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
//** Calculate Moire wavelength
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
Function ButtonProc_calculateMoireLc(ctrlName) : ButtonControl
	String ctrlName
	Execute "calculateMoireLc()"
end
Proc calculateMoireLc(asample,asub,angle)
	variable asample = 2.657
	variable asub = 2.657
	variable angle = 1.1
	prompt asample, "lattice constant of top layer"
	prompt asub, "lattice constant of bottom layer"
	prompt angle, "twist angle ˚"
	calculateMoireL(asample,asub,angle)
end
Function calculateMoireL(asample,asub,angle)
	variable asample,asub,angle

	variable mismatch

	mismatch = abs(asample-asub)/asample
	//mismatch = abs(asample-asub)/asub

	variable moirelen


	moirelen = (1+mismatch)*asample/(sqrt(2*(1+mismatch)*(1-cos(angle*pi/180))+mismatch^2))
	print "The moire wavelength is " + num2str(moirelen)
end
