#pragma rtGlobals=3		// Use modern global access method and strict wave access.
/////////////////////////////////////////////////////////////////////////
Function ButtonProc_FFTpro(ctrlName) : ButtonControl
	String ctrlName
	Execute " FFTpro()"
end
Proc FFTpro(mat,number,start,a,theta,unit)
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
		FFTsymind(matdest)
		duplicate/o M $matt
		i+=1
	while(i<number)
	di($matt)
	if (unit==2)
		setscale/P x, dimoffset($matt,0)/(0.5/a),dimdelta($matt,0)/(0.5/a),"",$matt
		setscale/P y, dimoffset($matt,1)/(0.5/a),dimdelta($matt,1)/(0.5/a),"",$matt

		Label bottom "\\Z20\\F'times'k\\B\\Z20x\\M\\Z20 (\F'symbol'p / \F'times'a)"
		Label left "\\Z20\\F'times'k\\B\\Z20y\\M\\Z20 (\F'symbol'p / \F'times'a)"

		SetAxis left -0.1,0.1;SetAxis bottom -0.1,0.1
		ModifyGraph width={Plan,1,bottom,left}
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
		append linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
	endif
	if (unit==1)
		setscale/P x, dimoffset($matt,0)/(0.5/a),dimdelta($matt,0)/(0.5/a),"",$matt
		setscale/P y, dimoffset($matt,1)/(0.5/a),dimdelta($matt,1)/(0.5/a),"",$matt

		setscale/P x, dimoffset($matt,0)*(pi/a),dimdelta($matt,0)*(pi/a),"",$matt
		setscale/P y, dimoffset($matt,1)*(pi/a),dimdelta($matt,1)*(pi/a),"",$matt

		Label bottom "\\Z20\\F'times'k\\B\\Z20x\\M\\Z20  (Å\S-1\M\F'times'\Z20)"
		Label left "\\Z20\\F'times'k\\B\\Z20y\\M\\Z20  (Å\S-1\M\F'times'\Z20)"

		SetAxis left -0.1,0.1;SetAxis bottom -0.1,0.1
		ModifyGraph width={Plan,1,bottom,left}
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
		append linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
	endif
end
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
Function FFTsymind(mat)
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
///////////////////////////////////////////////////////////////////////////

Function ButtonProc_C4symFFT(ctrlName) : ButtonControl
	String ctrlName
	Execute "C4symFFT()"
end


proc C4symFFT(name,num,theta)
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
	di($name6)
	Label bottom "\\Z12\\F'times'k\\B\\Z12x\\M\\Z12  (Å\S-1\M\F'times'\Z12)"
	Label left "\\Z12\\F'times'k\\B\\Z12y\\M\\Z12  (Å\S-1\M\F'times'\Z12)"
	SetAxis left -0.1,0.1;SetAxis bottom -0.1,0.1
	ModifyGraph width={Plan,1,bottom,left}
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
	append linefft1, linefft2,linefft3,linefft4,linefft5,linefft6,linefft7,linefft8,linefft0,linefft00
	ModifyImage $name6 ctab= {*,*,BlueGreenOrange,0}
	$name6*=1-exp(-(x^2+y^2)/0.0001)
	matrixfilter avg $name6
	matrixfilter avg $name6
	matrixfilter avg $name6
	matrixfilter avg $name6
	modifygraph width=150,height=150
	modifygraph width=0,height=0
	ModifyGraph width={Plan,1,bottom,left}
end

// to suppress central brightness : fft4foldsym*=1-0.5*exp(-(x^2+y^2)/0.1)
//
//to suppress vertical brightness: fft4foldsym*=1-abs((x+y)^2/4-(x-y)^2/4)
//
///////////////////////////////////////////////////////////////////////////
//
//e.g.
//FFTpro("data",1,80,15,4.2,29.283)/
// C4symFFT("datafftsym15",15,29.283)
Function ButtonProc_multi4fold(ctrlName) : ButtonControl
	String ctrlName
	Execute " multi4fold()"
end

proc multi4fold(num,name,lattice,theta)
	variable num
	string name
	variable lattice=3.8
	variable theta=29.283
	string name1, name2
	variable i
	i=0
	do
		name1=name+num2str(I+1)
		name2="datafftsym"+num2str(I+1)
		FFTpro(name,1,i+1,lattice,theta,1)
		C4symFFT(name2,i+1,theta)
		i+=1
	while(I<num)
end

//************************************************************************************************//
//************************************************************************************************//
//This procedure is used to make non Nxm (m <N) matrix to become (N x N-1) matrix, after this you can make C4 symmetric operation
//************************************************************************************************//
Function ButtonProc_c4special(ctrlName) : ButtonControl
	String ctrlName
	Execute " c4special()"
	end
proc c4special(name1,point)
	string name1="datafftsym"
	variable point //point number of the short dimension
	prompt name1,"Name of the data to interpolate"
	prompt point,"point number of the short dimension"

	string wavenamea,wavenameb,namee,wavenamec
	variable i,j,k
	string name
	name="real"+name1
	make/o/N=(dimsize($name1,0),dimsize($name1,1)) $name
	$name=sqrt(real($name1)^2+imag($name1)^2)
	setscale/i x,dimoffset($name1,0),dimoffset($name1,0)+dimdelta($name1,0)*(dimsize($name1,0)-1),"",$name
	setscale/i y,dimoffset($name1,1),dimoffset($name1,0)+dimdelta($name1,1)*(dimsize($name1,1)-1),"",$name

	namee=name1+"L1"
	make/o/N=(dimsize($name1,0),dimsize($name1,0)-1) $namee

	i=0
	do
		wavenamea="tempor"+num2str(i)
		wavenameb="tempor"+"_L"+num2str(i)
		make/o/N=(point) $wavenamea
		$wavenamea[]=$name[i][p]
		interpolate2/n=(dimsize($name1,0)-1) /t=1/Y=$wavenameb $wavenamea
		i+=1
	while(I<dimsize($name1,0))
	//j=0
	//do
	///k=0
	//do
	//wavenamec="tempor"+"_L"+num2str(j)
	//$namee[j][k]=$wavenamec[k]
	//K+=1
	//while(k<dimsize($wavenamec,0))
	//J+=1
	//while(j<129)
	makematrix(namee)
	setscale/i x,dimoffset($name,0),dimoffset($name,0)+dimdelta($name,0)*(dimsize($name,0)-1),"",$namee
	setscale/i y,dimoffset($name,1),dimoffset($name,0)+dimdelta($name,1)*(dimsize($name,1)-1),"",$namee
	di($namee)
end

function makematrix(namee)
	string namee
	string wavenamec
	variable j,k
	wave N=$namee

	j=0
	do
		k=0
		do
			wavenamec="tempor"+"_L"+num2str(j)
			wave M=$wavenamec
			N[j][k]=M[k]
			K+=1
		while(k<dimsize($wavenamec,0))
		J+=1
	while(j<dimsize($namee,0))
end
//************************************************************************************************//
//************************************************************************************************//
//************************************************************************************************//
//************************************************************************************************//
//
//  This procesure is designed for Interpolate a 2D matrix to arbiratary points.
//************************************************************************************************//
Function ButtonProc_twoDlinterp2Dall(ctrlName) : ButtonControl
	String ctrlName
	Execute " interp2Dall()"
end
Proc interp2Dall(name,number,xpoint,ypoint)
	String name = "data"
	variable number
	variable xpoint
	variable ypoint

	variable i
	string mat
	i=1
	do
		mat=name+num2str(i)
		twoDinterpolatexyf(mat,xpoint,ypoint)
		i+=1
	while(i<number+1)
end
//************************************************************************************************//
//************************************************************************************************//
//************************************************************************************************//
Function ButtonProc_twoDinterpolatel(ctrlName) : ButtonControl
	String ctrlName
	Execute " twoDinterpolatexy()"
end

Proc twoDinterpolatexy(name,xpoint,ypoint)
	string name=tpw()
	variable xpoint
	variable ypoint
	prompt name,"Name of Raw Data"
	Prompt xpoint,"Point number of x you wanted "
	Prompt ypoint,"Point number of y you wanted "

	twoDinterpolatexyf(name,xpoint,ypoint)
end

Function twoDinterpolatexyf(name,xpoint,ypoint)
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
	di($name2)
end
Function twoDinterpolatexyf2(name,xpoint,ypoint)
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
	name2=name+"_1"
	make/O/N=(xpoint,ypoint) $name2
	makematrix3(name2,xpoint,ypoint)
	setscale/I x,dimoffset($name,0),dimoffset($name,0)+dimdelta($name,0)*(dimsize($name,0)-1),""$name2
	setscale/I y,dimoffset($name,1),dimoffset($name,1)+dimdelta($name,1)*(dimsize($name,1)-1),""$name2
end

////////////////////////////////////////////////////////
Function makematrix2(namee,sizex,sizey)
	string namee
	variable sizex,sizey
	string wavenamec
	variable j,k
	wave N=$namee
	j=0
	do
		wavenamec="curve1L_"+num2str(j)
		wave M=$wavenamec
		N[j][]=M[q]
		KILLWAVES M
		J+=1
	while(j<sizex)
end
////////////////////////////////////////////////////////
Function makematrix3(namee,sizex,sizey)
	string namee
	variable sizex,sizey
	string wavenamec
	variable j,k
	wave N=$namee
	j=0
	do
		wavenamec="curve2L_"+num2str(j)
		wave M=$wavenamec
		N[][j]=M[p]
		KILLWAVES M
		J+=1
	while(j<sizey)
end
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
//************************************************************************************************//
//This procedure will only interpolate y axis
//************************************************************************************************//
Function ButtonProc_twoDinterpy(ctrlName) : ButtonControl
	String ctrlName
	Execute " twoDinterpy()"
	end
proc twoDinterpy(name,ypoint)
	string name=tpw()
	variable ypoint
	prompt name,"Name of Raw Data"
	Prompt ypoint,"Point number of y points you wanted "
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
		killwaves  $curve1

		i+=1
	while(i<sizex)
	name1=name+"1"
	make/O/N=(sizex,ypoint) $name1
	makematrix2(name1,sizex,ypoint)

	setscale/I x,dimoffset($name,0),dimoffset($name,0)+dimdelta($name,0)*(dimsize($name,0)-1),""$name1
	setscale/I y,dimoffset($name,1),dimoffset($name,1)+dimdelta($name,1)*(dimsize($name,1)-1),""$name1
	di($name1)
	//ModifyGraph width={Plan,1,bottom,left}
end

Function twoDinterpyf(name,ypoint)
	string name
	variable ypoint
	//prompt name,"Name of Raw Data"
	//Prompt ypoint,"Point number of y points you wanted "
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
		wave curve1w = $curve1
		wave namew = $name
		curve1w[]=namew[i][p]
		interpolate2/n=(ypoint) /t=1/Y=$curve11 $curve1
		killwaves  curve1w

		i+=1
	while(i<sizex)
	name1=name+"_1"
	make/O/N=(sizex,ypoint) $name1
	makematrix2(name1,sizex,ypoint)

	setscale/I x,dimoffset($name,0),dimoffset($name,0)+dimdelta($name,0)*(dimsize($name,0)-1),""$name1
	setscale/I y,dimoffset($name,1),dimoffset($name,1)+dimdelta($name,1)*(dimsize($name,1)-1),""$name1
	//di($name1)
	//ModifyGraph width={Plan,1,bottom,left}
end


//************************************************************************************************//
//************************************************************************************************//
Function ButtonProc_Complextoreal(ctrlName) : ButtonControl
	String ctrlName
	Execute " Complextoreal()"
	end
proc Complextoreal(name1,select)
	string name1 = tpw()
	variable select
	prompt name1,"Name of Complex Matrix"
	prompt select,"Which Mode",popup "Modula;Real;Imaginary"
	Complextorealf($name1,select)
	ModifyGraph width={Plan,1,bottom,left}
end

Function Complextorealf(name1w,select)
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
	di(namew)
	color3s_for3dFFT(namew,15)

end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Proc cvtcmplx2(data)
	string data

	String name
	name = "c_"+data
	make/C/O/N=(dimsize($data,0),dimsize($data,1)) $name
	setscale/p x,dimoffset($data,0),dimdelta($data,0),"",$name
	setscale/p y,dimoffset($data,1),dimdelta($data,1),"",$name
	$name = cmplx($data,0)
end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function/Wave cvtcmplx(data)
	wave data
	String name
	name = "c_"+nameofwave(data)

	matrixop/o $name = cmplx(data,0)
	wave namew = $name

	setscale/p x,dimoffset(data,0),dimdelta(data,0),"",namew
	setscale/p y,dimoffset(data,1),dimdelta(data,1),"",namew
	Return namew
end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_D2symetric(ctrlName) : ButtonControl
	String ctrlName
	Execute " D2symetric()"
	end
proc D2symetric(name2,centralx,centraly)
	string name2="datafftsym"
	variable centralx
	variable centraly
	prompt name2,"Data name"
	string name1,name
	name1="backup_"+name
	name=name2+"modulaD2"
	make/o/N=(dimsize($name2,0),dimsize($name2,1)) $name
	$name=sqrt(real($name2)^2+imag($name2)^2)
	setscale/i x,dimoffset($name2,0),dimoffset($name2,0)+dimdelta($name2,0)*(dimsize($name2,0)-1),"",$name
	setscale/i y,dimoffset($name2,1),dimoffset($name2,1)+dimdelta($name2,1)*(dimsize($name2,1)-1),"",$name
	xreflectmatrix(name,centralx)
	yreflectmatrix(name,centraly)
	duplicate/o $name $name1
	$name*=2
	$name+=namex
	$name+=namey
	$name/=4
	di($name)
	SetAxis left -4,4;DelayUpdate
	SetAxis bottom -4,4
	ModifyImage $name ctab= {0,5.9e-08,BlueGreenOrange,0}
	append linefft1 linefft2 linefft3 linefft4 linefft5 linefft6 linefft7 linefft8
	Label left "\\Z20\\F'times'k\\B\\Z20y\\M\\Z20  (Å\\S-1\\M\\F'times'\\Z20)";DelayUpdate
	Label bottom "\\Z20\\F'times'k\\B\\Z20y\\M\\Z20  (Å\\S-1\\M\\F'times'\\Z20)"
end
/////////////////////////////////////////////////////
Function xreflectmatrix(name,xpoint)
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

/////////////////////////////////////////////////////
Function yreflectmatrix(name,ypoint)
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
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_shrinktocube(ctrlName) : ButtonControl
	String ctrlName
	Execute " shrinktocube()"
end
proc shrinktocube(name,num,point)
	string name="data"
	variable num=dimsize(file_name,0)-1
	variable point=95

	variable i
	i=0
	do
		cutklarge2(name,i+1,point)
		cutElarge2(name,i+1,point)
		i+=1
	while (i<num)
end

proc cutklarge2(name,index,point)
	string name
	variable index
	variable point=95
	//point=95
	DeletePdata(name,1,index,point,-1,0)
end

proc cutElarge2(name,index,point)
	string name
	variable index
	variable point=95
	//point=95
	DeletePdata(name,2,index,point,-1,0)
end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
/////////// DO 1D FFT (x) to a linecut ///////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
Function ButtonProc_linecutFFT(ctrlName) : ButtonControl
	String ctrlName
	Execute "FFTL2c()"
	end
Proc FFTL2c(name,sel)
	String name = tpw()
	variable sel = 2
	prompt name,"Data Name"
	prompt sel,"Modes",popup "FFT x;FFT y"
    FFTL2($name,sel)
end
Function FFTL2(name,sel)
	wave name
	variable sel // 1 for x, 2 for y
	func_NaN0(name)
	String FFTout,nameout
	variable pc,qc

	if (sel == 1)
		FFTout = nameofWave(name) + "_FFTx"
		FFT/WINF=Hanning/COLS/DEST=$FFTout cvtcmplx(name)
		Complextorealf($FFTout,1)
		//SetAxis bottom 0,*


	endif
	if (sel == 2)
		FFTout = nameofWave(name) + "_FFTy"
		FFT/WINF=Hanning/ROWS/DEST=$FFTout cvtcmplx(name)
		Complextorealf($FFTout,1)
		matrixtranspose $tpw()
		//SetAxis left 0,*

		//Remove the q(E) = 0 intensity
		pc = round((-dimoffset($tpw(),0))/dimdelta($tpw(),0))
		qc=round((-dimoffset($tpw(),1))/dimdelta($tpw(),1))
		nameout =FFTout+"_Modula"
		wave nameoutw = $nameout
		nameoutw[pc][] = mean(nameoutw)
	endif
end
///////////////////////////////////////////////////////////////////////////////////
//Following is a home made old version
//This do slice by slice, faster but only have half
///////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_linecutFFT2(ctrlName) : ButtonControl
	String ctrlName
	Execute " linecutFFT()"
end
Proc linecutFFT(namedata) // input the name of the linecut
	string namedata

	variable dimsizex,dimsizey,dimdeltax,dimdeltay,startx, endx,numx,startp, endp

	dimsizex = dimsize($namedata,0);
	dimsizey = dimsize($namedata,1);
	dimdeltax= dimdelta($namedata,0);
	dimdeltay= dimdelta($namedata,1);
	if (mod(dimsizex,2) == 0)
		startx = dimoffset($namedata,0)
		endx = dimoffset($namedata,0) + (dimsizex-1)*dimdeltax
		numx = dimsizex
		startp = 0
		endp = dimsizex-1
	else
		startx = dimoffset($namedata,0)+dimdeltax
		endx = dimoffset($namedata,0) + (dimsizex-1)*dimdeltax
		numx = dimsizex-1
		startp = 1
		endp = dimsizex-1

	endif
	string matslice
	string FFtslice,namee
	namee= "FFT_slice"+namedata
	variable i
	i=0
	do
	matslice="slice"+num2str(i+1)
	FFtslice=namee+num2str(i+1)

	make/N=(dimsizex)/o $matslice

	$matslice[]=$namedata[p][i]

	setscale/p x,dimoffset($namedata,0),dimdelta($namedata,0),"",$matslice

	FFT/OUT=3/RP=[startp,endp]/WINF=Hanning/DEST=$FFTslice  $matslice
	killwaves $matslice
	//display $matslice

	i+=1
	while (i< dimsizey)
	linkstsmapfftlinecut(namee,dimsizey,1)
	modifygraph width=250, height=450
	modifygraph width=0, height=0
	string namelinecut = namee+"_maplinecut"

	$namelinecut[0][]=nan
	$namelinecut[1][]=nan
	$namelinecut[2][]=nan
	//maplinecut[3][]=nan
	//maplinecut[4][]=nan
	//maplinecut[5][]=nan
end

Function linkstsmapfftlinecut(name,num,startnum)
	string name
	variable num
	variable startnum

	variable i,j
	string mat,mat0,mat1
	mat0=name+num2str(1)
	wave m=$mat0
	mat1 = name+"_maplinecut"
	make/o/n=(dimsize(m,0),num) $mat1
	wave mat11=$mat1

	i=0
	do
		j=0
		do
			mat=name+num2str(i+startnum)
			wave n=$mat
			mat11[j][i]=n[j]
			j+=1
		while(j<dimsize(m,0))
		i+=1
	while(i<num)
	setscale/P x, dimoffset(m,0),dimdelta(m,0),"",mat11
	di(mat11)

end
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
/////////// End DO 1D FFT (x) to a linecut ///////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Normal FFT for arbitary data points and all value is positive
//1. Convert the wave to be complex wave "cvtcmplx(name)"
//2. Do complex FFT to this converted wave, it will get a full sized FFT image
//3. use Complextorealf() to convert the complex wave back magnitude wave and display
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_FFTr(ctrlName) : ButtonControl
	String ctrlName
	Execute "FFTrc()"
end
Proc FFTrc(name,sel)
	String name=tpw()
	variable sel
	prompt name,"Data Name"
	prompt sel,"Apply Window Function?",popup,"No;Yes"

   variable/G sel_FFT = sel-1
   variable/G interp_FFT
   FFTr($name,sel)
   	Button Mapmarque win=$winname(1,1),pos={1,1},size={85,12},fsize=10,title="Marqueed Area",proc=ButtonProc_Fmqfft
   	Button FFTwhole win=$winname(1,1),pos={90,1},size={80,12},fsize=10,title="Normal",proc=ButtonProc_Fmqfftnormal
	SetVariable setvarwin win=$winname(1,1),title="Hanning",size={65,12},pos={173,1},value=sel_FFT,limits={0,1,1}//,proc=SetVarProc_Fmqffthanning
	SetVariable setvarwin2 win=$winname(1,1),title="Interp",size={65,12},value=interp_FFT,limits={0,1,1}
end

Function ButtonProc_Fmqfftnormal(ctrlName) : ButtonControl
	String ctrlName
	drawaction delete
	variable/G sel_FFT
	variable/G interp_FFT

	FFTrls2($tpw(),sel_FFT+1,interp_FFT)
end

Function ButtonProc_Fmqfft(ctrlName) : ButtonControl
	String ctrlName
	Execute "Frommarqueegetsubmatrixsc2()"
end
Proc Frommarqueegetsubmatrixsc2()
	string name = tpw()
	Frommarqueegetsubmatrixs2(name)
	string nameout = "SelectA_"+name
	FFTrls2($nameout,sel_FFT+1,interp_FFT)
	String FFToutm1 = name+"_FFT"
	String FFToutm2 = nameout+"_FFT"
	duplicate/o $FFToutm2 $FFToutm1
	killwaves $FFToutm2
end

Function FFTrls2(name,sel,inter)
	wave name
	variable sel,inter
	duplicate/o name named
	func_NaN0(named)
	String FFTout
	FFTout = nameofWave(name) + "_FFT"
	if (sel == 1)
		FFT/out=3/DEST=$FFTout cvtcmplx(named)
		If (inter == 0)
		else
			twoDinterpFFTover(FFTout,10*dimsize($FFTout,0),10*dimsize($FFTout,1))
		endif
	endif
	if (sel == 2)
		duplicate/o named nametemp_fft
		imagewindow/O hanning nametemp_fft
		FFT/out=3/DEST=$FFTout cvtcmplx(nametemp_fft)
		killwaves nametemp_fft
		If (inter == 0)
		else
			twoDinterpFFTover(FFTout,10*dimsize($FFTout,0),10*dimsize($FFTout,1))
		endif
	endif
	//Complextorealfls2($FFTout,1)
	//String FFToutm = FFTout+"_Modula"
	//color3sfft($tpw(),30)
	killwaves named
	//Print "FFTr("+nameofWave(name)+")"
end

Function Frommarqueegetsubmatrixs2(name)
	string name
	di($name)
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
	string nameout = "SelectA_"+name
	duplicate/o ttop $nameout
	wave nameoutw = $nameout
	killwaves ttop
end


Function FFTr(name,sel)
	wave name
	variable sel

		duplicate/o name named
		func_NaN0(named)
		String FFTout
		FFTout = nameofWave(name) + "_FFT"
		if (sel == 1)
			FFT/out=3/DEST=$FFTout cvtcmplx(named)
		endif
		if (sel == 2)
			duplicate/o named nametemp_fft
			imagewindow/O hanning nametemp_fft
			FFT/out=3/DEST=$FFTout cvtcmplx(nametemp_fft)
			killwaves nametemp_fft
		endif
		//Complextorealf($FFTout,1)
		//String FFToutm = FFTout+"_Modula"
		di($FFTout)
		color3sfft($tpw(),300)
		killwaves named
		//Print "FFTr("+nameofWave(name)+")"
end

Function f()
	wave name=$tpw()
	func_NaN0(name)
	String FFTout
	FFTout = nameofWave(name) + "_FFT"
	FFT/out=1/WINF=Hanning/DEST=$FFTout cvtcmplx(name)
	Complextorealf($FFTout,1)
	String FFToutm = FFTout+"_Modula"
	ModifyImage $FFToutm ctab= {*,*,VioletOrangeYellow,1}
	Print "FFTr("+nameofWave(name)+")"
end
Function twoDinterpFFTover(name,xpoint,ypoint)
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
	Duplicate/O $name2 $name
	killwaves $name2 $name1
end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                           FFT Filter
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//** This is a Guassian FFT filter, that works for tetragonal sample.
//** How to use it.
//** (1) Click "preFFT" to generate a FFT image for pick up Qa and Qb. The callred procedure ffc() can grab the
//       wave name of the topmost figure automatically. If you put the raw data on the top, it does not need to
//		   reenter the wave name. After this step, a FFT image will be displayed.
//       Note[1]: This is not the FFT data used in the filter procedure. This is an enlarged FFT image with both
//                1/4 and 2/3 quadrants.
//		   Note[2]: The FFT wave is interpolated by 10 times larger, in order to fit better in step (2)
//** (2) Pick up the coordinate of Qa and Qb. The Qa and Qb is the vector at 1 and 4 quandrant. <1> First, pick
//		   up Qa. Put Cursor A abd Cursor B at the FFT image, A at the left-bottom corner, and B at the Top-right
//       Corner. Click "Pick up A", it will call GpA(), the wave name will be automatically putted in. Results
//       will be saved in a wave named cpicka. <2> Put Cursor A and B around Qb, and click "Pick up B", results
//       will be save in wave named cpickb.
//			Note[1]: Pick up method is by 2D Guassian fitting.
//** (3) Do filter: Click "Filtered", put the value of the real space guassian window, this is the diameter of
//       uniform circle in real space image. It will print the function called. If you want to adjust the diameter
//       you can only use the command window, do not need to click the botton again.
//** (4) Display and append window circle [the diameter used] on both real space and FFT space.
//** (5) The code will also print the information of the FFT peak, which is fitted by 2D Guassian.
//**************************************************************************************************************
//** Algrithm for FFT filter:
//** (1) Do complex FFT and padding
//       *FFT/PAD={3*dimsize(name,0),3*dimsize(name,0)}/OUT=1/DEST=$namefft name;
//			*This results in a complex wave which dimsize($namefft,0) = 3*dimsize(name,0)/2, dimsize($namefft,1) = 3*dimsize(name,1)
//         only have the 1 and 4 quandrant.
//** (2) apply guassian filter to $namefft, because this is only 1/4 quandrant, only to vector need to be applied
//** (3) Do real inverse FFT
//       *IFFT/DEST=$nameffti  namefftw;
//       *This will give a filtered Matrix which is dimsize($nameffti,0) = 3*dimsize(name,0), dimsize($nameffti,1) = 3*dimsize(name,1)
//** (4) Select the [dimsize(name,0),dimsize(name,1)] data points to be the final output.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_ffc(ctrlName) : ButtonControl
	String ctrlName
	Execute "ffc()"
End
Proc ffc(name,sel)
	string name = tpw()
	variable sel = 2
	prompt sel,"Do you want to interpolate?",popup,"No;Yes"
	String/G namefftraw
	namefftraw =  name

	if (sel == 1)
		ffnointer($namefftraw)
	else
		ff($namefftraw)
	endif



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
Function ffnointer(name)
	wave name
	func_NaN0(name)
	String FFTout
	FFTout = nameofWave(name) + "_FFT_Modula_INTER"
	FFT/PAD={3*dimsize(name,0),3*dimsize(name,1)}/out=3/DEST=$FFTout cvtcmplx(name)

	//di($FFTout)
	Display/N=FFTengineeringlaunchimage; appendimage $FFTout
	Modifygraph width=500,height=500
	ModifyImage $FFTout ctab= {*,*,VioletOrangeYellow,1}
	//ShowInfo
	Button Map84 pos={1,1},size={100,20},title="C4 shearing",proc=ButtonProc_C4sheargetparac
	Button Map85 pos={105,1},size={31,20},title="Go!",proc=ButtonProc_C4shearcorrectc
	Button Map83 pos={1,25},size={100,20},title="Lawler-Fujita",proc=ButtonProc_LF
	Button Map81 pos={1,50},size={100,20},title="FFT Filter",proc=ButtonProc_Ftc
	Button Symx12 pos={1,74},size={100,20},title="2D lock-in",proc=ButtonProc_t2dlockinandFilter
	Button Map79 title="Get A",proc=ButtonProc_GPAc,pos={270,1}
	Button Map80q title="Get B",proc=ButtonProc_GPBc,pos={340,1}
	Button Map81q title="Refine Q",proc=ButtonProc_determineqbyphase,pos={410,1},size={65,20}
	variable/G size_findQ = 20
	SetVariable setvar0 title="N(x)",value=size_findQ,limits={10,inf,5},pos={479,1},size={70,14}

end
Function ff(name)
	wave name
	func_NaN0(name)
	String FFTout
	FFTout = nameofWave(name) + "_FFT"
	FFT/PAD={3*dimsize(name,0),3*dimsize(name,1)}/out=1/WINF=Hanning/DEST=$FFTout cvtcmplx(name)

	Complextorealf1($FFTout,1)
	String FFToutm = FFTout+"_Modula"
	//di($FFToutm)
	twoDinterpolatexyFFT(FFToutm,3*dimsize($FFTout,0),3*dimsize($FFTout,1))
	string FFTout1 = nameofWave(name) + "_FFT_Modula_INTER"
	Display/N=FFTengineeringlaunchimage; appendimage $FFTout1
	Modifygraph width=500,height=500
	ModifyImage $FFTout1 ctab= {*,*,VioletOrangeYellow,1}

	//ShowInfo
	Button Map84 pos={1,1},size={100,20},title="C4 shearing",proc=ButtonProc_C4sheargetparac
	Button Map85 pos={105,1},size={31,20},title="Go!",proc=ButtonProc_C4shearcorrectc
	Button Map83 pos={1,25},size={100,20},title="Lawler-Fujita",proc=ButtonProc_LF
	Button Map81 pos={1,50},size={100,20},title="FFT Filter",proc=ButtonProc_Ftc
	Button Symx12 pos={1,74},size={100,20},title="2D lock-in",proc=ButtonProc_t2dlockinandFilter



	Button Map79 title="Get A",proc=ButtonProc_GPAc,pos={270,1}
	Button Map80 title="Get B",proc=ButtonProc_GPBc,pos={340,1}

	Button Map81q title="Refine Q",proc=ButtonProc_determineqbyphase,pos={410,1},size={65,20}
	variable/G size_findQ = 20
	SetVariable setvar0 title="N(x)",value=size_findQ,limits={10,inf,5},pos={479,1},size={70,14}


	//killwaves
		String namec
		namec = "c_"+nameofwave(name)

		string FFToutm1 = FFToutm+"1"

		killwaves $FFTout $namec $FFToutm $FFToutm1
end
Function ff2(name)
	wave name
	func_NaN0(name)
	String FFTout
	FFTout = nameofWave(name) + "_FFT"
	FFT/out=1/WINF=Hanning/DEST=$FFTout cvtcmplx(name)

	Complextorealf1($FFTout,1)
	String FFToutm = FFTout+"_Modula"
	//di($FFToutm)
	twoDinterpolatexyFFT(FFToutm,10*dimsize($FFTout,0),10*dimsize($FFTout,1))

	//killwaves
		String namec
		namec = "c_"+nameofwave(name)

		string FFToutm1 = FFToutm+"1"

		killwaves $FFTout $namec $FFToutm $FFToutm1
end
Function Complextorealf1(name1w,select)
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
end

Function twoDinterpolatexyFFT(name,xpoint,ypoint)
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
	///endif
	//killwindow $grabwin2(name2)
	//dilf($name2)
	//wavestats/Q $name2
	//color3s($name2,30)
	//ModifyImage $name2 ctab= {*,0.2*V_max,VioletOrangeYellow,0}
end
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_GPAc(ctrlName) : ButtonControl
	String ctrlName
	Execute "gpac()"
end
Proc gpac()
	//String name = namefftraw+"_FFT_Modula_INTER"
	String name =getall2dwaveongraph()
	Gpa(name,namefftraw)
End
Function/Wave GpA(name111,nameraw)
	String name111
	string nameraw
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
	String cpickas = nameraw+"_QA"
	//print cpickas
	make/N=4/o $cpickas
	wave cpicka = $cpickas
	cpicka[0] = xa_G
	cpicka[1] = ya_G
	cpicka[2] = wx
	cpicka[3] = wy

	//** Lattice angle get
		variable qx1
		variable qy1
		qx1 = cpicka[0]*2*pi
		qy1 = cpicka[1]*2*pi
		//# lattice angle on topo
		variable/G theta_lattice = atan2(qy1,qx1)*180/pi

	Print "Qa got. Qa = ("+num2str(xa_G)+","+num2str(ya_G)+")"
	TextBox/C/N=text0/F=0/A=LB/X=0.00/Y=0.00 "Qa got. Qa = ("+num2str(xa_G)+","+num2str(ya_G)+")"
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
		ModifyGraph mode=3,marker=1,rgb=(0,0,65535), mrkThick=2
	endif
	Return cpicka
end
////////////////////////////////////////////////
Function ButtonProc_GpBc(ctrlName) : ButtonControl
	String ctrlName
	Execute "gpbc()"
end

Proc gpbc()
	//String name = namefftraw+"_FFT_Modula_INTER"
	String name =getall2dwaveongraph()
	GpB(name,namefftraw)
End
Function/Wave GpB(name111,nameraw)
	String name111
	string nameraw
	wave name111w = $name111
	String name1111 = name111+"_f"
	duplicate/o name111w $name1111
	wave name1111w=$name1111
	name1111w=nan;
	GetMarquee left, bottom

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
	String cpickbs = nameraw+"_QB"
	make/N=4/o $cpickbs
	wave cpickb = $cpickbs
	cpickb[0] = xa_G
	cpickb[1] = ya_G
	cpickb[2] = wx
	cpickb[3] = wy
	Print "Qb got. Qb = ("+num2str(xa_G)+","+num2str(ya_G)+")"
	TextBox/C/N=text1/F=0/A=LB/X=0.00/Y=10.00 "Qb got. Qb = ("+num2str(xa_G)+","+num2str(ya_G)+")"
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
		ModifyGraph mode=3,marker=1,rgb=(0,0,65535), mrkThick=2
	endif
	Return cpickb
end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_FTc(ctrlName) : ButtonControl
	String ctrlName
	Execute "FTc()"
end
Proc FTc(avedia)
	variable avedia = dimsize($namefftraw,0)*dimdelta($namefftraw,0)/4
	prompt avedia,"The FWHM in real space (guassian window)"

	FT($namefftraw,avedia)
	print "FT("+namefftraw+","+num2str(avedia)+")"
	Const2dfilter()
End
Function FT(name,avedia)
	wave name
	variable avedia

	//** Draw figure of filtered partial FFT
	string fftdata = nameofwave(name)+"_FFT_Modula_INTER"
		variable widthq=(2*sqrt(ln(2)))/avedia
		String wn =grabwin(fftdata)
		Dowindow/F $wn
		HideInfo
		cursor/K A
		cursor/K B
		ModifyGraph width=300,height=300
		ModifyGraph margin(right)=86;
		ColorScale/C/N=text99/A=LC/X=101/Y=0/F=0 frame=0.00,image=$tpw()
		//ModifyImage $tpw() ctab= {*,*,VioletOrangeYellow,0}
		color3s($tpw(),30)
		//ModifyGraph/W=$grabwin(fftdata) width={Plan,1,bottom,left},height=0
		//DrawAction/W=$grabwin(fftdata) delete




	//dilf(name)
	Dowindow/F $grabwinnonew(nameofwave(name))
	modifyphasetopo()
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

	Print "The information from FFT peaks:"
	Print "*** QA = ("+num2str(cpicka[0])+","+num2str(cpicka[1])+"); QB = ("+num2str(cpickb[0])+","+num2str(cpickb[1])+")"
	Print "*** FWHM.QA(x,y) = ("+num2str(FWHMAx)+","+num2str(FWHMAy)+")" +" FWHM.QA.ave = "+num2str(FWHMAave)
	Print "*** FWHM.QB(x,y) = ("+num2str(FWHMBx)+","+num2str(FWHMBy)+")" +" FWHM.QB.ave = "+num2str(FWHMBave)
	Print "*** In real space, uniform diameter (FWHM) is "+num2str(FWHM_real)
	Print "Practically, Real space diameter (FWHM) is set to be "+num2str(avedia)+" ,as shown in the figure."

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
	//variable i,j
	//i=0
	//do
	//	j=0
	//	do
	//		nnw[i][j] = namefftiw[i][j]
	//		j+=1
	//	while (j<dimsize(name,1))
	//	i+=1
	//while (i<dimsize(name,0))
	//setscale/p x, dimoffset(name,0),dimdelta(name,0),"",nnw
	//setscale/p y, dimoffset(name,1),dimdelta(name,1),"",nnw

	//String filteredFFT = nameofwave(name) + "_FFT_Modula_INTER"
	//Wave filteredFFTw = $filteredFFT
	//string filteredFFT2 = filteredFFT+"_ftd"
	//duplicate/o filteredFFTw $filteredFFT2
	//wave filteredFFT2w=$filteredFFT2
	//filteredFFT2w*=(sqrt(pi)*widtha)^(-1)*exp(-((x-cpicka[0])^2+(y-cpicka[1])^2)/(widtha^2))+(sqrt(pi)*widthb)^(-1)*exp(-((x-cpickb[0])^2+(y-cpickb[1])^2)/(widthb^2))+(sqrt(pi)*widtha)^(-1)*exp(-((x+cpicka[0])^2+(y+cpicka[1])^2)/(widtha^2))+(sqrt(pi)*widthb)^(-1)*exp(-((x+cpickb[0])^2+(y+cpickb[1])^2)/(widthb^2))
		//Complextorealf_for3d(namefftw,1)
		//string namefftwtoreal=namefft+"_Modula"
	dilf(namefftw)
	modifyphasetopo()
	SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),dash= 7,linethick= 3.00,fillpat= 0;
	variable qax1,qay1,qax2,qay2,qamx1,qamy1,qamx2,qamy2
	variable qbx1,qby1,qbx2,qby2,qbmx1,qbmy1,qbmx2,qbmy2
	qax1 = cpicka[0]-2*sqrt(ln(2))*widtha/2
	qay1 = cpicka[1]-2*sqrt(ln(2))*widtha/2
	qax2 = cpicka[0]+2*sqrt(ln(2))*widtha/2
	qay2 = cpicka[1]+2*sqrt(ln(2))*widtha/2

	qamx1 = -cpicka[0]-2*sqrt(ln(2))*widtha/2
	qamy1 = -cpicka[1]-2*sqrt(ln(2))*widtha/2
	qamx2 = -cpicka[0]+2*sqrt(ln(2))*widtha/2
	qamy2 = -cpicka[1]+2*sqrt(ln(2))*widtha/2

	qbx1 = cpickb[0]-2*sqrt(ln(2))*widtha/2
	qby1 = cpickb[1]-2*sqrt(ln(2))*widtha/2
	qbx2 = cpickb[0]+2*sqrt(ln(2))*widtha/2
	qby2 = cpickb[1]+2*sqrt(ln(2))*widtha/2

	qbmx1 = -cpickb[0]-2*sqrt(ln(2))*widtha/2
	qbmy1 = -cpickb[1]-2*sqrt(ln(2))*widtha/2
	qbmx2 = -cpickb[0]+2*sqrt(ln(2))*widtha/2
	qbmy2 = -cpickb[1]+2*sqrt(ln(2))*widtha/2
	DrawOval qax1,qay1,qax2,qay2
	SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),dash= 7,linethick= 3.00,fillpat= 0;
	DrawOval qamx1,qamy1,qamx2,qamy2
	SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),dash= 7,linethick= 3.00,fillpat= 0;
	DrawOval qbx1,qby1,qbx2,qby2
	SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),dash= 7,linethick= 3.00,fillpat= 0;
	DrawOval qbmx1,qbmy1,qbmx2,qbmy2
	//color3s($namefftwtoreal,30)

	dilf(nnw)
	modifyphasetopo()
	variable xrange = abs((dimsize(nnw, 0))*dimdelta(nnw, 0))
	variable xs = dimoffset(nnw, 0)+xrange -(Xrange*0.02+avedia)
	variable yrange = abs((dimsize(nnw, 1))*dimdelta(nnw, 1))
	//variable ys = dimoffset(nnw, 1)+(yrange*0.02)
	variable ys =dimoffset(nnw, 1)+yrange*0.02
	SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (65535,65535,0),dash= 7,linethick= 3.00,fillpat= 0,linefgc= (65535,65535,0)
	DrawOval xs,ys,xs+avedia,ys+avedia
	tilewindows/WINS=WinList("*", ";","WIN:1")/R/A=(2,2)/w=(4,0,63,85)
	ModifyGraph/W=$grabwin(namefft) Height=300,width={Plan,1,bottom,left}
	string inforwaveLF = "inforwavefilter_"+nameofwave(name)
	make/o/N=1 $inforwaveLF
	wave inforwaveLFw = $inforwaveLF
	inforwaveLFw[0] = avedia
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
Function di3(name)
	wave name
		killgraphonlyhavethewave(nameofwave(name))
		display;appendimage name
		ModifyGraph width=500,height=500;
		modifygraph lsize=1
		ModifyGraph mirror=2
		ModifyGraph tick=0
		ModifyImage $nameofwave(name) ctab= {*,*,VioletOrangeYellow,0}
end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                           End FFT Filter
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_GPc(ctrlName) : ButtonControl
	String ctrlName
	Execute "gpc()"
end
Proc gpc()
	Gp(tpw())
End
Function/Wave Gp(name111)
	String name111
	wave name111w = $name111
	String name1111 = name111+"_f"
	duplicate/o name111w $name1111
	wave name1111w=$name1111
	name1111w=nan;
	CurveFit gauss2D name111w[pcsr(A),pcsr(b)][qcsr(A),qcsr(b)] /D=name1111w[pcsr(A),pcsr(b)][qcsr(A),qcsr(b)];
	//AppendMatrixContour $name1111
	variable xa_G, ya_G, wx,wy
	string W_coef = "W_coef"
	wave W_coefw = $W_coef
	xa_G = W_coefw[2]
	ya_G = W_coefw[4]
	wx = W_coefw[3]
	wy = W_coefw[5]
	//Print "Coordiante (x,y) from Figure is ("+num2str(xa_G)+","+num2str(ya_G)+")."
	String cpickc = name111+"_Q"
	make/N=4/o $cpickc
	wave cpick = $cpickc
	cpick[0] = xa_G
	cpick[1] = ya_G
	cpick[2] = wx
	cpick[3] = wy
	variable FWHMAx,FWHMAy,FWHMAave,FWHMBx,FWHMBy,FWHMBave,FWHM_real
	FWHMAx = cpick[2]*2*sqrt(ln(2))
	FWHMAy = cpick[3]*2*sqrt(ln(2))
	FWHMAave = (cpick[2]+cpick[3])*2*sqrt(ln(2))/2

	FWHM_real = 2*sqrt(ln(2))*2/(cpick[2]+cpick[3])

	Print "The information from FFT peaks:"
	Print "*** QA = ("+num2str(cpick[0])+","+num2str(cpick[1])+")"
	Print "*** FWHM.QA(x,y) = ("+num2str(FWHMAx)+","+num2str(FWHMAy)+")" +" FWHM.QA.ave = "+num2str(FWHMAave)
	Print "*** In real space, uniform diameter (FWHM) is "+num2str(FWHM_real)
	Print "Results save in wave, [0]Qx; [1]Qy; [2]Width_x; [3]Width_y"
	Print nameofwave(cpick)+"[]"
	Return cpick
end
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Interactive procedure for FFT filter
///////////////////////////////////////////////////////////////////////////////////////
//
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Const2dfilter(ctrlName) : ButtonControl
	String ctrlName
	Execute "Const2dfilter()"
End

Proc Const2dfilter()
	string inforwaveLF = "inforwavefilter_"+namefftraw
	variable/G avedia_ft = $inforwaveLF[0]
	//variable/G condA_LF	= $inforwaveLF[2]
	//variable/G factor_LF = $inforwaveLF[1]
	string dowin = namefftraw+"_ftd"
	//Dowindow/F $grabwin(dowin)
	SetVariable setvar0 title="FWHM(Filter_r)",size={120,20},value=avedia_ft,proc=SetVarProc_Const2dfilter
	SetVariable setvar0 limits={0,dimsize($namefftraw,0)*dimdelta($namefftraw,0),dimsize($namefftraw,0)*dimdelta($namefftraw,0)/100}
End

Function SetVarProc_Const2dfilter(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	execute "Const2dfilterc()"
End

Proc Const2dfilterc()
	variable  avedia = avedia_ft
	FTcons($namefftraw,avedia)
end

Function FTcons(name,avedia)
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

	//Print "The information from FFT peaks:"
	//Print "*** QA = ("+num2str(cpicka[0])+","+num2str(cpicka[1])+"); QB = ("+num2str(cpickb[0])+","+num2str(cpickb[1])+")"
	//Print "*** FWHM.QA(x,y) = ("+num2str(FWHMAx)+","+num2str(FWHMAy)+")" +" FWHM.QA.ave = "+num2str(FWHMAave)
	//Print "*** FWHM.QB(x,y) = ("+num2str(FWHMBx)+","+num2str(FWHMBy)+")" +" FWHM.QB.ave = "+num2str(FWHMBave)
	//Print "*** In real space, uniform diameter (FWHM) is "+num2str(FWHM_real)
	//Print "Practically, Real space diameter (FWHM) is set to be "+num2str(avedia)+" ,as shown in the figure."

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
	//variable i,j
	//i=0
	//do
	//	j=0
	//	do
	//		nnw[i][j] = namefftiw[i][j]
	//		j+=1
	//	while (j<dimsize(name,1))
	//	i+=1
	//while (i<dimsize(name,0))
	//setscale/p x, dimoffset(name,0),dimdelta(name,0),"",nnw
	//setscale/p y, dimoffset(name,1),dimdelta(name,1),"",nnw


	//String filteredFFT = nameofwave(name) + "_FFT_Modula_INTER"
	//Wave filteredFFTw = $filteredFFT
	//string filteredFFT2 = filteredFFT+"_ftd"
	//duplicate/o filteredFFTw $filteredFFT2
	//wave filteredFFT2w=$filteredFFT2
	//filteredFFT2w*=(sqrt(pi)*widtha)^(-1)*exp(-((x-cpicka[0])^2+(y-cpicka[1])^2)/(widtha^2))+(sqrt(pi)*widthb)^(-1)*exp(-((x-cpickb[0])^2+(y-cpickb[1])^2)/(widthb^2))+(sqrt(pi)*widtha)^(-1)*exp(-((x+cpicka[0])^2+(y+cpicka[1])^2)/(widtha^2))+(sqrt(pi)*widthb)^(-1)*exp(-((x+cpickb[0])^2+(y+cpickb[1])^2)/(widthb^2))
	//Dowindow/F $
	//di(filteredFFT2w)
	drawAction/W=$grabwin(namefft) delete
	SetDrawEnv/W=$grabwin(namefft) xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),dash= 7,linethick= 3.00,fillpat= 0;
	variable qax1,qay1,qax2,qay2,qamx1,qamy1,qamx2,qamy2
	variable qbx1,qby1,qbx2,qby2,qbmx1,qbmy1,qbmx2,qbmy2
	qax1 = cpicka[0]-2*sqrt(ln(2))*widtha/2
	qay1 = cpicka[1]-2*sqrt(ln(2))*widtha/2
	qax2 = cpicka[0]+2*sqrt(ln(2))*widtha/2
	qay2 = cpicka[1]+2*sqrt(ln(2))*widtha/2
	qamx1 = -cpicka[0]-2*sqrt(ln(2))*widtha/2
	qamy1 = -cpicka[1]-2*sqrt(ln(2))*widtha/2
	qamx2 = -cpicka[0]+2*sqrt(ln(2))*widtha/2
	qamy2 = -cpicka[1]+2*sqrt(ln(2))*widtha/2
	qbx1 = cpickb[0]-2*sqrt(ln(2))*widtha/2
	qby1 = cpickb[1]-2*sqrt(ln(2))*widtha/2
	qbx2 = cpickb[0]+2*sqrt(ln(2))*widtha/2
	qby2 = cpickb[1]+2*sqrt(ln(2))*widtha/2
	qbmx1 = -cpickb[0]-2*sqrt(ln(2))*widtha/2
	qbmy1 = -cpickb[1]-2*sqrt(ln(2))*widtha/2
	qbmx2 = -cpickb[0]+2*sqrt(ln(2))*widtha/2
	qbmy2 = -cpickb[1]+2*sqrt(ln(2))*widtha/2
	DrawOval/W=$grabwin(namefft) qax1,qay1,qax2,qay2
	SetDrawEnv/W=$grabwin(namefft) xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),dash= 7,linethick= 3.00,fillpat= 0;
	DrawOval/W=$grabwin(namefft) qamx1,qamy1,qamx2,qamy2
	SetDrawEnv/W=$grabwin(namefft) xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),dash= 7,linethick= 3.00,fillpat= 0;
	DrawOval/W=$grabwin(namefft) qbx1,qby1,qbx2,qby2
	SetDrawEnv/W=$grabwin(namefft) xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),dash= 7,linethick= 3.00,fillpat= 0;
	DrawOval/W=$grabwin(namefft) qbmx1,qbmy1,qbmx2,qbmy2

	//Dowindow/F $grabwin(nn)
	//di(nnw)
	drawAction/W=$grabwin(nn) delete
	variable xrange = abs((dimsize(nnw, 0))*dimdelta(nnw, 0))
	variable xs = dimoffset(nnw, 0)+xrange -(Xrange*0.02+avedia)
	variable yrange = abs((dimsize(nnw, 1))*dimdelta(nnw, 1))
	//variable ys = dimoffset(nnw, 1)+(yrange*0.02)
	variable ys =dimoffset(nnw, 1)+ yrange*0.02
	SetDrawEnv/W=$grabwin(nn) xcoord= bottom,ycoord= left,linefgc= (65535,65535,0),dash= 7,linethick= 3.00,fillpat= 0
	DrawOval/W=$grabwin(nn) xs,ys,xs+avedia,ys+avedia
	//tilewindows/WINS=WinList("*", ";","WIN:1")/R/w=(4,0,80,80)
	//string dowin = nameofwave(name)+"_FFT_Modula_INTER"
	//Dowindow/F $grabwin(dowin)
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




///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//     1D FFT filter for linecut, This is useful for Y linecut
//
//** Update 09/16/23: added 1D wave filter, the procedure can recongnize it automatically
//** but you need to input the avedia by your self.
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_FTlinecutc(ctrlName) : ButtonControl
	String ctrlName
	Execute "FTlinecutc()"
end
Proc FTlinecutc(name,avedia,q0,ind1,ind2)
	STRING name = tpw()
	variable avedia =dimsize($name,1)*dimdelta($name,1)/5
	variable q0 = 1/3.8
	string ind1 = "Do not need Launch"
	string ind2 = "Can use both 1D or 2D wave"
	prompt name,"The Linecut to be filtered"
	prompt avedia,"Real space Gaussian window"
	prompt q0,"Q0 locked (1/a)"
	prompt ind1,"Tip 1"
	prompt ind2,"Tip 2"

	variable/G avedia_2dlinecut
	variable/G q0_2dlinecut
	string/G name_2dlinecut
	avedia_2dlinecut = avedia
	q0_2dlinecut = q0

	string name1=name+"_1"
	string namepad

	if(waveDims($name) == 1)

		if (mod(dimsize($name,0),2) == 0) //even number
			onedpad2d(name)
			namepad = name+"_ypad"
			name_2dlinecut = namepad
			FTlinecut1d($namepad,avedia,q0)
		else
			interpolate2/T=1/N=(dimsize($name,0)+1)/Y=$name1 $name
			//print dimsize($name,0)+1
			//display $name1
			onedpad2d(name1)
			namepad = name1+"_ypad"
			name_2dlinecut = namepad
			FTlinecut1d($namepad,avedia,q0)
		endif
		appendtograph $name
		ModifyGraph mode($name)=4,marker($name)=5,msize($name)=4,mrkThick($name)=1,lstyle($name)=7,rgb($name)=(0,0,0)
		SetVariable setvarFTavedia title="FWHM",limits={0,inf,dimsize($name,0)*dimdelta($name,0)/100},size={80,14},value=avedia_2dlinecut,proc=SetVarProc_FTlinecutcons1d
		SetVariable setvarFTq0 title="q0",limits={0,inf,q0*0.05},size={80,14},value=q0_2dlinecut,proc=SetVarProc_FTlinecutcons1d
	endif

	if(waveDims($name) == 2)

		if (mod(dimsize($name,1),2) == 0) //even number
			name_2dlinecut = name
			FTlinecut($name,avedia,q0)
		else
			///if (mod(dimsize($name,0),2) == 0)
				twoDinterpyf(name,dimsize($name,1)+1)
				name_2dlinecut = name1
				FTlinecut($name1,avedia,q0)
			//else
			//	twoDinterpolatexyf2(name,dimsize($name,0)+1,dimsize($name,1)+1)
			//	name_2dlinecut = name1
			//	FTlinecut($name1,avedia,q0)
			//endif
		endif

		SetVariable setvarFTavedia title="FWHM",limits={0,inf,dimsize($name,1)*dimdelta($name,1)/100},size={80,14},value=avedia_2dlinecut,proc=SetVarProc_FTlinecutcons
		SetVariable setvarFTq0 title="q0",limits={0,inf,q0*0.05},size={80,14},value=q0_2dlinecut,proc=SetVarProc_FTlinecutcons
	endif
end

Function FTlinecut(name,avedia,q0)
	wave name
	variable avedia
	variable q0 //= 0.28483

	string namefft = nameofwave(name)+"_FFT"
	variable widtha
	FFT/ROWS/DEST=$namefft name
	widtha=(2*sqrt(ln(2)))/avedia

	wave/C namefftw = $namefft
	namefftw*=(sqrt(pi)*widtha)^(-1)*exp(-((y-q0)^2)/(widtha^2))//+(sqrt(pi)*widthb)^(-1)*exp(-((x-cpickb[0])^2+(y-cpickb[1])^2)/(widthb^2))

	String nameffti = nameofwave(name)+"_ftd"
	IFFT/ROWS/DEST=$nameffti  namefftw;
	wave namefftiw = $nameffti
	killwaves namefftw
	di(namefftiw)
	Modifygraph width=250, height=450
	//** Error message, no stop but Continuing execution
		String msg
		Variable err
		msg=GetErrMessage(GetRTError(0),3);
		err=GetRTError(1)
		if (err != 0)
			Print "Error in Demo: " + msg
			Print "Continuing execution"
		endif
END

Function SetVarProc_FTlinecutcons(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/G avedia_2dlinecut
	variable/G 	q0_2dlinecut
	FTlinecutcons(avedia_2dlinecut,q0_2dlinecut)
End
Function FTlinecutcons(avedia,q0)
	variable avedia //= avedia_2dlinecut
	variable q0 //=q0_2dlinecut

	string/G name_2dlinecut
	wave name = $name_2dlinecut

	variable/G avedia_2dlinecut
	variable/G q0_2dlinecut
	//print avedia_2dlinecut

	string namefft = nameofwave(name)+"_FFT"
	variable widtha
	FFT/ROWS/DEST=$namefft name
	widtha=(2*sqrt(ln(2)))/avedia

	wave/C namefftw = $namefft
	namefftw*=(sqrt(pi)*widtha)^(-1)*exp(-((y-q0)^2)/(widtha^2))//+(sqrt(pi)*widthb)^(-1)*exp(-((x-cpickb[0])^2+(y-cpickb[1])^2)/(widthb^2))

	String nameffti = nameofwave(name)+"_ftd"
	IFFT/ROWS/DEST=$nameffti  namefftw;
	wave namefftiw = $nameffti
	killwaves namefftw
	//di(namefftiw)

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

/////////////////////////////////////////////////////////////////////
Function FTlinecut1D(name,avedia,q0)
	wave name
	variable avedia
	variable q0 //= 0.28483

	string namefft = nameofwave(name)+"_FFT"
	variable widtha
	FFT/ROWS/DEST=$namefft name
	widtha=(2*sqrt(ln(2)))/avedia
	//display $namefft
	wave/C namefftw = $namefft
	namefftw*=(sqrt(pi)*widtha)^(-1)*exp(-((y-q0)^2)/(widtha^2))//+(sqrt(pi)*widthb)^(-1)*exp(-((x-cpickb[0])^2+(y-cpickb[1])^2)/(widthb^2))

	String nameffti = nameofwave(name)+"_ftd"
	IFFT/ROWS/DEST=$nameffti  namefftw;
	wave namefftiw = $nameffti
	killwaves namefftw
	//di(namefftiw)
	string onedftd = nameofwave(name)+"_ftd1d"
	make/n=(dimsize(namefftiw,1))/o $onedftd
	wave onedftdw = $onedftd
	onedftdw[]=namefftiw[round(dimsize(namefftiw,0)/2)][p]
	setscale/p x,dimoffset(name,1),dimdelta(name,1),"",onedftdw
	//print dimoffset(name,1)
	//print dimdelta(name,1)
	ysame(nameofwave(onedftdw),nameofwave(name))
	display onedftdw
	ModifyGraph lsize($onedftd)=6,rgb($onedftd)=(16385,65535,65535)
	ckfig(winname(0,1))
	killwaves namefftiw
	//Modifygraph width=250, height=450
	//** Error message, no stop but Continuing execution
		String msg
		Variable err
		msg=GetErrMessage(GetRTError(0),3);
		err=GetRTError(1)
		if (err != 0)
			Print "Error in Demo: " + msg
			Print "Continuing execution"
		endif
END

Function SetVarProc_FTlinecutcons1D(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/G avedia_2dlinecut
	variable/G 	q0_2dlinecut
	FTlinecutcons1d(avedia_2dlinecut,q0_2dlinecut)
End
Function FTlinecutcons1d(avedia,q0)
	variable avedia //= avedia_2dlinecut
	variable q0 //=q0_2dlinecut

	string/G name_2dlinecut
	wave name = $name_2dlinecut

	variable/G avedia_2dlinecut
	variable/G q0_2dlinecut
	//print avedia_2dlinecut

	string namefft = nameofwave(name)+"_FFT"
	variable widtha
	FFT/ROWS/DEST=$namefft name
	widtha=(2*sqrt(ln(2)))/avedia

	wave/C namefftw = $namefft
	namefftw*=(sqrt(pi)*widtha)^(-1)*exp(-((y-q0)^2)/(widtha^2))//+(sqrt(pi)*widthb)^(-1)*exp(-((x-cpickb[0])^2+(y-cpickb[1])^2)/(widthb^2))

	String nameffti = nameofwave(name)+"_ftd"
	IFFT/ROWS/DEST=$nameffti  namefftw;
	wave namefftiw = $nameffti
	killwaves namefftw
	//di(namefftiw)
	string onedftd = nameofwave(name)+"_ftd1d"
	make/n=(dimsize(namefftiw,1))/o $onedftd
	wave onedftdw = $onedftd
	onedftdw[]=namefftiw[round(dimsize(namefftiw,0)/2)][p]
	setscale/p x,dimoffset(name,1),dimdelta(name,1),"",onedftdw
	killwaves namefftiw
	ysame(nameofwave(onedftdw),nameofwave(name))
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
Function onedpad2d(name)
	string name
	string namepad = name+"_ypad"
	make/o/N=(dimsize($name,0),dimsize($name,0)) $namepad
	setscale/p x,dimoffset($name,0),dimdelta($name,0),"",$namepad
	setscale/p y,dimoffset($name,0),dimdelta($name,0),"",$namepad
	wave namepadw =$namepad
	wave namew = $name
	namepadw[][]=namew[q]
	//di($namepad)
end
Function ysame(name,ref)
	string name
	string ref

	wave namew = $name
	wave refw = $ref
	wavestats/Q refw
	variable yrangeref = V_max-V_min
	variable yminref = V_min

	wavestats/Q namew
	variable yrangename = V_max-V_min

	namew/=(yrangename/yrangeref)

	wavestats/Q namew
	variable yminname = V_min
	namew+=yminref-yminname
end
Function PDWonSC(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = g0+a0*cos(k0*x+phi0)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 4
	//CurveFitDialog/ w[0] = g0
	//CurveFitDialog/ w[1] = a0
	//CurveFitDialog/ w[2] = k0
	//CurveFitDialog/ w[3] = phi0

	return w[0]+w[1]*cos(w[2]*x+w[3])
End

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  2D low pass filter locked (0,0)
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
/////////////////////////
Function ButtonProc_FTclp(ctrlName) : ButtonControl
	String ctrlName
	Execute "FTclp()"
end
Proc FTclp(avedia,ind1,ind2)
	variable avedia = dimsize($tpw(),0)*dimdelta($tpw(),0)/4
	string ind1 = "Do not need Launch"
	string ind2 = "2D Low pass filter"
	prompt avedia,"The FWHM in real space (guassian window)"

	FTlp(avedia)
	Const2dfilterlp()
End
Function FTlp(avedia)
	variable avedia

	wave name = $tpw()
	string/G name_lp
	string name1=nameofwave(name)+"_1"

		if (mod(dimsize(name,1),2) == 0) //even number
			if (mod(dimsize(name,0),2) == 0)
				name_lp = nameofWave(name)
			else
				twoDinterpolatexyf2(nameofwave(name),dimsize(name,0)+1,dimsize(name,1))
				wave name = $name1
				//print name1
				//di(name)
				name_lp = name1
			endif

		else
			if (mod(dimsize(name,0),2) == 0)
				twoDinterpyf(nameofwave(name),dimsize(name,1)+1)
				wave name = $name1
				name_lp = name1
			else
				twoDinterpolatexyf2(nameofwave(name),dimsize(name,0)+1,dimsize(name,1)+1)
				wave name = $name1
				//print name1
				//di(name)
				name_lp = name1
			endif
		endif


	string namefft = nameofwave(name)+"_padFFT"
	variable widtha,widthb
	FFT/PAD={3*dimsize(name,0),3*dimsize(name,1)}/OUT=1/DEST=$namefft name;

	widtha=(2*sqrt(ln(2)))/avedia
	widthb=widtha

	wave/C namefftw = $namefft
	namefftw*=(sqrt(pi)*widtha)^(-1)*exp(-((x)^2+(y)^2)/(widtha^2))//+(sqrt(pi)*widthb)^(-1)*exp(-((x)^2+(y)^2)/(widthb^2))

	String nameffti = namefft+"i"
	IFFT/DEST=$nameffti  namefftw;
	wave namefftiw = $nameffti

	//unpadding the data
	unpadding(nameofwave(name),namefftiw)
	string npd=nameffti+"_up"
	string nn = nameofwave(name)+"_ftd"
	duplicate/o $npd $nn
	wave nnw = $nn
	wave npdw = $npd
	killwaves npdw
	string named = nameofwave(name)+"_d"
	duplicate/o name $named
	wave namedw = $named

	duplicate/o nnw $nameofwave(name)
	//modifyphasetopo()
	di(name)
	ModifyImage $tpw() ctab= {*,*,VioletOrangeYellow,0}
	drawAction delete

	variable xrange = abs((dimsize(nnw, 0))*dimdelta(nnw, 0))
	variable xs = dimoffset(nnw, 0)+xrange -(Xrange*0.02+avedia)
	variable yrange = abs((dimsize(nnw, 1))*dimdelta(nnw, 1))
	//variable ys = dimoffset(nnw, 1)+(yrange*0.02)
	variable ys =dimoffset(nnw, 1)+yrange*0.02
	SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (65535,65535,0),dash= 7,linethick= 3.00,fillpat= 0,linefgc= (65535,65535,0)
	DrawOval xs,ys,xs+avedia,ys+avedia
	ModifyGraph Height=300,width={Plan,1,bottom,left}


	string inforwaveLF = "inforwavefilterlp_"+nameofwave(name)
	make/o/N=1 $inforwaveLF
	wave inforwaveLFw = $inforwaveLF
	inforwaveLFw[0] = avedia
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


Proc Const2dfilterlp()
	string dowin = name_lp
	string inforwaveLF = "inforwavefilterlp_"+dowin
	variable/G avedia_ftlp = $inforwaveLF[0]
	//variable/G condA_LF	= $inforwaveLF[2]
	//variable/G factor_LF = $inforwaveLF[1]
	Dowindow/F $grabwin(dowin)
	SetVariable setvar0 title="FWHM(LP_Filter)",size={120,20},value=avedia_ftlp,proc=SetVarProc_Const2dfilterlp
	SetVariable setvar0 limits={0,dimsize($dowin,0)*dimdelta($dowin,0),dimsize($dowin,0)*dimdelta($dowin,0)/100}
End

Function SetVarProc_Const2dfilterlp(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	execute "Const2dfilterclp()"
End

Proc Const2dfilterclp()
	variable  avedia = avedia_ftlp
	FTconslp(avedia)
end

Function FTconslp(avedia)
	variable avedia

	string/G name_lp

	wave name = $name_lp
	//print nameofwave(name)

	string named = nameofwave(name)+"_d"
	duplicate/o $named $nameofwave(name)
	if (avedia == 0)
	else
		string namefft = nameofwave(name)+"_padFFT"
		variable widtha,widthb
		FFT/PAD={3*dimsize(name,0),3*dimsize(name,1)}/OUT=1/DEST=$namefft name;

		widtha=(2*sqrt(ln(2)))/avedia
		widthb=widtha

		wave/C namefftw = $namefft
		namefftw*=(sqrt(pi)*widtha)^(-1)*exp(-((x)^2+(y)^2)/(widtha^2))//+(sqrt(pi)*widthb)^(-1)*exp(-((x)^2+(y)^2)/(widthb^2))

		String nameffti = namefft+"i"
		IFFT/DEST=$nameffti  namefftw;
		wave namefftiw = $nameffti

		//unpadding the data
		unpadding(nameofwave(name),namefftiw)
		string npd=nameffti+"_up"
		string nn = nameofwave(name)+"_ftd"
		duplicate/o $npd $nn
		wave nnw = $nn
		wave npdw = $npd
		killwaves npdw



		duplicate/o nnw $nameofwave(name)
		//modifyphasetopo()
		//color3s_for3d($tpw(),3)
		ModifyImage $tpw() ctab= {*,*,VioletOrangeYellow,0}
		drawAction delete

		variable xrange = abs((dimsize(nnw, 0))*dimdelta(nnw, 0))
		variable xs = dimoffset(nnw, 0)+xrange -(Xrange*0.02+avedia)
		variable yrange = abs((dimsize(nnw, 1))*dimdelta(nnw, 1))
		//variable ys = dimoffset(nnw, 1)+(yrange*0.02)
		variable ys =dimoffset(nnw, 1)+yrange*0.02
		SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (65535,65535,0),dash= 7,linethick= 3.00,fillpat= 0,linefgc= (65535,65535,0)
		DrawOval xs,ys,xs+avedia,ys+avedia
		ModifyGraph Height=300,width={Plan,1,bottom,left}


		string inforwaveLF = "inforwavefilterlp_"+nameofwave(name)
		make/o/N=1 $inforwaveLF
		wave inforwaveLFw = $inforwaveLF
		inforwaveLFw[0] = avedia
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
END


Function/S getall2dwaveongraph()
	variable num=itemsinList(WaveList("*", ";", "WIN:"+winname(0,1)))
	variable i
	string namewave = ""
	i=0
	do
		if(waveDims($stringfromlist(i,WaveList("*", ";", "WIN:"+winname(0,1)))) == 2)
		namewave+=stringfromlist(i,WaveList("*", ";", "WIN:"+winname(0,1)))//+";"
		endif
		i+=1
	while(i<num)
	Return namewave
end

//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
//                    Refine Q vector
//////////////////////////////////////////////////////////////////////////////////////////////////
//Ref: https://www.nature.com/articles/s41467-024-48047-0
//////////////////////////////////////////////////////////////////////////////////////////////////
//Minimize the slope of phase map.
//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_determineqbyphase(ctrlName) : ButtonControl
	String ctrlName
	Execute "determineqbyphasec()"
end
Function ButtonProc_determineqbyphase2(ctrlName) : ButtonControl
	String ctrlName
	RemoveFromGraph/ALL
	Execute "determineqbyphasec()"
end



Proc determineqbyphasec()
	determineqbyphase(size_findQ)
	Button Map81 title="Refine Q",proc=ButtonProc_determineqbyphase2,size={65,20}//,pos={410,1}
	SetVariable setvar0 title="N(x)",value=size_findQ,limits={10,inf,5},size={70,14}//,pos={536,1}
	tilewindows/WINS=winname(0,1)/R/w=(43.5,0,83,40)/A=(1,1)
	Button peakget title="Get Q",proc=ButtonProc_peakIndi,size={65,20},pos={1,25}
	Button peakgetforA title="Save A",proc=ButtonProc_saveA_refineQ,size={65,20},pos={1,50}
	Button peakgetforB title="Save B",proc=ButtonProc_saveB_refineQ,size={65,20},pos={1,75}
end

Function ButtonProc_saveA_refineQ(ctrlName) : ButtonControl
	String ctrlName
	saveA_refineQ()
end
Function saveA_refineQ()
	String/G namefftraw
	string name = namefftraw
	string cpicka = name+"_QA"
	wave cpickaw = $cpicka

	string cpq = name+"_Q"
	wave cpqw = $cpq
	cpickaw[0] = cpqw[0]
	cpickaw[1] = cpqw[1]

	string Fitq1x =name+"_getq1x"
	string Fitq1y =name+"_getq1y"
	make/N=1/o $Fitq1x
	make/N=1/o $Fitq1y
	wave Fitq1xw = $Fitq1x
	wave Fitq1yw = $Fitq1y
	Fitq1xw[0] = cpickaw[0]
	Fitq1yw[0] = cpickaw[1]

	TextBox/W=FFTengineeringlaunchimage/C/N=text0/F=0/A=LB/X=0.00/Y=0.00 "Qa got. Qa = ("+num2str(cpickaw[0])+","+num2str(cpickaw[1])+")"

end
Function ButtonProc_saveB_refineQ(ctrlName) : ButtonControl
	String ctrlName
	saveB_refineQ()
end
Function saveB_refineQ()
	String/G namefftraw
	string name = namefftraw
	string cpickb = name+"_QB"
	wave cpickbw = $cpickb

	string cpq = name+"_Q"
	wave cpqw = $cpq
	cpickbw[0] = cpqw[0]
	cpickbw[1] = cpqw[1]


	string Fitq1x =name+"_getq2x"
	string Fitq1y =name+"_getq2y"
	make/N=1/o $Fitq1x
	make/N=1/o $Fitq1y
	wave Fitq1xw = $Fitq1x
	wave Fitq1yw = $Fitq1y
	Fitq1xw[0] = cpickbw[0]
	Fitq1yw[0] = cpickbw[1]
	TextBox/W=FFTengineeringlaunchimage/C/N=text1/F=0/A=LB/X=0.00/Y=10.00 "Qb got. Qb = ("+num2str(cpickbw[0])+","+num2str(cpickbw[1])+")"

end


Function determineqbyphase(grid)
	variable grid //dimsize of x direction

	String/G namefftraw
	string name = namefftraw

	GetMarquee left, bottom
	make/N=4/o PartialFFTsel
	PartialFFTsel={V_left,V_right,V_bottom,V_top}

	drawAction delete

	if (waveexists(PartialFFTsel) == 1)
		SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (0,0,0),fillpat= 0,linethick= 1.00;DelayUpdate
		DrawRect PartialFFTsel[0],PartialFFTsel[2],PartialFFTsel[1],PartialFFTsel[3]
	endif
	//variable LX,LY
	//LX = V_right-V_left
	//LY = V_top-V_bottom
	variable dimdeltam, grid2

	string nameqbyp = name+"_median"//+"_forA"
		//V_left+(grid-1)*dimdeltam=V_right

		dimdeltam = (V_right-V_left)/(grid-1)

		//V_bottom + (grid2-1)*dimdeltam = V_top
		grid2 = round(1+((V_top-V_bottom)/dimdeltam))

		make/o/n=(grid,grid2) $nameqbyp
		wave nameqbypw = $nameqbyp
		setscale/p x,V_left,dimdeltam,"",nameqbypw
		setscale/p y,V_bottom,dimdeltam,"",nameqbypw


	variable i,j
	variable qx1,qy1
	string tphase1 = name+"_phi_A_forQ"
	//string getslopmapinfor=tphase1+"_slopeinfor"

	variable avedia

	string Fitq1x =namefftraw+"_getq1x"
	string Fitq1y =namefftraw+"_getq1y"
	wave Fitq1xw = $Fitq1x
	wave Fitq1yw = $Fitq1y

	variable xx,yy
	xx = Fitq1xw[0]
	yy = Fitq1yw[0]
	avedia = 8/sqrt(xx^2+yy^2)

	//avedia = 60 // 8/sqrt(((V_left+V_right)/2)^2+((V_bottom+V_top)/2)^2)
		//print avedia
	i=0
	do
		Print i,"/",grid-1
		j=0
		do

			qx1 = (V_left + i*dimdeltam)*2*pi
			qy1 = (V_bottom + j*dimdeltam)*2*pi

			phaseextractionforq(name,qx1,qy1,avedia)
			//phaseextractionforq_pad(name,qx1,qy1,avedia)
			nameqbypw[i][j]= getslopmap($tphase1)
			j+=1
		while (j<grid2)
		i+=1
	while (i<grid)

	killwaves $tphase1
	wave getslopmap1 = $"getslopmap1"
	wave getslopmap2 = $"getslopmap2"
	wave getslopmap3 = $"getslopmap3"
	killwaves getslopmap1,getslopmap2,getslopmap3


	di(nameqbypw)
	ModifyGraph width={Plan,1,bottom,left}
	TextBox/C/N=text0/F=0/A=MT/X=0.00/Y=0 "\\$WMTEX$ \\sqrt{(\\frac{d\\phi}{dx})^{2}+(\\frac{d\\phi}{dy})^{2}} \\$/WMTEX$"
end


//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////

Function phaseextractionforq(name,qx1,qy1,avedia)
	String name    // the data to be manipulated
	variable qx1   // The FFT value of the vector, conversion (1/a), the scaled value directly readed from igor FFT image.
	variable qy1
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
		//FFT/PAD={3*dimsize(namew,0),3*dimsize(namew,1)}/OUT=1/DEST=$normdataFFT  normdataw
			FFT/OUT=1/DEST=$normdataFFT  normdataw

		wave/c normdataFFTw = $normdataFFT

		normdataFFTw*=(sqrt(pi)*widthq)^(-1)*exp((-x^2-y^2)/(widthq^2))
		string normdataiff = normdata+"_IFF"
		IFFT/DEST=$normdataiff  normdataFFTw
		//wave normdataiffw =$normdataiff
		//unpadding(name,normdataiffw)
		//string afternorm = normdataiff+"_up"
		//wave afternormw = $afternorm
			wave afternormw = $normdataiff



	//** Q_A ********************************************
	string tphase1
	tphase1 = name+"_phi_A_forQ"

		//****real part cosine
			String nameFFT1c,namec1c,nameFFTfilter1c,nameiff1c
			namec1c = name+"c1c"
			nameFFT1c = name+"raw_FFT1c"
			nameFFTfilter1c = nameFFT1c+"filter1c"
			nameiff1c = name+"ifft1c"
			duplicate/o namew $namec1c
			wave namec1cw = $namec1c
			namec1cw=namew*cos(qx1*x+qy1*y)
			//FFT/PAD={3*dimsize(namew,0),3*dimsize(namew,1)}/OUT=1/DEST=$nameFFT1c  namec1cw
				FFT/OUT=1/DEST=$nameFFT1c  namec1cw

			wave/c nameFFT1cw = $nameFFT1c
			duplicate/c/o nameFFT1cw $nameFFTfilter1c
			wave/c nameFFTfilter1cw=$nameFFTfilter1c
			nameFFTfilter1cw=nameFFT1cw*(sqrt(pi)*widthq)^(-1)*exp((-x^2-y^2)/(widthq^2))

			IFFT/DEST=$nameiff1c  nameFFTfilter1cw
			//wave nameiff1cw=$nameiff1c
			//unpadding(name,nameiff1cw)
			//string afterup1c = nameiff1c+"_up"
			//wave afterup1cw = $afterup1c
				wave afterup1cw = $nameiff1c

		//****Imag part cosine
			String nameFFT1s,namec1s,nameFFTfilter1s,nameiff1s
			namec1s = name+"c1s"
			nameFFT1s = name+"raw_FFT1s"
			nameFFTfilter1s = nameFFT1s+"filter1s"
			nameiff1s = name+"ifft1s"
			duplicate/o namew $namec1s
			wave namec1sw = $namec1s
			namec1sw=namew*sin(qx1*x+qy1*y)
			//FFT/PAD={3*dimsize(namew,0),3*dimsize(namew,1)}/OUT=1/DEST=$nameFFT1s  namec1sw
				FFT/OUT=1/DEST=$nameFFT1s  namec1sw

			wave/c nameFFT1sw = $nameFFT1s
			duplicate/c/o nameFFT1sw $nameFFTfilter1s
			wave/c nameFFTfilter1sw=$nameFFTfilter1s
			nameFFTfilter1sw=nameFFT1sw*(sqrt(pi)*widthq)^(-1)*exp((-x^2-y^2)/(widthq^2))
			IFFT/DEST=$nameiff1s  nameFFTfilter1sw
			//wave nameiff1sw=$nameiff1s
			//unpadding(name,nameiff1sw)
			//string afterup1s = nameiff1s+"_up"
			//wave afterup1sw = $afterup1s
				wave afterup1sw = $nameiff1s

	    //****calculate phase field theta1(r)
			duplicate/o namew $tphase1
			wave tphase1w = $tphase1
			tphase1w=atan2(afterup1sw/afternormw,afterup1cw/afternormw)

		killwaves normdataw normdataFFTw $normdataiff //afternormw
		killwaves namec1cw nameFFT1cw nameFFTfilter1cw $nameiff1c //afterup1cw
		killwaves namec1sw nameFFT1sw nameFFTfilter1sw $nameiff1s //afterup1sw
end


Function phaseextractionforq_pad(name,qx1,qy1,avedia)
	String name    // the data to be manipulated
	variable qx1   // The FFT value of the vector, conversion (1/a), the scaled value directly readed from igor FFT image.
	variable qy1
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
		string normdataiff = normdata+"_IFF"
		IFFT/DEST=$normdataiff  normdataFFTw
		wave normdataiffw =$normdataiff
		unpadding(name,normdataiffw)
		string afternorm = normdataiff+"_up"
		wave afternormw = $afternorm



	//** Q_A ********************************************
	string tphase1
	tphase1 = name+"_phi_A_forQ"

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
			duplicate/c/o nameFFT1cw $nameFFTfilter1c
			wave/c nameFFTfilter1cw=$nameFFTfilter1c
			nameFFTfilter1cw=nameFFT1cw*(sqrt(pi)*widthq)^(-1)*exp((-x^2-y^2)/(widthq^2))

			IFFT/DEST=$nameiff1c  nameFFTfilter1cw
			wave nameiff1cw=$nameiff1c
			unpadding(name,nameiff1cw)
			string afterup1c = nameiff1c+"_up"
			wave afterup1cw = $afterup1c

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
			duplicate/c/o nameFFT1sw $nameFFTfilter1s
			wave/c nameFFTfilter1sw=$nameFFTfilter1s
			nameFFTfilter1sw=nameFFT1sw*(sqrt(pi)*widthq)^(-1)*exp((-x^2-y^2)/(widthq^2))
			IFFT/DEST=$nameiff1s  nameFFTfilter1sw
			wave nameiff1sw=$nameiff1s
			unpadding(name,nameiff1sw)
			string afterup1s = nameiff1s+"_up"
			wave afterup1sw = $afterup1s

	    //****calculate phase field theta1(r)
			duplicate/o namew $tphase1
			wave tphase1w = $tphase1
			tphase1w=atan2(afterup1sw/afternormw,afterup1cw/afternormw)

		killwaves normdataw normdataFFTw $normdataiff afternormw
		killwaves namec1cw nameFFT1cw nameFFTfilter1cw $nameiff1c afterup1cw
		killwaves namec1sw nameFFT1sw nameFFTfilter1sw $nameiff1s afterup1sw
end

Function getslopmap(name)
	wave name
	duplicate/o name getslopmap1,getslopmap2,getslopmap3
	matrixtranspose getslopmap2
	differentiate getslopmap1
	differentiate getslopmap2
	matrixtranspose getslopmap2
	getslopmap3 = sqrt(getslopmap1^2+getslopmap2^2)

	getslopmap3[0][] *=-1
	getslopmap3[][0] *=-1

	variable med = median(getslopmap3)

	//string getslopmapinfor=nameofwave(name)+"_slopeinfor"
	//make/n=(2)/o $getslopmapinfor
	//wave getslopmapinforw = $getslopmapinfor
	//getslopmapinforw[0] = median(getslopmap3)
	//getslopmapinforw[1] = ave100median(getslopmap3)

	return med
end


//Function ave100median(name)
//	wave name
//	variable ref = median(name)
//
//	variable suma = 0
//	variable count = 0
//	variable i,j
//	i=0
//	do
//		j=0
//		do
//			if (name[i][j]< ref+10*ref && name[i][j]> ref-10*ref)
//				suma+= name[i][j]
//				count+=1
//			endif
//
//			j+=1
//		while (j<dimsize(name,1))
//		i+=1
//	while (i<dimsize(name,0))
//	variable ave = suma/count
//	return ave
//end

//////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_peakIndi(ctrlName) : ButtonControl
	String ctrlName
	Execute "peakIndi()"
end
Proc peakIndi()
	//String name = namefftraw+"_FFT_Modula_INTER"
	String name = getall2dwaveongraph()
	peakget(name,namefftraw)
End
Function/Wave peakget(name111,nameraw)
	String name111
	string nameraw
	GetMarquee left, bottom

	wave name111w = $name111
	String name1111 = name111+"_f"
	duplicate/o name111w $name1111
	wave name1111w=$name1111
	name1111w=nan;
	CurveFit/Q gauss2D name111w(V_left,V_right)(V_bottom,V_top) /D=name1111w(V_left,V_right)(V_bottom,V_top);

	variable xa_G, ya_G, wx,wy
	string W_coef = "W_coef"
	wave W_coefw = $W_coef
	xa_G = W_coefw[2]
	ya_G = W_coefw[4]
	wx = W_coefw[3]
	wy = W_coefw[5]
	//Print "Coordiante (x,y) from Figure is ("+num2str(xa_G)+","+num2str(ya_G)+")."
	String cpickas = nameraw+"_Q"
	make/N=4/o $cpickas
	wave cpicka = $cpickas
	cpicka[0] = xa_G
	cpicka[1] = ya_G
	cpicka[2] = wx
	cpicka[3] = wy

	//Print "Qa got. Qa = ("+num2str(xa_G)+","+num2str(ya_G)+")"
	TextBox/C/N=text0/F=0/A=LB/X=0.00/Y=0.00 "Q = ("+num2str(xa_G)+","+num2str(ya_G)+")"
	string Fitq1x =nameraw+"_getqx"
	string Fitq1y =nameraw+"_getqy"
	make/N=1/o $Fitq1x
	make/N=1/o $Fitq1y
	wave Fitq1xw = $Fitq1x
	wave Fitq1yw = $Fitq1y
	Fitq1xw[0] = xa_G
	Fitq1yw[0] = ya_G
	if(ckwaveonfig(winname(0,1),Fitq1y)==0)
		appendtograph Fitq1yw vs Fitq1xw
		ModifyGraph mode=3,marker=1,rgb=(0,0,65535), mrkThick=2
	endif
	Return cpicka
end