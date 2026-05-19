#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
// Simulation of 2D gap modulation with 2 gaps
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_choiceparameterc(ctrlName) : ButtonControl
	String ctrlName
	execute "choiceparameterc()"
end

Proc choiceparameterc()//(ampw1,ampw2,ampini1,ampini2,ampg1,ampg2,ampgini1,ampgini2)
	variable ampw1 = 0.025 // amplitude of the width of gap 1
	variable ampw2 = 0.025 // amplitude of the width of gap 2
	variable ampini1 = 0.07 // average of the width of gap 1
	variable ampini2 = 0.07 // average of the width of gap 2
	variable ampg1 = 0.22 // amplitude of the size of gap 1
	variable ampg2 = 0.31 // amplitude of the size of gap 2
	variable ampgini1 = 1.4 // average of the size of gap 1
	variable ampgini2 = 1.9 // average of the size of gap 2
	choiceparametercf(ampw1,ampw2,ampini1,ampini2,ampg1,ampg2,ampgini1,ampgini2)

end

Function choiceparametercf(ampw1,ampw2,ampini1,ampini2,ampg1,ampg2,ampgini1,ampgini2)
	variable ampw1 //= 0.025 // amplitude of the width of gap 1
	variable ampw2 //= 0.03 // amplitude of the width of gap 2
	variable ampini1 //= 0.07 // average of the width of gap 1
	variable ampini2 //= 0.07 // average of the width of gap 2
	variable ampg1 //= 0.22 // amplitude of the size of gap 1
	variable ampg2 //= 0.31 // amplitude of the size of gap 2
	variable ampgini1 //= 1.4 // average of the size of gap 1
	variable ampgini2 //= 1.9 // average of the size of gap 2

	variable dphid1 = pi //phi of the gap size 1
	variable dphid2 = pi // phi of the gap size 2
	variable dphih1 = pi // phi of the peak height 1
	variable dphih2 = 0 // phi of peak height 2
	variable shrinkratio = 0.3 // LDOS reduction ratio for the peak 2

	variable/G ampw1_simuSISTM = ampw1 //=0.025 // amplitude of the width of gap 1
	variable/G ampw2_simuSISTM = ampw2 //=0.025 // amplitude of the width of gap 2
	variable/G ampini1_simuSISTM = ampini1 //=0.07 // average of the width of gap 1
	variable/G ampini2_simuSISTM = ampini2//=0.07 // average of the width of gap 2
	variable/G ampg1_simuSISTM = ampg1 //=0.22 // amplitude of the size of gap 1
	variable/G ampg2_simuSISTM = ampg2 //=0.31 // amplitude of the size of gap 2
	variable/G ampgini1_simuSISTM = ampgini1 //=1.4 // average of the size of gap 1
	variable/G ampgini2_simuSISTM = ampgini2 //=1.9 // average of the size of gap 2

	variable/G dphid1_simuSISTM = dphid1 //=pi //phi of the gap size 1
	variable/G dphid2_simuSISTM = dphid2 //=pi // phi of the gap size 2
	variable/G dphih1_simuSISTM = dphih1 // =pi // phi of the peak height 1
	variable/G dphih2_simuSISTM = dphih2 // =0 // phi of peak height 2
	variable/G shrinkratio_simuSISTM = shrinkratio //= 6 // LDOS reduction ratio for the peak 2
	variable/G slice_simuSISTM = 0
	variable/G gaponwhich_simuSISTM = 1 //gap maximum at Se site
	variable/G linecutslice_simuPDM = 0
	variable/G tt2_simuSISTM = 2.5
	variable/G convornot_simuSISTM = 0
	variable/G convmode_SimuPDM = 2 //1: guassian, 2: differentiated FD

	make/o/n=(512,500) simu1line
	setscale/I y, 0,20*sqrt(2),"",simu1line
	setscale/I x, -5,5,"",simu1line
	simu1line = 0
	choiceparameter(ampw1,ampw2,ampini1,ampini2,ampg1,ampg2,ampgini1,ampgini2,dphid1,dphid2,dphih1,dphih2,shrinkratio)



	//# Window1
		display/N=PDMlinecut2peaksimu; ModifyGraph margin(top)=72; modifygraph width=1400,height=800
		Display/HOST=#/W=(0,0.1,0.25,0.75);
		appendimage simu1line;ModifyGraph mirror=2;
		ModifyImage simu1line ctab= {*,*,VioletOrangeYellow,0};
		//color3s($tpw(),30)
		Label left "\\Z18 b [the trace of: x=y] (Å)"

		make/n=2/o indisimu1,indisimu2
		setscale/i x, dimoffset(simu1line,0), dimoffset(simu1line,0)+(dimsize(simu1line,0)-1)*dimdelta(simu1line,0),"",indisimu1,indisimu2
		indisimu1 = dimoffset(simu1line,1)+slice_simuSISTM*dimdelta(simu1line,1)
		indisimu2 = dimoffset(simu1line,1)+(slice_simuSISTM+48)*dimdelta(simu1line,1)

		appendtograph indisimu1 indisimu2
		ModifyGraph rgb(indisimu1)=(0,0,65535)



	//# Window2
		duplicate/o simu1line simu1line_conv

		//string simu1line = "simu1line"

		if (convornot_simuSISTM == 1)
			if (tt2_simuSISTM == 0)
				simu1line_conv = simu1line
			else
				tconvchoiceparameter(tt2_simuSISTM)
			endif
		endif

		setActiveSubwindow ##;
		Display/HOST=#/W=(0.25,0.1,0.5,0.75);
		appendimage simu1line_conv;
		ModifyGraph mirror=2;
		ModifyImage simu1line_conv ctab= {*,*,VioletOrangeYellow,0};
		//color3s($tpw(),30)
		Label left "\\Z18 b [the trace of: x=y] (Å)"

		make/n=2/o indisimuconv1,indisimuconv2
		setscale/i x, dimoffset(simu1line_conv,0), dimoffset(simu1line_conv,0)+(dimsize(simu1line_conv,0)-1)*dimdelta(simu1line_conv,0),"",indisimuconv1,indisimuconv2
		indisimuconv1 = dimoffset(simu1line_conv,1)+slice_simuSISTM*dimdelta(simu1line_conv,1)
		indisimuconv2 = dimoffset(simu1line_conv,1)+(slice_simuSISTM+48)*dimdelta(simu1line_conv,1)

		appendtograph indisimuconv1 indisimuconv2
		ModifyGraph rgb(indisimuconv1)=(0,0,65535)



	//# Window3
		setActiveSubwindow ##;
		Display/HOST=#/W=(0,0.75,0.25,1);
		make/o/N=(dimsize(simu1line,0)) simu1line_1,simu1line_2
		setscale/p x,dimoffset(simu1line,0),dimdelta(simu1line,0),"",simu1line_1,simu1line_2
		simu1line_1[] = simu1line[p][slice_simuSISTM]
		simu1line_2[] = simu1line[p][slice_simuSISTM+48]
		appendtograph simu1line_1 simu1line_2
		ModifyGraph mirror=2
		ModifyGraph rgb(simu1line_1)=(0,0,65535)


	//# Window4
		setActiveSubwindow ##;
		Display/HOST=#/W=(0.25,0.75,0.5,1);
		make/o/N=(dimsize(simu1line,0)) simu1lineconv_1,simu1lineconv_2
		setscale/p x,dimoffset(simu1line,0),dimdelta(simu1line,0),"",simu1lineconv_1,simu1lineconv_2
		simu1lineconv_1[] = simu1line_conv[p][slice_simuSISTM]
		simu1lineconv_2[] = simu1line_conv[p][slice_simuSISTM+48]
		appendtograph simu1lineconv_1 simu1lineconv_2
		ModifyGraph mirror=2
		ModifyGraph rgb(simu1lineconv_1)=(0,0,65535)


	//# Window5group

		//calculate topo
		make/o/n=(100,100) topo_simuPDM
		setscale/i x,0,20,"",topo_simuPDM
		setscale/i y,0,20,"",topo_simuPDM
		topo_simuPDM = cos((2*pi/3.8)*x)+cos((2*pi/3.8)*y)

		//calculate gap1 gap2
		make/o/n=(100,100) d1_simuPDM,d2_simuPDM
		setscale/i x,0,20,"",d1_simuPDM,d2_simuPDM
		setscale/i y,0,20,"",d1_simuPDM,d2_simuPDM
		d1_simuPDM = (ampgini1+ ampg1*(cos((2*pi/3.8)*x+dphid1)+cos((2*pi/3.8)*y+dphid1)))
		d2_simuPDM = (ampgini2+ ampg2*(cos((2*pi/3.8)*x+dphid2)+cos((2*pi/3.8)*y+dphid2)))

		//calculate height1 height2
		make/o/n=(100,100) h1_simuPDM,h2_simuPDM
		setscale/i x,0,20,"",h1_simuPDM,h2_simuPDM
		setscale/i y,0,20,"",h1_simuPDM,h2_simuPDM
		h1_simuPDM = (1-shrinkratio)*(abs(real( (( ampgini1+ ampg1*(cos((2*pi/3.8)*x+dphid1)+cos((2*pi/3.8)*y+dphid1)) )-cmplx(0,(ampini1 + ampw1*(cos((2*pi/3.8)*x+(dphih1-pi))+cos((2*pi/3.8)*y+(dphih1-pi))) )))/sqrt( (( ampgini1+ ampg1*(cos((2*pi/3.8)*x+dphid1)+cos((2*pi/3.8)*y+dphid1)) )-cmplx(0,(ampini1 + ampw1*(cos((2*pi/3.8)*x+(dphih1-pi))+cos((2*pi/3.8)*y+(dphih1-pi))) )))^2 - ( ampgini1+ ampg1*(cos((2*pi/3.8)*x+dphid1)+cos((2*pi/3.8)*y+dphid1)) )^2 ) )))  +shrinkratio*(abs(real( (( ampgini1+ ampg1*(cos((2*pi/3.8)*x+dphid1)+cos((2*pi/3.8)*y+dphid1)) )-cmplx(0,(ampini2 + ampw2*(cos((2*pi/3.8)*x+(dphih2-pi))+cos((2*pi/3.8)*y+(dphih2-pi))) )))/sqrt( (( ampgini1+ ampg1*(cos((2*pi/3.8)*x+dphid1)+cos((2*pi/3.8)*y+dphid1)) )-cmplx(0,(ampini2 + ampw2*(cos((2*pi/3.8)*x+(dphih2-pi))+cos((2*pi/3.8)*y+(dphih2-pi))) )))^2 - ( ampgini2+ ampg2*(cos((2*pi/3.8)*x+dphid2)+cos((2*pi/3.8)*y+dphid2)) )^2 ) )))
		h2_simuPDM = (1-shrinkratio)*(abs(real( (( ampgini2+ ampg2*(cos((2*pi/3.8)*x+dphid2)+cos((2*pi/3.8)*y+dphid2)) )-cmplx(0,(ampini1 + ampw1*(cos((2*pi/3.8)*x+(dphih1-pi))+cos((2*pi/3.8)*y+(dphih1-pi))) )))/sqrt( (( ampgini2+ ampg2*(cos((2*pi/3.8)*x+dphid2)+cos((2*pi/3.8)*y+dphid2)) )-cmplx(0,(ampini1 + ampw1*(cos((2*pi/3.8)*x+(dphih1-pi))+cos((2*pi/3.8)*y+(dphih1-pi))) )))^2 - ( ampgini1+ ampg1*(cos((2*pi/3.8)*x+dphid1)+cos((2*pi/3.8)*y+dphid1)) )^2 ) ))) + shrinkratio*(abs(real( (( ampgini2+ ampg2*(cos((2*pi/3.8)*x+dphid2)+cos((2*pi/3.8)*y+dphid2)) )-cmplx(0,(ampini2 + ampw2*(cos((2*pi/3.8)*x+(dphih2-pi))+cos((2*pi/3.8)*y+(dphih2-pi))) )))/sqrt( (( ampgini2+ ampg2*(cos((2*pi/3.8)*x+dphid2)+cos((2*pi/3.8)*y+dphid2)) )-cmplx(0,(ampini2 + ampw2*(cos((2*pi/3.8)*x+(dphih2-pi))+cos((2*pi/3.8)*y+(dphih2-pi))) )))^2 - ( ampgini2+ ampg2*(cos((2*pi/3.8)*x+dphid2)+cos((2*pi/3.8)*y+dphid2)) )^2 ) )))

		//empty wave for gap size and height extraction
		make/o/n=(100,100) hextract_simuPDM,gextract_simuPDM
		setscale/i x,0,20,"",hextract_simuPDM,gextract_simuPDM
		setscale/i y,0,20,"",hextract_simuPDM,gextract_simuPDM
		hextract_simuPDM = 0
		gextract_simuPDM = 0

		make/n=1/o axindi_simuPDM,ayindi_simuPDM,bxindi_simuPDM,byindi_simuPDM
		axindi_simuPDM = indisimuconv1*sqrt(2)/2
		ayindi_simuPDM = indisimuconv1*sqrt(2)/2
		bxindi_simuPDM = indisimuconv2*sqrt(2)/2
		byindi_simuPDM = indisimuconv2*sqrt(2)/2


		//setActiveSubwindow ##;
		//Display/HOST=#/W=(0.5,0.33-0.25,0.66,0.33);

		//display calculated gap1
		setActiveSubwindow ##;
		Display/HOST=#/W=(0.66,0.33-0.25,0.82,0.33);
		appendimage d1_simuPDM
		ModifyGraph width={Plan,1,bottom,left},mirror=2,nticks=0,noLabel=2
		ModifyImage d1_simuPDM ctab= {*,*,BlueGreenOrange,0}
		ColorScale/C/N=text0/A=LC/X=101/Y=0/F=0 frame=0.00,image=$tpw()
		appendmatrixContour topo_simuPDM
		ModifyContour topo_simuPDM autoLevels={1.7,1.7,1}
		ModifyGraph rgb=(65535,0,0)

		appendtograph ayindi_simuPDM vs axindi_simuPDM
		appendtograph byindi_simuPDM vs bxindi_simuPDM
		ModifyGraph mode(ayindi_simuPDM)=3,marker(ayindi_simuPDM)=59,mode(byindi_simuPDM)=3,marker(byindi_simuPDM)=59
		ModifyGraph rgb(ayindi_simuPDM)=(0,0,65535)
		ModifyGraph mrkThick(ayindi_simuPDM)=2,mrkThick(byindi_simuPDM)=2
		TextBox/C/N=text1/F=0/A=LT/X=-2/Y=-2.00 "\\Z14\\$WMTEX$ \\Delta_{1}(r) \\$/WMTEX$: Calculated"

		//display calculated gap2
		setActiveSubwindow ##;
		Display/HOST=#/W=(0.82,0.33-0.25,0.98,0.33);
		appendimage d2_simuPDM
		ModifyGraph width={Plan,1,bottom,left},mirror=2,nticks=0,noLabel=2
		ModifyImage d2_simuPDM ctab= {*,*,BlueGreenOrange,0}
		ColorScale/C/N=text0/A=LC/X=101/Y=0/F=0 frame=0.00,image=$tpw()
		appendmatrixContour topo_simuPDM
		ModifyContour topo_simuPDM autoLevels={1.7,1.7,1}
		ModifyGraph rgb=(65535,0,0)

		appendtograph ayindi_simuPDM vs axindi_simuPDM
		appendtograph byindi_simuPDM vs bxindi_simuPDM
		ModifyGraph mode(ayindi_simuPDM)=3,marker(ayindi_simuPDM)=59,mode(byindi_simuPDM)=3,marker(byindi_simuPDM)=59
		ModifyGraph rgb(ayindi_simuPDM)=(0,0,65535)
		ModifyGraph mrkThick(ayindi_simuPDM)=2,mrkThick(byindi_simuPDM)=2
		TextBox/C/N=text1/F=0/A=LT/X=-2/Y=-2.00 "\\Z14\\$WMTEX$ \\Delta_{2}(r) \\$/WMTEX$: Calculated"



		//display calculated topo
		setActiveSubwindow ##;
		Display/HOST=#/W=(0.5,0.66-0.25-0.12,0.66,0.66-0.12);
		appendimage topo_simuPDM
		ModifyGraph width={Plan,1,bottom,left},mirror=2,nticks=0,noLabel=2
		ModifyImage topo_simuPDM ctab= {*,*,Mud,0}
		appendmatrixContour topo_simuPDM
		ModifyContour topo_simuPDM autoLevels={1.7,1.7,1}
		ColorScale/C/N=text0/A=LC/X=101/Y=0/F=0 frame=0.00,image=$tpw()

		appendtograph ayindi_simuPDM vs axindi_simuPDM
		appendtograph byindi_simuPDM vs bxindi_simuPDM
		ModifyGraph mode(ayindi_simuPDM)=3,marker(ayindi_simuPDM)=59,mode(byindi_simuPDM)=3,marker(byindi_simuPDM)=59
		ModifyGraph rgb(ayindi_simuPDM)=(0,0,65535)
		ModifyGraph mrkThick(ayindi_simuPDM)=2,mrkThick(byindi_simuPDM)=2
		TextBox/C/N=text1/F=0/A=LT/X=-2/Y=-2.00 "\\Z14\\$WMTEX$ T(r) \\$/WMTEX$: Calculated"

		//display calculated height1
		setActiveSubwindow ##;
		Display/HOST=#/W=(0.66,0.66-0.25-0.1-0.02,0.82,0.66-0.1-0.02);
		appendimage h1_simuPDM
		ModifyGraph width={Plan,1,bottom,left},mirror=2,nticks=0,noLabel=2
		ModifyImage h1_simuPDM ctab= {*,*,BrownViolet,0}
		ColorScale/C/N=text0/A=LC/X=101/Y=0/F=0 frame=0.00,image=$tpw()
		appendmatrixContour topo_simuPDM
		ModifyContour topo_simuPDM autoLevels={1.7,1.7,1}
		ModifyGraph rgb=(65535,0,0)

		appendtograph ayindi_simuPDM vs axindi_simuPDM
		appendtograph byindi_simuPDM vs bxindi_simuPDM
		ModifyGraph mode(ayindi_simuPDM)=3,marker(ayindi_simuPDM)=59,mode(byindi_simuPDM)=3,marker(byindi_simuPDM)=59
		ModifyGraph rgb(ayindi_simuPDM)=(0,0,65535)
		ModifyGraph mrkThick(ayindi_simuPDM)=2,mrkThick(byindi_simuPDM)=2
		TextBox/C/N=text1/F=0/A=LT/X=-2/Y=-2.00 "\\Z14\\$WMTEX$ \\frac{dI}{dV}(\\Delta_{1}) \\$/WMTEX$: Calculated"

		//display calculated height2
		setActiveSubwindow ##;
		Display/HOST=#/W=(0.82,0.66-0.25-0.1-0.02,0.98,0.66-0.1-0.02);
		appendimage h2_simuPDM
		ModifyGraph width={Plan,1,bottom,left},mirror=2,nticks=0,noLabel=2
		ModifyImage h2_simuPDM ctab= {*,*,BrownViolet,0}
		ColorScale/C/N=text0/A=LC/X=101/Y=0/F=0 frame=0.00,image=$tpw()
		appendmatrixContour topo_simuPDM
		ModifyContour topo_simuPDM autoLevels={1.7,1.7,1}
		ModifyGraph rgb=(65535,0,0)

		appendtograph ayindi_simuPDM vs axindi_simuPDM
		appendtograph byindi_simuPDM vs bxindi_simuPDM
		ModifyGraph mode(ayindi_simuPDM)=3,marker(ayindi_simuPDM)=59,mode(byindi_simuPDM)=3,marker(byindi_simuPDM)=59
		ModifyGraph rgb(ayindi_simuPDM)=(0,0,65535)
		ModifyGraph mrkThick(ayindi_simuPDM)=2,mrkThick(byindi_simuPDM)=2
		TextBox/C/N=text1/F=0/A=LT/X=-2/Y=-2.00 "\\Z14\\$WMTEX$ \\frac{dI}{dV}(\\Delta_{2}) \\$/WMTEX$: Calculated"

		//setActiveSubwindow ##;
		//Display/HOST=#/W=(0.5,0.99-0.25-0.24,0.66,0.99-0.24);

		setActiveSubwindow ##;
		Display/HOST=#/W=(0.66,0.99-0.25-0.24,0.82,0.99-0.24);
		appendimage gextract_simuPDM
		ModifyGraph width={Plan,1,bottom,left},mirror=2,nticks=0,noLabel=2
		ModifyImage gextract_simuPDM ctab= {*,*,BlueGreenOrange,0}
		ColorScale/C/N=text0/A=LC/X=101/Y=0/F=0 frame=0.00,image=$tpw()
		appendmatrixContour topo_simuPDM
		ModifyContour topo_simuPDM autoLevels={1.7,1.7,1}
		ModifyGraph rgb=(65535,0,0)

		appendtograph ayindi_simuPDM vs axindi_simuPDM
		appendtograph byindi_simuPDM vs bxindi_simuPDM
		ModifyGraph mode(ayindi_simuPDM)=3,marker(ayindi_simuPDM)=59,mode(byindi_simuPDM)=3,marker(byindi_simuPDM)=59
		ModifyGraph rgb(ayindi_simuPDM)=(0,0,65535)
		ModifyGraph mrkThick(ayindi_simuPDM)=2,mrkThick(byindi_simuPDM)=2
		TextBox/C/N=text1/F=0/A=LT/X=-2/Y=-2.00 "\\Z14\\$WMTEX$ \\Delta_{\\rm conv}(r) \\$/WMTEX$: Extracted"

		make/n=2/o linecutyindi_simupdm
		setscale/I x,0,20,"",linecutyindi_simupdm
		variable xindilinecut = dimoffset(topo_simuPDM,0)+dimdelta(topo_simuPDM,0)*linecutslice_simuPDM
		linecutyindi_simupdm = xindilinecut
		appendtograph/VERT linecutyindi_simupdm
		ModifyGraph rgb(linecutyindi_simupdm)=(0,0,0)


		setActiveSubwindow ##;
		Display/HOST=#/W=(0.82,0.99-0.25-0.24,0.98,0.99-0.24);
		appendimage hextract_simuPDM
		ModifyGraph width={Plan,1,bottom,left},mirror=2,nticks=0,noLabel=2
		ModifyImage hextract_simuPDM ctab= {*,*,BrownViolet,0}
		ColorScale/C/N=text0/A=LC/X=101/Y=0/F=0 frame=0.00,image=$tpw()
		appendmatrixContour topo_simuPDM
		ModifyContour topo_simuPDM autoLevels={1.7,1.7,1}
		ModifyGraph rgb=(65535,0,0)

		appendtograph ayindi_simuPDM vs axindi_simuPDM
		appendtograph byindi_simuPDM vs bxindi_simuPDM
		ModifyGraph mode(ayindi_simuPDM)=3,marker(ayindi_simuPDM)=59,mode(byindi_simuPDM)=3,marker(byindi_simuPDM)=59
		ModifyGraph rgb(ayindi_simuPDM)=(0,0,65535)
		ModifyGraph mrkThick(ayindi_simuPDM)=2,mrkThick(byindi_simuPDM)=2
		TextBox/C/N=text1/F=0/A=LT/X=-2/Y=-2.00 "\\Z14\\$WMTEX$ \\frac{dI}{dV}(\\Delta_{\\rm conv}, r) \\$/WMTEX$: Extracted"

		//more window
		make/o/n=(512,100) linecutxsimupdm_conv,linecutxsimupdm
		setscale/i x,-5,5,"",linecutxsimupdm_conv,linecutxsimupdm
		setscale/i y,0,20,"",linecutxsimupdm_conv,linecutxsimupdm
		linecutxsimupdm[][] = 1
		linecutxsimupdm_conv[][] = 1

		setActiveSubwindow ##;
		Display/HOST=#/W=(0.66+0.03,0.72,0.82+0.03-0.0423,1);
		appendimage linecutxsimupdm_conv
		ModifyGraph mirror=2
		ModifyImage linecutxsimupdm_conv ctab= {*,*,VioletOrangeYellow,0}
		Label left "\\Z10 y (Å)"
		TextBox/C/N=text1/F=0/A=LT/X=-0.5/Y=-0.5 "\\Z10 Convoluted"

		setActiveSubwindow ##;
		Display/HOST=#/W=(0.82+0.03,0.72,0.98+0.03-0.0423,1);
		appendimage linecutxsimupdm
		ModifyGraph mirror=2
		ModifyImage linecutxsimupdm ctab= {*,*,VioletOrangeYellow,0}
		Label left "\\Z10 y (Å)"
		TextBox/C/N=text1/F=0/A=LT/X=-0.5/Y=-0.5 "\\Z10 Dyne Data"

		setActiveSubwindow ##;
		Display/HOST=#/W=(0.5,0.75,0.7,1);

		make/n=2/o ratiod1_simupdm,ratiod2_simupdm,ratiodconv_simupdm
		setscale/i x,0,1,"",ratiod1_simupdm,ratiod2_simupdm,ratiodconv_simupdm
		ratiod1_simupdm[0] = 100*ampg1_simuSISTM/ampgini1_simuSISTM
		ratiod2_simupdm[0] = 100*ampg2_simuSISTM/ampgini2_simuSISTM
		wavestats/Q d1_simuPDM
		ratiod1_simupdm[1] = 100*(V_max-V_min)/(V_max+V_min)
		wavestats/Q d2_simuPDM
		ratiod2_simupdm[1] = 100*(V_max-V_min)/(V_max+V_min)
		wavestats/Q gextract_simuPDM
		ratiodconv_simupdm[1]  = 100*(V_max-V_min)/(V_max+V_min)

		//make/n=100/o gapx
		//gapx[] = gextract_simuPDM[0][p]
		//wavestats/Q gapx
		//ratiodconv_simupdm[0]  = 100*(V_max-V_min)/(V_max+V_min)
		//killwaves gapx
		ratiodconv_simupdm[0]  = ratiodconv_simupdm[1]/2

		appendtograph ratiod1_simupdm ratiod2_simupdm ratiodconv_simupdm

		ModifyGraph mirror=2
		Label left "\\Z10 Ratio (%)"
		SetAxis bottom -0.5,1.5
		ModifyGraph mode=3,marker=59,msize=5,mrkThick=2
		ModifyGraph msize=8,rgb(ratiod1_simupdm)=(0,0,0),rgb(ratiodconv_simupdm)=(0,0,65535)
		Legend/C/N=text0/J/F=0/B=1/A=LT/X=0.00/Y=0.00 "\\s(ratiod1_simupdm) \\$WMTEX$ \\Delta_{1} \\$/WMTEX$\r\\s(ratiod2_simupdm) \\$WMTEX$ \\Delta_{2} \\$/WMTEX$";DelayUpdate
		AppendText "\\s(ratiodconv_simupdm) \\$WMTEX$ \\Delta_{\\rm conv} \\$/WMTEX$"
		ModifyGraph grid(left)=2,minor(left)=1
		make/T/o/n=2 ratiolablet={"\\Z16\$WMTEX$ \frac{|\Delta^{i}_{Q}|}{\Delta^{i}_{0}} \$/WMTEX$", "\\Z16\$WMTEX$ \frac{\Delta_{max}-\Delta_{min}}{\Delta_{max}+\Delta_{min}} \$/WMTEX$"};
		make/o/n=2 ratiolablen={0,1}
		ModifyGraph userticks(bottom)={ratiolablen,ratiolablet}

		ModifyGraph marker(ratiod1_simupdm)=2
		ModifyGraph marker(ratiodconv_simupdm)=62

		setActiveSubwindow ##;


	//############# Initialize the controls
		SetVariable setvar0 title="\\$WMTEX$ \\left|\\Gamma_{\\rm Q}^{\\Delta_{1}}\\right| \\$/WMTEX$",limits={0,ampini1_simuSISTM/2,0.01}, size={80,20},value=ampw1_simuSISTM,proc=SetVarProc_simuSISTM1,pos={242,1}
		SetVariable setvar1 title="\\$WMTEX$ \\left|\\Gamma_{\\rm Q}^{\\Delta_{2}}\\right| \\$/WMTEX$",limits={0,ampini2_simuSISTM/2,0.01},size={80,20},value=ampw2_simuSISTM,proc=SetVarProc_simuSISTM1,pos={242,22}
		SetVariable setvar3 title="\\$WMTEX$ \\Gamma_{0}^{\\Delta_{1}} \\$/WMTEX$",limits={0,inf,0.01},size={80,20},value=ampini1_simuSISTM,proc=SetVarProc_simuSISTM1,pos={162,1}
		SetVariable setvar4 title="\\$WMTEX$ \\Gamma_{0}^{\\Delta_{2}} \\$/WMTEX$",limits={0,inf,0.01}, size={80,20},value=ampini2_simuSISTM,proc=SetVarProc_simuSISTM1,pos={162,22}

		SetVariable setvar5 title="\\$WMTEX$\\left| \\Delta^{1}_{\\rm Q}\\right|\\$/WMTEX$",limits={0,ampgini1_simuSISTM/2,0.1}, size={80,20},value=ampg1_simuSISTM,proc=SetVarProc_simuSISTM1,pos={82,1}
		SetVariable setvar6 title="\\$WMTEX$\\left| \\Delta^{2}_{\\rm Q}\\right|\\$/WMTEX$",limits={0,ampgini2_simuSISTM/2,0.1}, size={80,20},value=ampg2_simuSISTM,proc=SetVarProc_simuSISTM1,pos={82,22}
		SetVariable setvar7 title="\\$WMTEX$ \\Delta^{1}_{0}\\$/WMTEX$",limits={0,inf,0.1}, size={80,20},value=ampgini1_simuSISTM,proc=SetVarProc_simuSISTM1,pos={2,1}
		SetVariable setvar8 title="\\$WMTEX$ \\Delta^{2}_{0}\\$/WMTEX$",limits={0,inf,0.1}, size={80,20},value=ampgini2_simuSISTM,proc=SetVarProc_simuSISTM1,pos={2,22}

		SetVariable setvar9 title="\\$WMTEX$ \\delta\\phi^{\\Delta_{1}} \\$/WMTEX$",limits={0,pi,pi}, size={80,20},value=dphid1_simuSISTM,proc=SetVarProc_simuSISTM2,pos={322,1}
		SetVariable setvar10 title="\\$WMTEX$ \\delta\\phi^{\\Delta_{2}} \\$/WMTEX$",limits={0,pi,pi}, size={80,20},value=dphid2_simuSISTM,proc=SetVarProc_simuSISTM2,pos={322,22}
		SetVariable setvar11 title="\\$WMTEX$ \\delta\\phi^{\rm H_{1}} \\$/WMTEX$",limits={0,pi,pi}, size={80,20},value=dphih1_simuSISTM,proc=SetVarProc_simuSISTM2,pos={402,1}
		SetVariable setvar12 title="\\$WMTEX$ \\delta\\phi^{\rm H_{2}} \\$/WMTEX$",limits={0,pi,pi}, size={80,20},value=dphih2_simuSISTM,proc=SetVarProc_simuSISTM2,pos={402,22}

		SetVariable setvar13 title="\\$WMTEX$ r(\\Delta_{2}) \\$/WMTEX$ ",limits={0,1,0.1}, size={80,20},value=shrinkratio_simuSISTM,proc=SetVarProc_simuSISTM1,pos={207,45}

		SetVariable setvar14 title="\\$WMTEX$ T (\\rm K) \\$/WMTEX$ ",limits={0,inf,0.1}, size={80,20},value=tt2_simuSISTM,proc=SetVarProc_simuSISTM1,pos={510,56}
		PopupMenu pop1 title="Convolute",proc=PopMenuProc_simuSISTM1,value="No;Yes",mode=1,pos={500,30} //Yes is 2, No is 1

		Button button1 size={100,15},title="Make 3D",proc=ButtonProc_make3DfakeSISTMc,pos={775,532}
		Button button2 size={75,15},title="Show Raw",proc=ButtonProc_make3DfakeSISTMcraw,fSize=10,pos={746,552}
		Button button3 size={75,15},title="Show Conv",proc=ButtonProc_make3DfakeSISTMcconv,pos={828,552},fSize=10
		SetVariable setvar15 title="slice",limits={0,dimsize(simu1line,1)-49,2}, size={80,20},value=slice_simuSISTM,proc=SetVarProc_simuSISTM1slice,pos={321,636}

		PopupMenu pop2 title="\\$WMTEX$ r(\\Delta_{\\rm max}) \\$/WMTEX$",proc=PopMenuProc_simuSISTMSeFe,value="Se;Fe(x)",mode=1,pos={736,236} //Se is 1, Fe is 2
		Button button4 title="Extract \\$WMTEX$ \\Delta(\\rm Gaus) \\$/WMTEX$",pos={731,570},size={90,15}, proc=ButtonProc_gapdisGua2_forPDMsimu,fSize=10
		Button button5 title="Extract \\$WMTEX$ g(\\Delta) \\$/WMTEX$",proc=ButtonProc_gaph_forPDMsimu,size={90,15},pos={828,570},fSize=10
		SetVariable setvar16 title="mode",limits={1,2,1}, value=convmode_SimuPDM ,proc=SetVarProc_simuSISTM1convmode,pos={601,32},size={55,14}
		Button button6 title="Extract \\$WMTEX$ \\Delta(g_{\\rm max})\\$/WMTEX$ ",proc=ButtonProc_gapdisGua2_forPDMsimuc2,size={90,15},fSize=10,pos={731,588}
		SetVariable setvar17 title="x-slice",limits={0,99,1}, value=linecutslice_simuPDM ,proc=SetVarProc_simuSISTMlinecutx,pos={1130,825},size={65,14}
		Button turnoffls3d title="BACK",size={45,12},valueColor=(0,0,0),fColor=(1,65535,33232),proc=ButtonProc_lsturnoff3d,pos={1350,5}
		Button button7 title="Print Parameters",pos={1160,5},size={120,15},proc=ButtonProc_getparameterPDMsimu

		Button buttonexp1 title="1",size={20,20},fSize=13,fstyle=1,fColor=(0,65535,65535),valueColor=(26411,1,52428),pos={17,45},proc=ButtonProc_pdmsimu_example1
		Button buttonexp2 title="2",size={20,20},fSize=13,fstyle=1,fColor=(0,65535,65535),valueColor=(26411,1,52428),pos={17+24*1,45},proc=ButtonProc_pdmsimu_example2
		Button buttonexp3 title="3",size={20,20},fSize=13,fstyle=1,fColor=(0,65535,65535),valueColor=(26411,1,52428),pos={17+24*2,45},proc=ButtonProc_pdmsimu_example3
		Button buttonexp4 title="4",size={20,20},fSize=13,fstyle=1,fColor=(0,65535,65535),valueColor=(26411,1,52428),pos={17+24*3,45},proc=ButtonProc_pdmsimu_example4
		Button buttonexp5 title="5",size={20,20},fSize=13,fstyle=1,fColor=(0,65535,65535),valueColor=(26411,1,52428),pos={17+24*0,70},proc=ButtonProc_pdmsimu_example5
		Button buttonexp6 title="6",size={20,20},fSize=13,fstyle=1,fColor=(0,65535,65535),valueColor=(26411,1,52428),pos={17+24*1,70},proc=ButtonProc_pdmsimu_example6
		Button buttonexp7 title="7",size={20,20},fSize=13,fstyle=1,fColor=(0,65535,65535),valueColor=(26411,1,52428),pos={17+24*2,70},proc=ButtonProc_pdmsimu_example7
		Button buttonexp8 title="8",size={20,20},fSize=13,fstyle=1,fColor=(0,65535,65535),valueColor=(26411,1,52428),pos={17+24*3,70},proc=ButtonProc_pdmsimu_example8

		TextBox/C/N=text0/F=0/A=LT/X=10/Y=0.5 "\\Z18 Dyne Data"
		TextBox/C/N=text1/F=0/A=LT/X=35/Y=0.5 "\\Z18 Convoluted"

		TextBox/C/N=text2/F=0/A=MT/X=22.00/Y=-8/B=1 "\\Z10\\$WMTEX$ \\frac{dI}{dV}(E) =\\left[1-r(\\Delta_{2})\\right]\\left|{\\rm Dyne}(E,\\Delta_{1},\\Gamma_{1})\\right| +\\left[r(\\Delta_{2})\\right]\\left|{\\rm D";DelayUpdate
		AppendText /NOCR "yne}(E,\\Delta_{1},\\Gamma_{1})\\right|    \\$/WMTEX$;   \\$WMTEX$ {\\rm Dyne}(E,\\Delta,\\Gamma)= {\\rm Re}\\frac{E-i\\Gamma}{\\sqrt{(E-i\\Gamma)^{2}-\\Del";DelayUpdate
		AppendText /NOCR "ta^{2}}}\\$/WMTEX$\n\t\\$WMTEX$ \\Delta_{1}(r)=\\Delta^{1}_{0}+\\left|\\Delta_{\\rm Q}^{1}\\right|\\left[\\cos(q_{x}\\cdot x+\\delta\\phi^{\\Delta_{1}})+\\cos(";DelayUpdate
		AppendText /NOCR "q_{y}\\cdot y+\\delta\\phi^{\\Delta_{1}})\\right] \\$/WMTEX$;  \\$WMTEX$ \\Delta_{2}(r)=\\Delta^{2}_{0}+\\left|\\Delta_{\\rm Q}^{2}\\right|\\left[\\cos(q_{x}";DelayUpdate
		AppendText /NOCR "\\cdot x+\\delta\\phi^{\\Delta_{2}})+\\cos(q_{y}\\cdot y+\\delta\\phi^{\\Delta_{2}})\\right] \\$/WMTEX$\n\t\\$WMTEX$ \\Gamma_{1}(r)=\\Gamma^{1}_{0}+\\left|\\Gam";DelayUpdate
		AppendText /NOCR "ma_{\\rm Q}^{1}\\right|\\left[\\cos(q_{x}\\cdot x+\\delta\\phi^{H_{1}})+\\cos(q_{y}\\cdot y+\\delta\\phi^{H_{1}})\\right] \\$/WMTEX$;   \\$WMTEX$ \\Gamma_{2}";DelayUpdate
		AppendText /NOCR "(r)=\\Gamma^{2}_{0}+\\left|\\Gamma_{\\rm Q}^{2}\\right|\\left[\\cos(q_{x}\\cdot x+\\delta\\phi^{H_{2}})+\\cos(q_{y}\\cdot y+\\delta\\phi^{H_{2}})\\right] \\$/";DelayUpdate
		AppendText /NOCR "WMTEX$";DelayUpdate
		AppendText "\t\\$WMTEX$ q_{x} = (2\\pi/a,0) \\$/WMTEX$; \\$WMTEX$ q_{y} = (0, 2\\pi/a) \\$/WMTEX$; a = 3.8 Å\n\n#1: Caes of\\$WMTEX$ \\Delta \\$/WMTEX$ locking to Se: ";DelayUpdate
		AppendText "\tSe lattice: \\$WMTEX$ T(r) = \\cos(q_{x}\\cdot x)+\\cos(q_{y}\\cdot y) \\$/WMTEX$";DelayUpdate
		AppendText "\t\\$WMTEX$ \\Delta_{\\rm max} \\$/WMTEX$ at \\$WMTEX$ {\\rm Se}_{+} \\$/WMTEX$ if \\$WMTEX$ \\delta\\phi^{\\Delta} = 0 \\$/WMTEX$\n\t\\$WMTEX$ \\Delta_{\\rm max} \\$";DelayUpdate
		AppendText /NOCR "/WMTEX$ at \\$WMTEX$ {\\rm Se}_{-} \\$/WMTEX$ if \\$WMTEX$ \\delta\\phi^{\\Delta} = \\pi \\$/WMTEX$\n\n#2: Caes of\\$WMTEX$ \\Delta \\$/WMTEX$ locking to Fe";DelayUpdate
		AppendText /NOCR ": \n\tSe lattice: \\$WMTEX$ T(r) = \\cos(q_{x}\\cdot x+\\pi)+\\cos(q_{y}\\cdot y) \\$/WMTEX$\n\t\\$WMTEX$ \\Delta_{\\rm max} \\$/WMTEX$ at \\$WMTEX$ {\\rm Fe}_";DelayUpdate
		AppendText /NOCR "{x} \\$/WMTEX$ if \\$WMTEX$ \\delta\\phi^{\\Delta} = 0 \\$/WMTEX$\n\t\\$WMTEX$ \\Delta_{\\rm max} \\$/WMTEX$ at \\$WMTEX$ {\\rm Fe}_{y} \\$/WMTEX$ if \\$WMTEX";DelayUpdate
		AppendText /NOCR "$ \\delta\\phi^{\\Delta} = \\pi \\$/WMTEX$\n"

		TextBox/C/N=text3/F=0/B=1/A=MT/X=-8.50/Y=-8.00 "\\Z08\K(52428,1,1)\rConvolution Function       Mode 1: Gaussian\r                                         Mode 2: Fermi-Dirac"
		TextBox/C/N=text4/F=0/A=RC/X=37/Y=31 "\\K(52428,1,1)\\Z15Select Gap Lock Mode"
		TextBox/C/N=text5/F=0/A=RC/X=36/Y=-4.7 "\\K(52428,1,1)\\Z15          Extraction \r from convoluted data"
		TextBox/C/N=text6/F=0/A=RC/X=33.5/Y=-21 "\\K(52428,1,1)\\Z15Modulation Ratio (1D&2D)"
		TextBox/C/N=text7/F=0/A=RC/X=34.8/Y=1.8/B=1 "\\K(1,39321,19939)\\f01\\Z16 Convoluted Data Extraction \r \\Z10                                               (no auto-update)"
		Drawarrow(0.93,-0.03,0,0.02)
		SetDrawEnv fillpat= 0,linethick= 4.00,linefgc= (1,39321,19939),linethick= 6.00;DrawRect 0.495,0.457,1.021,0.993

		//** Error message, no stop but Continuing execution
		//String msg
		//Variable err
		//msg=GetErrMessage(GetRTError(0),3);
		//err=GetRTError(1)
		//if (err != 0)
		//	Print "Error in Demo: " + msg
		//	Print "Continuing execution"
		//endif
end

Function SetVarProc_simuSISTMlinecutx(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/G linecutslice_simuPDM

	wave simu1=$"simu1"
	wave simu1_conv = $"simu1_conv"
	wave topo_simuPDM = $"topo_simuPDM"

	if (waveexists(simu1) == 1)
		make/o/n=(512,100) linecutxsimupdm_conv,linecutxsimupdm
		setscale/i x,-5,5,"",linecutxsimupdm_conv,linecutxsimupdm
		setscale/i y,0,20,"",linecutxsimupdm_conv,linecutxsimupdm
		linecutxsimupdm[][] = simu1[linecutslice_simuPDM][q][p]
		linecutxsimupdm_conv[][] = simu1_conv[linecutslice_simuPDM][q][p]
	endif
	make/n=2/o linecutyindi_simupdm
	setscale/I x,0,20,"",linecutyindi_simupdm
	variable xindilinecut = dimoffset(topo_simuPDM,0)+dimdelta(topo_simuPDM,0)*linecutslice_simuPDM
	linecutyindi_simupdm = xindilinecut

	variable/G linecutslice_simuPDM
	wave gextract_simuPDM=$"gextract_simuPDM"
		make/n=2/o ratiodconv_simupdm
		setscale/i x,0,1,"",ratiodconv_simupdm

		wavestats/Q gextract_simuPDM
		ratiodconv_simupdm[1]  = 100*(V_max-V_min)/(V_max+V_min)

		//make/n=100/o gapx
		//gapx[] = gextract_simuPDM[0][p]
		//wavestats/Q gapx
		//ratiodconv_simupdm[0]  = 100*(V_max-V_min)/(V_max+V_min)
		//killwaves gapx
		ratiodconv_simupdm[0]  = ratiodconv_simupdm[1]/2
end

Function SetVarProc_simuSISTM1convmode(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/G tt2_simuSISTM


	tconvchoiceparameter(tt2_simuSISTM)
end

Function PopMenuProc_simuSISTMSeFe(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	variable/G gaponwhich_simuSISTM = popNum

	make/o/n=(100,100) topo_simuPDM
	setscale/i x,0,20,"",topo_simuPDM
	setscale/i y,0,20,"",topo_simuPDM

	if (gaponwhich_simuSISTM == 1)//Se
		topo_simuPDM = cos((2*pi/3.8)*x)+cos((2*pi/3.8)*y)
	endif

	if (gaponwhich_simuSISTM == 2)//Fe
		topo_simuPDM = cos((2*pi/3.8)*x+pi)+cos((2*pi/3.8)*y)
	endif


end

Function SetVarProc_simuSISTM1slice(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave simu1line = $"simu1line"
	wave simu1line_conv = $"simu1line_conv"
	variable/G slice_simuSISTM

	make/o/N=(dimsize(simu1line,0)) simu1line_1,simu1line_2
	setscale/p x,dimoffset(simu1line,0),dimdelta(simu1line,0),"",simu1line_1,simu1line_2
	simu1line_1[] = simu1line[p][slice_simuSISTM]
	simu1line_2[] = simu1line[p][slice_simuSISTM+48]


	make/o/N=(dimsize(simu1line,0)) simu1lineconv_1,simu1lineconv_2
	setscale/p x,dimoffset(simu1line,0),dimdelta(simu1line,0),"",simu1lineconv_1,simu1lineconv_2
	simu1lineconv_1[] = simu1line_conv[p][slice_simuSISTM]
	simu1lineconv_2[] = simu1line_conv[p][slice_simuSISTM+48]

	make/n=2/o indisimu1,indisimu2
	setscale/i x, dimoffset(simu1line,0), dimoffset(simu1line,0)+(dimsize(simu1line,0)-1)*dimdelta(simu1line,0),"",indisimu1,indisimu2
	indisimu1 = dimoffset(simu1line,1)+slice_simuSISTM*dimdelta(simu1line,1)
	indisimu2 = dimoffset(simu1line,1)+(slice_simuSISTM+48)*dimdelta(simu1line,1)

	make/n=2/o indisimuconv1,indisimuconv2
	setscale/i x, dimoffset(simu1line_conv,0), dimoffset(simu1line_conv,0)+(dimsize(simu1line_conv,0)-1)*dimdelta(simu1line_conv,0),"",indisimuconv1,indisimuconv2
	indisimuconv1 = dimoffset(simu1line_conv,1)+slice_simuSISTM*dimdelta(simu1line_conv,1)
	indisimuconv2 = dimoffset(simu1line_conv,1)+(slice_simuSISTM+48)*dimdelta(simu1line_conv,1)

	make/n=1/o axindi_simuPDM,ayindi_simuPDM,bxindi_simuPDM,byindi_simuPDM
	axindi_simuPDM = indisimuconv1*sqrt(2)/2
	ayindi_simuPDM = indisimuconv1*sqrt(2)/2
	bxindi_simuPDM = indisimuconv2*sqrt(2)/2
	byindi_simuPDM = indisimuconv2*sqrt(2)/2
end

//Function SetVarProc_simuSISTM1_dphid1(ctrlName,varNum,varStr,varName) : SetVariableControl
//	String ctrlName
//	Variable varNum
//	String varStr
//	String varName
//	variable/G dphid1_simuSISTM = varNum*pi //=pi //phi of the gap size 1
//	controlsimuSISTM1()
//end

//Function SetVarProc_simuSISTM1_dphid2(ctrlName,varNum,varStr,varName) : SetVariableControl
//	String ctrlName
//	Variable varNum
//	String varStr
//	String varName
//	variable/G dphid2_simuSISTM = varNum*pi //=pi //phi of the gap size 1
//	controlsimuSISTM1()
//end

//Function SetVarProc_simuSISTM1_dphih1(ctrlName,varNum,varStr,varName) : SetVariableControl
//	String ctrlName
//	Variable varNum
//	String varStr
//	String varName
//	variable/G dphih1_simuSISTM = varNum*pi //=pi //phi of the gap size 1
//	controlsimuSISTM1()
//end

//Function SetVarProc_simuSISTM1_dphih2(ctrlName,varNum,varStr,varName) : SetVariableControl
//	String ctrlName
//	Variable varNum
//	String varStr
//	String varName
//	variable/G dphih2_simuSISTM = varNum*pi //=pi //phi of the gap size 1
//	controlsimuSISTM1()
//end



Function PopMenuProc_simuSISTM1(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	variable/G convornot_simuSISTM = popNum-1
	controlsimuSISTM1()
end

Function SetVarProc_simuSISTM1(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	controlsimuSISTM1()

	variable/G tt2_simuSISTM
	variable/G convornot_simuSISTM
	variable/G slice_simuSISTM
	wave simu1line_conv = $"simu1line_conv"
	wave simu1line = $"simu1line"
	if (convornot_simuSISTM == 1)
		if (tt2_simuSISTM == 0)

			simu1line_conv = simu1line
		else
			tconvchoiceparameter(tt2_simuSISTM)
		endif
		make/o/N=(dimsize(simu1line,0)) simu1lineconv_1,simu1lineconv_2
		setscale/p x,dimoffset(simu1line,0),dimdelta(simu1line,0),"",simu1lineconv_1,simu1lineconv_2
		simu1lineconv_1[] = simu1line_conv[p][slice_simuSISTM]
		simu1lineconv_2[] = simu1line_conv[p][slice_simuSISTM+48]
	endif

	Button buttonexp1 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp2 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp3 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp4 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp5 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp6 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp7 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp8 fColor=(0,65535,65535),valueColor=(26411,1,52428)
end


Function SetVarProc_simuSISTM2(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	controlsimuSISTM1()

	variable/G tt2_simuSISTM
	variable/G convornot_simuSISTM
	variable/G slice_simuSISTM
	wave simu1line_conv = $"simu1line_conv"
	wave simu1line = $"simu1line"
	if (convornot_simuSISTM == 1)
		if (tt2_simuSISTM == 0)

			simu1line_conv = simu1line
		else
			tconvchoiceparameter(tt2_simuSISTM)
		endif
		make/o/N=(dimsize(simu1line,0)) simu1lineconv_1,simu1lineconv_2
		setscale/p x,dimoffset(simu1line,0),dimdelta(simu1line,0),"",simu1lineconv_1,simu1lineconv_2
		simu1lineconv_1[] = simu1line_conv[p][slice_simuSISTM]
		simu1lineconv_2[] = simu1line_conv[p][slice_simuSISTM+48]
	endif
	Button buttonexp1 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp2 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp3 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp4 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp5 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp6 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp7 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp8 fColor=(0,65535,65535),valueColor=(26411,1,52428)

end

Function controlsimuSISTM1()
	variable/G ampw1_simuSISTM //= ampw1 //=0.025 // amplitude of the width of gap 1
	variable/G ampw2_simuSISTM //= ampw2 //=0.025 // amplitude of the width of gap 2
	variable/G ampini1_simuSISTM //= ampini1 //=0.07 // average of the width of gap 1
	variable/G ampini2_simuSISTM //= ampini2//=0.07 // average of the width of gap 2
	variable/G ampg1_simuSISTM //= ampg1 //=0.22 // amplitude of the size of gap 1
	variable/G ampg2_simuSISTM //= ampg2 //=0.31 // amplitude of the size of gap 2
	variable/G ampgini1_simuSISTM //= ampgini1 //=1.4 // average of the size of gap 1
	variable/G ampgini2_simuSISTM //= ampgini2 //=1.9 // average of the size of gap 2
	variable/G dphid1_simuSISTM //=pi //phi of the gap size 1
	variable/G dphid2_simuSISTM //=pi // phi of the gap size 2
	variable/G dphih1_simuSISTM // =pi // phi of the peak height 1
	variable/G dphih2_simuSISTM // =0 // phi of peak height 2
	variable/G shrinkratio_simuSISTM //= 6 // LDOS reduction ratio for the peak 2

	variable/G tt2_simuSISTM
	variable/G convornot_simuSISTM

	variable/G slice_simuSISTM

	wave simu1line = $"simu1line"
	wave simu1line_conv = $"simu1line_conv"
	if (convornot_simuSISTM == 1)
		if (tt2_simuSISTM == 0)
			simu1line_conv = simu1line
		else
			tconvchoiceparameter(tt2_simuSISTM)
		endif
	endif

	choiceparameter(ampw1_simuSISTM,ampw2_simuSISTM,ampini1_simuSISTM,ampini2_simuSISTM,ampg1_simuSISTM,ampg2_simuSISTM,ampgini1_simuSISTM,ampgini2_simuSISTM,dphid1_simuSISTM,dphid2_simuSISTM,dphih1_simuSISTM,dphih2_simuSISTM,shrinkratio_simuSISTM)
	color3s_PDMsimu(30)
	SetVariable setvar0 title="\\$WMTEX$ \\left|\\Gamma_{\\rm Q}^{\\Delta_{1}}\\right| \\$/WMTEX$",limits={0,ampini1_simuSISTM/2,0.01}, size={80,20},value=ampw1_simuSISTM,proc=SetVarProc_simuSISTM1
	SetVariable setvar1 title="\\$WMTEX$ \\left|\\Gamma_{\\rm Q}^{\\Delta_{2}}\\right| \\$/WMTEX$",limits={0,ampini2_simuSISTM/2,0.01},size={80,20},value=ampw2_simuSISTM,proc=SetVarProc_simuSISTM1
	SetVariable setvar3 title="\\$WMTEX$ \\Gamma_{0}^{\\Delta_{1}} \\$/WMTEX$",limits={0,inf,0.01},size={80,20},value=ampini1_simuSISTM,proc=SetVarProc_simuSISTM1
	SetVariable setvar4 title="\\$WMTEX$ \\Gamma_{0}^{\\Delta_{2}} \\$/WMTEX$",limits={0,inf,0.01}, size={80,20},value=ampini2_simuSISTM,proc=SetVarProc_simuSISTM1

	SetVariable setvar5 title="\\$WMTEX$\\left| \\Delta^{1}_{\\rm Q}\\right|\\$/WMTEX$",limits={0,ampgini1_simuSISTM/2,0.1}, size={80,20},value=ampg1_simuSISTM,proc=SetVarProc_simuSISTM1
	SetVariable setvar6 title="\\$WMTEX$\\left| \\Delta^{2}_{\\rm Q}\\right|\\$/WMTEX$",limits={0,ampgini2_simuSISTM/2,0.1}, size={80,20},value=ampg2_simuSISTM,proc=SetVarProc_simuSISTM1
	SetVariable setvar7 title="\\$WMTEX$ \\Delta^{1}_{0}\\$/WMTEX$",limits={0,inf,0.1}, size={80,20},value=ampgini1_simuSISTM,proc=SetVarProc_simuSISTM1
	SetVariable setvar8 title="\\$WMTEX$ \\Delta^{2}_{0}\\$/WMTEX$",limits={0,inf,0.1}, size={80,20},value=ampgini2_simuSISTM,proc=SetVarProc_simuSISTM1


	make/o/N=(dimsize(simu1line,0)) simu1line_1,simu1line_2
	setscale/p x,dimoffset(simu1line,0),dimdelta(simu1line,0),"",simu1line_1,simu1line_2
	simu1line_1[] = simu1line[p][slice_simuSISTM]
	simu1line_2[] = simu1line[p][slice_simuSISTM+48]


	make/o/N=(dimsize(simu1line,0)) simu1lineconv_1,simu1lineconv_2
	setscale/p x,dimoffset(simu1line,0),dimdelta(simu1line,0),"",simu1lineconv_1,simu1lineconv_2
	simu1lineconv_1[] = simu1line_conv[p][slice_simuSISTM]
	simu1lineconv_2[] = simu1line_conv[p][slice_simuSISTM+48]

	//make/n=2/o indisimu1,indisimu2
	//setscale/i x, dimoffset(simu1line,0), dimoffset(simu1line,0)+(dimsize(simu1line,0)-1)*dimdelta(simu1line,0),"",indisimu1,indisimu2
	//indisimu1 = dimoffset(simu1line,1)+slice_simuSISTM*dimdelta(simu1line,1)
	//indisimu2 = dimoffset(simu1line,1)+(slice_simuSISTM+48)*dimdelta(simu1line,1)

	//make/n=2/o indisimuconv1,indisimuconv2
	//setscale/i x, dimoffset(simu1line_conv,0), dimoffset(simu1line_conv,0)+(dimsize(simu1line_conv,0)-1)*dimdelta(simu1line_conv,0),"",indisimuconv1,indisimuconv2
	//indisimuconv1 = dimoffset(simu1line_conv,1)+slice_simuSISTM*dimdelta(simu1line_conv,1)
	//indisimuconv2 = dimoffset(simu1line_conv,1)+(slice_simuSISTM+48)*dimdelta(simu1line_conv,1)

	//make/n=1/o axindi_simuPDM,ayindi_simuPDM,bxindi_simuPDM,byindi_simuPDM
	//axindi_simuPDM = indisimuconv1*sqrt(2)/3
	//ayindi_simuPDM = indisimuconv1*sqrt(2)/3
	//bxindi_simuPDM = indisimuconv2*sqrt(2)/3
	//byindi_simuPDM = indisimuconv2*sqrt(2)/3

	//calculate gap1 gap2
	make/o/n=(100,100) d1_simuPDM,d2_simuPDM
	setscale/i x,0,20,"",d1_simuPDM,d2_simuPDM
	setscale/i y,0,20,"",d1_simuPDM,d2_simuPDM
	multithread d1_simuPDM = (ampgini1_simuSISTM+ ampg1_simuSISTM*(cos((2*pi/3.8)*x+dphid1_simuSISTM)+cos((2*pi/3.8)*y+dphid1_simuSISTM)))
	multithread d2_simuPDM = (ampgini2_simuSISTM+ ampg2_simuSISTM*(cos((2*pi/3.8)*x+dphid2_simuSISTM)+cos((2*pi/3.8)*y+dphid2_simuSISTM)))


	//calculate height1 height2
	make/o/n=(100,100) h1_simuPDM,h2_simuPDM
	setscale/i x,0,20,"",h1_simuPDM,h2_simuPDM
	setscale/i y,0,20,"",h1_simuPDM,h2_simuPDM
	Multithread h1_simuPDM = (1-shrinkratio_simuSISTM)*(abs(real( (( ampgini1_simuSISTM+ ampg1_simuSISTM*(cos((2*pi/3.8)*x+dphid1_simuSISTM)+cos((2*pi/3.8)*y+dphid1_simuSISTM)) )-cmplx(0,(ampini1_simuSISTM + ampw1_simuSISTM*(cos((2*pi/3.8)*x+(dphih1_simuSISTM-pi))+cos((2*pi/3.8)*y+(dphih1_simuSISTM-pi))) )))/sqrt( (( ampgini1_simuSISTM+ ampg1_simuSISTM*(cos((2*pi/3.8)*x+dphid1_simuSISTM)+cos((2*pi/3.8)*y+dphid1_simuSISTM)) )-cmplx(0,(ampini1_simuSISTM + ampw1_simuSISTM*(cos((2*pi/3.8)*x+(dphih1_simuSISTM-pi))+cos((2*pi/3.8)*y+(dphih1_simuSISTM-pi))) )))^2 - ( ampgini1_simuSISTM+ ampg1_simuSISTM*(cos((2*pi/3.8)*x+dphid1_simuSISTM)+cos((2*pi/3.8)*y+dphid1_simuSISTM)) )^2 ) )))  +shrinkratio_simuSISTM*(abs(real( (( ampgini1_simuSISTM+ ampg1_simuSISTM*(cos((2*pi/3.8)*x+dphid1_simuSISTM)+cos((2*pi/3.8)*y+dphid1_simuSISTM)) )-cmplx(0,(ampini2_simuSISTM + ampw2_simuSISTM*(cos((2*pi/3.8)*x+(dphih2_simuSISTM-pi))+cos((2*pi/3.8)*y+(dphih2_simuSISTM-pi))) )))/sqrt( (( ampgini1_simuSISTM+ ampg1_simuSISTM*(cos((2*pi/3.8)*x+dphid1_simuSISTM)+cos((2*pi/3.8)*y+dphid1_simuSISTM)) )-cmplx(0,(ampini2_simuSISTM + ampw2_simuSISTM*(cos((2*pi/3.8)*x+(dphih2_simuSISTM-pi))+cos((2*pi/3.8)*y+(dphih2_simuSISTM-pi))) )))^2 - ( ampgini2_simuSISTM+ ampg2_simuSISTM*(cos((2*pi/3.8)*x+dphid2_simuSISTM)+cos((2*pi/3.8)*y+dphid2_simuSISTM)) )^2 ) )))
	Multithread h2_simuPDM = (1-shrinkratio_simuSISTM)*(abs(real( (( ampgini2_simuSISTM+ ampg2_simuSISTM*(cos((2*pi/3.8)*x+dphid2_simuSISTM)+cos((2*pi/3.8)*y+dphid2_simuSISTM)) )-cmplx(0,(ampini1_simuSISTM + ampw1_simuSISTM*(cos((2*pi/3.8)*x+(dphih1_simuSISTM-pi))+cos((2*pi/3.8)*y+(dphih1_simuSISTM-pi))) )))/sqrt( (( ampgini2_simuSISTM+ ampg2_simuSISTM*(cos((2*pi/3.8)*x+dphid2_simuSISTM)+cos((2*pi/3.8)*y+dphid2_simuSISTM)) )-cmplx(0,(ampini1_simuSISTM + ampw1_simuSISTM*(cos((2*pi/3.8)*x+(dphih1_simuSISTM-pi))+cos((2*pi/3.8)*y+(dphih1_simuSISTM-pi))) )))^2 - ( ampgini1_simuSISTM+ ampg1_simuSISTM*(cos((2*pi/3.8)*x+dphid1_simuSISTM)+cos((2*pi/3.8)*y+dphid1_simuSISTM)) )^2 ) ))) + shrinkratio_simuSISTM*(abs(real( (( ampgini2_simuSISTM+ ampg2_simuSISTM*(cos((2*pi/3.8)*x+dphid2_simuSISTM)+cos((2*pi/3.8)*y+dphid2_simuSISTM)) )-cmplx(0,(ampini2_simuSISTM + ampw2_simuSISTM*(cos((2*pi/3.8)*x+(dphih2_simuSISTM-pi))+cos((2*pi/3.8)*y+(dphih2_simuSISTM-pi))) )))/sqrt( (( ampgini2_simuSISTM+ ampg2_simuSISTM*(cos((2*pi/3.8)*x+dphid2_simuSISTM)+cos((2*pi/3.8)*y+dphid2_simuSISTM)) )-cmplx(0,(ampini2_simuSISTM + ampw2_simuSISTM*(cos((2*pi/3.8)*x+(dphih2_simuSISTM-pi))+cos((2*pi/3.8)*y+(dphih2_simuSISTM-pi))) )))^2 - ( ampgini2_simuSISTM+ ampg2_simuSISTM*(cos((2*pi/3.8)*x+dphid2_simuSISTM)+cos((2*pi/3.8)*y+dphid2_simuSISTM)) )^2 ) )))

	variable/G linecutslice_simuPDM
	wave gextract_simuPDM=$"gextract_simuPDM"
		make/n=2/o ratiod1_simupdm,ratiod2_simupdm,ratiodconv_simupdm
		setscale/i x,0,1,"",ratiod1_simupdm,ratiod2_simupdm,ratiodconv_simupdm
		ratiod1_simupdm[0] = 100*ampg1_simuSISTM/ampgini1_simuSISTM
		ratiod2_simupdm[0] = 100*ampg2_simuSISTM/ampgini2_simuSISTM
		wavestats/Q d1_simuPDM
		ratiod1_simupdm[1] = 100*(V_max-V_min)/(V_max+V_min)
		wavestats/Q d2_simuPDM
		ratiod2_simupdm[1] = 100*(V_max-V_min)/(V_max+V_min)
		wavestats/Q gextract_simuPDM
		ratiodconv_simupdm[1]  = 100*(V_max-V_min)/(V_max+V_min)

		//make/n=100/o gapx
		//gapx[] = gextract_simuPDM[0][p]
		//wavestats/Q gapx
		//ratiodconv_simupdm[0]  = 100*(V_max-V_min)/(V_max+V_min)
		//killwaves gapx
		ratiodconv_simupdm[0]  = ratiodconv_simupdm[1]/2

End

Function color3s_PDMsimu(tt)
	variable tt
	wave name = $"simu1line"
	//gethistgram_npcolor(nameofwave(name))
	//string W_coef = "W_coef"
	//wave W_coefw = $W_coef
	//variable sigma = sqrt(2)*W_coefw[3]
	//wavestats/Q name
	//variable lc,lh
	//if (W_coefw[2]-0.5*tt*sigma >V_min)
	//	lc = W_coefw[2]-0.5*tt*sigma
	//else
	//	lc =V_min
	//endif
	//if (W_coefw[2]+0.5*tt*sigma < V_max)
	//	lh = W_coefw[2]+0.5*tt*sigma
	//else
	//	lh =V_max
	//endif
	//ModifyImage/W=PDMlinecut2peaksimu#G0 $nameofwave(name) ctab= {lc,lh,VioletOrangeYellow,0}
	ModifyImage/W=PDMlinecut2peaksimu#G0 $nameofwave(name) ctab= {*,*,VioletOrangeYellow,0}

	wave name = $"simu1line_conv"
	//gethistgram_npcolor(nameofwave(name))
	//W_coef = "W_coef"
	//wave W_coefw = $W_coef
	//sigma = sqrt(2)*W_coefw[3]
	//wavestats/Q name
	//if (W_coefw[2]-0.5*tt*sigma >V_min)
	//	lc = W_coefw[2]-0.5*tt*sigma
	//else
	//	lc =V_min
	//endif
	//if (W_coefw[2]+0.5*tt*sigma < V_max)
	//	lh = W_coefw[2]+0.5*tt*sigma
	//else
	//	lh =V_max
	//endif
	//ModifyImage/W=PDMlinecut2peaksimu#G1 $nameofwave(name) ctab= {lc,lh,VioletOrangeYellow,0}
	ModifyImage/W=PDMlinecut2peaksimu#G1 $nameofwave(name) ctab= {*,*,VioletOrangeYellow,0}
end

Function tconvchoiceparameter(tt2)
	variable tt2
	wave simu1line = $"simu1line"
	variable aa
	make/o/N=(dimsize(simu1line,0)) coef_conv
	setscale/p x,dimoffset(simu1line,0),dimdelta(simu1line,0),"",coef_conv

	variable/G convmode_SimuPDM

	if (convmode_SimuPDM == 1)
		coef_conv=exp(-x^2/((3.5*0.086*tt2)/(2*sqrt(ln(2)))^2));
	endif
	if (convmode_SimuPDM == 2)
		coef_conv=1-1/(1+exp(x/(0.086*tt2)))
		differentiate coef_conv
		wavestats/Q coef_conv
		coef_conv/=V_max
	endif
	duplicate/o simu1line simu1line_conv;
	SmoothCustom coef_conv simu1line_conv;
	aa=simu1line_conv[0][0]/simu1line[0][0];
	simu1line_conv/=aa;
	killwaves coef_conv
end


Function choiceparameter(ampw1,ampw2,ampini1,ampini2,ampg1,ampg2,ampgini1,ampgini2,dphid1,dphid2,dphih1,dphih2,shrinkratio)
	variable ampw1 //=0.025 // amplitude of the width of gap 1
	variable ampw2 //=0.025 // amplitude of the width of gap 2
	variable ampini1 //=0.07 // average of the width of gap 1
	variable ampini2 //=0.07 // average of the width of gap 2
	variable ampg1 //=0.22 // amplitude of the size of gap 1
	variable ampg2 //=0.31 // amplitude of the size of gap 2
	variable ampgini1 //=1.4 // average of the size of gap 1
	variable ampgini2 //=1.9 // average of the size of gap 2
	variable dphid1 //=pi //phi of the gap size 1
	variable dphid2 //=pi // phi of the gap size 2
	variable dphih1 // =pi // phi of the peak height 1
	variable dphih2 // =0 // phi of peak height 2
	variable shrinkratio //= 6 // LDOS reduction ratio for the peak 2

	make/o/n=(512,500) simu1line
	setscale/I y, 0,20*sqrt(2),"",simu1line
	setscale/I x, -5,5,"",simu1line

	simu1line = 0

	Multithread simu1line += (1-shrinkratio)*(abs(real( (x-cmplx(0,(ampini1 + ampw1*(cos((2*pi/(3.8*sqrt(2)))*y+(dphih1-pi))+cos((2*pi/(3.8*sqrt(2)))*y+(dphih1-pi))) )))/sqrt( (x-cmplx(0,(ampini1 + ampw1*(cos((2*pi/(3.8*sqrt(2)))*y+(dphih1-pi))+cos((2*pi/(3.8*sqrt(2)))*y+(dphih1-pi))) )))^2 - ( ampgini1+ ampg1*(cos((2*pi/(3.8*sqrt(2)))*y+dphid1)+cos((2*pi/(3.8*sqrt(2)))*y+dphid1)) )^2 ) )))
	Multithread simu1line += shrinkratio*(abs(real( (x-cmplx(0,(ampini2 + ampw2*(cos((2*pi/(3.8*sqrt(2)))*y+(dphih2-pi))+cos((2*pi/(3.8*sqrt(2)))*y+(dphih2-pi))) )))/sqrt( (x-cmplx(0,(ampini2 + ampw2*(cos((2*pi/(3.8*sqrt(2)))*y+(dphih2-pi))+cos((2*pi/(3.8*sqrt(2)))*y+(dphih2-pi))) )))^2 - ( ampgini2+ ampg2*(cos((2*pi/(3.8*sqrt(2)))*y+dphid2)+cos((2*pi/(3.8*sqrt(2)))*y+dphid2)) )^2 ) )))
end

Function ButtonProc_make3DfakeSISTMc(ctrlName) : ButtonControl
	String ctrlName
	variable/G ampw1_simuSISTM //= ampw1 //=0.025 // amplitude of the width of gap 1
	variable/G ampw2_simuSISTM //= ampw2 //=0.025 // amplitude of the width of gap 2
	variable/G ampini1_simuSISTM //= ampini1 //=0.07 // average of the width of gap 1
	variable/G ampini2_simuSISTM //= ampini2//=0.07 // average of the width of gap 2
	variable/G ampg1_simuSISTM //= ampg1 //=0.22 // amplitude of the size of gap 1
	variable/G ampg2_simuSISTM //= ampg2 //=0.31 // amplitude of the size of gap 2
	variable/G ampgini1_simuSISTM //= ampgini1 //=1.4 // average of the size of gap 1
	variable/G ampgini2_simuSISTM //= ampgini2 //=1.9 // average of the size of gap 2
	variable/G dphid1_simuSISTM //=pi //phi of the gap size 1
	variable/G dphid2_simuSISTM //=pi // phi of the gap size 2
	variable/G dphih1_simuSISTM // =pi // phi of the peak height 1
	variable/G dphih2_simuSISTM // =0 // phi of peak height 2
	variable/G shrinkratio_simuSISTM //= 6 // LDOS reduction ratio for the peak 2

	variable/G tt2_simuSISTM
	variable/G convornot_simuSISTM

	make3DfakeSISTM(ampw1_simuSISTM,ampw2_simuSISTM,ampini1_simuSISTM,ampini2_simuSISTM,ampg1_simuSISTM,ampg2_simuSISTM,ampgini1_simuSISTM,ampgini2_simuSISTM,dphid1_simuSISTM,dphid2_simuSISTM,dphih1_simuSISTM,dphih2_simuSISTM,shrinkratio_simuSISTM)

end

proc make3DfakeSISTMc()
	make3DfakeSISTM(ampw1_simuSISTM,ampw2_simuSISTM,ampini1_simuSISTM,ampini2_simuSISTM,ampg1_simuSISTM,ampg2_simuSISTM,ampgini1_simuSISTM,ampgini2_simuSISTM,dphid1_simuSISTM,dphid2_simuSISTM,dphih1_simuSISTM,dphih2_simuSISTM,shrinkratio_simuSISTM)
end

Function make3DfakeSISTM(ampw1,ampw2,ampini1,ampini2,ampg1,ampg2,ampgini1,ampgini2,dphid1,dphid2,dphih1,dphih2,shrinkratio)
	variable ampw1 //=0.025 // amplitude of the width of gap 1
	variable ampw2 //=0.025 // amplitude of the width of gap 2
	variable ampini1 //=0.07 // average of the width of gap 1
	variable ampini2 //=0.07 // average of the width of gap 2
	variable ampg1 //=0.22 // amplitude of the size of gap 1
	variable ampg2 //=0.31 // amplitude of the size of gap 2
	variable ampgini1 //=1.4 // average of the size of gap 1
	variable ampgini2 //=1.9 // average of the size of gap 2
	variable dphid1 //=pi //phi of the gap size 1
	variable dphid2 //=pi // phi of the gap size 2
	variable dphih1 // =pi // phi of the peak height 1
	variable dphih2 // =0 // phi of peak height 2
	variable shrinkratio //= 6 // LDOS reduction ratio for the peak 2

	variable/G ampw1_simuSISTM //= ampw1 //=0.025 // amplitude of the width of gap 1
	variable/G ampw2_simuSISTM //= ampw2 //=0.025 // amplitude of the width of gap 2
	variable/G ampini1_simuSISTM //= ampini1 //=0.07 // average of the width of gap 1
	variable/G ampini2_simuSISTM //= ampini2//=0.07 // average of the width of gap 2
	variable/G ampg1_simuSISTM //= ampg1 //=0.22 // amplitude of the size of gap 1
	variable/G ampg2_simuSISTM //= ampg2 //=0.31 // amplitude of the size of gap 2
	variable/G ampgini1_simuSISTM //= ampgini1 //=1.4 // average of the size of gap 1
	variable/G ampgini2_simuSISTM //= ampgini2 //=1.9 // average of the size of gap 2
	variable/G dphid1_simuSISTM //=pi //phi of the gap size 1
	variable/G dphid2_simuSISTM //=pi // phi of the gap size 2
	variable/G dphih1_simuSISTM // =pi // phi of the peak height 1
	variable/G dphih2_simuSISTM // =0 // phi of peak height 2
	variable/G shrinkratio_simuSISTM //= 6 // LDOS reduction ratio for the peak 2

	variable/G tt2_simuSISTM
	variable/G convornot_simuSISTM

	make/o/n=(100,100,512) simu1
	setscale/I x, 0,20,"",simu1
	setscale/I y, 0,20,"",simu1
	setscale/I z, -5,5,"",simu1

	simu1 = 0

	Multithread simu1 += (1-shrinkratio)*(abs(real( (z-cmplx(0,(ampini1 + ampw1*(cos((2*pi/3.8)*x+(dphih1-pi))+cos((2*pi/3.8)*y+(dphih1-pi))) )))/sqrt( (z-cmplx(0,(ampini1 + ampw1*(cos((2*pi/3.8)*x+(dphih1-pi))+cos((2*pi/3.8)*y+(dphih1-pi))) )))^2 - ( ampgini1+ ampg1*(cos((2*pi/3.8)*x+dphid1)+cos((2*pi/3.8)*y+dphid1)) )^2 ) )))
	Multithread simu1 += shrinkratio*(abs(real( (z-cmplx(0,(ampini2 + ampw2*(cos((2*pi/3.8)*x+(dphih2-pi))+cos((2*pi/3.8)*y+(dphih2-pi))) )))/sqrt( (z-cmplx(0,(ampini2 + ampw2*(cos((2*pi/3.8)*x+(dphih2-pi))+cos((2*pi/3.8)*y+(dphih2-pi))) )))^2 - ( ampgini2+ ampg2*(cos((2*pi/3.8)*x+dphid2)+cos((2*pi/3.8)*y+dphid2)) )^2 ) )))

	make/o/n=(512,100) linecuttemp_SISTM
	setscale/I x,-5,5,"",linecuttemp_SISTM
	setscale/I y,0,20,"",linecuttemp_SISTM

	make/o/n=(100,100,512) simu1_conv
	setscale/I z,-5,5,"",simu1_conv
	setscale/I x,0,20,"",simu1_conv
	setscale/I y,0,20,"",simu1_conv

	variable tt2 = tt2_simuSISTM
	variable aa
	variable i
	variable/G convmode_SimuPDM

	if (convornot_simuSISTM ==1)

		make/o/N=(dimsize(simu1,2)) coef_conv
		setscale/p x,dimoffset(simu1,2),dimdelta(simu1,2),"",coef_conv

		if (convmode_SimuPDM == 1)
			coef_conv=exp(-x^2/((3.5*0.086*tt2)/(2*sqrt(ln(2)))^2));
		endif
		if (convmode_SimuPDM == 2)
			coef_conv=1-1/(1+exp(x/(0.086*tt2)))
			differentiate coef_conv
			wavestats/Q coef_conv
			coef_conv/=V_max
		endif


		i=0
		do
			//IF(mod(i+1,20)==0)
			//	Print i,"/",99
			//Endif

			multithread linecuttemp_SISTM[][] = simu1[q][i][p]
			SmoothCustom coef_conv linecuttemp_SISTM;

			multithread simu1_conv[][i][] = linecuttemp_SISTM[r][p]

			i+=1
		while (i<100)
		killwaves coef_conv linecuttemp_SISTM

		aa=simu1_conv[0][0][0]/simu1[0][0][0];
		simu1_conv/=aa;

	endif

	variable/G linecutslice_simuPDM
	make/o/n=(dimsize(simu1,2),dimsize(simu1,0)) linecutxsimupdm_conv,linecutxsimupdm
	setscale/i x,-5,5,"",linecutxsimupdm_conv,linecutxsimupdm
	setscale/i y,0,20,"",linecutxsimupdm_conv,linecutxsimupdm
	linecutxsimupdm[][] = simu1[linecutslice_simuPDM][q][p]
	linecutxsimupdm_conv[][] = simu1_conv[linecutslice_simuPDM][q][p]

end


Function ButtonProc_make3DfakeSISTMcraw(ctrlName) : ButtonControl
	String ctrlName

	execute "d3d(\"simu1\",2)"
end

Function ButtonProc_make3DfakeSISTMcconv(ctrlName) : ButtonControl
	String ctrlName
	execute "d3d(\"simu1_conv\",2)"
end


Function ButtonProc_gapdisGua2_forPDMsimu(ctrlName) : ButtonControl
	String ctrlName
	execute "gapdisGua2_forPDMsimuc()"
	variable/G linecutslice_simuPDM
	wave gextract_simuPDM=$"gextract_simuPDM"
		make/n=2/o ratiodconv_simupdm
		setscale/i x,0,1,"",ratiodconv_simupdm
		wavestats/Q gextract_simuPDM
		ratiodconv_simupdm[1]  = 100*(V_max-V_min)/(V_max+V_min)

		//make/n=100/o gapx
		//gapx[] = gextract_simuPDM[0][p]
		//wavestats/Q gapx
		//ratiodconv_simupdm[0]  = 100*(V_max-V_min)/(V_max+V_min)
		//killwaves gapx
		ratiodconv_simupdm[0]  = ratiodconv_simupdm[1]/2
end


proc gapdisGua2_forPDMsimuc(tip,namemat3d,froml,tol,fromr,tor)
	string tip="Need make convoluted 3D first"
	string namemat3d = "simu1_conv"// the 3D matrix g(r,v)
	Variable froml = -3//-(ampgini2_simuSISTM+2*ampg2_simuSISTM)
	Variable tol = -1//-(ampgini1_simuSISTM-2*ampg1_simuSISTM)
	Variable fromr = 1//= (ampgini1_simuSISTM-2*ampg1_simuSISTM)
	Variable tor = 3//= (ampgini2_simuSISTM+2*ampg2_simuSISTM)
	Prompt namemat3d,"Name of convoluted 3D data"

	gapdisGua2_forPDMsimu($namemat3d,froml,tol,fromr,tor)
end

Function gapdisGua2_forPDMsimu(namemat3d,froml,tol,fromr,tor)
	wave namemat3d // the 3D matrix g(r,v)
	Variable froml
	Variable tol
	Variable fromr
	Variable tor

	variable sizex=dimsize(namemat3d,0)
	variable sizey=dimsize(namemat3d,1)

	String name
	String mat
	Variable k,i,j

	string gapsize2d = "gextract_simuPDM"
	make/o/N=(sizex,sizey) $gapsize2d
	setscale/p x,dimoffset(namemat3d,0),dimdelta(namemat3d,0),"", $gapsize2d
	setscale/p y,dimoffset(namemat3d,1),dimdelta(namemat3d,1),"", $gapsize2d
	Wave m=$gapsize2d

	String mat3ds = nameofwave(namemat3d)
	Wave mat3d=$mat3ds


	String mat2,mat3
	Variable p1,p2
	p1=Round((froml-dimoffset(mat3d,2))/dimdelta(mat3d,2))
	p2=Round((tol-dimoffset(mat3d,2))/dimdelta(mat3d,2))
	Variable q1,q2
	q1=Round((fromr-dimoffset(mat3d,2))/dimdelta(mat3d,2))
	q2=Round((tor-dimoffset(mat3d,2))/dimdelta(mat3d,2))

	k=1
	i=0
	do
		j=0
		do

			//** Create Z-spectrum [the single STS]
			mat="sts"//+num2str(k)
			mat3="fit_"+mat
			mat2="W_coef"
			make/o/n=(dimsize(mat3d,2)) $mat
			Wave n=$mat
			setscale/p x, dimoffset(mat3d,2),dimdelta(mat3d,2),"",n

			n[]=mat3d[i][j][p]


			//** Multifunctional fitting to the Z-spectrum
			smooth 5,n
				//*** Guassian Fit Left
				CurveFit/Q/W=2 gauss, n[p1,p2]/D
				Wave W_coefl=$mat2

				variable j1,j2,u1,u2
				j1=1
				j2=1
				variable leftc
				leftc=-W_coefl[2]
				if (leftc < -froml && leftc > -tol)
				else
					leftc=NAN
					j1=0
				endif

				//*** Guassian Fit right
				CurveFit/Q/W=2 gauss, n[q1,q2]/D
				Wave W_coefr=$mat2
				variable rightc
				rightc=W_coefr[2]
				if (rightc > fromr && rightc < tor)
				else
					rightc=NAN
					j2=0
				endif

				//*** Linear substraction Fit left
				CurveFit/Q/NTHR=0 line n[p1,p2] /D
				duplicate/o n n2
				duplicate/o n n3
				Wave W_coefll=$mat2
				n2=W_coefll[0]+W_coefll[1]*x
				n=n3-n2
				wavestats/Q/R = (froml, tol) n
				variable ll
				ll=abs(V_maxloc)

				//*** Linear substraction Fit Right
				CurveFit/Q/NTHR=0 line n[q1,q2] /D
				duplicate/o n n2
				duplicate/o n n3
				Wave W_coefrr=$mat2
				n2=W_coefrr[0]+W_coefrr[1]*x
				n=n3-n2
				wavestats/Q/R = (fromr, tor) n
				variable rr
				rr=abs(V_maxloc)

			//*** Select a proper Fitting value
			if (j1 == 1 && j2 == 1)
				 m[i][j]=(rightc+leftc)/2
			endif

			if (j1 == 0 && j2 == 1)
				 m[i][j]= rightc
			endif

			if (j1 == 1 && j2 == 0)
				 m[i][j]= leftc
			endif
			if (j1 == 0 && j2 == 0)
				 m[i][j]=(ll+rr)/2
			endif

			j+=1
			K+=1

		while(j<sizey)
		i+=1
	while(i<sizex)

	wave fitn=$mat3
	killwaves fitn
	killwaves n,n2,n3
	killwaves W_coefrr//,W_coefll,W_coefr
end

Function ButtonProc_gaph_forPDMsimu(ctrlName) : ButtonControl
	String ctrlName
	wave simu1_conv = $"simu1_conv"
	extracthight_PDMsimu(simu1_conv)
end

Function extracthight_PDMsimu(namemat3d)
	wave namemat3d

	variable sizex=dimsize(namemat3d,0)
	variable sizey=dimsize(namemat3d,1)

	string height = "hextract_simuPDM"
	make/o/N=(sizex,sizey) $height
	setscale/p x,dimoffset(namemat3d,0),dimdelta(namemat3d,0),"", $height
	setscale/p y,dimoffset(namemat3d,1),dimdelta(namemat3d,1),"", $height
	Wave heightw=$height

	make/n=(dimsize(namemat3d,2))/o temp_simupdm
	setscale/p x,dimoffset(namemat3d,2),dimdelta(namemat3d,2),"",temp_simupdm
	variable i,j
	i=0
	do
		j=0
		do
			temp_simupdm[] = namemat3d[i][j][p]
			wavestats/Q temp_simupdm
			heightw[i][j] = V_max
			j+=1
		while(j<dimsize(namemat3d,1))
		i+=1
	while(i<dimsize(namemat3d,0))
	killwaves temp_simupdm

end


Function ButtonProc_gapdisGua2_forPDMsimuc2(ctrlName) : ButtonControl
	String ctrlName
	execute "gapdisGua2_forPDMsimuc2()"
	variable/G linecutslice_simuPDM
	wave gextract_simuPDM=$"gextract_simuPDM"
		make/n=2/o ratiodconv_simupdm
		setscale/i x,0,1,"",ratiodconv_simupdm
		wavestats/Q gextract_simuPDM
		ratiodconv_simupdm[1]  = 100*(V_max-V_min)/(V_max+V_min)

		//make/n=100/o gapx
		//gapx[] = gextract_simuPDM[0][p]
		//wavestats/Q gapx
		//ratiodconv_simupdm[0]  = 100*(V_max-V_min)/(V_max+V_min)
		//killwaves gapx
		ratiodconv_simupdm[0]  = ratiodconv_simupdm[1]/2
end
proc gapdisGua2_forPDMsimuc2()
	string tip="Need make convoluted 3D first"
	string namemat3d = "simu1_conv"// the 3D matrix g(r,v)
	//Prompt namemat3d,"Name of convoluted 3D data"

	gapdisGua2_forPDMsimu2($namemat3d)
end

Function gapdisGua2_forPDMsimu2(namemat3d)
	wave namemat3d

	variable sizex=dimsize(namemat3d,0)
	variable sizey=dimsize(namemat3d,1)

	string height = "gextract_simuPDM"
	make/o/N=(sizex,sizey) $height
	setscale/p x,dimoffset(namemat3d,0),dimdelta(namemat3d,0),"", $height
	setscale/p y,dimoffset(namemat3d,1),dimdelta(namemat3d,1),"", $height
	Wave heightw=$height

	make/n=(dimsize(namemat3d,2))/o temp_simupdm
	setscale/p x,dimoffset(namemat3d,2),dimdelta(namemat3d,2),"",temp_simupdm
	variable i,j
	i=0
	do
		j=0
		do
			temp_simupdm[] = namemat3d[i][j][p]
			wavestats/Q temp_simupdm
			heightw[i][j] = abs(V_maxloc)
			j+=1
		while(j<dimsize(namemat3d,1))
		i+=1
	while(i<dimsize(namemat3d,0))
	killwaves temp_simupdm

end

//Case one:

	//Gap		E_max	height_max
	//1		Se-		Se-
	//2		Se-		Se+

//lattice

	//cos((2*pi/3.8)*x)+cos((2*pi/3.8)*y)

//E gap 1 follow Se-

	//delta1 = ( 1.4+ 0.22*(cos((2*pi/3.8)*x+pi)+cos((2*pi/3.8)*y+pi)) )

	//width1 = (0.07 + 0.05*(cos((2*pi/3.8)*x)+cos((2*pi/3.8)*y)) )

//E gap 2 follow Se-

	//delta2 = ( 1.9+ 0.31*(cos((2*pi/3.8)*x+pi)+cos((2*pi/3.8)*y+pi)) )

	//width2 = ( 0.07 + 0.05*(cos((2*pi/3.8)*x+pi)+cos((2*pi/3.8)*y+pi)) )

//Dyne func

	//for1: abs(real( (x-cmplx(0,width1))/sqrt( (x-cmplx(0,width1))^2 - delta1^2 ) ))

	//for2: abs(real( (x-cmplx(0,width2))/sqrt( (x-cmplx(0,width2))^2 - delta2^2 ) ))/6

//Guassian func

	//cdynetest=exp(-x^2/(FWHM/(2*sqrt(ln(2)))^2))
////////////////////////////////////////////////////////////////////////////
// Examples of parameters
////////////////////////////////////////////////////////////////////////////
//Case#1 only have in-phase gap size modulation (no peak height modulation )
Function ButtonProc_pdmsimu_example1(ctrlName) : ButtonControl
	String ctrlName
	pdmsimu_example(0,0,0.03,0.05,0.22,0.31,1.4,1.9,0,0,0,0,0.2,48,2,57,3,1,2)
	Button buttonexp1 fColor=(26214,0,20971),valueColor=(65535,65535,65535)
	Button buttonexp2 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp3 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp4 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp5 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp6 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp7 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp8 fColor=(0,65535,65535),valueColor=(26411,1,52428)
end

//Case#2 No gap modulation but severe out-of-phase height modulation
Function ButtonProc_pdmsimu_example2(ctrlName) : ButtonControl
	String ctrlName
	pdmsimu_example(0.09,0.09,0.2,0.2,0,0,1.4,1.9,0,0,0,3.1416,0.4,48,2,47,2,1,2)
	Button buttonexp1 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp2 fColor=(26214,0,20971),valueColor=(65535,65535,65535)
	Button buttonexp3 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp4 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp5 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp6 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp7 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp8 fColor=(0,65535,65535),valueColor=(26411,1,52428)

end


//Case#3 Case of 1UC-FeSe case 1, gap in-phase/ height out-of-phase
Function ButtonProc_pdmsimu_example3(ctrlName) : ButtonControl
	String ctrlName
	pdmsimu_example(0.03,0.03,0.1,0.1,0.04,0.05,0.9,1.47,3.1416,3.1416,3.1416,0,0.55,48,1,57,2,1,2)
	Button buttonexp1 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp2 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp4 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp3 fColor=(26214,0,20971),valueColor=(65535,65535,65535)
	Button buttonexp5 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp6 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp7 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp8 fColor=(0,65535,65535),valueColor=(26411,1,52428)

end

//Case#4 only have in-phase gap size modulation (no peak height modulation )
Function ButtonProc_pdmsimu_example4(ctrlName) : ButtonControl
	String ctrlName
	pdmsimu_example(0.06,0.105,0.21,0.28,0.26,0.18,1.4,1.9,3.1416,3.1416,3.1416,0,0.65,48,2,57,2,1,2)
	Button buttonexp1 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp2 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp3 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp7 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp5 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp6 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp4 fColor=(26214,0,20971),valueColor=(65535,65535,65535)
	Button buttonexp8 fColor=(0,65535,65535),valueColor=(26411,1,52428)


end

//Case#5 in-phase gap size modulation/ out-of-phase peak height modulation
Function ButtonProc_pdmsimu_example5(ctrlName) : ButtonControl
	String ctrlName
	pdmsimu_example(0.02,0.02,0.05,0.05,0.22,0.3,1.4,1.9,0,0,3.1416,0,0.35,48,2,57,3,1,2)
	Button buttonexp1 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp2 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp5 fColor=(26214,0,20971),valueColor=(65535,65535,65535)
	Button buttonexp4 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp3 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp6 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp7 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp8 fColor=(0,65535,65535),valueColor=(26411,1,52428)

end

//Case#6 single gap
Function ButtonProc_pdmsimu_example6(ctrlName) : ButtonControl
	String ctrlName
	pdmsimu_example(0,0,0.2,0,0.25,0,1.65,0,3.1416,0,0,0,0,48,2,47,4,1,2)
	Button buttonexp1 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp2 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp3 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp4 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp5 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp6 fColor=(26214,0,20971),valueColor=(65535,65535,65535)
	Button buttonexp7 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp8 fColor=(0,65535,65535),valueColor=(26411,1,52428)

end

//Case#7 maybe our case? with correct peak height
Function ButtonProc_pdmsimu_example7(ctrlName) : ButtonControl
	String ctrlName
	pdmsimu_example(0.03,0.03,0.1,0.1,0.04,0.05,0.9,1.47,3.1416,0,3.1416,0,0.35,48,1,57,3,1,2)
	Button buttonexp1 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp2 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp3 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp4 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp7 fColor=(26214,0,20971),valueColor=(65535,65535,65535)
	Button buttonexp6 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp5 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp8 fColor=(0,65535,65535),valueColor=(26411,1,52428)

end

//Case#8 special
Function ButtonProc_pdmsimu_example8(ctrlName) : ButtonControl
	String ctrlName
	pdmsimu_example(0.075,0.04,0.17,0.1,0.1,0.1,1.4,1.9,3.1416,0,0,0,0.35,48,2,57,5,1,2)
	Button buttonexp1 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp2 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp3 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp4 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp5 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp6 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp7 fColor=(0,65535,65535),valueColor=(26411,1,52428)
	Button buttonexp8 fColor=(26214,0,20971),valueColor=(65535,65535,65535)

end

/////////////////////////////////////////////////////////////////////////////////////
//Function for example cases
Function pdmsimu_example(ampw1,ampw2,ampini1,ampini2,ampg1,ampg2,ampgini1,ampgini2,dphid1,dphid2,dphih1,dphih2,shrinkratio,slice,gaponwhich,linecutslice,tt2,convornot,convmode)
	variable ampw1//_simuSISTM = 0
	variable ampw2//_simuSISTM = 0
	variable ampini1//_simuSISTM = 0.03
	variable ampini2//_simuSISTM = 0.05
	variable ampg1//_simuSISTM = 0.22
	variable ampg2//_simuSISTM = 0.31
	variable ampgini1//_simuSISTM = 1.4
	variable ampgini2//_simuSISTM = 1.9
	variable dphid1//_simuSISTM = 0
	variable dphid2//_simuSISTM = 0
	variable dphih1//_simuSISTM = 0
	variable dphih2//_simuSISTM = 0
	variable shrinkratio//_simuSISTM = 0.2
	variable slice//_simuSISTM = 48
	variable gaponwhich//_simuSISTM = 2
	variable linecutslice//_simuPDM = 0
	variable tt2//_simuSISTM = 3
	variable convornot//_simuSISTM = 1
	variable convmode//_SimuPDM = 2

	variable/G ampw1_simuSISTM = ampw1
	variable/G ampw2_simuSISTM = ampw2
	variable/G ampini1_simuSISTM = ampini1
	variable/G ampini2_simuSISTM = ampini2
	variable/G ampg1_simuSISTM = ampg1
	variable/G ampg2_simuSISTM = ampg2
	variable/G ampgini1_simuSISTM = ampgini1
	variable/G ampgini2_simuSISTM = ampgini2
	variable/G dphid1_simuSISTM = dphid1
	variable/G dphid2_simuSISTM = dphid2
	variable/G dphih1_simuSISTM = dphih1
	variable/G dphih2_simuSISTM = dphih2
	variable/G shrinkratio_simuSISTM = shrinkratio
	variable/G slice_simuSISTM = slice
	variable/G gaponwhich_simuSISTM = gaponwhich
	variable/G linecutslice_simuPDM = linecutslice
	variable/G tt2_simuSISTM = tt2
	variable/G convornot_simuSISTM = convornot
	variable/G convmode_SimuPDM = convmode
	PDMSIMU_examplecore()
end
Function PDMSIMU_examplecore()
	variable/G ampw1_simuSISTM //= 0
	variable/G ampw2_simuSISTM //= 0
	variable/G ampini1_simuSISTM //= 0.03
	variable/G ampini2_simuSISTM //= 0.05
	variable/G ampg1_simuSISTM //= 0.22
	variable/G ampg2_simuSISTM //= 0.31
	variable/G ampgini1_simuSISTM //= 1.4
	variable/G ampgini2_simuSISTM //= 1.9
	variable/G dphid1_simuSISTM //= 0
	variable/G dphid2_simuSISTM //= 0
	variable/G dphih1_simuSISTM //= 0
	variable/G dphih2_simuSISTM //= 0
	variable/G shrinkratio_simuSISTM //= 0.2
	variable/G slice_simuSISTM //= 48
	variable/G gaponwhich_simuSISTM //= 2
	variable/G linecutslice_simuPDM //= 0
	variable/G tt2_simuSISTM //= 3
	variable/G convornot_simuSISTM //= 1
	variable/G convmode_SimuPDM //= 2
	controlsimuSISTM1()
	tconvchoiceparameter(tt2_simuSISTM)
	make3DfakeSISTM(ampw1_simuSISTM,ampw2_simuSISTM,ampini1_simuSISTM,ampini2_simuSISTM,ampg1_simuSISTM,ampg2_simuSISTM,ampgini1_simuSISTM,ampgini2_simuSISTM,dphid1_simuSISTM,dphid2_simuSISTM,dphih1_simuSISTM,dphih2_simuSISTM,shrinkratio_simuSISTM)
	wave simu1_conv = $"simu1_conv"
	gapdisGua2_forPDMsimu2(simu1_conv)
	extracthight_PDMsimu(simu1_conv)

	make/o/n=(100,100) topo_simuPDM
	setscale/i x,0,20,"",topo_simuPDM
	setscale/i y,0,20,"",topo_simuPDM

	if (gaponwhich_simuSISTM == 1)//Se
		topo_simuPDM = cos((2*pi/3.8)*x)+cos((2*pi/3.8)*y)
	endif

	if (gaponwhich_simuSISTM == 2)//Fe
		topo_simuPDM = cos((2*pi/3.8)*x+pi)+cos((2*pi/3.8)*y)
	endif

	wave simu1line=$"simu1line"
	make/o/N=(dimsize(simu1line,0)) simu1line_1,simu1line_2
	setscale/p x,dimoffset(simu1line,0),dimdelta(simu1line,0),"",simu1line_1,simu1line_2
	simu1line_1[] = simu1line[p][slice_simuSISTM]
	simu1line_2[] = simu1line[p][slice_simuSISTM+48]

	wave simu1line_conv=$"simu1line_conv"
	make/o/N=(dimsize(simu1line,0)) simu1lineconv_1,simu1lineconv_2
	setscale/p x,dimoffset(simu1line,0),dimdelta(simu1line,0),"",simu1lineconv_1,simu1lineconv_2
	simu1lineconv_1[] = simu1line_conv[p][slice_simuSISTM]
	simu1lineconv_2[] = simu1line_conv[p][slice_simuSISTM+48]

	make/n=2/o indisimu1,indisimu2
	setscale/i x, dimoffset(simu1line,0), dimoffset(simu1line,0)+(dimsize(simu1line,0)-1)*dimdelta(simu1line,0),"",indisimu1,indisimu2
	indisimu1 = dimoffset(simu1line,1)+slice_simuSISTM*dimdelta(simu1line,1)
	indisimu2 = dimoffset(simu1line,1)+(slice_simuSISTM+48)*dimdelta(simu1line,1)

	make/n=2/o indisimuconv1,indisimuconv2
	setscale/i x, dimoffset(simu1line_conv,0), dimoffset(simu1line_conv,0)+(dimsize(simu1line_conv,0)-1)*dimdelta(simu1line_conv,0),"",indisimuconv1,indisimuconv2
	indisimuconv1 = dimoffset(simu1line_conv,1)+slice_simuSISTM*dimdelta(simu1line_conv,1)
	indisimuconv2 = dimoffset(simu1line_conv,1)+(slice_simuSISTM+48)*dimdelta(simu1line_conv,1)

	make/n=1/o axindi_simuPDM,ayindi_simuPDM,bxindi_simuPDM,byindi_simuPDM
	axindi_simuPDM = indisimuconv1*sqrt(2)/2
	ayindi_simuPDM = indisimuconv1*sqrt(2)/2
	bxindi_simuPDM = indisimuconv2*sqrt(2)/2
	byindi_simuPDM = indisimuconv2*sqrt(2)/2

	wave gextract_simuPDM=$"gextract_simuPDM"
		make/n=2/o ratiodconv_simupdm
		setscale/i x,0,1,"",ratiodconv_simupdm
		wavestats/Q gextract_simuPDM
		ratiodconv_simupdm[1]  = 100*(V_max-V_min)/(V_max+V_min)

		//make/n=100/o gapx
		//gapx[] = gextract_simuPDM[0][p]
		//wavestats/Q gapx
		//ratiodconv_simupdm[0]  = 100*(V_max-V_min)/(V_max+V_min)
		//killwaves gapx
		ratiodconv_simupdm[0]  = ratiodconv_simupdm[1]/2

	wave simu1=$"simu1"
	make/o/n=(dimsize(simu1,2),dimsize(simu1,0)) linecutxsimupdm_conv,linecutxsimupdm
	setscale/i x,-5,5,"",linecutxsimupdm_conv,linecutxsimupdm
	setscale/i y,0,20,"",linecutxsimupdm_conv,linecutxsimupdm
	linecutxsimupdm[][] = simu1[linecutslice_simuPDM][q][p]
	linecutxsimupdm_conv[][] = simu1_conv[linecutslice_simuPDM][q][p]
	make/n=2/o linecutyindi_simupdm
	setscale/I x,0,20,"",linecutyindi_simupdm
	variable xindilinecut = dimoffset(topo_simuPDM,0)+dimdelta(topo_simuPDM,0)*linecutslice_simuPDM
	linecutyindi_simupdm = xindilinecut


	PopupMenu pop1 title="Convolve",proc=PopMenuProc_simuSISTM1,value="No;Yes",mode=(convornot_simuSISTM+1) //Yes is 2, No is 1
	PopupMenu pop2 title="\\$WMTEX$ r(\\Delta_{\\rm max}) \\$/WMTEX$",proc=PopMenuProc_simuSISTMSeFe,value="Se;Fe(x)",mode=gaponwhich_simuSISTM //Se is 1, Fe is 2
end



Function ButtonProc_getparameterPDMsimu(ctrlName) : ButtonControl
	String ctrlName
	variable/G ampw1_simuSISTM //= 0
	variable/G ampw2_simuSISTM //= 0
	variable/G ampini1_simuSISTM //= 0.03
	variable/G ampini2_simuSISTM //= 0.05
	variable/G ampg1_simuSISTM //= 0.22
	variable/G ampg2_simuSISTM //= 0.31
	variable/G ampgini1_simuSISTM //= 1.4
	variable/G ampgini2_simuSISTM //= 1.9
	variable/G dphid1_simuSISTM //= 0
	variable/G dphid2_simuSISTM //= 0
	variable/G dphih1_simuSISTM //= 0
	variable/G dphih2_simuSISTM //= 0
	variable/G shrinkratio_simuSISTM //= 0.2
	variable/G slice_simuSISTM //= 48
	variable/G gaponwhich_simuSISTM //= 2
	variable/G linecutslice_simuPDM //= 0
	variable/G tt2_simuSISTM //= 3
	variable/G convornot_simuSISTM //= 1
	variable/G convmode_SimuPDM //= 2

	print "ampw1_simuSISTM, \r ampw2_simuSISTM, \r ampini1_simuSISTM, \r ampini2_simuSISTM, \r ampg1_simuSISTM, \r ampg2_simuSISTM, \r ampgini1_simuSISTM, \r ampgini2_simuSISTM, \r dphid1_simuSISTM, \r dphid2_simuSISTM, \r dphih1_simuSISTM, \r dphih2_simuSISTM, \r shrinkratio_simuSISTM, \r slice_simuSISTM, \r gaponwhich_simuSISTM, \r linecutslice_simuPDM, \r tt2_simuSISTM, \r convornot_simuSISTM, \r convmode_SimuPDM"
	print "("+num2str(ampw1_simuSISTM)+","+num2str(ampw2_simuSISTM)+","+num2str(ampini1_simuSISTM)+","+num2str(ampini2_simuSISTM)+","+num2str(ampg1_simuSISTM)+","+num2str(ampg2_simuSISTM)+","+num2str(ampgini1_simuSISTM)+","+num2str(ampgini2_simuSISTM)+","+num2str(dphid1_simuSISTM)+","+num2str(dphid2_simuSISTM)+","+num2str(dphih1_simuSISTM)+","+num2str(dphih2_simuSISTM)+","+num2str(shrinkratio_simuSISTM)+","+num2str(slice_simuSISTM)+","+num2str(gaponwhich_simuSISTM)+","+num2str(linecutslice_simuPDM)+","+num2str(tt2_simuSISTM)+","+num2str(convornot_simuSISTM)+","+num2str(convmode_SimuPDM)+")"
end




///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
Function drawdyne(width,delta,width2,delta2)
	variable width
	variable delta
	variable width2
	variable delta2
	make/n=(2000)/o dynetest1,dynetest2,dynetest
	setscale/I x, -20,20,"",dynetest1,dynetest2,dynetest
	dynetest1 = abs(real( (x-cmplx(0,width))/sqrt( (x-cmplx(0,width))^2 - delta^2) ))
	dynetest2 = abs(real( (x-cmplx(0,width2))/sqrt( (x-cmplx(0,width2))^2 - delta2^2) ))/6

	dynetest = dynetest1 + dynetest2
end

Function DyneS(a,delta,width)
	variable a
	variable delta
	variable width

	variable dd

	dd = abs(real( (a-cmplx(0,width))/sqrt( (a-cmplx(0,width))^2 - delta^2) ))
	return dd
end

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
// Convolute any curve by temperature broadening
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
Function ButtonProc_convolvetempc(ctrlName) : ButtonControl
	String ctrlName
	Execute "convolvetempc()"
end
Proc convolvetempc(name,tt2)
	string name = tpw()
	variable tt2
	prompt name,"The 1D wave want to be convolved"
	Prompt tt2, "Temperature (K)"
	convolvetemp($name,tt2)
	string conv = name + "_Tconv"
	display  $name $conv
	ModifyGraph rgb($name)=(52428,52428,52428)
	ModifyGraph mirror=2,tick=2,axThick=2
	modifygraph width=300, height=250;
	ModifyGraph margin(top)=36
	Legend/C/N=text0/F=0/X=0.00/Y=0.00

	variable/G tt2_globaltconv = tt2
	SetVariable setvar0 title="T(K)",limits={0,inf,0.1}, size={80,20},value=tt2_globaltconv,proc=SetVarProc_Tconv

	variable/G convmode_SimuPDM = 2 //1: guassian, 2: differentiated FD
	SetVariable setvar16 title="mode",limits={1,2,1}, size={80,20},value=convmode_SimuPDM ,proc=SetVarProc_Tconv

end

Function SetVarProc_Tconv(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/G tt2_globaltconv
	convolvetemp($tpw(),tt2_globaltconv)
end
Function convolvetemp(name,tt2)
	wave name
	variable tt2
	variable aa

	string conv = nameofwave(name)+"_Tconv"
	duplicate/o name $conv;
	duplicate/o name coef_Tconv;
	//coef_Tconv=exp(-x^2/((3.5*0.086*tt2)/(2*sqrt(ln(2)))^2));

	variable/G convmode_SimuPDM

		if (convmode_SimuPDM == 1)
			coef_Tconv=exp(-x^2/((3.5*0.086*tt2)/(2*sqrt(ln(2)))^2));
		endif
		if (convmode_SimuPDM == 2)
			coef_Tconv=1-1/(1+exp(x/(0.086*tt2)))
			differentiate coef_Tconv
			wavestats/Q coef_Tconv
			coef_Tconv/=V_max
		endif


	wave convw = $conv
	SmoothCustom coef_Tconv convw;
	aa= convw[0]/name[0];
	convw/=aa
	killwaves coef_Tconv
end

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
Function ButtonProc_convallc(ctrlName) : ButtonControl
	String ctrlName
	Execute "convallc()"
end
Proc convallc(bathname,num,mode,temp)
	string bathname = ""
	variable num
	variable mode = 2
	variable temp = 4
	prompt bathname,"Bath name"
	prompt num, "Number of the batch"
	prompt mode,"Select mode",popup,"Guassian;F-D"
	prompt temp,"Temperature (K)"
	convall(bathname,num,mode,temp)
end

Function convall(bathname,num,mode,temp)
	string bathname
	variable num
	variable mode
	variable temp

	variable/G convmode_SimuPDM = mode
	string specname
	variable i
	i=1
	do
		specname = bathname + num2str(i)

		convolvetempall($specname,temp)

		i+=1
	while (i< num+1)

	display
	string conv = "Tconv_"+bathname
	displaymultiF(conv,1,num)

end

Function convolvetempall(name,tt2)
	wave name
	variable tt2
	variable aa

	string conv = "Tconv_"+nameofwave(name)
	duplicate/o name $conv;
	duplicate/o name coef_Tconv;
	//coef_Tconv=exp(-x^2/((3.5*0.086*tt2)/(2*sqrt(ln(2)))^2));

	variable/G convmode_SimuPDM

		if (convmode_SimuPDM == 1)
			coef_Tconv=exp(-x^2/((3.5*0.086*tt2)/(2*sqrt(ln(2)))^2));
		endif
		if (convmode_SimuPDM == 2)
			coef_Tconv=1-1/(1+exp(x/(0.086*tt2)))
			differentiate coef_Tconv
			wavestats/Q coef_Tconv
			coef_Tconv/=V_max
		endif


	wave convw = $conv
	SmoothCustom coef_Tconv convw;
	aa= convw[0]/name[0];
	convw/=aa
	killwaves coef_Tconv
end

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
//** Simulation of TBG and TTG lattice
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
Function ButtonProc_TBGsimu(ctrlName) : ButtonControl
	String ctrlName
	Execute "TBGsimu()"
End
Proc TBGsimu(xx,a1,a2,theta1,theta2)
	variable xx = 300
	variable a1 = 2.46
	variable a2 = 2.46
	variable theta1 = 1.05
	variable theta2	= 0
	prompt xx,"Length of the image (Å)"
	prompt a1,"Lattice constant of layer 1 (Å)"
	prompt a2,"Lattice constant of layer 2 (Å)"
	prompt theta1,"Twist angle of layer 1 (˚)"
	prompt theta2,"Twist angle of layer 2 (˚)"

	variable/G xx_TBGsimu = xx
	variable/G a1_TBGsimu = a1
	variable/G a2_TBGsimu = a2
	variable/G theta1_TBGsimu = theta1
	variable/G theta2_TBGsimu = theta2

	//Generate the First layer
	ExampleTriangularLattice(xx_TBGsimu, xx_TBGsimu, a1_TBGsimu, theta1_TBGsimu*pi/180)
	duplicate/o xwave layer1TBG_x
	duplicate/o ywave layer1TBG_y

	//Generate the First layer
	ExampleTriangularLattice(xx_TBGsimu, xx_TBGsimu, a2_TBGsimu, theta2_TBGsimu*pi/180)
	duplicate/o xwave layer2TBG_x
	duplicate/o ywave layer2TBG_y

	//Draw lattice
	display/N=TBGsimulation;modifygraph width=540,height=540
	appendtograph layer1TBG_y vs layer1TBG_x
	appendtograph layer2TBG_y vs layer2TBG_x
	ModifyGraph mode=3,marker=19,msize=1.2,mrkThick=1,mirror=2,nticks=3,axThick=2
	ModifyGraph rgb(layer1TBG_y)=(0,0,65535)
	ModifyGraph height=0,width={Plan,1,bottom,left}

	//Initialize Control Modula

	SetVariable setvar0 title="X(Å)",size={70,20},value=xx_TBGsimu,proc=SetVarProc_TBG,limits={10,inf,50}
	SetVariable setvar2 title="a1(Å)",size={70,20},value=a1_TBGsimu,proc=SetVarProc_TBG1,limits={1,inf,0.01}
	SetVariable setvar3 title="a2(Å)",size={70,20},value=a2_TBGsimu,proc=SetVarProc_TBG2,limits={1,inf,0.01}
	SetVariable setvar4 title="θ1(˚)",size={70,20},value=theta1_TBGsimu,proc=SetVarProc_TBG1,limits={-360,360,0.1}
	SetVariable setvar5 title="θ2(˚)",size={70,20},value=theta2_TBGsimu,proc=SetVarProc_TBG2,limits={-360,360,0.1}
	Button turnoffls3d size={45,12},valueColor=(0,0,0),fColor=(1,65535,33232),pos={370,0},proc=ButtonProc_lsturnoff3d,title="X",pos={650,0},size={20,12}
end


Function SetVarProc_TBG(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName


	variable/G xx_TBGsimu //= xx
	variable/G a1_TBGsimu //= a1
	variable/G a2_TBGsimu //= a2
	variable/G theta1_TBGsimu //= theta1
	variable/G theta2_TBGsimu //= theta2

	//Generate the First layer
	ExampleTriangularLattice(xx_TBGsimu, xx_TBGsimu, a1_TBGsimu, theta1_TBGsimu*pi/180)
	wave xwave = $"xwave"
	wave ywave = $"ywave"
	duplicate/o xwave layer1TBG_x
	duplicate/o ywave layer1TBG_y

	//Generate the Second layer
	ExampleTriangularLattice(xx_TBGsimu, xx_TBGsimu, a2_TBGsimu, theta2_TBGsimu*pi/180)
	wave xwave = $"xwave"
	wave ywave = $"ywave"
	duplicate/o xwave layer2TBG_x
	duplicate/o ywave layer2TBG_y



End


Function SetVarProc_TBG1(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName


	variable/G xx_TBGsimu //= xx
	variable/G a1_TBGsimu //= a1
	variable/G a2_TBGsimu //= a2
	variable/G theta1_TBGsimu //= theta1
	variable/G theta2_TBGsimu //= theta2

	//Generate the First layer
	ExampleTriangularLattice(xx_TBGsimu, xx_TBGsimu, a1_TBGsimu, theta1_TBGsimu*pi/180)
	wave xwave = $"xwave"
	wave ywave = $"ywave"
	duplicate/o xwave layer1TBG_x
	duplicate/o ywave layer1TBG_y


End


Function SetVarProc_TBG2(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName


	variable/G xx_TBGsimu //= xx
	variable/G a1_TBGsimu //= a1
	variable/G a2_TBGsimu //= a2
	variable/G theta1_TBGsimu //= theta1
	variable/G theta2_TBGsimu //= theta2


	//Generate the Second layer
	ExampleTriangularLattice(xx_TBGsimu, xx_TBGsimu, a2_TBGsimu, theta2_TBGsimu*pi/180)
	wave xwave = $"xwave"
	wave ywave = $"ywave"
	duplicate/o xwave layer2TBG_x
	duplicate/o ywave layer2TBG_y
End

Function ButtonProc_TTGsimu(ctrlName) : ButtonControl
	String ctrlName
	Execute "TTGsimu()"
End

Proc TTGsimu(xx,a1,a2,a3,theta1,theta2,theta3)
	variable xx = 300
	variable a1 = 2.46
	variable a2 = 2.46
	variable a3 = 2.46
	variable theta1 = 1.56
	variable theta2	= 0
	variable theta3 = 1.56

	prompt xx,"Length of the image (Å)"
	prompt a1,"Lattice constant of layer 1 (Å)"
	prompt a2,"Lattice constant of layer 2 (Å)"
	prompt a3,"Lattice constant of layer 3 (Å)"
	prompt theta1,"Twist angle of layer 1 (˚)"
	prompt theta2,"Twist angle of layer 2 (˚)"
	prompt theta3,"Twist angle of layer 3 (˚)"

	variable/G xx_TTGsimu = xx
	variable/G a1_TTGsimu = a1
	variable/G a2_TTGsimu = a2
	variable/G a3_TTGsimu = a3
	variable/G theta1_TTGsimu = theta1
	variable/G theta2_TTGsimu = theta2
	variable/G theta3_TTGsimu = theta3

	//Generate the First layer
	ExampleTriangularLattice(xx_TTGsimu, xx_TTGsimu, a1_TTGsimu, theta1_TTGsimu*pi/180)
	duplicate/o xwave layer1TTG_x
	duplicate/o ywave layer1TTG_y

	//Generate the First layer
	ExampleTriangularLattice(xx_TTGsimu, xx_TTGsimu, a2_TTGsimu, theta2_TTGsimu*pi/180)
	duplicate/o xwave layer2TTG_x
	duplicate/o ywave layer2TTG_y

	//Generate the First layer
	ExampleTriangularLattice(xx_TTGsimu, xx_TTGsimu, a3_TTGsimu, theta3_TTGsimu*pi/180)
	duplicate/o xwave layer3TTG_x
	duplicate/o ywave layer3TTG_y


	//Draw lattice
	display/N=TTGsimulation;modifygraph width=540,height=540
	appendtograph layer1TTG_y vs layer1TTG_x
	appendtograph layer2TTG_y vs layer2TTG_x
	appendtograph layer3TTG_y vs layer3TTG_x
	ModifyGraph mode=3,marker=19,msize=1.2,mrkThick=1,mirror=2,nticks=3,axThick=2
	ModifyGraph rgb(layer2TTG_y)=(0,0,65535)
	ModifyGraph rgb(layer3TTG_y)=(3,52428,1)
	ModifyGraph height=0,width={Plan,1,bottom,left}

	//Initialize Control Modula

	SetVariable setvar0 title="X(Å)",size={70,20},value=xx_TTGsimu,proc=SetVarProc_TTG,limits={10,inf,50}
	SetVariable setvar2 title="a1(Å)",size={70,20},value=a1_TTGsimu,proc=SetVarProc_TTG1,limits={1,inf,0.01}
	SetVariable setvar3 title="a2(Å)",size={70,20},value=a2_TTGsimu,proc=SetVarProc_TTG2,limits={1,inf,0.01}
	SetVariable setvar32 title="a3(Å)",size={70,20},value=a3_TTGsimu,proc=SetVarProc_TTG3,limits={1,inf,0.01}
	SetVariable setvar4 title="θ1(˚)",size={70,20},value=theta1_TTGsimu,proc=SetVarProc_TTG1,limits={-360,360,0.1}
	SetVariable setvar5 title="θ2(˚)",size={70,20},value=theta2_TTGsimu,proc=SetVarProc_TTG2,limits={-360,360,0.1}
	SetVariable setvar52 title="θ3(˚)",size={70,20},value=theta3_TTGsimu,proc=SetVarProc_TTG3,limits={-360,360,0.1}

	Button turnoffls3d size={45,12},valueColor=(0,0,0),fColor=(1,65535,33232),pos={370,0},proc=ButtonProc_lsturnoff3d,title="X",pos={650,0},size={20,12}
end


Function SetVarProc_TTG(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName


	variable/G xx_TTGsimu //= xx
	variable/G a1_TTGsimu //= a1
	variable/G a2_TTGsimu
	variable/G a3_TTGsimu
	variable/G theta1_TTGsimu //= theta1
	variable/G theta2_TTGsimu //= theta2
	variable/G theta3_TTGsimu

	//Generate the First layer
	ExampleTriangularLattice(xx_TTGsimu, xx_TTGsimu, a1_TTGsimu, theta1_TTGsimu*pi/180)
	wave xwave = $"xwave"
	wave ywave = $"ywave"
	duplicate/o xwave layer1TTG_x
	duplicate/o ywave layer1TTG_y

	//Generate the Second layer
	ExampleTriangularLattice(xx_TTGsimu, xx_TTGsimu, a2_TTGsimu, theta2_TTGsimu*pi/180)
	wave xwave = $"xwave"
	wave ywave = $"ywave"
	duplicate/o xwave layer2TTG_x
	duplicate/o ywave layer2TTG_y

	//Generate the Second layer
	ExampleTriangularLattice(xx_TTGsimu, xx_TTGsimu, a3_TTGsimu, theta3_TTGsimu*pi/180)
	wave xwave = $"xwave"
	wave ywave = $"ywave"
	duplicate/o xwave layer3TTG_x
	duplicate/o ywave layer3TTG_y


End


Function SetVarProc_TTG1(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName


	variable/G xx_TTGsimu //= xx
	variable/G a1_TTGsimu //= a1
	variable/G a2_TTGsimu
	variable/G a3_TTGsimu
	variable/G theta1_TTGsimu //= theta1
	variable/G theta2_TTGsimu //= theta2
	variable/G theta3_TTGsimu

	//Generate the First layer
	ExampleTriangularLattice(xx_TTGsimu, xx_TTGsimu, a1_TTGsimu, theta1_TTGsimu*pi/180)
	wave xwave = $"xwave"
	wave ywave = $"ywave"
	duplicate/o xwave layer1TTG_x
	duplicate/o ywave layer1TTG_y


End


Function SetVarProc_TTG2(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName


	variable/G xx_TTGsimu //= xx
	variable/G a1_TTGsimu //= a1
	variable/G a2_TTGsimu
	variable/G a3_TTGsimu
	variable/G theta1_TTGsimu //= theta1
	variable/G theta2_TTGsimu //= theta2
	variable/G theta3_TTGsimu


	//Generate the Second layer
	ExampleTriangularLattice(xx_TTGsimu, xx_TTGsimu, a2_TTGsimu, theta2_TTGsimu*pi/180)
	wave xwave = $"xwave"
	wave ywave = $"ywave"
	duplicate/o xwave layer2TTG_x
	duplicate/o ywave layer2TTG_y
End

Function SetVarProc_TTG3(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName


	variable/G xx_TTGsimu //= xx
	variable/G a1_TTGsimu //= a1
	variable/G a2_TTGsimu
	variable/G a3_TTGsimu
	variable/G theta1_TTGsimu //= theta1
	variable/G theta2_TTGsimu //= theta2
	variable/G theta3_TTGsimu


	//Generate the Second layer
	ExampleTriangularLattice(xx_TTGsimu, xx_TTGsimu, a3_TTGsimu, theta3_TTGsimu*pi/180)
	wave xwave = $"xwave"
	wave ywave = $"ywave"
	duplicate/o xwave layer3TTG_x
	duplicate/o ywave layer3TTG_y
End



//**************************************************************************
//#0 Main Function
//**************************************************************************
Function ExampleTriangularLattice(xx, yy, a, theta)
    Variable xx //= 100  // x-scale limit
    Variable yy// = 100  // y-scale limit
    Variable a //= 10    // Lattice constant
    Variable theta //= 0.1  // Rotation angle in radians

    CreateTriangularLatticeCoordinates(xx, yy, a, theta)

End
//**************************************************************************


//**************************************************************************
//#1 Core Function to output atomic positions of Honeycomb lattice
//**************************************************************************
Function CreateTriangularLatticeCoordinates(xx, yy, a, theta)
    // Input Parameters:
    // xx, yy: Dimensions of the wave's scale (0 to xx, 0 to yy)
    // a: Lattice constant
    // theta: In-plane rotation angle in radians
    // Output:
    // XWave, YWave: 1D waves containing x and y coordinates of all atomic centers

    Variable xx, yy, a, theta

    // Calculate center of the wave for rotation
    Variable centerX = xx / 2
    Variable centerY = yy / 2

    // Extend the range to ensure rotated lattice fills the entire wave dimensions
    Variable extendedX = xx + 2 * a
    Variable extendedY = yy + 2 * a

    // Calculate the number of lattice points in the extended range
    Variable nX = ceil(extendedX / a)
    Variable nY = ceil(extendedY / (sqrt(3) / 2 * a))

    // Create output waves
    Make/O/N=(0) XWave
    Make/O/N=(0) YWave

    // Generate triangular lattice coordinates
    Variable i, j, x, y, xRot, yRot
    For (j = -1.2*nY; j <= 1.2*nY; j += 1)
        For (i = -1.2*nX; i <= 1.2*nX; i += 1)
            x = i * a + (mod(j, 2) * a / 2)  // Offset for alternate rows
            y = j * sqrt(3) / 2 * a

            // Translate to origin, rotate, and translate back
            xRot = (x - centerX) * cos(theta) - (y - centerY) * sin(theta) + centerX
            yRot = (x - centerX) * sin(theta) + (y - centerY) * cos(theta) + centerY

            // Ensure points are within bounds
            If (xRot >= 0 && xRot <= xx && yRot >= 0 && yRot <= yy)
                // Use SetSize to dynamically add points
                Redimension/N=(DimSize(XWave, 0) + 1) XWave
                Redimension/N=(DimSize(YWave, 0) + 1) YWave
                XWave[DimSize(XWave, 0) - 1] = xRot
                YWave[DimSize(YWave, 0) - 1] = yRot
            EndIf
        EndFor
    EndFor

    // Generate second sublattice by shifting all points by a/2 along x-direction and 1/(2*sqrt(3)) along y-direction
    For (j = -1.2*nY; j <= 1.2*nY; j += 1)
        For (i = -1.2*nX; i <= 1.2*nX; i += 1)
            x = i * a + (mod(j, 2) * a / 2) + a / 2  // Shift by a/2 along x-direction
            y = j * sqrt(3) / 2 * a + (1 / (2 * sqrt(3)) * a)  // Shift by 1/(2*sqrt(3)) along y-direction

            // Translate to origin, rotate, and translate back
            xRot = (x - centerX) * cos(theta) - (y - centerY) * sin(theta) + centerX
            yRot = (x - centerX) * sin(theta) + (y - centerY) * cos(theta) + centerY

            // Ensure points are within bounds
            If (xRot >= 0 && xRot <= xx && yRot >= 0 && yRot <= yy)
                Redimension/N=(DimSize(XWave, 0) + 1) XWave
                Redimension/N=(DimSize(YWave, 0) + 1) YWave
                XWave[DimSize(XWave, 0) - 1] = xRot
                YWave[DimSize(YWave, 0) - 1] = yRot
            EndIf
        EndFor
    EndFor

End

///////////////////////////////////////////////////////////////////////////////////////
//Simu Honeycomb lattice
///////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Honeycomb(ctrlName) : ButtonControl
	String ctrlName
	Execute "Ahoneycombc()"
end

Proc Ahoneycombc(xx, a, theta, widthr)
    Variable xx = 100  // x-scale limit
    Variable a = 2.46    // Lattice constant
    Variable theta =0
    variable widthr = 5.5
    prompt xx, "L, Length of image (Å)"
    prompt a, "a, Lattice constant (Å)"
    prompt theta, "Lattice orientation (˚)"
    prompt widthr, "r, Width of Gaussian = a/r"
    Ahoneycomb(xx, a, theta, widthr)
end

Function Ahoneycomb(xx, a, theta, widthr)
    Variable xx //= 100  // x-scale limit
    Variable a //= 10    // Lattice constant
    Variable theta //=0
    variable widthr //= 5.5

    CreateTriangularLatticeCoordinates(xx, xx, a, theta)

    make/n=(1000,1000)/o honeycombspectralFunc
    honeycombspectralFunc = 0
    setscale/i x,0,xx,"",honeycombspectralFunc
    setscale/i y,0,xx,"",honeycombspectralFunc

    wave xwave = $"xwave"
    wave ywave = $"ywave"

    make/n=7/o gcoeff
    gcoeff[0] = 0
    gcoeff[1] = 1
	gcoeff[6] = 0
	gcoeff[3] = a/widthr
    gcoeff[5] = a/widthr

    variable i = 0
    do
    	multiThread gcoeff[2] = xwave[i]
    	multiThread gcoeff[4] = ywave[i]



    	multiThread honeycombspectralFunc += gauss2D(gcoeff,x,y)

    	IF(mod(i,100)==0)
			Print i,"/",dimsize(xwave,0)-1
		Endif

    	i+=1
    while (i<dimsize(xwave,0))

    di(honeycombspectralFunc)

end

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          Append Honeycomb lattice to a Topography                                   //
/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Fitimagehoneycombc(ctrlName) : ButtonControl
	String ctrlName
	Execute "Fitimagehoneycombc()"
End
Proc Fitimagehoneycombc(name, a, theta, dx, dy)
	string name = tpw()
	Variable a  = 2.46//= 10    // Lattice constant
    Variable theta = 0//= 0.1  // Rotation angle in radians
    Variable dx = 0 //= 2      // Phase shift in x-direction
    Variable dy = 0 //= 1

    variable/G a_aph = a
    variable/G theta_aph = theta
    variable/G dx_aph = dx
    variable/G dy_aph = dy

    Fitimagehoneycomb($name, a_aph, theta_aph*pi/180, dx_aph, dy_aph)
    Appendtograph Honeywavey vs Honeywavex;ModifyGraph mode=3,marker=8,msize=6,mrkThick=2;
	ModifyGraph msize=9,rgb=(0,65535,0);ModifyGraph width=0,height={Plan,1,left,bottom}

	SetVariable setva1 win =$grabwin(tpw()),title="a(Å)",size={70,20},value=a_aph,proc=SetVarProc_aph,limits={1,inf,0.01}
	SetVariable setva2 win =$grabwin(tpw()),title="θ(˚)",size={70,20},value=theta_aph,proc=SetVarProc_aph,limits={-360,360,0.1}
	SetVariable setva3 win =$grabwin(tpw()),title="dx(Å)",size={70,20},value=dx_aph,proc=SetVarProc_aph,limits={0,inf,0.01}
	SetVariable setva4 win =$grabwin(tpw()),title="dy(Å)",size={70,20},value=dy_aph,proc=SetVarProc_aph,limits={0,inf,0.01}
end

Function SetVarProc_aph(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

    variable/G a_aph
    variable/G theta_aph
    variable/G dx_aph
    variable/G dy_aph

	Fitimagehoneycomb($tpw(), a_aph, theta_aph*pi/180, dx_aph, dy_aph)
End


Function Fitimagehoneycomb(namew, a, theta, dx, dy)
	wave namew
	Variable a //= 10    // Lattice constant
    Variable theta //= 0.1  // Rotation angle in radians
    Variable dx //= 2      // Phase shift in x-direction
    Variable dy //= 1

	//X length
	variable xx = (dimsize(namew,0)-1)*dimdelta(namew,0)

	//Y length
	variable yy = (dimsize(namew,1)-1)*dimdelta(namew,1)

		//print xx
		//print yy

	Appendhoneycomb00(xx, yy, a, theta, dx, dy)
	wave Honeywavex = $"Honeywavex"
	wave Honeywavey = $"Honeywavey"

		//print dimoffset(namew,0)
		//print dimoffset(namew,1)
	Honeywavex += dimoffset(namew,0)
	Honeywavey += dimoffset(namew,1)
end


Function appendhoneycomb00(xx, yy, a, theta, dx, dy)
    Variable xx //= 100  // x-scale limit
    Variable yy //= 100  // y-scale limit
    Variable a //= 10    // Lattice constant
    Variable theta //= 0.1  // Rotation angle in radians
    Variable dx //= 2      // Phase shift in x-direction
    Variable dy //= 1

    // Calculate center of the wave for rotation
    Variable centerX = xx / 2
    Variable centerY = yy / 2

    // Extend the range to ensure rotated lattice fills the entire wave dimensions
    Variable extendedX = xx + 2 * a
    Variable extendedY = yy + 2 * a

    // Calculate the number of lattice points in the extended range
    Variable nX = ceil(extendedX / a)
    Variable nY = ceil(extendedY / (sqrt(3) / 2 * a))

    // Create output waves
    Make/O/N=(0) Honeywavex
    Make/O/N=(0) Honeywavey

    // Generate triangular lattice coordinates
    Variable i, j, x, y, xRot, yRot
    For (j = -1.5 * nY; j <= 1.5 * nY; j += 1)
        For (i = -1.5 * nX; i <= 1.5 * nX; i += 1)
            x = i * a + (mod(j, 2) * a / 2) + dx  // Offset for alternate rows and apply phase shift dx
            y = j * sqrt(3) / 2 * a + dy          // Apply phase shift dy

            // Translate to origin, rotate, and translate back
            xRot = (x - centerX) * cos(theta) - (y - centerY) * sin(theta) + centerX
            yRot = (x - centerX) * sin(theta) + (y - centerY) * cos(theta) + centerY

            // Ensure points are within bounds
            If (xRot >= 0 && xRot <= xx && yRot >= 0 && yRot <= yy)
                // Use SetSize to dynamically add points
                Redimension/N=(DimSize(Honeywavex, 0) + 1) Honeywavex
                Redimension/N=(DimSize(Honeywavey, 0) + 1) Honeywavey
                Honeywavex[DimSize(Honeywavex, 0) - 1] = xRot
                Honeywavey[DimSize(Honeywavey, 0) - 1] = yRot
            EndIf
        EndFor
    EndFor

    // Generate second sublattice by shifting all points by a/2 along x-direction and 1/(2*sqrt(3)) along y-direction
    For (j = -1.5 * nY; j <= 1.5 * nY; j += 1)
        For (i = -1.5 * nX; i <= 1.5 * nX; i += 1)
            x = i * a + (mod(j, 2) * a / 2) + a / 2 + dx  // Shift by a/2 along x-direction and apply phase shift dx
            y = j * sqrt(3) / 2 * a + (1 / (2 * sqrt(3)) * a) + dy  // Shift by 1/(2*sqrt(3)) along y-direction and apply phase shift dy

            // Translate to origin, rotate, and translate back
            xRot = (x - centerX) * cos(theta) - (y - centerY) * sin(theta) + centerX
            yRot = (x - centerX) * sin(theta) + (y - centerY) * cos(theta) + centerY

            // Ensure points are within bounds
            If (xRot >= 0 && xRot <= xx && yRot >= 0 && yRot <= yy)
                Redimension/N=(DimSize(Honeywavex, 0) + 1) Honeywavex
                Redimension/N=(DimSize(Honeywavey, 0) + 1) Honeywavey
                Honeywavex[DimSize(Honeywavex, 0) - 1] = xRot
                Honeywavey[DimSize(Honeywavey, 0) - 1] = yRot
            EndIf
        EndFor
    EndFor

    //appendtograph Honeywavey vs Honeywavex;ModifyGraph mode=3,marker=8,msize=6,mrkThick=2;
	//ModifyGraph msize=9,rgb=(0,0,0);ModifyGraph width=0,height={Plan,1,left,bottom}
End


/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          Append Triangular lattice to a Topography                                  //
/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Fitimagetriangularc(ctrlName) : ButtonControl
	String ctrlName
	Execute "Fitimagetriangularc()"
End
Proc Fitimagetriangularc(name, a, theta, dx, dy)
	string name = tpw()
	Variable a  = 2.46//= 10    // Lattice constant
    Variable theta = 0//= 0.1  // Rotation angle in radians
    Variable dx = 0 //= 2      // Phase shift in x-direction
    Variable dy = 0 //= 1

    variable/G a_aph = a
    variable/G theta_aph = theta
    variable/G dx_aph = dx
    variable/G dy_aph = dy

    Fitimagetriangular($name, a_aph, theta_aph*pi/180, dx_aph, dy_aph)
    Appendtograph triangularwavey vs triangularwavex;ModifyGraph mode=3,marker=8,msize=6,mrkThick=2;
	ModifyGraph msize=9,rgb=(0,65535,0);ModifyGraph width=0,height={Plan,1,left,bottom}

	SetVariable setva1 win =$grabwin(tpw()),title="a(Å)",size={70,20},value=a_aph,proc=SetVarProc_apsquare,limits={1,inf,0.01}
	SetVariable setva2 win =$grabwin(tpw()),title="θ(˚)",size={70,20},value=theta_aph,proc=SetVarProc_apsquare,limits={-360,360,0.1}
	SetVariable setva3 win =$grabwin(tpw()),title="dx(Å)",size={70,20},value=dx_aph,proc=SetVarProc_apsquare,limits={0,inf,0.01}
	SetVariable setva4 win =$grabwin(tpw()),title="dy(Å)",size={70,20},value=dy_aph,proc=SetVarProc_apsquare,limits={0,inf,0.01}
end

Function SetVarProc_apsquare(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

    variable/G a_aph
    variable/G theta_aph
    variable/G dx_aph
    variable/G dy_aph

	Fitimagetriangular($tpw(), a_aph, theta_aph*pi/180, dx_aph, dy_aph)
End


Function Fitimagetriangular(namew, a, theta, dx, dy)
	wave namew
	Variable a //= 10    // Lattice constant
    Variable theta //= 0.1  // Rotation angle in radians
    Variable dx //= 2      // Phase shift in x-direction
    Variable dy //= 1

	//X length
	variable xx = (dimsize(namew,0)-1)*dimdelta(namew,0)

	//Y length
	variable yy = (dimsize(namew,1)-1)*dimdelta(namew,1)

		//print xx
		//print yy

	Appendtriangular00(xx, yy, a, theta, dx, dy)
	wave triangularwavex = $"triangularwavex"
	wave triangularwavey = $"triangularwavey"

		//print dimoffset(namew,0)
		//print dimoffset(namew,1)
	triangularwavex += dimoffset(namew,0)
	triangularwavey += dimoffset(namew,1)
end


Function appendtriangular00(xx, yy, a, theta, dx, dy)
    Variable xx //= 100  // x-scale limit
    Variable yy //= 100  // y-scale limit
    Variable a //= 10    // Lattice constant
    Variable theta //= 0.1  // Rotation angle in radians
    Variable dx //= 2      // Phase shift in x-direction
    Variable dy //= 1

    // Calculate center of the wave for rotation
    Variable centerX = xx / 2
    Variable centerY = yy / 2

    // Extend the range to ensure rotated lattice fills the entire wave dimensions
    Variable extendedX = xx + 2 * a
    Variable extendedY = yy + 2 * a

    // Calculate the number of lattice points in the extended range
    Variable nX = ceil(extendedX / a)
    Variable nY = ceil(extendedY / (sqrt(3) / 2 * a))

    // Create output waves
    Make/O/N=(0) triangularwavex
    Make/O/N=(0) triangularwavey

    // Generate triangular lattice coordinates
    Variable i, j, x, y, xRot, yRot
    For (j = -1.5 * nY; j <= 1.5 * nY; j += 1)
        For (i = -1.5 * nX; i <= 1.5 * nX; i += 1)
            x = i * a + (mod(j, 2) * a / 2) + dx  // Offset for alternate rows and apply phase shift dx
            y = j * sqrt(3) / 2 * a + dy          // Apply phase shift dy

            // Translate to origin, rotate, and translate back
            xRot = (x - centerX) * cos(theta) - (y - centerY) * sin(theta) + centerX
            yRot = (x - centerX) * sin(theta) + (y - centerY) * cos(theta) + centerY

            // Ensure points are within bounds
            If (xRot >= 0 && xRot <= xx && yRot >= 0 && yRot <= yy)
                // Use SetSize to dynamically add points
                Redimension/N=(DimSize(triangularwavex, 0) + 1) triangularwavex
                Redimension/N=(DimSize(triangularwavey, 0) + 1) triangularwavey
                triangularwavex[DimSize(triangularwavex, 0) - 1] = xRot
                triangularwavey[DimSize(triangularwavey, 0) - 1] = yRot
            EndIf
        EndFor
    EndFor
End



/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
//                              Append Square lattice to a Topography                                  //
/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
Function ButtonProc_Fitimagesquarec(ctrlName) : ButtonControl
	String ctrlName
	Execute "Fitimagesquarec()"
End
Proc Fitimagesquarec(name, a, theta, dx, dy)
	string name = tpw()
	Variable a  = 3.8//= 10    // Lattice constant
    Variable theta = 0//= 0.1  // Rotation angle in radians
    Variable dx = 0 //= 2      // Phase shift in x-direction
    Variable dy = 0 //= 1

    variable/G a_aph = a
    variable/G theta_aph = theta
    variable/G dx_aph = dx
    variable/G dy_aph = dy

    Fitimagesquare($name, a_aph, theta_aph*pi/180, dx_aph, dy_aph)
    Appendtograph squarewavey vs squarewavex;ModifyGraph mode=3,marker=8,msize=6,mrkThick=2;
	ModifyGraph msize=9,rgb=(0,65535,0);ModifyGraph width=0,height={Plan,1,left,bottom}

	SetVariable setva1 win =$grabwin(tpw()),title="a(Å)",size={70,20},value=a_aph,proc=SetVarProc_aptri,limits={1,inf,0.01}
	SetVariable setva2 win =$grabwin(tpw()),title="θ(˚)",size={70,20},value=theta_aph,proc=SetVarProc_aptri,limits={-360,360,0.1}
	SetVariable setva3 win =$grabwin(tpw()),title="dx(Å)",size={70,20},value=dx_aph,proc=SetVarProc_aptri,limits={0,inf,0.01}
	SetVariable setva4 win =$grabwin(tpw()),title="dy(Å)",size={70,20},value=dy_aph,proc=SetVarProc_aptri,limits={0,inf,0.01}
end

Function SetVarProc_aptri(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

    variable/G a_aph
    variable/G theta_aph
    variable/G dx_aph
    variable/G dy_aph

	Fitimagesquare($tpw(), a_aph, theta_aph*pi/180, dx_aph, dy_aph)
End


Function Fitimagesquare(namew, a, theta, dx, dy)
	wave namew
	Variable a //= 10    // Lattice constant
    Variable theta //= 0.1  // Rotation angle in radians
    Variable dx //= 2      // Phase shift in x-direction
    Variable dy //= 1

	//X length
	variable xx = (dimsize(namew,0)-1)*dimdelta(namew,0)

	//Y length
	variable yy = (dimsize(namew,1)-1)*dimdelta(namew,1)

		//print xx
		//print yy

	Appendsquare00(xx, yy, a, theta, dx, dy)
	wave squarewavex = $"squarewavex"
	wave squarewavey = $"squarewavey"

		//print dimoffset(namew,0)
		//print dimoffset(namew,1)
	squarewavex += dimoffset(namew,0)
	squarewavey += dimoffset(namew,1)
end


Function appendsquare00(xx, yy, a, theta, dx, dy)
    Variable xx //= 100  // x-scale limit
    Variable yy //= 100  // y-scale limit
    Variable a //= 10    // Lattice constant
    Variable theta //= 0.1  // Rotation angle in radians
    Variable dx //= 2      // Phase shift in x-direction
    Variable dy //= 1      // Phase shift in y-direction

    // Calculate center of the wave for rotation
    Variable centerX = xx / 2
    Variable centerY = yy / 2

    // Extend the range to ensure rotated lattice fills the entire wave dimensions
    Variable extendedX = xx + 2 * a
    Variable extendedY = yy + 2 * a

    // Calculate the number of lattice points in the extended range
    Variable nX = ceil(extendedX / a)
    Variable nY = ceil(extendedY / a)

    // Create output waves
    Make/O/N=(0) Squarewavex
    Make/O/N=(0) Squarewavey

    // Generate square lattice coordinates
    Variable i, j, x, y, xRot, yRot
    For (j = -1.5 * nY; j <= 1.5 * nY; j += 1)
        For (i = -1.5 * nX; i <= 1.5 * nX; i += 1)
            x = i * a + dx  // Apply phase shift dx
            y = j * a + dy  // Apply phase shift dy

            // Translate to origin, rotate, and translate back
            xRot = (x - centerX) * cos(theta) - (y - centerY) * sin(theta) + centerX
            yRot = (x - centerX) * sin(theta) + (y - centerY) * cos(theta) + centerY

            // Ensure points are within bounds
            If (xRot >= 0 && xRot <= xx && yRot >= 0 && yRot <= yy)
                // Use SetSize to dynamically add points
                Redimension/N=(DimSize(Squarewavex, 0) + 1) Squarewavex
                Redimension/N=(DimSize(Squarewavey, 0) + 1) Squarewavey
                Squarewavex[DimSize(Squarewavex, 0) - 1] = xRot
                Squarewavey[DimSize(Squarewavey, 0) - 1] = yRot
            EndIf
        EndFor
    EndFor
End


