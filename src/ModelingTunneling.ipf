#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
//********************************************************************************************************************************************************
//********************************************************************************************************************************************************
//********************************************************************************************************************************************************
//********************************************************************************************************************************************************
//********************************************************************************************************************************************************
//********************************************************************************************************************************************************
//////////////////////////////////////////////////////////////////////////////////
//Individual P(E) theory calculation
//consider SIS junction, tip interact with enviroment
//enviroment impedance is a lamda/4 monopole antena
//Ref: Ast, C., Jäck, B., Senkpiel, J. et al. Sensing the quantum limit in scanning tunnelling spectroscopy. Nat Commun 7, 13009 (2016). https://doi.org/10.1038/ncomms13009
//Ref: Appl. Phys. Lett. 106, 013109 (2015) https://doi.org/10.1063/1.4905322
//Condition: EC > EJ
//Condition: EC > ET
//////////////////////////////////////////////////////////////////////////////////
//********************************************************************************************************************************************************
//********************************************************************************************************************************************************
//********************************************************************************************************************************************************
//********************************************************************************************************************************************************
//********************************************************************************************************************************************************
//********************************************************************************************************************************************************
Function ButtonProc_CalculateP0Ec(ctrlName) : ButtonControl
	String ctrlName
	Execute "CalculateP0Ec()"
end
Proc CalculateP0Ec()
   	// === Tip Antenna parameters ===
    	Variable/G omega0_uV_pe = 80//233           // [µeV] Principle resonance of tip antenna
    	Variable/G alpha_pe = 0.6//0.7
    	variable/G switch_antena_pe = 1 		   // 1: with antena; 0: without antena

    // === Tip Junction parameters ===
    	Variable/G CJ_pe = 3.5// [fF]
    	Variable/G Ic_pe = 1.6// [nA], critical current
    	Variable/G Renv_pe = 30//31             // Vaccum impedance 376.73 [Ohm]

    // === Enviroment Temperature  ===
    	Variable/G T_pe = 0.065//0.065//1.5                 // [K]

    // === Energy calculation parameters  ===
    	Variable/G Emax_uV_pe = 2000             // [µeV], the energy range to calculate [-Emax_uV, +Emax_uV]
    										//Note that, if the EC [= (2e)^2/2CJ] is too large, the Emax_uV should be increase to avoid unphysical oscillation
    	Variable/G NE_pe = 1000                  // Energy points

    // === frquency parameters (integrated out)  ===
    	Variable/G NW_pe = 500//              // Frequency points
    	Variable/G Coff_freq_pe = 3            // Paramter determine the integration upper limit
    	Variable/G nMax_pe = 300			// Maximum eignenumber of vn (sum n from 0 to nMax)

    	variable/G enforceornot_p0_pe = 0


    // === Criteria for self-consistent calculation
    	Variable/G MaxIter_pe = 500//500
    	Variable/G tol_pe = 1e-3

     	variable/G SISon_pe = 1


     	variable/G DCB_n_pe = 50
     	variable/G DCB_ornot_pe = 0

    	CalculateP0E_auto()


    Display/N=PEthoerycalculation;modifygraph width=1100,height=900

	Display/HOST=#/W=(0.05,0.05,0.35,0.25);appendtograph p0_E;
	ModifyGraph log(left)=1,mirror=2,fSize=12;
	Label left "\\$WMTEX$ P_0 (E) \\ \\ \\rm{(eV^{-1})} \\$/WMTEX$ ";DelayUpdate
	Label bottom "Energy (eV)"


	setActiveSubwindow ##;
	Display/HOST=#/W=(0.35,0.05,0.65,0.25);appendtograph pn_E p0_E;appendtograph/R Pn_E
	ModifyGraph mirror(bottom)=2,fSize=12;
	Label left "\\$WMTEX$ P_0 (E), P_N (E)  \\ \\ \\rm{(eV^{-1})} \\$/WMTEX$ ";DelayUpdate
	Label bottom "Energy (eV)"
	ModifyGraph rgb(PN_E)=(0,0,0);ModifyGraph lstyle(PN_E#1)=1,rgb(PN_E#1)=(29524,1,58982);ModifyGraph axRGB(right)=(29524,1,58982),tlblRGB(right)=(29524,1,58982),alblRGB(right)=(29524,1,58982)
	Legend/C/N=text0/J/F=0/B=1/X=0.00/Y=0.00 "\\Z12\\s(P0_E) \\$WMTEX$ P_0\\ (E) \\$/WMTEX$\r\\s(PN_E) \\$WMTEX$ P_N\\ (E) \\$/WMTEX$\r\\s(PN_E#1) \\$WMTEX$ P_N\\ (E) \\$/WMTEX$"

	setActiveSubwindow ##;
	Display/HOST=#/W=(0.65,0.05,0.95,0.25);appendtograph p0_E_conv;
	ModifyGraph log(left)=1,mirror=2,fSize=12;DelayUpdate
	Label left "\\$WMTEX$ P(E) \\ \\ \\rm{(eV^{-1})} \\$/WMTEX$ ";DelayUpdate
	Label bottom "Energy (eV)"
	ModifyGraph lsize=2, rgb=(0,0,0)

	setActiveSubwindow ##;
	Display/HOST=#/W=(0.05,0.3,0.5,0.75);appendtograph IV_pe;
	ModifyGraph mirror=2,fSize=12;
	Label left "\\$WMTEX$ I \\$/WMTEX$ (A) ";
	Label bottom "Energy (eV)"
	ModifyGraph lsize=2,rgb=(0,0,65535)


	setActiveSubwindow ##;
	Display/HOST=#/W=(0.5,0.3,0.95,0.75);appendtograph dIdV_pe;
	ModifyGraph mirror=2,fSize=12;
	Label left "\\$WMTEX$ dI/dV \\$/WMTEX$ (S) ";
	Label bottom "Energy (eV)"
	ModifyGraph lsize=2,rgb=(0,0,65535)


	setActiveSubwindow ##;
	make/N=1/o dIdV_dcb=nan
	Display/HOST=#/W=(0.05,0.8,0.95,0.98);appendtograph dIdV_dcb;
	ModifyGraph mirror=2,fSize=12;
	Label left "\\$WMTEX$ dI/dV \\$/WMTEX$ (S) ";
	Label bottom "Energy (eV)"


	setActiveSubwindow ##;
	TextBox/C/N=text0/F=0/B=1/A=MC/X=3.00/Y=22.00 "\\Z20S-I-S junction spectrum"
	TextBox/C/N=text1/F=0/B=1/A=MT/X=2.50/Y=0.50 "\\Z20P(E) function calculation"
	TextBox/C/N=text2/F=0/B=1/A=MB/X=2.50/Y=22.0 "\\Z20N-I-N junction spectrum"


	Button turnoffls3d title="BACK",size={45,12},valueColor=(0,0,0),fColor=(1,65535,33232),proc=ButtonProc_lsturnoff3d,pos={1050,5}
	Button dcb proc=ButtonProc_PE_dcb,pos={901,710},size={120,14},title="Caculate DCB"

	Button b1 proc=ButtonProc_PE_saveantenamode,title="Examaple \r #1",size={70,60},pos={1026,58}
	Button b2 proc=ButtonProc_PE_save2,title="Examaple \r #2",size={70,60},pos={1026,120}
	Button b3 proc=ButtonProc_PE_save3,title="Examaple \r #3",size={70,60},pos={1026,182}
	Button b4 proc=ButtonProc_PE_save4,title="Examaple \r #4",size={70,60},pos={1026,182+62}

	Button bdcbbatch proc=ButtonProc_PE_CalculateDCBc,title="Batch DCB",size={100,20},pos={918,822}
	Button bdcbbatch2 proc=ButtonProc_PE_dcbbatchexample,title="e.g.",size={40,20},pos={1025,822}

	SetDrawEnv xcoord= axrel,ycoord= axrel,fillbgc= (1,34817,52428),fillfgc= (1,34817,52428),fillpat= 3,linethick= 0.00;
	DrawRect 0.00181,-1.11111111111072e-05,0.14481818,0.059866;SetDrawEnv textrgb= (39321,1,1);DrawText 0.0334,0.01888,"λ/4-Tip Antenna"
	SetVariable setv3 value=switch_antena_pe,proc=SetVarProc_pe,limits={0,1,1},title="Antenna on?",size={85,14},pos={5,18}
	SetVariable setv1 value=omega0_uV_pe,proc=SetVarProc_pe,limits={10,inf,10},title="\\$WMTEX$ \omega_{0}^{\rm{Antenna}} \\$/WMTEX$ (ueV)",size={150,14},pos={5,37}
	SetVariable setv2 value=alpha_pe,proc=SetVarProc_pe,limits={0.01,inf,0.1},title="\\$WMTEX$ \alpha \\$/WMTEX$",size={65,14},pos={91,18}


	SetDrawEnv xcoord= axrel,ycoord= axrel,fillbgc= (65535,49151,49151),fillfgc= (65535,49151,49151),fillpat= 3,linethick= 0.00;
	DrawRect 0.149,0.0011,0.366636363636366,0.059866
	SetVariable setv4 value=CJ_pe,proc=SetVarProc_pe,limits={0.00000001,inf,1},title="\\$WMTEX$ C_J\\$/WMTEX$ (fF)",fSize=16,size={120,14},pos={166,2}
	SetVariable setv5 value=Ic_pe,proc=SetVarProc_pe,limits={0.000000000000001,inf,1},title="\\$WMTEX$ I_c \\$/WMTEX$ (nA)",fSize=16,pos={158,286},size={130,23}
	SetVariable setv6 value=Renv_pe,proc=SetVarProc_pe,limits={0.000001,inf,10},title="\\$WMTEX$ R(\omega = 0) \\$/WMTEX$ (Ω)",fSize=16,size={160,14},pos={166,30}
	SetVariable setv7 value=T_pe,proc=SetVarProc_pe,limits={0.0000001,inf,0.01},title="\\$WMTEX$ T \\$/WMTEX$ (K)",fSize=16,size={110,14},pos={291,2}


	SetDrawEnv xcoord= axrel,ycoord= axrel,fillbgc= (39321,39321,39321),fillfgc= (39321,39321,39321),fillpat= 3,linethick= 0.00;
	DrawRect 0.3672722,0.0277666666666667,0.664,0.0587548888888889;SetDrawEnv textrgb= (39321,1,1);SetDrawEnv fsize= 10;DrawText 0.462627272727272,0.041,"Simulated Data Parameters"
	SetVariable setv8 value=Emax_uV_pe,proc=SetVarProc_pe,limits={100,inf,100},title="Data range: \\$WMTEX$ ±E_{\rm{max}} \\$/WMTEX$ (ueV)",size={160,14},pos={420,37}
	SetVariable setv9 value=NE_pe,proc=SetVarProc_pe,limits={100,inf,100},title="Point Number: \\$WMTEX$ N(E) \\$/WMTEX$",pos={586,37},size={140,14}

	SetDrawEnv xcoord= axrel,ycoord= axrel,fillbgc= (19675,39321,1),fillfgc= (19675,39321,1),fillpat= 3,linethick= 0.00;
	DrawRect 0.694545,0.0011,0.843,0.059866;SetDrawEnv textrgb= (39321,1,1);DrawText 0.7299,0.01888,"Precision of \\$WMTEX$ P_0(E) \\$/WMTEX$"
	SetVariable setv10 value=NW_pe,proc=SetVarProc_pe,limits={100,inf,100},title="\\$WMTEX$ N(\omega) \\$/WMTEX$",pos={767,18},size={70,14}
	SetVariable setv11 value=Coff_freq_pe,proc=SetVarProc_pe,limits={1,inf,1},title="Integ. Range(\\$WMTEX$ n*E_{\rm{max}} \\$/WMTEX$) [ueV]",size={160,14},pos={767,37}
	SetVariable setv12 value=nMax_pe,proc=SetVarProc_pe,limits={100,inf,100},title="Matsu \\$WMTEX$ n_{\rm{max}} \\$/WMTEX$",pos={838,18},size={90,14}

	SetVariable setv13 value=enforceornot_p0_pe,proc=SetVarProc_pe,limits={0,1,1},title="Enforce detailed balance?",size={150,14},pos={206,172}

	SetDrawEnv xcoord= axrel,ycoord= axrel,fillbgc= (1,34817,52428),fillfgc= (1,34817,52428),fillpat= 3,linethick= 0.00;
	DrawRect 0.845454545454546,0.0011,0.947272727272727,0.059866;SetDrawEnv textrgb= (39321,1,1);DrawText 0.848181818,0.01888,"Converge Tolerance"
	SetVariable setv14 value=MaxIter_pe,limits={50,inf,10},title="Max. Inter",size={100,14},pos={940,18}
	variable/G tol_pe_exp = -3
	SetVariable setv15 value=tol_pe_exp,limits={-11,0,1},title="\\$WMTEX$ e^{\rm{tolerance}} \\$/WMTEX$",size={100,14},pos={940,37}

	SetVariable setv16 value=SISon_pe,limits={0,1,1},title="Calculate SIS?",size={130,14},fSize=12,pos={890,260}

	SetVariable setv17 value=DCB_n_pe,limits={10,inf,10},title="\\$WMTEX$ N \\$/WMTEX$",pos={280,710},size={80,14},fSize=12
	SetVariable setv18 value=DCB_ornot_pe,limits={0,1,1},title="Calculate DCB?",size={130,14},fSize=12, pos={130,710}

	tilewindows/WINS=winname(0,1)/R/w=(3,0,83,85)/A=(1,1)
end






Function SetVarProc_peic(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	 // === Tip Antenna parameters ===
    	Variable/G omega0_uV_pe
    	Variable/G alpha_pe
    	variable/G switch_antena_pe  //******************
    // === Tip Junction parameters ===
    	Variable/G CJ_pe
    	Variable/G Ic_pe
    	Variable/G Renv_pe
        // === Enviroment Temperature  ===
    	Variable/G T_pe
    // === Energy calculation parameters  ===
    	Variable/G Emax_uV_pe
    	Variable/G NE_pe
    // === frquency parameters (integrated out)  ===
    	Variable/G NW_pe
    	Variable/G Coff_freq_pe
    	Variable/G nMax_pe
    	variable/G enforceornot_p0_pe   //******************

    	variable/G SISon_pe //******************
    // === Criteria for self-consistent calculation
    	variable/G tol_pe_exp
    	Variable/G MaxIter_pe
    	Variable/G tol_pe = 1*10^(tol_pe_exp)

    	variable/G DCB_ornot_pe  //******************
    	variable/G DCB_n_pe
    	variable/G SISon

    	if (DCB_ornot_pe == 1)
    		wave p0_E_conv = $"p0_E_conv"
			SimulateDCB_IV(p0_E_conv, 3000, T_pe, 10^(-6)*Emax_uV_pe/(2*1.5), DCB_n_pe)
    	endif

	    // === Constants (all in SI base or eV-compatible units) ===
    	Variable hbar = 6.582e-16          // [eV·s]
    	Variable e = 1.602e-19             // [C]
    	Variable kB = 8.617e-5             // [eV/K]
    	Variable RQ = 6.45e3               // [Ohm], quantum resistance

	variable Ic  = Ic_pe
	// === Compute I(V) from P(E) theory: I(V) = (π ℏ Ic² / 4e) [P(2eV) - P(-2eV)] ===
    if (SISon == 1)
    	Make/D/O/N=(dimsize(P0_E_conv,0)) IV_pe, Bias
    	Variable coef = pi * hbar * Ic^2 / (4 * e)  // pre-factor [eV * A]
    	//print coef
		variable valuep,locatem,voltage,current
		variable ii = 0
		do
			valuep = dimoffset(p0_E_conv,0)+ii*dimdelta(p0_E_conv,0) //eV
			//-valuep = dimoffset(p0_E_conv,0)+locatem*dimdelta(p0_E_conv,0)
			locatem = (-valuep - dimoffset(p0_E_conv,0))/dimdelta(p0_E_conv,0)
			voltage = valuep/2 //V

			current = coef*(p0_E_conv[ii]-p0_E_conv[locatem])

			IV_pe[ii] = current
			Bias[ii] = voltage
			ii+=1
		while (ii<dimsize(P0_E_conv,0))
		setscale/p x, Bias[0],Bias[1]-Bias[0],"",IV_pe
		duplicate/o IV_pe didv_pe
		differentiate didv_pe
   endif
end


Function SetVarProc_pe(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	 // === Tip Antenna parameters ===
    	Variable/G omega0_uV_pe
    	Variable/G alpha_pe
    	variable/G switch_antena_pe  //******************
    // === Tip Junction parameters ===
    	Variable/G CJ_pe
    	Variable/G Ic_pe
    	Variable/G Renv_pe
        // === Enviroment Temperature  ===
    	Variable/G T_pe
    // === Energy calculation parameters  ===
    	Variable/G Emax_uV_pe
    	Variable/G NE_pe
    // === frquency parameters (integrated out)  ===
    	Variable/G NW_pe
    	Variable/G Coff_freq_pe
    	Variable/G nMax_pe
    	variable/G enforceornot_p0_pe   //******************

    	variable/G SISon_pe //******************
    // === Criteria for self-consistent calculation
    	variable/G tol_pe_exp
    	Variable/G MaxIter_pe
    	Variable/G tol_pe = 1*10^(tol_pe_exp)

    	variable/G DCB_ornot_pe  //******************
    	variable/G DCB_n_pe

    	if (DCB_ornot_pe == 1)
    		wave p0_E_conv = $"p0_E_conv"
			SimulateDCB_IV(p0_E_conv, 3000, T_pe, 10^(-6)*Emax_uV_pe/(2*1.5), DCB_n_pe)
    	endif

		CalculateP0E_auto()
end


Function CalculateP0E_auto()
   	// === Tip Antenna parameters ===
    	Variable/G omega0_uV_pe
    	Variable/G alpha_pe
    	variable/G switch_antena_pe
    // === Tip Junction parameters ===
    	Variable/G CJ_pe
    	Variable/G Ic_pe
    	Variable/G Renv_pe
        // === Enviroment Temperature  ===
    	Variable/G T_pe
    // === Energy calculation parameters  ===
    	Variable/G Emax_uV_pe
    	Variable/G NE_pe
    // === frquency parameters (integrated out)  ===
    	Variable/G NW_pe
    	Variable/G Coff_freq_pe
    	Variable/G nMax_pe
    	variable/G enforceornot_p0_pe
    	variable/G SISon_pe
    // === Criteria for self-consistent calculation
    	Variable/G MaxIter_pe
    	Variable/G tol_pe

    	variable/G DCB_ornot_pe
    	variable/G DCB_n_pe


	///////////////////////////////////////////////////////////////////////////////////////

     // === Tip Antenna parameters ===
    	Variable omega0_uV = omega0_uV_pe//233           // [µeV] Principle resonance of tip antenna
    	Variable alpha = alpha_pe//0.7
    	variable switch_antena = switch_antena_pe 		   // 1: with antena; 0: without antena

    // === Tip Junction parameters ===
    	Variable CJ = CJ_pe*10^(-15)// [F]
    	Variable Ic = Ic_pe*10^(-9)// [A], critical current
    	Variable Renv = Renv_pe// [Ohm]

    // === Enviroment Temperature  ===
    	Variable T = T_pe // [K]

    // === Energy calculation parameters  ===
    	Variable Emax_uV = Emax_uV_pe             // [µeV], the energy range to calculate [-Emax_uV, +Emax_uV]
    										//Note that, if the EC [= (2e)^2/2CJ] is too large, the Emax_uV should be increase to avoid unphysical oscillation
    	Variable NE = NE_pe                  // Energy points

    // === frquency parameters (integrated out)  ===
    	Variable NW = NW_pe//3000//1500                  // Frequency points
    	Variable Coff_freq = Coff_freq_pe            // Paramter determine the integration upper limit
    	Variable nMax = nMax_pe					// Maximum eignenumber of vn (sum n from 0 to nMax)

    	variable enforceornot_p0 = enforceornot_p0_pe      // 1 means enforce P0 with the exponential relationship

    // === Criteria for self-consistent calculation
    	Variable MaxIter = MaxIter_pe//500
    	Variable tol = tol_pe


		variable SISon = SISon_pe
    // === Constants (all in SI base or eV-compatible units) ===
    	Variable hbar = 6.582e-16          // [eV·s]
    	Variable e = 1.602e-19             // [C]
    	Variable kB = 8.617e-5             // [eV/K]
    	Variable RQ = 6.45e3               // [Ohm], quantum resistance

	//------------------------------------------------------------------------------------------------------
	//------------------------------------------------------------------------------------------------------
	//------------------------------------------------------------------------------------------------------
    // === Unit conversion ===
    	Variable omega0_eV = omega0_uV * 1e-6
    	Variable Emax = Emax_uV * 1e-6     // [eV]
    	Variable dE = 2*Emax/(NE-1)

    // === Grids ===
    	Make/D/O/N=(NE) Egrid = -Emax + p*dE
    	Make/D/O/N=(NE) P0_old, P0_new, I_E, PN_E
		setscale/I x, -Emax , Emax ,"",P0_old, P0_new, I_E, PN_E, Egrid

    	Variable betaT = 1 / (kB*T)        // [1/eV]
    	//print betaT

    	//Variable dOmega = omega0_eV / (hbar * NW)
    	//Make/D/O/N=(NW) omega = Coff_freq*p*dOmega // the paramter Coff_freq set the integrate omega range to be Coff_freq times of omega0_uV which is the principle resonance of the antenna
    	//Variable dOmega = 2 * Coff_freq * omega0_eV / (hbar * (NW - 1))     // [1/s] step size for symmetric range
    	Variable dOmega = 2 * Coff_freq * Emax / (hbar * (NW - 1))     // [1/s] step size for symmetric range

		Make/D/O/N=(NW) omega
		//omega = -Coff_freq * omega0_eV / hbar + p * dOmega
    	omega = -Coff_freq * Emax / hbar + p * dOmega
    	Make/D/O/N=(NW) Z_re, Z_im, ReZT, ImZT, k_w, kappa_w

    // === Compute Z_env(omega) ===
    	Variable omega_ratio
    	Variable i
    	for(i=0; i<NW; i+=1)
        	omega_ratio = pi * omega[i] / (2 * omega0_eV / hbar)
        	Complex num = 1 + switch_antena*cmplx(0, 1/alpha) * tan(omega_ratio)
        	Complex den = 1 + switch_antena*cmplx(0, alpha) * tan(omega_ratio)
        	Complex Z = Renv * (num / den)
        	Z_re[i] = real(Z)
        	Z_im[i] = imag(Z)
    	endfor

    // === Z_T(omega) ===
    	for(i=0; i<NW; i+=1)
        	Complex Zenv = cmplx(Z_re[i], Z_im[i])
        	Complex ZT = 1 / (cmplx(0, omega[i] * CJ) + 1 / Zenv)
        	ReZT[i] = real(ZT)
        	ImZT[i] = imag(ZT)
    	endfor

	// === Compute I_E ===
    	Variable ZT0_real = ReZT[0]
    	Variable D = pi * ZT0_real / (betaT * RQ)

    	I_E = (1/pi) * D / (D^2 + Egrid^2)
    	P0_old = I_E

    // === Compute κ(ω) ===
    	k_w = (ReZT / RQ) / (1 - exp(-hbar * omega * betaT)) - (ZT0_real / RQ) / (betaT * hbar * omega)

    // === Compute Kappa(ω) ===
    	Variable n, j
    	Make/D/O/N=(nMax) ZT_Matsu_Re
    	for(n = 1; n <= nMax; n += 1)
        	Variable vn = 2 * pi * n / (betaT * hbar)
        	Complex omega_vn = cmplx(0, -vn)
        	Complex arg = pi * omega_vn / (2 * omega0_eV / hbar)
        	Complex tanZ = tan(arg)
        	Complex numerator = 1 + switch_antena*cmplx(0, 1/alpha) * tanZ
        	Complex denominator = 1 + switch_antena*cmplx(0, alpha) * tanZ
        	Complex Z_env = Renv * (numerator / denominator)

        	// check Z_env stability
    		if(numtype(Z_env) != 0 || abs(Z_env) > 1e6)
        		Z_env = cmplx(Renv, 0)
    		endif


        	Complex ZT_matsu = 1 / (vn * CJ + 1 / Z_env)

        	if(numtype(ZT_matsu) == 0)
        		ZT_Matsu_Re[n-1] = real(ZT_matsu)
    		else
        		ZT_Matsu_Re[n-1] = 0 // fallback: 0 contribution
    		endif
    	endfor

    	for(j = 0; j < NW; j += 1)
        	Variable w = omega[j]
       		Variable A, B

    		// === Correction：to avoid divded by 0 in A ===
    		if(abs(1 - exp(-hbar * w * betaT)) > 1e-12)
        		A = (ImZT[j] / RQ) / (1 - exp(-hbar * w * betaT))
    		else
        		A = 0
        		//print j,w
    		endif

        	Variable sumkapp = 0
        	for(n = 1; n <= nMax; n += 1)
            	vn = 2 * pi * n / (betaT * hbar)
            	sumkapp += (vn / (vn^2 + w^2)) * (ZT_Matsu_Re[n-1] / RQ)
        	endfor
        	B = (2 / (betaT * hbar)) * sumkapp
        	//print "A", A
        	//print "B", B
        	kappa_w[j] = A - B
    	endfor

    // === Self-consistence calculation ===
    	Variable iter = 0, error
    	Make/D/O/N=(NE) deltaP
    	do

        	for(i = 0; i < NE; i += 1)
            	Variable Ei_pe = Egrid[i]
            	Variable denom = D^2 + Ei_pe^2 //+ 1e-20
            	Variable sumK = 0

            	for(j = 0; j < NW; j += 1)
                	w = omega[j]
                	Variable E_shift = Ei_pe - hbar * w
                	if(E_shift >= -Emax && E_shift <= Emax)
                    	Variable idx = (E_shift + Emax) / dE // the point number of the energy E_shift in waves
                    	Variable iL = floor(idx)
                    	Variable iH = iL + 1
                    	if(iL >= 0 && iH < NE)
                        	Variable f = idx - iL
                        	Variable kVal = k_w[j]
                        	Variable kapVal = kappa_w[j]
                        	Variable KK = (hbar * Ei_pe / denom) * kVal + (hbar * D / denom) * kapVal
                        	Variable interpP = (1 - f) * P0_old[iL] + f * P0_old[iH]
							//Print "kapVal = ", kapVal
                        	if(numtype(KK)==0 && numtype(interpP)==0)
                        	//if(numtype(KK)!=2)
                            	sumK += KK * interpP * dOmega
                            	//print sumK
                        	endif
                    	endif
                	endif
            	endfor

            	multithread P0_new[i] = I_E[i] + sumK
        	endfor

        	//deltaP = abs(P0_new - P0_old)
        	//WaveStats/Q deltaP
        	//error = V_max
        	multithread deltaP = (P0_new - P0_old)^2
			error = sqrt(sum(deltaP)/NE)
        	P0_old = P0_new
        	//Print "P0(E) computed in", iter, "iterations.  Error =", error


        	iter += 1
    	while(error > tol && iter < MaxIter)


	// === Enforce detailed balance: P0(-E) = exp(-E / kB T) * P0(E)
	if (enforceornot_p0 == 1)
		Variable EiEnforce, Em, idx1, iL1, iH1, f1, Pm, corrected

		for(i = 0; i < NE; i += 1)
    		EiEnforce = Egrid[i]
    		if(EiEnforce < 0)
        		Em = -EiEnforce
        		idx1 = (Em + Emax)/dE
        		iL1 = floor(idx1)
        		iH1 = iL1 + 1

        		if(iL1 >= 0 && iH1 < NE)
            		f1 = idx1 - iL1
            		Pm = (1 - f1) * P0_new[iL1] + f1 * P0_new[iH1]
            		corrected = Pm * exp(EiEnforce / (kB * T))
            		P0_new[i] = corrected

        		elseif(iL1 == NE - 1)  // edge case: exact hit at last point
            		Pm = P0_new[iL1]
            		corrected = Pm * exp(EiEnforce / (kB * T))
            		P0_new[i] = corrected
        		endif
    		endif
		endfor
	endif

    // === Normalize P0(E) and output ===
    	Variable normvalue = areaXY(Egrid, P0_new)
    	P0_new /= normvalue
    	Duplicate/O Egrid, P0_E
    	P0_E = P0_new
    	//Print "P0(E) computed in", iter, "iterations. Final error =", error


    // === Gaussian PN(E) ===
    	Variable EC = ((2*e)^2) / (2 * CJ) / e // Convert to [eV]
    	Variable sigma2 = 4 * EC * kB * T
    	Variable normPN = 1 / sqrt(pi * sigma2)
    	for(i = 0; i < NE; i += 1)
        	Ei_pe = Egrid[i]
        	PN_E[i] = normPN * exp(-Ei_pe^2 / sigma2)
    	endfor
    	//PN_E /= areaXY(Egrid, PN_E)

    // === Convolve P0 * PN ===
    	Duplicate/O P0_E,P0_E_conv
		Convolve PN_E, P0_E_conv
		setscale/I x,-Emax*2,Emax*2,"",P0_E_conv
   		variable convnorm = sum(P0_E_conv,-Emax,Emax)*dimdelta(P0_E_conv,0)
   		P0_E_conv/=convnorm

   		CutWave_EcenteredRange(P0_E_conv)



    // === Compute I(V) from P(E) theory: I(V) = (π ℏ Ic² / 4e) [P(2eV) - P(-2eV)] ===
    if (SISon == 1)
    	Make/D/O/N=(dimsize(P0_E_conv,0)) IV_pe, Bias
    	Variable coef = pi * hbar * Ic^2 / (4 * e)  // pre-factor [eV * A]
    	//print coef
		variable valuep,locatem,voltage,current
		variable ii = 0
		do
			valuep = dimoffset(p0_E_conv,0)+ii*dimdelta(p0_E_conv,0) //eV
			//-valuep = dimoffset(p0_E_conv,0)+locatem*dimdelta(p0_E_conv,0)
			locatem = (-valuep - dimoffset(p0_E_conv,0))/dimdelta(p0_E_conv,0)
			voltage = valuep/2 //V

			current = coef*(p0_E_conv[ii]-p0_E_conv[locatem])

			IV_pe[ii] = current
			Bias[ii] = voltage
			ii+=1
		while (ii<dimsize(P0_E_conv,0))
		setscale/p x, Bias[0],Bias[1]-Bias[0],"",IV_pe
		duplicate/o IV_pe didv_pe
		differentiate didv_pe


	// ==
		if (DCB_ornot_pe == 1)
			wave p0_E_conv = $"p0_E_conv"
			SimulateDCB_IV(p0_E_conv, 3000, T_pe, 10^(-6)*Emax_uV_pe/(2*1.5), DCB_n_pe)

		endif

    // === Display ===
    //	display IV_pe
    //	Label bottom "\\Z16Sample Bias (V)"
    //	Label Left "\\Z16Current (A)"

    //	display didv_pe
    //	Label bottom "\\Z16Sample Bias (V)"
    //	Label Left "\\Z16dI/dV (S)"
   endif
   killwaves Bias, deltaP, Egrid, ImZT,I_E,kappa_w,k_w,omega,p0_new,p0_old,ReZT,ZT_Matsu_Re,Z_im,Z_re
    //----------------------------------------------------------------------------------------------------
End




Function ButtonProc_PE_saveantenamode(ctrlName) : ButtonControl
	String ctrlName


	// === Tip Antenna parameters ===
    	Variable/G omega0_uV_pe = 80//233           // [µeV] Principle resonance of tip antenna
    	Variable/G alpha_pe = 0.6//0.7
    	variable/G switch_antena_pe = 1 		   // 1: with antena; 0: without antena

    // === Tip Junction parameters ===
    	Variable/G CJ_pe = 3.5// [fF]
    	Variable/G Ic_pe = 1.6// [nA], critical current
    	Variable/G Renv_pe = 30//31             // Vaccum impedance 376.73 [Ohm]

    // === Enviroment Temperature  ===
    	Variable/G T_pe = 0.065//0.065//1.5                 // [K]

    // === Energy calculation parameters  ===
    	Variable/G Emax_uV_pe = 2000             // [µeV], the energy range to calculate [-Emax_uV, +Emax_uV]
    										//Note that, if the EC [= (2e)^2/2CJ] is too large, the Emax_uV should be increase to avoid unphysical oscillation
    	Variable/G NE_pe = 1000                  // Energy points

    // === frquency parameters (integrated out)  ===
    	Variable/G NW_pe = 3000//              // Frequency points
    	Variable/G Coff_freq_pe = 3            // Paramter determine the integration upper limit
    	Variable/G nMax_pe = 300			// Maximum eignenumber of vn (sum n from 0 to nMax)

    	variable/G enforceornot_p0_pe = 0


    // === Criteria for self-consistent calculation
    	Variable/G MaxIter_pe = 500//500
    	Variable/G tol_pe = 1e-3

     	variable/G SISon_pe = 1

     	CalculateP0E_auto()
end



Function ButtonProc_PE_DCB(ctrlName) : ButtonControl
	String ctrlName

		// === Tip Antenna parameters ===
    	Variable/G omega0_uV_pe //= 80//233           // [µeV] Principle resonance of tip antenna
    	Variable/G alpha_pe // = 0.6//0.7
    	variable/G switch_antena_pe //= 1 		   // 1: with antena; 0: without antena

    // === Tip Junction parameters ===
    	Variable/G CJ_pe //= 3.5// [fF]
    	Variable/G Ic_pe //= 1.6// [nA], critical current
    	Variable/G Renv_pe //= 30//31             // Vaccum impedance 376.73 [Ohm]

    // === Enviroment Temperature  ===
    	Variable/G T_pe //= 0.065//0.065//1.5                 // [K]

    // === Energy calculation parameters  ===
    	Variable/G Emax_uV_pe //= 2000             // [µeV], the energy range to calculate [-Emax_uV, +Emax_uV]
    										//Note that, if the EC [= (2e)^2/2CJ] is too large, the Emax_uV should be increase to avoid unphysical oscillation
    	Variable/G NE_pe //= 1000                  // Energy points

    // === frquency parameters (integrated out)  ===
    	Variable/G NW_pe //= 3000//              // Frequency points
    	Variable/G Coff_freq_pe //= 3            // Paramter determine the integration upper limit
    	Variable/G nMax_pe //= 300			// Maximum eignenumber of vn (sum n from 0 to nMax)

    	variable/G enforceornot_p0_pe //= 0


    // === Criteria for self-consistent calculation
    	Variable/G MaxIter_pe //= 500//500
    	Variable/G tol_pe //= 1e-3

     	variable/G SISon_pe //= 1

     	variable/G DCB_n_pe // =

		wave p0_E_conv = $"p0_E_conv"
		SimulateDCB_IV(p0_E_conv, 3000, T_pe, 10^(-6)*Emax_uV_pe/(2*1.5), DCB_n_pe)
end

Function ButtonProc_PE_save2(ctrlName) : ButtonControl
	String ctrlName
	// === Tip Antenna parameters ===
    	Variable/G omega0_uV_pe = 233           // [µeV] Principle resonance of tip antenna
    	Variable/G alpha_pe = 0.7
    	variable/G switch_antena_pe = 1 		   // 1: with antena; 0: without antena

    // === Tip Junction parameters ===
    	Variable/G CJ_pe = 3.5// [fF]
    	Variable/G Ic_pe = 1.6// [nA], critical current
    	Variable/G Renv_pe = 376.73//31             // Vaccum impedance 376.73 [Ohm]

    // === Enviroment Temperature  ===
    	Variable/G T_pe = 0.065//0.065//1.5                 // [K]

    // === Energy calculation parameters  ===
    	Variable/G Emax_uV_pe = 2000             // [µeV], the energy range to calculate [-Emax_uV, +Emax_uV]
    										//Note that, if the EC [= (2e)^2/2CJ] is too large, the Emax_uV should be increase to avoid unphysical oscillation
    	Variable/G NE_pe = 1000                  // Energy points

    // === frquency parameters (integrated out)  ===
    	Variable/G NW_pe = 1000//              // Frequency points
    	Variable/G Coff_freq_pe = 3            // Paramter determine the integration upper limit
    	Variable/G nMax_pe = 300			// Maximum eignenumber of vn (sum n from 0 to nMax)

    	variable/G enforceornot_p0_pe = 0


    // === Criteria for self-consistent calculation
    	Variable/G MaxIter_pe = 500//500
    	Variable/G tol_pe = 1e-3

     	variable/G SISon_pe = 1

     	CalculateP0E_auto()
end


Function ButtonProc_PE_save3(ctrlName) : ButtonControl
	String ctrlName
	// === Tip Antenna parameters ===
    	Variable/G omega0_uV_pe = 120           // [µeV] Principle resonance of tip antenna
    	Variable/G alpha_pe = 0.75
    	variable/G switch_antena_pe = 1 		   // 1: with antena; 0: without antena

    // === Tip Junction parameters ===
    	Variable/G CJ_pe = 7// [fF]
    	Variable/G Ic_pe = 0.66// [nA], critical current
    	Variable/G Renv_pe = 376.73//31             // Vaccum impedance 376.73 [Ohm]

    // === Enviroment Temperature  ===
    	Variable/G T_pe = 0.092//0.065//1.5                 // [K]

    // === Energy calculation parameters  ===
    	Variable/G Emax_uV_pe = 2000             // [µeV], the energy range to calculate [-Emax_uV, +Emax_uV]
    										//Note that, if the EC [= (2e)^2/2CJ] is too large, the Emax_uV should be increase to avoid unphysical oscillation
    	Variable/G NE_pe = 1000                  // Energy points

    // === frquency parameters (integrated out)  ===
    	Variable/G NW_pe = 1000//              // Frequency points
    	Variable/G Coff_freq_pe = 3            // Paramter determine the integration upper limit
    	Variable/G nMax_pe = 300			// Maximum eignenumber of vn (sum n from 0 to nMax)

    	variable/G enforceornot_p0_pe = 0


    // === Criteria for self-consistent calculation
    	Variable/G MaxIter_pe = 500//500
    	Variable/G tol_pe = 1e-3

     	variable/G SISon_pe = 1

     	CalculateP0E_auto()
end

Function ButtonProc_PE_save4(ctrlName) : ButtonControl
	String ctrlName
	// === Tip Antenna parameters ===
    	Variable/G omega0_uV_pe = 120           // [µeV] Principle resonance of tip antenna
    	Variable/G alpha_pe = 0.75
    	variable/G switch_antena_pe = 0 		   // 1: with antena; 0: without antena

    // === Tip Junction parameters ===
    	Variable/G CJ_pe = 100// [fF]
    	Variable/G Ic_pe = 3.89462// [pA], critical current
    	Variable/G Renv_pe = 31//31             // Vaccum impedance 376.73 [Ohm]

    // === Enviroment Temperature  ===
    	Variable/G T_pe = 1.5//0.065//1.5                 // [K]

    // === Energy calculation parameters  ===
    	Variable/G Emax_uV_pe = 800             // [µeV], the energy range to calculate [-Emax_uV, +Emax_uV]
    										//Note that, if the EC [= (2e)^2/2CJ] is too large, the Emax_uV should be increase to avoid unphysical oscillation
    	Variable/G NE_pe = 1000                  // Energy points

    // === frquency parameters (integrated out)  ===
    	Variable/G NW_pe = 1000//              // Frequency points
    	Variable/G Coff_freq_pe = 3            // Paramter determine the integration upper limit
    	Variable/G nMax_pe = 300			// Maximum eignenumber of vn (sum n from 0 to nMax)

    	variable/G enforceornot_p0_pe = 0


    // === Criteria for self-consistent calculation
    	Variable/G MaxIter_pe = 500//500
    	Variable/G tol_pe = 1e-3

     	variable/G SISon_pe = 1

     	CalculateP0E_auto()
end


Function ButtonProc_PE_CalculateDCBc(ctrlName) : ButtonControl
	String ctrlName
	execute "CalculateDCBc()"
end

Proc CalculateDCBc(startT,deltaT,EndT)
	variable startT = 0.1 //(K)
	variable deltaT = 0.2 // (K)
	variable EndT = 50.2 //(K)
	Prompt startT,"Start T (K)"
	Prompt deltaT,"delta T (K)"
	Prompt EndT,"End T (K)"
	CalculateDCB(startT,deltaT,EndT)
end

Function CalculateDCB(startT,deltaT,EndT)
	variable startT,deltaT,EndT
	variable i
	variable T
	string name
	i=0
	// === Tip Antenna parameters ===
    	Variable/G omega0_uV_pe //= 80//233           // [µeV] Principle resonance of tip antenna
    	Variable/G alpha_pe // = 0.6//0.7
    	variable/G switch_antena_pe //= 1 		   // 1: with antena; 0: without antena

    // === Tip Junction parameters ===
    	Variable/G CJ_pe //= 3.5// [fF]
    	Variable/G Ic_pe //= 1.6// [nA], critical current
    	Variable/G Renv_pe //= 30//31             // Vaccum impedance 376.73 [Ohm]

    // === Enviroment Temperature  ===
    	Variable/G T_pe //= 0.065//0.065//1.5                 // [K]

    // === Energy calculation parameters  ===
    	Variable/G Emax_uV_pe //= 2000             // [µeV], the energy range to calculate [-Emax_uV, +Emax_uV]
    										//Note that, if the EC [= (2e)^2/2CJ] is too large, the Emax_uV should be increase to avoid unphysical oscillation
    	Variable/G NE_pe //= 1000                  // Energy points

    // === frquency parameters (integrated out)  ===
    	Variable/G NW_pe //= 3000//              // Frequency points
    	Variable/G Coff_freq_pe //= 3            // Paramter determine the integration upper limit
    	Variable/G nMax_pe //= 300			// Maximum eignenumber of vn (sum n from 0 to nMax)

    	variable/G enforceornot_p0_pe //= 0


    // === Criteria for self-consistent calculation
    	Variable/G MaxIter_pe //= 500//500
    	Variable/G tol_pe //= 1e-3

     	variable/G SISon_pe //= 1

     	variable/G DCB_n_pe // =
	do
		T_pe = startT+deltaT*i
		print "complete temperature:", T, "(K);","index:", i
		CalculateP0E_auto()

		wave p0_E_conv = $"p0_E_conv"
		//SimulateDCB_IV(p0_E_conv, 3000, T, 0.007, 50)

		SimulateDCB_IV(p0_E_conv, 3000, T_pe, 10^(-6)*Emax_uV_pe/(2*1.5), DCB_n_pe)
		wave dIdV_DCB = $"dIdV_DCB"
		name="DCB_"+num2str(i+1)
		duplicate/o dIdV_DCB $name

		i+=1

	while (T< EndT)
end

Function ButtonProc_PE_dcbbatchexample(ctrlName) : ButtonControl
	String ctrlName
	// === Tip Antenna parameters ===
    	Variable/G omega0_uV_pe = 120           // [µeV] Principle resonance of tip antenna
    	Variable/G alpha_pe = 0.75
    	variable/G switch_antena_pe = 0 		   // 1: with antena; 0: without antena

    // === Tip Junction parameters ===
    	Variable/G CJ_pe = 3.5// [fF]
    	Variable/G Ic_pe = 1.6// [pA], critical current
    	Variable/G Renv_pe = 100//31             // Vaccum impedance 376.73 [Ohm]

    // === Enviroment Temperature  ===
    	//Variable/G T_pe = 1.5//0.065//1.5                 // [K]

    // === Energy calculation parameters  ===
    	Variable/G Emax_uV_pe = 30000             // [µeV], the energy range to calculate [-Emax_uV, +Emax_uV]
    										//Note that, if the EC [= (2e)^2/2CJ] is too large, the Emax_uV should be increase to avoid unphysical oscillation
    	Variable/G NE_pe = 3000                  // Energy points

    // === frquency parameters (integrated out)  ===
    	Variable/G NW_pe = 3000//              // Frequency points
    	Variable/G Coff_freq_pe = 10            // Paramter determine the integration upper limit
    	Variable/G nMax_pe = 300			// Maximum eignenumber of vn (sum n from 0 to nMax)

    	variable/G enforceornot_p0_pe = 0


    // === Criteria for self-consistent calculation
    	Variable/G MaxIter_pe = 500//500
    	Variable/G tol_pe = 1e-3

     	variable/G SISon_pe = 0

     	CalculateDCB(0.1,0.2,50.2)
end


Function MinEnvelopeFilter(wave1, outputWave, window1)
    Wave wave1
    Wave outputWave
    Variable window1

    Variable N = numpnts(wave1)
    Variable i, j, lo, hi, minval

    for(i = 0; i < N; i += 1)
        lo = max(0, i - window1)
        hi = min(N - 1, i + window1)

        minval = wave1[lo]
        for(j = lo+1; j <= hi; j += 1)
            if(wave1[j] < minval)
                minval = wave1[j]
            endif
        endfor
        outputWave[i] = minval
    endfor
End


Function CutWave_EcenteredRange(sourceWave)
	wave sourceWave
	Variable xmin = DimOffset(sourceWave, 0)
	Variable dx = DimDelta(sourceWave, 0)
	Variable N = DimSize(sourceWave, 0)
	Variable xmax = xmin + dx * (N - 1)

	Variable Emin = -xmin
	Variable Emax = xmax

	Variable cut_min = -Emin / 2
	Variable cut_max = Emax / 2

	Variable idx_low = ceil((cut_min - xmin) / dx)
	Variable idx_high = floor((cut_max - xmin) / dx)
	Variable Ncut = idx_high - idx_low + 1

	//if (Ncut <= 0)
	//	Print "Error: Cut range is invalid."
	//	Return -2
	//endif

	Make/D/O/N=(Ncut)/FREE tempCut
	tempCut = sourceWave[p + idx_low]

	Duplicate/O tempCut $nameofwave(sourceWave)
	SetScale/I x, cut_min, cut_max,"", $nameofwave(sourceWave)

	//Print "Cut wave generated:", newWaveName
	//Return 0
End

/////////////////////////////////////////////////////////////////////////////////////
//NIN tunneling simulate Dynamical Coulomb blockade
//Calculate the eq.(1) of PRL 110, 157003 (2013)
/////////////////////////////////////////////////////////////////////////////////////

Function SimulateDCB_IV(Pconv, RT, T, Vrange, NV)
    Wave Pconv //P(E) function
    Variable RT //Junction resistance (Ohm)
    variable T //Temperature (K)
    variable Vrange // Bias range for calculation [-Vrang, Vrange] (V)
    Variable NV // Number of point

    //print time()
    variable Emin = dimoffset(Pconv,0)
    variable Emax = dimoffset(Pconv,0)+(dimsize(Pconv,0)-1)*dimdelta(Pconv,0)
	variable Vmin = -Vrange
	variable Vmax = Vrange

    Variable e = 1.602e-19
    Variable kB = 8.617e-5  // [eV/K]
    Variable betaT = 1 / (kB * T)

    Variable dE = dimdelta(Pconv,0)//(Emax - Emin) / (numpnts(Pconv) - 1)
    Variable NE = dimsize(Pconv,0)//numpnts(Pconv)

    Make/D/O/N=(NV) Vbias, IV_DCB, IV_DCB2, IV_DCB1
    SetScale/I x, Vmin, Vmax, "", Vbias
    Variable v, i, j, EE, eps, f1, f2, integrand, GammaV, GammaMinusV

    for(i = 0; i < NV; i += 1)
        v = Vmin + i * (Vmax - Vmin) / (NV - 1)
        GammaV = 0
        GammaMinusV = 0

        for(j = 0; j < NE; j += 1)
            EE = Emin + j*dE
            f1 = 1 / (1 + exp(betaT * EE))  // f(E)

            Variable innerSumV = 0
            Variable innerSumMinusV = 0

            Variable k
            for(k = 0; k < NE; k += 1)
                eps = Emin + k*dE
                f2 = 1 / (1 + exp(betaT * (EE - eps + v)))   // f(E - ε + eV)
                integrand = f1 * (1 - f2) * Pconv[k]
                innerSumV += integrand * dE

                //f2 = 1 / (1 + exp(betaT * (EE - eps - v)))   // f(E - ε - eV)
                //integrand = f1 * (1 - f2) * Pconv[k]
                //innerSumMinusV += integrand * dE
            endfor

            GammaV += innerSumV * dE
            GammaMinusV += innerSumMinusV * dE
        endfor

        //IV_DCB[i] = e * (GammaV - GammaMinusV) / (e^2 * RT)
        IV_DCB1[i] = GammaV
        IV_DCB2[]=IV_DCB1[dimsize(IV_DCB1,0)-p-1] //GammaMinusV
        IV_DCB = (1/(6.19933e+18))* e * (IV_DCB1-IV_DCB2) / (e^2 * RT)
        Vbias[i] = v
        setscale/i x, Vbias[0],Vbias[NV-1],"",IV_DCB

        duplicate/o  IV_DCB dIdV_DCB
        differentiate dIdV_DCB
    endfor
    //print time()
End

//////////////////////////////////////////////////////////////////////////////////
//Individual P(E) theory calculation
//////////////////////////////////////////////////////////////////////////////////
Function CalculateP0E(T)
     Variable T
     // === Tip Antenna parameters ===
    	Variable omega0_uV = 233//233           // [µeV] Principle resonance of tip antenna
    	Variable alpha = 0.7//0.7
    	variable switch_antena = 0 		   // 1: with antena; 0: without antena

    // === Tip Junction parameters ===
    	Variable CJ = 3.5e-15//7e-15//3.5e-15   //100e-15//           // [F]
    	Variable Ic = 1.6e-9//0.66e-9//1.6e-9    //3.89462e-09//    	   // [A], critical current
    	Variable Renv = 100//31             // Vaccum impedance 376.73 [Ohm]

    // === Enviroment Temperature  ===
    	//Variable T = 0.1//0.065//1.5                 // [K]

    // === Energy calculation parameters  ===
    	Variable Emax_uV = 30000             // [µeV], the energy range to calculate [-Emax_uV, +Emax_uV]
    										//Note that, if the EC [= (2e)^2/2CJ] is too large, the Emax_uV should be increase to avoid unphysical oscillation
    	Variable NE = 3000                  // Energy points

    // === frquency parameters (integrated out)  ===
    	Variable NW = 3000//3000//1500                  // Frequency points
    	Variable Coff_freq = 10//2 //* T/0.1           // Paramter determine the integration upper limit
    	Variable nMax = 300					// Maximum eignenumber of vn (sum n from 0 to nMax)

    	variable enforceornot_p0 = 0      // 1 means enforce P0 with the exponential relationship
    	variable SISon = 0
    // === Criteria for self-consistent calculation
    	Variable MaxIter = 500//500
    	Variable tol = 1e-3

    // === Constants (all in SI base or eV-compatible units) ===
    	Variable hbar = 6.582e-16          // [eV·s]
    	Variable e = 1.602e-19             // [C]
    	Variable kB = 8.617e-5             // [eV/K]
    	Variable RQ = 6.45e3               // [Ohm], quantum resistance

	//------------------------------------------------------------------------------------------------------
	//------------------------------------------------------------------------------------------------------
	//------------------------------------------------------------------------------------------------------
    // === Unit conversion ===
    	Variable omega0_eV = omega0_uV * 1e-6
    	Variable Emax = Emax_uV * 1e-6     // [eV]
    	Variable dE = 2*Emax/(NE-1)

    // === Grids ===
    	Make/D/O/N=(NE) Egrid = -Emax + p*dE
    	Make/D/O/N=(NE) P0_old, P0_new, I_E, PN_E
		setscale/I x, -Emax , Emax ,"",P0_old, P0_new, I_E, PN_E, Egrid

    	Variable betaT = 1 / (kB*T)        // [1/eV]
    	//print betaT

    	//Variable dOmega = omega0_eV / (hbar * NW)
    	//Make/D/O/N=(NW) omega = Coff_freq*p*dOmega // the paramter Coff_freq set the integrate omega range to be Coff_freq times of omega0_uV which is the principle resonance of the antenna
    	//Variable dOmega = 2 * Coff_freq * omega0_eV / (hbar * (NW - 1))     // [1/s] step size for symmetric range
    	Variable dOmega = 2 * Coff_freq * Emax / (hbar * (NW - 1))     // [1/s] step size for symmetric range

		Make/D/O/N=(NW) omega
		//omega = -Coff_freq * omega0_eV / hbar + p * dOmega
    	omega = -Coff_freq * Emax / hbar + p * dOmega
    	Make/D/O/N=(NW) Z_re, Z_im, ReZT, ImZT, k_w, kappa_w

    // === Compute Z_env(omega) ===
    	Variable omega_ratio
    	Variable i
    	for(i=0; i<NW; i+=1)
        	omega_ratio = pi * omega[i] / (2 * omega0_eV / hbar)
        	Complex num = 1 + switch_antena*cmplx(0, 1/alpha) * tan(omega_ratio)
        	Complex den = 1 + switch_antena*cmplx(0, alpha) * tan(omega_ratio)
        	Complex Z = Renv * (num / den)
        	Z_re[i] = real(Z)
        	Z_im[i] = imag(Z)
    	endfor

    // === Z_T(omega) ===
    	for(i=0; i<NW; i+=1)
        	Complex Zenv = cmplx(Z_re[i], Z_im[i])
        	Complex ZT = 1 / (cmplx(0, omega[i] * CJ) + 1 / Zenv)
        	ReZT[i] = real(ZT)
        	ImZT[i] = imag(ZT)
    	endfor

	// === Compute I_E ===
    	Variable ZT0_real = ReZT[0]
    	Variable D = pi * ZT0_real / (betaT * RQ)

    	I_E = (1/pi) * D / (D^2 + Egrid^2)
    	P0_old = I_E

    // === Compute κ(ω) ===
    	k_w = (ReZT / RQ) / (1 - exp(-hbar * omega * betaT)) - (ZT0_real / RQ) / (betaT * hbar * omega)

    // === Compute Kappa(ω) ===
    	Variable n, j
    	Make/D/O/N=(nMax) ZT_Matsu_Re
    	for(n = 1; n <= nMax; n += 1)
        	Variable vn = 2 * pi * n / (betaT * hbar)
        	Complex omega_vn = cmplx(0, -vn)
        	Complex arg = pi * omega_vn / (2 * omega0_eV / hbar)
        	Complex tanZ = tan(arg)
        	Complex numerator = 1 + switch_antena*cmplx(0, 1/alpha) * tanZ
        	Complex denominator = 1 + switch_antena*cmplx(0, alpha) * tanZ
        	Complex Z_env = Renv * (numerator / denominator)

        	// check Z_env stability
    		if(numtype(Z_env) != 0 || abs(Z_env) > 1e6)
        		Z_env = cmplx(Renv, 0)
    		endif


        	Complex ZT_matsu = 1 / (vn * CJ + 1 / Z_env)

        	if(numtype(ZT_matsu) == 0)
        		ZT_Matsu_Re[n-1] = real(ZT_matsu)
    		else
        		ZT_Matsu_Re[n-1] = 0 // fallback: 0 contribution
    		endif
    	endfor

    	for(j = 0; j < NW; j += 1)
        	Variable w = omega[j]
       		Variable A, B

    		// === Correction：to avoid divded by 0 in A ===
    		if(abs(1 - exp(-hbar * w * betaT)) > 1e-12)
        		A = (ImZT[j] / RQ) / (1 - exp(-hbar * w * betaT))
    		else
        		A = 0
        		//print j,w
    		endif

        	Variable sumkapp = 0
        	for(n = 1; n <= nMax; n += 1)
            	vn = 2 * pi * n / (betaT * hbar)
            	sumkapp += (vn / (vn^2 + w^2)) * (ZT_Matsu_Re[n-1] / RQ)
        	endfor
        	B = (2 / (betaT * hbar)) * sumkapp
        	//print "A", A
        	//print "B", B
        	kappa_w[j] = A - B
    	endfor

    // === Self-consistence calculation ===
    	Variable iter = 0, error
    	Make/D/O/N=(NE) deltaP
    	do

        	for(i = 0; i < NE; i += 1)
            	Variable Ei_pe = Egrid[i]
            	Variable denom = D^2 + Ei_pe^2 //+ 1e-20
            	Variable sumK = 0

            	for(j = 0; j < NW; j += 1)
                	w = omega[j]
                	Variable E_shift = Ei_pe - hbar * w
                	if(E_shift >= -Emax && E_shift <= Emax)
                    	Variable idx = (E_shift + Emax) / dE // the point number of the energy E_shift in waves
                    	Variable iL = floor(idx)
                    	Variable iH = iL + 1
                    	if(iL >= 0 && iH < NE)
                        	Variable f = idx - iL
                        	Variable kVal = k_w[j]
                        	Variable kapVal = kappa_w[j]
                        	Variable KK = (hbar * Ei_pe / denom) * kVal + (hbar * D / denom) * kapVal
                        	Variable interpP = (1 - f) * P0_old[iL] + f * P0_old[iH]
							//Print "kapVal = ", kapVal
                        	if(numtype(KK)==0 && numtype(interpP)==0)
                        	//if(numtype(KK)!=2)
                            	sumK += KK * interpP * dOmega
                            	//print sumK
                        	endif
                    	endif
                	endif
            	endfor

            	multithread P0_new[i] = I_E[i] + sumK
        	endfor

        	//deltaP = abs(P0_new - P0_old)
        	//WaveStats/Q deltaP
        	//error = V_max
        	multithread deltaP = (P0_new - P0_old)^2
			error = sqrt(sum(deltaP)/NE)
        	P0_old = P0_new
        	//Print "P0(E) computed in", iter, "iterations.  Error =", error


        	iter += 1
    	while(error > tol && iter < MaxIter)


	// === Enforce detailed balance: P0(-E) = exp(-E / kB T) * P0(E)
	if (enforceornot_p0 == 1)
		Variable EiEnforce, Em, idx1, iL1, iH1, f1, Pm, corrected

		for(i = 0; i < NE; i += 1)
    		EiEnforce = Egrid[i]
    		if(EiEnforce < 0)
        		Em = -EiEnforce
        		idx1 = (Em + Emax)/dE
        		iL1 = floor(idx1)
        		iH1 = iL1 + 1

        		if(iL1 >= 0 && iH1 < NE)
            		f1 = idx1 - iL1
            		Pm = (1 - f1) * P0_new[iL1] + f1 * P0_new[iH1]
            		corrected = Pm * exp(EiEnforce / (kB * T))
            		P0_new[i] = corrected

        		elseif(iL1 == NE - 1)  // edge case: exact hit at last point
            		Pm = P0_new[iL1]
            		corrected = Pm * exp(EiEnforce / (kB * T))
            		P0_new[i] = corrected
        		endif
    		endif
		endfor
	endif

    // === Normalize P0(E) and output ===
    	Variable normvalue = areaXY(Egrid, P0_new)
    	P0_new /= normvalue
    	Duplicate/O Egrid, P0_E
    	P0_E = P0_new
    	//Print "P0(E) computed in", iter, "iterations. Final error =", error


    // === Gaussian PN(E) ===
    	Variable EC = ((2*e)^2) / (2 * CJ) / e // Convert to [eV]
    	Variable sigma2 = 4 * EC * kB * T
    	Variable normPN = 1 / sqrt(pi * sigma2)
    	for(i = 0; i < NE; i += 1)
        	Ei_pe = Egrid[i]
        	PN_E[i] = normPN * exp(-Ei_pe^2 / sigma2)
    	endfor
    	//PN_E /= areaXY(Egrid, PN_E)

    // === Convolve P0 * PN ===
    	Duplicate/O P0_E,P0_E_conv
		Convolve PN_E, P0_E_conv
		setscale/I x,-Emax*2,Emax*2,"",P0_E_conv
   		variable convnorm = sum(P0_E_conv,-Emax,Emax)*dimdelta(P0_E_conv,0)
   		P0_E_conv/=convnorm

   		CutWave_EcenteredRange(P0_E_conv)



    // === Compute I(V) from P(E) theory: I(V) = (π ℏ Ic² / 4e) [P(2eV) - P(-2eV)] ===
    if (SISon == 1)
    	Make/D/O/N=(dimsize(P0_E_conv,0)) IV_pe, Bias
    	Variable coef = pi * hbar * Ic^2 / (4 * e)  // pre-factor [eV * A]
    	//print coef
		variable valuep,locatem,voltage,current
		variable ii = 0
		do
			valuep = dimoffset(p0_E_conv,0)+ii*dimdelta(p0_E_conv,0) //eV
			//-valuep = dimoffset(p0_E_conv,0)+locatem*dimdelta(p0_E_conv,0)
			locatem = (-valuep - dimoffset(p0_E_conv,0))/dimdelta(p0_E_conv,0)
			voltage = valuep/2 //V

			current = coef*(p0_E_conv[ii]-p0_E_conv[locatem])

			IV_pe[ii] = current
			Bias[ii] = voltage
			ii+=1
		while (ii<dimsize(P0_E_conv,0))
		setscale/p x, Bias[0],Bias[1]-Bias[0],"",IV_pe
		duplicate/o IV_pe didv_pe
		differentiate didv_pe

	killwaves Bias, deltaP, Egrid, ImZT,I_E,kappa_w,k_w,omega,p0_new,p0_old,ReZT,ZT_Matsu_Re,Z_im,Z_re
    // === Display ===
    //	display IV_pe
    //	Label bottom "\\Z16Sample Bias (V)"
    //	Label Left "\\Z16Current (A)"

    //	display didv_pe
    //	Label bottom "\\Z16Sample Bias (V)"
    //	Label Left "\\Z16dI/dV (S)"
   endif
    //----------------------------------------------------------------------------------------------------
End

//********************************************************************************************************************************************************
//********************************************************************************************************************************************************
//********************************************************************************************************************************************************
//********************************************************************************************************************************************************
//********************************************************************************************************************************************************
//********************************************************************************************************************************************************
//********************************************************************************************************************************************************
//********************************************************************************************************************************************************
//********************************************************************************************************************************************************
//********************************************************************************************************************************************************
//********************************************************************************************************************************************************
//********************************************************************************************************************************************************
//********************************************************************************************************************************************************
//********************************************************************************************************************************************************
//********************************************************************************************************************************************************
//********************************************************************************************************************************************************
//********************************************************************************************************************************************************
//********************************************************************************************************************************************************




/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
// Simulate RCSJ Model for Supercurrent
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////

Function ButtonProc_RCSJ(ctrlName) : ButtonControl
	String ctrlName
	Execute "RCSJc()"
end
Proc RCSJc(TT,beta_c,sm,current)
	variable TT = 0.5 // Temperature (K)
	variable beta_c = 2 // Stewart–McCumber parameter
	variable sm = 10 // smooth number
	variable current = 1 // Normalized drive current （Ic）

	Prompt TT,"Temperature (K)"
	Prompt beta_c,"\\$WMTEX$ \\beta_{c} \\$/WMTEX$ :Stewart–McCumber parameter"
	Prompt sm,"smooth"
	Prompt current," Normalized drive current （Ic）"


	variable/G TT_RCSJ = TT
	variable/G beta_c_RCSJ = beta_c
	variable/G sm_RCSJ = sm
	variable/G current_RCSJ = current
	variable/G TT_RCSJ_V = TT


	SimulateRCSJ_IV_Hysteresis_Realistic(TT,beta_c,sm)
	SimulateRCSJ_voltage_vs_Time(TT,current,beta_c)


	display/N=RCSJIVcurveandvoltagesimu I_array vs V_avg;
	modifygraph width=700,height=450;
	ModifyGraph margin(top)=350;
	Label bottom "\\Z16Voltage (\\$WMTEX$ I_{c}R \\$/WMTEX$)";
	Label left "\\Z16Current (\\$WMTEX$ I_{c} \\$/WMTEX$)";
	ModifyGraph fSize=16
	duplicate/o V_avg color_Vavg
	variable ico = dimsize(color_Vavg,0)/4
	color_Vavg = 1
	do
		color_Vavg[ico]=0
 		ico+=1
	while(ico<3*dimsize(color_Vavg,0)/4)
	ModifyGraph zColor(I_array)={color_Vavg,*,*,RedWhiteBlue256,0}
	TextBox/C/N=text0/F=0/A=RB/X=0.00/Y=5.00 "\\Z16\\K(0,0,65535)Forward\r\\Z16\\K(65535,0,0)Backward\r\\Z16\\K(0,0,0)0 \\K(0,0,65535)--> \\K(0,0,0)\$WMTEX$ +I_{max} \$/WMTEX$ \\K(65535,0,0)--> \\K(0,0,0)\$WMTEX$ -I_{max} \$/WMTEX$ \\K(0,0,65535)--> \\K(0,0,0)0"

	make/n=2/o RCSJindicator
	setscale/I x,-1.5,1.5,"",RCSJindicator
	RCSJindicator = current
	appendtograph RCSJindicator
	ModifyGraph lstyle(RCSJindicator)=7,rgb(RCSJindicator)=(21845,21845,21845)

	///////////////////////////////////////////////
	Display/HOST=#/W=(0.02,0.05,0.98,0.4);
	appendtograph voltage
	Label left "\\Z16Voltage (\\$WMTEX$ I_{c}R \\$/WMTEX$)"
	Label bottom "\\Z16Time (\\$WMTEX$ \\frac{ℏ}{2eI_{c}R} \\$/WMTEX$)"
	ModifyGraph fSize=16




	setActiveSubwindow ##;


	SetVariable set1 win=RCSJIVcurveandvoltagesimu, title="\\$WMTEX$ T \\$/WMTEX$ (K)",pos={165,8},size={100,15},value=TT_RCSJ,limits={0,inf,0.1},proc=SetVarProc_RCSJ
	SetVariable set2 win=RCSJIVcurveandvoltagesimu, title="\\$WMTEX$ \beta_{c} \\$/WMTEX$",pos={300,8},size={100,15},value=beta_c_RCSJ,limits={0,inf,0.1},proc=SetVarProc_RCSJ
	SetVariable set3 win=RCSJIVcurveandvoltagesimu, title="I/\\$WMTEX$ I_{c} \\$/WMTEX$",pos={420,8},size={100,15},value=current_RCSJ,limits={-inf,inf,0.02},proc=SetVarProc_RCSJ2
	SetVariable set4 win=RCSJIVcurveandvoltagesimu, title="smooth",pos={555,8},size={100,8},value=sm_RCSJ,limits={0,inf,1},proc=SetVarProc_RCSJ

	SetVariable set5 win=RCSJIVcurveandvoltagesimu, title="\\$WMTEX$ T_{Voltage only} \\$/WMTEX$ (K)",pos={420,28},size={100,15},value=TT_RCSJ_V,limits={0,inf,0.1},proc=SetVarProc_RCSJ2

	Button turnoffls3d title="BACK",size={45,12},valueColor=(0,0,0),fColor=(1,65535,33232),pos={786,5},proc=ButtonProc_lsturnoff3d
	tilewindows/WINS=winname(0,1)/R/A=(1,1)/w=(3,1,50,100)
	//ckfig_child(winname(0,1))
end


Function SetVarProc_RCSJ(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName


	variable/G TT_RCSJ
	variable/G beta_c_RCSJ
	variable/G sm_RCSJ
	variable/G current_RCSJ

	variable/G TT_RCSJ_V

	TT_RCSJ_V = TT_RCSJ

	SimulateRCSJ_IV_Hysteresis_Realistic(TT_RCSJ,beta_c_RCSJ,sm_RCSJ)

end

Function SetVarProc_RCSJ2(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName


	variable/G TT_RCSJ
	variable/G beta_c_RCSJ
	variable/G sm_RCSJ
	variable/G current_RCSJ
	variable/G TT_RCSJ_V

	TT_RCSJ = TT_RCSJ_V

	SimulateRCSJ_voltage_vs_Time(TT_RCSJ,current_RCSJ,beta_c_RCSJ)
	wave RCSJindicator = $"RCSJindicator"
	RCSJindicator = current_RCSJ
end


/////////////////////////////////////////////////////////////////////////////////////////
//Main Function #01 Simulate I(V) curve
/////////////////////////////////////////////////////////////////////////////////////////

Function SimulateRCSJ_IV_Hysteresis_Realistic(T,beta_c,sm)
    Variable T         // 温度 (K)
    Variable beta_c //= 8
    variable sm

    Variable tMax = 1000         // 增加演化时间以利于 retrap // Optimized parameter [Fix it]
    Variable dt = 0.05			 // Optimized parameter [Fix it]

    Variable N = tMax/dt + 1
    Variable i, j

    variable Imax = 1.5, dI = 0.01
    Variable numI = round((Imax - 0)/dI) + 1

    // ----- 物理常数 -----
    Variable kB = 1.380649e-23
    Variable phi0 = 2.067833848e-15
    Variable Ic = 3e-6   // 临界电流 (A)，用于计算噪声强度

    // ----- 噪声标准差（归一化单位） -----
    Variable noiseSTD = sqrt((4 * Pi * kB * T) / (phi0 * Ic * dt))

    // ----- 变量和数据 -----
    Make/O/N=(N) phi, dphi_dt, voltage
    Make/O/N=(4*numI) I_array, V_avg

    // ----- Forward 扫描 -----
    for(i = 0; i < numI; i += 1)
        Variable current = 0 + i*dI
        I_array[i] = current

        phi[0] = 0
        dphi_dt[0] = 0

        for(j = 1; j < N; j += 1)
            Variable eta = noiseSTD * gnoise(1)

            Variable y1 = phi[j-1]
            Variable y2 = dphi_dt[j-1]

            Variable k1_1 = y2
            Variable k1_2 = (current + eta - sin(y1) - y2)/beta_c

            Variable k2_1 = y2 + 0.5*dt*k1_2
            Variable k2_2 = (current + eta - sin(y1 + 0.5*dt*k1_1) - k2_1)/beta_c

            Variable k3_1 = y2 + 0.5*dt*k2_2
            Variable k3_2 = (current + eta - sin(y1 + 0.5*dt*k2_1) - k3_1)/beta_c

            Variable k4_1 = y2 + dt*k3_2
            Variable k4_2 = (current + eta - sin(y1 + dt*k3_1) - k4_1)/beta_c

            phi[j] = y1 + (dt/6)*(k1_1 + 2*k2_1 + 2*k3_1 + k4_1)
            dphi_dt[j] = y2 + (dt/6)*(k1_2 + 2*k2_2 + 2*k3_2 + k4_2)
            voltage[j] = dphi_dt[j]
        endfor

        V_avg[i] = mean(voltage, round(0.7 * N), N-1)
    endfor

    // ----- Backward Scan -----
    for(i = 0; i < 2*numI; i += 1)
        current = Imax - i*dI
        I_array[numI + i] = current

        // 使用 forward 扫描最终状态作为起点（真实 hysteresis）
        phi[0] = phi[N-1]
        dphi_dt[0] = dphi_dt[N-1]

        for(j = 1; j < N; j += 1)
             eta = noiseSTD * gnoise(1)

             y1 = phi[j-1]
             y2 = dphi_dt[j-1]

             k1_1 = y2
             k1_2 = (current + eta - sin(y1) - y2)/beta_c

             k2_1 = y2 + 0.5*dt*k1_2
             k2_2 = (current + eta - sin(y1 + 0.5*dt*k1_1) - k2_1)/beta_c

             k3_1 = y2 + 0.5*dt*k2_2
             k3_2 = (current + eta - sin(y1 + 0.5*dt*k2_1) - k3_1)/beta_c

             k4_1 = y2 + dt*k3_2
             k4_2 = (current + eta - sin(y1 + dt*k3_1) - k4_1)/beta_c

            phi[j] = y1 + (dt/6)*(k1_1 + 2*k2_1 + 2*k3_1 + k4_1)
            dphi_dt[j] = y2 + (dt/6)*(k1_2 + 2*k2_2 + 2*k3_2 + k4_2)
            voltage[j] = dphi_dt[j]
        endfor
        V_avg[numI + i] = mean(voltage, round(0.7 * N), N-1)
    endfor


    // ----- forward scan again-----

    for(i = 0; i < numI; i += 1)
        current = -Imax + i*dI
        I_array[3*numI + i] = current

        // 使用 forward 扫描最终状态作为起点（真实 hysteresis）
        phi[0] = phi[N-1]
        dphi_dt[0] = dphi_dt[N-1]

        for(j = 1; j < N; j += 1)
             eta = noiseSTD * gnoise(1)

             y1 = phi[j-1]
             y2 = dphi_dt[j-1]

             k1_1 = y2
             k1_2 = (current + eta - sin(y1) - y2)/beta_c

             k2_1 = y2 + 0.5*dt*k1_2
             k2_2 = (current + eta - sin(y1 + 0.5*dt*k1_1) - k2_1)/beta_c

             k3_1 = y2 + 0.5*dt*k2_2
             k3_2 = (current + eta - sin(y1 + 0.5*dt*k2_1) - k3_1)/beta_c

             k4_1 = y2 + dt*k3_2
             k4_2 = (current + eta - sin(y1 + dt*k3_1) - k4_1)/beta_c

            phi[j] = y1 + (dt/6)*(k1_1 + 2*k2_1 + 2*k3_1 + k4_1)
            dphi_dt[j] = y2 + (dt/6)*(k1_2 + 2*k2_2 + 2*k3_2 + k4_2)
            voltage[j] = dphi_dt[j]
        endfor
        V_avg[3*numI + i] = mean(voltage, round(0.7 * N), N-1)
    endfor

	if (sm == 0)
	else
		smooth sm,V_avg
	endif

    // ----- 显示 I–V 曲线 -----
    //Display I_array vs V_avg
    //Label bottom "Voltage (\\$WMTEX$ I_{c}R \\$/WMTEX$)"
    //Label left "Current (\\$WMTEX$ I_{c} \\$/WMTEX$)"

    //duplicate/o V_avg color_Vavg
    //wave color_Vavg = $"color_Vavg"
	//variable ico = dimsize(color_Vavg,0)/4
	//color_Vavg = 1
	//do
	//	color_Vavg[ico]=0
 	//	ico+=1
	//while(ico<3*dimsize(color_Vavg,0)/4)
	//ModifyGraph zColor(I_array)={color_Vavg,*,*,RedWhiteBlue256,0}

End

/////////////////////////////////////////////////////////////////////////////////////////
//Main Function #02 Simulate V(t) curve
/////////////////////////////////////////////////////////////////////////////////////////

Function SimulateRCSJ_voltage_vs_Time(TT,current,beta_c)
    Variable TT,current, beta_c
    variable tMax = 1000
    variable dt = 0.05
    Variable N, i,j
    Wave phi, dphi_dt, I_bias, voltage


    N = tMax/dt + 1

    // ----- Allocate Waves -----
    Make/N=(N)/o phi, dphi_dt, I_bias, voltage
    SetScale/P x, 0, dt, voltage

    // ----- Initial Conditions -----
    phi[0] = 0
    dphi_dt[0] = 0
    I_bias[] = current


 	// ----- constant -----
    Variable Ic = 3e-6           // Ic (A) [set to 3 uA]
    Variable kB = 1.380649e-23   // Boltzmann constant (J/K)
    Variable phi0 = 2.067833848e-15 // Φ₀ (Wb)


    // ----- Calculate thermal noise standard deviation -----
    Variable noiseSTD = sqrt((4 * pi * kB * TT) / (phi0 * Ic * dt))


    // ----- time Evolution Loop (Euler method) -----
    	//for(i = 1; i < N; i += 1)

    	//    Variable eta = noiseSTD * gnoise(1)   // 高斯白噪声，均值0、方差1
    	//    Variable d2phi = I_bias[i-1] + eta - sin(phi[i-1]) - beta_c*dphi_dt[i-1]

    	//    d2phi /= beta_c

    	//    dphi_dt[i] = dphi_dt[i-1] + d2phi * dt
    	//    phi[i] = phi[i-1] + dphi_dt[i-1] * dt
    	//    voltage[i] = dphi_dt[i] // normalized voltage
    	//endfor


    // ----- time Evolution Loop (RK4 method) -----

    	phi[0] = 0
        dphi_dt[0] = 0

        for(j = 1; j < N; j += 1)
            Variable eta = noiseSTD * gnoise(1)

            Variable y1 = phi[j-1]
            Variable y2 = dphi_dt[j-1]

            Variable k1_1 = y2
            Variable k1_2 = (current + eta - sin(y1) - y2)/beta_c

            Variable k2_1 = y2 + 0.5*dt*k1_2
            Variable k2_2 = (current + eta - sin(y1 + 0.5*dt*k1_1) - k2_1)/beta_c

            Variable k3_1 = y2 + 0.5*dt*k2_2
            Variable k3_2 = (current + eta - sin(y1 + 0.5*dt*k2_1) - k3_1)/beta_c

            Variable k4_1 = y2 + dt*k3_2
            Variable k4_2 = (current + eta - sin(y1 + dt*k3_1) - k4_1)/beta_c

            phi[j] = y1 + (dt/6)*(k1_1 + 2*k2_1 + 2*k3_1 + k4_1)
            dphi_dt[j] = y2 + (dt/6)*(k1_2 + 2*k2_2 + 2*k3_2 + k4_2)
            voltage[j] = dphi_dt[j]
        endfor

    //Display voltage
    //Label left "Voltage (\\$WMTEX$ I_{c}R \\$/WMTEX$)"
	//Label bottom "Time (\\$WMTEX$ \\frac{ℏ}{2eI_{c}R} \\$/WMTEX$)"
End

