#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#include <Peak AutoFind>
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
// Part 1 Multipeak extraction for linecut
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_t2nddpeakc(ctrlName) : ButtonControl
	String ctrlName
	Execute "t2nddpeakc()"
End
Proc t2nddpeakc(inputname,peaknum,smootht,smoothtadd,l1,l2,r1,r2,minPeakPercent,bgr)
	string inputname = tpw()
	variable peaknum = 3
	variable smootht = 20
	variable smoothtadd = 0
	variable l1 = -3
	variable l2 = -1
	variable r1 = 1
	variable r2 = 3
	variable minPeakPercent = 5
	variable bgr = 1
	prompt inputname,"The wave name for mp extract (1D or 2D)"//,popup,getall1or2dwave()
	prompt peaknum,"How much peaks in expectation"// = 3
	prompt smootht,"Times of smooth (both)"// = 20
	prompt smoothtadd,"Times of smooth (Add to right)"// = 0
	prompt l1,"L1 (meV)" //= -3
	prompt l2 ,"L2 (meV)" //= -1
	prompt r1 ,"R1 (meV)" //= 1
	prompt r2,"R2 (meV)" // = 3
	prompt minPeakPercent, "Minimum Peak Amplitude (% max)"// = 5
	prompt bgr,"Background remove (1) or not (0)"// = 1

	variable show = 1
	t2nddpeak(inputname,smootht,smoothtadd,peaknum,l1,l2,r1,r2,minPeakPercent,show,bgr)
end

Function/Wave t2nddpeak(inputname,smootht,smoothtadd,peaknum,l1,l2,r1,r2,minPeakPercent,show,bgr)
	string inputname
	variable smootht,smoothtadd,peaknum
	variable l1,l2,r1,r2,minPeakPercent,show,bgr

	string WA_PeakCentersX="WA_PeakCentersX"
	string WA_PeakCentersY="WA_PeakCentersY"
	String W_autoPeakinfo = "W_autoPeakinfo"
	variable i

	string/G inputname_pf = inputname
	variable/G nameindex_pf = 0
	variable/G smootht_pf = smootht
	variable/G peaknum_pf = peaknum
	variable/G l1_pf = l1
	variable/G l2_pf = l2
	variable/G r1_pf = r1
	variable/G r2_pf = r2
	variable/G minPeakPercent_pf = minPeakPercent
	variable/G show_pf = show
	variable/G bgr_pf = bgr
	variable/G smoothtadd_pf = smoothtadd
	variable/G extmode_pf = 1
	variable/G style_pf = 0
	//Make parameter matrix
		string param = "param_"+inputname_pf
		make/o/N=(dimsize($inputname_pf,1),10) $param
		wave paramw = $param
		paramw = nan
			paramw[nameindex_pf][0] = smootht_pf
			paramw[nameindex_pf][1] = peaknum_pf
			paramw[nameindex_pf][2] = l1_pf
			paramw[nameindex_pf][3] = l2_pf
			paramw[nameindex_pf][4] = r1_pf
			paramw[nameindex_pf][5] = r2_pf
			paramw[nameindex_pf][6] = minPeakPercent_pf
			paramw[nameindex_pf][7] = bgr_pf
			paramw[nameindex_pf][8] = smoothtadd_pf
			paramw[nameindex_pf][9] = extmode_pf
		setDimLabel 1,0,smootht_pf,paramw
		setDimLabel 1,1,peaknum_pf,paramw
 		setDimLabel 1,2,l1_pf,paramw
		setDimLabel 1,3,l2_pf,paramw
		setDimLabel 1,4,r1_pf,paramw
		setDimLabel 1,5,r2_pf,paramw
		setDimLabel 1,6,minPeakPercent_pf,paramw
		setDimLabel 1,7,bgr_pf,paramw
		setDimLabel 1,8,smoothtadd_pf,paramw
		setDimLabel 1,9,extmode_pf,paramw

	// Make 2nDD wave of the input wave
	wave inputnamew = $inputname
	string name = inputname+"_"+num2str(nameindex_pf)
	make/N=(dimsize($inputname,0))/o $name
	setscale/p x,dimoffset($inputname,0),dimdelta($inputname,0),"",$name
	wave namew = $name
	namew[] =  inputnamew[p][nameindex_pf]
	duplicate/o namew t2ndcurv; smooth smootht,t2ndcurv;differentiate t2ndcurv;smooth smootht,t2ndcurv;differentiate t2ndcurv;t2ndcurv*=-1
	duplicate/o/R=(l1,l2) t2ndcurv t2ndcurv_L
	duplicate/o namew t2ndcurv; smooth (smootht+smoothtadd_pf),t2ndcurv;differentiate t2ndcurv;smooth (smootht+smoothtadd_pf),t2ndcurv;differentiate t2ndcurv;t2ndcurv*=-1
	duplicate/o/R=(r1,r2) t2ndcurv t2ndcurv_R

	duplicate/o namew rawdidv
	/// Find peak after remove the 2nDD background
	if (bgr == 1)
		wavestats/Q t2ndcurv_L
		t2ndcurv_L-=2*V_min
		wavestats/Q t2ndcurv_R
		t2ndcurv_R-=2*V_min
		duplicate/o t2ndcurv_L smt2ndcurv_L
		duplicate/o t2ndcurv_R smt2ndcurv_R
		smooth 1500,smt2ndcurv_L //This is also tunable parameter
		smooth 1500,smt2ndcurv_R //This is also tunable parameter
		t2ndcurv_L/=smt2ndcurv_L
		t2ndcurv_R/=smt2ndcurv_R
	endif
	///

	// Get the peaks at the left side
	make/n=(peaknum+3,2)/o returnpeakl
	AutomaticallyFindPeaks1("t2ndcurv_L",100,minPeakPercent,0)
	wave WA_PeakCentersXw = $WA_PeakCentersX
	wave WA_PeakCentersYw = $WA_PeakCentersY
	wave W_autoPeakinfow = $W_autoPeakinfo
	duplicate/o WA_PeakCentersXw WA_PeakCentersXl
	duplicate/o WA_PeakCentersYw WA_PeakCentersYl

	if (show == 1)
		duplicate/o WA_PeakCentersYw WA_PeakCentersYlraw
		WA_PeakCentersYlraw= rawdidv[round((WA_PeakCentersXw-dimoffset(rawdidv,0))/dimdelta(rawdidv,0))]
	endif

	if (bgr == 1)
		WA_PeakCentersYl= t2ndcurv[round((WA_PeakCentersXw-dimoffset(t2ndcurv,0))/dimdelta(t2ndcurv,0))]
	endif
	i=0
	do
		if(i > dimsize(WA_PeakCentersXw,0)-1)
			returnpeakl[i][0]=nan
		else
			returnpeakl[i][0]=WA_PeakCentersXw[i]
		endif
		i+=1
	while(i<peaknum+3)

	// Get the peaks at the right side
	AutomaticallyFindPeaks2("t2ndcurv_R",100,minPeakPercent,0)
	wave WA_PeakCentersXw = $WA_PeakCentersX
	wave WA_PeakCentersYw = $WA_PeakCentersY
	wave W_autoPeakinfow = $W_autoPeakinfo
	duplicate/o WA_PeakCentersXw WA_PeakCentersXr
	duplicate/o WA_PeakCentersYw WA_PeakCentersYr

	if (show == 1)
		duplicate/o WA_PeakCentersYw WA_PeakCentersYrraw
		WA_PeakCentersYrraw= rawdidv[round((WA_PeakCentersXw-dimoffset(rawdidv,0))/dimdelta(rawdidv,0))]
	endif

	if (bgr == 1)
		WA_PeakCentersYr= t2ndcurv[round((WA_PeakCentersXw-dimoffset(t2ndcurv,0))/dimdelta(t2ndcurv,0))]
	endif

	i=0
	do
		if(i > dimsize(WA_PeakCentersXw,0)-1)
			returnpeakl[i][1]=nan
		else
			returnpeakl[i][1]=WA_PeakCentersXw[i]
		endif
		i+=1
	while(i<peaknum+3)
	killwaves t2ndcurv_L t2ndcurv_R smt2ndcurv_L smt2ndcurv_R

	// Display the extracted results or not
	if (show == 1)
		CheckDisplayed t2ndcurv
		if (V_flag == 1)
		else
			//Display 2ndd curve and Fitted dot
			display t2ndcurv;
			appendtograph  WA_PeakCentersYr vs WA_PeakCentersXr
			appendtograph  WA_PeakCentersYl vs WA_PeakCentersXl
			ModifyGraph mode(WA_PeakCentersYr)=3,marker(WA_PeakCentersYr)=19,rgb(WA_PeakCentersYr)=(0,0,65535),mode(WA_PeakCentersYl)=3,marker(WA_PeakCentersYl)=19,rgb(WA_PeakCentersYl)=(0,0,65535)

			//Display fitting range indicative lines
			make/n=(2)/o ll1_pf, ll2_pf, rr1_pf, rr2_pf
			ll1_pf = l1_pf
			ll2_pf = l2_pf
			rr1_pf = r1_pf
			rr2_pf = r2_pf
			wavestats/Q rawdidv
			setscale/i x,v_min,V_max,"",ll1_pf, ll2_pf, rr1_pf, rr2_pf
			AppendToGraph/L=StackedAxis_Hist/Vert ll1_pf, ll2_pf, rr1_pf, rr2_pf
			ModifyGraph lsize(ll1_pf)=3,rgb(ll1_pf)=(56797,56797,56797),lsize(ll2_pf)=3,rgb(ll2_pf)=(56797,56797,56797),lsize(rr1_pf)=3,rgb(rr1_pf)=(56797,56797,56797),lsize(rr2_pf)=3,rgb(rr2_pf)=(56797,56797,56797)

			//Display the raw data and Fitted dot
			AppendToGraph/L=StackedAxis_Hist rawdidv
			ModifyGraph standoff(left)=0,standoff(bottom)=0,axisEnab(left)={0,0.45}
			ModifyGraph axisEnab(StackedAxis_Hist)={0.55,1},freePos(StackedAxis_Hist)=0
			ModifyGraph margin(top)=20;ModifyGraph width= 600,height=500
			ModifyGraph mirror=2,tick=2,axThick=2
			appendtograph/L=StackedAxis_Hist  WA_PeakCentersYrraw vs WA_PeakCentersXr
			appendtograph/L=StackedAxis_Hist  WA_PeakCentersYlraw vs WA_PeakCentersXl
			ModifyGraph mode(WA_PeakCentersYrraw)=3,marker(WA_PeakCentersYrraw)=19,rgb(WA_PeakCentersYrraw)=(0,0,65535),mode(WA_PeakCentersYlraw)=3,marker(WA_PeakCentersYlraw)=19,rgb(WA_PeakCentersYlraw)=(0,0,65535)
			ModifyGraph msize(WA_PeakCentersYrraw)=1,msize(WA_PeakCentersYlraw)=1
			SetDrawEnv/W=$grabwinnonew("t2ndcurv") textyjust= 1,textrot= 90;DrawText/W=$grabwinnonew("t2ndcurv") -0.2,0.5,inputname_pf+"(MDC="+num2str(nameindex_pf)+")"
			//tilewindows/WINS=grabwinnonew("t2ndcurv")/R/A=(1,1)/w=(30,20,50,60)
			tilewindows/WINS=grabwinnonew("t2ndcurv")/R/A=(1,1)/w=(50.5,10,90,60)

			//Display extracted peak position on 2D linecut
			variable ii
			string gapline = inputname_pf+"_ex"
			string gaplinein
			if(dimsize($inputname_pf,1)==0)
			else
				//Activate display control
				di($inputname_pf);ModifyGraph width= 600,height=500
				//string exb = "popupmenu popselectext size={60,14},proc=PopMenuProc_const2nddpext,value=\"NO;YES\",title=\"crt?\",MODE="+num2str(extmode_pf+1)//+",pos={1,167}"
				//execute exb
				SetVariable Setconst2nddpext title="Corct.extrct.",size={100,14},value=extmode_pf,limits={0,1,1},proc=SetVarProc_const2nddpext
				SetVariable dotorline title="Style",pos={1,20},size={60,14},value=style_pf,limits={0,1,1},proc=SetVarProc_const2nddpstyle
				Button History title="Show\rdI/dV\rHistory",pos={1,38},size={43,43},fSize=10,proc=ButtonProc_t2nddpeakcd
				Button turnoff title="X",fSize=15,fstyle=1,size={20,18},valueColor=(0,0,0),fColor=(1,65535,33232),pos={695,5},proc=ButtonProc_t2nddpeakturnoff
				//make null gapline left
				ii=0
				do
					gaplinein=gapline+"_l"+num2str(ii+1)
					MAKE/N=(dimsize($inputname_pf,1))/o $gaplinein
					setscale/p x,dimoffset($inputname_pf,1),dimdelta($inputname_pf,1),"",$gaplinein
					wave gaplineinw = $gaplinein
					gaplineinw = 0
					appendtograph/W=$winname(0,1)/VERT  gaplineinw ///W=$grabwinnonew(inputname_pf)
					ModifyGraph/W=$winname(0,1) mode($gaplinein)=3,marker($gaplinein)=19,rgb($gaplinein)=(1,65535,33232),msize($gaplinein)=3///W=$grabwinnonew(inputname_pf)
					//display gaplineinw
					ii+=1
				while (ii < peaknum_pf)

				//make null gapline right
				ii=0
				do
					gaplinein=gapline+"_r"+num2str(ii+1)
					MAKE/N=(dimsize($inputname_pf,1))/o $gaplinein
					setscale/p x,dimoffset($inputname_pf,1),dimdelta($inputname_pf,1),"",$gaplinein
					wave gaplineinw = $gaplinein
					gaplineinw = 0
					appendtograph/W=$winname(0,1)/VERT  gaplineinw///W=$grabwinnonew(inputname_pf)
					ModifyGraph/W=$winname(0,1) mode($gaplinein)=3,marker($gaplinein)=19,rgb($gaplinein)=(1,65535,33232),msize($gaplinein)=3///W=$grabwinnonew(inputname_pf)
					//display gaplineinw
					ii+=1
				while (ii < peaknum_pf)

				//Assign value of gaplineleft
					if (extmode_pf == 0)
						ii=0
						do
							gaplinein=gapline+"_l"+num2str(ii+1)
							wave gaplineinw = $gaplinein
							gaplineinw[nameindex_pf] = returnpeakl[ii][0]
							ii+=1
						while (ii < peaknum_pf)
					endif

					if (extmode_pf == 1)
						ii=0
						do
							gaplinein=gapline+"_l"+num2str(ii+1)
							wave gaplineinw = $gaplinein
							if (nameindex_pf == 0)
								gaplineinw[nameindex_pf] = returnpeakl[ii][0]
							else
								duplicate/RMD=[0,*][0,0]/o returnpeakl differpfsort,differpf
								differpfsort-=gaplineinw[nameindex_pf-1]
								differpfsort=abs(differpfsort)
								sort differpfsort differpf
								gaplineinw[nameindex_pf] =	differpf[0]
							endif
							ii+=1
						while (ii < peaknum_pf)
					endif

				//Assign value of gaplineright
					if (extmode_pf == 0)
						ii=0
						do
							gaplinein=gapline+"_r"+num2str(ii+1)
							wave gaplineinw = $gaplinein
							gaplineinw[nameindex_pf] = returnpeakl[ii][1]
							ii+=1
						while (ii < peaknum_pf)
					endif

					if (extmode_pf == 1)
						ii=0
						do
							gaplinein=gapline+"_r"+num2str(ii+1)
							wave gaplineinw = $gaplinein
							if (nameindex_pf == 0)
								gaplineinw[nameindex_pf] = returnpeakl[ii][1]
							else
								duplicate/RMD=[0,*][1,1]/o returnpeakl differpfsort,differpf
								differpfsort-=gaplineinw[nameindex_pf-1]
								differpfsort=abs(differpfsort)
								sort differpfsort differpf
								gaplineinw[nameindex_pf] =	differpf[0]
							endif
							ii+=1
						while (ii < peaknum_pf)
					endif

				//append MDC indicative line to 2D linecut
				make/o/N=(2) linecutmdcind
				setscale/i x,dimoffset($inputname_pf,0),dimoffset($inputname_pf,0)+(dimsize($inputname_pf,0)-1)*dimdelta($inputname_pf,0),"",linecutmdcind
				linecutmdcind = dimoffset($inputname_pf,1)+nameindex_pf*dimdelta($inputname_pf,1)
				//print winname(0,1)
				//appendtograph/W=$grabwinnonew(inputname_pf) linecutmdcind
				//ModifyGraph/W=$grabwinnonew(inputname_pf) mode(linecutmdcind)=0,lstyle(linecutmdcind)=1,rgb(linecutmdcind)=(65535,65535,65535)
				//tilewindows/WINS=grabwinnonew(inputname_pf)/R/A=(1,1)/w=(10,20,30,60)

				appendtograph/W=$winname(0,1) linecutmdcind
				ModifyGraph/W=$winname(0,1) mode(linecutmdcind)=0,lstyle(linecutmdcind)=1,rgb(linecutmdcind)=(65535,65535,65535)
				//tilewindows/WINS=winname(0,1)/R/A=(1,1)/w=(10,20,30,60)
				tilewindows/WINS=winname(0,1)/R/A=(1,1)/w=(3,10,30,60)

				//tilewindows/WINS=grabwinnonew("linecutmdcind")/R/A=(1,1)/w=(10,20,30,60)
			endif

			//activiate interaction control
			const2nddpeak()
		endif
	else
		checkdisplayed namew
		if(V_flag == 1)
			killwindow $grabwinnonew(name)
		endif
		killwaves WA_PeakCentersXr WA_PeakCentersYr WA_PeakCentersXl WA_PeakCentersYl t2ndcurv rawdidv
	endif
	return returnpeakl
end


Function const2nddpeak()
	string/G inputname_pf
	variable/G nameindex_pf //= 0
	variable/G smootht_pf //= smootht
	variable/G peaknum_pf //= peaknum
	variable/G l1_pf //= l1
	variable/G l2_pf //= l2
	variable/G r1_pf //= r1
	variable/G r2_pf //= r2
	variable/G minPeakPercent_pf //= minPeakPercent
	variable/G show_pf //= show
	variable/G bgr_pf //= bgr
	Dowindow/F $winname(1,1)
	SetVariable setnameindex_pf title="MDC index",pos={1,179},size={100,14},value=nameindex_pf,limits={0,dimsize($inputname_pf,1)-1,1},proc=SetVarProc_const2nddpeakind
	SetVariable setsmootht_pf title="Smt.(both)",pos={103,179},size={100,14},value=smootht_pf,limits={1,inf,5},proc=SetVarProc_const2nddpeaksmt2ndd
	SetVariable setsmootht_pfadd title="Smt.(addR)",pos={103,195},size={100,15},value=smoothtadd_pf,limits={-smootht_pf+1,inf,5},proc=SetVarProc_const2nddpeaksmt2nddadd
	SetVariable setminPeakPercent_pf title="minPeak%",pos={207,195},size={100,14},value=minPeakPercent_pf,limits={0,100,1},proc=SetVarProc_const2nddpeakmp
	SetVariable setl1_pf title="L1",pos={23,1},size={60,20},value=l1_pf,limits={-inf,inf,0.1},proc=SetVarProc_const2nddpeakl1
	SetVariable setl2_pf title="L2",pos={85,1},size={60,20},value=l2_pf,limits={-inf,inf,0.1},proc=SetVarProc_const2nddpeakl2
	SetVariable setr1_pf title="R1",pos={183,1},size={60,20},value=r1_pf,limits={-inf,inf,0.1},proc=SetVarProc_const2nddpeakr1
	SetVariable setr2_pf title="R2",pos={244,1},size={60,20},value=r2_pf,limits={-inf,inf,0.1},proc=SetVarProc_const2nddpeakr2
	//SetVariable setpeaknum_pf value=peaknum_pf,limits={1,inf,1},proc=SetVarProc_const2nddpeakpm,pos={246,1},size={70,20},title="Peaknm"
		//string exb = "popupmenu popselectmode size={60,14},proc=PopMenuProc_const2nddpeakmode,value=\"NO;YES\",title=\"BGR?\",MODE="+num2str(bgr_pf+1)+",pos={1,167}"
		//execute exb
	SetVariable popselectmode title="2dDBgRemove?",pos={1,195},size={99,14},value=bgr_pf,limits={0,1,1},proc=SetVarProc_const2nddpeakmode

	SetVariable setnameindex_pf pos={70,255}
	SetVariable popselectmode pos={70,271}
	SetVariable setsmootht_pf pos={172,255}
	SetVariable setsmootht_pfadd pos={172,271}
	SetVariable setminPeakPercent_pf pos={276,271}
	SetVariable setl1_pf pos={215,2}
	SetVariable setl2_pf pos={277,2}
	SetVariable setr1_pf pos={398,2}
	SetVariable setr2_pf pos={459,2}

	Button Manualext proc=ButtonProc_manualvalue_1Dextracp,title="Manual. Extraction",size={120,20},fSize=13,pos={5,2}



end


Function SetVarProc_const2nddpstyle(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/G style_pf
	style_pf = varNum

	string linecutmdcind = "linecutmdcind"
	if (style_pf == 0)
		ModifyGraph mode=3;ModifyGraph mode($linecutmdcind)=0
	endif
	if (style_pf == 1)
		ModifyGraph mode=4;ModifyGraph mode($linecutmdcind)=0
	endif

end

Function SetVarProc_const2nddpext(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	const2nddpeakcontrol()
end

//Function PopMenuProc_const2nddpext(ctrlName,popNum,popStr) : PopupMenuControl
//	String ctrlName
//	Variable popNum
//	String popStr
//	variable/G extmode_pf = popNum-1
//	//PRINT popStr, bgr_pf
//
//	const2nddpeakcontrol()
//end


//Function PopMenuProc_const2nddpeakmode(ctrlName,popNum,popStr) : PopupMenuControl
//	String ctrlName
//	Variable popNum
//	String popStr
//	variable/G bgr_pf = popNum-1
	//PRINT popStr, bgr_pf

//	const2nddpeakcontrol()
//end

Function SetVarProc_const2nddpeakmode(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	const2nddpeakcontrol()
end


Function SetVarProc_const2nddpeakmp(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	const2nddpeakcontrol()
end

Function SetVarProc_const2nddpeakr2(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	const2nddpeakcontrol()
end

Function SetVarProc_const2nddpeakr1(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	const2nddpeakcontrol()
end

Function SetVarProc_const2nddpeakl2(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	const2nddpeakcontrol()
end

Function SetVarProc_const2nddpeakl1(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	const2nddpeakcontrol()
end

Function SetVarProc_const2nddpeakpm(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	const2nddpeakcontrol()
end

Function SetVarProc_const2nddpeaksmt2nddadd(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	const2nddpeakcontrol()
End

Function SetVarProc_const2nddpeaksmt2ndd(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	const2nddpeakcontrol()
End
Function SetVarProc_const2nddpeakind(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	const2nddpeakcontrol()
End

Function/Wave const2nddpeakcontrol()
	string WA_PeakCentersX="WA_PeakCentersX"
	string WA_PeakCentersY="WA_PeakCentersY"
	String W_autoPeakinfo = "W_autoPeakinfo"
	variable i

	string/G inputname_pf
	variable/G nameindex_pf //= 0
	variable/G smootht_pf //= smootht
	variable/G peaknum_pf //= peaknum
	variable/G l1_pf //= l1
	variable/G l2_pf //= l2
	variable/G r1_pf //= r1
	variable/G r2_pf //= r2
	variable/G minPeakPercent_pf //= minPeakPercent
	variable/G show_pf //= show
	variable/G bgr_pf //= bgr
	variable/G smoothtadd_pf
	variable/G extmode_pf

	// Make 2nDD wave of the input wave
	wave inputnamew = $inputname_pf
	string name = inputname_pf+"_"+num2str(nameindex_pf)
	make/N=(dimsize($inputname_pf,0))/o $name
	setscale/p x,dimoffset($inputname_pf,0),dimdelta($inputname_pf,0),"",$name
	wave namew = $name
	namew[] =  inputnamew[p][nameindex_pf]
	duplicate/o namew t2ndcurv; smooth smootht_pf,t2ndcurv;differentiate t2ndcurv;smooth smootht_pf,t2ndcurv;differentiate t2ndcurv;t2ndcurv*=-1
	duplicate/o/R=(l1_pf,l2_pf) t2ndcurv t2ndcurv_L
	duplicate/o namew t2ndcurv; smooth (smootht_pf+smoothtadd_pf),t2ndcurv;differentiate t2ndcurv;smooth (smootht_pf+smoothtadd_pf),t2ndcurv;differentiate t2ndcurv;t2ndcurv*=-1
	duplicate/o/R=(r1_pf,r2_pf) t2ndcurv t2ndcurv_R

	duplicate/o namew rawdidv
	/// Find peak after remove the 2nDD background
	if (bgr_pf == 1)
		wavestats/Q t2ndcurv_L
		t2ndcurv_L-=2*V_min
		wavestats/Q t2ndcurv_R
		t2ndcurv_R-=2*V_min
		duplicate/o t2ndcurv_L smt2ndcurv_L
		duplicate/o t2ndcurv_R smt2ndcurv_R
		smooth 1500,smt2ndcurv_L //This is also tunable parameter
		smooth 1500,smt2ndcurv_R //This is also tunable parameter
		t2ndcurv_L/=smt2ndcurv_L
		t2ndcurv_R/=smt2ndcurv_R
	endif
	///

	// Get the peaks at the left side
	make/n=(peaknum_pf+3,2)/o returnpeakl
	AutomaticallyFindPeaks1("t2ndcurv_L",100,minPeakPercent_pf,0)
	wave WA_PeakCentersXw = $WA_PeakCentersX
	wave WA_PeakCentersYw = $WA_PeakCentersY
	wave W_autoPeakinfow = $W_autoPeakinfo
	duplicate/o WA_PeakCentersXw WA_PeakCentersXl
	duplicate/o WA_PeakCentersYw WA_PeakCentersYl
	duplicate/o WA_PeakCentersYw WA_PeakCentersYlraw
	WA_PeakCentersYlraw= rawdidv[round((WA_PeakCentersXw-dimoffset(rawdidv,0))/dimdelta(rawdidv,0))]

	if (bgr_pf == 1)
		WA_PeakCentersYl= t2ndcurv[round((WA_PeakCentersXw-dimoffset(t2ndcurv,0))/dimdelta(t2ndcurv,0))]
	endif
	i=0
	do
		if(i > dimsize(WA_PeakCentersXw,0)-1)
			returnpeakl[i][0]=nan
		else
			returnpeakl[i][0]=WA_PeakCentersXw[i]
		endif
		i+=1
	while(i<peaknum_pf+3)

	// Get the peaks at the right side
	AutomaticallyFindPeaks2("t2ndcurv_R",100,minPeakPercent_pf,0)
	wave WA_PeakCentersXw = $WA_PeakCentersX
	wave WA_PeakCentersYw = $WA_PeakCentersY
	wave W_autoPeakinfow = $W_autoPeakinfo
	duplicate/o WA_PeakCentersXw WA_PeakCentersXr
	duplicate/o WA_PeakCentersYw WA_PeakCentersYr
	duplicate/o WA_PeakCentersYw WA_PeakCentersYrraw
	WA_PeakCentersYrraw= rawdidv[round((WA_PeakCentersXw-dimoffset(rawdidv,0))/dimdelta(rawdidv,0))]

	if (bgr_pf == 1)
		WA_PeakCentersYr= t2ndcurv[round((WA_PeakCentersXw-dimoffset(t2ndcurv,0))/dimdelta(t2ndcurv,0))]
	endif

	i=0
	do
		if(i > dimsize(WA_PeakCentersXw,0)-1)
			returnpeakl[i][1]=nan
		else
			returnpeakl[i][1]=WA_PeakCentersXw[i]
		endif
		i+=1
	while(i<peaknum_pf+3)
	killwaves t2ndcurv_L t2ndcurv_R smt2ndcurv_L smt2ndcurv_R

	//update the indicative lines
			make/n=(2)/o ll1_pf, ll2_pf, rr1_pf, rr2_pf
			ll1_pf = l1_pf
			ll2_pf = l2_pf
			rr1_pf = r1_pf
			rr2_pf = r2_pf
			wavestats/Q rawdidv
			setscale/i x,v_min,V_max,"",ll1_pf, ll2_pf, rr1_pf, rr2_pf

	//Update the extracted dot at 2D linecut
			variable ii
			string gapline = inputname_pf+"_ex"
			string gaplinein
			if(dimsize($inputname_pf,1)==0)
			else

				//Assign value of gaplineleft
					if (extmode_pf == 0)
						ii=0
						do
							gaplinein=gapline+"_l"+num2str(ii+1)
							wave gaplineinw = $gaplinein
							gaplineinw[nameindex_pf] = returnpeakl[ii][0]
							ii+=1
						while (ii < peaknum_pf)
					endif

					if (extmode_pf == 1)
						ii=0
						do
							gaplinein=gapline+"_l"+num2str(ii+1)
							wave gaplineinw = $gaplinein
							if (nameindex_pf == 0)
								gaplineinw[nameindex_pf] = returnpeakl[ii][0]
							else
								duplicate/RMD=[0,*][0,0]/o returnpeakl differpfsort,differpf
								differpfsort-=gaplineinw[nameindex_pf-1]
								differpfsort=abs(differpfsort)
								sort differpfsort differpf
								gaplineinw[nameindex_pf] =	differpf[0]
							endif
							ii+=1
						while (ii < peaknum_pf)
					endif

				//Assign value of gaplineright
					if (extmode_pf == 0)
						ii=0
						do
							gaplinein=gapline+"_r"+num2str(ii+1)
							wave gaplineinw = $gaplinein
							gaplineinw[nameindex_pf] = returnpeakl[ii][1]
							ii+=1
						while (ii < peaknum_pf)
					endif

					if (extmode_pf == 1)
						ii=0
						do
							gaplinein=gapline+"_r"+num2str(ii+1)
							wave gaplineinw = $gaplinein
							if (nameindex_pf == 0)
								gaplineinw[nameindex_pf] = returnpeakl[ii][1]
							else
								duplicate/RMD=[0,*][1,1]/o returnpeakl differpfsort,differpf
								differpfsort-=gaplineinw[nameindex_pf-1]
								differpfsort=abs(differpfsort)
								sort differpfsort differpf
								gaplineinw[nameindex_pf] =	differpf[0]
							endif
							ii+=1
						while (ii < peaknum_pf)
					endif
			endif
	//Update MDC indicative line on 2D linecut
			make/o/N=(2) linecutmdcind
			setscale/i x,dimoffset($inputname_pf,0),dimoffset($inputname_pf,0)+(dimsize($inputname_pf,0)-1)*dimdelta($inputname_pf,0),"",linecutmdcind
			linecutmdcind = dimoffset($inputname_pf,1)+nameindex_pf*dimdelta($inputname_pf,1)
	//Update label
			DrawAction/W=$grabwinnonew("t2ndcurv")  delete
			SetDrawEnv/W=$grabwinnonew("t2ndcurv")  textyjust= 1,textrot= 90;DrawText/W=$grabwinnonew("t2ndcurv") -0.2,0.5,inputname_pf+"(MDC="+num2str(nameindex_pf)+")"
	//Make parameter matrix
			string param = "param_"+inputname_pf
			wave paramw = $param
			// Coloum sequences (smootht_pf,peaknum_pf,l1_pf,l2_pf,r1_pf,r2_pf,minPeakPercent_pf,bgr_pf,smoothtadd_pf,extmode_pf)
			// Row sequences (follow the nameindex_pf)
			paramw[nameindex_pf][0] = smootht_pf
			paramw[nameindex_pf][1] = peaknum_pf
			paramw[nameindex_pf][2] = l1_pf
			paramw[nameindex_pf][3] = l2_pf
			paramw[nameindex_pf][4] = r1_pf
			paramw[nameindex_pf][5] = r2_pf
			paramw[nameindex_pf][6] = minPeakPercent_pf
			paramw[nameindex_pf][7] = bgr_pf
			paramw[nameindex_pf][8] = smoothtadd_pf
			paramw[nameindex_pf][9] = extmode_pf
	return returnpeakl
end





Proc AutomaticallyFindPeaksc(wname,maxPeaks,minPeakPercent,show)
	String wname = tpw()
	Variable maxPeaks = 100
	variable minPeakPercent = 5
	variable show = 0
	Prompt wname, "Peak Wave", popup, WaveList("*",";","DIMS:1,TEXT:0,CMPLX:0")+"_none_;"
	Prompt maxPeaks, "Maximum Peaks"
	Prompt minPeakPercent, "Minimum Peak Amplitude (% max)"
	AutomaticallyFindPeaks2(wname,maxPeaks,minPeakPercent,show)
	//AutomaticallyFindPeaks2(wname,100,1,0)
end
Function AutomaticallyFindPeaks1(wname,maxPeaks,minPeakPercent,show)
	String wname
	Variable maxPeaks, minPeakPercent
	variable show
	string xdata="_calculated_"

	//Prompt wname, "Peak Wave", popup, WaveList("*",";","DIMS:1,TEXT:0,CMPLX:0")+"_none_;"
	//Prompt xdata, "X values", popup, "_calculated_;"+WaveList("*",";","DIMS:1,TEXT:0,CMPLX:0")
	//Prompt maxPeaks, "Maximum Peaks"
	//Prompt minPeakPercent, "Minimum Peak Amplitude (% max)"
	//DoPrompt "Automatically Find Peaks", wname, xdata, maxPeaks, minPeakPercent
	//if( V_Flag != 0 )
	//	return 0	// user cancelled
	//endif

	WAVE/Z w=$wname
	WAVE/Z wx=$xdata
	Variable pBegin=0, pEnd= numpnts(w)-1
	Variable/C estimates= EstPeakNoiseAndSmfact2(w,pBegin, pEnd)
	Variable noiselevel=real(estimates)
	Variable smoothingFactor=imag(estimates)

	AutoFindPeaksWorker2(w, wx, pBegin, pEnd, maxPeaks, minPeakPercent, noiseLevel, smoothingFactor,show)
	string WA_PeakCentersX="WA_PeakCentersX"
	wave WA_PeakCentersXw = $WA_PeakCentersX
	string WA_PeakCentersY="WA_PeakCentersY"
	wave WA_PeakCentersYw = $WA_PeakCentersY
	String W_autoPeakinfo = "W_autoPeakinfo"
	wave W_autoPeakinfow = $W_autoPeakinfo
	sortColumns/R keyWaves=WA_PeakCentersXw,sortWaves=W_autoPeakinfow;Sort/R WA_PeakCentersXw,WA_PeakCentersYw;DelayUpdate;Sort/R WA_PeakCentersXw,WA_PeakCentersXw;DelayUpdate

end
Function AutomaticallyFindPeaks2(wname,maxPeaks,minPeakPercent,show)
	String wname
	Variable maxPeaks, minPeakPercent
	variable show
	string xdata="_calculated_"

	//Prompt wname, "Peak Wave", popup, WaveList("*",";","DIMS:1,TEXT:0,CMPLX:0")+"_none_;"
	//Prompt xdata, "X values", popup, "_calculated_;"+WaveList("*",";","DIMS:1,TEXT:0,CMPLX:0")
	//Prompt maxPeaks, "Maximum Peaks"
	//Prompt minPeakPercent, "Minimum Peak Amplitude (% max)"
	//DoPrompt "Automatically Find Peaks", wname, xdata, maxPeaks, minPeakPercent
	//if( V_Flag != 0 )
	//	return 0	// user cancelled
	//endif

	WAVE/Z w=$wname
	WAVE/Z wx=$xdata
	Variable pBegin=0, pEnd= numpnts(w)-1
	Variable/C estimates= EstPeakNoiseAndSmfact2(w,pBegin, pEnd)
	Variable noiselevel=real(estimates)
	Variable smoothingFactor=imag(estimates)

	AutoFindPeaksWorker2(w, wx, pBegin, pEnd, maxPeaks, minPeakPercent, noiseLevel, smoothingFactor,show)
	string WA_PeakCentersX="WA_PeakCentersX"
	wave WA_PeakCentersXw = $WA_PeakCentersX
	string WA_PeakCentersY="WA_PeakCentersY"
	wave WA_PeakCentersYw = $WA_PeakCentersY
	String W_autoPeakinfo = "W_autoPeakinfo"
	wave W_autoPeakinfow = $W_autoPeakinfo
	sortColumns keyWaves=WA_PeakCentersXw,sortWaves=W_autoPeakinfow;Sort WA_PeakCentersXw,WA_PeakCentersYw;DelayUpdate;Sort WA_PeakCentersXw,WA_PeakCentersXw;DelayUpdate

end
Function AutoFindPeaksWorker2(w, wx, pBegin, pEnd, maxPeaks, minPeakPercent, noiseLevel, smoothingFactor,show)
	WAVE w
	WAVE/Z wx
	Variable pBegin, pEnd
	Variable maxPeaks, minPeakPercent, noiseLevel, smoothingFactor
	variable show

	Variable peaksFound= AutoFindPeaks(w,pBegin,pEnd,noiseLevel,smoothingFactor,maxPeaks)
	if( peaksFound > 0 )
		WAVE W_AutoPeakInfo
		// Remove too-small peaks
		peaksFound= TrimAmpAutoPeakInfo(W_AutoPeakInfo,minPeakPercent/100)
		if( peaksFound > 0 )
			// Make waves to display in a graph
			// The x values in W_AutoPeakInfo are still actually points, not X
			Make/O/N=(peaksFound) WA_PeakCentersY = w[W_AutoPeakInfo[p][0]]
			AdjustAutoPeakInfoForX(W_AutoPeakInfo,w,wx)
			Make/O/N=(peaksFound) WA_PeakCentersX = W_AutoPeakInfo[p][0]

			if (show == 0)
			else
				// Show W_AutoPeakInfo in a table, with dimension labels
				SetDimLabel 1, 0, center, W_AutoPeakInfo
				SetDimLabel 1, 1, width, W_AutoPeakInfo
				SetDimLabel 1, 2, height, W_AutoPeakInfo

				CheckDisplayed/A W_AutoPeakInfo
				if( V_Flag == 0 )
					Edit W_AutoPeakInfo.ld
				endif

				DoWindow ShowPeaks
				if( V_Flag == 0 )
					if( WaveExists(wx) )
						Display/N=ShowPeaks w vs wx
					else
						Display/N=ShowPeaks w
					endif
					AppendToGraph/W=ShowPeaks WA_PeakCentersY vs WA_PeakCentersX
					ModifyGraph/W=ShowPeaks rgb(WA_PeakCentersY)=(0,0,65535)
					ModifyGraph/W=ShowPeaks mode(WA_PeakCentersY)=3
					ModifyGraph/W=ShowPeaks marker(WA_PeakCentersY)=19
				endif
			endif
		endif
	endif
	if( peaksFound < 1 )
		DoAlert 0, "No Peaks found!"
	endif
	return peaksFound
End
Function/C EstPeakNoiseAndSmfact2(w,pBegin,pEnd[,userWidth])
	Wave w
	Variable pBegin,pEnd
	Variable userWidth					// ST: 221202 - in points; will provide a better guess if S/N ratio is below 100

	if (abs(pBegin-pEnd) < 21)			// 21 is pretty arbitrary; this is intended to avoid trying to apply this test to unreasonably small waves. Even a 10-point wave is probably a mistake: a fit coefficient wave was selected by mistake or something.
		return cmplx(0,0)
	endif

	if( pBegin > pEnd )
		Variable tmp = pBegin
		pBegin = pEnd
		pEnd = tmp
	endif

	pBegin = max(pBegin,0)
	pEnd = min(pEnd,numpnts(w)-1)

	if (pEnd - pBegin < 150)
		Variable resampleFactor = max(2, ceil(150/(pEnd - pBegin)))
		Duplicate/FREE w, resampledY
		Resample/UP=(resampleFactor)/WINF=None resampledY
		Wave w = resampledY
		pBegin *= resampleFactor
		pEnd *= resampleFactor
	endif

	// ST: prepare data folder and differentiated data waves.
	NewDataFolder/S/O AutoFindPeaksTemp
	Duplicate/O/R=[pBegin,pEnd] w, w_temp
	Differentiate w_temp
	Duplicate/O w_temp, w_temp_OrigDif

	// ST: estimate noise level and S/N ratio from data histogram and its cumulative distribution function (CDF).
	Variable Histpnts = 999
	Make/O/N=(Histpnts+1) DataHistogram
	Histogram/B=1 w_temp, DataHistogram
	Duplicate/O DataHistogram, DataHistogram_Int
	Integrate DataHistogram_Int

	// ST: extract the width of the CDF around the center which should be an indication of the noise.
	FindLevel/Q DataHistogram_Int, (0.5 - 0.1) * DataHistogram_Int[Histpnts]
	Variable x0 = V_LevelX
	FindLevel/Q DataHistogram_Int, (0.5 + 0.1) * DataHistogram_Int[Histpnts]
	Variable x1 = V_LevelX
	Variable NoiseLevel		= abs(2*(x1-x0)*deltax(w))
	Variable SignalToNoise	= (pnt2x(DataHistogram_Int, Histpnts)-pnt2x(DataHistogram_Int, 0))/(x1-x0)

	// ST: the maximum useful smoothing factor depends on the size of the input wave.
	Variable maxSmoothFactor= max(2, (pEnd-pBegin+1)/20)

	// ST: create a wave with succesively increasing smoothing factors (not used).
	Variable nMaxSF=2* ceil(sqrt(maxSmoothFactor))
	Make/O/N=(nMaxSF) w_Smoothed_SNratio = 0, w_SmoothFactor = round((p/2)^2)

	// ST: another method to create a wave with successively increasing smoothing factors. This overrides the ones above.
	Variable nLinFactors, nSpacedFactors

	if( maxSmoothFactor < 20 )	// ST: smoothing factors increase only linearly.
		nSpacedFactors = 0
		nLinFactors = maxSmoothFactor
	else						// ST: smoothing factors increase linearly for the first 10 point, then quadratic for the next 20 points.
		nLinFactors = 10
		nSpacedFactors = 20
	endif

	nMaxSF = nLinFactors + nSpacedFactors
	Make/O/N=(nMaxSF) w_Smoothed_SNratio = 0, w_SmoothFactor = p+1

	if( nSpacedFactors > 0 )	// ST: the quadratic part will be scaled to end at the maxSmoothFactor value.
		Variable accelerator = (maxSmoothFactor-nLinFactors)/nSpacedFactors^2
		w_SmoothFactor[nLinFactors,*]= ceil(nLinFactors + accelerator * (p - nLinFactors + 1)^2)
	endif

	// ST: successively increase the smoothing factor and observe how the S/N ratio changes as the noise (and then the signal) is suppressed. Want to find optimal compromise here.
	Variable i = 1,imax = min(nMaxSF, numpnts(w_SmoothFactor))
	w_Smoothed_SNratio[0] = SignalToNoise				// ST: the first (unsmoothed) value is already done above.
	do
		Duplicate/O w_temp_OrigDif, w_temp
		Smooth/E=2/B=3 2*w_SmoothFactor[i]+1, w_temp
		Histogram/B=1 w_temp, DataHistogram
		Duplicate/O DataHistogram, DataHistogram_Int
		Integrate DataHistogram_Int

		FindLevel/Q DataHistogram_Int, (0.5 - 0.1) * DataHistogram_Int[Histpnts]
		x0 = V_LevelX
		FindLevel/Q DataHistogram_Int, (0.5 + 0.1) * DataHistogram_Int[Histpnts]
		x1 = V_LevelX
		SignalToNoise = (pnt2x(DataHistogram_Int, Histpnts)-pnt2x(DataHistogram_Int, 0))/(x1-x0)
		w_Smoothed_SNratio[i]= SignalToNoise			// ST: next S/N ratio result
		i+=1
	while(i<imax)
	WaveTransform zapNaNs w_Smoothed_SNratio			// ST: 200806 - get rid of any NaN values
	WaveStats/Q/R=[2,] w_Smoothed_SNratio
	Variable SmoothFactor = maxSmoothFactor
	if (V_maxloc > -1)									// ST: 200806 - make sure there is any value at all
		SmoothFactor = w_SmoothFactor[V_maxloc]			// ST: maximal S/N ratio achieved here
	endif

	// added heuristics
	// Variable SmoothFactorwpd=0
	do
		if( w_Smoothed_SNratio[V_maxloc] < 100 )		// ST: S/N ratio somewhat too low => try to estimate the right smoothing factor to find a peak.
			i=0
			do
				Variable findPeaksReturn = AutoFindPeaks(w,pBegin,pEnd,noiselevel*10,w_SmoothFactor[i],1)
				//Variable findPeaksReturnOrig = AutoFindPeaksOriginal(w,pBegin,pEnd,noiselevel*10,w_SmoothFactor[i],1)
				//Variable findPeaksReturnNew = AutoFindPeaksNew(w,pBegin,pEnd,noiselevel*10,w_SmoothFactor[i],1)
				//print "Smooth Factor:", w_SmoothFactor[i], "Original:", findPeaksReturnOrig, "New:", findPeaksReturnNew

				//if( findPeaksReturnOrig > 0 )
				//if( findPeaksReturnNew > 0 )
				if( findPeaksReturn > 0 )				// ST: successfully found at least one peak at the current smoothing level.
					Wave wpd= W_AutoPeakInfo
					//SmoothFactorwpd = floor(wpd[0][1]/3)
					SmoothFactor = round(wpd[0][1]/3)	// ST: take around 1/3 of the width of the first found peak.
					//print "TRIAL FIND",wpd[0][1],SmoothFactor,i,w_SmoothFactor[i],w_Smoothed_SNratio[V_maxloc],w_Smoothed_SNratio[i]
					break;
				endif
				i+=1
			while(i<imax)
			if( findPeaksReturn > 0 )
				break
			endif
		endif
		// If really low snr and couldn't find a principal peak, force high smooth factors
		if( w_Smoothed_SNratio[V_maxloc] < 20 )
			SmoothFactor= maxSmoothFactor
			break
		endif
		if( w_Smoothed_SNratio[V_maxloc] < 30 )
			SmoothFactor= round(maxSmoothFactor/4)
			break
		endif
		if( w_Smoothed_SNratio[V_maxloc] < 50 )
			SmoothFactor= round(maxSmoothFactor/6)
			break
		endif
	while(0)

	if (!ParamIsDefault(userWidth) && userWidth > 0)
		SmoothFactor = limit(SmoothFactor,round(userWidth/3),inf)		// ST: 221205 - use user-provided width as lower limit
	endif

	if( SmoothFactor < 2 )
		SmoothFactor = 2
	endif
	//SmoothFactor = max(SmoothFactor, SmoothFactorwpd)

	KillDataFolder :
	//print noiselevel, SmoothFactor
	return cmplx(noiselevel,SmoothFactor)
end



////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
// Part 2 Extraction History Displayer
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

Function ButtonProc_t2nddpeakturnoff(ctrlName) : ButtonControl
	String ctrlName
	killwindow $grabwinnonew(tpw())
	killwindow $grabwinnonew("t2ndcurv")
	killwindow $grabwinnonew("t2ndcurvd")
	string/G inputname_pf
	string tablename = grabtablenonew("param_"+inputname_pf)
	killwindow $tablename

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

Function ButtonProc_t2nddpeakcd(ctrlName) : ButtonControl
	String ctrlName
	Execute "t2nddpeakcd()"
End
Proc t2nddpeakcd()
	t2nddpeakd()
end

Function/Wave t2nddpeakd()

	//variable smootht,smoothtadd,peaknum
	//variable l1,l2,r1,r2,minPeakPercent,show,bgr
	variable show = 1
	string WA_PeakCentersX="WA_PeakCentersX"
	string WA_PeakCentersY="WA_PeakCentersY"
	String W_autoPeakinfo = "W_autoPeakinfo"
	variable i



	string/G inputname_pf
	variable/G nameindex_pfd
	string param = "param_"+inputname_pf
	wave paramw = $param
	variable/G smootht_pf = paramw[nameindex_pfd][0]
	variable/G peaknum_pf = paramw[nameindex_pfd][1]
	variable/G l1_pf = paramw[nameindex_pfd][2]
	variable/G l2_pf = paramw[nameindex_pfd][3]
	variable/G r1_pf = paramw[nameindex_pfd][4]
	variable/G r2_pf = paramw[nameindex_pfd][5]
	variable/G minPeakPercent_pf = paramw[nameindex_pfd][6]
	variable/G show_pf =show
	variable/G bgr_pf = paramw[nameindex_pfd][7]
	variable/G smoothtadd_pf = paramw[nameindex_pfd][8]
	variable/G extmode_pf = paramw[nameindex_pfd][9]
	variable/G style_pf = 0

	string inputname = inputname_pf

	variable smootht = smootht_pf
	variable smoothtadd = smoothtadd_pf
	variable peaknum = peaknum_pf
	variable l1 = l1_pf
	variable l2 = l2_pf
	variable r1 = r1_pf
	variable r2 = r2_pf
	variable minPeakPercent = minPeakPercent_pf
	variable bgr = bgr_pf


			//paramw[nameindex_pf][0] = smootht_pf
			//paramw[nameindex_pf][1] = peaknum_pf
			//paramw[nameindex_pf][2] = l1_pf
			//paramw[nameindex_pf][3] = l2_pf
			//paramw[nameindex_pf][4] = r1_pf
			//paramw[nameindex_pf][5] = r2_pf
			//paramw[nameindex_pf][6] = minPeakPercent_pf
			//paramw[nameindex_pf][7] = bgr_pf
			//paramw[nameindex_pf][8] = smoothtadd_pf
			//paramw[nameindex_pf][9] = extmode_pf

	// Make 2nDD wave of the input wave
	wave inputnamew = $inputname
	string name = inputname+"_d"+num2str(nameindex_pfd)
	make/N=(dimsize($inputname,0))/o $name
	setscale/p x,dimoffset($inputname,0),dimdelta($inputname,0),"",$name
	wave namew = $name
	namew[] =  inputnamew[p][nameindex_pfd]
	duplicate/o namew t2ndcurvd; smooth smootht,t2ndcurvd;differentiate t2ndcurvd;smooth smootht,t2ndcurvd;differentiate t2ndcurvd;t2ndcurvd*=-1
	duplicate/o/R=(l1,l2) t2ndcurvd t2ndcurv_Ld
	duplicate/o namew t2ndcurvd; smooth (smootht+smoothtadd_pf),t2ndcurvd;differentiate t2ndcurvd;smooth (smootht+smoothtadd_pf),t2ndcurvd;differentiate t2ndcurvd;t2ndcurvd*=-1
	duplicate/o/R=(r1,r2) t2ndcurvd t2ndcurv_Rd

	duplicate/o namew rawdidvd
	/// Find peak after remove the 2nDD background
	if (bgr == 1)
		wavestats/Q t2ndcurv_Ld
		t2ndcurv_Ld-=2*V_min
		wavestats/Q t2ndcurv_Rd
		t2ndcurv_Rd-=2*V_min
		duplicate/o t2ndcurv_Ld smt2ndcurv_Ld
		duplicate/o t2ndcurv_Rd smt2ndcurv_Rd
		smooth 1500,smt2ndcurv_Ld //This is also tunable parameter
		smooth 1500,smt2ndcurv_Rd //This is also tunable parameter
		t2ndcurv_Ld/=smt2ndcurv_Ld
		t2ndcurv_Rd/=smt2ndcurv_Rd
	endif
	///

	// Get the peaks at the left side
	make/n=(peaknum+3,2)/o returnpeakld
	AutomaticallyFindPeaks1("t2ndcurv_Ld",100,minPeakPercent,0)
	wave WA_PeakCentersXw = $WA_PeakCentersX
	wave WA_PeakCentersYw = $WA_PeakCentersY
	wave W_autoPeakinfow = $W_autoPeakinfo
	duplicate/o WA_PeakCentersXw WA_PeakCentersXld
	duplicate/o WA_PeakCentersYw WA_PeakCentersYld

	if (show == 1)
		duplicate/o WA_PeakCentersYw WA_PeakCentersYlrawd
		WA_PeakCentersYlrawd= rawdidvd[round((WA_PeakCentersXw-dimoffset(rawdidvd,0))/dimdelta(rawdidvd,0))]
	endif

	if (bgr == 1)
		WA_PeakCentersYld= t2ndcurvd[round((WA_PeakCentersXw-dimoffset(t2ndcurvd,0))/dimdelta(t2ndcurvd,0))]
	endif
	i=0
	do
		if(i > dimsize(WA_PeakCentersXw,0)-1)
			returnpeakld[i][0]=nan
		else
			returnpeakld[i][0]=WA_PeakCentersXw[i]
		endif
		i+=1
	while(i<peaknum+3)

	// Get the peaks at the right side
	AutomaticallyFindPeaks2("t2ndcurv_Rd",100,minPeakPercent,0)
	wave WA_PeakCentersXw = $WA_PeakCentersX
	wave WA_PeakCentersYw = $WA_PeakCentersY
	wave W_autoPeakinfow = $W_autoPeakinfo
	duplicate/o WA_PeakCentersXw WA_PeakCentersXrd
	duplicate/o WA_PeakCentersYw WA_PeakCentersYrd

	if (show == 1)
		duplicate/o WA_PeakCentersYw WA_PeakCentersYrrawd
		WA_PeakCentersYrrawd= rawdidvd[round((WA_PeakCentersXw-dimoffset(rawdidvd,0))/dimdelta(rawdidvd,0))]
	endif

	if (bgr == 1)
		WA_PeakCentersYrd= t2ndcurvd[round((WA_PeakCentersXw-dimoffset(t2ndcurvd,0))/dimdelta(t2ndcurvd,0))]
	endif

	i=0
	do
		if(i > dimsize(WA_PeakCentersXw,0)-1)
			returnpeakld[i][1]=nan
		else
			returnpeakld[i][1]=WA_PeakCentersXw[i]
		endif
		i+=1
	while(i<peaknum+3)
	killwaves t2ndcurv_Ld t2ndcurv_Rd smt2ndcurv_Ld smt2ndcurv_Rd

	// Display the extracted results or not
	if (show == 1)
		CheckDisplayed t2ndcurvd
		if (V_flag == 1)
		else
			//Display 2ndd curve and Fitted dot
			display t2ndcurvd
			appendtograph  WA_PeakCentersYrd vs WA_PeakCentersXrd
			appendtograph  WA_PeakCentersYld vs WA_PeakCentersXld
			ModifyGraph mode(WA_PeakCentersYrd)=3,marker(WA_PeakCentersYrd)=19,rgb(WA_PeakCentersYrd)=(0,0,65535),mode(WA_PeakCentersYld)=3,marker(WA_PeakCentersYld)=19,rgb(WA_PeakCentersYld)=(0,0,65535)

			//Display fitting range indicative lines
			make/n=(2)/o ll1_pfd, ll2_pfd, rr1_pfd, rr2_pfd
			ll1_pfd = l1_pf
			ll2_pfd = l2_pf
			rr1_pfd = r1_pf
			rr2_pfd = r2_pf
			wavestats/Q rawdidvd
			setscale/i x,v_min,V_max,"",ll1_pfd, ll2_pfd, rr1_pfd, rr2_pfd
			AppendToGraph/L=StackedAxis_Hist/Vert ll1_pfd, ll2_pfd, rr1_pfd, rr2_pfd
			ModifyGraph lsize(ll1_pfd)=3,rgb(ll1_pfd)=(56797,56797,56797),lsize(ll2_pfd)=3,rgb(ll2_pfd)=(56797,56797,56797),lsize(rr1_pfd)=3,rgb(rr1_pfd)=(56797,56797,56797),lsize(rr2_pfd)=3,rgb(rr2_pfd)=(56797,56797,56797)

			//Display the raw data and Fitted dot
			AppendToGraph/L=StackedAxis_Hist rawdidvd
			ModifyGraph standoff(left)=0,standoff(bottom)=0,axisEnab(left)={0,0.45}
			ModifyGraph axisEnab(StackedAxis_Hist)={0.55,1},freePos(StackedAxis_Hist)=0
			ModifyGraph margin(top)=20;modifygraph width=230,height=144
			ModifyGraph mirror=2,tick=2,axThick=2
			appendtograph/L=StackedAxis_Hist  WA_PeakCentersYrrawd vs WA_PeakCentersXrd
			appendtograph/L=StackedAxis_Hist  WA_PeakCentersYlrawd vs WA_PeakCentersXld
			ModifyGraph mode(WA_PeakCentersYrrawd)=3,marker(WA_PeakCentersYrrawd)=19,rgb(WA_PeakCentersYrrawd)=(0,0,65535),mode(WA_PeakCentersYlrawd)=3,marker(WA_PeakCentersYlrawd)=19,rgb(WA_PeakCentersYlrawd)=(0,0,65535)
			ModifyGraph msize(WA_PeakCentersYrrawd)=1,msize(WA_PeakCentersYlrawd)=1
			SetDrawEnv textyjust= 1,textrot= 90;DrawText -0.2,0.5,"dI/dV(E,L\Bi\M="+num2str(nameindex_pfd)+")"
			tilewindows/WINS=grabwinnonew("t2ndcurvd")/R/A=(1,1)/w=(30,44.5,50,60)
			//Display extracted peak position on 2D linecut
			//variable ii
			//string gapline = inputname_pf+"_ex"
			//string gaplinein
			//if(dimsize($inputname_pf,1)==0)
			//else
			//	//Activate display control
			//	di($inputname_pf)
			//
			//	//Assign value of gaplineleft
			//		if (extmode_pf == 0)
			//			ii=0
			//			do
			//				gaplinein=gapline+"_l"+num2str(ii+1)
			//				wave gaplineinw = $gaplinein
			//				gaplineinw[nameindex_pfd] = returnpeakld[ii][0]
			//				ii+=1
			//			while (ii < peaknum_pf)
			//		endif
			//
			//		if (extmode_pf == 1)
			//			ii=0
			//			do
			//				gaplinein=gapline+"_l"+num2str(ii+1)
			//				wave gaplineinw = $gaplinein
			//				if (nameindex_pfd == 0)
			//					gaplineinw[nameindex_pfd] = returnpeakld[ii][0]
			//				else
			//					duplicate/RMD=[0,*][0,0]/o returnpeakld differpfsort,differpf
			//					differpfsort-=gaplineinw[nameindex_pfd-1]
			//					differpfsort=abs(differpfsort)
			//					sort differpfsort differpf
			//					gaplineinw[nameindex_pfd] =	differpf[0]
			//				endif
			//				ii+=1
			//			while (ii < peaknum_pf)
			//		endif
			//
			//	//Assign value of gaplineright
			//		if (extmode_pf == 0)
			//			ii=0
			//			do
			//				gaplinein=gapline+"_r"+num2str(ii+1)
			//				wave gaplineinw = $gaplinein
			//				gaplineinw[nameindex_pfd] = returnpeakld[ii][1]
			//				ii+=1
			//			while (ii < peaknum_pf)
			//		endif
			//
			//		if (extmode_pf == 1)
			//			ii=0
			//			do
			//				gaplinein=gapline+"_r"+num2str(ii+1)
			//				wave gaplineinw = $gaplinein
			//				if (nameindex_pfd == 0)
			//					gaplineinw[nameindex_pfd] = returnpeakld[ii][1]
			//				else
			//					duplicate/RMD=[0,*][1,1]/o returnpeakld differpfsort,differpf
			//					differpfsort-=gaplineinw[nameindex_pfd-1]
			//					differpfsort=abs(differpfsort)
			//					sort differpfsort differpf
			//					gaplineinw[nameindex_pfd] =	differpf[0]
			//				endif
			//				ii+=1
			//			while (ii < peaknum_pf)
			//		endif
			//endif

			//activiate interaction control
			const2nddpeakd()
		endif
	else
		checkdisplayed namew
		if(V_flag == 1)
			killwindow $grabwinnonew(name)
		endif
		killwaves WA_PeakCentersXrd WA_PeakCentersYrd WA_PeakCentersXld WA_PeakCentersYld t2ndcurvd rawdidvd
	endif
	return returnpeakld
end


Function const2nddpeakd()
	string/G inputname_pf
	variable/G nameindex_pfd //= 0
	variable/G smootht_pf //= smootht
	variable/G peaknum_pf //= peaknum
	variable/G l1_pf //= l1
	variable/G l2_pf //= l2
	variable/G r1_pf //= r1
	variable/G r2_pf //= r2
	variable/G minPeakPercent_pf //= minPeakPercent
	variable/G show_pf //= show
	variable/G bgr_pf //= bgr
	Dowindow/F $winname(1,1)
	SetVariable setnameindex_pfd win=$grabwinnonew("t2ndcurvd"),title="Show Extraction History (MDC index)",pos={2,2},size={200,20},value=nameindex_pfd,limits={0,dimsize($inputname_pf,1)-1,1},proc=SetVarProc_const2nddpeakindd
	Button showtable win=$grabwinnonew("t2ndcurvd"),title="Show Parameters",pos={205,1},size={100,14},fSize=10,proc=ButtonProc_showtable
	Button makelayout win=$grabwinnonew("t2ndcurvd"),title="Make Layout",pos={205,180},size={100,14},fSize=10,proc=ButtonProc_makelayoutforhis
	Button killlayout win=$grabwinnonew("t2ndcurvd"),title="Kill Layout",pos={205,195},size={100,14},fSize=10,proc=ButtonProc_killlayoutforhis

end

Function ButtonProc_showtable(ctrlName) : ButtonControl
	String ctrlName
	string/G inputname_pf
	string tablebame = "param_"+inputname_pf
	edit $tablebame
	modifytable horizontalIndex=2
	tilewindows/WINS=grabtable(tablebame)/R/A=(1,1)/w=(51,20,100,50)
	cktable(winname(0,2))
End

Function SetVarProc_const2nddpeakindd(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	const2nddpeakcontrold()
End

Function/Wave const2nddpeakcontrold()
	string WA_PeakCentersX="WA_PeakCentersX"
	string WA_PeakCentersY="WA_PeakCentersY"
	String W_autoPeakinfo = "W_autoPeakinfo"
	variable i

	string/G inputname_pf
	variable/G nameindex_pfd
	variable/G nameindex_pf = nameindex_pfd

	string param = "param_"+inputname_pf
	wave paramw = $param
	variable/G smootht_pf = paramw[nameindex_pfd][0]
	variable/G peaknum_pf = paramw[nameindex_pfd][1]
	variable/G l1_pf = paramw[nameindex_pfd][2]
	variable/G l2_pf = paramw[nameindex_pfd][3]
	variable/G r1_pf = paramw[nameindex_pfd][4]
	variable/G r2_pf = paramw[nameindex_pfd][5]
	variable/G minPeakPercent_pf = paramw[nameindex_pfd][6]
	variable/G show_pf
	variable/G bgr_pf = paramw[nameindex_pfd][7]
	variable/G smoothtadd_pf = paramw[nameindex_pfd][8]
	variable/G extmode_pf = paramw[nameindex_pfd][9]
	variable/G style_pf = 0

	// Make 2nDD wave of the input wave
	wave inputnamew = $inputname_pf
	string name = inputname_pf+"_d"+num2str(nameindex_pfd)
	make/N=(dimsize($inputname_pf,0))/o $name
	setscale/p x,dimoffset($inputname_pf,0),dimdelta($inputname_pf,0),"",$name
	wave namew = $name
	namew[] =  inputnamew[p][nameindex_pfd]
	duplicate/o namew t2ndcurvd; smooth smootht_pf,t2ndcurvd;differentiate t2ndcurvd;smooth smootht_pf,t2ndcurvd;differentiate t2ndcurvd;t2ndcurvd*=-1
	duplicate/o/R=(l1_pf,l2_pf) t2ndcurvd t2ndcurv_Ld
	duplicate/o namew t2ndcurvd; smooth (smootht_pf+smoothtadd_pf),t2ndcurvd;differentiate t2ndcurvd;smooth (smootht_pf+smoothtadd_pf),t2ndcurvd;differentiate t2ndcurvd;t2ndcurvd*=-1
	duplicate/o/R=(r1_pf,r2_pf) t2ndcurvd t2ndcurv_Rd

	duplicate/o namew rawdidvd
	/// Find peak after remove the 2nDD background
	if (bgr_pf == 1)
		wavestats/Q t2ndcurv_Ld
		t2ndcurv_Ld-=2*V_min
		wavestats/Q t2ndcurv_Rd
		t2ndcurv_Rd-=2*V_min
		duplicate/o t2ndcurv_Ld smt2ndcurv_Ld
		duplicate/o t2ndcurv_Rd smt2ndcurv_Rd
		smooth 1500,smt2ndcurv_Ld //This is also tunable parameter
		smooth 1500,smt2ndcurv_Rd //This is also tunable parameter
		t2ndcurv_Ld/=smt2ndcurv_Ld
		t2ndcurv_Rd/=smt2ndcurv_Rd
	endif
	///

	// Get the peaks at the left side
	make/n=(peaknum_pf+3,2)/o returnpeakld
	AutomaticallyFindPeaks1("t2ndcurv_Ld",100,minPeakPercent_pf,0)
	wave WA_PeakCentersXw = $WA_PeakCentersX
	wave WA_PeakCentersYw = $WA_PeakCentersY
	wave W_autoPeakinfow = $W_autoPeakinfo
	duplicate/o WA_PeakCentersXw WA_PeakCentersXld
	duplicate/o WA_PeakCentersYw WA_PeakCentersYld
	duplicate/o WA_PeakCentersYw WA_PeakCentersYlrawd
	WA_PeakCentersYlrawd = rawdidvd[round((WA_PeakCentersXw-dimoffset(rawdidvd,0))/dimdelta(rawdidvd,0))]

	if (bgr_pf == 1)
		WA_PeakCentersYld = t2ndcurvd[round((WA_PeakCentersXw-dimoffset(t2ndcurvd,0))/dimdelta(t2ndcurvd,0))]
	endif
	i=0
	do
		if(i > dimsize(WA_PeakCentersXw,0)-1)
			returnpeakld[i][0]=nan
		else
			returnpeakld[i][0]=WA_PeakCentersXw[i]
		endif
		i+=1
	while(i<peaknum_pf+3)

	// Get the peaks at the right side
	AutomaticallyFindPeaks2("t2ndcurv_Rd",100,minPeakPercent_pf,0)
	wave WA_PeakCentersXw = $WA_PeakCentersX
	wave WA_PeakCentersYw = $WA_PeakCentersY
	wave W_autoPeakinfow = $W_autoPeakinfo
	duplicate/o WA_PeakCentersXw WA_PeakCentersXrd
	duplicate/o WA_PeakCentersYw WA_PeakCentersYrd
	duplicate/o WA_PeakCentersYw WA_PeakCentersYrrawd
	WA_PeakCentersYrrawd = rawdidvd[round((WA_PeakCentersXw-dimoffset(rawdidvd,0))/dimdelta(rawdidvd,0))]

	if (bgr_pf == 1)
		WA_PeakCentersYrd = t2ndcurvd[round((WA_PeakCentersXw-dimoffset(t2ndcurvd,0))/dimdelta(t2ndcurvd,0))]
	endif

	i=0
	do
		if(i > dimsize(WA_PeakCentersXw,0)-1)
			returnpeakld[i][1]=nan
		else
			returnpeakld[i][1]=WA_PeakCentersXw[i]
		endif
		i+=1
	while(i<peaknum_pf+3)
	killwaves t2ndcurv_Ld t2ndcurv_Rd smt2ndcurv_Ld smt2ndcurv_Rd

	//update the indicative lines
			make/n=(2)/o ll1_pfd, ll2_pfd, rr1_pfd, rr2_pfd
			ll1_pfd = l1_pf
			ll2_pfd = l2_pf
			rr1_pfd = r1_pf
			rr2_pfd = r2_pf
			wavestats/Q rawdidvd
			setscale/i x,v_min,V_max,"",ll1_pfd, ll2_pfd, rr1_pfd, rr2_pfd

	//Update the extracted dot at 2D linecut
	//		variable ii
	//		string gapline = inputname_pf+"_ex"
	//		string gaplinein
	//		if(dimsize($inputname_pf,1)==0)
	//		else
	//
	//			//Assign value of gaplineleft
	//				if (extmode_pf == 0)
	//					ii=0
	//					do
	//						gaplinein=gapline+"_l"+num2str(ii+1)
	//						wave gaplineinw = $gaplinein
	//						gaplineinw[nameindex_pfd] = returnpeakld[ii][0]
	//						ii+=1
	//					while (ii < peaknum_pf)
	//				endif
	//
	//				if (extmode_pf == 1)
	//					ii=0
	//					do
	//						gaplinein=gapline+"_l"+num2str(ii+1)
	//						wave gaplineinw = $gaplinein
	//						if (nameindex_pfd == 0)
	//							gaplineinw[nameindex_pfd] = returnpeakld[ii][0]
	//						else
	//							duplicate/RMD=[0,*][0,0]/o returnpeakld differpfsort,differpf
	//							differpfsort-=gaplineinw[nameindex_pfd-1]
	//							differpfsort=abs(differpfsort)
	//							sort differpfsort differpf
	//							gaplineinw[nameindex_pfd] =	differpf[0]
	//						endif
	//						ii+=1
	//					while (ii < peaknum_pf)
	//				endif
	//
	//			//Assign value of gaplineright
	//				if (extmode_pf == 0)
	//					ii=0
	//					do
	//						gaplinein=gapline+"_r"+num2str(ii+1)
	//						wave gaplineinw = $gaplinein
	//						gaplineinw[nameindex_pfd] = returnpeakld[ii][1]
	//						ii+=1
	//					while (ii < peaknum_pf)
	//				endif
	//
	//				if (extmode_pf == 1)
	//					ii=0
	//					do
	//						gaplinein=gapline+"_r"+num2str(ii+1)
	//						wave gaplineinw = $gaplinein
	//						if (nameindex_pfd == 0)
	//							gaplineinw[nameindex_pfd] = returnpeakld[ii][1]
	//						else
	//							duplicate/RMD=[0,*][1,1]/o returnpeakld differpfsort,differpf
	//							differpfsort-=gaplineinw[nameindex_pfd-1]
	//							differpfsort=abs(differpfsort)
	//							sort differpfsort differpf
	//							gaplineinw[nameindex_pfd] =	differpf[0]
	//						endif
	//						ii+=1
	//					while (ii < peaknum_pf)
	//				endif
	//		endif

	//Update MDC indicative line on 2D linecut
			make/o/N=(2) linecutmdcind
			setscale/i x,dimoffset($inputname_pf,0),dimoffset($inputname_pf,0)+(dimsize($inputname_pf,0)-1)*dimdelta($inputname_pf,0),"",linecutmdcind
			linecutmdcind = dimoffset($inputname_pf,1)+nameindex_pfd*dimdelta($inputname_pf,1)
	//Update label
			DrawAction/W=$grabwinnonew("t2ndcurvd") delete
			SetDrawEnv/W=$grabwinnonew("t2ndcurvd") textyjust= 1,textrot= 90;DrawText/W=$grabwinnonew("t2ndcurvd") -0.2,0.5,"dI/dV(E,L\Bi\M="+num2str(nameindex_pfd)+")"

	return returnpeakld
end

//** Function to get a stringlist containing the name of
//** all the 1 & 2 dimensional data.
Function/S getall1or2dwave()
	variable num=itemsinList(WaveList("*",";",""))
	variable i
	string namewave = ""
	i=0
	do
		if(waveDims($stringfromlist(i,WaveList("*",";",""))) == 2)
		namewave+=stringfromlist(i,WaveList("*",";",""))+";"
		endif
		i+=1
	while(i<num)
	i=0
	do
		if(waveDims($stringfromlist(i,WaveList("*",";",""))) == 1) //|| waveDims($stringfromlist(i,WaveList("*",";",""))) == 1
		namewave+=stringfromlist(i,WaveList("*",";",""))+";"
		endif
		i+=1
	while(i<num)
	Return namewave
end


////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
// Part 3 Auto Layout
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

Function ButtonProc_makelayoutforhis(ctrlName) : ButtonControl
	String ctrlName
	makelayoutforhis()
End

Function makelayoutforhis()
	variable/G nameindex_pfd
	string/G inputname_pf
	variable endnum = dimsize($inputname_pf,1)
	variable i
	string/G winlst_pf = ""
	i=0
	do
		dpfig_pf(i)
		winlst_pf+=winname(0,1)+","
		i+=1
	while(i< endnum)

	variable figitem = itemsInList(winlst_pf,",")
	variable rd = (figitem - mod(figitem,35))/35
	//print rd
	string slexe=""
	variable ii,j,jj
	j=0
	jj=0
	do
		ii=0
		slexe=""
		do
			slexe+=stringfromList(ii+j,winlst_pf,",")+","
			ii+=1
		while(ii < 35)

		//print slexe
		if(jj==0)
			string lay1 = "Layout/T"
			execute lay1
			string lay2 = "LayoutPageAction size(-1)=(540*2, 576*2), margins(-1)=(18, 18, 18, 18)"
		else
			LayoutPageAction appendPage
		endif

		execute lay2
		string lay ="AppendToLayout/T/A=(7,5) " + slexe
		execute lay
		string lay3 = "	ModifyLayout frame=0"
		execute lay3
		jj+=1
		j+=35
	while(jj < rd+1)
end

Function dpfig_pf(i)
	variable i
	variable/G nameindex_pfd = i
	const2nddpeakcontrold()
	// Display the extracted results or not
			string curvd = "t2ndcurvd"
			wave t2ndcurvd = $curvd

			string CentersYrd = "WA_PeakCentersYrd"
			wave WA_PeakCentersYrd = $CentersYrd

			string CentersXrd = "WA_PeakCentersXrd"
			wave WA_PeakCentersXrd = $CentersXrd

			string CentersYld = "WA_PeakCentersYld"
			wave WA_PeakCentersYld = $CentersYld

			string CentersXld = "WA_PeakCentersXld"
			wave WA_PeakCentersXld = $CentersXld

			string ll1 = "ll1_pfd"
			wave ll1_pfd = $ll1

			string ll2 = "ll2_pfd"
			wave ll2_pfd = $ll2

			string rr2 = "rr2_pfd"
			wave rr2_pfd = $rr2

			string rr1 = "rr1_pfd"
			wave rr1_pfd = $rr1

			String didvd = "rawdidvd"
			wave rawdidvd = $didvd

			string CentersYrrawd = "WA_PeakCentersYrrawd"
			wave WA_PeakCentersYrrawd = $CentersYrrawd

			string CentersYlrawd = "WA_PeakCentersYlrawd"
			wave WA_PeakCentersYlrawd = $CentersYlrawd

			//Display 2ndd curve and Fitted dot
			string t2ndcurvd_s
			t2ndcurvd_s = "t2ndcurvd"+num2str(i)
			duplicate/o t2ndcurvd $t2ndcurvd_s
			wave t2ndcurvd_sw = $t2ndcurvd_s

			display t2ndcurvd_sw

			string WA_PeakCentersYrd_s
			WA_PeakCentersYrd_s = "WA_PeakCentersYrd"+num2str(i)
			duplicate/o WA_PeakCentersYrd $WA_PeakCentersYrd_s
			wave WA_PeakCentersYrd_sw = $WA_PeakCentersYrd_s

			string WA_PeakCentersXrd_s
			WA_PeakCentersXrd_s = "WA_PeakCentersXrd"+num2str(i)
			duplicate/o WA_PeakCentersXrd $WA_PeakCentersXrd_s
			wave WA_PeakCentersXrd_sw = $WA_PeakCentersXrd_s

			string WA_PeakCentersYld_s
			WA_PeakCentersYld_s = "WA_PeakCentersYld"+num2str(i)
			duplicate/o WA_PeakCentersYld $WA_PeakCentersYld_s
			wave WA_PeakCentersYld_sw = $WA_PeakCentersYld_s

			string WA_PeakCentersXld_s
			WA_PeakCentersXld_s = "WA_PeakCentersXld"+num2str(i)
			duplicate/o WA_PeakCentersXld $WA_PeakCentersXld_s
			wave WA_PeakCentersXld_sw = $WA_PeakCentersXld_s

			appendtograph  WA_PeakCentersYrd_sw vs WA_PeakCentersXrd_sw
			appendtograph  WA_PeakCentersYld_sw vs WA_PeakCentersXld_sw
			ModifyGraph mode($WA_PeakCentersYrd_s)=3,marker($WA_PeakCentersYrd_s)=19,rgb($WA_PeakCentersYrd_s)=(0,0,65535),mode($WA_PeakCentersYld_s)=3,marker($WA_PeakCentersYld_s)=19,rgb($WA_PeakCentersYld_s)=(0,0,65535)

			//Display fitting range indicative lines
			string ll1_pfd_s = "ll1_pfd"+num2str(i)
			duplicate/o ll1_pfd $ll1_pfd_s
			wave ll1_pfd_sw = $ll1_pfd_s

			string ll2_pfd_s = "ll2_pfd"+num2str(i)
			duplicate/o ll2_pfd $ll2_pfd_s
			wave ll2_pfd_sw = $ll2_pfd_s

			string rr1_pfd_s = "rr1_pfd"+num2str(i)
			duplicate/o rr1_pfd $rr1_pfd_s
			wave rr1_pfd_sw = $rr1_pfd_s

			string rr2_pfd_s = "rr2_pfd"+num2str(i)
			duplicate/o rr2_pfd $rr2_pfd_s
			wave rr2_pfd_sw = $rr2_pfd_s

			AppendToGraph/L=StackedAxis_Hist/Vert ll1_pfd_sw, ll2_pfd_sw, rr1_pfd_sw, rr2_pfd_sw
			ModifyGraph lsize($ll1_pfd_s)=3,rgb($ll1_pfd_s)=(56797,56797,56797),lsize($ll2_pfd_s)=3,rgb($ll2_pfd_s)=(56797,56797,56797),lsize($rr1_pfd_s)=3,rgb($rr1_pfd_s)=(56797,56797,56797),lsize($rr2_pfd_s)=3,rgb($rr2_pfd_s)=(56797,56797,56797)

			//Display the raw data and Fitted dot
			string rawdidvd_s = "rawdidvd"+num2str(i)
			duplicate/o rawdidvd $rawdidvd_s
			wave rawdidvd_sw = $rawdidvd_s

			AppendToGraph/L=StackedAxis_Hist rawdidvd_sw
			ModifyGraph standoff(left)=0,standoff(bottom)=0,axisEnab(left)={0,0.45}
			ModifyGraph axisEnab(StackedAxis_Hist)={0.55,1},freePos(StackedAxis_Hist)=0
			//ModifyGraph margin(top)=20;//modifygraph width=230,height=144
			ModifyGraph mirror=2,tick=2,axThick=2

			string WA_PeakCentersYrrawd_s = "WA_PeakCentersYrrawd"+num2str(i)
			duplicate/o WA_PeakCentersYrrawd $WA_PeakCentersYrrawd_s
			wave WA_PeakCentersYrrawd_sw = $WA_PeakCentersYrrawd_s

			string WA_PeakCentersYlrawd_s = "WA_PeakCentersYlrawd"+num2str(i)
			duplicate/o WA_PeakCentersYlrawd $WA_PeakCentersYlrawd_s
			wave WA_PeakCentersYlrawd_sw = $WA_PeakCentersYlrawd_s


			appendtograph/L=StackedAxis_Hist  WA_PeakCentersYrrawd_sw vs WA_PeakCentersXrd_sw
			appendtograph/L=StackedAxis_Hist  WA_PeakCentersYlrawd_sw vs WA_PeakCentersXld_sw
			ModifyGraph mode($WA_PeakCentersYrrawd_s)=3,marker($WA_PeakCentersYrrawd_s)=19,rgb($WA_PeakCentersYrrawd_s)=(0,0,65535),mode($WA_PeakCentersYlrawd_s)=3,marker($WA_PeakCentersYlrawd_s)=19,rgb($WA_PeakCentersYlrawd_s)=(0,0,65535)
			ModifyGraph msize($WA_PeakCentersYrrawd_s)=1,msize($WA_PeakCentersYlrawd_s)=1
			//SetDrawEnv textxjust= 1,textyjust= 2,textrot= 0,fsize= 7;DrawText 0.5,-0.1,"dI/dV(E,L\\Bi\\M="+num2str(i)+")"


			//These settings relates to the layout
			Label bottom "\\Z12\\F'Helvetica'Energy (meV)";ModifyGraph lblPosMode=0,lblMargin(bottom)=10;
			ModifyGraph font(left)="Helvetica",fSize=12
			ModifyGraph lblPos(StackedAxis_Hist)=40,lblLatPos(StackedAxis_Hist)=30;DelayUpdate;Label StackedAxis_Hist "\\Z12\\F'Helvetica'dI/dV (E, L\\Bi\\M = "+num2str(i)+"\Z12)"
			//ModifyGraph lblPos(left)=40;Label left "\\Z12\\F'Helvetica'd\\S2\\MI/dV\\S2\\M(E,L\\Bi\\M="+num2str(i)+")"
			ModifyGraph rgb($t2ndcurvd_s)=(39321,1,1),rgb($rawdidvd_s)=(39321,1,1),lsize($t2ndcurvd_s)=1.5,lsize($rawdidvd_s)=1.5

			ModifyGraph margin(left)=0.5,margin(right)=1,width=0;ModifyGraph margin(top)=1,margin(bottom)=0.5,height=0

end

Function ButtonProc_killlayoutforhis(ctrlName) : ButtonControl
	String ctrlName
	execute "killalldisplay_pf()"
End
proc killalldisplay_pf()
	variable figitem = itemsInList(winlst_pf,",")
	variable i

	i = 0
	do
		killwindow  $stringfromlist(i,winlst_pf,",")
		i+=1
	while(i<figitem)

	//i=0
	//variable rd = 1+(figitem - mod(figitem,35))/35
	//string layouts
	//do
	//	layouts = "layout"+num2str(i)
	//	killwindow  $layouts
	//	i+=1
	//while(i<rd)
	killwindow  layout0
end

Function/s grabtablenonew(name)
	string name
 	string fulllist = WinList("*", ";","WIN:2")
	string nn,waveong,cmdn,out
	out = ""
	variable i,j
	for(i=0; i<itemsinlist(fulllist); i +=1)
        nn= stringfromlist(i, fulllist)
        cmdn="WIN:"+nn
        j=0
        do
        	waveong = stringfromlist(j,WaveList("*", ";",cmdn)) //check all the data on the table
        	if (CmpStr(name,waveong) == 0)
        		out = nn
        	else
        	endif
        	j+=1
        while (j< itemsinlist(WaveList("*", ";",cmdn)))
    endfor

    if (cmpstr(out,"") == 0)
    	if (exists(name) == 1)
    		wave namew = $name
    		//ed(namew)
    		out = winname(0,1)
    	endif
    endif
    Return out
end

// Adds-ons
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
//  Manual change extraction value
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////

Function ButtonProc_manualvalue_1Dextracp(ctrlName) : ButtonControl
	String ctrlName
	execute "manualvalue_1Dextracp()"
end
Proc manualvalue_1Dextracp(Note1, Note2, leftvalue, rightvalue)
	String note1 = "blank is NaN"
	String note2 = "0 is no change"
	string leftvalue = ";0;"
	string rightvalue = ";0;"
	Prompt leftvalue,"Left peaks"
	prompt rightvalue,"Right peaks"
	manualvalue_1Dextrac(leftvalue, rightvalue)
	Print "manualvalue_1Dextrac(\""+leftvalue+"\", \""+rightvalue+"\")"
end

Function manualvalue_1Dextrac(leftvalue, rightvalue)
	string leftvalue
	string rightvalue

	variable/G peaknum_pf
	string/G inputname_pf

	variable/G nameindex_pf

	string left = inputname_pf+"_ex_l"
	string right = inputname_pf+"_ex_r"

	string lefti
	string righti

	variable leftele,rightele

	variable i

	i=0
	do
		lefti = left+num2str(i+1)
		righti = right+num2str(i+1)
		wave leftiw = $lefti
		wave rightiw = $righti

		leftele = str2num(stringFromList(i,leftvalue))
		rightele = str2num(stringFromList(i,rightvalue))

		if (leftele == 0)
		else
			leftiw[nameindex_pf] = leftele
		endif

		if (rightele == 0)
		else
			rightiw[nameindex_pf] = rightele
		endif

		i+=1
	while (i< peaknum_pf)
end