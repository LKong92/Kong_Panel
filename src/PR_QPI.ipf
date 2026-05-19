#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
//##############################################################
//** $ Defect bound state Phase referenced QPI to extract
//** $ superconducting pair phase
//** $ Ref. Phys. Rev. B 99,014507 (2019) & references therein
//##############################################################
Function ButtonProc_DBD_PRQPI(ctrlName) : ButtonControl
	String ctrlName
	execute "DBD_PRQPI()"
End
Proc DBD_PRQPI(name,sel)
	string name = stringfromlist(0,getall3dwave())
	variable sel = 1
	prompt name,"3D conductance g matrix, require Zn = 2"
	prompt sel,"Select Mode",popup,"Phase FFT & cvtcmplx(src); Phase FFT & real(src);Phase Cal. & cvtcmplx(src); Phase Cal. & real(src)"
	if (sel == 1)
		DBD_PRQPI_FP_w($name)
	endif
	if (sel == 2)
		DBD_PRQPI_FP_wo($name)
	endif
	if (sel == 3)
		DBD_PRQPI_cP_w($name)
	endif
	if (sel == 4)
		DBD_PRQPI_cP_wo($name)
	endif


	//** Call smart 3D displayer
		string PR_QPI = name+"_PR_QPI"
		//killwaves modelresult_QWZ sorteigen QWZHw n
		string exe = "d3d(\""+PR_QPI+"\",2)"
		execute exe
		//

	//** Modify the 3D player for this special simulation use (band structure)
	string slicename = "Zslice_"+mat3dn_cons
	variable/G divcolor_cons
	divcolor_cons = 1

		ModifyImage/w=$grabwin(slicename) $slicename ctab= {-color3s_for3dmprqpi($slicename,100),color3s_for3dmprqpi($slicename,100),:Packages:NewColortable:dvg_seismic,0};
		//ColorScale/W=$grabwinchild(tpw())/C/N=textcc/X=-21.00/Y=5.00/F=0 heightPct=30,nticks=5,minor=1,tickLen=1.00,image=$tpw()//;ColorScale/W=$grabwinchild(Fexyd)/C/N=text0/F=0/A=MC/Y=-120 image=$Fexyd
		variable/G normornot_3dplot =2

	//** SetVariable of Layer energy
		SetVariable setvarz_cons win=$grabwin(slicename),title="Z",size={65,14},value=z_cons,proc=SetVarProc_Cons3dplotPRQPI
		SetVariable setvarz_cons win=$grabwin(slicename),limits={dimoffset($mat3dn_cons,zn_cons),(dimoffset($mat3dn_cons,zn_cons)+dimdelta($mat3dn_cons,zn_cons)*(dimsize($mat3dn_cons,zn_cons)-1)),dimdelta($mat3dn_cons,zn_cons)}

		variable/G ss_PRQPI=100
		SetVariable setvarzt_cons win=$grabwin(slicename),title="σ",size={60,14},pos={2,198},value=ss_PRQPI,limits={0,inf,10},proc=SetVarProc_PRQPI_setcolorratio

	string aa = slicename+"_FFT_Modula"
	killwindow $grabwinnonew(aa)

end

//////////////////////////////////////////////////////////////////////////////////
//## Main Functional Body
//////////////////////////////////////////////////////////////////////////////////
Function DBD_PRQPI_FP_w(wg)
	wave wg

	variable zn_consl =2
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
	string PR_QPI = nameofwave(wg)+"_PR_QPI"

	variable i

	variable symmetrici
		//-(dimoffset(wg,zn)+i*dimdelta(wg,zn))=dimoffset(wg,zn)+symmetrici*dimdelta(wg,zn)

	string map_pE, map_mE
	map_pE="map_pE"
	map_mE="map_mE"

	print "Check for symmetric energy: the calculated step for 0 meV is "+num2str(ptest)
	print "The judgments should be zero, the calculated value is: "+num2str(abs(mod(ptest,1)))

	if (abs(mod(ptest,1)) < 10^-3)
			make/N=(dimsize(wg,xn),dimsize(wg,yn))/o $map_pE
			make/N=(dimsize(wg,xn),dimsize(wg,yn))/o $map_mE
			setscale/p x,dimoffset(wg,0),dimdelta(wg,0),"",$map_pE
			setscale/p y,dimoffset(wg,1),dimdelta(wg,1),"",$map_pE
			setscale/p x,dimoffset(wg,0),dimdelta(wg,0),"",$map_mE
			setscale/p y,dimoffset(wg,1),dimdelta(wg,1),"",$map_mE
			wave map_mEw = $map_mE
			wave map_pEw = $map_pE

			make/O/N=(dimsize(wg,xn),dimsize(wg,yn),dimsize(wg,zn)) $PR_QPI

			wave PR_QPIw = $PR_QPI

			i=0
			do
				symmetrici =(-(dimoffset(wg,zn)+i*dimdelta(wg,zn))-dimoffset(wg,zn))/dimdelta(wg,zn)
				if (symmetrici < 0 || symmetrici >= dimsize(wg,zn))
					PR_QPIw[][][i] = gammaNoise(0.001)
				else

					map_mEw[][] = wg[p][q][i]
					map_pEw[][] = wg[p][q][symmetrici]


					FFT/OUT=3/DEST=absmE  cvtcmplx(map_mEw)

					FFT/OUT=5/DEST=phasepE  cvtcmplx(map_pEw)
					FFT/OUT=5/DEST=phasemE  cvtcmplx(map_mEw)

					duplicate/o phasemE PRQPIslice

					PRQPIslice = absmE*(cos(phasemE-phasepE))
					//C4sym_PRQPI(PRQPIslice)

					PR_QPIw[][][i] = PRQPIslice[p][q]

				endif
				i+=1
			while(i<dimsize(wg,zn))
			//PR_QPIw[][][-dimoffset(wg,zn)/dimdelta(wg,zn)]+=gammaNoise(0.001)

			setscale/p x,dimoffset(absmE,0),dimdelta(absmE,0),"",PR_QPIw
			setscale/p y,dimoffset(absmE,1),dimdelta(absmE,1),"",PR_QPIw
			setscale/p z,dimoffset(wg,zn),dimdelta(wg,zn),"",PR_QPIw
			killwaves absmE PRQPIslice phasemE phasepE $map_mE $map_pE
	else
		print "Energy asymmetric, can not make Z(r,V), R(r,V), and ρ(r,V)"
	endif
end

//////////////////////////////////////////////////////////////////////////////////
//## Control Color range
//////////////////////////////////////////////////////////////////////////////////
Function SetVarProc_PRQPI_setcolorratio(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G ss_PRQPI
	colorPRQPI()
end

//////////////////////////////////////////////////////////////////////////////////
//## Control Z slice
//////////////////////////////////////////////////////////////////////////////////
Function SetVarProc_Cons3dplotPRQPI(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName


	//Update layers
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

	//func_zeroNaN($slicename)

	//variable/G divcolor_cons
	//if (divcolor_cons == 1)
	//	wavestats/Q slicenamew
	//	variable rangls = max(abs(V_max),abs(V_min))
	//	ModifyImage/W=$grabwinchild(slicename) $slicename ctab= {-color3s_for3dmprqpi($slicename,100),color3s_for3dmprqpi($slicename,100),:Packages:NewColortable:dvg_seismic,0};
	//	color3s_for3dmprqpi($slicename,100)
	//	ColorScale/W=$grabwinchild(slicename)/C/N=textcc/X=-21.00/Y=5.00/F=0 heightPct=30,nticks=5,minor=1,tickLen=1.00,image=$slicename//;ColorScale/W=$grabwinchild(Fexyd)/C/N=text0/F=0/A=MC/Y=-120 image=$Fexyd
	//endif

	//if (divcolor_cons == 0)
	//	color3s_for3d($slicename,3)
	//	ColorScale/K/N=textcc
	//endif

	colorPRQPI()

	//** Indicative line
	string Zpp = "Zpp_"+mat3dn_cons
	wave zppw = $zpp
	Zppw=z_cons
end

//////////////////////////////////////////////////////////////////////////////////
//## Set color
//////////////////////////////////////////////////////////////////////////////////
Function colorPRQPI()
	//Update layers
	string/G mat3dn_cons
	variable/G zn_cons
	variable/G z_cons
	variable/G ss_PRQPI


	variable/G colorratio_consFFT
	wave mat3dnw = $mat3dn_cons
	variable Z_constp=(z_cons-dimoffset(mat3dnw,zn_cons))/dimdelta(mat3dnw,zn_cons)
	string bare3d
	string barename = replaceString("_G",mat3dn_cons,"")

	//** g(r,V)
	string slicename = "Zslice_"+mat3dn_cons
	wave slicenamew =$slicename

	func_zeroNaN($slicename)

	variable/G divcolor_cons
	if (divcolor_cons == 1)
		wavestats/Q slicenamew
		variable rangls = max(abs(V_max),abs(V_min))
		ModifyImage/W=$grabwinchild(slicename) $slicename ctab= {-color3s_for3dmprqpi($slicename,ss_PRQPI),color3s_for3dmprqpi($slicename,ss_PRQPI),:Packages:NewColortable:dvg_seismic,0};
		color3s_for3dmprqpi($slicename,100)
		ColorScale/W=$grabwinchild(slicename)/C/N=textcc/X=-21.00/Y=5.00/F=0 heightPct=30,nticks=5,minor=1,tickLen=1.00,image=$slicename//;ColorScale/W=$grabwinchild(Fexyd)/C/N=text0/F=0/A=MC/Y=-120 image=$Fexyd
	endif
	if (divcolor_cons == 0)
		color3s_for3d($slicename,3)
		ColorScale/K/N=textcc
	endif
end

//##############################################################
//** $ Functional Functions
//##############################################################

//////////////////////////////////////////////////////////////////////////////////
//## Return the sigma range value
//////////////////////////////////////////////////////////////////////////////////
Function color3s_for3dmprqpi(name,tt)
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

	variable aa = max(abs(lc),abs(lh))
	return aa
end

//////////////////////////////////////////////////////////////////////////////////
//## Half-FFT to full FFT image, do not rely on cvtcmplx()
//////////////////////////////////////////////////////////////////////////////////
Function extendffterealimage(name) // For real wave
	wave name

	duplicate/o name name2
	name2[][]=name[dimsize(name,0)-p-1][dimsize(name,1)-q-1]
	DeletePoints dimsize(name2,0)-1,1, name2
	DeletePoints 0,1, name

	variable sizex,sizey
	sizey = dimsize(name,1)
	sizex = dimsize(name,0)+dimsize(name2,0)
	make/o/N=(sizex,sizey) temp

	variable i
	i = 0
	do
		temp[i][]= name2[i][q]
		i+=1
	while (i<dimsize(name2,0))
	i = dimsize(name2,0)
	do
		temp[i][]= name[i-dimsize(name2,0)][q]
		i+=1
	while (i<sizex)

	setscale/p y,dimoffset(name,1),dimdelta(name,1),"",temp
	setscale/p x,-dimsize(name2,0)*dimdelta(name,0),dimdelta(name,0),"",temp
	duplicate/o temp $nameofwave(name)
	//killwaves name2 temp
end

Function extendffterealimage_c(name) //For complex wave
	wave/c name

	duplicate/o/c name name2
	name2[][]=name[dimsize(name,0)-p-1][dimsize(name,1)-q-1]
	DeletePoints dimsize(name2,0)-1,1, name2
	DeletePoints 0,1, name

	variable sizex,sizey
	sizey = dimsize(name,1)
	sizex = dimsize(name,0)+dimsize(name2,0)
	make/o/N=(sizex,sizey)/c temp

	variable i
	i = 0
	do
		temp[i][]= name2[i][q]
		i+=1
	while (i<dimsize(name2,0))
	i = dimsize(name2,0)
	do
		temp[i][]= name[i-dimsize(name2,0)][q]
		i+=1
	while (i<sizex)

	setscale/p y,dimoffset(name,1),dimdelta(name,1),"",temp
	setscale/p x,-dimsize(name2,0)*dimdelta(name,0),dimdelta(name,0),"",temp
	duplicate/o/c temp $nameofwave(name)
	//killwaves name2 temp
end

//////////////////////////////////////////////////////////////////////////////////
//## C4 symmetrilization of a wave
//////////////////////////////////////////////////////////////////////////////////
Function C4sym_PRQPI(name)
	wave name
	duplicate/o name temp
	string  M_RotatedImage="M_RotatedImage"

	imagerotate/A=90 name
	wave M = $ M_RotatedImage
	temp+=M

	imagerotate/A=180 name
	wave M = $ M_RotatedImage
	temp+=M

	imagerotate/A=270 name
	wave M = $ M_RotatedImage
	temp+=M

	temp/=4

	duplicate/o temp $nameOfWave(name)
	killwaves temp M
end



//##############################################################
//##############################################################
//##############################################################
//##############################################################
//## Other algrithom, equivalent but not the best strategies
//##############################################################
//##############################################################
//##############################################################
//##############################################################

//##############################################################
//** #01 Old version  No Phase FFT w/o cvtcmplx of source data
//##############################################################
Function DBD_PRQPI_cP_wo(wg)
	wave wg

	variable zn_consl =2
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
	string PR_QPI = nameofwave(wg)+"_PR_QPI"
		//string Rmap = nameofwave(wg)+"_R_map"
		//string Rhomap = nameofwave(wg)+"_Rho_map"
	variable i
		//print ptest
		//print mod(ptest,1)
	variable symmetrici
		//-(dimoffset(wg,zn)+i*dimdelta(wg,zn))=dimoffset(wg,zn)+symmetrici*dimdelta(wg,zn)


	string map_pE, map_mE
	map_pE="map_pE"
	map_mE="map_mE"


	print "Check for symmetric energy: the calculated step for 0 meV is "+num2str(ptest)
	print "The judgments should be zero, the calculated value is: "+num2str(abs(mod(ptest,1)))

	if (abs(mod(ptest,1)) < 10^-3)
			make/N=(dimsize(wg,xn),dimsize(wg,yn))/o $map_pE
			make/N=(dimsize(wg,xn),dimsize(wg,yn))/o $map_mE
			setscale/p x,dimoffset(wg,0),dimdelta(wg,0),"",$map_pE
			setscale/p y,dimoffset(wg,1),dimdelta(wg,1),"",$map_pE
			setscale/p x,dimoffset(wg,0),dimdelta(wg,0),"",$map_mE
			setscale/p y,dimoffset(wg,1),dimdelta(wg,1),"",$map_mE
			wave map_mEw = $map_mE
			wave map_pEw = $map_pE

			map_mEw[][] = wg[p][q][0]
			FFT/OUT=1/DEST=map_pEw_cmplx  map_pEw
			extendffterealimage_c(map_pEw_cmplx)

			make/O/N=(dimsize(map_pEw_cmplx,0),dimsize(map_pEw_cmplx,1),dimsize(wg,zn)) $PR_QPI
			//setscale/p z,dimoffset(wg,zn),dimdelta(wg,zn),"",$Zmap
			//setscale/p x,dimoffset(wg,xn),dimdelta(wg,xn),"",$Zmap
			//setscale/p y,dimoffset(wg,yn),dimdelta(wg,yn),"",$Zmap

			wave PR_QPIw = $PR_QPI



			i=0
			do
				symmetrici =(-(dimoffset(wg,zn)+i*dimdelta(wg,zn))-dimoffset(wg,zn))/dimdelta(wg,zn)
				if (symmetrici < 0 || symmetrici >= dimsize(wg,zn))
					PR_QPIw[][][i] = gammaNoise(0.001)
				else

					map_mEw[][] = wg[p][q][i]
					map_pEw[][] = wg[p][q][symmetrici]

					//FFT/OUT=1/DEST=map_pEw_cmplx  cvtcmplx(map_pEw)
					//FFT/OUT=1/DEST=map_mEw_cmplx  cvtcmplx(map_mEw)

					FFT/OUT=1/DEST=map_pEw_cmplx  map_pEw
					FFT/OUT=1/DEST=map_mEw_cmplx  map_mEw
					extendffterealimage_c(map_pEw_cmplx)
					extendffterealimage_c(map_mEw_cmplx)

					make/n=(dimsize(map_pEw_cmplx,0),dimsize(map_pEw_cmplx,1))/o absmE
					setscale/p x,dimoffset(map_pEw_cmplx,0),dimdelta(map_pEw_cmplx,0),"",absmE
					setscale/p y,dimoffset(map_pEw_cmplx,1),dimdelta(map_pEw_cmplx,1),"",absmE
					duplicate/o absmE abspE
					duplicate/o absmE realpE
					duplicate/o absmE realmE
					duplicate/o absmE imagpE
					duplicate/o absmE imagmE
					duplicate/o absmE PRQPIslice


					realpE = real(map_pEw_cmplx)
					realmE = real(map_mEw_cmplx)
					imagpE = imag(map_pEw_cmplx)
					imagmE = imag(map_mEw_cmplx)
					absmE = sqrt(realmE^2+imagmE^2)
					abspE = sqrt(realpE^2+realmE^2)

					PRQPIslice = absmE*( (realmE*realpE+imagpE*imagmE)/(absmE*abspE) )
					C4sym_PRQPI(PRQPIslice)

					PR_QPIw[][][i] = PRQPIslice[p][q]

				endif
				i+=1
			while(i<dimsize(wg,zn))
			//PR_QPIw[][][-dimoffset(wg,zn)/dimdelta(wg,zn)]+=gammaNoise(0.001)

			setscale/p x,dimoffset(map_pEw_cmplx,0),dimdelta(map_pEw_cmplx,0),"",PR_QPIw
			setscale/p y,dimoffset(map_pEw_cmplx,1),dimdelta(map_pEw_cmplx,1),"",PR_QPIw
			setscale/p z,dimoffset(wg,zn),dimdelta(wg,zn),"",PR_QPIw

			killwaves abspE absmE realpE realmE imagpE imagmE PRQPIslice $map_mE $map_pE map_pEw_cmplx
	else
		print "Energy asymmetric, can not make Z(r,V), R(r,V), and ρ(r,V)"
	endif
end

//##############################################################
//** #02 Old version  No Phase FFT w/ cvtcmplx of source data
//##############################################################
Function DBD_PRQPI_cP_w(wg)
	wave wg

	variable zn_consl =2
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
	string PR_QPI = nameofwave(wg)+"_PR_QPI"
		//string Rmap = nameofwave(wg)+"_R_map"
		//string Rhomap = nameofwave(wg)+"_Rho_map"
	variable i
		//print ptest
		//print mod(ptest,1)
	variable symmetrici
		//-(dimoffset(wg,zn)+i*dimdelta(wg,zn))=dimoffset(wg,zn)+symmetrici*dimdelta(wg,zn)


	string map_pE, map_mE
	map_pE="map_pE"
	map_mE="map_mE"

	print "Check for symmetric energy: the calculated step for 0 meV is "+num2str(ptest)
	print "The judgments should be zero, the calculated value is: "+num2str(abs(mod(ptest,1)))

	if (abs(mod(ptest,1)) < 10^-3)
			make/N=(dimsize(wg,xn),dimsize(wg,yn))/o $map_pE
			make/N=(dimsize(wg,xn),dimsize(wg,yn))/o $map_mE
			setscale/p x,dimoffset(wg,0),dimdelta(wg,0),"",$map_pE
			setscale/p y,dimoffset(wg,1),dimdelta(wg,1),"",$map_pE
			setscale/p x,dimoffset(wg,0),dimdelta(wg,0),"",$map_mE
			setscale/p y,dimoffset(wg,1),dimdelta(wg,1),"",$map_mE
			wave map_mEw = $map_mE
			wave map_pEw = $map_pE

			make/O/N=(dimsize(wg,xn),dimsize(wg,yn),dimsize(wg,zn)) $PR_QPI
			//setscale/p z,dimoffset(wg,zn),dimdelta(wg,zn),"",$Zmap
			//setscale/p x,dimoffset(wg,xn),dimdelta(wg,xn),"",$Zmap
			//setscale/p y,dimoffset(wg,yn),dimdelta(wg,yn),"",$Zmap

			wave PR_QPIw = $PR_QPI

			i=0
			do
				symmetrici =(-(dimoffset(wg,zn)+i*dimdelta(wg,zn))-dimoffset(wg,zn))/dimdelta(wg,zn)
				if (symmetrici < 0 || symmetrici >= dimsize(wg,zn))
					PR_QPIw[][][i] = gammaNoise(0.001)
				else

					map_mEw[][] = wg[p][q][i]
					map_pEw[][] = wg[p][q][symmetrici]

					//FFT/OUT=1/DEST=map_pEw_cmplx  cvtcmplx(map_pEw)
					//FFT/OUT=1/DEST=map_mEw_cmplx  cvtcmplx(map_mEw)

					FFT/OUT=1/DEST=map_pEw_cmplx  cvtcmplx(map_pEw)
					FFT/OUT=1/DEST=map_mEw_cmplx  cvtcmplx(map_mEw)

					make/n=(dimsize(map_pEw_cmplx,0),dimsize(map_pEw_cmplx,1))/o absmE
					setscale/p x,dimoffset(map_pEw_cmplx,0),dimdelta(map_pEw_cmplx,0),"",absmE
					setscale/p y,dimoffset(map_pEw_cmplx,1),dimdelta(map_pEw_cmplx,1),"",absmE
					duplicate/o absmE abspE
					duplicate/o absmE realpE
					duplicate/o absmE realmE
					duplicate/o absmE imagpE
					duplicate/o absmE imagmE
					duplicate/o absmE PRQPIslice


					realpE = real(map_pEw_cmplx)
					realmE = real(map_mEw_cmplx)
					imagpE = imag(map_pEw_cmplx)
					imagmE = imag(map_mEw_cmplx)
					absmE = sqrt(realmE^2+imagmE^2)
					abspE = sqrt(realpE^2+realmE^2)

					PRQPIslice = absmE*( (realmE*realpE+imagpE*imagmE)/(absmE*abspE) )
					//C4sym_PRQPI(PRQPIslice)

					PR_QPIw[][][i] = PRQPIslice[p][q]

				endif
				i+=1
			while(i<dimsize(wg,zn))
			//PR_QPIw[][][-dimoffset(wg,zn)/dimdelta(wg,zn)]+=gammaNoise(0.001)

			setscale/p x,dimoffset(map_pEw_cmplx,0),dimdelta(map_pEw_cmplx,0),"",PR_QPIw
			setscale/p y,dimoffset(map_pEw_cmplx,1),dimdelta(map_pEw_cmplx,1),"",PR_QPIw
			setscale/p z,dimoffset(wg,zn),dimdelta(wg,zn),"",PR_QPIw
			killwaves abspE absmE realpE realmE imagpE imagmE PRQPIslice $map_mE $map_pE map_pEw_cmplx

	else
		print "Energy asymmetric, can not make Z(r,V), R(r,V), and ρ(r,V)"
	endif
end

//##############################################################
//** #03 Old version  Phase FFT w/o cvtcmplx of source data
//##############################################################
Function DBD_PRQPI_FP_wo(wg)
	wave wg

	variable zn_consl =2
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
	string PR_QPI = nameofwave(wg)+"_PR_QPI"
		//string Rmap = nameofwave(wg)+"_R_map"
		//string Rhomap = nameofwave(wg)+"_Rho_map"
	variable i
		//print ptest
		//print mod(ptest,1)
	variable symmetrici
		//-(dimoffset(wg,zn)+i*dimdelta(wg,zn))=dimoffset(wg,zn)+symmetrici*dimdelta(wg,zn)


	string map_pE, map_mE
	map_pE="map_pE"
	map_mE="map_mE"


	print "Check for symmetric energy: the calculated step for 0 meV is "+num2str(ptest)
	print "The judgments should be zero, the calculated value is: "+num2str(abs(mod(ptest,1)))

	if (abs(mod(ptest,1)) < 10^-3)
			make/N=(dimsize(wg,xn),dimsize(wg,yn))/o $map_pE
			make/N=(dimsize(wg,xn),dimsize(wg,yn))/o $map_mE
			setscale/p x,dimoffset(wg,0),dimdelta(wg,0),"",$map_pE
			setscale/p y,dimoffset(wg,1),dimdelta(wg,1),"",$map_pE
			setscale/p x,dimoffset(wg,0),dimdelta(wg,0),"",$map_mE
			setscale/p y,dimoffset(wg,1),dimdelta(wg,1),"",$map_mE
			wave map_mEw = $map_mE
			wave map_pEw = $map_pE

			map_mEw[][] = wg[p][q][0]
			FFT/OUT=1/DEST=map_pEw_cmplx  map_pEw
			extendffterealimage_c(map_pEw_cmplx)

			make/O/N=(dimsize(map_pEw_cmplx,0),dimsize(map_pEw_cmplx,1),dimsize(wg,zn)) $PR_QPI
			//setscale/p z,dimoffset(wg,zn),dimdelta(wg,zn),"",$Zmap
			//setscale/p x,dimoffset(wg,xn),dimdelta(wg,xn),"",$Zmap
			//setscale/p y,dimoffset(wg,yn),dimdelta(wg,yn),"",$Zmap

			wave PR_QPIw = $PR_QPI



			i=0
			do
				symmetrici =(-(dimoffset(wg,zn)+i*dimdelta(wg,zn))-dimoffset(wg,zn))/dimdelta(wg,zn)
				if (symmetrici < 0 || symmetrici >= dimsize(wg,zn))
					PR_QPIw[][][i] = gammaNoise(0.001)
				else

					map_mEw[][] = wg[p][q][i]
					map_pEw[][] = wg[p][q][symmetrici]


					FFT/OUT=3/DEST=absmE  map_mEw

					FFT/OUT=5/DEST=phasepE  map_pEw
					FFT/OUT=5/DEST=phasemE  map_mEw

					extendffterealimage(absmE)
					extendffterealimage(phasepE)
					extendffterealimage(phasemE)

					duplicate/o phasemE PRQPIslice

					PRQPIslice = absmE*(cos(phasemE-phasepE))
					//C4sym_PRQPI(PRQPIslice)

					PR_QPIw[][][i] = PRQPIslice[p][q]


				endif
				i+=1
			while(i<dimsize(wg,zn))
			//PR_QPIw[][][-dimoffset(wg,zn)/dimdelta(wg,zn)]+=gammaNoise(0.001)

			setscale/p x,dimoffset(map_pEw_cmplx,0),dimdelta(map_pEw_cmplx,0),"",PR_QPIw
			setscale/p y,dimoffset(map_pEw_cmplx,1),dimdelta(map_pEw_cmplx,1),"",PR_QPIw
			setscale/p z,dimoffset(wg,zn),dimdelta(wg,zn),"",PR_QPIw

			killwaves  absmE PRQPIslice $map_mE $map_pE phasepE phasemE map_pEw_cmplx
	else
		print "Energy asymmetric, can not make Z(r,V), R(r,V), and ρ(r,V)"
	endif
end

