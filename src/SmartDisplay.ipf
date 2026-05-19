#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
/////////////////    Eliminate duplicating display Figure //////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
// How to use this function: in a Proc or Function, put it direction below the sentence of
// made a new figure and call "ckfig(winname(0,1))"
// *** Note: only complex figures which contain multiples waves need to use these functions,
// ***       for simple figure which only have one wave, modified di() is good enough.
////////////////////////////////////////////////////////////////////////////////////////////
Function ckfig(name)
	String name //name of the figure

	//The information of the Fig.name***************
	String cmd,wavenamelist,nn,cmdn,wavenamelistn
	cmd="WIN:"+name
	wavenamelist = WaveList("*", ";",cmd)
	//**********************************************

    string fulllist = WinList("*", ";","WIN:1")
	variable i
	for(i=0; i<itemsinlist(fulllist); i +=1)
        nn= stringfromlist(i, fulllist)
        cmdn="WIN:"+nn
        wavenamelistn = WaveList("*", ";",cmdn)
        if (CmpStr(wavenamelist,wavenamelistn) == 0)
        	if (CmpStr(name,nn) == 0)
        	else
        		Killsinglewindow(name)
        		dowindow/F $nn
        	endif
        endif
    endfor
end

//#special checkFig in childen window, [only in child window]
Function/S wavelistsub(name)
	string name // graph name
	string childwinname = childWindowList(name)
	variable numchildwin = itemsInList(childwinname)
	string wavelistall =""
	string subwinname
	variable i
	i=0
	do
		subwinname = name+"#"+stringfromList(i,childwinname)
		wavelistall+= WaveList("*", ";","WIN:"+subwinname)
		i+=1
	while (i < numchildwin)
	return wavelistall
end
Function ckfig_child(name)
	String name //name of the figure

	//The information of the Fig.name***************
	String wavenamelist,nn,wavenamelistn
	wavenamelist = wavelistsub(name)
	//**********************************************

    string fulllist = WinList("*", ";","WIN:1")
	variable i
	for(i=0; i<itemsinlist(fulllist); i +=1)
        nn= stringfromlist(i, fulllist)
        if (itemsInList(childWindowList(nn)) == 0)
        	wavenamelistn = WaveList("*", ";","WIN:"+nn)
        else
        	wavenamelistn = wavelistsub(nn)
        endif
        if (CmpStr(wavenamelist,wavenamelistn) == 0)
        	if (CmpStr(name,nn) == 0)
        	else
        		Killsinglewindow(name)
        		dowindow/F $nn
        	endif
        endif
    endfor
end

////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// End remove redundant Figure ///////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
/////////////////    Eliminate duplicating display table //////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
// How to use this function: in a Proc or Function, put it direction below the sentence of
// made a new figure and call "ckfig(winname(0,2))"
// *** Note: only complex figures which contain multiples waves need to use these functions,
// ***       for simple figure which only have one wave, modified di() is good enough.
////////////////////////////////////////////////////////////////////////////////////////////

Function cktable(name)
	String name //name of the figure

	//The information of the Fig.name***************
	String cmd,wavenamelist,nn,cmdn,wavenamelistn
	cmd="WIN:"+name
	wavenamelist = WaveList("*", ";",cmd)
	//**********************************************

    string fulllist = WinList("*", ";","WIN:2")
	variable i
	for(i=0; i<itemsinlist(fulllist); i +=1)
        nn= stringfromlist(i, fulllist)
        cmdn="WIN:"+nn
        wavenamelistn = WaveList("*", ";",cmdn)
        if (CmpStr(wavenamelist,wavenamelistn) == 0)
        	if (CmpStr(name,nn) == 0)
        	else
        		Killsinglewindow(name)
        		dowindow/F $nn
        	endif
        endif
    endfor
end
end
////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// End remove redundant Figure ///////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
/////////////////    Eliminate duplicating display Layout //////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
// How to use this function: in a Proc or Function, put it direction below the sentence of
// made a new figure and call "ck(winname(0,4))"
////////////////////////////////////////////////////////////////////////////////////////////
Function cklayout(name)
	String name //name of the figure

	string graphlist,nn,graphlistn
	graphlist=graphlistinlayout(name)

    string fulllist = WinList("*", ";","WIN:4")
	variable i
	for(i=0; i<itemsinlist(fulllist); i +=1)
        nn= stringfromlist(i, fulllist)

        graphlistn = graphlistinlayout(nn)
        if (CmpStr(graphlistn,graphlist) == 0)
        	if (CmpStr(name,nn) == 0)
        	else
        		Killsinglewindow(name)
        		dowindow/F $nn
        	endif
        endif
    endfor
End

Function/T graphlistinlayout(name)
	String name
	string graphlist
	variable i,ii
    graphlist = ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),"0")),"")
	//print ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),"0")),"")
	string layoutinfos, graphinfo
	i=1
	do
	if(i == 1)
		layoutinfos ="1"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 2)
		layoutinfos ="2"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 3)
		layoutinfos ="3"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 4)
		layoutinfos ="4"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 5)
		layoutinfos ="5"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 6)
		layoutinfos ="6"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 7)
		layoutinfos ="7"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 8)
		layoutinfos ="8"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 9)
		layoutinfos ="9"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 10)
		layoutinfos ="10"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 11)
		layoutinfos ="11"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 12)
		layoutinfos ="12"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 13)
		layoutinfos ="13"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 14)
		layoutinfos ="14"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 15)
		layoutinfos ="15"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 16)
		layoutinfos ="16"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 17)
		layoutinfos ="17"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 18)
		layoutinfos ="18"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 19)
		layoutinfos ="19"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 20)
		layoutinfos ="20"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 21)
		layoutinfos ="21"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 22)
		layoutinfos ="22"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 23)
		layoutinfos ="23"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 24)
		layoutinfos ="24"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 25)
		layoutinfos ="25"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 26)
		layoutinfos ="26"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 27)
		layoutinfos ="27"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 28)
		layoutinfos ="28"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 29)
		layoutinfos ="29"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 30)
		layoutinfos ="30"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 31)
		layoutinfos ="31"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	if(i == 32)
		layoutinfos ="32"
		graphinfo=stringfromlist(0,layoutinfo(winname(0,4),layoutinfos))
		graphlist = graphlist+","+ReplaceString("NAME:",stringfromlist(0,layoutinfo(winname(0,4),layoutinfos)),"")
		ii=strlen(layoutinfo(winname(0,4),layoutinfos))
	endif

	i+=1
	while(i < str2num(ReplaceString("NUMOBJECTS:",stringfromlist(7,layoutinfo(winname(0,4),"layout")),"")))
	Return graphlist
end
////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// End remove redundant Layout ///////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////  ##Auto display figure##  ////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
//Display mode 1: When there already a graph with the same single wave
//                Stop display and bring that window to front
Function di(destw)
	wave destw
    string fulllist = WinList("*", ";","WIN:1") //"1 for graph, 2 for table"
    string name,cmd,wavenamelist
    variable i,cc
    String dest=nameofwave(destw)
    cc=0
    for(i=0; i<itemsinlist(fulllist); i +=1)
        name= stringfromlist(i, fulllist)
        cmd="WIN:"+name
        wavenamelist = WaveList("*", ";",cmd)
		  if (itemsinlist(wavenamelist) == 1)
		  	if (itemsinlist(listMatch(wavenamelist,dest)) == 1)
		  		//Killsinglewindow(name)
		  		Dowindow/F $name
		  		cc +=1
		  	endif
		  else
		  endif
    endfor
   if (cc == 0)
  	   display;appendimage destw
		ModifyGraph width=300,height=300;
		modifygraph lsize=1
		ModifyGraph mirror=2
		ModifyGraph tick=2
		ModifyImage $nameofwave(destw) ctab= {*,*,VioletOrangeYellow,0}
		ModifyGraph width=0,height=0

		if (dimsize(destw,0)*dimdelta(destw,0) == dimsize(destw,1)*dimdelta(destw,1))
			ModifyGraph width={Plan,1,bottom,left}
		else
		endif
	endif
end
/////////////////////////////////////////////////////////////////////////////
//Display mode 2: kill the graph with same single wave and redisplay
Function di2(name)
	wave name
		killgraphonlyhavethewave(nameofwave(name))
		display;appendimage name
		ModifyGraph width=300,height=300;
		modifygraph lsize=1
		ModifyGraph mirror=2
		ModifyGraph tick=2
		ModifyImage $nameofwave(name) ctab= {*,*,VioletOrangeYellow,0}
		ModifyGraph width=0,height=0

		if (dimsize(name,0)*dimdelta(name,0) == dimsize(name,1)*dimdelta(name,1))
			ModifyGraph width={Plan,1,bottom,left}
		else
		endif
end

Function killgraphonlyhavethewave(dest)
	String dest
    string fulllist = WinList("*", ";","WIN:1") //"1 for graph, 2 for table"
    string name,cmd,wavenamelist
    variable i
    wave destw=$dest

    for(i=0; i<itemsinlist(fulllist); i +=1)
        name= stringfromlist(i, fulllist)
        cmd="WIN:"+name
        wavenamelist = WaveList("*", ";",cmd)
		  if (itemsinlist(wavenamelist) == 1)
		  	if (itemsinlist(listMatch(wavenamelist,dest)) == 1)
		  		Killsinglewindow(name)
		  	endif
		  else
		  endif
    endfor
end

Function Killsinglewindow(name) //kill window of a specific name
    string name //window name
    string cmd
    variable i
    sprintf  cmd, "Dowindow/K %s", name
    execute cmd
end
/////////////////////////////////////////////////////////////////////////////
////////   End display  /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
Function di2lf(name)
	wave name
		killgraphonlyhavethewave(nameofwave(name))
		display;appendimage name
		ModifyGraph width=500,height=500;
		modifygraph lsize=1
		ModifyGraph mirror=2
		ModifyGraph tick=2
		ModifyImage $nameofwave(name) ctab= {*,*,VioletOrangeYellow,0}
		ModifyGraph width=0,height=0
		ModifyGraph width={Plan,1,bottom,left}
end

Function dilf(destw)
	wave destw
    string fulllist = WinList("*", ";","WIN:1") //"1 for graph, 2 for table"
    string name,cmd,wavenamelist
    variable i,cc
    String dest=nameofwave(destw)
    cc=0
    for(i=0; i<itemsinlist(fulllist); i +=1)
        name= stringfromlist(i, fulllist)
        cmd="WIN:"+name
        wavenamelist = WaveList("*", ";",cmd)
		  if (itemsinlist(wavenamelist) == 1)
		  	if (itemsinlist(listMatch(wavenamelist,dest)) == 1)
		  		//Killsinglewindow(name)
		  		Dowindow/F $name
		  		cc +=1
		  	endif
		  else
		  endif
    endfor
   if (cc == 0)
  	   display;appendimage destw
		ModifyGraph width=300,height=300;
		modifygraph lsize=1
		ModifyGraph mirror=2
		ModifyGraph tick=2
		ModifyImage $nameofwave(destw) ctab= {*,*,VioletOrangeYellow,0}
		ModifyGraph width=0,height=0


		ModifyGraph width={Plan,1,bottom,left}
	endif
end
///////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// Smart edit table for single wave table
////////////////////////////////////////////////////////////////////////////////////////////
Function ed2(name)
 	wave name
	killgraphonlyhavethewavetable(nameofwave(name))
	edit name
end

Function killgraphonlyhavethewavetable(dest)
	String dest
    string fulllist = WinList("*", ";","WIN:2") //"1 for graph, 2 for table"
    string name,cmd,wavenamelist
    variable i
    wave destw=$dest

    for(i=0; i<itemsinlist(fulllist); i +=1)
        name= stringfromlist(i, fulllist)
        cmd="WIN:"+name
        wavenamelist = WaveList("*", ";",cmd)
		  if (itemsinlist(wavenamelist) == 1)
		  	if (itemsinlist(listMatch(wavenamelist,dest)) == 1)
		  		Killsinglewindow(name)
		  	endif
		  else
		  endif
    endfor
end

Function ed(destw)
	wave destw
    string fulllist = WinList("*", ";","WIN:2") //"1 for graph, 2 for table"
    string name,cmd,wavenamelist
    variable i,cc
    String dest=nameofwave(destw)
    cc=0
    for(i=0; i<itemsinlist(fulllist); i +=1)
        name= stringfromlist(i, fulllist)
        cmd="WIN:"+name
        wavenamelist = WaveList("*", ";",cmd)
		  if (itemsinlist(wavenamelist) == 1)
		  	if (itemsinlist(listMatch(wavenamelist,dest)) == 1)
		  		//Killsinglewindow(name)
		  		Dowindow/F $name
		  		cc +=1
		  	endif
		  else
		  endif
    endfor
   if (cc == 0)
  	   edit destw
	endif
end
////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// End of Smart edit table for single wave table
////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
////////   kill all graph  //////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
Function ButtonProc_killags(ctrlName) : ButtonControl
	String ctrlName
	Execute "killags()"
end

Proc killags()
	KillAllGraphs()
end


Function KillAllGraphs()
    string fulllist = WinList("*", ";","WIN:3")
    string name, cmd
    variable i

    for(i=0; i<itemsinlist(fulllist); i +=1)
        name= stringfromlist(i, fulllist)
        sprintf  cmd, "Dowindow/K %s", name
        execute cmd
    endfor
end
/////////////////////////////////////////////////////////////////////////////
////////   End of kill all graphs  //////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
//Return the name of the wave in the topmost image
/////////////////////////////////////////////////////////////////////////////
//****************Old Version (not sensitive to subwindow)*******************
//Function/S tpw()
//	String name
//	name = stringfromlist(0,WaveList("*", ";","WIN:"+winname(0,1)))
//	Return name
//end
//****************  New Version with getwindow function   *******************
Function/S tpw()
	String name
	getwindow $winname(0,1) activeSW;
	name = stringfromlist(0,WaveList("*", ";","WIN:"+S_Value))
	Return name
	//if (itemsInList(childWindowList(winname(0,1))) == 0)
	//	name = stringfromlist(0,WaveList("*", ";","WIN:"+winname(0,1)))
	//	Return name
	//if (itemsInList(childWindowList(winname(0,1))) != 0)
	//	getwindow $winname(0,1) activeSW
end
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
//**    modifygraph display range follow times sigma
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
//**    modifygraph display range follow times sigma
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
Function SetVarProc_changeds(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	Execute "coloarrangec()"
End
Proc coloarrangec()
	string name = topgraphimage
	wavestats/Q $name
	variable sigma = sqrt(2)*W_coef[3]
	variable lc,lh
	string/G topgraphcolorinv
	String/G topgraphcolor
	if (W_coef[2]-0.5*timesg*sigma >V_min)
		lc = W_coef[2]-0.5*timesg*sigma
	else
		lc =V_min
	endif
	if (W_coef[2]+0.5*timesg*sigma < V_max)
		lh = W_coef[2]+0.5*timesg*sigma
	else
		lh =V_max
	endif
	string body = "ModifyImage "+name+" ctab= {"+num2str(lc)+","+num2str(lh)+","+topgraphcolor+","+topgraphcolorinv+"}"
	Execute body
	//PRINT num2str(W_coefw[2]-1.5*sigma)+" "+ num2str(W_coefw[2]+1.5*sigma)
	//print num2str(W_coefw[2])
	//display namehistw
END
Function ButtonProc_colorFFT(ctrlName) : ButtonControl
	String ctrlName
	Execute "colorFFT()"
end

Proc colorFFT()
	//String toexecute1,toexecute2,toexecute
	//wavestats/Q $topgraphimage
	//toexecute1="Modifyimage/W= "+topgraphname+" "+topgraphimage+" ctab={"+num2str(V_min)
	//toexecute2=","+num2str(0.2*V_max)+","+topgraphcolor+","+topgraphcolorinv+"}"
	//toexecute=toexecute1+toexecute2
	//Execute toexecute
	color3sfft($tpw(),30)
end
Function color3sfft(name,tt)
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
	ModifyImage $nameofwave(name) ctab= {lc,lh,VioletOrangeYellow,1}
end
/////////////////////////////////////////////////////////////////////////////
//** Function can be called in a procedure (3*sigma)
/////////////////////////////////////////////////////////////////////////////
Function color3s(name,tt)
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

	ModifyImage $nameofwave(name) ctab= {lc,lh,VioletOrangeYellow,0}
	//PRINT num2str(W_coefw[2]-1.5*sigma)+" "+ num2str(W_coefw[2]+1.5*sigma)
	//print num2str(W_coefw[2])
	//display namehistw
end
Function gethistgram_npcolor(name)
	string name
	string histn = "Hist_"+name
	make/o/N=1000 $histn
	wavestats/Q $name
	variable Vmax = V_max
	Variable Vmin = V_min
	variable mdian = median($name)
	Histogram/B={(mdian-(Vmax-Vmin)/2),(V_max-V_min)/1000,1000} $name,$histn
	duplicate/o $histn fithttemp

	//CurveFit/Q gauss, $histn/D=fithttemp
	variable V_FitError = 0
	CurveFit/Q gauss, $histn/D=fithttemp
	if (V_FitError != 0)
	endif

	killwaves fithttemp
	string W_coef="W_coef"
	wave W_coefw = $W_coef
	variable coverratio //(0,1]
	coverratio = (2*5*W_coefw[3])/(Vmax-Vmin)
	Histogram/B={(mdian-coverratio*(Vmax-Vmin)/2),coverratio*(V_max-V_min)/200,200} $name,$histn

	//CurveFit/Q gauss, $histn/D//=fithttemp
	V_FitError = 0
	CurveFit/Q gauss, $histn/D//=fithttemp
	if (V_FitError != 0)
	endif
end
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
//** End   modifygraph display range follow times sigma
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////








///////////////////////////////////////////////////////////////////////////////////////////////
/// return the win name of the selected data
/// if the data with the name exist, and did not on a display, the data will be displayed and
/// return the name of the newest window.
///////////////////////////////////////////////////////////////////////////////////////////////
Function/s grabwin(name)
	string name
 	string fulllist = WinList("*", ";","WIN:1")
	string nn,waveong,cmdn,out
	out = ""
	variable i
	for(i=0; i<itemsinlist(fulllist); i +=1)
        nn= stringfromlist(i, fulllist)
        cmdn="WIN:"+nn
        waveong = stringfromlist(0,WaveList("*", ";",cmdn))  //Only detect the first element.
        if (CmpStr(name,waveong) == 0)
        	out = nn
        else
        endif
    endfor

    if (cmpstr(out,"") == 0)
    	if (exists(name) == 1)
    		wave namew = $name
    		di(namew)
    		out = winname(0,1)
    	endif
    endif
    Return out
end

Function/s grabwin2(name)
	string name
 	string fulllist = WinList("*", ";","WIN:1")
	string nn,waveong,cmdn,out
	out = ""
	variable i
	for(i=0; i<itemsinlist(fulllist); i +=1)
        nn= stringfromlist(i, fulllist)
        cmdn="WIN:"+nn
        waveong = stringfromlist(0,WaveList("*", ";",cmdn))
        if (CmpStr(name,waveong) == 0)
        	out = nn
        else
        endif
    endfor

    if (cmpstr(out,"") == 0)
    	if (exists(name) == 1)
    		wave namew = $name
    		di2(namew)
    		out = winname(0,1)
    	endif
    endif
    Return out
end
////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// End of return winname
////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
///return the table name of the selected data
/// if the data with the name exist, and did not on a display, the data will be displayed and
/// return the name of the newest window.
////////////////////////////////////////////////////////////////////////////////////////////
Function/s grabtable(name)
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
    		ed(namew)
    		out = winname(0,1)
    	endif
    endif
    Return out
end
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////             check if a wave on the graph             //////////
////////////////////////////////////////////////////////////////////////////////////////////
//name = winame(0,1)
//waven is the name of the wave want to append
//If the wave on the graph, it will return =!0, if it is not on the graph, return 0
Function ckwaveonfig(name,waven)
	string name  //name of the graph
	string waven //name of the wave
	wave wavenw = $waven
	string cmd ="WIN:"+name
	string wavenamelist
	wavenamelist=WaveList("*", ";",cmd)
	variable i,count
	count = 0
	i=0
	do
		//print stringfromlist(i, wavenamelist)+","+waven
		//print num2str(cmpstr(stringfromlist(i, wavenamelist),waven))
		if(cmpstr(stringfromlist(i, wavenamelist),waven) == 0)
			count +=1
		else
		endif
		//print count
		i+=1
	while(i<itemsInList(wavenamelist))
	//if (count == 0)
	//	appendtograph wavenw
	//endif
	Return count
end
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////         end check if a wave on the graph             //////////
////////////////////////////////////////////////////////////////////////////////////////////
Function PopMenuProc_more2(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	Variable/G colorsetedc2
	colorsetedc2=popNum
End
Function ButtonProc_color_edc_more2(ctrlName) : ButtonControl
	String ctrlName
	Execute "color_edc_more2()"
End
Proc color_edc_more2()
	PauseUpdate
	Silent 1
	String WN
	String fromcolorlist
	String nameofcolor,nameofcolor0
	Variable color1,color2,color0
	Variable i
	Variable num_of_curves
	Variable xvalue
	fromcolorlist=WaveList("*", ";", "", root:Packages:NewColortable:)
	nameofcolor0=Stringfromlist(colorsetedc2-1,fromcolorlist)
	//print nameofcolor
	nameofcolor="root:Packages:NewColortable:"+nameofcolor0
	num_of_curves=0
	Do
		num_of_curves+=1
	While(WaveExists($WaveName("",num_of_curves,1) ) != 0)
	num_of_curves-=1
	//ColorTab2Wave $nameofcolor
	Setscale/I x,0,1,"",$nameofcolor
	If(colorinverseedc==2)
		Duplicate/O $nameofcolor tempmatcolor
		tempmatcolor[][]=$nameofcolor[(dimsize($nameofcolor,0)-1)-p][q]
		Duplicate/O tempmatcolor $nameofcolor
		Killwaves tempmatcolor
	Endif
	Make/O/N=(dimsize($nameofcolor,0)) xcolorwave
	xcolorwave[]=0+p*dimdelta($nameofcolor,0)
	i=0
	Do
		xvalue=i/num_of_curves
		Duplicate/O xcolorwave ycolorwave
		ycolorwave[]=$nameofcolor[p][0]
		color0=Round(interp(xvalue,xcolorwave,ycolorwave))
		ycolorwave[]=$nameofcolor[p][1]
		color1=Round(interp(xvalue,xcolorwave,ycolorwave))
		ycolorwave[]=$nameofcolor[p][2]
		color2=Round(interp(xvalue,xcolorwave,ycolorwave))
		WN=WaveName("",i,1)
		ModifyGraph rgb($WN)=(color0,color1,color2)
		i+=1
	while( WaveExists($WaveName("",i,1) ) != 0 )
	Killwaves xcolorwave,ycolorwave
End
///////////////////////////////////////////////////////////////////////////
//************************************************************************
////////////////////////////////////////////////////////////////////////////////////////
Function SetVarProc_colormatmorevvline(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	Execute "colormatmorevvline()"
End
Function colormatmorevvline()
	String WN
	String fromcolorlist
	String nameofcolor,nameofcolor0
	Variable color1,color2,color0
	Variable i
	Variable num_of_curves
	Variable xvalue
	Variable/G colorsetedc3
	Variable/G colorinverseedc

	variable numnew = itemsInList(WaveList("*", ";", "", root:Packages:NewColortable:))
	string M_colors = "M_colors"
	if(colorsetedc3 < numnew)
		fromcolorlist=WaveList("*", ";", "", root:Packages:NewColortable:)
		nameofcolor0=Stringfromlist(colorsetedc3,fromcolorlist)
		nameofcolor="root:Packages:NewColortable:"+nameofcolor0
		Setscale/I x,0,1,"",$nameofcolor

		SetVariable setvarsetciu1 title="\\JL"+stringfromList(colorsetedc3,WaveList("*", ";", "", root:Packages:NewColortable:))

		wave nameofcolorw = $nameofcolor
		num_of_curves=0
		Do
			num_of_curves+=1
		While(WaveExists($WaveName("",num_of_curves,1) ) != 0)
		num_of_curves-=1


		If(colorinverseedc==2)
			Duplicate/O $nameofcolor tempmatcolor
			tempmatcolor[][]=nameofcolorw[(dimsize($nameofcolor,0)-1)-p][q]
			Duplicate/O tempmatcolor $nameofcolor
			Killwaves tempmatcolor
		Endif
		Make/O/N=(dimsize($nameofcolor,0)) xcolorwave
		xcolorwave[]=0+p*dimdelta($nameofcolor,0)
		i=0
		Do
			xvalue=i/num_of_curves
			Duplicate/O xcolorwave ycolorwave
			ycolorwave[]=nameofcolorw[p][0]
			color0=Round(interp(xvalue,xcolorwave,ycolorwave))
			ycolorwave[]=nameofcolorw[p][1]
			color1=Round(interp(xvalue,xcolorwave,ycolorwave))
			ycolorwave[]=nameofcolorw[p][2]
			color2=Round(interp(xvalue,xcolorwave,ycolorwave))
			WN=WaveName("",i,1)
			ModifyGraph rgb($WN)=(color0,color1,color2)
			i+=1
		while( WaveExists($WaveName("",i,1) ) != 0 )


	else
		fromcolorlist=CTabList()
		nameofcolor=Stringfromlist(colorsetedc3-numnew,fromcolorlist)
		num_of_curves=0

		Do
			num_of_curves+=1
		While(WaveExists($WaveName("",num_of_curves,1) ) != 0)
		num_of_curves-=1

		ColorTab2Wave $nameofcolor
		wave M_colorsw = $M_colors
		Setscale/I x,0,1,"",M_colorsw
		SetVariable setvarsetciu1 title="\\JL"+stringfromList(colorsetedc3-numnew,CtabList())

		If(colorinverseedc==2)
		Duplicate/O M_colorsw tempmatcolor
		tempmatcolor[][]=M_colorsw[(dimsize(M_colorsw,0)-1)-p][q]
		Duplicate/O tempmatcolor M_colorsw
		Killwaves tempmatcolor
		Endif
		Make/O/N=(dimsize(M_colorsw,0)) xcolorwave
		xcolorwave[]=0+p*dimdelta(M_colorsw,0)
		i=0
		Do
			xvalue=i/num_of_curves
			Duplicate/O xcolorwave ycolorwave
			ycolorwave[]=M_colorsw[p][0]
			color0=Round(interp(xvalue,xcolorwave,ycolorwave))
			ycolorwave[]=M_colorsw[p][1]
			color1=Round(interp(xvalue,xcolorwave,ycolorwave))
			ycolorwave[]=M_colorsw[p][2]
			color2=Round(interp(xvalue,xcolorwave,ycolorwave))
			WN=WaveName("",i,1)
			ModifyGraph rgb($WN)=(color0,color1,color2)
			i+=1
		while( WaveExists($WaveName("",i,1) ) != 0 )

	endif


	Killwaves xcolorwave,ycolorwave

End
/////////////////////////////////////////////////////////////////////////////////////////


//************************************************************************
//////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////
Function PopMenuProc_colormatmore2(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	variable/G topgraphnum
	Variable/G topimagemin
	Variable/G topimagemax
	Variable/G minsetvar
	Variable/G maxsetvar
	Variable/G topimageminratio
	Variable/G topimagemaxratio
	String/G topgraphimage
	String/G topgraphname
	String topgraphcolor_m2
	String/G topgraphcolor
	String/G topgraphcolorinv
	String toexecute1,toexecute2,toexecute
	//string ttpath
	topgraphcolor_m2=popstr
	topgraphcolor = "root:Packages:NewColortable:"+topgraphcolor_m2
	toexecute1="Modifyimage/W= "+topgraphname+" "+topgraphimage+" ctab={"+num2str(topimageminratio*(topimagemax-topimagemin)+topimagemin)
	toexecute2=","+num2str(topimagemaxratio*(topimagemax-topimagemin)+topimagemin)+","+topgraphcolor+","+topgraphcolorinv+"}"
	toexecute=toexecute1+toexecute2
	Execute toexecute
End
////////////////////////////////////////////////////////////////////////////////////////
Function SetVarProc_colormatmorevv(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	colormatmorevv()
End
Function colormatmorevv()
	variable/G topgraphnum
	Variable/G topimagemin
	Variable/G topimagemax
	Variable/G minsetvar
	Variable/G maxsetvar
	Variable/G topimageminratio
	Variable/G topimagemaxratio
	String/G topgraphimage
	String/G topgraphname
	String topgraphcolor_m2
	String/G topgraphcolor
	String/G topgraphcolorinv
	variable/G colorindexuser
	String toexecute1,toexecute2,toexecute
	//string ttpath
	variable numnew = itemsInList(WaveList("*", ";", "", root:Packages:NewColortable:))

	if(colorindexuser < numnew)
		topgraphcolor_m2=stringfromList(colorindexuser,WaveList("*", ";", "", root:Packages:NewColortable:))
		topgraphcolor = "root:Packages:NewColortable:"+topgraphcolor_m2
		SetVariable setvarsetciu title="\\JL"+stringfromList(colorindexuser,WaveList("*", ";", "", root:Packages:NewColortable:))
	else
		topgraphcolor_m2=stringfromList(colorindexuser-numnew,CtabList())
		topgraphcolor = topgraphcolor_m2
		SetVariable setvarsetciu title="\\JL"+stringfromList(colorindexuser-numnew,CtabList())
	endif
	toexecute1="Modifyimage/W= "+topgraphname+" "+topgraphimage+" ctab={"+num2str(topimageminratio*(topimagemax-topimagemin)+topimagemin)
	toexecute2=","+num2str(topimagemaxratio*(topimagemax-topimagemin)+topimagemin)+","+topgraphcolor+","+topgraphcolorinv+"}"
	toexecute=toexecute1+toexecute2
	Execute toexecute

End
/////////////////////////////////////////////////////////////////////////////////////////
Function PopMenuProc_colormatinvmore2(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	variable/G topgraphnum
	Variable/G topimagemin
	Variable/G topimagemax
	Variable/G minsetvar
	Variable/G maxsetvar
	Variable/G topimageminratio
	Variable/G topimagemaxratio
	String/G topgraphimage
	String/G topgraphname
	String/G topgraphcolor_m2
	String/G topgraphcolorinv
	String toexecute1,toexecute2,toexecute
	string ttpath
	ttpath = "root:Packages:NewColortable:"+topgraphcolor_m2
	topgraphcolorinv=num2str(popNum-1)
	toexecute1="Modifyimage/W= "+topgraphname+" "+topgraphimage+" ctab={"+num2str(topimageminratio*(topimagemax-topimagemin)+topimagemin)
	toexecute2=","+num2str(topimagemaxratio*(topimagemax-topimagemin)+topimagemin)+","+ttpath+","+topgraphcolorinv+"}"
	toexecute=toexecute1+toexecute2
	Execute toexecute
End

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
Function autoallfigure()
	string winl = WinList("*", ";","WIN:1")
	variable num=itemsInList(winl)
	string nn
	variable i
	i=0
	do
		nn=stringfromlist(i,winl)
		dowindow/F $nn
		ModifyGraph width=0,height=0
		i+=1
	while(i<num)
end
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
Function dic(destw)
	wave destw
    string fulllist = WinList("*", ";","WIN:1") //"1 for graph, 2 for table"
    string name,cmd,wavenamelist
    variable i,cc
    String dest=nameofwave(destw)
    cc=0
    for(i=0; i<itemsinlist(fulllist); i +=1)
        name= stringfromlist(i, fulllist)
        cmd="WIN:"+name
        wavenamelist = WaveList("*", ";",cmd)
		  if (itemsinlist(wavenamelist) == 1)
		  	if (itemsinlist(listMatch(wavenamelist,dest)) == 1)
		  		//Killsinglewindow(name)
		  		Dowindow/F $name
		  		cc +=1
		  	endif
		  else
		  endif
    endfor
   if (cc == 0)
  	   display destw

	endif
end
////////////////////////////////////////////////////////////////////////////
Function PrintMarqueeCoords()
	GetMarquee left, bottom
	if (V_flag == 0)
		Print "There is no marquee"
	else
		printf "marquee left in bottom axis terms: %g\r", V_left
		printf "marquee right in bottom axis terms: %g\r", V_right
		printf "marquee top in left axis terms: %g\r", V_top
		printf "marquee bottom in left axis terms: %g\r", V_bottom
	endif
End

Function ButtonProc_Consactiveall(ctrlName) : ButtonControl
	String ctrlName
	Execute "Consoffsetx()"
	Execute "Consoffset()"
	Execute "Conslinethick()"
	Execute "Consmoo()"
End
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//   continuely tuning smooth to any graph
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Consmoo(ctrlName) : ButtonControl
	String ctrlName
	Execute "Consmoo()"
End
Proc Consmoo()
	variable/G ss_cons = 0
	Dowindow/F $winname(0,1)
	duplicateongraph()
	SetVariable setvar90 title="Times",size={60,14},value=ss_cons,proc=SetVarProc_Consmoo
	//SetVariable setvar0 pos={70,1};
	SetVariable setvar90 limits={0,inf,1}
end
Function SetVarProc_Consmoo(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	execute "Consmooc()"
End
Proc Consmooc()
	revoverongraph()
	smoothallthegraph(ss_cons)
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
Function smoothallthegraph(ss)
	variable ss
	string allname=WaveList("*", ";","WIN:")
	variable num = itemsInList(WaveList("*", ";","WIN:"))
	string name
	variable i
	i=0
	do
		name = stringFromList(i,allname)
		wave namew = $name
		smooth ss,namew
		i+=1
	while(i<num)
end
Function duplicateongraph()
	string allname=WaveList("*", ";","WIN:")
	variable num = itemsInList(WaveList("*", ";","WIN:"))
	string name
	variable i
	string namen
	i=0
	do
		name = stringFromList(i,allname)
		namen="D_"+name
		duplicate/o $name $namen
		i+=1
	while(i<num)
end
Function revoverongraph()
	string allname=WaveList("*", ";","WIN:")
	variable num = itemsInList(WaveList("*", ";","WIN:"))
	string name
	variable i
	string namen
	i=0
	do
		name = stringFromList(i,allname)
		Wave namew = $name
		namen="D_"+name
		Wave namenw = $namen
		namew = namenw
		i+=1
	while(i<num)
end
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//   End of continuely tuning smooth to any graph
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//   continuely tuning Y offset to any graph
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Consoffset(ctrlName) : ButtonControl
	String ctrlName
	Execute "Consoffset()"
	Execute "Consoffsetx()"
End
Proc Consoffset()
	string allname=WaveList("*", ";","WIN:")
	variable num = itemsInList(WaveList("*", ";","WIN:"))
	string name
	variable i
	i=0
	name = stringFromList(i,allname)
	wavestats/Q $name
	variable/G off_cons = dimsize($name,0)*str2num(ReplaceString("offset(x)={0,", stringfromList(49,TraceInfo("","",1)), ""))/V_max
	Dowindow/F $winname(0,1)
	SetVariable setvar91 title="Offset(Y)",size={80,14},value=off_cons,proc=SetVarProc_Consoffset
	//SetVariable setvar5 pos={200,1}
	SetVariable setvar91 limits={-inf,inf,1}
end
Function SetVarProc_Consoffset(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	execute "Consoffsetc()"
End
Proc Consoffsetc()
	string allname=WaveList("*", ";","WIN:")
	variable num = itemsInList(WaveList("*", ";","WIN:"))
	string name
	variable i
	i=0
	name = stringFromList(i,allname)
	wavestats/Q $name
	variable Xoff = off_consx*V_max/dimsize($name,0)
	Constantoffset_nFx(Xoff,1,off_cons*V_max/dimsize($name,0))
end

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//   End continuely tuning offset to any graph
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////




////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//   continuely tuning line thickness on the graph
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Conslinethick(ctrlName) : ButtonControl
	String ctrlName
	Execute "Conslinethick()"
End
Proc Conslinethick()
	//string allname=WaveList("*", ";","WIN:")
	//variable num = itemsInList(WaveList("*", ";","WIN:"))
	//string name
	//variable i
	//i=0
	//name = stringFromList(i,allname)
	//wavestats/Q $name
	variable/G thick_cons
	Dowindow/F $winname(0,1)
	SetVariable setvar92 title="Thick",size={65,14},value=thick_cons,proc=SetVarProc_Conslinethick
	//SetVariable setvar5 pos={200,1}
	SetVariable setvar92 limits={0,10,0.1}
end
Function SetVarProc_Conslinethick(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	execute "Conslinethickc()"
End
Proc Conslinethickc()
	//string allname=WaveList("*", ";","WIN:")
	//variable num = itemsInList(WaveList("*", ";","WIN:"))
	//string name
	//variable i
	ModifyGraph lsize=thick_cons
end
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//   End of continuely tuning line thickness on the graph
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//   continuely tuning X offset to any graph
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Consoffsetx(ctrlName) : ButtonControl
	String ctrlName
	Execute "Consoffsetx()"
	Execute "Consoffset()"
End
Proc Consoffsetx()
	string allname=WaveList("*", ";","WIN:")
	variable num = itemsInList(WaveList("*", ";","WIN:"))
	string name
	variable i
	i=0
	name = stringFromList(i,allname)
	wavestats/Q $name
	variable/G off_consx =0
	Dowindow/F $winname(0,1)
	SetVariable setvar88 title="Offset(x)",size={80,14},value=off_consx,proc=SetVarProc_Consoffsetx
	//SetVariable setvar5 pos={200,1}
	SetVariable setvar88 limits={-inf,inf,1}
end
Function SetVarProc_Consoffsetx(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	execute "Consoffsetcx()"
End
Proc Consoffsetcx()
	string allname=WaveList("*", ";","WIN:")
	variable num = itemsInList(WaveList("*", ";","WIN:"))
	string name
	variable i
	i=0
	name = stringFromList(i,allname)
	wavestats/Q $name
	variable Yoff = off_cons*V_max/dimsize($name,0)

	Constantoffset_nFx(off_consx*V_max/dimsize($name,0),1,Yoff)
end

Function Constantoffset_nFx(Shift,number_of_same,xx)
	Variable Shift
	Variable number_of_same
	variable xx
	Variable n=0,i
	String WN0
	Variable Y_Offset=0
	variable X_offset=0
	Do
		i=0
		Do
			WN0=WaveName("",n+i,1)
			//wave wn0w=$WN0
			ModifyGraph offset($wn0)={X_offset,Y_offset}
			i+=1
			//display wn0w//**
		While(i<number_of_same)

		X_Offset+=shift
		Y_offset+=xx
		n+=number_of_same
		string tc
		tc = WaveName("",n,1)
		wave tcw = $tc
	while( WaveExists( tcw ) != 0 )
End
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//   End continuely tuning X offset to any graph
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////


//****************************************************************************************************************///
//****************************************************************************************************************///
//****************************************************************************************************************///
//****************************************************************************************************************///
//**	Procedure for auto Zcolor map
//****************************************************************************************************************///
//****************************************************************************************************************///
//****************************************************************************************************************///
//****************************************************************************************************************///
//****************************************************************************************************************///


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//Part I : from color table
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

Function ButtonProc_Zcoloro(ctrlName) : ButtonControl
	String ctrlName

	Dowindow/F $winname(0,1)
	modifygraph width=350,height=500
	ModifyGraph margin(top)=72
	PopupMenu popup0 proc=PopMenuProc_Zcoloronthegraph,value="*COLORTABLEPOP*",bodyWidth=150
	PopupMenu popup1 proc=PopMenuProc_colormatinv1,value="Normal;Inverse",pos={160,1}
	Slider slider0 vert=1,proc=SliderProc_topmaxwf1,limits={0.1,1.5,0.01},ticks=4,value=0.5,pos={240,1}
	Slider slider1 vert=1,proc=SliderProc_topminwf1,limits={-0.2,1.4,0.01},ticks=4,value=0,side=0,pos={290,1}
	Button button0 proc=Button_image_auto_bothwf1,title="auto",size={40,15},fSize=8,pos={330,1}

	PopupMenu popup2 pos={1,26}, proc=PopMenuProc_Zcoloronthegraph2,value=WaveList("*", ";", "", root:Packages:NewColortable),bodyWidth=150
	PopupMenu popup3 proc=PopMenuProc_colormatinv2,value="Normal;Inverse",pos={160,26}
	Slider slider2 vert=1,proc=SliderProc_topmaxwf2,limits={0.1,1.5,0.01},ticks=4,value=0.5,pos={240,26}
	Slider slider3 vert=1,proc=SliderProc_topminwf2,limits={-0.2,1.4,0.01},ticks=4,value=0,side=0,pos={290,26}
	Button button1 proc=Button_image_auto_bothwf2,title="auto",size={40,15},fSize=8,pos={330,26}
	Button button2 proc=ButtonProc_Zcoloroexist,title="Exist",size={40,15},fSize=8,pos={380,26}


	SetVariable setvarciuz size={100,20},pos={1,52},limits={0,itemsInList(WaveList("*", ";", "", root:Packages:NewColortable:))-1+itemsInList(CTabList()),1},value=colorsetedc3,proc=SetVarProc_ConsZcuiz,title="\\JLdvg_bwr_20_95_c54", bodyWidth=45,textAlign=2

	Execute "Consoffsetx()"
	Execute "Consoffset()"
	Execute "Conslinethick()"
	Execute "Consmoo()"
	modifygraph width=0,height=0

end

Function SetVarProc_ConsZcuiz(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	ConsZcuiz()
End
///////////////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************************
Function ConsZcuiz()
	variable/G topgraphnum1
	Variable/G topimagemin1
	Variable/G topimagemax1
	Variable/G minsetvar1
	Variable/G maxsetvar1
	Variable/G topimageminratio1
	Variable/G topimagemaxratio1
	String/G topgraphimage1
	String/G topgraphname1
	String/G topgraphcolor1
	String/G topgraphcolorinv1

	variable/G colorsetedc3

	string allname=WaveList("*", ";","WIN:")
	variable num = itemsInList(WaveList("*", ";","WIN:"))
	string name
	variable i
	string exbody
	topimagemax1=maxwaterfall()
	topimagemin1=minwaterfall()
	variable numnew = itemsInList(WaveList("*", ";", "", root:Packages:NewColortable:))

	if(colorsetedc3 < numnew)
		SetVariable setvarciuz bodyWidth=0,title="\\JL"+stringfromList(colorsetedc3,WaveList("*", ";", "", root:Packages:NewColortable:))
		topgraphcolor1 = Stringfromlist(colorsetedc3,WaveList("*", ";", "", root:Packages:NewColortable:))
		i=0
		do
			name = stringFromList(i,allname)
			exbody="ModifyGraph zColor("+name+")={"+name+","+num2str(topimageminratio1*(topimagemax1-topimagemin1)+topimagemin1)+","+num2str(topimagemaxratio1*(topimagemax1-topimagemin1)+topimagemin1)+","+"ctableRGB"+","+topgraphcolorinv1+",:Packages:NewColortable:"+topgraphcolor1+"}"
			execute exbody
			i+=1
		while (i<num)

	else
		SetVariable setvarciuz bodyWidth=0,title="\\JL"+stringfromList(colorsetedc3-numnew,CtabList())
		topgraphcolor1 = Stringfromlist(colorsetedc3-numnew,CTabList())
		i=0
		do
			name = stringFromList(i,allname)
			exbody="ModifyGraph zColor("+name+")={"+name+","+num2str(topimageminratio1*(topimagemax1-topimagemin1)+topimagemin1)+","+num2str(topimagemaxratio1*(topimagemax1-topimagemin1)+topimagemin1)+","+topgraphcolor1+","+topgraphcolorinv1+"}"
			execute exbody
			i+=1
		while (i<num)
	endif
end

//*****************************************************************************************
///////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Zcoloroexist(ctrlName) : ButtonControl
	String ctrlName
	ModifyGraph zColor=0
end

Function PopMenuProc_Zcoloronthegraph(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	variable/G topgraphnum1
	Variable/G topimagemin1
	Variable/G topimagemax1
	Variable/G minsetvar1
	Variable/G maxsetvar1
	Variable/G topimageminratio1
	Variable/G topimagemaxratio1
	String/G topgraphimage1
	String/G topgraphname1
	String/G topgraphcolor1
	String/G topgraphcolorinv1
	topgraphcolor1=popstr
	//topgraphcolorinv1 ="1"
	string allname=WaveList("*", ";","WIN:")
	variable num = itemsInList(WaveList("*", ";","WIN:"))
	string name
	variable i
	string exbody

	topimagemax1=maxwaterfall()
	topimagemin1=minwaterfall()

	i=0
	do
		name = stringFromList(i,allname)
		exbody="ModifyGraph zColor("+name+")={"+name+","+num2str(topimageminratio1*(topimagemax1-topimagemin1)+topimagemin1)+","+num2str(topimagemaxratio1*(topimagemax1-topimagemin1)+topimagemin1)+","+topgraphcolor1+","+topgraphcolorinv1+"}"

		//exbody="ModifyGraph zColor("+name+")={"+name+","+"*"+","+"*"+","+topgraphcolor1+","+topgraphcolorinv1+"}"

		execute exbody
		i+=1

	while (i<num)
end




Function PopMenuProc_colormatinv1(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	variable/G topgraphnum1
	Variable/G topimagemin1
	Variable/G topimagemax1
	Variable/G minsetvar1
	Variable/G maxsetvar1
	Variable/G topimageminratio1
	Variable/G topimagemaxratio1
	String/G topgraphimage1
	String/G topgraphname1
	String/G topgraphcolor1
	String/G topgraphcolorinv1
	topgraphcolorinv1=num2str(popNum-1)
	string allname=WaveList("*", ";","WIN:")
	variable num = itemsInList(WaveList("*", ";","WIN:"))
	string name
	variable i
	string exbody

	topimagemax1=maxwaterfall()
	topimagemin1=minwaterfall()

	i=0
	do
		name = stringFromList(i,allname)
		exbody="ModifyGraph zColor("+name+")={"+name+","+num2str(topimageminratio1*(topimagemax1-topimagemin1)+topimagemin1)+","+num2str(topimagemaxratio1*(topimagemax1-topimagemin1)+topimagemin1)+","+topgraphcolor1+","+topgraphcolorinv1+"}"

		//exbody="ModifyGraph zColor("+name+")={"+name+","+"*"+","+"*"+","+topgraphcolor1+","+topgraphcolorinv1+"}"

		execute exbody
		i+=1

	while (i<num)

End


//********************************************************************************************************************************
Function SliderProc_topmaxwf1(ctrlName,sliderValue,event) : SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved
	variable/G topgraphnum1
	Variable/G topimagemin1
	Variable/G topimagemax1
	Variable/G minsetvar1
	Variable/G maxsetvar1
	Variable/G topimageminratio1
//	Variable/G topimagemaxratio
	String/G topgraphimage1
	String/G topgraphname1
	String/G topgraphcolor1
	String/G topgraphcolorinv1
	//String toexecute1,toexecute2,toexecute
	if(event %& 0x1)	// bit 0, value set
	endif
	//toexecute1="Modifyimage/W= "+topgraphname+" "+topgraphimage+" ctab={"+num2str(topimageminratio*(topimagemax-topimagemin)+topimagemin)
	//toexecute2=","+num2str(sliderValue*(topimagemax-topimagemin)+topimagemin)+","+topgraphcolor+","+topgraphcolorinv+"}"
	//toexecute=toexecute1+toexecute2
	//Execute toexecute

	string allname=WaveList("*", ";","WIN:")
	variable num = itemsInList(WaveList("*", ";","WIN:"))
	string name
	variable i
	string exbody
	i=0
	do
		name = stringFromList(i,allname)
		exbody="ModifyGraph zColor("+name+")={"+name+","+num2str(topimageminratio1*(topimagemax1-topimagemin1)+topimagemin1)+","+num2str(sliderValue*(topimagemax1-topimagemin1)+topimagemin1)+","+topgraphcolor1+","+topgraphcolorinv1+"}"

		//exbody="ModifyGraph zColor("+name+")={"+name+","+"*"+","+"*"+","+topgraphcolor1+","+topgraphcolorinv1+"}"

		execute exbody
		i+=1

	while (i<num)


	return 0
End
//********************************************************************************************************************************
Function SliderProc_topminwf1(ctrlName,sliderValue,event) : SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved
	variable/G topgraphnum1
	Variable/G topimagemin1
	Variable/G topimagemax1
	Variable/G minsetvar1
	Variable/G maxsetvar1
//	Variable/G topimageminratio
	Variable/G topimagemaxratio1
	String/G topgraphimage1
	String/G topgraphname1
	String/G topgraphcolor1
	String/G topgraphcolorinv1
	//String toexecute1,toexecute2,toexecute
	if(event %& 0x1)	// bit 0, value set
	endif
	//toexecute1="Modifyimage/W= "+topgraphname+" "+topgraphimage+" ctab={"+num2str(sliderValue*(topimagemax-topimagemin)+topimagemin)
	//toexecute2=","+num2str(topimagemaxratio*(topimagemax-topimagemin)+topimagemin)+","+topgraphcolor+","+topgraphcolorinv+"}"
	//toexecute=toexecute1+toexecute2
	//Execute toexecute
	string allname=WaveList("*", ";","WIN:")
	variable num = itemsInList(WaveList("*", ";","WIN:"))
	string name
	variable i
	string exbody
	i=0
	do
		name = stringFromList(i,allname)
		exbody="ModifyGraph zColor("+name+")={"+name+","+num2str(sliderValue*(topimagemax1-topimagemin1)+topimagemin1)+","+num2str(topimagemaxratio1*(topimagemax1-topimagemin1)+topimagemin1)+","+topgraphcolor1+","+topgraphcolorinv1+"}"

		//exbody="ModifyGraph zColor("+name+")={"+name+","+"*"+","+"*"+","+topgraphcolor1+","+topgraphcolorinv1+"}"

		execute exbody
		i+=1

	while (i<num)

	return 0
End
//********************************************************************************************************************************
Function Button_image_auto_bothwf1(ctrlName) : ButtonControl
	String ctrlName
	variable/G topgraphnum1
	Variable/G topimagemin1
	Variable/G topimagemax1
	Variable/G minsetvar1
	Variable/G maxsetvar1
	Variable/G topimageminratio1
	Variable/G topimagemaxratio1
	String/G topgraphimage1
	String/G topgraphname1
	String/G topgraphcolor1
	String/G topgraphcolorinv1
	//String toexecute1,toexecute2,toexecute


	string allname=WaveList("*", ";","WIN:")
	variable num = itemsInList(WaveList("*", ";","WIN:"))
	string name
	variable i
	string exbody
	i=0
	do
		name = stringFromList(i,allname)
		//exbody="ModifyGraph zColor("+name+")={"+name+","+num2str(sliderValue*(topimagemax1-topimagemin1)+topimagemin1)+","+num2str(topimagemaxratio1*(topimagemax1-topimagemin1)+topimagemin1)+","+topgraphcolor1+","+topgraphcolorinv1+"}"

		exbody="ModifyGraph zColor("+name+")={"+name+","+"*"+","+"*"+","+topgraphcolor1+","+topgraphcolorinv1+"}"

		execute exbody
		i+=1

	while (i<num)

	//toexecute1="Modifyimage/W= "+topgraphname+" "+topgraphimage+" ctab={*"
	//toexecute2=",*,"+topgraphcolor+","+topgraphcolorinv+"}"
	//toexecute=toexecute1+toexecute2
	//Execute toexecute
	topimageminratio1=0
	topimagemaxratio1=1
	slider slider0 value=topimagemaxratio1
	slider slider1 value=topimageminratio1
	return 0
End



Function maxwaterfall()
	string allname=WaveList("*", ";","WIN:")
	variable num = itemsInList(WaveList("*", ";","WIN:"))
	string name
	make/N=(num)/o maxwww

	variable i
	i=0
	do
		name = stringFromList(i,allname)
		wave namew = $name
		WaveStats/Q namew
		maxwww[i]=V_max
		i+=1
	while (i<num)
	WaveStats/Q maxwww
	killwaves maxwww
	return V_max
end

Function minwaterfall()
	string allname=WaveList("*", ";","WIN:")
	variable num = itemsInList(WaveList("*", ";","WIN:"))
	string name
	make/N=(num)/o minwww

	variable i
	i=0
	do
		name = stringFromList(i,allname)
		wave namew = $name
		WaveStats/Q namew
		minwww[i]=V_min
		i+=1
	while (i<num)
	WaveStats/Q minwww
	killwaves minwww
	return V_min
end


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//Part II : from User color table wave
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

Function PopMenuProc_Zcoloronthegraph2(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	variable/G topgraphnum1
	Variable/G topimagemin1
	Variable/G topimagemax1
	Variable/G minsetvar1
	Variable/G maxsetvar1
	Variable/G topimageminratio1
	Variable/G topimagemaxratio1
	String/G topgraphimage1
	String/G topgraphname1
	String/G topgraphcolor1
	String/G topgraphcolorinv1
	topgraphcolor1=popstr
	//topgraphcolorinv1 ="1"
	string allname=WaveList("*", ";","WIN:")
	variable num = itemsInList(WaveList("*", ";","WIN:"))
	string name
	variable i
	string exbody

	topimagemax1=maxwaterfall()
	topimagemin1=minwaterfall()

	i=0
	do
		name = stringFromList(i,allname)
		exbody="ModifyGraph zColor("+name+")={"+name+","+num2str(topimageminratio1*(topimagemax1-topimagemin1)+topimagemin1)+","+num2str(topimagemaxratio1*(topimagemax1-topimagemin1)+topimagemin1)+","+"ctableRGB"+","+topgraphcolorinv1+",:Packages:NewColortable:"+topgraphcolor1+"}"

		//exbody="ModifyGraph zColor("+name+")={"+name+","+"*"+","+"*"+","+"ctableRGB"+","+topgraphcolorinv1+",:Packages:NewColortable:"+topgraphcolor1+"}"

		execute exbody
		i+=1

	while (i<num)
end


Function PopMenuProc_colormatinv2(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	variable/G topgraphnum1
	Variable/G topimagemin1
	Variable/G topimagemax1
	Variable/G minsetvar1
	Variable/G maxsetvar1
	Variable/G topimageminratio1
	Variable/G topimagemaxratio1
	String/G topgraphimage1
	String/G topgraphname1
	String/G topgraphcolor1
	String/G topgraphcolorinv1
	topgraphcolorinv1=num2str(popNum-1)
	string allname=WaveList("*", ";","WIN:")
	variable num = itemsInList(WaveList("*", ";","WIN:"))
	string name
	variable i
	string exbody

	topimagemax1=maxwaterfall()
	topimagemin1=minwaterfall()

	i=0
	do
		name = stringFromList(i,allname)
		exbody="ModifyGraph zColor("+name+")={"+name+","+num2str(topimageminratio1*(topimagemax1-topimagemin1)+topimagemin1)+","+num2str(topimagemaxratio1*(topimagemax1-topimagemin1)+topimagemin1)+","+"ctableRGB"+","+topgraphcolorinv1+",:Packages:NewColortable:"+topgraphcolor1+"}"

		//exbody="ModifyGraph zColor("+name+")={"+name+","+"*"+","+"*"+","+"ctableRGB"+","+topgraphcolorinv1+",:Packages:NewColortable:"+topgraphcolor1+"}"

		execute exbody
		i+=1

	while (i<num)

End


//********************************************************************************************************************************
Function SliderProc_topmaxwf2(ctrlName,sliderValue,event) : SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved
	variable/G topgraphnum1
	Variable/G topimagemin1
	Variable/G topimagemax1
	Variable/G minsetvar1
	Variable/G maxsetvar1
	Variable/G topimageminratio1
//	Variable/G topimagemaxratio
	String/G topgraphimage1
	String/G topgraphname1
	String/G topgraphcolor1
	String/G topgraphcolorinv1
	//String toexecute1,toexecute2,toexecute
	if(event %& 0x1)	// bit 0, value set
	endif
	//toexecute1="Modifyimage/W= "+topgraphname+" "+topgraphimage+" ctab={"+num2str(topimageminratio*(topimagemax-topimagemin)+topimagemin)
	//toexecute2=","+num2str(sliderValue*(topimagemax-topimagemin)+topimagemin)+","+topgraphcolor+","+topgraphcolorinv+"}"
	//toexecute=toexecute1+toexecute2
	//Execute toexecute

	string allname=WaveList("*", ";","WIN:")
	variable num = itemsInList(WaveList("*", ";","WIN:"))
	string name
	variable i
	string exbody
	i=0
	do
		name = stringFromList(i,allname)
		exbody="ModifyGraph zColor("+name+")={"+name+","+num2str(topimageminratio1*(topimagemax1-topimagemin1)+topimagemin1)+","+num2str(sliderValue*(topimagemax1-topimagemin1)+topimagemin1)+","+"ctableRGB"+","+topgraphcolorinv1+",:Packages:NewColortable:"+topgraphcolor1+"}"


		//exbody="ModifyGraph zColor("+name+")={"+name+","+"*"+","+"*"+","+"ctableRGB"+","+topgraphcolorinv1+",:Packages:NewColortable:"+topgraphcolor1+"}"


		execute exbody
		i+=1

	while (i<num)


	return 0
End
//********************************************************************************************************************************
Function SliderProc_topminwf2(ctrlName,sliderValue,event) : SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved
	variable/G topgraphnum1
	Variable/G topimagemin1
	Variable/G topimagemax1
	Variable/G minsetvar1
	Variable/G maxsetvar1
//	Variable/G topimageminratio
	Variable/G topimagemaxratio1
	String/G topgraphimage1
	String/G topgraphname1
	String/G topgraphcolor1
	String/G topgraphcolorinv1
	//String toexecute1,toexecute2,toexecute
	if(event %& 0x1)	// bit 0, value set
	endif
	//toexecute1="Modifyimage/W= "+topgraphname+" "+topgraphimage+" ctab={"+num2str(sliderValue*(topimagemax-topimagemin)+topimagemin)
	//toexecute2=","+num2str(topimagemaxratio*(topimagemax-topimagemin)+topimagemin)+","+topgraphcolor+","+topgraphcolorinv+"}"
	//toexecute=toexecute1+toexecute2
	//Execute toexecute
	string allname=WaveList("*", ";","WIN:")
	variable num = itemsInList(WaveList("*", ";","WIN:"))
	string name
	variable i
	string exbody
	i=0
	do
		name = stringFromList(i,allname)
		exbody="ModifyGraph zColor("+name+")={"+name+","+num2str(sliderValue*(topimagemax1-topimagemin1)+topimagemin1)+","+num2str(topimagemaxratio1*(topimagemax1-topimagemin1)+topimagemin1)+","+"ctableRGB"+","+topgraphcolorinv1+",:Packages:NewColortable:"+topgraphcolor1+"}"


		//exbody="ModifyGraph zColor("+name+")={"+name+","+"*"+","+"*"+","+"ctableRGB"+","+topgraphcolorinv1+",:Packages:NewColortable:"+topgraphcolor1+"}"


		execute exbody
		i+=1

	while (i<num)

	return 0
End
//********************************************************************************************************************************
Function Button_image_auto_bothwf2(ctrlName) : ButtonControl
	String ctrlName
	variable/G topgraphnum1
	Variable/G topimagemin1
	Variable/G topimagemax1
	Variable/G minsetvar1
	Variable/G maxsetvar1
	Variable/G topimageminratio1
	Variable/G topimagemaxratio1
	String/G topgraphimage1
	String/G topgraphname1
	String/G topgraphcolor1
	String/G topgraphcolorinv1
	//String toexecute1,toexecute2,toexecute


	string allname=WaveList("*", ";","WIN:")
	variable num = itemsInList(WaveList("*", ";","WIN:"))
	string name
	variable i
	string exbody
	i=0
	do
		name = stringFromList(i,allname)
		//exbody="ModifyGraph zColor("+name+")={"+name+","+num2str(sliderValue*(topimagemax1-topimagemin1)+topimagemin1)+","+num2str(topimagemaxratio1*(topimagemax1-topimagemin1)+topimagemin1)+","+topgraphcolor1+","+topgraphcolorinv1+"}"

		exbody="ModifyGraph zColor("+name+")={"+name+","+"*"+","+"*"+","+"ctableRGB"+","+topgraphcolorinv1+",:Packages:NewColortable:"+topgraphcolor1+"}"


		execute exbody
		i+=1

	while (i<num)

	//toexecute1="Modifyimage/W= "+topgraphname+" "+topgraphimage+" ctab={*"
	//toexecute2=",*,"+topgraphcolor+","+topgraphcolorinv+"}"
	//toexecute=toexecute1+toexecute2
	//Execute toexecute
	topimageminratio1=0
	topimagemaxratio1=1
	slider slider0 value=topimagemaxratio1
	slider slider1 value=topimageminratio1
	return 0
End

//****************************************************************************************************************///
//****************************************************************************************************************///
//****************************************************************************************************************///
//****************************************************************************************************************///
//**	End of Procedure for auto Zcolor map
//****************************************************************************************************************///
//****************************************************************************************************************///
//****************************************************************************************************************///
//****************************************************************************************************************///


//****************************************************************************************************************///
//****************************************************************************************************************///
//****************************************************************************************************************///
//****************************************************************************************************************///
//**	Procedure for Auto Histogram
//****************************************************************************************************************///
//****************************************************************************************************************///
//****************************************************************************************************************///
//****************************************************************************************************************///
//****************************************************************************************************************///


Function gethistgram()
	string wn=winname(0,1)
	string histn = "Hist_"+tpw()
	make/o/N=1000 $histn
	wavestats/Q $tpw()
	variable Vmax = V_max
	Variable Vmin = V_min
	variable mdian = median($tpw())
	Histogram/B={(mdian-(Vmax-Vmin)/2),(V_max-V_min)/1000,1000} $tpw(),$histn
	duplicate/o $histn fithttemp
	CurveFit/Q gauss, $histn/D=fithttemp
	killwaves fithttemp
	string W_coef="W_coef"
	wave W_coefw = $W_coef
	variable coverratio //(0,1]
	coverratio = (2*5*W_coefw[3])/(Vmax-Vmin)
	Histogram/B={(mdian-coverratio*(Vmax-Vmin)/2),coverratio*(V_max-V_min)/200,200} $tpw(),$histn

	wave histnw = $histn
	variable sumhis=sum($histn)
	histnw/=sumhis
	histnw*=100

	dichis($histn)

	//display $histn
	//ckfig(winname(0,1))

	//duplicate/o $histn fithttemp
	CurveFit/Q gauss, $histn/D//=fithttemp
	//killwaves fithttemp
	String fiii ="fit_"+histn
	//ModifyGraph rgb($fiii)=(0,0,0)
	//string exeb = "TextBox/C/N=text0 "+"X0 = "+num2str(W_coefw[2])+"\rσ = "+num2str(W_coefw[3]/sqrt(2))
	//execute exeb
	TextBox/C/N=text0 "X0 = "+num2str(W_coefw[2])+"\rσ = "+num2str(W_coefw[3]/sqrt(2))+"\rFWHM = "+num2str(2*sqrt(ln(2))*W_coefw[3])

	Dowindow/F $wn
	Return coverratio
end

Function dichis(destw)
	wave destw
    string fulllist = WinList("*", ";","WIN:1") //"1 for graph, 2 for table"
    string name,cmd,wavenamelist
    variable i,cc
    String dest=nameofwave(destw)
    cc=0
    for(i=0; i<itemsinlist(fulllist); i +=1)
        name= stringfromlist(i, fulllist)
        cmd="WIN:"+name
        wavenamelist = WaveList("*", ";",cmd)
		  if (itemsinlist(wavenamelist) == 2)
		  	if (itemsinlist(listMatch(wavenamelist,dest)) == 1)
		  		//Killsinglewindow(name)
		  		Dowindow/F $name
		  		cc +=1
		  	endif
		  else
		  endif
    endfor
   if (cc == 0)
		display destw
		ModifyGraph rgb=(0,0,0)
		ModifyGraph mode=5
		Label left "\\Z15Probability (%)"
		ModifyGraph mirror=2
		ModifyGraph tick=2
		ModifyGraph noLabel=0,axThick=2
	endif
end



////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//   continuely tuning Histogram parameters
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Conshist(ctrlName) : ButtonControl
	String ctrlName
	Execute "Conshist()"
End
Proc Conshist()
	gethistgram()
	variable/G binnum_cons = 200
	variable/G coverratio_cons =getratiohis()
	Variable/G times_sigma_cons =5
	SetVariable setvar99 title="Bin Num",size={100,20},value=binnum_cons,proc=SetVarProc_Conshist
	SetVariable setvar99 limits={100,1000,100}
	SetVariable setvarratio title="Ratio",size={100,20},value=coverratio_cons,proc=SetVarProc_Conshist
	SetVariable setvarratio limits={getratiohis()/10,inf,getratiohis()}

	SetVariable setvar991 title="Sigma mode",size={100,20},value=times_sigma_cons,proc=SetVarProc_Conshistsigma
	SetVariable setvar991 limits={1,inf,1}

end
Function SetVarProc_Conshist(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	execute "Conshistc()"
End
Proc Conshistc()
	gethistgramcons(binnum_cons,coverratio_cons)
end
Function gethistgramcons(binnum,coverratio)
	variable binnum //> 100 to 1000
	variable coverratio //(0,1]
	string wn=winname(0,1)
	string histn = "Hist_"+tpw()
	make/o/N=1000 $histn
	wavestats/Q $tpw()
	variable Vmax = V_max
	Variable Vmin = V_min
	variable mdian = median($tpw())
	Histogram/B={(mdian-coverratio*(Vmax-Vmin)/2),coverratio*(V_max-V_min)/binnum,binnum} $tpw(),$histn

	wave histnw = $histn
	variable sumhis=sum($histn)
	histnw/=sumhis
	histnw*=100

	CurveFit/Q gauss, $histn/D
	//display $histn
	//ModifyGraph mode=5
	//ckfig(winname(0,1))
	//Dowindow/F $wn
end

Function SetVarProc_Conshistsigma(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	execute "Conshistcsigma()"
End
Proc Conshistcsigma()
	gethistgramhowmanysigma(times_sigma_cons)
end


Function gethistgramhowmanysigma(aa)
	variable aa
	string wn=winname(0,1)
	string histn = "Hist_"+tpw()
	make/o/N=1000 $histn
	wavestats/Q $tpw()
	variable Vmax = V_max
	Variable Vmin = V_min
	variable mdian = median($tpw())
	Histogram/B={(mdian-(Vmax-Vmin)/2),(V_max-V_min)/1000,1000} $tpw(),$histn
	duplicate/o $histn fithttemp
	CurveFit/Q gauss, $histn/D=fithttemp
	killwaves fithttemp
	string W_coef="W_coef"
	wave W_coefw = $W_coef
	variable coverratio //(0,1]
	coverratio = (2*aa*W_coefw[3])/(Vmax-Vmin)
	Histogram/B={(mdian-coverratio*(Vmax-Vmin)/2),coverratio*(V_max-V_min)/200,200} $tpw(),$histn

	wave histnw = $histn
	variable sumhis=sum($histn)
	histnw/=sumhis
	histnw*=100
	CurveFit/Q gauss, $histn/D
end
////////////////////////////////////////////////////////////////////////
Function getratiohis()
	string wn=winname(0,1)
	string histn = "Hist_"+tpw()
	make/o/N=1000 $histn
	wavestats/Q $tpw()
	variable Vmax = V_max
	Variable Vmin = V_min
	variable mdian = median($tpw())
	Histogram/B={(mdian-(Vmax-Vmin)/2),(V_max-V_min)/1000,1000} $tpw(),$histn
	duplicate/o $histn fithttemp
	CurveFit/Q gauss, $histn/D=fithttemp
	killwaves fithttemp
	string W_coef="W_coef"
	wave W_coefw = $W_coef
	variable coverratio //(0,1]
	coverratio = (2*5*W_coefw[3])/(Vmax-Vmin)
	Histogram/B={(mdian-coverratio*(Vmax-Vmin)/2),coverratio*(V_max-V_min)/200,200} $tpw(),$histn
	wave histnw = $histn
	variable sumhis=sum($histn)
	histnw/=sumhis
	histnw*=100

	Dowindow/F $wn

	Return coverratio
end
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//   End continuely histogram parameters
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

Function gethistgram_np()
	string wn=winname(0,1)
	string histn = "Hist_"+tpw()
	make/o/N=1000 $histn
	wavestats/Q $tpw()
	variable Vmax = V_max
	Variable Vmin = V_min
	variable mdian = median($tpw())
	Histogram/B={(mdian-(Vmax-Vmin)/2),(V_max-V_min)/1000,1000} $tpw(),$histn
	duplicate/o $histn fithttemp
	CurveFit/Q gauss, $histn/D=fithttemp
	killwaves fithttemp
	string W_coef="W_coef"
	wave W_coefw = $W_coef
	variable coverratio //(0,1]
	coverratio = (2*5*W_coefw[3])/(Vmax-Vmin)
	Histogram/B={(mdian-coverratio*(Vmax-Vmin)/2),coverratio*(V_max-V_min)/200,200} $tpw(),$histn

	wave histnw = $histn
	variable sumhis=sum($histn)
	histnw/=sumhis
	histnw*=100

	//dichis($histn)

	//display $histn
	//ckfig(winname(0,1))

	//duplicate/o $histn fithttemp
	CurveFit/Q gauss, $histn/D//=fithttemp
	//killwaves fithttemp
	//String fiii ="fit_"+histn
	//ModifyGraph rgb($fiii)=(0,0,0)
	//string exeb = "TextBox/C/N=text0 "+"X0 = "+num2str(W_coefw[2])+"\rσ = "+num2str(W_coefw[3]/sqrt(2))
	//execute exeb
	//TextBox/C/N=text0 "X0 = "+num2str(W_coefw[2])+"\rσ = "+num2str(W_coefw[3]/sqrt(2))+"\rFWHM = "+num2str(2*sqrt(ln(2))*W_coefw[3])

	//Dowindow/F $wn
	//Return coverratio
end



//****************************************************************************************************************///
//****************************************************************************************************************///
//****************************************************************************************************************///
//****************************************************************************************************************///
//**	End of Procedure for auto Zcolor map
//****************************************************************************************************************///
//****************************************************************************************************************///
//****************************************************************************************************************///
//****************************************************************************************************************///
//****************************************************************************************************************///


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//   continuely tuning levelingimage order to an image
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Conslevel(ctrlName) : ButtonControl
	String ctrlName
	Execute "Conslevel()"
End
Proc Conslevel()
	variable/G ss_consl = 0
	variable/G mode_consl = 1
	Dowindow/F $winname(0,1)
	string originalimage = "O_"+tpw()
	duplicate/o $tpw() $originalimage

	SetVariable setvar90 title="Order",size={100,20},value=ss_consl,proc=SetVarProc_Conslevelp
	//SetVariable setvar0 pos={70,1};
	SetVariable setvar90 limits={0,10,1}
	SetVariable setvar91 title="1D or 2D",size={80,20},value=mode_consl,proc=SetVarProc_Conslevelp,limits={1,2,1}
end
Function SetVarProc_Conslevelp(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	execute "Conslevelp()"
End
Proc Conslevelp()
	string originalimage = "O_"+tpw()
	$tpw() = $originalimage

	if (ss_consl == 0)
	else
		if (mode_consl == 1)
			levelimage2($tpw(),ss_consl)
		endif
		if (mode_consl == 2)
			levelimage2_2D($tpw(),ss_consl)
		endif
	endif
	//wavestats/Q $tpw()
	//print num2str(V_max)+" "+num2str(V_min)
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

Function levelimage2_2D(name,sel)
	wave name
	variable sel
	string destfit = "levelfit_"+nameofWave(name)

	duplicate/O name $destfit
	wave destfitw = $destfit
	CurveFit/Q/W=0 poly2D sel, name/D = destfitw
	//CurveFit/Q/M=0/W=0 Gauss2D, name/D = destfitw
	name -= destfitw
	killwaves destfitw
	//di(destfitw)
end

Function levelimage2(name,sel)
	wave name
	variable sel
	make/o/N=(dimsize(name,0)) figpara1D
	string namenew = nameofwave(name)+"_correct"
	duplicate/o name $namenew
	wave nameneww=$namenew
	nameneww = 0

	variable j
	j=0
	do
		figpara1D[] = name[p][j]
		duplicate/O figpara1D figpara1Dfit
		CurveFit/Q/W=0 Poly sel, figpara1D /D = figpara1Dfit
		figpara1D -= figpara1Dfit
		nameneww[][j] = figpara1D[p]

		j+=1
	while(j<dimsize(name,1))
	name = nameneww

	killwaves figpara1D figpara1Dfit nameneww
	//di(nameneww)
end

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
//   End of continuely tuning smooth to any graph
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////






//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$   Smart 2D matrix EMDC  $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
// Main Procedures
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Smart2DEMDC(ctrlName) : ButtonControl
	String ctrlName
	Execute "Smart2DEMDC()"
End
Proc Smart2DEMDC(name)
	string name = tpw()
	prompt name,"2D matrix name",popup getall2dwave()
	variable/G MDC_2dplot
	variable/G EDC_2dplot
	variable/G sel_L_2dplot =0

	//Initial plot
	display;appendimage $name
	modifygraph lsize=1
	ModifyGraph mirror=2
	ModifyGraph tick=2
	ModifyImage $nameofwave($name) ctab= {*,*,VioletOrangeYellow,0}
	ModifyGraph/W=$winname(0,1) width={Plan,1,bottom,left},height=300
	ModifyGraph/W=$winname(0,1) height=201
	ModifyGraph/W=$winname(0,1) margin(bottom)=144
	ModifyGraph/W=$winname(0,1) margin(right)=144
	ModifyGraph width=201


	//Basic EMDC mode
	getMDC_2dplot(MDC_2dplot)
	getEDC_2dplot(EDC_2dplot)
	string MDC = "MDC_"+tpw()
	string EDC = "EDC_"+tpw()

	Display/HOST=$winname(0,1)/W=(0.04,0.65,0.7,1)  $MDC
	string childgrapn = winname(0,1)+"#"+stringFromList(0,childWindowList(winname(0,1)))
	ModifyGraph/W=$childgrapn lsize=2,rgb=(0,0,65535)

	Display/HOST=$winname(0,1)/W=(0.62,0.01,1,0.695)/VERT  $EDC
	childgrapn = winname(0,1)+"#"+stringFromList(1,childWindowList(winname(0,1)))
	ModifyGraph/W=$childgrapn lsize=2
	SetActiveSubwindow ##

	string lm_2dplot="lm_2dplot_"+tpw()
	make/N=(2)/o $lm_2dplot
	$lm_2dplot = dimoffset($tpw(),1)+dimdelta($tpw(),1)*MDC_2dplot
	setscale/I x,dimoffset($tpw(),0),dimoffset($tpw(),0)+dimdelta($tpw(),0)*(dimsize($tpw(),0)-1),"",$lm_2dplot
	appendtograph/W=$winname(0,1) $lm_2dplot
	ModifyGraph/W=$winname(0,1) lsize($lm_2dplot)=2,rgb($lm_2dplot)=(0,0,65535)

	string le_2dplot="le_2dplot_"+tpw()
	make/N=(2)/o $le_2dplot
	$le_2dplot = dimoffset($tpw(),0)+dimdelta($tpw(),0)*EDC_2dplot
	setscale/I x,dimoffset($tpw(),1),dimoffset($tpw(),1)+dimdelta($tpw(),1)*(dimsize($tpw(),1)-1),"",$le_2dplot
	appendtograph/W=$winname(0,1)/VERT $le_2dplot
	ModifyGraph/W=$winname(0,1) lsize($le_2dplot)=2

	//** Control of Basic EMDC modes
	SetVariable setvarMDC_2dplot win=$winname(0,1), title="MDC",size={60,14},value=MDC_2dplot,proc=SetVarProc_SmartMDC_2dplot,limits={0,dimsize($tpw(),1)-1,1}
	SetVariable setvarEDC_2dplot win=$winname(0,1), title="EDC",size={60,14},value=EDC_2dplot,proc=SetVarProc_SmartEDC_2dplot,limits={0,dimsize($tpw(),0)-1,1}

	//** Control of Cycling color
	Button colorcycling win=$winname(0,1), title="CycleC",proc=ButtonProc_colorcycling,size={50,15},fSize=11

	//** Control of Plain color
	Button colorplain win=$winname(0,1), title="PlainC",proc=ButtonProc_colorplain,size={50,15},fSize=11

	//** Control of π-norm
	variable/G pinorm_2dplot = 0
	SetVariable pinorm win=$winname(0,1), title="π norm",size={60,14},value=pinorm_2dplot,proc=SetVarProc_pinorm_2dplot,limits={0,1,1}


	//** Control of Advanced Modes
	popupmenu popselectmode win=$winname(0,1), size={60,14},pos={280,245},proc=PopMenuProc_selmode2dplot,value="TwoPoint;FreeHand;Circular"
	Button Bfreehandprofile win=$winname(0,1), title="Go",proc=ButtonProc_L2dplotdo,size={30,18},fSize=11,pos={373,245}
	popupmenu Unipolarw1 win=$winname(0,1), size={60,14},pos={335,265},proc=PopMenuProc_L2dpolar,title="Polar",value="Off;On"

	//** Control of Jump remover
	variable/G removejump_2dp = 1
	variable/G removejumpmode_2dp = 2
	variable/G removejumpvalue_2dp = 2*pi
	variable/G givenjumpcriteria_2dp = pi

	popupmenu removejump win=$winname(0,1), size={60,14},pos={280,285},proc=PopMenuProc_jump2dp,title="Jump",value="Off;On"
	popupmenu removejumpmode win=$winname(0,1), pos={385,285},bodyWidth=51,size={30,14},proc=PopMenuProc_jump2dpmode,value="Auto;Given",mode=2
	SetDrawEnv fillfgc= (39321,39319,1),linethick= 0.00;DrawRect 1.06,1.44,1.71,1.62
	SetDrawEnv textrgb= (65535,65535,65535),fstyle= 1,fsize= 9;DrawText 1.083,1.575,"Given\rMode"

	SetVariable setvar_removejpv win=$winname(0,1),title="Given δ",pos={315,305},size={95,14},value=removejumpvalue_2dp,proc=SetVarProc_jumpmount_2dplot
	SetVariable setvar_removejpc win=$winname(0,1),title="Criteria",pos={315,322},size={95,14},value=givenjumpcriteria_2dp,proc=SetVarProc_jumpCriteria_2dplot

	tilewindows/WINS=winname(0,1)/R/w=(3,30,100,100)/A=(1,1)

		//** Launch Advanced EMDC
		//Cursor/W=$winname(0,1)/P/I/C=(1,65535,33232)/T=6 A $tpw() 0,0
		//Cursor/W=$winname(0,1)/P/I/C=(0,65535,65535)/T=6 B $tpw() round(dimsize($tpw(),0)/2),round(dimsize($tpw(),1)/2)
		//SetWindow $winname(0,1) hook(myHook)=myCursorMovedHook2Dfdn
	twopgetline() //initial graph
		Button turnoffls3d title="BACK",size={45,12},valueColor=(0,0,0),fColor=(1,65535,33232),pos={360,1},proc=ButtonProc_lsturnoff3d
	ckfig(winname(0,1))
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



//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//** Color Figure
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

Function ButtonProc_colorcycling(ctrlName) : ButtonControl
	String ctrlName
	ModifyGraph noLabel=2
	ModifyGraph axThick=0
	ModifyImage $tpw() ctab= {-pi,pi,RainbowCycle,0}
	ColorScale/C/N=text0/F=0/X=-30.00/Y=0.00 image=$tpw()
end

Function ButtonProc_colorplain(ctrlName) : ButtonControl
	String ctrlName
	ModifyGraph noLabel=0
	ModifyGraph axThick=1
	ModifyImage $tpw() ctab= {*,*,VioletOrangeYellow,0}
	ColorScale/K/N=text0
end

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//** Normalize Line cut by wave/=pi, wave-=wave[0]
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

Function SetVarProc_pinorm_2dplot(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G pinorm_2dplot
	variable/G sel_L_2dplot
	variable/G MDC_2dplot
	variable/G EDC_2dplot
	getMDC_2dplot(MDC_2dplot)
	getEDC_2dplot(EDC_2dplot)

		//Two point mode
		if (sel_L_2dplot == 1)
		twopgetline()
		endif

		//Free hand mode
		if (sel_L_2dplot == 2)
		makefreehandwave_2dplot()
		endif

		//Circular mode
		if (sel_L_2dplot == 3)
		Lineprofilefromcircle()
		endif
End
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//** Basic EMDC Mode
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

//#1 control MDC
Function SetVarProc_SmartMDC_2dplot(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G MDC_2dplot
	variable/G EDC_2dplot
	getMDC_2dplot(MDC_2dplot)
	recalindicativeline()
End

//#2 control EDC
Function SetVarProc_SmartEDC_2dplot(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G MDC_2dplot
	variable/G EDC_2dplot
	getEDC_2dplot(EDC_2dplot)
	recalindicativeline()
End

//#3 get MDC
Function getMDC_2dplot(index)
	variable index
	string MDC = "MDC_"+tpw()

	if (waveexists($MDC) == 1)
	else
		make/N=(dimsize($tpw(),0))/O $MDC
		setscale/P x, dimoffset($tpw(),0),dimdelta($tpw(),0),"",$MDC
	endif
	wave MDCw = $MDC
	wave matw = $tpw()
	MDCw[] = matw[p][index]

	//** jump remover or not
	variable/G removejump_2dp
	variable/G removejumpmode_2dp
	variable/G removejumpvalue_2dp
	variable/G givenjumpcriteria_2dp
	if (removejump_2dp == 2)
		autoremovejump1D(MDCw,removejumpmode_2dp,removejumpvalue_2dp,givenjumpcriteria_2dp)
	endif

	//** pi-norm
	variable/G pinorm_2dplot
	if(pinorm_2dplot == 1)
		MDCw/=pi
		variable shift = MDCw[0]
		MDCw-=shift
	endif
end

//#4 get EDC
Function getEDC_2dplot(index)
	variable index
	string EDC = "EDC_"+tpw()

	if (waveexists($EDC) == 1)
	else
		make/N=(dimsize($tpw(),1))/O $EDC
		setscale/P x, dimoffset($tpw(),1),dimdelta($tpw(),1),"",$EDC
	endif
	wave EDCw = $EDC
	wave matw = $tpw()
	EDCw[] = matw[index][p]

	//** jump remover or not
	variable/G removejump_2dp
	variable/G removejumpmode_2dp
	variable/G removejumpvalue_2dp
	variable/G givenjumpcriteria_2dp

	if (removejump_2dp == 2)
		autoremovejump1D(EDCw,removejumpmode_2dp,removejumpvalue_2dp,givenjumpcriteria_2dp)
	endif

	//** pi-norm
	variable/G pinorm_2dplot
	if(pinorm_2dplot == 1)
		EDCw/=pi
		variable shift = EDCw[0]
		EDCw-=shift
	endif
end

//#5 update indicative lines
Function recalindicativeline()
	variable/G MDC_2dplot
	variable/G EDC_2dplot

	string lm_2dplot="lm_2dplot_"+tpw()
	wave lm_2dplotw =$lm_2dplot
	lm_2dplotw = dimoffset($tpw(),1)+dimdelta($tpw(),1)*MDC_2dplot

	string le_2dplot="le_2dplot_"+tpw()
	wave le_2dplotw =$le_2dplot
	le_2dplotw = dimoffset($tpw(),0)+dimdelta($tpw(),0)*EDC_2dplot
end

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//** Advanced EMDC Mode
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

//#1 control of Advanced mode (select modes)
Function PopMenuProc_selmode2dplot(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	variable/G sel_L_2dplot
	sel_L_2dplot = popNum

	if (sel_L_2dplot == 1) //Two Points Mode
		Cursor/W=$winname(0,1)/P/I/C=(1,65535,33232)/T=6 A $tpw() 0,0
		Cursor/W=$winname(0,1)/P/I/C=(0,65535,65535)/T=6 B $tpw() round(dimsize($tpw(),0)/2),round(dimsize($tpw(),1)/2)
		SetWindow $winname(0,1) hook(myHook)=myCursorMovedHook2Dfdn
		twopgetline() //initial graph
	endif

	if (sel_L_2dplot == 2) //Free Hand Mode
		Cursor/W=$winname(0,1)/P/I/C=(1,65535,33232)/T=6 A $tpw() 0,0
		SetWindow $winname(0,1) hook(myHook)=myCursorMovedHook2Dfreehand
		makefreehandwave_2dplot()
		//** Error message, no stop but Continuing execution
		String msg
		Variable err
		msg=GetErrMessage(GetRTError(0),3);
		err=GetRTError(1)
		if (err != 0)
			//Print "Error in Demo: " + msg
			//Print "Continuing execution"
		endif
	endif

	if (sel_L_2dplot == 3) //Circle Mode
		Cursor/W=$winname(0,1)/P/I/C=(1,65535,33232)/T=6 A $tpw() 0,round(dimsize($tpw(),1)/2)
		Cursor/W=$winname(0,1)/P/I/C=(0,65535,65535)/T=6 B $tpw() round(dimsize($tpw(),0)/2),round(dimsize($tpw(),1)/2)
		SetWindow $winname(0,1) hook(myHook)=myCursorMovedHook2Dcc
		Lineprofilefromcircle()
	endif

end

//#2 Update freehand modes
Function ButtonProc_L2dplotdo(ctrlName) : ButtonControl
	String ctrlName
	Variable/G sel_L_2dplot

	makefreehandwave_2dplot()
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

////////////////////////////////////////////////////////////////////
//#3** (1): Two Points Method

//#3_01 Cursor Hook
Function myCursorMovedHook2Dfdn(s)
	STRUCT WMWinHookStruct &s
	Variable statusCode= 0
	strswitch( s.eventName )
		case "cursormoved":
			twopgetline()
			break
	endswitch
	return statusCode
End

//#3_02 Hook Called: Extract Line profile from two points
//		{Note: this function will be called every time cursor moves}
Function twopgetline()
	variable xd = abs(pcsr(A)-pcsr(B))
	variable yd = abs(qcsr(A)-qcsr(B))
	if (xd > yd)
		twopgetlinex()
	else
		twopgetliney()
	endif
end

Function twopgetlinex()
	variable k,b
	// define the line parameters
	k = (qcsr(A)-qcsr(B))/(pcsr(A)-pcsr(B))
	b = qcsr(A) - k*pcsr(A)

	variable/G pinorm_2dplot
	wave tpww = $tpw()
	string ZoutI = "ZoutI_"+tpw()
	make/N = (abs(pcsr(B)-pcsr(A))+1)/o $ZoutI
	wave ZoutIw = $ZoutI

	variable i , yy, signw,signwq
	signw = pcsr(A) - pcsr(B)
	signwq=qcsr(A) - qcsr(B)
	variable xx1 = dimoffset(tpww,0)+dimdelta(tpww,0)*pcsr(A)
	variable xx2 = dimoffset(tpww,0)+dimdelta(tpww,0)*pcsr(B)
	variable yy1 = dimoffset(tpww,1)+dimdelta(tpww,1)*qcsr(A)
	variable yy2 = dimoffset(tpww,1)+dimdelta(tpww,1)*qcsr(B)
	variable len = sqrt((xx1-xx2)^2+(yy1-yy2)^2)

	//Make Z wave follow the two-point line
	i = pcsr(A)
	if (signw < 0)
		do
			yy = round(k*i+b)
			ZoutIw[i-pcsr(A)] = tpww[i][yy]
			i+=1
		while(i< pcsr(B)+1)
	endif

	variable j =pcsr(A)
	if (signw > 0)
		do
			yy = round(k*i+b)
			ZoutIw[j-pcsr(A)] = tpww[i][yy]
			j+=1
			i-=1
		while(i > pcsr(B)-1)
	endif

	if (signw == 0)
		i = qcsr(A)
		if (signwq < 0)
		do
			yy = round((i-b)/k)
			ZoutIw[i-qcsr(A)] = tpww[yy][i]
			i+=1
		while(i< qcsr(B)+1)
		endif

		j =qcsr(A)
		if (signwq > 0)
		do
			yy = round((i-b)/k)
			ZoutIw[j-qcsr(A)] = tpww[yy][i]
			j+=1
			i-=1
		while(i > qcsr(B)-1)
		endif
	endif
	setscale/I x,0,len, "",ZoutIw

	//** jump remover or not
	variable/G removejump_2dp
	variable/G removejumpmode_2dp
	variable/G removejumpvalue_2dp
	variable/G givenjumpcriteria_2dp

	if (removejump_2dp == 2)
		autoremovejump1D(ZoutIw,removejumpmode_2dp,removejumpvalue_2dp,givenjumpcriteria_2dp)
	endif


	//Make the X&Y wave for indication
	string xwaveout = "Xout_"+tpw()
	string ywaveout = "Yout_"+tpw()
	make/N=2/O $ywaveout
	make/N=2/O $Xwaveout
	wave xwaveoutw = $xwaveout
	wave ywaveoutw = $ywaveout
	ywaveoutw[0]=yy1
	ywaveoutw[1]=yy2
	xwaveoutw={xx1,xx2}

	//Append indicative Ywave vs Xwave if it is not on graph
	checkDisplayed ywaveoutw
	if(V_flag == 0)
		appendtograph ywaveoutw vs Xwaveoutw
		ModifyGraph/W=$winname(0,1) lsize($ywaveout)=1,rgb($ywaveout)=(3690,43690,43690),mode($ywaveout)=4	,lstyle($ywaveout)=7, mrkThick($ywaveout)=2,useMrkStrokeRGB($ywaveout)=1,mrkStrokeRGB($ywaveout)=(1,52428,26586),msize($ywaveout)=1
	else
	endif

	//Display Scaled Zwave if it is not displayed
	if(cmpstr(grabwinnonew(ZoutI),"") == 0)
		display ZoutIw
		ModifyGraph/W=$winname(0,1) lsize($ZoutI)=1,rgb($ZoutI)=(3690,43690,43690),mode($ZoutI)=4,lstyle($ZoutI)=7, mrkThick($ZoutI)=2,useMrkStrokeRGB($ZoutI)=1,mrkStrokeRGB($ZoutI)=(1,52428,26586)

		//Dowindow/F $winname(1,1)
		//string tw = winname(0,1)+";"+winname(1,1)+";"
		//tilewindows/WINS=tw/R/A=(1,2)/w=(3,0,58,20)
		//tilewindows/WINS=WinList("*", ";","WIN:1")/R/A=(1,2)/w=(3,0,58,20)	//Tilewindow
		//tilewindows/WINS=grabtablenonew(ZoutI)/R/A=(1,2)/w=(30,0,58,20)

	else
	endif

	if(cmpstr(grabwinnonew(ZoutI),"") == 1)
		if(pinorm_2dplot == 1)
			Label/W=$grabwinnonew(ZoutI) left "\\Z16 θ (π)"
		endif
		if(pinorm_2dplot == 0)
			Label/W=$grabwinnonew(ZoutI) left ""
		endif
	endif

	//Initial the Polar plot, this is incorrect formula for this mode, the current formula is only good for circular mode
	variable/G polar_L_2dplot
	if (polar_L_2dplot == 2)
		Dopolarfig_nondis(ZoutI,"_calculated_",2)
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

	//** pi-norm
	if(pinorm_2dplot == 1)
		ZoutIw/=pi
		//variable shift=ZoutIw[0]
		wavestats/Q ZoutIw
		ZoutIw-=V_min
	endif
end
Function twopgetliney()
	variable k,b
	// define the line parameters
	k = (pcsr(A)-pcsr(B))/(qcsr(A)-qcsr(B))
	b = pcsr(A) - k*qcsr(A)

	variable/G pinorm_2dplot
	wave tpww = $tpw()
	string ZoutI = "ZoutI_"+tpw()
	make/N = (abs(qcsr(B)-qcsr(A))+1)/o $ZoutI
	wave ZoutIw = $ZoutI

	variable i , yy, signw,signwq
	signw = qcsr(A) - qcsr(B)
	signwq=pcsr(A) - pcsr(B)
	variable xx1 = dimoffset(tpww,1)+dimdelta(tpww,1)*qcsr(A)
	variable xx2 = dimoffset(tpww,1)+dimdelta(tpww,1)*qcsr(B)
	variable yy1 = dimoffset(tpww,0)+dimdelta(tpww,0)*pcsr(A)
	variable yy2 = dimoffset(tpww,0)+dimdelta(tpww,0)*pcsr(B)
	variable len = sqrt((xx1-xx2)^2+(yy1-yy2)^2)

	//Make Z wave follow the two-point line
	i = qcsr(A)
	if (signw < 0)
		do
			yy = round(k*i+b)
			ZoutIw[i-qcsr(A)] = tpww[yy][i]
			i+=1
		while(i< qcsr(B)+1)
	endif

	variable j =qcsr(A)
	if (signw > 0)
		do
			yy = round(k*i+b)
			ZoutIw[j-qcsr(A)] = tpww[yy][i]
			j+=1
			i-=1
		while(i > qcsr(B)-1)
	endif

	if (signw == 0)
		i = pcsr(A)
		if (signwq < 0)
		do
			yy = round((i-b)/k)
			ZoutIw[i-pcsr(A)] = tpww[i][yy]
			i+=1
		while(i< pcsr(B)+1)
		endif

		j =pcsr(A)
		if (signwq > 0)
		do
			yy = round((i-b)/k)
			ZoutIw[j-pcsr(A)] = tpww[i][yy]
			j+=1
			i-=1
		while(i > pcsr(B)-1)
		endif
	endif
	setscale/I x,0,len, "",ZoutIw

	//** jump remover or not
	variable/G removejump_2dp
	variable/G removejumpmode_2dp
	variable/G removejumpvalue_2dp
	variable/G givenjumpcriteria_2dp
	if (removejump_2dp == 2)
		autoremovejump1D(ZoutIw,removejumpmode_2dp,removejumpvalue_2dp,givenjumpcriteria_2dp)
	endif


	//Make the X&Y wave for indication
	string xwaveout = "Xout_"+tpw()
	string ywaveout = "Yout_"+tpw()
	make/N=2/O $ywaveout
	make/N=2/O $Xwaveout
	wave xwaveoutw = $xwaveout
	wave ywaveoutw = $ywaveout
	ywaveoutw[0]=xx1
	ywaveoutw[1]=xx2
	xwaveoutw={yy1,yy2}

	//Append indicative Ywave vs Xwave if it is not on graph
	checkDisplayed ywaveoutw
	if(V_flag == 0)
		appendtograph ywaveoutw vs Xwaveoutw
		ModifyGraph/W=$winname(0,1) lsize($ywaveout)=1,rgb($ywaveout)=(3690,43690,43690),mode($ywaveout)=4	,lstyle($ywaveout)=7, mrkThick($ywaveout)=2,useMrkStrokeRGB($ywaveout)=1,mrkStrokeRGB($ywaveout)=(1,52428,26586),msize($ywaveout)=1
	else
	endif

	//Display Scaled Zwave if it is not displayed
	if(cmpstr(grabwinnonew(ZoutI),"") == 0)
		display ZoutIw
		ModifyGraph/W=$winname(0,1) lsize($ZoutI)=1,rgb($ZoutI)=(3690,43690,43690),mode($ZoutI)=4,lstyle($ZoutI)=7, mrkThick($ZoutI)=2,useMrkStrokeRGB($ZoutI)=1,mrkStrokeRGB($ZoutI)=(1,52428,26586)

		//Dowindow/F $winname(1,1)
		//tilewindows/WINS=WinList("*", ";","WIN:1")/R/A=(1,2)/w=(3,0,58,20)	//Tilewindow
		//tilewindows/WINS=grabtablenonew(ZoutI)/R/A=(1,2)/w=(30,0,58,20)

	else
	endif

	if(cmpstr(grabwinnonew(ZoutI),"") == 1)
		if(pinorm_2dplot == 1)
			Label/W=$grabwinnonew(ZoutI) left "\\Z16 θ (π)"
		endif
		if(pinorm_2dplot == 0)
			Label/W=$grabwinnonew(ZoutI) left ""
		endif
	endif

	//Initial the Polar plot, this is incorrect formula for this mode, the current formula is only good for circular mode
	variable/G polar_L_2dplot
	if (polar_L_2dplot == 2)
		Dopolarfig_nondis(ZoutI,"_calculated_",2)
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

	//** pi-norm
	if(pinorm_2dplot == 1)
		ZoutIw/=pi
		wavestats/Q ZoutIw
		ZoutIw-=V_min
	endif
end
////////////////////////////////////////////////////////////////////
//#3** (2): Free hand Mode

//#3_03 Cursor Hook
Function myCursorMovedHook2Dfreehand(s)
	STRUCT WMWinHookStruct &s
	Variable statusCode= 0
	strswitch( s.eventName )
		case "cursormoved":
			// see "Members of WMWinHookStruct Used with cursormoved Code"
			//UpdateControls_2df(s.traceName, s.cursorName, s.pointNumber, s.yPointNumber)
			UpdateControls_2df(s.traceName, s.cursorName, s.pointNumber, s.yPointNumber)

			break
	endswitch
	return statusCode
End

//#3_04 Extract line profile by free hand draw
//		{Note: this function will be called every time cursor moves}
Function UpdateControls_2df(traceName, cursorName, pointNumber, yPointNumber)
	String traceName, cursorName
	Variable pointNumber,yPointNumber

	//pointNumber = pcsr(A)
	//ypointNumber = qcsr(A)

	//**Initialize indicative X&Y wave and [temporary profile Z wave]
	string xwaveout = "Xout_"+tpw()
	string ywaveout = "Yout_"+tpw()
	string zwave = "Zwave_"+tpw()
	if (waveexists($xwaveout) == 1)
	else
		make/n=(0)/o $xwaveout
		wave xwaveoutw = $xwaveout
	endif
	if (waveexists($ywaveout) == 1)
	else
		make/n=(0)/o $ywaveout
		wave ywaveoutw = $ywaveout
	endif
	if (waveexists($zwave) == 1)
	else
		make/n=(0)/o $zwave
		wave zwavew = $zwave
	endif

	wave zwavew = $zwave
	wave xwaveoutw = $xwaveout
	wave ywaveoutw = $ywaveout
	wave tpww = $tpw()

	InsertPoints dimsize(xwaveoutw,0),1, xwaveoutw
	xwaveoutw[dimsize(xwaveoutw,0)-1]= dimoffset(tpww,0)+dimdelta(tpww,0)*pointNumber

	InsertPoints dimsize(ywaveoutw,0),1, ywaveoutw
	ywaveoutw[dimsize(ywaveoutw,0)-1]= dimoffset(tpww,1)+dimdelta(tpww,1)*ypointNumber

	InsertPoints dimsize(zwavew,0),1, zwavew
	zwavew[dimsize(zwavew,0)-1]= tpww[pointNumber][ypointNumber]


	//**Checking auxiliary indicative wave defined in the "Go function" below
	string xwaveout2 = "Xout2_"+tpw()
	string ywaveout2 = "Yout2_"+tpw()
	checkDisplayed $ywaveout2
	if(V_flag == 0)
	else
		RemoveFromGraph $ywaveout2
	endif
		//## {Note} X&Ywave2 are introduced for defining the start curor hood of a new free hand draw
		//## {Note} See details in the Go function.

	//**Append Indicative X&Y wave if it is not on the graph
	checkDisplayed ywaveoutw
	if(V_flag == 0)
		appendtograph ywaveoutw vs Xwaveoutw
		ModifyGraph/W=$winname(0,1) lsize($ywaveout)=1,rgb($ywaveout)=(3690,43690,43690),mode($ywaveout)=4	,lstyle($ywaveout)=7, mrkThick($ywaveout)=2,useMrkStrokeRGB($ywaveout)=1,mrkStrokeRGB($ywaveout)=(1,52428,26586),msize($ywaveout)=1
	else
	endif
End

//#3_05 GO Function
//		{Note: this function Define the end of the free hand draw and set the next cursor hook call belong to new lineprofile}
Function makefreehandwave_2dplot()
	//** Create scattered Z wave from temporary Z wave]
	string zwave = "Zwave_"+tpw()
	wave zwavew = $zwave
	wave tpww = $tpw()
	string zwaveout = "Zout_"+tpw()
	string xwaveout = "Xout_"+tpw()
	string ywaveout = "Yout_"+tpw()
	wave xwaveoutw = $xwaveout
	wave ywaveoutw = $ywaveout
	duplicate/O zwavew $zwaveout
	wave zwaveoutw = $zwaveout
	killwaves zwavew
	variable/G pinorm_2dplot

	//** Calculate the trajectory distance of the free-hand-draw trace
	string trajdis = "trajdis_"+tpw()
	make/N=(dimsize($zwaveout,0))/o $trajdis
	wave trajdisw = $trajdis
	trajdisw[0] = 0

	//**calculate trajectory distance
		variable i,delta
		i = 1
		do
			delta = sqrt((xwaveoutw[i]-xwaveoutw[i-1])^2+(ywaveoutw[i]-ywaveoutw[i-1])^2)
			trajdisw[i] = delta+trajdisw[i-1]
			i+=1
		while (i< dimsize($zwaveout,0))

	//** jump remover or not
		variable/G removejump_2dp
		variable/G removejumpmode_2dp
		variable/G removejumpvalue_2dp
		variable/G givenjumpcriteria_2dp

		if (removejump_2dp == 2)
		autoremovejump1D(zwaveoutw,removejumpmode_2dp,removejumpvalue_2dp,givenjumpcriteria_2dp)
		endif

	//**From scattered Z wave and trajectory wave to make waveform Z wave
	string ZoutI = "ZoutI_"+tpw()
	wave ZoutIw = $ZoutI
	Interpolate2/T=1/N=(2*dimsize(Xwaveoutw,0))/E=2/Y=$ZoutI trajdisw, zwaveoutw


	//**Create auxiliary indicative X&Ywave2
	string xwaveout2 = "Xout2_"+tpw()
	string ywaveout2 = "Yout2_"+tpw()
	duplicate/o xwaveoutw $xwaveout2
	duplicate/o ywaveoutw $ywaveout2
	wave xwaveout2w = $xwaveout2
	wave ywaveout2w = $ywaveout2
		//** {Note} In order to define new start of the indicative X&Ywave for a free hand drawing, it is important to
		//** {Note} set X&Y wave dimsize to be zero at this Go function, so that it cause a problem that after click the
		//** {Note} "Go" button, the current free hand draw is generated but the indicative lines disappear. In order to
		//** {Note} solve this problem, we introduced this auxiliary X&Ywave2 that before set the dimsize of XYwave to zero
		//** {Note} we transfer the information to the auxiliarys, remove the X&Ywave and append the X&Ywave2 with same format
		//** {Note} These auxiliarys will be remove and X&Ywave will be appended again when Cursor Hook runs in the next free hand draw.

	//**Remove indicative X&Ywave preparing for redefine the new start.
	RemoveFromGraph $ywaveout

	//**Append auxiliary indicative X&Ywave2
	checkDisplayed ywaveout2w
	if(V_flag == 0)
		appendtograph ywaveout2w vs Xwaveout2w
		ModifyGraph/W=$winname(0,1) lsize($ywaveout2)=1,rgb($ywaveout2)=(3690,43690,43690),mode($ywaveout2)=4,lstyle($ywaveout2)=7, mrkThick($ywaveout2)=2,useMrkStrokeRGB($ywaveout2)=1,mrkStrokeRGB($ywaveout2)=(1,52428,26586),msize($ywaveout2)=1
	else
	endif

	//**Display waveform Z wave
	if(cmpstr(grabwinnonew(ZoutI),"") == 0)
		display ZoutIw
		ModifyGraph/W=$winname(0,1) lsize($ZoutI)=1,rgb($ZoutI)=(3690,43690,43690),mode($ZoutI)=4,lstyle($ZoutI)=7, mrkThick($ZoutI)=2,useMrkStrokeRGB($ZoutI)=1,mrkStrokeRGB($ZoutI)=(1,52428,26586)

		//Dowindow/F $winname(1,1)
		//tilewindows/WINS=WinList("*", ";","WIN:1")/R/A=(1,2)/w=(3,0,58,20)
		//tilewindows/WINS=grabtablenonew(ZoutI)/R/A=(1,2)/w=(30,0,58,20)

	else
	endif

	if(cmpstr(grabwinnonew(ZoutI),"") == 1)
		if(pinorm_2dplot == 1)
			Label/W=$grabwinnonew(ZoutI) left "\\Z16 θ (π)"
		endif
		if(pinorm_2dplot == 0)
			Label/W=$grabwinnonew(ZoutI) left ""
		endif
	endif

	//Initial the Polar plot, this is incorrect formula for this mode, the current formula is only good for circular mode
	variable/G polar_L_2dplot
	if (polar_L_2dplot == 2)
		Dopolarfig_nondis(ZoutI,"_calculated_",2)
	endif

	//**Reinitial the X&Ywave for the next free hand drawing
	deletePoints 0,dimsize($xwaveout,0), xwaveoutw
	deletePoints 0,dimsize($ywaveout,0), ywaveoutw

	//** pi-norm
	if(pinorm_2dplot == 1)
		ZoutIw/=pi
		wavestats/Q ZoutIw
		ZoutIw-=V_min
	endif
end


////////////////////////////////////////////////////////////////////
//#3** (3): Circular Mode

//#3_06 Cursor Hook
Function myCursorMovedHook2Dcc(s)
	STRUCT WMWinHookStruct &s
	Variable statusCode= 0
	strswitch( s.eventName )
		case "cursormoved":
			Lineprofilefromcircle()
			break
	endswitch
	return statusCode
End

//#3_07 Extract line profile by Circular Mode
//		{Note: this function will be called every time cursor moves}
Function Lineprofilefromcircle()
	//**Define the Origin
	variable Ox = pcsr(B)
	variable Oy = qcsr(B)

	//**Define the radium
	variable ax = pcsr(A)
	variable ay = qcsr(A)
	variable rr = round(sqrt((ox-ax)^2+(oy-ay)^2))

	//**Define the circular trace
	variable xx, yy
		//(xx-ox)^2+(yy-oy)^2 = rr^2
		//yy = +-sqrt(rr^2 - (xx-ox)^2)+oy

	//**Define the  leftP (polar pi) and rightP (Polar 0)
	variable leftP,rightP
	leftP = round(ox - rr)
	rightP = round(ox +rr)

	variable/G pinorm_2dplot

	//**Create Z wave
	string ZoutI = "ZoutI_"+tpw()
	variable num = abs(rightP-leftP)+1+(abs(rightP-leftP)+1-1)
	make/N=(num)/o $ZoutI
	wave ZoutIw =$ZoutI
	setscale/I x 0,2*pi,"",ZoutIw
	ZoutIw=nan

	//**Create Indicative X&Y wave
	string xwaveout = "Xout_"+tpw()
	string ywaveout = "Yout_"+tpw()
	make/N=(num)/O $ywaveout
	make/N=(num)/O $Xwaveout
	wave xwaveoutw = $xwaveout
	wave ywaveoutw = $ywaveout

	//**Build Z wave and X&Ywave [Upper half circle (counter-clockwise)]
	wave tpww = $tpw()
	variable i, qq,j
	i=rightp
	j=0
	do
		xx = i
		yy = sqrt(rr^2 - (xx-ox)^2)+oy
		qq = round(yy)
		if (qq >=0 && qq <dimsize($tpw(),1))
			if(i>=0 && i <dimsize($tpw(),0))
				ZoutIw[j] = tpww[i][qq]
			else
			endif
		else
			//ZoutIw[j] = nan
		endif
		xwaveoutw[j] = dimoffset($tpw(),0)+xx*dimdelta($tpw(),0)
		ywaveoutw[j] = dimoffset($tpw(),1)+qq*dimdelta($tpw(),1)
		j+=1
		i-=1
	while (i > leftp-1)

	//**[Continuing] Build Z wave and X&Ywave [Lower half circle (counter-clockwise)]
	j=0
	i=leftp+1
	do
		xx = i
		yy = -sqrt(rr^2 - (xx-ox)^2)+oy
		qq = round(yy)
		if (qq >=0 && qq <dimsize($tpw(),1))
			if(i>=0 && i <dimsize($tpw(),0))
				ZoutIw[abs(rightP-leftP)+1+j] = tpww[i][qq]
			else
			endif
		else
			//ZoutIw[abs(rightP-leftP)+1+j] = nan
		endif
		xwaveoutw[abs(rightP-leftP)+1+j] = dimoffset($tpw(),0)+xx*dimdelta($tpw(),0)
		ywaveoutw[abs(rightP-leftP)+1+j] = dimoffset($tpw(),1)+qq*dimdelta($tpw(),1)
		j+=1
		i+=1
	while (i < rightp+1)
	ZoutIw[dimsize(ZoutIw,0)-1] = ZoutIw[0]

	//** jump remover or not
	variable/G removejump_2dp
	variable/G removejumpmode_2dp
	variable/G removejumpvalue_2dp
	variable/G givenjumpcriteria_2dp

	if (removejump_2dp == 2)
		autoremovejump1D(ZoutIw,removejumpmode_2dp,removejumpvalue_2dp,givenjumpcriteria_2dp)
	endif

	//**Append Indicative X&Ywaves
	checkDisplayed ywaveoutw
	if(V_flag == 0)
		appendtograph ywaveoutw vs Xwaveoutw
		ModifyGraph/W=$winname(0,1) lsize($ywaveout)=1,rgb($ywaveout)=(3690,43690,43690),mode($ywaveout)=4	,lstyle($ywaveout)=7, mrkThick($ywaveout)=2,useMrkStrokeRGB($ywaveout)=1,mrkStrokeRGB($ywaveout)=(1,52428,26586),msize($ywaveout)=1
	else
	endif

	//**Append Zwaves
	if(cmpstr(grabwinnonew(ZoutI),"") == 0)
		display ZoutIw
		ModifyGraph/W=$winname(0,1) lsize($ZoutI)=1,rgb($ZoutI)=(3690,43690,43690),mode($ZoutI)=4,lstyle($ZoutI)=7, mrkThick($ZoutI)=2,useMrkStrokeRGB($ZoutI)=1,mrkStrokeRGB($ZoutI)=(1,52428,26586)

		//Dowindow/F $winname(1,1)
		//tilewindows/WINS=WinList("*", ";","WIN:1")/R/A=(1,2)/w=(3,0,58,20)
		//tilewindows/WINS=grabtablenonew(ZoutI)/R/A=(1,2)/w=(30,0,58,20)

	else
	endif

	if(cmpstr(grabwinnonew(ZoutI),"") == 1)
		if(pinorm_2dplot == 1)
			Label/W=$grabwinnonew(ZoutI) left "\\Z16 θ (π)"
		endif
		if(pinorm_2dplot == 0)
			Label/W=$grabwinnonew(ZoutI) left ""
		endif
	endif

	//**Do Polar plot the r = sin(2*tpw()[])
	variable/G polar_L_2dplot
	if (polar_L_2dplot == 2)
		Dopolarfig_nondis(ZoutI,"_calculated_",2)
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

	//** pi-norm
	if(pinorm_2dplot == 1)
		ZoutIw/=pi
		wavestats/Q ZoutIw
		ZoutIw-=V_min
	endif
end





//#3_08 Polar plot
Function PopMenuProc_L2dpolar(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	variable/G polar_L_2dplot
	polar_L_2dplot = popNum

	string ZoutI = "ZoutI_"+tpw()
	string yy = "yy_"+ZoutI
	string xx = "xx_"+ZoutI


	if (polar_L_2dplot == 2)
		Dopolarfig(ZoutI,"_calculated_",2)
	endif

	if (polar_L_2dplot == 1)
		killwindow $grabwinnonew("sty_w1")
		killwindow $grabwinnonew(yy)
		killwindow $grabwinnonew(xx)
		killwindow $grabwinnonew("stx_w1")
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
end
Function Dopolarfig(datay,datax,sel)
	string datay
	string datax
	variable sel

	string datax1
	wave datayw = $datay
	if (cmpstr(datax,"_calculated_") == 0)
		datax = "x_"+datay
		duplicate/o datayw $datax
		wave dataxw = $datax
		dataxw[]=dimoffset(datayw,0)+p*dimdelta(datayw,0)
	else
		datax1 = "x_"+datay
		duplicate/o $datax $datax1
		wave dataxw = $datax1
	endif

	string xx, yy
	xx = "xx_"+datay
	yy = "yy_"+datay
	duplicate/o $datax $xx
	duplicate/o $datax $yy
	wave xxw = $xx
	wave yyw = $yy

	if (sel == 1) //Quantity is the amplitude
		xxw[] = datayw[p]*cos(dataxw[p])
		yyw[] = datayw[p]*sin(dataxw[p])
	endif

	string RR, theta,stand
	stand = "standWinding_1"
	if (sel == 2) //Quantity is phase with winding number = 1
		RR = "RR_"+datay
		theta = "theta_"+datay
		duplicate/o $datax $RR
		duplicate/o $datax $theta
		wave RRw = $RR
		wave thetaw = $theta
		RRw[] = sin(2*datayw[p]) //define the R --> coverted to winding number = 2
		thetaw[] = dataxw[p]

		xxw[] = RRw[p]*cos(thetaw[p])
		yyw[] = RRw[p]*sin(thetaw[p])


		string W_coef = "W_coef"
		Make/D/N=1/O $W_coef
		wave W_coefw =$W_coef
		W_coefw[0] = {0}
		FuncFit/Q wind1uniformity $W_coef RRw /D
		duplicate/o $datax $stand
		wave standw =$stand


		standw=sin(2*(W_coefw[0]+x))
		//standw=sin(2*(datayw[0]+sign(datayw[1]-datayw[0])*x))
		//display standw
		string sty = "sty_w1"
		duplicate/o $datax $sty
		wave styw =$sty
		styw[] = standw[p]*sin(thetaw[p])
		string stx = "stx_w1"
		duplicate/o $datax $stx
		wave stxw =$stx
		stxw[] = standw[p]*cos(thetaw[p])

		killwaves RRw, thetaw,standw
	endif

	//print yy
	//print cmpstr(grabwinnonew(yy),"")
	//print grabwinnonew(yy)
		display yyw vs xxw
		ModifyGraph/W=$winname(0,1) lsize($yy)=1,rgb($yy)=(3690,43690,43690),mode($yy)=4,lstyle($yy)=7, mrkThick($yy)=2,useMrkStrokeRGB($yy)=1,mrkStrokeRGB($yy)=(1,52428,26586)
		TextBox/C/N=text0/F=0/A=LT "r = sin(2*tpw()[p])"
		ModifyGraph/W=$winname(0,1) width={Plan,1,bottom,left}
		appendtograph/W=$winname(0,1) styw vs stxw
		ckfig(winname(0,1))
		tilewindows/WINS=winname(0,1)/R/w=(31,24,100,43)/A=(1,1)

		Dowindow/F $winname(1,1)

end


Function Dopolarfig_nondis(datay,datax,sel)
	string datay
	string datax
	variable sel

	string datax1
	wave datayw = $datay
	if (cmpstr(datax,"_calculated_") == 0)
		datax = "x_"+datay
		duplicate/o datayw $datax
		wave dataxw = $datax
		dataxw[]=dimoffset(datayw,0)+p*dimdelta(datayw,0)
	else
		datax1 = "x_"+datay
		duplicate/o $datax $datax1
		wave dataxw = $datax1
	endif

	string xx, yy
	xx = "xx_"+datay
	yy = "yy_"+datay
	duplicate/o $datax $xx
	duplicate/o $datax $yy
	wave xxw = $xx
	wave yyw = $yy

	if (sel == 1) //Quantity is the amplitude
		xxw[] = datayw[p]*cos(dataxw[p])
		yyw[] = datayw[p]*sin(dataxw[p])
	endif

	string RR, theta,stand
	stand = "standWinding_1"
	if (sel == 2) //Quantity is phase with winding number = 1
		RR = "RR_"+datay
		theta = "theta_"+datay
		duplicate/o $datax $RR
		duplicate/o $datax $theta
		wave RRw = $RR
		wave thetaw = $theta
		RRw[] = sin(2*datayw[p]) //define the R --> coverted to winding number = 2
		thetaw[] = dataxw[p]

		xxw[] = RRw[p]*cos(thetaw[p])
		yyw[] = RRw[p]*sin(thetaw[p])


		string W_coef = "W_coef"
		Make/D/N=1/O $W_coef
		wave W_coefw =$W_coef
		W_coefw[0] = {0}
		FuncFit/Q wind1uniformity $W_coef RRw /D
		duplicate/o $datax $stand
		wave standw =$stand


		standw=sin(2*(W_coefw[0]+x))
		//standw=sin(2*(datayw[0]+sign(datayw[1]-datayw[0])*x))
		//display standw
		string sty = "sty_w1"
		duplicate/o $datax $sty
		wave styw =$sty
		styw[] = standw[p]*sin(thetaw[p])
		string stx = "stx_w1"
		duplicate/o $datax $stx
		wave stxw =$stx
		stxw[] = standw[p]*cos(thetaw[p])

		killwaves RRw, thetaw,standw
	endif


end

//#3_09 Fit Function for perfect Winding number 1 Polar plot
Function wind1uniformity(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = sin(2*(a0+x))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 1
	//CurveFitDialog/ w[0] = a0

	return sin(2*(w[0]+x))
End

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//** 1D Jump remover
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//[1]Auto mode is suitable for some arbitary jump at a data, if auto mode can not remove the jump, you
//## should go to code and change the criteria for auto mode.
//****************************************************************************************************
//[2]Given mode is suitable for some the jump is physics meanigful, we know exactly how much is should
//## jump, then put the given delta that value, some put some value to criteria to judge if there is a
//## jump happen, usually we put it as half of the delta.
//////////////////////////////////////////////////////////////////////////////////////////////////////

//#0_1 Jump Remove: Given Mode_control jump delta
Function SetVarProc_jumpmount_2dplot(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G removejumpmode_2dp
	variable/G removejumpvalue_2dp = varNum
	variable/G pinorm_2dplot
	variable/G sel_L_2dplot
	variable/G MDC_2dplot
	variable/G EDC_2dplot

	if (removejumpmode_2dp == 1)
	else
		getMDC_2dplot(MDC_2dplot)
		getEDC_2dplot(EDC_2dplot)

			//Two point mode
			if (sel_L_2dplot == 1)
			twopgetline()
			endif

			//Free hand mode
			if (sel_L_2dplot == 2)
			makefreehandwave_2dplot()
			endif

			//Circular mode
			if (sel_L_2dplot == 3)
			Lineprofilefromcircle()
			endif
	endif
End

//#0_2 Jump Remove: Given Mode_control jump criteria
Function SetVarProc_jumpCriteria_2dplot(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	variable/G removejumpmode_2dp
	variable/G givenjumpcriteria_2dp = varNum

	variable/G pinorm_2dplot
	variable/G sel_L_2dplot
	variable/G MDC_2dplot
	variable/G EDC_2dplot

	if (removejumpmode_2dp == 1)
	else
		getMDC_2dplot(MDC_2dplot)
		getEDC_2dplot(EDC_2dplot)

		//Two point mode
		if (sel_L_2dplot == 1)
		twopgetline()
		endif

		//Free hand mode
		if (sel_L_2dplot == 2)
		makefreehandwave_2dplot()
		endif

		//Circular mode
		if (sel_L_2dplot == 3)
		Lineprofilefromcircle()
		endif
	endif
End


//#1 Control of On/OFF of the remover
Function PopMenuProc_jump2dp(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	variable/G removejump_2dp
	variable/G removejumpmode_2dp
	variable/G removejumpvalue_2dp
	removejump_2dp = popNum

	variable/G MDC_2dplot
	variable/G EDC_2dplot
	variable/G sel_L_2dplot


	if (removejump_2dp == 2)
		//Basic EMDC
		getMDC_2dplot(MDC_2dplot)
		getEDC_2dplot(EDC_2dplot)

		//Two point mode
		if (sel_L_2dplot == 1)
		twopgetline()
		endif

		//Free hand mode
		if (sel_L_2dplot == 2)
		makefreehandwave_2dplot()
		endif

		//Circular mode
		if (sel_L_2dplot == 3)
		Lineprofilefromcircle()
		endif
	endif

	string ZoutI, raw2pm,ZoutI2, trajdis

	if (removejump_2dp == 1)
		//recover basic EMDC

		string EDC = "EDC_"+tpw()
		string mDC = "MDC_"+tpw()
		wave edcw = $edc
		wave mdcw = $mdc
		string namerawe = "raw_"+EDC
		string namerawm = "raw_"+mDC
		wave namerawew = $namerawe
		wave namerawmw = $namerawm
		edcw = namerawew
		mdcw = namerawmw

		if (sel_L_2dplot == 1)
		ZoutI = "ZoutI_"+tpw()
		wave ZoutIw = $ZoutI
		raw2pm = "raw_"+ZoutI
		wave raw2pmw = $raw2pm
		ZoutIw = raw2pmw
		endif

		if (sel_L_2dplot == 2)
		ZoutI = "Zout_"+tpw()
		wave ZoutIw = $ZoutI
		raw2pm = "raw_"+ZoutI
		wave raw2pmw = $raw2pm
		ZoutIw = raw2pmw

		ZoutI2 = "ZoutI_"+tpw()
		wave ZoutI2w = $ZoutI2
		trajdis = "trajdis_"+tpw()
		wave trajdisw = $trajdis
		Interpolate2/T=1/N=(2*dimsize(ZoutIw,0))/E=2/Y=$ZoutI2 trajdisw, ZoutIw
		endif

		if (sel_L_2dplot == 3)
		ZoutI = "ZoutI_"+tpw()
		wave ZoutIw = $ZoutI
		raw2pm = "raw_"+ZoutI
		wave raw2pmw = $raw2pm
		ZoutIw = raw2pmw
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
end

//#2 Control of Remover Mode <auto or Givem>
Function PopMenuProc_jump2dpmode(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	variable/G removejump_2dp
	variable/G removejumpmode_2dp
	variable/G removejumpvalue_2dp
	removejumpmode_2dp = popNum //1 auto, 2 given
end

//#3 Excellent 1D jump remover
Function autoremovejump1D(name,mode,valueif2,givencriteria)
	wave name
	variable mode //1 for auto, 2 for specified value
	variable valueif2
	variable givencriteria

	//** Make the delta wave
		string deltawave = "delta_"+nameofwave(name)
		make/N=(dimsize(name,0)-1)/o $deltawave
		wave deltawavew = $deltawave
		variable i =0
		do
			deltawavew[i] = name[i+1] - name[i] //How much difference between the adjacent points
			i+=1
		while (i < dimsize(deltawavew,0))

	//** Auto Mode: The criteria for jump
		duplicate/o deltawavew deltawavewabs
		deltawavewabs[] = abs(deltawavew[p])
		//##### This value is important for Auto Mode
		//##### If this is not proper, some jump may be not removed
		variable jumpjudge = 100*median(deltawavewabs) //100 times Median of the difference wave as criteria
		//#####
		//#####

	//** Given Mode, reassign the value for Jump criteria
		if (mode == 2)
			jumpjudge = givencriteria
		endif
		killwaves deltawavewabs
			//display deltawavew
			//print jumpjudge

	//** Use the criteria to Find the Jump Position
		make/o/N=0 jp_p1d //Jump posiotn wave
		i=0
		do
			if(abs(deltawavew[i]) > jumpjudge)
					//print i
				InsertPoints dimsize(jp_p1d,0),1, jp_p1d
					//print dimsize(jp_p1d,0)-1
				jp_p1d[dimsize(jp_p1d,0)-1] = (i+1)*sign(deltawavew[i])
			endif
			i+=1
		while (i<dimsize(deltawavew,0))
			//edit jp_p1d
		//%% Add the dimsize of $name to the last point of jump positon wave
		variable num = dimsize(jp_p1d,0)
		InsertPoints dimsize(jp_p1d,0),1, jp_p1d
		jp_p1d[dimsize(jp_p1d,0)-1] =dimsize(name,0)-1

	//** Save the raw data before Jump remove
		string nameraw = "raw_"+nameofwave(name)
		duplicate/o name $nameraw

	//** Do Jump remove
		variable jump,sj,jp2
		jp2=0
		i=0
		do
			//Calculte the jump amount for auto mode
				jump = name[abs(jp_p1d[i])]-name[abs(jp_p1d[i])-1]

			//Reassigne the jump amount for Given mode
				if (mode == 2)
					sj=sign(jp_p1d[i])
					jp2+=sj*valueif2
					jump=jp2
				endif

			//Use the proper assigned Jump amount to do jump remove
				if (num == 0)
				else
					if (i == num-1)
						name[abs(jp_p1d[i]),abs(jp_p1d[i+1])]-=jump
					else
						name[abs(jp_p1d[i]),abs(jp_p1d[i+1])-1]-=jump
					endif
				endif
			//Do cycle
			i+=1
		while(i < num)
		killwaves jp_p1d deltawavew

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
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$   End of Smart 2D matrix EMDC  $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////  ## New and Smarter version of Auto display figure##  ////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Showfigind(ctrlName) : ButtonControl
	String ctrlName
	d($tpw())
End

Function d(name)
	wave name
	di(name)
	PauseUpdate
	Silent 1
	String wn =winname(0,1)


	modifygraph width=300,height=300;ModifyGraph nticks=0,noLabel=2,axThick=2,standoff=0;
	ModifyGraph margin(right)=72;ColorScale/C/N=text0/F=0/A=RC/X=-23/Y=0 image=name;ColorScale/C/N=text0 frame=0.00

	ColorScale/C/N=text0/A=LC/X=101/Y=0/F=0 frame=0.00,image=$nameofwave(name)
	//ModifyImage name ctab= {*,*,:Packages:NewColortable:Biploar_matlab,0}
	Dowindow/F $wn
	drawAction delete
	variable lenx = (dimsize(name,0)-1)*dimdelta(name,0)//+dimoffset(name,0)
	variable leny = (dimsize(name,1)-1)*dimdelta(name,1)//+dimoffset(name,1)
	//print lenx
	//print leny
	Dowindow/F $wn
	variable x1,x2,lenbar1,lenbar
	x1 = 0.75*lenx+dimoffset(name,0)
	lenbar1 = round(0.2*lenx)
	if(lenbar1 > 10)
		lenbar = lenbar1+(round(lenbar1/10)-lenbar1/10)*10
	else
		lenbar = lenbar1
	endif
	X2 = 0.75*lenx+lenbar+dimoffset(name,0)

	SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),linethick= 4.00
	DrawLine x1,0.06*leny+dimoffset(name,1),x2,0.06*leny+dimoffset(name,1)
	//print ">>>>>>>>>>>>>>>>>>>>>>>>"
	//print x1
	//print x2
	//print 0.06*leny+dimoffset(name,1)
	//print 0.06*leny+dimoffset(name,1)


	string textv =num2str(round(lenbar))+" Å"
	SetDrawEnv xcoord= bottom,ycoord= left,textrgb= (65535,65535,65535),fstyle= 1,fsize= 20,textxjust= 1,textyjust= 1
	DrawText 0.85*lenx+dimoffset(name,0),0.105*leny+dimoffset(name,1),textv


	//** Control of Cycling color
	Button colorcycling win=$winname(0,1), title="CycleC",proc=ButtonProc_colorcycling_ind,pos={101,0},size={50,12},fSize=10

	//** Control of Plain color
	Button colorplain win=$winname(0,1), title="PlainC",proc=ButtonProc_colorplain_ind,pos={176,0},size={50,12},fSize=10

	//** Control of div color
	Button colordiv win=$winname(0,1), title="DivgC",proc=ButtonProc_colordiv_ind,pos={251,0},size={50,12},fSize=10

	Button turnoffls3d title="BACK",size={45,12},valueColor=(0,0,0),fColor=(1,65535,33232),pos={370,0},proc=ButtonProc_lsturnoff3d

	wavestats/Q name
	variable/G colormin_ind = V_min
	variable/G colormax_ind = V_max
	variable/G timesg = 3
	variable/G colorinver_ind = 0
	variable/G colorindexuser
	SetVariable setCmin size={100,20},value=colormin_ind,proc=SetVarProc_colornumind,limits={-inf,inf,(V_max-V_min)/50},title="C_Min",pos={208,319}
	SetVariable setCmax size={100,20},value=colormax_ind,proc=SetVarProc_colornumind,limits={-inf,inf,(V_max-V_min)/50},title="C_Max",pos={208,340}
	SetVariable setCmaxsigma size={60,20},value=timesg,proc=SetVarProc_coloarrange_ind,limits={-inf,inf,0.2},title="σ",pos={313,319}
	SetVariable setCinverse size={60,20},value=colorinver_ind,proc=SetVarProc_colorinver_ind,limits={0,1,1},title="IV",pos={313,340}

	PopupMenu popup0 value="*COLORTABLEPOP*",pos={0,340},proc=PopMenuProc_colormat_ind

	Button setCauto1 title="A",size={17,12},pos={374,319},proc=ButtonProc_colormatauto1,fSize=10
	Button setCauto2 title="∓1",size={22,12},pos={395,319},proc=ButtonProc_colormatauto2,fSize=10
	Button setCauto3 title="∓π",size={22,12},pos={395,335},proc=ButtonProc_colormatauto3,fSize=10
	Button setCauto4 title="∓V",size={22,12},pos={374,335},proc=ButtonProc_colormatauto4,fSize=10

	PopupMenu popup1 value=WaveList("*",";","",root:Packages:NewColortable:),proc=PopMenuProc_colormat_ind2,bodyWidth=130,pos={0,319}


	SetVariable setvarsetciuind title=" ",value=colorindexuser,proc=SetVarProc_colormatmorevv_ind
	variable setvarsetciuindlim = itemsInList(WaveList("*", ";", "", root:Packages:NewColortable:))+itemsInList(CtabList())-1
	SetVariable setvarsetciuind limits={0,setvarsetciuindlim,1},pos={149,323}

	tilewindows/WINS=winname(0,1)/R/w=(18,22,100,100)/A=(1,1)
end


Function ButtonProc_colormatauto1(ctrlName) : ButtonControl
	String ctrlName
	string color=stringfromlist(2,stringByKey("RECREATION",imageinfo("",tpw(),0)),",")
	string colorinv=stringfromlist(3,stringByKey("RECREATION",imageinfo("",tpw(),0)),",")

	string exe
	exe = "ModifyImage $tpw() ctab= {*,*,"+color+","+colorinv
	execute exe
	wavestats/Q $tpw()
	variable/G colormin_ind = V_min
	variable/G colormax_ind = V_max
end

Function ButtonProc_colormatauto2(ctrlName) : ButtonControl
	String ctrlName
	string color=stringfromlist(2,stringByKey("RECREATION",imageinfo("",tpw(),0)),",")
	string colorinv=stringfromlist(3,stringByKey("RECREATION",imageinfo("",tpw(),0)),",")

	string exe
	exe = "ModifyImage $tpw() ctab= {-1,1,"+color+","+colorinv
	execute exe
	variable/G colormin_ind = -1
	variable/G colormax_ind = 1
end
Function ButtonProc_colormatauto3(ctrlName) : ButtonControl
	String ctrlName
	string color=stringfromlist(2,stringByKey("RECREATION",imageinfo("",tpw(),0)),",")
	string colorinv=stringfromlist(3,stringByKey("RECREATION",imageinfo("",tpw(),0)),",")

	string exe
	exe = "ModifyImage $tpw() ctab= {-pi,pi,"+color+","+colorinv
	execute exe
	variable/G colormin_ind = -pi
	variable/G colormax_ind = pi
end
Function ButtonProc_colormatauto4(ctrlName) : ButtonControl
	String ctrlName

	wavestats/Q $tpw()
	variable vv
	if(abs(V_max) > abs(V_min))
		vv = abs(V_max)
	else
		vv = abs(V_min)
	endif

	string color=stringfromlist(2,stringByKey("RECREATION",imageinfo("",tpw(),0)),",")
	string colorinv=stringfromlist(3,stringByKey("RECREATION",imageinfo("",tpw(),0)),",")

	string exe
	exe = "ModifyImage $tpw() ctab= {"+num2str(-vv)+","+num2str(vv)+","+color+","+colorinv
	execute exe
	variable/G colormin_ind = -vv
	variable/G colormax_ind = vv
end


Function ButtonProc_colorcycling_ind(ctrlName) : ButtonControl
	String ctrlName
	ModifyGraph noLabel=2
	ModifyGraph axThick=0
	ModifyImage $tpw() ctab= {-pi,pi,RainbowCycle,0}
	//ColorScale/C/N=text0/F=0/X=-30.00/Y=0.00 image=$tpw()
	variable/G colormin_ind = -pi
	variable/G colormax_ind = pi
	variable/G colorinver_ind = 1
end

Function ButtonProc_colorplain_ind(ctrlName) : ButtonControl
	String ctrlName
	ModifyGraph noLabel=0
	ModifyGraph axThick=1
	ModifyImage $tpw() ctab= {*,*,VioletOrangeYellow,0}
	//ColorScale/K/N=text0
	wavestats/Q $tpw()
	variable/G colormin_ind = V_min
	variable/G colormax_ind = V_max
	variable/G colorinver_ind = 0

end

Function ButtonProc_colordiv_ind(ctrlName) : ButtonControl
	String ctrlName
	ModifyGraph noLabel=0
	ModifyGraph axThick=1
	wavestats/Q $tpw()
	variable vv
	if(abs(V_max) > abs(V_min))
		vv = abs(V_max)
	else
		vv = abs(V_min)
	endif
	ModifyImage $tpw() ctab= {-vv,vv,root:Packages:NewColortable:dvg_seismic,1}
	//ColorScale/K/N=text0
	variable/G colormin_ind = -vv
	variable/G colormax_ind = vv
	variable/G colorinver_ind = 1

end

Function SetVarProc_colornumind(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/G colormin_ind
	variable/G colormax_ind

	//stringByKey("RECREATION",imageinfo("",tpw(),0))

	string color=stringfromlist(2,stringByKey("RECREATION",imageinfo("",tpw(),0)),",")
	string colorinv=stringfromlist(3,stringByKey("RECREATION",imageinfo("",tpw(),0)),",")

	string exe
	exe = "ModifyImage $tpw() ctab= {"+num2str(colormin_ind)+","+num2str(colormax_ind)+","+color+","+colorinv
	execute exe
	//ModifyImage $tpw() ctab= {colormin_ind,colormax_ind,VioletOrangeYellow,0}
End

Function SetVarProc_coloarrange_ind(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	gethistgram_np()
	wave W_coef=$"W_coef"
	string name = tpw()
	wavestats/Q $name
	variable sigma = sqrt(2)*W_coef[3]
	variable lc,lh
	variable/G timesg
	if (W_coef[2]-0.5*timesg*sigma >V_min)
		lc = W_coef[2]-0.5*timesg*sigma
	else
		lc =V_min
	endif
	if (W_coef[2]+0.5*timesg*sigma < V_max)
		lh = W_coef[2]+0.5*timesg*sigma
	else
		lh =V_max
	endif

	string color=stringfromlist(2,stringByKey("RECREATION",imageinfo("",tpw(),0)),",")
	string colorinv=stringfromlist(3,stringByKey("RECREATION",imageinfo("",tpw(),0)),",")

	string exe
	exe = "ModifyImage $tpw() ctab= {"+num2str(lc)+","+num2str(lh)+","+color+","+colorinv
	//print exe
	execute exe
	variable/G colormin_ind = lc
	variable/G colormax_ind = lh
END

Function SetVarProc_colorinver_ind(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/G colorinver_ind

	variable/G colormin_ind
	variable/G colormax_ind

	//stringByKey("RECREATION",imageinfo("",tpw(),0))

	string color=stringfromlist(2,stringByKey("RECREATION",imageinfo("",tpw(),0)),",")
	string colorinv=stringfromlist(3,stringByKey("RECREATION",imageinfo("",tpw(),0)),",")

	string exe
	exe = "ModifyImage $tpw() ctab= {"+num2str(colormin_ind)+","+num2str(colormax_ind)+","+color+","+num2str(colorinver_ind)+"}"
	execute exe
end

Function PopMenuProc_colormat_ind(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	variable/G colorinver_ind

	variable/G colormin_ind
	variable/G colormax_ind

	//stringByKey("RECREATION",imageinfo("",tpw(),0))

	string color=popStr
	string colorinv=stringfromlist(3,stringByKey("RECREATION",imageinfo("",tpw(),0)),",")

	string exe
	exe = "ModifyImage $tpw() ctab= {"+num2str(colormin_ind)+","+num2str(colormax_ind)+","+color+","+num2str(colorinver_ind)+"}"
	execute exe

	variable numnew = itemsInList(WaveList("*", ";", "", root:Packages:NewColortable:))
	variable/G colorindexuser = numnew+popNum-1

End

Function PopMenuProc_colormat_ind2(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	variable/G colorinver_ind

	variable/G colormin_ind
	variable/G colormax_ind

	//stringByKey("RECREATION",imageinfo("",tpw(),0))

	string color="root:Packages:NewColortable:"+popStr
	string colorinv=stringfromlist(3,stringByKey("RECREATION",imageinfo("",tpw(),0)),",")

	string exe
	exe = "ModifyImage $tpw() ctab= {"+num2str(colormin_ind)+","+num2str(colormax_ind)+","+color+","+num2str(colorinver_ind)+"}"
	execute exe

	variable/G colorindexuser = popNum-1

End


Function SetVarProc_colormatmorevv_ind(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	colormatmorevv_ind()
End
Function colormatmorevv_ind()
	variable/G colorinver_ind
	variable/G colormin_ind
	variable/G colormax_ind
	variable/G colorindexuser
	variable numnew = itemsInList(WaveList("*", ";", "", root:Packages:NewColortable:))
	string colorinv=stringfromlist(3,stringByKey("RECREATION",imageinfo("",tpw(),0)),",")
	string color
	string exe

	if(colorindexuser < numnew)
		color="root:Packages:NewColortable:"+stringfromList(colorindexuser,WaveList("*", ";", "", root:Packages:NewColortable:))
		exe = "ModifyImage $tpw() ctab= {"+num2str(colormin_ind)+","+num2str(colormax_ind)+","+color+","+num2str(colorinver_ind)+"}"
		execute exe
		PopupMenu popup1 value=WaveList("*",";","",root:Packages:NewColortable:),proc=PopMenuProc_colormat_ind2,pos={0,319},mode = colorindexuser+1

	else
		color=stringfromList(colorindexuser-numnew,CtabList())
		exe = "ModifyImage $tpw() ctab= {"+num2str(colormin_ind)+","+num2str(colormax_ind)+","+color+","+num2str(colorinver_ind)+"}"
		execute exe
		PopupMenu popup0 value="*COLORTABLEPOP*",pos={0,340},proc=PopMenuProc_colormat_ind,mode=colorindexuser-numnew+1
	endif
End

////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
// Procedure for vector field plot
// You need to input the phase map and amplitude map
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_makevectorfield(ctrlName) : ButtonControl
	String ctrlName
	Execute "makevectorfieldc()"
end
proc makevectorfieldc(name,amp)
	string name  //Name of the phase map
	String amp   //Name of the amplitude map
	prompt name,"Phase map"
	prompt amp, "amplitude map"
	makevectorfield(name,amp)
end
Function makevectorfield(name,amp)
	string name  //Name of the phase map
	String amp   //Name of the amplitude map

	string/G phase_vf = name
	string/G amp_vf = amp
	variable/G arrowl_vf = 7
	variable/G bk_vf = 6.7
	variable/G lineThick_vf = 0.2
	variable/G headLen_vf = 6
	variable/G headFat_vf = 0.2
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
		ModifyGraph margin(right)=72;ColorScale/C/N=text0/F=0/A=LC/X=101.50/Y=0.00 image=$namedd;
		ColorScale/C/N=text0 frame=0.00


	//Set scale bar
		variable lenx = (dimsize($phase_vf,0)-1)*dimdelta($phase_vf,0)
		variable leny = (dimsize($phase_vf,1)-1)*dimdelta($phase_vf,1)
		variable x1,x2,lenbar1,lenbar
		x1 = 0.75*lenx+dimoffset($phase_vf,0)
		lenbar1 = round(0.2*lenx)
		if(lenbar1 > 10)
			lenbar = lenbar1+(round(lenbar1/10)-lenbar1/10)*10
		else
			lenbar = lenbar1
		endif
		X2 = 0.75*lenx+lenbar+dimoffset($phase_vf,0)

		SetDrawEnv xcoord= bottom,ycoord= left,linefgc= (65535,65535,65535),linethick= 4.00
		DrawLine x1,0.03*leny+dimoffset($phase_vf,1),x2,0.03*leny+dimoffset($phase_vf,1)
		string textv =num2str(round(lenbar))+" Å"
		SetDrawEnv xcoord= bottom,ycoord= left,textrgb= (65535,65535,65535),fstyle= 1,fsize= 20,textxjust= 1,textyjust= 1
		DrawText 0.85*lenx+dimoffset($phase_vf,0),0.05*leny+dimoffset($phase_vf,1),textv


	//Set controls
		SetVariable set1 size={75,14},value=arrowl_vf,proc=SetVarProc_vf1,limits={0.1,inf,0.1},title="↑ length",pos={1,1}

		SetVariable sets1 pos={340,1},title="Thick",size={65,14},value=lineThick_vf,proc=SetVarProc_vf2,limits={0.1,inf,0.1}
		SetVariable sets2 pos={410,1},size={75,14},value=headLen_vf,proc=SetVarProc_vf2,limits={0.1,inf,0.1},title="headLen"
		SetVariable sets3 pos={485,1},size={75,14},value=headFat_vf,proc=SetVarProc_vf2,limits={0.1,inf,0.1},title="headFat"
		SetVariable sets4 pos={560,1},size={70,14},value=posMode_vf,proc=SetVarProc_vf2,limits={0,3,1},title="posMode"

		if (cmpstr(amp,"")==0) // amp is empty
			popupmenu popvfcolor  size={60,14},proc=PopMenuProc_vf,value="Phase;Plain",mode =2,title="Color",bodyWidth=80,pos={680,1}
		else
			popupmenu popvfcolor  size={60,14},proc=PopMenuProc_vf,value="Phase;Plain;Amplitude",mode =2,title="Color",bodyWidth=80,pos={680,1}
		endif


		if (cmpstr(amp,"")==0) // amp is empty
		else
			SetVariable set2 size={75,14},value=bk_vf,proc=SetVarProc_vf1,limits={0.1,inf,0.1},title="↑l_bkg ",pos={80,1}
			popupmenu popvflenmode  size={60,14},bodyWidth=80,pos={226,1},proc=PopMenuProc_vflenmode, mode = lenmode_vf,value="Uniform;From amp",title="LMode"
		endif

		BUTTON VFCLOSE title="X",pos={720,24},size={20,20},fColor=(1,52428,26586),fstyle=1,proc=ButtonProc_VF


		PopupMenu appendtordvf proc=PopMenuProc_appendimagevf,value="Remove;φ(r);A(r)",pos={1,18}

		Variable/G stepsshrink_vf = 1
		SetVariable setshrink value=stepsshrink_vf,proc=SetVarProc_vfshrink,limits={1,inf,1},pos={1,40},size={65,14},title="Coarse"

		SetVariable set1 size={90,14},pos={1,2}
		SetVariable set2 pos={92,2},size={80,14}
		SetVariable sets1 pos={287,2},size={80,14}
		SetVariable sets2 pos={366,2},size={80,14}
		SetVariable sets3 pos={446,2},size={80,14}


end

Function SetVarProc_vfshrink(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	shrinkvf(varNum)
end

Function ButtonProc_VF(ctrlName) : ButtonControl
	String ctrlName

	//string matnew = stringfromlist(0,mat3dn_cons,"_")+"_"+stringfromlist(1,mat3dn_cons,"_")+"_"+stringfromlist(2,mat3dn_cons,"_")
	killwindow $winname(0,1)
	//mat3dn_cons = matnew
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

Function PopMenuProc_vflenmode(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String/G phase_vf
	string/G amp_vf
	variable/G arrowl_vf
	variable/G bk_vf
	variable/G lineThick_vf
	variable/G headLen_vf
	variable/G headFat_vf
	variable/G posMode_vf

	variable/G lenmode_vf = popNum

	string arrowDatas = "arrowData_"+phase_vf
	wave arrowData2 = $arrowDatas
	// change length mode, real length or uniform length
			string amp = amp_vf
			if (lenmode_vf==1) // uniform length
				arrowData2[][0]=  arrowl_vf   // Column 0: arrow lengths in points
			endif

			if (lenmode_vf==2) // amp length
				//Make the information of length at each points
					wave ampw = $amp
					string arrowlens = "arrowlen_"+phase_vf
					duplicate/o ampw $arrowlens
					wave arrowlen2 = $arrowlens
					variable sxamp, syamp
					sxamp = dimsize(ampw,0)
					syamp = dimsize(ampw,1)
					redimension/N=(sxamp*syamp) $arrowlens
					wave arrowlen2 = $arrowlens
					wavestats/Q $arrowlens
					arrowlen2/= V_max
					arrowlen2*= arrowl_vf
					arrowlen2+= bk_vf*arrowl_vf/10

				arrowData2[][0]=  arrowlen2[p]
			endif
end


Function PopMenuProc_vf(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	arrowcolortype_vf(popNum)
end

Function arrowcolortype_vf(sel)
	variable sel
	String/G phase_vf
	string/G amp_vf
	variable/G arrowl_vf
	variable/G bk_vf
	variable/G lineThick_vf
	variable/G headLen_vf
	variable/G headFat_vf
	variable/G posMode_vf

	string ypoints = "ypoint_"+phase_vf
	string arrowDatas = "arrowData_"+phase_vf

	string arrowlens = "arrowlen_"+phase_vf
	wave arrowlen2 = $arrowlens

	string S_arrowangle = "arrowangle_"+phase_vf
	wave S_arrowanglew = $S_arrowangle

	if (sel == 1) // phase
		ModifyGraph zColor($ypoints)={S_arrowanglew,*,*,RainbowCycle,0}
	endif

	if (sel == 3) // amp
		ModifyGraph zColor($ypoints)={arrowlen2,*,*,VioletOrangeYellow,0}
	endif

	if (sel == 2) // plain
		ModifyGraph rgb=(0,0,0)
		ModifyGraph zColor($ypoints)=0
	endif
end

Function SetVarProc_vf1(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	String/G phase_vf
	string/G amp_vf
	variable/G arrowl_vf
	variable/G bk_vf
	variable/G lineThick_vf
	variable/G headLen_vf
	variable/G headFat_vf
	variable/G posMode_vf


	variable/G lenmode_vf

	string arrowDatas = "arrowData_"+phase_vf
	wave arrowData2 = $arrowDatas
	// change length mode, real length or uniform length
			string amp = amp_vf
			if (lenmode_vf==1) // uniform length
				arrowData2[][0]=  arrowl_vf   // Column 0: arrow lengths in points
			endif

			if (lenmode_vf==2) // amp length
				//Make the information of length at each points
					wave ampw = $amp
					string arrowlens = "arrowlen_"+phase_vf
					duplicate/o ampw $arrowlens
					wave arrowlen2 = $arrowlens
					variable sxamp, syamp
					sxamp = dimsize(ampw,0)
					syamp = dimsize(ampw,1)
					redimension/N=(sxamp*syamp) $arrowlens
					wave arrowlen2 = $arrowlens
					wavestats/Q $arrowlens
					arrowlen2/= V_max
					arrowlen2*= arrowl_vf
					arrowlen2+= bk_vf*arrowl_vf/10

				arrowData2[][0]=  arrowlen2[p]
			endif
end


Function SetVarProc_vf2(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	String/G phase_vf
	string/G amp_vf
	variable/G arrowl_vf
	variable/G bk_vf
	variable/G lineThick_vf
	variable/G headLen_vf
	variable/G headFat_vf
	variable/G posMode_vf

	string ypoints = "ypoint_"+phase_vf
	string arrowDatas = "arrowData_"+phase_vf
	wave arrowData2 = $arrowDatas

	ModifyGraph arrowMarker($ypoints) = {arrowData2, lineThick_vf, headLen_vf, headFat_vf, posMode_vf}
end
Function PopMenuProc_appendimagevf(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String/G phase_vf
	string/G amp_vf
	variable/G arrowl_vf
	variable/G bk_vf
	variable/G lineThick_vf
	variable/G headLen_vf
	variable/G headFat_vf
	variable/G posMode_vf

	variable/G lenmode_vf

	string Tr = phase_vf+"_Backup"
	string dr = amp_vf+"_Backup"


	string appendvalue
	print waveexists($dr)
		if (waveexists($dr) == 1)
			appendvalue = "Remove;φ(r);A(r)"
		else
			appendvalue = "Remove;φ(r)"
		endif
	string exbody ="PopupMenu appendtordvf value= \""+appendvalue+"\""
	execute exbody


	string listcheck = wavelist("*",";","Win:"+winname(0,1))+"1"

	//Remove
	if (popNum == 1)
		if (cmpstr(StringByKey(tr,listcheck,";"),"") == 1)
			removeimage $Tr
		endif

		if (cmpstr(StringByKey(dr,listcheck,";"),"") == 1)
			removeimage $dr
		endif
	endif

	//Phase map
	if (popNum == 2)
		if (cmpstr(StringByKey(dr,listcheck,";"),"") == 1)
			removeimage $dr
		endif
		if (cmpstr(StringByKey(tr,listcheck,";"),"") == 1)
			removeimage $Tr
		endif
		Appendimage $Tr
		ModifyImage $Tr ctab= {*,*,RainbowCycle,0}
		ModifyGraph margin(right)=72;ColorScale/C/N=text0/F=0/A=LC/X=101.50/Y=0.00 image=$Tr;
		ColorScale/C/N=text0 frame=0.00
		arrowcolortype_vf(3)

		string aa = "popupmenu popvfcolor mode =3"
		execute aa
	endif


	//amplitude map
	if (popNum == 3)
		if (cmpstr(StringByKey(dr,listcheck,";"),"") == 1)
			removeimage $dr
		endif
		if (cmpstr(StringByKey(tr,listcheck,";"),"") == 1)
			removeimage $Tr
		endif
		Appendimage $dr
		gethistgram_npcolor(dr)
		string W_coef = "W_coef"
		wave W_coefw = $W_coef
		variable sigma = sqrt(2)*W_coefw[3]

		wavestats/Q $dr
		variable lc,lh
		if (W_coefw[2]-0.5*3*sigma >V_min)
			lc = W_coefw[2]-0.5*3*sigma
		else
			lc =V_min
		endif
		if (W_coefw[2]+0.5*3*sigma < V_max)
			lh = W_coefw[2]+0.5*3*sigma
		else
			lh =V_max
		endif

		ModifyImage $dr ctab= {lc,lh,VioletOrangeYellow,0}
		ColorScale/C/N=text0/F=0/A=LC/X=101.50/Y=0.00 image=$dr;
		ColorScale/C/N=text0 frame=0.00

		arrowcolortype_vf(1)
		string bb = "popupmenu popvfcolor mode =1"
		execute bb
	endif
end

//Make vector field plot with shrinked dimsize, steps is a int
Function shrinkvf(steps)
	int steps
	string/G phase_vf
	string/G amp_vf

	string name = phase_vf+"_Backup"
	string amp = amp_vf+"_Backup"

	duplicate/o $name $phase_vf


	shrinkmatrixbysteps(phase_vf,steps)
	string s_p = phase_vf+"_shrinked"
	duplicate/o $s_p $phase_vf


	if (cmpstr(amp_vf,"")==0) // amp is empty
		makevectorfield_shrink(phase_vf,"")
		killwaves $s_p
	else
		duplicate/o $amp $amp_vf
		shrinkmatrixbysteps(amp_vf,steps)
		string a_p = amp_vf+"_shrinked"
		duplicate/o $a_p $amp_vf


		makevectorfield_shrink(phase_vf,amp_vf)

		killwaves $a_p $s_p
	endif
end

Function makevectorfield_shrink(name,amp)
	string name  //Name of the phase map
	String amp   //Name of the amplitude map

	string/G phase_vf = name
	string/G amp_vf = amp
	variable/G arrowl_vf
	variable/G bk_vf
	variable/G lineThick_vf
	variable/G headLen_vf
	variable/G headFat_vf
	variable/G posMode_vf
	variable/G lenmode_vf


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

Function ButtonProc_shrinkmatrixbysteps(ctrlName) : ButtonControl
	String ctrlName
	Execute "shrinkmatrixbystepsc()"
end
proc shrinkmatrixbystepsc(name,steps)
	string name = tpw()
	variable steps = 2
	prompt name,"Matrix name"
	prompt steps,"Times to shrink, increase the dimdelta step times"
	shrinkmatrixbysteps(name,steps)
end

Function shrinkmatrixbysteps(name,steps)
	string name
	variable steps
	string namenew = name+"_shrinked"
	duplicate/o $name $namenew
	wave nameneww = $namenew
	nameneww = 0
	wave namew = $name

	variable i,j,i2,j2
	i=0
	i2=0
	do
		j=0
		j2=0
		do
			nameneww[i][j]= namew[i2][j2]
			j+=1
			j2+=steps
		while (j2<dimsize($name,1))
		i+=1
		i2+=steps
	while (i2<dimsize($name,0))
	Redimension/N=(i,j) nameneww
	setscale/p x,dimoffset($name,0),steps*dimdelta($name,0),"",nameneww
	setscale/p y,dimoffset($name,1),steps*dimdelta($name,1),"",nameneww
	//di(nameneww)
end

Function ButtonProc_cyclecolorwavec(ctrlName) : ButtonControl
	String ctrlName
	Execute "cyclecolorwavec()"
end

Proc cyclecolorwavec(c,index)
	variable c = 2
	variable index = 87
	Prompt c,"Cycles (>= 2)"
	Prompt index,"Color index, 14, 15, 16, 38, 39, 40, 84, 87"

	cyclecolorwave(c,index)
	print "color_cycle"
	variable numnew = itemsInList(WaveList("*", ";", "", root:Packages:NewColortable:))
	string s1,s2
	if(colorindexuser < numnew)
		s1 = stringfromList(colorindexuser,WaveList("*", ";", "", root:Packages:NewColortable:))
		s2 = "root:Packages:NewColortable:"+s1
		Print s2
	else
		s1=stringfromList(colorindexuser-numnew,CtabList())
		s2 = s1
		ColorTab2Wave $s2
		Print s2
	endif
	ModifyImage $tpw() ctab= {*,*,color_cycle,0}
end

Function cyclecolorwave(c,index)
	variable c
	variable index
	variable/G colorindexuser = index

	variable numnew = itemsInList(WaveList("*", ";", "", root:Packages:NewColortable:))
	string s1,s2
	if(colorindexuser < numnew)
		s1 = stringfromList(colorindexuser,WaveList("*", ";", "", root:Packages:NewColortable:))
		s2 = "root:Packages:NewColortable:"+s1
		wave M_colorsw = $s2
		//Print s2
	else
		s1=stringfromList(colorindexuser-numnew,CtabList())
		s2 = s1
		ColorTab2Wave $s2
		wave M_colorsw = $"M_colors"
		//Print s2
	endif

	variable odimx = dimsize(M_colorsw,0)
	variable odimy = dimsize(M_colorsw,1)
	make/n=(odimx+(c-1)*odimx,odimy)/o color_cycle
	variable i,kk
	kk = 0
	do
		i=0
		do
			color_cycle[i+odimx*kk][] = M_colorsw[i][q]
			i+=1
		while(i<odimx)
		kk+=1
	while (kk < (c))
end

/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
//Special version of smart 3D plot for Simulated 3D matrix
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_d3dsimu(ctrlName) : ButtonControl
	String ctrlName
	Execute "d3dsimu()"
End
Proc d3dsimu(mat3dn,zn)
	string mat3dn
	variable zn = zn_cons
	Prompt mat3dn,"Name of the 3D simulation matrix", popup getall3dwave()
	Prompt zn,"Index of the Energy"
	string/G mat3dn_cons = mat3dn
	variable/G zn_cons = zn //the Energy in which dimension?
	variable/G z_cons = (dimoffset($mat3dn_cons,zn_cons)+dimdelta($mat3dn_cons,zn_cons)*round((dimsize($mat3dn_cons,zn_cons)-1)/2)) //energy to show
	variable/G Znorm_cons
	//** Auto ordering layer index
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

	//** Scaling the layer to show
		string slicename = "Zslice_"+mat3dn_cons
		make/o/N=(dimsize($mat3dn_cons,xn),dimsize($mat3dn_cons,yn)) $slicename
		setscale/p x,dimoffset($mat3dn_cons,xn),dimdelta($mat3dn_cons,xn),"",$slicename
		setscale/p y,dimoffset($mat3dn_cons,yn),dimdelta($mat3dn_cons,yn),"",$slicename

	//** Generate the average curve
		variable Z_constp=(z_cons-dimoffset($mat3dn_cons,zn_cons))/dimdelta($mat3dn_cons,zn_cons)
		//Z_cons = dimoffset($mat3dn,zn)+dimdelta($mat3dn,zn)*(Z_constp)

		string singlespectra = "sgsg_"+mat3dn_cons
		//SumDimension/D=(xn)/DEST=wout $mat3dn;
		sumoned(singlespectra,mat3dn,zn)
		//duplicate/o wout1 $singlespectra
		//setscale/p x,dimoffset($mat3dn_cons,zn),dimdelta($mat3dn_cons,zn),"",$singlespectra
		//killwaves wout

		//display $singlespectra
		//print num2str(wavemin($singlespectra))+" "+num2str(wavemax($singlespectra))
		//wavestats  $singlespectra
		//wavestats wout1
		//make/o/n=(dimsize($mat3dn_cons,zn)) $singlespectra
		//setscale/p x,dimoffset($mat3dn_cons,zn),dimdelta($mat3dn_cons,zn),"",$singlespectra
		string Zpp = "Zpp_"+mat3dn_cons
		make/o/n=(2) $Zpp
		setscale/I x,wavemin($singlespectra),wavemax($singlespectra),"",$Zpp
		$Zpp=z_cons

	//** Generate layer image
		if(zn_cons == 0)
			$slicename[][]=$mat3dn_cons[Z_constp][p][q]
		endif
		if(zn_cons == 1)
			$slicename[][]=$mat3dn_cons[p][Z_constp][q]
		endif
		if(zn_cons == 2)
			$slicename[][]=$mat3dn_cons[p][q][Z_constp]
		endif

	//** Display layer image
		di2lf($slicename)
		func_zeroNaN($slicename)
		color3s_for3d($slicename,3)
		modifygraph width=300,height=300
		ModifyGraph width={Plan,1,bottom,left}
		SetAxis bottom dimoffset($slicename,0),dimoffset($slicename,0)+(dimsize($slicename,0)-1)*dimdelta($slicename,0)
		SetAxis left dimoffset($slicename,1),dimoffset($slicename,1)+(dimsize($slicename,1)-1)*dimdelta($slicename,1)




	//** Display FFT of the layer image
		//variable/G colorratio_consFFT =30
		//f_for3d()
		//String FFToutm = slicename+"_FFT"+"_Modula"
		//di2lf($FFToutm)
		//** Set color scale
		//SetVariable setvarz_csfftm win=$grabwin(FFToutm),title="σ",size={65,14},value=colorratio_consFFT,limits={1,inf,1},proc=SetVarProc_colorratio_consFFT

		//modifygraph width=300,height=300
		//ModifyGraph width={Plan,1,bottom,left}
		//color3s_for3dinv($FFToutm,colorratio_consFFT)

	//** Make subwindow to show average curve
		Dowindow/F $grabwin(slicename)
		ModifyGraph margin(bottom)=144
		Display/HOST=#/W=(0,0.7,1,1)  $singlespectra
		ModifyGraph/W=$(grabwin(slicename)+"#"+stringFromList(0,childWindowList(grabwin(slicename))))  rgb($singlespectra)=(52428,52428,52428)

		appendtoGraph/W=$(grabwin(slicename)+"#"+stringFromList(0,childWindowList(grabwin(slicename))))/VERT $Zpp
		ModifyGraph/W=$(grabwin(slicename)+"#"+stringFromList(0,childWindowList(grabwin(slicename)))) lsize($Zpp)=2,rgb($Zpp)=(0,0,0),nticks(bottom)=10,minor(bottom)=1
		SetActiveSubwindow ##
	//** SetVariable of Layer energy
		SetVariable setvarz_cons win=$grabwin(slicename),title="Z",size={65,14},value=z_cons,proc=SetVarProc_Cons3dplot
		SetVariable setvarz_cons win=$grabwin(slicename),limits={dimoffset($mat3dn_cons,zn_cons),(dimoffset($mat3dn_cons,zn_cons)+dimdelta($mat3dn_cons,zn_cons)*(dimsize($mat3dn_cons,zn_cons)-1)),dimdelta($mat3dn_cons,zn_cons)}

	//**PopoMenu of Normalization or not
		variable setnormcurrentitem
		if (Znorm_cons == 2)
			setnormcurrentitem = 2
		else
			setnormcurrentitem = 1
		endif
		PopupMenu popupnormornot win=$grabwin(slicename),pos={300,406},proc=PopMenuProc_Znormornot,value="No;Norm",mode=setnormcurrentitem //Yes is 2, No is 1

	//** Knob to launch linecut
		Button launchLinecut win=$grabwin(slicename),title="Linecut",size={82,14},pos={70,1},fSize=10,proc=ButtonProc_Cons3dplotlcfmodel

	//** Cursor moving sts
		Cursor/W=$grabwin(slicename)/P/I/C=(1,65535,33232)/T=6 A $slicename 0,0
		//ShowInfo
		getsinglests($mat3dn_cons,0,0,zn_cons)

		string ssn = "sts_"+mat3dn_cons
		//display $ssn
		appendtoGraph/W=$(grabwin(slicename)+"#"+stringFromList(0,childWindowList(grabwin(slicename))))/R $ssn
		SetWindow $grabwin(slicename) hook(myHook)=myCursorMovedHook
		UpdateControls_3dp(slicename, "A", 0,0)






	//** Select subgroup average dI/dV
		Button subavedidv win=$grabwin(slicename), title="Grp.dI/dV",pos={320,445},size={60,15},fSize=10,proc=ButtonProc_subavedidv

	//** SetColor style
		variable/G divcolor_cons
		SetVariable setdiv_cons win=$grabwin(slicename),title="DivC",pos={1,75},size={65,14},value=divcolor_cons,limits={0,1,1},proc=SetVarProc_Cons3dplotdivc

		divcolor_cons = 1
		wavestats/Q $tpw()
		variable rangls = max(abs(V_max),abs(V_min))
		ModifyImage/W=$grabwinchild(tpw()) $tpw() ctab= {-rangls,rangls,:Packages:NewColortable:dvg_seismic,0};
		ColorScale/W=$grabwinchild(tpw())/C/N=textcc/X=-21.00/Y=5.00/F=0 heightPct=30,nticks=5,minor=1,tickLen=1.00,image=$tpw()//;ColorScale/W=$grabwinchild(Fexyd)/C/N=text0/F=0/A=MC/Y=-120 image=$Fexyd
		variable/G normornot_3dplot =2


	//** Turn off
		Button turnoffls3d title="BACK",size={45,18},valueColor=(0,0,0),fColor=(1,65535,33232),pos={356,1},proc=ButtonProc_lsturnoff3d

	//** make single spectra
		Button selecshowsp title="P",size={20,15},pos={279,407},fSize=10,proc=ButtonProc_selecshowsp

	//** Tile window
		tilewindows/WINS=grabwinnonew(slicename)/R/w=(30.5,10,83,85)/A=(1,1)

end
Function ButtonProc_Cons3dplotlcfmodel(ctrlName) : ButtonControl
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
		ModifyImage $linecutH ctab= {*,*,VioletOrangeYellow,1}
		variable/G FFTmode_3dplot
		Button turnoffls3d title="BACK",size={45,12},valueColor=(0,0,0),fColor=(1,65535,33232),proc=ButtonProc_lsturnoff3d
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
		ModifyImage $linecutV ctab= {*,*,VioletOrangeYellow,1}
		Button turnoffls3d title="BACK",size={45,12},valueColor=(0,0,0),fColor=(1,65535,33232),proc=ButtonProc_lsturnoff3d

		Modifygraph/W=$grabwinnonew(linecutV) width=400, height=200
		Label left "\\Z16\\F'times'\\f02E - E\\BF\\f00\\M\\F'times'\\Z16 (meV)"
		Label bottom "\\Z16\\f02k\\f00 (2π Å\\S\\Z10-1\\M\\Z16)"

		ModifyGraph/W=$grabwinnonew(linecutV) axThick=3,axRGB=(16385,65535,41303),tlblRGB=(16385,65535,41303),alblRGB=(16385,65535,41303)
		tilewindows/WINS=grabwinnonew(linecutV)/R/w=(56,0,100,30)/A=(1,1)

end
Function ButtonProc_Capturename_child(ctrlName) : ButtonControl
	String ctrlName
	Execute "Capturename_child()"
End
Proc Capturename_child()
	PauseUpdate
	Silent 1
	variable/G topgraphnum
	Variable/G topimagemin
	Variable/G topimagemax
	Variable/G minsetvar
	Variable/G maxsetvar
	Variable/G topimageminratio
	Variable/G topimagemaxratio
	String/G topgraphimage
	String/G topgraphname
	String/G topgraphcolor
	String/G topgraphcolorinv
	Variable/G timesg	= 3
	String thelist
	string thewinlist
	string iminfolist
	string colorinfolist1,colorinfolist
	string iminfo
	string minsetstr,maxsetstr
	Variable minsetvar,maxsetvar
	//thelist=ImageNameList("",";")
	topgraphimage=tpw()//StringFromList(topgraphnum, thelist , ";")
	//thewinlist=winlist("*",";","")
	topgraphname=grabwinchild(tpw())   //StringFromList(1, thewinlist , ";")
	print topgraphname
	print topgraphimage
	imagestats/Q $topgraphimage
	topimagemin=V_min
	topimagemax=V_max
	iminfolist=ImageInfo(topgraphname,topgraphimage,0)
//	print iminfolist
	iminfo=StringFromList(10, iminfolist , ";")
	colorinfolist1=iminfo[18,strlen(iminfo)-2]
	colorinfolist=colorinfolist1+","
	minsetstr=StringFromList(0, colorinfolist , ",")
	maxsetstr=StringFromList(1, colorinfolist , ",")
	topgraphcolor=StringFromList(2, colorinfolist , ",")
	topgraphcolorinv=StringFromList(3, colorinfolist , ",")
	IF(cmpstr(minsetstr,"*")==0)
		minsetvar=topimagemin
		ELSE
			minsetvar=str2num(minsetstr)
	Endif
	IF(cmpstr(maxsetstr,"*")==0)
		maxsetvar=topimagemax
		ELSE
			maxsetvar=str2num(maxsetstr)
	Endif
	topimageminratio=(minsetvar-topimagemin)/(topimagemax-topimagemin)
	topimagemaxratio=(maxsetvar-topimagemin)/(topimagemax-topimagemin)
	slider topimagetop value=topimagemaxratio
	slider topimagebot value=topimageminratio
	IF(str2num(topgraphcolorinv)==0)
		Popupmenu popupinvmatcolor mode=1
		Else
			Popupmenu popupinvmatcolor mode=2
	Endif
	gethistgram_np()

	//string name = topgraphimage
	//wavestats/Q $name
	//String namehist = name+"_hist"
	//Make/N=2000/O $namehist
	//Histogram/B={V_min,(V_max-V_min)/2000,2000} $name,$namehist
	//wavestats/Q $namehist
	//K2 = V_maxloc;
	//CurveFit/H="0010"/Q gauss $namehist /D


	//** Error message, no stop but Continuing execution
		String msg
		Variable err
		msg=GetErrMessage(GetRTError(0),3);
		err=GetRTError(1)
		if (err != 0)
			Print "Error in Demo: " + msg
			Print "Continuing execution"
		endif
End



///////////////////////////////////////////////////////////////////////
//Draw axis

Function ButtonProc_Drawarrowy(ctrlName) : ButtonControl
	String ctrlName
	Execute "Drawarrowc()"
End

Proc Drawarrowc(zerox,zeroy,angle,length)
	variable zerox = 0.1//0.1
	variable zeroy = 0.95 //0.95
	variable angle = 55
	variable length = 0.08 //0.1
	prompt zerox,"Plot relative Ox"
	prompt zeroy,"Plot relative Oy"
	prompt angle,"axis angle"
	prompt length,"axis length"

	Drawarrow(zerox,zeroy,angle,length)
end

Function Drawarrow(zerox,zeroy,angle,length)
	variable zerox
	variable zeroy
	variable angle
	variable length

	Drawarrowx(zerox,zeroy,angle,length)
	Drawarrowy(zerox,zeroy,angle+90,length)

	Drawarrowa(zerox,zeroy,angle-45,length)
	Drawarrowb(zerox,zeroy,angle+45,length)
end

Function Drawarrowx(zerox,zeroy,angle,length)
	variable zerox
	variable zeroy
	variable angle
	variable length

	variable x0,y0,x1,y1
	variable xx1,yy1

	GetWindow $winname(0,1) gsize
	variable xsize = abs(v_left-v_right)
	variable ysize = abs(v_top-v_bottom)
	variable yvxratio = ysize/xsize

	x0 = zerox
	y0 = zeroy
	x1 = x0+length*cos(angle*pi/180)
	y1 = y0-length*sin(angle*pi/180)/yvxratio

	SetDrawEnv/W=$winname(0,1) arrow = 1,linefgc= (65535,0,0);DrawLine/W=$winname(0,1) x0,y0,x1,y1
	SetDrawEnv/W=$winname(0,1) textrgb= (65535,0,0);DrawText/W=$winname(0,1) x1,y1,"x"

end



Function Drawarrowy(zerox,zeroy,angle,length)
	variable zerox
	variable zeroy
	variable angle
	variable length

	variable x0,y0,x1,y1
	variable xx1,yy1

	GetWindow $winname(0,1) gsize
	variable xsize = abs(v_left-v_right)
	variable ysize = abs(v_top-v_bottom)
	variable yvxratio = ysize/xsize

	x0 = zerox
	y0 = zeroy
	x1 = x0+length*cos(angle*pi/180)
	y1 = y0-length*sin(angle*pi/180)/yvxratio

	SetDrawEnv/W=$winname(0,1) arrow = 1,linefgc= (65535,0,0);DrawLine/W=$winname(0,1) x0,y0,x1,y1
	SetDrawEnv/W=$winname(0,1) textrgb= (65535,0,0);DrawText/W=$winname(0,1) x1,y1,"y"

end

Function Drawarrowa(zerox,zeroy,angle,length)
	variable zerox
	variable zeroy
	variable angle
	variable length

	variable x0,y0,x1,y1
	variable xx1,yy1

	GetWindow $winname(0,1) gsize
	variable xsize = abs(v_left-v_right)
	variable ysize = abs(v_top-v_bottom)
	variable yvxratio = ysize/xsize

	x0 = zerox
	y0 = zeroy
	x1 = x0+length*cos(angle*pi/180)
	y1 = y0-length*sin(angle*pi/180)/yvxratio

	SetDrawEnv/W=$winname(0,1) arrow = 1,linefgc= (0,0,65535);DrawLine/W=$winname(0,1) x0,y0,x1,y1
	SetDrawEnv/W=$winname(0,1) textrgb= (0,0,65535);DrawText/W=$winname(0,1) x1,y1,"a"

end

Function Drawarrowb(zerox,zeroy,angle,length)
	variable zerox
	variable zeroy
	variable angle
	variable length

	variable x0,y0,x1,y1
	variable xx1,yy1

	GetWindow $winname(0,1) gsize
	variable xsize = abs(v_left-v_right)
	variable ysize = abs(v_top-v_bottom)
	variable yvxratio = ysize/xsize

	x0 = zerox
	y0 = zeroy
	x1 = x0+length*cos(angle*pi/180)
	y1 = y0-length*sin(angle*pi/180)/yvxratio

	SetDrawEnv/W=$winname(0,1) arrow = 1,linefgc= (0,0,65535);DrawLine/W=$winname(0,1) x0,y0,x1,y1
	SetDrawEnv/W=$winname(0,1) textrgb= (0,0,65535);DrawText/W=$winname(0,1) x1,y1,"b"

end

/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
//Contour tracor by cursor
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Csrtracor1(ctrlName) : ButtonControl
	String ctrlName
	Button Csrtracor win=$winname(0,1),title="Cursor Tracor",proc=ButtonProc_Csrtracor
	Button Csrtracor size={100,20}
End

Function ButtonProc_Csrtracor(ctrlName) : ButtonControl
	String ctrlName
	Execute "Csrtracor()"
end

Proc Csrtracor()
	savexypairbycursor()
end

Function savexypairbycursor()
	make/o/n=0 xcoorwave,ycoorwave

	//Cursor/W=winname(0,1)/P/I/C=(1,65535,33232)/T=6 A $slicename 0,0
	SetWindow $winname(0,1) hook(myHook)=myCursorMovedHook2c

	edit xcoorwave,ycoorwave
end
Function myCursorMovedHook2c(s)
	STRUCT WMWinHookStruct &s
	Variable statusCode= 0
	strswitch( s.eventName )
		case "cursormoved":
			// see "Members of WMWinHookStruct Used with cursormoved Code"
				//UpdateControls_3dp2c(s.traceName, s.cursorName, s.pointNumber, s.yPointNumber)

			wave xcoorwave = $"xcoorwave"
			wave ycoorwave = $"ycoorwave"
			InsertPoints (dimsize(xcoorwave,0)+1),1, xcoorwave
			InsertPoints (dimsize(ycoorwave,0)+1),1, ycoorwave
			xcoorwave[dimsize(xcoorwave,0)-1] = hcsr(A)
			ycoorwave[dimsize(ycoorwave,0)-1] = vcsr(A)


			//dimsize(xcoorwave,0)

			break
	endswitch
	return statusCode
End

//////////////////////////////////////////////////////////////////////////////////
// Extract every dI/dV curve from a 3D wave and make a linecut from it.
//////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Gridtolinecutc(ctrlName) : ButtonControl//"Load BNL Data in Folder"
	String ctrlName
	Execute "Gridtolinecutc()"
End

Proc Gridtolinecutc(grid,indexdim)
	string grid
	variable indexdim = 2
	prompt grid,"Name of the 3Dwave",popup getall3dwave()
	prompt indexdim,"Energy dimension index"

	Gridtolinecut($grid,indexdim)
end


Function Gridtolinecut(grid,indexdim)
	wave grid //3Dwave
	variable indexdim // the dimensional index of energy

	//** Auto ordering layer index
		make/o/N=3 ordernum ={0,1,2}
		ordernum=abs(ordernum-indexdim)
		wavestats/Q ordernum
		ordernum={0,1,2}
		DeletePoints V_minloc,1, ordernum
		wavestats/Q ordernum
		variable xn = ordernum[V_minloc]
		variable yn = ordernum[V_maxloc]
		killwaves ordernum
		//print num2str(xn)+" "+num2str(yn)


	string linecut = nameofwave(grid)+"_linecut"
	make/o/n=(dimsize(grid,indexdim),dimsize(grid,yn)*dimsize(grid,xn)) $linecut
	setscale/p x,dimoffset(grid,indexdim),dimdelta(grid,indexdim),"",$linecut
	//setscale/p y,dimoffset(grid,1),dimdelta(grid,1),"",$linecut
	wave linecutw = $linecut

	variable i,j,k,index


		index = 0
		k=0
		do
			i=0
			do
				j=0
				do

					if (indexdim == 2)
						linecutw[j][index] = grid[i][k][j]
					endif


					if (indexdim == 1)
						linecutw[j][index] = grid[i][j][k]
					endif

					if (indexdim == 0)
						linecutw[j][index] = grid[j][i][k]
					endif



				j+=1
				while (j<dimsize(grid,indexdim))
			index+=1
			i+=1
			while (i<dimsize(grid,xn))
		k+=1
		while (k<dimsize(grid,yn))


	di(linecutw)
end

