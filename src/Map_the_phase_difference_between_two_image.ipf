#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
Function ButtonProc_findpolarizationc(ctrlName) : ButtonControl
	String ctrlName
	Execute "findpolarizationc()"
end
Proc findpolarizationc(DA,DB,TA,TB)
	string DA = "g2_003_G_Gap_map_phi_A"
	string DB = "g2_003_G_Gap_map_phi_B"
	string TA = "g2_003_T_phi_A"
	string TB = "g2_003_T_phi_B"
	Prompt DA,"Name of phase Δ(QA)"
	Prompt DB,"Name of phase Δ(QB)"
	Prompt TA,"Name of phase T(QA)"
	Prompt TB,"Name of phase T(QB)"
	findpolarization($DA,$DB,$TA,$TB)
	ckfig_child(winname(0,1))
end
Function findpolarization(DA,DB,TA,TB)
	wave DA
	wave DB
	wave TA
	wave TB

	duplicate/o DA Admt Bdmt abdif abdif_abs

	Admt = DA - TA
	Bdmt = DB - TB

	shift2pi(Admt)
	shift2pi(Bdmt)
	abdif = (abs(Admt) - abs(Bdmt))/pi
	abdif_abs = abs(abdif)

	Display/N=PDWfinddomainmapwin;modifygraph width=900,height=900
	tilewindows/WINS=winname(0,1)/R/A=(1,1)/w=(3,0,50,100)
	Display/HOST=#/W=(0,0.05,0.33,0.33);appendimage DA;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "\\Z16\\$WMTEX$ \phi^{\Delta}_{Q_{A}}(r) \\$/WMTEX$";modifyphasenew()//ModifyImage $name ctab= {*,*,VioletOrangeYellow,0}//;AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {cts_ls, cte_ls, ctn_ls};ModifyGraph rgb=(65535,65535,65535)
		setActiveSubwindow ##;Display/HOST=#/W=(0.31,0.05,0.64,0.33);appendimage TA;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "\\Z16\\$WMTEX$ \phi^{T}_{Q_{A}}(r) \\$/WMTEX$";modifyphasenew()
		setActiveSubwindow ##;Display/HOST=#/W=(0.63,0.05,0.96,0.33);appendimage Admt;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "\\Z16\\$WMTEX$ \delta\phi^{\Delta/T}_{Q_{A}} \\$/WMTEX$";modifyphasenew();ModifyImage Admt ctab= {-pi,pi,:Packages:NewColortable:Cyclic_dvg_seismic,0}//ModifyImage $ux ctab= {*,*,VioletOrangeYellow,0}//;color3s_for3dm($Se_outputLs,3,$src);//;color3s_for3dm($nameftd,3);AppendMatrixContour $ContourZwave;ModifyContour $ContourZwave autoLevels= {0, 0.5, 1};ModifyGraph rgb=(65535,65535,65535)

		setActiveSubwindow ##;Display/HOST=#/W=(0,0.3,0.33,0.58);appendimage DB;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "\\Z16\\$WMTEX$ \phi^{\Delta}_{Q_{B}}(r) \\$/WMTEX$";modifyphasenew()
		setActiveSubwindow ##;Display/HOST=#/W=(0.31,0.3,0.64,0.58);appendimage TB;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "\\Z16\\$WMTEX$ \phi^{T}_{Q_{B}}(r) \\$/WMTEX$";modifyphasenew()//ModifyImage $tphase1 ctab= {*,*,VioletOrangeYellow,0}
		setActiveSubwindow ##;Display/HOST=#/W=(0.63,0.3,0.96,0.58);appendimage Bdmt;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "\\Z16\\$WMTEX$ \delta\phi^{\Delta/T}_{Q_{B}} \\$/WMTEX$";modifyphasenew();ModifyImage Bdmt ctab= {-pi,pi,:Packages:NewColortable:Cyclic_dvg_seismic,0}//ModifyImage $jc1 ctab= {*,*,VioletOrangeYellow,0}

		//setActiveSubwindow ##;Display/HOST=#/W=(0,0.55,0.33,0.83);appendimage Admt;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;//ModifyImage $padded ctab= {*,*,VioletOrangeYellow,0}
		setActiveSubwindow ##;Display/HOST=#/W=(0,0.6,0.45,1);appendimage abdif;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "\\Z16\\$WMTEX$ p \\$/WMTEX$";modifyphasenew();ModifyImage abdif ctab= {-0.8,0.8,:Packages:NewColortable:dvg_seismic,1}//ModifyImage $tphase2 ctab= {*,*,VioletOrangeYellow,0}//color3s_for3dm($tphase2,3)
		//setActiveSubwindow ##;Display/HOST=#/W=(0.63,0.55,0.96,0.83);appendimage $nn3;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "\\Z16\\$WMTEX$ Raw_{(Q_{B})}(r) \\$/WMTEX$";modifyphasetoponew()//ModifyImage $jc2 ctab= {*,*,VioletOrangeYellow,0}//color3s_for3dm($jc2,3)
		setActiveSubwindow ##;Display/HOST=#/W=(0.45,0.6,0.9,1);appendimage abdif_abs;ModifyGraph width={Plan,1,bottom,left},noLabel=2,axThick=0;TextBox/C/N=text0/F=0/X=0.00/Y=0.00 "\\Z16\\$WMTEX$ |p| \\$/WMTEX$";modifyphasetoponew();ModifyImage abdif_abs ctab= {*,*,VioletOrangeYellow,1}//ModifyImage $tphase2 ctab= {*,*,VioletOrangeYellow,0}//color3s_for3dm($tphase2,3)
		setActiveSubwindow ##;
		TextBox/C/N=text0/F=0/A=MB/X=-30.00/Y=40.00 "\\$WMTEX$ p(r)\equiv \frac{\left|\delta \phi_{P_{X}}^{\Delta/T}(r)\right|-\left|\delta \phi_{P_{Y}}^{\Delta/T}(r)\right|}{\pi} \\$/WMTEX$"
		TextBox/C/N=text1/F=0/A=MB/X=0.00/Y=40.00 "\Z16\\$WMTEX$ \delta \phi_{P_{X}}^{\Delta / T}(r)=\phi_{P_{X}}^{\Delta}(r)-\phi_{P_{X}}^{T}(r) \\$/WMTEX$"
		TextBox/C/N=text2/F=0/A=MB/X=30.00/Y=40.00 "\Z16\\$WMTEX$ \delta \phi_{P_{Y}}^{\Delta / T}(r)=\phi_{P_{Y}}^{\Delta}(r)-\phi_{P_{Y}}^{T}(r) \\$/WMTEX$"
		TextBox/C/N=text3/F=0/B=1/A=MT/X=0.00/Y=0 "Domain: How PDW lock to Lattice"
	Button turnoffls3d title="BACK",size={45,18},valueColor=(0,0,0),fColor=(1,65535,33232),pos={850,1},proc=ButtonProc_lsturnoff3d
end

/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
//Pre procedure, to make amplitude FFT
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_doampfftforphase(ctrlName) : ButtonControl
	String ctrlName
	Execute " doampfftforphase()"
end

Proc doampfftforphase(gapname,topname)
	string gapname
	string topname

	String name1 = "gapsize2d"
	String name2 = "topo_I2"

	duplicate/o $gapname $name1
	duplicate/o $topname $name2

	String name11 = name1+"_FFT"
	String name22 = name2+"_FFT"
	String name111 = name11+"_inter"
	String name222 = name22+"_inter"
	String name1111 = name111+"_f"
	String name2222 = name222+"_f"
	//Prompt name1,"name of the gap map"
	//Prompt name2,"name of the topography"
	FFT/OUT=3/DEST=$name11  $name1;DelayUpdate
	Display;AppendImage $name11
	ModifyGraph width=300,height=300
	ModifyGraph width=0,height=0
	ModifyGraph height={Plan,1,left,bottom}
	wavestats/Q $name11
	ModifyImage $name11 ctab= {V_min,V_max/60,Grays,0}


	FFT/OUT=3/DEST=$name22  $name2;DelayUpdate
	Display;AppendImage $name22
	ModifyGraph width=300,height=300
	ModifyGraph width=0,height=0
	ModifyGraph height={Plan,1,left,bottom}
	wavestats/Q $name22
	ModifyImage $name22 ctab= {V_min,V_max/60,Grays,0}

	twoDinterpolatexy(name11,dimsize($name11,0)*5,dimsize($name11,1)*5)
	ModifyGraph width=300,height=300
	ModifyGraph width=0,height=0
	ModifyGraph height={Plan,1,left,bottom}
	wavestats/Q $name111
	ModifyImage $name111 ctab= {V_min,V_max/60,Grays,0}


	twoDinterpolatexy(name22,dimsize($name22,0)*5,dimsize($name22,1)*5)
	ModifyGraph width=300,height=300
	ModifyGraph width=0,height=0
	ModifyGraph height={Plan,1,left,bottom}
	wavestats/Q $name222
	ModifyImage $name222 ctab= {V_min,V_max/60,Grays,0}



end

/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
//Pre procedure, to pick up the coordinate of FFT peak A
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_pickupPA(ctrlName) : ButtonControl
	String ctrlName
	Execute "pickupPA()"
end
Proc pickupPA()

	String name1 = "gapsize2d"
	String name2 = "topo_I2"
	String name11 = name1+"_FFT"
	String name22 = name2+"_FFT"
	String name111 = name11+"_inter"
	String name222 = name22+"_inter"
	String name1111 = name111+"_f"
	String name2222 = name222+"_f"

	//twoDinterpolatexy(name1,dimsize($name11,0)*5,dimsize($name11,1)*5)
	duplicate/o $name111 $name1111;
	$name1111=nan;
	CurveFit/Q gauss2D $name111[pcsr(A),pcsr(b)][qcsr(A),qcsr(b)] /D=$name1111[pcsr(A),pcsr(b)][qcsr(A),qcsr(b)];
	//AppendMatrixContour $name1111
	variable xa_G ya_G
	xa_G = W_coef[2]
	ya_G = W_coef[4]

	//twoDinterpolatexy(name2,dimsize($name22,0)*5,dimsize($name22,1)*5)
	duplicate/o $name222 $name2222;
	$name2222=nan;
	CurveFit/Q gauss2D $name222[pcsr(A),pcsr(b)][qcsr(A),qcsr(b)] /D=$name2222[pcsr(A),pcsr(b)][qcsr(A),qcsr(b)];
	variable xa_T ya_T
	xa_t = W_coef[2]
	ya_t = W_coef[4]

	Print "Coordiante from Gap map is ("+num2str(xa_G)+","+num2str(ya_G)+")."
	Print "Coordiante from Topograph is ("+num2str(xa_t)+","+num2str(ya_t)+")."

	variable xa_ave ya_ave
	xa_ave=(xa_G+xa_t)/2
	ya_ave=(ya_G+ya_t)/2
	Print "Coordiante averaged is ("+num2str(xa_ave)+","+num2str(ya_ave)+")."

	Variable/G X1_globalforphaseMap
	Variable/G Y1_globalforphaseMap
	X1_globalforphaseMap=xa_ave
	Y1_globalforphaseMap=ya_ave
	Print "X1_globalforphaseMap = "
	Print "Y1_globalforphaseMap = "

end

/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
//Pre procedure, to pick up the coordinate of FFT peak B
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_pickupPB(ctrlName) : ButtonControl
	String ctrlName
	Execute "pickupPB()"
end
Proc pickupPB()

	String name1 = "gapsize2d"
	String name2 = "topo_I2"
	String name11 = name1+"_FFT"
	String name22 = name2+"_FFT"
	String name111 = name11+"_inter"
	String name222 = name22+"_inter"
	String name1111 = name111+"_f"
	String name2222 = name222+"_f"

	//twoDinterpolatexy(name1,dimsize($name11,0)*5,dimsize($name11,1)*5)
	duplicate/o $name111 $name1111;
	$name1111=nan;
	CurveFit/Q gauss2D $name111[pcsr(A),pcsr(b)][qcsr(A),qcsr(b)] /D=$name1111[pcsr(A),pcsr(b)][qcsr(A),qcsr(b)];
	//AppendMatrixContour $name1111
	variable xa_G ya_G
	xa_G = W_coef[2]
	ya_G = W_coef[4]

	//twoDinterpolatexy(name2,dimsize($name22,0)*5,dimsize($name22,1)*5)
	duplicate/o $name222 $name2222;
	$name2222=nan;
	CurveFit/Q gauss2D $name222[pcsr(A),pcsr(b)][qcsr(A),qcsr(b)] /D=$name2222[pcsr(A),pcsr(b)][qcsr(A),qcsr(b)];
	variable xa_T ya_T
	xa_t = W_coef[2]
	ya_t = W_coef[4]

	Print "Coordiante from Gap map is ("+num2str(xa_G)+","+num2str(ya_G)+")."
	Print "Coordiante from Topograph is ("+num2str(xa_t)+","+num2str(ya_t)+")."

	variable xa_ave ya_ave
	xa_ave=(xa_G+xa_t)/2
	ya_ave=(ya_G+ya_t)/2
	Print "Coordiante averaged is ("+num2str(xa_ave)+","+num2str(ya_ave)+")."

	Variable/G X2_globalforphaseMap
	Variable/G Y2_globalforphaseMap
	X2_globalforphaseMap=xa_ave
	Y2_globalforphaseMap=ya_ave
	Print "X2_globalforphaseMap = "
	Print "Y2_globalforphaseMap = "

end

//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////                      /////////////////////////////////////////////////////
//****************************************************    Main Procedure    *****************************************************
//////////////////////////////////////////////////////                      /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
Function ButtonProc_PhaseMap(ctrlName) : ButtonControl
	String ctrlName
	Execute "PhaseMap()"
end
Proc PhaseMap(name1,name2,size1,x1,y1,x2,y2)
	String name1 = "gapsize2d"
	String name2 = "topo_I2"
	Variable size1
	variable x1 //= X1_globalforphaseMap
	variable y1 //= Y1_globalforphaseMap
	variable x2 //= X2_globalforphaseMap
	variable y2 //= Y2_globalforphaseMap
	Prompt name1,"name of the gap map"
	Prompt name2,"name of the topography"
	Prompt size1,"dimsize of the subwindow (must be even number, but I write a correction code inside, you do not need to care about the even odd here)"
	prompt x1,"x of FFT Point 1"
	prompt y1,"y of FFT Point 1"
	prompt x2,"x of FFT Point 2"
	prompt y2,"y of FFT Point 2"

	Print "FFT peak A is (" +num2str(x1)+","+num2str(y1)+")"
	Print "FFT peak B is (" +num2str(x2)+","+num2str(y2)+")"

	if(mod(size1,2) == 0)
	else
		size1+=1
	endif

	makechunkdataFFT(name1,name2,size1,x1,y1,x2,y2)
	Print "PhaseMap(\""+name1+"\",\""+name2+"\","+num2str(size1)+","+num2str(x1)+","+num2str(y1)+","+num2str(x2)+","+num2str(y2)+")"
end


Function makechunkdataFFT(name1,name2,size1,x1,y1,x2,y2)
	String name1
	String name2
	Variable size1
	variable x1
	variable y1
	variable x2
	variable y2

	Wave gapm=$name1
	Wave topm=$name2

	variable Fulldimsizex = dimsize(gapm,0)
	variable Fulldimsizey = dimsize(gapm,1)
	variable i,j

	variable destdimx, destdimy

	destdimx=Fulldimsizex-size1+1
	destdimy=Fulldimsizey-size1+1

	make/o/N=(destdimx,destdimy) a_gapp_point //Map of phase of A FFT peak of gap map

	//Those are full range which is not correct // because window data has width
	//setscale/I x, dimoffset(gapm,0), (dimoffset(gapm,0)+(dimsize(gapm,0)-1)*dimdelta(gapm,0)),"",a_gapp_point
	//setscale/I y, dimoffset(gapm,1), (dimoffset(gapm,1)+(dimsize(gapm,1)-1)*dimdelta(gapm,1)),"",a_gapp_point

	//Corrected scale is
	setscale/I x, dimoffset(gapm,0)+dimdelta(gapm,0)*(-1+size1/2) , (dimoffset(gapm,0)+(dimsize(gapm,0)-size1/2)*dimdelta(gapm,0)),"",a_gapp_point
	setscale/I y, dimoffset(gapm,1)+dimdelta(gapm,1)*(-1+size1/2) , (dimoffset(gapm,1)+(dimsize(gapm,1)-size1/2)*dimdelta(gapm,1)),"",a_gapp_point

	duplicate/o a_gapp_point b_gapp_point //Map of phase of B FFT peak of gap map
	duplicate/o a_gapp_point a_topp_point //Map of phase of A FFT peak of Topography
	duplicate/o a_gapp_point b_topp_point //Map of phase of B FFT peak of Topography

	duplicate/o a_gapp_point a_gapmtop   //Map of phase difference between gap map and topograph at A FFT peak ///[a_gapp_point-a_topp_point]
	duplicate/o a_gapp_point b_gapmtop	 //Map of phase difference between gap map and topograph at B FFT peak ///[b_gapp_point-b_topp_point]

	duplicate/o a_gapp_point amb		 //Map of A B imbalance  ///[abs(a_gapmtop)-abs(b_gapmtop)]


	i=0
	do /// Sweep along y direction
		j=0
		do /// sweep along x direction
			duplicate/o/R=[j,j+size1-1][i,i+size1-1] gapm gapmw
			duplicate/o/R=[j,j+size1-1][i,i+size1-1] topm topmw

			//Do Phase FFT on the subgap data
			FFT/OUT=5/DEST=subgap_pFFT  gapmw
			twoDinterpolatexyfd("subgap_pFFT",dimsize(subgap_pFFT,0)*20,dimsize(subgap_pFFT,1)*20)
			string subgapFFT = "subgap_pFFT_INTER"
			wave subgapFFTw = $subgapFFT
			variable pg1,qg1,pg2,qg2
			pg1=Round((x1-dimoffset(subgapFFTw,0))/dimdelta(subgapFFTw,0))
			qg1=Round((y1-dimoffset(subgapFFTw,1))/dimdelta(subgapFFTw,1))
			pg2=Round((x2-dimoffset(subgapFFTw,0))/dimdelta(subgapFFTw,0))
			qg2=Round((y2-dimoffset(subgapFFTw,1))/dimdelta(subgapFFTw,1))

			a_gapp_point[j][i]=subgapFFTw[pg1][qg1]*180/pi
			b_gapp_point[j][i]=subgapFFTw[pg2][qg2]*180/pi

			//Do Phase FFT on the subgap data
			FFT/OUT=5/DEST=subtop_pFFT  topmw
			twoDinterpolatexyfd("subtop_pFFT",dimsize(subtop_pFFT,0)*20,dimsize(subtop_pFFT,1)*20)
			string subtopFFT = "subtop_pFFT_INTER"
			wave subtopFFTw = $subtopFFT

			a_topp_point[j][i]=subtopFFTw[pg1][qg1]*180/pi
			b_topp_point[j][i]=subtopFFTw[pg2][qg2]*180/pi

			//Calculate the phase difference (comapre the two image) at A and B
			a_gapmtop[j][i] = a_gapp_point[j][i] - a_topp_point[j][i]
			b_gapmtop[j][i] = b_gapp_point[j][i] - b_topp_point[j][i]


			//Calculate the nematicity
			variable difphaseA
			if (abs(a_gapmtop[j][i]) < 180)
				difphaseA = abs(a_gapmtop[j][i])
			else
				difphaseA = 360 - abs(a_gapmtop[j][i])
			endif

			a_gapmtop[j][i] = difphaseA

			variable difphaseB
			if (abs(b_gapmtop[j][i]) < 180)
				difphaseB = abs(b_gapmtop[j][i])
			else
				difphaseB = 360 - abs(b_gapmtop[j][i])
			endif

			b_gapmtop[j][i] = difphaseB


			amb[j][i] = difphaseA - difphaseB

			j+=1
		while(j<(Fulldimsizex-size1+1))
		i+=1
	while (i<(Fulldimsizey-size1+1))
	display;appendimage a_gapp_point
	ModifyImage a_gapp_point ctab= {*,*,RedWhiteBlue256,0}
	modifygraph width=300,height=300
	modifygraph width=0,height=0
	//ModifyGraph width={Plan,1,bottom,left}
	ModifyGraph margin(right)=90
	ColorScale/C/N=text0/F=0/A=RB/X=-30.00/Y=10.00 frame=0.00,image=a_gapp_point;DelayUpdate;ColorScale/C/N=text0 "\\Z16  \\F'Symbol'φ\\B\\Z08\\F'Symbol'∆ \\Z16\\M\\Z16 (π , π)\\F'arial'\\Z10   [along X direction]"





	display;appendimage b_gapp_point
	ModifyImage b_gapp_point ctab= {*,*,RedWhiteBlue256,0}
	modifygraph width=300,height=300
	modifygraph width=0,height=0
	//ModifyGraph width={Plan,1,bottom,left}
	ModifyGraph margin(right)=90
	ColorScale/C/N=text0/F=0/A=RB/X=-30.00/Y=10.00 frame=0.00,image=b_gapp_point;DelayUpdate;ColorScale/C/N=text0 "\\Z16  \\F'Symbol'φ\\B\\Z08\\F'Symbol'∆ \\Z16\\M\\Z16 (π , -π)\\F'arial'\\Z10   [along Y direction]"




	display;appendimage a_topp_point
	ModifyImage a_topp_point ctab= {*,*,RedWhiteBlue256,0}
	modifygraph width=300,height=300
	modifygraph width=0,height=0
	//ModifyGraph width={Plan,1,bottom,left}
	ModifyGraph margin(right)=90
	ColorScale/C/N=text0/F=0/A=RB/X=-30.00/Y=10.00 frame=0.00,image=a_topp_point;DelayUpdate;ColorScale/C/N=text0 "\\Z16  \\F'Symbol'φ\\B\\Z08T \\Z16\\M\\Z16 (π , π)\\F'arial'\\Z10   [along X direction]"



	display;appendimage b_topp_point
	ModifyImage b_topp_point ctab= {*,*,RedWhiteBlue256,0}
	modifygraph width=300,height=300
	modifygraph width=0,height=0
	//ModifyGraph width={Plan,1,bottom,left}
	ModifyGraph margin(right)=90
	ColorScale/C/N=text0/F=0/A=RB/X=-30.00/Y=10.00 frame=0.00,image=b_topp_point;DelayUpdate;ColorScale/C/N=text0 "\\Z16  \\F'Symbol'φ\\B\\Z08T \\Z16\\M\\Z16 (π , -π)\\F'arial'\\Z10   [along Y direction]"


	display;appendimage a_gapmtop
	ModifyImage a_gapmtop ctab= {*,*,RedWhiteBlue256,0}
	modifygraph width=300,height=300
	modifygraph width=0,height=0
	//ModifyGraph width={Plan,1,bottom,left}
	ModifyGraph margin(right)=90
	ColorScale/C/N=text0/F=0/A=RB/X=-30.00/Y=10.00 frame=0.00,image=a_gapmtop;DelayUpdate;ColorScale/C/N=text0 "\\Z16  \\F'Symbol'δφ\\Z16\\M\\Z16 (π , π)\\F'arial'\\Z10   [along X direction]"

	display;appendimage b_gapmtop
	ModifyImage b_gapmtop ctab= {*,*,RedWhiteBlue256,0}
	modifygraph width=300,height=300
	modifygraph width=0,height=0
	//ModifyGraph width={Plan,1,bottom,left}
	ModifyGraph margin(right)=90
	ColorScale/C/N=text0/F=0/A=RB/X=-30.00/Y=10.00 frame=0.00,image=b_gapmtop;DelayUpdate;ColorScale/C/N=text0 "\\Z16  \\F'Symbol'δφ\\Z16\\M\\Z16 (π , -π)\\F'arial'\\Z10   [along Y direction]"

	display;appendimage amb
	ModifyImage amb ctab= {*,*,RedWhiteBlue256,0}
	modifygraph width=300,height=300
	modifygraph width=0,height=0
	//ModifyGraph width={Plan,1,bottom,left}
	ModifyGraph margin(right)=90
	ColorScale/C/N=text0/F=0/A=RB/X=-30.00/Y=10.00 frame=0.00,image=amb;DelayUpdate;ColorScale/C/N=text0 "\\Z16  \\F'Symbol'δφ\\Z16\\M\\Z16 (π , π) - \\F'Symbol'δφ\\Z16\\M\\Z16 (π , -π)"
	SetDrawEnv fstyle= 1, textxjust= 2;DelayUpdate;DrawText 1.096666666666667,0.9533333333333338,"Y"
	SetDrawEnv fstyle= 1, textxjust= 2;DelayUpdate;DrawText 1.096666666666667,0.1500000000000108,"X"

End

//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
/////////////////////////////////////////////////////////////////
//the unplot interpolation function called in the main procedure
/////////////////////////////////////////////////////////////////
Function twoDinterpolatexyfd(name,xpoint,ypoint)
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
end

//** This procedure used to fix the stripe artifact introduced by the movewindow
Function ButtonProc_PhaseMapcorrectbd(ctrlName) : ButtonControl
	String ctrlName
	Execute "correctboundPhMapc()"
end
Proc correctboundPhMapc(nn,ref,block)
	string nn = "a_gapmtop"
	string ref = "a_topp_point"
	variable block = 3
	prompt nn,"Source wave"
	prompt ref,"Jump ref wave"
	prompt block,"width for correction"
	correctboundPhMap($nn,$ref,block)
end

Function correctboundPhMap(nn,ref,block)
	wave nn
	wave ref
	variable block
	findjumpphMap(nn)

	string refwaveP = "P_"+nameofWave(ref)
	string refwaveQ = "Q_"+nameofWave(ref)
	wave refwavePw = $refwaveP
	wave refwaveQw = $refwaveQ
	string nnnew = "New_"+nameofwave(nn)
	duplicate/o nn $nnnew
	wave nnneww = $nnnew

	variable i,j,k
	i=0
	do
		j=0
		do
			nnneww[refwavePw[i]+j][refwaveQw[i]] = (nn[refwavePw[i]+j+block][refwaveQw[i]]+nn[refwavePw[i]+j-block][refwaveQw[i]])/2
			nnneww[refwavePw[i]][refwaveQw[i]+j] = (nn[refwavePw[i]][refwaveQw[i]+j+block]+nn[refwavePw[i]][refwaveQw[i]+j-block])/2

			//nnneww[refwavePw[i]+j][refwaveQw[i]] = (nn[refwavePw[i]+j+block][refwaveQw[i]+j+block]+nn[refwavePw[i]+j-block][refwaveQw[i]+j-block])/2
			//nnneww[refwavePw[i]][refwaveQw[i]+j] = (nn[refwavePw[i]+j+block][refwaveQw[i]+j+block]+nn[refwavePw[i]+j-block][refwaveQw[i]+j-block])/2



			j+=1
		while (j<block)
		i+=1
	while (i<dimsize(refwavePw,0))
	di(nnneww)
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

Function findjumpphMap(nn)
	wave nn
	string pnn = "P_"+nameofwave(nn)
	string qnn = "Q_"+nameofwave(nn)

	make/N=0/O $pnn
	wave pnnw= $pnn
	make/N=0/O $qnn
	wave qnnw = $qnn

	variable i,j
	i=0
	do
		j=1
		do
			if (abs(nn[i][j]-nn[i][j-1]) > 90)
				insertPoints dimsize(pnnw,0),1, pnnw
				insertPoints dimsize(qnnw,0),1, qnnw
				pnnw[dimsize(pnnw,0)-1] = i
				qnnw[dimsize(qnnw,0)-1] = j
			endif

			j+=1
		while (j<dimsize(nn,1))
		i+=1
	while (i<dimsize(nn,0))
	//edit pnnw qnnw
end