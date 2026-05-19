#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
//**********************************************************************//
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//*************   Template for Hamiltonian deriviation   ***************//
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//**********************************************************************//

//# 01. New version Text; equation (2) of PRB 98, 214503
Function NewDerivPRB98_214503_eq2_T()
	//** Create Parameter waves
		wT("e0t",{{"ε0"}})
		wT("Vxyt",{{"γxy"}})
		wT("Vxt",{{"γx"}})
		wT("Vyt",{{"γy"}})
		wT("mdd0t",{{"-∆d0"}})
		wT("mddzt",{{"-∆dz"}})

		//wT("e0t",{{"-µ+(kx^2+ky^2)/(2*m)"}})
		//wT("Vxyt",{{"a*ky*kx"}})
		//wT("Vxt",{{"γso*kx"}})
		//wT("Vyt",{{"γso*ky"}})
		//wT("mdd0t",{{"-∆2*kx*ky/k0^2"}})
		//wT("mddzt",{{"-∆0"}})

	//** Create Pauli sequence wave
		Wn("ps",{{3,0,0},{3,3,0},{3,1,2},{0,1,1},{2,0,2},{2,3,2}})

	//** Do text matrix  derivation
	string ps = "ps"
	automatrixT("e0t;Vxyt;Vxt;Vyt;mdd0t;mddzt",$ps)
		//alternatively you can also do automatrixT("e0t;Vxyt;Vxt;Vyt;mdd0t;mddzt",Wn("ps",{{3,0,0},{3,3,0},{3,1,2},{0,1,1},{2,0,2},{2,3,2}}))
end


//# 02. New version numerical; equation (2) of PRB 98, 214503
Function NewDerivPRB98_214503_eq2_N()
	variable e0c1 = 2.65
	variable Vxyc1 = 3.213
	variable Vxc1 = 1.2345
	variable Vyc1 = 324.34
	variable mdd0c1 = -123.213
	variable mddzc1 = -24.1

	wC("e0c",{{cmplx(e0c1,0)}})
	wC("Vxyc",{{cmplx(Vxyc1,0)}})
	wC("Vxc",{{cmplx(Vxc1,0)}})
	wC("Vyc",{{cmplx(Vyc1,0)}})
	wC("mdd0c",{{cmplx(mdd0c1,0)}})
	wC("mddzc",{{cmplx(mddzc1,0)}})

	Wn("psc",{{3,0,0},{3,3,0},{3,1,2},{0,1,1},{2,0,2},{2,3,2}})

	//** Do text matrix  derivation
	string psc = "psc"
	matrixEigenV automatrixC("e0c;Vxyc;Vxc;Vyc;mdd0c;mddzc",$psc)
	string W_eigenvalues="W_eigenvalues"
	wave/C n=$W_eigenvalues
	edit n
	cktable(winname(0,2))
end

//**********************************************************************//
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//*******************   Calculate pauli equation   *********************//
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//**********************************************************************//

//# 01. Proc Head
Function ButtonProc_automatrixTC(ctrlName) : ButtonControl
	String ctrlName
	Execute "automatrixTC()"
end
Proc automatrixTC(paralist,xyzseq,sel)
	string paralist
	string xyzseq
	variable sel
	Prompt paralist,"List (by ;) of parameter waves (1x1 waves)"
	prompt xyzseq,"Wave of Pauli sequence, e.g. a polynomial with 6 terms, each term has 3 paulis, the wave should be like {{0,1,2},{2,3,1},{0,2,2},{1,1,1},{2,2,2},{1,0,0}}"
	prompt sel,"Select Modes",popup,"Text;Numerical"
	//variable multi = dimsize($xyzseq,0)
	//variable add = dimsize($xyzseq,1)
	//prompt multi, "How many pauli matrixs in each term"
	//prompt add,"How many terms in the polynomial"
	if (sel == 1)
		automatrixT(paralist,$xyzseq)
	endif
	if (sel == 2)
		automatrixC(paralist,$xyzseq)
	endif
end

//# 02. Main Function for Text wave [This useful for derivation equation]
Function automatrixT(paralist,xyzseq)
	string paralist
	//"List (by ;) of parameter waves (1x1 waves)"
	//e.g. the string is "w1;w2;w3;w4;w5;w6"
	wave xyzseq
	//"Wave of Pauli sequence,
	//e.g. a polynomial with 6 terms, each term has 3 paulis,
	//the wave can be {{0,1,2},{2,3,1},{0,2,2},{1,1,1},{2,2,2},{1,0,0}}"
	//This indicates the Hamiltonian is
	//"H = w1*σ0σxσy + w2*σyσzσx + w3*σ0σyσy + w4*σxσxσx + w5*σyσyσy + w6*σxσ0σ0"

	variable multi //"How many pauli matrixs in each term"
	variable add //"How many terms in the polynomial"
	multi = dimsize(xyzseq,0)
	add = dimsize(xyzseq,1)

	//** Make each term by tensor product code
		string para //individual name of parameter wave
		variable i_add,i_multi
		variable paulisel
		string tempmul
		i_add=0
		do
			para=stringfromlist(i_add,paralist)
			wave paraw = $para
			tempmul = "tempmul_"+num2str(i_add+1)

			paulisel=xyzseq[0][i_add]
			if (paulisel == 0)
				 mpt(paraw,st0())
			endif
			if (paulisel == 1)
				mpt(paraw,stx())
			endif
			if (paulisel == 2)
				mpt(paraw,sty())
			endif
			if (paulisel == 3)
				mpt(paraw,stz())
			endif

			wave/T prod2=$"prod2"
			duplicate/o/T prod2 $tempmul

			if (multi == 1)
			else
				i_multi=1
				do
					paulisel=xyzseq[i_multi][i_add]
					if (paulisel == 0)
				 		mpt($tempmul,st0())
					endif
					if (paulisel == 1)
				 		mpt($tempmul,stx())
					endif
					if (paulisel == 2)
				 		mpt($tempmul,sty())
					endif
					if (paulisel == 3)
				 		mpt($tempmul,stz())
					endif

					wave/T prod2=$"prod2"
					duplicate/o/T prod2 $tempmul

					i_multi+=1
				while(i_multi < multi)
			ENDIF
			i_add+=1
		while(i_add < add)

	//** Add the terms
		string tempmula1,tempmula2
		tempmula1 = "tempmul_"+num2str(1)
		tempmula2 = "tempmul_"+num2str(2)
		plust($tempmula1,$tempmula2)
		wave/T prod3=$"prod3"
		duplicate/o/T prod3 Result_T

		i_add=1
		do
			tempmula2 = "tempmul_"+num2str(i_add+2)
			plust(Result_T,$tempmula2)
			wave/T prod3=$"prod3"
			duplicate/o/T prod3 Result_T
			i_add+=1
		while(i_add < add-1)

	//** Kill temp waves
		string sigmat0 ="sigmat0"
		string sigmatx ="sigmatx"
		string sigmaty ="sigmaty"
		string sigmatz ="sigmatz"
		killwaves prod2 prod3 xyzseq $sigmat0 $sigmatx $sigmaty $sigmatz
		i_add=0
		do
			tempmul = "tempmul_"+num2str(i_add+1)
			para=stringfromlist(i_add,paralist)

			killwaves $tempmul $para
			i_add+=1
		while(i_add < add)

	//** Show table
		string Resul="Result_T"
		wave Resulw = $Resul
		edit Resulw
		cktable(winname(0,2))
end

//# 02. Main Function for complex numerical wave [This useful for model calculation in function]
Function/Wave automatrixC(paralist,xyzseq)
	string paralist
	//"List (by ;) of parameter waves (1x1 waves)"
	//e.g. the string is "w1;w2;w3;w4;w5;w6"
	wave xyzseq
	//"Wave of Pauli sequence,
	//e.g. a polynomial with 6 terms, each term has 3 paulis,
	//the wave can be {{0,1,2},{2,3,1},{0,2,2},{1,1,1},{2,2,2},{1,0,0}}"
	//This indicates the Hamiltonian is
	//"H = w1*σ0σxσy + w2*σyσzσx + w3*σ0σyσy + w4*σxσxσx + w5*σyσyσy + w6*σxσ0σ0"

	variable multi //"How many pauli matrixs in each term"
	variable add //"How many terms in the polynomial"
	multi = dimsize(xyzseq,0)
	add = dimsize(xyzseq,1)

	//** Make each term by tensor product code
		string para //individual name of parameter wave
		variable i_add,i_multi
		variable paulisel
		string tempmul
		i_add=0
		do
			para=stringfromlist(i_add,paralist)
			wave paraw = $para
			tempmul = "tempmulc_"+num2str(i_add+1)

			paulisel=xyzseq[0][i_add]
			if (paulisel == 0)
				mpc(paraw,s0())
			endif
			if (paulisel == 1)
				mpc(paraw,sx())
			endif
			if (paulisel == 2)
				mpc(paraw,sy())
			endif
			if (paulisel == 3)
				mpc(paraw,sz())
			endif

			wave/C/D prod=$"prod"
			duplicate/o/C/D prod $tempmul

			if (multi == 1)
			else
				i_multi=1
				do
					paulisel=xyzseq[i_multi][i_add]
					if (paulisel == 0)
				 		mpc($tempmul,s0())
					endif
					if (paulisel == 1)
				 		mpc($tempmul,sx())
					endif
					if (paulisel == 2)
				 		mpc($tempmul,sy())
					endif
					if (paulisel == 3)
				 		mpc($tempmul,sz())
					endif

					wave/C/D prod=$"prod"
					duplicate/o/C/D prod $tempmul

					i_multi+=1
				while(i_multi < multi)
			endif

			i_add+=1
		while(i_add < add)

	//** Add the terms
		string tempmula1
		tempmula1 = "tempmulc_"+num2str(1)
		duplicate/o/C/D $tempmula1 Result_C

		i_add=1
		do
			tempmula1 = "tempmulc_"+num2str(i_add+1)
			wave/C/D tempmula1w = $tempmula1
			Result_C+=tempmula1w
			i_add+=1
		while(i_add < add)

	//** Kill temp waves
		string sigma0 ="sigma0"
		string sigmax ="sigmax"
		string sigmay ="sigmay"
		string sigmaz ="sigmaz"
		killwaves prod //xyzseq $sigma0 $sigmax $sigmay $sigmaz
		i_add=0
		do
			tempmul = "tempmulc_"+num2str(i_add+1)
			para=stringfromlist(i_add,paralist)

			killwaves $tempmul $para
			i_add+=1
		while(i_add < add)

	//** Show table
		string Resul="Result_C"
		wave Resulw = $Resul
		//edit Resulw
		//cktable(winname(0,2))
	Return Resulw
end

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//*********************   Matrix Tensor Product  ***********************//
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

//** #1. Complex
Function/wave mpc(A,B)
    wave/C A,B
    variable n1,n2,n
    n1 = dimsize(A,0)
    n2 = dimsize(B,0)
    n = n1*n2
    make/o/n=(n,n)/C/D prod
    prod = A[(floor(p/n2))][(floor(q/n2))]*B[(mod(p,n2))][(mod(q,n2))]
	return prod
end

//** #2. Numerical (real)
Function/wave mpn(A,B)
    wave A,B
    variable n1,n2,n
    n1 = dimsize(A,0)
    n2 = dimsize(B,0)
    n = n1*n2
    make/o/n=(n,n)/D prod
    prod = A[(floor(p/n2))][(floor(q/n2))]*B[(mod(p,n2))][(mod(q,n2))]
	return prod
end

//** #3. Text
Function/Wave mpt(A,B)
    wave/T A,B

    variable n1,n2,n
    n1 = dimsize(A,0)
    n2 = dimsize(B,0)
    n = n1*n2
    make/o/n=(n,n)/T prod2
    variable i,j
    i=0
    do
    	j=0
    	do
    		prod2[i][j] =  "("+A[(floor(i/n2))][(floor(j/n2))]+")*("+B[(mod(i,n2))][(mod(j,n2))]+")"
    		if (str2num(A[(floor(i/n2))][(floor(j/n2))]) == 0 || str2num(B[(mod(i,n2))][(mod(j,n2))]) == 0)
    			prod2[i][j] ="0"

    			else

    			if (str2num(A[(floor(i/n2))][(floor(j/n2))]) == 1 )
    				prod2[i][j] =B[(mod(i,n2))][(mod(j,n2))]
    			endif
    			if (str2num(B[(mod(i,n2))][(mod(j,n2))]) == 1)
    				prod2[i][j] =A[(floor(i/n2))][(floor(j/n2))]
    			endif
    		endif

    		if (cmpstr(prod2[i][j],"(1)") == 0)
    			prod2[i][j] = "1"
    		endif
    		j+=1
    	while(j< dimsize(prod2,1))
    	i+=1
    while(i < dimsize(prod2,0))
    return prod2
end

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//*******************  Text matrix Tensor Add  *************************//
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
Function/Wave plust(A,B)
	wave/T A,B
    variable n1,n2,n
    n1 = dimsize(A,0)
    n2 = dimsize(B,0)
    n = n1
    make/o/n=(n,n)/T prod3
    variable i,j
    i=0
    do
    	j=0
    	do
    		prod3[i][j]=A[i][j]+"+"+B[i][j]
    		if (str2num(A[i][j]) == 0)
    			prod3[i][j] = B[i][j]
    		endif
    		if (str2num(B[i][j]) == 0)
    			prod3[i][j] = A[i][j]
    		endif
    		j+=1
    	while(j<dimsize(prod3,1))
    	i+=1
    while(i<dimsize(prod3,0))
end

Function testkrnkproduct(wave1,wave2)
	wave wave1
	wave wave2
	EDIT mpt(wave1,wave2)
	cktable(winname(0,2))
end

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//***********************   Auto make matrix  **************************//
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

//** #1. Numerical wave (real)
	//try wN("name",{}), {1} for 1D, {{1}} for 2D, {{{1}}} for 3D
Function/Wave wN(name,ww)
	string name
	wave ww
	duplicate/o/D ww $name
	return $name
end

//** #2. Text wave (real)
		//try wT("name",{""}), {"t"} for 1D, {{"t"}} for 2D, {{{"t"}}} for 3D
Function/Wave wT(name,ww)
	string name
	wave/T ww
	duplicate/o/T ww $name
	return $name
end

//** #3. Complex wave (real)
		//try wT("name",{cmplx(,)}), {cmplx(1,1)} for 1D, {{cmplx(1,1)}} for 2D, {{{cmplx(1,1)}}} for 3D
Function/Wave wC(name,ww)
	string name
	wave/C ww
	duplicate/o/C/D ww $name
	return $name
end

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//********************   Complex Pauli matrix    ***********************//
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

Function/wave s0()
	make/N=(2,2)/o/C/D sigma0
	sigma0[0][0] = cmplx(1,0)
	sigma0[0][1] = cmplx(0,0)
	sigma0[1][0] = cmplx(0,0)
	sigma0[1][1] = cmplx(1,0)
	//sigma0 = {{1,0},{0,1}}
	//edit sigma0
	return sigma0
end

Function/wave sz()
	make/N=(2,2)/o/C/D sigmaz
	sigmaz[0][0] = cmplx(1,0)
	sigmaz[0][1] = cmplx(0,0)
	sigmaz[1][0] = cmplx(0,0)
	sigmaz[1][1] = cmplx(-1,0)
	//sigmaz = {{1,0},{0,-1}}
	//edit sigmaz
	return sigmaz
end

Function/wave sx()
	make/N=(2,2)/o/C/D sigmax
	sigmax[0][0] = cmplx(0,0)
	sigmax[0][1] = cmplx(1,0)
	sigmax[1][0] = cmplx(1,0)
	sigmax[1][1] = cmplx(0,0)
	//sigmax = {{0,1},{1,0}}
	//edit sigmax
	return sigmax
end

Function/wave sy()
	make/N=(2,2)/o/C/D sigmay
	//sigmay = {{0,cmplx(0,-1)},{cmplx(0,1),0}}
	sigmay[0][0] = cmplx(0,0)
	sigmay[0][1] = cmplx(0,-1)
	sigmay[1][0] = cmplx(0,1)
	sigmay[1][1] = cmplx(0,0)
	//edit sigmay
	return sigmay
end

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//********************     Text Pauli matrix     ***********************//
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
Function/wave st0()
	make/N=(2,2)/o/T sigmat0
	sigmat0[0][0] = "1"
	sigmat0[0][1] = "0"
	sigmat0[1][0] = "0"
	sigmat0[1][1] = "1"
	//sigma0 = {{1,0},{0,1}}
	//edit sigmat0
	return sigmat0
end

Function/wave stz()
	make/N=(2,2)/o/T sigmatz
	sigmatz[0][0] = "1"
	sigmatz[0][1] = "0"
	sigmatz[1][0] = "0"
	sigmatz[1][1] = "-1"
	//sigmaz = {{1,0},{0,-1}}
	//edit sigmatz
	return sigmatz
end

Function/wave stx()
	make/N=(2,2)/o/T sigmatx
	sigmatx[0][0] = "0"
	sigmatx[0][1] = "1"
	sigmatx[1][0] = "1"
	sigmatx[1][1] = "0"
	//sigmax = {{0,1},{1,0}}
	//edit sigmatx
	return sigmatx
end

Function/wave sty()
	make/N=(2,2)/o/T sigmaty
	//sigmay = {{0,cmplx(0,-1)},{cmplx(0,1),0}}
	sigmaty[0][0] = "0"
	sigmaty[0][1] = "-i"
	sigmaty[1][0] = "i"
	sigmaty[1][1] = "0"
	//edit sigmaty
	return sigmaty
end

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//**********   Old Examples for Hamiltonian deriviation  ***************//
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

//# 01. Old version Text; equation (1) of PRB 98, 214503
Function OldderivPRB98_214503_eq1_T()
	make/N=(1,1)/T/O e0
		e0={"e0"}//{"-u+(x^2+y^2)/(2*m)"}
	make/N=(1,1)/T/O Vxy
		Vxy={"Vxy"}//{"a*x*y"}
	make/N=(1,1)/T/O Vx
		Vx={"Vx"}//{"Vso*x"}
	make/N=(1,1)/T/O Vy
		Vy={"Vy"}//{"Vso*y"}

	mpt(e0,st0())
	wave/T prod2=$"prod2"
	duplicate/o/T prod2 seq1
	mpt(seq1,st0())
	wave/T prod2=$"prod2"
	duplicate/o/T prod2 result1

	mpt(Vxy,stz())
	wave/T prod2=$"prod2"
	duplicate/o/T prod2 seq2
	mpt(seq2,st0())
	wave/T prod2=$"prod2"
	duplicate/o/T prod2 result2

	mpt(Vx,stx())
	wave/T prod2=$"prod2"
	duplicate/o/T prod2 seq3
	mpt(seq3,sty())
	wave/T prod2=$"prod2"
	duplicate/o/T prod2 result3

	mpt(Vy,stx())
	wave/T prod2=$"prod2"
	duplicate/o/T prod2 seq4
	mpt(seq4,stx())
	wave/T prod2=$"prod2"
	duplicate/o/T prod2 result4



	plust(result1,result2)
	wave/T prod3=$"prod3"
	duplicate/o/T prod3 add1

	plust(add1,result3)
	wave/T prod3=$"prod3"
	duplicate/o/T prod3 add2

	plust(add2,result4)
	wave/T prod3=$"prod3"
	duplicate/o/T prod3 Final

	edit final
end

//# 02. Old version Text; equation (2) of PRB 98, 214503
Function OldderivPRB98_214503_eq2_T()
	make/N=(1,1)/T/O e0
		e0={"e0v"}//{"-u+(x^2+y^2)/(2*m)"}
	make/N=(1,1)/T/O Vxy
		Vxy={"Vxyv"}//{"a*x*y"}
	make/N=(1,1)/T/O Vx
		Vx={"Vxv"}//{"Vso*x"}
	make/N=(1,1)/T/O Vy
		Vy={"Vyv"}//{"Vso*y"}
	make/N=(1,1)/T/O mdd0
		mdd0={"-1*dd0v"}
	make/N=(1,1)/T/O mddz
		mddz={"-1*ddzv"}

	mpt(e0,stz())
	wave/T prod2=$"prod2"
	duplicate/o/T prod2 seq1
	mpt(seq1,st0())
	wave/T prod2=$"prod2"
	duplicate/o/T prod2 seq2
	mpt(seq2,st0())
	wave/T prod2=$"prod2"
	duplicate/o/T prod2 result1

	mpt(Vxy,stz())
	wave/T prod2=$"prod2"
	duplicate/o/T prod2 seq1
	mpt(seq1,stz())
	wave/T prod2=$"prod2"
	duplicate/o/T prod2 seq2
	mpt(seq2,st0())
	wave/T prod2=$"prod2"
	duplicate/o/T prod2 result2

	mpt(Vx,stz())
	wave/T prod2=$"prod2"
	duplicate/o/T prod2 seq1
	mpt(seq1,stx())
	wave/T prod2=$"prod2"
	duplicate/o/T prod2 seq2
	mpt(seq2,sty())
	wave/T prod2=$"prod2"
	duplicate/o/T prod2 result3

	mpt(Vy,st0())
	wave/T prod2=$"prod2"
	duplicate/o/T prod2 seq1
	mpt(seq1,stx())
	wave/T prod2=$"prod2"
	duplicate/o/T prod2 seq2
	mpt(seq2,stx())
	wave/T prod2=$"prod2"
	duplicate/o/T prod2 result4

	mpt(mdd0,sty())
	wave/T prod2=$"prod2"
	duplicate/o/T prod2 seq1
	mpt(seq1,st0())
	wave/T prod2=$"prod2"
	duplicate/o/T prod2 seq2
	mpt(seq2,sty())
	wave/T prod2=$"prod2"
	duplicate/o/T prod2 result5

	mpt(mddz,sty())
	wave/T prod2=$"prod2"
	duplicate/o/T prod2 seq1
	mpt(seq1,stz())
	wave/T prod2=$"prod2"
	duplicate/o/T prod2 seq2
	mpt(seq2,sty())
	wave/T prod2=$"prod2"
	duplicate/o/T prod2 result6

	plust(result1,result2)
	wave/T prod3=$"prod3"
	duplicate/o/T prod3 add1

	plust(add1,result3)
	wave/T prod3=$"prod3"
	duplicate/o/T prod3 add1

	plust(add1,result4)
	wave/T prod3=$"prod3"
	duplicate/o/T prod3 add1

	plust(add1,result5)
	wave/T prod3=$"prod3"
	duplicate/o/T prod3 add1

	plust(add1,result6)
	wave/T prod3=$"prod3"
	duplicate/o/T prod3 Final

	edit Final
	cktable(winname(0,2))
end

//# 03. Old version Numerical; equation (2) of PRB 98, 214503
Function OldDerivPRB98_214503_eq2_N()
	variable/c e0v = cmplx(2.65,0)
	variable/c Vxyv = cmplx(3.213,0)
	variable/c Vxv = cmplx(1.2345,0)
	variable/c Vyv = cmplx(324.34,0)
	variable/c dd0v = cmplx(123.213,0)
	variable/c ddzv = cmplx(24.1,0)

	make/N=(1,1)/O/c/D e0
		e0={e0v}//{"-u+(x^2+y^2)/(2*m)"}
	make/N=(1,1)/O/c/D Vxy
		Vxy={Vxyv}//{"a*x*y"}
	make/N=(1,1)/O/c/D Vx
		Vx={Vxv}//{"Vso*x"}
	make/N=(1,1)/O/c/D Vy
		Vy={Vyv}//{"Vso*y"}
	make/N=(1,1)/O/c/D mdd0
		mdd0={-dd0v}
	make/N=(1,1)/O/c/D mddz
		mddz={-ddzv}

	mpc(e0,sz())
	wave/c/D prod2=$"prod"
	duplicate/o/c/D prod2 seq1
	mpc(seq1,s0())
	wave/c/D prod2=$"prod"
	duplicate/o/c/D prod2 seq2
	mpc(seq2,s0())
	wave/c/D prod2=$"prod"
	duplicate/o/c/D prod2 result1

	mpc(Vxy,sz())
	wave/c/D prod2=$"prod"
	duplicate/o/c/D prod2 seq1
	mpc(seq1,sz())
	wave/c/D prod2=$"prod"
	duplicate/o/c/D prod2 seq2
	mpc(seq2,s0())
	wave/c/D prod2=$"prod"
	duplicate/o/c/D prod2 result2

	mpc(Vx,sz())
	wave/c/D prod2=$"prod"
	duplicate/o/c/D prod2 seq1
	mpc(seq1,sx())
	wave/c/D prod2=$"prod"
	duplicate/o/c/D prod2 seq2
	mpc(seq2,sy())
	wave/c/D prod2=$"prod"
	duplicate/o/c/D prod2 result3

	mpc(Vy,s0())
	wave/c/D prod2=$"prod"
	duplicate/o/c/D prod2 seq1
	mpc(seq1,sx())
	wave/c/D prod2=$"prod"
	duplicate/o/c/D prod2 seq2
	mpc(seq2,sx())
	wave/c/D prod2=$"prod"
	duplicate/o/c/D prod2 result4

	mpc(mdd0,sy())
	wave/c/D prod2=$"prod"
	duplicate/o/c/D prod2 seq1
	mpc(seq1,s0())
	wave/c/D prod2=$"prod"
	duplicate/o/c/D prod2 seq2
	mpc(seq2,sy())
	wave/c/D prod2=$"prod"
	duplicate/o/c/D prod2 result5

	mpc(mddz,sy())
	wave/c/D prod2=$"prod"
	duplicate/o/c/D prod2 seq1
	mpc(seq1,sz())
	wave/c/D prod2=$"prod"
	duplicate/o/c/D prod2 seq2
	mpc(seq2,sy())
	wave/c/D prod2=$"prod"
	duplicate/o/c/D prod2 result6

	duplicate/o/c/D prod2 Final

	Final= result1+result2+result3+result4+result5+result6

	edit Final
	cktable(winname(0,2))
end

Function/Wave diagM_cmplx(num)
	variable num
	make/n=(num,num)/O/C Diag
	Diag = 0
	variable i
	i=0
		do
			Diag[i][i] = 1

			i+=1
		while(i<num)
	return Diag
end

Function/Wave SubdiagM_cmplx(num)
	variable num
	make/n=(num,num)/O/C SubDiag
	SubDiag = 0
	variable i
	i=0
		do
			SubDiag[i+1][i] = 1

			i+=1
		while(i<num-1)
	return subDiag
end

Function/Wave SuperdiagM_cmplx(num)
	variable num
	make/n=(num,num)/O/C Superdiag
	Superdiag = 0
	variable i
	i=0
		do
			Superdiag[i][i+1] = 1

			i+=1
		while(i<num-1)
	return Superdiag
end


Function/Wave diagM(num)
	variable num
	make/n=(num,num)/O Diag
	Diag = 0
	variable i
	i=0
		do
			Diag[i][i] = 1

			i+=1
		while(i<num)
	return Diag
end

Function/Wave SubdiagM(num)
	variable num
	make/n=(num,num)/O SubDiag
	SubDiag = 0
	variable i
	i=0
		do
			SubDiag[i+1][i] = 1

			i+=1
		while(i<num-1)
	return subDiag
end

Function/Wave SuperdiagM(num)
	variable num
	make/n=(num,num)/O Superdiag
	Superdiag = 0
	variable i
	i=0
		do
			Superdiag[i][i+1] = 1

			i+=1
		while(i<num-1)
	return Superdiag
end
