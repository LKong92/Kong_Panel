#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
Function FTguassianremover(name,sigma)
	wave name
	variable sigma
	duplicate/o name gmask
	make/n=6 gmaskpara
	gmaskpara = {0,1,0,sigma,0,sigma,0}
	gmask = 1-Gauss2D(gmaskpara,x,y)

	name *= gmask
	killwaves gmaskpara gmask
end

/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
//Function FTC4sym_old(name)
//	wave name
//
//	if (dimsize(name,0) == dimsize(name,1))
//	else
//		twoDinterpolatexyfFFT(nameofwave(name),max(dimsize(name,0),dimsize(name,1)),max(dimsize(name,0),dimsize(name,1)))
//		String inter = nameofwave(name)+"_INTER"
//		duplicate/o $inter $nameofwave(name)
//		killwaves $inter
//
//	endif
//	duplicate/o name C4sym_90 C4sym_180 C4sym_270 C4sym_0
//	imagerotate/A=90/o/Q C4sym_90
//	imagerotate/A=180/o/Q C4sym_180
//	imagerotate/A=270/o/Q C4sym_270
//
//	name = (C4sym_90 + C4sym_180 + C4sym_270 + C4sym_0)/4
//	killwaves C4sym_90 C4sym_180 C4sym_270 C4sym_0
//end
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
//Function FTC2sym_old(name)
///	wave name
//
//	if (dimsize(name,0) == dimsize(name,1))
//	else
//		twoDinterpolatexyfFFT(nameofwave(name),max(dimsize(name,0),dimsize(name,1)),max(dimsize(name,0),dimsize(name,1)))
//		String inter = nameofwave(name)+"_INTER"
//		duplicate/o $inter $nameofwave(name)
//		killwaves $inter
//
//	endif
//	duplicate/o name C4sym_180 C4sym_0
//	imagerotate/A=180/o/Q C4sym_180

//	name = (C4sym_180 + C4sym_0)/2
//	killwaves C4sym_180 C4sym_0
//end
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
//Function twoDinterpolatexyfFFT(name,xpoint,ypoint)
//	string name
//	variable xpoint
//	variable ypoint
//
//	variable i
//	variable j
//	variable k
//	variable sizex, sizey
//	string curve1,curve2,curve11,curve22,name1,name2
//	wave namew=$name
//	sizex=dimsize(namew,0)
//	sizey=dimsize(namew,1)
//	i=0
//	do
//		curve1="curve1_"+num2str(i)
//		curve11="curve1L_"+num2str(i)
//
//		make/O/N=(sizey) $curve1
//		wave curve1w = $curve1
//
//		curve1w[]=namew[i][p]
//		interpolate2/n=(ypoint) /t=1/Y=$curve11 $curve1
//		killwaves curve1w
//		i+=1
//	while(i<sizex)
///	name1=name+"1"
//	make/O/N=(sizex,ypoint) $name1
//	wave name1w = $name1
//	makematrix2(name1,sizex,ypoint)
//
//	j=0
//	do
//		curve2="curve2_"+num2str(j)
//		curve22="curve2L_"+num2str(j)
//
//		make/O/N=(sizex) $curve2
//		wave curve2w = $curve2
//
//		curve2w[]=name1w[p][j]
//		interpolate2/n=(xpoint) /t=1/Y=$curve22 $curve2
//		killwaves curve2w
//		j+=1
//	while(j<ypoint)
//	name2=name+"_INTER"
//	make/O/N=(xpoint,ypoint) $name2
//	makematrix3(name2,xpoint,ypoint)
//	setscale/I x,dimoffset($name,0),dimoffset($name,0)+dimdelta($name,0)*(dimsize($name,0)-1),""$name2
//	setscale/I y,dimoffset($name,1),dimoffset($name,1)+dimdelta($name,1)*(dimsize($name,1)-1),""$name2

//	CheckDisplayed $name2
//	if (V_flag == 1)
//		print "display;appendimage " + name2+";ModifyGraph width={Plan,1,bottom,left}"
//	else
//	endif
//end
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//####. C4 symmetrization of a matrix
////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_C4_symc(ctrlName) : ButtonControl
	String ctrlName
	execute "C4_symc()"
End
proc C4_symc(name)
	string name = tpw()
	prompt name,"Matrix name"
	C4_sym($name)
end
Function C4_sym(name)
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

			//***********************************************************************
			//### Due to the C2 symmetry of the FFT data, these parts can be deleted.
			//***********************************************************************
			//calculateRC(i,j,pc,qc,180)
			//if (M_product[0] >= 0 && M_product[0] < dimsize(name,0))
			//	if (M_product[1] >= 0 && M_product[1] < dimsize(name,1))
			//		multithread name_C4w[i][j]+= name[M_product[0]][M_product[1]]
			//	else
			//		name_C4w[i][j]+= name[i][j]
			//	endif
			//else
			//	name_C4w[i][j]+= name[i][j]
			//endif
			//calculateRC(i,j,pc,qc,270)
			//if (M_product[0] >= 0 && M_product[0] < dimsize(name,0))
			//	if (M_product[1] >= 0 && M_product[1] < dimsize(name,1))
			//		multithread name_C4w[i][j]+= name[M_product[0]][M_product[1]]
			//	else
			//		name_C4w[i][j]+= name[i][j]
			//	endif
			//else
			//	name_C4w[i][j]+= name[i][j]
			//endif

			name_C4w[i][j]/=2

			j+=1
		while (j<dimsize(name,1))
		i+=1
	while (i<dimsize(name,0))
	//name_C4w[pc][qc]= mean(name_C4w)
	di(name_C4w)
	color3s_for3dFFT($tpw(),15)
	//wave rotate2DM_calculateRC = $"rotate2DM_calculateRC"
	//wave input_calculateRC = $"input_calculateRC"
	//wave M_product = $"M_product"
	//killwaves rotate2DM_calculateRC input_calculateRC M_product
end


Function ButtonProc_calculateRCc(ctrlName) : ButtonControl
	String ctrlName
	execute "calculateRCc()"
End
proc calculateRCc(pp,qq,pc,qc,angle)
	variable pp = 10
	variable qq = 10
	variable pc = 0
	variable qc = 0
	variable angle = 90
	prompt pp,"x_i"
	prompt qq,"y_i"
	Prompt pc,"x_0"
	prompt qc,"y_0"
	prompt angle,"roate angle (˚)"

	calculateRC2(pp,qq,pc,qc,angle)
	print "Inital coordinate: "+"x_i: "+num2str(pp)+"; "+ "y_i: "+num2str(qq)
	print "Origin at: "+"x_0: "+num2str(pc)+"; "+ "y_0: "+num2str(qc)
	print "After Rotation counter-clockwise " + num2str(angle) +" degree"
	print "x_j: "+num2str(M_product[0])+"; "+ "y_j: "+num2str(M_product[1])

end
Function calculateRC(pp,qq,pc,qc,angle)
	variable pp
	variable qq
	variable pc
	variable qc
	variable angle

	variable m1,m2
	m1 = (pp-pc)*cos(angle*pi/180) - (qq-qc)*sin(angle*pi/180)
	m2 = (pp-pc)*sin(angle*pi/180) + (qq-qc)*cos(angle*pi/180)
	make/o/n=(2,1) M_product = {m1+pc,m2+qc}

	//make/o/n=(2,2) rotate2DM_calculateRC = {{cos(angle*pi/180),sin(angle*pi/180)},{-sin(angle*pi/180),cos(angle*pi/180)}}
	//make/o/n=(2,1) input_calculateRC = {pp-pc,qq-qc}
	//matrixmultiply rotate2DM_calculateRC, input_calculateRC
	//wave M_product = $"M_product"
	//M_product[0]+=pc
	//M_product[1]+=qc

	//Test Diagram
		//edit M_product
		//make/n=1/o a1, a2, b1, b2, c1, c2
		//a1 = pc
		//a2 = qc
		//b1 = pp
		//b2 = qq
		//c1 = M_product[0]
		//c2 = M_product[1]

		//display;
		//appendtograph a2 vs a1
		//appendtograph b2 vs b1
		//appendtograph c2 vs c1
end
Function calculateRC2(pp,qq,pc,qc,angle)
	variable pp
	variable qq
	variable pc
	variable qc
	variable angle

	variable m1,m2
	m1 = (pp-pc)*cos(angle*pi/180) - (qq-qc)*sin(angle*pi/180)
	m2 = (pp-pc)*sin(angle*pi/180) + (qq-qc)*cos(angle*pi/180)
	make/o/n=(2,1) M_product = {m1+pc,m2+qc}


	//make/o/n=(2,2) rotate2DM_calculateRC = {{cos(angle*pi/180),sin(angle*pi/180)},{-sin(angle*pi/180),cos(angle*pi/180)}}
	//make/o/n=(2,1) input_calculateRC = {pp-pc,qq-qc}
	//matrixmultiply rotate2DM_calculateRC, input_calculateRC
	//wave M_product = $"M_product"
	//M_product[0]+=pc
	//M_product[1]+=qc

	//Test Diagram
		//edit M_product
		//make/n=1/o a1, a2, b1, b2, c1, c2
		//a1 = pc
		//a2 = qc
		//b1 = pp
		//b2 = qq
		//c1 = M_product[0]
		//c2 = M_product[1]

		//display;
		//appendtograph a2 vs a1
		//appendtograph b2 vs b1
		//appendtograph c2 vs c1
end


////////////////////////////////////////////////////////////////////////////////
//####. Mirror symmetrization (Mirror plane: diagnoal)
////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Mdiag_symc(ctrlName) : ButtonControl
	String ctrlName
	execute "Mdiag_symc()"
End
proc Mdiag_symc(name)
	string name = tpw()
	prompt name,"Matrix name"
	Mdiag_sym($name)
end
Function Mdiag_sym(name)
	wave name
	string name_Md = nameofwave(name)+"_Md"
	duplicate/o name $name_Md
	wave name_Mdw = $name_Md

	matrixtranspose name_Mdw
	name_Mdw +=name
	name_Mdw/=2
	//variable pc,qc
	//pc = round((-dimoffset(name,0))/dimdelta(name,0))
	//qc = round((-dimoffset(name,1))/dimdelta(name,1))
	//name_Mdw[pc][qc]= mean(name_Mdw)
	di(name_Mdw)
	color3s_for3dFFT($tpw(),15)
end

////////////////////////////////////////////////////////////////////////////////
//####. Mirror symmetrization of a matrix along x
////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Mx_symc(ctrlName) : ButtonControl
	String ctrlName
	execute "Mx_symc()"
End
proc Mx_symc(name)
	string name = tpw()
	prompt name,"Matrix name"
	Mx_sym($name)
end
Function Mx_sym(name)
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

	//name_mxw[pc][qc]= mean(name_mxw)

	di(name_mxw)
	color3s_for3dFFT($tpw(),15)
end


////////////////////////////////////////////////////////////////////////////////
//####. Mirror symmetrization (Mirror plane: off diagnoal)
////////////////////////////////////////////////////////////////////////////////
//For FFT data, owing to the C2 symmetry of the FFT data,
//the off-diagonal Mirror symmetrization is same as the diagonal symmetrization
//So, this procedure does not provide new information
Function ButtonProc_Moffdiag_symc(ctrlName) : ButtonControl
	String ctrlName
	execute "Moffdiag_symc()"
End
proc Moffdiag_symc(name)
	string name = tpw()
	prompt name,"Matrix name"
	Moffdiag_sym($name)
end
Function Moffdiag_sym(name)
	wave name
	string name_Moffd = nameofwave(name)+"_Moffd"
	duplicate/o name $name_Moffd
	wave name_Moffdw = $name_Moffd

	variable i,j
	i=0
	do
		j=0
		do
			if (dimsize(name,1)-j >= 0 && dimsize(name,1)-j < dimsize(name,0))
				if (dimsize(name,1)-i >= 0 && dimsize(name,1)-i < dimsize(name,1))
					name_Moffdw[i][j] += name[dimsize(name,1)-j][dimsize(name,1)-i]
				else
					name_Moffdw[i][j] += name[i][j]
				endif
			else
				name_Moffdw[i][j] += name[i][j]
			endif

			j+=1
		while (j<dimsize(name,1))
		i+=1
	while (i<dimsize(name,0))
	name_Moffdw/=2
	//variable pc,qc
	//pc = round((-dimoffset(name,0))/dimdelta(name,0))
	//qc = round((-dimoffset(name,1))/dimdelta(name,1))
	//name_Moffdw[pc][qc]= mean(name_Moffdw)


	di(name_Moffdw)
	color3s_for3dFFT($tpw(),15)
end
////////////////////////////////////////////////////////////////////////////////
Function Matrixtranspose_off(name)
	wave name
	string name_Moffd = nameofwave(name)+"_Toff"
	duplicate/o name $name_Moffd
	wave name_Moffdw = $name_Moffd

	variable i,j
	i=0
	do
		j=0
		do
			if (dimsize(name,1)-j >= 0 && dimsize(name,1)-j < dimsize(name,0))
				if (dimsize(name,1)-i >= 0 && dimsize(name,1)-i < dimsize(name,1))
					name_Moffdw[i][j] = name[dimsize(name,1)-j][dimsize(name,1)-i]
				else
					name_Moffdw[i][j] = name[i][j]
				endif
			else
				name_Moffdw[i][j] = name[i][j]
			endif

			j+=1
		while (j<dimsize(name,1))
		i+=1
	while (i<dimsize(name,0))
	name_Moffdw/=2
	name = name_Moffdw
	killwaves name_Moffdw
end

////////////////////////////////////////////////////////////////////////////////
//####. Mirror symmetrization of a matrix along y
////////////////////////////////////////////////////////////////////////////////
//For FFT data, owing to the C2 symmetry of the FFT data,
//the y-Mirror symmetrization is same as the x-mirror symmetrization
//So, this procedure does not provide new information
Function ButtonProc_My_symc(ctrlName) : ButtonControl
	String ctrlName
	execute "My_symc()"
End
proc My_symc(name)
	string name = tpw()
	prompt name,"Matrix name"
	My_sym($name)
end
Function My_sym(name)
	wave name
	variable pc,qc
	pc = round((-dimoffset(name,0))/dimdelta(name,0))
	qc=round((-dimoffset(name,1))/dimdelta(name,1))

	string name_my = nameofwave(name)+"_my"
	duplicate/o name $name_my
	wave name_myw = $name_my

	variable distance

	variable i

		i=0
		do
			distance = i-pc

			if (pc-distance >= 0 && pc-distance < dimsize(name,0))
				name_myw[i][] += name[pc-distance][q]
			else
				name_myw[i][] += name[i][q]
			endif

			i+=1
		while (i<dimsize(name,0))

	name_myw/=2
	//name_myw[pc][qc]= mean(name_myw)
	di(name_myw)
	color3s_for3dFFT($tpw(),15)
end

////////////////////////////////////////////////////////////////////////////////
//####. Octect symmetrization D4
////////////////////////////////////////////////////////////////////////////////
/// Equivalent operation for FT data, owing to its intrinsic C2 symmetry
/// 1: Mx Mdiag; Mx Moffdiag; My Mdiag; My Moffdiag;
/// 2: C4 Mx; C4 My;
/// 3: C4 Moffdiag; C4 Mdiag
////////////////////////////////////////////////////////////////////////////////
/// We use method 1
////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_D4_symc(ctrlName) : ButtonControl
	String ctrlName
	execute "D4_symc()"
End
proc D4_symc(name)
	string name = tpw()
	prompt name,"Matrix name"
	D4_sym($name)
end
Function D4_sym(name)
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
	//variable pc,qc
	//pc = round((-dimoffset(name,0))/dimdelta(name,0))
	//qc = round((-dimoffset(name,1))/dimdelta(name,1))
	//name_Mdw[pc][qc]= mean(name_Mdw)
	di(name_D4w)
	color3s_for3dFFT($tpw(),15)
	killwaves name_mxw
end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_symmetrizeQPIdallc(ctrlName) : ButtonControl
	String ctrlName
	Execute "symmetrizeQPIdallc()"
end
Proc symmetrizeQPIdallc(name)
	string name = tpw()
	symmetrizeQPIdall($name)
end

Function symmetrizeQPIdall(name)
	wave name

	String name_c4 = nameofwave(name)+"_C4"
	String name_D4 = nameofwave(name)+"_D4"
	String name_Mx = nameofwave(name)+"_Mx"
	String name_Mdiag = nameofwave(name)+"_Mdiag"

	duplicate/O name $name_c4
	duplicate/O name $name_D4
	duplicate/O name $name_Mx
	duplicate/O name $name_Mdiag

		D4_sym_3dplot($name_D4)

		Mdiag_sym_3dplot($name_Mdiag)

		Mx_sym_3dplot($name_Mx)

		C4_sym_3dplot($name_c4)




	wave name_c4w = $name_c4
	wave name_D4w = $name_D4
	wave name_Mxw = $name_Mx
	wave name_Mdiagw = $name_Mdiag

	variable/G colorratio_consFFT = 15
	string/G name_symQPI = nameofwave(name)

	//**Show subwindow***********************************************************************************\\

		display/N=symmetrizationFFTwin; ModifyGraph margin(top)=72; modifygraph width=700,height=600
		Display/HOST=#/W=(0,0.05,0.5,0.55);
		appendimage $name_D4
		color3s_subfor3dFFT($name_D4,colorratio_consFFT)
		ModifyGraph mirror=2,axThick=3
		ModifyGraph height={Plan,1,left,bottom}
		TextBox/C/N=text1a/F=0/A=RT/X=0.00/Y=0.00 "D4 (Octet)"


		setActiveSubwindow ##;
		Display/HOST=#/W=(0.5,0.05,1,0.55);
		appendimage $name_c4
		color3s_subfor3dFFT($name_c4,colorratio_consFFT)
		ModifyGraph mirror=2,axThick=3
		ModifyGraph height={Plan,1,left,bottom}
		TextBox/C/N=text1a/F=0/A=RT/X=0.00/Y=0.00 "C_4"


		setActiveSubwindow ##;
		Display/HOST=#/W=(0,0.5,0.5,1);
		appendimage $name_Mx
		color3s_subfor3dFFT($name_Mx,colorratio_consFFT)
		ModifyGraph mirror=2,axThick=3
		ModifyGraph height={Plan,1,left,bottom}
		TextBox/C/N=text1a/F=0/A=RT/X=0.00/Y=0.00 "M_x, M_y"



		setActiveSubwindow ##;
		Display/HOST=#/W=(0.5,0.5,1,1);
		appendimage $name_Mdiag
		color3s_subfor3dFFT($name_Mdiag,colorratio_consFFT)
		ModifyGraph mirror=2,axThick=3
		ModifyGraph height={Plan,1,left,bottom}
		TextBox/C/N=text1a/F=0/A=RT/X=0.00/Y=0.00 "M_diag, M_offdiag"



		setActiveSubwindow ##;

		TextBox/C/N=text0/F=0/A=LT/X=8/Y=-8.5 "\Z08 C_4 M_x,  C_4 M_y,  C_4 M_diag,  C_4 M_yoffdiag,\rM_x M_diag,   M_x M_offdiag,  M_y M_diag,  M_y M_offdiag"

		SetVariable setvarz_csfftm title="Color Range σ",size={110,14},value=colorratio_consFFT,limits={1,inf,1},proc=SetVarProc_colorratio_consFFTdemo,pos={1,5}
		variable/G GBK2dornot_3dplot = 2
		variable/G GBK2dsigma_3dplot = 0.001
		PopupMenu GBK2dMode bodyWidth=120 ,title="Bkg.Rmv?",fSize=10,proc=PopMenuProc_bkgrmv2Ddemo_3dplot,value="Yes;No",mode=2, pos={401,2}
		SetVariable setvarz_GBK2d title="σ_bkg",size={100,14},value=GBK2dsigma_3dplot,limits={0.0001,inf,0.01},proc=SetVarProc_bkgrmv2Ddemo_3dplot,pos={460,5}

	//** Turn off
		Button turnoffls3d title="BACK",size={45,18},valueColor=(0,0,0),fColor=(1,65535,33232),pos={651,2},proc=ButtonProc_lsturnoff3d
		tilewindows/WINS="symmetrizationFFTwin"/R/w=(30,0,83,85)/A=(1,1)


end

Function SetVarProc_colorratio_consFFTdemo(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	string/G name_symQPI
	variable/G colorratio_consFFT

	String name_c4 = name_symQPI+"_C4"
	String name_D4 = name_symQPI+"_D4"
	String name_Mx = name_symQPI+"_Mx"
	String name_Mdiag = name_symQPI+"_Mdiag"


	color3s_subfor3dFFT($name_c4,colorratio_consFFT)
	color3s_subfor3dFFT($name_D4,colorratio_consFFT)
	color3s_subfor3dFFT($name_Mx,colorratio_consFFT)
	color3s_subfor3dFFT($name_Mdiag,colorratio_consFFT)

End

Function PopMenuProc_bkgrmv2Ddemo_3dplot(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	variable/G GBK2dornot_3dplot
	variable/G GBK2dsigma_3dplot

	GBK2dornot_3dplot = popNum

	string/G name_symQPI
	variable/G colorratio_consFFT

	String name_c4 = name_symQPI+"_C4"
	String name_D4 = name_symQPI+"_D4"
	String name_Mx = name_symQPI+"_Mx"
	String name_Mdiag = name_symQPI+"_Mdiag"


	duplicate/O $name_symQPI $name_c4
	duplicate/O $name_symQPI $name_D4
	duplicate/O $name_symQPI $name_Mx
	duplicate/O $name_symQPI $name_Mdiag

		D4_sym_3dplot($name_D4)

		Mdiag_sym_3dplot($name_Mdiag)

		Mx_sym_3dplot($name_Mx)

		C4_sym_3dplot($name_c4)



	if (GBK2dornot_3dplot == 1)
		FTguassianremover($name_c4,GBK2dsigma_3dplot)
		FTguassianremover($name_D4,GBK2dsigma_3dplot)
		FTguassianremover($name_Mx,GBK2dsigma_3dplot)
		FTguassianremover($name_Mdiag,GBK2dsigma_3dplot)
		color3s_subfor3dFFT($name_c4,colorratio_consFFT)
		color3s_subfor3dFFT($name_D4,colorratio_consFFT)
		color3s_subfor3dFFT($name_Mx,colorratio_consFFT)
		color3s_subfor3dFFT($name_Mdiag,colorratio_consFFT)
	endif

end

Function SetVarProc_bkgrmv2Ddemo_3dplot(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/G GBK2dornot_3dplot
	variable/G GBK2dsigma_3dplot

	GBK2dsigma_3dplot = varNum

	string/G name_symQPI
	variable/G colorratio_consFFT

	String name_c4 = name_symQPI+"_C4"
	String name_D4 = name_symQPI+"_D4"
	String name_Mx = name_symQPI+"_Mx"
	String name_Mdiag = name_symQPI+"_Mdiag"





	if (GBK2dornot_3dplot == 1)
		duplicate/O $name_symQPI $name_c4
		duplicate/O $name_symQPI $name_D4
		duplicate/O $name_symQPI $name_Mx
		duplicate/O $name_symQPI $name_Mdiag

		D4_sym_3dplot($name_D4)

		Mdiag_sym_3dplot($name_Mdiag)

		Mx_sym_3dplot($name_Mx)

		C4_sym_3dplot($name_c4)

		FTguassianremover($name_c4,GBK2dsigma_3dplot)
		FTguassianremover($name_D4,GBK2dsigma_3dplot)
		FTguassianremover($name_Mx,GBK2dsigma_3dplot)
		FTguassianremover($name_Mdiag,GBK2dsigma_3dplot)
		color3s_subfor3dFFT($name_c4,colorratio_consFFT)
		color3s_subfor3dFFT($name_D4,colorratio_consFFT)
		color3s_subfor3dFFT($name_Mx,colorratio_consFFT)
		color3s_subfor3dFFT($name_Mdiag,colorratio_consFFT)
	endif

End

