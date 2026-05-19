#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
Function ButtonProc_plotlattice(ctrlName) : ButtonControl
	String ctrlName
	Execute "plotlattice()"
end
/////////////////////////////////////////////////////////////////////////////
//this procedure can draw lattice in 2D. it can also be used as a fitting to
//an experimental data, by manually adjust these parameters.
/////////////////////////////////////////////////////////////////////////////
proc plotlattice(num,theta,ah,av,b,c)
	variable num
	variable theta
	variable ah=3.79
	variable av=3.79
	variable b
	variable c
	prompt num,"number of line"
	prompt theta,"angle of lattice to x+"
	prompt ah,"lattice constance h"
	prompt av,"lattice constance v"
	prompt b,"offset#1"
	prompt c,"offset#2"
	string lset,hset
	//NVAR topgraphimage=topgraphimage
	variable i
	Capturenamedd()
	i=0
	do
		lset=topgraphimage+"hori"+num2str(i)
		hset=topgraphimage+"verti"+num2str(i)
		make/N=10/O  $lset
		make/N=10/O  $hset
		setscale/I x, -100,100,"", $lset
		setscale/I x, -100,100,"", $hset
		$lset=tan(theta*pi/180)*x+ah*i/cos(theta*pi/180)+b
		$hset=tan((theta+90)*pi/180)*x+av*i/cos((theta+90)*pi/180)+c
		append $lset $hset
		//append $hset
		i+=1
	while(i<num)
	print "plotlattice("+num2str(num)+","+num2str(theta)+","+num2str(ah)+","+num2str(av)+","+num2str(b)+","+num2str(c)+")"
end
///////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//this procedure solve a simulation problem, that make 2D lattice matrix by two
//sets of lines, the atoms locate at the intersections.\
//algrithom, we use the 2D guassian to make this,
//the kernal part is to determine the positions of the atomics
//1. find a initial point (xi,yi) of the left-top atom,
//2. determine the ''many'' to fully cover the region of interest xn,yn
//3, use the same value of theta, av, ah, in the last procedure
////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Makelatticedata(ctrlName) : ButtonControl
	String ctrlName
	Execute "Makelatticedata()"
end

Proc Makelatticedata(xi,yi,many,theta,av,ah,sigmaa,xn,yn)
	variable xi =-98.945
	variable yi =50.23298
	variable many = 50
	variable theta = 52
	variable av = 3.8
	variable ah = 3.6
	variable sigmaa = 1
	variable xn = 50
	variable yn = 50
	prompt xi,"xi(initial x for calculation)"
	prompt yi,"yi(initial y for calculation)"
	prompt many,"The size of lattice will be calculated is many x many"
	prompt theta,"angle of lattice to x+ (degree)"
	prompt ah,"ah(lattice constance h)"
	prompt av,"av(lattice constance v)"
	prompt sigmaa,"sigma of the Guassian"
	prompt xn,"x scale of lattice"
	prompt yn,"y scale of lattice"


		make/O/N=(many*many) xvaluematrix
		make/O/N=(many*many) yvaluematrix
		make/o/N=(500, 500) Guassiansimulation
		Setscale/I x,0,xn,"",Guassiansimulation
		Setscale/I y,0,yn,"",Guassiansimulation
		findtheintersection(xi,yi,many,theta,av,ah,sigmaa)

		display;appendimage Guassiansimulation
		print "Makelatticedata("+num2str(xi)+","+num2str(yi)+","+num2str(many)+","+num2str(theta)+","+num2str(av)+","+num2str(ah)+","+num2str(sigmaa)+","+num2str(xn)+","+num2str(yn)+")"
end

Function findtheintersection(xi,yi,many,theta,av,ah,sigmaa)
	variable xi
	variable yi
	variable many
	variable theta
	variable av
	variable ah
	variable sigmaa

	string xvaluematrix
		xvaluematrix="xvaluematrix"
	string yvaluematrix
		yvaluematrix="yvaluematrix"
	Wave xx = $xvaluematrix

	Wave yy = $yvaluematrix

	Variable i,j,k
		k=0
		i=0
		do
			j=0
			do

			xx[k] = xi+av*cos((theta)*pi/180)*j+ah*sin((theta)*pi/180)*i
			yy[k] = yi+av*sin((theta)*pi/180)*j-ah*cos((theta)*pi/180)*i

			k+=1
			j+=1
			while (j< many)
		i+=1
		while (i<many)


	string Guassiansimulation
	Guassiansimulation="Guassiansimulation"
	Wave mmmm= $Guassiansimulation
	mmmm=0
	variable ii
	ii=0
	do
	mmmm += (1/(sqrt(2*pi)*sigmaa))*(exp(-((x-xx[ii])^2/(2*sigmaa^2) + (y-yy[ii])^2/(2*sigmaa^2))))


	ii+=1
	while(ii<many*many)
	edit xx yy
end


/////////////////////////////////////////////////////////////////////////////////////////////////////////
//       This is code to show how to do ab initio band calculation based on definite Hamiltonian Model
//
//        Ref: arXiv:1802.01376v1
//
//        This code is compiled to show a 2D (kx,ky,0) eigne value. If you want to get band along high symmetry line
//        please check the code and change the k-space range setting to what you want
//
//         e.g. G-M you need ky=kx      G-X you need ky=0
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_calculateband(ctrlName) : ButtonControl
	String ctrlName
	Execute " calculateband()"
end
proc calculateband()
	claculateband()
end
/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
Function claculateband()
	variable a=3.76
	variable b=3.91
	variable c=12.78
	variable ta=-1.13//eV
	variable tap=-0.31*(-1.13)
	variable tb=0.057*(-1.13)
	variable tbp=0.01*(-1.13)
	variable tab=-0.175*(-1.13)
	variable tbz=0.014*(-1.13)
	variable tbzp=-0.005*(-1.13)
	variable miu=-0.97*(-1.13)
	variable grid=500

	variable xstart=-pi/a
	variable xend=pi/a
	variable ystart=0.2*pi/a
	variable yend=0.3*pi/a


	variable kx
	variable ky
	variable kz=0//calculate gamma plan  if you want to calculate other plan , e.g. Z, please make Z= pi/c

	// if you want to calculate not only the band in (001) plan, you need choose other different k to zero, e.g. (010) kx=0; (110) kx=ky

	variable mxy
	variable mz,mzp1,mzp2,mzp3,mzp4,mzp5
	variable pesai
	variable eigen1, eigen2

	variable i,j
	string W_eigenvalues
	make/o/N=(grid,grid) gm2band1// for 1D BAND you need shrink this wave to 1D// make/o/N=(grid)
	make/o/N=(grid,grid) gm2band2// for 1D BAND you need shrink this wave to 1D// make/o/N=(grid)
	W_eigenvalues="W_eigenvalues"
	j=0
	do
		i=0
		do
			kx=xstart+(xend-xstart)/(grid-1)*i
			ky=ystart+(yend-ystart)/(grid-1)*j

			//For1D band you need make relation like "ky=kx" for G-M here
			//If you do not calculate (010) plan, you may change k varaible accordingly.

			mxy=2*ta*(cos(kx*a)+cos(ky*b))+miu+2*tap*cos(kx*a+ky*b)+2*tap*cos(kx*a-ky*b)
			mzp1=2*tb*(cos(kx*a)+cos(ky*b))-miu
			mzp2=2*tbp*cos(kx*a+ky*b)+2*tbp*cos(kx*a-ky*b)
			mzp3=2*tbz*cos(0.5*(kx*a+ky*b+kz*c))+2*tbz*cos(0.5*(kx*a-ky*b+kz*c))+2*tbz*cos(0.5*(-kx*a-ky*b+kz*c))+2*tbz*cos(0.5*(-kx*a+ky*b+kz*c))
			mzp4=2*tbzp*cos(0.5*(3*kx*a+ky*b+kz*c))+2*tbzp*cos(0.5*(3*kx*a-ky*b+kz*c))+2*tbzp*cos(0.5*(-3*kx*a-ky*b+kz*c))+2*tbzp*cos(0.5*(-3*kx*a+ky*b+kz*c))
			mzp5=2*tbzp*cos(0.5*(kx*a+3*ky*b+kz*c))+2*tbzp*cos(0.5*(kx*a-3*ky*b+kz*c))+2*tbzp*cos(0.5*(-kx*a-3*ky*b+kz*c))+2*tbzp*cos(0.5*(-kx*a+3*ky*b+kz*c))
			mz=mzp1+mzp2+mzp3+mzp4+mzp5

			pesai=2*tab*(cos(kx*a)-cos(ky*b))
			make/o/n=(2,2)/D solvematrix
			solvematrix[0][0]=mxy
			solvematrix[0][1]=pesai
			solvematrix[1][0]=pesai
			solvematrix[1][1]=mz
			matrixeigenv solvematrix
			wave/C n=$W_eigenvalues
			make/n=2/o sorteigen

			//sorteigen[0]= real(W_eigenvalues[0])
			//sorteigen[1]= real(W_eigenvalues[1])
			sorteigen[0]= real(N[0])
			sorteigen[1]= real(N[1])

			sort sorteigen sorteigen
			gm2band1[i][j]=sorteigen[0]
			gm2band2[i][j]=sorteigen[1]
			i+=1
		while(i<grid)
		j+=1
	while(j<grid)
	setscale/I x, xstart, xend,"",gm2band1
	setscale/I x, xstart, xend,"",gm2band2
	setscale/I y, ystart, yend,"",gm2band1
	setscale/I y, ystart, yend,"",gm2band2
	display;appendimage  gm2band1;
	display;appendimage  gm2band2// For 1D band , you need change here accordingly.

end

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////



Function ButtonProc_S_Svortex(ctrlName) : ButtonControl
	String ctrlName
	Execute "automultiSV()"
end

/////////////////////////////////////////////////
Function UserFunctionsstunneling(dE)//
	Variable dE
	variable ft//ft(E-eV)
	variable fs//fs(E)
	variable Nt//nt(E-eV)
	variable Ns//Ns(E)
	variable deltavs

	NVAR Db=Db //meV
	NVAR eVp=eVp //meV
	NVAR deltaGs=deltaGs//meV
	NVAR deltaGt=deltaGt//meV
	NVAR Kc=Kc //nm
	NVAR rv=rv //nm
	NVAR Tem=Tem //K

	ft=1/(exp((dE-eVp)/(0.086*Tem))+1)
	fs=1/(exp((dE)/(0.086*Tem))+1)
	//deltavt=deltagt*tanh(rv/Kc)
	deltavs=deltags*tanh(rv/Kc)
	Ns=real(sqrt(dE^2+db^2)/(cmplx(dE^2-db^2-deltavs^2,-2*dE*db))^(1/2))
	Nt=real(sqrt((dE-evP)^2+db^2)/(cmplx((dE-evp)^2-db^2-deltagt^2,-2*(dE-evp)*db))^(1/2))
	return ((ft-fs)*Nt*Ns)
end
/////////////////////////////////////////////////
proc testint(grid,Kc,Db,deltaGs,deltaGt,tem,xrange,Erange,rv)//
	variable Grid=600
	variable Kc=47
	variable Db=0.1
	variable deltaGs=1.5
	variable deltaGt=1.5
	variable tem=0.45
	variable xrange=50//nm
	variable Erange=5//meV
	variable rv=1000//nm spectrum
	PauseUpdate
		Silent 1
	variable evp
	variable i
	make/o/N=(grid) testwavesv
	setscale/I x, -Erange,Erange,"",testwavesv
	i=0
	do
		evp=-Erange+i*(dimdelta(testwavesv,0))
		testwavesv[i]=integrate1d(UserFunctionsstunneling,-Erange*2,Erange*2,0)
		I+=1
	while(I<grid)
	//smooth 10,testwavesv
	differentiate testwavesv
	//display testwavesv
end
//////////////////////////////////////////////////////////////////
proc automultiSV(grid,Kc,Db,deltaGs,deltaGt,tem,xrange,Erange,num,mat)
	variable Grid=600
	variable Kc=47
	variable Db=0.1
	variable deltaGs=1.5
	variable deltaGt=1.5
	variable tem=0.45
	variable xrange=50//nm
	variable Erange=5//meV
	variable num=10
	string mat="simu"
	prompt Grid,"Number of data point"
	prompt Kc,"Coherent length (nm)"
	prompt db,"Dyne broadenig (meV)"
	prompt deltaGs,"Gap Amplitude of sample (meV)"
	prompt deltaGt,"Gap Amplitude of tip (meV)"
	prompt tem,"Temperature (K)"
	prompt xrange,"Distance from Core center (nm)"
	Prompt Erange,"Energy Range (meV)"
	Prompt num,"Number of cut"
	Prompt mat,"cut name"
	PauseUpdate
		Silent 1
	string name
	variable rv
	variable i
	i=0
	do
		name=mat+num2str(i+1)
		rv=-xrange+i*(2*xrange/(num-1))
		testint(grid,Kc,Db,deltaGs,deltaGt,tem,xrange,Erange,rv)
		duplicate/o testwavesv $name
		I+=1
	while(i<num)
end
///////////////////////////////////
Function ButtonProc_S_Svortexindiv(ctrlName) : ButtonControl
	String ctrlName
	Execute "indivlinecut()"
end
///////////////////////////////////
proc indivlinecut(grid,Kc,Db,deltaGs,deltaGt,tem,xrange,Erange,rv)//
	variable Grid=600
	variable Kc=47
	variable Db=0.1
	variable deltaGs=1.5
	variable deltaGt=1.5
	variable tem=0.45
	variable xrange=50//nm
	variable Erange=5//meV
	variable rv=1000//nm spectrum
	prompt Grid,"Number of data point"
	prompt Kc,"Coherent length (nm)"
	prompt db,"Dyne broadenig (meV)"
	prompt deltaGs,"Gap Amplitude of sample (meV)"
	prompt deltaGt,"Gap Amplitude of tip (meV)"
	prompt tem,"Temperature (K)"
	prompt xrange,"Distance from Core center (nm)"
	Prompt Erange,"Energy Range (meV)"
	Prompt rv,"Position from vortex (nm)"
	PauseUpdate
		Silent 1
	variable evp
	variable i
	make/o/N=(grid) testwavesv
	setscale/I x, -Erange,Erange,"",testwavesv
	i=0
	do
		evp=-Erange+i*(dimdelta(testwavesv,0))
		testwavesv[i]=integrate1d(UserFunctionsstunneling,-Erange*2,Erange*2,0)
		I+=1
	while(I<grid)
	//smooth 10,testwavesv
	differentiate testwavesv
	display testwavesv
end


///////////////////////////////////////////////////////////////////////////////////////
//
// Scaling 2D
//
///////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Batchscalingoure(ctrlName) : ButtonControl
	String ctrlName
	Execute "Batchscalingoure()"
end
proc Batchscalingoure(xmin,xmax,ymin,ymax,po,grid)
	variable xmin=0.1
	variable xmax=0.5
	variable ymin=0.4
	variable ymax=5
	variable po=0
	variable grid=500
	prompt xmin "Tunnel couple_min (meV)"
	prompt xmax "Tunnel couple_max (meV)"
	prompt ymin "T_min (K)"
	prompt ymax "T_max (K)"
	prompt po "Poison coupling (meV)"

	calGS(xmin,xmax,ymin,ymax,po,grid)
end

Function calGS(xmin,xmax,ymin,ymax,po,grid)
	variable xmin
	variable xmax
	variable ymin
	variable ymax
	variable po
	variable grid


	variable/G Gamwidth
	variable/G TemGS
	variable/G Gamwidth_2

	make/o/n=(grid,grid) Datamatrix
	setscale/I x, xmin,xmax,"",datamatrix
	setscale/I y, ymin,ymax,"",datamatrix
	variable dx,dy
	dx=dimdelta(datamatrix,0)
	dy=dimdelta(datamatrix,1)

	Gamwidth_2=po
	variable i,j
	j=0
	do
		TemGS=ymin+j*dy
		i=0
		do
			Gamwidth=xmin+i*dx
			datamatrix[i][j]=Integrate1D(Function_MBSGS,-100,100)
			i+=1
		while(i<grid)
		j+=1
	while(j<grid)
	display; appendimage datamatrix
	Label left "Temperature (K)"
	Label bottom "\\F'symbol'Γ\\F'times' (meV)"
end

Function Function_MBSGS(inX)
	variable inX
	NVAR Gamwidth=Gamwidth
	NVAR Gamwidth_2=Gamwidth_2
	NVAR TemGS=TemGS
	//return ((Gamwidth^2/(inX^2+Gamwidth^2))*(1/(4*0.086*TemGS*(cosh(inX/(2*0.086*TemGS)))^2)))
	return ((Gamwidth*(Gamwidth_2+Gamwidth)/(inX^2+(Gamwidth_2+Gamwidth)^2))*(1/(4*0.086*TemGS*(cosh(inX/(2*0.086*TemGS)))^2)))
End

proc testgs()
	variable/G Gamwidth=10^-2
	variable/G TemGS=10^5
	print Integrate1D(Function_MBSGS,-100,100)
end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//
// Scaling+Poison        output Gs (2e2/h) vs Gamma (meV) curve under different poiosning rate
//
///////////////////////////////////////////////////////////////////////////////////////
//Batchscaling(0.01,10,0.4,0,0.1,5,1000)
Function ButtonProc_MZMscaling_poison(ctrlName) : ButtonControl
	String ctrlName
	Execute "Batchscaling()"
end
proc Batchscaling(xmin,xmax,tem,po_s,po_delta,num,grid)
	variable xmin=0.01//gamma
	variable xmax=10
	variable tem=0.4
	variable po_s=0
	variable po_delta=0.1
	variable grid=1000//the point number for integration
	variable num=5//how many posion data curves

	variable i
	string haha
	display
	i=0
	do
		calGSpo(xmin,xmax,tem,po_s+po_delta*i,grid)
		haha="poi_"+num2str(tem)+"K_"+num2str(po_s+po_delta*i)
		duplicate/o datamatrix $haha
		appendtograph $haha
		i+=1
	while(i<num)
	//make/o/n=(grid) xwavee
	//xwavee=0.086*tem/(xmin+(xmax-xmin)*p/(grid-1))
end

Function calGSpo(xmin,xmax,tem,po,grid)
	variable xmin//gamma
	variable xmax
	//variable ymin//Tem
	//variable ymax
	variable tem
	variable po
	variable grid
	variable/G Gamwidth
	variable/G Gamwidth_2
	variable/G TemGS
	//make/o/n=(grid,grid) Datamatrix
	make/o/n=(grid) Datamatrix
	setscale/I x, xmin,xmax,"",datamatrix
    // setscale/I x,(0.086*tem/xmin),(0.086*tem/xmax),"",datamatrix
	//setscale/I y, ymin,ymax,"",datamatrix
	variable dx,dy
	dx=dimdelta(datamatrix,0)
	dy=dimdelta(datamatrix,1)
	variable i,j
        //Gamwidth_2=Gamwidth^po
	Gamwidth_2=po
	//j=0
	//do
	TemGS=tem
	i=0
	do
		Gamwidth=xmin+i*dx
		datamatrix[i]=Integrate1D(Function_MBSGSpo,-100,100)
		i+=1
	while(i<grid)
	//j+=1
	//while(j<grid)
	//Label left "Temperature (K)"
	//Label bottom "\\F'symbol'Γ\\F'times' (meV)"
end

Function Function_MBSGSpo(inX)
	variable inX
	NVAR Gamwidth=Gamwidth
	NVAR Gamwidth_2=Gamwidth_2
	NVAR TemGS=TemGS
	//return ((Gamwidth^2/(inX^2+Gamwidth^2))*(1/(4*0.086*TemGS*(cosh(inX/(2*0.086*TemGS)))^2)))
	return ((Gamwidth*(Gamwidth_2+Gamwidth)/(inX^2+(Gamwidth_2+Gamwidth)^2))*(1/(4*0.086*TemGS*(cosh(inX/(2*0.086*TemGS)))^2)))
End

proc testgspo()
	variable/G Gamwidth=10^-2
	variable/G TemGS=10^5
	print Integrate1D(Function_MBSGSpo,-100,100)
end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
// Here is a non- accurate numerical bulit of  Macdonald Function
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
Function macdonald(a,b)
	variable a //the order of function
	variable b //the independence variable
	variable/G v=a
	variable/G z=b
	return 0.5*(0.5*z)^v * integrate1d(macintegrand, 0.0001,1000,1)
	//return integrate1d(macintegrand,0.1,10000,1)
end
Function macintegrand(t)
	variable t
	NVAR z=z
	NVAR v=v
	variable p1,p2
	p1=exp(-t-z^2/(4*t))
	p2=t^(-v-1)
	return p1*p2
	//return exp(-t^2*z*v)
end
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
// Here is the procedure to calcultate energe level of CdGM states related to single quantized vortex (voeticity n=1), in a superconducting Dirac Material
// Refenrence  Eq (20) in PHYSICAL REVIEW B 79, 224506  (2009)
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
Function ButtonProc_CdGMDirac(ctrlName) : ButtonControl
	String ctrlName
	Execute "CdGM_Dirac_singlevortex()"
end
Proc CdGM_Dirac_singlevortex(EF,hv,delta,level)
	variable EF //meV
	variable hv=250 //meV.A
	variable delta=1.8 //meV
	variable level=10
	prompt EF,"Fermi Energy (meV)"
	prompt hv, "Fermi Velocity (meV A)"
	prompt delta,"SC gap (meV)"
	prompt level, "How many levels do you want to display"

	variable kf
	variable kesai
	kf=EF/hv
	kesai=hv/delta
	string mat
	mat="CDGM_gap"+num2str(delta)+"_EF"+num2str(EF)
	make/N=(2*level+1)/o $mat
	setscale/I x, -level,level,"",$mat
	$mat =   delta*(-x/kf)*      macdonald(0,2*sqrt((-x/(kf*kesai))^2+1))    /   (    macdonald(1,2*sqrt((-x/(kf*kesai))^2+1))      *sqrt((-x/kf)^2+kesai^2)                   )
	EDIT $MAT
	display $mat
	ModifyGraph mode=3,marker=8
	ModifyGraph zero(left)=1
	ModifyGraph mirror=2
	ModifyGraph nticks(bottom)=(level*2)
	ModifyGraph grid(bottom)=1
	Label left "\\Z16\\F'Helvetica'Energy (meV)"
	Label bottom "\\Z16\\F'Helvetica'Angular Momentum v"
end

// under this procedure the energy under unit "meV"
// Ref: 10.1038/ncomms11139
//Revisiting the vortex-core tunnelling spectroscopy in YBa2Cu3O7-d
Function ButtonProc_dscgap(ctrlName) : ButtonControl
	String ctrlName
	Execute " plotdgap()"
	end
proc plotdgap(grid, gam, delta, range)
	variable grid=500 // number of data points
	variable range=90 // define spectral length (meV)
	variable gam=0.5   //dyne broadening  (meV)
	variable delta=17//SC gap (meV)
	prompt grid,"Number of points"
	prompt range,"Energy range of spectra (meV)"
	prompt gam,"Dyne width (meV)"
	prompt delta,"SC gap (meV)"

	variable/G Ga  //dyne broadening  (meV)
	variable/G d //SC gap (meV)
	variable/G Eer // energy (meV)
	variable i
	Ga=gam
	d=delta
	i=0
	make/o/n=(grid) spectra
	setscale/I x,(-1*range),range, "",spectra   // define spectral length
	do
		Eer=-range+2*range*i/(grid-1)
		spectra[i]=integrate1D(UserFunctionG,-range*2,range*2,1)
		I+=1
	while (i<grid)
	display spectra
end

Function UserFunctionG(inX)
	Variable inX
	variable Ne
	variable SC
	NVAR Ga=Ga
	NVAR Eer=Eer
	NVAR d=d
	 Ne=(1+ exp(-(inx-5)^2/0.1)+exp(-(inx+5)^2/0.1))  // normal states
        SC=imag((cmplx(Eer,Ga)+inX)/(sqrt(cmplx(Eer,Ga)^2-inX^2) *sqrt(cmplx(Eer,Ga)^2-inX^2-d^2)))	// d-wave pairing with isotropic normal states
	//return (-1/pi*((1+ exp(-(inx-5)^2/0.1)+exp(-(inx+5)^2/0.1))* imag((cmplx(Eer,Ga)+inX)/(sqrt(cmplx(Eer,Ga)^2-inX^2) *sqrt(cmplx(Eer,Ga)^2-inX^2-d^2)))))
	//return ( -1/pi*imag((cmplx(Eer,Ga)+inX)/(sqrt(cmplx(Eer,Ga)^2-inX^2) *sqrt(cmplx(Eer,Ga)^2-inX^2-d^2))))
	return ( -1/pi*Ne*SC)
End
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Svortex(ctrlName) : ButtonControl
	String ctrlName
	Execute " DyneModbyvortex()"
end
proc DyneModbyvortex(grid,K,b1,delta,xrange,Erange)
	variable Grid=1000
	variable K=3
	variable b1=0.1
	variable delta=1.8
	variable xrange=10//nm
	variable Erange=5//meV
	prompt Grid,"Number of data point"
	prompt K,"Coherent length (nm)"
	prompt b1,"Dyne broadenig (meV)"
	prompt delta,"Gap Amplitude (meV)"
	prompt xrange,"Distance from Core center (nm)"
	Prompt Erange,"Energy Range (meV)"
	DOSvor(grid,K,b1,delta,xrange,Erange)
end

Function DOSvor(grid,K,b1,delta,xrange,Erange)
	variable Grid
	variable K
	variable b1
	variable delta
	variable xrange//nm
	variable Erange//meV

	variable E//Energy
	variable d1
	variable r
	variable p,q

	make/o/N=(grid,grid)  DOSvortex
	setscale/I x, -Erange,Erange,"",DOSvortex//energy
	setscale/I y, -xrange,xrange,"",DOSvortex//length

	p=0
	do
		q=0
		do
			r= -xrange+q*(dimdelta(DOSvortex,1))
			E=-Erange+p*(dimdelta(DOSvortex,0))
			d1=delta*tanh(r/k)
			DOSvortex[p][q]= real(sqrt(E^2+b1^2)/(cmplx(E^2-b1^2-d1^2,-2*E*b1))^(1/2))
			q+=1
		while(q<grid)
		p+=1
	while(p<grid)
	display; appendimage DOSvortex
	TextBox/C/N=text0/F=0/A=MC "Coherence "+num2str(K)+" nm; "+" gap "+num2str(delta)+" meV "
	Label left "\\Z20\\F'times'Distance (nm)"
	Label bottom "\\Z20\\F'times'Energy\\M\\F'times'\\Z20 (meV)"
end

//////////////////
Function ButtonProc_fanoline(ctrlName) : ButtonControl
	String ctrlName
	Execute " fanoline()"
end
proc fanoline(G_res, E_res,endnum)
	variable G_res=0.5 //FWHM of resonace peak
	variable E_res=3 //resonace energy
	variable endnum=1 //
	variable q
	string fanol
	display
	q=0
	do
		fanol="fano"+num2str(q)
		make/N=500/o $fanol
		setscale/I x, E_res-10*G_res,E_res+10*G_res,"",$fanol
		$fanol=(q*G_res+x-E_res)^2/((G_res/2)^2+(x-E_res)^2)
		//wavestats/Q $fanol
		//$fanol/=V_max
		append $fanol
		q+=0.2
	while(q<endnum)
end









Function ButtonProc_tbmodel(ctrlName) : ButtonControl
	String ctrlName
	Execute "tbmodel()"
end

proc tbmodel(t1,t2,t3,u,rx1,rx2,ry1,ry2,grid)
	variable t1 =-281
	variable t2=139
	variable t3=-44
	variable u=-356
	variable grid=500
	variable rx1=-pi
	variable rx2=pi
	variable ry1=-pi
	variable ry2=pi
	prompt t1,"t1(N) meV"
	prompt t2,"t2(NN) meV"
	prompt t3,"t3(NNN) meV"
	prompt u,"Chemical potential meV"
	prompt grid,"Number of points"
	prompt rx1,"left of kx (0,2pi)"
	prompt rx2,"right of kx (0,2pi)"
	prompt ry1,"left of ky (0,2pi)"
	prompt ry2,"right of ky (0,2pi)"


	variable i,ky
	string wavelinek
	make/o/n=(grid) kxwave
	make/o/n=(grid) kywave
	kxwave=-Pi+2*pi*p/(grid-1)
	kywave=-pi+2*pi*p/(grid-1)
	i=0
	do
		wavelinek="wavell"+num2str(i+1)
		make/o/n=(grid) $wavelinek
		setscale/I x, rx1, rx2,"",$wavelinek
		ky=ry1+(ry2-ry1)*i/(grid-1)
 		$wavelinek=2*t1*(cos(x)+cos(ky))+4*t2*(cos(x)*cos(ky))+2*t3*( cos(2*x)+cos(2*ky))//+(t_v/4 )*(cos(x)- cos(ky))^2-u    (this part is anti-bonding band via a bilayer coupling )
		//$wavelinek=2*t1*(cos(x)+cos(ky))+4*t2*(cos(x)*cos(ky))+2*t3*( cos(2*x)+cos(2*ky))-(t1/4 )*(cos(x)- cos(ky))^2-u
		//$wavelinek=-2*(t1/4 )*(cos(x)- cos(ky))^2

		i+=1
	while(i<grid)

	linkstsmap_P("wavell",grid)
	duplicate/o mapsts bandstructure
	display;appendimage bandstructure
	ModifyImage bandstructure ctab= {*,*,Terrain256,0}
	setscale/I y, ry1, ry2,"",bandstructure
	modifygraph width=400,height={Plan,1,left,bottom}
	ModifyGraph grid=1,gridRGB=(0,0,0)
	setscale/p y, dimoffset(bandstructure,1)/pi,  dimdelta(bandstructure,1)/pi,"",bandstructure
	setscale/p x, dimoffset(bandstructure,0)/pi,  dimdelta(bandstructure,0)/pi,"",bandstructure
	Label bottom "\\Z22\\F'times'k\\B\\Z22x\\M\\Z22 (\\F'symbol'π\\F'times'/\\f02a\\f00)"
	Label left "\\Z22\\F'times'k\\B\\Z22y\\M\\Z22 (\\F'symbol'π\\F'times'/\\f02a\\f00)"

	Display;AppendMatrixContour bandstructure vs {kywave,kxwave}
	modifygraph width=400,height={Plan,1,left,bottom}
	ModifyGraph grid=1,gridRGB=(0,0,0)
end
//***************************************************************************************************************************
//***************************************************************************************************************************
//***************************************************************************************************************************
//***************************************************************************************************************************
//***************************************************************************************************************************


//***************************************************************************************************************************
//***************************************************************************************************************************
//
// a tight binding model used in arXiv:1808.08390, and builded in Phys. Rev. X 2, 021009 (2012), to simulate the band structure of Iron-based superconductor.
// In this model only four bands were considered, in which on double degenerate hole band around gamma point and another double degenerate electron band around M points
//This model is builded in an one Fe unit cell.
//
//***************************************************************************************************************************
//***************************************************************************************************************************
Function ButtonProc_tbmodelIBSC(ctrlName) : ButtonControl
	String ctrlName
	Execute " fourbandmodel()"
end
Proc fourbandmodel(a,t2,t2p,t1,t3,u,grid,rx1,rx2,ry1)
	variable t2=55.6
	variable t2p=2.6
	variable a=2.687
	variable t1=53
	variable t3=14.4
	variable u=-51
	variable grid=500
	variable rx1=-pi
	variable rx2=pi
	variable ry1=-pi
	prompt t1,"t1(N) meV"
	prompt a,"Lattice constance (A)"
	prompt t2,"t2(NN_1) meV"
	prompt t2p,"t2p(NN_2) meV"
	prompt t3,"t3(NNN) meV"
	prompt u,"Chemical potential meV"
	prompt grid,"Number of points"
	prompt rx1,"left of kx (0,2pi)"
	prompt rx2,"right of kx (0,2pi)"
	prompt ry1,"left of ky (0,2pi)"
	//prompt ry2,"right of ky (0,2pi)"

	variable  ry2
	ry2=-ry1

	variable ts
	variable td
	ts=(t2+t2p)/2
	td=(t2-t2p)/2

	// 2D band dispersion

	make/o/n=(grid,grid) band1
	setscale/I x, rx1/a,rx2/a,"",band1
	setscale/I y, ry1/a,ry2/a,"",band1
	duplicate/o band1 band2
	band1=4*ts*cos(x*a)*cos(y*a)+2*sqrt(t1^2*(cos(x*a) + cos(y*a))^2 + (2*td*sin(x*a)*sin(y*a))^2)+2*t3*(cos(2*x*a) + cos(2*y*a)) -u
	band2=4*ts*cos(x*a)*cos(y*a)-2*sqrt(t1^2*(cos(x*a) + cos(y*a))^2 + (2*td*sin(x*a)*sin(y*a))^2)+2*t3*(cos(2*x*a) + cos(2*y*a)) -u

	// 1D band dispersion

	make/N=(grid)/o band1dgx
	setscale/I x, 2*rx1/a,2*rx2/a,"",band1dgx
	duplicate/o band1dgx band2dgx
	band1dgx=4*ts*cos(x*a)*cos(x*a)+2*sqrt(t1^2*(cos(x*a) + cos(x*a))^2 + (2*td*sin(x*a)*sin(x*a))^2)+2*t3*(cos(2*x*a) + cos(2*x*a)) -u
	band2dgx=4*ts*cos(x*a)*cos(x*a)-2*sqrt(t1^2*(cos(x*a) + cos(x*a))^2 + (2*td*sin(x*a)*sin(x*a))^2)+2*t3*(cos(2*x*a) + cos(2*x*a)) -u
	display band1dgx band2dgx
	Label left "\\Z22\F'times'\f02E - E\BF\f00\M\F'times'\Z22 (meV)";DelayUpdate
	Label bottom "\Z22\F'times'Momentum (Å\S-1\M\F'times'\Z22)"
	make/N=(grid)/o band1dgm
	setscale/I x, 2*rx1/a,2*rx2/a,"",band1dgm
	duplicate/o band1dgm band2dgm
	band1dgm=4*ts*cos(x*a)*cos(0*a)+2*sqrt(t1^2*(cos(x*a) + cos(0*a))^2 + (2*td*sin(x*a)*sin(0*a))^2)+2*t3*(cos(2*x*a) + cos(2*0*a)) -u
	band2dgm=4*ts*cos(x*a)*cos(0*a)-2*sqrt(t1^2*(cos(x*a) + cos(0*a))^2 + (2*td*sin(x*a)*sin(0*a))^2)+2*t3*(cos(2*x*a) + cos(2*0*a)) -u
	display band1dgm band2dgm
	Label left "\\Z22\F'times'\f02E - E\BF\f00\M\F'times'\Z22 (meV)";DelayUpdate
	Label bottom "\Z22\F'times'Momentum (Å\S-1\M\F'times'\Z22)"
end


//***************************************************************************************************************************
//The nonsinodal CPR from andreev bound state, the model is from PHYSICAL REVIEW B 100, 064523 (2019)
//***************************************************************************************************************************
Function ButtonProc_nonsinodal(ctrlName) : ButtonControl
	String ctrlName
	Execute "nonsinodal()"
end
Proc nonsinodal()
	variable/G tp_cpr = 1
	variable/G delta_cpr = 1// 0.128
	variable/G tt_cpr = 0.1
	variable tp = tp_cpr
	variable delta = delta_cpr
	variable tt = tt_cpr

	make/o/N=(500) nonsinodalcpr
	setscale/i x,0,3.8*10,"",nonsinodalcpr

	variable h_bar = 6.58*10^(-13) // meV.s
	variable ee = 1.6*10^(-19) // C

	variable precoeff = ee*delta^2/(2*h_bar)
	//Now, convert the current with the unit of nA
	nonsinodalcpr= 10^9*precoeff*sin(2*pi*x/3.8)*(tp/(delta*sqrt(1-tp*(sin(pi*x/3.8))^2)))*tanh(delta*sqrt(1-tp*(sin(pi*x/3.8))^2)/(2*0.086*TT/1000))
	duplicate/o nonsinodalcpr sinref
	sinref=sin(2*pi*x/3.8)
	WAVESTATS/Q nonsinodalcpr
	sinref*=V_max

	renormcuts_k("nonsinodalcpr",1,3.8/2)
	renormcuts_k("sinref",1,3.8/2)
	display  sinref nonsinodalcpr
	Label left "\\Z16I (nA)"
	Label Bottom "\\Z16Φ (π)"
	ModifyGraph nticks(bottom)=10,grid(bottom)=1

	ModifyGraph margin(top)=21
	modifygraph width=800,height=150
	ModifyGraph rgb(sinref)=(61166,61166,61166),lsize(sinref)=6
	ModifyGraph mode(nonsinodalcpr)=4,marker(nonsinodalcpr)=43
	SetVariable setvartp title="τ\Bp",limits={0,1,0.05},value=tp_cpr,proc=SetVarProc_tp_cpr,size={80,15}
	SetVariable setvardelta title="Δ(meV)",limits={0,inf,0.1},value=delta_cpr,proc=SetVarProc_tp_cpr,size={80,15}
	SetVariable setvartt title="T(mK)",limits={0,inf,100},value=tt_cpr,proc=SetVarProc_tp_cpr,size={80,15}
	ValDisplay valdisp0 value=3.5*0.086*tt_cpr/1000,title="3.5k\\BB\\MT (meV)",size={150,13}
end

Function SetVarProc_tp_cpr(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	execute "nonsinodalcprf()"
End

proc nonsinodalcprf()
	variable tp = tp_cpr
	variable delta = delta_cpr
	variable tt = tt_cpr


	variable h_bar = 6.58*10^(-13) // meV.s
	variable ee = 1.6*10^(-19) // C

	variable precoeff = ee*delta^2/(2*h_bar)

	make/o/N=(500) nonsinodalcpr
	setscale/i x,0,3.8*10,"",nonsinodalcpr

	nonsinodalcpr= 10^9*precoeff*sin(2*pi*x/3.8)*(tp/(delta*sqrt(1-tp*(sin(pi*x/3.8))^2)))*tanh(delta*sqrt(1-tp*(sin(pi*x/3.8))^2)/(2*0.086*TT/1000))
	duplicate/o nonsinodalcpr sinref
	sinref=sin(2*pi*x/3.8)
	WAVESTATS/Q nonsinodalcpr
	sinref*=V_max
	renormcuts_k("nonsinodalcpr",1,3.8/2)
	renormcuts_k("sinref",1,3.8/2)
end

//This is the simulation of normal bands in PRB 98,214503 (2018) This is the eignevalue of equation (1)
Function ButtonProc_PRB_98_214503_n(ctrlName) : ButtonControl
	String ctrlName
	execute "PRB_98_214503()"
end

Proc PRB_98_214503(sel)
	variable sel
	prompt sel,"Model of Phys Rev B 98, 214503 (2018)",popup,"Normal state;SC state"
	if (sel == 1)
		PRB_98_214503_normal()
	endif
	if (sel == 2)
		PRB_98_214503_SC()
	endif
end


Function PRB_98_214503_normal()
	variable u = 55 //meV
	variable m = 1/(2*1375) //(meV*A^2)^-1
	variable a = 600 //meV*A^2
	variable Vsoc = 1 // < 15 meV*A
	variable selfimg = 1
	variable selfreal = 0
	//E(x,y) = (-u+(x^2+y^2)/(2*m)+sqrt((a*x*y)^2+(Vsoc*x)^2+(Vsoc*y)^2))

	string/G mat3dn_cons
	variable/G zn_cons
	variable/G z_cons

	make/n=(200,200,200)/o  S2_001
	setscale/i x,-0.4,0.4,"",S2_001
	setscale/i y,-0.4,0.4,"",S2_001
	setscale/i z,-1.2*u,1.2*u,"",S2_001

	S2_001 = (-1/pi)*selfimg/(selfimg^2+(z-selfreal-(-u+(x^2+y^2)/(2*m)+sqrt((a*x*y)^2+(Vsoc*x)^2+(Vsoc*y)^2)))^2)+(-1/pi)*selfimg/(selfimg^2+(z-selfreal-(-u+(x^2+y^2)/(2*m)-sqrt((a*x*y)^2+(Vsoc*x)^2+(Vsoc*y)^2)))^2)



	execute "d3d(\"S2_001\",2)"

	//////Modify the 3D player for this special simulation use (band structure)
	variable/G divcolor_cons
	divcolor_cons = 1
		wavestats/Q $tpw()
		variable rangls = max(abs(V_max),abs(V_min))
		ModifyImage/W=$grabwinchild(tpw()) $tpw() ctab= {-rangls,rangls,:Packages:NewColortable:dvg_seismic,0};
		ColorScale/W=$grabwinchild(tpw())/C/N=textcc/X=-21.00/Y=5.00/F=0 heightPct=30,nticks=5,minor=1,tickLen=1.00,image=$tpw()//;ColorScale/W=$grabwinchild(Fexyd)/C/N=text0/F=0/A=MC/Y=-120 image=$Fexyd
		variable/G normornot_3dplot =2

	variable/G u_normal214503 = u
	variable/G m_normal214503 = m
	variable/G a_normal214503 = a
	variable/G Vsoc_normal214503 = Vsoc
	variable/G selfimg_normal214503 = selfimg
	variable/G selfreal_normal214503 = selfreal


	display/N=PRB_98_214503_normalP
	tilewindows/WINS=winname(0,1)/R/w=(30,43,50,52)/A=(1,1)
	SetVariable setvarz_u_normal win=PRB_98_214503_normalP,title="µ",size={65,14},value=u_normal214503,limits={-inf,inf,1},proc=SetVarProc_PRB_98_214503_normalu
	SetVariable setvarz_m_normal win=PRB_98_214503_normalP,title="m",size={65,14},value=m_normal214503,limits={-inf,inf,0.5*m},proc=SetVarProc_PRB_98_214503_normalm
	SetVariable setvarz_a_normal win=PRB_98_214503_normalP,title="a",size={65,14},value=a_normal214503,limits={-inf,inf,0.5*a},proc=SetVarProc_PRB_98_214503_normala
	SetVariable setvarz_Vsoc_normal win=PRB_98_214503_normalP,title="V\Bsoc\M",size={65,14},value=Vsoc_normal214503,limits={-inf,inf,10},proc=SetVarProc_PRB_98_214503_normalvsoc
	SetVariable setvarz_selfimg_normal win=PRB_98_214503_normalP,title="∑\S''",size={65,14},value=selfimg_normal214503,limits={-inf,inf,1},proc=SetVarProc_PRB_98_214503_normalselfi
	SetVariable setvarz_selfreal_normal win=PRB_98_214503_normalP,title="∑\S'",size={65,14},value=selfreal_normal214503,limits={-inf,inf,1},proc=SetVarProc_PRB_98_214503_normalselfr
	SetVariable setvarz_cons2 win=PRB_98_214503_normalP,title="Z",size={65,14},value=z_cons,proc=SetVarProc_Cons3dplotprbc
	SetVariable setvarz_cons2 win=PRB_98_214503_normalP,limits={dimoffset($mat3dn_cons,zn_cons),(dimoffset($mat3dn_cons,zn_cons)+dimdelta($mat3dn_cons,zn_cons)*(dimsize($mat3dn_cons,zn_cons)-1)),dimdelta($mat3dn_cons,zn_cons)}
	Button launchLinecut win=PRB_98_214503_normalP,title="Linecut",size={65,14},fSize=10,proc=ButtonProc_Cons3dplotlcf2

end

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** {{{{{{{{{{ Launch arbitary Linecut extraction (Z is horizental) }}}}}}}}}}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Cons3dplotlcf2(ctrlName) : ButtonControl
	String ctrlName
	string/G mat3dn_cons

	string mat3dn_consf = mat3dn_cons//+"_FFT3d"


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
		SetVariable setvarangle win=$grabwin(slicename),title="Rotate",size={65,14},value=angle_3dplot,proc=SetVarProc_rotate3dplotf2,pos={159,1}
		SetVariable setvarangle win=$grabwin(slicename),limits={-89,89,1}

		SetVariable setvarangle2 win=PRB_98_214503_normalP,title="Rotate",size={65,14},value=angle_3dplot,proc=SetVarProc_rotate3dplotf22
		SetVariable setvarangle2 win=PRB_98_214503_normalP,limits={-89,89,1}


	//**SetVar of AddY [set the Yrange(angel) by auto search]
		SetVariable setaddY win=$grabwin(slicename),title="LH",size={65,14},value=addY_3dplot,proc=SetVarProc_addY3dplotf2,pos={225,1}
		duplicate/o findrangeforangle_LHf(mat3dn_consf,angle_3dplot,zn_cons) rotateYlimit
		SetVariable setaddY win=$grabwin(slicename),limits={rotateYlimit[0],rotateYlimit[1],1}


		SetVariable setaddY2 win=PRB_98_214503_normalP,title="LH",size={65,14},value=addY_3dplot,proc=SetVarProc_rotate3dplotf22//SetVarProc_addY3dplotf22
		SetVariable setaddY2 win=PRB_98_214503_normalP,limits={rotateYlimit[0],rotateYlimit[1],1}

	//**SetVar of AddX [set the Xrange(angel) by auto search]
		SetVariable setaddX win=$grabwin(slicename),title="LV",size={65,14},value=addX_3dplot,proc=SetVarProc_addX3dplotf2,pos={292,1}
		duplicate/o findrangeforangle_LVf(mat3dn_consf,angle_3dplot,zn_cons) rotateXlimit
		SetVariable setaddX win=$grabwin(slicename),limits={rotateXlimit[0],rotateXlimit[1],1}

		SetVariable setaddX2 win=PRB_98_214503_normalP,title="LV",size={65,14},value=addX_3dplot,proc=SetVarProc_rotate3dplotf22//SetVarProc_addX3dplotf22
		SetVariable setaddX2 win=PRB_98_214503_normalP,limits={rotateXlimit[0],rotateXlimit[1],1}

	//**Extract LinecutH and make graph
		anglelinecutHf(mat3dn_consf,angle_3dplot,zn_cons,addY_3dplot,normornot_3dplot,smornot_3dplot)
		string linecutH = "LH_"+mat3dn_consf
		di($linecutH)
		variable/G FFTmode_3dplot
		if (FFTmode_3dplot == 5)
			ModifyImage $linecutH ctab= {*,*,VioletOrangeYellow,0}
		else
			//color3s_for3d($linecutH,30)
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
			ModifyImage $linecutV ctab= {*,*,VioletOrangeYellow,0}
		else
			//color3s_for3d($linecutV,30)
		endif
		Modifygraph/W=$grabwinnonew(linecutV) width=400, height=200
		Label left "\\Z16\\F'times'\\f02E - E\\BF\\f00\\M\\F'times'\\Z16 (meV)"
		Label bottom "\\Z16\\f02k\\f00 (2π Å\\S\\Z10-1\\M\\Z16)"

		ModifyGraph/W=$grabwinnonew(linecutV) axThick=3,axRGB=(16385,65535,41303),tlblRGB=(16385,65535,41303),alblRGB=(16385,65535,41303)
		tilewindows/WINS=grabwinnonew(linecutV)/R/w=(56,0,100,30)/A=(1,1)



	//** Control of Advanced Modes
		//popupmenu popselectmode3d win=$grabwin(slicename), pos={1,36},bodyWidth=65,proc=PopMenuProc_selmode3dplotf,value="2Point;FreeHand;Circular",bodyWidth=68
		//Button Bfreehandprofile3d win=$grabwin(slicename), title="Go",proc=ButtonProc_L3dplotdof,size={30,15},fSize=11,pos={35,56}


	//** Tile window
		//tilewindows/WINS=WinList("*", ";","WIN:1")/R/w=(3,0,92,100)/A=(2,4)


end

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//##01
//** Control Function:Change addY,
//** Call to change LinecutH and change the indicative line
Function SetVarProc_addY3dplotf2(ctrlName,varNum,varStr,varName) : SetVariableControl
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

	string mat3dn_consf = mat3dn_cons//+"_FFT3d"


	anglelinecutHf(mat3dn_cons,angle_3dplot,zn_cons,addY_3dplot,normornot_3dplot,smornot_3dplot)
	angleline_3dpf2()
	//string linecutH = "LH_"+mat3dn_consf
	//slicesMDC($linecutH)
end
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//##02
//** Control Function:Change addX,
//** Call to change LinecutH and change the indicative line
Function SetVarProc_addX3dplotf2(ctrlName,varNum,varStr,varName) : SetVariableControl
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

	string mat3dn_consf= mat3dn_cons//+"_FFT3d"

	anglelinecutVf(mat3dn_cons,angle_3dplot,zn_cons,addX_3dplot,normornot_3dplot,smornot_3dplot)
	angleline_3dpf2()
	//string linecutH = "LH_"+mat3dn_consf
	//slicesMDC($linecutH)
end

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//##03
//** Control Function:Change Rotation,
//** Call to change LinecutH, LinecutV and change the indicative line, and Setvariable range setaddX/setaddY
Function SetVarProc_rotate3dplotf2(ctrlName,varNum,varStr,varName) : SetVariableControl
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

	string mat3dn_consf= mat3dn_cons//+"_FFT3d"

	string slicename = "Zslice_"+mat3dn_consf

	//Update Linecut
		anglelinecutHf(mat3dn_cons,angle_3dplot,zn_cons,addY_3dplot,normornot_3dplot,smornot_3dplot)
		anglelinecutVf(mat3dn_cons,angle_3dplot,zn_cons,addX_3dplot,normornot_3dplot,smornot_3dplot)

	//Update indicative line
		angleline_3dpf2()

	//Reset the range for addY
		duplicate/o findrangeforangle_LHf(mat3dn_cons,angle_3dplot,zn_cons) rotateYlimit
		SetVariable setaddY win=$grabwin(slicename),limits={rotateYlimit[0],rotateYlimit[1],1}

	//Reset the range for addX
		duplicate/o findrangeforangle_LVf(mat3dn_cons,angle_3dplot,zn_cons) rotateXlimit
		SetVariable setaddX win=$grabwin(slicename),limits={rotateXlimit[0],rotateXlimit[1],1}

		//string linecutH = "LH_"+mat3dn_consf
		//slicesMDC($linecutH)
end


////////////////////////////////////////////////////////////////////////////////////////////////////////////
//** INTERACTING FUNCTIONAL: Update indicative lines

Function angleline_3dpf2()
	string/G mat3dn_cons
	variable/G zn_cons

	string mat3dn_consf= mat3dn_cons//+"_FFT3d"

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


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** {{{{{{{{{{ Control the simulation parameters }}}}}}}}}}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

Function SetVarProc_Cons3dplotprbc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	updatePRB_98_214503_normalFS()
	string/G mat3dn_cons
	variable/G z_cons
	//** Indicative line
	string Zpp = "Zpp_"+mat3dn_cons
	wave zppw = $zpp
	Zppw=z_cons
end

Function SetVarProc_PRB_98_214503_normalu(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	updatePRB_98_214503_normal()
end

Function SetVarProc_PRB_98_214503_normalm(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	updatePRB_98_214503_normal()
end

Function SetVarProc_PRB_98_214503_normala(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	updatePRB_98_214503_normal()
end

Function SetVarProc_PRB_98_214503_normalvsoc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	updatePRB_98_214503_normal()
end

Function SetVarProc_PRB_98_214503_normalselfi(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	updatePRB_98_214503_normal()
end

Function SetVarProc_PRB_98_214503_normalselfr(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	updatePRB_98_214503_normal()
end

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** {{{{{{{{{{ Functional main function }}}}}}}}}}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

Function updatePRB_98_214503_normal()
	variable/G u_normal214503
	variable/G m_normal214503
	variable/G a_normal214503
	variable/G Vsoc_normal214503
	variable/G selfimg_normal214503
	variable/G selfreal_normal214503

	variable u = u_normal214503 //meV
	variable m = m_normal214503//(meV*A^2)^-1
	variable a = a_normal214503 //meV*A^2
	variable Vsoc = Vsoc_normal214503 // < 15 meV*A
	variable selfimg = selfimg_normal214503
	variable selfreal = selfreal_normal214503

	string/G mat3dn_cons
	variable/G zn_cons
	variable/G z_cons

	variable/G addY_3dplot
	variable/G addX_3dplot
	//z_cons = (dimoffset($mat3dn_cons,zn_cons)+dimdelta($mat3dn_cons,zn_cons)*round((dimsize($mat3dn_cons,zn_cons)-1)/2)) //energy to show
	//variable Z_constp=(z_cons-dimoffset($mat3dn_cons,zn_cons))/dimdelta($mat3dn_cons,zn_cons)

	string zslice="Zslice_"+mat3dn_cons
	wave zslicew=$zslice
	zslicew = (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-(-u+(x^2+y^2)/(2*m)+sqrt((a*x*y)^2+(Vsoc*x)^2+(Vsoc*y)^2)))^2)+(-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-(-u+(x^2+y^2)/(2*m)-sqrt((a*x*y)^2+(Vsoc*x)^2+(Vsoc*y)^2)))^2)

	string lh="linetest_"+mat3dn_cons
	string lv="linetestv_"+mat3dn_cons
	wave lhw=$lh
	wave lvw=$lv
	variable x1h,x2h,y1h,y2h
	variable x1v,x2v,y1v,y2v
	x1h = dimoffset(lhw,0)
	x2h = dimoffset(lhw,0)+dimdelta(lhw,0)*(dimsize(lhw,0)-1)
	y1h = lhw[0]
	y2h = lhw[1]

	variable kh
	variable bh

	x1v = dimoffset(lvw,0)
	x2v = dimoffset(lvw,0)+dimdelta(lvw,0)*(dimsize(lvw,0)-1)
	y1v = lvw[0]
	y2v = lvw[1]

	variable kv
	variable bv

	string lhline,lvline
	lhline="LH_"+mat3dn_cons
	lvline="LV_"+mat3dn_cons
	wave lhlinew=$lhline
	wave lvlinew=$lvline

	if (abs(y1h-y2h) <= abs(x1h-x2h))
		kh = (y1h-y2h)/(x1h-x2h)
		bh = y1h-kh*x1h
		lhlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+(x^2+(kh*x+bh)^2)/(2*m)+sqrt((a*x*(kh*x+bh))^2+(Vsoc*x)^2+(Vsoc*(kh*x+bh))^2)))^2)+(-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+(x^2+(kh*x+bh)^2)/(2*m)-sqrt((a*x*(kh*x+bh))^2+(Vsoc*x)^2+(Vsoc*(kh*x+bh))^2)))^2)
	else
		kh = (x1h-x2h)/(y1h-y2h)
		bh = x1h-kh*y1h
		lhlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+((kh*x+bh)^2+x^2)/(2*m)+sqrt((a*(kh*x+bh)*x)^2+(Vsoc*(kh*x+bh))^2+(Vsoc*x)^2)))^2)+(-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+((kh*x+bh)^2+x^2)/(2*m)-sqrt((a*(kh*x+bh)*x)^2+(Vsoc*(kh*x+bh))^2+(Vsoc*x)^2)))^2)
	endif

	if (abs(y1v-y2v) <= abs(x1v-x2v))
		kv = (y1v-y2v)/(x1v-x2v)
		bv = y1v-kv*x1v
		lvlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+(x^2+(kv*x+bv)^2)/(2*m)+sqrt((a*x*(kv*x+bv))^2+(Vsoc*x)^2+(Vsoc*(kv*x+bv))^2)))^2)+(-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+(x^2+(kv*x+bv)^2)/(2*m)-sqrt((a*x*(kv*x+bv))^2+(Vsoc*x)^2+(Vsoc*(kv*x+bv))^2)))^2)
	else
		kv = (x1v-x2v)/(y1v-y2v)
		bv = x1v-kv*y1v
		lvlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+((kv*x+bv)^2+x^2)/(2*m)+sqrt((a*(kv*x+bv)*x)^2+(Vsoc*(kh*x+bh))^2+(Vsoc*x)^2)))^2)+(-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+((kv*x+bv)^2+x^2)/(2*m)-sqrt((a*(kv*x+bv)*x)^2+(Vsoc*(kv*x+bv))^2+(Vsoc*x)^2)))^2)

	endif
	variable lensh = sqrt((x1h-x2h)^2+(y1h-y2h)^2)
	variable lensv = sqrt((x1v-x2v)^2+(y1v-y2v)^2)
	setscale/i x,-lensh/2,lensh/2,"",lhlinew
	setscale/i x,-lensv/2,lensv/2,"",lvlinew

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

Function updatePRB_98_214503_normalFS()
	variable/G u_normal214503
	variable/G m_normal214503
	variable/G a_normal214503
	variable/G Vsoc_normal214503
	variable/G selfimg_normal214503
	variable/G selfreal_normal214503

	variable u = u_normal214503 //meV
	variable m = m_normal214503//(meV*A^2)^-1
	variable a = a_normal214503 //meV*A^2
	variable Vsoc = Vsoc_normal214503 // < 15 meV*A
	variable selfimg = selfimg_normal214503
	variable selfreal = selfreal_normal214503

	string/G mat3dn_cons
	variable/G zn_cons
	variable/G z_cons

	variable/G addY_3dplot
	variable/G addX_3dplot
	//z_cons = (dimoffset($mat3dn_cons,zn_cons)+dimdelta($mat3dn_cons,zn_cons)*round((dimsize($mat3dn_cons,zn_cons)-1)/2)) //energy to show
	//variable Z_constp=(z_cons-dimoffset($mat3dn_cons,zn_cons))/dimdelta($mat3dn_cons,zn_cons)

	string zslice="Zslice_"+mat3dn_cons
	wave zslicew=$zslice
	zslicew = (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-(-u+(x^2+y^2)/(2*m)+sqrt((a*x*y)^2+(Vsoc*x)^2+(Vsoc*y)^2)))^2)+(-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-(-u+(x^2+y^2)/(2*m)-sqrt((a*x*y)^2+(Vsoc*x)^2+(Vsoc*y)^2)))^2)

end

Function SetVarProc_rotate3dplotf22(ctrlName,varNum,varStr,varName) : SetVariableControl
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

	string mat3dn_consf= mat3dn_cons//+"_FFT3d"



	variable/G u_normal214503
	variable/G m_normal214503
	variable/G a_normal214503
	variable/G Vsoc_normal214503
	variable/G selfimg_normal214503
	variable/G selfreal_normal214503

	variable u = u_normal214503 //meV
	variable m = m_normal214503//(meV*A^2)^-1
	variable a = a_normal214503 //meV*A^2
	variable Vsoc = Vsoc_normal214503 // < 15 meV*A
	variable selfimg = selfimg_normal214503
	variable selfreal = selfreal_normal214503


	variable/G z_cons

	angleline_3dpf2()

	string lh="linetest_"+mat3dn_cons
	string lv="linetestv_"+mat3dn_cons
	wave lhw=$lh
	wave lvw=$lv
	variable x1h,x2h,y1h,y2h
	variable x1v,x2v,y1v,y2v
	x1h = dimoffset(lhw,0)
	x2h = dimoffset(lhw,0)+dimdelta(lhw,0)*(dimsize(lhw,0)-1)
	y1h = lhw[0]
	y2h = lhw[1]

	variable kh
	variable bh

	x1v = dimoffset(lvw,0)
	x2v = dimoffset(lvw,0)+dimdelta(lvw,0)*(dimsize(lvw,0)-1)
	y1v = lvw[0]
	y2v = lvw[1]

	variable kv
	variable bv

	string lhline,lvline
	lhline="LH_"+mat3dn_cons
	lvline="LV_"+mat3dn_cons
	wave lhlinew=$lhline
	wave lvlinew=$lvline

	if (abs(y1h-y2h) <= abs(x1h-x2h))
		kh = (y1h-y2h)/(x1h-x2h)
		bh = y1h-kh*x1h
		lhlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+(x^2+(kh*x+bh)^2)/(2*m)+sqrt((a*x*(kh*x+bh))^2+(Vsoc*x)^2+(Vsoc*(kh*x+bh))^2)))^2)+(-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+(x^2+(kh*x+bh)^2)/(2*m)-sqrt((a*x*(kh*x+bh))^2+(Vsoc*x)^2+(Vsoc*(kh*x+bh))^2)))^2)
	else
		kh = (x1h-x2h)/(y1h-y2h)
		bh = x1h-kh*y1h
		lhlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+((kh*x+bh)^2+x^2)/(2*m)+sqrt((a*(kh*x+bh)*x)^2+(Vsoc*(kh*x+bh))^2+(Vsoc*x)^2)))^2)+(-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+((kh*x+bh)^2+x^2)/(2*m)-sqrt((a*(kh*x+bh)*x)^2+(Vsoc*(kh*x+bh))^2+(Vsoc*x)^2)))^2)


	endif

	if (abs(y1v-y2v) <= abs(x1v-x2v))
		kv = (y1v-y2v)/(x1v-x2v)
		bv = y1v-kv*x1v
		lvlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+(x^2+(kv*x+bv)^2)/(2*m)+sqrt((a*x*(kv*x+bv))^2+(Vsoc*x)^2+(Vsoc*(kv*x+bv))^2)))^2)+(-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+(x^2+(kv*x+bv)^2)/(2*m)-sqrt((a*x*(kv*x+bv))^2+(Vsoc*x)^2+(Vsoc*(kv*x+bv))^2)))^2)
	else
		kv = (x1v-x2v)/(y1v-y2v)
		bv = x1v-kv*y1v
		lvlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+((kv*x+bv)^2+x^2)/(2*m)+sqrt((a*(kv*x+bv)*x)^2+(Vsoc*(kh*x+bh))^2+(Vsoc*x)^2)))^2)+(-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+((kv*x+bv)^2+x^2)/(2*m)-sqrt((a*(kv*x+bv)*x)^2+(Vsoc*(kv*x+bv))^2+(Vsoc*x)^2)))^2)

	endif
	variable lensh = sqrt((x1h-x2h)^2+(y1h-y2h)^2)
	variable lensv = sqrt((x1v-x2v)^2+(y1v-y2v)^2)
	setscale/i x,-lensh/2,lensh/2,"",lhlinew
	setscale/i x,-lensv/2,lensv/2,"",lvlinew


	//anglelinecutVf(mat3dn_cons,angle_3dplot,zn_cons,addX_3dplot,normornot_3dplot,smornot_3dplot)
	//string linecutH = "LH_"+mat3dn_consf
	//slicesMDC($linecutH)
end
//This is the simulation of normal bands in PRB 98,214503 (2018) This is the eignevalue of equation (2)
Function PRB_98_214503_SC()
	variable u = 55 //meV
	variable m = 1/(2*1375) //(meV*A^2)^-1
	variable a = 600 //meV*A^2
	variable Vsoc = 1 // < 15 meV*A
	variable selfimg = 3
	variable selfreal = 0
	variable d2 = -1.5
	variable d0 = 20
	variable k0 = 0.2
	//sqrt( ((-u+(x^2+y^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*y)^2 + (a*x*y)^2 + (d2*x*y/k0^2)^2 + d0^2 ))
	//+2*sqrt((((-u+(x^2+y^2)/(2*m))*(a*x*y)+(d2*x*y/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*y)^2)*(((-u+(x^2+y^2)/(2*m))^2+d0^2))))
	//-2*sqrt((((-u+(x^2+y^2)/(2*m))*(a*x*y)+(d2*x*y/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*y)^2)*(((-u+(x^2+y^2)/(2*m))^2+d0^2))))

	//E1 = sqrt(((-u+(x^2+y^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*y)^2 + (a*x*y)^2 + (d2*x*y/k0^2)^2 + d0^2 +2*sqrt((((-u+(x^2+y^2)/(2*m))*(a*x*y)+(d2*x*y/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*y)^2)*(((-u+(x^2+y^2)/(2*m))^2+d0^2))))))
	//E2 = sqrt(((-u+(x^2+y^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*y)^2 + (a*x*y)^2 + (d2*x*y/k0^2)^2 + d0^2 -2*sqrt((((-u+(x^2+y^2)/(2*m))*(a*x*y)+(d2*x*y/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*y)^2)*(((-u+(x^2+y^2)/(2*m))^2+d0^2))))))
	//A = 	(-1/pi)*selfimg/(selfimg^2+(z-selfreal-)^2)
	//A1= (-1/pi)*selfimg/(selfimg^2+(z-selfreal-sqrt(((-u+(x^2+y^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*y)^2 + (a*x*y)^2 + (d2*x*y/k0^2)^2 + d0^2 +2*sqrt((((-u+(x^2+y^2)/(2*m))*(a*x*y)+(d2*x*y/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*y)^2)*(((-u+(x^2+y^2)/(2*m))^2+d0^2))))))))
	//A2= (-1/pi)*selfimg/(selfimg^2+(z-selfreal-sqrt(((-u+(x^2+y^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*y)^2 + (a*x*y)^2 + (d2*x*y/k0^2)^2 + d0^2 -2*sqrt((((-u+(x^2+y^2)/(2*m))*(a*x*y)+(d2*x*y/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*y)^2)*(((-u+(x^2+y^2)/(2*m))^2+d0^2))))))))
	string/G mat3dn_cons
	variable/G zn_cons
	variable/G z_cons

	make/n=(200,200,200)/o  S2_002
	setscale/i x,-0.4,0.4,"",S2_002
	setscale/i y,-0.4,0.4,"",S2_002
	setscale/i z,-70,70,"",S2_002

	S2_002 = (-1/pi)*selfimg/(selfimg^2+(z-selfreal-sqrt(((-u+(x^2+y^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*y)^2 + (a*x*y)^2 + (d2*x*y/k0^2)^2 + d0^2 +2*sqrt((((-u+(x^2+y^2)/(2*m))*(a*x*y)+(d2*x*y/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*y)^2)*(((-u+(x^2+y^2)/(2*m))^2+d0^2)))))))^2) +  (-1/pi)*selfimg/(selfimg^2+(z-selfreal-sqrt(((-u+(x^2+y^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*y)^2 + (a*x*y)^2 + (d2*x*y/k0^2)^2 + d0^2 -2*sqrt((((-u+(x^2+y^2)/(2*m))*(a*x*y)+(d2*x*y/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*y)^2)*(((-u+(x^2+y^2)/(2*m))^2+d0^2)))))))^2) + (-1/pi)*selfimg/(selfimg^2+(z-selfreal+sqrt(((-u+(x^2+y^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*y)^2 + (a*x*y)^2 + (d2*x*y/k0^2)^2 + d0^2 +2*sqrt((((-u+(x^2+y^2)/(2*m))*(a*x*y)+(d2*x*y/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*y)^2)*(((-u+(x^2+y^2)/(2*m))^2+d0^2)))))))^2) + (-1/pi)*selfimg/(selfimg^2+(z-selfreal+sqrt(((-u+(x^2+y^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*y)^2 + (a*x*y)^2 + (d2*x*y/k0^2)^2 + d0^2 -2*sqrt((((-u+(x^2+y^2)/(2*m))*(a*x*y)+(d2*x*y/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*y)^2)*(((-u+(x^2+y^2)/(2*m))^2+d0^2)))))))^2)
	execute "d3d(\"S2_002\",2)"

	//////Modify the 3D player for this special simulation use (band structure)
	variable/G divcolor_cons
	divcolor_cons = 1
		wavestats/Q $tpw()
		variable rangls = max(abs(V_max),abs(V_min))
		ModifyImage/W=$grabwinchild(tpw()) $tpw() ctab= {-rangls,rangls,:Packages:NewColortable:dvg_seismic,0};
		ColorScale/W=$grabwinchild(tpw())/C/N=textcc/X=-21.00/Y=5.00/F=0 heightPct=30,nticks=5,minor=1,tickLen=1.00,image=$tpw()//;ColorScale/W=$grabwinchild(Fexyd)/C/N=text0/F=0/A=MC/Y=-120 image=$Fexyd
		variable/G normornot_3dplot =2

	variable/G u_SC214503 = u
	variable/G m_SC214503 = m
	variable/G a_SC214503 = a
	variable/G Vsoc_SC214503 = Vsoc
	variable/G selfimg_SC214503 = selfimg
	variable/G selfreal_SC214503 = selfreal

	variable/G d2_SC214503 = d2
	variable/G d0_SC214503 = d0
	variable/G k0_SC214503 = k0



	display/N=PRB_98_214503_normalPSC
	tilewindows/WINS=winname(0,1)/R/w=(30,43,50,56)/A=(1,1)
	SetVariable setvarz_u_SC win=PRB_98_214503_normalPSC,title="µ",size={65,14},value=u_SC214503,limits={-inf,inf,1},proc=SetVarProc_PRB_98_214503_SCu
	SetVariable setvarz_m_SC win=PRB_98_214503_normalPSC,title="m",size={65,14},value=m_SC214503,limits={-inf,inf,0.5*m},proc=SetVarProc_PRB_98_214503_SCm
	SetVariable setvarz_a_SC win=PRB_98_214503_normalPSC,title="a",size={65,14},value=a_SC214503,limits={-inf,inf,0.5*a},proc=SetVarProc_PRB_98_214503_SCa
	SetVariable setvarz_Vsoc_SC win=PRB_98_214503_normalPSC,title="V\Bsoc\M",size={65,14},value=Vsoc_SC214503,limits={-inf,inf,10},proc=SetVarProc_PRB_98_214503_SCvsoc
	SetVariable setvarz_selfimg_SC win=PRB_98_214503_normalPSC,title="∑\S''",size={65,14},value=selfimg_SC214503,limits={-inf,inf,1},proc=SetVarProc_PRB_98_214503_SCselfi
	SetVariable setvarz_selfreal_SC win=PRB_98_214503_normalPSC,title="∑\S'",size={65,14},value=selfreal_SC214503,limits={-inf,inf,1},proc=SetVarProc_PRB_98_214503_SCselfr
	SetVariable setvarz_d2_SC win=PRB_98_214503_normalPSC,title="∆\B2",size={65,14},value=d2_SC214503,limits={-inf,inf,0.5},proc=SetVarProc_PRB_98_214503_SCd2
	SetVariable setvarz_d0_SC win=PRB_98_214503_normalPSC,title="∆\B0",size={65,14},value=d0_SC214503,limits={-inf,inf,0.5},proc=SetVarProc_PRB_98_214503_SCd0
	SetVariable setvarz_k0_SC win=PRB_98_214503_normalPSC,title="k\B0'",size={65,14},value=k0_SC214503,limits={-inf,inf,k0},proc=SetVarProc_PRB_98_214503_SCk0



	SetVariable setvarz_cons2SC win=PRB_98_214503_normalPSC,title="Z",size={65,14},value=z_cons,proc=SetVarProc_Cons3dplotprbcSC
	SetVariable setvarz_cons2SC win=PRB_98_214503_normalPSC,limits={dimoffset($mat3dn_cons,zn_cons),(dimoffset($mat3dn_cons,zn_cons)+dimdelta($mat3dn_cons,zn_cons)*(dimsize($mat3dn_cons,zn_cons)-1)),dimdelta($mat3dn_cons,zn_cons)}

	Button launchLinecutSC win=PRB_98_214503_normalPSC,title="Linecut",size={65,14},fSize=10,proc=ButtonProc_Cons3dplotlcf2SC
end



////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** {{{{{{{{{{ Launch arbitary Linecut extraction (Z is horizental) }}}}}}}}}}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Cons3dplotlcf2SC(ctrlName) : ButtonControl
	String ctrlName
	string/G mat3dn_cons

	string mat3dn_consf = mat3dn_cons//+"_FFT3d"


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
		SetVariable setvarangle win=$grabwin(slicename),title="Rotate",size={65,14},value=angle_3dplot,proc=SetVarProc_rotate3dplotf2,pos={159,1}
		SetVariable setvarangle win=$grabwin(slicename),limits={-89,89,1}

		SetVariable setvarangle2 win=PRB_98_214503_normalPSC,title="Rotate",size={65,14},value=angle_3dplot,proc=SetVarProc_rotate3dplotf22SC
		SetVariable setvarangle2 win=PRB_98_214503_normalPSC,limits={-89,89,1}


	//**SetVar of AddY [set the Yrange(angel) by auto search]
		SetVariable setaddY win=$grabwin(slicename),title="LH",size={65,14},value=addY_3dplot,proc=SetVarProc_addY3dplotf2,pos={225,1}
		duplicate/o findrangeforangle_LHf(mat3dn_consf,angle_3dplot,zn_cons) rotateYlimit
		SetVariable setaddY win=$grabwin(slicename),limits={rotateYlimit[0],rotateYlimit[1],1}


		SetVariable setaddY2 win=PRB_98_214503_normalPSC,title="LH",size={65,14},value=addY_3dplot,proc=SetVarProc_rotate3dplotf22SC//SetVarProc_addY3dplotf22
		SetVariable setaddY2 win=PRB_98_214503_normalPSC,limits={rotateYlimit[0],rotateYlimit[1],1}

	//**SetVar of AddX [set the Xrange(angel) by auto search]
		SetVariable setaddX win=$grabwin(slicename),title="LV",size={65,14},value=addX_3dplot,proc=SetVarProc_addX3dplotf2,pos={292,1}
		duplicate/o findrangeforangle_LVf(mat3dn_consf,angle_3dplot,zn_cons) rotateXlimit
		SetVariable setaddX win=$grabwin(slicename),limits={rotateXlimit[0],rotateXlimit[1],1}

		SetVariable setaddX2 win=PRB_98_214503_normalPSC,title="LV",size={65,14},value=addX_3dplot,proc=SetVarProc_rotate3dplotf22SC//SetVarProc_addX3dplotf22
		SetVariable setaddX2 win=PRB_98_214503_normalPSC,limits={rotateXlimit[0],rotateXlimit[1],1}

	//**Extract LinecutH and make graph
		anglelinecutHf(mat3dn_consf,angle_3dplot,zn_cons,addY_3dplot,normornot_3dplot,smornot_3dplot)
		string linecutH = "LH_"+mat3dn_consf
		di($linecutH)
		variable/G FFTmode_3dplot
		if (FFTmode_3dplot == 5)
			ModifyImage $linecutH ctab= {*,*,VioletOrangeYellow,0}
		else
			//color3s_for3d($linecutH,30)
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
			ModifyImage $linecutV ctab= {*,*,VioletOrangeYellow,0}
		else
			//color3s_for3d($linecutV,30)
		endif
		Modifygraph/W=$grabwinnonew(linecutV) width=400, height=200
		Label left "\\Z16\\F'times'\\f02E - E\\BF\\f00\\M\\F'times'\\Z16 (meV)"
		Label bottom "\\Z16\\f02k\\f00 (2π Å\\S\\Z10-1\\M\\Z16)"

		ModifyGraph/W=$grabwinnonew(linecutV) axThick=3,axRGB=(16385,65535,41303),tlblRGB=(16385,65535,41303),alblRGB=(16385,65535,41303)
		tilewindows/WINS=grabwinnonew(linecutV)/R/w=(56,0,100,30)/A=(1,1)



	//** Control of Advanced Modes
		//popupmenu popselectmode3d win=$grabwin(slicename), pos={1,36},bodyWidth=65,proc=PopMenuProc_selmode3dplotf,value="2Point;FreeHand;Circular",bodyWidth=68
		//Button Bfreehandprofile3d win=$grabwin(slicename), title="Go",proc=ButtonProc_L3dplotdof,size={30,15},fSize=11,pos={35,56}


	//** Tile window
		//tilewindows/WINS=WinList("*", ";","WIN:1")/R/w=(3,0,92,100)/A=(2,4)


end

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** {{{{{{{{{{ Control the simulation parameters }}}}}}}}}}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function SetVarProc_Cons3dplotprbcSC(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	updatePRB_98_214503_SCFS()
	string/G mat3dn_cons
	variable/G z_cons
	//** Indicative line
	string Zpp = "Zpp_"+mat3dn_cons
	wave zppw = $zpp
	Zppw=z_cons
end


Function SetVarProc_PRB_98_214503_SCu(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	updatePRB_98_214503_SC()
end

Function SetVarProc_PRB_98_214503_SCm(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	updatePRB_98_214503_SC()
end

Function SetVarProc_PRB_98_214503_SCa(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	updatePRB_98_214503_SC()
end

Function SetVarProc_PRB_98_214503_SCvsoc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	updatePRB_98_214503_SC()
end

Function SetVarProc_PRB_98_214503_SCselfi(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	updatePRB_98_214503_SC()
end

Function SetVarProc_PRB_98_214503_SCselfr(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	updatePRB_98_214503_SC()
end

Function SetVarProc_PRB_98_214503_SCd2(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	updatePRB_98_214503_SC()
end


Function SetVarProc_PRB_98_214503_SCd0(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	updatePRB_98_214503_SC()
end

Function SetVarProc_PRB_98_214503_SCk0(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	updatePRB_98_214503_SC()
end


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** {{{{{{{{{{ Functional main function }}}}}}}}}}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

Function updatePRB_98_214503_SC()
	variable/G u_SC214503 //= u
	variable/G m_SC214503 //= m
	variable/G a_SC214503 //= a
	variable/G Vsoc_SC214503 //= Vsoc
	variable/G selfimg_SC214503 //= selfimg
	variable/G selfreal_SC214503 //= selfreal

	variable/G d2_SC214503 //= d2
	variable/G d0_SC214503 //= d0
	variable/G k0_SC214503 //= k0


	variable u = u_SC214503 //meV
	variable m = m_SC214503//(meV*A^2)^-1
	variable a = a_SC214503 //meV*A^2
	variable Vsoc = Vsoc_SC214503 // < 15 meV*A
	variable selfimg = selfimg_SC214503
	variable selfreal = selfreal_SC214503
	variable d2 = d2_SC214503
	variable d0 = d0_SC214503
	variable k0 = k0_SC214503

	string/G mat3dn_cons
	variable/G zn_cons
	variable/G z_cons

	variable/G addY_3dplot
	variable/G addX_3dplot

	string zslice="Zslice_"+mat3dn_cons
	wave zslicew=$zslice
		//zslicew = (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-(-u+(x^2+y^2)/(2*m)+sqrt((a*x*y)^2+(Vsoc*x)^2+(Vsoc*y)^2)))^2)+(-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-(-u+(x^2+y^2)/(2*m)-sqrt((a*x*y)^2+(Vsoc*x)^2+(Vsoc*y)^2)))^2)
	zslicew = (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-sqrt(((-u+(x^2+y^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*y)^2 + (a*x*y)^2 + (d2*x*y/k0^2)^2 + d0^2 +2*sqrt((((-u+(x^2+y^2)/(2*m))*(a*x*y)+(d2*x*y/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*y)^2)*(((-u+(x^2+y^2)/(2*m))^2+d0^2)))))))^2) +  (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-sqrt(((-u+(x^2+y^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*y)^2 + (a*x*y)^2 + (d2*x*y/k0^2)^2 + d0^2 -2*sqrt((((-u+(x^2+y^2)/(2*m))*(a*x*y)+(d2*x*y/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*y)^2)*(((-u+(x^2+y^2)/(2*m))^2+d0^2)))))))^2) + (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal+sqrt(((-u+(x^2+y^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*y)^2 + (a*x*y)^2 + (d2*x*y/k0^2)^2 + d0^2 +2*sqrt((((-u+(x^2+y^2)/(2*m))*(a*x*y)+(d2*x*y/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*y)^2)*(((-u+(x^2+y^2)/(2*m))^2+d0^2)))))))^2) + (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal+sqrt(((-u+(x^2+y^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*y)^2 + (a*x*y)^2 + (d2*x*y/k0^2)^2 + d0^2 -2*sqrt((((-u+(x^2+y^2)/(2*m))*(a*x*y)+(d2*x*y/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*y)^2)*(((-u+(x^2+y^2)/(2*m))^2+d0^2)))))))^2)

	string lh="linetest_"+mat3dn_cons
	string lv="linetestv_"+mat3dn_cons
	wave lhw=$lh
	wave lvw=$lv
	variable x1h,x2h,y1h,y2h
	variable x1v,x2v,y1v,y2v
	x1h = dimoffset(lhw,0)
	x2h = dimoffset(lhw,0)+dimdelta(lhw,0)*(dimsize(lhw,0)-1)
	y1h = lhw[0]
	y2h = lhw[1]

	variable lensh = sqrt((x1h-x2h)^2+(y1h-y2h)^2)

	variable kh
	variable bh

	x1v = dimoffset(lvw,0)
	x2v = dimoffset(lvw,0)+dimdelta(lvw,0)*(dimsize(lvw,0)-1)
	y1v = lvw[0]
	y2v = lvw[1]

	variable lensv = sqrt((x1v-x2v)^2+(y1v-y2v)^2)

	variable kv
	variable bv

	string lhline,lvline
	lhline="LH_"+mat3dn_cons
	lvline="LV_"+mat3dn_cons
	wave lhlinew=$lhline
	wave lvlinew=$lvline

	if (abs(y1h-y2h) <= abs(x1h-x2h))
		kh = (y1h-y2h)/(x1h-x2h)
		bh = y1h-kh*x1h
			//lhlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+(x^2+(kh*x+bh)^2)/(2*m)+sqrt((a*x*(kh*x+bh))^2+(Vsoc*x)^2+(Vsoc*(kh*x+bh))^2)))^2)+(-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+(x^2+(kh*x+bh)^2)/(2*m)-sqrt((a*x*(kh*x+bh))^2+(Vsoc*x)^2+(Vsoc*(kh*x+bh))^2)))^2)
		lhlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-sqrt(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kh*x+bh))^2 + (a*x*(kh*x+bh))^2 + (d2*x*(kh*x+bh)/k0^2)^2 + d0^2 +2*sqrt((((-u+(x^2+(kh*x+bh)^2)/(2*m))*(a*x*(kh*x+bh))+(d2*x*(kh*x+bh)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kh*x+bh))^2)*(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2+d0^2)))))))^2) +  (-1/pi)*selfimg/(selfimg^2+(y-selfreal-sqrt(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kh*x+bh))^2 + (a*x*(kh*x+bh))^2 + (d2*x*(kh*x+bh)/k0^2)^2 + d0^2 -2*sqrt((((-u+(x^2+(kh*x+bh)^2)/(2*m))*(a*x*(kh*x+bh))+(d2*x*(kh*x+bh)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kh*x+bh))^2)*(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2+d0^2)))))))^2) + (-1/pi)*selfimg/(selfimg^2+(y-selfreal+sqrt(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kh*x+bh))^2 + (a*x*(kh*x+bh))^2 + (d2*x*(kh*x+bh)/k0^2)^2 + d0^2 +2*sqrt((((-u+(x^2+(kh*x+bh)^2)/(2*m))*(a*x*(kh*x+bh))+(d2*x*(kh*x+bh)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kh*x+bh))^2)*(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2+d0^2)))))))^2) + (-1/pi)*selfimg/(selfimg^2+(y-selfreal+sqrt(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kh*x+bh))^2 + (a*x*(kh*x+bh))^2 + (d2*x*(kh*x+bh)/k0^2)^2 + d0^2 -2*sqrt((((-u+(x^2+(kh*x+bh)^2)/(2*m))*(a*x*(kh*x+bh))+(d2*x*(kh*x+bh)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kh*x+bh))^2)*(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2+d0^2)))))))^2)
	else
		kh = (x1h-x2h)/(y1h-y2h)
		bh = x1h-kh*y1h
			//lhlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+((kh*x+bh)^2+x^2)/(2*m)+sqrt((a*(kh*x+bh)*x)^2+(Vsoc*(kh*x+bh))^2+(Vsoc*x)^2)))^2)+(-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+((kh*x+bh)^2+x^2)/(2*m)-sqrt((a*(kh*x+bh)*x)^2+(Vsoc*(kh*x+bh))^2+(Vsoc*x)^2)))^2)
		lhlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-sqrt(((-u+((kh*x+bh)^2+x^2)/(2*m))^2 + (Vsoc*(kh*x+bh))^2 + (Vsoc*x)^2 + (a*(kh*x+bh)*x)^2 + (d2*(kh*x+bh)*x/k0^2)^2 + d0^2 +2*sqrt((((-u+(x^2+(kh*x+bh)^2)/(2*m))*(a*(kh*x+bh)*x)+(d2*x*(kh*x+bh)/k0^2)*d0)^2 + ((Vsoc*(kh*x+bh))^2+(Vsoc*x)^2)*(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2+d0^2)))))))^2) +  (-1/pi)*selfimg/(selfimg^2+(y-selfreal-sqrt(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2 + (Vsoc*(kh*x+bh))^2 + (Vsoc*x)^2 + (a*x*(kh*x+bh))^2 + (d2*x*(kh*x+bh)/k0^2)^2 + d0^2 -2*sqrt((((-u+(x^2+(kh*x+bh)^2)/(2*m))*(a*x*(kh*x+bh))+(d2*x*(kh*x+bh)/k0^2)*d0)^2 + ((Vsoc*(kh*x+bh))^2+(Vsoc*x)^2)*(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2+d0^2)))))))^2) + (-1/pi)*selfimg/(selfimg^2+(y-selfreal+sqrt(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kh*x+bh))^2 + (a*x*(kh*x+bh))^2 + (d2*x*(kh*x+bh)/k0^2)^2 + d0^2 +2*sqrt((((-u+(x^2+(kh*x+bh)^2)/(2*m))*(a*x*(kh*x+bh))+(d2*x*(kh*x+bh)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kh*x+bh))^2)*(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2+d0^2)))))))^2) + (-1/pi)*selfimg/(selfimg^2+(y-selfreal+sqrt(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kh*x+bh))^2 + (a*x*(kh*x+bh))^2 + (d2*x*(kh*x+bh)/k0^2)^2 + d0^2 -2*sqrt((((-u+(x^2+(kh*x+bh)^2)/(2*m))*(a*x*(kh*x+bh))+(d2*x*(kh*x+bh)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kh*x+bh))^2)*(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2+d0^2)))))))^2)
	endif

	if (abs(y1v-y2v) <= abs(x1v-x2v))
		kv = (y1v-y2v)/(x1v-x2v)
		bv = y1v-kv*x1v
		//lvlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+(x^2+(kv*x+bv)^2)/(2*m)+sqrt((a*x*(kv*x+bv))^2+(Vsoc*x)^2+(Vsoc*(kv*x+bv))^2)))^2)+(-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+(x^2+(kv*x+bv)^2)/(2*m)-sqrt((a*x*(kv*x+bv))^2+(Vsoc*x)^2+(Vsoc*(kv*x+bv))^2)))^2)
		lvlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-sqrt(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kv*x+bv))^2 + (a*x*(kv*x+bv))^2 + (d2*x*(kv*x+bv)/k0^2)^2 + d0^2 +2*sqrt((((-u+(x^2+(kv*x+bv)^2)/(2*m))*(a*x*(kv*x+bv))+(d2*x*(kv*x+bv)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kv*x+bv))^2)*(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2+d0^2)))))))^2) +  (-1/pi)*selfimg/(selfimg^2+(y-selfreal-sqrt(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kv*x+bv))^2 + (a*x*(kv*x+bv))^2 + (d2*x*(kv*x+bv)/k0^2)^2 + d0^2 -2*sqrt((((-u+(x^2+(kv*x+bv)^2)/(2*m))*(a*x*(kv*x+bv))+(d2*x*(kv*x+bv)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kv*x+bv))^2)*(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2+d0^2)))))))^2) + (-1/pi)*selfimg/(selfimg^2+(y-selfreal+sqrt(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kv*x+bv))^2 + (a*x*(kv*x+bv))^2 + (d2*x*(kv*x+bv)/k0^2)^2 + d0^2 +2*sqrt((((-u+(x^2+(kv*x+bv)^2)/(2*m))*(a*x*(kv*x+bv))+(d2*x*(kv*x+bv)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kv*x+bv))^2)*(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2+d0^2)))))))^2) + (-1/pi)*selfimg/(selfimg^2+(y-selfreal+sqrt(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kv*x+bv))^2 + (a*x*(kv*x+bv))^2 + (d2*x*(kv*x+bv)/k0^2)^2 + d0^2 -2*sqrt((((-u+(x^2+(kv*x+bv)^2)/(2*m))*(a*x*(kv*x+bv))+(d2*x*(kv*x+bv)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kv*x+bv))^2)*(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2+d0^2)))))))^2)

	else
		kv = (x1v-x2v)/(y1v-y2v)
		bv = x1v-kv*y1v
		//lvlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+((kv*x+bv)^2+x^2)/(2*m)+sqrt((a*(kv*x+bv)*x)^2+(Vsoc*(kh*x+bh))^2+(Vsoc*x)^2)))^2)+(-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+((kv*x+bv)^2+x^2)/(2*m)-sqrt((a*(kv*x+bv)*x)^2+(Vsoc*(kv*x+bv))^2+(Vsoc*x)^2)))^2)
		lvlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-sqrt(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kv*x+bv))^2 + (a*x*(kv*x+bv))^2 + (d2*x*(kv*x+bv)/k0^2)^2 + d0^2 +2*sqrt((((-u+(x^2+(kv*x+bv)^2)/(2*m))*(a*x*(kv*x+bv))+(d2*x*(kv*x+bv)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kv*x+bv))^2)*(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2+d0^2)))))))^2) +  (-1/pi)*selfimg/(selfimg^2+(y-selfreal-sqrt(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kv*x+bv))^2 + (a*x*(kv*x+bv))^2 + (d2*x*(kv*x+bv)/k0^2)^2 + d0^2 -2*sqrt((((-u+(x^2+(kv*x+bv)^2)/(2*m))*(a*x*(kv*x+bv))+(d2*x*(kv*x+bv)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kv*x+bv))^2)*(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2+d0^2)))))))^2) + (-1/pi)*selfimg/(selfimg^2+(y-selfreal+sqrt(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kv*x+bv))^2 + (a*x*(kv*x+bv))^2 + (d2*x*(kv*x+bv)/k0^2)^2 + d0^2 +2*sqrt((((-u+(x^2+(kv*x+bv)^2)/(2*m))*(a*x*(kv*x+bv))+(d2*x*(kv*x+bv)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kv*x+bv))^2)*(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2+d0^2)))))))^2) + (-1/pi)*selfimg/(selfimg^2+(y-selfreal+sqrt(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kv*x+bv))^2 + (a*x*(kv*x+bv))^2 + (d2*x*(kv*x+bv)/k0^2)^2 + d0^2 -2*sqrt((((-u+(x^2+(kv*x+bv)^2)/(2*m))*(a*x*(kv*x+bv))+(d2*x*(kv*x+bv)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kv*x+bv))^2)*(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2+d0^2)))))))^2)
	endif
	setscale/i x,-lensh/2,lensh/2,"",lhlinew
	setscale/i x,-lensv/2,lensv/2,"",lvlinew

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

Function updatePRB_98_214503_SCFS()
	variable/G u_SC214503 //= u
	variable/G m_SC214503 //= m
	variable/G a_SC214503 //= a
	variable/G Vsoc_SC214503 //= Vsoc
	variable/G selfimg_SC214503 //= selfimg
	variable/G selfreal_SC214503 //= selfreal

	variable/G d2_SC214503 //= d2
	variable/G d0_SC214503 //= d0
	variable/G k0_SC214503 //= k0


	variable u = u_SC214503 //meV
	variable m = m_SC214503//(meV*A^2)^-1
	variable a = a_SC214503 //meV*A^2
	variable Vsoc = Vsoc_SC214503 // < 15 meV*A
	variable selfimg = selfimg_SC214503
	variable selfreal = selfreal_SC214503
	variable d2 = d2_SC214503
	variable d0 = d0_SC214503
	variable k0 = k0_SC214503

	string/G mat3dn_cons
	variable/G zn_cons
	variable/G z_cons

	variable/G addY_3dplot
	variable/G addX_3dplot

	string zslice="Zslice_"+mat3dn_cons
	wave zslicew=$zslice
		//zslicew = (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-(-u+(x^2+y^2)/(2*m)+sqrt((a*x*y)^2+(Vsoc*x)^2+(Vsoc*y)^2)))^2)+(-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-(-u+(x^2+y^2)/(2*m)-sqrt((a*x*y)^2+(Vsoc*x)^2+(Vsoc*y)^2)))^2)
	zslicew = (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-sqrt(((-u+(x^2+y^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*y)^2 + (a*x*y)^2 + (d2*x*y/k0^2)^2 + d0^2 +2*sqrt((((-u+(x^2+y^2)/(2*m))*(a*x*y)+(d2*x*y/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*y)^2)*(((-u+(x^2+y^2)/(2*m))^2+d0^2)))))))^2) +  (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-sqrt(((-u+(x^2+y^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*y)^2 + (a*x*y)^2 + (d2*x*y/k0^2)^2 + d0^2 -2*sqrt((((-u+(x^2+y^2)/(2*m))*(a*x*y)+(d2*x*y/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*y)^2)*(((-u+(x^2+y^2)/(2*m))^2+d0^2)))))))^2) + (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal+sqrt(((-u+(x^2+y^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*y)^2 + (a*x*y)^2 + (d2*x*y/k0^2)^2 + d0^2 +2*sqrt((((-u+(x^2+y^2)/(2*m))*(a*x*y)+(d2*x*y/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*y)^2)*(((-u+(x^2+y^2)/(2*m))^2+d0^2)))))))^2) + (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal+sqrt(((-u+(x^2+y^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*y)^2 + (a*x*y)^2 + (d2*x*y/k0^2)^2 + d0^2 -2*sqrt((((-u+(x^2+y^2)/(2*m))*(a*x*y)+(d2*x*y/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*y)^2)*(((-u+(x^2+y^2)/(2*m))^2+d0^2)))))))^2)

end

Function SetVarProc_rotate3dplotf22SC(ctrlName,varNum,varStr,varName) : SetVariableControl
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

	string mat3dn_consf= mat3dn_cons//+"_FFT3d"



	variable/G u_SC214503 //= u
	variable/G m_SC214503 //= m
	variable/G a_SC214503 //= a
	variable/G Vsoc_SC214503 //= Vsoc
	variable/G selfimg_SC214503 //= selfimg
	variable/G selfreal_SC214503 //= selfreal

	variable/G d2_SC214503 //= d2
	variable/G d0_SC214503 //= d0
	variable/G k0_SC214503 //= k0


	variable u = u_SC214503 //meV
	variable m = m_SC214503//(meV*A^2)^-1
	variable a = a_SC214503 //meV*A^2
	variable Vsoc = Vsoc_SC214503 // < 15 meV*A
	variable selfimg = selfimg_SC214503
	variable selfreal = selfreal_SC214503
	variable d2 = d2_SC214503
	variable d0 = d0_SC214503
	variable k0 = k0_SC214503


	variable/G z_cons

	angleline_3dpf2()

	string lh="linetest_"+mat3dn_cons
	string lv="linetestv_"+mat3dn_cons
	wave lhw=$lh
	wave lvw=$lv
	variable x1h,x2h,y1h,y2h
	variable x1v,x2v,y1v,y2v
	x1h = dimoffset(lhw,0)
	x2h = dimoffset(lhw,0)+dimdelta(lhw,0)*(dimsize(lhw,0)-1)
	y1h = lhw[0]
	y2h = lhw[1]

	variable kh
	variable bh

	x1v = dimoffset(lvw,0)
	x2v = dimoffset(lvw,0)+dimdelta(lvw,0)*(dimsize(lvw,0)-1)
	y1v = lvw[0]
	y2v = lvw[1]

	variable kv
	variable bv

	string lhline,lvline
	lhline="LH_"+mat3dn_cons
	lvline="LV_"+mat3dn_cons
	wave lhlinew=$lhline
	wave lvlinew=$lvline

	if (abs(y1h-y2h) <= abs(x1h-x2h))
		kh = (y1h-y2h)/(x1h-x2h)
		bh = y1h-kh*x1h
			//lhlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+(x^2+(kh*x+bh)^2)/(2*m)+sqrt((a*x*(kh*x+bh))^2+(Vsoc*x)^2+(Vsoc*(kh*x+bh))^2)))^2)+(-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+(x^2+(kh*x+bh)^2)/(2*m)-sqrt((a*x*(kh*x+bh))^2+(Vsoc*x)^2+(Vsoc*(kh*x+bh))^2)))^2)
		lhlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-sqrt(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kh*x+bh))^2 + (a*x*(kh*x+bh))^2 + (d2*x*(kh*x+bh)/k0^2)^2 + d0^2 +2*sqrt((((-u+(x^2+(kh*x+bh)^2)/(2*m))*(a*x*(kh*x+bh))+(d2*x*(kh*x+bh)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kh*x+bh))^2)*(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2+d0^2)))))))^2) +  (-1/pi)*selfimg/(selfimg^2+(y-selfreal-sqrt(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kh*x+bh))^2 + (a*x*(kh*x+bh))^2 + (d2*x*(kh*x+bh)/k0^2)^2 + d0^2 -2*sqrt((((-u+(x^2+(kh*x+bh)^2)/(2*m))*(a*x*(kh*x+bh))+(d2*x*(kh*x+bh)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kh*x+bh))^2)*(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2+d0^2)))))))^2) + (-1/pi)*selfimg/(selfimg^2+(y-selfreal+sqrt(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kh*x+bh))^2 + (a*x*(kh*x+bh))^2 + (d2*x*(kh*x+bh)/k0^2)^2 + d0^2 +2*sqrt((((-u+(x^2+(kh*x+bh)^2)/(2*m))*(a*x*(kh*x+bh))+(d2*x*(kh*x+bh)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kh*x+bh))^2)*(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2+d0^2)))))))^2) + (-1/pi)*selfimg/(selfimg^2+(y-selfreal+sqrt(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kh*x+bh))^2 + (a*x*(kh*x+bh))^2 + (d2*x*(kh*x+bh)/k0^2)^2 + d0^2 -2*sqrt((((-u+(x^2+(kh*x+bh)^2)/(2*m))*(a*x*(kh*x+bh))+(d2*x*(kh*x+bh)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kh*x+bh))^2)*(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2+d0^2)))))))^2)
	else
		kh = (x1h-x2h)/(y1h-y2h)
		bh = x1h-kh*y1h
			//lhlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+((kh*x+bh)^2+x^2)/(2*m)+sqrt((a*(kh*x+bh)*x)^2+(Vsoc*(kh*x+bh))^2+(Vsoc*x)^2)))^2)+(-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+((kh*x+bh)^2+x^2)/(2*m)-sqrt((a*(kh*x+bh)*x)^2+(Vsoc*(kh*x+bh))^2+(Vsoc*x)^2)))^2)
		lhlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-sqrt(((-u+((kh*x+bh)^2+x^2)/(2*m))^2 + (Vsoc*(kh*x+bh))^2 + (Vsoc*x)^2 + (a*(kh*x+bh)*x)^2 + (d2*(kh*x+bh)*x/k0^2)^2 + d0^2 +2*sqrt((((-u+(x^2+(kh*x+bh)^2)/(2*m))*(a*(kh*x+bh)*x)+(d2*x*(kh*x+bh)/k0^2)*d0)^2 + ((Vsoc*(kh*x+bh))^2+(Vsoc*x)^2)*(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2+d0^2)))))))^2) +  (-1/pi)*selfimg/(selfimg^2+(y-selfreal-sqrt(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2 + (Vsoc*(kh*x+bh))^2 + (Vsoc*x)^2 + (a*x*(kh*x+bh))^2 + (d2*x*(kh*x+bh)/k0^2)^2 + d0^2 -2*sqrt((((-u+(x^2+(kh*x+bh)^2)/(2*m))*(a*x*(kh*x+bh))+(d2*x*(kh*x+bh)/k0^2)*d0)^2 + ((Vsoc*(kh*x+bh))^2+(Vsoc*x)^2)*(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2+d0^2)))))))^2) + (-1/pi)*selfimg/(selfimg^2+(y-selfreal+sqrt(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kh*x+bh))^2 + (a*x*(kh*x+bh))^2 + (d2*x*(kh*x+bh)/k0^2)^2 + d0^2 +2*sqrt((((-u+(x^2+(kh*x+bh)^2)/(2*m))*(a*x*(kh*x+bh))+(d2*x*(kh*x+bh)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kh*x+bh))^2)*(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2+d0^2)))))))^2) + (-1/pi)*selfimg/(selfimg^2+(y-selfreal+sqrt(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kh*x+bh))^2 + (a*x*(kh*x+bh))^2 + (d2*x*(kh*x+bh)/k0^2)^2 + d0^2 -2*sqrt((((-u+(x^2+(kh*x+bh)^2)/(2*m))*(a*x*(kh*x+bh))+(d2*x*(kh*x+bh)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kh*x+bh))^2)*(((-u+(x^2+(kh*x+bh)^2)/(2*m))^2+d0^2)))))))^2)
	endif

	if (abs(y1v-y2v) <= abs(x1v-x2v))
		kv = (y1v-y2v)/(x1v-x2v)
		bv = y1v-kv*x1v
		//lvlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+(x^2+(kv*x+bv)^2)/(2*m)+sqrt((a*x*(kv*x+bv))^2+(Vsoc*x)^2+(Vsoc*(kv*x+bv))^2)))^2)+(-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+(x^2+(kv*x+bv)^2)/(2*m)-sqrt((a*x*(kv*x+bv))^2+(Vsoc*x)^2+(Vsoc*(kv*x+bv))^2)))^2)
		lvlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-sqrt(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kv*x+bv))^2 + (a*x*(kv*x+bv))^2 + (d2*x*(kv*x+bv)/k0^2)^2 + d0^2 +2*sqrt((((-u+(x^2+(kv*x+bv)^2)/(2*m))*(a*x*(kv*x+bv))+(d2*x*(kv*x+bv)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kv*x+bv))^2)*(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2+d0^2)))))))^2) +  (-1/pi)*selfimg/(selfimg^2+(y-selfreal-sqrt(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kv*x+bv))^2 + (a*x*(kv*x+bv))^2 + (d2*x*(kv*x+bv)/k0^2)^2 + d0^2 -2*sqrt((((-u+(x^2+(kv*x+bv)^2)/(2*m))*(a*x*(kv*x+bv))+(d2*x*(kv*x+bv)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kv*x+bv))^2)*(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2+d0^2)))))))^2) + (-1/pi)*selfimg/(selfimg^2+(y-selfreal+sqrt(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kv*x+bv))^2 + (a*x*(kv*x+bv))^2 + (d2*x*(kv*x+bv)/k0^2)^2 + d0^2 +2*sqrt((((-u+(x^2+(kv*x+bv)^2)/(2*m))*(a*x*(kv*x+bv))+(d2*x*(kv*x+bv)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kv*x+bv))^2)*(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2+d0^2)))))))^2) + (-1/pi)*selfimg/(selfimg^2+(y-selfreal+sqrt(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kv*x+bv))^2 + (a*x*(kv*x+bv))^2 + (d2*x*(kv*x+bv)/k0^2)^2 + d0^2 -2*sqrt((((-u+(x^2+(kv*x+bv)^2)/(2*m))*(a*x*(kv*x+bv))+(d2*x*(kv*x+bv)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kv*x+bv))^2)*(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2+d0^2)))))))^2)

	else
		kv = (x1v-x2v)/(y1v-y2v)
		bv = x1v-kv*y1v
		//lvlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+((kv*x+bv)^2+x^2)/(2*m)+sqrt((a*(kv*x+bv)*x)^2+(Vsoc*(kh*x+bh))^2+(Vsoc*x)^2)))^2)+(-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+((kv*x+bv)^2+x^2)/(2*m)-sqrt((a*(kv*x+bv)*x)^2+(Vsoc*(kv*x+bv))^2+(Vsoc*x)^2)))^2)
		lvlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-sqrt(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kv*x+bv))^2 + (a*x*(kv*x+bv))^2 + (d2*x*(kv*x+bv)/k0^2)^2 + d0^2 +2*sqrt((((-u+(x^2+(kv*x+bv)^2)/(2*m))*(a*x*(kv*x+bv))+(d2*x*(kv*x+bv)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kv*x+bv))^2)*(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2+d0^2)))))))^2) +  (-1/pi)*selfimg/(selfimg^2+(y-selfreal-sqrt(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kv*x+bv))^2 + (a*x*(kv*x+bv))^2 + (d2*x*(kv*x+bv)/k0^2)^2 + d0^2 -2*sqrt((((-u+(x^2+(kv*x+bv)^2)/(2*m))*(a*x*(kv*x+bv))+(d2*x*(kv*x+bv)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kv*x+bv))^2)*(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2+d0^2)))))))^2) + (-1/pi)*selfimg/(selfimg^2+(y-selfreal+sqrt(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kv*x+bv))^2 + (a*x*(kv*x+bv))^2 + (d2*x*(kv*x+bv)/k0^2)^2 + d0^2 +2*sqrt((((-u+(x^2+(kv*x+bv)^2)/(2*m))*(a*x*(kv*x+bv))+(d2*x*(kv*x+bv)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kv*x+bv))^2)*(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2+d0^2)))))))^2) + (-1/pi)*selfimg/(selfimg^2+(y-selfreal+sqrt(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2 + (Vsoc*x)^2 + (Vsoc*(kv*x+bv))^2 + (a*x*(kv*x+bv))^2 + (d2*x*(kv*x+bv)/k0^2)^2 + d0^2 -2*sqrt((((-u+(x^2+(kv*x+bv)^2)/(2*m))*(a*x*(kv*x+bv))+(d2*x*(kv*x+bv)/k0^2)*d0)^2 + ((Vsoc*x)^2+(Vsoc*(kv*x+bv))^2)*(((-u+(x^2+(kv*x+bv)^2)/(2*m))^2+d0^2)))))))^2)
	endif
	variable lensh = sqrt((x1h-x2h)^2+(y1h-y2h)^2)
	variable lensv = sqrt((x1v-x2v)^2+(y1v-y2v)^2)
	setscale/i x,-lensh/2,lensh/2,"",lhlinew
	setscale/i x,-lensv/2,lensv/2,"",lvlinew

	//anglelinecutVf(mat3dn_cons,angle_3dplot,zn_cons,addX_3dplot,normornot_3dplot,smornot_3dplot)
	//string linecutH = "LH_"+mat3dn_consf
	//slicesMDC($linecutH)
end




/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
// Gamma kp model used in Nat. Phys. 15, 41 (2019)
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

Function ButtonProc_fourbandkpFeSC(ctrlName) : ButtonControl
	String ctrlName
	execute "fourbandkpFeSC()"
end

Proc fourbandkpFeSC(sel)
	variable sel
	prompt sel,"select mode",popup,"2D;3D"
	if (sel == 1)
		fourbandFeSC2D()
	endif

	if (sel == 2)
		fourbandFeSC3D()
	endif
end

Function fourbandFeSC3D()
	variable/C m01, m11, m21, m02,m12,m22,m03,m13,m23
	m01= cmplx(0.04,0)
	m11=cmplx(2.4,0)
	m21=cmplx(-0.8,0)
	m02=cmplx(0,0)
	m12=cmplx(-3.8,0)
	m22=cmplx(0.14,0)
	m03=cmplx(-0.002,0)
	m13=cmplx(-0.2,0)
	m23=cmplx(0.002,0)
	variable/c alpha,bet,gamm,kai
	alpha = cmplx(-4.4,0)
	bet = cmplx(2.2,0)
	gamm = cmplx(0.004,0)
	kai = cmplx(0.412,0)
	variable/c lamda1, lamda2,lamda3, lamdar
	lamda1 = cmplx(0.50105,0)
	lamda2 = cmplx(0.5003,0)
	lamda3 = cmplx(0.5019,0)
	lamdar = cmplx(2.5005,0)


	variable kz = 0
	variable kx,ky
	variable/C M1, M2, M3
	variable/C kp,km

	make/o/n=(200,200,2000) modelresult
	setscale/i x,-2,2,"",modelresult
	setscale/i y,-2,2,"",modelresult
	setscale/i z,-8,8,"",modelresult
	modelresult = 0


	variable roff = dimoffset(modelresult,2)
	variable rdelta = dimdelta(modelresult,2)

	string prod = "prod"
	string W_eigenvalues="W_eigenvalues"

	variable i,j,selfimg,selfreal,t
	selfimg = 0.2
	selfreal = 0
	i=0
	do
		j=0
		do
			kx = dimoffset(modelresult,0)+i*dimdelta(modelresult,0)
			ky = dimoffset(modelresult,1)+j*dimdelta(modelresult,1)

			M1 = m01+ m11*(kx^2+ky^2)+m21*kz^2
			M2 = m02+ m12*(kx^2+ky^2)+m22*kz^2
			M3 = m03+ m13*(kx^2+ky^2)+m23*kz^2
			kp = cmplx(kx,ky)
			km = cmplx(kx,-ky)

			make/N=(8,8)/o/C Hsoc
			Hsoc = cmplx(0,0)
			Hsoc[0][6] = sqrt(2)*kz*lamda3
			Hsoc[1][1] = -lamda1
			Hsoc[1][4] = sqrt(2)*kz*lamda3
			Hsoc[2][2] = lamda1
			Hsoc[2][7] = -sqrt(2)*lamda2
			Hsoc[3][5] = sqrt(2)*lamda2
			Hsoc[4][1] = sqrt(2)*kz*lamda3
			Hsoc[5][3] = sqrt(2)*lamda2
			Hsoc[5][5] = lamda1
			Hsoc[6][0] = sqrt(2)*kz*lamda3
			Hsoc[6][6] = -lamda1
			Hsoc[7][2] = -sqrt(2)*lamda2

			make/N=(8,8)/o/C HSOCR
			Hsocr = cmplx(0,0)
			HSOCR[1][5]=-lamdar*cmplx(0,1)*km
			HSOCR[2][6]=-lamdar*cmplx(0,1)*km
			HSOCR[5][1]=lamdar*cmplx(0,1)*kp
			HSOCR[6][2]=lamdar*cmplx(0,1)*kp

			make/N=(4,4)/o/C Hband
			Hband = cmplx(0,0)
			Hband[0][0] = m1
			Hband[0][1] = -kai*km/sqrt(2)
			Hband[0][2] = kai*kp/sqrt(2)
			Hband[0][3] = 0
			Hband[1][0] = -kai*kp/sqrt(2)
			Hband[1][1] = m2
			Hband[1][2] = bet*(kx^2-ky^2)-cmplx(0,1)*alpha*kx*ky
			Hband[1][3] = gamm*kz*km/sqrt(2)
			Hband[2][0] = kai*km/sqrt(2)
			Hband[2][1] = bet*(kx^2-ky^2)+cmplx(0,1)*alpha*kx*ky
			Hband[2][2] = m2
			Hband[2][3] = gamm*kz*kp/sqrt(2)
			Hband[3][0] = 0
			Hband[3][1] = gamm*kz*kp/sqrt(2)
			Hband[3][2] = gamm*kz*km/sqrt(2)
			Hband[3][3] = m3

			mpc(s0(),Hband)
			wave/C prodw = $prod
			make/N=(8,8)/o/C Htotal
			Htotal = prodw + HSOC + HSOCR

			matrixeigenv Htotal
			wave/C n=$W_eigenvalues
			make/n=8/o sorteigen


			sorteigen[0]= real(N[0])
			sorteigen[1]= real(N[1])
			sorteigen[2]= real(N[2])
			sorteigen[3]= real(N[3])
			sorteigen[4]= real(N[4])
			sorteigen[5]= real(N[5])
			sorteigen[6]= real(N[6])
			sorteigen[7]= real(N[7])

			sort sorteigen sorteigen



			T=0
			do
				modelresult[i][j][]+=(-1/pi)*selfimg/(selfimg^2+((roff+r*rdelta)-selfreal-sorteigen[t])^2)
				t+=1
			while (t < 8)


			j+=1
		while(j < dimsize(modelresult,1))
		i+=1
	while(i < dimsize(modelresult,0)	)
	duplicate/o modelresult N1_001
	killwaves modelresult sorteigen Hband HSOCR HSOC prodw Htotal



	execute "d3d(\"N1_001\",2)"

	//////Modify the 3D player for this special simulation use (band structure)
	variable/G divcolor_cons
	divcolor_cons = 1
		wavestats/Q $tpw()
		variable rangls = max(abs(V_max),abs(V_min))
		ModifyImage/W=$grabwinchild(tpw()) $tpw() ctab= {-rangls,rangls,:Packages:NewColortable:dvg_seismic,0};
		ColorScale/W=$grabwinchild(tpw())/C/N=textcc/X=-21.00/Y=5.00/F=0 heightPct=30,nticks=5,minor=1,tickLen=1.00,image=$tpw()//;ColorScale/W=$grabwinchild(Fexyd)/C/N=text0/F=0/A=MC/Y=-120 image=$Fexyd
		variable/G normornot_3dplot =2

	Button launchLinecut title="Linecut",size={65,14},fSize=10,proc=ButtonProc_Cons3dplotZ
end



////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//** {{{{{{{{{{ Launch arbitary Linecut extraction (Z is horizental) }}}}}}}}}}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Cons3dplotZ(ctrlName) : ButtonControl
	String ctrlName
	string/G mat3dn_cons

	string mat3dn_consf = mat3dn_cons//+"_FFT3d"


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
		SetVariable setvarangle win=$grabwin(slicename),title="Rotate",size={65,14},value=angle_3dplot,proc=SetVarProc_rotate3dplotf2,pos={159,1}
		SetVariable setvarangle win=$grabwin(slicename),limits={-89,89,1}

		//SetVariable setvarangle2 win=PRB_98_214503_normalP,title="Rotate",size={65,14},value=angle_3dplot,proc=SetVarProc_rotate3dplotf22
		//SetVariable setvarangle2 win=PRB_98_214503_normalP,limits={-89,89,1}


	//**SetVar of AddY [set the Yrange(angel) by auto search]
		SetVariable setaddY win=$grabwin(slicename),title="LH",size={65,14},value=addY_3dplot,proc=SetVarProc_addY3dplotf2,pos={225,1}
		duplicate/o findrangeforangle_LHf(mat3dn_consf,angle_3dplot,zn_cons) rotateYlimit
		SetVariable setaddY win=$grabwin(slicename),limits={rotateYlimit[0],rotateYlimit[1],1}


		//SetVariable setaddY2 win=PRB_98_214503_normalP,title="LH",size={65,14},value=addY_3dplot,proc=SetVarProc_rotate3dplotf22//SetVarProc_addY3dplotf22
		//SetVariable setaddY2 win=PRB_98_214503_normalP,limits={rotateYlimit[0],rotateYlimit[1],1}

	//**SetVar of AddX [set the Xrange(angel) by auto search]
		SetVariable setaddX win=$grabwin(slicename),title="LV",size={65,14},value=addX_3dplot,proc=SetVarProc_addX3dplotf2,pos={292,1}
		duplicate/o findrangeforangle_LVf(mat3dn_consf,angle_3dplot,zn_cons) rotateXlimit
		SetVariable setaddX win=$grabwin(slicename),limits={rotateXlimit[0],rotateXlimit[1],1}

		//SetVariable setaddX2 win=PRB_98_214503_normalP,title="LV",size={65,14},value=addX_3dplot,proc=SetVarProc_rotate3dplotf22//SetVarProc_addX3dplotf22
		//SetVariable setaddX2 win=PRB_98_214503_normalP,limits={rotateXlimit[0],rotateXlimit[1],1}

	//**Extract LinecutH and make graph
		anglelinecutHf(mat3dn_consf,angle_3dplot,zn_cons,addY_3dplot,normornot_3dplot,smornot_3dplot)
		string linecutH = "LH_"+mat3dn_consf
		di($linecutH)
		variable/G FFTmode_3dplot
		if (FFTmode_3dplot == 5)
			ModifyImage $linecutH ctab= {*,*,VioletOrangeYellow,0}
		else
			//color3s_for3d($linecutH,30)
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
			ModifyImage $linecutV ctab= {*,*,VioletOrangeYellow,0}
		else
			//color3s_for3d($linecutV,30)
		endif
		Modifygraph/W=$grabwinnonew(linecutV) width=400, height=200
		Label left "\\Z16\\F'times'\\f02E - E\\BF\\f00\\M\\F'times'\\Z16 (meV)"
		Label bottom "\\Z16\\f02k\\f00 (2π Å\\S\\Z10-1\\M\\Z16)"

		ModifyGraph/W=$grabwinnonew(linecutV) axThick=3,axRGB=(16385,65535,41303),tlblRGB=(16385,65535,41303),alblRGB=(16385,65535,41303)
		tilewindows/WINS=grabwinnonew(linecutV)/R/w=(56,0,100,30)/A=(1,1)
end


/////////////////////////////////////////////////////////////////////////////////////////////
Function fourbandFeSC2D()
	variable/C m01, m11, m21, m02,m12,m22,m03,m13,m23
	m01= cmplx(0.04,0)
	m11=cmplx(2.4,0)
	m21=cmplx(-0.8,0)
	m02=cmplx(0,0)
	m12=cmplx(-3.8,0)
	m22=cmplx(0.14,0)
	m03=cmplx(-0.002,0)
	m13=cmplx(-0.2,0)
	m23=cmplx(0.002,0)
	variable/c alpha,bet,gamm,kai
	alpha = cmplx(-4.4,0)
	bet = cmplx(2.2,0)
	gamm = cmplx(0.004,0)
	kai = cmplx(0.412,0)
	variable/c lamda1, lamda2,lamda3, lamdar
	lamda1 = cmplx(1.2,0)
	lamda2 = cmplx(-1.2009,0)
	lamda3 = cmplx(1.9,0)
	lamdar = cmplx(8.0015,0)


	variable kz
	variable kx,ky
	variable/C M1, M2, M3
	variable/C kp,km

	make/o/n=(200,2000) modelresult2d
	setscale/i x,-3,3,"",modelresult2d
	setscale/i y,-15,15,"",modelresult2d
	modelresult2d = 0


	variable roff = dimoffset(modelresult2d,1)
	variable rdelta = dimdelta(modelresult2d,1)

	string prod = "prod"
	string W_eigenvalues="W_eigenvalues"

	variable i,j,selfimg,selfreal,t
	selfimg = 0.2
	selfreal = 0

	variable projectkz = 0
	if (projectkz == 1)

		j=0
		do
			kz = -pi+j*(2*pi/99)
			i=0
			do
				kx = dimoffset(modelresult2d,0)+i*dimdelta(modelresult2d,0)
				ky = 0

				M1 = m01+ m11*(kx^2+ky^2)+m21*kz^2
				M2 = m02+ m12*(kx^2+ky^2)+m22*kz^2
				M3 = m03+ m13*(kx^2+ky^2)+m23*kz^2
				kp = cmplx(kx,ky)
				km = cmplx(kx,-ky)

				make/N=(8,8)/o/C Hsoc
				Hsoc = cmplx(0,0)
				Hsoc[0][6] = sqrt(2)*kz*lamda3
				Hsoc[1][1] = -lamda1
				Hsoc[1][4] = sqrt(2)*kz*lamda3
				Hsoc[2][2] = lamda1
				Hsoc[2][7] = -sqrt(2)*lamda2
				Hsoc[3][5] = sqrt(2)*lamda2
				Hsoc[4][1] = sqrt(2)*kz*lamda3
				Hsoc[5][3] = sqrt(2)*lamda2
				Hsoc[5][5] = lamda1
				Hsoc[6][0] = sqrt(2)*kz*lamda3
				Hsoc[6][6] = -lamda1
				Hsoc[7][2] = -sqrt(2)*lamda2

				make/N=(8,8)/o/C HSOCR
				Hsocr = cmplx(0,0)
				HSOCR[1][5]=-lamdar*cmplx(0,1)*km
				HSOCR[2][6]=-lamdar*cmplx(0,1)*km
				HSOCR[5][1]=lamdar*cmplx(0,1)*kp
				HSOCR[6][2]=lamdar*cmplx(0,1)*kp

				make/N=(4,4)/o/C Hband
				Hband = cmplx(0,0)
				Hband[0][0] = m1
				Hband[0][1] = -kai*km/sqrt(2)
				Hband[0][2] = kai*kp/sqrt(2)
				Hband[0][3] = 0
				Hband[1][0] = -kai*kp/sqrt(2)
				Hband[1][1] = m2
				Hband[1][2] = bet*(kx^2-ky^2)-cmplx(0,1)*alpha*kx*ky
				Hband[1][3] = gamm*kz*km/sqrt(2)
				Hband[2][0] = kai*km/sqrt(2)
				Hband[2][1] = bet*(kx^2-ky^2)+cmplx(0,1)*alpha*kx*ky
				Hband[2][2] = m2
				Hband[2][3] = gamm*kz*kp/sqrt(2)
				Hband[3][0] = 0
				Hband[3][1] = gamm*kz*kp/sqrt(2)
				Hband[3][2] = gamm*kz*km/sqrt(2)
				Hband[3][3] = m3

				mpc(s0(),Hband)
				wave/C prodw = $prod
				make/N=(8,8)/o/C Htotal
				Htotal = prodw + HSOC + HSOCR

				matrixeigenv Htotal
				wave/C n=$W_eigenvalues
				make/n=8/o sorteigen

				sorteigen[0]= real(N[0])
				sorteigen[1]= real(N[1])
				sorteigen[2]= real(N[2])
				sorteigen[3]= real(N[3])
				sorteigen[4]= real(N[4])
				sorteigen[5]= real(N[5])
				sorteigen[6]= real(N[6])
				sorteigen[7]= real(N[7])

				//sort sorteigen sorteigen

				t=0
				do
					modelresult2d[i][]+=(-1/pi)*selfimg/(selfimg^2+((roff+q*rdelta)-selfreal-sorteigen[t])^2)
					t+=1
				while (t < 8)

				i+=1
			while(i < dimsize(modelresult2d,0))
			j+=1
		while (j<100)
	endif

	if (projectkz == 0)
			kz = 0
			i=0
			do
				kx = dimoffset(modelresult2d,0)+i*dimdelta(modelresult2d,0)
				ky = 0

				M1 = m01+ m11*(kx^2+ky^2)+m21*kz^2
				M2 = m02+ m12*(kx^2+ky^2)+m22*kz^2
				M3 = m03+ m13*(kx^2+ky^2)+m23*kz^2
				kp = cmplx(kx,ky)
				km = cmplx(kx,-ky)

				make/N=(8,8)/o/C Hsoc
				Hsoc = cmplx(0,0)
				Hsoc[0][6] = sqrt(2)*kz*lamda3
				Hsoc[1][1] = -lamda1
				Hsoc[1][4] = sqrt(2)*kz*lamda3
				Hsoc[2][2] = lamda1
				Hsoc[2][7] = -sqrt(2)*lamda2
				Hsoc[3][5] = sqrt(2)*lamda2
				Hsoc[4][1] = sqrt(2)*kz*lamda3
				Hsoc[5][3] = sqrt(2)*lamda2
				Hsoc[5][5] = lamda1
				Hsoc[6][0] = sqrt(2)*kz*lamda3
				Hsoc[6][6] = -lamda1
				Hsoc[7][2] = -sqrt(2)*lamda2

				make/N=(8,8)/o/C HSOCR
				Hsocr = cmplx(0,0)
				HSOCR[1][5]=-lamdar*cmplx(0,1)*km
				HSOCR[2][6]=-lamdar*cmplx(0,1)*km
				HSOCR[5][1]=lamdar*cmplx(0,1)*kp
				HSOCR[6][2]=lamdar*cmplx(0,1)*kp

				make/N=(4,4)/o/C Hband
				Hband = cmplx(0,0)
				Hband[0][0] = m1
				Hband[0][1] = -kai*km/sqrt(2)
				Hband[0][2] = kai*kp/sqrt(2)
				Hband[0][3] = 0
				Hband[1][0] = -kai*kp/sqrt(2)
				Hband[1][1] = m2
				Hband[1][2] = bet*(kx^2-ky^2)-cmplx(0,1)*alpha*kx*ky
				Hband[1][3] = gamm*kz*km/sqrt(2)
				Hband[2][0] = kai*km/sqrt(2)
				Hband[2][1] = bet*(kx^2-ky^2)+cmplx(0,1)*alpha*kx*ky
				Hband[2][2] = m2
				Hband[2][3] = gamm*kz*kp/sqrt(2)
				Hband[3][0] = 0
				Hband[3][1] = gamm*kz*kp/sqrt(2)
				Hband[3][2] = gamm*kz*km/sqrt(2)
				Hband[3][3] = m3

				mpc(s0(),Hband)
				wave/C prodw = $prod
				make/N=(8,8)/o/C Htotal
				Htotal = prodw + HSOC + HSOCR

				matrixeigenv Htotal
				wave/C n=$W_eigenvalues
				make/n=8/o sorteigen

				sorteigen[0]= real(N[0])
				sorteigen[1]= real(N[1])
				sorteigen[2]= real(N[2])
				sorteigen[3]= real(N[3])
				sorteigen[4]= real(N[4])
				sorteigen[5]= real(N[5])
				sorteigen[6]= real(N[6])
				sorteigen[7]= real(N[7])


				t=0
				do
					modelresult2d[i][]+=(-1/pi)*selfimg/(selfimg^2+((roff+q*rdelta)-selfreal-sorteigen[t])^2)
					t+=1
				while (t < 8)

				i+=1
			while(i < dimsize(modelresult2d,0))
	endif


	killwaves sorteigen Hband HSOCR HSOC prodw Htotal
	di(modelresult2d)
	ModifyImage modelresult2d ctab= {*,*,Terrain,1}
	modifygraph width= 300,height=500

	variable/G lamda1_fesc2d = real(lamda1)
	variable/G lamda2_fesc2d = real(lamda2)
	variable/G lamda3_fesc2d = real(lamda3)
	variable/G lamdaR_fesc2d = real(lamdar)

	SetVariable setvarz_lamda1_fesc2d title="λ1",size={65,14},value=lamda1_fesc2d,limits={-inf,inf,lamda1},proc=SetVarProc_lamda_fesc2d
	SetVariable setvarz_lamda2_fesc2d title="λ2",size={65,14},value=lamda2_fesc2d,limits={-inf,inf,lamda2},proc=SetVarProc_lamda_fesc2d
	SetVariable setvarz_lamda3_fesc2d title="λ3",size={65,14},value=lamda3_fesc2d,limits={-inf,inf,lamda3},proc=SetVarProc_lamda_fesc2d
	SetVariable setvarz_lamdar_fesc2d title="λR",size={65,14},value=lamdaR_fesc2d,limits={-inf,inf,lamdaR},proc=SetVarProc_lamda_fesc2d
	Button Kzprojection title="Project kz",size={65,14},fSize=10,proc=ButtonProc_Kzprojection
end

Function SetVarProc_lamda_fesc2d(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	updatefourbandFeSC2D()
end

Function updatefourbandFeSC2D()

	variable/G lamda1_fesc2d //= real(lamda1)
	variable/G lamda2_fesc2d //= real(lamda2)
	variable/G lamda3_fesc2d //= real(lamda3)
	variable/G lamdaR_fesc2d //= real(lamdar)

	variable/C m01, m11, m21, m02,m12,m22,m03,m13,m23
	m01= cmplx(0.04,0)
	m11=cmplx(2.4,0)
	m21=cmplx(-0.8,0)
	m02=cmplx(0,0)
	m12=cmplx(-3.8,0)
	m22=cmplx(0.14,0)
	m03=cmplx(-0.002,0)
	m13=cmplx(-0.2,0)
	m23=cmplx(0.002,0)
	variable/c alpha,bet,gamm,kai
	alpha = cmplx(-4.4,0)
	bet = cmplx(2.2,0)
	gamm = cmplx(0.004,0)
	kai = cmplx(0.412,0)
	variable/c lamda1, lamda2,lamda3, lamdar
	lamda1 = cmplx(lamda1_fesc2d,0)
	lamda2 = cmplx(lamda2_fesc2d,0)
	lamda3 = cmplx(lamda3_fesc2d,0)
	lamdar = cmplx(lamdaR_fesc2d,0)


	variable kz
	variable kx,ky
	variable/C M1, M2, M3
	variable/C kp,km

	make/o/n=(200,2000) modelresult2d
	setscale/i x,-3,3,"",modelresult2d
	setscale/i y,-15,15,"",modelresult2d
	modelresult2d = 0


	variable roff = dimoffset(modelresult2d,1)
	variable rdelta = dimdelta(modelresult2d,1)

	string prod = "prod"
	string W_eigenvalues="W_eigenvalues"

	variable i,j,selfimg,selfreal,t
	selfimg = 0.2
	selfreal = 0

			kz = 0
			i=0
			do
				kx = dimoffset(modelresult2d,0)+i*dimdelta(modelresult2d,0)
				ky = 0

				M1 = m01+ m11*(kx^2+ky^2)+m21*kz^2
				M2 = m02+ m12*(kx^2+ky^2)+m22*kz^2
				M3 = m03+ m13*(kx^2+ky^2)+m23*kz^2
				kp = cmplx(kx,ky)
				km = cmplx(kx,-ky)

				make/N=(8,8)/o/C Hsoc
				Hsoc = cmplx(0,0)
				Hsoc[0][6] = sqrt(2)*kz*lamda3
				Hsoc[1][1] = -lamda1
				Hsoc[1][4] = sqrt(2)*kz*lamda3
				Hsoc[2][2] = lamda1
				Hsoc[2][7] = -sqrt(2)*lamda2
				Hsoc[3][5] = sqrt(2)*lamda2
				Hsoc[4][1] = sqrt(2)*kz*lamda3
				Hsoc[5][3] = sqrt(2)*lamda2
				Hsoc[5][5] = lamda1
				Hsoc[6][0] = sqrt(2)*kz*lamda3
				Hsoc[6][6] = -lamda1
				Hsoc[7][2] = -sqrt(2)*lamda2

				make/N=(8,8)/o/C HSOCR
				Hsocr = cmplx(0,0)
				HSOCR[1][5]=-lamdar*cmplx(0,1)*km
				HSOCR[2][6]=-lamdar*cmplx(0,1)*km
				HSOCR[5][1]=lamdar*cmplx(0,1)*kp
				HSOCR[6][2]=lamdar*cmplx(0,1)*kp

				make/N=(4,4)/o/C Hband
				Hband = cmplx(0,0)
				Hband[0][0] = m1
				Hband[0][1] = -kai*km/sqrt(2)
				Hband[0][2] = kai*kp/sqrt(2)
				Hband[0][3] = 0
				Hband[1][0] = -kai*kp/sqrt(2)
				Hband[1][1] = m2
				Hband[1][2] = bet*(kx^2-ky^2)-cmplx(0,1)*alpha*kx*ky
				Hband[1][3] = gamm*kz*km/sqrt(2)
				Hband[2][0] = kai*km/sqrt(2)
				Hband[2][1] = bet*(kx^2-ky^2)+cmplx(0,1)*alpha*kx*ky
				Hband[2][2] = m2
				Hband[2][3] = gamm*kz*kp/sqrt(2)
				Hband[3][0] = 0
				Hband[3][1] = gamm*kz*kp/sqrt(2)
				Hband[3][2] = gamm*kz*km/sqrt(2)
				Hband[3][3] = m3

				mpc(s0(),Hband)
				wave/C prodw = $prod
				make/N=(8,8)/o/C Htotal
				Htotal = prodw + HSOC + HSOCR

				matrixeigenv Htotal
				wave/C n=$W_eigenvalues
				make/n=8/o sorteigen

				sorteigen[0]= real(N[0])
				sorteigen[1]= real(N[1])
				sorteigen[2]= real(N[2])
				sorteigen[3]= real(N[3])
				sorteigen[4]= real(N[4])
				sorteigen[5]= real(N[5])
				sorteigen[6]= real(N[6])
				sorteigen[7]= real(N[7])


				t=0
				do
					modelresult2d[i][]+=(-1/pi)*selfimg/(selfimg^2+((roff+q*rdelta)-selfreal-sorteigen[t])^2)
					t+=1
				while (t < 8)

				i+=1
			while(i < dimsize(modelresult2d,0))
	killwaves sorteigen Hband HSOCR HSOC prodw Htotal
end

Function ButtonProc_Kzprojection(ctrlName) : ButtonControl
	String ctrlName

	variable/G lamda1_fesc2d //= real(lamda1)
	variable/G lamda2_fesc2d //= real(lamda2)
	variable/G lamda3_fesc2d //= real(lamda3)
	variable/G lamdaR_fesc2d //= real(lamdar)
	variable/C m01, m11, m21, m02,m12,m22,m03,m13,m23
	m01= cmplx(0.04,0)
	m11=cmplx(2.4,0)
	m21=cmplx(-0.8,0)
	m02=cmplx(0,0)
	m12=cmplx(-3.8,0)
	m22=cmplx(0.14,0)
	m03=cmplx(-0.002,0)
	m13=cmplx(-0.2,0)
	m23=cmplx(0.002,0)
	variable/c alpha,bet,gamm,kai
	alpha = cmplx(-4.4,0)
	bet = cmplx(2.2,0)
	gamm = cmplx(0.004,0)
	kai = cmplx(0.412,0)
	variable/c lamda1, lamda2,lamda3, lamdar
	lamda1 = cmplx(lamda1_fesc2d,0)
	lamda2 = cmplx(lamda2_fesc2d,0)
	lamda3 = cmplx(lamda3_fesc2d,0)
	lamdar = cmplx(lamdaR_fesc2d,0)


	variable kz
	variable kx,ky
	variable/C M1, M2, M3
	variable/C kp,km

	make/o/n=(200,2000) modelresult2d
	setscale/i x,-3,3,"",modelresult2d
	setscale/i y,-15,15,"",modelresult2d
	modelresult2d = 0


	variable roff = dimoffset(modelresult2d,1)
	variable rdelta = dimdelta(modelresult2d,1)

	string prod = "prod"
	string W_eigenvalues="W_eigenvalues"

	variable i,j,selfimg,selfreal,t
	selfimg = 0.2
	selfreal = 0

		j=0
		do
			kz = -pi+j*(2*pi/99)
			i=0
			do
				kx = dimoffset(modelresult2d,0)+i*dimdelta(modelresult2d,0)
				ky = 0

				M1 = m01+ m11*(kx^2+ky^2)+m21*kz^2
				M2 = m02+ m12*(kx^2+ky^2)+m22*kz^2
				M3 = m03+ m13*(kx^2+ky^2)+m23*kz^2
				kp = cmplx(kx,ky)
				km = cmplx(kx,-ky)

				make/N=(8,8)/o/C Hsoc
				Hsoc = cmplx(0,0)
				Hsoc[0][6] = sqrt(2)*kz*lamda3
				Hsoc[1][1] = -lamda1
				Hsoc[1][4] = sqrt(2)*kz*lamda3
				Hsoc[2][2] = lamda1
				Hsoc[2][7] = -sqrt(2)*lamda2
				Hsoc[3][5] = sqrt(2)*lamda2
				Hsoc[4][1] = sqrt(2)*kz*lamda3
				Hsoc[5][3] = sqrt(2)*lamda2
				Hsoc[5][5] = lamda1
				Hsoc[6][0] = sqrt(2)*kz*lamda3
				Hsoc[6][6] = -lamda1
				Hsoc[7][2] = -sqrt(2)*lamda2

				make/N=(8,8)/o/C HSOCR
				Hsocr = cmplx(0,0)
				HSOCR[1][5]=-lamdar*cmplx(0,1)*km
				HSOCR[2][6]=-lamdar*cmplx(0,1)*km
				HSOCR[5][1]=lamdar*cmplx(0,1)*kp
				HSOCR[6][2]=lamdar*cmplx(0,1)*kp

				make/N=(4,4)/o/C Hband
				Hband = cmplx(0,0)
				Hband[0][0] = m1
				Hband[0][1] = -kai*km/sqrt(2)
				Hband[0][2] = kai*kp/sqrt(2)
				Hband[0][3] = 0
				Hband[1][0] = -kai*kp/sqrt(2)
				Hband[1][1] = m2
				Hband[1][2] = bet*(kx^2-ky^2)-cmplx(0,1)*alpha*kx*ky
				Hband[1][3] = gamm*kz*km/sqrt(2)
				Hband[2][0] = kai*km/sqrt(2)
				Hband[2][1] = bet*(kx^2-ky^2)+cmplx(0,1)*alpha*kx*ky
				Hband[2][2] = m2
				Hband[2][3] = gamm*kz*kp/sqrt(2)
				Hband[3][0] = 0
				Hband[3][1] = gamm*kz*kp/sqrt(2)
				Hband[3][2] = gamm*kz*km/sqrt(2)
				Hband[3][3] = m3

				mpc(s0(),Hband)
				wave/C prodw = $prod
				make/N=(8,8)/o/C Htotal
				Htotal = prodw + HSOC + HSOCR

				matrixeigenv Htotal
				wave/C n=$W_eigenvalues
				make/n=8/o sorteigen

				sorteigen[0]= real(N[0])
				sorteigen[1]= real(N[1])
				sorteigen[2]= real(N[2])
				sorteigen[3]= real(N[3])
				sorteigen[4]= real(N[4])
				sorteigen[5]= real(N[5])
				sorteigen[6]= real(N[6])
				sorteigen[7]= real(N[7])

				//sort sorteigen sorteigen

				t=0
				do
					modelresult2d[i][]+=(-1/pi)*selfimg/(selfimg^2+((roff+q*rdelta)-selfreal-sorteigen[t])^2)
					t+=1
				while (t < 8)

				i+=1
			while(i < dimsize(modelresult2d,0))
			j+=1
		while (j<100)
	killwaves sorteigen Hband HSOCR HSOC prodw Htotal
end




///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
//****************************** Haldane Model ********************************************
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
//Ref: Duncan Haldane Phys. Rev. Lett. 61 (1988) 2015-2018
//Ref: https://ncatlab.org/nlab/show/Haldane+model#DTC
//Ref: https://topocondmat.org/w4_haldane/haldane_model.html
//Ref: https://mp.weixin.qq.com/s/aQl7YvSIc3xCaAZ4ZQUYEg
///////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////
//************************* Build Haldane Hamiltonian *************************************
///////////////////////////////////////////////////////////////////////////////////////////
Function/Wave HaldaneModel(t1,t2,M,phi,kx,ky)
	variable t1
	variable t2
	variable M
	variable phi
	variable kx
	variable ky

	//** Lattice vector of Haldane Hamiltonian
		variable a = 1
		wn("a1",{0,a})
		wn("a2",{-sqrt(3)*a/2,-a/2})
		wn("a3",{sqrt(3)*a/2,-a/2})
		wave a1 = $"a1"
		wave a2 = $"a2"
		wave a3 = $"a3"
		duplicate/o a1 b1
		duplicate/o a1 b2
		duplicate/o a1 b3
		b1 = a2-a3
		b2 = a3-a1
		b3 = a1-a2
		variable e,dx,dy,dz

	//** Pointer String for called Functions
		string ps = "ps_haldane"
		string result_C = "result_C"


	//** Create Haldane Hamiltonian
		e = 2*t2*cos(phi)*(cos(kx*b1[0]+ky*b1[1]) + cos(kx*b2[0]+ky*b2[1]) + cos(kx*b3[0]+ky*b3[1]))
		dx = t1*(Cos(kx*a1[0]+ky*a1[1])+Cos(kx*a2[0]+ky*a2[1])+Cos(kx*a3[0]+ky*a3[1]))
		dy = t1* (Sin(kx*a1[0]+ky*a1[1])+Sin(kx*a2[0]+ky*a2[1])+Sin(kx*a3[0]+ky*a3[1]))
		dz = M-2*t2*Sin(phi)*(Sin(kx*b1[0]+ky*b1[1])+Sin(kx*b2[0]+ky*b2[1])+Sin(kx*b3[0]+ky*b3[1]))

		//## Haldane Hamiltonian: H=e*sigma0+dx*sigma1+dy*sigma2+dz*sigma3;

		wC("e_haldane",{{cmplx(e,0)}})
		wC("dx_haldane",{{cmplx(dx,0)}})
		wC("dy_haldane",{{cmplx(dy,0)}})
		wC("dz_haldane",{{cmplx(dz,0)}})
		Wn("ps_haldane",{{0},{1},{2},{3}})
		automatrixC("e_haldane;dx_haldane;dy_haldane;dz_haldane",$ps)
		wave/C result_Cw = $result_C
		duplicate/C/o result_Cw HaldaneH
		killwaves $result_C a1 a2 a3 b1 b2 b3
	return HaldaneH
end

///////////////////////////////////////////////////////////////////////////////////////////
//*************************** Build Haldane Spectral Function *****************************
///////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_HaldaneA(ctrlName) : ButtonControl
	String ctrlName
	execute "HaldaneSpectralFunctionc()"
end
Proc HaldaneSpectralFunctionc(t1,t2,M,phi,selfimg,numxy)
	variable t1 = 1
	variable t2 = 0.2
	variable M = 0.2
	variable phi = 0.2*pi
	variable selfimg = 0.05
	variable numxy = 100
	prompt selfimg,"Im(Σ)"
	prompt numxy,"N x N in (kx,ky) space"
	HaldaneSpectralFunction(t1,t2,M,phi,selfimg,numxy)
end

Function HaldaneSpectralFunction(t1,t2,M,phi,selfimg,numxy)
	variable t1 //= 1
	variable t2 //= 0
	variable M //= 0.2
	variable phi //= 0.2*pi
	variable selfimg
	variable numxy //= 100
	variable/G zn_cons = 2

	//** Make void matrix for spectral function
	make/o/n=(numxy,numxy,500) modelresult_haldane
	setscale/i x,-3,3,"",modelresult_haldane
	setscale/i y,-3,3,"",modelresult_haldane
	setscale/i z,-4.5,4.5,"",modelresult_haldane
	modelresult_haldane = 0
	variable roff = dimoffset(modelresult_haldane,2)
	variable rdelta = dimdelta(modelresult_haldane,2)

	//** Variable for Spectral Function
	variable i,j,selfreal,t
	selfreal = 0
	variable kx
	variable ky

	//** Pointer String for called Functions
	string W_eigenvalues="W_eigenvalues"
	string HaldaneH = "HaldaneH"

	//** Start loop for (kx, ky)
	i=0
	do
		j=0
		do
			//** Define kx, ky by void matrix shape
				kx = dimoffset(modelresult_haldane,0)+i*dimdelta(modelresult_haldane,0)
				ky = dimoffset(modelresult_haldane,1)+j*dimdelta(modelresult_haldane,1)

				HaldaneModel(t1,t2,M,phi,kx,ky)
				wave/C HaldaneHw = $HaldaneH

			//** Solve eigenvalue of Haldane Hamiltonian

				matrixEigenV HaldaneHw
				wave/C n=$W_eigenvalues
				make/n=(dimsize(HaldaneHw,0))/o sorteigen

				sorteigen[0]= real(N[0])
				sorteigen[1]= real(N[1])

			//Make 3D Spectral Function
				t=0
				do
					modelresult_haldane[i][j][]+=(-1/pi)*selfimg/(selfimg^2+((roff+r*rdelta)-selfreal-sorteigen[t])^2)
					t+=1
				while (t < dimsize(sorteigen,0))

			j+=1
		while(j < dimsize(modelresult_haldane,1))
		i+=1
	while(i < dimsize(modelresult_haldane,0)	)

	//** Call smart 3D displayer
		duplicate/o modelresult_haldane N1_002
		killwaves modelresult_haldane sorteigen HaldaneHw n
		execute "d3d(\"N1_002\",2)"

	//** Modify the 3D player for this special simulation use (band structure)
		variable/G divcolor_cons
		divcolor_cons = 1
		wavestats/Q $tpw()
		variable rangls = max(abs(V_max),abs(V_min))
		ModifyImage/W=$grabwinchild(tpw()) $tpw() ctab= {-rangls,rangls,:Packages:NewColortable:dvg_seismic,0};
		ColorScale/W=$grabwinchild(tpw())/C/N=textcc/X=-21.00/Y=5.00/F=0 heightPct=30,nticks=5,minor=1,tickLen=1.00,image=$tpw()//;ColorScale/W=$grabwinchild(Fexyd)/C/N=text0/F=0/A=MC/Y=-120 image=$Fexyd
		variable/G normornot_3dplot =2
		Button launchLinecut title="Linecut",size={65,14},fSize=10,proc=ButtonProc_Cons3dplotZ
end

///////////////////////////////////////////////////////////////////////////////////////////
//************************** Calculate Berry Curvature ************************************
///////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_HaldaneBC(ctrlName) : ButtonControl
	String ctrlName
	execute "HaldaneBerryCurvaturec()"
end
Proc HaldaneBerryCurvaturec(t1,t2,M,phi,numxy,sel)
	variable t1 = 1
	variable t2 = 0.2
	variable M = 0.2
	variable phi = 0.2*pi
	variable numxy = 100
	variable sel = 1
	prompt numxy,"N x N in (kx,ky) space"
	prompt sel,"Select algorithm",popup,"Direct;Fukui"
	if (sel == 1)
		HaldaneBerryCurvature(t1,t2,M,phi,numxy)
	endif
	if (sel == 2)
		HaldaneBCFukui(t1,t2,M,phi,numxy)
	endif
end
Function HaldaneBerryCurvature(t1,t2,M,phi,numxy)
	variable t1 //= 1
	variable t2 //= 0.2
	variable M //= 0.2
	variable phi //= 0.2*pi
	variable numxy //= 100

	variable kx
	variable ky
	variable i,j

	Variable timerRefNum
	timerRefNum = StartMSTimer

	//** Make void matrix for spectral function
		make/o/n=(numxy,numxy,1) voidberry_haldane
		setscale/i x,-3,3,"",voidberry_haldane
		setscale/i y,-3,3,"",voidberry_haldane
		//setscale/i z,-2.5,4.5,"",voidberry_haldane
		voidberry_haldane = 0

	//** Make void matrix for Berry curvature band #1 (lower) and #2 (higher)
		make/o/n=(numxy,numxy) BC_haldane1
		setscale/i x,-3,3,"",BC_haldane1
		setscale/i y,-3,3,"",BC_haldane1
		BC_haldane1 = 0//cmplx(0,0)

		make/o/n=(numxy,numxy) BC_haldane2
		setscale/i x,-3,3,"",BC_haldane2
		setscale/i y,-3,3,"",BC_haldane2
		BC_haldane2 = 0//cmplx(0,0)

	//** Pointer String for called Functions
		string W_eigenvalues="W_eigenvalues"
		string HaldaneH = "HaldaneH"
		string M_R_eigenVectors = "M_R_eigenVectors"
		string M_product = "M_product"

	//** variable for Berry curvature
		variable E1k, E2K //1 for low band, 2 for high band
		variable delta = 10^-6
		variable/C Berryterm1A = cmplx(0,0)
		variable/C Berryterm1B = cmplx(0,0)

		variable/C Berryterm2A = cmplx(0,0)
		variable/C Berryterm2B = cmplx(0,0)

	//** Start loop for (kx, ky)
		i=0
		do
			j=0
			do
				//** Define kx, ky by void matrix shape
					kx = dimoffset(voidberry_haldane,0)+i*dimdelta(voidberry_haldane,0)
					ky = dimoffset(voidberry_haldane,1)+j*dimdelta(voidberry_haldane,1)

					HaldaneModel(t1,t2,M,phi,kx,ky)
					wave/C HaldaneHw = $HaldaneH

				//** Solve eigenvalue of Haldane Hamiltonian

					matrixEigenV/R HaldaneHw
					wave/C n=$W_eigenvalues
					wave/C eignevector=$M_R_eigenVectors

					make/n=(dimsize(HaldaneHw,0))/o sorteigen

					sorteigen[0]= real(N[0])
					sorteigen[1]= real(N[1])

				//**Sort eigenvalue and eigenvector
					make/o/n=(dimsize(HaldaneHw,0)) sortindex
					sortindex=p
					sort sorteigen sortindex //the value indicates the column number in M_R_eigenVectors belong to each eigenvalue labeled in sorteigen
					sort sorteigen sorteigen

				//** Calculat Berry Curvature

					//## E1,k = sorteigen[0]
					//## |u1,k> = eignevector[][sortindex[0]]

					//## E2,k = sorteigen[1]
					//## |u2,k> = eignevector[][sortindex[1]]


					//** get eigenvalue
						E1k = sorteigen[0]
						E2k = sorteigen[1]

					//** make |u1,k>
						//|ket>
						make/n=(dimsize(HaldaneHw,0),1)/o/C u1k_ket
						u1k_ket[] = eignevector[p][sortindex[0]]
						//<bra|
						duplicate/o/c u1k_ket u1k_bra
						matrixtranspose/H u1k_bra

					//** make |u2,k>
						//|ket>
						make/n=(dimsize(HaldaneHw,0),1)/o/C u2k_ket
						u2k_ket[] = eignevector[p][sortindex[1]]
						//<bra|
						duplicate/o/c u2k_ket u2k_bra
						matrixtranspose/H u2k_bra

					//** make dH/dx(k)
						duplicate/o/c HaldaneHw HaldaneHworigin

						HaldaneModel(t1,t2,M,phi,kx+delta,ky)
						wave/C HaldaneHw = $HaldaneH
						duplicate/o/c HaldaneHw dHdx
						dHdx = (HaldaneHw - HaldaneHworigin)/delta

					//** make dH/dy(k)
						HaldaneModel(t1,t2,M,phi,kx,ky+delta)
						wave/C HaldaneHw = $HaldaneH
						duplicate/o/c HaldaneHw dHdy
						dHdy = (HaldaneHw - HaldaneHworigin)/delta
						killwaves HaldaneHworigin HaldaneHw

					//** calculate Omega_1

						matrixMultiply u1k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm1A =  M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1A *= M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm1B =  M_productw[0][0]

						matrixMultiply u2k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1B *=  M_productw[0][0]

						Berryterm1A -= Berryterm1B
						Berryterm1A /= (E1k-E2k)^2
						Berryterm1A *= cmplx(0,1)

						//BC_haldane1[i][j] = sqrt(magsqr(Berryterm1A))
						BC_haldane1[i][j] = real(Berryterm1A)

					//** calculate Omega_2

						matrixMultiply u2k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm2A =  M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2A *= M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm2B =  M_productw[0][0]

						matrixMultiply u1k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2B *=  M_productw[0][0]

						Berryterm2A -= Berryterm2B
						Berryterm2A /= (E1k-E2k)^2
						Berryterm2A *= cmplx(0,1)

						//BC_haldane2[i][j] = sqrt(magsqr(Berryterm2A))
						BC_haldane2[i][j] = real(Berryterm2A)

				j+=1
			while(j < dimsize(voidberry_haldane,1))
			i+=1
		while(i < dimsize(voidberry_haldane,0))
	killwaves voidberry_haldane n sorteigen eignevector sortindex u1k_ket u1k_bra u2k_ket u2k_bra dHdx dHdy HaldaneHworigin HaldaneHw M_productw
	di(BC_haldane1)
	ModifyImage BC_haldane1 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0}
	di(BC_haldane2)
	ModifyImage BC_haldane2 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0}
	Print "//*************************************                "
	Print "		The parameters (t1,t2,M,phi) are ("+num2str(t1)+","+num2str(t2)+","+num2str(M)+","+num2str(phi)+")"
	Print "		Chern Number for band #1 is "+num2str(ChernN_haldane(BC_haldane1))
	Print "		Chern Number for band #2 is "+num2str(ChernN_haldane(BC_haldane2))
	variable Seconds = StopMSTimer(timerRefNum)/10^6
	Print "		Total Time Running: "+num2str(Seconds)+" (s)"
end

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
//****************************** Interactive Tuning ***************************************
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_HaldaneCons(ctrlName) : ButtonControl
	String ctrlName
	execute "ConsHaldane()"
end

//** #01 Body
Proc ConsHaldane()
	variable t1 = 1
	variable t2 = 0.2
	variable M = 0.2
	variable phi = 0.2*pi
	variable selfimg = 0.05

	variable numxy = 100
	variable rangls
	Cons_Haldanecut(t1,t2,M,phi,selfimg,200)
	Cons_HaldaneFS(t1,t2,M,phi,selfimg,15)
	cons_HaldaneBC(t1,t2,M,phi,20)
	string bc_haldane1 = "bc_haldane1"
	string bc_haldane2 = "bc_haldane2"
	string fs_haldane = "fs_haldane"
	string cut_haldane = "cut_haldane"
	display/N=haldanemodelinteractive
	modifygraph width= 600,height=600

	Display/HOST=#/W=(0,0.05,0.5,0.5);appendimage $fs_haldane;ModifyGraph width={Plan,1,bottom,left},mirror=2;wavestats/Q $fs_haldane;rangls = max(abs(V_max),abs(V_min));ModifyImage $fs_haldane ctab= {-rangls,rangls,:Packages:NewColortable:dvg_seismic,0};Label left "\\Z16 A(ω = E\BF\M\Z16, k)"
	setActiveSubwindow ##;Display/HOST=#/W=(0.55,0.05,1,0.5);appendimage $cut_haldane;ModifyGraph width={Plan,1,bottom,left},mirror=2;ModifyImage $cut_haldane ctab= {*,*,VioletOrangeYellow,0};Label left "\\Z16 A(ω,k\\Bx\\M\\Z16,k\\By\\M\\Z16=0)"
	setActiveSubwindow ##;Display/HOST=#/W=(0,0.55,0.5,1);appendimage $bc_haldane1;ModifyGraph width={Plan,1,bottom,left},mirror=2;ModifyImage $bc_haldane1 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0};Label left "\\Z16 Ω(k,i=1\Z16) \Z10[Lower Band]"
	setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.55,1,1);appendimage $bc_haldane2;ModifyGraph width={Plan,1,bottom,left},mirror=2;ModifyImage $bc_haldane2 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0};Label left "\\Z16 Ω(k,i=2\Z16) \Z10[Higher Band]"
	setActiveSubwindow ##
	ckfig_child(winname(0,1))

	variable/G t1_haldane = t1
	variable/G t2_haldane = t2
	variable/G M_haldane = M
	variable/G phi_haldane = phi
	variable/G selfimg_haldane = selfimg
	SetVariable sett1_haldane win=haldanemodelinteractive, title="t1",size={60,20},value=t1_haldane,limits={-inf,inf,0.1},proc=SetVarProc_haldane
	SetVariable sett2_haldane win=haldanemodelinteractive, title="t2",size={60,20},value=t2_haldane,limits={-inf,inf,0.1},proc=SetVarProc_haldane
	SetVariable setM_haldane win=haldanemodelinteractive, title="M",size={60,20},value=M_haldane,limits={-inf,inf,0.1},proc=SetVarProc_haldane
	SetVariable setphi_haldane win=haldanemodelinteractive, title="phi",size={100,20},value=phi_haldane,limits={-inf,inf,0.1},proc=SetVarProc_haldane
	SetVariable setselfimg_haldane win=haldanemodelinteractive, title="Im(Σ)",size={100,20},value=selfimg_haldane,limits={-inf,inf,0.05},proc=SetVarProc_haldane
	variable/G onoroffBCFS_haldane = 0
	SetVariable setonoroffBCFS_haldane win=haldanemodelinteractive, title="Update",size={60,20},value=onoroffBCFS_haldane,limits={0,1,1},proc=SetVarProc_haldane

	variable/G HQBCFS_haldane = 0
	SetVariable setHQBCFS_haldane win=haldanemodelinteractive, title="HQ",size={60,20},value=HQBCFS_haldane,limits={0,1,1},proc=SetVarProc_haldane

	//variable/G Chern_H1
	//variable/G Chern_H2
	ValDisplay valdispH1 title="Chern Number",pos={420,320},size={100,20},value=ShrinkDigit(Chern_H1,1)
	ValDisplay valdispH2 title="Chern Number",pos={110,320},size={100,20},value=ShrinkDigit(Chern_H2,1)
end

//** #02 Interactive Link
Function SetVarProc_haldane(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G t1_haldane
	variable/G t2_haldane
	variable/G M_haldane
	variable/G phi_haldane
	variable/G selfimg_haldane
	variable/G onoroffBCFS_haldane
	variable/G HQBCFS_haldane

	variable times
	if (HQBCFS_haldane == 0)
		times = 20
	else
		times = 100
	endif

	Cons_Haldanecut(t1_haldane,t2_haldane,M_haldane,phi_haldane,selfimg_haldane,200)

	if (onoroffBCFS_haldane == 0)
	else
		Cons_HaldaneFS(t1_haldane,t2_haldane,M_haldane,phi_haldane,selfimg_haldane,times-5)
		cons_HaldaneBC(t1_haldane,t2_haldane,M_haldane,phi_haldane,times)
	endif

end

//** #03 Functional: make Fermi surface
Function Cons_HaldaneFS(t1,t2,M,phi,selfimg,numxy)
	variable t1 //= 1
	variable t2 //= 0
	variable M //= 0.2
	variable phi //= 0.2*pi
	variable selfimg
	variable numxy //= 100

	//** Make void matrix for FS
	make/o/n=(numxy,numxy) fs_haldane
	setscale/i x,-3,3,"",fs_haldane
	setscale/i y,-3,3,"",fs_haldane
	fs_haldane = 0


	//** Make void matrix
	//make/o/n=(numxy,1000) cut_haldane
	//setscale/i x,-3,3,"",cut_haldane
	//setscale/i y,-4.5,4.5,"",cut_haldane
	//cut_haldane = 0

	//variable roff = dimoffset(cut_haldane,1)
	//variable rdelta = dimdelta(cut_haldane,1)


	//** Variable for Spectral Function
	variable i,j,selfreal,t
	selfreal = 0
	variable kx
	variable ky

	//** Pointer String for called Functions
	string W_eigenvalues="W_eigenvalues"
	string HaldaneH = "HaldaneH"

	//** Start loop for (kx, ky)
	i=0
	do
		j=0
		do
			//** Define kx, ky by void matrix shape
				kx = dimoffset(fs_haldane,0)+i*dimdelta(fs_haldane,0)
				ky = dimoffset(fs_haldane,1)+j*dimdelta(fs_haldane,1)

				HaldaneModel(t1,t2,M,phi,kx,ky)
				wave/C HaldaneHw = $HaldaneH

			//** Solve eigenvalue of Haldane Hamiltonian

				matrixEigenV HaldaneHw
				wave/C n=$W_eigenvalues
				make/n=(dimsize(HaldaneHw,0))/o sorteigen

				sorteigen[0]= real(N[0])
				sorteigen[1]= real(N[1])

			//Make 3D Spectral Function
				t=0
				do
					fs_haldane[i][j][]+=(-1/pi)*selfimg/(selfimg^2+((0)-selfreal-sorteigen[t])^2)

					//cut_haldane[i][]+=(-1/pi)*selfimg/(selfimg^2+((roff+q*rdelta)-selfreal-sorteigen[t])^2)
					t+=1
				while (t < dimsize(sorteigen,0))

			j+=1
		while(j < dimsize(fs_haldane,1))
		i+=1
	while(i < dimsize(fs_haldane,0))
	killwaves HaldaneHw sorteigen n
	//di(fs_haldane)
	//di(cut_haldane)
end

//** #04 Functional: make band dispersion cut
Function Cons_Haldanecut(t1,t2,M,phi,selfimg,numxy)
	variable t1 //= 1
	variable t2 //= 0
	variable M //= 0.2
	variable phi //= 0.2*pi
	variable selfimg
	variable numxy //= 100

	//** Make void matrix for spectral function
	make/o/n=(numxy,500) cut_haldane
	setscale/i x,-3,3,"",cut_haldane
	setscale/i y,-4.5,4.5,"",cut_haldane
	cut_haldane = 0
	variable roff = dimoffset(cut_haldane,1)
	variable rdelta = dimdelta(cut_haldane,1)

	//** Variable for Spectral Function
	variable i,j,selfreal,t
	selfreal = 0
	variable kx
	variable ky = 0

	//** Pointer String for called Functions
	string W_eigenvalues="W_eigenvalues"
	string HaldaneH = "HaldaneH"

	//** Start loop for (kx)
	i=0
	do

			//** Define kx, ky by void matrix shape
				kx = dimoffset(cut_haldane,0)+i*dimdelta(cut_haldane,0)

				HaldaneModel(t1,t2,M,phi,kx,ky)
				wave/C HaldaneHw = $HaldaneH

			//** Solve eigenvalue of Haldane Hamiltonian

				matrixEigenV HaldaneHw
				wave/C n=$W_eigenvalues
				make/n=(dimsize(HaldaneHw,0))/o sorteigen

				sorteigen[0]= real(N[0])
				sorteigen[1]= real(N[1])

			//Make 3D Spectral Function
				t=0
				do
					cut_haldane[i][]+=(-1/pi)*selfimg/(selfimg^2+((roff+q*rdelta)-selfreal-sorteigen[t])^2)
					t+=1
				while (t < dimsize(sorteigen,0))

		i+=1
	while(i < dimsize(cut_haldane,0)	)
	killwaves HaldaneHw sorteigen n

	//di(cut_haldane)
end

//** #05 Functional: Calculate Berry curvature
Function cons_HaldaneBC(t1,t2,M,phi,numxy)
	variable t1 //= 1
	variable t2 //= 0.2
	variable M //= 0.2
	variable phi //= 0.2*pi
	variable numxy //= 100

	variable kx
	variable ky
	variable i,j

	//** Make void matrix for spectral function
		make/o/n=(numxy,numxy,1) voidberry_haldane
		setscale/i x,-3,3,"",voidberry_haldane
		setscale/i y,-3,3,"",voidberry_haldane
		//setscale/i z,-2.5,4.5,"",voidberry_haldane
		voidberry_haldane = 0

	//** Make void matrix for Berry curvature band #1 (lower) and #2 (higher)
		make/o/n=(numxy,numxy) BC_haldane1
		setscale/i x,-3,3,"",BC_haldane1
		setscale/i y,-3,3,"",BC_haldane1
		BC_haldane1 = 0//cmplx(0,0)

		make/o/n=(numxy,numxy) BC_haldane2
		setscale/i x,-3,3,"",BC_haldane2
		setscale/i y,-3,3,"",BC_haldane2
		BC_haldane2 = 0//cmplx(0,0)

	//** Pointer String for called Functions
		string W_eigenvalues="W_eigenvalues"
		string HaldaneH = "HaldaneH"
		string M_R_eigenVectors = "M_R_eigenVectors"
		string M_product = "M_product"

	//** variable for Berry curvature
		variable E1k, E2K //1 for low band, 2 for high band
		variable delta = 10^-6
		variable/C Berryterm1A = cmplx(0,0)
		variable/C Berryterm1B = cmplx(0,0)

		variable/C Berryterm2A = cmplx(0,0)
		variable/C Berryterm2B = cmplx(0,0)

	//** Start loop for (kx, ky)
		i=0
		do
			j=0
			do
				//** Define kx, ky by void matrix shape
					kx = dimoffset(voidberry_haldane,0)+i*dimdelta(voidberry_haldane,0)
					ky = dimoffset(voidberry_haldane,1)+j*dimdelta(voidberry_haldane,1)

					HaldaneModel(t1,t2,M,phi,kx,ky)
					wave/C HaldaneHw = $HaldaneH

				//** Solve eigenvalue of Haldane Hamiltonian

					matrixEigenV/R HaldaneHw
					wave/C n=$W_eigenvalues
					wave/C eignevector=$M_R_eigenVectors

					make/n=(dimsize(HaldaneHw,0))/o sorteigen

					sorteigen[0]= real(N[0])
					sorteigen[1]= real(N[1])

				//**Sort eigenvalue and eigenvector
					make/o/n=(dimsize(HaldaneHw,0)) sortindex
					sortindex=p
					sort sorteigen sortindex //the value indicates the column number in M_R_eigenVectors belong to each eigenvalue labeled in sorteigen
					sort sorteigen sorteigen

				//** Calculat Berry Curvature

					//## E1,k = sorteigen[0]
					//## |u1,k> = eignevector[][sortindex[0]]

					//## E2,k = sorteigen[1]
					//## |u2,k> = eignevector[][sortindex[1]]


					//** get eigenvalue
						E1k = sorteigen[0]
						E2k = sorteigen[1]

					//** make |u1,k>
						//|ket>
						make/n=(dimsize(HaldaneHw,0),1)/o/C u1k_ket
						u1k_ket[] = eignevector[p][sortindex[0]]
						//<bra|
						duplicate/o/c u1k_ket u1k_bra
						matrixtranspose/H u1k_bra

					//** make |u2,k>
						//|ket>
						make/n=(dimsize(HaldaneHw,0),1)/o/C u2k_ket
						u2k_ket[] = eignevector[p][sortindex[1]]
						//<bra|
						duplicate/o/c u2k_ket u2k_bra
						matrixtranspose/H u2k_bra

					//** make dH/dx(k)
						duplicate/o/c HaldaneHw HaldaneHworigin

						HaldaneModel(t1,t2,M,phi,kx+delta,ky)
						wave/C HaldaneHw = $HaldaneH
						duplicate/o/c HaldaneHw dHdx
						dHdx = (HaldaneHw - HaldaneHworigin)/delta

					//** make dH/dy(k)
						HaldaneModel(t1,t2,M,phi,kx,ky+delta)
						wave/C HaldaneHw = $HaldaneH
						duplicate/o/c HaldaneHw dHdy
						dHdy = (HaldaneHw - HaldaneHworigin)/delta

					//** calculate Omega_1

						matrixMultiply u1k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm1A =  M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1A *= M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm1B =  M_productw[0][0]

						matrixMultiply u2k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1B *=  M_productw[0][0]

						Berryterm1A -= Berryterm1B
						Berryterm1A /= (E1k-E2k)^2
						Berryterm1A *= cmplx(0,1)

						//BC_haldane1[i][j] = sqrt(magsqr(Berryterm1A))
						BC_haldane1[i][j] = real(Berryterm1A)

					//** calculate Omega_2

						matrixMultiply u2k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm2A =  M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2A *= M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm2B =  M_productw[0][0]

						matrixMultiply u1k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2B *=  M_productw[0][0]

						Berryterm2A -= Berryterm2B
						Berryterm2A /= (E1k-E2k)^2
						Berryterm2A *= cmplx(0,1)

						//BC_haldane2[i][j] = sqrt(magsqr(Berryterm2A))
						BC_haldane2[i][j] = real(Berryterm2A)

				j+=1
			while(j < dimsize(voidberry_haldane,1))
			i+=1
		while(i < dimsize(voidberry_haldane,0))

	//Calculate Chern Number
		variable/G Chern_H1 = ChernN_haldane(BC_haldane1)
		variable/G Chern_H2 = ChernN_haldane(BC_haldane2)

	killwaves voidberry_haldane n sorteigen eignevector sortindex u1k_ket u1k_bra u2k_ket u2k_bra dHdx dHdy HaldaneHworigin HaldaneHw M_productw
end

//** #06 Shrink digit
Function ShrinkDigit(value, numSigDigits)
    variable value, numSigDigits
    string str
    sprintf str, "%.*g\r", numSigDigits, value
    return str2num(str)
End

//** #07 Calculate Chern number
Function ChernN_haldane(BCname)
	wave BCname
	variable left = -4*sqrt(3)*pi/9
	variable right = 2*sqrt(3)*pi/9
	variable top = 2*pi/3
	variable bottom = -2*pi/3


	variable nleft = round((left-dimoffset(BCname,0))/dimdelta(BCname,0))
	variable nright = round((right-dimoffset(BCname,0))/dimdelta(BCname,0))
	variable ntop = round((top-dimoffset(BCname,1))/dimdelta(BCname,1))
	variable nbottom = round((bottom-dimoffset(BCname,1))/dimdelta(BCname,1))

	variable Sumbc = 0

	variable i,j
	i=nleft
	do
		j=nbottom
		do
			Sumbc+=BCname[i][j]
			j+=1
		while (j < ntop) // [nbottom,ntop)
		i+=1
	while (i < nright) //[nleft,nright), nleft included, but nright excluded
	variable Chernnumber

	Chernnumber = Sumbc*dimdelta(BCname,1)*dimdelta(BCname,0)/(2*pi)
	//print Chernnumber
	return Chernnumber
end

//** #08 A different method for calculating Berry Curvature, but it is slower
//ref: Journal of the Physical Society of Japan, 2005, 74(6): 1674-1677.
//ref: https://mp.weixin.qq.com/s/zhyowoXSP91H3xYdByNDEQ
Function HaldaneBCFukui(t1,t2,M,phi,numxy)
	variable t1 //= 1
	variable t2 //= 0.2
	variable M //= 0.2
	variable phi //= 0.2*pi
	variable numxy //= 100

	variable kx
	variable ky
	variable i,j

	Variable timerRefNum
	timerRefNum = StartMSTimer
	//** Make void matrix for spectral function
		make/o/n=(numxy,numxy,1) voidberry_haldane
		setscale/i x,-3,3,"",voidberry_haldane
		setscale/i y,-3,3,"",voidberry_haldane
		//setscale/i z,-2.5,4.5,"",voidberry_haldane
		voidberry_haldane = 0

	//** Make void matrix for Berry curvature band #1 (lower) and #2 (higher)
		make/o/n=(numxy,numxy) BC_haldane1
		setscale/i x,-3,3,"",BC_haldane1
		setscale/i y,-3,3,"",BC_haldane1
		BC_haldane1 = 0//cmplx(0,0)

		make/o/n=(numxy,numxy) BC_haldane2
		setscale/i x,-3,3,"",BC_haldane2
		setscale/i y,-3,3,"",BC_haldane2
		BC_haldane2 = 0//cmplx(0,0)

	//** Pointer String for called Functions
		string W_eigenvalues="W_eigenvalues"
		string HaldaneH = "HaldaneH"
		string M_R_eigenVectors = "M_R_eigenVectors"
		string M_product = "M_product"

	//** variable for Berry curvature

		variable/C Berry1 = cmplx(0,0)

		variable/C Berry2 = cmplx(0,0)

		variable/C Uxx1, Uxy1, Uyx1, Uyy1
		variable normUxx1,normUxy1,normUyx1,normUyy1

		variable/C Uxx2, Uxy2, Uyx2, Uyy2
		variable normUxx2,normUxy2,normUyx2,normUyy2
		variable dxdy = (dimdelta(voidberry_haldane,1)*dimdelta(voidberry_haldane,0))

	//** Start loop for (kx, ky)
		i=0
		do
			j=0
			do
				//** Define kx, ky by void matrix shape
					kx = dimoffset(voidberry_haldane,0)+i*dimdelta(voidberry_haldane,0)
					ky = dimoffset(voidberry_haldane,1)+j*dimdelta(voidberry_haldane,1)

				// (kx,ky)
					HaldaneModel(t1,t2,M,phi,kx,ky)
					wave/C HaldaneHw = $HaldaneH
					matrixEigenV/R HaldaneHw
					wave/C n=$W_eigenvalues
					wave/C eignevector=$M_R_eigenVectors
					make/n=(dimsize(HaldaneHw,0))/o sorteigen
					sorteigen[0]= real(N[0])
					sorteigen[1]= real(N[1])
					make/o/n=(dimsize(HaldaneHw,0)) sortindex
					sortindex=p
					sort sorteigen sortindex //the value indicates the column number in M_R_eigenVectors belong to each eigenvalue labeled in sorteigen
					sort sorteigen sorteigen
					//** make |u1,k>
						//|ket>
						make/n=(dimsize(HaldaneHw,0),1)/o/C u1k_ket
						u1k_ket[] = eignevector[p][sortindex[0]]
						//<bra|
						duplicate/o/c u1k_ket u1k_bra
						matrixtranspose/H u1k_bra
					//** make |u2,k>
						//|ket>
						make/n=(dimsize(HaldaneHw,0),1)/o/C u2k_ket
						u2k_ket[] = eignevector[p][sortindex[1]]
						//<bra|
						duplicate/o/c u2k_ket u2k_bra
						matrixtranspose/H u2k_bra

				// (kx+d,ky)
					HaldaneModel(t1,t2,M,phi,kx+dimdelta(voidberry_haldane,0),ky)
					wave/C HaldaneHw = $HaldaneH
					matrixEigenV/R HaldaneHw
					wave/C n=$W_eigenvalues
					wave/C eignevector=$M_R_eigenVectors
					make/n=(dimsize(HaldaneHw,0))/o sorteigen
					sorteigen[0]= real(N[0])
					sorteigen[1]= real(N[1])
					make/o/n=(dimsize(HaldaneHw,0)) sortindex
					sortindex=p
					sort sorteigen sortindex //the value indicates the column number in M_R_eigenVectors belong to each eigenvalue labeled in sorteigen
					sort sorteigen sorteigen
					//** make |u1,k+dx>
						//|ket>
						make/n=(dimsize(HaldaneHw,0),1)/o/C u1kdx_ket
						u1kdx_ket[] = eignevector[p][sortindex[0]]
						//<bra|
						duplicate/o/c u1kdx_ket u1kdx_bra
						matrixtranspose/H u1kdx_bra
					//** make |u2,k+dx>
						//|ket>
						make/n=(dimsize(HaldaneHw,0),1)/o/C u2kdx_ket
						u2kdx_ket[] = eignevector[p][sortindex[1]]
						//<bra|
						duplicate/o/c u2kdx_ket u2kdx_bra
						matrixtranspose/H u2kdx_bra

				// (kx,ky+d)
					HaldaneModel(t1,t2,M,phi,kx,ky+dimdelta(voidberry_haldane,1))
					wave/C HaldaneHw = $HaldaneH
					matrixEigenV/R HaldaneHw
					wave/C n=$W_eigenvalues
					wave/C eignevector=$M_R_eigenVectors
					make/n=(dimsize(HaldaneHw,0))/o sorteigen
					sorteigen[0]= real(N[0])
					sorteigen[1]= real(N[1])
					make/o/n=(dimsize(HaldaneHw,0)) sortindex
					sortindex=p
					sort sorteigen sortindex //the value indicates the column number in M_R_eigenVectors belong to each eigenvalue labeled in sorteigen
					sort sorteigen sorteigen
					//** make |u1,k+dy>
						//|ket>
						make/n=(dimsize(HaldaneHw,0),1)/o/C u1kdy_ket
						u1kdy_ket[] = eignevector[p][sortindex[0]]
						//<bra|
						duplicate/o/c u1kdy_ket u1kdy_bra
						matrixtranspose/H u1kdy_bra
					//** make |u2,k+dy>
						//|ket>
						make/n=(dimsize(HaldaneHw,0),1)/o/C u2kdy_ket
						u2kdy_ket[] = eignevector[p][sortindex[1]]
						//<bra|
						duplicate/o/c u2kdy_ket u2kdy_bra
						matrixtranspose/H u2kdy_bra

				// (kx+d,ky+d)
					HaldaneModel(t1,t2,M,phi,kx+dimdelta(voidberry_haldane,0),ky+dimdelta(voidberry_haldane,1))
					wave/C HaldaneHw = $HaldaneH
					matrixEigenV/R HaldaneHw
					wave/C n=$W_eigenvalues
					wave/C eignevector=$M_R_eigenVectors
					make/n=(dimsize(HaldaneHw,0))/o sorteigen
					sorteigen[0]= real(N[0])
					sorteigen[1]= real(N[1])
					make/o/n=(dimsize(HaldaneHw,0)) sortindex
					sortindex=p
					sort sorteigen sortindex //the value indicates the column number in M_R_eigenVectors belong to each eigenvalue labeled in sorteigen
					sort sorteigen sorteigen
					//** make |u1,k+(dx,dy)>
						//|ket>
						make/n=(dimsize(HaldaneHw,0),1)/o/C u1kdxdy_ket
						u1kdxdy_ket[] = eignevector[p][sortindex[0]]
						//<bra|
						duplicate/o/c u1kdxdy_ket u1kdxdy_bra
						matrixtranspose/H u1kdxdy_bra
					//** make |u2,k+(dx,dy)>
						//|ket>
						make/n=(dimsize(HaldaneHw,0),1)/o/C u2kdxdy_ket
						u2kdxdy_ket[] = eignevector[p][sortindex[1]]
						//<bra|
						duplicate/o/c u2kdxdy_ket u2kdxdy_bra
						matrixtranspose/H u2kdxdy_bra

				//Uxx1
					matrixMultiply u1k_bra,u1kdx_ket
					wave/C M_productw = $M_product
					normuxx1 = abs(sqrt(real(M_productw[0][0])^2+imag(M_productw[0][0])^2))
					Uxx1 = M_productw[0][0]/normuxx1

				//Uxy1
					matrixMultiply u1kdy_bra,u1kdxdy_ket
					wave/C M_productw = $M_product
					normUxy1 = abs(sqrt(real(M_productw[0][0])^2+imag(M_productw[0][0])^2))
					Uxy1 = M_productw[0][0]/normuxy1

				//Uyx1
					matrixMultiply u1kdx_bra,u1kdxdy_ket
					wave/C M_productw = $M_product
					normUyx1 = abs(sqrt(real(M_productw[0][0])^2+imag(M_productw[0][0])^2))
					Uyx1 = M_productw[0][0]/normuyx1

				//Uyy1
					matrixMultiply u1k_bra,u1kdy_ket
					wave/C M_productw = $M_product
					normuyy1 = abs(sqrt(real(M_productw[0][0])^2+imag(M_productw[0][0])^2))
					Uyy1 = M_productw[0][0]/normuyy1

				//Uxx2
					matrixMultiply u2k_bra,u2kdx_ket
					wave/C M_productw = $M_product
					normuxx2 = abs(sqrt(real(M_productw[0][0])^2+imag(M_productw[0][0])^2))
					Uxx2 = M_productw[0][0]/normuxx2

				//Uxy2
					matrixMultiply u2kdy_bra,u2kdxdy_ket
					wave/C M_productw = $M_product
					normUxy2 = abs(sqrt(real(M_productw[0][0])^2+imag(M_productw[0][0])^2))
					Uxy2 = M_productw[0][0]/normuxy2

				//Uyx2
					matrixMultiply u2kdx_bra,u2kdxdy_ket
					wave/C M_productw = $M_product
					normUyx2 = abs(sqrt(real(M_productw[0][0])^2+imag(M_productw[0][0])^2))
					Uyx2 = M_productw[0][0]/normuyx2

				//Uyy2
					matrixMultiply u2k_bra,u2kdy_ket
					wave/C M_productw = $M_product
					normuyy2 = abs(sqrt(real(M_productw[0][0])^2+imag(M_productw[0][0])^2))
					Uyy2 = M_productw[0][0]/normuyy2

				//** calculate Omega_1
					Berry1 = ln(Uxx1*Uyx1/(Uxy1*Uyy1))*cmplx(0,1)/dxdy
					BC_haldane1[i][j] = real(Berry1)

				//** calculate Omega_2
					Berry2 = ln(Uxx2*Uyx2/(Uxy2*Uyy2))*cmplx(0,1)/dxdy
					BC_haldane2[i][j] = real(Berry2)

				j+=1
			while(j < dimsize(voidberry_haldane,1))
			i+=1
		while(i < dimsize(voidberry_haldane,0))
	killwaves voidberry_haldane n sorteigen eignevector sortindex u1k_ket u1k_bra u2k_ket u2k_bra  HaldaneHw M_productw u1kdx_ket u1kdy_ket u1kdxdy_ket u1kdx_bra u1kdy_bra u1kdxdy_bra u2kdx_ket u2kdy_ket u2kdxdy_ket u2kdx_bra u2kdy_bra u2kdxdy_bra
	di(BC_haldane1)
	ModifyImage BC_haldane1 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0}
	di(BC_haldane2)
	ModifyImage BC_haldane2 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0}
	Print "//*************************************                "
	Print "		The parameters (t1,t2,M,phi) are ("+num2str(t1)+","+num2str(t2)+","+num2str(M)+","+num2str(phi)+")"
	Print "		Chern Number for band #1 is "+num2str(ChernN_haldane(BC_haldane1))
	Print "		Chern Number for band #2 is "+num2str(ChernN_haldane(BC_haldane2))

	variable Seconds = StopMSTimer(timerRefNum)/10^6
	Print "		Total Time Running: "+num2str(Seconds)+" (s)"
end


///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
//****************************** Simulate Landau Level ************************************
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
//                                                                                        /                                                                                        //
//           Landau level prediction.    valid when 2D dirac cone istropic.               /
//                                                                                        /                                                                                       //
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////

Function ButtonProc_predictLL(ctrlName) : ButtonControl
	String ctrlName
	Execute "calculateLLNewc()"
end

Proc calculateLLNewc(hv,B,ED,num)
	variable hv=4.4/0.025//fermi velocity  (meV*A)
	variable B=4// magnetic field (T)
	Variable ED=-4.4//Dirac point (meV)
	variable num=40
	prompt hv,"Fermi velocity (meV*A)"
	prompt B,"Magnetic Field (T)"
	prompt ED,"Binding Energy of Dirac Point (meV)"
	prompt num,"number of levels"
	calculateLLNew(hv,B,ED,num)
end


Function calculateLLNew(hv,B,ED,num)
	variable hv//=4.4/0.025//fermi velocity  (meV*A)
	variable B//=4// magnetic field (T)
	Variable ED//=-4.4//Dirac point (meV)
	variable num//=40
	//prompt hv,"Fermi velocity (meV*A)"
	//prompt B,"Magnetic Field (T)"
	//prompt ED,"Binding Energy of Dirac Point (meV)"
	//prompt num,"number of levels"

	variable e,hbar

	e=1.6*10^-19
	hbar=6.626*10^-34/(2*pi)

	string nameE, namek, namemk, namemE
	nameE="DiracLLE"
	nameK="DiracLLK"
	namemk="DiracLLmK"
	namemE="DiracLLmE"

	make/o/n=(num) energy // energy level from dirac point.
	make/o/n=(num) kn
	make/o/n=(num) minuskn
	make/o/n=(num) minusenergy


	kn=sqrt(2*e*B*p/hbar)*10^-10 // A^-1
	energy=ED+hv*sqrt(2*e*B*p/hbar)*10^-10
	minuskn=-kn
	minusenergy=ED-hv*sqrt(2*e*B*p/hbar)*10^-10
	duplicate/o kn $namek
	duplicate/o minuskn $namemk
	duplicate/o energy $nameE
	duplicate/o minusenergy $namemE
	wave nameEw = $nameE
	wave namemEw = $namemE
	wave nameKw = $nameK
	wave namemKw = $namemK

	display nameEw vs namekw
	appendtograph nameEw vs namemkw
	appendtograph namemEw vs namekw
	appendtograph namemEw vs namemkw
	ModifyGraph mode=3,marker=8,msize=3
	Label left "\\Z22\\F'times'\\f02E - E\\BF\\f00\\M\\F'times'\\Z22 (meV)"
	Label bottom "\\Z22\\F'times'Momentum (Å\\S-1\\M\\F'times'\\Z22)"
	Label bottom "\\Z22\\F'times'Momentum (Å\\S-1\\M\\F'times'\\Z22)"
	ModifyGraph tick=2,mirror=2,zero(left)=8
	ModifyGraph zero(bottom)=10
	ModifyGraph height=400, width=280
	if (ED >= 0)
		duplicate/o namemEw temmE
		temmE = abs(namemEw)
		wavestats/Q temmE
		TextBox/C/N=text0/F=0/A=MT/X=0.00/Y=0.00 "\\Z14\\F'Times New Roman Bold'"+"Field: "+num2str(B)+"T\r"+"Velocity: "+num2str(hv)+"meV*A\r"+"1LL Space: "+num2str(energy[1]-energy[0])+"meV\r"+"2LL Space: "+num2str(energy[2]-energy[1])+"meV\rE\Bg\M\Z14(E\BF\M\Z14)="+num2str(abs(namemEw[V_minloc-1]-namemEw[V_minloc+1])/2)+" meV"
	endif

	if (ED < 0)
		duplicate/o nameEw temmE
		temmE = abs(nameEw)
		wavestats/Q temmE
		TextBox/C/N=text0/F=0/A=MT/X=0.00/Y=0.00 "\\Z14\\F'Times New Roman Bold'"+"Field: "+num2str(B)+"T\r"+"Velocity: "+num2str(hv)+"meV*A\r"+"1LL Space: "+num2str(energy[1]-energy[0])+"meV\r"+"2LL Space: "+num2str(energy[2]-energy[1])+"meV\rE\Bg\M\Z14(E\BF\M\Z14)="+num2str(abs(nameEw[V_minloc-1]-nameEw[V_minloc+1])/2)+" meV"
	endif
	killwaves temmE energy kn minuskn minusenergy
	//edit $nameE

	variable/G hv_DiracLL = hv
	variable/G B_DiracLL = B
	variable/G ED_DiracLL = ED
	variable/G num_DiracLL = num

	ModifyGraph margin(top)=30
	SetVariable sethv_DiracLLhv title="Velocity (meV*A)",size={130,14},value=hv_DiracLL,limits={-inf,inf,10},proc=SetVarProc_DiracLL
	SetVariable sethv_DiracLLB title="B (T)",size={80,20},value=B_DiracLL,limits={-inf,inf,0.1},proc=SetVarProc_DiracLL
	SetVariable sethv_DiracLLED title="E\BD\M (meV)",size={100,20},value=ED_DiracLL,limits={-inf,inf,1},proc=SetVarProc_DiracLL
	SetVariable sethv_DiracLLnum title="Num",size={80,20},value=num_DiracLL,limits={0,inf,10},proc=SetVarProc_DiracLL

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

Function SetVarProc_DiracLL(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G hv_DiracLL
	variable/G B_DiracLL
	variable/G ED_DiracLL
	variable/G num_DiracLL

	calculateLLNewcons(hv_DiracLL,B_DiracLL,ED_DiracLL,num_DiracLL)
end

Function calculateLLNewcons(hv,B,ED,num)
	variable hv//=4.4/0.025//fermi velocity  (meV*A)
	variable B//=4// magnetic field (T)
	Variable ED//=-4.4//Dirac point (meV)
	variable num//=40
	//prompt hv,"Fermi velocity (meV*A)"
	//prompt B,"Magnetic Field (T)"
	//prompt ED,"Binding Energy of Dirac Point (meV)"
	//prompt num,"number of levels"

	variable e,hbar

	e=1.6*10^-19
	hbar=6.626*10^-34/(2*pi)

	string nameE, namek, namemk, namemE
	nameE="DiracLLE"
	nameK="DiracLLK"
	namemk="DiracLLmK"
	namemE="DiracLLmE"

	make/o/n=(num) energy // energy level from dirac point.
	make/o/n=(num) kn
	make/o/n=(num) minuskn
	make/o/n=(num) minusenergy


	kn=sqrt(2*e*B*p/hbar)*10^-10 // A^-1
	energy=ED+hv*sqrt(2*e*B*p/hbar)*10^-10
	minuskn=-kn
	minusenergy=ED-hv*sqrt(2*e*B*p/hbar)*10^-10
	duplicate/o kn $namek
	duplicate/o minuskn $namemk
	duplicate/o energy $nameE
	duplicate/o minusenergy $namemE
	wave nameEw = $nameE
	wave namemEw = $namemE
	wave nameKw = $nameK
	wave namemKw = $namemK

	if (ED >= 0)
		duplicate/o namemEw temmE
		temmE = abs(namemEw)
		wavestats/Q temmE
		TextBox/C/N=text0/F=0/A=MT/X=0.00/Y=0.00 "\\Z14\\F'Times New Roman Bold'"+"Field: "+num2str(B)+"T\r"+"Velocity: "+num2str(hv)+"meV*A\r"+"1LL Space: "+num2str(energy[1]-energy[0])+"meV\r"+"2LL Space: "+num2str(energy[2]-energy[1])+"meV\rE\Bg\M\Z14(E\BF\M\Z14)="+num2str(abs(namemEw[V_minloc-1]-namemEw[V_minloc+1])/2)+" meV"
	endif

	if (ED < 0)
		duplicate/o nameEw temmE
		temmE = abs(nameEw)
		wavestats/Q temmE
		TextBox/C/N=text0/F=0/A=MT/X=0.00/Y=0.00 "\\Z14\\F'Times New Roman Bold'"+"Field: "+num2str(B)+"T\r"+"Velocity: "+num2str(hv)+"meV*A\r"+"1LL Space: "+num2str(energy[1]-energy[0])+"meV\r"+"2LL Space: "+num2str(energy[2]-energy[1])+"meV\rE\Bg\M\Z14(E\BF\M\Z14)="+num2str(abs(nameEw[V_minloc-1]-nameEw[V_minloc+1])/2)+" meV"
	endif
	killwaves temmE energy kn minuskn minusenergy
	//edit $nameE
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

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
//
//   The procedure bellow is to calculate LL DOS within different Temperature and Field
//            Simple model regard LL peak as a Lorentzian, and add them all
//
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

Function ButtonProc_LLDOS(ctrlName) : ButtonControl
	String ctrlName
	Execute " makeLLspectra()"
end

proc makeLLspectra(hv,ED,tem,num,field,ER)
	variable hv=6000//4.4/0.025//fermi velocity  (meV*A)
	Variable ED=0//Dirac point (meV)
	variable tem=3//K
	variable num=300
	variable field=11//T
	variable ER=200 //meV
	prompt hv,"Fermi velocity (meV*A)"
	//prompt B,"Magnetic Field (T)"
	prompt ED,"Binding Energy of Dirac Point (meV)"
	prompt tem,"Temperature of the system (K)"
	prompt num,"number of levels"
	prompt field,"Field Range: (1 to ?)T"
	Prompt ER,"Energe range of spectrum (meV)"
	makeLLspectraf(hv,ED,tem,num,field,ER)
end
Function makeLLspectraf(hv,ED,tem,num,field,ER)
	variable hv//=6000//4.4/0.025//fermi velocity  (meV*A)
	Variable ED//=0//Dirac point (meV)
	variable tem//=3//K
	variable num//=300
	variable field//=11//T
	variable ER//=200 //meV
	prompt hv,"Fermi velocity (meV*A)"
	//prompt B,"Magnetic Field (T)"
	prompt ED,"Binding Energy of Dirac Point (meV)"
	prompt tem,"Temperature of the system (K)"
	prompt num,"number of levels"
	prompt field,"Field Range: (1 to ?)T"
	Prompt ER,"Energe range of spectrum (meV)"
	//Doprompt
	variable i,B,index
	i=0
	index = 1
	do
		B=i+0.01
		madelldos(hv,B,ED,tem,num,ER,index)
		i+=0.01
		index+=1
	while (i<field)
	string lladd
	lladd="llpure"+"_"+num2str(tem)+"K"
	//print "llpure"+"_"+num2str(tem)+"K"
	//displaymulti(lladd,1,index)
	//print index
	linkstsmapno(lladd,index-1,1)
	wave mapsts=$"mapsts"
	duplicate/o mapsts $lladd
	killwaves mapsts
	matrixtranspose $lladd
	di($lladd)
	wave energy = $"energy"
	wave minusenergy = $"minusenergy"
	killwaves energy minusenergy
	setscale/i x,0.01,field,"",$lladd
	Label bottom "\\Z16B (T)"
	Label Left "\\Z16Energy (meV)"
	variable ii=1
	string kkk
	do
		kkk = lladd+num2str(ii)
		killwaves $kkk
		ii+=1
	while(ii < index-1)

end

Function linkstsmapno(name,num,startnum)
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


Function madelldos(hv,B,ED,tem,num,ER,index)
	variable hv//=4.4/0.025//fermi velocity  (meV*A)
	variable B//=4// magnetic field (T)
	Variable ED//=-4.4//Dirac point (meV)
	variable tem//=15
	variable num//=100
	variable ER//=10 //meV
	variable index

	variable broad
	broad=tem*0.086*3.5
	//e=1.6*10^-19
	//hbar=6.626*10^-34/(2*pi)
	calculateLLall(hv,B,ED,num)
	wave energy = $"energy"
	wave minusenergy = $"minusenergy"
	string lladd//, LDOSb
	make/o/N=2000 LDOSb
	setscale/i x,ED-ER,ED+ER,"",LDOSb// Please change energe range here.
	lladd="llpure"+"_"+num2str(tem)+"K"+num2str(index)
	duplicate/o LDOSb $LLadd
	wave LLaddw = $LLadd
	LLaddw=0
	//normwave("LDOSb",ED-ER,ED+ER)
	variable mean_value=mean(LDOSb,ED-ER,ED+ER)
	LDOSb/=mean_value

	string mata,matb,mat
	mat="LL"+num2str(B)
	variable i
	i=0
	do
		mata="a"+num2str(B)+"_"+num2str(i)
		matb="b"+num2str(B)+"_"+num2str(i)
		duplicate/o LDOSb $mata
		duplicate/o LDOSb $matb
		wave mataw = $mata
		wave matbw = $matb

		mataw=(1/pi)*(broad/2)/((x-(energy[i]))^2+(broad/2)^2)
		matbw=(1/pi)*(broad/2)/((x-(minusenergy[i]))^2+(broad/2)^2)

		Lladdw+=mataw
		Lladdw+=matbw
		killwaves mataw matbw
		i+=1
	while(i<num)

	string mata0
	mata0="a"+num2str(B)+"_0"
	wave mata0w = $mata0
	//Lladdw-=mata0w

	wavestats/q lladdw
	lladdw/=V_max
	killwaves mata0w LDOSb
end

//////////////////////////////////////////////////////
Function calculateLLall(hv,B,ED,num)
	variable hv//=4.4/0.025//fermi velocity  (meV*A)
	variable B//=4// magnetic field (T)
	Variable ED//=-4.4//Dirac point (meV)
	variable num//=100
	variable e,hbar
	e=1.6*10^-19
	hbar=6.626*10^-34/(2*pi)
	make/o/n=(num) energy // energy level from dirac point.
	make/o/n=(num) minusenergy
	energy=ED+hv*sqrt(2*e*B*p/hbar)*10^-10
	minusenergy=ED-hv*sqrt(2*e*B*p/hbar)*10^-10
end
//////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
//**************************** Qi-Wu-Zhang Model ******************************************
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
//Ref: Duncan Haldane Phys. Rev. B 74, 085308 (2006)
//Ref: https://arxiv.org/abs/1509.02295
//Ref: https://www.weizmann.ac.il/condmat/oreg/sites/condmat.oreg/files/uploads/amittulchinskythesisfinal.pdf
Function/Wave QWZ(A,B,m,kx,ky,mu)
	variable A,B,m,kx,ky,mu

	//** Pointer String for called Functions
		string ps = "ps_QWZ"
		string result_C = "result_C"

	//** Create QHZ Hamiltonian
		variable pf1,pf2,pf3,pf4,pf5,pf6
		pf1 = A*sin(kx) //From A*kx; kx --> sin(kx)
		pf2 = A*sin(ky)
		pf3 = m+B*(2-cos(kx)-cos(ky)) //Tranform from m+B*(kx^2+ky^2); kx^2 --> 1-cos(kx)
		pf4 = -mu

		wC("pf1_QWZ",{{cmplx(pf1,0)}})
		wC("pf2_QWZ",{{cmplx(pf2,0)}})
		wC("pf3_QWZ",{{cmplx(pf3,0)}})
		wC("pf4_QWZ",{{cmplx(pf4,0)}})

		Wn("ps_QWZ",{{1},{2},{3},{0}})
		automatrixC("pf1_QWZ;pf2_QWZ;pf3_QWZ;pf4_QWZ",$ps)

		wave/C result_Cw = $result_C
		duplicate/C/o result_Cw QWZH
		killwaves $result_C $ps
	return QWZH
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
Function QWZSpectralFunction(A,B,m,mu,selfimg,numxy)
	variable A,B,m,mu
	variable selfimg
	variable numxy //= 100
	variable/G zn_cons = 2

	//** Make void matrix for spectral function
	make/o/n=(numxy,numxy,500) modelresult_QWZ
	setscale/i x,-pi,pi,"",modelresult_QWZ
	setscale/i y,-pi,pi,"",modelresult_QWZ
	setscale/i z,-3,3,"",modelresult_QWZ
	modelresult_QWZ = 0
	variable roff = dimoffset(modelresult_QWZ,2)
	variable rdelta = dimdelta(modelresult_QWZ,2)

	//** Variable for Spectral Function
	variable i,j,selfreal,t
	selfreal = 0
	variable kx
	variable ky

	//** Pointer String for called Functions
	string W_eigenvalues="W_eigenvalues"
	string QWZH = "QWZH"

	//** Start loop for (kx, ky)
	i=0
	do
		j=0
		do
			//** Define kx, ky by void matrix shape
				kx = dimoffset(modelresult_QWZ,0)+i*dimdelta(modelresult_QWZ,0)
				ky = dimoffset(modelresult_QWZ,1)+j*dimdelta(modelresult_QWZ,1)

				QWZ(A,B,m,kx,ky,mu)
				wave/C QWZHw = $QWZH

			//** Solve eigenvalue of QWZ Hamiltonian

				matrixEigenV QWZHw
				wave/C n=$W_eigenvalues
				make/n=(dimsize(QWZHw,0))/o sorteigen

				sorteigen[0]= real(N[0])
				sorteigen[1]= real(N[1])


			//Make 3D Spectral Function
				t=0
				do
					modelresult_QWZ[i][j][]+=(-1/pi)*selfimg/(selfimg^2+((roff+r*rdelta)-selfreal-sorteigen[t])^2)
					t+=1
				while (t < dimsize(sorteigen,0))

			j+=1
		while(j < dimsize(modelresult_QWZ,1))
		i+=1
	while(i < dimsize(modelresult_QWZ,0)	)

	//** Call smart 3D displayer
		duplicate/o modelresult_QWZ Z2_001
		//killwaves modelresult_QWZ sorteigen QWZHw n
		execute "d3d(\"Z2_001\",2)"

	//** Modify the 3D player for this special simulation use (band structure)
		variable/G divcolor_cons
		divcolor_cons = 1
		wavestats/Q $tpw()
		variable rangls = max(abs(V_max),abs(V_min))
		ModifyImage/W=$grabwinchild(tpw()) $tpw() ctab= {-rangls,rangls,:Packages:NewColortable:dvg_seismic,0};
		ColorScale/W=$grabwinchild(tpw())/C/N=textcc/X=-21.00/Y=5.00/F=0 heightPct=30,nticks=5,minor=1,tickLen=1.00,image=$tpw()//;ColorScale/W=$grabwinchild(Fexyd)/C/N=text0/F=0/A=MC/Y=-120 image=$Fexyd
		variable/G normornot_3dplot =2
		Button launchLinecut title="Linecut",size={65,14},fSize=10,proc=ButtonProc_Cons3dplotZ
end




Function QWZBerryCurvature(A,B,m,mu,numxy)
	variable A,B,m,mu
	variable numxy //= 100

	variable kx
	variable ky
	variable i,j

	Variable timerRefNum
	timerRefNum = StartMSTimer

	//** Make void matrix for spectral function
		make/o/n=(numxy,numxy,1) voidberry_QWZ
		setscale/i x,-pi,pi,"",voidberry_QWZ
		setscale/i y,-pi,pi,"",voidberry_QWZ
		//setscale/i z,-2.5,4.5,"",voidberry_QWZ
		voidberry_QWZ = 0

	//** Make void matrix for Berry curvature band #1 (lower) and #2 (higher)
		make/o/n=(numxy,numxy) BC_QWZ1
		setscale/i x,-pi,pi,"",BC_QWZ1
		setscale/i y,-pi,pi,"",BC_QWZ1
		BC_QWZ1 = 0//cmplx(0,0)

		make/o/n=(numxy,numxy) BC_QWZ2
		setscale/i x,-pi,pi,"",BC_QWZ2
		setscale/i y,-pi,pi,"",BC_QWZ2
		BC_QWZ2 = 0//cmplx(0,0)

	//** Pointer String for called Functions
		string W_eigenvalues="W_eigenvalues"
		string QWZH = "QWZH"
		string M_R_eigenVectors = "M_R_eigenVectors"
		string M_product = "M_product"

	//** variable for Berry curvature
		variable E1k, E2K //1 for low band, 2 for high band
		variable delta = 10^-6
		variable/C Berryterm1A = cmplx(0,0)
		variable/C Berryterm1B = cmplx(0,0)

		variable/C Berryterm2A = cmplx(0,0)
		variable/C Berryterm2B = cmplx(0,0)

	//** Start loop for (kx, ky)
		i=0
		do
			j=0
			do
				//** Define kx, ky by void matrix shape
					kx = dimoffset(voidberry_QWZ,0)+i*dimdelta(voidberry_QWZ,0)
					ky = dimoffset(voidberry_QWZ,1)+j*dimdelta(voidberry_QWZ,1)

					QWZ(A,B,m,kx,ky,mu)
					wave/C QWZHw = $QWZH

				//** Solve eigenvalue of QWZ Hamiltonian

					matrixEigenV/R QWZHw
					wave/C n=$W_eigenvalues
					wave/C eignevector=$M_R_eigenVectors

					make/n=(dimsize(QWZHw,0))/o sorteigen

					sorteigen[0]= real(N[0])
					sorteigen[1]= real(N[1])

				//**Sort eigenvalue and eigenvector
					make/o/n=(dimsize(QWZHw,0)) sortindex
					sortindex=p
					sort sorteigen sortindex //the value indicates the column number in M_R_eigenVectors belong to each eigenvalue labeled in sorteigen
					sort sorteigen sorteigen

				//** Calculat Berry Curvature

					//## E1,k = sorteigen[0]
					//## |u1,k> = eignevector[][sortindex[0]]

					//## E2,k = sorteigen[1]
					//## |u2,k> = eignevector[][sortindex[1]]


					//** get eigenvalue
						E1k = sorteigen[0]
						E2k = sorteigen[1]

					//** make |u1,k>
						//|ket>
						make/n=(dimsize(QWZHw,0),1)/o/C u1k_ket
						u1k_ket[] = eignevector[p][sortindex[0]]
						//<bra|
						duplicate/o/c u1k_ket u1k_bra
						matrixtranspose/H u1k_bra

					//** make |u2,k>
						//|ket>
						make/n=(dimsize(QWZHw,0),1)/o/C u2k_ket
						u2k_ket[] = eignevector[p][sortindex[1]]
						//<bra|
						duplicate/o/c u2k_ket u2k_bra
						matrixtranspose/H u2k_bra

					//** make dH/dx(k)
						duplicate/o/c QWZHw QWZHworigin

						QWZ(A,B,m,kx+delta,ky,mu)
						wave/C QWZHw = $QWZH
						duplicate/o/c QWZHw dHdx
						dHdx = (QWZHw - QWZHworigin)/delta

					//** make dH/dy(k)
						QWZ(A,B,m,kx,ky+delta,mu)
						wave/C QWZHw = $QWZH
						duplicate/o/c QWZHw dHdy
						dHdy = (QWZHw - QWZHworigin)/delta

					//** calculate Omega_1

						matrixMultiply u1k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm1A =  M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1A *= M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm1B =  M_productw[0][0]

						matrixMultiply u2k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1B *=  M_productw[0][0]

						Berryterm1A -= Berryterm1B
						Berryterm1A /= (E1k-E2k)^2
						Berryterm1A *= cmplx(0,1)

						//BC_QWZ1[i][j] = sqrt(magsqr(Berryterm1A))
						BC_QWZ1[i][j] = real(Berryterm1A)

					//** calculate Omega_2

						matrixMultiply u2k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm2A =  M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2A *= M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm2B =  M_productw[0][0]

						matrixMultiply u1k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2B *=  M_productw[0][0]

						Berryterm2A -= Berryterm2B
						Berryterm2A /= (E1k-E2k)^2
						Berryterm2A *= cmplx(0,1)

						//BC_QWZ2[i][j] = sqrt(magsqr(Berryterm2A))
						BC_QWZ2[i][j] = real(Berryterm2A)

				j+=1
			while(j < dimsize(voidberry_QWZ,1))
			i+=1
		while(i < dimsize(voidberry_QWZ,0))


	killwaves voidberry_QWZ n sorteigen eignevector sortindex u1k_ket u1k_bra u2k_ket u2k_bra dHdx dHdy QWZHworigin QWZHw M_productw
	di(BC_QWZ1)
	ModifyImage BC_QWZ1 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0}
	di(BC_QWZ2)
	ModifyImage BC_QWZ2 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0}
	Print "//*************************************                "
	//Print "		The parameters (A,B,M,phi) are ("+num2str(A)+","+num2str(B)+","+num2str(M)+","+num2str(phi)+")"
	Print "		Chern Number for band #1 is "+num2str(ChernN_QWZ(BC_QWZ1))
	Print "		Chern Number for band #2 is "+num2str(ChernN_QWZ(BC_QWZ2))

	variable Seconds = StopMSTimer(timerRefNum)/10^6
	Print "		Total Time Running: "+num2str(Seconds)+" (s)"

end

Function ChernN_qwz(BCname)
	wave BCname
	variable left = -pi
	variable right = pi
	variable top = pi
	variable bottom = -pi


	variable nleft = round((left-dimoffset(BCname,0))/dimdelta(BCname,0))
	variable nright = round((right-dimoffset(BCname,0))/dimdelta(BCname,0))
	variable ntop = round((top-dimoffset(BCname,1))/dimdelta(BCname,1))
	variable nbottom = round((bottom-dimoffset(BCname,1))/dimdelta(BCname,1))

	variable Sumbc = 0

	variable i,j
	i=nleft
	do
		j=nbottom
		do
			Sumbc+=BCname[i][j]
			j+=1
		while (j < ntop) // [nbottom,ntop)
		i+=1
	while (i < nright) //[nleft,nright), nleft included, but nright excluded
	variable Chernnumber

	Chernnumber = Sumbc*dimdelta(BCname,1)*dimdelta(BCname,0)/(2*pi)
	//print Chernnumber
	return Chernnumber
end


///////////////////////////////////////////////////////////////////////////////////////////
//****************************** Interactive Tuning ***************************************
///////////////////////////////////////////////////////////////////////////////////////////


//** #01 Body
Proc ConsQWZ()
	variable A = 1
	variable B = 1
	variable m = 0.2
	variable selfimg = 0.1
	variable mu = 0

	variable numxy = 100
	variable rangls
	Cons_QWZcut(A,B,m,mu,selfimg,200)
	Cons_QWZFS(A,B,m,mu,selfimg,15)
	cons_QWZBC(A,B,m,mu,20)
	string bc_QWZ1 = "bc_QWZ1"
	string bc_QWZ2 = "bc_QWZ2"
	string fs_QWZ = "fs_QWZ"
	string cut_QWZ = "cut_QWZ"
	display/N=QWZmodelinteractive
	modifygraph width= 600,height=600

	Display/HOST=#/W=(0,0.05,0.5,0.5);appendimage $fs_QWZ;ModifyGraph width={Plan,1,bottom,left},mirror=2;wavestats/Q $fs_QWZ;rangls = max(abs(V_max),abs(V_min));ModifyImage $fs_QWZ ctab= {-rangls,rangls,:Packages:NewColortable:dvg_seismic,0};Label left "\\Z16 A(ω = E\BF\M\Z16, k)"
	setActiveSubwindow ##;Display/HOST=#/W=(0.55,0.05,1,0.5);appendimage $cut_QWZ;ModifyGraph width={Plan,1,bottom,left},mirror=2;ModifyImage $cut_QWZ ctab= {*,*,VioletOrangeYellow,0};Label left "\\Z16 A(ω,k\\Bx\\M\\Z16,k\\By\\M\\Z16=0)"
	setActiveSubwindow ##;Display/HOST=#/W=(0,0.55,0.5,1);appendimage $bc_QWZ1;ModifyGraph width={Plan,1,bottom,left},mirror=2;ModifyImage $bc_QWZ1 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0};Label left "\\Z16 Ω(k,i=1\Z16) \Z10[Lower Band]"
	setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.55,1,1);appendimage $bc_QWZ2;ModifyGraph width={Plan,1,bottom,left},mirror=2;ModifyImage $bc_QWZ2 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0};Label left "\\Z16 Ω(k,i=2\Z16) \Z10[Higher Band]"
	setActiveSubwindow ##
	ckfig_child(winname(0,1))

	variable/G A_QWZ = A
	variable/G B_QWZ = B
	variable/G M_QWZ = M
	variable/G selfimg_QWZ = selfimg
	variable/G mu_QWZ = mu
	SetVariable setA_QWZ win=QWZmodelinteractive, title="A",size={60,20},value=A_QWZ,limits={-inf,inf,0.1},proc=SetVarProc_QWZ
	SetVariable setB_QWZ win=QWZmodelinteractive, title="B",size={60,20},value=B_QWZ,limits={-inf,inf,0.1},proc=SetVarProc_QWZ
	SetVariable setM_QWZ win=QWZmodelinteractive, title="M",size={60,20},value=M_QWZ,limits={-inf,inf,0.05},proc=SetVarProc_QWZ
	SetVariable setMu_QWZ win=QWZmodelinteractive, title="μ",size={60,20},value=Mu_QWZ,limits={-inf,inf,0.05},proc=SetVarProc_QWZ
	SetVariable setselfimg_QWZ win=QWZmodelinteractive, title="Im(Σ)",size={100,20},value=selfimg_QWZ,limits={-inf,inf,0.05},proc=SetVarProc_QWZ
	variable/G onoroffBCFS_QWZ = 0
	SetVariable setonoroffBCFS_QWZ win=QWZmodelinteractive, title="Update",size={60,20},value=onoroffBCFS_QWZ,limits={0,1,1},proc=SetVarProc_QWZ

	variable/G HQBCFS_QWZ = 0
	SetVariable setHQBCFS_QWZ win=QWZmodelinteractive, title="HQ",size={60,20},value=HQBCFS_QWZ,limits={0,1,1},proc=SetVarProc_QWZ
	Button do3dQWZ win=QWZmodelinteractive,title="3D",size={60,20},proc=ButtonProc_QWZ3d
	Button CCQWZ win=QWZmodelinteractive,title="Chern",size={60,20},proc=ButtonProc_QWZChern


	//variable/G Chern_H1
	//variable/G Chern_H2
	ValDisplay valdispH1 title="Chern Number",pos={420,320},size={100,20},value=ShrinkDigit(Chern_H1,1)
	ValDisplay valdispH2 title="Chern Number",pos={110,320},size={100,20},value=ShrinkDigit(Chern_H2,1)
end



//** #02 Interactive Link

Function ButtonProc_QWZCons(ctrlName) : ButtonControl
	String ctrlName
	execute "ConsQWZ()"
end

Function ButtonProc_QWZ3d(ctrlName) : ButtonControl
	String ctrlName
	variable/G A_QWZ
	variable/G B_QWZ
	variable/G M_QWZ
	variable/G selfimg_QWZ
	variable/G mu_QWZ
	QWZSpectralFunction(A_QWZ,B_QWZ,M_QWZ,mu_QWZ,selfimg_QWZ,100)
End

Function ButtonProc_QWZChern(ctrlName) : ButtonControl
	String ctrlName
	variable/G A_QWZ
	variable/G B_QWZ
	variable/G M_QWZ
	variable/G selfimg_QWZ
	Variable/G mu_QWZ

	QWZChernline(A_QWZ,B_QWZ,mu_QWZ)
End

Function SetVarProc_QWZ(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G A_QWZ
	variable/G B_QWZ
	variable/G M_QWZ
	variable/G selfimg_QWZ
	variable/G onoroffBCFS_QWZ
	variable/G HQBCFS_QWZ
	Variable/G mu_QWZ


	variable times
	if (HQBCFS_QWZ == 0)
		times = 20
	else
		times = 100
	endif

	Cons_QWZcut(A_QWZ,B_QWZ,M_QWZ,mu_QWZ,selfimg_QWZ,200)

	if (onoroffBCFS_QWZ == 0)
	else
		Cons_QWZFS(A_QWZ,B_QWZ,M_QWZ,mu_QWZ,selfimg_QWZ,times-5)
		cons_QWZBC(A_QWZ,B_QWZ,M_QWZ,mu_QWZ,times)
	endif

end

//** #03 Functional: make Fermi surface
Function Cons_QWZFS(A,B,M,mu,selfimg,numxy)
	variable A //= 1
	variable B //= 0
	variable M //= 0.2
	variable mu
	variable selfimg
	variable numxy //= 100

	//** Make void matrix for FS
	make/o/n=(numxy,numxy) fs_QWZ
	setscale/i x,-pi,pi,"",fs_QWZ
	setscale/i y,-pi,pi,"",fs_QWZ
	fs_QWZ = 0


	//** Make void matrix
	//make/o/n=(numxy,1000) cut_QWZ
	//setscale/i x,-3,3,"",cut_QWZ
	//setscale/i y,-4.5,4.5,"",cut_QWZ
	//cut_QWZ = 0

	//variable roff = dimoffset(cut_QWZ,1)
	//variable rdelta = dimdelta(cut_QWZ,1)


	//** Variable for Spectral Function
	variable i,j,selfreal,t
	selfreal = 0
	variable kx
	variable ky

	//** Pointer String for called Functions
	string W_eigenvalues="W_eigenvalues"
	string QWZH = "QWZH"

	//** Start loop for (kx, ky)
	i=0
	do
		j=0
		do
			//** Define kx, ky by void matrix shape
				kx = dimoffset(fs_QWZ,0)+i*dimdelta(fs_QWZ,0)
				ky = dimoffset(fs_QWZ,1)+j*dimdelta(fs_QWZ,1)

				QWZ(A,B,M,kx,ky,mu)
				wave/C QWZHw = $QWZH

			//** Solve eigenvalue of QWZ Hamiltonian

				matrixEigenV QWZHw
				wave/C n=$W_eigenvalues
				make/n=(dimsize(QWZHw,0))/o sorteigen

				sorteigen[0]= real(N[0])
				sorteigen[1]= real(N[1])

			//Make 3D Spectral Function
				t=0
				do
					fs_QWZ[i][j][]+=(-1/pi)*selfimg/(selfimg^2+((0)-selfreal-sorteigen[t])^2)

					//cut_QWZ[i][]+=(-1/pi)*selfimg/(selfimg^2+((roff+q*rdelta)-selfreal-sorteigen[t])^2)
					t+=1
				while (t < dimsize(sorteigen,0))

			j+=1
		while(j < dimsize(fs_QWZ,1))
		i+=1
	while(i < dimsize(fs_QWZ,0))
	killwaves QWZHw sorteigen n
	//di(fs_QWZ)
	//di(cut_QWZ)
end

//** #04 Functional: make band dispersion cut
Function Cons_QWZcut(A,B,M,mu,selfimg,numxy)
	variable A //= 1
	variable B //= 0
	variable M //= 0.2
	variable mu
	variable selfimg
	variable numxy //= 100

	//** Make void matrix for spectral function
	make/o/n=(numxy,500) cut_QWZ
	setscale/i x,-pi,pi,"",cut_QWZ
	setscale/i y,-3,3,"",cut_QWZ
	cut_QWZ = 0
	variable roff = dimoffset(cut_QWZ,1)
	variable rdelta = dimdelta(cut_QWZ,1)

	//** Variable for Spectral Function
	variable i,j,selfreal,t
	selfreal = 0
	variable kx
	variable ky = 0

	//** Pointer String for called Functions
	string W_eigenvalues="W_eigenvalues"
	string QWZH = "QWZH"

	//** Start loop for (kx)
	i=0
	do

			//** Define kx, ky by void matrix shape
				kx = dimoffset(cut_QWZ,0)+i*dimdelta(cut_QWZ,0)

				QWZ(A,B,M,kx,ky,mu)
				wave/C QWZHw = $QWZH

			//** Solve eigenvalue of QWZ Hamiltonian

				matrixEigenV QWZHw
				wave/C n=$W_eigenvalues
				make/n=(dimsize(QWZHw,0))/o sorteigen

				sorteigen[0]= real(N[0])
				sorteigen[1]= real(N[1])

			//Make 3D Spectral Function
				t=0
				do
					cut_QWZ[i][]+=(-1/pi)*selfimg/(selfimg^2+((roff+q*rdelta)-selfreal-sorteigen[t])^2)
					t+=1
				while (t < dimsize(sorteigen,0))

		i+=1
	while(i < dimsize(cut_QWZ,0)	)
	killwaves QWZHw sorteigen n

	//di(cut_QWZ)
end

//** #05 Functional: Calculate Berry curvature


Function cons_QWZBC(A,B,M,mu,numxy)
	variable A //= 1
	variable B //= 0.2
	variable M //= 0.2
	variable mu
	variable numxy
	variable kx
	variable ky
	variable i,j

	//** Make void matrix for spectral function
		make/o/n=(numxy,numxy,1) voidberry_QWZ
		setscale/i x,-pi,pi,"",voidberry_QWZ
		setscale/i y,-pi,pi,"",voidberry_QWZ
		//setscale/i z,-2.5,4.5,"",voidberry_QWZ
		voidberry_QWZ = 0

	//** Make void matrix for Berry curvature band #1 (lower) and #2 (higher)
		make/o/n=(numxy,numxy) BC_QWZ1
		setscale/i x,-pi,pi,"",BC_QWZ1
		setscale/i y,-pi,pi,"",BC_QWZ1
		BC_QWZ1 = 0//cmplx(0,0)

		make/o/n=(numxy,numxy) BC_QWZ2
		setscale/i x,-pi,pi,"",BC_QWZ2
		setscale/i y,-pi,pi,"",BC_QWZ2
		BC_QWZ2 = 0//cmplx(0,0)

	//** Pointer String for called Functions
		string W_eigenvalues="W_eigenvalues"
		string QWZH = "QWZH"
		string M_R_eigenVectors = "M_R_eigenVectors"
		string M_product = "M_product"

	//** variable for Berry curvature
		variable E1k, E2K //1 for low band, 2 for high band
		variable delta = 10^-6
		variable/C Berryterm1A = cmplx(0,0)
		variable/C Berryterm1B = cmplx(0,0)

		variable/C Berryterm2A = cmplx(0,0)
		variable/C Berryterm2B = cmplx(0,0)

	//** Start loop for (kx, ky)
		i=0
		do
			j=0
			do
				//** Define kx, ky by void matrix shape
					kx = dimoffset(voidberry_QWZ,0)+i*dimdelta(voidberry_QWZ,0)
					ky = dimoffset(voidberry_QWZ,1)+j*dimdelta(voidberry_QWZ,1)

					QWZ(A,B,M,kx,ky,mu)
					wave/C QWZHw = $QWZH

				//** Solve eigenvalue of QWZ Hamiltonian

					matrixEigenV/R QWZHw
					wave/C n=$W_eigenvalues
					wave/C eignevector=$M_R_eigenVectors

					make/n=(dimsize(QWZHw,0))/o sorteigen

					sorteigen[0]= real(N[0])
					sorteigen[1]= real(N[1])

				//**Sort eigenvalue and eigenvector
					make/o/n=(dimsize(QWZHw,0)) sortindex
					sortindex=p
					sort sorteigen sortindex //the value indicates the column number in M_R_eigenVectors belong to each eigenvalue labeled in sorteigen
					sort sorteigen sorteigen

				//** Calculat Berry Curvature

					//## E1,k = sorteigen[0]
					//## |u1,k> = eignevector[][sortindex[0]]

					//## E2,k = sorteigen[1]
					//## |u2,k> = eignevector[][sortindex[1]]


					//** get eigenvalue
						E1k = sorteigen[0]
						E2k = sorteigen[1]

					//** make |u1,k>
						//|ket>
						make/n=(dimsize(QWZHw,0),1)/o/C u1k_ket
						u1k_ket[] = eignevector[p][sortindex[0]]
						//<bra|
						duplicate/o/c u1k_ket u1k_bra
						matrixtranspose/H u1k_bra

					//** make |u2,k>
						//|ket>
						make/n=(dimsize(QWZHw,0),1)/o/C u2k_ket
						u2k_ket[] = eignevector[p][sortindex[1]]
						//<bra|
						duplicate/o/c u2k_ket u2k_bra
						matrixtranspose/H u2k_bra

					//** make dH/dx(k)
						duplicate/o/c QWZHw QWZHworigin

						QWZ(A,B,M,kx+delta,ky,mu)
						wave/C QWZHw = $QWZH
						duplicate/o/c QWZHw dHdx
						dHdx = (QWZHw - QWZHworigin)/delta

					//** make dH/dy(k)
						QWZ(A,B,M,kx,ky+delta,mu)
						wave/C QWZHw = $QWZH
						duplicate/o/c QWZHw dHdy
						dHdy = (QWZHw - QWZHworigin)/delta

					//** calculate Omega_1

						matrixMultiply u1k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm1A =  M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1A *= M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm1B =  M_productw[0][0]

						matrixMultiply u2k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1B *=  M_productw[0][0]

						Berryterm1A -= Berryterm1B
						Berryterm1A /= (E1k-E2k)^2
						Berryterm1A *= cmplx(0,1)

						//BC_QWZ1[i][j] = sqrt(magsqr(Berryterm1A))
						BC_QWZ1[i][j] = real(Berryterm1A)

					//** calculate Omega_2

						matrixMultiply u2k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm2A =  M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2A *= M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm2B =  M_productw[0][0]

						matrixMultiply u1k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2B *=  M_productw[0][0]

						Berryterm2A -= Berryterm2B
						Berryterm2A /= (E1k-E2k)^2
						Berryterm2A *= cmplx(0,1)

						//BC_QWZ2[i][j] = sqrt(magsqr(Berryterm2A))
						BC_QWZ2[i][j] = real(Berryterm2A)

				j+=1
			while(j < dimsize(voidberry_QWZ,1))
			i+=1
		while(i < dimsize(voidberry_QWZ,0))

	//Calculate Chern Number
		variable/G Chern_H1 = ChernN_QWZ(BC_QWZ1)
		variable/G Chern_H2 = ChernN_QWZ(BC_QWZ2)

	killwaves voidberry_QWZ n sorteigen eignevector sortindex u1k_ket u1k_bra u2k_ket u2k_bra dHdx dHdy QWZHworigin QWZHw M_productw
end

Function QWZChernline(A,B,mu)
	variable A,B,mu
	make/o/N=(50) ChernQWZ
	setscale/i x,-3,5,"",ChernQWZ

	variable m,i

	i=0
	do
		m= dimoffset(ChernQWZ,0)+i*dimdelta(ChernQWZ,0)
		cons_QWZBC(A,B,M,mu,30)
		wave BC_QWZ1 = $"BC_QWZ1"
		ChernQWZ[i] = ChernN_QWZ(BC_QWZ1)
		i+=1
	while(i<dimsize(ChernQWZ,0))
	display ChernQWZ
	ModifyGraph mode=4,marker=19,msize=4,mrkThick=2
	SetAxis left -1.5,1.5
	Label left "Z"
	Label bottom "m"
	ckfig(winname(0,1))
end
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
//****************** Qi-Hughes-Zhang Model **************************
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////
//** Text the form of Hamiltonian
//** We find the current form missing the PH0(k)P^-1 = -conj(H0(-k))
Function QHZT()
	//** Create Parameter waves
		wT("a1",{{"A*sinX"}})
		wT("a2",{{"A*sinY"}})
		wT("a3",{{"m+B*(2-cosX-cosY)"}})
		wT("a4",{{"-u"}})
		wT("a5",{{"-∆"}})
		wT("a6",{{"-∆2"}})

		//wT("e0t",{{"-µ+(kx^2+ky^2)/(2*m)"}})
		//wT("Vxyt",{{"a*ky*kx"}})
		//wT("Vxt",{{"γso*kx"}})
		//wT("Vyt",{{"γso*ky"}})
		//wT("mdd0t",{{"-∆2*kx*ky/k0^2"}})
		//wT("mddzt",{{"-∆0"}})

	//** Create Pauli sequence wave
		Wn("ps",{{3,1},{3,2},{3,3},{3,0},{2,2},{1,2}})

	//** Do text matrix  derivation
	string ps = "ps"
	automatrixT("a1;a2;a3;a4;a5;a6",$ps)
		//alternatively you can also do automatrixT("e0t;Vxyt;Vxt;Vyt;mdd0t;mddzt",Wn("ps",{{3,0,0},{3,3,0},{3,1,2},{0,1,1},{2,0,2},{2,3,2}}))
end

/////////////////////////////////////////////////////////////////////
//** Correct QHZ BdG Hamiltonian
Function/Wave QHZ(A,B,m,mu,ReD,ImD,kx,ky)
	variable A,B,m,mu,ReD,ImD,kx,ky

	//** Pointer String for called Functions
		string ps = "ps_QHZ"
		string result_C = "result_C"

	//** Create QHZ Hamiltonian
		variable pf1,pf2,pf3,pf4,pf5,pf6
		pf1 = A*sin(kx)
		pf2 = A*sin(ky)
		pf3 = m+B*(2-cos(kx)-cos(ky))
		pf4 = -mu

		//** Select a pairing symmetry
		variable/G pairmode

		if (pairmode == 1) // S
			pf5 = -ReD
			ImD = 0
			pf6 = -ImD
		endif

		if (pairmode == 2) // S1+iS2
			pf5 = -ReD
			pf6 = -ImD
		endif

		if (pairmode == 3) // Px+iPy
			pf5 = -ReD*sin(kx)
			pf6 = -ReD*sin(ky)
		endif

		if (pairmode == 4) // S+-
			pf5 = -ReD*cos(kx)*cos(ky)
			ImD = 0
			pf6 = -ImD
		endif

		if (pairmode == 5) // Dx2-y2
			pf5 = -ReD*(cos(kx)-cos(ky))
			ImD = 0
			pf6 = -ImD
		endif

		if (pairmode == 6) // Dxy
			pf5 = -ReD*(sin(kx)*sin(ky))
			ImD = 0
			pf6 = -ImD
		endif

		if (pairmode == 7) // Px
			pf5 = -ReD*sin(kx)
			ImD = 0
			pf6 = -ImD
		endif

		if (pairmode == 8) // Py
			pf5 = -ReD*sin(ky)
			ImD = 0
			pf6 = -ImD
		endif

		wC("pf1_QHZ",{{cmplx(pf1,0)}})
		wC("pf2_QHZ",{{cmplx(pf2,0)}})
		wC("pf3_QHZ",{{cmplx(pf3,0)}})
		wC("pf4_QHZ",{{cmplx(pf4,0)}})
		wC("pf5_QHZ",{{cmplx(pf5,0)}})
		wC("pf6_QHZ",{{cmplx(pf6,0)}})

		Wn("ps_QHZ",{{3,1},{3,2},{3,3},{3,0},{2,2},{1,2}})
		automatrixC("pf1_QHZ;pf2_QHZ;pf3_QHZ;pf4_QHZ;pf5_QHZ;pf6_QHZ",$ps)

		wave/C result_Cw = $result_C
		duplicate/C/o result_Cw QHZH

		//This is to make k to -k and apply complex conjugation
			variable/c e23 = QHZH[2][3]
			QHZH[2][3] = -conj(e23)
			variable/c e32 = QHZH[3][2]
			QHZH[3][2] = -conj(e32)
			//print e23, QHZH[2][3]
		killwaves $result_C
	return QHZH
end

/////////////////////////////////////////////////////////////////////
//** 3D Spetral Function
//QHZSpectralFunction(1,1,0.5,0,1,0,0.1,20)
Function QHZSpectralFunction(A,B,m,mu,ReD,ImD,selfimg,numxy)
	variable A,B,m,mu,ReD,ImD
	variable selfimg
	variable numxy //= 100
	variable/G zn_cons = 2

	//** Make void matrix for spectral function
	make/o/n=(numxy,numxy,500) modelresult_QHZ
	setscale/i x,-pi,pi,"",modelresult_QHZ
	setscale/i y,-pi,pi,"",modelresult_QHZ
	setscale/i z,-5,5,"",modelresult_QHZ
	modelresult_QHZ = 0
	variable roff = dimoffset(modelresult_QHZ,2)
	variable rdelta = dimdelta(modelresult_QHZ,2)

	//** Variable for Spectral Function
	variable i,j,selfreal,t
	selfreal = 0
	variable kx
	variable ky

	//** Pointer String for called Functions
	string W_eigenvalues="W_eigenvalues"
	string QHZH = "QHZH"

	//** Start loop for (kx, ky)
	i=0
	do
		j=0
		do
			//** Define kx, ky by void matrix shape
				kx = dimoffset(modelresult_QHZ,0)+i*dimdelta(modelresult_QHZ,0)
				ky = dimoffset(modelresult_QHZ,1)+j*dimdelta(modelresult_QHZ,1)

				QHZ(A,B,m,mu,ReD,ImD,kx,ky)
				wave/C QHZHw = $QHZH

			//** Solve eigenvalue of QHZ Hamiltonian

				matrixEigenV QHZHw
				wave/C n=$W_eigenvalues
				make/n=(dimsize(QHZHw,0))/o sorteigen

				sorteigen[0]= real(N[0])
				sorteigen[1]= real(N[1])
				sorteigen[2]= real(N[2])
				sorteigen[3]= real(N[3])

			//Make 3D Spectral Function
				t=0
				do
					modelresult_QHZ[i][j][]+=(-1/pi)*selfimg/(selfimg^2+((roff+r*rdelta)-selfreal-sorteigen[t])^2)
					t+=1
				while (t < dimsize(sorteigen,0))

			j+=1
		while(j < dimsize(modelresult_QHZ,1))
		i+=1
	while(i < dimsize(modelresult_QHZ,0)	)

	//** Call smart 3D displayer
		duplicate/o modelresult_QHZ Z1_001
		killwaves modelresult_QHZ sorteigen QHZHw n
		execute "d3d(\"Z1_001\",2)"

	//** Modify the 3D player for this special simulation use (band structure)
		string aa =winname(0,1)+"#G0";
		SetAxis/W=$aa/A/R right
		variable/G divcolor_cons
		divcolor_cons = 1
		wavestats/Q $tpw()
		variable rangls = max(abs(V_max),abs(V_min))
		ModifyImage/W=$grabwinchild(tpw()) $tpw() ctab= {-rangls,rangls,:Packages:NewColortable:dvg_seismic,0};
		ColorScale/W=$grabwinchild(tpw())/C/N=textcc/X=-21.00/Y=5.00/F=0 heightPct=30,nticks=5,minor=1,tickLen=1.00,image=$tpw()//;ColorScale/W=$grabwinchild(Fexyd)/C/N=text0/F=0/A=MC/Y=-120 image=$Fexyd
		variable/G normornot_3dplot =2
		Button launchLinecut title="Linecut",size={65,14},fSize=10,proc=ButtonProc_Cons3dplotZ
		tilewindows/WINS=winname(0,1)/R/w=(49,0,83,85)/A=(1,1)
		tilewindows/WINS=winname(1,1)/R/w=(49,0,83,85)/A=(1,1)

		//string/G mat3dn_cons
		//string mat3dn = mat3dn_cons+"_FFT3d"
		//string mat3dn_consf = mat3dn
		//variable/G zn_cons  //the Energy in which dimension?
		variable/G z_cons
		SetVariable setvarz_cons title="Z",size={65,14},value=z_cons,proc=SetVarProc_Cons3dplot2
		//SetVariable setvarz_cons limits={dimoffset($mat3dn_consf,zn_cons),(dimoffset($mat3dn_consf,zn_cons)+dimdelta($mat3dn_consf,zn_cons)*(dimsize($mat3dn_consf,zn_cons)-1)),dimdelta($mat3dn_consf,zn_cons)}


end

/////////////////////////////////////////////////////////////////////
//** Interactive Tune band structure
Function ButtonProc_QHZ(ctrlName) : ButtonControl
	String ctrlName
	Execute "Cons_QHZcut2c()"
end
Proc Cons_QHZcut2c(A,B,m,mu,ReD,ImD,selfimg,numxy,mode)
	variable A = 1 //= A_QHZ
	variable B  = 1//= B_QHZ
	variable m = 0//= m_QHZ
	variable mu = 0//= mu_QHZ
	variable ReD = 0.5//= ReD_QHZ
	variable ImD = 0//= ImD_QHZ
	variable selfimg = 0.03 //= selfimg_QHZ
	variable numxy = 200//= numxy_QHZ
	variable mode //= pairmode
	Prompt mu,"μ"
	prompt ReD,"Re(Δ)"
	Prompt ImD,"Im(Δ)"
	Prompt selfimg,"Im(Σ)"
	prompt numxy,"Number of point in k space"
	Prompt mode,"Pairing sym",popup,"s;s+is;px+ipy;s±;dx2-y2;dxy;px;py"
	QHZ_bandtune(A,B,m,mu,ReD,ImD,selfimg,numxy,mode)
end
Function QHZ_bandtune(A,B,m,mu,ReD,ImD,selfimg,numxy,mode)
	variable A,B,m,mu,ReD,ImD,selfimg,numxy,mode
	variable/G pairmode = mode
	Cons_QHZcut(A,B,m,mu,ReD,ImD,selfimg,numxy)
	Cons_QHZcut2(A,B,m,mu,ReD,ImD,selfimg,numxy)
	wave cut_QHZ2=$"cut_QHZ2"
	wave cut_QHZ=$"cut_QHZ"
	display/N=QHZmodelinteractive;modifygraph width=700,height=500
	Variable/G A_QHZ = A
	Variable/G B_QHZ = B
	Variable/G m_QHZ = m
	Variable/G mu_QHZ = mu
	Variable/G ReD_QHZ = ReD
	Variable/G ImD_QHZ = ImD
	Variable/G selfimg_QHZ = selfimg
	Variable/G numxy_QHZ = numxy
	variable/G pairmode = mode
	SetVariable sett1_QHZ win=QHZmodelinteractive, title="A",size={50,15},value=A_QHZ,limits={-inf,inf,0.1},proc=SetVarProc_QHZ_band
	SetVariable sett2_QHZ win=QHZmodelinteractive, title="B",size={50,15},value=B_QHZ,limits={-inf,inf,0.1},proc=SetVarProc_QHZ_band,pos={53,1}
	SetVariable setM_QHZ win=QHZmodelinteractive, title="M",size={50,15},value=m_QHZ,limits={-inf,inf,0.05},proc=SetVarProc_QHZ_band,pos={105,1}
	SetVariable setphi_QHZ win=QHZmodelinteractive, title="μ",size={50,15},value=mu_QHZ,limits={-inf,inf,0.1},proc=SetVarProc_QHZ_band,pos={158,1}
	SetVariable setreal_QHZ win=QHZmodelinteractive, title="Re(Δ)",size={70,15},value=ReD_QHZ,limits={-inf,inf,0.1},proc=SetVarProc_QHZ_band,pos={208,1}
	if(pairmode == 2)
		SetVariable setimg_QHZ win=QHZmodelinteractive, title="Im(Δ)",size={70,15},value=ImD_QHZ,limits={-inf,inf,0.1},proc=SetVarProc_QHZ_band,pos={278,1}
	else
		if(pairmode == 3)
			SetVariable setimg_QHZ win=QHZmodelinteractive, title="Im(Δ)",size={70,15},value=ReD_QHZ,limits={ReD_QHZ,ReD_QHZ,0},pos={278,1}
		else
			SetVariable setimg_QHZ win=QHZmodelinteractive, title="Im(Δ)",size={70,15},value=ImD_QHZ,limits={ImD_QHZ,ImD_QHZ,0},proc=SetVarProc_QHZ_band,pos={278,1}
		endif
	endif
	SetVariable setselfimg_QHZ win=QHZmodelinteractive, title="Im(Σ)",size={70,15},value=selfimg_QHZ,limits={-inf,inf,0.1},proc=SetVarProc_QHZ_band,pos={368,1}
	SetVariable setnum_QHZ win=QHZmodelinteractive, title="num",size={70,15},value=numxy_QHZ,limits={0,inf,10},proc=SetVarProc_QHZ_band,pos={440,1}
	Button b3sQHZ win=QHZmodelinteractive, title="3D",size={70,15},proc=ButtonProc_QHZband
	Button m0BCQHZ win=QHZmodelinteractive, title="Chern(m=0)",size={100,15},proc=ButtonProc_QHZChernm0,pos={81,21},fSize=11
	Button m0BCQHZ2 win=QHZmodelinteractive, title="Z(Δ,m=0)",size={100,15},proc=ButtonProc_QHZChernm02,pos={81,40},fSize=11
	Button d0BCQHZ win=QHZmodelinteractive, title="Chern(Δ=0)",size={100,15},proc=ButtonProc_QHZChernd0,pos={188,21},fSize=11
	Button d0BCQHZ2 win=QHZmodelinteractive, title="Z(m,Δ=0,μ=μ0)",size={100,15},proc=ButtonProc_QHZChernd0l1,pos={188,40},fSize=11
	Button d0BCQHZ3 win=QHZmodelinteractive, title="Z(μ,Δ=0,m=m0)",size={100,15},proc=ButtonProc_QHZChernd0l2,pos={188,60},fSize=11
	Button Edge win=QHZmodelinteractive, title="Slab",size={50,15},proc=ButtonProc_QHZedge,pos={650,1},fSize=11

	PopupMenu gapsym proc=PopMenuProc_QHZgapsym,value="s;s+is;px+ipy;s±;dx2-y2;dxy;px;py",title="Gap. Sym.",pos={516,0},mode=mode

	Display/HOST=#/W=(0.0,0.05,0.5,1);appendimage cut_QHZ;ModifyGraph mirror=2;ModifyImage cut_QHZ ctab= {*,*,VioletOrangeYellow,0};ModifyGraph zero(left)=8;Label bottom "\\Z16X          \t \t\t\t\t\t\t\t\tΓ\t\t\t\t\t\t\t\t\t          X"
	setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.05,1,1);appendimage cut_QHZ2;ModifyGraph mirror=2;ModifyImage cut_QHZ2 ctab= {*,*,VioletOrangeYellow,0};ModifyGraph zero(left)=8;Label bottom "\\Z16M          \t \t\t\t\t\t\t\t\tΓ\t\t\t\t\t\t\t\t\t          M"
	setActiveSubwindow ##;
end
Function PopMenuProc_QHZgapsym(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	Variable/G pairmode
	variable/G ImD_QHZ
	variable/G ReD_QHZ
	pairmode=popNum
	if(pairmode == 2)
		SetVariable setimg_QHZ win=QHZmodelinteractive, title="Im(Δ)",size={70,15},value=ImD_QHZ,limits={-inf,inf,0.1},proc=SetVarProc_QHZ_band,pos={278,1}
	else
		if(pairmode == 3)
			SetVariable setimg_QHZ win=QHZmodelinteractive, title="Im(Δ)",size={70,15},value=ReD_QHZ,limits={ReD_QHZ,ReD_QHZ,0},pos={278,1}
		else
			SetVariable setimg_QHZ win=QHZmodelinteractive, title="Im(Δ)",size={70,15},value=ImD_QHZ,limits={ImD_QHZ,ImD_QHZ,0},proc=SetVarProc_QHZ_band,pos={278,1}
		endif
	endif
	Variable/G A_QHZ //= A
	Variable/G B_QHZ //= B
	Variable/G m_QHZ //= m
	Variable/G mu_QHZ //= mu
	Variable/G selfimg_QHZ //= selfimg
	Variable/G numxy_QHZ //= numxy
	variable A = A_QHZ
	variable B = B_QHZ
	variable m = m_QHZ
	variable mu = mu_QHZ
	variable ReD = ReD_QHZ
	variable ImD = ImD_QHZ
	variable selfimg = selfimg_QHZ
	variable numxy = numxy_QHZ

	Cons_QHZcut(A,B,m,mu,ReD,ImD,selfimg,numxy)
	Cons_QHZcut2(A,B,m,mu,ReD,ImD,selfimg,numxy)

	if (cmpstr(grabwinnonew("phasediagramtempQHZ"),"") == 1)
		if (pairmode == 2 || pairmode == 6 || pairmode == 8)
			Solveedgestate_QHZ_cmplx(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,10,300)
		else
			Solveedgestate_QHZ(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,10,300)
		endif
	endif

	variable/G LDOSEawr_QHZ
	if (LDOSEawr_QHZ == 1)
		effQHZ_LDOSEawr()
	endif

End
Function ButtonProc_QHZband(ctrlName) : ButtonControl
	String ctrlName
	Variable/G A_QHZ //= A
	Variable/G B_QHZ //= B
	Variable/G m_QHZ //= m
	Variable/G mu_QHZ //= mu
	Variable/G ReD_QHZ //= ReD
	Variable/G ImD_QHZ //= ImD
	Variable/G selfimg_QHZ //= selfimg
	variable A = A_QHZ
	variable B = B_QHZ
	variable m = m_QHZ
	variable mu = mu_QHZ
	variable ReD = ReD_QHZ
	variable ImD = ImD_QHZ
	variable selfimg = selfimg_QHZ
	QHZSpectralFunction(A,B,m,mu,ReD,ImD,selfimg,100)
	QWZSpectralFunction2(A,B,m,mu,selfimg,100)
end


Function Cons_QHZcut(A,B,m,mu,ReD,ImD,selfimg,numxy)
	variable A,B,m,mu,ReD,ImD,selfimg,numxy

	//** Make void matrix for spectral function
	make/o/n=(numxy,500) cut_QHZ
	setscale/i x,-pi,pi,"",cut_QHZ
	setscale/i y,-5,5,"",cut_QHZ
	cut_QHZ = 0
	variable roff = dimoffset(cut_QHZ,1)
	variable rdelta = dimdelta(cut_QHZ,1)

	//** Variable for Spectral Function
	variable i,j,selfreal,t
	selfreal = 0
	variable kx
	variable ky = 0

	//** Pointer String for called Functions
	string W_eigenvalues="W_eigenvalues"
	string QHZH = "QHZH"

	//** Start loop for (kx)
	i=0
	do

			//** Define kx, ky by void matrix shape
				kx = dimoffset(cut_QHZ,0)+i*dimdelta(cut_QHZ,0)

				QHZ(A,B,m,mu,ReD,ImD,kx,ky)
				wave/C QHZHw = $QHZH

			//** Solve eigenvalue of QHZ Hamiltonian

				matrixEigenV QHZHw
				wave/C n=$W_eigenvalues
				make/n=(dimsize(QHZHw,0))/o sorteigen

				sorteigen[0]= real(N[0])
				sorteigen[1]= real(N[1])
				sorteigen[2]= real(N[2])
				sorteigen[3]= real(N[3])

			//Make 3D Spectral Function
				t=0
				do
					cut_QHZ[i][]+=(-1/pi)*selfimg/(selfimg^2+((roff+q*rdelta)-selfreal-sorteigen[t])^2)
					t+=1
				while (t < dimsize(sorteigen,0))

		i+=1
	while(i < dimsize(cut_QHZ,0)	)
	killwaves QHZHw sorteigen n

	//di(cut_QHZ)
end

Function Cons_QHZcut2(A,B,m,mu,ReD,ImD,selfimg,numxy)
	variable A,B,m,mu,ReD,ImD,selfimg,numxy

	//** Make void matrix for spectral function
	make/o/n=(numxy,500) cut_QHZ2
	setscale/i x,-sqrt(2)*pi,sqrt(2)*pi,"",cut_QHZ2
	setscale/i y,-5,5,"",cut_QHZ2
	cut_QHZ2 = 0
	variable roff = dimoffset(cut_QHZ2,1)
	variable rdelta = dimdelta(cut_QHZ2,1)

	//** Variable for Spectral Function
	variable i,j,selfreal,t
	selfreal = 0
	variable kx
	variable ky

	//** Pointer String for called Functions
	string W_eigenvalues="W_eigenvalues"
	string QHZH = "QHZH"

	//** Start loop for (kx)
	i=0
	do

			//** Define kx, ky by void matrix shape
				kx = -pi+i*2*pi/(dimsize(cut_QHZ2,0)-1)
				ky = kx
				QHZ(A,B,m,mu,ReD,ImD,kx,ky)
				wave/C QHZHw = $QHZH

			//** Solve eigenvalue of QHZ Hamiltonian

				matrixEigenV QHZHw
				wave/C n=$W_eigenvalues
				make/n=(dimsize(QHZHw,0))/o sorteigen

				sorteigen[0]= real(N[0])
				sorteigen[1]= real(N[1])
				sorteigen[2]= real(N[2])
				sorteigen[3]= real(N[3])

			//Make 3D Spectral Function
				t=0
				do
					cut_QHZ2[i][]+=(-1/pi)*selfimg/(selfimg^2+((roff+q*rdelta)-selfreal-sorteigen[t])^2)
					t+=1
				while (t < dimsize(sorteigen,0))

		i+=1
	while(i < dimsize(cut_QHZ2,0)	)
	killwaves QHZHw sorteigen n

	//di(cut_QHZ)
end



Function SetVarProc_QHZ_band(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	Variable/G A_QHZ //= A
	Variable/G B_QHZ //= B
	Variable/G m_QHZ //= m
	Variable/G mu_QHZ //= mu
	Variable/G ReD_QHZ //= ReD
	Variable/G ImD_QHZ //= ImD
	Variable/G selfimg_QHZ //= selfimg
	Variable/G numxy_QHZ //= numxy
	variable/G pairmode

	variable A = A_QHZ
	variable B = B_QHZ
	variable m = m_QHZ
	variable mu = mu_QHZ
	variable ReD = ReD_QHZ
	variable ImD = ImD_QHZ
	variable selfimg = selfimg_QHZ
	variable numxy = numxy_QHZ

	Cons_QHZcut(A,B,m,mu,ReD,ImD,selfimg,numxy)
	Cons_QHZcut2(A,B,m,mu,ReD,ImD,selfimg,numxy)

	//print cmpstr(grabwinnonew("phasediagramtempQHZ"),"")

	if (cmpstr(grabwinnonew("phasediagramtempQHZ"),"") == 1)

		if (pairmode == 2 || pairmode == 6 || pairmode == 8)
			Solveedgestate_QHZ_cmplx(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,10,300)
		else
			Solveedgestate_QHZ(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,10,300)
		endif


		//Cursor/W=QHZedgemodeshowinteractive/I b phasediagramtempQHZ m, ReD
	endif

	variable/G LDOSEawr_QHZ
	if (LDOSEawr_QHZ == 1)
		effQHZ_LDOSEawr()
	endif

end

/////////////////////////////////////////////////////////////////////
//** Calculate Chern number when m = 0
Function ButtonProc_QHZChernm0(ctrlName) : ButtonControl
	String ctrlName
	QHZ_hpBerryCurvature(30)
	QHZ_hmBerryCurvature(30)
	wave BC_QHZ_hm1 = $"BC_QHZ_hm1"
	wave BC_QHZ_hm2 = $"BC_QHZ_hm2"
	wave BC_QHZ_hp1 = $"BC_QHZ_hp1"
	wave BC_QHZ_hp2 = $"BC_QHZ_hp2"
	display/N=QHZeq5BSshowfig;modifygraph width= 350,height=300
	Display/HOST=#/W=(0,0,0.5,0.5);appendimage BC_QHZ_hm1;ModifyGraph width={Plan,1,bottom,left},mirror=2;ModifyImage BC_QHZ_hm1 ctab= {*,*,VioletOrangeYellow,0};Label left "h-(#1)"
	setActiveSubwindow ##;Display/HOST=#/W=(0.5,0,1,0.5);appendimage BC_QHZ_hm2;ModifyGraph width={Plan,1,bottom,left},mirror=2;ModifyImage BC_QHZ_hm2 ctab= {*,*,VioletOrangeYellow,0};Label left "h-(#2)"
	setActiveSubwindow ##;Display/HOST=#/W=(0,0.5,0.5,1);appendimage BC_QHZ_hp1;ModifyGraph width={Plan,1,bottom,left},mirror=2;ModifyImage BC_QHZ_hp1 ctab= {*,*,VioletOrangeYellow,0};Label left "h+(#1)"
	setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.5,1,1);appendimage BC_QHZ_hp2;ModifyGraph width={Plan,1,bottom,left},mirror=2;ModifyImage BC_QHZ_hp2 ctab= {*,*,VioletOrangeYellow,0};Label left "h+(#2)"
	setActiveSubwindow ##;
	ckfig_child(winname(0,1))
	tilewindows/WINS=winname(0,1)/R/A=(1,1)/w=(3,58,50,100)

end
Function ButtonProc_QHZChernm02(ctrlName) : ButtonControl
	String ctrlName
	QHZeq8Chernline()
end
/////////////////////////////////////////////////////////////////////
//# PRB 82, 184516 eq. (5) calculate the chern number of m = 0 case
Function qHZeq5hphm(kx, ky)
	variable kx
	variable ky
	Variable/G A_QHZ //= A
	Variable/G B_QHZ //= B
	Variable/G ReD_QHZ //= ReD
	Variable/G ImD_QHZ
	Variable/G numxy_QHZ //= numxy
	variable A = A_QHZ
	variable B = B_QHZ
	variable ReD = ReD_QHZ
	variable ImD = ImD_QHZ
	variable numxy = numxy_QHZ

	make/o/N=(2,2)/C QHZ_hp
	QHZ_hp[0][0] = cmplx(sqrt(ReD^2+ImD^2) + B*(2-cos(kx)-cos(ky)),0)
	QHZ_hp[0][1] = cmplx(A*sin(kx),-A*sin(ky))
	QHZ_hp[1][0] = cmplx(A*sin(kx),A*sin(ky))
	QHZ_hp[1][1] = -cmplx(sqrt(ReD^2+ImD^2) + B*(2-cos(kx)-cos(ky)),0)

	make/o/N=(2,2)/C QHZ_hm
	QHZ_hm[0][0] = cmplx(-sqrt(ReD^2+ImD^2) + B*(2-cos(kx)-cos(ky)),0)
	QHZ_hm[0][1] = cmplx(A*sin(kx),-A*sin(ky))
	QHZ_hm[1][0] = cmplx(A*sin(kx),A*sin(ky))
	QHZ_hm[1][1] = -cmplx(-sqrt(ReD^2+ImD^2) + B*(2-cos(kx)-cos(ky)),0)

end


Function QHZ_hpBerryCurvature(numxy)
	variable numxy //= 100

	variable kx
	variable ky
	variable i,j

	//Variable timerRefNum
	//timerRefNum = StartMSTimer

	//** Make void matrix for spectral function
		make/o/n=(numxy,numxy,1) voidberry_QHZ_hp
		setscale/i x,-pi,pi,"",voidberry_QHZ_hp
		setscale/i y,-pi,pi,"",voidberry_QHZ_hp
		//setscale/i z,-2.5,4.5,"",voidberry_QHZ_hp
		voidberry_QHZ_hp = 0

	//** Make void matrix for Berry curvature band #1 (lower) and #2 (higher)
		make/o/n=(numxy,numxy) BC_QHZ_hp1
		setscale/i x,-pi,pi,"",BC_QHZ_hp1
		setscale/i y,-pi,pi,"",BC_QHZ_hp1
		BC_QHZ_hp1 = 0//cmplx(0,0)

		make/o/n=(numxy,numxy) BC_QHZ_hp2
		setscale/i x,-pi,pi,"",BC_QHZ_hp2
		setscale/i y,-pi,pi,"",BC_QHZ_hp2
		BC_QHZ_hp2 = 0//cmplx(0,0)

	//** Pointer String for called Functions
		string W_eigenvalues="W_eigenvalues"
		string QHZ_hpH = "QHZ_hp"
		string M_R_eigenVectors = "M_R_eigenVectors"
		string M_product = "M_product"

	//** variable for Berry curvature
		variable E1k, E2K //1 for low band, 2 for high band
		variable delta = 10^-6
		variable/C Berryterm1A = cmplx(0,0)
		variable/C Berryterm1B = cmplx(0,0)

		variable/C Berryterm2A = cmplx(0,0)
		variable/C Berryterm2B = cmplx(0,0)

	//** Start loop for (kx, ky)
		i=0
		do
			j=0
			do
				//** Define kx, ky by void matrix shape
					kx = dimoffset(voidberry_QHZ_hp,0)+i*dimdelta(voidberry_QHZ_hp,0)
					ky = dimoffset(voidberry_QHZ_hp,1)+j*dimdelta(voidberry_QHZ_hp,1)

					qHZeq5hphm(kx, ky)
					wave/C QHZ_hpHw = $QHZ_hpH

				//** Solve eigenvalue of QHZ_hp Hamiltonian

					matrixEigenV/R QHZ_hpHw
					wave/C n=$W_eigenvalues
					wave/C eignevector=$M_R_eigenVectors

					make/n=(dimsize(QHZ_hpHw,0))/o sorteigen

					sorteigen[0]= real(N[0])
					sorteigen[1]= real(N[1])

				//**Sort eigenvalue and eigenvector
					make/o/n=(dimsize(QHZ_hpHw,0)) sortindex
					sortindex=p
					sort sorteigen sortindex //the value indicates the column number in M_R_eigenVectors belong to each eigenvalue labeled in sorteigen
					sort sorteigen sorteigen

				//** Calculat Berry Curvature

					//## E1,k = sorteigen[0]
					//## |u1,k> = eignevector[][sortindex[0]]

					//## E2,k = sorteigen[1]
					//## |u2,k> = eignevector[][sortindex[1]]


					//** get eigenvalue
						E1k = sorteigen[0]
						E2k = sorteigen[1]

					//** make |u1,k>
						//|ket>
						make/n=(dimsize(QHZ_hpHw,0),1)/o/C u1k_ket
						u1k_ket[] = eignevector[p][sortindex[0]]
						//<bra|
						duplicate/o/c u1k_ket u1k_bra
						matrixtranspose/H u1k_bra

					//** make |u2,k>
						//|ket>
						make/n=(dimsize(QHZ_hpHw,0),1)/o/C u2k_ket
						u2k_ket[] = eignevector[p][sortindex[1]]
						//<bra|
						duplicate/o/c u2k_ket u2k_bra
						matrixtranspose/H u2k_bra

					//** make dH/dx(k)
						duplicate/o/c QHZ_hpHw QHZ_hpHworigin

						qHZeq5hphm(kx+delta, ky)
						wave/C QHZ_hpHw = $QHZ_hpH
						duplicate/o/c QHZ_hpHw dHdx
						dHdx = (QHZ_hpHw - QHZ_hpHworigin)/delta

					//** make dH/dy(k)
						qHZeq5hphm(kx,ky+delta)
						wave/C QHZ_hpHw = $QHZ_hpH
						duplicate/o/c QHZ_hpHw dHdy
						dHdy = (QHZ_hpHw - QHZ_hpHworigin)/delta
						killwaves QHZ_hpHworigin QHZ_hpHw

					//** calculate Omega_1

						matrixMultiply u1k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm1A =  M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1A *= M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm1B =  M_productw[0][0]

						matrixMultiply u2k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1B *=  M_productw[0][0]

						Berryterm1A -= Berryterm1B
						Berryterm1A /= (E1k-E2k)^2
						Berryterm1A *= cmplx(0,1)

						//BC_QHZ_hp1[i][j] = sqrt(magsqr(Berryterm1A))
						BC_QHZ_hp1[i][j] = real(Berryterm1A)

					//** calculate Omega_2

						matrixMultiply u2k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm2A =  M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2A *= M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm2B =  M_productw[0][0]

						matrixMultiply u1k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2B *=  M_productw[0][0]

						Berryterm2A -= Berryterm2B
						Berryterm2A /= (E1k-E2k)^2
						Berryterm2A *= cmplx(0,1)

						//BC_QHZ_hp2[i][j] = sqrt(magsqr(Berryterm2A))
						BC_QHZ_hp2[i][j] = real(Berryterm2A)

				j+=1
			while(j < dimsize(voidberry_QHZ_hp,1))
			i+=1
		while(i < dimsize(voidberry_QHZ_hp,0))
	killwaves voidberry_QHZ_hp n sorteigen eignevector sortindex u1k_ket u1k_bra u2k_ket u2k_bra dHdx dHdy QHZ_hpHworigin QHZ_hpHw M_productw
	//di(BC_QHZ_hp1)
	//ModifyImage BC_QHZ_hp1 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0}
	//di(BC_QHZ_hp2)
	//ModifyImage BC_QHZ_hp2 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0}
	TextBox/C/N=text1/F=0/B=1/A=RT/X=3/Y=6 "Z(m=0,+) =  "+num2str(ChernN_QHZ(BC_QHZ_hp1))//+"\r"+"h+(#2): Z = "+num2str(ChernN_QHZ(BC_QHZ_hp2))


	//Print "//*************************************                "
	//Print "		The parameters (t1,t2,M,phi) are ("+num2str(t1)+","+num2str(t2)+","+num2str(M)+","+num2str(phi)+")"
	//Print "		h+(#1): Z = "+num2str(ChernN_QHZ(BC_QHZ_hp1))
	//Print "		h+(#2): Z = "+num2str(ChernN_QHZ(BC_QHZ_hp2))
	//variable Seconds = StopMSTimer(timerRefNum)/10^6
	//Print "		Total Time Running: "+num2str(Seconds)+" (s)"
end

Function QHZ_hmBerryCurvature(numxy)
	variable numxy //= 100

	variable kx
	variable ky
	variable i,j

	//Variable timerRefNum
	//timerRefNum = StartMSTimer

	//** Make void matrix for spectral function
		make/o/n=(numxy,numxy,1) voidberry_QHZ_hm
		setscale/i x,-pi,pi,"",voidberry_QHZ_hm
		setscale/i y,-pi,pi,"",voidberry_QHZ_hm
		//setscale/i z,-2.5,4.5,"",voidberry_QHZ_hm
		voidberry_QHZ_hm = 0

	//** Make void matrix for Berry curvature band #1 (lower) and #2 (higher)
		make/o/n=(numxy,numxy) BC_QHZ_hm1
		setscale/i x,-pi,pi,"",BC_QHZ_hm1
		setscale/i y,-pi,pi,"",BC_QHZ_hm1
		BC_QHZ_hm1 = 0//cmplx(0,0)

		make/o/n=(numxy,numxy) BC_QHZ_hm2
		setscale/i x,-pi,pi,"",BC_QHZ_hm2
		setscale/i y,-pi,pi,"",BC_QHZ_hm2
		BC_QHZ_hm2 = 0//cmplx(0,0)

	//** Pointer String for called Functions
		string W_eigenvalues="W_eigenvalues"
		string QHZ_hmH = "QHZ_hm"
		string M_R_eigenVectors = "M_R_eigenVectors"
		string M_product = "M_product"

	//** variable for Berry curvature
		variable E1k, E2K //1 for low band, 2 for high band
		variable delta = 10^-6
		variable/C Berryterm1A = cmplx(0,0)
		variable/C Berryterm1B = cmplx(0,0)

		variable/C Berryterm2A = cmplx(0,0)
		variable/C Berryterm2B = cmplx(0,0)

	//** Start loop for (kx, ky)
		i=0
		do
			j=0
			do
				//** Define kx, ky by void matrix shape
					kx = dimoffset(voidberry_QHZ_hm,0)+i*dimdelta(voidberry_QHZ_hm,0)
					ky = dimoffset(voidberry_QHZ_hm,1)+j*dimdelta(voidberry_QHZ_hm,1)

					qHZeq5hphm(kx, ky)
					wave/C QHZ_hmHw = $QHZ_hmH

				//** Solve eigenvalue of QHZ_hm Hamiltonian

					matrixEigenV/R QHZ_hmHw
					wave/C n=$W_eigenvalues
					wave/C eignevector=$M_R_eigenVectors

					make/n=(dimsize(QHZ_hmHw,0))/o sorteigen

					sorteigen[0]= real(N[0])
					sorteigen[1]= real(N[1])

				//**Sort eigenvalue and eigenvector
					make/o/n=(dimsize(QHZ_hmHw,0)) sortindex
					sortindex=p
					sort sorteigen sortindex //the value indicates the column number in M_R_eigenVectors belong to each eigenvalue labeled in sorteigen
					sort sorteigen sorteigen

				//** Calculat Berry Curvature

					//## E1,k = sorteigen[0]
					//## |u1,k> = eignevector[][sortindex[0]]

					//## E2,k = sorteigen[1]
					//## |u2,k> = eignevector[][sortindex[1]]


					//** get eigenvalue
						E1k = sorteigen[0]
						E2k = sorteigen[1]

					//** make |u1,k>
						//|ket>
						make/n=(dimsize(QHZ_hmHw,0),1)/o/C u1k_ket
						u1k_ket[] = eignevector[p][sortindex[0]]
						//<bra|
						duplicate/o/c u1k_ket u1k_bra
						matrixtranspose/H u1k_bra

					//** make |u2,k>
						//|ket>
						make/n=(dimsize(QHZ_hmHw,0),1)/o/C u2k_ket
						u2k_ket[] = eignevector[p][sortindex[1]]
						//<bra|
						duplicate/o/c u2k_ket u2k_bra
						matrixtranspose/H u2k_bra

					//** make dH/dx(k)
						duplicate/o/c QHZ_hmHw QHZ_hmHworigin

						qHZeq5hphm(kx+delta, ky)
						wave/C QHZ_hmHw = $QHZ_hmH
						duplicate/o/c QHZ_hmHw dHdx
						dHdx = (QHZ_hmHw - QHZ_hmHworigin)/delta

					//** make dH/dy(k)
						qHZeq5hphm(kx,ky+delta)
						wave/C QHZ_hmHw = $QHZ_hmH
						duplicate/o/c QHZ_hmHw dHdy
						dHdy = (QHZ_hmHw - QHZ_hmHworigin)/delta
						killwaves QHZ_hmHworigin QHZ_hmHw

					//** calculate Omega_1

						matrixMultiply u1k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm1A =  M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1A *= M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm1B =  M_productw[0][0]

						matrixMultiply u2k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1B *=  M_productw[0][0]

						Berryterm1A -= Berryterm1B
						Berryterm1A /= (E1k-E2k)^2
						Berryterm1A *= cmplx(0,1)

						//BC_QHZ_hm1[i][j] = sqrt(magsqr(Berryterm1A))
						BC_QHZ_hm1[i][j] = real(Berryterm1A)

					//** calculate Omega_2

						matrixMultiply u2k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm2A =  M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2A *= M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm2B =  M_productw[0][0]

						matrixMultiply u1k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2B *=  M_productw[0][0]

						Berryterm2A -= Berryterm2B
						Berryterm2A /= (E1k-E2k)^2
						Berryterm2A *= cmplx(0,1)

						//BC_QHZ_hm2[i][j] = sqrt(magsqr(Berryterm2A))
						BC_QHZ_hm2[i][j] = real(Berryterm2A)

				j+=1
			while(j < dimsize(voidberry_QHZ_hm,1))
			i+=1
		while(i < dimsize(voidberry_QHZ_hm,0))
	killwaves voidberry_QHZ_hm n sorteigen eignevector sortindex u1k_ket u1k_bra u2k_ket u2k_bra dHdx dHdy QHZ_hmHworigin QHZ_hmHw M_productw
	//di(BC_QHZ_hm1)
	//ModifyImage BC_QHZ_hm1 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0}
	//di(BC_QHZ_hm2)
	//ModifyImage BC_QHZ_hm2 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0}
	//Print "//*************************************                "
	//Print "		The parameters (t1,t2,M,phi) are ("+num2str(t1)+","+num2str(t2)+","+num2str(M)+","+num2str(phi)+")"
	TextBox/C/N=text0/F=0/B=1/A=RT/X=3/Y=3 "Z(m=0,-) = "+num2str(ChernN_QHZ(BC_QHZ_hm1))//+"\r"+"h-(#2): Z = "+num2str(ChernN_QHZ(BC_QHZ_hm2))


	//Print "		h-(#1): Z = "+num2str(ChernN_QHZ(BC_QHZ_hm1))
	//Print "		h-(#2): Z = "+num2str(ChernN_QHZ(BC_QHZ_hm2))
	//variable Seconds = StopMSTimer(timerRefNum)/10^6
	//Print "		Total Time Running: "+num2str(Seconds)+" (s)"
end

Function QHZeq8Chernline()
	Variable/G A_QHZ //= A
	Variable/G B_QHZ
	variable A = A_QHZ
	variable B = B_QHZ
	make/o/N=(50) ChernQHZeq8p
	setscale/i x,-3,3,"",ChernQHZeq8p
	setscale/i x,-3,3,"",ChernQHZeq8p

	make/o/N=(50) ChernQHZeq8m
	setscale/i x,-3,3,"",ChernQHZeq8m
	setscale/i x,-3,3,"",ChernQHZeq8m

	variable d,i

	i=0
	do
		d= dimoffset(ChernQHZeq8p,0)+i*dimdelta(ChernQHZeq8p,0)
		QHZ_hpBerryCurvatured(d,50)
		wave BC_QHZ_hp1 = $"BC_QHZ_hp1"
		ChernQHZeq8p[i] = ChernN_QHZ(BC_QHZ_hp1)

		QHZ_hmBerryCurvatured(d,50)
		wave BC_QHZ_hm1 = $"BC_QHZ_hm1"
		ChernQHZeq8m[i] = ChernN_QHZ(BC_QHZ_hm1)


		i+=1
	while(i<dimsize(ChernQHZeq8p,0))
	display ChernQHZeq8p ChernQHZeq8m
	tilewindows/WINS=winname(0,1)/R/A=(1,1)/w=(49,0,75,25)
	ModifyGraph mode=4,marker=19,msize=4,mrkThick=2
	ModifyGraph rgb(ChernQHZeq8m)=(0,0,65535)
	Legend/C/N=text0/J/A=RB/X=0.00/Y=0.00 "\\s(ChernQHZeq8p) h+\r\\s(ChernQHZeq8m) h-"
	TextBox/C/N=text1/X=0.00/Y=0.00 "m = 0; A = "+num2str(A)+"; B = "+num2str(B)
	SetAxis left -1.5,1.5
	Label left "Z (m = 0; A = "+num2str(A)+"; B = "+num2str(B)+")"
	Label bottom "ReD"
	ckfig(winname(0,1))
end
Function qHZeq5hphmdelta(kx,ky,d)
	variable kx
	variable ky
	variable d
	Variable/G A_QHZ //= A
	Variable/G B_QHZ //= B
	Variable/G ReD_QHZ //= ReD
	Variable/G numxy_QHZ //= numxy
	variable A = A_QHZ
	variable B = B_QHZ
	variable ReD = d
	variable numxy = numxy_QHZ

	make/o/N=(2,2)/C QHZ_hp
	QHZ_hp[0][0] = cmplx(abs(ReD) + B*(2-cos(kx)-cos(ky)),0)
	QHZ_hp[0][1] = cmplx(A*sin(kx),-A*sin(ky))
	QHZ_hp[1][0] = cmplx(A*sin(kx),A*sin(ky))
	QHZ_hp[1][1] = -cmplx(abs(ReD) + B*(2-cos(kx)-cos(ky)),0)

	make/o/N=(2,2)/C QHZ_hm
	QHZ_hm[0][0] = cmplx(-abs(ReD) + B*(2-cos(kx)-cos(ky)),0)
	QHZ_hm[0][1] = cmplx(A*sin(kx),-A*sin(ky))
	QHZ_hm[1][0] = cmplx(A*sin(kx),A*sin(ky))
	QHZ_hm[1][1] = -cmplx(-abs(ReD) + B*(2-cos(kx)-cos(ky)),0)

end

Function QHZ_hpBerryCurvatured(d,numxy)
	variable d
	variable numxy //= 100

	variable kx
	variable ky
	variable i,j

	//Variable timerRefNum
	//timerRefNum = StartMSTimer

	//** Make void matrix for spectral function
		make/o/n=(numxy,numxy,1) voidberry_QHZ_hp
		setscale/i x,-pi,pi,"",voidberry_QHZ_hp
		setscale/i y,-pi,pi,"",voidberry_QHZ_hp
		//setscale/i z,-2.5,4.5,"",voidberry_QHZ_hp
		voidberry_QHZ_hp = 0

	//** Make void matrix for Berry curvature band #1 (lower) and #2 (higher)
		make/o/n=(numxy,numxy) BC_QHZ_hp1
		setscale/i x,-pi,pi,"",BC_QHZ_hp1
		setscale/i y,-pi,pi,"",BC_QHZ_hp1
		BC_QHZ_hp1 = 0//cmplx(0,0)

		make/o/n=(numxy,numxy) BC_QHZ_hp2
		setscale/i x,-pi,pi,"",BC_QHZ_hp2
		setscale/i y,-pi,pi,"",BC_QHZ_hp2
		BC_QHZ_hp2 = 0//cmplx(0,0)

	//** Pointer String for called Functions
		string W_eigenvalues="W_eigenvalues"
		string QHZ_hpH = "QHZ_hp"
		string M_R_eigenVectors = "M_R_eigenVectors"
		string M_product = "M_product"

	//** variable for Berry curvature
		variable E1k, E2K //1 for low band, 2 for high band
		variable delta = 10^-6
		variable/C Berryterm1A = cmplx(0,0)
		variable/C Berryterm1B = cmplx(0,0)

		variable/C Berryterm2A = cmplx(0,0)
		variable/C Berryterm2B = cmplx(0,0)

	//** Start loop for (kx, ky)
		i=0
		do
			j=0
			do
				//** Define kx, ky by void matrix shape
					kx = dimoffset(voidberry_QHZ_hp,0)+i*dimdelta(voidberry_QHZ_hp,0)
					ky = dimoffset(voidberry_QHZ_hp,1)+j*dimdelta(voidberry_QHZ_hp,1)

					qHZeq5hphmdelta(kx, ky,d)
					wave/C QHZ_hpHw = $QHZ_hpH

				//** Solve eigenvalue of QHZ_hp Hamiltonian

					matrixEigenV/R QHZ_hpHw
					wave/C n=$W_eigenvalues
					wave/C eignevector=$M_R_eigenVectors

					make/n=(dimsize(QHZ_hpHw,0))/o sorteigen

					sorteigen[0]= real(N[0])
					sorteigen[1]= real(N[1])

				//**Sort eigenvalue and eigenvector
					make/o/n=(dimsize(QHZ_hpHw,0)) sortindex
					sortindex=p
					sort sorteigen sortindex //the value indicates the column number in M_R_eigenVectors belong to each eigenvalue labeled in sorteigen
					sort sorteigen sorteigen

				//** Calculat Berry Curvature

					//## E1,k = sorteigen[0]
					//## |u1,k> = eignevector[][sortindex[0]]

					//## E2,k = sorteigen[1]
					//## |u2,k> = eignevector[][sortindex[1]]


					//** get eigenvalue
						E1k = sorteigen[0]
						E2k = sorteigen[1]

					//** make |u1,k>
						//|ket>
						make/n=(dimsize(QHZ_hpHw,0),1)/o/C u1k_ket
						u1k_ket[] = eignevector[p][sortindex[0]]
						//<bra|
						duplicate/o/c u1k_ket u1k_bra
						matrixtranspose/H u1k_bra

					//** make |u2,k>
						//|ket>
						make/n=(dimsize(QHZ_hpHw,0),1)/o/C u2k_ket
						u2k_ket[] = eignevector[p][sortindex[1]]
						//<bra|
						duplicate/o/c u2k_ket u2k_bra
						matrixtranspose/H u2k_bra

					//** make dH/dx(k)
						duplicate/o/c QHZ_hpHw QHZ_hpHworigin

						qHZeq5hphmdelta(kx+delta, ky,d)
						wave/C QHZ_hpHw = $QHZ_hpH
						duplicate/o/c QHZ_hpHw dHdx
						dHdx = (QHZ_hpHw - QHZ_hpHworigin)/delta

					//** make dH/dy(k)
						qHZeq5hphmdelta(kx,ky+delta,d)
						wave/C QHZ_hpHw = $QHZ_hpH
						duplicate/o/c QHZ_hpHw dHdy
						dHdy = (QHZ_hpHw - QHZ_hpHworigin)/delta
						killwaves QHZ_hpHworigin QHZ_hpHw

					//** calculate Omega_1

						matrixMultiply u1k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm1A =  M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1A *= M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm1B =  M_productw[0][0]

						matrixMultiply u2k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1B *=  M_productw[0][0]

						Berryterm1A -= Berryterm1B
						Berryterm1A /= (E1k-E2k)^2
						Berryterm1A *= cmplx(0,1)

						//BC_QHZ_hp1[i][j] = sqrt(magsqr(Berryterm1A))
						BC_QHZ_hp1[i][j] = real(Berryterm1A)

					//** calculate Omega_2

						matrixMultiply u2k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm2A =  M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2A *= M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm2B =  M_productw[0][0]

						matrixMultiply u1k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2B *=  M_productw[0][0]

						Berryterm2A -= Berryterm2B
						Berryterm2A /= (E1k-E2k)^2
						Berryterm2A *= cmplx(0,1)

						//BC_QHZ_hp2[i][j] = sqrt(magsqr(Berryterm2A))
						BC_QHZ_hp2[i][j] = real(Berryterm2A)

				j+=1
			while(j < dimsize(voidberry_QHZ_hp,1))
			i+=1
		while(i < dimsize(voidberry_QHZ_hp,0))
	//killwaves voidberry_QHZ_hp n sorteigen eignevector sortindex u1k_ket u1k_bra u2k_ket u2k_bra dHdx dHdy QHZ_hpHworigin QHZ_hpHw M_productw
	//di(BC_QHZ_hp1)
	//ModifyImage BC_QHZ_hp1 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0}
	//di(BC_QHZ_hp2)
	//ModifyImage BC_QHZ_hp2 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0}
	TextBox/C/N=text1/F=0/B=1/A=RT/X=3/Y=3 "Z(m=0,+) = "+num2str(ChernN_QHZ(BC_QHZ_hp1))//+"\r"+"h-(#2): Z = "+num2str(ChernN_QHZ(BC_QHZ_hm2))


	//Print "//*************************************                "
	//Print "		The parameters (t1,t2,M,phi) are ("+num2str(t1)+","+num2str(t2)+","+num2str(M)+","+num2str(phi)+")"
	//Print "		h+(#1): Z = "+num2str(ChernN_QHZ(BC_QHZ_hp1))
	//Print "		h+(#2): Z = "+num2str(ChernN_QHZ(BC_QHZ_hp2))
	//variable Seconds = StopMSTimer(timerRefNum)/10^6
	//Print "		Total Time Running: "+num2str(Seconds)+" (s)"
end

Function QHZ_hmBerryCurvatured(d,numxy)
	variable d
	variable numxy //= 100

	variable kx
	variable ky
	variable i,j

	//Variable timerRefNum
	//timerRefNum = StartMSTimer

	//** Make void matrix for spectral function
		make/o/n=(numxy,numxy,1) voidberry_QHZ_hm
		setscale/i x,-pi,pi,"",voidberry_QHZ_hm
		setscale/i y,-pi,pi,"",voidberry_QHZ_hm
		//setscale/i z,-2.5,4.5,"",voidberry_QHZ_hm
		voidberry_QHZ_hm = 0

	//** Make void matrix for Berry curvature band #1 (lower) and #2 (higher)
		make/o/n=(numxy,numxy) BC_QHZ_hm1
		setscale/i x,-pi,pi,"",BC_QHZ_hm1
		setscale/i y,-pi,pi,"",BC_QHZ_hm1
		BC_QHZ_hm1 = 0//cmplx(0,0)

		make/o/n=(numxy,numxy) BC_QHZ_hm2
		setscale/i x,-pi,pi,"",BC_QHZ_hm2
		setscale/i y,-pi,pi,"",BC_QHZ_hm2
		BC_QHZ_hm2 = 0//cmplx(0,0)

	//** Pointer String for called Functions
		string W_eigenvalues="W_eigenvalues"
		string QHZ_hmH = "QHZ_hm"
		string M_R_eigenVectors = "M_R_eigenVectors"
		string M_product = "M_product"

	//** variable for Berry curvature
		variable E1k, E2K //1 for low band, 2 for high band
		variable delta = 10^-6
		variable/C Berryterm1A = cmplx(0,0)
		variable/C Berryterm1B = cmplx(0,0)

		variable/C Berryterm2A = cmplx(0,0)
		variable/C Berryterm2B = cmplx(0,0)

	//** Start loop for (kx, ky)
		i=0
		do
			j=0
			do
				//** Define kx, ky by void matrix shape
					kx = dimoffset(voidberry_QHZ_hm,0)+i*dimdelta(voidberry_QHZ_hm,0)
					ky = dimoffset(voidberry_QHZ_hm,1)+j*dimdelta(voidberry_QHZ_hm,1)

					qHZeq5hphmdelta(kx, ky,d)
					wave/C QHZ_hmHw = $QHZ_hmH

				//** Solve eigenvalue of QHZ_hm Hamiltonian

					matrixEigenV/R QHZ_hmHw
					wave/C n=$W_eigenvalues
					wave/C eignevector=$M_R_eigenVectors

					make/n=(dimsize(QHZ_hmHw,0))/o sorteigen

					sorteigen[0]= real(N[0])
					sorteigen[1]= real(N[1])

				//**Sort eigenvalue and eigenvector
					make/o/n=(dimsize(QHZ_hmHw,0)) sortindex
					sortindex=p
					sort sorteigen sortindex //the value indicates the column number in M_R_eigenVectors belong to each eigenvalue labeled in sorteigen
					sort sorteigen sorteigen

				//** Calculat Berry Curvature

					//## E1,k = sorteigen[0]
					//## |u1,k> = eignevector[][sortindex[0]]

					//## E2,k = sorteigen[1]
					//## |u2,k> = eignevector[][sortindex[1]]


					//** get eigenvalue
						E1k = sorteigen[0]
						E2k = sorteigen[1]

					//** make |u1,k>
						//|ket>
						make/n=(dimsize(QHZ_hmHw,0),1)/o/C u1k_ket
						u1k_ket[] = eignevector[p][sortindex[0]]
						//<bra|
						duplicate/o/c u1k_ket u1k_bra
						matrixtranspose/H u1k_bra

					//** make |u2,k>
						//|ket>
						make/n=(dimsize(QHZ_hmHw,0),1)/o/C u2k_ket
						u2k_ket[] = eignevector[p][sortindex[1]]
						//<bra|
						duplicate/o/c u2k_ket u2k_bra
						matrixtranspose/H u2k_bra

					//** make dH/dx(k)
						duplicate/o/c QHZ_hmHw QHZ_hmHworigin

						qHZeq5hphmdelta(kx+delta, ky,d)
						wave/C QHZ_hmHw = $QHZ_hmH
						duplicate/o/c QHZ_hmHw dHdx
						dHdx = (QHZ_hmHw - QHZ_hmHworigin)/delta

					//** make dH/dy(k)
						qHZeq5hphmdelta(kx,ky+delta,d)
						wave/C QHZ_hmHw = $QHZ_hmH
						duplicate/o/c QHZ_hmHw dHdy
						dHdy = (QHZ_hmHw - QHZ_hmHworigin)/delta
						killwaves QHZ_hmHworigin QHZ_hmHw

					//** calculate Omega_1

						matrixMultiply u1k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm1A =  M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1A *= M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm1B =  M_productw[0][0]

						matrixMultiply u2k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1B *=  M_productw[0][0]

						Berryterm1A -= Berryterm1B
						Berryterm1A /= (E1k-E2k)^2
						Berryterm1A *= cmplx(0,1)

						//BC_QHZ_hm1[i][j] = sqrt(magsqr(Berryterm1A))
						BC_QHZ_hm1[i][j] = real(Berryterm1A)

					//** calculate Omega_2

						matrixMultiply u2k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm2A =  M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2A *= M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm2B =  M_productw[0][0]

						matrixMultiply u1k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2B *=  M_productw[0][0]

						Berryterm2A -= Berryterm2B
						Berryterm2A /= (E1k-E2k)^2
						Berryterm2A *= cmplx(0,1)

						//BC_QHZ_hm2[i][j] = sqrt(magsqr(Berryterm2A))
						BC_QHZ_hm2[i][j] = real(Berryterm2A)

				j+=1
			while(j < dimsize(voidberry_QHZ_hm,1))
			i+=1
		while(i < dimsize(voidberry_QHZ_hm,0))
	killwaves voidberry_QHZ_hm n sorteigen eignevector sortindex u1k_ket u1k_bra u2k_ket u2k_bra dHdx dHdy QHZ_hmHworigin QHZ_hmHw M_productw
	//di(BC_QHZ_hm1)
	//ModifyImage BC_QHZ_hm1 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0}
	//di(BC_QHZ_hm2)
	//ModifyImage BC_QHZ_hm2 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0}
	//Print "//*************************************                "
	//Print "		The parameters (t1,t2,M,phi) are ("+num2str(t1)+","+num2str(t2)+","+num2str(M)+","+num2str(phi)+")"
	//TextBox/C/N=text0/F=0/B=1/A=RT/X=3/Y=3 "h-(#1): Z = "+num2str(ChernN_QHZ(BC_QHZ_hm1))+"\r"+"h-(#2): Z = "+num2str(ChernN_QHZ(BC_QHZ_hm2))
	TextBox/C/N=text0/F=0/B=1/A=RT/X=3/Y=3 "Z(m=0,-) = "+num2str(ChernN_QHZ(BC_QHZ_hm1))//+"\r"+"h-(#2): Z = "+num2str(ChernN_QHZ(BC_QHZ_hm2))


	//Print "		h-(#1): Z = "+num2str(ChernN_QHZ(BC_QHZ_hm1))
	//Print "		h-(#2): Z = "+num2str(ChernN_QHZ(BC_QHZ_hm2))
	//variable Seconds = StopMSTimer(timerRefNum)/10^6
	//Print "		Total Time Running: "+num2str(Seconds)+" (s)"
end
/////////////////////////////////////////////////////////////////////
//** Calculate Chern number when d = 0
Function QHZd0(kx, ky)
	variable kx
	variable ky
	Variable/G A_QHZ //= A
	Variable/G B_QHZ //= B
	Variable/G m_QHZ //= m
	Variable/G mu_QHZ //= mu
	Variable/G ReD_QHZ //= ReD
	Variable/G ImD_QHZ //= ImD
	Variable/G selfimg_QHZ //= selfimg
	Variable/G numxy_QHZ //= numxy

	variable A = A_QHZ
	variable B = B_QHZ
	variable m = m_QHZ
	variable mu = mu_QHZ
	variable ReD = ReD_QHZ
	variable ImD = ImD_QHZ
	variable selfimg = selfimg_QHZ
	variable numxy = numxy_QHZ

	make/o/N=(2,2)/C QHZ_d0p
	QHZ_d0p[0][0] = cmplx(m+B*(2-cos(kx)-cos(ky))-mu,0)
	QHZ_d0p[0][1] = cmplx(A*sin(kx),-A*sin(ky))
	QHZ_d0p[1][0] = cmplx(A*sin(kx),A*sin(ky))
	QHZ_d0p[1][1] = cmplx(-m-B*(2-cos(kx)-cos(ky))-mu,0)

	make/o/N=(2,2)/C QHZ_d0m
	QHZ_d0m[0][0] = -cmplx(m+B*(2-cos(-kx)-cos(-ky))+mu,0)
	QHZ_d0m[0][1] = -cmplx(A*sin(-kx),A*sin(-ky))
	QHZ_d0m[1][0] = -cmplx(A*sin(-kx),-A*sin(-ky))
	QHZ_d0m[1][1] = -cmplx(-m-B*(2-cos(-kx)-cos(-ky))+mu,0)
end

/////////////////////////////////////////////////////////////////////
//** Calculate Chern number when d = 0
Function ButtonProc_QHZChernd0(ctrlName) : ButtonControl
	String ctrlName
	QHZ_d0pBerryCurvature(30)
	QHZ_d0mBerryCurvature(30)
	wave BC_QHZ_d0m1 = $"BC_QHZ_d0m1"
	wave BC_QHZ_d0m2 = $"BC_QHZ_d0m2"
	wave BC_QHZ_d0p1 = $"BC_QHZ_d0p1"
	wave BC_QHZ_d0p2 = $"BC_QHZ_d0p2"
	display/N=QHZd0BSshowfig;modifygraph width= 350,height=300
	Display/HOST=#/W=(0,0,0.5,0.5);appendimage BC_QHZ_d0m1;ModifyGraph width={Plan,1,bottom,left},mirror=2;ModifyImage BC_QHZ_d0m1 ctab= {*,*,VioletOrangeYellow,0};Label left "h-(#1)"
	setActiveSubwindow ##;Display/HOST=#/W=(0.5,0,1,0.5);appendimage BC_QHZ_d0m2;ModifyGraph width={Plan,1,bottom,left},mirror=2;ModifyImage BC_QHZ_d0m2 ctab= {*,*,VioletOrangeYellow,0};Label left "h-(#2)"
	setActiveSubwindow ##;Display/HOST=#/W=(0,0.5,0.5,1);appendimage BC_QHZ_d0p1;ModifyGraph width={Plan,1,bottom,left},mirror=2;ModifyImage BC_QHZ_d0p1 ctab= {*,*,VioletOrangeYellow,0};Label left "h+(#1)"
	setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.5,1,1);appendimage BC_QHZ_d0p2;ModifyGraph width={Plan,1,bottom,left},mirror=2;ModifyImage BC_QHZ_d0p2 ctab= {*,*,VioletOrangeYellow,0};Label left "h+(#2)"
	setActiveSubwindow ##;
	ckfig_child(winname(0,1))
	tilewindows/WINS=winname(0,1)/R/A=(1,1)/w=(26.5,58,100,100)

end

Function QHZ_d0pBerryCurvature(numxy)
	variable numxy //= 100

	variable kx
	variable ky
	variable i,j

	//Variable timerRefNum
	//timerRefNum = StartMSTimer

	//** Make void matrix for spectral function
		make/o/n=(numxy,numxy,1) voidberry_QHZ_d0p
		setscale/i x,-pi,pi,"",voidberry_QHZ_d0p
		setscale/i y,-pi,pi,"",voidberry_QHZ_d0p
		//setscale/i z,-2.5,4.5,"",voidberry_QHZ_d0p
		voidberry_QHZ_d0p = 0

	//** Make void matrix for Berry curvature band #1 (lower) and #2 (higher)
		make/o/n=(numxy,numxy) BC_QHZ_d0p1
		setscale/i x,-pi,pi,"",BC_QHZ_d0p1
		setscale/i y,-pi,pi,"",BC_QHZ_d0p1
		BC_QHZ_d0p1 = 0//cmplx(0,0)

		make/o/n=(numxy,numxy) BC_QHZ_d0p2
		setscale/i x,-pi,pi,"",BC_QHZ_d0p2
		setscale/i y,-pi,pi,"",BC_QHZ_d0p2
		BC_QHZ_d0p2 = 0//cmplx(0,0)

	//** Pointer String for called Functions
		string W_eigenvalues="W_eigenvalues"
		string QHZ_d0pH = "QHZ_d0p"
		string M_R_eigenVectors = "M_R_eigenVectors"
		string M_product = "M_product"

	//** variable for Berry curvature
		variable E1k, E2K //1 for low band, 2 for high band
		variable delta = 10^-6
		variable/C Berryterm1A = cmplx(0,0)
		variable/C Berryterm1B = cmplx(0,0)

		variable/C Berryterm2A = cmplx(0,0)
		variable/C Berryterm2B = cmplx(0,0)

	//** Start loop for (kx, ky)
		i=0
		do
			j=0
			do
				//** Define kx, ky by void matrix shape
					kx = dimoffset(voidberry_QHZ_d0p,0)+i*dimdelta(voidberry_QHZ_d0p,0)
					ky = dimoffset(voidberry_QHZ_d0p,1)+j*dimdelta(voidberry_QHZ_d0p,1)

					QHZd0(kx, ky)
					wave/C QHZ_d0pHw = $QHZ_d0pH

				//** Solve eigenvalue of QHZ_d0p Hamiltonian

					matrixEigenV/R QHZ_d0pHw
					wave/C n=$W_eigenvalues
					wave/C eignevector=$M_R_eigenVectors

					make/n=(dimsize(QHZ_d0pHw,0))/o sorteigen

					sorteigen[0]= real(N[0])
					sorteigen[1]= real(N[1])

				//**Sort eigenvalue and eigenvector
					make/o/n=(dimsize(QHZ_d0pHw,0)) sortindex
					sortindex=p
					sort sorteigen sortindex //the value indicates the column number in M_R_eigenVectors belong to each eigenvalue labeled in sorteigen
					sort sorteigen sorteigen

				//** Calculat Berry Curvature

					//## E1,k = sorteigen[0]
					//## |u1,k> = eignevector[][sortindex[0]]

					//## E2,k = sorteigen[1]
					//## |u2,k> = eignevector[][sortindex[1]]


					//** get eigenvalue
						E1k = sorteigen[0]
						E2k = sorteigen[1]

					//** make |u1,k>
						//|ket>
						make/n=(dimsize(QHZ_d0pHw,0),1)/o/C u1k_ket
						u1k_ket[] = eignevector[p][sortindex[0]]
						//<bra|
						duplicate/o/c u1k_ket u1k_bra
						matrixtranspose/H u1k_bra

					//** make |u2,k>
						//|ket>
						make/n=(dimsize(QHZ_d0pHw,0),1)/o/C u2k_ket
						u2k_ket[] = eignevector[p][sortindex[1]]
						//<bra|
						duplicate/o/c u2k_ket u2k_bra
						matrixtranspose/H u2k_bra

					//** make dH/dx(k)
						duplicate/o/c QHZ_d0pHw QHZ_d0pHworigin

						QHZd0(kx+delta, ky)
						wave/C QHZ_d0pHw = $QHZ_d0pH
						duplicate/o/c QHZ_d0pHw dHdx
						dHdx = (QHZ_d0pHw - QHZ_d0pHworigin)/delta

					//** make dH/dy(k)
						QHZd0(kx, ky+delta)
						wave/C QHZ_d0pHw = $QHZ_d0pH
						duplicate/o/c QHZ_d0pHw dHdy
						dHdy = (QHZ_d0pHw - QHZ_d0pHworigin)/delta
						killwaves QHZ_d0pHworigin QHZ_d0pHw

					//** calculate Omega_1

						matrixMultiply u1k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm1A =  M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1A *= M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm1B =  M_productw[0][0]

						matrixMultiply u2k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1B *=  M_productw[0][0]

						Berryterm1A -= Berryterm1B
						Berryterm1A /= (E1k-E2k)^2
						Berryterm1A *= cmplx(0,1)

						//BC_QHZ_d0p1[i][j] = sqrt(magsqr(Berryterm1A))
						BC_QHZ_d0p1[i][j] = real(Berryterm1A)

					//** calculate Omega_2

						matrixMultiply u2k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm2A =  M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2A *= M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm2B =  M_productw[0][0]

						matrixMultiply u1k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2B *=  M_productw[0][0]

						Berryterm2A -= Berryterm2B
						Berryterm2A /= (E1k-E2k)^2
						Berryterm2A *= cmplx(0,1)

						//BC_QHZ_d0p2[i][j] = sqrt(magsqr(Berryterm2A))
						BC_QHZ_d0p2[i][j] = real(Berryterm2A)

				j+=1
			while(j < dimsize(voidberry_QHZ_d0p,1))
			i+=1
		while(i < dimsize(voidberry_QHZ_d0p,0))
	killwaves voidberry_QHZ_d0p n sorteigen eignevector sortindex u1k_ket u1k_bra u2k_ket u2k_bra dHdx dHdy QHZ_d0pHworigin QHZ_d0pHw M_productw
	//di(BC_QHZ_d0p1)
	//ModifyImage BC_QHZ_d0p1 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0}
	//di(BC_QHZ_d0p2)
	//ModifyImage BC_QHZ_d0p2 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0}
	TextBox/C/N=text3/F=0/B=1/A=RT/X=3/Y=9 "Z(Δ=0,+) = "+num2str(ChernN_QHZ(BC_QHZ_d0p1))

	//Print "//*************************************                "
	//Print "		The parameters (t1,t2,M,phi) are ("+num2str(t1)+","+num2str(t2)+","+num2str(M)+","+num2str(phi)+")"
	//Print "		h+(#1): Z = "+num2str(ChernN_QHZ(BC_QHZ_d0p1))
	//Print "		h+(#2): Z = "+num2str(ChernN_QHZ(BC_QHZ_d0p2))
	//variable Seconds = StopMSTimer(timerRefNum)/10^6
	//Print "		Total Time Running: "+num2str(Seconds)+" (s)"
end

Function QHZ_d0mBerryCurvature(numxy)
	variable numxy //= 100

	variable kx
	variable ky
	variable i,j

	//Variable timerRefNum
	//timerRefNum = StartMSTimer

	//** Make void matrix for spectral function
		make/o/n=(numxy,numxy,1) voidberry_QHZ_d0m
		setscale/i x,-pi,pi,"",voidberry_QHZ_d0m
		setscale/i y,-pi,pi,"",voidberry_QHZ_d0m
		//setscale/i z,-2.5,4.5,"",voidberry_QHZ_d0m
		voidberry_QHZ_d0m = 0

	//** Make void matrix for Berry curvature band #1 (lower) and #2 (higher)
		make/o/n=(numxy,numxy) BC_QHZ_d0m1
		setscale/i x,-pi,pi,"",BC_QHZ_d0m1
		setscale/i y,-pi,pi,"",BC_QHZ_d0m1
		BC_QHZ_d0m1 = 0//cmplx(0,0)

		make/o/n=(numxy,numxy) BC_QHZ_d0m2
		setscale/i x,-pi,pi,"",BC_QHZ_d0m2
		setscale/i y,-pi,pi,"",BC_QHZ_d0m2
		BC_QHZ_d0m2 = 0//cmplx(0,0)

	//** Pointer String for called Functions
		string W_eigenvalues="W_eigenvalues"
		string QHZ_d0mH = "QHZ_d0m"
		string M_R_eigenVectors = "M_R_eigenVectors"
		string M_product = "M_product"

	//** variable for Berry curvature
		variable E1k, E2K //1 for low band, 2 for high band
		variable delta = 10^-6
		variable/C Berryterm1A = cmplx(0,0)
		variable/C Berryterm1B = cmplx(0,0)

		variable/C Berryterm2A = cmplx(0,0)
		variable/C Berryterm2B = cmplx(0,0)

	//** Start loop for (kx, ky)
		i=0
		do
			j=0
			do
				//** Define kx, ky by void matrix shape
					kx = dimoffset(voidberry_QHZ_d0m,0)+i*dimdelta(voidberry_QHZ_d0m,0)
					ky = dimoffset(voidberry_QHZ_d0m,1)+j*dimdelta(voidberry_QHZ_d0m,1)

					QHZd0(kx, ky)
					wave/C QHZ_d0mHw = $QHZ_d0mH

				//** Solve eigenvalue of QHZ_d0m Hamiltonian

					matrixEigenV/R QHZ_d0mHw
					wave/C n=$W_eigenvalues
					wave/C eignevector=$M_R_eigenVectors

					make/n=(dimsize(QHZ_d0mHw,0))/o sorteigen

					sorteigen[0]= real(N[0])
					sorteigen[1]= real(N[1])

				//**Sort eigenvalue and eigenvector
					make/o/n=(dimsize(QHZ_d0mHw,0)) sortindex
					sortindex=p
					sort sorteigen sortindex //the value indicates the column number in M_R_eigenVectors belong to each eigenvalue labeled in sorteigen
					sort sorteigen sorteigen

				//** Calculat Berry Curvature

					//## E1,k = sorteigen[0]
					//## |u1,k> = eignevector[][sortindex[0]]

					//## E2,k = sorteigen[1]
					//## |u2,k> = eignevector[][sortindex[1]]


					//** get eigenvalue
						E1k = sorteigen[0]
						E2k = sorteigen[1]

					//** make |u1,k>
						//|ket>
						make/n=(dimsize(QHZ_d0mHw,0),1)/o/C u1k_ket
						u1k_ket[] = eignevector[p][sortindex[0]]
						//<bra|
						duplicate/o/c u1k_ket u1k_bra
						matrixtranspose/H u1k_bra

					//** make |u2,k>
						//|ket>
						make/n=(dimsize(QHZ_d0mHw,0),1)/o/C u2k_ket
						u2k_ket[] = eignevector[p][sortindex[1]]
						//<bra|
						duplicate/o/c u2k_ket u2k_bra
						matrixtranspose/H u2k_bra

					//** make dH/dx(k)
						duplicate/o/c QHZ_d0mHw QHZ_d0mHworigin

						QHZd0(kx+delta, ky)

						wave/C QHZ_d0mHw = $QHZ_d0mH
						duplicate/o/c QHZ_d0mHw dHdx
						dHdx = (QHZ_d0mHw - QHZ_d0mHworigin)/delta

					//** make dH/dy(k)
						QHZd0(kx, ky+delta)
						wave/C QHZ_d0mHw = $QHZ_d0mH
						duplicate/o/c QHZ_d0mHw dHdy
						dHdy = (QHZ_d0mHw - QHZ_d0mHworigin)/delta
						killwaves QHZ_d0mHworigin QHZ_d0mHw

					//** calculate Omega_1

						matrixMultiply u1k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm1A =  M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1A *= M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm1B =  M_productw[0][0]

						matrixMultiply u2k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1B *=  M_productw[0][0]

						Berryterm1A -= Berryterm1B
						Berryterm1A /= (E1k-E2k)^2
						Berryterm1A *= cmplx(0,1)

						//BC_QHZ_d0m1[i][j] = sqrt(magsqr(Berryterm1A))
						BC_QHZ_d0m1[i][j] = real(Berryterm1A)

					//** calculate Omega_2

						matrixMultiply u2k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm2A =  M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2A *= M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm2B =  M_productw[0][0]

						matrixMultiply u1k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2B *=  M_productw[0][0]

						Berryterm2A -= Berryterm2B
						Berryterm2A /= (E1k-E2k)^2
						Berryterm2A *= cmplx(0,1)

						//BC_QHZ_d0m2[i][j] = sqrt(magsqr(Berryterm2A))
						BC_QHZ_d0m2[i][j] = real(Berryterm2A)

				j+=1
			while(j < dimsize(voidberry_QHZ_d0m,1))
			i+=1
		while(i < dimsize(voidberry_QHZ_d0m,0))
	killwaves voidberry_QHZ_d0m n sorteigen eignevector sortindex u1k_ket u1k_bra u2k_ket u2k_bra dHdx dHdy QHZ_d0mHworigin QHZ_d0mHw M_productw
	//di(BC_QHZ_d0m1)
	//ModifyImage BC_QHZ_d0m1 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0}
	//di(BC_QHZ_d0m2)
	//ModifyImage BC_QHZ_d0m2 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0}
	//Print "//*************************************                "
	//Print "		The parameters (t1,t2,M,phi) are ("+num2str(t1)+","+num2str(t2)+","+num2str(M)+","+num2str(phi)+")"
	TextBox/C/N=text2/F=0/B=1/A=RT/X=3/Y=12 "Z(Δ=0,-) = "+num2str(ChernN_QHZ(BC_QHZ_d0m1))


	//Print "		h-(#1): Z = "+num2str(ChernN_QHZ(BC_QHZ_d0m1))
	//Print "		h-(#2): Z = "+num2str(ChernN_QHZ(BC_QHZ_d0m2))
	//variable Seconds = StopMSTimer(timerRefNum)/10^6
	//Print "		Total Time Running: "+num2str(Seconds)+" (s)"
end

Function ButtonProc_QHZChernd0l1(ctrlName) : ButtonControl
	String ctrlName
	execute "QHZd0Chernlineuuc()"
end
Function ButtonProc_QHZChernd0l2(ctrlName) : ButtonControl
	String ctrlName
	execute "QHZd0Chernlinemmc()"
end

Proc QHZd0Chernlineuuc(uu)
	variable uu = 0
	Prompt uu,"please fix a μ value, we calculate Z along m"
	QHZd0Chernlineuu(uu)
end
Function QHZd0Chernlineuu(uu)
	variable uu
	Variable/G A_QHZ //= A
	Variable/G B_QHZ //= B
	Variable/G m_QHZ //= m
	Variable/G mu_QHZ //= mu
	Variable/G ReD_QHZ //= ReD
	Variable/G ImD_QHZ //= ImD
	Variable/G selfimg_QHZ //= selfimg

	variable A = A_QHZ
	variable B = B_QHZ
	variable m = m_QHZ
	variable mu = mu_QHZ
	variable ReD = ReD_QHZ
	variable ImD = ImD_QHZ
	variable selfimg = selfimg_QHZ

	make/o/N=(50) ChernQHZd0_mp
	setscale/i x,-5,5,"",ChernQHZd0_mp
	setscale/i x,-5,5,"",ChernQHZd0_mp

	make/o/N=(50) ChernQHZd0_mm
	setscale/i x,-5,5,"",ChernQHZd0_mm
	setscale/i x,-5,5,"",ChernQHZd0_mm

	variable mm,i

	i=0
	do
		mm= dimoffset(ChernQHZd0_mp,0)+i*dimdelta(ChernQHZd0_mp,0)
		QHZ_d0pBerryCurvaturemu(50,mm,uu)
		wave BC_QHZ_d0p1 = $"BC_QHZ_d0p1"
		ChernQHZd0_mp[i] = ChernN_QHZ(BC_QHZ_d0p1)

		QHZ_d0mBerryCurvaturemu(50,mm,uu)
		wave BC_QHZ_d0m1 = $"BC_QHZ_d0m1"
		ChernQHZd0_mm[i] = ChernN_QHZ(BC_QHZ_d0m1)


		i+=1
	while(i<dimsize(ChernQHZd0_mp,0))
	display ChernQHZd0_mp ChernQHZd0_mm
	tilewindows/WINS=winname(0,1)/R/A=(1,1)/w=(49,0,75,25)
	ModifyGraph mode=4,marker=19,msize=4,mrkThick=2
	ModifyGraph rgb(ChernQHZd0_mm)=(0,0,65535)
	ModifyGraph marker(ChernQHZd0_mm)=8,mrkThick(ChernQHZd0_mm)=1
	Legend/C/N=text0/J/A=RB/X=0.00/Y=0.00 "\\s(ChernQHZd0_mp) h+\r\\s(ChernQHZd0_mm) h-"
	TextBox/C/N=text1/X=0.00/Y=0.00 "Δ = 0; A = "+num2str(A)+"; B = "+num2str(B)+"; μ = "+num2str(uu)
	SetAxis left -1.5,1.5
	Label left "Z (Δ = 0; A = "+num2str(A)+"; B = "+num2str(B)+"; μ = "+num2str(uu)+")"
	Label bottom "m"
	ckfig(winname(0,1))
end

Proc QHZd0Chernlinemmc(mm)
	variable mm = 0
	Prompt mm,"please fix a m value, we calculate Z along μ"
	QHZd0Chernlinemm(mm)
end
Function QHZd0Chernlinemm(mm)
	variable mm
	Variable/G A_QHZ //= A
	Variable/G B_QHZ //= B
	Variable/G m_QHZ //= m
	Variable/G mu_QHZ //= mu
	Variable/G ReD_QHZ //= ReD
	Variable/G ImD_QHZ //= ImD
	Variable/G selfimg_QHZ //= selfimg

	variable A = A_QHZ
	variable B = B_QHZ
	variable m = m_QHZ
	variable mu = mu_QHZ
	variable ReD = ReD_QHZ
	variable ImD = ImD_QHZ
	variable selfimg = selfimg_QHZ

	make/o/N=(50) ChernQHZd0_up
	setscale/i x,-5,5,"",ChernQHZd0_up
	setscale/i x,-5,5,"",ChernQHZd0_up

	make/o/N=(50) ChernQHZd0_um
	setscale/i x,-5,5,"",ChernQHZd0_um
	setscale/i x,-5,5,"",ChernQHZd0_um

	variable uu,i

	i=0
	do
		uu= dimoffset(ChernQHZd0_up,0)+i*dimdelta(ChernQHZd0_up,0)
		QHZ_d0pBerryCurvaturemu(50,mm,uu)
		wave BC_QHZ_d0p1 = $"BC_QHZ_d0p1"
		ChernQHZd0_up[i] = ChernN_QHZ(BC_QHZ_d0p1)

		QHZ_d0mBerryCurvaturemu(50,mm,uu)
		wave BC_QHZ_d0m1 = $"BC_QHZ_d0m1"
		ChernQHZd0_um[i] = ChernN_QHZ(BC_QHZ_d0m1)


		i+=1
	while(i<dimsize(ChernQHZd0_up,0))
	display ChernQHZd0_up ChernQHZd0_um
	tilewindows/WINS=winname(0,1)/R/A=(1,1)/w=(49,0,75,25)
	ModifyGraph mode=4,marker=19,msize=4,mrkThick=2
	ModifyGraph rgb(ChernQHZd0_um)=(0,0,65535)
	ModifyGraph marker(ChernQHZd0_um)=8,mrkThick(ChernQHZd0_um)=1
	Legend/C/N=text0/J/A=RB/X=0.00/Y=0.00 "\\s(ChernQHZd0_up) h+\r\\s(ChernQHZd0_um) h-"
	TextBox/C/N=text1/X=0.00/Y=0.00 "Δ = 0; A = "+num2str(A)+"; B = "+num2str(B)+"; m = "+num2str(mm)
	SetAxis left -1.5,1.5
	Label left "Z (Δ = 0; A = "+num2str(A)+"; B = "+num2str(B)+"; m = "+num2str(mm)+")"
	Label bottom "μ"
	ckfig(winname(0,1))
end


Function QHZd0mu(kx,ky,mm,u)
	variable kx
	variable ky
	variable mm, u
	Variable/G A_QHZ //= A
	Variable/G B_QHZ //= B
	Variable/G m_QHZ //= m
	Variable/G mu_QHZ //= mu
	Variable/G ReD_QHZ //= ReD
	Variable/G ImD_QHZ //= ImD
	Variable/G selfimg_QHZ //= selfimg
	Variable/G numxy_QHZ //= numxy

	variable A = A_QHZ
	variable B = B_QHZ
	variable m = mm
	variable mu = u

	variable selfimg = selfimg_QHZ
	variable numxy = numxy_QHZ

	make/o/N=(2,2)/C QHZ_d0p
	QHZ_d0p[0][0] = cmplx(m+B*(2-cos(kx)-cos(ky))-mu,0)
	QHZ_d0p[0][1] = cmplx(A*sin(kx),-A*sin(ky))
	QHZ_d0p[1][0] = cmplx(A*sin(kx),A*sin(ky))
	QHZ_d0p[1][1] = cmplx(-m-B*(2-cos(kx)-cos(ky))-mu,0)

	make/o/N=(2,2)/C QHZ_d0m
	QHZ_d0m[0][0] = -cmplx(m+B*(2-cos(-kx)-cos(-ky))+mu,0)
	QHZ_d0m[0][1] = -cmplx(A*sin(-kx),A*sin(-ky))
	QHZ_d0m[1][0] = -cmplx(A*sin(-kx),-A*sin(-ky))
	QHZ_d0m[1][1] = -cmplx(-m-B*(2-cos(-kx)-cos(-ky))+mu,0)
end

Function QHZ_d0pBerryCurvaturemu(numxy,m,u)
	variable numxy //= 100
	variable m,u

	variable kx
	variable ky
	variable i,j

	//Variable timerRefNum
	//timerRefNum = StartMSTimer

	//** Make void matrix for spectral function
		make/o/n=(numxy,numxy,1) voidberry_QHZ_d0p
		setscale/i x,-pi,pi,"",voidberry_QHZ_d0p
		setscale/i y,-pi,pi,"",voidberry_QHZ_d0p
		//setscale/i z,-2.5,4.5,"",voidberry_QHZ_d0p
		voidberry_QHZ_d0p = 0

	//** Make void matrix for Berry curvature band #1 (lower) and #2 (higher)
		make/o/n=(numxy,numxy) BC_QHZ_d0p1
		setscale/i x,-pi,pi,"",BC_QHZ_d0p1
		setscale/i y,-pi,pi,"",BC_QHZ_d0p1
		BC_QHZ_d0p1 = 0//cmplx(0,0)

		make/o/n=(numxy,numxy) BC_QHZ_d0p2
		setscale/i x,-pi,pi,"",BC_QHZ_d0p2
		setscale/i y,-pi,pi,"",BC_QHZ_d0p2
		BC_QHZ_d0p2 = 0//cmplx(0,0)

	//** Pointer String for called Functions
		string W_eigenvalues="W_eigenvalues"
		string QHZ_d0pH = "QHZ_d0p"
		string M_R_eigenVectors = "M_R_eigenVectors"
		string M_product = "M_product"

	//** variable for Berry curvature
		variable E1k, E2K //1 for low band, 2 for high band
		variable delta = 10^-6
		variable/C Berryterm1A = cmplx(0,0)
		variable/C Berryterm1B = cmplx(0,0)

		variable/C Berryterm2A = cmplx(0,0)
		variable/C Berryterm2B = cmplx(0,0)

	//** Start loop for (kx, ky)
		i=0
		do
			j=0
			do
				//** Define kx, ky by void matrix shape
					kx = dimoffset(voidberry_QHZ_d0p,0)+i*dimdelta(voidberry_QHZ_d0p,0)
					ky = dimoffset(voidberry_QHZ_d0p,1)+j*dimdelta(voidberry_QHZ_d0p,1)

					QHZd0mu(kx, ky,m,u)
					wave/C QHZ_d0pHw = $QHZ_d0pH

				//** Solve eigenvalue of QHZ_d0p Hamiltonian

					matrixEigenV/R QHZ_d0pHw
					wave/C n=$W_eigenvalues
					wave/C eignevector=$M_R_eigenVectors

					make/n=(dimsize(QHZ_d0pHw,0))/o sorteigen

					sorteigen[0]= real(N[0])
					sorteigen[1]= real(N[1])

				//**Sort eigenvalue and eigenvector
					make/o/n=(dimsize(QHZ_d0pHw,0)) sortindex
					sortindex=p
					sort sorteigen sortindex //the value indicates the column number in M_R_eigenVectors belong to each eigenvalue labeled in sorteigen
					sort sorteigen sorteigen

				//** Calculat Berry Curvature

					//## E1,k = sorteigen[0]
					//## |u1,k> = eignevector[][sortindex[0]]

					//## E2,k = sorteigen[1]
					//## |u2,k> = eignevector[][sortindex[1]]


					//** get eigenvalue
						E1k = sorteigen[0]
						E2k = sorteigen[1]

					//** make |u1,k>
						//|ket>
						make/n=(dimsize(QHZ_d0pHw,0),1)/o/C u1k_ket
						u1k_ket[] = eignevector[p][sortindex[0]]
						//<bra|
						duplicate/o/c u1k_ket u1k_bra
						matrixtranspose/H u1k_bra

					//** make |u2,k>
						//|ket>
						make/n=(dimsize(QHZ_d0pHw,0),1)/o/C u2k_ket
						u2k_ket[] = eignevector[p][sortindex[1]]
						//<bra|
						duplicate/o/c u2k_ket u2k_bra
						matrixtranspose/H u2k_bra

					//** make dH/dx(k)
						duplicate/o/c QHZ_d0pHw QHZ_d0pHworigin

						QHZd0mu(kx+delta, ky,m,u)
						wave/C QHZ_d0pHw = $QHZ_d0pH
						duplicate/o/c QHZ_d0pHw dHdx
						dHdx = (QHZ_d0pHw - QHZ_d0pHworigin)/delta

					//** make dH/dy(k)
						QHZd0mu(kx, ky+delta,m,u)
						wave/C QHZ_d0pHw = $QHZ_d0pH
						duplicate/o/c QHZ_d0pHw dHdy
						dHdy = (QHZ_d0pHw - QHZ_d0pHworigin)/delta
						killwaves QHZ_d0pHworigin QHZ_d0pHw

					//** calculate Omega_1

						matrixMultiply u1k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm1A =  M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1A *= M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm1B =  M_productw[0][0]

						matrixMultiply u2k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1B *=  M_productw[0][0]

						Berryterm1A -= Berryterm1B
						Berryterm1A /= (E1k-E2k)^2
						Berryterm1A *= cmplx(0,1)

						//BC_QHZ_d0p1[i][j] = sqrt(magsqr(Berryterm1A))
						BC_QHZ_d0p1[i][j] = real(Berryterm1A)

					//** calculate Omega_2

						matrixMultiply u2k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm2A =  M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2A *= M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm2B =  M_productw[0][0]

						matrixMultiply u1k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2B *=  M_productw[0][0]

						Berryterm2A -= Berryterm2B
						Berryterm2A /= (E1k-E2k)^2
						Berryterm2A *= cmplx(0,1)

						//BC_QHZ_d0p2[i][j] = sqrt(magsqr(Berryterm2A))
						BC_QHZ_d0p2[i][j] = real(Berryterm2A)

				j+=1
			while(j < dimsize(voidberry_QHZ_d0p,1))
			i+=1
		while(i < dimsize(voidberry_QHZ_d0p,0))
	killwaves voidberry_QHZ_d0p n sorteigen eignevector sortindex u1k_ket u1k_bra u2k_ket u2k_bra dHdx dHdy QHZ_d0pHworigin QHZ_d0pHw M_productw
	//di(BC_QHZ_d0p1)
	//ModifyImage BC_QHZ_d0p1 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0}
	//di(BC_QHZ_d0p2)
	//ModifyImage BC_QHZ_d0p2 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0}
	TextBox/C/N=text3/F=0/B=1/A=RT/X=3/Y=9 "Z(Δ=0,+) = "+num2str(ChernN_QHZ(BC_QHZ_d0p1))

	//Print "//*************************************                "
	//Print "		The parameters (t1,t2,M,phi) are ("+num2str(t1)+","+num2str(t2)+","+num2str(M)+","+num2str(phi)+")"
	//Print "		h+(#1): Z = "+num2str(ChernN_QHZ(BC_QHZ_d0p1))
	//Print "		h+(#2): Z = "+num2str(ChernN_QHZ(BC_QHZ_d0p2))
	//variable Seconds = StopMSTimer(timerRefNum)/10^6
	//Print "		Total Time Running: "+num2str(Seconds)+" (s)"
end

Function QHZ_d0mBerryCurvaturemu(numxy,m,u)
	variable numxy,m,u //= 100

	variable kx
	variable ky
	variable i,j

	//Variable timerRefNum
	//timerRefNum = StartMSTimer

	//** Make void matrix for spectral function
		make/o/n=(numxy,numxy,1) voidberry_QHZ_d0m
		setscale/i x,-pi,pi,"",voidberry_QHZ_d0m
		setscale/i y,-pi,pi,"",voidberry_QHZ_d0m
		//setscale/i z,-2.5,4.5,"",voidberry_QHZ_d0m
		voidberry_QHZ_d0m = 0

	//** Make void matrix for Berry curvature band #1 (lower) and #2 (higher)
		make/o/n=(numxy,numxy) BC_QHZ_d0m1
		setscale/i x,-pi,pi,"",BC_QHZ_d0m1
		setscale/i y,-pi,pi,"",BC_QHZ_d0m1
		BC_QHZ_d0m1 = 0//cmplx(0,0)

		make/o/n=(numxy,numxy) BC_QHZ_d0m2
		setscale/i x,-pi,pi,"",BC_QHZ_d0m2
		setscale/i y,-pi,pi,"",BC_QHZ_d0m2
		BC_QHZ_d0m2 = 0//cmplx(0,0)

	//** Pointer String for called Functions
		string W_eigenvalues="W_eigenvalues"
		string QHZ_d0mH = "QHZ_d0m"
		string M_R_eigenVectors = "M_R_eigenVectors"
		string M_product = "M_product"

	//** variable for Berry curvature
		variable E1k, E2K //1 for low band, 2 for high band
		variable delta = 10^-6
		variable/C Berryterm1A = cmplx(0,0)
		variable/C Berryterm1B = cmplx(0,0)

		variable/C Berryterm2A = cmplx(0,0)
		variable/C Berryterm2B = cmplx(0,0)

	//** Start loop for (kx, ky)
		i=0
		do
			j=0
			do
				//** Define kx, ky by void matrix shape
					kx = dimoffset(voidberry_QHZ_d0m,0)+i*dimdelta(voidberry_QHZ_d0m,0)
					ky = dimoffset(voidberry_QHZ_d0m,1)+j*dimdelta(voidberry_QHZ_d0m,1)

					QHZd0mu(kx, ky,m,u)
					wave/C QHZ_d0mHw = $QHZ_d0mH

				//** Solve eigenvalue of QHZ_d0m Hamiltonian

					matrixEigenV/R QHZ_d0mHw
					wave/C n=$W_eigenvalues
					wave/C eignevector=$M_R_eigenVectors

					make/n=(dimsize(QHZ_d0mHw,0))/o sorteigen

					sorteigen[0]= real(N[0])
					sorteigen[1]= real(N[1])

				//**Sort eigenvalue and eigenvector
					make/o/n=(dimsize(QHZ_d0mHw,0)) sortindex
					sortindex=p
					sort sorteigen sortindex //the value indicates the column number in M_R_eigenVectors belong to each eigenvalue labeled in sorteigen
					sort sorteigen sorteigen

				//** Calculat Berry Curvature

					//## E1,k = sorteigen[0]
					//## |u1,k> = eignevector[][sortindex[0]]

					//## E2,k = sorteigen[1]
					//## |u2,k> = eignevector[][sortindex[1]]


					//** get eigenvalue
						E1k = sorteigen[0]
						E2k = sorteigen[1]

					//** make |u1,k>
						//|ket>
						make/n=(dimsize(QHZ_d0mHw,0),1)/o/C u1k_ket
						u1k_ket[] = eignevector[p][sortindex[0]]
						//<bra|
						duplicate/o/c u1k_ket u1k_bra
						matrixtranspose/H u1k_bra

					//** make |u2,k>
						//|ket>
						make/n=(dimsize(QHZ_d0mHw,0),1)/o/C u2k_ket
						u2k_ket[] = eignevector[p][sortindex[1]]
						//<bra|
						duplicate/o/c u2k_ket u2k_bra
						matrixtranspose/H u2k_bra

					//** make dH/dx(k)
						duplicate/o/c QHZ_d0mHw QHZ_d0mHworigin

						QHZd0mu(kx+delta, ky,m,u)

						wave/C QHZ_d0mHw = $QHZ_d0mH
						duplicate/o/c QHZ_d0mHw dHdx
						dHdx = (QHZ_d0mHw - QHZ_d0mHworigin)/delta

					//** make dH/dy(k)
						QHZd0mu(kx, ky+delta,m,u)
						wave/C QHZ_d0mHw = $QHZ_d0mH
						duplicate/o/c QHZ_d0mHw dHdy
						dHdy = (QHZ_d0mHw - QHZ_d0mHworigin)/delta
						killwaves QHZ_d0mHworigin QHZ_d0mHw

					//** calculate Omega_1

						matrixMultiply u1k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm1A =  M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1A *= M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm1B =  M_productw[0][0]

						matrixMultiply u2k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1B *=  M_productw[0][0]

						Berryterm1A -= Berryterm1B
						Berryterm1A /= (E1k-E2k)^2
						Berryterm1A *= cmplx(0,1)

						//BC_QHZ_d0m1[i][j] = sqrt(magsqr(Berryterm1A))
						BC_QHZ_d0m1[i][j] = real(Berryterm1A)

					//** calculate Omega_2

						matrixMultiply u2k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm2A =  M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2A *= M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm2B =  M_productw[0][0]

						matrixMultiply u1k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2B *=  M_productw[0][0]

						Berryterm2A -= Berryterm2B
						Berryterm2A /= (E1k-E2k)^2
						Berryterm2A *= cmplx(0,1)

						//BC_QHZ_d0m2[i][j] = sqrt(magsqr(Berryterm2A))
						BC_QHZ_d0m2[i][j] = real(Berryterm2A)

				j+=1
			while(j < dimsize(voidberry_QHZ_d0m,1))
			i+=1
		while(i < dimsize(voidberry_QHZ_d0m,0))
	killwaves voidberry_QHZ_d0m n sorteigen eignevector sortindex u1k_ket u1k_bra u2k_ket u2k_bra dHdx dHdy QHZ_d0mHworigin QHZ_d0mHw M_productw
	//di(BC_QHZ_d0m1)
	//ModifyImage BC_QHZ_d0m1 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0}
	//di(BC_QHZ_d0m2)
	//ModifyImage BC_QHZ_d0m2 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0}
	//Print "//*************************************                "
	//Print "		The parameters (t1,t2,M,phi) are ("+num2str(t1)+","+num2str(t2)+","+num2str(M)+","+num2str(phi)+")"
	TextBox/C/N=text2/F=0/B=1/A=RT/X=3/Y=12 "Z(Δ=0,-) = "+num2str(ChernN_QHZ(BC_QHZ_d0m1))


	//Print "		h-(#1): Z = "+num2str(ChernN_QHZ(BC_QHZ_d0m1))
	//Print "		h-(#2): Z = "+num2str(ChernN_QHZ(BC_QHZ_d0m2))
	//variable Seconds = StopMSTimer(timerRefNum)/10^6
	//Print "		Total Time Running: "+num2str(Seconds)+" (s)"
end
Function ChernN_qhz(BCname)
	wave BCname
	variable left = -pi
	variable right = pi
	variable top = pi
	variable bottom = -pi


	variable nleft = round((left-dimoffset(BCname,0))/dimdelta(BCname,0))
	variable nright = round((right-dimoffset(BCname,0))/dimdelta(BCname,0))
	variable ntop = round((top-dimoffset(BCname,1))/dimdelta(BCname,1))
	variable nbottom = round((bottom-dimoffset(BCname,1))/dimdelta(BCname,1))

	variable Sumbc = 0

	variable i,j
	i=nleft
	do
		j=nbottom
		do
			Sumbc+=BCname[i][j]
			j+=1
		while (j < ntop) // [nbottom,ntop)
		i+=1
	while (i < nright) //[nleft,nright), nleft included, but nright excluded
	variable Chernnumber

	Chernnumber = Sumbc*dimdelta(BCname,1)*dimdelta(BCname,0)/(2*pi)
	//print Chernnumber
	return Chernnumber
end
//*******************************************************************
//** Failed trails to calculate Berry phase directly on BdG
//*******************************************************************
Function QHZBerryCurvature(A,B,M,mu,ReD,ImD,numxy)
	variable A //= 1
	variable B //= 0.2
	variable M,mu,ReD,ImD //= 0.2
	variable numxy //= 100

	variable kx
	variable ky
	variable i,j

	//Variable timerRefNum
	//timerRefNum = StartMSTimer

	//** Make void matrix for spectral function
		make/o/n=(numxy,numxy,1) voidberry_QHZ
		setscale/i x,-pi,pi,"",voidberry_QHZ
		setscale/i y,-pi,pi,"",voidberry_QHZ
		//setscale/i z,-2.5,4.5,"",voidberry_QHZ
		voidberry_QHZ = 0

	//** Make void matrix for Berry curvature band #1 (lower) and #2 (higher)
		make/o/n=(numxy,numxy) BC_QHZ1
		setscale/i x,-pi,pi,"",BC_QHZ1
		setscale/i y,-pi,pi,"",BC_QHZ1
		BC_QHZ1 = 0//cmplx(0,0)

		make/o/n=(numxy,numxy) BC_QHZ2
		setscale/i x,-pi,pi,"",BC_QHZ2
		setscale/i y,-pi,pi,"",BC_QHZ2
		BC_QHZ2 = 0//cmplx(0,0)

	//** Pointer String for called Functions
		string W_eigenvalues="W_eigenvalues"
		string QHZH = "QHZH"
		string M_R_eigenVectors = "M_R_eigenVectors"
		string M_product = "M_product"

	//** variable for Berry curvature
		variable E1k, E2K, E3K, E4K //1 for low band, 2 for high band
		variable delta = 10^-6
		variable/C Berryterm1A = cmplx(0,0)
		variable/C Berryterm1B = cmplx(0,0)
		variable/C Berryterm1 = cmplx(0,0)


		variable/C Berryterm2A = cmplx(0,0)
		variable/C Berryterm2B = cmplx(0,0)
		variable/C Berryterm2 = cmplx(0,0)


	//** Start loop for (kx, ky)
		i=0
		do
			j=0
			do
				//** Define kx, ky by void matrix shape
					kx = dimoffset(voidberry_QHZ,0)+i*dimdelta(voidberry_QHZ,0)
					ky = dimoffset(voidberry_QHZ,1)+j*dimdelta(voidberry_QHZ,1)

					QHZ(A,B,m,mu,ReD,ImD,kx,ky)
					wave/C QHZHw = $QHZH

				//** Solve eigenvalue of QHZ Hamiltonian

					matrixEigenV/R QHZHw
					wave/C n=$W_eigenvalues
					wave/C eignevector=$M_R_eigenVectors

					make/n=(dimsize(QHZHw,0))/o sorteigen

					sorteigen[0]= real(N[0])
					sorteigen[1]= real(N[1])
					sorteigen[2]= real(N[2])
					sorteigen[3]= real(N[3])

				//**Sort eigenvalue and eigenvector
					make/o/n=(dimsize(QHZHw,0)) sortindex
					sortindex=p
					sort sorteigen sortindex //the value indicates the column number in M_R_eigenVectors belong to each eigenvalue labeled in sorteigen
					sort sorteigen sorteigen

				//** Calculat Berry Curvature

					//## E1,k = sorteigen[0]
					//## |u1,k> = eignevector[][sortindex[0]]

					//## E2,k = sorteigen[1]
					//## |u2,k> = eignevector[][sortindex[1]]


					//** get eigenvalue
						E1k = sorteigen[0]
						E2k = sorteigen[1]
						E3k = sorteigen[2]
						E4k = sorteigen[3]


					//** make |u1,k>
						//|ket>
						make/n=(dimsize(QHZHw,0),1)/o/C u1k_ket
						u1k_ket[] = eignevector[p][sortindex[0]]
						//<bra|
						duplicate/o/c u1k_ket u1k_bra
						matrixtranspose/H u1k_bra

					//** make |u2,k>
						//|ket>
						make/n=(dimsize(QHZHw,0),1)/o/C u2k_ket
						u2k_ket[] = eignevector[p][sortindex[1]]
						//<bra|
						duplicate/o/c u2k_ket u2k_bra
						matrixtranspose/H u2k_bra

					//** make |u3,k>
						//|ket>
						make/n=(dimsize(QHZHw,0),1)/o/C u3k_ket
						u3k_ket[] = eignevector[p][sortindex[2]]
						//<bra|
						duplicate/o/c u3k_ket u3k_bra
						matrixtranspose/H u3k_bra

					//** make |u4,k>
						//|ket>
						make/n=(dimsize(QHZHw,0),1)/o/C u4k_ket
						u4k_ket[] = eignevector[p][sortindex[3]]
						//<bra|
						duplicate/o/c u4k_ket u4k_bra
						matrixtranspose/H u4k_bra

					//** make dH/dx(k)
						duplicate/o/c QHZHw QHZHworigin

						QHZ(A,B,m,mu,ReD,ImD,kx+delta,ky)
						wave/C QHZHw = $QHZH
						duplicate/o/c QHZHw dHdx
						dHdx = (QHZHw - QHZHworigin)/delta

					//** make dH/dy(k)
						QHZ(A,B,m,mu,ReD,ImD,kx,ky+delta)
						wave/C QHZHw = $QHZH
						duplicate/o/c QHZHw dHdy
						dHdy = (QHZHw - QHZHworigin)/delta
						killwaves QHZHworigin QHZHw

					//** calculate Omega_1
						//#2
						matrixMultiply u1k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm1A =  M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1A *= M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm1B =  M_productw[0][0]

						matrixMultiply u2k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1B *=  M_productw[0][0]

						Berryterm1A -= Berryterm1B
						Berryterm1A /= (E1k-E2k)^2


						Berryterm1 = Berryterm1A


						//#3
						matrixMultiply u1k_bra,dHdx,u3k_ket
						wave/C M_productw = $M_product
						Berryterm1A =  M_productw[0][0]

						matrixMultiply u3k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1A *= M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u3k_ket
						wave/C M_productw = $M_product
						Berryterm1B =  M_productw[0][0]

						matrixMultiply u3k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1B *=  M_productw[0][0]

						Berryterm1A -= Berryterm1B
						Berryterm1A /= (E1k-E3k)^2

						Berryterm1 += Berryterm1A


						//#4
						matrixMultiply u1k_bra,dHdx,u4k_ket
						wave/C M_productw = $M_product
						Berryterm1A =  M_productw[0][0]

						matrixMultiply u4k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1A *= M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u4k_ket
						wave/C M_productw = $M_product
						Berryterm1B =  M_productw[0][0]

						matrixMultiply u4k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm1B *=  M_productw[0][0]

						Berryterm1A -= Berryterm1B
						Berryterm1A /= (E1k-E4k)^2

						Berryterm1 += Berryterm1A



						Berryterm1 *= cmplx(0,1)

						BC_QHZ1[i][j] = real(Berryterm1)

					//** calculate Omega_2

						//#1
						matrixMultiply u2k_bra,dHdx,u1k_ket
						wave/C M_productw = $M_product
						Berryterm2A =  M_productw[0][0]

						matrixMultiply u1k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2A *= M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u1k_ket
						wave/C M_productw = $M_product
						Berryterm2B =  M_productw[0][0]

						matrixMultiply u1k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2B *=  M_productw[0][0]

						Berryterm2A -= Berryterm2B
						Berryterm2A /= (E1k-E2k)^2


						Berryterm2 = Berryterm2A

						//#3
						matrixMultiply u2k_bra,dHdx,u3k_ket
						wave/C M_productw = $M_product
						Berryterm2A =  M_productw[0][0]

						matrixMultiply u3k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2A *= M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u3k_ket
						wave/C M_productw = $M_product
						Berryterm2B =  M_productw[0][0]

						matrixMultiply u3k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2B *=  M_productw[0][0]

						Berryterm2A -= Berryterm2B
						Berryterm2A /= (E1k-E3k)^2


						Berryterm2 += Berryterm2A


						//#4
						matrixMultiply u2k_bra,dHdx,u4k_ket
						wave/C M_productw = $M_product
						Berryterm2A =  M_productw[0][0]

						matrixMultiply u4k_bra,dHdy,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2A *= M_productw[0][0]

						matrixMultiply u2k_bra,dHdy,u4k_ket
						wave/C M_productw = $M_product
						Berryterm2B =  M_productw[0][0]

						matrixMultiply u4k_bra,dHdx,u2k_ket
						wave/C M_productw = $M_product
						Berryterm2B *=  M_productw[0][0]

						Berryterm2A -= Berryterm2B
						Berryterm2A /= (E1k-E4k)^2


						Berryterm2 += Berryterm2A


						Berryterm2A *= cmplx(0,1)

						//BC_QHZ2[i][j] = sqrt(magsqr(Berryterm2A))
						BC_QHZ2[i][j] = real(Berryterm2)

				j+=1
			while(j < dimsize(voidberry_QHZ,1))
			i+=1
		while(i < dimsize(voidberry_QHZ,0))
	killwaves voidberry_QHZ n sorteigen eignevector sortindex u1k_ket u1k_bra u2k_ket u2k_bra dHdx dHdy QHZHworigin QHZHw M_productw
	di(BC_QHZ1)
	ModifyImage BC_QHZ1 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0}
	di(BC_QHZ2)
	ModifyImage BC_QHZ2 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0}
	Print "//*************************************                "
	//Print "		The parameters (A,B,M,phi) are ("+num2str(A)+","+num2str(B)+","+num2str(M)+","+num2str(mu)+","+num2str(ReD)+","+num2str(ImD)+")"
	Print "		Chern Number for band #1 is "+num2str(ChernN_QHZ(BC_QHZ1))
	Print "		Chern Number for band #2 is "+num2str(ChernN_QHZ(BC_QHZ2))
	//variable Seconds = StopMSTimer(timerRefNum)/10^6
	//Print "		Total Time Running: "+num2str(Seconds)+" (s)"
end
Function QHZBCFukui(A,B,m,mu,ReD,ImD,numxy)
	variable A,B,m,mu,ReD,ImD
	variable numxy //= 100

	variable kx
	variable ky
	variable i,j

	Variable timerRefNum
	timerRefNum = StartMSTimer
	//** Make void matrix for spectral function
		make/o/n=(numxy,numxy,1) voidberry_QHZ
		setscale/i x,-pi,pi,"",voidberry_QHZ
		setscale/i y,-pi,pi,"",voidberry_QHZ
		//setscale/i z,-2.5,4.5,"",voidberry_QHZ
		voidberry_QHZ = 0

	//** Make void matrix for Berry curvature band #1 (lower) and #2 (higher)
		make/o/n=(numxy,numxy) BC_QHZ1
		setscale/i x,-pi,pi,"",BC_QHZ1
		setscale/i y,-pi,pi,"",BC_QHZ1
		BC_QHZ1 = 0//cmplx(0,0)

		make/o/n=(numxy,numxy) BC_QHZ2
		setscale/i x,-pi,pi,"",BC_QHZ2
		setscale/i y,-pi,pi,"",BC_QHZ2
		BC_QHZ2 = 0//cmplx(0,0)

	//** Pointer String for called Functions
		string W_eigenvalues="W_eigenvalues"
		string QHZH = "QHZH"
		string M_R_eigenVectors = "M_R_eigenVectors"
		string M_product = "M_product"

	//** variable for Berry curvature

		variable/C Berry1 = cmplx(0,0)

		variable/C Berry2 = cmplx(0,0)

		variable/C Uxx1, Uxy1, Uyx1, Uyy1
		variable normUxx1,normUxy1,normUyx1,normUyy1

		variable/C Uxx2, Uxy2, Uyx2, Uyy2
		variable normUxx2,normUxy2,normUyx2,normUyy2
		variable dxdy = (dimdelta(voidberry_QHZ,1)*dimdelta(voidberry_QHZ,0))

	//** Start loop for (kx, ky)
		i=0
		do
			j=0
			do
				//** Define kx, ky by void matrix shape
					kx = dimoffset(voidberry_QHZ,0)+i*dimdelta(voidberry_QHZ,0)
					ky = dimoffset(voidberry_QHZ,1)+j*dimdelta(voidberry_QHZ,1)

				// (kx,ky)
					QHZ(A,B,m,mu,ReD,ImD,kx,ky)
					wave/C QHZHw = $QHZH
					matrixEigenV/R QHZHw
					wave/C n=$W_eigenvalues
					wave/C eignevector=$M_R_eigenVectors
					make/n=(dimsize(QHZHw,0))/o sorteigen
					sorteigen[0]= real(N[0])
					sorteigen[1]= real(N[1])
					make/o/n=(dimsize(QHZHw,0)) sortindex
					sortindex=p
					sort sorteigen sortindex //the value indicates the column number in M_R_eigenVectors belong to each eigenvalue labeled in sorteigen
					sort sorteigen sorteigen
					//** make |u1,k>
						//|ket>
						make/n=(dimsize(QHZHw,0),1)/o/C u1k_ket
						u1k_ket[] = eignevector[p][sortindex[0]]
						//<bra|
						duplicate/o/c u1k_ket u1k_bra
						matrixtranspose/H u1k_bra
					//** make |u2,k>
						//|ket>
						make/n=(dimsize(QHZHw,0),1)/o/C u2k_ket
						u2k_ket[] = eignevector[p][sortindex[1]]
						//<bra|
						duplicate/o/c u2k_ket u2k_bra
						matrixtranspose/H u2k_bra

				// (kx+d,ky)
					QHZ(A,B,m,mu,ReD,ImD,kx+dimdelta(voidberry_QHZ,0),ky)
					wave/C QHZHw = $QHZH
					matrixEigenV/R QHZHw
					wave/C n=$W_eigenvalues
					wave/C eignevector=$M_R_eigenVectors
					make/n=(dimsize(QHZHw,0))/o sorteigen
					sorteigen[0]= real(N[0])
					sorteigen[1]= real(N[1])
					make/o/n=(dimsize(QHZHw,0)) sortindex
					sortindex=p
					sort sorteigen sortindex //the value indicates the column number in M_R_eigenVectors belong to each eigenvalue labeled in sorteigen
					sort sorteigen sorteigen
					//** make |u1,k+dx>
						//|ket>
						make/n=(dimsize(QHZHw,0),1)/o/C u1kdx_ket
						u1kdx_ket[] = eignevector[p][sortindex[0]]
						//<bra|
						duplicate/o/c u1kdx_ket u1kdx_bra
						matrixtranspose/H u1kdx_bra
					//** make |u2,k+dx>
						//|ket>
						make/n=(dimsize(QHZHw,0),1)/o/C u2kdx_ket
						u2kdx_ket[] = eignevector[p][sortindex[1]]
						//<bra|
						duplicate/o/c u2kdx_ket u2kdx_bra
						matrixtranspose/H u2kdx_bra

				// (kx,ky+d)
					QHZ(A,B,m,mu,ReD,ImD,kx,ky+dimdelta(voidberry_QHZ,1))
					wave/C QHZHw = $QHZH
					matrixEigenV/R QHZHw
					wave/C n=$W_eigenvalues
					wave/C eignevector=$M_R_eigenVectors
					make/n=(dimsize(QHZHw,0))/o sorteigen
					sorteigen[0]= real(N[0])
					sorteigen[1]= real(N[1])
					make/o/n=(dimsize(QHZHw,0)) sortindex
					sortindex=p
					sort sorteigen sortindex //the value indicates the column number in M_R_eigenVectors belong to each eigenvalue labeled in sorteigen
					sort sorteigen sorteigen
					//** make |u1,k+dy>
						//|ket>
						make/n=(dimsize(QHZHw,0),1)/o/C u1kdy_ket
						u1kdy_ket[] = eignevector[p][sortindex[0]]
						//<bra|
						duplicate/o/c u1kdy_ket u1kdy_bra
						matrixtranspose/H u1kdy_bra
					//** make |u2,k+dy>
						//|ket>
						make/n=(dimsize(QHZHw,0),1)/o/C u2kdy_ket
						u2kdy_ket[] = eignevector[p][sortindex[1]]
						//<bra|
						duplicate/o/c u2kdy_ket u2kdy_bra
						matrixtranspose/H u2kdy_bra

				// (kx+d,ky+d)
					QHZ(A,B,m,mu,ReD,ImD,kx+dimdelta(voidberry_QHZ,0),ky+dimdelta(voidberry_QHZ,1))

					wave/C QHZHw = $QHZH
					matrixEigenV/R QHZHw
					wave/C n=$W_eigenvalues
					wave/C eignevector=$M_R_eigenVectors
					make/n=(dimsize(QHZHw,0))/o sorteigen
					sorteigen[0]= real(N[0])
					sorteigen[1]= real(N[1])
					make/o/n=(dimsize(QHZHw,0)) sortindex
					sortindex=p
					sort sorteigen sortindex //the value indicates the column number in M_R_eigenVectors belong to each eigenvalue labeled in sorteigen
					sort sorteigen sorteigen
					//** make |u1,k+(dx,dy)>
						//|ket>
						make/n=(dimsize(QHZHw,0),1)/o/C u1kdxdy_ket
						u1kdxdy_ket[] = eignevector[p][sortindex[0]]
						//<bra|
						duplicate/o/c u1kdxdy_ket u1kdxdy_bra
						matrixtranspose/H u1kdxdy_bra
					//** make |u2,k+(dx,dy)>
						//|ket>
						make/n=(dimsize(QHZHw,0),1)/o/C u2kdxdy_ket
						u2kdxdy_ket[] = eignevector[p][sortindex[1]]
						//<bra|
						duplicate/o/c u2kdxdy_ket u2kdxdy_bra
						matrixtranspose/H u2kdxdy_bra

				//Uxx1
					matrixMultiply u1k_bra,u1kdx_ket
					wave/C M_productw = $M_product
					normuxx1 = abs(sqrt(real(M_productw[0][0])^2+imag(M_productw[0][0])^2))
					Uxx1 = M_productw[0][0]/normuxx1

				//Uxy1
					matrixMultiply u1kdy_bra,u1kdxdy_ket
					wave/C M_productw = $M_product
					normUxy1 = abs(sqrt(real(M_productw[0][0])^2+imag(M_productw[0][0])^2))
					Uxy1 = M_productw[0][0]/normuxy1

				//Uyx1
					matrixMultiply u1kdx_bra,u1kdxdy_ket
					wave/C M_productw = $M_product
					normUyx1 = abs(sqrt(real(M_productw[0][0])^2+imag(M_productw[0][0])^2))
					Uyx1 = M_productw[0][0]/normuyx1

				//Uyy1
					matrixMultiply u1k_bra,u1kdy_ket
					wave/C M_productw = $M_product
					normuyy1 = abs(sqrt(real(M_productw[0][0])^2+imag(M_productw[0][0])^2))
					Uyy1 = M_productw[0][0]/normuyy1

				//Uxx2
					matrixMultiply u2k_bra,u2kdx_ket
					wave/C M_productw = $M_product
					normuxx2 = abs(sqrt(real(M_productw[0][0])^2+imag(M_productw[0][0])^2))
					Uxx2 = M_productw[0][0]/normuxx2

				//Uxy2
					matrixMultiply u2kdy_bra,u2kdxdy_ket
					wave/C M_productw = $M_product
					normUxy2 = abs(sqrt(real(M_productw[0][0])^2+imag(M_productw[0][0])^2))
					Uxy2 = M_productw[0][0]/normuxy2

				//Uyx2
					matrixMultiply u2kdx_bra,u2kdxdy_ket
					wave/C M_productw = $M_product
					normUyx2 = abs(sqrt(real(M_productw[0][0])^2+imag(M_productw[0][0])^2))
					Uyx2 = M_productw[0][0]/normuyx2

				//Uyy2
					matrixMultiply u2k_bra,u2kdy_ket
					wave/C M_productw = $M_product
					normuyy2 = abs(sqrt(real(M_productw[0][0])^2+imag(M_productw[0][0])^2))
					Uyy2 = M_productw[0][0]/normuyy2

				//** calculate Omega_1
					Berry1 = ln(Uxx1*Uyx1/(Uxy1*Uyy1))*cmplx(0,1)/dxdy
					BC_QHZ1[i][j] = real(Berry1)

				//** calculate Omega_2
					Berry2 = ln(Uxx2*Uyx2/(Uxy2*Uyy2))*cmplx(0,1)/dxdy
					BC_QHZ2[i][j] = real(Berry2)

				j+=1
			while(j < dimsize(voidberry_QHZ,1))
			i+=1
		while(i < dimsize(voidberry_QHZ,0))
	killwaves voidberry_QHZ n sorteigen eignevector sortindex u1k_ket u1k_bra u2k_ket u2k_bra  QHZHw M_productw u1kdx_ket u1kdy_ket u1kdxdy_ket u1kdx_bra u1kdy_bra u1kdxdy_bra u2kdx_ket u2kdy_ket u2kdxdy_ket u2kdx_bra u2kdy_bra u2kdxdy_bra
	di(BC_QHZ1)
	ModifyImage BC_QHZ1 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0}
	di(BC_QHZ2)
	ModifyImage BC_QHZ2 ctab= {*,*,:Packages:NewColortable:dvg_seismic,0}
	//Print "//*************************************                "
	//Print "		The parameters (t1,t2,M,phi) are ("+num2str(t1)+","+num2str(t2)+","+num2str(M)+","+num2str(phi)+")"
	//Print "		Chern Number for band #1 is "+num2str(sum(BC_QHZ1)*dimdelta(BC_QHZ1,1)*dimdelta(BC_QHZ1,0)/(2*pi))
	//Print "		Chern Number for band #2 is "+num2str(sum(BC_QHZ2)*dimdelta(BC_QHZ2,1)*dimdelta(BC_QHZ2,0)/(2*pi))
	//Print "		Chern Number for all is "+num2str(sum(BC_QHZ1)*dimdelta(BC_QHZ1,1)*dimdelta(BC_QHZ1,0)/(2*pi)+sum(BC_QHZ2)*dimdelta(BC_QHZ2,1)*dimdelta(BC_QHZ2,0)/(2*pi))

	Print "		Chern Number for band #1 is "+num2str(ChernN_qhz(BC_QHZ1))
	Print "		Chern Number for band #2 is "+num2str(ChernN_qhz(BC_QHZ2))
	Print "		Chern Number for all is "+num2str(ChernN_qhz(BC_QHZ1)+ChernN_qhz(BC_QHZ2))

	//variable Seconds = StopMSTimer(timerRefNum)/10^6
	//Print "		Total Time Running: "+num2str(Seconds)+" (s)"
end

/////////////////////////////////////////////////////////////////////
//** Calculate Edge mode, slab calculation
//** Edge Hamiltonian of QHZ model
//** edge along kx, kx is good quamtum number, ky direction become slab.

//## 01 S [real]
Function/wave QHZedgeH1(A,B,m,mu,ReD,ImD,kx,nslab)
	variable A,B,m,mu,ReD,ImD,kx,nslab
		make/n=(4,4)/o hnn
		hnn = {{2*B+m-mu-B*Cos(kx),A*Sin(kx),0, ReD}, {A*Sin(kx), -2*B-m-mu+B*Cos(kx), -ReD,0}, {0,-ReD,-2*B-m+mu+B*Cos(kx),A*Sin(kx)}, {ReD,0,A*Sin(kx),2*B+m+mu-B*Cos(kx)}}
		make/n=(4,4)/o hnn_super
		hnn_super = {{-B/2, A/2, 0, 0}, {-(A/2), B/2, 0, 0}, {0, 0, B/2, -(A/2)}, {0, 0, A/2, -B/2}}
		make/n=(4,4)/o hnn_sub
		hnn_sub = {{-B/2, -(A/2), 0, 0}, {A/2, B/2, 0, 0}, {0, 0, B/2, A/2}, {0, 0, -(A/2), -B/2}}
		mpn(diagM(nslab),hnn)
		wave prod = $"prod"
		duplicate/o prod p1
		mpn(superdiagM(nslab),hnn_super)
		wave prod = $"prod"
		duplicate/o prod p2
		mpn(subdiagM(nslab),hnn_sub)
		wave prod = $"prod"
		duplicate/o prod p3
		duplicate/o prod QHZedge
		QHZedge = p1 + p2 +p3
		return QHZedge
	//killwaves prod, p1, p2, p3
end

//## 02 S+iS [complex]
Function/wave QHZedgeH2(A,B,m,mu,ReD,ImD,kx,nslab)
	variable A,B,m,mu,ReD,ImD,kx,nslab
		make/n=(4,4)/o/C hnn
		hnn = {{2*B+m-mu-B*Cos(kx),A*Sin(kx),0, cmplx(ReD,-ImD)}, {A*Sin(kx), -2*B-m-mu+B*Cos(kx), cmplx(-ReD,ImD),0}, {0,cmplx(-ReD,-ImD),-2*B-m+mu+B*Cos(kx),A*Sin(kx)}, {cmplx(ReD,ImD),0,A*Sin(kx),2*B+m+mu-B*Cos(kx)}}
		make/n=(4,4)/o/C hnn_super
		hnn_super = {{-B/2, A/2, 0, 0}, {-(A/2), B/2, 0, 0}, {0, 0, B/2, -(A/2)}, {0, 0, A/2, -B/2}}
		make/n=(4,4)/o/C hnn_sub
		hnn_sub = {{-B/2, -(A/2), 0, 0}, {A/2, B/2, 0, 0}, {0, 0, B/2, A/2}, {0, 0, -(A/2), -B/2}}
		mpc(diagM_cmplx(nslab),hnn)
		wave/C prod = $"prod"
		duplicate/o/C prod p1
		mpc(superdiagM_cmplx(nslab),hnn_super)
		wave/C prod = $"prod"
		duplicate/o/C prod p2
		mpc(subdiagM_cmplx(nslab),hnn_sub)
		wave/C prod = $"prod"
		duplicate/o/C prod p3
		duplicate/o/C prod QHZedge
		QHZedge = p1 + p2 +p3
		return QHZedge
	//killwaves prod, p1, p2, p3
end

//## 03 P+iP [real]
Function/wave QHZedgeH3(A,B,m,mu,ReD,ImD,kx,nslab)
	variable A,B,m,mu,ReD,ImD,kx,nslab
		make/n=(4,4)/o hnn
		hnn = {{2*B+m-mu-B*Cos(kx),A*Sin(kx),0, ReD*Sin(kx)}, {A*Sin(kx),-2*B-m-mu+B*Cos(kx),-ReD*Sin(kx),0}, {0,-ReD*Sin(kx),-2*B-m+mu+B*Cos(kx),A*Sin(kx)}, {ReD*Sin(kx),0,A*Sin(kx),2*B+m+mu-B*Cos(kx)}}
		make/n=(4,4)/o hnn_super
		hnn_super = {{-(B/2),A/2,0,-(ReD/2)}, {-(A/2),B/2,ReD/2,0}, {0,-(ReD/2),B/2,-(A/2)}, {ReD/2,0,A/2,-(B/2)}}
		make/n=(4,4)/o hnn_sub
		hnn_sub = {{-(B/2),-(A/2),0,ReD/2}, {A/2,B/2,-(ReD/2),0}, {0,ReD/2,B/2,A/2}, {-(ReD/2),0,-(A/2),-(B/2)}}
		mpn(diagM(nslab),hnn)
		wave prod = $"prod"
		duplicate/o prod p1
		mpn(superdiagM(nslab),hnn_super)
		wave prod = $"prod"
		duplicate/o prod p2
		mpn(subdiagM(nslab),hnn_sub)
		wave prod = $"prod"
		duplicate/o prod p3
		duplicate/o prod QHZedge
		QHZedge = p1 + p2 +p3
		return QHZedge
end

//## 04 S± [real]
Function/wave QHZedgeH4(A,B,m,mu,ReD,ImD,kx,nslab)
	variable A,B,m,mu,ReD,ImD,kx,nslab
		make/n=(4,4)/o hnn
		hnn = {{2*B+m-mu-B*Cos(kx),A*Sin(kx),0,0},{A*Sin(kx),-2*B-m-mu+B*Cos(kx),0,0},{0,0,-2*B-m+mu+B*Cos(kx),A*Sin(kx)},{0,0,A*Sin(kx),2*B+m+mu-B*Cos(kx)}}
		make/n=(4,4)/o hnn_super
		hnn_super = {{-(B/2),A/2,0,ReD*Cos(kx)/2},{-(A/2),B/2,-ReD*Cos(kx)/2,0},{0,-ReD*Cos(kx)/2,B/2,-(A/2)},{ReD*Cos(kx)/2,0,A/2,-(B/2)}}
		make/n=(4,4)/o hnn_sub
		hnn_sub = {{-(B/2),-(A/2),0,ReD*Cos(kx)/2},{A/2,B/2,-ReD*Cos(kx)/2,0},{0,-ReD*Cos(kx)/2,B/2,A/2},{ReD*Cos(kx)/2,0,-(A/2),-(B/2)}}
		mpn(diagM(nslab),hnn)
		wave prod = $"prod"
		duplicate/o prod p1
		mpn(superdiagM(nslab),hnn_super)
		wave prod = $"prod"
		duplicate/o prod p2
		mpn(subdiagM(nslab),hnn_sub)
		wave prod = $"prod"
		duplicate/o prod p3
		duplicate/o prod QHZedge
		QHZedge = p1 + p2 +p3
		return QHZedge
end


//## 05 dx2-y2 [real]
Function/wave QHZedgeH5(A,B,m,mu,ReD,ImD,kx,nslab)
	variable A,B,m,mu,ReD,ImD,kx,nslab
		make/n=(4,4)/o hnn
		hnn = {{2*B+m-mu-B*Cos(kx),A*Sin(kx),0,ReD*Cos(kx)},{A*Sin(kx),-2*B-m-mu+B*Cos(kx),-ReD*Cos(kx),0},{0,-ReD*Cos(kx),-2*B-m+mu+B*Cos(kx),A*Sin(kx)},{ReD*Cos(kx),0,A*Sin(kx),2*B+m+mu-B*Cos(kx)}}
		make/n=(4,4)/o hnn_super
		hnn_super = {{-(B/2),A/2,0,-(ReD/2)},{-(A/2),B/2,ReD/2,0},{0,ReD/2,B/2,-(A/2)},{-(ReD/2),0,A/2,-(B/2)}}
		make/n=(4,4)/o hnn_sub
		hnn_sub = {{-(B/2),-(A/2),0,-(ReD/2)},{A/2,B/2,ReD/2,0},{0,ReD/2,B/2,A/2},{-(ReD/2),0,-(A/2),-(B/2)}}
		mpn(diagM(nslab),hnn)
		wave prod = $"prod"
		duplicate/o prod p1
		mpn(superdiagM(nslab),hnn_super)
		wave prod = $"prod"
		duplicate/o prod p2
		mpn(subdiagM(nslab),hnn_sub)
		wave prod = $"prod"
		duplicate/o prod p3
		duplicate/o prod QHZedge
		QHZedge = p1 + p2 +p3
		return QHZedge
end


//## 06 dxy [Complex]
Function/wave QHZedgeH6(A,B,m,mu,ReD,ImD,kx,nslab)
	variable A,B,m,mu,ReD,ImD,kx,nslab
		make/n=(4,4)/o/C hnn
		hnn = {{2*B+m-mu-B*Cos(kx),A*Sin(kx),0,0},{A*Sin(kx),-2*B-m-mu+B*Cos(kx),0,0},{0,0,-2*B-m+mu+B*Cos(kx),A*Sin(kx)},{0,0,A*Sin(kx),2*B+m+mu-B*Cos(kx)}}
		make/n=(4,4)/o/C hnn_super
		hnn_super = {{-(B/2),A/2,0, cmplx(0,-ReD*Sin(kx)/2)},{-(A/2),B/2,cmplx(0,ReD*Sin(kx)/2),0},{0,cmplx(0,ReD*Sin(kx)/2),B/2,-(A/2)},{cmplx(0,-ReD*Sin(kx)/2),0,A/2,-(B/2)}}
		make/n=(4,4)/o/C hnn_sub
		hnn_sub ={{-(B/2),-(A/2),0,cmplx(0,ReD*Sin(kx)/2)},{A/2,B/2,cmplx(0,-ReD*Sin(kx)/2),0},{0,cmplx(0,-ReD*Sin(kx)/2),B/2,A/2},{cmplx(0,ReD*Sin(kx)/2),0,-(A/2),-(B/2)}}
		mpc(diagM_cmplx(nslab),hnn)
		wave/C prod = $"prod"
		duplicate/o/C prod p1
		mpc(superdiagM_cmplx(nslab),hnn_super)
		wave/C prod = $"prod"
		duplicate/o/C prod p2
		mpc(subdiagM_cmplx(nslab),hnn_sub)
		wave/C prod = $"prod"
		duplicate/o/C prod p3
		duplicate/o/C prod QHZedge
		QHZedge = p1 + p2 +p3
		return QHZedge
	//killwaves prod, p1, p2, p3
end


//## 07 Px [real]
Function/wave QHZedgeH7(A,B,m,mu,ReD,ImD,kx,nslab)
	variable A,B,m,mu,ReD,ImD,kx,nslab
		make/n=(4,4)/o hnn
		hnn = {{2*B+m-mu-B*Cos(kx),A*Sin(kx),0,ReD*Sin(kx)},{A*Sin(kx),-2*B-m-mu+B*Cos(kx),-ReD*Sin(kx),0},{0,-ReD*Sin(kx),-2*B-m+mu+B*Cos(kx),A*Sin(kx)},{ReD*Sin(kx),0,A*Sin(kx),2*B+m+mu-B*Cos(kx)}}
		make/n=(4,4)/o hnn_super
		hnn_super = {{-(B/2),A/2,0,0},{-(A/2),B/2,0,0},{0,0,B/2,-(A/2)},{0,0,A/2,-(B/2)}}
		make/n=(4,4)/o hnn_sub
		hnn_sub = {{-(B/2),-(A/2),0,0},{A/2,B/2,0,0},{0,0,B/2,A/2},{0,0,-(A/2),-(B/2)}}
		mpn(diagM(nslab),hnn)
		wave prod = $"prod"
		duplicate/o prod p1
		mpn(superdiagM(nslab),hnn_super)
		wave prod = $"prod"
		duplicate/o prod p2
		mpn(subdiagM(nslab),hnn_sub)
		wave prod = $"prod"
		duplicate/o prod p3
		duplicate/o prod QHZedge
		QHZedge = p1 + p2 +p3
		return QHZedge
	//killwaves prod, p1, p2, p3
end

//## 08 Py [Complex]
Function/wave QHZedgeH8(A,B,m,mu,ReD,ImD,kx,nslab)
	variable A,B,m,mu,ReD,ImD,kx,nslab
		make/n=(4,4)/o/C hnn
		hnn = {{2*B+m-mu-B*Cos(kx),A*Sin(kx),0,0},{A*Sin(kx),-2*B-m-mu+B*Cos(kx),0,0},{0,0,-2*B-m+mu+B*Cos(kx),A*Sin(kx)},{0,0,A*Sin(kx),2*B+m+mu-B*Cos(kx)}}
		make/n=(4,4)/o/C hnn_super
		hnn_super = {{-(B/2),A/2,0,cmplx(0,-ReD/2)}, {-(A/2),B/2,cmplx(0,ReD/2),0}, {0,cmplx(0,ReD/2),B/2,-(A/2)}, {cmplx(0,-ReD/2),0,A/2,-(B/2)}}
		make/n=(4,4)/o/C hnn_sub
		hnn_sub = {{-(B/2),-(A/2),0,cmplx(0,ReD/2)}, {A/2,B/2,cmplx(0,-ReD/2),0}, {0,cmplx(0,-ReD/2),B/2,A/2}, {cmplx(0,ReD/2),0,-(A/2),-(B/2)}}
		mpc(diagM_cmplx(nslab),hnn)
		wave/C prod = $"prod"
		duplicate/o/C prod p1
		mpc(superdiagM_cmplx(nslab),hnn_super)
		wave/C prod = $"prod"
		duplicate/o/C prod p2
		mpc(subdiagM_cmplx(nslab),hnn_sub)
		wave/C prod = $"prod"
		duplicate/o/C prod p3
		duplicate/o/C prod QHZedge
		QHZedge = p1 + p2 +p3
		return QHZedge
	//killwaves prod, p1, p2, p3
end



Function ButtonProc_Solveedgestate_QHZc(ctrlName) : ButtonControl
	String ctrlName
	execute "Solveedgestate_QHZc()"
end
Proc Solveedgestate_QHZc(A,B,m,mu,ReD,ImD,nslab,num,mode)
	variable A = A_QHZ
	variable B = B_QHZ
	variable m = m_QHZ
	variable mu = mu_QHZ
	variable ReD = ReD_QHZ
	variable ImD = ImD_QHZ
	variable nslab = 50
	variable num = 200
	variable mode = pairmode

	prompt nslab,"Number of Slab"
	prompt num,"Number of point in k space"
	Prompt mode,"Pairing sym",popup,"s;s+is;px+ipy;s±;dx2-y2;dxy;px;py"

	if (mode == 2 || mode == 6 || mode == 8)
		Solveedgestate_QHZ_cmplx(A,B,m,mu,ReD,ImD,nslab,num)
	else
		Solveedgestate_QHZ(A,B,m,mu,ReD,ImD,nslab,num)
	endif
	displaymultiFQHZ("em",1,4*nslab)
end

Function Solveedgestate_QHZ_cmplx(A,B,m,mu,ReD,ImD,nslab,num)
	variable A,B,m,mu,ReD,ImD,nslab,num
	make/N=(num)/o temp
	setscale/I x,-1.5*pi,1.5*pi,"",temp

	variable/G pairmode


	//Create void wave for "nslab" number band
	string em
	variable ii
	ii = 0
	do
		em = "em" + num2str(ii+1)
		make/N=(num)/o $em
		setscale/I x,-1.5*pi,1.5*pi,"",$em
		ii+=1
	while (ii < 4*nslab)

	variable i,kx
	i=0
	do
		kx = dimoffset(temp,0)+i*dimdelta(temp,0)

		if (pairmode == 2) //s+is
			QHZedgeH2(A,B,m,mu,ReD,ImD,kx,nslab)
		endif
		if (pairmode == 6) //dxy
			QHZedgeH6(A,B,m,mu,ReD,ImD,kx,nslab)
		endif
		if (pairmode == 8) //py
			QHZedgeH8(A,B,m,mu,ReD,ImD,kx,nslab)
		endif

		wave/C QHZedge = $"QHZedge"


		//** Solve eigenvalue of Haldane Hamiltonian

				matrixEigenV QHZedge
				wave/C n=$"W_eigenvalues"
				make/n=(dimsize(QHZedge,0))/o sorteigen

				sorteigen=real(N)
				sort sorteigen sorteigen

				ii = 0
				do
					em = "em" + num2str(ii+1)
					wave emw = $em
					emw[i] = sorteigen[ii]
					ii+=1
				while (ii < 4*nslab)
		i+=1
	while (i < num)
	//displaymultiFQHZ("em",1,4*nslab)
end


Function  displaymultiFQHZ(dataname,from,to)
	string dataname
	variable from
	variable to

	STRING  datan,datam
	Display/N=qhzedgem
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

	modifygraph width=300,height=500
end



Function ButtonProc_QHZedge(ctrlName) : ButtonControl
	String ctrlName
	execute "Interactiveshow()"
end

Function Interactiveshow()
	Variable/G A_QHZ = 1
	Variable/G B_QHZ = 1
	Variable/G mu_QHZ //= 0
	variable/G ReD_QHZ
	variable/G ImD_QHZ
	variable/G pairmode
	wave pphs = $"phasediagramtempQHZ"
	checkDisplayed/A pphs
	//print V_flag
	if (V_flag == 0)
		display/n=QHZedgemodeshowinteractive
		modifygraph width=300,height=150
		make/o/n=(31,41) phasediagramtempQHZ
		setscale/I x,-2,2,"",phasediagramtempQHZ
		setscale/I y,0,2,"",phasediagramtempQHZ
		appendimage phasediagramtempQHZ
		Label left "\\Z16Δ"
		Label bottom "\\Z16m"
		tilewindows/WINS=winname(0,1)/R/A=(1,1)/w=(49,0,100,100)

		if (pairmode == 2 || pairmode == 6 || pairmode == 8)
			Solveedgestate_QHZ_cmplx(A_QHZ,B_QHZ,0,mu_QHZ,ReD_QHZ,ImD_QHZ,10,300)
		else
			Solveedgestate_QHZ(A_QHZ,B_QHZ,0,mu_QHZ,ReD_QHZ,ImD_QHZ,10,300)
		endif

		displaymultiFQHZ("em",1,4*10)
		modifygraph width=300,height=500
		make/o/T/N=3 lbslabQHZ
		lbslabQHZ={"-π","0","π"}
		make/o/N=3 lbslabQHZp
		lbslabQHZp={-pi,0,pi}
		ModifyGraph userticks(bottom)={lbslabQHZp,lbslabQHZ}
		tilewindows/WINS=winname(0,1)/R/A=(1,1)/w=(49,29,100,100)
		Label bottom "\\Z16k\\Bx\\M\\Z16 (Å\\S-1\\M\\Z16)"
		Label left "\\Z16Energy"

		variable i,j,xx,yy
		i=0
		do
			j=0
			do
				xx = dimoffset(phasediagramtempQHZ,0)+i*dimdelta(phasediagramtempQHZ,0)
				yy = dimoffset(phasediagramtempQHZ,1)+j*dimdelta(phasediagramtempQHZ,1)

				if (xx > 0)
					if (abs(xx) > abs(yy))
						phasediagramtempQHZ[i][j] = 1
					endif
					if (abs(xx) < abs(yy))
						phasediagramtempQHZ[i][j] = 2
					endif
				else
					if (abs(xx) > abs(yy))
						phasediagramtempQHZ[i][j] = 3
					endif
					if (abs(xx) < abs(yy))
						phasediagramtempQHZ[i][j] = 2
					endif
				endif

				j+=1
			while (j<dimsize(phasediagramtempQHZ,1))
			i+=1
		while (i<dimsize(phasediagramtempQHZ,0))
	endif

	variable/G m_QHZ
	variable pp =round((m_QHZ-dimoffset(phasediagramtempQHZ,0))/dimdelta(phasediagramtempQHZ,0))
	variable qq =round((ReD_QHZ-dimoffset(phasediagramtempQHZ,1))/dimdelta(phasediagramtempQHZ,1))
	string gpn="qhzedgem"
	variable/G xi_QHZ = -1
	variable/G LDOSEawr_QHZ

	//** Cursor moving sts
	if(V_flag == 1)
		SetWindow QHZedgemodeshowinteractive hook(myHook)=myCursorMovedHookQHZ1
		Cursor/W=QHZedgemodeshowinteractive/P/I/C=(1,65535,33232)/T=6 A phasediagramtempQHZ pp,qq
		SetWindow QHZedgemodeshowinteractive hook(myHook)=myCursorMovedHookQHZ
	endif
		//ShowInfo

	if (V_flag == 0)
		Cursor/W=QHZedgemodeshowinteractive/P/I/C=(1,65535,33232)/T=6 A phasediagramtempQHZ pp,qq
		SetWindow QHZedgemodeshowinteractive hook(myHook)=myCursorMovedHookQHZ


		SetVariable sett1_QHZ win=$gpn, title="A",size={50,16},value=A_QHZ,limits={-inf,inf,0.1},proc=SetVarProc_QHZ_bandem
		SetVariable sett2_QHZ win=$gpn, title="B",size={50,16},value=B_QHZ,limits={-inf,inf,0.1},proc=SetVarProc_QHZ_bandem
		SetVariable setphi_QHZ win=$gpn, title="μ",size={50,16},value=mu_QHZ,limits={-inf,inf,0.1},proc=SetVarProc_QHZ_bandem
		Button setHQemQHZ win=$gpn, title="HQ",proc=ButtonProc_QHZ_bandemhq,size={25,15},fSize=8//,pos={175,1}

		Button bLDOSindex win=$gpn, title="LDOS(index)",size={60,15},fSize=8,proc=ButtonProc_QHZ_LDOSindex
		Button bLDOSE win=$gpn, title="LDOS(E)",size={60,15},fSize=8,proc=ButtonProc_QHZ_LDOSE

		SetVariable bLDOSEAwrl win=$gpn, title="A(ω,k,i)",size={65,15},fSize=8,value=xi_QHZ,limits={-1,1,1},proc=SetVarProc_QHZ_LDOSEawr//,pos={212,1},

		SetVariable bLDOSEAwrlupdate win=$gpn, title="A(Update)",size={65,15},pos={1,36},fSize=8,value=LDOSEawr_QHZ,limits={0,1,1},proc=SetVarProc_QHZ_LDOSEawr//,pos={212,1},
		SetVariable bLDOSEAwrlupdate size={70,13},labelBack=(65535,65535,65535)
	endif
end

Function myCursorMovedHookQHZ(s)
	STRUCT WMWinHookStruct &s
	Variable statusCode= 0
	Variable/G A_QHZ
	Variable/G B_QHZ
	Variable/G mu_QHZ
	Variable/G m_QHZ //= m
	Variable/G ReD_QHZ
	variable/G ImD_QHZ

	Variable/G selfimg_QHZ //= selfimg
	Variable/G numxy_QHZ //= numxy
	variable/G pairmode
	variable/G LDOSEawr_QHZ
	strswitch( s.eventName )
		case "cursormoved":
			// see "Members of WMWinHookStruct Used with cursormoved Code"


			if (pairmode == 2 || pairmode == 6 || pairmode == 8)
				Solveedgestate_QHZ_cmplx(A_QHZ,B_QHZ,hcsr(A),mu_QHZ,vcsr(A),ImD_QHZ,10,300)
			else
				Solveedgestate_QHZ(A_QHZ,B_QHZ,hcsr(A),mu_QHZ,vcsr(A),ImD_QHZ,10,300)
			endif


			m_QHZ = hcsr(A)
			ReD_QHZ = vcsr(A)

			Cons_QHZcut(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,selfimg_QHZ,numxy_QHZ)
			Cons_QHZcut2(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,selfimg_QHZ,numxy_QHZ)

			if (LDOSEawr_QHZ == 1)
				effQHZ_LDOSEawr()
			endif
			break
	endswitch
	return statusCode
End

Function ButtonProc_QHZ_bandemhq(ctrlName) : ButtonControl
	String ctrlName
	Variable/G A_QHZ //= A
	Variable/G B_QHZ //= B
	Variable/G m_QHZ //= m
	Variable/G mu_QHZ //= mu
	Variable/G ReD_QHZ //= ReD
	Variable/G selfimg_QHZ //= selfimg
	Variable/G numxy_QHZ //= numxy
	variable/G ImD_QHZ
	variable/G pairmode


	if (pairmode == 2 || pairmode == 6 || pairmode == 8)
		Solveedgestate_QHZhq_cmplx(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,60,350)
	else
		Solveedgestate_QHZhq(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,60,350)
	endif

	displaymultiFQHZ("emhq",1,4*60)
	tilewindows/WINS=winname(0,1)/R/A=(1,1)/w=(74.2,29,100,100)
	make/o/T/N=3 lbslabQHZ
	lbslabQHZ={"-π","0","π"}
	make/o/N=3 lbslabQHZp
	lbslabQHZp={-pi,0,pi}
	ModifyGraph userticks(bottom)={lbslabQHZp,lbslabQHZ}
	ModifyGraph rgb($"emhq120")=(0,0,0)
	ModifyGraph rgb($"emhq121")=(0,0,0)
	ckfig(winname(0,1))
end


Function Solveedgestate_QHZhq_cmplx(A,B,m,mu,ReD,ImD,nslab,num)
	variable A,B,m,mu,ReD,ImD,nslab,num
	make/N=(num)/o temp
	setscale/I x,-1.5*pi,1.5*pi,"",temp

	variable/G pairmode
	//Create void wave for "nslab" number band
	string em
	variable ii
	ii = 0
	do
		em = "emhq" + num2str(ii+1)
		make/N=(num)/o $em
		setscale/I x,-1.5*pi,1.5*pi,"",$em
		ii+=1
	while (ii < 4*nslab)

	variable i,kx
	i=0
	do
		kx = dimoffset(temp,0)+i*dimdelta(temp,0)

		if (pairmode == 2) //s+is
			QHZedgeH2(A,B,m,mu,ReD,ImD,kx,nslab)
		endif
		if (pairmode == 6) //dxy
			QHZedgeH6(A,B,m,mu,ReD,ImD,kx,nslab)
		endif
		if (pairmode == 8) //py
			QHZedgeH8(A,B,m,mu,ReD,ImD,kx,nslab)
		endif
		wave/C QHZedge = $"QHZedge"


		//** Solve eigenvalue of Haldane Hamiltonian

				matrixEigenV QHZedge
				wave/C n=$"W_eigenvalues"
				make/n=(dimsize(QHZedge,0))/o sorteigen

				sorteigen=real(N)
				sort sorteigen sorteigen

				ii = 0
				do
					em = "emhq" + num2str(ii+1)
					wave emw = $em
					emw[i] = sorteigen[ii]
					ii+=1
				while (ii < 4*nslab)
		i+=1
	while (i < num)
	//displaymultiFQHZ("em",1,4*nslab)
end

Function SetVarProc_QHZ_bandem(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	Variable/G A_QHZ //= A
	Variable/G B_QHZ //= B
	Variable/G m_QHZ //= m
	Variable/G mu_QHZ //= mu
	Variable/G ReD_QHZ //= ReD
	Variable/G selfimg_QHZ //= selfimg
	Variable/G numxy_QHZ //= numxy
	Variable/G ImD_QHZ //= ImD
	variable/G pairmode
	//print A_QHZ, B_QHZ, m_QHZ, mu_QHZ, ReD_QHZ
	if (pairmode == 2 || pairmode == 6 || pairmode == 8)
		Solveedgestate_QHZ_cmplx(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,10,300)
	else
		Solveedgestate_QHZ(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,10,300)
	endif

	Cons_QHZcut(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,selfimg_QHZ,numxy_QHZ)
	Cons_QHZcut2(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,selfimg_QHZ,numxy_QHZ)

	variable/G LDOSEawr_QHZ
	if (LDOSEawr_QHZ == 1)
		effQHZ_LDOSEawr()
	endif
end


/////////////////////////////////////////////////////////////////////
//** Calculate the LDOS of Edge mode, continue slab calculation
///////////////////////////////////////////////////////////////////////////
//** Calculate Egienvalue index resolved LDOS
///////////////////////////////////////////////////////////////////////////
Function ButtonProc_QHZLDOSCall(ctrlName) : ButtonControl
	String ctrlName
	execute "QHZLDOSCall()"
end
Proc QHZLDOSCall(m,mu,ReD,ImD,nslab,num,Vmax,sel,mode)
	variable m = m_QHZ
	variable mu = mu_QHZ
	variable ReD = ReD_QHZ
	variable ImD = ImD_QHZ
	variable nslab = 80//= 10
	variable num = 200//= 10
	variable Vmax = 5
	variable sel
	variable mode = pairmode
	prompt nslab,"Number of Slab"
	prompt num,"Number of point in k space"
	prompt Vmax,"E(max)"
	prompt sel,"Select Mode",popup,"E;Index"
	Prompt mode,"Pairing sym",popup,"s;s+is;px+ipy;s±;dx2-y2;dxy;px;py"

	print "nslab = "+num2str(nslab)
	print "num(k) = "+num2str(num)
	variable A = A_QHZ
	variable B = B_QHZ
	variable Vmin = -Vmax

	if (sel == 2)
		QHZLDOSCindex(A,B,m,mu,ReD,ImD,nslab,num)
	endif
	if (sel == 1)
		QHZLDOSC(A,B,m,mu,ReD,ImD,nslab,num,Vmin,Vmax)
	endif
end

Proc QHZLDOSCindex(A,B,m,mu,ReD,ImD,nslab,num)
	variable A = 1
	variable B = 1
	variable m = 0
	variable mu = 0
	variable ReD = 1
	variable ImD = 0
	variable nslab = 10
	variable num = 100
	prompt nslab,"Number of Slab"
	prompt num,"Number of point in k space"

	QHZLDOSindex(A,B,m,mu,ReD,ImD,nslab,num)
end

Function QHZLDOSindex(A,B,m,mu,ReD,ImD,nslab,num)
	variable A,B,m,mu,ReD,ImD,nslab,num
	variable/G pairmode

	if (pairmode == 2 || pairmode == 6 || pairmode == 8)
		Solveslabindex_QHZ_cmplx(A,B,m,mu,ReD,ImD,nslab,num)
	else
		Solveslabindex_QHZ(A,B,m,mu,ReD,ImD,nslab,num)
	endif

	//** QHZ edge hamiltonian is 4*nslab x 4*nslab matrix
	//** except for the slab site space, there are still inner space 4x4
	//** to show purely the LDOS on different site, we need sum out each 4 coloumns
	MergeColumneach($"QHZ_eigenvector",4) // the number is the dimensinon of inner space
	di($"QHZ_eigenvector_m")
	Label Bottom "\\Z16Y (Site)"
	Label left "\\Z16Index of Eigenvalue"
end

//********************************************************
//** Function to calculate Eigenvalue index resolved LDOS
//********************************************************
Function Solveslabindex_QHZ_cmplx(A,B,m,mu,ReD,ImD,nslab,num)
	variable A,B,m,mu,ReD,ImD,nslab,num
	//** Shape of k-cycle
		make/N=(num)/o temp
		setscale/I x,-pi,pi,"",temp

	variable/G pairmode

	//** Create void wave for "nslab" number band
		string em//,em2
		em = "QHZ_eigenvector"
		make/N=(4*nslab,4*nslab)/o $em
		wave emw = $em
		emw = 0

		//em2 = "QHZ_LDOS_eignevalue"
		//make/N=(4*nslab,num)/o $em2
		//wave em2w = $em2
		//em2w = 0

	//** Run cycle for different k
		variable i,kx
		i=0
		do
			kx = dimoffset(temp,0)+i*dimdelta(temp,0)
			//** Calculate the momentum resolved LDOS(index)
				if (pairmode == 2) //s+is
					Indexofmatrix_cmplx(QHZedgeH2(A,B,m,mu,ReD,ImD,kx,nslab),0)
				endif
				if (pairmode == 6) //dxy
					Indexofmatrix_cmplx(QHZedgeH6(A,B,m,mu,ReD,ImD,kx,nslab),0)
				endif
				if (pairmode == 8) //py
					Indexofmatrix_cmplx(QHZedgeH8(A,B,m,mu,ReD,ImD,kx,nslab),0)
				endif

				wave M_R_Index2 = $"M_R_Index2"
				emw+=M_R_Index2

				//wave egv=$"egv"
				//em2w[][i]=egv[p]

			i+=1
		while (i < round(num/2))

		//** For chiral mode, we revert the energy of the middle 4 modes
			//This can avoid the mixing and left and right moving wavefunction

		//** Middle gap (two modes)
			make/N=(4*nslab)/o tempmiddle1
			make/N=(4*nslab)/o tempmiddle2
			make/N=(4*nslab)/o tempmiddle3
			make/N=(4*nslab)/o tempmiddle4

		//** Lower gap (one mode)
			make/N=(4*nslab)/o tempmiddle5
			make/N=(4*nslab)/o tempmiddle6

		//** Higher gap (one mode)
			make/N=(4*nslab)/o tempmiddle7
			make/N=(4*nslab)/o tempmiddle8


		i=round(num/2)
		do
			//** Middle gap (two modes)
			tempmiddle1[] = emw[p][2*nslab-1]
			tempmiddle2[] = emw[p][2*nslab]
			tempmiddle3[] = emw[p][2*nslab+1]
			tempmiddle4[] = emw[p][2*nslab-2]

			//** Lower gap (one mode)
			tempmiddle5[] = emw[p][nslab-1]
			tempmiddle6[] = emw[p][nslab]

			//** Higher gap (one mode)
			tempmiddle7[] = emw[p][3*nslab-1]
			tempmiddle8[] = emw[p][3*nslab]

			kx = dimoffset(temp,0)+i*dimdelta(temp,0)
				if (pairmode == 2) //s+is
					Indexofmatrix_cmplx(QHZedgeH2(A,B,m,mu,ReD,ImD,kx,nslab),0)
				endif
				if (pairmode == 6) //dxy
					Indexofmatrix_cmplx(QHZedgeH6(A,B,m,mu,ReD,ImD,kx,nslab),0)
				endif
				if (pairmode == 8) //py
					Indexofmatrix_cmplx(QHZedgeH8(A,B,m,mu,ReD,ImD,kx,nslab),0)
				endif
			wave M_R_Index2 = $"M_R_Index2"
			emw+=M_R_Index2

				//wave egv=$"egv"
				//em2w[][i]=egv[p]

			//** Replace the middle 4 modes with reverse E
			RefY(M_R_Index2)
			wave M_R_Index2 = $"M_R_Index2"

			//** Middle gap (two modes)
			emw[][2*nslab]= tempmiddle2[p]+M_R_Index2[p][2*nslab]
			emw[][2*nslab-1]= tempmiddle1[p]+M_R_Index2[p][2*nslab-1]
			emw[][2*nslab+1]= tempmiddle3[p]+M_R_Index2[p][2*nslab+1]
			emw[][2*nslab-2]= tempmiddle4[p]+M_R_Index2[p][2*nslab-2]

			//** Lower gap (one mode)
			emw[][nslab]= tempmiddle6[p]+M_R_Index2[p][nslab]
			emw[][nslab-1]= tempmiddle5[p]+M_R_Index2[p][nslab-1]

			//** Higher gap (one mode)
			emw[][3*nslab]= tempmiddle8[p]+M_R_Index2[p][3*nslab]
			emw[][3*nslab-1]= tempmiddle7[p]+M_R_Index2[p][3*nslab-1]

			i+=1
		while (i < num-1)  // [0,num-1)
	emw/=num
	killwaves temp tempmiddle1 tempmiddle2 M_R_Index2 //tempmiddle3 tempmiddle4
	//di(emw)
	//Label left "\\Z16Index of Eigenvalue"
	//Label bottom "\\Z16 Index of Eigenvector Space"
end

//********************************************************
//** Merge every several columns for a matrix
//********************************************************
Function MergeColumneach(name,each)
	wave name
	variable each

	string new = nameofwave(name)+"_m"
	make/N=(dimsize(name,0)/each,dimsize(name,1))/o $new
	wave neww = $new
	neww = 0
	variable i,j
	i=0
	do
		j=0
		do
			neww[i][]+=name[each*i+j][q]
			j+=1
		while (j< each)

		i+=1
	while(i< dimsize(name,0)/each)
	//di(neww)
	//Label left "Index of Eigenvalue"
	//Label bottom "Site of Slab (i)"
end

//********************************************************
//** Sort Column index of a matrix by ref wave
//********************************************************
Function sortColumnindex(ref,src)
	wave ref
	wave src
	make/n=(dimsize(ref,0))/o sortc
	sortc[] = p
	sort ref sortc
	sort ref ref
	duplicate/o src src2
	variable i
	i=0
	do
		src[][i]=src2[p][sortc[i]]
		i+=1
	while(i<dimsize(src,1))
	killwaves sortc src2
end

//********************************************************
//** Momentum resolved LDOS(index)
//********************************************************
Function/wave Indexofmatrix_cmplx(mat,show)
	wave mat
	variable show

	matrixEigenV/R mat;
	wave/C M_R_eigenVectors=$"M_R_eigenVectors"
	wave/C W_eigenvalues=$"W_eigenvalues"
	make/N=(dimsize(M_R_eigenVectors,0),dimsize(M_R_eigenVectors,1))/o M_R_Index2

	M_R_Index2=real(M_R_eigenVectors)^2;
	make/o/N=(dimsize(W_eigenvalues,0)) egv;
	egv=real(W_eigenvalues);
	sortColumnindex(egv,M_R_Index2)
	//killwaves egv //W_eigenvalues M_R_eigenVectors

	if (show == 1)
		di(M_R_Index2)
		Label left "Index of Eigenvalue"
		Label bottom "\\Z16 Index of Eigenvector Space"
	endif
	return M_R_Index2
end

//********************************************************
//** Momentum resolved Wavefunction(index)
//********************************************************
Function/wave WFofmatrix(mat,show)
	wave mat
	variable show
	matrixEigenV/R mat;
	wave M_R_eigenVectors=$"M_R_eigenVectors"
	wave W_eigenvalues=$"W_eigenvalues"
	duplicate/o M_R_eigenVectors M_R_WF2;
	M_R_WF2=M_R_eigenVectors;
	make/o/N=(dimsize(W_eigenvalues,0)) egv;
	egv=real(W_eigenvalues);
	sortColumnindex(egv,M_R_WF2)
	killwaves egv //W_eigenvalues M_R_eigenVectors
	if (show == 1)
		di(M_R_WF2)
		Label left "Index of Eigenvalue"
		Label bottom "\\Z16 Index of Eigenvector Space"
	endif
	return M_R_WF2
end

Function RefY(name)
	wave name
	duplicate/o name name2
	name[][]=name2[p][dimsize(name2,1)-q-1]
	killwaves name2
end



///////////////////////////////////////////////////////////////////////////
//** Calculate LDOS(E)
///////////////////////////////////////////////////////////////////////////
Proc QHZLDOSC(A,B,m,mu,ReD,ImD,nslab,num,Vmin,Vmax)
	variable A = 1
	variable B = 1
	variable m = 0
	variable mu = 0
	variable ReD = 1
	variable ImD = 0
	variable nslab = 10
	variable num = 10
	variable Vmin = -6
	variable Vmax = 6
	prompt nslab,"Number of Slab"
	prompt num,"Number of point in k space"
	prompt Vmin,"E(min)"
	prompt Vmax,"E(max)"
	QHZLDOS(A,B,m,mu,ReD,ImD,nslab,num,Vmin,Vmax)
end


Function QHZLDOS(A,B,m,mu,ReD,ImD,nslab,num,Vmin,Vmax)
	variable A,B,m,mu,ReD,ImD,nslab,num,Vmin,Vmax
	variable/G pairmode

	if (pairmode == 2 || pairmode == 6 || pairmode == 8)
		SolveslabLDOS_QHZ_cmplx(A,B,m,mu,ReD,ImD,nslab,num,Vmin,Vmax)
	else
		SolveslabLDOS_QHZ(A,B,m,mu,ReD,ImD,nslab,num,Vmin,Vmax)
	endif

	MergeRoweach($"QHZ_LDOS",4)

	di($"QHZ_LDOS_m")
	Label left "\\Z16Y (Site)"
	Label bottom "\\Z16Energy"
end


Function SolveslabLDOS_QHZ_cmplx(A,B,m,mu,ReD,ImD,nslab,num,Vmin,Vmax)
	variable A,B,m,mu,ReD,ImD,nslab,num,Vmin,Vmax

	make/N=(num)/o temp
	setscale/I x,-pi,pi,"",temp

	variable/G pairmode
	//Create void wave for "nslab" number band
	string em,em2

	em = "QHZ_LDOS"
	make/N=(2000,4*nslab)/o $em
	setscale/i x,Vmin,Vmax,"",$em
	wave emw = $em
	emw = 0

	variable i,kx,count
	i=0
	do
		count = round(i/(num/10))
		kx = dimoffset(temp,0)+i*dimdelta(temp,0)

				if (pairmode == 2) //s+is
					LDOSofmatrix_cmplx(QHZedgeH2(A,B,m,mu,ReD,ImD,kx,nslab),Vmin,Vmax,0)
				endif
				if (pairmode == 6) //dxy
					LDOSofmatrix_cmplx(QHZedgeH6(A,B,m,mu,ReD,ImD,kx,nslab),Vmin,Vmax,0)
				endif
				if (pairmode == 8) //py
					LDOSofmatrix_cmplx(QHZedgeH8(A,B,m,mu,ReD,ImD,kx,nslab),Vmin,Vmax,0)
				endif
		wave QHZ_LDOSk = $"QHZ_LDOSk"
		emw+=QHZ_LDOSk
		//print num2str(i)+"/"+num2str(num)

		IF(mod(i,20)==0)
			Print i,"/",num
		Endif

		i+=1

	while (i < num-1) // This is correct for [0,num-1)

	emw/=num
	killwaves temp QHZ_LDOSk
	//di(emw)
	//Label left "Index of Eigenvalue"
	//Label bottom "Index of Eigenvector Space"
end

Function/wave LDOSofmatrix_cmplx(mat,Vmin,Vmax,show)
	wave mat
	variable Vmin,Vmax,show

	matrixEigenV/R mat;
	wave/C M_R_eigenVectors=$"M_R_eigenVectors"
	wave/C W_eigenvalues=$"W_eigenvalues"
	make/N=(dimsize(M_R_eigenVectors,0),dimsize(M_R_eigenVectors,1))/o M_R_LDOS2
	M_R_LDOS2=real(M_R_eigenVectors)^2
	make/o/N=(dimsize(W_eigenvalues,0)) egv;
	egv=real(W_eigenvalues);
	sortColumnindex(egv,M_R_LDOS2)
	//killwaves egv //W_eigenvalues M_R_eigenVectors

	string name = "QHZ_LDOSk"
	make/N=(2000,dimsize(M_R_LDOS2,0))/o $name
	wave namew = $name
	setscale/I x,Vmin,Vmax,"",namew
	namew = 0
	variable roff = dimoffset(namew,0)
	variable rdelta = dimdelta(namew,0)
	variable i,t
	i=0
	do
		t=0
		do

			Multithread namew[][i] +=  M_R_LDOS2[i][t]* (1/(sqrt(2*pi)*0.01))* exp(-((roff+p*rdelta)-egv[t])^2/(2*0.01^2))
			t+=1
		while (t < dimsize(egv,0))
		i+=1
	while (i<dimsize(M_R_LDOS2,0))

	if (show == 1)
		di(namew)
		Label left "Index of Eigenvalue"
		Label bottom "\\Z16 Index of Eigenvector Space"
	endif
	killwaves M_R_LDOS2
end

Function MergeRoweach(name,each)
	wave name
	variable each

	string new = nameofwave(name)+"_m"
	make/N=(dimsize(name,0),dimsize(name,1)/each)/o $new
	setscale/p x,dimoffset(name,0),dimdelta(name,0),"",$new
	wave neww = $new
	neww = 0
	variable i,j
	i=0
	do
		j=0
		do
			neww[][i]+=name[p][each*i+j]
			j+=1
		while (j< each)
		i+=1
	while(i< dimsize(name,1)/each)
	di(neww)
	Label left "Index of Eigenvalue"
	Label bottom "Site of Slab (i)"
end

Function ButtonProc_QHZ_LDOSindex(ctrlName) : ButtonControl
	String ctrlName
	Variable/G A_QHZ //= A
	Variable/G B_QHZ //= B
	Variable/G m_QHZ //= m
	Variable/G mu_QHZ //= mu
	Variable/G ReD_QHZ //= ReD
	Variable/G numxy_QHZ //= numxy
	variable/G ImD_QHZ

	QHZLDOSindex(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,20,numxy_QHZ)
	tilewindows/WINS=winname(0,1)/R/A=(1,1)/w=(26,58,49,100)
	button bLDOSindexHQ title="HQ",size={60,20},fSize=8,proc=ButtonProc_QHZ_LDOSindexHQ
end

Function ButtonProc_QHZ_LDOSindexHQ(ctrlName) : ButtonControl
	String ctrlName
	Variable/G A_QHZ //= A
	Variable/G B_QHZ //= B
	Variable/G m_QHZ //= m
	Variable/G mu_QHZ //= mu
	Variable/G ReD_QHZ //= ReD
	Variable/G numxy_QHZ //= numxy
	variable/G ImD_QHZ

	QHZLDOSindex(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,80,numxy_QHZ)
	tilewindows/WINS=winname(0,1)/R/A=(1,1)/w=(26,58,49,100)
end

Function ButtonProc_QHZ_LDOSE(ctrlName) : ButtonControl
	String ctrlName
	Variable/G A_QHZ //= A
	Variable/G B_QHZ //= B
	Variable/G m_QHZ //= m
	Variable/G mu_QHZ //= mu
	Variable/G ReD_QHZ //= ReD
	Variable/G numxy_QHZ //= numxy
	variable/G ImD_QHZ

	QHZLDOSindex(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,20,numxy_QHZ)
	QHZLDOS(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,10,20,-5,5)
	tilewindows/WINS=winname(0,1)/R/A=(1,1)/w=(3,58,26,100)
end


/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
//** Calculate the Spectral function with layer weight
Function ButtonProc_QHZslabcutc(ctrlName) : ButtonControl
	String ctrlName
	execute "QHZslabcutc()"
end
Proc QHZslabcutc(m,mu,ReD,ImD,nslab,numxy,ratio,xi,Vmax,mode)
	variable m = m_QHZ
	variable mu = mu_QHZ
	variable ReD = ReD_QHZ
	variable ImD = ImD_QHZ
	variable nslab = 50
	variable numxy = 200
	variable ratio = 1
	variable xi = xi_QHZ
	variable Vmax = 5
	variable mode = pairmode
	prompt nslab,"Number of Slab"
	prompt numxy,"Number of point in k space"
	prompt ratio,"Weight?",popup,"Yes;No"
	Prompt xi,"ξ(layer) [Slab decay length]" // xi = 1 means top layer, xi = -1 means bottom layer.
	Prompt mode,"Pairing sym",popup,"s;s+is;px+ipy;s±;dx2-y2;dxy;px;py"

	variable selfimg = selfimg_QHZ
	variable Vmin = -Vmax
	if (mode == 2 || mode == 6 || mode == 8)
		QHZslabcut_cmplx(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,selfimg_QHZ,nslab,numxy,Ratio,xi,Vmin,Vmax)
	else
		QHZslabcut(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,selfimg_QHZ,nslab,numxy,Ratio,xi,Vmin,Vmax)
	endif

	di(cut_slabQHZ)
end

Function QHZslabcut_cmplx(A,B,m,mu,ReD,ImD,selfimg,nslab,numxy,ratio,xi,v1,v2)
	variable A,B,m,mu,ReD,ImD,selfimg,nslab,numxy,ratio,xi,v1,v2

	variable/G pairmode
	//** Make void matrix for spectral function
	make/o/n=(numxy,2000) cut_slabQHZ
	setscale/i x,-1.5*pi,1.5*pi,"",cut_slabQHZ
	setscale/i y,v1,v2,"",cut_slabQHZ
	cut_slabQHZ = 0
	variable roff = dimoffset(cut_slabQHZ,1)
	variable rdelta = dimdelta(cut_slabQHZ,1)

	//** Variable for Spectral Function
	variable i,j,selfreal,t
	selfreal = 0
	variable kx

	//** Pointer String for called Functions
	string W_eigenvalues="W_eigenvalues"
	string QHZH = "QHZH"

	//** Do you want to consider tunnel matrix
	variable me
	if (ratio == 0) // No I do not
		//** Start loop for (kx)
		i=0
		do

			//** Define kx, ky by void matrix shape
				kx = dimoffset(cut_slabQHZ,0)+i*dimdelta(cut_slabQHZ,0)

				if (pairmode == 2) //s+is
					QHZedgeH2(A,B,m,mu,ReD,ImD,kx,nslab)
				endif
				if (pairmode == 6) //dxy
					QHZedgeH6(A,B,m,mu,ReD,ImD,kx,nslab)
				endif
				if (pairmode == 8) //py
					QHZedgeH8(A,B,m,mu,ReD,ImD,kx,nslab)
				endif
				wave/C QHZedge = $"QHZedge"


			//** Solve eigenvalue of QHZ Hamiltonian

				matrixEigenV QHZedge
				wave/C n=$W_eigenvalues
				//wave M_R_eigenVectors = $"M_R_eigenVectors"


				//M_R_eigenVectors=M_R_eigenVectors^2;
				make/n=(dimsize(QHZedge,0))/o sorteigen
				sorteigen = real(N)
				//sortColumnindex(sorteigen,M_R_eigenVectors)
				//MergeColumneach(M_R_eigenVectors,4)
				//wave M_R_eigenVectors_m = $"M_R_eigenVectors_m"

			//Make 3D Spectral Function
				t=0
				do
					cut_slabQHZ[i][]+=(1/pi)*selfimg/(selfimg^2+((roff+q*rdelta)-selfreal-sorteigen[t])^2)
					t+=1
				while (t < dimsize(sorteigen,0))

			i+=1
		while(i < dimsize(cut_slabQHZ,0)	)
	Endif

	if (ratio == 1) // Yes I do
		//** Start loop for (kx)
		i=0
		do

			//** Define kx, ky by void matrix shape
				kx = dimoffset(cut_slabQHZ,0)+i*dimdelta(cut_slabQHZ,0)

				if (pairmode == 2) //s+is
					QHZedgeH2(A,B,m,mu,ReD,ImD,kx,nslab)
				endif
				if (pairmode == 6) //dxy
					QHZedgeH6(A,B,m,mu,ReD,ImD,kx,nslab)
				endif
				if (pairmode == 8) //py
					QHZedgeH8(A,B,m,mu,ReD,ImD,kx,nslab)
				endif
				wave/C QHZedge = $"QHZedge"


			//** Solve eigenvalue of QHZ Hamiltonian

				matrixEigenV/R QHZedge
				wave/C n=$W_eigenvalues
				make/n=(dimsize(QHZedge,0))/o sorteigen
				sorteigen = real(N)

				wave/C mm= $"M_R_eigenVectors"
				make/n=(dimsize(mm,0),dimsize(mm,1))/o MM_R_eigenVectors
				wave M_R_eigenVectors = $"MM_R_eigenVectors"
				M_R_eigenVectors=real(mm)^2+ imag(mm)^2


				sortColumnindex(sorteigen,M_R_eigenVectors)
				MergeColumneach(M_R_eigenVectors,4)
				wave M_R_eigenVectors_m = $"MM_R_eigenVectors_m"

				make/n=(dimsize(M_R_eigenVectors_m,0))/o temptt

			//Make 3D Spectral Function
				t=0
				do
					temptt[]=M_R_eigenVectors_m[p][t]
					temptt*=(exp(-x/xi))
					me = sum(temptt)/dimsize(temptt,0)

					cut_slabQHZ[i][]+=me*(1/pi)*selfimg/(selfimg^2+((roff+q*rdelta)-selfreal-sorteigen[t])^2)
					t+=1
				while (t < dimsize(sorteigen,0))
			i+=1
		while(i < dimsize(cut_slabQHZ,0)	)
	Endif
	killwaves QHZedge sorteigen n temptt MM_R_eigenVectors
	//di(cut_slabQHZ)
end

Function SetVarProc_QHZ_LDOSEawr(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	effQHZ_LDOSEawr()
end

Function effQHZ_LDOSEawr()
	Variable/G A_QHZ //= A
	Variable/G B_QHZ //= B
	Variable/G m_QHZ //= m
	Variable/G mu_QHZ //= mu
	Variable/G ReD_QHZ
	Variable/G ImD_QHZ //= ReD
	Variable/G numxy_QHZ //= numxy
	variable/G selfimg_QHZ
	variable/G xi_QHZ
	variable/G pairmode

	getaxis/Q/W=qhzedgem left
	if (xi_QHZ == -1)
		if (pairmode == 2 || pairmode == 6 || pairmode == 8)
			QHZslabcut_cmplx(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,selfimg_QHZ,10,100,1,-1,V_min,V_max)
		else
			QHZslabcut(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,selfimg_QHZ,10,100,1,-1,V_min,V_max)
		endif
	endif
	if (xi_QHZ == 0)
		if (pairmode == 2 || pairmode == 6 || pairmode == 8)
			QHZslabcut_cmplx(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,selfimg_QHZ,10,100,1,1,V_min,V_max)
		else
			QHZslabcut(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,selfimg_QHZ,10,100,1,1,V_min,V_max)
		endif
	endif
	if (xi_QHZ == 1)
		if (pairmode == 2 || pairmode == 6 || pairmode == 8)
			QHZslabcut_cmplx(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,selfimg_QHZ,10,100,0,1,V_min,V_max)
		else
			QHZslabcut(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,selfimg_QHZ,10,100,0,1,V_min,V_max)
		endif
	endif
	string cut_slabQHZ="cut_slabQHZ"
	wave cutw = $cut_slabQHZ
	checkDisplayed/A cutw
	//print v_flag
	if (V_flag == 1)
	else
		di(cutw)
		Button LDOSEawrhq title="HQ",size={30,15},fSize=8,proc=ButtonProc_QHZ_LDOSEawrhq
		Button LDOSEawrrn title="Rename",size={50,15},fSize=8,proc=ButtonProc_QHZ_LDOSEawrrn
		modifygraph width=300,height=500
		make/o/T/N=3 lbslabQHZ
		lbslabQHZ={"-π","0","π"}
		make/o/N=3 lbslabQHZp
		lbslabQHZp={-pi,0,pi}
		ModifyGraph userticks(bottom)={lbslabQHZp,lbslabQHZ}
		Label bottom "\\Z16k\\Bx\\M\\Z16 (Å\\S-1\\M\\Z16)"
		Label left "\\Z16Energy"
		tilewindows/WINS=winname(0,1)/R/A=(1,1)/w=(74.2,29,100,100)
		DOwindow/F $winname(1,1)
	endif
end

Function ButtonProc_QHZ_LDOSEawrhq(ctrlName) : ButtonControl
	String ctrlName
	Variable/G A_QHZ //= A
	Variable/G B_QHZ //= B
	Variable/G m_QHZ //= m
	Variable/G mu_QHZ //= mu
	Variable/G ReD_QHZ //= ReD
	Variable/G numxy_QHZ //= numxy
	variable/G selfimg_QHZ
	variable/G ImD_QHZ
	variable/G pairmode
	variable/G xi_QHZ

	getaxis/Q left

	if (xi_QHZ == -1)
		if (pairmode == 2 || pairmode == 6 || pairmode == 8)
			QHZslabcut_cmplx(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,selfimg_QHZ,50,200,1,-1,V_min,V_max)
		else
			QHZslabcut(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,selfimg_QHZ,50,200,1,-1,V_min,V_max)
		endif
	endif
	if (xi_QHZ == 0)
		if (pairmode == 2 || pairmode == 6 || pairmode == 8)
			QHZslabcut_cmplx(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,selfimg_QHZ,50,200,1,1,V_min,V_max)
		else
			QHZslabcut(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,selfimg_QHZ,50,200,1,1,V_min,V_max)
		endif
	endif
	if (xi_QHZ == 1)
		if (pairmode == 2 || pairmode == 6 || pairmode == 8)
			QHZslabcut_cmplx(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,selfimg_QHZ,50,200,0,1,V_min,V_max)
		else
			QHZslabcut(A_QHZ,B_QHZ,m_QHZ,mu_QHZ,ReD_QHZ,ImD_QHZ,selfimg_QHZ,50,200,0,1,V_min,V_max)
		endif
	endif
end

Function ButtonProc_QHZ_LDOSEawrrn(ctrlName) : ButtonControl
	String ctrlName
	Variable/G m_QHZ //= m
	Variable/G mu_QHZ //= mu
	Variable/G ReD_QHZ //= ReD

	string name = "cut_slabQHZ_"+num2str(m_QHZ)+"_"+num2str(mu_QHZ)+"_"+num2str(ReD_QHZ)
	string nameref = "cut_slabQHZ_"+num2str(m_QHZ)+"_"+num2str(mu_QHZ)+"_"+num2str(ReD_QHZ)
	if (itemsInList(wavelist(nameref+"*",";","")) != 0)
		name = "cut_slabQHZ_"+num2str(m_QHZ)+"_"+num2str(mu_QHZ)+"_"+num2str(ReD_QHZ)+"_"+num2str(itemsInList(wavelist(nameref+"*",";",""))+1)
		//print name
	endif
	wave cut_slabQHZ=$"cut_slabQHZ"
	rename cut_slabQHZ $name
end

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//** Simutaneous Qi-Wu-Zhang Fermi surface and G-X bands (Normal states)
Function QWZSpectralFunction2(A,B,m,mu,selfimg,numxy)
	variable A,B,m,mu
	variable selfimg
	variable numxy //= 100
	variable/G zn_cons = 2

	//** Make void matrix for spectral function
	make/o/n=(numxy,numxy,500) modelresult_QWZ
	setscale/i x,-pi,pi,"",modelresult_QWZ
	setscale/i y,-pi,pi,"",modelresult_QWZ
	setscale/i z,-5,5,"",modelresult_QWZ
	modelresult_QWZ = 0
	variable roff = dimoffset(modelresult_QWZ,2)
	variable rdelta = dimdelta(modelresult_QWZ,2)

	//** Variable for Spectral Function
	variable i,j,selfreal,t
	selfreal = 0
	variable kx
	variable ky

	//** Pointer String for called Functions
	string W_eigenvalues="W_eigenvalues"
	string QWZH = "QWZH"

	//** Start loop for (kx, ky)
	i=0
	do
		j=0
		do
			//** Define kx, ky by void matrix shape
				kx = dimoffset(modelresult_QWZ,0)+i*dimdelta(modelresult_QWZ,0)
				ky = dimoffset(modelresult_QWZ,1)+j*dimdelta(modelresult_QWZ,1)

				QWZ(A,B,m,kx,ky,mu)
				wave/C QWZHw = $QWZH

			//** Solve eigenvalue of QWZ Hamiltonian

				matrixEigenV QWZHw
				wave/C n=$W_eigenvalues
				make/n=(dimsize(QWZHw,0))/o sorteigen

				sorteigen[0]= real(N[0])
				sorteigen[1]= real(N[1])


			//Make 3D Spectral Function
				t=0
				do
					modelresult_QWZ[i][j][]+=(-1/pi)*selfimg/(selfimg^2+((roff+r*rdelta)-selfreal-sorteigen[t])^2)
					t+=1
				while (t < dimsize(sorteigen,0))

			j+=1
		while(j < dimsize(modelresult_QWZ,1))
		i+=1
	while(i < dimsize(modelresult_QWZ,0)	)

	//** Call smart 3D displayer
		duplicate/o modelresult_QWZ Z2_001
		killwaves modelresult_QWZ
	make/N=(dimsize(Z2_001,0),dimsize(Z2_001,1))/O Z2_001_slice
	setscale/p x, dimoffset(Z2_001,0), dimdelta(Z2_001,0),"",Z2_001_slice
	setscale/p y, dimoffset(Z2_001,1), dimdelta(Z2_001,1),"",Z2_001_slice
	string/G mat3dn_cons
	variable/G zn_cons
	variable/G z_cons
	variable Z_constp=(z_cons-dimoffset($mat3dn_cons,zn_cons))/dimdelta($mat3dn_cons,zn_cons)
	Z2_001_slice[][]=Z2_001[p][q][Z_constp]
	di(Z2_001_slice)
	modifygraph width=300,height=300
	Legend/C/N=text0/J/F=0/A=LT/X=0.00/Y=0.00 "Normal state Fermi Surface\rCalculated by Qi-Wu-Zhang model"
	tilewindows/WINS=winname(0,1)/R/w=(74,0,83,85)/A=(1,1)
	//ModifyGraph width={Plan,1,bottom,left}


	make/N=(dimsize(Z2_001,0),dimsize(Z2_001,2))/O Z2_001_sliceband
	setscale/p x, dimoffset(Z2_001,0), dimdelta(Z2_001,0),"",Z2_001_sliceband
	setscale/p y, dimoffset(Z2_001,2), dimdelta(Z2_001,2),"",Z2_001_sliceband
	Z2_001_sliceband[][]=Z2_001[p][round(dimsize(Z2_001,1)/2)][q]
	di(Z2_001_sliceband)
	modifygraph width=270,height=420
	ModifyGraph zero(left)=8
	Legend/C/N=text0/J/F=0/A=LT/X=0.00/Y=0.00 "Normal state X-Γ-X Bands\rCalculated by Qi-Wu-Zhang model"
	Label bottom "\\Z16X\t\t\t\t\t\t\t\t\t\t\t\t\tΓ\t\t\t\t\t\t\t\t\t\t\t\t\tX"
	tilewindows/WINS=winname(0,1)/R/w=(74,40,83,85)/A=(1,1)
end

Function SetVarProc_Cons3dplot2(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	string/G mat3dn_cons = replacestring("Zslice_",tpw(),"")

	string barename = replaceString("_G",mat3dn_cons,"")
	string sliceI = "Zslice_"+barename+"_I"
	string sliceZ = "Zslice_"+mat3dn_cons+"_Z_map"
	string sliceR = "Zslice_"+mat3dn_cons+"_R_map"
	string sliceRho = "Zslice_"+mat3dn_cons+"_Rho_map"

	//Update layers
		Cons3dplotc()
		Cons3dplotcQWZ()

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
Function Cons3dplotcQWZ()
	string/G mat3dn_cons
	variable/G zn_cons
	variable/G z_cons

	variable/G colorratio_consFFT
	wave mat3dnw = $"Z2_001"
	variable Z_constp=(z_cons-dimoffset($mat3dn_cons,zn_cons))/dimdelta($mat3dn_cons,zn_cons)

	//** g(r,V)

	wave slicenamew =$"Z2_001_slice"

	if(zn_cons == 0)
		slicenamew[][]=mat3dnw[Z_constp][p][q]
	endif
	if(zn_cons == 1)
		slicenamew[][]=mat3dnw[p][Z_constp][q]
	endif
	if(zn_cons == 2)
		slicenamew[][]=mat3dnw[p][q][Z_constp]
	endif

	func_zeroNaN(slicenamew)

	variable/G divcolor_cons
	if (divcolor_cons == 1)
		wavestats/Q slicenamew
		variable rangls = max(abs(V_max),abs(V_min))
		ModifyImage/W=$grabwinchild("Z2_001_slice") $"Z2_001_slice" ctab= {-rangls,rangls,:Packages:NewColortable:dvg_seismic,0};
		ColorScale/W=$grabwinchild("Z2_001_slice")/C/N=textcc/X=-21.00/Y=5.00/F=0 heightPct=30,nticks=5,minor=1,tickLen=1.00,image=$"Z2_001_slice"//;ColorScale/W=$grabwinchild(Fexyd)/C/N=text0/F=0/A=MC/Y=-120 image=$Fexyd
	endif

	if (divcolor_cons == 0)
		color3s_for3d(slicenamew,3)
		ColorScale/K/N=textcc
	endif
end

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//** Slab functions for real matrix
Function Solveedgestate_QHZ(A,B,m,mu,ReD,ImD,nslab,num)
	variable A,B,m,mu,ReD,ImD,nslab,num
	make/N=(num)/o temp
	setscale/I x,-1.5*pi,1.5*pi,"",temp

	variable/G pairmode
	//Create void wave for "nslab" number band
	string em
	variable ii
	ii = 0
	do
		em = "em" + num2str(ii+1)
		make/N=(num)/o $em
		setscale/I x,-1.5*pi,1.5*pi,"",$em
		ii+=1
	while (ii < 4*nslab)

	variable i,kx
	i=0
	do
		kx = dimoffset(temp,0)+i*dimdelta(temp,0)

		if (pairmode == 1) //s
			QHZedgeH1(A,B,m,mu,ReD,ImD,kx,nslab)
		endif
		if (pairmode == 3) //px+ipy
			QHZedgeH3(A,B,m,mu,ReD,ImD,kx,nslab)
		endif
		if (pairmode == 4) //s±
			QHZedgeH4(A,B,m,mu,ReD,ImD,kx,nslab)
		endif
		if (pairmode == 5) //dx2-y2
			QHZedgeH5(A,B,m,mu,ReD,ImD,kx,nslab)
		endif
		if (pairmode == 7) //px
			QHZedgeH7(A,B,m,mu,ReD,ImD,kx,nslab)
		endif

		wave QHZedge = $"QHZedge"

		//** Solve eigenvalue of Haldane Hamiltonian

				matrixEigenV QHZedge
				wave/C n=$"W_eigenvalues"
				make/n=(dimsize(QHZedge,0))/o sorteigen

				sorteigen=real(N)
				sort sorteigen sorteigen

				ii = 0
				do
					em = "em" + num2str(ii+1)
					wave emw = $em
					emw[i] = sorteigen[ii]
					ii+=1
				while (ii < 4*nslab)
		i+=1
	while (i < num)
	//displaymultiFQHZ("em",1,4*nslab)
end


Function Solveedgestate_QHZhq(A,B,m,mu,ReD,ImD,nslab,num)
	variable A,B,m,mu,ReD,ImD,nslab,num
	make/N=(num)/o temp
	setscale/I x,-1.5*pi,1.5*pi,"",temp

	variable/G pairmode

	//Create void wave for "nslab" number band
	string em
	variable ii
	ii = 0
	do
		em = "emhq" + num2str(ii+1)
		make/N=(num)/o $em
		setscale/I x,-1.5*pi,1.5*pi,"",$em
		ii+=1
	while (ii < 4*nslab)

	variable i,kx
	i=0
	do
		kx = dimoffset(temp,0)+i*dimdelta(temp,0)

		if (pairmode == 1) //s
			QHZedgeH1(A,B,m,mu,ReD,ImD,kx,nslab)
		endif
		if (pairmode == 3) //px+ipy
			QHZedgeH3(A,B,m,mu,ReD,ImD,kx,nslab)
		endif
		if (pairmode == 4) //s±
			QHZedgeH4(A,B,m,mu,ReD,ImD,kx,nslab)
		endif
		if (pairmode == 5) //dx2-y2
			QHZedgeH5(A,B,m,mu,ReD,ImD,kx,nslab)
		endif
		if (pairmode == 7) //px
			QHZedgeH7(A,B,m,mu,ReD,ImD,kx,nslab)
		endif
		wave QHZedge = $"QHZedge"

		//** Solve eigenvalue of Haldane Hamiltonian

				matrixEigenV QHZedge
				wave/C n=$"W_eigenvalues"
				make/n=(dimsize(QHZedge,0))/o sorteigen

				sorteigen=real(N)
				sort sorteigen sorteigen

				ii = 0
				do
					em = "emhq" + num2str(ii+1)
					wave emw = $em
					emw[i] = sorteigen[ii]
					ii+=1
				while (ii < 4*nslab)
		i+=1
	while (i < num)
	//displaymultiFQHZ("em",1,4*nslab)
end

Function/wave Indexofmatrix(mat,show)
	wave mat
	variable show

	matrixEigenV/R mat;
	wave M_R_eigenVectors=$"M_R_eigenVectors"
	wave W_eigenvalues=$"W_eigenvalues"
	duplicate/o M_R_eigenVectors M_R_Index2;
	M_R_Index2=(M_R_eigenVectors)^2;
	make/o/N=(dimsize(W_eigenvalues,0)) egv;
	egv=real(W_eigenvalues);
	sortColumnindex(egv,M_R_Index2)
	//killwaves egv //W_eigenvalues M_R_eigenVectors

	if (show == 1)
		di(M_R_Index2)
		Label left "Index of Eigenvalue"
		Label bottom "\\Z16 Index of Eigenvector Space"
	endif
	return M_R_Index2
end


//********************************************************
//** Function to calculate Eigenvalue index resolved LDOS
//********************************************************
Function Solveslabindex_QHZ(A,B,m,mu,ReD,ImD,nslab,num)
	variable A,B,m,mu,ReD,ImD,nslab,num
	//** Shape of k-cycle
		make/N=(num)/o temp
		setscale/I x,-pi,pi,"",temp

	variable/G pairmode
	//** Create void wave for "nslab" number band
		string em//,em2
		em = "QHZ_eigenvector"
		make/N=(4*nslab,4*nslab)/o $em
		wave emw = $em
		emw = 0

		//em2 = "QHZ_LDOS_eignevalue"
		//make/N=(4*nslab,num)/o $em2
		//wave em2w = $em2
		//em2w = 0

	//** Run cycle for different k
		variable i,kx
		i=0
		do
			kx = dimoffset(temp,0)+i*dimdelta(temp,0)
			//** Calculate the momentum resolved LDOS(index)
				if (pairmode == 1) //s
					Indexofmatrix(QHZedgeH1(A,B,m,mu,ReD,ImD,kx,nslab),0)
				endif
				if (pairmode == 3) //px+ipy
					Indexofmatrix(QHZedgeH3(A,B,m,mu,ReD,ImD,kx,nslab),0)
				endif
				if (pairmode == 4) //s±
					Indexofmatrix(QHZedgeH4(A,B,m,mu,ReD,ImD,kx,nslab),0)
				endif
				if (pairmode == 5) //dx2-y2
					Indexofmatrix(QHZedgeH5(A,B,m,mu,ReD,ImD,kx,nslab),0)
				endif
				if (pairmode == 7) //px
					Indexofmatrix(QHZedgeH7(A,B,m,mu,ReD,ImD,kx,nslab),0)
				endif
				wave M_R_Index2 = $"M_R_Index2"
				emw+=M_R_Index2

				//wave egv=$"egv"
				//em2w[][i]=egv[p]

			i+=1
		while (i < round(num/2))

		//** For chiral mode, we revert the energy of the middle 4 modes
			//This can avoid the mixing and left and right moving wavefunction

		//** Middle gap (two modes)
			make/N=(4*nslab)/o tempmiddle1
			make/N=(4*nslab)/o tempmiddle2
			make/N=(4*nslab)/o tempmiddle3
			make/N=(4*nslab)/o tempmiddle4

		//** Lower gap (one mode)
			make/N=(4*nslab)/o tempmiddle5
			make/N=(4*nslab)/o tempmiddle6

		//** Higher gap (one mode)
			make/N=(4*nslab)/o tempmiddle7
			make/N=(4*nslab)/o tempmiddle8


		i=round(num/2)
		do
			//** Middle gap (two modes)
			tempmiddle1[] = emw[p][2*nslab-1]
			tempmiddle2[] = emw[p][2*nslab]
			tempmiddle3[] = emw[p][2*nslab+1]
			tempmiddle4[] = emw[p][2*nslab-2]

			//** Lower gap (one mode)
			tempmiddle5[] = emw[p][nslab-1]
			tempmiddle6[] = emw[p][nslab]

			//** Higher gap (one mode)
			tempmiddle7[] = emw[p][3*nslab-1]
			tempmiddle8[] = emw[p][3*nslab]

			kx = dimoffset(temp,0)+i*dimdelta(temp,0)
				if (pairmode == 1) //s
					Indexofmatrix(QHZedgeH1(A,B,m,mu,ReD,ImD,kx,nslab),0)
				endif
				if (pairmode == 3) //px+ipy
					Indexofmatrix(QHZedgeH3(A,B,m,mu,ReD,ImD,kx,nslab),0)
				endif
				if (pairmode == 4) //s±
					Indexofmatrix(QHZedgeH4(A,B,m,mu,ReD,ImD,kx,nslab),0)
				endif
				if (pairmode == 5) //dx2-y2
					Indexofmatrix(QHZedgeH5(A,B,m,mu,ReD,ImD,kx,nslab),0)
				endif
				if (pairmode == 7) //px
					Indexofmatrix(QHZedgeH7(A,B,m,mu,ReD,ImD,kx,nslab),0)
				endif
				wave M_R_Index2 = $"M_R_Index2"
				emw+=M_R_Index2

				//wave egv=$"egv"
				//em2w[][i]=egv[p]

			//** Replace the middle 4 modes with reverse E
			RefY(M_R_Index2)
			wave M_R_Index2 = $"M_R_Index2"

			//** Middle gap (two modes)
			emw[][2*nslab]= tempmiddle2[p]+M_R_Index2[p][2*nslab]
			emw[][2*nslab-1]= tempmiddle1[p]+M_R_Index2[p][2*nslab-1]
			emw[][2*nslab+1]= tempmiddle3[p]+M_R_Index2[p][2*nslab+1]
			emw[][2*nslab-2]= tempmiddle4[p]+M_R_Index2[p][2*nslab-2]

			//** Lower gap (one mode)
			emw[][nslab]= tempmiddle6[p]+M_R_Index2[p][nslab]
			emw[][nslab-1]= tempmiddle5[p]+M_R_Index2[p][nslab-1]

			//** Higher gap (one mode)
			emw[][3*nslab]= tempmiddle8[p]+M_R_Index2[p][3*nslab]
			emw[][3*nslab-1]= tempmiddle7[p]+M_R_Index2[p][3*nslab-1]

			i+=1
		while (i < num-1)  // [0,num-1)
	emw/=num
	killwaves temp tempmiddle1 tempmiddle2 M_R_Index2 //tempmiddle3 tempmiddle4
	//di(emw)
	//Label left "\\Z16Index of Eigenvalue"
	//Label bottom "\\Z16 Index of Eigenvector Space"
end

Function/wave LDOSofmatrix(mat,Vmin,Vmax,show)
	wave mat
	variable Vmin,Vmax,show

	matrixEigenV/R mat;
	wave M_R_eigenVectors=$"M_R_eigenVectors"
	wave W_eigenvalues=$"W_eigenvalues"
	duplicate/o M_R_eigenVectors M_R_LDOS2;
	M_R_LDOS2=(M_R_eigenVectors)^2;
	make/o/N=(dimsize(W_eigenvalues,0)) egv;
	egv=real(W_eigenvalues);
	sortColumnindex(egv,M_R_LDOS2)
	//killwaves egv //W_eigenvalues M_R_eigenVectors

	string name = "QHZ_LDOSk"
	make/N=(2000,dimsize(M_R_LDOS2,0))/o $name
	wave namew = $name
	setscale/I x,Vmin,Vmax,"",namew
	namew = 0
	variable roff = dimoffset(namew,0)
	variable rdelta = dimdelta(namew,0)
	variable i,t
	i=0
	do
		t=0
		do

			Multithread namew[][i] +=  M_R_LDOS2[i][t]* (1/(sqrt(2*pi)*0.01))* exp(-((roff+p*rdelta)-egv[t])^2/(2*0.01^2))
			t+=1
		while (t < dimsize(egv,0))
		i+=1
	while (i<dimsize(M_R_LDOS2,0))

	if (show == 1)
		di(namew)
		Label left "Index of Eigenvalue"
		Label bottom "\\Z16 Index of Eigenvector Space"
	endif
	killwaves M_R_LDOS2
end

Function SolveslabLDOS_QHZ(A,B,m,mu,ReD,ImD,nslab,num,Vmin,Vmax)
	variable A,B,m,mu,ReD,ImD,nslab,num,Vmin,Vmax

	make/N=(num)/o temp
	setscale/I x,-pi,pi,"",temp

	variable/G pairmode
	//Create void wave for "nslab" number band
	string em,em2

	em = "QHZ_LDOS"
	make/N=(2000,4*nslab)/o $em
	setscale/i x,Vmin,Vmax,"",$em
	wave emw = $em
	emw = 0

	variable i,kx,count
	i=0
	do
		count = round(i/(num/10))
		kx = dimoffset(temp,0)+i*dimdelta(temp,0)
				if (pairmode == 1) //s
					LDOSofmatrix_cmplx(QHZedgeH1(A,B,m,mu,ReD,ImD,kx,nslab),Vmin,Vmax,0)
				endif
				if (pairmode == 3) //px+ipy
					LDOSofmatrix_cmplx(QHZedgeH3(A,B,m,mu,ReD,ImD,kx,nslab),Vmin,Vmax,0)
				endif
				if (pairmode == 4) //s±
					LDOSofmatrix_cmplx(QHZedgeH4(A,B,m,mu,ReD,ImD,kx,nslab),Vmin,Vmax,0)
				endif
				if (pairmode == 5) //dx2-y2
					LDOSofmatrix_cmplx(QHZedgeH5(A,B,m,mu,ReD,ImD,kx,nslab),Vmin,Vmax,0)
				endif
				if (pairmode == 7) //px
					LDOSofmatrix_cmplx(QHZedgeH7(A,B,m,mu,ReD,ImD,kx,nslab),Vmin,Vmax,0)
				endif
		wave QHZ_LDOSk = $"QHZ_LDOSk"
		emw+=QHZ_LDOSk
		//print num2str(i)+"/"+num2str(num)

		IF(mod(i,20)==0)
			Print i,"/",num
		Endif

		i+=1

	while (i < num-1) // This is correct for [0,num-1)

	emw/=num
	killwaves temp QHZ_LDOSk
	//di(emw)
	//Label left "Index of Eigenvalue"
	//Label bottom "Index of Eigenvector Space"
end

Function QHZslabcut(A,B,m,mu,ReD,ImD,selfimg,nslab,numxy,ratio,xi,v1,v2)
	variable A,B,m,mu,ReD,ImD,selfimg,nslab,numxy,ratio,xi,v1,v2

	variable/G pairmode

	//** Make void matrix for spectral function
	make/o/n=(numxy,2000) cut_slabQHZ
	setscale/i x,-1.5*pi,1.5*pi,"",cut_slabQHZ
	setscale/i y,v1,v2,"",cut_slabQHZ
	cut_slabQHZ = 0
	variable roff = dimoffset(cut_slabQHZ,1)
	variable rdelta = dimdelta(cut_slabQHZ,1)

	//** Variable for Spectral Function
	variable i,j,selfreal,t
	selfreal = 0
	variable kx

	//** Pointer String for called Functions
	string W_eigenvalues="W_eigenvalues"
	string QHZH = "QHZH"

	//** Do you want to consider tunnel matrix
	variable me
	if (ratio == 0) // No I do not
		//** Start loop for (kx)
		i=0
		do

			//** Define kx, ky by void matrix shape
				kx = dimoffset(cut_slabQHZ,0)+i*dimdelta(cut_slabQHZ,0)

				if (pairmode == 1) //s
					QHZedgeH1(A,B,m,mu,ReD,ImD,kx,nslab)
				endif
				if (pairmode == 3) //px+ipy
					QHZedgeH3(A,B,m,mu,ReD,ImD,kx,nslab)
				endif
				if (pairmode == 4) //s±
					QHZedgeH4(A,B,m,mu,ReD,ImD,kx,nslab)
				endif
				if (pairmode == 5) //dx2-y2
					QHZedgeH5(A,B,m,mu,ReD,ImD,kx,nslab)
				endif
				if (pairmode == 7) //px
					QHZedgeH7(A,B,m,mu,ReD,ImD,kx,nslab)
				endif
				wave QHZedge = $"QHZedge"

			//** Solve eigenvalue of QHZ Hamiltonian

				matrixEigenV QHZedge
				wave/C n=$W_eigenvalues
				//wave M_R_eigenVectors = $"M_R_eigenVectors"


				//M_R_eigenVectors=M_R_eigenVectors^2;
				make/n=(dimsize(QHZedge,0))/o sorteigen
				sorteigen = real(N)
				//sortColumnindex(sorteigen,M_R_eigenVectors)
				//MergeColumneach(M_R_eigenVectors,4)
				//wave M_R_eigenVectors_m = $"M_R_eigenVectors_m"

			//Make 3D Spectral Function
				t=0
				do
					cut_slabQHZ[i][]+=(1/pi)*selfimg/(selfimg^2+((roff+q*rdelta)-selfreal-sorteigen[t])^2)
					t+=1
				while (t < dimsize(sorteigen,0))

			i+=1
		while(i < dimsize(cut_slabQHZ,0)	)
	Endif

	if (ratio == 1) // Yes I do
		//** Start loop for (kx)
		i=0
		do

			//** Define kx, ky by void matrix shape
				kx = dimoffset(cut_slabQHZ,0)+i*dimdelta(cut_slabQHZ,0)

				if (pairmode == 1) //s
					QHZedgeH1(A,B,m,mu,ReD,ImD,kx,nslab)
				endif
				if (pairmode == 3) //px+ipy
					QHZedgeH3(A,B,m,mu,ReD,ImD,kx,nslab)
				endif
				if (pairmode == 4) //s±
					QHZedgeH4(A,B,m,mu,ReD,ImD,kx,nslab)
				endif
				if (pairmode == 5) //dx2-y2
					QHZedgeH5(A,B,m,mu,ReD,ImD,kx,nslab)
				endif
				if (pairmode == 7) //px
					QHZedgeH7(A,B,m,mu,ReD,ImD,kx,nslab)
				endif
				wave QHZedge = $"QHZedge"

			//** Solve eigenvalue of QHZ Hamiltonian

				matrixEigenV/R QHZedge
				wave/C n=$W_eigenvalues
				wave M_R_eigenVectors = $"M_R_eigenVectors"


				M_R_eigenVectors=M_R_eigenVectors^2;
				make/n=(dimsize(QHZedge,0))/o sorteigen
				sorteigen = real(N)
				sortColumnindex(sorteigen,M_R_eigenVectors)
				MergeColumneach(M_R_eigenVectors,4)
				wave M_R_eigenVectors_m = $"M_R_eigenVectors_m"

				make/n=(dimsize(M_R_eigenVectors_m,0))/o temptt

			//Make 3D Spectral Function
				t=0
				do
					temptt[]=M_R_eigenVectors_m[p][t]
					temptt*=(exp(-x/xi))
					me = sum(temptt)/dimsize(temptt,0)

					cut_slabQHZ[i][]+=me*(1/pi)*selfimg/(selfimg^2+((roff+q*rdelta)-selfreal-sorteigen[t])^2)
					t+=1
				while (t < dimsize(sorteigen,0))
			i+=1
		while(i < dimsize(cut_slabQHZ,0)	)
	Endif
	killwaves QHZedge sorteigen n
end


///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
//****************************** Simulate Topological defect ******************************
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_SIMUtopodefectc(ctrlName) : ButtonControl
	String ctrlName
	Execute "SIMUtopodefectc()"
end
Proc SIMUtopodefectc(a1,a2,add,lattice,zero,amp,x0,y0,windhalf,windsingle)
	variable a1 = -170 // angle of dislocation
	variable a2 = -125 // angle of lattice vector q
	variable add = 1.4 // added phase
	variable lattice = 11.5//lattice constance
	variable zero = 2 //background
	variable amp = 0.3
	variable x0 = 10
	variable y0 = 0
	variable windhalf = 1
	variable windsingle = 1
	Prompt a1,"Angle of dislocation (°)"
	Prompt a2,"Angle of Order Q (°)"
	Prompt add,"Phase offset"
	Prompt lattice,"Lattice constant"
	Prompt zero,"∆0 background"
	Prompt amp,"Amplitude of PDW"
	Prompt x0,"Frame X offset"
	Prompt y0,"Frame Y offset"
	Prompt windhalf,"Half vortex winding number"
	Prompt windsingle,"Single vortex winding number"

	variable/G a2_td = a2 // angle of lattice vector q
	variable/G lattice_td = lattice//lattice constance
	variable/G x0_td = x0
	variable/G y0_td = y0

	variable/G a1_td_half = a1 // angle of dislocation
	variable/G add_td_half = add // added phase
	variable/G zero_td_half = zero //background
	variable/G amp_td_half = amp
	variable/G windhalf_td = windhalf

	variable/G a1_td_single = a1 // angle of dislocation
	variable/G add_td_single = 3.3 // added phase
	variable/G zero_td_single = zero //background
	variable/G amp_td_single = amp
	variable/G windsingle_td = windsingle

	SIMUtopodefecthalf(a1_td_half,a2_td,add_td_half,lattice_td,zero_td_half,amp_td_half,x0_td,y0_td,windhalf_td)
	SIMUtopodefectsingle(a1_td_single,a2_td,add_td_single,lattice_td,zero_td_single,amp_td_single,x0_td,y0_td,windsingle_td)

	makeQindicate(a2_td)
	//wave topodefectVectorY=$"topodefectVectorY"
	//wave topodefectVectorX=$"topodefectVectorX"

	display/N=vortexandhalfvortexsimu;modifygraph width=700,height=600
	Display/HOST=#/W=(0,0.05,0.5,0.5);appendimage phasehalf;ModifyGraph mirror=2;ModifyImage phasehalf ctab= {-3.14,3.14,RainbowCycle,0};ModifyGraph width={Plan,1,bottom,left};ColorScale/C/N=text0/F=0/B=1/A=RC/X=-20.00/Y=0.00 image=phasehalf;ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;ColorScale/C/N=text0 frame=0.00//;Label bottom "\\Z16X          \t \t\t\t\t\t\t\t\tΓ\t\t\t\t\t\t\t\t\t          X"
	setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.05,1,0.5);appendimage phasesingle;ModifyGraph mirror=2;ModifyImage phasesingle ctab= {-3.14,3.14,RainbowCycle,0};ModifyGraph width={Plan,1,bottom,left};ColorScale/C/N=text0/F=0/B=1/A=RC/X=-20.00/Y=0.00 image=phasesingle;ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;ColorScale/C/N=text0 frame=0.00//;Label bottom "\\Z16M          \t \t\t\t\t\t\t\t\tΓ\t\t\t\t\t\t\t\t\t          M"
	setActiveSubwindow ##;Display/HOST=#/W=(0,0.45,0.5,0.9);appendimage amphalf;ModifyGraph mirror=2;ModifyImage amphalf ctab= {*,*,VioletOrangeYellow,0};ModifyGraph width={Plan,1,bottom,left};ColorScale/C/N=text0/F=0/B=1/A=RC/X=-22.5/Y=0.00 image=amphalf;ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;ColorScale/C/N=text0 frame=0.00//;Label bottom "\\Z16M          \t \t\t\t\t\t\t\t\tΓ\t\t\t\t\t\t\t\t\t          M"
	setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.45,1,0.9);appendimage ampsingle;ModifyGraph mirror=2;ModifyImage ampsingle ctab= {*,*,VioletOrangeYellow,0};ModifyGraph width={Plan,1,bottom,left};ColorScale/C/N=text0/F=0/B=1/A=RC/X=-22.5/Y=0.00 image=ampsingle;ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;ColorScale/C/N=text0 frame=0.00//;Label bottom "\\Z16M          \t \t\t\t\t\t\t\t\tΓ\t\t\t\t\t\t\t\t\t          M"

	setActiveSubwindow ##;Display/HOST=#/W=(0.35,0.8,0.55,1);appendtograph topodefectVectorY vs topodefectVectorX
	ModifyGraph mode=3,marker=19,msize=6,mrkThick=3;SetAxis left -1,1;SetAxis bottom -1,1;ModifyGraph mirror=1,nticks=0,axThick=2,standoff=0

	setActiveSubwindow ##;
	TextBox/C/N=text0/F=0/B=1/A=MB/X=-4.00/Y=2.00 "(-Q ,  Q)"


	SetVariable set1 win=vortexandhalfvortexsimu, title="Latt.Q(°)",pos={290,5},size={100,15},value=a2_td,limits={-inf,inf,1},proc=SetVarProc_tdefecct
	SetVariable set2 win=vortexandhalfvortexsimu, title="Latt. a",pos={290,25},size={100,15},value=lattice_td,limits={0,inf,1},proc=SetVarProc_tdefecct

	SetVariable set3 win=vortexandhalfvortexsimu, title="Dislo.(°)",pos={3,5},size={100,15},value=a1_td_half,limits={-inf,inf,1},proc=SetVarProc_tdefecct
	SetVariable set4 win=vortexandhalfvortexsimu, title="Ph. shif",pos={110,5},size={100,15},value=add_td_half,limits={-inf,inf,0.2},proc=SetVarProc_tdefecct
	SetVariable set5 win=vortexandhalfvortexsimu, title="Background",pos={3,25},size={100,15},value=zero_td_half,limits={-inf,inf,0.1},proc=SetVarProc_tdefecct
	SetVariable set6 win=vortexandhalfvortexsimu, title="Amplitude",pos={110,25},size={100,15},value=amp_td_half,limits={0.01,inf,0.1},proc=SetVarProc_tdefecct

	SetVariable set7 win=vortexandhalfvortexsimu, title="Dislo.(°)",pos={493,5},size={100,15},value=a1_td_single,limits={-inf,inf,10},proc=SetVarProc_tdefecct
	SetVariable set8 win=vortexandhalfvortexsimu, title="Ph. shif",pos={600,5},size={100,15},value=add_td_single,limits={-inf,inf,0.2},proc=SetVarProc_tdefecct
	SetVariable set9 win=vortexandhalfvortexsimu, title="Background",pos={493,25},size={100,15},value=zero_td_single,limits={-inf,inf,0.1},proc=SetVarProc_tdefecct
	SetVariable set10 win=vortexandhalfvortexsimu, title="Amplitude",pos={600,25},size={100,15},value=amp_td_single,limits={0.01,inf,0.1},proc=SetVarProc_tdefecct

	SetVariable set11 win=vortexandhalfvortexsimu, title="offset x",size={80,15},value=x0_td,limits={-inf,inf,1},proc=SetVarProc_tdefecct,pos={300,250}
	SetVariable set12 win=vortexandhalfvortexsimu, title="offset y",size={80,15},value=y0_td,limits={-inf,inf,1},proc=SetVarProc_tdefecct,pos={300,270}

	SetVariable set13 win=vortexandhalfvortexsimu, title="C",size={40,15},value=windhalf_td,limits={-1,1,2},proc=SetVarProc_tdefecct,pos={215,25}
	SetVariable set14 win=vortexandhalfvortexsimu, title="C",size={40,15},value=windsingle_td,limits={-1,1,2},proc=SetVarProc_tdefecct,pos={660,45}
	Button turnoffls3d title="BACK",size={45,12},valueColor=(0,0,0),fColor=(1,65535,33232),pos={650,585},proc=ButtonProc_lsturnoff3d
	tilewindows/WINS=winname(0,1)/R/A=(1,1)/w=(3,1,50,100)
	ckfig_child(winname(0,1))
end

Function makeQindicate(a2_td)
	variable a2_td //= lattice//lattice constance


	make/N=2/o topodefectVectorY, topodefectVectorX

	topodefectVectorY[0] = sin(pi+a2_td*pi/180)
	topodefectVectorY[1] = -sin(pi+a2_td*pi/180)

	topodefectVectorX[0] = cos(pi+a2_td*pi/180)
	topodefectVectorX[1] = -cos(pi+a2_td*pi/180)
end


Function SetVarProc_tdefecct(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G a2_td //= a2 // angle of lattice vector q
	variable/G lattice_td //= lattice//lattice constance
	variable/G x0_td
	variable/G y0_td

	variable/G a1_td_half //= a1 // angle of dislocation
	variable/G add_td_half //= add // added phase
	variable/G zero_td_half //= zero //background
	variable/G amp_td_half //= amp
	variable/G windhalf_td

	variable/G a1_td_single //= a1 // angle of dislocation
	variable/G add_td_single //= add // added phase
	variable/G zero_td_single //= zero //background
	variable/G amp_td_single //= amp
	variable/G windsingle_td

	SIMUtopodefecthalf(a1_td_half,a2_td,add_td_half,lattice_td,zero_td_half,amp_td_half,x0_td,y0_td,windhalf_td)
	SIMUtopodefectsingle(a1_td_single,a2_td,add_td_single,lattice_td,zero_td_single,amp_td_single,x0_td,y0_td,windsingle_td)
	makeQindicate(a2_td)
	//ModifyImage/W=$"vortexandhalfvortexsimu#G1" $"phasesingle" ctab= {-3.14+add_td_single,3.14+add_td_single,RainbowCycle,0}
end


Function SIMUtopodefecthalf(a1,a2,add,lattice,zero,amp,x0,y0,wind)
	variable a1 //= 190 // angle of dislocation
	variable a2 //= 50 // angle of lattice vector q
	variable add //= 1.3 // added phase
	variable lattice //= 10//lattice constance
	variable zero //= 1.1 //background
	variable amp
	variable x0,y0,wind

	variable a2v = a2*pi/180
	variable a1v = (a1-180)*pi/180
	make/N=(500,500)/o phasehalf
	setscale/I x,-25-x0,25-x0,"",phasehalf
	setscale/I y,-25-y0,25-y0,"",phasehalf
	duplicate/O phasehalf amphalf

	phasehalf=atan2( wind*(x*sin(-a1v)+y*cos(-a1v)), x*cos(-a1v)-y*sin(-a1v) )/2+add
	amphalf[][]=zero+amp*cos( (2*pi/lattice)*(x*cos(-a2v)-y*sin(-a2v)) + phasehalf[p][q])

end

Function SIMUtopodefectsingle(a1,a2,add,lattice,zero,amp,x0,y0,wind)
	variable a1 //= 190 // angle of dislocation
	variable a2 //= 50 // angle of lattice vector q
	variable add //= 1.3 // added phase
	variable lattice //= 10//lattice constance
	variable zero //= 1.1 //background
	variable amp,x0,y0,wind

	variable a2v = a2*pi/180
	variable a1v = (a1-180)*pi/180
	make/N=(500,500)/o phasesingle
	setscale/I x,-25-x0,25-x0,"",phasesingle
	setscale/I y,-25-y0,25-y0,"",phasesingle
	duplicate/O phasesingle ampsingle

	phasesingle=atan2( wind*(x*sin(-a1v)+y*cos(-a1v)) , x*cos(-a1v)-y*sin(-a1v) )+add
	ampsingle[][]=zero+amp*cos( (2*pi/lattice)*(x*cos(-a2v)-y*sin(-a2v)) + phasesingle[p][q])
	shift2pi(phasesingle)
end

Function shift2pi(name)
	wave name
	variable i,j
	i=0
	do
		j=0
		do
			if (name[i][j]>pi)
				name[i][j] -=2*pi
			endif

			if (name[i][j]<-pi)
				name[i][j] +=2*pi
			endif

			j+=1
		while (j<dimsize(name,1))
		i+=1
	while (i< dimsize(name,0))
end
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
//Ref: PHYSICAL REVIEW B 93, 064522 (2016)
//https://journals.aps.org/prb/pdf/10.1103/PhysRevB.93.064522
//eq. 5b
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_vortexantivortexsimuc(ctrlName) : ButtonControl
	String ctrlName
	Execute "vortexantivortexsimuc()"
end
Proc vortexantivortexsimuc(a_sep,AA,BB,vorticity,pshif,reverseV)
	variable a_sep = 100
	variable AA = 1
	variable BB = 10
	variable vorticity = 1
	variable pshif = 0.5
	variable reverseV = 0
	prompt a_sep,"Vortex-antivortex speration"
	prompt AA, "A"
	prompt BB, "B"
	prompt vorticity,"|m|:vorticity"
	prompt pshif,"Phase shift (π)"
	prompt reverseV,"[-*]: sign of vorticity"
	vortexantivortexsimu(a_sep,AA,BB,vorticity,pshif,reverseV)
end

Function vortexantivortexsimu(a_sep,AA,BB,vorticity,pshif,reverseV)
	variable a_sep
	variable AA
	variable BB
	variable vorticity
	variable pshif
	variable reverseV

	variable NN
	NN = 4*a_sep

	make/o/n=(600,300) vortexpair;
	setscale/i x,-200,200,"",vortexpair;
	setscale/i y,-100,100,"",vortexpair;
	//vortexpair = atan2((x^2+y^2-a_sep^2),2*a_sep*y*abs((1+AA-2*abs(y)/(NN)))^(1/BB))+pshif*pi

	vortexpair = vorticity*atan2(2*a_sep*y*abs((1+AA-2*abs(y)/(NN)))^(1/BB),(x^2+y^2-a_sep^2))+pshif*pi  -reverseV*pi

	makevectorfield_vortexsimu("vortexpair","")
	shrinkvf(10)

	variable/G a_sep_vortex = a_sep
	variable/G AA_vortex = AA
	variable/G BB_vortex = BB
	variable/G vorticity_vortex = vorticity
	variable/G pshif_vortex = pshif
	variable/G reverseV_vortex = reverseV

	SetVariable setv1 value=a_sep_vortex,proc=SetVarProc_vortex1,limits={0,200,2},title="Sepration",pos={75,652},size={100,14}
	SetVariable setv2 value=AA_vortex,proc=SetVarProc_vortex1,limits={0,inf,1},title="A",pos={175,652},size={100,14}
	SetVariable setv3 value=BB_vortex,proc=SetVarProc_vortex1,limits={0,inf,1},title="B",pos={275,652},size={100,14}
	SetVariable setv4 value=vorticity_vortex,proc=SetVarProc_vortex1,limits={0,inf,1},title="|m|:vorticity",pos={375,652},size={100,14}
	SetVariable setv5 value=reverseV_vortex,proc=SetVarProc_vortex1,limits={0,1,1},title="[-*]:vorticity",pos={475,652},size={100,14}

	SetVariable setv6 value=pshif_vortex,proc=SetVarProc_vortex1,limits={0,2,0.1},title="∆φ(π)",pos={575,652},size={100,14}

	cyclecolorwave(vorticity_vortex,87)
	wave color_cycle = $"color_cycle"
	ModifyImage $tpw() ctab= {*,*,color_cycle,0}
end

Function makevectorfield_vortexsimu(name,amp)
	string name  //Name of the phase map
	String amp   //Name of the amplitude map

	string/G phase_vf = name
	string/G amp_vf = amp
	variable/G arrowl_vf = 16.8
	variable/G bk_vf = 6.7
	variable/G lineThick_vf = 1
	variable/G headLen_vf = 12.4
	variable/G headFat_vf = 0.4
	variable/G posMode_vf = 1
	variable/G lenmode_vf

	string namedd = name+"_Backup"
	duplicate/o $name $namedd

	//Make the information of angle at each points
		string S_arrowangle = "arrowangle_"+name
		wave namew = $name
		duplicate/o namew $S_arrowangle
		wave S_arrowanglew = $S_arrowangle
		variable sx, sy
		sx = dimsize($name,0)
		sy = dimsize($name,1)
		redimension/N=(sx*sy) S_arrowanglew


	//Make the Points matrix
		string xpoints = "xpoint_"+name
		string ypoints = "ypoint_"+name

		Make/o/N=(sx*sy) $xpoints
		make/o/n=(sx*sy) $ypoints
		wave xpoint = $xpoints
		wave ypoint = $ypoints

		variable i,j,k
		i=0
		k=0
		do
			j=0
			do
				xpoint[k]=dimoffset($name,0)+j*dimdelta($name,0)
				ypoint[k]=dimoffset($name,1)+i*dimdelta($name,1)
				j+=1
				k+=1
			while (j < sx)
			i+=1
		while (i < sy)


	// Controls arrow length and angle
		string arrowDatas = "arrowData_"+name

		Make/O/N=(sx*sy,2) $arrowDatas
		wave arrowData2 = $arrowDatas
		arrowData2[][1]= S_arrowanglew[p]

		// change length mode, real length or uniform length
			if (cmpstr(amp,"")==0) // amp is empty
				arrowData2[][0]=  arrowl_vf   // Column 0: arrow lengths in points
				lenmode_vf = 1
			else
				lenmode_vf = 2
				string ampdd = amp+"_Backup"
				duplicate/o $amp $ampdd

				//Make the information of length at each points
					wave ampw = $amp
					string arrowlens = "arrowlen_"+name
					duplicate/o ampw $arrowlens
					wave arrowlen2 = $arrowlens
					variable sxamp, syamp
					sxamp = dimsize(ampw,0)
					syamp = dimsize(ampw,1)
					redimension/N=(sxamp*syamp) $arrowlens
					wavestats/Q $arrowlens
					arrowlen2/= V_max
					arrowlen2*= arrowl_vf
					arrowlen2+= bk_vf*arrowl_vf/10

				arrowData2[][0]=  arrowlen2[p]
			endif

	//Draw vector field plot
		Display ypoint vs xpoint
		ModifyGraph mode($ypoints) = 3
		//ModifyGraph arrowMarker($ypoints) = {arrowData2, 0.2, 6, 0.2, 1}
		ModifyGraph arrowMarker($ypoints) = {arrowData2, lineThick_vf, headLen_vf, headFat_vf, posMode_vf}

		ModifyGraph axThick=3,nticks=0,noLabel=2,standoff=0,mirror=2;
		ModifyGraph height= 600;
		ModifyGraph width={Plan,1,bottom,left};

		//Set color of the vector field
			//ModifyGraph zColor($ypoints)={S_arrowanglew,*,*,RainbowCycle,0}
			//ModifyGraph zColor($ypoints)={arrowlen2,*,*,VioletOrangeYellow,0}
			ModifyGraph rgb=(0,0,0)


	//Append image
		appendimage $namedd;ModifyImage $namedd ctab= {*,*,RainbowCycle,0}
		ModifyGraph margin(right)=72;ColorScale/C/N=text0/F=0/A=LC/X=100.20/Y=0.00 image=$namedd;
		ColorScale/C/N=text0 frame=0.00

	//Set scale bar
		//variable lenx = (dimsize($phase_vf,0)-1)*dimdelta($phase_vf,0)
		//variable leny = (dimsize($phase_vf,1)-1)*dimdelta($phase_vf,1)
		//variable x1,x2,lenbar1,lenbar
		//x1 = 0.75*lenx+dimoffset($phase_vf,0)
		//lenbar1 = round(0.2*lenx)
		//if(lenbar1 > 10)
		//	lenbar = lenbar1+(round(lenbar1/10)-lenbar1/10)*10
		//else
		//	lenbar = lenbar1
		//endif
		//X2 = 0.75*lenx+lenbar+dimoffset($phase_vf,0)

		//SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),linethick= 4.00
		//DrawLine x1,0.03*leny+dimoffset($phase_vf,1),x2,0.03*leny+dimoffset($phase_vf,1)
		//string textv =num2str(round(lenbar))+" Å"
		//SetDrawEnv xcoord= bottom,ycoord= left,textrgb= (65535,65535,65535),fstyle= 1,fsize= 20,textxjust= 1,textyjust= 1
		//DrawText 0.85*lenx+dimoffset($phase_vf,0),0.05*leny+dimoffset($phase_vf,1),textv

	//Set controls
		SetVariable set1 size={75,14},value=arrowl_vf,proc=SetVarProc_vf1,limits={0.1,inf,0.1},title="↑ length",pos={1,1}
		SetVariable sets1 pos={340,1},title="Thick",size={65,14},value=lineThick_vf,proc=SetVarProc_vf2,limits={0.1,inf,0.1}
		SetVariable sets2 pos={410,1},size={75,14},value=headLen_vf,proc=SetVarProc_vf2,limits={0.1,inf,0.1},title="headLen"
		SetVariable sets3 pos={485,1},size={75,14},value=headFat_vf,proc=SetVarProc_vf2,limits={0.1,inf,0.1},title="headFat"
		SetVariable sets4 pos={560,1},size={70,14},value=posMode_vf,proc=SetVarProc_vf2,limits={0,3,1},title="posMode"

		popupmenu popvfcolor  size={60,14},proc=PopMenuProc_vf,value="Phase;Plain",mode =2,title="Color",bodyWidth=80,pos={680,1}

		BUTTON VFCLOSE title="X",size={20,20},fColor=(1,52428,26586),fstyle=1,proc=ButtonProc_VF, pos={1320,3}

		PopupMenu appendtordvf proc=PopMenuProc_appendimagevf,value="Remove;φ(r)",pos={1,18}

		Variable/G stepsshrink_vf = 10
		SetVariable setshrink value=stepsshrink_vf,proc=SetVarProc_vfshrink,limits={1,inf,1},pos={1,40},size={65,14},title="Coarse"
		SetVariable set1 size={90,14},pos={1,2}
		SetVariable sets1 pos={287,2},size={80,14}
		SetVariable sets2 pos={366,2},size={80,14}
		SetVariable sets3 pos={446,2},size={80,14}
end

Function vortexantivortexsimu_tune(a_sep,AA,BB,vorticity,pshif,reverseV)
	variable a_sep
	variable AA
	variable BB
	variable vorticity
	variable pshif
	variable reverseV

	variable NN
	NN = 4*a_sep

	make/o/n=(600,300) vortexpair;
	setscale/i x,-200,200,"",vortexpair;
	setscale/i y,-100,100,"",vortexpair;

	vortexpair = vorticity*atan2(2*a_sep*y*abs((1+AA-2*abs(y)/(NN)))^(1/BB),(x^2+y^2-a_sep^2))+pshif*pi -reverseV*pi
end


Function makevectorfield_vortexsimu_tune(name,amp)
	string name  //Name of the phase map
	String amp   //Name of the amplitude map

	string/G phase_vf //= name
	string/G amp_vf //= amp
	variable/G arrowl_vf //= 11
	variable/G bk_vf //= 6.7
	variable/G lineThick_vf //= 1
	variable/G headLen_vf //= 6
	variable/G headFat_vf //= 0.6
	variable/G posMode_vf //= 1
	variable/G lenmode_vf

	string namedd = name+"_Backup"
	duplicate/o $name $namedd

	//Make the information of angle at each points
		string S_arrowangle = "arrowangle_"+name
		wave namew = $name
		duplicate/o namew $S_arrowangle
		wave S_arrowanglew = $S_arrowangle
		variable sx, sy
		sx = dimsize($name,0)
		sy = dimsize($name,1)
		redimension/N=(sx*sy) S_arrowanglew

	//Make the Points matrix
		string xpoints = "xpoint_"+name
		string ypoints = "ypoint_"+name

		Make/o/N=(sx*sy) $xpoints
		make/o/n=(sx*sy) $ypoints
		wave xpoint = $xpoints
		wave ypoint = $ypoints

		variable i,j,k
		i=0
		k=0
		do
			j=0
			do
				xpoint[k]=dimoffset($name,0)+j*dimdelta($name,0)
				ypoint[k]=dimoffset($name,1)+i*dimdelta($name,1)
				j+=1
				k+=1
			while (j < sx)
			i+=1
		while (i < sy)


	// Controls arrow length and angle
		string arrowDatas = "arrowData_"+name

		Make/O/N=(sx*sy,2) $arrowDatas
		wave arrowData2 = $arrowDatas
		arrowData2[][1]= S_arrowanglew[p]

		// change length mode, real length or uniform length
			if (cmpstr(amp,"")==0) // amp is empty
				arrowData2[][0]=  arrowl_vf   // Column 0: arrow lengths in points
				lenmode_vf = 1
			else
				lenmode_vf = 2
				string ampdd = amp+"_Backup"
				duplicate/o $amp $ampdd

				//Make the information of length at each points
					wave ampw = $amp
					string arrowlens = "arrowlen_"+name
					duplicate/o ampw $arrowlens
					wave arrowlen2 = $arrowlens
					variable sxamp, syamp
					sxamp = dimsize(ampw,0)
					syamp = dimsize(ampw,1)
					redimension/N=(sxamp*syamp) $arrowlens
					wavestats/Q $arrowlens
					arrowlen2/= V_max
					arrowlen2*= arrowl_vf
					arrowlen2+= bk_vf*arrowl_vf/10

				arrowData2[][0]=  arrowlen2[p]
			endif
end

Function SetVarProc_vortex1(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G a_sep_vortex
	variable/G AA_vortex
	variable/G BB_vortex
	variable/G vorticity_vortex
	variable/G pshif_vortex
	variable/G reverseV_vortex

	vortexantivortexsimu_tune(a_sep_vortex,AA_vortex,BB_vortex,vorticity_vortex,pshif_vortex,reverseV_vortex)
	makevectorfield_vortexsimu_tune("vortexpair","")
	shrinkvf(10)
	cyclecolorwave(vorticity_vortex,87)
	wave color_cycle = $"color_cycle"
	ModifyImage $tpw() ctab= {*,*,color_cycle,0}
	String msg
	Variable err
	msg=GetErrMessage(GetRTError(0),3);
	err=GetRTError(1)
end







////////////////////////////////////////////////////////////////////////
//** Failed to organize: smooth the phase jump
//** Not implement in the current version
////////////////////////////////////////////////////////////////////////
Function smoothjumphalfvortex_V(name,judge,smoothnp)
	wave name
	variable judge //(=2.9)
	variable smoothnp
	variable i,j,k
	string named=nameofwave(name)+"_sm"
	duplicate/o name $named
	wave namedw = $named
	variable medium,D1,D2
	variable medium1, medium2
	i=0
	do
		j=1
		do
			if (abs(name[i][j]-name[i][j-1]) > judge)

				if (name[i][j] > name[i][j-1])
					medium1 = name[i][j] + pi/2
					medium2 = name[i][j-1] - pi/2

					if (smoothnp == 0)
					else
						k=0
						do
							namedw[i][j+k] = medium1 - (k+1)*(pi/2)/smoothnp - 2*pi
							namedw[i][j-1-k] = medium2 + (k+1)*(pi/2)/smoothnp //+2*pi
							k+=1
						while(k<smoothnp)
					endif
				endif

				if (name[i][j] < name[i][j-1])
					medium1 = name[i][j] - pi/2
					medium2 = name[i][j-1] + pi/2

					if (smoothnp == 0)
					else
						k=0
						do
							namedw[i][j+k] = medium1 + (k+1)*(pi/2)/smoothnp //+2*pi
							namedw[i][j-1-k] = medium2 - (k+1)*(pi/2)/smoothnp -2*pi
							k+=1
						while(k<smoothnp)
					endif
				endif
			endif
			j+=1
		while (j < dimsize(name,1))
		i+=1
	while (i < dimsize(name,0))
	di(namedw)
end
////////////////////////////////////////////////////////////////////////
//** Failed to organize: smooth the phase jump
//** Not implement in the current version
////////////////////////////////////////////////////////////////////////
Function testnewangle(tt)
	variable tt
	make/N=(300,300)/o newangle
	setscale/I x,-50,50,"",newangle
	setscale/I y,-50,50,"",newangle
	variable i,j
	variable xx,yy,theta
	i=0
	do
		j=0
		do
			xx = dimoffset(newangle,0)+i*dimdelta(newangle,0)
			yy = dimoffset(newangle,1)+j*dimdelta(newangle,1)
			theta = atan2(yy,xx)
			newangle[i][j] = smoothphasejump(theta,tt)+1.3

			j+=1
		while (j<dimsize(newangle,1))
		i+=1
	while (i<dimsize(newangle,0))
	di(newangle)
end
Function smoothphasejump(xx,tt)
	variable xx // the angle input
	variable tt // control the jump smoothness, 0 is very sharp
	variable tp = 1
	variable delta = 1
	variable amp1
	amp1 = (pi/2)*sin(xx)*(tp/(delta*sqrt(1-tp*(sin(xx/2))^2)))*tanh(delta*sqrt(1-tp*(sin(xx/2))^2)/(2*0.086*TT/1000)) /2
	return amp1
end


///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
//******************************    TB FeSC Fermi Surface    ******************************
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_FeSC_normal(ctrlName) : ButtonControl
	String ctrlName
	FeSC_normal()
end
Function FeSC_normal()
	variable t1 = -0.3
	variable t2 = 0.53
	variable t = 0.3
	variable tp = -0.6
	variable u = -1.9
	variable selfimg = 0.02
	variable selfreal = 0
	//
	//variable kx,ky
	//ariable E1,E2,E3

	//E1=-2*t1*(cos(x)+cos(y))
	//E2=-2*t2*(cos(x)+cos(y))

	//E3=-2*t*(cos(x)+cos(y))-4*tp*cos(x)*cos(y)

	//a = E1+E2+E3

	string/G mat3dn_cons
	variable/G zn_cons
	variable/G z_cons

	make/n=(200,200,200)/o  a1_001
	setscale/i x,-1.3*pi,1.3*pi,"",a1_001
	setscale/i y,-1.3*pi,1.3*pi,"",a1_001
	setscale/i z,-2,7,"",a1_001

	a1_001 = (-1/pi)*selfimg/(selfimg^2+(z-selfreal-(  -2*t1*(cos(x)+cos(y))-u    ))^2) + (-1/pi)*selfimg/(selfimg^2+(z-selfreal-( -2*t2*(cos(x)+cos(y))-u ))^2) + (-1/pi)*selfimg/(selfimg^2+(z-selfreal-( -2*t*(cos(x)+cos(y))-4*tp*cos(x)*cos(y)-u ))^2)

	a1_001+= (-1/pi)*selfimg/(selfimg^2+(z-selfreal-(  -2*t1*(cos(x+pi)+cos(y+pi))-u    ))^2) + (-1/pi)*selfimg/(selfimg^2+(z-selfreal-( -2*t2*(cos(x+pi)+cos(y+pi))-u ))^2) + (-1/pi)*selfimg/(selfimg^2+(z-selfreal-( -2*t*(cos(x+pi)+cos(y+pi))-4*tp*cos(x+pi)*cos(y+pi)-u ))^2)

	z_cons =0
	execute "d3d(\"a1_001\",2)"

	//////Modify the 3D player for this special simulation use (band structure)
	variable/G divcolor_cons
	divcolor_cons = 1
		wavestats/Q $tpw()
		variable rangls = max(abs(V_max),abs(V_min))
		ModifyImage/W=$grabwinchild(tpw()) $tpw() ctab= {-rangls,rangls,:Packages:NewColortable:dvg_seismic,0};
		ColorScale/W=$grabwinchild(tpw())/C/N=textcc/X=-21.00/Y=5.00/F=0 heightPct=30,nticks=5,minor=1,tickLen=1.00,image=$tpw()//;ColorScale/W=$grabwinchild(Fexyd)/C/N=text0/F=0/A=MC/Y=-120 image=$Fexyd
		variable/G normornot_3dplot =2


	variable/G t1_FeSCb = t1
	variable/G t2_FeSCb = t2
	variable/G t_FeSCb = t
	variable/G tp_FeSCb = tp
	variable/G selfimg_FeSCb = selfimg
	variable/G selfreal_FeSCb = selfreal
	variable/G u_FeSCb = u


	display/N=FeSCbandnormaltightbindingmodel
	tilewindows/WINS=winname(0,1)/R/w=(30,43,50,52)/A=(1,1)
	SetVariable setvarz_u_normal win=FeSCbandnormaltightbindingmodel,title="t1",size={65,14},value=t1_FeSCb,limits={-inf,inf,0.1},proc=SetVarProc_FeSC_normal
	SetVariable setvarz_m_normal win=FeSCbandnormaltightbindingmodel,title="t2",size={65,14},value=t2_FeSCb,limits={-inf,inf,0.1},proc=SetVarProc_FeSC_normal
	SetVariable setvarz_a_normal win=FeSCbandnormaltightbindingmodel,title="t",size={65,14},value=t_FeSCb,limits={-inf,inf,0.1},proc=SetVarProc_FeSC_normal
	SetVariable setvarz_Vsoc_normal win=FeSCbandnormaltightbindingmodel,title="t'",size={65,14},value=tp_FeSCb,limits={-inf,inf,0.1},proc=SetVarProc_FeSC_normal
	SetVariable setvarz_Vsoc_normal2 win=FeSCbandnormaltightbindingmodel,title="u'",size={65,14},value=u_FeSCb,limits={-inf,inf,0.1},proc=SetVarProc_FeSC_normal

	SetVariable setvarz_selfimg_normal win=FeSCbandnormaltightbindingmodel,title="Im(∑)''",size={65,14},value=selfimg_FeSCb,limits={-inf,inf,0.05},proc=SetVarProc_FeSC_normal
	SetVariable setvarz_selfreal_normal win=FeSCbandnormaltightbindingmodel,title="Re(∑)'",size={65,14},value=selfreal_FeSCb,limits={-inf,inf,0.05},proc=SetVarProc_FeSC_normal

	SetVariable setvarz_selfreal_normalzz win=FeSCbandnormaltightbindingmodel,title="E'",size={65,14},value=z_cons,proc=SetVarProc_Cons3dplotFeSC_normalc,limits={dimoffset($mat3dn_cons,zn_cons),(dimoffset($mat3dn_cons,zn_cons)+dimdelta($mat3dn_cons,zn_cons)*(dimsize($mat3dn_cons,zn_cons)-1)),dimdelta($mat3dn_cons,zn_cons)}

	Button launchLinecut win=FeSCbandnormaltightbindingmodel,title="Linecut",size={65,14},fSize=10,proc=ButtonProc_Cons3dplotlcf3
	Button MAKEFS win=FeSCbandnormaltightbindingmodel,title="Make FS",size={80,14},fSize=10,proc=ButtonProc_makeFeSC_normalFSc
end


Function SetVarProc_Cons3dplotFeSC_normalc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G t1_FeSCb //= t1
	variable/G t2_FeSCb //= t2
	variable/G t_FeSCb //= t
	variable/G tp_FeSCb //= tp
	variable/G selfimg_FeSCb //= selfimg
	variable/G selfreal_FeSCb //= selfreal
	variable/G u_FeSCb
	updateFeSC_normalFS(t1_FeSCb,t2_FeSCb,t_FeSCb,tp_FeSCb,u_FeSCb,selfimg_FeSCb,selfreal_FeSCb)
	string/G mat3dn_cons
	variable/G z_cons
	//** Indicative line
	string Zpp = "Zpp_"+mat3dn_cons
	wave zppw = $zpp
	Zppw=z_cons
end

Function updateFeSC_normalFS(t1,t2,t,tp,u,selfimg,selfreal)
	variable t1
	variable t2 //= 1
	variable t //= 1
	variable tp// = 1
	variable u
	variable selfimg// = 0.1
	variable selfreal //= 0


	string/G mat3dn_cons
	variable/G zn_cons
	variable/G z_cons

	variable/G addY_3dplot
	variable/G addX_3dplot
	//z_cons = (dimoffset($mat3dn_cons,zn_cons)+dimdelta($mat3dn_cons,zn_cons)*round((dimsize($mat3dn_cons,zn_cons)-1)/2)) //energy to show
	//variable Z_constp=(z_cons-dimoffset($mat3dn_cons,zn_cons))/dimdelta($mat3dn_cons,zn_cons)

	string zslice="Zslice_"+mat3dn_cons
	wave zslicew=$zslice
	zslicew = (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-(    -2*t1*(cos(x)+cos(y))-u  ))^2) + (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-(  -2*t2*(cos(x)+cos(y))-u   ))^2) + (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-(   -2*t*(cos(x)+cos(y))-4*tp*cos(x)*cos(y)-u  ))^2)
	zslicew += (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-(    -2*t1*(cos(x+pi)+cos(y+pi))-u  ))^2) + (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-(  -2*t2*(cos(x+pi)+cos(y+pi))-u   ))^2) + (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-(   -2*t*(cos(x+pi)+cos(y+pi))-4*tp*cos(x+pi)*cos(y+pi)-u  ))^2)

end



Function SetVarProc_FeSC_normal(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/G t1_FeSCb //= t1
	variable/G t2_FeSCb //= t2
	variable/G t_FeSCb //= t
	variable/G tp_FeSCb //= tp
	variable/G selfimg_FeSCb //= selfimg
	variable/G selfreal_FeSCb //= selfreal
	variable/G u_FeSCb
	updateFeSC_normal(t1_FeSCb,t2_FeSCb,t_FeSCb,tp_FeSCb,u_FeSCb,selfimg_FeSCb,selfreal_FeSCb)
end
Function updateFeSC_normal(t1,t2,t,tp,u,selfimg,selfreal)
	variable t1
	variable t2 //= 1
	variable t //= 1
	variable tp// = 1
	variable u
	variable selfimg// = 0.1
	variable selfreal //= 0

	string/G mat3dn_cons
	variable/G zn_cons
	variable/G z_cons

	variable/G addY_3dplot
	variable/G addX_3dplot


	string zslice="Zslice_"+mat3dn_cons
	wave zslicew=$zslice
	zslicew = (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-(    -2*t1*(cos(x)+cos(y)) -u  ))^2) + (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-(  -2*t2*(cos(x)+cos(y)) -u  ))^2) + (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-(   -2*t*(cos(x)+cos(y))-4*tp*cos(x)*cos(y) -u ))^2)
	zslicew += (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-(    -2*t1*(cos(x+pi)+cos(y+pi))-u  ))^2) + (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-(  -2*t2*(cos(x+pi)+cos(y+pi))-u   ))^2) + (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-(   -2*t*(cos(x+pi)+cos(y+pi))-4*tp*cos(x+pi)*cos(y+pi)-u  ))^2)

	string lh="linetest_"+mat3dn_cons
	string lv="linetestv_"+mat3dn_cons
	wave lhw=$lh
	wave lvw=$lv
	variable x1h,x2h,y1h,y2h
	variable x1v,x2v,y1v,y2v
	x1h = dimoffset(lhw,0)
	x2h = dimoffset(lhw,0)+dimdelta(lhw,0)*(dimsize(lhw,0)-1)
	y1h = lhw[0]
	y2h = lhw[1]

	variable kh
	variable bh

	x1v = dimoffset(lvw,0)
	x2v = dimoffset(lvw,0)+dimdelta(lvw,0)*(dimsize(lvw,0)-1)
	y1v = lvw[0]
	y2v = lvw[1]

	variable kv
	variable bv

	string lhline,lvline
	lhline="LH_"+mat3dn_cons
	lvline="LV_"+mat3dn_cons
	wave lhlinew=$lhline
	wave lvlinew=$lvline

	if (abs(y1h-y2h) <= abs(x1h-x2h))
		kh = (y1h-y2h)/(x1h-x2h)
		bh = y1h-kh*x1h
		//lhlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+(x^2+(kh*x+bh)^2)/(2*m)+sqrt((a*x*(kh*x+bh))^2+(Vsoc*x)^2+(Vsoc*(kh*x+bh))^2)))^2)+(-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+(x^2+(kh*x+bh)^2)/(2*m)-sqrt((a*x*(kh*x+bh))^2+(Vsoc*x)^2+(Vsoc*(kh*x+bh))^2)))^2)
		lhlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(    -2*t1*(cos(x)+cos(kh*x+bh)) -u ))^2) + (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(   -2*t2*(cos(x)+cos(kh*x+bh)) -u ))^2) + (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(     -2*t*(cos(x)+cos(kh*x+bh))-4*tp*cos(x)*cos(kh*x+bh)  -u    ))^2)
		lhlinew += (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(    -2*t1*(cos(x+pi)+cos(kh*x+bh+pi)) -u ))^2) + (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(   -2*t2*(cos(x+pi)+cos(kh*x+bh+pi)) -u ))^2) + (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(     -2*t*(cos(x+pi)+cos(kh*x+bh+pi))-4*tp*cos(x+pi)*cos(kh*x+bh+pi)  -u    ))^2)

	else
		kh = (x1h-x2h)/(y1h-y2h)
		bh = x1h-kh*y1h
		//lhlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+((kh*x+bh)^2+x^2)/(2*m)+sqrt((a*(kh*x+bh)*x)^2+(Vsoc*(kh*x+bh))^2+(Vsoc*x)^2)))^2)+(-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+((kh*x+bh)^2+x^2)/(2*m)-sqrt((a*(kh*x+bh)*x)^2+(Vsoc*(kh*x+bh))^2+(Vsoc*x)^2)))^2)
		lhlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(    -2*t1*(cos(kh*x+bh)+cos(x)) -u    ))^2)  +  (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(     -2*t2*(cos(kh*x+bh)+cos(x))  -u   ))^2)  +  (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(      -2*t*(cos(kh*x+bh)+cos(x))-4*tp*cos(kh*x+bh)*cos(x)  -u    ))^2)
		lhlinew += (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(    -2*t1*(cos(kh*x+bh+pi)+cos(x+pi)) -u    ))^2)  +  (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(     -2*t2*(cos(kh*x+bh+pi)+cos(x+pi))  -u   ))^2)  +  (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(      -2*t*(cos(kh*x+bh+pi)+cos(x+pi))-4*tp*cos(kh*x+bh+pi)*cos(x+pi)  -u    ))^2)

	endif

	if (abs(y1v-y2v) <= abs(x1v-x2v))
		kv = (y1v-y2v)/(x1v-x2v)
		bv = y1v-kv*x1v
		//lvlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+(x^2+(kv*x+bv)^2)/(2*m)+sqrt((a*x*(kv*x+bv))^2+(Vsoc*x)^2+(Vsoc*(kv*x+bv))^2)))^2)+(-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+(x^2+(kv*x+bv)^2)/(2*m)-sqrt((a*x*(kv*x+bv))^2+(Vsoc*x)^2+(Vsoc*(kv*x+bv))^2)))^2)
		lvlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(    -2*t1*(cos(x)+cos(kv*x+bv))  -u   ))^2)  +  (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(     -2*t2*(cos(x)+cos(kv*x+bv)) -u ))^2)  +  (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(     -2*t*(cos(x)+cos(kv*x+bv))-4*tp*cos(x)*cos(kv*x+bv)  -u    ))^2)
		lvlinew += (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(    -2*t1*(cos(x+pi)+cos(kv*x+bv+pi))  -u   ))^2)  +  (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(     -2*t2*(cos(x+pi)+cos(kv*x+bv+pi)) -u ))^2)  +  (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(     -2*t*(cos(x+pi)+cos(kv*x+bv+pi))-4*tp*cos(x+pi)*cos(kv*x+bv+pi)  -u    ))^2)

	else
		kv = (x1v-x2v)/(y1v-y2v)
		bv = x1v-kv*y1v
		//lvlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+((kv*x+bv)^2+x^2)/(2*m)+sqrt((a*(kv*x+bv)*x)^2+(Vsoc*(kh*x+bh))^2+(Vsoc*x)^2)))^2)+(-1/pi)*selfimg/(selfimg^2+(y-selfreal-(-u+((kv*x+bv)^2+x^2)/(2*m)-sqrt((a*(kv*x+bv)*x)^2+(Vsoc*(kv*x+bv))^2+(Vsoc*x)^2)))^2)
		lvlinew = (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(    -2*t1*(cos(kv*x+bv)+cos(x))  -u   ))^2)  +  (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(    -2*t2*(cos(kv*x+bv)+cos(x))  -u  ))^2)  +  (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(      -2*t*(cos(kv*x+bv)+cos(x))-4*tp*cos(kv*x+bv)*cos(x)  -u    ))^2)
		lvlinew += (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(    -2*t1*(cos(kv*x+bv+pi)+cos(x+pi))  -u   ))^2)  +  (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(    -2*t2*(cos(kv*x+bv+pi)+cos(x+pi))  -u  ))^2)  +  (-1/pi)*selfimg/(selfimg^2+(y-selfreal-(      -2*t*(cos(kv*x+bv+pi)+cos(x+pi))-4*tp*cos(kv*x+bv+pi)*cos(x+pi)  -u    ))^2)

	endif
	variable lensh = sqrt((x1h-x2h)^2+(y1h-y2h)^2)
	variable lensv = sqrt((x1v-x2v)^2+(y1v-y2v)^2)
	setscale/i x,-lensh/2,lensh/2,"",lhlinew
	setscale/i x,-lensv/2,lensv/2,"",lvlinew

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


Function ButtonProc_Cons3dplotlcf3(ctrlName) : ButtonControl
	String ctrlName
	string/G mat3dn_cons

	string mat3dn_consf = mat3dn_cons//+"_FFT3d"


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
		SetVariable setvarangle win=$grabwin(slicename),title="Rotate",size={65,14},value=angle_3dplot,proc=SetVarProc_rotate3dplotf2,pos={159,1}
		SetVariable setvarangle win=$grabwin(slicename),limits={-89,89,1}

		//SetVariable setvarangle2 win=FeSCbandnormaltightbindingmodel,title="Rotate",size={65,14},value=angle_3dplot,proc=SetVarProc_rotate3dplotf22
		//SetVariable setvarangle2 win=FeSCbandnormaltightbindingmodel,limits={-89,89,1}


	//**SetVar of AddY [set the Yrange(angel) by auto search]
		SetVariable setaddY win=$grabwin(slicename),title="LH",size={65,14},value=addY_3dplot,proc=SetVarProc_addY3dplotf2,pos={225,1}
		duplicate/o findrangeforangle_LHf(mat3dn_consf,angle_3dplot,zn_cons) rotateYlimit
		SetVariable setaddY win=$grabwin(slicename),limits={rotateYlimit[0],rotateYlimit[1],1}


		//SetVariable setaddY2 win=FeSCbandnormaltightbindingmodel,title="LH",size={65,14},value=addY_3dplot,proc=SetVarProc_rotate3dplotf22//SetVarProc_addY3dplotf22
		//SetVariable setaddY2 win=FeSCbandnormaltightbindingmodel,limits={rotateYlimit[0],rotateYlimit[1],1}

	//**SetVar of AddX [set the Xrange(angel) by auto search]
		SetVariable setaddX win=$grabwin(slicename),title="LV",size={65,14},value=addX_3dplot,proc=SetVarProc_addX3dplotf2,pos={292,1}
		duplicate/o findrangeforangle_LVf(mat3dn_consf,angle_3dplot,zn_cons) rotateXlimit
		SetVariable setaddX win=$grabwin(slicename),limits={rotateXlimit[0],rotateXlimit[1],1}

		//SetVariable setaddX2 win=FeSCbandnormaltightbindingmodel,title="LV",size={65,14},value=addX_3dplot,proc=SetVarProc_rotate3dplotf22//SetVarProc_addX3dplotf22
		//SetVariable setaddX2 win=FeSCbandnormaltightbindingmodel,limits={rotateXlimit[0],rotateXlimit[1],1}

	//**Extract LinecutH and make graph
		anglelinecutHf(mat3dn_consf,angle_3dplot,zn_cons,addY_3dplot,normornot_3dplot,smornot_3dplot)
		string linecutH = "LH_"+mat3dn_consf
		di($linecutH)
		variable/G FFTmode_3dplot
		if (FFTmode_3dplot == 5)
			ModifyImage $linecutH ctab= {*,*,VioletOrangeYellow,0}
		else
			//color3s_for3d($linecutH,30)
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
			ModifyImage $linecutV ctab= {*,*,VioletOrangeYellow,0}
		else
			//color3s_for3d($linecutV,30)
		endif
		Modifygraph/W=$grabwinnonew(linecutV) width=400, height=200
		Label left "\\Z16\\F'times'\\f02E - E\\BF\\f00\\M\\F'times'\\Z16 (meV)"
		Label bottom "\\Z16\\f02k\\f00 (2π Å\\S\\Z10-1\\M\\Z16)"

		ModifyGraph/W=$grabwinnonew(linecutV) axThick=3,axRGB=(16385,65535,41303),tlblRGB=(16385,65535,41303),alblRGB=(16385,65535,41303)
		tilewindows/WINS=grabwinnonew(linecutV)/R/w=(56,0,100,30)/A=(1,1)



	//** Control of Advanced Modes
		//popupmenu popselectmode3d win=$grabwin(slicename), pos={1,36},bodyWidth=65,proc=PopMenuProc_selmode3dplotf,value="2Point;FreeHand;Circular",bodyWidth=68
		//Button Bfreehandprofile3d win=$grabwin(slicename), title="Go",proc=ButtonProc_L3dplotdof,size={30,15},fSize=11,pos={35,56}

	//** Tile window
		//tilewindows/WINS=WinList("*", ";","WIN:1")/R/w=(3,0,92,100)/A=(2,4)
end

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
Function ButtonProc_makeFeSC_normalFSc(ctrlName) : ButtonControl
	String ctrlName
	execute "makeFeSC_normalFSc()"
end

Proc makeFeSC_normalFSc(t1,t2,t,tp,u,selfimg,selfreal)
	variable t1 = t1_FeSCb
	variable t2 = t2_FeSCb//= 1
	variable t = t_FeSCb//= 1
	variable tp = tP_FeSCb// = 1
	variable u = U_FeSCb
	variable selfimg = selfimg_FeSCb// = 0.1
	variable selfreal = selfreal_FeSCb //=
	variable/G t1_FeSCb //= t1
	variable/G t2_FeSCb //= t2
	variable/G t_FeSCb //= t
	variable/G tp_FeSCb //= tp
	variable/G selfimg_FeSCb //= selfimg
	variable/G selfreal_FeSCb //= selfreal
	variable/G u_FeSCb
	makeFeSC_normalFS(t1,t2,t,tp,u,selfimg,selfreal)
end
Function makeFeSC_normalFS(t1,t2,t,tp,u,selfimg,selfreal)
	variable t1
	variable t2 //= 1
	variable t //= 1
	variable tp// = 1
	variable u
	variable selfimg// = 0.1
	variable selfreal //= 0

	make/n=(800,800)/o  FeSC_normalFS
	setscale/i x,-1.3*pi,1.3*pi,"",FeSC_normalFS
	setscale/i y,-1.3*pi,1.3*pi,"",FeSC_normalFS
	variable z_cons = 0

	FeSC_normalFS = (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-(    -2*t1*(cos(x)+cos(y))-u  ))^2) + (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-(  -2*t2*(cos(x)+cos(y))-u   ))^2) + (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-(   -2*t*(cos(x)+cos(y))-4*tp*cos(x)*cos(y)-u  ))^2)
	FeSC_normalFS += (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-(    -2*t1*(cos(x+pi)+cos(y+pi))-u  ))^2) + (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-(  -2*t2*(cos(x+pi)+cos(y+pi))-u   ))^2) + (-1/pi)*selfimg/(selfimg^2+(z_cons-selfreal-(   -2*t*(cos(x+pi)+cos(y+pi))-4*tp*cos(x+pi)*cos(y+pi)-u  ))^2)
	di(FeSC_normalFS)
end
///////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_SumCompOrder(ctrlName) : ButtonControl
	String ctrlName
	Execute "SumCompOrder()"
end
Proc SumCompOrder(sel,A1,A2,A3,theta,wLength,A4,inc_L,inc_an)
	variable sel
	variable A1 = 1
	variable A2 = 1
	variable A3 = 1
	variable theta = 0
	variable wLength = 40

	variable A4 = 0
	Variable inc_L=0
	variable inc_an=0
	prompt sel,"Lattice",popup,"Square;Triangular"
	prompt A1,"Amplitude of Q1"
	prompt A2,"Amplitude of Q2"
	prompt A3,"Amplitude of Q3"
	prompt theta,"Angel of Q1 (°)"
	prompt wLength,"Wave length of the commensurate orders"


	Prompt A4,"Amplitude of an additional incommensurate vector"
	prompt inc_L,"wavelength off from the commensurate value"
	prompt inc_an,"angle off from the direction of commensurate Q1"


	if (sel == 1)
		SumCompOrder_square(A1,A2,theta)
	endif

	if (sel == 2)
		SumCompOrder_tria(A1,A2,A3,theta,A4,inc_L,inc_an,wLength)
	endif
end
Function SumCompOrder_square(A1,A2,theta)
	variable A1,A2,theta
	make/N=(300,300)/o Square1
	make/N=(300,300)/o Square2
	make/N=(300,300)/o Square
	setscale/I x,-150,150,"",Square1
	setscale/I y,-150,150,"",Square1
	setscale/I x,-150,150,"",Square2
	setscale/I y,-150,150,"",Square2

	setscale/I x,-150,150,"",Square
	setscale/I y,-150,150,"",Square
	Square1=A1*cos((2*pi/40)*(cos(theta*pi/180)*x+sin(theta*pi/180)*y));
	Square2=A2*cos((2*pi/40)*(cos((90+theta)*pi/180)*x+sin((90+theta)*pi/180)*y));
	//Square3=A3*cos((2*pi/40)*(cos((120+theta)*pi/180)*x+sin((120+theta)*pi/180)*y));
	Square=Square2+Square1


	String FFTout
	FFTout = nameofWave(Square) + "_FFT"
	FFT/PAD={3*dimsize(Square,0),3*dimsize(Square,1)}/out=3/DEST=$FFTout cvtcmplx(Square)

	display/N=SumCompOrder_squaresim;modifygraph width=900,height=600
	Display/HOST=#/W=(0,0.05,0.4,0.55);appendimage Square1;ModifyGraph mirror=2;ModifyImage Square1 ctab= {-max(A1,A2),max(A1,A2),VioletOrangeYellow,0};ModifyGraph width={Plan,1,bottom,left};ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;
	setActiveSubwindow ##;Display/HOST=#/W=(0.3,0.05,0.7,0.55);appendimage Square2;ModifyGraph mirror=2;ModifyImage Square2 ctab= {-max(A1,A2),max(A1,A2),VioletOrangeYellow,0};ModifyGraph width={Plan,1,bottom,left};ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;//;ColorScale/C/N=text0/F=0/B=1/A=RC/X=-20.00/Y=0.00 image=phasesingle;ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;ColorScale/C/N=text0 frame=0.00//;Label bottom "\\Z16M          \t \t\t\t\t\t\t\t\tΓ\t\t\t\t\t\t\t\t\t          M"

	setActiveSubwindow ##;Display/HOST=#/W=(0,0.5,0.4,1);appendimage $FFTout;ModifyGraph mirror=2;ModifyImage $FFTout ctab= {*,*,VioletOrangeYellow,0};ModifyGraph width={Plan,1,bottom,left};ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;SetAxis left -0.05,0.05;SetAxis bottom -0.05,0.05
	setActiveSubwindow ##;Display/HOST=#/W=(0.3,0.5,0.7,1);appendimage Square;ModifyGraph mirror=2;ModifyImage Square ctab= {*,*,VioletOrangeYellow,0};ModifyGraph width={Plan,1,bottom,left};ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;
	setActiveSubwindow ##

	TextBox/C/N=text0/A=RC/F=0/B=1/X=3/Y=-20.00 "\\Z15\r\\$WMTEX$ |A_{1}|cos(Q_{1}\\cdot r)+|A_{2}|cos(Q_{2}\\cdot r) \\$/WMTEX$\rAmplitude along 3 lattice direction:";DelayUpdate
	AppendText/N=text0 "Direction \\$WMTEX$ Q_{i}\\ \\$/WMTEX$: the amplitude is \\$WMTEX$  |A_{i}|\\$/WMTEX$"

	variable/G A1_square = A1
	variable/G A2_square = A2
	//variable/G A3_square = A3
	variable/G theta_square = theta


	SetVariable set1 win=SumCompOrder_squaresim, title="|A1|",size={100,15},value=A1_square,limits={0.1,inf,0.1},proc=SetVarProc_SumCompOrder_square
	SetVariable set2 win=SumCompOrder_squaresim, title="|A2|",size={100,15},value=A2_square,limits={0.1,inf,0.1},proc=SetVarProc_SumCompOrder_square

	//SetVariable set3 win=SumCompOrder_squaresim, title="|A3|",size={100,15},value=A3_square,limits={0.1,inf,0.1},proc=SetVarProc_SumCompOrder_square
	SetVariable set4 win=SumCompOrder_squaresim, title="θ",size={100,15},value=theta_square,limits={0,180,1},proc=SetVarProc_SumCompOrder_square

	ckfig_child(winname(0,1))
end

Function SetVarProc_SumCompOrder_square(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G A1_square
	variable/G A2_square
	variable/G theta_square

	cons_SumCompOrder_square(A1_square,A2_square,theta_square)
end

Function cons_SumCompOrder_square(A1,A2,theta)
	variable A1,A2,theta
	make/N=(300,300)/o Square1
	make/N=(300,300)/o Square2
	make/N=(300,300)/o Square
	setscale/I x,-150,150,"",Square1
	setscale/I y,-150,150,"",Square1
	setscale/I x,-150,150,"",Square2
	setscale/I y,-150,150,"",Square2

	setscale/I x,-150,150,"",Square
	setscale/I y,-150,150,"",Square
	Square1=A1*cos((2*pi/40)*(cos(theta*pi/180)*x+sin(theta*pi/180)*y));
	Square2=A2*cos((2*pi/40)*(cos((90+theta)*pi/180)*x+sin((90+theta)*pi/180)*y));
	Square=Square2+Square1


	String FFTout
	FFTout = nameofWave(Square) + "_FFT"
	FFT/PAD={3*dimsize(Square,0),3*dimsize(Square,1)}/out=3/DEST=$FFTout cvtcmplx(Square)

	ModifyImage/W=$"SumCompOrder_squaresim#G0" Square1 ctab= {-max(A1,A2),max(A1,A2),VioletOrangeYellow,0};
	ModifyImage/W=$"SumCompOrder_squaresim#G1" Square2 ctab= {-max(A1,A2),max(A1,A2),VioletOrangeYellow,0};
end

////////////////////////////////////////////////////////////////////////////////
Function SumCompOrder_tria(A1,A2,A3,theta,A4,inc_L,inc_an,wLength)
	variable A1,A2,A3,theta,A4,inc_L,inc_an,wLength
	make/N=(300,300)/o trian1
	make/N=(300,300)/o trian2
	make/N=(300,300)/o trian3
	make/N=(300,300)/o trian4

	make/N=(300,300)/o trian
	setscale/I x,-150,150,"",trian1
	setscale/I y,-150,150,"",trian1
	setscale/I x,-150,150,"",trian2
	setscale/I y,-150,150,"",trian2
	setscale/I x,-150,150,"",trian3
	setscale/I y,-150,150,"",trian3
	setscale/I x,-150,150,"",trian4
	setscale/I y,-150,150,"",trian4

	setscale/I x,-150,150,"",trian
	setscale/I y,-150,150,"",trian

	trian1=A1*cos((2*pi/wLength)*(cos(theta*pi/180)*x+sin(theta*pi/180)*y));
	trian2=A2*cos((2*pi/wLength)*(cos((60+theta)*pi/180)*x+sin((60+theta)*pi/180)*y));
	trian3=A3*cos((2*pi/wLength)*(cos((120+theta)*pi/180)*x+sin((120+theta)*pi/180)*y));
	trian4=A4*cos((2*pi/(wLength+inc_L))*(cos((inc_an+theta)*pi/180)*x+sin((inc_an+theta)*pi/180)*y));


	trian=trian3+trian2+trian1+trian4


	String FFTout
	FFTout = nameofWave(trian) + "_FFT"
	FFT/PAD={3*dimsize(trian,0),3*dimsize(trian,1)}/out=3/DEST=$FFTout cvtcmplx(trian)

	display/N=SumCompOrder_triasim;modifygraph width=900,height=600
	Display/HOST=#/W=(0,0.05,0.4,0.55);appendimage trian1;ModifyGraph mirror=2;ModifyImage trian1 ctab= {-max(A1,A2,A3),max(A1,A2,A3),VioletOrangeYellow,0};ModifyGraph width={Plan,1,bottom,left};ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;
	setActiveSubwindow ##;Display/HOST=#/W=(0.3,0.05,0.7,0.55);appendimage trian2;ModifyGraph mirror=2;ModifyImage trian2 ctab= {-max(A1,A2,A3),max(A1,A2,A3),VioletOrangeYellow,0};ModifyGraph width={Plan,1,bottom,left};ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;//;ColorScale/C/N=text0/F=0/B=1/A=RC/X=-20.00/Y=0.00 image=phasesingle;ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;ColorScale/C/N=text0 frame=0.00//;Label bottom "\\Z16M          \t \t\t\t\t\t\t\t\tΓ\t\t\t\t\t\t\t\t\t          M"
	setActiveSubwindow ##;Display/HOST=#/W=(0.6,0.05,1,0.55);appendimage trian3;ModifyGraph mirror=2;ModifyImage trian3 ctab= {-max(A1,A2,A3),max(A1,A2,A3),VioletOrangeYellow,0};ModifyGraph width={Plan,1,bottom,left};ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;//;ColorScale/C/N=text0/F=0/B=1/A=RC/X=-20.00/Y=0.00 image=phasesingle;ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;ColorScale/C/N=text0 frame=0.00//;Label bottom "\\Z16M          \t \t\t\t\t\t\t\t\tΓ\t\t\t\t\t\t\t\t\t          M"

	setActiveSubwindow ##;Display/HOST=#/W=(0,0.5,0.4,1);appendimage $FFTout;ModifyGraph mirror=2;ModifyImage $FFTout ctab= {*,*,VioletOrangeYellow,0};ModifyGraph width={Plan,1,bottom,left};ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;SetAxis left -0.05,0.05;SetAxis bottom -0.05,0.05
	setActiveSubwindow ##;Display/HOST=#/W=(0.3,0.5,0.7,1);appendimage trian;ModifyGraph mirror=2;ModifyImage trian ctab= {*,*,VioletOrangeYellow,0};ModifyGraph width={Plan,1,bottom,left};ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;
	setActiveSubwindow ##;Display/HOST=#/W=(0.6,0.5,1,1);appendimage trian4;ModifyGraph mirror=2;ModifyImage trian4 ctab= {*,*,VioletOrangeYellow,0};ModifyGraph width={Plan,1,bottom,left};ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;

	setActiveSubwindow ##
	TextBox/C/N=text0/A=MB/X=0.00/Y=0.00 "\\Z15";DelayUpdate
	AppendText/N=text0 "\\$WMTEX$ |A_{1}|cos(Q_{1}\\cdot r)+|A_{2}|cos(Q_{2}\\cdot r)+|A_{3}|cos(Q_{3}\\cdot r) \\$/WMTEX$ Amplitude along 3 lattice direction: Directio";DelayUpdate
	AppendText/N=text0 /NOCR "n \\$WMTEX$ Q_{i}\\pm Q_{j} \\$/WMTEX$: the amplitude is \\$WMTEX$  |A_{i}|+ |A_{j}| \\$/WMTEX$"
	TextBox/C/N=text0/F=0

	TextBox/C/N=text1/F=0/A=LT/X=1.5/Y=7 "\\$WMTEX$ Q_{1} \\$/WMTEX$"
	TextBox/C/N=text2/F=0/A=LT/X=32/Y=7 "\\$WMTEX$ Q_{2} \\$/WMTEX$"
	TextBox/C/N=text3/F=0/A=LT/X=62/Y=7 "\\$WMTEX$ Q_{3} \\$/WMTEX$"
	TextBox/C/N=text4/F=0/A=LT/X=92/Y=52 "\\$WMTEX$ Q_{\rm IKS,4} \\$/WMTEX$"
	TextBox/C/N=text5/F=0/A=LT/X=49/Y=3.00 "Additonal Incommensurate Vector"

	variable/G A1_tria = A1
	variable/G A2_tria = A2
	variable/G A3_tria = A3
	variable/G theta_tria = theta
	variable/G A4_tria = A4
	variable/G inc_L_tria = inc_L
	variable/G inc_an_tria = inc_an
	variable/G wLength_tria = wLength


	SetVariable set1 win=SumCompOrder_triasim, title="|A1|",size={100,15},value=A1_tria,limits={0.1,inf,0.1},proc=SetVarProc_SumCompOrder_tria
	SetVariable set2 win=SumCompOrder_triasim, title="|A2|",size={100,15},value=A2_tria,limits={0.1,inf,0.1},proc=SetVarProc_SumCompOrder_tria

	SetVariable set3 win=SumCompOrder_triasim, title="|A3|",size={100,15},value=A3_tria,limits={0.1,inf,0.1},proc=SetVarProc_SumCompOrder_tria
	SetVariable set4 win=SumCompOrder_triasim, title="θ",size={100,15},value=theta_tria,limits={0,180,1},proc=SetVarProc_SumCompOrder_tria

	SetVariable set5 win=SumCompOrder_triasim, title="|A4|",size={100,15},value=A4_tria,limits={0.1,inf,0.1},proc=SetVarProc_SumCompOrder_tria
	SetVariable set6 win=SumCompOrder_triasim, title="δθ",size={100,15},value=inc_an_tria,limits={0,180,1},proc=SetVarProc_SumCompOrder_tria
	SetVariable set7 win=SumCompOrder_triasim, title="δλ",size={100,15},value=inc_L_tria,limits={-inf,inf,1},proc=SetVarProc_SumCompOrder_tria
	SetVariable set8 win=SumCompOrder_triasim, title="λ",size={100,15},value=wLength_tria,limits={0,inf,1},proc=SetVarProc_SumCompOrder_tria

	SetVariable set1 pos={1,2}
	SetVariable set2 pos={111,2}
	SetVariable set3 pos={221,2}
	SetVariable set4 pos={65,20}
	SetVariable set5 pos={426,2}
	SetVariable set6 pos={530,2}
	SetVariable set7 pos={634,2}
	SetVariable set8 pos={175,20}

	ckfig_child(winname(0,1))
end

Function SetVarProc_SumCompOrder_tria(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G A1_tria
	variable/G A2_tria
	variable/G A3_tria
	variable/G theta_tria
	variable/G A4_tria
	variable/G inc_L_tria
	variable/G inc_an_tria
	variable/G wLength_tria

	cons_SumCompOrder_tria(A1_tria,A2_tria,A3_tria,theta_tria,A4_tria,inc_L_tria,inc_an_tria,wLength_tria)
end

Function cons_SumCompOrder_tria(A1,A2,A3,theta,A4,inc_L,inc_an,wLength)
	variable A1,A2,A3,theta,A4,inc_L,inc_an,wLength
	make/N=(300,300)/o trian1
	make/N=(300,300)/o trian2
	make/N=(300,300)/o trian3
	make/N=(300,300)/o trian4

	make/N=(300,300)/o trian
	setscale/I x,-150,150,"",trian1
	setscale/I y,-150,150,"",trian1
	setscale/I x,-150,150,"",trian2
	setscale/I y,-150,150,"",trian2
	setscale/I x,-150,150,"",trian3
	setscale/I y,-150,150,"",trian3
	setscale/I x,-150,150,"",trian4
	setscale/I y,-150,150,"",trian4

	setscale/I x,-150,150,"",trian
	setscale/I y,-150,150,"",trian

	trian1=A1*cos((2*pi/wLength)*(cos(theta*pi/180)*x+sin(theta*pi/180)*y));
	trian2=A2*cos((2*pi/wLength)*(cos((60+theta)*pi/180)*x+sin((60+theta)*pi/180)*y));
	trian3=A3*cos((2*pi/wLength)*(cos((120+theta)*pi/180)*x+sin((120+theta)*pi/180)*y));
	trian4=A4*cos((2*pi/(wLength+inc_L))*(cos((inc_an+theta)*pi/180)*x+sin((inc_an+theta)*pi/180)*y));

	trian=trian3+trian2+trian1+trian4

	String FFTout
	FFTout = nameofWave(trian) + "_FFT"
	FFT/PAD={3*dimsize(trian,0),3*dimsize(trian,1)}/out=3/DEST=$FFTout cvtcmplx(trian)

	ModifyImage/W=$"SumCompOrder_triasim#G0" trian1 ctab= {-max(A1,A2,A3,A4),max(A1,A2,A3,A4),VioletOrangeYellow,0};
	ModifyImage/W=$"SumCompOrder_triasim#G1" trian2 ctab= {-max(A1,A2,A3,A4),max(A1,A2,A3,A4),VioletOrangeYellow,0};
	ModifyImage/W=$"SumCompOrder_triasim#G2" trian3 ctab= {-max(A1,A2,A3,A4),max(A1,A2,A3,A4),VioletOrangeYellow,0};
	ModifyImage/W=$"SumCompOrder_triasim#G5" trian4 ctab= {-max(A1,A2,A3,A4),max(A1,A2,A3,A4),VioletOrangeYellow,0};
	SetAxis/W=$"SumCompOrder_triasim#G3" left -2/(wLength),2/(wLength);SetAxis/W=$"SumCompOrder_triasim#G3" bottom -2/(wLength),2/(wLength)
end

//***************************************************************************************************************************
Function ButtonProc_simupdwwithw(ctrlName) : ButtonControl
	String ctrlName
	Execute "simupdwwithw()"
end
proc simupdwwithw(indicate)
	String indicate = "Open the code to adjust parameters"
	Prompt indicate,"Indicate"
	make/N=(600,300)/o simupdwn
	setscale/I x,-7,7,"",simupdwn
	setscale/I y,0,31,"",simupdwn

	//variable x0 = (2.09+0.13*cos((2*pi/3.8)*y-0.5*pi))
	variable FWHM = (1.55/2-0.13)*2
	variable sigma = FWHM/(2*sqrt(2*ln(2)))

	//simupdw = 1/(sqrt(2*pi)*sigma)*exp(-(x-x0)^2/(2*sigma^2))+1/(sqrt(2*pi)*sigma)*exp(-(x+x0)^2/(2*sigma^2))

	duplicate/o simupdwn simupdw1
	duplicate/o simupdwn simupdw2

	simupdw1 = 1/(sqrt(2*pi)*sigma)*exp(-(x-(2.09+0.13*cos((2*pi/3.8)*y-0.5*pi)))^2/(2*sigma^2))+(1-1/(exp((x-(2.09+0.13*cos((2*pi/3.8)*y-0.5*pi)))/(0.086*6))+1))

	simupdw2 = 1/(sqrt(2*pi)*sigma)*exp(-(x+(2.09+0.13*cos((2*pi/3.8)*y-0.5*pi)))^2/(2*sigma^2))+(1/(exp((x+(2.09+0.13*cos((2*pi/3.8)*y-0.5*pi)))/(0.086*6))+1))
	simupdwn = simupdw1 + simupdw2
	KILLwaves simupdw1 simupdw2
	di(simupdwn)
	FFTL2(simupdwn,2)
	string aa = "simupdwn_FFTY_MOdula"
	matrixtranspose $aa
end
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
//** Simulation of 1D PDW (only Qx) linecut and corresponding 2D PDW map (Qx and Qy)
Function ButtonProc_SimuPDW1Dc(ctrlName) : ButtonControl
	String ctrlName
	Execute "SimuPDW1Dc()"
end
Proc SimuPDW1Dc(delta0,deltap,FWHM,T,Edb)
	variable delta0 = 2.09
	variable deltap = 0.13
	variable FWHM = 0.55 //1.29 at delta
	variable T = 6
	variable Edb = 1
	Prompt delta0,"Δ0 (meV)"
	Prompt deltap,"|Δp| (meV)"
	Prompt FWHM,"FWHM (meV)"
	Prompt T,"T (K)"
	Prompt Edb,"FWHM(|E|)?"
	SimuPDW1Dbody(delta0,deltap,FWHM,T,Edb)
end

Function SimuPDW1Dbody(delta0,deltap,FWHM,T,Edb)
	variable delta0,deltap,FWHM,T,Edb

	SimuPDW1D(delta0,deltap,FWHM,T,Edb)
	string PDW_1Dsim = "PDW_1Dsim"
	wave PDW_1Dsimw = $PDW_1Dsim
	sum2dlinecut($PDW_1Dsim,0,"_out",0)
	string sumout = "PDW_1Dsim_out"

	make/N=(dimsize($PDW_1Dsim,0))/O stssmall_pdw
	make/N=(dimsize($PDW_1Dsim,0))/O stslarge_pdw
	stssmall_pdw[] = PDW_1Dsimw[p][308]
	stslarge_pdw[] = PDW_1Dsimw[p][331]
	setscale/p x, dimoffset(PDW_1Dsimw,0),dimdelta(PDW_1Dsimw,0),"",stssmall_pdw,stslarge_pdw


	//FFTLpdw($PDW_1Dsim,2)
	FFTLpdw(PDW_1Dsimw,2)
	String namemod="PDW_1Dsim_FFTy_Modula"
	Setscale/P x,dimoffset($namemod,0)*3.8,dimdelta($namemod,0)*3.8,""$namemod

	display/N=SimPDW1dlinecut_sim;modifygraph width=400,height=500
	Display/HOST=#/W=(0,0.05,0.6,1);appendimage $PDW_1Dsim;ModifyImage $PDW_1Dsim ctab= {*,*,VioletOrangeYellow,0};Label Bottom "Energy (meV)"//modifygraph width=200,height=450
	setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.05,1,0.35);appendtograph $sumout;//;ColorScale/C/N=text0/F=0/B=1/A=RC/X=-20.00/Y=0.00 image=phasesingle;ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;ColorScale/C/N=text0 frame=0.00//;Label bottom "\\Z16M          \t \t\t\t\t\t\t\t\tΓ\t\t\t\t\t\t\t\t\t          M"
	setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.35,1,0.65);appendtograph stssmall_pdw,stslarge_pdw;//;ColorScale/C/N=text0/F=0/B=1/A=RC/X=-20.00/Y=0.00 image=phasesingle;ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;ColorScale/C/N=text0 frame=0.00//;Label bottom "\\Z16M          \t \t\t\t\t\t\t\t\tΓ\t\t\t\t\t\t\t\t\t          M"
		ModifyGraph rgb(stslarge_pdw)=(0,0,65535)
		Legend/C/N=text0/J/F=0/B=1/A=RB/X=0.00/Y=0.00 "\\s(stssmall_pdw) Min\r\\s(stslarge_pdw) Max"
	setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.65,1,1);appendimage $namemod;color3s_for3dmf($namemod,600)//;ColorScale/C/N=text0/F=0/B=1/A=RC/X=-20.00/Y=0.00 image=phasesingle;ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;ColorScale/C/N=text0 frame=0.00//;Label bottom "\\Z16M          \t \t\t\t\t\t\t\t\tΓ\t\t\t\t\t\t\t\t\t          M"
		SetAxis bottom -4,4;SetAxis left -(delta0+deltap+2),(delta0+deltap+2)
		Label bottom "q (π,π)";//Label left "Energy (meV)"

	setActiveSubwindow ##

	variable/G delta0_pdw = delta0
	variable/G deltap_pdw = deltap
	variable/G FWHM_pdw = FWHM
	variable/G T_pdw = T
	variable/G Edb_pdw = Edb

	SetVariable set1 win=SimPDW1dlinecut_sim, title="Δ0 (meV)",size={100,15},value=delta0_pdw,limits={0,inf,0.1},proc=SetVarProc_SimPDW1dlinecut
	SetVariable set2 win=SimPDW1dlinecut_sim, title="|Δp| (meV)",size={100,15},value=deltap_pdw,limits={0,inf,0.1},proc=SetVarProc_SimPDW1dlinecut
	SetVariable set3 win=SimPDW1dlinecut_sim, title="FWHM (meV)",size={100,15},value=FWHM_pdw,limits={0,inf,0.05},proc=SetVarProc_SimPDW1dlinecut
	SetVariable set4 win=SimPDW1dlinecut_sim, title="T (K)",size={100,15},value=T_pdw,limits={0,inf,0.2},proc=SetVarProc_SimPDW1dlinecut,pos={1,18}
	SetVariable set5 win=SimPDW1dlinecut_sim, title="FWHM(|E|)?",size={100,15},value=Edb_pdw,limits={0,1,1},proc=SetVarProc_SimPDW1dlinecut,pos={111,18}
	Button turnoffls3d title="BACK",size={45,12},valueColor=(0,0,0),fColor=(1,65535,33232),pos={353,1},proc=ButtonProc_lsturnoff3d
	Button turnoffls3d1 title="Make3D",size={60,12},pos={222,18},proc=ButtonProc_SimuPDW2Dc
	ckfig_child(winname(0,1))
end

Function SetVarProc_SimPDW1dlinecut(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/G delta0_pdw //= delta0
	variable/G deltap_pdw //= deltap
	variable/G FWHM_pdw //= FWHM
	variable/G T_pdw //= T
	variable/G Edb_pdw //= Edb
	SimuPDW1D(delta0_pdw,deltap_pdw,FWHM_pdw,T_pdw,Edb_pdw)
	string PDW_1Dsim = "PDW_1Dsim"
	sum2dlinecut($PDW_1Dsim,0,"_out",0)

	wave PDW_1Dsimw = $PDW_1Dsim
	make/N=(dimsize($PDW_1Dsim,0))/O stssmall_pdw
	make/N=(dimsize($PDW_1Dsim,0))/O stslarge_pdw
	stssmall_pdw[] = PDW_1Dsimw[p][308]
	stslarge_pdw[] = PDW_1Dsimw[p][331]
	setscale/p x, dimoffset(PDW_1Dsimw,0),dimdelta(PDW_1Dsimw,0),"",stssmall_pdw,stslarge_pdw


	FFTLpdw($PDW_1Dsim,2)
	String namemod="PDW_1Dsim_FFTy_Modula"
	color3s_for3dmf($namemod,600)
	Setscale/P x,dimoffset($namemod,0)*3.8,dimdelta($namemod,0)*3.8,""$namemod
	SetAxis/W=SimPDW1dlinecut_sim#G3 bottom -4,4;SetAxis/W=SimPDW1dlinecut_sim#G3 left -(delta0_pdw+deltap_pdw+2),(delta0_pdw+deltap_pdw+2)

end



Function SimuPDW1D(delta0,deltap,FWHM,T,Edb)
	variable delta0,deltap,FWHM,T,Edb

	make/N=(600,600)/o PDW_1Dsim
	setscale/I x,-9,9,"",PDW_1Dsim
	setscale/I y,0,50,"",PDW_1Dsim

	variable sigma = FWHM/(2*sqrt(2*ln(2)))
	duplicate/o PDW_1Dsim simupdw1
	duplicate/o PDW_1Dsim simupdw2

	if (Edb == 1)
		simupdw1 = 1/(sqrt(2*pi)*sigma*abs(x))*exp(-(x-(delta0+deltap*cos((2*pi/3.8)*y-0.5*pi)))^2/(2*(sigma*abs(x))^2))+(1-1/(exp((x-(delta0+deltap*cos((2*pi/3.8)*y-0.5*pi)))/(0.086*T))+1))
		simupdw2 = 1/(sqrt(2*pi)*sigma*abs(x))*exp(-(x+(delta0+deltap*cos((2*pi/3.8)*y-0.5*pi)))^2/(2*(sigma*abs(x))^2))+(1/(exp((x+(delta0+deltap*cos((2*pi/3.8)*y-0.5*pi)))/(0.086*T))+1))
	else
		simupdw1 = 1/(sqrt(2*pi)*sigma)*exp(-(x-(delta0+deltap*cos((2*pi/3.8)*y-0.5*pi)))^2/(2*(sigma)^2))+(1-1/(exp((x-(delta0+deltap*cos((2*pi/3.8)*y-0.5*pi)))/(0.086*T))+1))
		simupdw2 = 1/(sqrt(2*pi)*sigma)*exp(-(x+(delta0+deltap*cos((2*pi/3.8)*y-0.5*pi)))^2/(2*(sigma)^2))+(1/(exp((x+(delta0+deltap*cos((2*pi/3.8)*y-0.5*pi)))/(0.086*T))+1))
	endif

	PDW_1Dsim = simupdw1 + simupdw2
	killwaves simupdw1 simupdw2
end



Function ButtonProc_sum2dlinecutc(ctrlName) : ButtonControl
	String ctrlName
	Execute "sum2dlinecutc()"
end
Proc sum2dlinecutc(name,zn,sufout,show)
	string name = tpw()
	variable zn = 0
	string sufout = "_sum"
	variable show = 1
	prompt name,"The source 2D wave"
	Prompt zn,"The dimension to keep, 0 for x; 1 for y"
	Prompt sufout,"The suffix add to the name of output"
	Prompt show,"Do you want display?"
	sum2dlinecut($name,zn,sufout,show)
end
Function sum2dlinecut(name,zn,sufout,show)
	wave name
	variable zn
	string sufout
	variable show

	string stsname = nameofwave(name)+sufout
	make/n=(dimsize(name,zn))/o $stsname
	wave stsnamew = $stsname
	setscale/p x, dimoffset(name,zn),dimdelta(name,zn),"",stsnamew
	stsnamew = 0

	variable i
	i=0

	variable zn_other
	if (zn == 0)
		zn_other = 1
		do
			stsnamew[]+=name[p][i]
			i+=1
		while (i<dimsize(name,zn_other))
		stsnamew/=dimsize(name,zn_other)
	endif

	if (zn == 1)
		zn_other = 0
		do
			stsnamew[]+=name[i][p]
			i+=1
		while (i<dimsize(name,zn_other))
		stsnamew/=dimsize(name,zn_other)
	endif

	if (show == 1)
		display stsnamew
	endif
end

Function FFTLpdw(name,sel)
	wave name
	variable sel // 1 for x, 2 for y
	func_NaN0(name)
	String FFTout
	if (sel == 1)
		FFTout = nameofWave(name) + "_FFTx"
		FFT/WINF=Hanning/COLS/DEST=$FFTout cvtcmplx(name)
		Complextorealfpdw($FFTout,1)
		SetAxis bottom 0,*
	endif

	String namemod=nameofwave(name)+"_FFTy_Modula"

	if (sel == 2)
		FFTout = nameofWave(name) + "_FFTy"
		FFT/WINF=Hanning/ROWS/DEST=$FFTout cvtcmplx(name)
		Complextorealfpdw($FFTout,1)
		matrixtranspose $namemod
		//SetAxis left 0,*
	endif
end
Function Complextorealfpdw(name1w,select)
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

Function ButtonProc_SimuPDW2Dc(ctrlName) : ButtonControl
	String ctrlName
	Execute "SimuPDW2Dc()"
end
Proc SimuPDW2Dc(delta0,deltap,FWHM,T,Edb)
	variable delta0 = delta0_pdw
	variable deltap = deltap_pdw
	variable FWHM = FWHM_pdw //1.29 at delta
	variable T = T_pdw
	variable Edb = Edb_pdw
	Prompt delta0,"Δ0 (meV)"
	Prompt deltap,"|Δp| (meV)"
	Prompt FWHM,"FWHM (meV)"
	Prompt T,"T (K)"
	Prompt Edb,"FWHM(|E|)?"
	SimuPDW2D(delta0,deltap,FWHM,T,Edb)
end
Function SimuPDW2D(delta0,deltap,FWHM,T,Edb)
	variable delta0,deltap,FWHM,T,Edb

	make/N=(100,100,600)/o PDW_2Dsim
	setscale/I z,-9,9,"",PDW_2Dsim
	setscale/I y,0,20,"",PDW_2Dsim
	setscale/I x,0,20,"",PDW_2Dsim

	variable sigma = FWHM/(2*sqrt(2*ln(2)))
	duplicate/o PDW_2Dsim simupdw1
	duplicate/o PDW_2Dsim simupdw2

	if (Edb == 1)
		simupdw1 = 1/(sqrt(2*pi)*sigma*abs(z))*exp(-(z-(delta0+deltap*cos((2*pi/3.8)*x-0.5*pi)  +deltap*cos((2*pi/3.8)*y-0.5*pi)   ))^2/(2*(sigma*abs(z))^2))+(1-1/(exp((z-(delta0+deltap*cos((2*pi/3.8)*x-0.5*pi)+deltap*cos((2*pi/3.8)*y-0.5*pi) ))/(0.086*T))+1))
		simupdw2 = 1/(sqrt(2*pi)*sigma*abs(z))*exp(-(z+(delta0+deltap*cos((2*pi/3.8)*x-0.5*pi)  +deltap*cos((2*pi/3.8)*y-0.5*pi)   ))^2/(2*(sigma*abs(z))^2))+(1/(exp((z+(delta0+deltap*cos((2*pi/3.8)*x-0.5*pi)+deltap*cos((2*pi/3.8)*y-0.5*pi) ))/(0.086*T))+1))
	else
		simupdw1 = 1/(sqrt(2*pi)*sigma)*exp(-(z-(delta0+deltap*cos((2*pi/3.8)*x-0.5*pi)+deltap*cos((2*pi/3.8)*y-0.5*pi)))^2/(2*(sigma)^2))+(1-1/(exp((z-(delta0+deltap*cos((2*pi/3.8)*x-0.5*pi)+deltap*cos((2*pi/3.8)*y-0.5*pi)))/(0.086*T))+1))
		simupdw2 = 1/(sqrt(2*pi)*sigma)*exp(-(z+(delta0+deltap*cos((2*pi/3.8)*x-0.5*pi)+deltap*cos((2*pi/3.8)*y-0.5*pi)))^2/(2*(sigma)^2))+(1/(exp((z+(delta0+deltap*cos((2*pi/3.8)*x-0.5*pi)+deltap*cos((2*pi/3.8)*y-0.5*pi)))/(0.086*T))+1))
	endif

	PDW_2Dsim = simupdw1 + simupdw2
	killwaves simupdw1 simupdw2

	duplicate/o PDW_2Dsim p2_001
	killwaves PDW_2Dsim
	string exe="d3d(\"p2_001\",2)"
	execute exe
	SetVariable setvarz_cons title="Z",size={65,14},value=z_cons,proc=SetVarProc_Cons3dplotpdw
end

Function SetVarProc_Cons3dplotpdw(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

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
		color3s_for3d($slicename,30)
		ModifyImage Zslice_p2_001 ctab= {*,*,VioletOrangeYellow,0}
		ColorScale/K/N=textcc
	endif

	if (checkmultiopen(12) == 0)
	else
		color3s_for3dm($slicename,3)
	endif
	f_for3d()
	String FFToutm = "Zslice_"+mat3dn_cons+ "_FFT"	+"_Modula"
	color3s_for3dinv($FFToutm,colorratio_consFFT)
	if (checkmultiopen(12) == 0)
	else
		color3s_for3dm($FFToutm,colorratio_consFFT)
	endif

	//** Indicative line
	string Zpp = "Zpp_"+mat3dn_cons
	wave zppw = $zpp
	Zppw=z_cons
end

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
//********************** Estimate QPI Grid and Range **************************************
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_makelatticec(ctrlName) : ButtonControl
	String ctrlName
	Execute "makelatticec()"
end
Proc makelatticec(a,angle,num,areaL,q_por)
	variable a = 3.8
	variable angle = 45
	variable num = 100
	variable areaL = 50
	variable q_por = 8
	prompt a,"Lattice constant (Å)"
	prompt angle,"degree of the lattice axis"
	prompt num,"Grid Points"
	prompt areaL,"Map area (Å x Å)"
	prompt q_por,"Interpocket |q| vector, portion of G"

	makelattice(a,angle,num,areaL,q_por)

	string FFTout = "estimateQPI_FFT"
	string estimateQPI = "estimateQPI"

	//variable q1x,q1y,q2x,q2y
	//q1x = cos(angle*pi/180)*1/(a)
	//q1y = sin(angle*pi/180)*1/(a)

	//q2x = cos((angle+90)*pi/180)*1/(a)
	//q2y = sin((angle+90)*pi/180)*1/(a)

	make/o/n=(1) q1xss,q1yss,q2xss,q2yss,mq1xss,mq1yss,mq2xss,mq2yss
	q1xss = cos(angle*pi/180)*1/(a)
	q1yss = sin(angle*pi/180)*1/(a)

	q2xss = cos((angle+90)*pi/180)*1/(a)
	q2yss = sin((angle+90)*pi/180)*1/(a)

	mq1xss = -cos(angle*pi/180)*1/(a)
	mq1yss = -sin(angle*pi/180)*1/(a)

	mq2xss = -cos((angle+90)*pi/180)*1/(a)
	mq2yss = -sin((angle+90)*pi/180)*1/(a)

	display/N=QPIrangesimuaaaaaaa;modifygraph width=1000,height=500
	Display/HOST=#/W=(0,0.05,0.5,1);appendimage $estimateQPI;ModifyGraph mirror=2;ModifyImage $estimateQPI ctab= {*,*,VioletOrangeYellow,0};ModifyGraph width={Plan,1,bottom,left};ModifyGraph axThick=2,standoff=0;Label left "\\Z15Y (Å)";Label bottom "\\Z15X (Å)"
	setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.05,0.95,1);appendimage $FFTout;ModifyGraph mirror=2;ModifyImage $FFTout ctab= {*,*,BlueHot256,1};ModifyGraph width={Plan,1,bottom,left};ModifyGraph axThick=2,standoff=0;Label bottom "\\$WMTEX$ Q_{x}  \\$/WMTEX$ \\$WMTEX$  (2\\pi Å^{-1}) \\$/WMTEX$";Label left "\\$WMTEX$ Q_{y}  \\$/WMTEX$ \\$WMTEX$  (2\\pi Å^{-1}) \\$/WMTEX$"
	appendtograph q1yss vs q1xss
	appendtograph q2yss vs q2xss
	appendtograph mq1yss vs mq1xss
	appendtograph mq2yss vs mq2xss
	ModifyGraph mode=3,marker=8,msize=5,mrkThick=2

	setActiveSubwindow ##;

	variable/G a_QPIrangesimu = a
	variable/G angle_QPIrangesimu = angle
	variable/G num_QPIrangesimu = num
	variable/G areaL_QPIrangesimu = areaL/10
	variable/G q_por_QPIrangesimu = q_por

	SetVariable set1 win=QPIrangesimuaaaaaaa, title="Latt. a (Å)",pos={290,5},size={100,15},value=a_QPIrangesimu,limits={-inf,inf,0.1},proc=SetVarProc_QPIrangesimu
	SetVariable set2 win=QPIrangesimuaaaaaaa, title="Latt.Q (°)",pos={290,25},size={100,15},value=angle_QPIrangesimu,limits={-180,180,1},proc=SetVarProc_QPIrangesimu
	SetVariable set3 win=QPIrangesimuaaaaaaa, title="Grid (NxN)",pos={62,5},size={100,15},value=num_QPIrangesimu,limits={0,inf,10},proc=SetVarProc_QPIrangesimu
	SetVariable set4 win=QPIrangesimuaaaaaaa, title="Lenght (nm x nm)",pos={62,21},size={150,15},value=areaL_QPIrangesimu,limits={0,inf,1},proc=SetVarProc_QPIrangesimu
	SetVariable set5 win=QPIrangesimuaaaaaaa, title="λ(a0)",pos={477,5},size={100,15},value=q_por_QPIrangesimu,limits={-inf,inf,0.1},proc=SetVarProc_QPIrangesimu
	variable/G kf_QPIrangesimu = pi/(a_QPIrangesimu*q_por_QPIrangesimu)
	ValDisplay valdisp0 title = "kF (Å-1)",value=kf_QPIrangesimu,size={150,13}
	Button turnoffls3d title="BACK",size={45,18},valueColor=(0,0,0),fColor=(1,65535,33232),pos={950,1},proc=ButtonProc_lsturnoff3d

	variable/G colorratio_fftqpirange =30
	SetVariable setcolor win=QPIrangesimuaaaaaaa,title="σ",size={65,14},value=colorratio_fftqpirange,limits={1,inf,1},proc=SetVarProc_qpirangeFFTcolor,pos={780,22}
	Button setcolorauto win=QPIrangesimuaaaaaaa,title="Auto",size={65,14},pos={820,22},proc=ButtonProc_colorauto
end

Function SetVarProc_QPIrangesimu(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G a_QPIrangesimu //= a
	variable/G angle_QPIrangesimu //= angle
	variable/G num_QPIrangesimu //= num
	variable/G areaL_QPIrangesimu //= areaL
	variable/G q_por_QPIrangesimu //= q_por

	makelattice(a_QPIrangesimu,angle_QPIrangesimu,num_QPIrangesimu,areaL_QPIrangesimu*10,q_por_QPIrangesimu)

	make/o/n=(1) q1xss,q1yss,q2xss,q2yss,mq1xss,mq1yss,mq2xss,mq2yss
	q1xss = cos(angle_QPIrangesimu*pi/180)*1/(a_QPIrangesimu)
	q1yss = sin(angle_QPIrangesimu*pi/180)*1/(a_QPIrangesimu)

	q2xss = cos((angle_QPIrangesimu+90)*pi/180)*1/(a_QPIrangesimu)
	q2yss = sin((angle_QPIrangesimu+90)*pi/180)*1/(a_QPIrangesimu)

	mq1xss = -cos(angle_QPIrangesimu*pi/180)*1/(a_QPIrangesimu)
	mq1yss = -sin(angle_QPIrangesimu*pi/180)*1/(a_QPIrangesimu)

	mq2xss = -cos((angle_QPIrangesimu+90)*pi/180)*1/(a_QPIrangesimu)
	mq2yss = -sin((angle_QPIrangesimu+90)*pi/180)*1/(a_QPIrangesimu)
	variable/G kf_QPIrangesimu = pi/(a_QPIrangesimu*q_por_QPIrangesimu)
end

Function makelattice(a,angle,num,areaL,q_por)
	variable a,angle,num,areaL,q_por

	make/N=(num,num)/o estimateQPI
	setscale/I x,0,areaL,"",estimateQPI
	setscale/I y,0,areaL,"",estimateQPI

	variable q1x,q1y,q2x,q2y,qband
	q1x = cos(angle*pi/180)*2*pi/(a)
	q1y = sin(angle*pi/180)*2*pi/(a)

	q2x = cos((angle+90)*pi/180)*2*pi/(a)
	q2y = sin((angle+90)*pi/180)*2*pi/(a)

	qband = 2*pi/(a*q_por)

	estimateQPI = cos(q1x*x+q1y*y) + cos(q2x*x+q2y*y) //+ gammaNoise(0.1)

	estimateQPI += exp(-sqrt((x-areaL/2)^2+(y-areaL/2)^2)/(areal/5))*sin(qband*sqrt((x-areaL/2)^2+(y-areaL/2)^2))

	estimateQPI += exp(-sqrt((x-areaL/2.5)^2+(y-areaL/8)^2)/(areal/5))*sin(qband*sqrt((x-areaL/2.5)^2+(y-areaL/8)^2))

	estimateQPI += exp(-sqrt((x-areaL/1.2)^2+(y-areaL/1.2)^2)/(areal/5))*sin(qband*sqrt((x-areaL/1.2)^2+(y-areaL/1.2)^2))

	//variable ppx,ppy,p0x,p0y
	//ppx = q1x
	//ppy = q1y
	//p0x = cos((angle+45)*pi/180)*2*pi/(a*sqrt(2))
	//p0y = sin((angle+45)*pi/180)*2*pi/(a*sqrt(2))
	//estimateQPI += cos(p0x*x+p0y*y)

	FFTrQPIsimu(estimateQPI)

	string FFTout = "estimateQPI_FFT"

	//di(estimateQPI)
	//di($FFTout)
end

Function FFTrQPIsimu(name)
	wave name

		duplicate/o name named
		func_NaN0(named)
		String FFTout
		FFTout = nameofWave(name) + "_FFT"
		duplicate/o named nametemp_fft
		imagewindow/O hanning nametemp_fft
		FFT/out=3/DEST=$FFTout cvtcmplx(nametemp_fft)
		killwaves nametemp_fft

		//di($FFTout)
		//color3sfft($tpw(),300)
		killwaves named
end




Function SetVarProc_qpirangeFFTcolor(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G colorratio_fftqpirange
	color3s_for3dinvqpirange($"estimateQPI_FFT",colorratio_fftqpirange)
End

Function color3s_for3dinvqpirange(name,tt)
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

	ModifyImage/W=QPIrangesimuaaaaaaa#G1 $nameofwave(name) ctab= {lc,lh,BlueHot256,1}
	//PRINT num2str(W_coefw[2]-1.5*sigma)+" "+ num2str(W_coefw[2]+1.5*sigma)
	//print num2str(W_coefw[2])
	//display namehistw
end

Function ButtonProc_colorauto(ctrlName) : ButtonControl
	String ctrlName
	string estimateQPI_FFT = "estimateQPI_FFT"
	ModifyImage/W=QPIrangesimuaaaaaaa#G1 $estimateQPI_FFT ctab= {*,*,BlueHot256,1}
end

///////////////////////////////////////////////////////////////////////////////////////////
//*************************** New simultaneous simulation of  *****************************
//***************************    Spectral function of QPI     *****************************
//***************************   2 band tight-binding model    *****************************
//***************************     Gamma hole & M electron     *****************************
///////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_QPISIMUNew(ctrlName) : ButtonControl
	String ctrlName
	execute "QPIESimu2Dbandc()"
End

Proc QPIESimu2Dbandc(shape_hole,shape_ele,mu_hole,mu_ele,gap_hole,gap_ele,selfE,sel)
	variable shape_hole = 50
	variable shape_ele = 60
	variable gap_hole = 1.5
	variable gap_ele = 1.5
	variable mu_hole = 5.5
	variable mu_ele  = -8
	variable selfE = 0.5
	variable sel = 1
	prompt shape_hole,"Band shape (hole band)"
	prompt shape_ele,"Band shape (electron band)"
	prompt gap_hole,"Δ(hole band)"
	prompt gap_ele,"Δ(electron band)"
	prompt mu_hole,"μ(hole band)"
	prompt mu_ele,"μ(electron band)"
	prompt selfE,"Im∑"
	prompt sel,"SC or Normal",popup,"Normal state;SC state"
	QPIESimu2Dband(shape_hole,shape_ele,mu_hole,mu_ele,gap_hole,gap_ele,selfE,sel)
end
Function QPIESimu2Dband(shape_hole,shape_ele,mu_hole,mu_ele,gap_hole,gap_ele,selfE,sel)
	variable shape_hole
	variable shape_ele
	variable gap_hole
	variable gap_ele
	variable mu_hole
	variable mu_ele
	variable selfE
	variable sel

	// Hole E > 0
	variable/G Mask_hole_p_E_Intens = 0.15
	variable/G Mask_hole_p_E_FWHM = 1
	variable/G Mask_hole_p_E_detune = 0.5
	variable/G Mask_hole_p_k_Intens0 = 0
	variable/G Mask_hole_p_k_Intens = 0.8
	variable/G Mask_hole_p_k_FWHM = 0.6

	// Hole E < 0
	variable/G Mask_hole_n_E_Intens = 0.1
	variable/G Mask_hole_n_E_FWHM = 1
	variable/G Mask_hole_n_E_detune = 0.5
	variable/G Mask_hole_n_k_Intens0 = 0
	variable/G Mask_hole_n_k_Intens = 15//2.5
	variable/G Mask_hole_n_k_FWHM = 5

	// electron E > 0
	variable/G Mask_ele_p_E_Intens = 0
	variable/G Mask_ele_p_E_FWHM = 1
	variable/G Mask_ele_p_E_detune = 0.5
	variable/G Mask_ele_p_k_Intens0 = 0.6
	variable/G Mask_ele_p_k_Intens = 0
	variable/G Mask_ele_p_k_FWHM = 5

	// electron E < 0
	variable/G Mask_ele_n_E_Intens = 0
	variable/G Mask_ele_n_E_FWHM = 1
	variable/G Mask_ele_n_E_detune = 0.5
	variable/G Mask_ele_n_k_Intens0 = 0.05
	variable/G Mask_ele_n_k_Intens = 0
	variable/G Mask_ele_n_k_FWHM = 0.6

	variable/G z_QPISIM = 0
	variable/G quality_QPISIM = 250

	make/n=(quality_QPISIM*sqrt(2),quality_QPISIM)/o simudisper_GM
	setscale/I x, -2*pi, 2*pi,"",simudisper_GM
	setscale/I y, -20, 20,"",simudisper_GM

	if (sel == 1)
		//Normal state
			// Gamma hole pocket
				simudisper_GM= 1/((y+          (shape_hole*(1-cos(x))+(shape_hole*(1-cos(x)))-mu_hole)         )^2+(selfE)^2)
			// M electron pocket
				simudisper_GM += 1/((y-        (shape_ele*(1-cos(x+pi))+shape_ele*(1-cos(x+pi))-mu_ele)               )^2+(selfE)^2)
	endif

	if (sel == 2)
		//SC hole band (Gamma)
	  		// Below EF (n)
				//spectral weight follow k
					simudisper_GM = (Mask_hole_n_k_Intens0+Mask_hole_n_k_Intens*(1-exp(-(2*(1-cos(x)))/(Mask_hole_n_k_FWHM/(2*sqrt(ln(2))))^2)))/((y+     sqrt((shape_hole*(1-cos(x))+(shape_hole*(1-cos(x)))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
				//spectral weight follow E (add some around delta to enhance coherence peak)
					if (Mask_hole_n_E_Intens == 0)
					else
						simudisper_GM += Mask_hole_n_E_Intens*(exp(-(y+(gap_hole+Mask_hole_n_E_detune))^2/(Mask_hole_n_E_FWHM/(2*sqrt(ln(2))))^2))/((y+     sqrt((shape_hole*(1-cos(x))+(shape_hole*(1-cos(x)))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
 	  				endif
 	  		// Above EF (p)
				//spectral weight follow k
					simudisper_GM += (Mask_hole_p_k_Intens0+Mask_hole_p_k_Intens*(exp(-(2*(1-cos(x)))/(Mask_hole_p_k_FWHM/(2*sqrt(ln(2))))^2)))/((y+     -sqrt((shape_hole*(1-cos(x))+(shape_hole*(1-cos(x)))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
				//spectral weight follow E (add some around delta to enhance coherence peak)
					if (Mask_hole_p_E_Intens == 0)
					else
						simudisper_GM += Mask_hole_p_E_Intens*(exp(-(y-(gap_hole+Mask_hole_p_E_detune))^2/(Mask_hole_p_E_FWHM/(2*sqrt(ln(2))))^2))/((y+     -sqrt((shape_hole*(1-cos(x))+(shape_hole*(1-cos(x)))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
					endif
		//electron band (M)
	  		// Below EF (n)
				//spectral weight follow k
					simudisper_GM += (Mask_ele_n_k_Intens0+Mask_ele_n_k_Intens*(exp(-(2*(1-cos(x+pi)))/(Mask_ele_n_k_FWHM/(2*sqrt(ln(2))))^2)))/((y-        -sqrt((shape_ele*(1-cos(x+pi))+shape_ele*(1-cos(x+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
				//spectral weight follow E (add some around delta to enhance coherence peak)
					if (Mask_ele_n_E_Intens == 0)
					else
						simudisper_GM += Mask_ele_n_E_Intens*(exp(-(y+(gap_ele+Mask_ele_n_E_detune))^2/(Mask_ele_n_E_FWHM/(2*sqrt(ln(2))))^2))/((y-        -sqrt((shape_ele*(1-cos(x+pi))+shape_ele*(1-cos(x+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
					endif

			// above EF
				//spectral weight follow k
					simudisper_GM += (Mask_ele_p_k_Intens0+Mask_ele_p_k_Intens*(1-exp(-(2*(1-cos(x+pi)))/(Mask_ele_p_k_FWHM/(2*sqrt(ln(2))))^2)))/((y-        sqrt((shape_ele*(1-cos(x+pi))+shape_ele*(1-cos(x+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
				//spectral weight follow E (add some around delta to enhance coherence peak)
					if (Mask_ele_p_E_Intens == 0)
					else
						simudisper_GM += Mask_ele_p_E_Intens*(exp(-(y-(gap_ele+Mask_ele_p_E_detune))^2/(Mask_ele_p_E_FWHM/(2*sqrt(ln(2))))^2))/((y-        sqrt((shape_ele*(1-cos(x+pi))+shape_ele*(1-cos(x+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
					endif
	endif

	make/n=(quality_QPISIM,quality_QPISIM)/o simu_FS
	setscale/I x, -2*pi, 2*pi,"",simu_FS
	setscale/I y, -2*pi, 2*pi,"",simu_FS

	if (sel == 1)
		//Normal state
			// Gamma hole pocket
				//simu_FS= 1/((z_QPISIM+          (shape_hole*(1-cos(x))+(shape_hole*(1-cos(y)))-mu_hole)         )^2+(selfE)^2)
				simu_FS= 1/((z_QPISIM+          (shape_hole*(1-cos((sqrt(2)/2)*(x-y)))+(shape_hole*(1-cos((sqrt(2)/2)*(x+y))))-mu_hole)         )^2+(selfE)^2)

			// M electron pocket

				//simu_FS += 1/((z_QPISIM-        (shape_ele*(1-cos(x+pi))+shape_ele*(1-cos(y+pi))-mu_ele)               )^2+(selfE)^2)
				simu_FS += 1/((z_QPISIM-        (shape_ele*(1-cos((sqrt(2)/2)*(x-y)+pi))+shape_ele*(1-cos((sqrt(2)/2)*(x+y)+pi))-mu_ele)               )^2+(selfE)^2)

	endif

	if (sel == 2)
		//SC hole band (Gamma)
	  		// Below EF (n)
				//spectral weight follow k
					simu_FS = (Mask_hole_n_k_Intens0+Mask_hole_n_k_Intens*(1-exp(-(2*(1-cos((sqrt(2)/2)*(x-y)))+2*(1-cos((sqrt(2)/2)*(x+y))))/(Mask_hole_n_k_FWHM/(2*sqrt(ln(2))))^2)))/((z_QPISIM+     sqrt((shape_hole*(1-cos((sqrt(2)/2)*(x-y)))+(shape_hole*(1-cos((sqrt(2)/2)*(x+y))))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
				//spectral weight follow E (add some around delta to enhance coherence peak)
					if (Mask_hole_n_E_Intens == 0)
					else
						simu_FS += Mask_hole_n_E_Intens*(exp(-(0+(gap_hole+Mask_hole_n_E_detune))^2/(Mask_hole_n_E_FWHM/(2*sqrt(ln(2))))^2))/((z_QPISIM+     sqrt((shape_hole*(1-cos((sqrt(2)/2)*(x-y)))+(shape_hole*(1-cos((sqrt(2)/2)*(x+y))))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
 	  				endif
 	  		// Above EF (p)
				//spectral weight follow k
					simu_FS += (Mask_hole_p_k_Intens0+Mask_hole_p_k_Intens*(exp(-(2*(1-cos((sqrt(2)/2)*(x-y)))+2*(1-cos((sqrt(2)/2)*(x+y))))/(Mask_hole_p_k_FWHM/(2*sqrt(ln(2))))^2)))/((z_QPISIM+     -sqrt((shape_hole*(1-cos((sqrt(2)/2)*(x-y)))+(shape_hole*(1-cos((sqrt(2)/2)*(x+y))))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
				//spectral weight follow E (add some around delta to enhance coherence peak)
					if (Mask_hole_p_E_Intens == 0)
					else
						simu_FS += Mask_hole_p_E_Intens*(exp(-(0-(gap_hole+Mask_hole_p_E_detune))^2/(Mask_hole_p_E_FWHM/(2*sqrt(ln(2))))^2))/((z_QPISIM+     -sqrt((shape_hole*(1-cos((sqrt(2)/2)*(x-y)))+(shape_hole*(1-cos((sqrt(2)/2)*(x+y))))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
					endif
		//electron band (M)
	  		// Below EF (n)
				//spectral weight follow k
					simu_FS += (Mask_ele_n_k_Intens0+Mask_ele_n_k_Intens*(exp(-(2*(1-cos((sqrt(2)/2)*(x-y)+pi))+2*(1-cos((sqrt(2)/2)*(x+y)+pi)))/(Mask_ele_n_k_FWHM/(2*sqrt(ln(2))))^2)))/((z_QPISIM-        -sqrt((shape_ele*(1-cos((sqrt(2)/2)*(x-y)+pi))+shape_ele*(1-cos((sqrt(2)/2)*(x+y)+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
				//spectral weight follow E (add some around delta to enhance coherence peak)
					if (Mask_ele_n_E_Intens == 0)
					else
						simu_FS += Mask_ele_n_E_Intens*(exp(-(z_QPISIM+(gap_ele+Mask_ele_n_E_detune))^2/(Mask_ele_n_E_FWHM/(2*sqrt(ln(2))))^2))/((z_QPISIM-        -sqrt((shape_ele*(1-cos((sqrt(2)/2)*(x-y)+pi))+shape_ele*(1-cos((sqrt(2)/2)*(x+y)+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
					endif

			// above EF
				//spectral weight follow k
					simu_FS += (Mask_ele_p_k_Intens0+Mask_ele_p_k_Intens*(1-exp(-(2*(1-cos((sqrt(2)/2)*(x-y)+pi))+2*(1-cos((sqrt(2)/2)*(x+y)+pi)))/(Mask_ele_p_k_FWHM/(2*sqrt(ln(2))))^2)))/((z_QPISIM-        sqrt((shape_ele*(1-cos((sqrt(2)/2)*(x-y)+pi))+shape_ele*(1-cos((sqrt(2)/2)*(x+y)+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
				//spectral weight follow E (add some around delta to enhance coherence peak)
					if (Mask_ele_p_E_Intens == 0)
					else
						simu_FS += Mask_ele_p_E_Intens*(exp(-(z_QPISIM-(gap_ele+Mask_ele_p_E_detune))^2/(Mask_ele_p_E_FWHM/(2*sqrt(ln(2))))^2))/((z_QPISIM-        sqrt((shape_ele*(1-cos((sqrt(2)/2)*(x-y)+pi))+shape_ele*(1-cos((sqrt(2)/2)*(x+y)+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
					endif
	endif

	MatrixOP/O simu_FS_corr=Correlate(simu_FS,simu_FS,4)

	duplicate/o simudisper_GM simudisper_GM2

	//Start the Displays
	Display/N=TwobandsimuandQPIsimu;modifygraph width=700,height=900
	tilewindows/WINS=winname(0,1)/R/A=(1,1)/w=(3,0,50,100)

	Display/HOST=#/W=(0,0.05,1,0.4);appendimage simudisper_GM;ModifyImage simudisper_GM ctab= {*,*,VioletOrangeYellow,1};ModifyGraph mirror=2;ModifyGraph zero(left)=9
		ModifyGraph nticks(bottom)=0
		SetDrawEnv xcoord= bottom,ycoord= left,dash= 8,linethick= 0.50;DelayUpdate
		DrawLine 0,-20,0,20
		SetDrawEnv xcoord= bottom,ycoord= left,dash= 8,linethick= 0.50;DelayUpdate
		DrawLine 3.1416,-20,3.1416,20
	    SetDrawEnv xcoord= bottom,ycoord= left,dash= 8,linethick= 0.50;DelayUpdate
		DrawLine -3.1416,-20,-3.1416,20
		SetDrawEnv fsize= 16;DelayUpdate;DrawText 0.495,1.1340206185567,"Γ"
		SetDrawEnv fsize= 16;DelayUpdate;DrawText 0.2389106252397292,1.1340206185567,"M "
		SetDrawEnv fsize= 16;DelayUpdate;DrawText 0.7404802858700194,1.1340206185567,"M "

		make/N=2/o Eindicator_Y_QPISIM; Eindicator_Y_QPISIM={z_QPISIM,z_QPISIM}
		make/N=2/o Eindicator_X_QPISIM; Eindicator_X_QPISIM={-2*pi,2*pi}
		appendtograph Eindicator_Y_QPISIM vs Eindicator_X_QPISIM
		ModifyGraph lsize=1,lstyle=8

	setActiveSubwindow ##;Display/HOST=#/W=(0,0.6,0.3,1);appendimage simu_FS;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;
		wavestats/Q simu_FS
		variable rangls = max(abs(V_max),abs(V_min))
		ModifyImage simu_FS ctab= {-rangls,rangls,:Packages:NewColortable:dvg_seismic,0};
		ColorScale/C/N=textcc/X=-21.00/Y=5.00/F=0 heightPct=30,nticks=5,minor=1,tickLen=1.00,image=simu_FS;ColorScale/C/N=textcc/A=MB/X=0/Y=-10 vert=0, heightPct=2//;ColorScale/W=$grabwinchild(Fexyd)/C/N=text0/F=0/A=MC/Y=-120 image=$Fexyd
		SetDrawEnv xcoord= bottom,ycoord= left,dash= 8;DelayUpdate
		DrawLine -sqrt(2)*pi,0,0,sqrt(2)*pi
		SetDrawEnv xcoord= bottom,ycoord= left,dash= 8;DelayUpdate
		DrawLine 0,sqrt(2)*pi,sqrt(2)*pi,0
		SetDrawEnv xcoord= bottom,ycoord= left,dash= 8;DelayUpdate
		DrawLine sqrt(2)*pi,0,0,-sqrt(2)*pi
		SetDrawEnv xcoord= bottom,ycoord= left,dash= 8;DelayUpdate
		DrawLine -sqrt(2)*pi,0,0,-sqrt(2)*pi
		SetDrawEnv xcoord= bottom,ycoord= left,fsize= 16;DelayUpdate;DrawText -1.21,-6.29,"2-Fe BZ"
		//SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (52428,52425,1),dash= 7,arrow= 1,linethick= 0.50,linefgc= (26214,26212,0);DelayUpdate
		//DrawLine -sqrt(2)*pi,-sqrt(2)*pi,sqrt(2)*pi,sqrt(2)*pi
		SetDrawEnv xcoord= bottom,ycoord= left;DelayUpdate;DrawText 5.2,-0.2,"M"

	setActiveSubwindow ##;Display/HOST=#/W=(0.45,0.6,0.75,1);appendimage simu_FS_corr;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;
		ModifyImage simu_FS_corr ctab= {*,*,VioletOrangeYellow,1}
		ColorScale/C/N=textcc2/X=-21.00/Y=5.00/F=0 heightPct=30,nticks=5,minor=1,tickLen=1.00,image=simu_FS_corr;ColorScale/C/N=textcc2/A=MB/X=0/Y=-10 vert=0, heightPct=2//;ColorScale/W=$grabwinchild(Fexyd)/C/N=text0/F=0/A=MC/Y=-120 image=$Fexyd
		SetDrawEnv xcoord= bottom,ycoord= left,arrow= 1
		DrawLine 248.17109634551,249.828903654485,422.6,249.828903654485

		SetDrawEnv xcoord= bottom,ycoord= left,textxjust= 1,textyjust= 1;DelayUpdate
		DrawText 458.712624584718,251.5,"\\$WMTEX$ q_{1} \\$/WMTEX$"
		SetDrawEnv xcoord= bottom,ycoord= left,textxjust= 1,textyjust= 1;DelayUpdate;
		DrawText 337.692691029899,278,"M"

	setActiveSubwindow ##;

	variable/G shape_hole_QPISIM = shape_hole
	variable/G shape_ele_QPISIM = shape_ele
	variable/G gap_hole_QPISIM = gap_hole
	variable/G gap_ele_QPISIM = gap_ele
	variable/G mu_hole_QPISIM = mu_hole
	variable/G mu_ele_QPISIM = mu_ele
	variable/G selfE_QPISIM = selfE
	variable/G sel_QPISIM = sel

	//Universal parameter for the both bands
		SetVariable set7 size={100,20},value=selfE_QPISIM,proc=SetVarProc_ConstQPIsimuand2bands,limits={0.01,inf,0.05},title="Im∑",pos={1,1}
		SetVariable set8 size={100,20},value=sel_QPISIM,proc=SetVarProc_ConstQPIsimuand2bands,limits={1,2,1},title="N1/S2"//,pos={1,1}

		SetVariable set33 size={100,20},value=z_QPISIM,proc=SetVarProc_ConstQPIsimuand2bandsFS,limits={-inf,inf,0.5},title="E"//,pos={1,1}
		SetVariable set34 size={100,20},value=quality_QPISIM,proc=SetVarProc_ConstQPIsimuand2bands,limits={100,inf,50},title="NxN"//,pos={1,1}

	//Hole bands (gamma)

		//Basic parameters
			SetVariable set1 size={100,20},value=shape_hole_QPISIM,proc=SetVarProc_ConstQPIsimuand2bands,limits={0.1,inf,1},title="BandShape(h)"//,pos={1,1}
			SetVariable set3 size={100,20},value=gap_hole_QPISIM,proc=SetVarProc_ConstQPIsimuand2bands,limits={0.1,inf,0.2},title="Δ(h)"//,pos={1,1}
			SetVariable set5 size={100,20},value=mu_hole_QPISIM,proc=SetVarProc_ConstQPIsimuand2bands,limits={-inf,inf,0.5},title="μ(h)"//,pos={1,1}

		//Bogoliubov coherence factor E > 0
				//variable/G Mask_hole_p_E_Intens = 0.15
				//variable/G Mask_hole_p_E_FWHM = 1
				//variable/G Mask_hole_p_E_detune = 0.5
				//variable/G Mask_hole_p_k_Intens0 = 0
				//variable/G Mask_hole_p_k_Intens = 0.8
				//variable/G Mask_hole_p_k_FWHM = 0.6
			SetVariable set9 size={100,20},value=Mask_hole_p_E_Intens,proc=SetVarProc_ConstQPIsimuand2bands,limits={0,inf,0.1},title="+M(E,A)_h"//,pos={1,1}
			SetVariable set10 size={100,20},value=Mask_hole_p_E_FWHM,proc=SetVarProc_ConstQPIsimuand2bands,limits={0.01,inf,0.1},title="+M(E,σ)_h"//,pos={1,1}
			SetVariable set11 size={100,20},value=Mask_hole_p_E_detune,proc=SetVarProc_ConstQPIsimuand2bands,limits={-inf,inf,0.1},title="+M(E,dE)_h"//,pos={1,1}
			SetVariable set12 size={100,20},value=Mask_hole_p_k_Intens0,proc=SetVarProc_ConstQPIsimuand2bands,limits={0,inf,0.1},title="+M(k,A0)_h"//,pos={1,1}
			SetVariable set13 size={100,20},value=Mask_hole_p_k_Intens,proc=SetVarProc_ConstQPIsimuand2bands,limits={0,inf,0.1},title="+M(k,A)_h"//,pos={1,1}
			SetVariable set14 size={100,20},value=Mask_hole_p_k_FWHM,proc=SetVarProc_ConstQPIsimuand2bands,limits={0.01,inf,0.1},title="+M(k,σ)_h"//,pos={1,1}

		//Bogoliubov coherence factor E < 0
				//variable/G Mask_hole_n_E_Intens = 0.1
				//variable/G Mask_hole_n_E_FWHM = 1
				//variable/G Mask_hole_n_E_detune = 0.5
				//variable/G Mask_hole_n_k_Intens0 = 0
				//variable/G Mask_hole_n_k_Intens = 15//2.5
				//variable/G Mask_hole_n_k_FWHM = 5
			SetVariable set15 size={100,20},value=Mask_hole_n_E_Intens,proc=SetVarProc_ConstQPIsimuand2bands,limits={0,inf,0.1},title="-M(E,A)_h"//,pos={1,1}
			SetVariable set16 size={100,20},value=Mask_hole_n_E_FWHM,proc=SetVarProc_ConstQPIsimuand2bands,limits={0.01,inf,0.1},title="-M(E,σ)_h"//,pos={1,1}
			SetVariable set17 size={100,20},value=Mask_hole_n_E_detune,proc=SetVarProc_ConstQPIsimuand2bands,limits={-inf,inf,0.1},title="-M(E,dE)_h"//,pos={1,1}
			SetVariable set18 size={100,20},value=Mask_hole_n_k_Intens0,proc=SetVarProc_ConstQPIsimuand2bands,limits={0,inf,0.1},title="-M(k,A0)_h"//,pos={1,1}
			SetVariable set19 size={100,20},value=Mask_hole_n_k_Intens,proc=SetVarProc_ConstQPIsimuand2bands,limits={0,inf,0.1},title="-M(k,A)_h"//,pos={1,1}
			SetVariable set20 size={100,20},value=Mask_hole_n_k_FWHM,proc=SetVarProc_ConstQPIsimuand2bands,limits={0.01,inf,0.1},title="-M(k,σ)_h"//,pos={1,1}

	//Electron bands (M)

		//Basic parameters
			SetVariable set2 size={100,20},value=shape_ele_QPISIM,proc=SetVarProc_ConstQPIsimuand2bands,limits={0.1,inf,1},title="BandShape(e)"//,pos={1,1}
			SetVariable set4 size={100,20},value=gap_ele_QPISIM,proc=SetVarProc_ConstQPIsimuand2bands,limits={0.1,inf,0.2},title="Δ(e)"//,pos={1,1}
			SetVariable set6 size={100,20},value=mu_ele_QPISIM,proc=SetVarProc_ConstQPIsimuand2bands,limits={-inf,inf,0.5},title="μ(e)"//,pos={1,1}

		//Bogoliubov coherence factor E > 0
				//variable/G Mask_ele_p_E_Intens = 0
				//variable/G Mask_ele_p_E_FWHM = 1
				//variable/G Mask_ele_p_E_detune = 0.5
				//variable/G Mask_ele_p_k_Intens0 = 0.6
				//variable/G Mask_ele_p_k_Intens = 0
				//variable/G Mask_ele_p_k_FWHM = 5
			SetVariable set21 size={100,20},value=Mask_ele_p_E_Intens,proc=SetVarProc_ConstQPIsimuand2bands,limits={0,inf,0.1},title="+M(E,A)_e"//,pos={1,1}
			SetVariable set22 size={100,20},value=Mask_ele_p_E_FWHM,proc=SetVarProc_ConstQPIsimuand2bands,limits={0.01,inf,0.1},title="+M(E,σ)_e"//,pos={1,1}
			SetVariable set23 size={100,20},value=Mask_ele_p_E_detune,proc=SetVarProc_ConstQPIsimuand2bands,limits={-inf,inf,0.1},title="+M(E,dE)_e"//,pos={1,1}
			SetVariable set24 size={100,20},value=Mask_ele_p_k_Intens0,proc=SetVarProc_ConstQPIsimuand2bands,limits={0,inf,0.1},title="+M(k,A0)_e"//,pos={1,1}
			SetVariable set25 size={100,20},value=Mask_ele_p_k_Intens,proc=SetVarProc_ConstQPIsimuand2bands,limits={0,inf,0.1},title="+M(k,A)_e"//,pos={1,1}
			SetVariable set26 size={100,20},value=Mask_ele_p_k_FWHM,proc=SetVarProc_ConstQPIsimuand2bands,limits={0.01,inf,0.1},title="+M(k,σ)_e"//,pos={1,1}

		//Bogoliubov coherence factor E < 0
				//variable/G Mask_ele_n_E_Intens = 0
				//variable/G Mask_ele_n_E_FWHM = 1
				//variable/G Mask_ele_n_E_detune = 0.5
				//variable/G Mask_ele_n_k_Intens0 = 0.05
				//variable/G Mask_ele_n_k_Intens = 0
				//variable/G Mask_ele_n_k_FWHM = 0.6
			SetVariable set27 size={100,20},value=Mask_ele_n_E_Intens,proc=SetVarProc_ConstQPIsimuand2bands,limits={0,inf,0.1},title="-M(E,A)_e"//,pos={1,1}
			SetVariable set28 size={100,20},value=Mask_ele_n_E_FWHM,proc=SetVarProc_ConstQPIsimuand2bands,limits={0.01,inf,0.1},title="-M(E,σ)_e"//,pos={1,1}
			SetVariable set29 size={100,20},value=Mask_ele_n_E_detune,proc=SetVarProc_ConstQPIsimuand2bands,limits={-inf,inf,0.1},title="-M(E,dE)_e"//,pos={1,1}
			SetVariable set30 size={100,20},value=Mask_ele_n_k_Intens0,proc=SetVarProc_ConstQPIsimuand2bands,limits={0,inf,0.1},title="-M(k,A0)_e"//,pos={1,1}
			SetVariable set31 size={100,20},value=Mask_ele_n_k_Intens,proc=SetVarProc_ConstQPIsimuand2bands,limits={0,inf,0.1},title="-M(k,A)_e"//,pos={1,1}
			SetVariable set32 size={100,20},value=Mask_ele_n_k_FWHM,proc=SetVarProc_ConstQPIsimuand2bands,limits={0.01,inf,0.1},title="-M(k,σ)_e"//,pos={1,1}

		//Set positions
			SetVariable set7 pos={200,1}
			SetVariable set8 pos={312,1}
			SetVariable set34 pos={416,1}
			SetVariable set2 pos={373,35}
			SetVariable set4 pos={483,35}
			SetVariable set6 pos={593,35}
			SetVariable set1 pos={9,35}
			SetVariable set3 pos={115,35}
			SetVariable set5 pos={219,35}
			SetVariable set9 pos={18,392}
			SetVariable set10 pos={125,392}
			SetVariable set11 pos={230,392}
			SetVariable set13 pos={18,419}
			SetVariable set14 pos={125,419}
			SetVariable set12 pos={229,419}
			SetVariable set21 pos={367,392}
			SetVariable set22 pos={477,392}
			SetVariable set23 pos={587,392}
			SetVariable set25 pos={366,419}
			SetVariable set26 pos={476,419}
			SetVariable set24 pos={587,419}
			SetVariable set15 pos={18,461}
			SetVariable set16 pos={125,461}
			SetVariable set17 pos={227,461}
			SetVariable set27 pos={367,461}
			SetVariable set28 pos={477,461}
			SetVariable set29 pos={586,461}
			SetVariable set19 pos={18,486}
			SetVariable set20 pos={124,486}
			SetVariable set18 pos={227,486}
			SetVariable set31 pos={367,486}
			SetVariable set32 pos={477,486}
			SetVariable set30 pos={586,486}
			SetVariable set33 pos={155,530}

			SetDrawEnv xcoord= axrel,ycoord= axrel,fillfgc= (49151,49152,65535);
			DrawRect 0.00142857142857,0.428888888888889,0.477142857142857,0.487581300813008

			SetDrawEnv xcoord= axrel,ycoord= axrel,fillfgc= (49151,49152,65535);
			DrawRect 0.00142857142857,0.504444444444445,0.477142857142857,0.563136856368567

			SetDrawEnv xcoord= axrel,ycoord= axrel,fillfgc= (49151,49152,65535);
			DrawRect 0.00142857142857,0.0355555555555554,0.477142857142857,0.0575813008130081

			SetDrawEnv xcoord= axrel,ycoord= axrel,fillfgc= (65535,49151,49151);
			DrawRect 0.50142857142857,0.428888888888889,0.977142857142857,0.487581300813008

			SetDrawEnv xcoord= axrel,ycoord= axrel,fillfgc= (65535,49151,49151);
			DrawRect 0.50142857142857,0.504444444444445,0.977142857142857,0.563136856368567

			SetDrawEnv xcoord= axrel,ycoord= axrel,fillfgc= (65535,49151,49151);
			DrawRect 0.52285714285714,0.0355555555555554,0.99857142857143,0.0575813008130081

			SetDrawEnv textrgb= (0,0,65535),textyjust= 2,fsize= 16;DrawText 0.158571428571429,0.0166666666666667,"Hole band (Γ)"
			SetDrawEnv textrgb= (65535,0,0),textyjust= 2,fsize= 16;DrawText 0.688571428571429,0.0166666666666667,"Electron band (M)"

			SetDrawEnv textrgb= (0,0,65535),textyjust= 1;DelayUpdate
			DrawText 0.00285714285714286,0.42111111111111,"+E (hole)  SC coherence factor"

			SetDrawEnv textrgb= (0,0,65535),textyjust= 1;DelayUpdate
			DrawText 0.00571428571428571,0.496666666666666,"-E (hole)  SC coherence factor"

			SetDrawEnv textrgb= (0,0,65535),textyjust= 1;DelayUpdate
			SetDrawEnv textrgb= (65535,0,0);DelayUpdate
			DrawText 0.498571428571427,0.42111111111111,"+E (electron)  SC coherence factor"

			SetDrawEnv textrgb= (0,0,65535),textyjust= 1;DelayUpdate
			SetDrawEnv textrgb= (65535,0,0);DelayUpdate
			DrawText 0.498571428571427,0.496666666666665,"-E (electron)  SC coherence factor"

		Button turnoffQPISIM title="X",size={45,12},valueColor=(0,0,0),fColor=(1,65535,33232),proc=ButtonProc_lsturnoff3d
		Button turnoffQPISIM size={25,12}, pos={668,6}

		Button MakeQPIGMcut title="QPI(G-X)",size={45,12},valueColor=(0,0,0),fColor=(1,65535,33232),proc=ButtonProc_QPIESimu_getGMcut
		Button MakeQPIGMcut size={80,20}
		Button MakeQPIGMcut pos={492,510}

		Button AppendMakeQPIGMcut size={45,12},valueColor=(0,0,0),fColor=(1,65535,33232),proc=ButtonProc_appendQPIESimu_getGMcut
		Button AppendMakeQPIGMcut title="Append QPI",fSize=8

		Button AppendMakebandGMcut size={45,12},valueColor=(0,0,0),fColor=(1,65535,33232),proc=ButtonProc_appendQPIESimu_getGMcut2
		Button AppendMakebandGMcut title="Append Band",fSize=8

		Button showLDOS title="LDOS",size={45,12},proc=ButtonProc_LDOSQPIESimu
		Button showLDOS pos={555,512}
		Button AppendMakeQPIGMcut size={70,12},pos={498,535};
		Button AppendMakebandGMcut size={70,12},pos={425,535};
		Button showLDOS size={70,12},fSize=8,pos={571,535};
		variable/G save3D_QPISIM = 0
		SetVariable set36 size={100,20},value=save3D_QPISIM,limits={0,1,1},title="Save 3D?"//,pos={1,1}
		SetVariable set36 size={75,14},pos={578,513}


		Button template1 title="Temp#h",size={45,12},valueColor=(0,0,0),fColor=(1,65535,33232),proc=ButtonProc_QPIESimutemp1
		Button template2 title="Temp#e-h",size={45,12},valueColor=(0,0,0),fColor=(1,65535,33232),proc=ButtonProc_QPIESimutemp2
		Button template3 title="Temp#e",size={45,12},valueColor=(0,0,0),fColor=(1,65535,33232),proc=ButtonProc_QPIESimutemp3

		Button template1 size={80,12},pos={208,512},fColor=(65535,32768,58981)
		Button template2 size={80,12},pos={298,512},fColor=(65535,32768,58981)
		Button template3 size={80,12},pos={388,512},fColor=(65535,32768,58981)

end

Function ButtonProc_QPIESimutemp1(ctrlName) : ButtonControl
	String ctrlName
	// Hole E > 0
	variable/G Mask_hole_p_E_Intens = 0.5
	variable/G Mask_hole_p_E_FWHM = 1
	variable/G Mask_hole_p_E_detune = 0
	variable/G Mask_hole_p_k_Intens0 = 0
	variable/G Mask_hole_p_k_Intens = 0.8
	variable/G Mask_hole_p_k_FWHM = 0.4

	// Hole E < 0
	variable/G Mask_hole_n_E_Intens = 0.5
	variable/G Mask_hole_n_E_FWHM = 1
	variable/G Mask_hole_n_E_detune = 0
	variable/G Mask_hole_n_k_Intens0 = 0
	variable/G Mask_hole_n_k_Intens = 5//2.5
	variable/G Mask_hole_n_k_FWHM = 5

	// electron E > 0
	variable/G Mask_ele_p_E_Intens = 0
	variable/G Mask_ele_p_E_FWHM = 1
	variable/G Mask_ele_p_E_detune = 0
	variable/G Mask_ele_p_k_Intens0 = 0.6
	variable/G Mask_ele_p_k_Intens = 0
	variable/G Mask_ele_p_k_FWHM = 5

	// electron E < 0
	variable/G Mask_ele_n_E_Intens = 0
	variable/G Mask_ele_n_E_FWHM = 1
	variable/G Mask_ele_n_E_detune = 0
	variable/G Mask_ele_n_k_Intens0 = 0.05
	variable/G Mask_ele_n_k_Intens = 0
	variable/G Mask_ele_n_k_FWHM = 0.6

	variable/G z_QPISIM = 0
	variable/G quality_QPISIM = 250

	variable shape_hole = 20
	variable shape_ele = 20
	variable gap_hole = 1.5
	variable gap_ele = 1.5
	variable mu_hole = 4
	variable mu_ele  = -4.5
	variable selfE = 0.5
	variable sel = 2
	variable/G shape_hole_QPISIM = shape_hole
	variable/G shape_ele_QPISIM = shape_ele
	variable/G gap_hole_QPISIM = gap_hole
	variable/G gap_ele_QPISIM = gap_ele
	variable/G mu_hole_QPISIM = mu_hole
	variable/G mu_ele_QPISIM = mu_ele
	variable/G selfE_QPISIM = selfE
	variable/G sel_QPISIM = sel
	QPIESimu2Dband_interact(shape_hole_QPISIM ,shape_ele_QPISIM ,mu_hole_QPISIM ,mu_ele_QPISIM ,gap_hole_QPISIM ,gap_ele_QPISIM ,selfE_QPISIM ,sel_QPISIM )
end

Function ButtonProc_QPIESimutemp3(ctrlName) : ButtonControl
	String ctrlName
	// electron E > 0
	variable/G Mask_ele_n_E_Intens = 0.15
	variable/G Mask_ele_n_E_FWHM = 1
	variable/G Mask_ele_n_E_detune = 0
	variable/G Mask_ele_n_k_Intens0 = 0
	variable/G Mask_ele_n_k_Intens = 0.8
	variable/G Mask_ele_n_k_FWHM = 0.6

	// electron E < 0
	variable/G Mask_ele_p_E_Intens = 0.1
	variable/G Mask_ele_p_E_FWHM = 1
	variable/G Mask_ele_p_E_detune = 0
	variable/G Mask_ele_p_k_Intens0 = 0
	variable/G Mask_ele_p_k_Intens = 15//2.5
	variable/G Mask_ele_p_k_FWHM = 5

	// Hole E > 0
	variable/G Mask_hole_n_E_Intens = 0
	variable/G Mask_hole_n_E_FWHM = 1
	variable/G Mask_hole_n_E_detune = 0
	variable/G Mask_hole_n_k_Intens0 = 0.6
	variable/G Mask_hole_n_k_Intens = 0
	variable/G Mask_hole_n_k_FWHM = 5

	// Hole E < 0
	variable/G Mask_hole_p_E_Intens = 0
	variable/G Mask_hole_p_E_FWHM = 1
	variable/G Mask_hole_p_E_detune = 0
	variable/G Mask_hole_p_k_Intens0 = 0.05
	variable/G Mask_hole_p_k_Intens = 0
	variable/G Mask_hole_p_k_FWHM = 0.6

	variable/G z_QPISIM = 0
	variable/G quality_QPISIM = 250

	variable shape_hole = 20
	variable shape_ele = 20
	variable gap_hole = 1.5
	variable gap_ele = 1.5
	variable mu_hole = -4.5
	variable mu_ele  = 4
	variable selfE = 0.5
	variable sel = 2
	variable/G shape_hole_QPISIM = shape_hole
	variable/G shape_ele_QPISIM = shape_ele
	variable/G gap_hole_QPISIM = gap_hole
	variable/G gap_ele_QPISIM = gap_ele
	variable/G mu_hole_QPISIM = mu_hole
	variable/G mu_ele_QPISIM = mu_ele
	variable/G selfE_QPISIM = selfE
	variable/G sel_QPISIM = sel
	QPIESimu2Dband_interact(shape_hole_QPISIM ,shape_ele_QPISIM ,mu_hole_QPISIM ,mu_ele_QPISIM ,gap_hole_QPISIM ,gap_ele_QPISIM ,selfE_QPISIM ,sel_QPISIM )
end

Function ButtonProc_QPIESimutemp2(ctrlName) : ButtonControl
	String ctrlName
	// Hole E > 0
	variable/G Mask_hole_p_E_Intens = 1
	variable/G Mask_hole_p_E_FWHM = 1
	variable/G Mask_hole_p_E_detune = 0
	variable/G Mask_hole_p_k_Intens0 = 0
	variable/G Mask_hole_p_k_Intens = 0.8
	variable/G Mask_hole_p_k_FWHM = 0.6

	// Hole E < 0
	variable/G Mask_hole_n_E_Intens = 1
	variable/G Mask_hole_n_E_FWHM = 1
	variable/G Mask_hole_n_E_detune = 0
	variable/G Mask_hole_n_k_Intens0 = 0
	variable/G Mask_hole_n_k_Intens = 30//2.5
	variable/G Mask_hole_n_k_FWHM = 5

	// electron E > 0
	variable/G Mask_ele_p_E_Intens = 1.45
	variable/G Mask_ele_p_E_FWHM = 1
	variable/G Mask_ele_p_E_detune = 0
	variable/G Mask_ele_p_k_Intens0 = 0
	variable/G Mask_ele_p_k_Intens = 15
	variable/G Mask_ele_p_k_FWHM = 5

	// electron E < 0
	variable/G Mask_ele_n_E_Intens = 1.45
	variable/G Mask_ele_n_E_FWHM = 1
	variable/G Mask_ele_n_E_detune = 0
	variable/G Mask_ele_n_k_Intens0 = 0
	variable/G Mask_ele_n_k_Intens = 0.8
	variable/G Mask_ele_n_k_FWHM = 0.6

	variable/G z_QPISIM = 0
	variable/G quality_QPISIM = 250

	variable shape_hole = 20
	variable shape_ele = 20
	variable gap_hole = 1.5
	variable gap_ele = 1.5
	variable mu_hole = 4
	variable mu_ele  = 8
	variable selfE = 0.4
	variable sel = 2
	variable/G shape_hole_QPISIM = shape_hole
	variable/G shape_ele_QPISIM = shape_ele
	variable/G gap_hole_QPISIM = gap_hole
	variable/G gap_ele_QPISIM = gap_ele
	variable/G mu_hole_QPISIM = mu_hole
	variable/G mu_ele_QPISIM = mu_ele
	variable/G selfE_QPISIM = selfE
	variable/G sel_QPISIM = sel
	QPIESimu2Dband_interact(shape_hole_QPISIM ,shape_ele_QPISIM ,mu_hole_QPISIM ,mu_ele_QPISIM ,gap_hole_QPISIM ,gap_ele_QPISIM ,selfE_QPISIM ,sel_QPISIM )
end

Function SetVarProc_ConstQPIsimuand2bands(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G shape_hole_QPISIM
	variable/G shape_ele_QPISIM
	variable/G gap_hole_QPISIM
	variable/G gap_ele_QPISIM
	variable/G mu_hole_QPISIM
	variable/G mu_ele_QPISIM
	variable/G selfE_QPISIM
	variable/G sel_QPISIM

	QPIESimu2Dband_interact(shape_hole_QPISIM ,shape_ele_QPISIM ,mu_hole_QPISIM ,mu_ele_QPISIM ,gap_hole_QPISIM ,gap_ele_QPISIM ,selfE_QPISIM ,sel_QPISIM )
	wave simu_FS = $"simu_FS"
	wavestats/Q simu_FS
	variable rangls = max(abs(V_max),abs(V_min))
	ModifyImage/W=$"TwobandsimuandQPIsimu#G1" simu_FS ctab= {-rangls,rangls,:Packages:NewColortable:dvg_seismic,0};
	wave simu_FS_corr = $"simu_FS_corr"
	ModifyImage/W=$"TwobandsimuandQPIsimu#G2" simu_FS_corr ctab= {*,*,VioletOrangeYellow,1}
end

Function SetVarProc_ConstQPIsimuand2bandsFS(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G shape_hole_QPISIM
	variable/G shape_ele_QPISIM
	variable/G gap_hole_QPISIM
	variable/G gap_ele_QPISIM
	variable/G mu_hole_QPISIM
	variable/G mu_ele_QPISIM
	variable/G selfE_QPISIM
	variable/G sel_QPISIM

	QPIESimu2Dband_interactFS(shape_hole_QPISIM ,shape_ele_QPISIM ,mu_hole_QPISIM ,mu_ele_QPISIM ,gap_hole_QPISIM ,gap_ele_QPISIM ,selfE_QPISIM ,sel_QPISIM )
	wave simu_FS = $"simu_FS"
	wavestats/Q simu_FS
	variable rangls = max(abs(V_max),abs(V_min))
	ModifyImage/W=$"TwobandsimuandQPIsimu#G1" simu_FS ctab= {-rangls,rangls,:Packages:NewColortable:dvg_seismic,0};
	wave simu_FS_corr = $"simu_FS_corr"
	ModifyImage/W=$"TwobandsimuandQPIsimu#G2" simu_FS_corr ctab= {*,*,VioletOrangeYellow,1}
end

Function QPIESimu2Dband_interact(shape_hole,shape_ele,mu_hole,mu_ele,gap_hole,gap_ele,selfE,sel)
	variable shape_hole
	variable shape_ele
	variable gap_hole
	variable gap_ele
	variable mu_hole
	variable mu_ele
	variable selfE
	variable sel

	// Hole E > 0
	variable/G Mask_hole_p_E_Intens// = 0.15
	variable/G Mask_hole_p_E_FWHM// = 1
	variable/G Mask_hole_p_E_detune// = 0.5
	variable/G Mask_hole_p_k_Intens0// = 0
	variable/G Mask_hole_p_k_Intens// = 0.8
	variable/G Mask_hole_p_k_FWHM// = 0.6

	// Hole E < 0
	variable/G Mask_hole_n_E_Intens// = 0.1
	variable/G Mask_hole_n_E_FWHM// = 1
	variable/G Mask_hole_n_E_detune// = 0.5
	variable/G Mask_hole_n_k_Intens0// = 0
	variable/G Mask_hole_n_k_Intens// = 15//2.5
	variable/G Mask_hole_n_k_FWHM// = 5

	// electron E > 0
	variable/G Mask_ele_p_E_Intens// = 0
	variable/G Mask_ele_p_E_FWHM// = 1
	variable/G Mask_ele_p_E_detune// = 0.5
	variable/G Mask_ele_p_k_Intens0// = 0.6
	variable/G Mask_ele_p_k_Intens// = 0
	variable/G Mask_ele_p_k_FWHM// = 5

	// electron E < 0
	variable/G Mask_ele_n_E_Intens// = 0
	variable/G Mask_ele_n_E_FWHM// = 1
	variable/G Mask_ele_n_E_detune// = 0.5
	variable/G Mask_ele_n_k_Intens0// = 0.05
	variable/G Mask_ele_n_k_Intens// = 0
	variable/G Mask_ele_n_k_FWHM// = 0.6

	variable/G z_QPISIM
	variable/G quality_QPISIM

	make/N=2/o Eindicator_Y_QPISIM; Eindicator_Y_QPISIM={z_QPISIM,z_QPISIM}
	make/N=2/o Eindicator_X_QPISIM; Eindicator_X_QPISIM={-2*pi,2*pi}



	make/n=(quality_QPISIM*sqrt(2),quality_QPISIM)/o simudisper_GM
	setscale/I x, -2*pi, 2*pi,"",simudisper_GM
	setscale/I y, -20, 20,"",simudisper_GM

	if (sel == 1)
		//Normal state
			// Gamma hole pocket
				simudisper_GM= 1/((y+          (shape_hole*(1-cos(x))+(shape_hole*(1-cos(x)))-mu_hole)         )^2+(selfE)^2)
			// M electron pocket
				simudisper_GM += 1/((y-        (shape_ele*(1-cos(x+pi))+shape_ele*(1-cos(x+pi))-mu_ele)               )^2+(selfE)^2)
	endif

//(sqrt(2)/2)*(x-y))



	if (sel == 2)
		//SC hole band (Gamma)
	  		// Below EF (n)
				//spectral weight follow k
					simudisper_GM = (Mask_hole_n_k_Intens0+Mask_hole_n_k_Intens*(1-exp(-(2*(1-cos(x)))/(Mask_hole_n_k_FWHM/(2*sqrt(ln(2))))^2)))/((y+     sqrt((shape_hole*(1-cos(x))+(shape_hole*(1-cos(x)))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
				//spectral weight follow E (add some around delta to enhance coherence peak)
					if (Mask_hole_n_E_Intens == 0)
					else
						simudisper_GM += Mask_hole_n_E_Intens*(exp(-(y+(gap_hole+Mask_hole_n_E_detune))^2/(Mask_hole_n_E_FWHM/(2*sqrt(ln(2))))^2))/((y+     sqrt((shape_hole*(1-cos(x))+(shape_hole*(1-cos(x)))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
 	  				endif
 	  		// Above EF (p)
				//spectral weight follow k
					simudisper_GM += (Mask_hole_p_k_Intens0+Mask_hole_p_k_Intens*(exp(-(2*(1-cos(x)))/(Mask_hole_p_k_FWHM/(2*sqrt(ln(2))))^2)))/((y+     -sqrt((shape_hole*(1-cos(x))+(shape_hole*(1-cos(x)))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
				//spectral weight follow E (add some around delta to enhance coherence peak)
					if (Mask_hole_p_E_Intens == 0)
					else
						simudisper_GM += Mask_hole_p_E_Intens*(exp(-(y-(gap_hole+Mask_hole_p_E_detune))^2/(Mask_hole_p_E_FWHM/(2*sqrt(ln(2))))^2))/((y+     -sqrt((shape_hole*(1-cos(x))+(shape_hole*(1-cos(x)))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
					endif
		//electron band (M)
	  		// Below EF (n)
				//spectral weight follow k
					simudisper_GM += (Mask_ele_n_k_Intens0+Mask_ele_n_k_Intens*(exp(-(2*(1-cos(x+pi)))/(Mask_ele_n_k_FWHM/(2*sqrt(ln(2))))^2)))/((y-        -sqrt((shape_ele*(1-cos(x+pi))+shape_ele*(1-cos(x+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
				//spectral weight follow E (add some around delta to enhance coherence peak)
					if (Mask_ele_n_E_Intens == 0)
					else
						simudisper_GM += Mask_ele_n_E_Intens*(exp(-(y+(gap_ele+Mask_ele_n_E_detune))^2/(Mask_ele_n_E_FWHM/(2*sqrt(ln(2))))^2))/((y-        -sqrt((shape_ele*(1-cos(x+pi))+shape_ele*(1-cos(x+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
					endif

			// above EF
				//spectral weight follow k
					simudisper_GM += (Mask_ele_p_k_Intens0+Mask_ele_p_k_Intens*(1-exp(-(2*(1-cos(x+pi)))/(Mask_ele_p_k_FWHM/(2*sqrt(ln(2))))^2)))/((y-        sqrt((shape_ele*(1-cos(x+pi))+shape_ele*(1-cos(x+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
				//spectral weight follow E (add some around delta to enhance coherence peak)
					if (Mask_ele_p_E_Intens == 0)
					else
						simudisper_GM += Mask_ele_p_E_Intens*(exp(-(y-(gap_ele+Mask_ele_p_E_detune))^2/(Mask_ele_p_E_FWHM/(2*sqrt(ln(2))))^2))/((y-        sqrt((shape_ele*(1-cos(x+pi))+shape_ele*(1-cos(x+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
					endif
	endif

	make/n=(quality_QPISIM,quality_QPISIM)/o simu_FS
	setscale/I x, -2*pi, 2*pi,"",simu_FS
	setscale/I y, -2*pi, 2*pi,"",simu_FS

	if (sel == 1)
		//Normal state
			// Gamma hole pocket
				//simu_FS= 1/((z_QPISIM+          (shape_hole*(1-cos(x))+(shape_hole*(1-cos(y)))-mu_hole)         )^2+(selfE)^2)
				simu_FS= 1/((z_QPISIM+          (shape_hole*(1-cos((sqrt(2)/2)*(x-y)))+(shape_hole*(1-cos((sqrt(2)/2)*(x+y))))-mu_hole)         )^2+(selfE)^2)

			// M electron pocket

				//simu_FS += 1/((z_QPISIM-        (shape_ele*(1-cos(x+pi))+shape_ele*(1-cos(y+pi))-mu_ele)               )^2+(selfE)^2)
				simu_FS += 1/((z_QPISIM-        (shape_ele*(1-cos((sqrt(2)/2)*(x-y)+pi))+shape_ele*(1-cos((sqrt(2)/2)*(x+y)+pi))-mu_ele)               )^2+(selfE)^2)

	endif

	if (sel == 2)
		//SC hole band (Gamma)
	  		// Below EF (n)
				//spectral weight follow k
					simu_FS = (Mask_hole_n_k_Intens0+Mask_hole_n_k_Intens*(1-exp(-(2*(1-cos((sqrt(2)/2)*(x-y)))+2*(1-cos((sqrt(2)/2)*(x+y))))/(Mask_hole_n_k_FWHM/(2*sqrt(ln(2))))^2)))/((z_QPISIM+     sqrt((shape_hole*(1-cos((sqrt(2)/2)*(x-y)))+(shape_hole*(1-cos((sqrt(2)/2)*(x+y))))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
				//spectral weight follow E (add some around delta to enhance coherence peak)
					if (Mask_hole_n_E_Intens == 0)
					else
						simu_FS += Mask_hole_n_E_Intens*(exp(-(0+(gap_hole+Mask_hole_n_E_detune))^2/(Mask_hole_n_E_FWHM/(2*sqrt(ln(2))))^2))/((z_QPISIM+     sqrt((shape_hole*(1-cos((sqrt(2)/2)*(x-y)))+(shape_hole*(1-cos((sqrt(2)/2)*(x+y))))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
 	  				endif
 	  		// Above EF (p)
				//spectral weight follow k
					simu_FS += (Mask_hole_p_k_Intens0+Mask_hole_p_k_Intens*(exp(-(2*(1-cos((sqrt(2)/2)*(x-y)))+2*(1-cos((sqrt(2)/2)*(x+y))))/(Mask_hole_p_k_FWHM/(2*sqrt(ln(2))))^2)))/((z_QPISIM+     -sqrt((shape_hole*(1-cos((sqrt(2)/2)*(x-y)))+(shape_hole*(1-cos((sqrt(2)/2)*(x+y))))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
				//spectral weight follow E (add some around delta to enhance coherence peak)
					if (Mask_hole_p_E_Intens == 0)
					else
						simu_FS += Mask_hole_p_E_Intens*(exp(-(0-(gap_hole+Mask_hole_p_E_detune))^2/(Mask_hole_p_E_FWHM/(2*sqrt(ln(2))))^2))/((z_QPISIM+     -sqrt((shape_hole*(1-cos((sqrt(2)/2)*(x-y)))+(shape_hole*(1-cos((sqrt(2)/2)*(x+y))))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
					endif
		//electron band (M)
	  		// Below EF (n)
				//spectral weight follow k
					simu_FS += (Mask_ele_n_k_Intens0+Mask_ele_n_k_Intens*(exp(-(2*(1-cos((sqrt(2)/2)*(x-y)+pi))+2*(1-cos((sqrt(2)/2)*(x+y)+pi)))/(Mask_ele_n_k_FWHM/(2*sqrt(ln(2))))^2)))/((z_QPISIM-        -sqrt((shape_ele*(1-cos((sqrt(2)/2)*(x-y)+pi))+shape_ele*(1-cos((sqrt(2)/2)*(x+y)+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
				//spectral weight follow E (add some around delta to enhance coherence peak)
					if (Mask_ele_n_E_Intens == 0)
					else
						simu_FS += Mask_ele_n_E_Intens*(exp(-(z_QPISIM+(gap_ele+Mask_ele_n_E_detune))^2/(Mask_ele_n_E_FWHM/(2*sqrt(ln(2))))^2))/((z_QPISIM-        -sqrt((shape_ele*(1-cos((sqrt(2)/2)*(x-y)+pi))+shape_ele*(1-cos((sqrt(2)/2)*(x+y)+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
					endif

			// above EF
				//spectral weight follow k
					simu_FS += (Mask_ele_p_k_Intens0+Mask_ele_p_k_Intens*(1-exp(-(2*(1-cos((sqrt(2)/2)*(x-y)+pi))+2*(1-cos((sqrt(2)/2)*(x+y)+pi)))/(Mask_ele_p_k_FWHM/(2*sqrt(ln(2))))^2)))/((z_QPISIM-        sqrt((shape_ele*(1-cos((sqrt(2)/2)*(x-y)+pi))+shape_ele*(1-cos((sqrt(2)/2)*(x+y)+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
				//spectral weight follow E (add some around delta to enhance coherence peak)
					if (Mask_ele_p_E_Intens == 0)
					else
						simu_FS += Mask_ele_p_E_Intens*(exp(-(z_QPISIM-(gap_ele+Mask_ele_p_E_detune))^2/(Mask_ele_p_E_FWHM/(2*sqrt(ln(2))))^2))/((z_QPISIM-        sqrt((shape_ele*(1-cos((sqrt(2)/2)*(x-y)+pi))+shape_ele*(1-cos((sqrt(2)/2)*(x+y)+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
					endif
	endif

	MatrixOP/O simu_FS_corr=Correlate(simu_FS,simu_FS,4)

	duplicate/o simudisper_GM simudisper_GM2

end

Function QPIESimu2Dband_interactFS(shape_hole,shape_ele,mu_hole,mu_ele,gap_hole,gap_ele,selfE,sel)
	variable shape_hole
	variable shape_ele
	variable gap_hole
	variable gap_ele
	variable mu_hole
	variable mu_ele
	variable selfE
	variable sel

	// Hole E > 0
	variable/G Mask_hole_p_E_Intens// = 0.15
	variable/G Mask_hole_p_E_FWHM// = 1
	variable/G Mask_hole_p_E_detune// = 0.5
	variable/G Mask_hole_p_k_Intens0// = 0
	variable/G Mask_hole_p_k_Intens// = 0.8
	variable/G Mask_hole_p_k_FWHM// = 0.6

	// Hole E < 0
	variable/G Mask_hole_n_E_Intens// = 0.1
	variable/G Mask_hole_n_E_FWHM// = 1
	variable/G Mask_hole_n_E_detune// = 0.5
	variable/G Mask_hole_n_k_Intens0// = 0
	variable/G Mask_hole_n_k_Intens// = 15//2.5
	variable/G Mask_hole_n_k_FWHM// = 5

	// electron E > 0
	variable/G Mask_ele_p_E_Intens// = 0
	variable/G Mask_ele_p_E_FWHM// = 1
	variable/G Mask_ele_p_E_detune// = 0.5
	variable/G Mask_ele_p_k_Intens0// = 0.6
	variable/G Mask_ele_p_k_Intens// = 0
	variable/G Mask_ele_p_k_FWHM// = 5

	// electron E < 0
	variable/G Mask_ele_n_E_Intens// = 0
	variable/G Mask_ele_n_E_FWHM// = 1
	variable/G Mask_ele_n_E_detune// = 0.5
	variable/G Mask_ele_n_k_Intens0// = 0.05
	variable/G Mask_ele_n_k_Intens// = 0
	variable/G Mask_ele_n_k_FWHM// = 0.6

	variable/G z_QPISIM
	variable/G quality_QPISIM

	make/N=2/o Eindicator_Y_QPISIM; Eindicator_Y_QPISIM={z_QPISIM,z_QPISIM}
	make/N=2/o Eindicator_X_QPISIM; Eindicator_X_QPISIM={-2*pi,2*pi}



	make/n=(quality_QPISIM,quality_QPISIM)/o simu_FS
	setscale/I x, -2*pi, 2*pi,"",simu_FS
	setscale/I y, -2*pi, 2*pi,"",simu_FS

//	if (sel == 1)
		//Normal state
			// Gamma hole pocket
//				simu_FS= 1/((z_QPISIM+          (shape_hole*(1-cos(x))+(shape_hole*(1-cos(y)))-mu_hole)         )^2+(selfE)^2)
			// M electron pocket
//				simu_FS += 1/((z_QPISIM-        (shape_ele*(1-cos(x+pi))+shape_ele*(1-cos(y+pi))-mu_ele)               )^2+(selfE)^2)
//	endif

	if (sel == 1)
		//Normal state
			// Gamma hole pocket
				//simu_FS= 1/((z_QPISIM+          (shape_hole*(1-cos(x))+(shape_hole*(1-cos(y)))-mu_hole)         )^2+(selfE)^2)
				simu_FS= 1/((z_QPISIM+          (shape_hole*(1-cos((sqrt(2)/2)*(x-y)))+(shape_hole*(1-cos((sqrt(2)/2)*(x+y))))-mu_hole)         )^2+(selfE)^2)

			// M electron pocket

				//simu_FS += 1/((z_QPISIM-        (shape_ele*(1-cos(x+pi))+shape_ele*(1-cos(y+pi))-mu_ele)               )^2+(selfE)^2)
				simu_FS += 1/((z_QPISIM-        (shape_ele*(1-cos((sqrt(2)/2)*(x-y)+pi))+shape_ele*(1-cos((sqrt(2)/2)*(x+y)+pi))-mu_ele)               )^2+(selfE)^2)

	endif

//	if (sel == 2)
//		//SC hole band (Gamma)
//	  		// Below EF (n)
//				//spectral weight follow k
//					simu_FS = (Mask_hole_n_k_Intens0+Mask_hole_n_k_Intens*(1-exp(-(2*(1-cos(x))+2*(1-cos(y)))/(Mask_hole_n_k_FWHM/(2*sqrt(ln(2))))^2)))/((z_QPISIM+     sqrt((shape_hole*(1-cos(x))+(shape_hole*(1-cos(y)))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
//				//spectral weight follow E (add some around delta to enhance coherence peak)
//					if (Mask_hole_n_E_Intens == 0)
//					else
//						simu_FS += Mask_hole_n_E_Intens*(exp(-(0+(gap_hole+Mask_hole_n_E_detune))^2/(Mask_hole_n_E_FWHM/(2*sqrt(ln(2))))^2))/((z_QPISIM+     sqrt((shape_hole*(1-cos(x))+(shape_hole*(1-cos(y)))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
 //	  				endif
 	//  		// Above EF (p)
	//			//spectral weight follow k
	//				simu_FS += (Mask_hole_p_k_Intens0+Mask_hole_p_k_Intens*(exp(-(2*(1-cos(x))+2*(1-cos(y)))/(Mask_hole_p_k_FWHM/(2*sqrt(ln(2))))^2)))/((z_QPISIM+     -sqrt((shape_hole*(1-cos(x))+(shape_hole*(1-cos(y)))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
//			//spectral weight follow E (add some around delta to enhance coherence peak)
//					if (Mask_hole_p_E_Intens == 0)
//					else
//						simu_FS += Mask_hole_p_E_Intens*(exp(-(0-(gap_hole+Mask_hole_p_E_detune))^2/(Mask_hole_p_E_FWHM/(2*sqrt(ln(2))))^2))/((z_QPISIM+     -sqrt((shape_hole*(1-cos(x))+(shape_hole*(1-cos(y)))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
//					endif
//		//electron band (M)
	  		// Below EF (n)
				//spectral weight follow k
//					simu_FS += (Mask_ele_n_k_Intens0+Mask_ele_n_k_Intens*(exp(-(2*(1-cos(x+pi))+2*(1-cos(y+pi)))/(Mask_ele_n_k_FWHM/(2*sqrt(ln(2))))^2)))/((z_QPISIM-        -sqrt((shape_ele*(1-cos(x+pi))+shape_ele*(1-cos(y+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
				//spectral weight follow E (add some around delta to enhance coherence peak)
//					if (Mask_ele_n_E_Intens == 0)
//					else
//						simu_FS += Mask_ele_n_E_Intens*(exp(-(z_QPISIM+(gap_ele+Mask_ele_n_E_detune))^2/(Mask_ele_n_E_FWHM/(2*sqrt(ln(2))))^2))/((z_QPISIM-        -sqrt((shape_ele*(1-cos(x+pi))+shape_ele*(1-cos(y+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
//					endif

			// above EF
				//spectral weight follow k
//					simu_FS += (Mask_ele_p_k_Intens0+Mask_ele_p_k_Intens*(1-exp(-(2*(1-cos(x+pi))+2*(1-cos(y+pi)))/(Mask_ele_p_k_FWHM/(2*sqrt(ln(2))))^2)))/((z_QPISIM-        sqrt((shape_ele*(1-cos(x+pi))+shape_ele*(1-cos(y+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
				//spectral weight follow E (add some around delta to enhance coherence peak)
//					if (Mask_ele_p_E_Intens == 0)
//					else
//						simu_FS += Mask_ele_p_E_Intens*(exp(-(z_QPISIM-(gap_ele+Mask_ele_p_E_detune))^2/(Mask_ele_p_E_FWHM/(2*sqrt(ln(2))))^2))/((z_QPISIM-        sqrt((shape_ele*(1-cos(x+pi))+shape_ele*(1-cos(y+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
//					endif
//	endif

	if (sel == 2)
		//SC hole band (Gamma)
	  		// Below EF (n)
				//spectral weight follow k
					simu_FS = (Mask_hole_n_k_Intens0+Mask_hole_n_k_Intens*(1-exp(-(2*(1-cos((sqrt(2)/2)*(x-y)))+2*(1-cos((sqrt(2)/2)*(x+y))))/(Mask_hole_n_k_FWHM/(2*sqrt(ln(2))))^2)))/((z_QPISIM+     sqrt((shape_hole*(1-cos((sqrt(2)/2)*(x-y)))+(shape_hole*(1-cos((sqrt(2)/2)*(x+y))))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
				//spectral weight follow E (add some around delta to enhance coherence peak)
					if (Mask_hole_n_E_Intens == 0)
					else
						simu_FS += Mask_hole_n_E_Intens*(exp(-(0+(gap_hole+Mask_hole_n_E_detune))^2/(Mask_hole_n_E_FWHM/(2*sqrt(ln(2))))^2))/((z_QPISIM+     sqrt((shape_hole*(1-cos((sqrt(2)/2)*(x-y)))+(shape_hole*(1-cos((sqrt(2)/2)*(x+y))))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
 	  				endif
 	  		// Above EF (p)
				//spectral weight follow k
					simu_FS += (Mask_hole_p_k_Intens0+Mask_hole_p_k_Intens*(exp(-(2*(1-cos((sqrt(2)/2)*(x-y)))+2*(1-cos((sqrt(2)/2)*(x+y))))/(Mask_hole_p_k_FWHM/(2*sqrt(ln(2))))^2)))/((z_QPISIM+     -sqrt((shape_hole*(1-cos((sqrt(2)/2)*(x-y)))+(shape_hole*(1-cos((sqrt(2)/2)*(x+y))))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
				//spectral weight follow E (add some around delta to enhance coherence peak)
					if (Mask_hole_p_E_Intens == 0)
					else
						simu_FS += Mask_hole_p_E_Intens*(exp(-(0-(gap_hole+Mask_hole_p_E_detune))^2/(Mask_hole_p_E_FWHM/(2*sqrt(ln(2))))^2))/((z_QPISIM+     -sqrt((shape_hole*(1-cos((sqrt(2)/2)*(x-y)))+(shape_hole*(1-cos((sqrt(2)/2)*(x+y))))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
					endif
		//electron band (M)
	  		// Below EF (n)
				//spectral weight follow k
					simu_FS += (Mask_ele_n_k_Intens0+Mask_ele_n_k_Intens*(exp(-(2*(1-cos((sqrt(2)/2)*(x-y)+pi))+2*(1-cos((sqrt(2)/2)*(x+y)+pi)))/(Mask_ele_n_k_FWHM/(2*sqrt(ln(2))))^2)))/((z_QPISIM-        -sqrt((shape_ele*(1-cos((sqrt(2)/2)*(x-y)+pi))+shape_ele*(1-cos((sqrt(2)/2)*(x+y)+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
				//spectral weight follow E (add some around delta to enhance coherence peak)
					if (Mask_ele_n_E_Intens == 0)
					else
						simu_FS += Mask_ele_n_E_Intens*(exp(-(z_QPISIM+(gap_ele+Mask_ele_n_E_detune))^2/(Mask_ele_n_E_FWHM/(2*sqrt(ln(2))))^2))/((z_QPISIM-        -sqrt((shape_ele*(1-cos((sqrt(2)/2)*(x-y)+pi))+shape_ele*(1-cos((sqrt(2)/2)*(x+y)+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
					endif

			// above EF
				//spectral weight follow k
					simu_FS += (Mask_ele_p_k_Intens0+Mask_ele_p_k_Intens*(1-exp(-(2*(1-cos((sqrt(2)/2)*(x-y)+pi))+2*(1-cos((sqrt(2)/2)*(x+y)+pi)))/(Mask_ele_p_k_FWHM/(2*sqrt(ln(2))))^2)))/((z_QPISIM-        sqrt((shape_ele*(1-cos((sqrt(2)/2)*(x-y)+pi))+shape_ele*(1-cos((sqrt(2)/2)*(x+y)+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
				//spectral weight follow E (add some around delta to enhance coherence peak)
					if (Mask_ele_p_E_Intens == 0)
					else
						simu_FS += Mask_ele_p_E_Intens*(exp(-(z_QPISIM-(gap_ele+Mask_ele_p_E_detune))^2/(Mask_ele_p_E_FWHM/(2*sqrt(ln(2))))^2))/((z_QPISIM-        sqrt((shape_ele*(1-cos((sqrt(2)/2)*(x-y)+pi))+shape_ele*(1-cos((sqrt(2)/2)*(x+y)+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
					endif
	endif

	MatrixOP/O simu_FS_corr=Correlate(simu_FS,simu_FS,4)
end

Function ButtonProc_QPIESimu_getGMcut(ctrlName) : ButtonControl
	String ctrlName
	variable/G shape_hole_QPISIM
	variable/G shape_ele_QPISIM
	variable/G gap_hole_QPISIM
	variable/G gap_ele_QPISIM
	variable/G mu_hole_QPISIM
	variable/G mu_ele_QPISIM
	variable/G selfE_QPISIM
	variable/G sel_QPISIM
	variable/G save3D_QPISIM
	QPIESimu_getGMcut(shape_hole_QPISIM,shape_ele_QPISIM,mu_hole_QPISIM,mu_ele_QPISIM,gap_hole_QPISIM,gap_ele_QPISIM,selfE_QPISIM,sel_QPISIM)
end

Function QPIESimu_getGMcut(shape_hole,shape_ele,mu_hole,mu_ele,gap_hole,gap_ele,selfE,sel)
	variable shape_hole
	variable shape_ele
	variable gap_hole
	variable gap_ele
	variable mu_hole
	variable mu_ele
	variable selfE
	variable sel

	// Hole E > 0
	variable/G Mask_hole_p_E_Intens //= 0.15
	variable/G Mask_hole_p_E_FWHM //= 1
	variable/G Mask_hole_p_E_detune //= 0.5
	variable/G Mask_hole_p_k_Intens0 //= 0
	variable/G Mask_hole_p_k_Intens //= 0.8
	variable/G Mask_hole_p_k_FWHM //= 0.6

	// Hole E < 0
	variable/G Mask_hole_n_E_Intens //= 0.1
	variable/G Mask_hole_n_E_FWHM //= 1
	variable/G Mask_hole_n_E_detune //= 0.5
	variable/G Mask_hole_n_k_Intens0 //= 0
	variable/G Mask_hole_n_k_Intens //= 2.5
	variable/G Mask_hole_n_k_FWHM //= 5

	// electron E > 0
	variable/G Mask_ele_p_E_Intens //= 0
	variable/G Mask_ele_p_E_FWHM //= 1
	variable/G Mask_ele_p_E_detune //= 0.5
	variable/G Mask_ele_p_k_Intens0 //= 0.6
	variable/G Mask_ele_p_k_Intens //= 0
	variable/G Mask_ele_p_k_FWHM //= 5

	// electron E < 0
	variable/G Mask_ele_n_E_Intens //= 0
	variable/G Mask_ele_n_E_FWHM //= 1
	variable/G Mask_ele_n_E_detune //= 0.5
	variable/G Mask_ele_n_k_Intens0 //= 0.05
	variable/G Mask_ele_n_k_Intens //= 0
	variable/G Mask_ele_n_k_FWHM //= 0.6



	make/n=(200,200,150)/o simuband
	setscale/I x, -2*pi, 2*pi,"",simuband
	setscale/I y, -2*pi, 2*pi,"",simuband
	setscale/I z, -20, 20,"",simuband

//(sqrt(2)/2)*(x-y)

	if (sel == 1)
		//Normal state
			// Gamma hole pocket
				simuband= 1/((z+          (shape_hole*(1-cos((sqrt(2)/2)*(x-y)))+(shape_hole*(1-cos((sqrt(2)/2)*(x+y))))-mu_hole)         )^2+(selfE)^2)
			// M electron pocket
				simuband += 1/((z-        (shape_ele*(1-cos((sqrt(2)/2)*(x-y)+pi))+shape_ele*(1-cos((sqrt(2)/2)*(x+y)+pi))-mu_ele)               )^2+(selfE)^2)
	endif

	if (sel == 2)
		//SC hole band (Gamma)
	  		// Below EF (n)
				//spectral weight follow k
					simuband = (Mask_hole_n_k_Intens0+Mask_hole_n_k_Intens*(1-exp(-(2*(1-cos((sqrt(2)/2)*(x-y)))+2*(1-cos((sqrt(2)/2)*(x+y))))/(Mask_hole_n_k_FWHM/(2*sqrt(ln(2))))^2)))/((z+     sqrt((shape_hole*(1-cos((sqrt(2)/2)*(x-y)))+(shape_hole*(1-cos((sqrt(2)/2)*(x+y))))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
				//spectral weight follow E (add some around delta to enhance coherence peak)
					if (Mask_hole_n_E_Intens == 0)
					else
						simuband += Mask_hole_n_E_Intens*(exp(-(z+(gap_hole+Mask_hole_n_E_detune))^2/(Mask_hole_n_E_FWHM/(2*sqrt(ln(2))))^2))/((z+     sqrt((shape_hole*(1-cos((sqrt(2)/2)*(x-y)))+(shape_hole*(1-cos((sqrt(2)/2)*(x+y))))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
 	  				endif
 	  		// Above EF (p)
				//spectral weight follow k
					simuband += (Mask_hole_p_k_Intens0+Mask_hole_p_k_Intens*(exp(-(2*(1-cos((sqrt(2)/2)*(x-y)))+2*(1-cos((sqrt(2)/2)*(x+y))))/(Mask_hole_p_k_FWHM/(2*sqrt(ln(2))))^2)))/((z+     -sqrt((shape_hole*(1-cos((sqrt(2)/2)*(x-y)))+(shape_hole*(1-cos((sqrt(2)/2)*(x+y))))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
				//spectral weight follow E (add some around delta to enhance coherence peak)
					if (Mask_hole_p_E_Intens == 0)
					else
						simuband += Mask_hole_p_E_Intens*(exp(-(z-(gap_hole+Mask_hole_p_E_detune))^2/(Mask_hole_p_E_FWHM/(2*sqrt(ln(2))))^2))/((z+     -sqrt((shape_hole*(1-cos((sqrt(2)/2)*(x-y)))+(shape_hole*(1-cos((sqrt(2)/2)*(x+y))))-mu_hole)^2+gap_hole^2)         )^2+(selfE)^2)
					endif
		//electron band (M)
	  		// Below EF (n)
				//spectral weight follow k
					simuband += (Mask_ele_n_k_Intens0+Mask_ele_n_k_Intens*(exp(-(2*(1-cos((sqrt(2)/2)*(x-y)+pi))+2*(1-cos((sqrt(2)/2)*(x+y)+pi)))/(Mask_ele_n_k_FWHM/(2*sqrt(ln(2))))^2)))/((z-        -sqrt((shape_ele*(1-cos((sqrt(2)/2)*(x-y)+pi))+shape_ele*(1-cos((sqrt(2)/2)*(x+y)+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
				//spectral weight follow E (add some around delta to enhance coherence peak)
					if (Mask_ele_n_E_Intens == 0)
					else
						simuband += Mask_ele_n_E_Intens*(exp(-(z+(gap_ele+Mask_ele_n_E_detune))^2/(Mask_ele_n_E_FWHM/(2*sqrt(ln(2))))^2))/((z-        -sqrt((shape_ele*(1-cos((sqrt(2)/2)*(x-y)+pi))+shape_ele*(1-cos((sqrt(2)/2)*(x+y)+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
					endif

			// above EF
				//spectral weight follow k
					simuband += (Mask_ele_p_k_Intens0+Mask_ele_p_k_Intens*(1-exp(-(2*(1-cos((sqrt(2)/2)*(x-y)+pi))+2*(1-cos((sqrt(2)/2)*(x+y)+pi)))/(Mask_ele_p_k_FWHM/(2*sqrt(ln(2))))^2)))/((z-        sqrt((shape_ele*(1-cos((sqrt(2)/2)*(x-y)+pi))+shape_ele*(1-cos((sqrt(2)/2)*(x+y)+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
				//spectral weight follow E (add some around delta to enhance coherence peak)
					if (Mask_ele_p_E_Intens == 0)
					else
						simuband += Mask_ele_p_E_Intens*(exp(-(z-(gap_ele+Mask_ele_p_E_detune))^2/(Mask_ele_p_E_FWHM/(2*sqrt(ln(2))))^2))/((z-        sqrt((shape_ele*(1-cos((sqrt(2)/2)*(x-y)+pi))+shape_ele*(1-cos((sqrt(2)/2)*(x+y)+pi))-mu_ele)^2+gap_ele^2)               )^2+(selfE)^2)
					endif
	endif

	print "Finish bands Matrix"

	//Calculate QPI
		make/n=(2*dimsize(simuband,0)-1,2*dimsize(simuband,1)-1,dimsize(simuband,2))/o corrsimu
			//setscale/I z, -8, 8,"",corrsimu
		setscale/p z,dimoffset(simuband,2),dimdelta(simuband,2),"",corrsimu
		make/n=(dimsize(simuband,0),dimsize(simuband,1))/o slicesimuband
		setscale/I x, -2*pi, 2*pi,"",slicesimuband
		setscale/I y, -2*pi, 2*pi,"",slicesimuband
		variable i
		string aa
		i=0
		do
			slicesimuband[][] = simuband[p][q][i]
			MatrixOP/O slicesimuband_corr=Correlate(slicesimuband,slicesimuband,4)
			wave slicesimuband_corrw = $"slicesimuband_corr"

			corrsimu[][][i] = slicesimuband_corrw[p][q]

			i+=1
		while (i < dimsize(simuband,2))

	make/n=(dimsize(corrsimu,0),dimsize(corrsimu,2))/o corrsimu_GM
	setscale/I y, dimoffset(corrsimu,2),dimoffset(corrsimu,2)+dimdelta(corrsimu,2)*(dimsize(corrsimu,2)-1),"",corrsimu_GM
	setscale/I x, -2*pi,2*pi,"",corrsimu_GM
	variable j
	i=0
	do
		j=0
		do
			corrsimu_GM[i][j] = corrsimu[i][i][j]
			j+=1
		while (j<dimsize(corrsimu,2))
		i+=1
	while (i < dimsize(corrsimu,0))

	//duplicate/o corrsimu_GM simudisper_GM
	//display/N=Correlationresult_QPIsimu; appendimage corrsimu_GM
	di(corrsimu_GM)
	ModifyImage corrsimu_GM ctab= {*,*,VioletOrangeYellow,1};modifygraph width=550,height=300
	tilewindows/WINS=winname(0,1)/R/A=(1,1)/w=(49,0,70,20)

	string singlespectra = "sgsg_simuband"
	sumoned(singlespectra,"simuband",2)

	variable/G save3D_QPISIM
	if (save3D_QPISIM == 0)
		killwaves simuband corrsimu
	else
	endif
end

Function ButtonProc_appendQPIESimu_getGMcut(ctrlName) : ButtonControl
	String ctrlName
	wave corrsimu_GM=$"corrsimu_GM"
	duplicate/o corrsimu_GM simudisper_GM
end

Function ButtonProc_appendQPIESimu_getGMcut2(ctrlName) : ButtonControl
	String ctrlName
	wave simudisper_GM2=$"simudisper_GM2"
	duplicate/o simudisper_GM2 simudisper_GM
end



Function ButtonProc_LDOSQPIESimu(ctrlName) : ButtonControl
	String ctrlName
	string singlespectra = "sgsg_simuband"
		//sumoned(singlespectra,"simuband",2)

	wave aa = $singlespectra
	display aa
	SetAxis left 0,*
	Button turnoffQPISIM title="X",size={45,12},valueColor=(0,0,0),fColor=(1,65535,33232),proc=ButtonProc_lsturnoff3d
	tilewindows/WINS=winname(0,1)/R/A=(1,1)/w=(49.5,0,70,20)
end

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
// Simulation of stripes features on FFT image
Function ButtonProc_FFTstripesimulationc(ctrlName) : ButtonControl
	String ctrlName
	Execute "FFTstripesimulationc()"
end
Proc FFTstripesimulationc(p1,q1,p2,q2,scalex,scaley,b,sigma,h,hd)
	variable p1 = 1
	variable q1 = 1
	variable p2 = 198
	variable q2 = 198
	variable scalex = 10
	variable scaley = 10
	variable b = 0
	variable sigma = 0.1
	variable h = 100
	variable hd = 0
	prompt p1,"P for the 1st point" //= 1
	prompt q1,"Q for the 1st point"  //= 1
	prompt p2,"P for the 2nd point"  // = 198
	prompt q2,"Q for the 2nd point"  //= 198
	prompt scalex,"X length for the real space image"
	prompt scaley,"Y length for the real space image" //= 10
	prompt b, "Background intensity of image" //= 0
	prompt sigma, "Guassian noise sigma" //= 0.1
	prompt h, "Intensity of 1st/2nd points" //= 100
	prompt hd, "difference between st/2nd points" //= 0

	FFTstripesimulation(p1,q1,p2,q2,scalex,scaley,b,sigma,h,hd)
end

Function FFTstripesimulation(p1,q1,p2,q2,scalex,scaley,b,sigma,h,hd)
	variable p1 //= 1
	variable q1 //= 1
	variable p2 // = 198
	variable q2 //= 198
	variable scalex //= 10
	variable scaley //= 10
	variable b //= 0
	variable sigma //= 0.1
	variable h //= 100
	variable hd //= 0


	make/o/N=(200,200) FFTstripesimu
	setscale/I x,0,scalex,"",FFTstripesimu;
	setscale/I y,0,scaley,"",FFTstripesimu
	FFTstripesimu = b + gnoise(sigma)
	FFTstripesimu[p1][q1] = h
	FFTstripesimu[p2][q2] = h+hd

	FFT/out=3/DEST=FFTstripesimu_FFT cvtcmplx(FFTstripesimu)
	FFTstripesimu_FFT[100][100] = nan
	display/N=FFTstripesimu_FFTstripe;modifygraph width=1000,height=500;
	Display/HOST=#/W=(0,0.1,0.5,1);appendimage FFTstripesimu;ModifyGraph mirror=2;ModifyGraph width={Plan,1,bottom,left};ModifyImage FFTstripesimu ctab= {*,*,Grays,1};modifygraph width=400, height=400//ModifyImage FFTstripesimu ctab= {-3.14,3.14,RainbowCycle,0};;ColorScale/C/N=text0/F=0/B=1/A=RC/X=-20.00/Y=0.00 image=FFTstripesimu;ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;ColorScale/C/N=text0 frame=0.00//;Label bottom "\\Z16X          \t \t\t\t\t\t\t\t\tΓ\t\t\t\t\t\t\t\t\t          X"
	setActiveSubwindow ##;Display/HOST=#/W=(0.5,0.1,1,1);appendimage FFTstripesimu_FFT;ModifyGraph mirror=2;ModifyGraph width={Plan,1,bottom,left};modifygraph width=400, height=400//ModifyImage FFTstripesimu_FFT ctab= {-3.14,3.14,RainbowCycle,0};ModifyGraph width={Plan,1,bottom,left};ColorScale/C/N=text0/F=0/B=1/A=RC/X=-20.00/Y=0.00 image=FFTstripesimu_FFT;ModifyGraph nticks=0,noLabel=1;ModifyGraph axThick=2,standoff=0;ColorScale/C/N=text0 frame=0.00//;Label bottom "\\Z16M          \t \t\t\t\t\t\t\t\tΓ\t\t\t\t\t\t\t\t\t          M"
	setActiveSubwindow ##;


	variable/G p1_fftstripesimu = p1
	variable/G q1_fftstripesimu = q1
	variable/G p2_fftstripesimu = p2
	variable/G q2_fftstripesimu = q2
	variable/G scalex_fftstripesimu = scalex
	variable/G scaley_fftstripesimu = scaley
	variable/G b_fftstripesimu = b
	variable/G sigma_fftstripesimu = sigma
	variable/G h_fftstripesimu = h
	variable/G hd_fftstripesimu = hd


	SetVariable setv1 value=p1_fftstripesimu,proc=SetVarProc_FTstripesimu,limits={0,199,1},title="P1"//,pos={75,652},size={100,14}
	SetVariable setv2 value=q1_fftstripesimu,proc=SetVarProc_FTstripesimu,limits={0,199,1},title="Q1"//,pos={175,652},size={100,14}
	SetVariable setv3 value=p2_fftstripesimu,proc=SetVarProc_FTstripesimu,limits={0,199,1},title="P2"//,pos={275,652},size={100,14}
	SetVariable setv4 value=q2_fftstripesimu,proc=SetVarProc_FTstripesimu,limits={0,199,1},title="Q2"//,pos={375,652},size={100,14}
	SetVariable setv5 value=scalex_fftstripesimu,proc=SetVarProc_FTstripesimu,limits={0,INF,1},title="L(X)",size={70,14}//,pos={475,652},size={100,14}
	SetVariable setv6 value=scaley_fftstripesimu,proc=SetVarProc_FTstripesimu,limits={0,INF,1},title="L(Y)",size={70,14}//,pos={475,652},size={100,14}
	SetVariable setv7 value=b_fftstripesimu,proc=SetVarProc_FTstripesimu,limits={0,INF,0.1},title="Background",size={100,14},pos={398,1}//,pos={475,652},size={100,14}
	SetVariable setv8 value=sigma_fftstripesimu,proc=SetVarProc_FTstripesimu,limits={0,inf,0.1},title="σ(noise)",size={100,14},pos={501,1}//,pos={475,652},size={100,14}
	SetVariable setv9 value=h_fftstripesimu,proc=SetVarProc_FTstripesimu,limits={-inf,inf,1},title="Peak height",size={100,14},pos={609,1}//,pos={475,652},size={100,14}
	SetVariable setv10 value=hd_fftstripesimu,proc=SetVarProc_FTstripesimu,limits={-inf,inf,1},title="Peak difference",size={120,14},pos={712,1}//,pos={475,652},size={100,14}

	Button turnoffls3d title="BACK",size={45,12},valueColor=(0,0,0),fColor=(1,65535,33232),pos={942,3},proc=ButtonProc_lsturnoff3d

	TextBox/C/N=text0/A=LT/X=20/Y=8/F=0 "Real space image"
	TextBox/C/N=text1/A=RT/X=20/Y=8/F=0 "FFT"
end

Function SetVarProc_FTstripesimu(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G p1_fftstripesimu //= p1
	variable/G q1_fftstripesimu //= q1
	variable/G p2_fftstripesimu //= p2
	variable/G q2_fftstripesimu //= q2
	variable/G scalex_fftstripesimu //= scalex
	variable/G scaley_fftstripesimu //= scaley
	variable/G b_fftstripesimu //= b
	variable/G sigma_fftstripesimu //= sigma
	variable/G h_fftstripesimu //= h
	variable/G hd_fftstripesimu //= hd
	FFTstripesimulation_cons(p1_fftstripesimu,q1_fftstripesimu,p2_fftstripesimu,q2_fftstripesimu,scalex_fftstripesimu,scaley_fftstripesimu,b_fftstripesimu,sigma_fftstripesimu,h_fftstripesimu,hd_fftstripesimu)
end


Function FFTstripesimulation_cons(p1,q1,p2,q2,scalex,scaley,b,sigma,h,hd)
	variable p1,q1,p2,q2,scalex,scaley,b,sigma,h,hd
	make/o/N=(200,200) FFTstripesimu
	setscale/I x,0,scalex,"",FFTstripesimu;
	setscale/I y,0,scaley,"",FFTstripesimu
	FFTstripesimu = b + gnoise(sigma)
	FFTstripesimu[p1][q1] = h
	FFTstripesimu[p2][q2] = h+hd

	FFT/out=3/DEST=FFTstripesimu_FFT cvtcmplx(FFTstripesimu)
	FFTstripesimu_FFT[100][100] = nan

end


/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
//Simulation for NbSe2 STM data, Science 372,1447 (2021)
Function ButtonProc_simuCDWc(ctrlName) : ButtonControl
	String ctrlName
	Execute "simuCDWc()"
end

Proc simuCDWc(theta,wLength,c1,c2,c3)
	variable theta = 40
	variable wLength = 3
	variable c1 = 1.5
	variable c2 = 1
	variable c3 = 1
	Prompt theta,"Latticfe angle˚"
	prompt wLength,"Lattice constant"
	prompt c1,"Phase shift of Q1 (c1*2π/3)"
	prompt c2,"Phase shift of Q2 (c2*2π/3)"
	prompt c3,"Phase shift of Q3 (c3*2π/3)"
	//variable p1 = 0.5
	//variable p2 = 0
	//variable p3 = 0
	simuCDW(1,theta,wLength,c1,c2,c3)
	display/N=CDWPDWsimulatorforNbSe2;modifygraph width=1200,height=800
	Display/HOST=#/W=(0,0.1,0.3,0.4);appendimage simuCDWLattice;
		modifygraph width=300,height=300;ModifyGraph nticks=0,noLabel=2,axThick=2,standoff=0,mirror=2;
		ModifyGraph margin(right)=72;ColorScale/C/N=text0/F=0/A=RC/X=-23/Y=0 image=simuCDWLattice;ColorScale/C/N=text0 frame=0.00
		ModifyImage simuCDWLattice ctab= {*,*,:Packages:NewColortable:XLiu_T,0}
		ColorScale/C/N=text0/A=LC/X=101/Y=0/F=0 frame=0.00,image=$nameofwave(simuCDWLattice)
	setActiveSubwindow ##;
	Display/HOST=#/W=(0.33,0.1,0.63,0.4);appendimage simuCDWL1;
		modifygraph width=300,height=300;ModifyGraph nticks=0,noLabel=2,axThick=2,standoff=0,mirror=2;
		ModifyGraph margin(right)=72;ColorScale/C/N=text0/F=0/A=RC/X=-23/Y=0 image=simuCDWL1;ColorScale/C/N=text0 frame=0.00
		ModifyImage simuCDWL1 ctab= {*,*,:Packages:NewColortable:XLiu_G,0}
		ColorScale/C/N=text0/A=LC/X=101/Y=0/F=0 frame=0.00,image=$nameofwave(simuCDWL1)
	setActiveSubwindow ##;
	Display/HOST=#/W=(0.66,0.1,0.96,0.4);appendimage simuCDWL2;
		modifygraph width=300,height=300;ModifyGraph nticks=0,noLabel=2,axThick=2,standoff=0,mirror=2;
		ModifyGraph margin(right)=72;ColorScale/C/N=text0/F=0/A=RC/X=-23/Y=0 image=simuCDWL2;ColorScale/C/N=text0 frame=0.00
		ModifyImage simuCDWL2 ctab= {*,*,:Packages:NewColortable:XLiu_gap,0}
		ColorScale/C/N=text0/A=LC/X=101/Y=0/F=0 frame=0.00,image=$nameofwave(simuCDWL2)

	setActiveSubwindow ##;
	Display/HOST=#/W=(0.33,0.55,0.63,0.85);appendimage simuCDWCDW;
		modifygraph width=300,height=300;ModifyGraph nticks=0,noLabel=2,axThick=2,standoff=0,mirror=2;
		ModifyGraph margin(right)=72;ColorScale/C/N=text0/F=0/A=RC/X=-23/Y=0 image=simuCDWCDW;ColorScale/C/N=text0 frame=0.00
		ModifyImage simuCDWCDW ctab= {*,*,:Packages:NewColortable:XLiu_G,0}
		ColorScale/C/N=text0/A=LC/X=101/Y=0/F=0 frame=0.00,image=$nameofwave(simuCDWCDW)

	setActiveSubwindow ##;
	Display/HOST=#/W=(0.66,0.55,0.96,0.85);appendimage simuCDWPDW;
		modifygraph width=300,height=300;ModifyGraph nticks=0,noLabel=2,axThick=2,standoff=0,mirror=2;
		ModifyGraph margin(right)=72;ColorScale/C/N=text0/F=0/A=RC/X=-23/Y=0 image=simuCDWPDW;ColorScale/C/N=text0 frame=0.00
		ModifyImage simuCDWPDW ctab= {*,*,:Packages:NewColortable:XLiu_gap,0}
		ColorScale/C/N=text0/A=LC/X=101/Y=0/F=0 frame=0.00,image=$nameofwave(simuCDWPDW)
	setActiveSubwindow ##;


	TextBox/C/N=text0/B=1/A=MT/F=0/X=0.00/Y=0.00 "Simulation of CDW & PDW on \\$WMTEX${\\rm NbSe}_{2} \\$/WMTEX$ [Science 372,1447 (2021)]"
	TextBox/C/N=text1/F=0/B=1/A=LT/x=12/y=9 "\\Z15\\$WMTEX$ T(r) \\$/WMTEX$: Se lattice"
	TextBox/C/N=text2/F=0/B=1/A=LT/x=45/y=9 "\\Z15\\$WMTEX$ N_{Q}(r) \\$/WMTEX$: Total CDW"
	TextBox/C/N=text3/F=0/B=1/A=LT/x=78/y=9 "\\Z15\\$WMTEX$ N_{\rm CP}(r) \\$/WMTEX$: Total PDW"
	TextBox/C/N=text4/F=0/B=1/A=LT/x=44/y=54 "\\Z15\\$WMTEX$ N_{\rm C}(r) \\$/WMTEX$: Filtered CDW"
	TextBox/C/N=text5/F=0/B=1/A=LT/x=77/y=54 "\\Z15\\$WMTEX$ N_{\rm P}(r) \\$/WMTEX$: Filtered PDW"
	TextBox/C/N=text6/F=0/B=1/A=LT/X=5/Y=70 "We set: \\$WMTEX$ \\phi_{i}^{CDW} -\\phi_{i}^{PDW} =\\frac{2\\pi}{3} \\$/WMTEX$ \r                                  \Z14for i = 1,2,3 "
	Button turnoffls3d title="BACK",size={45,12},valueColor=(0,0,0),fColor=(1,65535,33232),proc=ButtonProc_lsturnoff3d,pos={1150,5}

	variable/G theta_NbSe2simu=theta //= 45
	variable/G wLength_NbSe2simu=wLength //= 3
	variable/G c1_NbSe2simu=c1 //= 1.5
	variable/G c2_NbSe2simu=c2 //= 1
	variable/G c3_NbSe2simu=c3 //= 1
	SetVariable setv1 value=theta_NbSe2simu,proc=SetVarProc_NbSe2simu,limits={-180,180,1},title="\\$WMTEX$ \theta \\$/WMTEX$"//,pos={75,652},size={100,14}
	SetVariable setv2 value=wLength_NbSe2simu,proc=SetVarProc_NbSe2simu,limits={0,inf,1},title="\\$WMTEX$ a_{0} \\$/WMTEX$ (Å)",size={70,14}//,pos={75,652},size={100,14}
	SetVariable setv3 value=c1_NbSe2simu,proc=SetVarProc_NbSe2simu,limits={0,3,0.1},title="C1 phase shift of \\$WMTEX$ Q_{1} \\$/WMTEX$ (2π/3)",size={180,14}//,pos={75,652},size={100,14}
	SetVariable setv4 value=c2_NbSe2simu,proc=SetVarProc_NbSe2simu,limits={0,3,0.1},title="C2 phase shift of \\$WMTEX$ Q_{2} \\$/WMTEX$ (2π/3)",size={180,14}//,pos={75,652},size={100,14}
	SetVariable setv5 value=c3_NbSe2simu,proc=SetVarProc_NbSe2simu,limits={0,3,0.1},title="C3 phase shift of \\$WMTEX$ Q_{3} \\$/WMTEX$ (2π/3)",size={180,14}//,pos={75,652},size={100,14}
	SetVariable setv1 pos={509,30}
	SetVariable setv2 pos={569,30}
	SetVariable setv3 pos={297,50}
	SetVariable setv4 pos={487,50}
	SetVariable setv5 pos={677,50}
end

Function SetVarProc_NbSe2simu(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G theta_NbSe2simu//=theta //= 45
	variable/G wLength_NbSe2simu//=wLength //= 3
	variable/G c1_NbSe2simu//=c1 //= 1.5
	variable/G c2_NbSe2simu//=c2 //= 1
	variable/G c3_NbSe2simu//=c3
	simuCDW(1,theta_NbSe2simu,wLength_NbSe2simu,c1_NbSe2simu,c2_NbSe2simu,c3_NbSe2simu)
end

Function simuCDW(A1,theta,wLength,c1,c2,c3)
	variable A1,theta,wLength,c1,c2,c3//,p1,p2,p3
	make/N=(300,300)/o simuCDWLattice
	make/N=(300,300)/o simuCDWCDW
	make/N=(300,300)/o simuCDWPDW

	setscale/I x,-150,150,"",simuCDWLattice
	setscale/I y,-150,150,"",simuCDWLattice
	setscale/I x,-150,150,"",simuCDWCDW
	setscale/I y,-150,150,"",simuCDWCDW
	setscale/I x,-150,150,"",simuCDWPDW
	setscale/I y,-150,150,"",simuCDWPDW
	variable A2,A3
	A2 = A1
	A3 = A1

	//Lattice
	simuCDWLattice=A1*cos((2*pi/wLength)*(cos(theta*pi/180)*x+sin(theta*pi/180)*y));
	simuCDWLattice+=A2*cos((2*pi/wLength)*(cos((60+theta)*pi/180)*x+sin((60+theta)*pi/180)*y));
	simuCDWLattice+=A3*cos((2*pi/wLength)*(cos((120+theta)*pi/180)*x+sin((120+theta)*pi/180)*y));


	//CDW
	simuCDWCDW= A1*cos((2*pi/(3*wLength))*(cos(theta*pi/180)*x+sin(theta*pi/180)*y)+c1*2*pi/3)
	simuCDWCDW+= A2*cos((2*pi/(3*wLength))*(cos((60+theta)*pi/180)*x+sin((60+theta)*pi/180)*y)+c2*2*pi/3)
	simuCDWCDW+= A3*cos((2*pi/(3*wLength))*(cos((120+theta)*pi/180)*x+sin((120+theta)*pi/180)*y)+c3*2*pi/3)

	//PDW
	simuCDWPDW= A1*cos((2*pi/(3*wLength))*(cos(theta*pi/180)*x+sin(theta*pi/180)*y)+(c1-1)*2*pi/3)
	simuCDWPDW+= A2*cos((2*pi/(3*wLength))*(cos((60+theta)*pi/180)*x+sin((60+theta)*pi/180)*y)+(c2-1)*2*pi/3)
	simuCDWPDW+= A3*cos((2*pi/(3*wLength))*(cos((120+theta)*pi/180)*x+sin((120+theta)*pi/180)*y)+(c3-1)*2*pi/3)

	make/N=(300,300)/o simuCDWL1,simuCDWL2
	setscale/I x,-150,150,"",simuCDWL1,simuCDWL2
	setscale/I y,-150,150,"",simuCDWL1,simuCDWL2
	simuCDWL1=simuCDWLattice+simuCDWCDW
	simuCDWL2=simuCDWLattice+simuCDWPDW


end


/////////////////////////////////////////////////////////////////////////////////////////////
// Plot the 3D surface Gizmo for the 1UC-FeSe gap distribution.
// Gap function is from ref: https://journals.aps.org/prl/abstract/10.1103/PhysRevLett.117.117001
Function ButtonProc_oneUCFeSegapsimu(ctrlName) : ButtonControl
	String ctrlName
	Execute "oneUCFeSegapsimu()"
end
Proc oneUCFeSegapsimu()
	makegap1UCFeSe()
	di(gap1UCFeSe)
	NewGizmo; AppendToGizmo defaultSurface=root:gap1UCFeSe
	ModifyGizmo stopUpdates
	ModifyGizmo ModifyObject=surface0,objectType=surface,property={ surfaceCTab,VioletOrangeYellow}
	ModifyGizmo ModifyObject=surface0,objectType=surface,property={ SurfaceCTABScaling,96}
	ModifyGizmo ModifyObject=surface0,objectType=surface,property={ surfaceMinRGBA,7,0.666667,0.666667,0.666667,1}
	ModifyGizmo ModifyObject=surface0,objectType=surface,property={ surfaceMaxRGBA,14,2.36943e-38,2.36943e-38,2.36943e-38,1}
	ModifyGizmo resumeUpdates

	makegap1UCFeSed()
	di(gap1UCFeSed)
	NewGizmo; AppendToGizmo defaultSurface=root:gap1UCFeSed
	ModifyGizmo stopUpdates
	ModifyGizmo ModifyObject=surface0,objectType=surface,property={ surfaceCTab,RedWhiteBlue256}
	ModifyGizmo ModifyObject=surface0,objectType=surface,property={ SurfaceCTABScaling,96}
	ModifyGizmo ModifyObject=surface0,objectType=surface,property={ surfaceMinRGBA,-13,0,0,0,1}
	ModifyGizmo ModifyObject=surface0,objectType=surface,property={ surfaceMaxRGBA,13,2.36943e-38,2.36943e-38,2.36943e-38,1}
	ModifyGizmo resumeUpdates



	makegap1UCFeSebabs()
	di(gap1UCFeSebabs)
	NewGizmo; AppendToGizmo defaultSurface=root:gap1UCFeSebabs
	ModifyGizmo stopUpdates
	ModifyGizmo ModifyObject=surface0,objectType=surface,property={ surfaceCTab,RedWhiteBlue256}
	ModifyGizmo ModifyObject=surface0,objectType=surface,property={ SurfaceCTABScaling,96}
	ModifyGizmo ModifyObject=surface0,objectType=surface,property={ surfaceMinRGBA,-13,0,0,0,1}
	ModifyGizmo ModifyObject=surface0,objectType=surface,property={ surfaceMaxRGBA,13,2.36943e-38,2.36943e-38,2.36943e-38,1}
	ModifyGizmo resumeUpdates
end

Function makegap1UCFeSe()
	variable theta, a, b, gg, num
	num = 6000
	a = 5
	b = 9
	gg = 0.1


	make/n=(150,150)/o gap1UCFeSe
	setscale/I x,-10,10,"",gap1UCFeSe
	setscale/I y,-10,10,"",gap1UCFeSe

	gap1UCFeSe = 0
	wave gap1UCFeSew = $"gap1UCFeSe"



	//make/N=100/o xxrecord
	//make/N=100/o yyrecord
	//wave xxrecordw = $"xxrecord"
	//wave yyrecordw = $"yyrecord"
	variable i, xx, yy, pp, qq

	variable gapsize

	/// ellispe #1

	i=-num*pi/(2*2*pi)
	do
		theta = i*2*pi/num

		gapsize = 9.98-1.24*cos(2*theta)+1.15*cos(4*theta)

		if (theta > -pi/2 && theta < pi/2)
			xx = a*b/(sqrt(b^2+a^2*(tan(theta))^2))
			yy = a*b*(tan(theta))/(sqrt(b^2+a^2*(tan(theta))^2))

			//xxrecordw[i+25] = pp
			//yyrecordw[i+25] = qq



			pp = round((xx-dimoffset(gap1UCFeSew,0))/dimdelta(gap1UCFeSew,0))
			qq = round((yy-dimoffset(gap1UCFeSew,1))/dimdelta(gap1UCFeSew,1))
			gap1UCFeSew[pp][qq] = gapsize
			//gap1UCFeSe+= gg/((x-xx)^2+(y-yy)^2+gg^2)

		endif

		if (theta > pi/2 && theta < 3*pi/2)
			xx = -a*b/(sqrt(b^2+a^2*(tan(theta))^2))
			yy = -a*b*(tan(theta))/(sqrt(b^2+a^2*(tan(theta))^2))

			//xxrecordw[i+25] = pp
			//yyrecordw[i+25] = qq

			pp = round((xx-dimoffset(gap1UCFeSew,0))/dimdelta(gap1UCFeSew,0))
			qq = round((yy-dimoffset(gap1UCFeSew,1))/dimdelta(gap1UCFeSew,1))
			gap1UCFeSew[pp][qq] = gapsize
			//gap1UCFeSe+= gg/((x-xx)^2+(y-yy)^2+gg^2)

		endif

		if (theta == -pi/2)
			xx = 0
			yy = -b

			//xxrecordw[i+25] = pp
			//yyrecordw[i+25] = qq

			pp = round((xx-dimoffset(gap1UCFeSew,0))/dimdelta(gap1UCFeSew,0))
			qq = round((yy-dimoffset(gap1UCFeSew,1))/dimdelta(gap1UCFeSew,1))
			gap1UCFeSew[pp][qq] = gapsize
			//gap1UCFeSe+= gg/((x-xx)^2+(y-yy)^2+gg^2)

		endif

		if (theta == pi/2)
			xx = 0
			yy = b

			//xxrecordw[i+25] = pp
			//yyrecordw[i+25] = qq

			pp = round((xx-dimoffset(gap1UCFeSew,0))/dimdelta(gap1UCFeSew,0))
			qq = round((yy-dimoffset(gap1UCFeSew,1))/dimdelta(gap1UCFeSew,1))
			gap1UCFeSew[pp][qq] = gapsize
			//gap1UCFeSe+= gg/((x-xx)^2+(y-yy)^2+gg^2)

		endif
		//print theta

		i+=1
	while (i<3*num*pi/(2*2*pi))



	/// ellispe #2

	i=-num*pi/(2*2*pi)
	do
		theta = i*2*pi/num

		gapsize = 9.98-1.24*cos(2*(theta+pi/2))+1.15*cos(4*(theta+pi/2))

		if (theta > -pi/2 && theta < pi/2)
			xx = a*b/(sqrt(a^2+b^2*(tan(theta))^2))
			yy = a*b*(tan(theta))/(sqrt(a^2+b^2*(tan(theta))^2))

			//xxrecordw[i+25] = pp
			//yyrecordw[i+25] = qq



			pp = round((xx-dimoffset(gap1UCFeSew,0))/dimdelta(gap1UCFeSew,0))
			qq = round((yy-dimoffset(gap1UCFeSew,1))/dimdelta(gap1UCFeSew,1))
			gap1UCFeSew[pp][qq] = gapsize
			//gap1UCFeSe+= gg/((x-xx)^2+(y-yy)^2+gg^2)

		endif

		if (theta > pi/2 && theta < 3*pi/2)
			xx = -a*b/(sqrt(a^2+b^2*(tan(theta))^2))
			yy = -a*b*(tan(theta))/(sqrt(a^2+b^2*(tan(theta))^2))

			//xxrecordw[i+25] = pp
			//yyrecordw[i+25] = qq

			pp = round((xx-dimoffset(gap1UCFeSew,0))/dimdelta(gap1UCFeSew,0))
			qq = round((yy-dimoffset(gap1UCFeSew,1))/dimdelta(gap1UCFeSew,1))
			gap1UCFeSew[pp][qq] = gapsize
			//gap1UCFeSe+= gg/((x-xx)^2+(y-yy)^2+gg^2)

		endif

		if (theta == -pi/2)
			xx = 0
			yy = -a

			//xxrecordw[i+25] = pp
			//yyrecordw[i+25] = qq

			pp = round((xx-dimoffset(gap1UCFeSew,0))/dimdelta(gap1UCFeSew,0))
			qq = round((yy-dimoffset(gap1UCFeSew,1))/dimdelta(gap1UCFeSew,1))
			gap1UCFeSew[pp][qq] = gapsize
			//gap1UCFeSe+= gg/((x-xx)^2+(y-yy)^2+gg^2)

		endif

		if (theta == pi/2)
			xx = 0
			yy = a

			//xxrecordw[i+25] = pp
			//yyrecordw[i+25] = qq

			pp = round((xx-dimoffset(gap1UCFeSew,0))/dimdelta(gap1UCFeSew,0))
			qq = round((yy-dimoffset(gap1UCFeSew,1))/dimdelta(gap1UCFeSew,1))
			gap1UCFeSew[pp][qq] = gapsize
			//gap1UCFeSe+= gg/((x-xx)^2+(y-yy)^2+gg^2)

		endif
		//print theta

		i+=1
	while (i<3*num*pi/(2*2*pi))

end



Function makegap1UCFeSed()
	variable theta, a, b, gg, num
	num = 6000
	a = 5
	b = 9
	gg = 0.1


	make/n=(150,150)/o gap1UCFeSed
	setscale/I x,-10,10,"",gap1UCFeSed
	setscale/I y,-10,10,"",gap1UCFeSed

	gap1UCFeSed = 0
	wave gap1UCFeSedw = $"gap1UCFeSed"



	//make/N=100/o xxrecord
	//make/N=100/o yyrecord
	//wave xxrecordw = $"xxrecord"
	//wave yyrecordw = $"yyrecord"
	variable i, xx, yy, pp, qq

	variable gapsize

	/// ellispe #1

	i=-num*pi/(2*2*pi)
	do
		theta = i*2*pi/num

		gapsize = 9.98-1.24*cos(2*theta)+1.15*cos(4*theta)

		if (theta > -pi/2 && theta < pi/2)
			xx = a*b/(sqrt(b^2+a^2*(tan(theta))^2))
			yy = a*b*(tan(theta))/(sqrt(b^2+a^2*(tan(theta))^2))

			//xxrecordw[i+25] = pp
			//yyrecordw[i+25] = qq



			pp = round((xx-dimoffset(gap1UCFeSedw,0))/dimdelta(gap1UCFeSedw,0))
			qq = round((yy-dimoffset(gap1UCFeSedw,1))/dimdelta(gap1UCFeSedw,1))
			gap1UCFeSedw[pp][qq] = gapsize
			//gap1UCFeSed+= gg/((x-xx)^2+(y-yy)^2+gg^2)

		endif

		if (theta > pi/2 && theta < 3*pi/2)
			xx = -a*b/(sqrt(b^2+a^2*(tan(theta))^2))
			yy = -a*b*(tan(theta))/(sqrt(b^2+a^2*(tan(theta))^2))

			//xxrecordw[i+25] = pp
			//yyrecordw[i+25] = qq

			pp = round((xx-dimoffset(gap1UCFeSedw,0))/dimdelta(gap1UCFeSedw,0))
			qq = round((yy-dimoffset(gap1UCFeSedw,1))/dimdelta(gap1UCFeSedw,1))
			gap1UCFeSedw[pp][qq] = gapsize
			//gap1UCFeSed+= gg/((x-xx)^2+(y-yy)^2+gg^2)

		endif

		if (theta == -pi/2)
			xx = 0
			yy = -b

			//xxrecordw[i+25] = pp
			//yyrecordw[i+25] = qq

			pp = round((xx-dimoffset(gap1UCFeSedw,0))/dimdelta(gap1UCFeSedw,0))
			qq = round((yy-dimoffset(gap1UCFeSedw,1))/dimdelta(gap1UCFeSedw,1))
			gap1UCFeSedw[pp][qq] = gapsize
			//gap1UCFeSed+= gg/((x-xx)^2+(y-yy)^2+gg^2)

		endif

		if (theta == pi/2)
			xx = 0
			yy = b

			//xxrecordw[i+25] = pp
			//yyrecordw[i+25] = qq

			pp = round((xx-dimoffset(gap1UCFeSedw,0))/dimdelta(gap1UCFeSedw,0))
			qq = round((yy-dimoffset(gap1UCFeSedw,1))/dimdelta(gap1UCFeSedw,1))
			gap1UCFeSedw[pp][qq] = gapsize
			//gap1UCFeSed+= gg/((x-xx)^2+(y-yy)^2+gg^2)

		endif
		//print theta

		i+=1
	while (i<3*num*pi/(2*2*pi))



	/// ellispe #2

	i=-num*pi/(2*2*pi)
	do
		theta = i*2*pi/num

		gapsize = -(9.98-1.24*cos(2*(theta+pi/2))+1.15*cos(4*(theta+pi/2)))

		if (theta > -pi/2 && theta < pi/2)
			xx = a*b/(sqrt(a^2+b^2*(tan(theta))^2))
			yy = a*b*(tan(theta))/(sqrt(a^2+b^2*(tan(theta))^2))

			//xxrecordw[i+25] = pp
			//yyrecordw[i+25] = qq



			pp = round((xx-dimoffset(gap1UCFeSedw,0))/dimdelta(gap1UCFeSedw,0))
			qq = round((yy-dimoffset(gap1UCFeSedw,1))/dimdelta(gap1UCFeSedw,1))
			gap1UCFeSedw[pp][qq] = gapsize
			//gap1UCFeSed+= gg/((x-xx)^2+(y-yy)^2+gg^2)

		endif

		if (theta > pi/2 && theta < 3*pi/2)
			xx = -a*b/(sqrt(a^2+b^2*(tan(theta))^2))
			yy = -a*b*(tan(theta))/(sqrt(a^2+b^2*(tan(theta))^2))

			//xxrecordw[i+25] = pp
			//yyrecordw[i+25] = qq

			pp = round((xx-dimoffset(gap1UCFeSedw,0))/dimdelta(gap1UCFeSedw,0))
			qq = round((yy-dimoffset(gap1UCFeSedw,1))/dimdelta(gap1UCFeSedw,1))
			gap1UCFeSedw[pp][qq] = gapsize
			//gap1UCFeSed+= gg/((x-xx)^2+(y-yy)^2+gg^2)

		endif

		if (theta == -pi/2)
			xx = 0
			yy = -a

			//xxrecordw[i+25] = pp
			//yyrecordw[i+25] = qq

			pp = round((xx-dimoffset(gap1UCFeSedw,0))/dimdelta(gap1UCFeSedw,0))
			qq = round((yy-dimoffset(gap1UCFeSedw,1))/dimdelta(gap1UCFeSedw,1))
			gap1UCFeSedw[pp][qq] = gapsize
			//gap1UCFeSed+= gg/((x-xx)^2+(y-yy)^2+gg^2)

		endif

		if (theta == pi/2)
			xx = 0
			yy = a

			//xxrecordw[i+25] = pp
			//yyrecordw[i+25] = qq

			pp = round((xx-dimoffset(gap1UCFeSedw,0))/dimdelta(gap1UCFeSedw,0))
			qq = round((yy-dimoffset(gap1UCFeSedw,1))/dimdelta(gap1UCFeSedw,1))
			gap1UCFeSedw[pp][qq] = gapsize
			//gap1UCFeSed+= gg/((x-xx)^2+(y-yy)^2+gg^2)

		endif
		//print theta

		i+=1
	while (i<3*num*pi/(2*2*pi))

end


Function makegap1UCFeSebabs()
	variable theta, a, b, gg, num
	num = 6000
	a = 5
	b = 9
	gg = 0.1


	make/n=(150,150)/o gap1UCFeSebabs
	setscale/I x,-10,10,"",gap1UCFeSebabs
	setscale/I y,-10,10,"",gap1UCFeSebabs

	gap1UCFeSebabs = 0
	wave gap1UCFeSebabsw = $"gap1UCFeSebabs"



	//make/N=100/o xxrecord
	//make/N=100/o yyrecord
	//wave xxrecordw = $"xxrecord"
	//wave yyrecordw = $"yyrecord"
	variable i, xx, yy, pp, qq

	variable gapsize

	/// ellispe #1

	i=-num*pi/(2*2*pi)
	do
		theta = i*2*pi/num

		gapsize = 9.98-1.24*cos(2*theta)+1.15*cos(4*theta)

		if (theta > -pi/4 && theta < pi/4)
				gapsize*=-1
		endif
		if (theta > 3*pi/4 && theta < 5*pi/4)
				gapsize*=-1
		endif





		if (theta > -pi/2 && theta < pi/2)
			xx = a*b/(sqrt(b^2+a^2*(tan(theta))^2))
			yy = a*b*(tan(theta))/(sqrt(b^2+a^2*(tan(theta))^2))

			//xxrecordw[i+25] = pp
			//yyrecordw[i+25] = qq



			pp = round((xx-dimoffset(gap1UCFeSebabsw,0))/dimdelta(gap1UCFeSebabsw,0))
			qq = round((yy-dimoffset(gap1UCFeSebabsw,1))/dimdelta(gap1UCFeSebabsw,1))
			gap1UCFeSebabsw[pp][qq] = gapsize
			//gap1UCFeSebabs+= gg/((x-xx)^2+(y-yy)^2+gg^2)




		endif

		if (theta > pi/2 && theta < 3*pi/2)
			xx = -a*b/(sqrt(b^2+a^2*(tan(theta))^2))
			yy = -a*b*(tan(theta))/(sqrt(b^2+a^2*(tan(theta))^2))

			//xxrecordw[i+25] = pp
			//yyrecordw[i+25] = qq

			pp = round((xx-dimoffset(gap1UCFeSebabsw,0))/dimdelta(gap1UCFeSebabsw,0))
			qq = round((yy-dimoffset(gap1UCFeSebabsw,1))/dimdelta(gap1UCFeSebabsw,1))
			gap1UCFeSebabsw[pp][qq] = gapsize
			//gap1UCFeSebabs+= gg/((x-xx)^2+(y-yy)^2+gg^2)



		endif

		if (theta == -pi/2)
			xx = 0
			yy = -b

			//xxrecordw[i+25] = pp
			//yyrecordw[i+25] = qq

			pp = round((xx-dimoffset(gap1UCFeSebabsw,0))/dimdelta(gap1UCFeSebabsw,0))
			qq = round((yy-dimoffset(gap1UCFeSebabsw,1))/dimdelta(gap1UCFeSebabsw,1))
			gap1UCFeSebabsw[pp][qq] = gapsize
			//gap1UCFeSebabs+= gg/((x-xx)^2+(y-yy)^2+gg^2)

		endif

		if (theta == pi/2)
			xx = 0
			yy = b

			//xxrecordw[i+25] = pp
			//yyrecordw[i+25] = qq

			pp = round((xx-dimoffset(gap1UCFeSebabsw,0))/dimdelta(gap1UCFeSebabsw,0))
			qq = round((yy-dimoffset(gap1UCFeSebabsw,1))/dimdelta(gap1UCFeSebabsw,1))
			gap1UCFeSebabsw[pp][qq] = gapsize
			//gap1UCFeSebabs+= gg/((x-xx)^2+(y-yy)^2+gg^2)

		endif
		//print theta

		i+=1
	while (i<3*num*pi/(2*2*pi))



	/// ellispe #2

	i=-num*pi/(2*2*pi)
	do
		theta = i*2*pi/num

		gapsize = 9.98-1.24*cos(2*(theta+pi/2))+1.15*cos(4*(theta+pi/2))
		if (theta > pi/4 && theta < 3*pi/4)
				gapsize*=-1
		endif

		if (theta > -pi/2 && theta < -pi/4)
				gapsize*=-1
		endif
		if (theta > 5*pi/4 && theta < 6*pi/4)
				gapsize*=-1
		endif


		if (theta > -pi/2 && theta < pi/2)
			xx = a*b/(sqrt(a^2+b^2*(tan(theta))^2))
			yy = a*b*(tan(theta))/(sqrt(a^2+b^2*(tan(theta))^2))

			//xxrecordw[i+25] = pp
			//yyrecordw[i+25] = qq



			pp = round((xx-dimoffset(gap1UCFeSebabsw,0))/dimdelta(gap1UCFeSebabsw,0))
			qq = round((yy-dimoffset(gap1UCFeSebabsw,1))/dimdelta(gap1UCFeSebabsw,1))
			gap1UCFeSebabsw[pp][qq] = gapsize
			//gap1UCFeSebabs+= gg/((x-xx)^2+(y-yy)^2+gg^2)



		endif

		if (theta > pi/2 && theta < 3*pi/2)
			xx = -a*b/(sqrt(a^2+b^2*(tan(theta))^2))
			yy = -a*b*(tan(theta))/(sqrt(a^2+b^2*(tan(theta))^2))

			//xxrecordw[i+25] = pp
			//yyrecordw[i+25] = qq

			pp = round((xx-dimoffset(gap1UCFeSebabsw,0))/dimdelta(gap1UCFeSebabsw,0))
			qq = round((yy-dimoffset(gap1UCFeSebabsw,1))/dimdelta(gap1UCFeSebabsw,1))
			gap1UCFeSebabsw[pp][qq] = gapsize
			//gap1UCFeSebabs+= gg/((x-xx)^2+(y-yy)^2+gg^2)



		endif

		if (theta == -pi/2)
			xx = 0
			yy = -a

			//xxrecordw[i+25] = pp
			//yyrecordw[i+25] = qq

			pp = round((xx-dimoffset(gap1UCFeSebabsw,0))/dimdelta(gap1UCFeSebabsw,0))
			qq = round((yy-dimoffset(gap1UCFeSebabsw,1))/dimdelta(gap1UCFeSebabsw,1))
			gap1UCFeSebabsw[pp][qq] = gapsize
			//gap1UCFeSebabs+= gg/((x-xx)^2+(y-yy)^2+gg^2)

		endif

		if (theta == pi/2)
			xx = 0
			yy = a

			//xxrecordw[i+25] = pp
			//yyrecordw[i+25] = qq

			pp = round((xx-dimoffset(gap1UCFeSebabsw,0))/dimdelta(gap1UCFeSebabsw,0))
			qq = round((yy-dimoffset(gap1UCFeSebabsw,1))/dimdelta(gap1UCFeSebabsw,1))
			gap1UCFeSebabsw[pp][qq] = gapsize
			//gap1UCFeSebabs+= gg/((x-xx)^2+(y-yy)^2+gg^2)

		endif
		//print theta

		i+=1
	while (i<3*num*pi/(2*2*pi))

end

