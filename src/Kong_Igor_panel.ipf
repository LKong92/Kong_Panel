#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3
#pragma DefaultTab={3,20,4}

// Self-contained panel entry.
// Opening this file compiles the panel and all action procedures used by its controls.

#include "KP_ColorTables"
#include "KP_GlobalState"
#include "Procedure"
#include "KP_NanonisLoaders"
#include "ModelingTunneling"
#include "General_Simu"
#include "Miscellaneous_Codes"
#include "SmartDisplay"
#include "Smart_3D_Viewer_New"
#include "Map_the_phase_difference_between_two_image"
#include "FFT"
#include "Pierre's Template"
#include "UNISOKU3dscutextract"
#include "Models"
#include "Symmetrization"
#include "Lattice Segregation"
#include "PR_QPI"
#include "transfergraph"
#include "MultipeakforLinecut"
#include "Lawler-Fujita Drift Correction"
#include "Shear Correction for C4"
#include "Triangle Lattice_Graphene_like"
#include "MatrixCalculation"

Window Kong_Igor_panel() : Panel
	PauseUpdate; Silent 1		// building window...
	// Source installs do not carry template.pxp data waves, so restore color tables before controls read them.
	KP_EnsureNewColorTables()
	KP_EnsureStartupGlobals()
	NewPanel /K=2 /W=(909,66,1475,910) as "Kong_Igor_panel"
	ModifyPanel cbRGB=(0,52224,0)
	SetDrawLayer UserBack
	SetDrawEnv linefgc= (65535,0,52428),fillfgc= (51664,44236,58982),fillbgc= (0,0,0)
	DrawRect -98,637,343,730
	SetDrawEnv fillfgc= (0,0,0),fillbgc= (0,0,0)
	DrawRect -98,726,453,843
	SetDrawEnv linefgc= (1,12815,52428),fillfgc= (1,12815,52428),fillbgc= (1,12815,52428)
	DrawRect 342,724,452,843
	SetDrawEnv linethick= 0,linefgc= (65535,21845,0),fillfgc= (65535,65532,16385)
	DrawRect 341,649,453,726
	SetDrawEnv linethick= 0,linefgc= (65535,0,0),fillpat= 4,fillfgc= (0,65535,0),fillbgc= (0,65535,0)
	DrawRect 453,638,515.3125,675
	SetDrawEnv linethick= 0,linefgc= (65535,0,0),fillpat= 4,fillfgc= (65535,43690,0),fillbgc= (65535,43690,0)
	DrawRect 514.3125,638,563,675
	SetDrawEnv textrot= 180
	SetDrawEnv save
	SetDrawEnv linethick= 0,linefgc= (49163,65535,16385),linebgc= (49163,65535,32768),fillpat= 0
	DrawRect 479,14,485,14
	SetDrawEnv linefgc= (1,12815,52428),fillfgc= (26411,1,52428),fillbgc= (26411,1,52428)
	DrawRect 143,4,452,117
	SetDrawEnv fname= "Times New Roman",fsize= 15,textrgb= (65535,65535,65535),textrot= 0
	DrawText 149,24,"ARPES"
	SetDrawEnv linefgc= (1,12815,52428),fillfgc= (1,12815,52428),fillbgc= (1,12815,52428)
	DrawRect 114,478,231,579
	SetDrawEnv linefgc= (1,12815,52428),fillfgc= (1,12815,52428),fillbgc= (1,12815,52428)
	DrawRect 114,478,231,579
	SetDrawEnv linefgc= (65535,0,0),fillfgc= (65535,0,0)
	DrawRect 1.24344978758018e-14,477,340,638
	SetDrawEnv fillfgc= (0,0,0),fillbgc= (0,0,0)
	DrawRect 0,477,117,533
	SetDrawEnv linefgc= (1,12815,52428),fillfgc= (1,12815,52428),fillbgc= (1,12815,52428)
	DrawRect 114,476,222,567
	SetDrawEnv fname= "Times New Roman",fsize= 15,textrgb= (65535,65535,65535),textrot= 0
	DrawText 4,746,"Modeling"
	SetDrawEnv linefgc= (1,12815,52428),fillfgc= (1,12815,52428),fillbgc= (1,12815,52428)
	DrawRect 341,535,450,580
	SetDrawEnv fname= "Times New Roman",textrgb= (65535,65535,65535),textrot= 0
	DrawText 344,550,"Cube"
	SetDrawEnv linefgc= (0,65535,0),fillfgc= (0,65535,0),fillbgc= (0,65535,0)
	DrawRect 220,595,340,637
	SetDrawEnv linefgc= (1,12815,52428),fillfgc= (26411,1,52428),fillbgc= (26411,1,52428)
	DrawRect 341,477,450,535
	SetDrawEnv linefgc= (1,12815,52428),fillfgc= (0,65535,65535),fillbgc= (0,65535,65535)
	DrawRect 114,568,222,637
	SetDrawEnv linefgc= (1,12815,52428),fillfgc= (0,0,0),fillbgc= (26411,1,52428)
	DrawRect 353,117,453,206
	SetDrawEnv fname= "Times New Roman",fsize= 13,textrgb= (65535,65535,65535),textrot= 0
	DrawText 362,133,"Lattice Simu"
	SetDrawEnv linefgc= (1,12815,52428),fillfgc= (26411,1,52428),fillbgc= (26411,1,52428)
	DrawRect 354,206,454,303
	SetDrawEnv fname= "Times New Roman",fsize= 13,textrgb= (65535,65535,65535),textrot= 0
	DrawText 360,223,"Fix Data"
	SetDrawEnv linefgc= (1,12815,52428),fillfgc= (39321,1,1),fillbgc= (26411,1,52428)
	DrawRect 143,117,231,264
	SetDrawEnv fname= "Times New Roman",fsize= 13,textrgb= (65535,65535,65535),textrot= 0
	DrawText 147,134,"Gap Map"
	SetDrawEnv linefgc= (1,12815,52428),fillfgc= (65535,0,0),fillbgc= (26411,1,52428)
	DrawRect 231,116,355,304
	SetDrawEnv fname= "Times New Roman",fsize= 13,textrgb= (65535,65535,65535),textrot= 0
	DrawText 246,133,"Convert Nanonis"
	SetDrawEnv linefgc= (65535,54611,49151),fillfgc= (65535,54611,49151),fillbgc= (26411,1,52428)
	DrawRect 142,264,354,303
	SetDrawEnv linefgc= (1,12815,52428),fillfgc= (0,65535,65535),fillbgc= (0,65535,65535)
	DrawRect 452,477,565,591
	SetDrawEnv fname= "Times New Roman",fsize= 15,textrgb= (65535,0,0),textrot= 0
	DrawText 454,495,"FFT Smart"
	SetDrawEnv linethick= 0,linefgc= (1,12815,52428),fillpat= 4,fillfgc= (1,12815,52428),fillbgc= (1,12815,52428)
	DrawRect 452,508,564.3125,574
	SetDrawEnv linethick= 0,linefgc= (65535,0,0),fillpat= 4,fillfgc= (65535,0,0),fillbgc= (65535,0,0)
	DrawRect 453,553,513.3125,594
	SetDrawEnv linethick= 0,linefgc= (65535,0,0),fillpat= 4,fillfgc= (0,65535,0),fillbgc= (0,65535,0)
	DrawRect 513,553,564.3125,593
	SetDrawEnv fname= "Times New Roman",fsize= 15,textrgb= (65535,0,0),textrot= 0
	DrawText 455,526,"FFT Engineer"
	SetDrawEnv linethick= 0,linefgc= (65535,0,0),fillpat= 4,fillfgc= (29524,1,58982),fillbgc= (29524,1,58982)
	DrawRect 453,592,565.3125,638
	SetDrawEnv fname= "Times New Roman",fsize= 10,textrot= 0
	DrawText 455,606,"C4 Shearing"
	SetDrawEnv fname= "Times New Roman",fsize= 10,textrot= 0
	DrawText 518,566,"LF drift"
	SetDrawEnv fname= "Times New Roman",fsize= 10,textrot= 0
	DrawText 454,566,"FFT Filter"
	SetDrawEnv linethick= 2,linebgc= (0,0,0),fillfgc= (65280,0,0),fillbgc= (65280,0,0)
	DrawRect 10,151,139,201
	SetDrawEnv linefgc= (65535,21845,0),fillfgc= (65535,65532,16385)
	DrawRect 10,203,140,302
	SetDrawEnv fname= "Times New Roman",fsize= 15,fstyle= 1,textrot= 0
	DrawText 15,221,"Get Information"
	SetDrawEnv linethick= 0,linefgc= (65535,21845,0),fillfgc= (65535,65532,16385)
	DrawRect 514,593,563,637
	SetDrawEnv fname= "Times New Roman",fsize= 10,textrot= 0
	DrawText 515,606,"2D Lock-in"
	SetDrawEnv fname= "Times New Roman",textrgb= (65535,65535,65535),textrot= 0
	DrawText 344,491,"Complex Fit"
	SetDrawEnv fname= "Times New Roman",fsize= 15,fstyle= 1,textrgb= (65535,65535,65535),textrot= 0
	DrawText 14,169,"Smart Displayer"
	SetDrawEnv fname= "Times New Roman",fsize= 10,textrot= 0
	DrawText 455,650,"Segregation"
	SetDrawEnv linefgc= (1,12815,52428),linejoin= 1,linecap= 1,fillpat= 4,fillfgc= (0,65535,65535),fillbgc= (0,65535,65535)
	DrawRect 117,779,195,806
	SetDrawEnv fname= "Times New Roman",fsize= 8,fstyle= 1,textrgb= (65535,0,0),textrot= 0
	DrawText 119,791,"MZM Scaling"
	SetDrawEnv linefgc= (1,12815,52428),linejoin= 1,linecap= 1,fillpat= 4,fillfgc= (19675,39321,1),fillbgc= (0,65535,65535)
	DrawRect 117,807,195,840
	SetDrawEnv fname= "Times New Roman",fsize= 8,fstyle= 1,textrgb= (65535,0,0),textrot= 0
	DrawText 119,817,"Haldane Model"
	SetDrawEnv linefgc= (1,12815,52428),linejoin= 1,linecap= 1,fillpat= 4,fillfgc= (1,52428,52428),fillbgc= (0,65535,65535)
	DrawRect 195,807,340,840
	SetDrawEnv fname= "Times New Roman",fsize= 8,fstyle= 1,textrgb= (65535,0,0),textrot= 0
	DrawText 198,817,"Chiral Majorana mode (QH+SC=TSC)"
	SetDrawEnv linefgc= (1,12815,52428),fillfgc= (0,65535,65535),fillbgc= (0,65535,65535)
	DrawRect 342,581,451,650
	SetDrawEnv fname= "Times New Roman",fsize= 8,textrgb= (65535,0,0),textrot= 0
	DrawText 343,621,"Move Window Tech."
	SetDrawEnv fname= "Times New Roman",textrgb= (65535,0,0),textrot= 0
	DrawText 117,582,"MultiSet (Old)"
	SetDrawEnv fname= "Times New Roman",textrgb= (65535,65535,65535),textrot= 0
	DrawText 4,548,"Basic Display"
	SetDrawEnv fname= "Times New Roman",textrgb= (65535,65535,65535),textrot= 0
	DrawText 4,492,"Load individual STS"
	SetDrawEnv fname= "Times New Roman",textrgb= (65535,65535,65535),textrot= 0
	DrawText 117,492,"Normalization"
	SetDrawEnv fname= "Times New Roman",textrgb= (65535,0,0),textrot= 0
	DrawText 344,597,"PDW Domain Map"
	SetDrawEnv fname= "Times New Roman",textrgb= (65535,65535,65535),textrot= 0
	DrawText 224,492,"Matrix Operation (Old)"
	SetDrawEnv fname= "Times New Roman",textrgb= (65535,0,0),textrot= 0
	DrawText 224,610,"\r"
	SetDrawEnv fname= "Times New Roman",textrgb= (65535,0,0),textrot= 0
	DrawText 224,609,"Curve Info Extraction"
	SetDrawEnv linethick= 2,linebgc= (0,0,0),fillfgc= (26411,1,52428),fillbgc= (26411,1,52428)
	DrawRect 10,9.00000000000006,140,147
	SetDrawEnv linethick= 2,linebgc= (0,0,0),fillfgc= (65535,43690,0),fillbgc= (26411,1,52428)
	DrawRect 10,4.00000000000006,140,39
	SetDrawEnv fname= "Times New Roman",fsize= 15,fstyle= 1,textrot= 0
	DrawText 38,26,"Kong Panel"
	SetDrawEnv fname= "Times New Roman",fsize= 9,fstyle= 1,textrgb= (65535,65535,65535),textrot= 0
	DrawText 16,37,"Ver. 9.04.16  (Date: 05/18/2026)"
	SetDrawEnv fname= "Times New Roman",fsize= 10,textrot= 0
	DrawText 516,650,"PR-QPI"
	SetDrawEnv linethick= 0,linefgc= (49163,65535,16385),linebgc= (49163,65535,32768),fillpat= 0
	DrawRect 486,163,492,163
	SetDrawEnv linefgc= (1,12815,52428),fillfgc= (1,12815,52428),fillbgc= (1,12815,52428)
	DrawRect 452,249,566,478
	SetDrawEnv fname= "Times New Roman",fsize= 13,textrgb= (65535,65535,65535),textrot= 0
	DrawText 454,263,"Matrix Engineer"
	SetDrawEnv linethick= 0,fillfgc= (65535,0,0)
	DrawRect 454,149,570,248
	SetDrawEnv fname= "Times New Roman",fsize= 13,textrgb= (65535,65535,65535),textrot= 0
	DrawText 456,165,"Quick Format"
	SetDrawEnv linethick= 0,fillpat= 3,fillfgc= (0,0,0)
	DrawRect 453,215,566,249
	SetDrawEnv linefgc= (65535,21845,0),fillfgc= (65535,65532,16385)
	DrawRect 525,308,564,333
	SetDrawEnv linethick= 0,fillpat= 3,fillfgc= (65535,65535,0)
	DrawRect 454,182,566,215
	SetDrawEnv linethick= 0,linefgc= (1,12815,52428),fillpat= 4,fillfgc= (1,12815,52428),fillbgc= (1,12815,52428)
	DrawRect 451,663,567.3125,676
	SetDrawEnv fname= "Times New Roman",fsize= 10,textrot= 0
	DrawText 455,675,"QPI Range Estimate"
	SetDrawEnv fname= "Times New Roman",fsize= 15,textrgb= (65535,65535,65535),textrot= 0
	DrawText 344,744,"Triangle Lattice"
	SetDrawEnv linethick= 0,fillfgc= (39321,1,31457)
	DrawRect 453,751,570,844
	SetDrawEnv fname= "Times New Roman",fsize= 13,fstyle= 1,textrgb= (65535,65535,65535),textrot= 0
	DrawText 455,769,"Adjust on Graph"
	SetDrawEnv linethick= 0,fillpat= 4,fillfgc= (1,16019,65535),fillbgc= (65535,0,0)
	DrawRect 454,577,563.3125,593
	SetDrawEnv fname= "Times New Roman",fsize= 10,textrot= 0
	DrawText 454,592,"Nano. Strain"
	SetDrawEnv fname= "Times New Roman",textrgb= (65535,0,0),textrot= 0
	DrawText 343,664,"PDW Related Simu."
	SetDrawEnv fname= "Times New Roman",fsize= 15,textrot= 0
	DrawText 4,657,"General Simu"
	SetDrawEnv linefgc= (1,12815,52428),fillfgc= (39321,1,1),fillbgc= (26411,1,52428)
	DrawRect 453,676,563,751
	SetDrawEnv linethick= 3,linefgc= (65535,0,0),fillpat= 0,fillfgc= (1,12815,52428),fillbgc= (1,12815,52428)
	DrawRect 452,508,564.3125,752
	SetDrawEnv linethick= 3,fillpat= 0,fillfgc= (1,12815,52428),fillbgc= (1,12815,52428)
	DrawRect 452,752,564.3125,843
	SetDrawEnv fname= "Times New Roman",fsize= 10,fstyle= 1,textrgb= (65535,65535,65535),textrot= 0
	DrawText 455,689,"Symmetrization"
	SetDrawEnv linefgc= (1,12815,52428),fillfgc= (39321,1,1),fillbgc= (26411,1,52428)
	DrawRect 223,639,341,726
	SetDrawEnv fname= "Times New Roman",textrgb= (65535,65535,65535),textrot= 0
	DrawText 226,654,"Tip Height Experiment"
	Button button14,pos={375.00,434.00},size={64.00,19.00},disable=1,proc=ButtonProc_ConstOffset
	Button button14,title="ConstOff"
	Button button_Generatecut,pos={195.00,102.00},size={72.00,19.00},disable=1,proc=ButtonProc_Makecutimage
	Button button_Generatecut,title="Cut Image"
	Button button_mat3d_pi,pos={148.00,34.00},size={69.00,19.00},disable=1,proc=ButtonProc_mat3d_pi
	Button button_mat3d_pi,title="Mat3D",labelBack=(0,0,0)
	Button button5,pos={219.00,34.00},size={59.00,19.00},disable=1,proc=ButtonProc_mat3dfsploter
	Button button5,title="-->Plot",labelBack=(0,0,0)
	Button button6,pos={200.00,375.00},size={69.00,19.00},disable=1,proc=ButtonProc_combine_range
	Button button6,title="Cb range"
	Button button7,pos={200.00,353.00},size={69.00,19.00},disable=1,proc=ButtonProc_comb_krange
	Button button7,title="Cb krange"
	Button button8,pos={250.00,331.00},size={46.00,19.00},disable=1,proc=ButtonProc_combineall
	Button button8,title="Cb all"
	Button button12,pos={20.00,353.00},size={74.00,19.00},disable=1,proc=ButtonProc_file2wave
	Button button12,title="File 2 wave"
	Button button13,pos={100.00,353.00},size={80.00,19.00},disable=1,proc=ButtonProc_wave2file
	Button button13,title="Wave 2 file"
	Button button15,pos={20.00,377.00},size={120.00,19.00},disable=1,proc=ButtonProc_wave2filenokill
	Button button15,title="Wave2file (no kill)"
	Button button16,pos={304.00,395.00},size={59.00,19.00},disable=1,proc=ButtonProc_new_eres_pi
	Button button16,title="E-comb"
	Button button17,pos={371.00,395.00},size={59.00,19.00},disable=1,proc=ButtonProc_new_kres_pi
	Button button17,title="M-comb"
	Button button18,pos={69.00,396.00},size={51.00,19.00},disable=1,proc=ButtonProc_ln_mat_pi
	Button button18,title="Ln(mat)",fSize=10
	Button button19,pos={16.00,396.00},size={51.00,19.00},disable=1,proc=ButtonProc_mat_n_pi
	Button button19,title="(mat)^n",fSize=10
	Button button20,pos={122.00,375.00},size={64.00,19.00},disable=1,proc=ButtonProc_nan0
	Button button20,title="NaN to 0"
	Button button21,pos={16.00,352.00},size={99.00,19.00},disable=1,proc=ButtonProc_derivmat
	Button button21,title="2nd derivative",fColor=(52428,52425,1)
	Button button22,pos={356.00,35.00},size={49.00,19.00},disable=1,proc=ButtonProc_mat3dkfsploter
	Button button22,title="->Plot",labelBack=(0,0,0)
	Button button23,pos={16.00,374.00},size={89.00,19.00},disable=1,proc=ButtonProc_rot2d_pi
	Button button23,title="Rotate image"
	Button button24,pos={148.00,57.00},size={44.00,19.00},disable=1,proc=ButtonProc_mat3dVD_pi
	Button button24,title="3dVD",labelBack=(0,0,0)
	Button button25,pos={284.00,58.00},size={69.00,19.00},disable=1,proc=ButtonProc_mat3dkVD_pi
	Button button25,title="Mat3dkVD",labelBack=(0,0,0),fSize=12
	Button button26,pos={356.00,58.00},size={49.00,19.00},disable=1,proc=ButtonProc_mat3dkVDfsploter
	Button button26,title="->Plot",labelBack=(0,0,0)
	Button button45,pos={284.00,81.00},size={69.00,19.00},disable=1,proc=ButtonProc_mat3dkHD_pi
	Button button45,title="Mat3dkHD",labelBack=(0,0,0),fSize=12
	Button button46,pos={356.00,80.00},size={49.00,19.00},disable=1,proc=ButtonProc_mat3dkHDfsploter
	Button button46,title="->Plot",labelBack=(0,0,0)
	Button button27,pos={284.00,35.00},size={69.00,19.00},disable=1,proc=ButtonProc_mat3dk_pi
	Button button27,title="Mat3dk",labelBack=(0,0,0),fSize=12
	Button button30,pos={220.00,57.00},size={59.00,19.00},disable=1,proc=ButtonProc_mat3dVDfsploter
	Button button30,title="-->Plot",labelBack=(0,0,0)
	Button button44,pos={221.00,80.00},size={59.00,19.00},disable=1,proc=ButtonProc_mat3dHDfsploter
	Button button44,title="-->Plot",labelBack=(0,0,0)
	Button button31,pos={316.00,372.00},size={99.00,19.00},disable=1,proc=ButtonProc_new_step
	Button button31,title="New-stepsize"
	Button button2001,pos={122.00,353.00},size={64.00,19.00},disable=1,proc=ButtonProc_zeronan
	Button button2001,title="0 to NaN"
	Button button32,pos={269.00,102.00},size={59.00,19.00},disable=1,proc=ButtonProc_allcuts
	Button button32,title="All cuts"
	Button button34,pos={76.00,336.00},size={69.00,19.00},disable=1,proc=ButtonProc_normwave
	Button button34,title="Normwave"
	Button button36,pos={139.00,331.00},size={54.00,19.00},disable=1,proc=ButtonProc_smoothmat_k
	Button button36,title="Smooth",fSize=10
	Button button37,pos={339.00,349.00},size={69.00,19.00},disable=1,proc=ButtonProc_give_area
	Button button37,title="Give area"
	Button button38,pos={203.00,352.00},size={24.00,19.00},disable=1,proc=ButtonProc_finddispersion_min
	Button button38,title="V-"
	Button button39,pos={232.00,352.00},size={24.00,19.00},disable=1,proc=ButtonProc_finddispersionHD_min
	Button button39,title="H-"
	Button button40,pos={202.00,373.00},size={80.00,19.00},disable=1,proc=ButtonProc_showpntreader
	Button button40,title="Bands table"
	Button button43,pos={123.00,396.00},size={80.00,19.00},disable=1,proc=ButtonProc_NaN0mat3d
	Button button43,title="NaN0mat3d",fSize=10
	Button but_mat3dHD,pos={148.00,80.00},size={44.00,19.00},disable=1,proc=ButtonProc_mat3dHD_pi
	Button but_mat3dHD,title="3dHD",labelBack=(0,0,0)
	Button but_rm_simpleedc,pos={28.00,423.00},size={49.00,19.00},disable=1,proc=ButtonProc_Rm_simplebgnd_edc
	Button but_rm_simpleedc,title="EDC"
	Button but_rm_mat,pos={88.00,423.00},size={49.00,19.00},disable=1,proc=ButtonProc_Rm_simplebgnd_mat
	Button but_rm_mat,title="Matrix"
	Button but_sym_edc,pos={13.00,336.00},size={59.00,19.00},disable=1,proc=ButtonProc_sym_one_edc
	Button but_sym_edc,title="Sym EDC"
	PopupMenu Data_type,pos={17.00,65.00},size={115.00,20.00},bodyWidth=115,proc=PopMenuProc
	PopupMenu Data_type,mode=4,popvalue=" txt (A1)",value=#"\"pxt;txt (Scienta);dat (Scienta); txt (A1); asc (txt)\""
	Button button_copy_traces,pos={149.00,336.00},size={99.00,19.00},disable=1,proc=ButtonProc_Copytraces
	Button button_copy_traces,title="Copy all traces"
	TabControl tab_matrices,pos={7.00,304.00},size={445.00,174.00},proc=TabProc_main
	TabControl tab_matrices,labelBack=(16385,49025,65535),font="Geneva",fSize=11
	TabControl tab_matrices,fStyle=0,tabLabel(0)="Matrices",tabLabel(1)="Traces"
	TabControl tab_matrices,tabLabel(2)="Pres. 1",tabLabel(3)="2"
	TabControl tab_matrices,tabLabel(4)="Miscellaneous",value=3
	GroupBox groupstepsize,pos={297.00,355.00},size={139.00,69.00},disable=1
	GroupBox groupstepsize,title="Change Stepsize",fSize=12,fStyle=1
	GroupBox groupstepsize,fColor=(0,9472,39168)
	GroupBox groupsaveload,pos={12.00,333.00},size={179.00,69.00},disable=1
	GroupBox groupsaveload,title="Save and load",fSize=12,fStyle=1
	GroupBox groupsaveload,fColor=(52428,1,1)
	GroupBox groupfinddispersion,pos={198.00,332.00},size={133.00,65.00},disable=1
	GroupBox groupfinddispersion,title="Find Dispersion",fSize=12,fStyle=1
	GroupBox groupfinddispersion,fColor=(1,26214,0)
	GroupBox groupRmback,pos={12.00,405.00},size={139.00,44.00},disable=1
	GroupBox groupRmback,title="Rm linear bkgnd",fSize=12,fStyle=1
	GroupBox groupRmback,fColor=(0,17409,26214)
	Button buttonefedc,pos={284.00,434.00},size={89.00,19.00},disable=1,proc=ButtonProc_put_fermi_edc
	Button buttonefedc,title="EF line (EDC)"
	Button buttonEFimage,pos={184.00,434.00},size={99.00,19.00},disable=1,proc=ButtonProc_put_fermi_image
	Button buttonEFimage,title="EF line (image)"
	Button coloredcnow,pos={310.00,348.00},size={42.00,19.00},disable=1,proc=ButtonProc_color_edc
	Button coloredcnow,title="Color"
	PopupMenu inversecoloredc,pos={357.00,358.00},size={77.00,20.00},disable=1,proc=PopMenuProc_2
	PopupMenu inversecoloredc,mode=1,popvalue="Normal",value=#"\"Normal;Inverse\""
	PopupMenu edccolorset,pos={184.00,349.00},size={120.00,20.00},bodyWidth=120,disable=1,proc=PopMenuProc_1
	PopupMenu edccolorset,mode=15,value=#"\"*COLORTABLEPOPNONAMES*\""
	GroupBox grouplotoftraces,pos={178.00,330.00},size={268.00,126.00},disable=1
	GroupBox grouplotoftraces,title="Group of traces",fSize=12,fStyle=1
	GroupBox grouplotoftraces,fColor=(65535,65535,65535)
	Button buttonintbe,pos={20.00,350.00},size={69.00,19.00},disable=1,proc=ButtonProc_legend_int_vs_BE
	Button buttonintbe,title="Int. vs BE"
	Button buttonintke,pos={100.00,349.00},size={69.00,19.00},disable=1,proc=ButtonProc_legend_int_vs_KE
	Button buttonintke,title="Int. vs KE"
	Button buttonbeangle,pos={20.00,370.00},size={69.00,19.00},disable=1,proc=ButtonProc_legend_BE_vs_angle
	Button buttonbeangle,title="BE vs \\F'symbol'θ"
	Button buttonKEangle,pos={100.00,370.00},size={69.00,19.00},disable=1,proc=ButtonProc_legend_KE_vs_angle
	Button buttonKEangle,title="KE vs \\F'symbol'θ"
	Button buttonBEvsmom_pi,pos={20.00,393.00},size={149.00,15.00},disable=1,proc=ButtonProc_legendBEvsmompia
	Button buttonBEvsmom_pi,title="BE vs Momentum (\\F'symbol'ώ\\F'Geneva'/a)"
	Button buttonBEvsmom_pi,fSize=10
	Button buttonBEvsmom_pi1,pos={21.00,411.00},size={149.00,15.00},disable=1,proc=ButtonProc_legendBEvsmomang
	Button buttonBEvsmom_pi1,title="BE vs Momentum (√Ö\\S-1\\M)",fSize=10
	GroupBox grouplegend,pos={14.00,329.00},size={166.00,147.00},disable=1
	GroupBox grouplegend,title="Axis legend",fSize=12,fStyle=1
	GroupBox grouplegend,fColor=(26411,1,52428)
	PopupMenu mirror_onoff,pos={22.00,450.00},size={92.00,20.00},disable=1,proc=PopMenuProc_mirroronoff
	PopupMenu mirror_onoff,mode=2,popvalue="Mirror ON",value=#"\"Mirror OFF;Mirror ON\""
	PopupMenu popupthicks_inout,pos={21.00,429.00},size={112.00,20.00},disable=1,proc=PopMenuProc_6
	PopupMenu popupthicks_inout,mode=2,popvalue="Ticks outside",value=#"\"Ticks inside;Ticks outside\""
	Button button33,pos={147.00,229.00},size={80.00,19.00},disable=1,proc=ButtonProc_making_fsH
	Button button33,title="Making FS",fColor=(1,26214,0)
	Button button35,pos={147.00,229.00},size={80.00,19.00},disable=1,proc=ButtonProc_making_fs2f
	Button button35,title="Making FS",fColor=(1,26214,0)
	Button for_copy_TB2f,pos={230.00,229.00},size={74.00,19.00},disable=1,proc=ButtonProc_copy_circles2f
	Button for_copy_TB2f,title="Copy TB"
	Button for_image_fs2f,pos={148.00,252.00},size={80.00,19.00},disable=1,proc=ButtonProc_image_fs2f
	Button for_image_fs2f,title="\\K(65535,65535,65535)Image FS",fColor=(27085,28,1)
	Button for_image_fsH,pos={148.00,252.00},size={80.00,19.00},disable=1,proc=ButtonProc_image_fsHEX
	Button for_image_fsH,title="\\K(65535,65535,65535)Image FS",fColor=(27085,28,1)
	Button button41,pos={16.00,419.00},size={89.00,19.00},disable=1,proc=ButtonProc_normcut
	Button button41,title="Norm matrix"
	Button button42,pos={108.00,419.00},size={54.00,19.00},disable=1,proc=ButtonProc_get_fermi_profile
	Button button42,title="Fermi P"
	Button button47,pos={252.00,336.00},size={49.00,19.00},disable=1,proc=ButtonProc_rot_vector
	Button button47,title="Rotate"
	Button button48,pos={212.00,442.00},size={124.00,19.00},disable=1,proc=ButtonProc_sym_edc_matrix
	Button button48,title="Symetrize EDC mat"
	Button button49,pos={304.00,336.00},size={89.00,19.00},disable=1,proc=ButtonProc_dividewavebyfermi
	Button button49,title="Divide by FD"
	Button button50,pos={16.00,442.00},size={84.00,19.00},disable=1,proc=ButtonProc_dividematrixbyfermi
	Button button50,title="Divide by FD"
	Button button51,pos={105.00,442.00},size={49.00,19.00},disable=1,proc=ButtonProc_keep_positive
	Button button51,title="Keep +"
	Button button52,pos={158.00,442.00},size={49.00,19.00},disable=1,proc=ButtonProc_keep_negative
	Button button52,title="Keep -"
	Button button55,pos={266.00,352.00},size={24.00,19.00},disable=1,proc=ButtonProc_finddispersion_plus
	Button button55,title="V+"
	Button button56,pos={294.00,352.00},size={24.00,19.00},disable=1,proc=ButtonProc_finddispersionHDplus
	Button button56,title="H+"
	Button button58,pos={13.00,360.00},size={134.00,19.00},disable=1,proc=ButtonProc_openbkgndremover
	Button button58,title="\\K(65535,0,0)Background remover"
	Button button59,pos={152.00,360.00},size={114.00,19.00},disable=1,proc=ButtonProc_trans2equiv_waves
	Button button59,title="Equivalent waves"
	Button buttonini,pos={18.00,42.00},size={115.00,19.00},proc=ButtonProc_mainpanelinitalize
	Button buttonini,title="\\K(65535,65535,65535)Initialize",fSize=12,fStyle=1
	Button buttonini,fColor=(39321,1,1)
	Button buttonhelptools1,pos={411.00,331.00},size={24.00,19.00},disable=1,proc=Button_Help_tab_matrices
	Button buttonhelptools1,title="\\K(65535,65535,65535)?",fSize=15,fStyle=0
	Button buttonhelptools1,fColor=(16385,16388,65535)
	Button buttonhelptools2,pos={408.00,332.00},size={24.00,19.00},disable=1,proc=Button_help_tab_traces
	Button buttonhelptools2,title="\\K(65535,65535,65535)?",fSize=15,fStyle=16
	Button buttonhelptools2,fColor=(16385,16388,65535)
	Button buttonhelptools4,pos={406.00,330.00},size={24.00,19.00},disable=1,proc=Button_Help_tab_Misc
	Button buttonhelptools4,title="\\K(65535,65535,65535)?",fSize=15,fStyle=16
	Button buttonhelptools4,fColor=(16385,16388,65535)
	Button button4,pos={316.00,331.00},size={74.00,19.00},disable=1,proc=ButtonProc_trans2equiv_mat
	Button button4,title="Equiv. mat"
	Button button10,pos={206.00,423.00},size={29.00,19.00},disable=1,proc=ButtonProc_FlipRGBimage
	Button button10,title="Flip"
	Button button60,pos={238.00,423.00},size={80.00,19.00},disable=1,proc=ButtonProc_RGBimagetoRGB
	Button button60,title="Image2RGB"
	Button button61,pos={324.00,423.00},size={54.00,19.00},disable=1,proc=ButtonProc_RGBimagetoIntensity
	Button button61,title="\\K(65535,0,0)RGB2Int"
	GroupBox groupimage,pos={202.00,406.00},size={182.00,47.00},disable=1
	GroupBox groupimage,title="RGB image",fSize=12,fStyle=1,fColor=(26411,1,52428)
	Button button63,pos={284.00,35.00},size={69.00,19.00},disable=1,proc=ButtonProc_make_mat3dk
	Button button63,title="Mat3dk",labelBack=(0,0,0)
	Button button64,pos={284.00,58.00},size={69.00,19.00},disable=1,proc=ButtonProc_make_mat3dkVD
	Button button64,title="Mat3dkVD",labelBack=(0,0,0)
	Button button65,pos={284.00,81.00},size={69.00,19.00},disable=1,proc=ButtonProc_make_mat3dkHD
	Button button65,title="Mat3dkHD",labelBack=(0,0,0)
	Button button66,pos={150.00,34.00},size={74.00,19.00},disable=1,proc=ButtonProc_Make_onechunkcut
	Button button66,title="1chunkcut"
	Button button67,pos={227.00,34.00},size={54.00,19.00},disable=1,proc=ButtonProc_Make_allchunkcuts
	Button button67,title="All Ckts"
	Button button68,pos={150.00,56.00},size={49.00,19.00},disable=1,proc=ButtonProc_Generate_chunklist
	Button button68,title="Mk List"
	Button button69,pos={152.00,78.00},size={49.00,19.00},disable=1,proc=ButtonProc_deriv_1chunkcut
	Button button69,title="Deriv1"
	Button button70,pos={202.00,78.00},size={54.00,19.00},disable=1,proc=ButtonProc_deriv_allchunkcut
	Button button70,title="Deriv all"
	Button button71,pos={280.00,102.00},size={99.00,19.00},disable=1,proc=ButtonProc_angmodeconverterfs
	Button button71,title="Angle Cvter \\K(65535,0,0)FS"
	Button button72,pos={340.00,440.00},size={69.00,19.00},disable=1,proc=ButtonProc_shiftNsym
	Button button72,title="ShiftNsym"
	Button button108,pos={149.00,102.00},size={29.00,19.00},disable=1,proc=ButtonProc_CVT2EK_exact1cut
	Button button108,title="\\F'symbol'θ\\F'arial'2k"
	Button button74,pos={20.00,344.00},size={52.00,19.00},proc=ButtonProc_Capturename
	Button button74,title="Capture",fSize=11
	SetVariable setvargrnum,pos={73.00,346.00},size={44.00,14.00},title="#"
	SetVariable setvargrnum,labelBack=(16385,49025,65535)
	SetVariable setvargrnum,limits={0,inf,1},value=topgraphnum
	Slider topimagetop,pos={20.00,390.00},size={374.00,42.00},proc=SliderProc_topmax
	Slider topimagetop,fSize=8
	Slider topimagetop,limits={-2,3,0.01},value=0.0432300861154021,vert=0,ticks=4
	Slider topimagebot,pos={21.00,432.00},size={374.00,17.00},proc=SliderProc_topmin
	Slider topimagebot,fSize=8,limits={-2,3,0.01},value=-1.1,vert=0,ticks=0
	Button button_a_up,pos={398.00,386.00},size={17.00,18.00},proc=Button_image_auto_up
	Button button_a_up,title="A",fSize=11
	Button button_a_down,pos={398.00,431.00},size={17.00,18.00},proc=Button_image_auto_down
	Button button_a_down,title="A",fSize=11
	Button button_0_up,pos={417.00,386.00},size={17.00,18.00},proc=Button_image_0_up
	Button button_0_up,title="0",fSize=12
	Button button_0_down,pos={417.00,431.00},size={17.00,18.00},proc=Button_image_0_down
	Button button_0_down,title="0",fSize=11
	Button button_a_both,pos={398.00,408.00},size={34.00,19.00},proc=Button_image_auto_both
	Button button_a_both,title="Auto",labelBack=(52428,17472,1),fSize=11,fStyle=0
	Button button_a_both,fColor=(52428,17472,1)
	PopupMenu popupmatcolor,pos={122.00,344.00},size={200.00,20.00},proc=PopMenuProc_colormat
	PopupMenu popupmatcolor,mode=51,value=#"\"*COLORTABLEPOP*\""
	PopupMenu popupinvmatcolor,pos={325.00,344.00},size={77.00,20.00},proc=PopMenuProc_colormatinv
	PopupMenu popupinvmatcolor,mode=1,popvalue="Normal",value=#"\"Normal;Inverse\""
	GroupBox Matcolorscalegroup,pos={16.00,326.00},size={421.00,109.00}
	GroupBox Matcolorscalegroup,title="Matrix color scale",fSize=12,fStyle=1
	GroupBox Matcolorscalegroup,fColor=(1,3,39321)
	Button button75,pos={150.00,34.00},size={54.00,19.00},disable=1,proc=ButtonProc_make_table_hv_kz
	Button button75,title="Table"
	Button button76,pos={150.00,57.00},size={54.00,19.00},disable=1,proc=ButtonProc_CVT2K_vs_hv
	Button button76,title="Map hv"
	Button button77,pos={150.00,80.00},size={54.00,19.00},disable=1,proc=ButtonProc_CVT2K_vs_kz
	Button button77,title="Map kz"
	Button button78,pos={208.00,58.00},size={74.00,19.00},disable=1,proc=ButtonDuplicate_hvmat3d
	Button button78,title="-->mat3d"
	Button button79,pos={208.00,80.00},size={74.00,19.00},disable=1,proc=ButtonDuplicate_kzmat3d
	Button button79,title="-->mat3d"
	Button button80,pos={312.00,58.00},size={29.00,19.00},disable=1,proc=ButtonProc_mat3dVD_pi
	Button button80,title="VD",labelBack=(0,0,0)
	Button button81,pos={366.00,34.00},size={59.00,19.00},disable=1,proc=ButtonProc_mat3dfsploter
	Button button81,title="-->Plot",labelBack=(0,0,0)
	Button button82,pos={366.00,58.00},size={59.00,19.00},disable=1,proc=ButtonProc_mat3dVDfsploter
	Button button82,title="-->Plot",labelBack=(0,0,0)
	Button button83,pos={312.00,80.00},size={29.00,19.00},disable=1,proc=ButtonProc_mat3dHD_pi
	Button button83,title="HD",labelBack=(0,0,0)
	Button button84,pos={366.00,80.00},size={59.00,19.00},disable=1,proc=ButtonProc_mat3dHDfsploter
	Button button84,title="-->Plot",labelBack=(0,0,0)
	Button button85,pos={408.00,35.00},size={19.00,19.00},disable=1,proc=ButtonProc_mat3dkrot
	Button button85,title="\\K(65535,0,0)Q",font="Wingdings 3",fStyle=0
	Button button85,fColor=(32792,65535,1)
	Button button86,pos={408.00,58.00},size={19.00,19.00},disable=1,proc=ButtonProc_mat3dkVDrot
	Button button86,title="\\K(65535,0,0)Q",font="Wingdings 3",fStyle=0
	Button button86,fColor=(32792,65535,1)
	Button button87,pos={408.00,80.00},size={19.00,19.00},disable=1,proc=ButtonProc_mat3dkHDrot
	Button button87,title="\\K(65535,0,0)Q",font="Wingdings 3",fStyle=0
	Button button87,fColor=(32792,65535,1)
	Button button88,pos={381.00,102.00},size={44.00,19.00},disable=1,proc=ButtonProcInterp3D
	Button button88,title="Interp"
	Button button89,pos={204.00,396.00},size={89.00,19.00},disable=1,proc=ButtonProcCutNaNedges
	Button button89,title="CutNaNedges",fSize=10
	Button button90,pos={115.00,449.00},size={59.00,19.00},disable=1,proc=Button_set_auto_axis
	Button button90,title="A axises"
	Button button91,pos={165.00,419.00},size={54.00,19.00},disable=1,proc=Button_adjust_to_fp
	Button button91,title="Fix FP 1"
	Button button92,pos={221.00,419.00},size={24.00,19.00},disable=1,proc=Button_adjust_all_to_fp
	Button button92,title="All"
	Button button93,pos={16.00,330.00},size={120.00,19.00},disable=1,proc=ButtonProc_curv_Zhang
	Button button93,title="\\K(65535,65535,65535)Peng's Curvature",fSize=14
	Button button93,fColor=(13107,0,5243)
	Button button94,pos={14.00,384.00},size={94.00,19.00},disable=1,proc=ButtonProc_findEres
	Button button94,title="\\K(65535,65535,65535)E-Resolution"
	Button button94,labelBack=(65535,65535,65535),fStyle=1,fColor=(13112,0,26214)
	Button button95,pos={340.00,372.00},size={69.00,19.00},disable=1,proc=ButtonProcAVG_tool
	Button button95,title="\\K(65535,65535,0)AVG_tool",fStyle=1,fColor=(0,0,65535)
	Button button111,pos={150.00,101.00},size={54.00,19.00},disable=1,proc=ButtonProc_symmat3dhv
	Button button111,title="Sym hv"
	Button button112,pos={198.00,57.00},size={19.00,19.00},disable=1,proc=ButtonProc_mat3dVC_pi
	Button button112,title="\\K(65535,0,0)C",labelBack=(0,0,0)
	Button button113,pos={198.00,80.00},size={19.00,19.00},disable=1,proc=ButtonProc_mat3dHC_pi
	Button button113,title="\\K(65535,0,0)C",labelBack=(0,0,0)
	Button button114,pos={344.00,58.00},size={19.00,19.00},disable=1,proc=ButtonProc_mat3dVC_pi
	Button button114,title="\\K(65535,0,0)C",labelBack=(0,0,0)
	Button button115,pos={344.00,80.00},size={19.00,19.00},disable=1,proc=ButtonProc_mat3dHC_pi
	Button button115,title="\\K(65535,0,0)C",labelBack=(0,0,0)
	Button lykongmap,pos={144.00,31.00},size={100.00,18.00},proc=ButtonProc_kly_mapping
	Button lykongmap,title="map k\\Bx\\M-k\\By"
	Button button00,pos={144.00,52.00},size={100.00,18.00},proc=ButtonProc_renormcuts_k
	Button button00,title="Rescale k"
	Button button02,pos={348.00,31.00},size={100.00,18.00},proc=ButtonProc_Kz_predict
	Button button02,title="k\\Bz\\M/V\\B0\\M before"
	Button lykongmap2,pos={348.00,11.00},size={100.00,18.00},proc=ButtonProc_kly_Kzmap
	Button lykongmap2,title="map k\\Bz"
	Button MBEkly1,pos={144.00,94.00},size={100.00,18.00},proc=ButtonProc_MBE1MLTime
	Button MBEkly1,title="MBE_1MLTime"
	Button MBEkly2,pos={348.00,52.00},size={100.00,18.00},proc=ButtonProc_Kz_predict2
	Button MBEkly2,title="k\\Bz\\M/V\\B0\\M after"
	Button AuFit,pos={246.00,31.00},size={100.00,18.00},proc=ButtonProc_AuFitkly
	Button AuFit,title="Au Fit"
	Button Normformap,pos={246.00,73.00},size={100.00,18.00},proc=ButtonProc_Normdivide
	Button Normformap,title="Norm for map"
	Button button116,pos={348.00,73.00},size={100.00,18.00},proc=ButtonProc_CEM2DToKZ
	Button button116,title="CEM k\\Bz\\M"
	Button Normformap1,pos={348.00,94.00},size={100.00,18.00},proc=ButtonProc_bkremover
	Button Normformap1,title="BKG remover"
	Button Map51,pos={456.00,58.00},size={80.00,15.00},proc=ButtonProc_findmaxBatch
	Button Map51,title="Max in Batch",fSize=10
	Button button_LoadAll,pos={18.00,86.00},size={60.00,19.00},proc=ButtonProc_Loaddata2
	Button button_LoadAll,title="LD 2D",fColor=(65535,65535,65535)
	Button button_LoadDA30SSRF,pos={18.00,105.00},size={60.00,19.00},proc=ButtonProc_LoadDA30
	Button button_LoadDA30SSRF,title="LDA30",fColor=(65535,65535,65535)
	Button button3,pos={18.00,126.00},size={60.00,19.00},proc=ButtonProc_dataploter
	Button button3,title="Ploter",labelBack=(27085,28,1),fColor=(65535,21845,0)
	Button button05,pos={81.00,126.00},size={50.00,19.00},proc=ButtonProc_dataploter2
	Button button05,title="P2",labelBack=(27085,28,1),fColor=(65535,21845,0)
	Button PeakvsGate,pos={456.00,7.00},size={80.00,15.00},proc=ButtonProc_gatemapextractpeak
	Button PeakvsGate,title="PeakvsGate",fSize=11
	Button PKvsGrid,pos={456.00,24.00},size={80.00,15.00},proc=ButtonProc_gridextractpeak
	Button PKvsGrid,title="PeakvsGrid",fSize=11
	Button button53,pos={196.00,331.00},size={48.00,19.00},disable=1,proc=ButtonProc_SmoothMat_k23
	Button button53,title="Sm_BS",fSize=10
	Button Map59,pos={240.00,136.00},size={106.00,30.00},proc=ButtonProc_getslicerData
	Button Map59,title="3D to 2Ds \r (Grid Map)"
	Button button100,pos={149.00,102.00},size={44.00,19.00},disable=1,proc=ButtonProc_CVT2EK
	Button button100,title="\\F'symbol'θ\\F'arial' to k"
	Button button01,pos={246.00,52.00},size={100.00,18.00},proc=ButtonProc_CVT2EK_pi_renorm
	Button button01,title="\\F'symbol'θ\\F'arial' to k"
	Button Normline2p3,pos={456.00,75.00},size={80.00,15.00},proc=ButtonProc_subsc
	Button Normline2p3,title="Subtset",fSize=11
	Button button03,pos={456.00,92.00},size={80.00,15.00},proc=ButtonProc_Constofftheset
	Button button03,title="Offset The",fSize=11
	Button button04,pos={456.00,41.00},size={80.00,15.00},proc=ButtonProc_LiFeAsfindmiushift
	Button button04,title="µ-shift LFA",fSize=11
	Button Symx3,pos={4.00,606.00},size={25.00,12.00},proc=ButtonProc_xplusall
	Button Symx3,title="V+",fSize=10
	Button Map13,pos={64.00,578.00},size={45.00,12.00},proc=ButtonProc_Layoutmap
	Button Map13,title="VMap",fSize=10
	Button Symx1,pos={4.00,550.00},size={105.00,12.00},proc=ButtonProc_displaymulti
	Button Symx1,title="Display Waterfall",fSize=10
	Button Symx2,pos={61.00,493.00},size={50.00,12.00},proc=ButtonProc_extractfromdos
	Button Symx2,title="ExSTS",fSize=10
	Button Symx4,pos={31.00,606.00},size={25.00,12.00},proc=ButtonProc_xmultisall
	Button Symx4,title="V*",fSize=10
	Button Map1,pos={118.00,493.00},size={100.00,12.00},proc=ButtonProc_Linenorm
	Button Map1,title="LnNorm FitAll",fSize=10
	Button Normline2p,pos={118.00,508.00},size={80.00,12.00},proc=ButtonProc_line2p
	Button Normline2p,title="Old LnNorm2P",fSize=10
	Button Map5,pos={118.00,536.00},size={100.00,12.00},proc=ButtonProc_normwavemulti
	Button Map5,title="NumNorm_SR",fSize=10,fColor=(65535,65535,0)
	Button Map7,pos={225.00,508.00},size={112.00,12.00},proc=ButtonProc_Interpoint
	Button Map7,title="Interpolate All",fSize=10
	Button Map8,pos={4.00,592.00},size={51.00,12.00},proc=ButtonProc_Isolate2C
	Button Map8,title="Ratio",fSize=10
	Button Map9,pos={225.00,522.00},size={57.00,12.00},proc=ButtonProc_duplicateall
	Button Map9,title="Dup All",fSize=10
	Button Map2,pos={58.00,606.00},size={25.00,12.00},proc=ButtonProc_addyall
	Button Map2,title="Y+",fSize=10
	Button Map03,pos={199.00,508.00},size={19.00,12.00},proc=ButtonProc_selectlinenorm
	Button Map03,title="all",fSize=10
	Button Map01,pos={225.00,552.00},size={56.00,12.00},proc=ButtonProc_Areacurve
	Button Map01,title="Area All",fSize=10
	Button Map02,pos={225.00,582.00},size={112.00,12.00},proc=ButtonProc_summul
	Button Map02,title="SumTrace",fSize=10
	Button Map07,pos={225.00,567.00},size={112.00,12.00},proc=ButtonProc_2ndDall
	Button Map07,title="2ndDif All",fSize=10
	Button Map10,pos={118.00,550.00},size={100.00,12.00},proc=ButtonProc_normwavemulti2
	Button Map10,title="NormNum_TR",fSize=10
	Button Map11,pos={118.00,608.00},size={100.00,12.00},proc=ButtonProc_sigma
	Button Map11,title="Data_sigma",fSize=10
	Button Map12,pos={342.00,490.00},size={105.00,12.00},proc=ButtonProc_savefitdata
	Button Map12,title="Reader_Mpk2.0",fSize=10
	Button Map14,pos={118.00,595.00},size={100.00,12.00},proc=ButtonProc_comparea
	Button Map14,title="Comp_MultiSet",fSize=10
	Button Map15,pos={225.00,493.00},size={57.00,12.00},proc=ButtonProc_renameall
	Button Map15,title="Rename",fSize=10
	Button Symx9,pos={4.00,493.00},size={53.00,12.00},proc=ButtonProc_interpavedata
	Button Symx9,title="Intra",fSize=10
	Button Map16,pos={84.00,606.00},size={25.00,12.00},proc=ButtonProc_myall
	Button Map16,title="Y*",fSize=10
	Button Map20,pos={344.00,552.00},size={78.00,12.00},proc=ButtonProc_ExtractSTS
	Button Map20,title="ExtractSTS",fSize=10
	Button Map21,pos={344.00,566.00},size={101.00,12.00},proc=ButtonProc_2DSTS
	Button Map21,title="2D STS",fSize=10
	Button Map22,pos={375.00,537.00},size={70.00,12.00},proc=ButtonProc_IExyf
	Button Map22,title="dI/dV(E,x,y)",fSize=10
	Button Map23,pos={225.00,622.00},size={112.00,12.00},proc=ButtonProc_exwidth
	Button Map23,title="Extract_Width",fSize=10
	Button Map24,pos={118.00,621.00},size={100.00,12.00},proc=ButtonProc_autoclbzero
	Button Map24,title="Individual Shift",fSize=10
	Button Map19,pos={225.00,609.00},size={112.00,12.00},proc=ButtonProc_extracnumfromstr
	Button Map19,title="Extract_dI/dV",fSize=10
	Button Symx0,pos={4.00,507.00},size={57.00,12.00},proc=ButtonProc_Loadnewmk
	Button Symx0,title="Ld_Nnis",fSize=10,fColor=(65535,65535,0)
	Button Symx01,pos={92.00,507.00},size={20.00,12.00},proc=ButtonProc_dataplotersts
	Button Symx01,title="P",fSize=10
	Button Map30,pos={4.00,520.00},size={85.00,12.00},proc=ButtonProc_addper
	Button Map30,title="AverSlice (R9)",fSize=10
	Button Map31,pos={60.00,592.00},size={49.00,12.00},proc=ButtonProc_shift
	Button Map31,title="Offset",fSize=10
	Button Map32,pos={147.00,154.00},size={80.00,15.00},proc=ButtonProc_gapdiis
	Button Map32,title="2D_LS",fSize=11
	Button Map33,pos={118.00,582.00},size={100.00,12.00},proc=ButtonProc_twosetdifference
	Button Map33,title="Two set Diffe",fSize=10
	Button Normline2p1,pos={342.00,504.00},size={105.00,12.00},proc=ButtonProc_DyneFit
	Button Normline2p1,title="BCS_Dyne Fit ",fSize=10
	Button Symx03,pos={92.00,520.00},size={20.00,12.00},proc=ButtonProc_autodisplay
	Button Symx03,title="A",fSize=10
	Button Normline2p2,pos={342.00,518.00},size={105.00,12.00},proc=ButtonProc_DyneFitS
	Button Normline2p2,title="SC-SC Fit ",fSize=10
	Button Map37,pos={284.00,493.00},size={53.00,12.00},proc=ButtonProc_renamep
	Button Map37,title="Partial",fSize=10
	Button Symx06,pos={63.00,507.00},size={28.00,12.00},proc=ButtonProc_Loadnewmkfab
	Button Symx06,title="Ave",fSize=10
	Button Map4,pos={284.00,522.00},size={53.00,12.00},proc=ButtonProc_duplicatepart
	Button Map4,title="x1~x2",fSize=10
	Button Map57,pos={424.00,552.00},size={21.00,12.00},proc=ButtonProc_ExtractSTSall
	Button Map57,title="all",fSize=10
	Button Map0,pos={225.00,537.00},size={56.00,12.00},proc=ButtonProc_smoothall
	Button Map0,title="Smt All",fSize=10
	Button Map04,pos={284.00,552.00},size={53.00,12.00},proc=ButtonProc_rescaleallpr
	Button Map04,title="Rsclall",fSize=10
	Button Map61,pos={240.00,171.00},size={106.00,30.00},proc=ButtonProc_extract3dslinecut
	Button Map61,title="Reorder 2D\r(Grid Linecut)"
	Button Map62,pos={240.00,206.00},size={106.00,30.00},proc=ButtonProc_slice1ddpro
	Button Map62,title="2D to 1Ds\r(Grid Linecut)"
	Button Map63,pos={147.00,197.00},size={80.00,15.00},proc=ButtonProc_linecutgapdistrpp
	Button Map63,title="1D_LS",fSize=11
	Button KMExist,pos={264.00,241.00},size={61.00,20.00},proc=ButtonProc_exitkm
	Button KMExist,title="Clean"
	Button buttonhelptools3,pos={0.00,310.00},size={49.00,19.00},disable=1
	Button Map75,pos={147.00,136.00},size={80.00,15.00},proc=ButtonProc_gapdiisGuassian
	Button Map75,title="2D_G",fSize=11
	Button Map76,pos={147.00,172.00},size={80.00,15.00},proc=ButtonProc_gapdiisGuassian2
	Button Map76,title="2D_GCB ",fSize=11
	Button Map69,pos={418.00,157.00},size={30.00,12.00},proc=ButtonProc_Makelatticedata
	Button Map69,title="Old",fSize=10
	Button Map70,pos={147.00,215.00},size={80.00,15.00},proc=ButtonProc_gapdiisGuassian3
	Button Map70,title="1D_GCB",fSize=11
	Button SMap,pos={4.00,564.00},size={56.00,12.00},proc=ButtonProc_map
	Button SMap,title="Linecut",fSize=10
	Button SMap1,pos={61.00,564.00},size={28.00,12.00},proc=ButtonProc_mapaa
	Button SMap1,title="Lc1",fSize=10
	Button Map3,pos={4.00,578.00},size={54.00,12.00},proc=ButtonProc_InterpSTS
	Button Map3,title="InterpL",fSize=10
	Button SMap2,pos={91.00,564.00},size={18.00,12.00},proc=ButtonProc_mapaa2
	Button SMap2,title="2",fSize=10
	Button Line2D2,pos={454.00,493.00},size={81.00,13.00},proc=ButtonProc_linecutFFT
	Button Line2D2,title="Line@2D(2)",fSize=12
	Button Rotate4,pos={536.00,493.00},size={25.00,13.00},proc=ButtonProc_linecutFFT2
	Button Rotate4,title="(1)",fSize=12
	Button Line2D3,pos={525.00,479.00},size={37.00,13.00},proc=ButtonProc_FFTr
	Button Line2D3,title="FFT",fSize=12
	Button Map45,pos={284.00,537.00},size={53.00,12.00},proc=ButtonProc_smoothallmatrix
	Button Map45,title="(2D)",fSize=10
	Button Map78,pos={457.00,525.00},size={60.00,25.00},proc=ButtonProc_ffc
	Button Map78,title="Launch"
	Button Map79,pos={522.00,525.00},size={37.00,12.00},proc=ButtonProc_GPAc
	Button Map79,title="getA",fSize=10
	Button Map80,pos={522.00,538.00},size={37.00,12.00},proc=ButtonProc_GpBc
	Button Map80,title="getB",fSize=10
	Button Map84,pos={454.00,606.00},size={34.00,15.00},proc=ButtonProc_C4sheargetparac
	Button Map84,title="Coef",fSize=10
	Button button96,pos={82.00,366.00},size={32.00,16.00},proc=ButtonProc_colorFFT
	Button button96,title="FFT"
	SetVariable setvargrnum1,pos={170.00,327.00},size={60.00,16.00},proc=SetVarProc_changeds
	SetVariable setvargrnum1,title="\\Z10σ",labelBack=(16385,49025,65535)
	SetVariable setvargrnum1,limits={0.1,inf,0.5},value=timesg
	PopupMenu popuptest,pos={184.00,369.00},size={120.00,20.00},bodyWidth=120,disable=1,proc=PopMenuProc_more2
	PopupMenu popuptest,mode=6,popvalue="Viridis",value=#"WaveList(\"*\",\";\",\"\",root:Packages:NewColortable:)"
	Button C,pos={311.00,368.00},size={42.00,19.00},disable=1,proc=ButtonProc_color_edc_more2
	Button C,title="Color"
	PopupMenu popuptest1,pos={123.00,364.00},size={210.00,20.00},bodyWidth=210,proc=PopMenuProc_colormatmore2
	PopupMenu popuptest1,mode=1,popvalue="Cividis",value=#"WaveList(\"*\",\";\",\"\",root:Packages:NewColortable:)"
	Button button62,pos={13.00,167.00},size={123.00,17.00},proc=ButtonProc_Smart2DEMDC
	Button button62,title="2D Multifunc. Displayer",fSize=10
	Button Symx07,pos={359.00,241.00},size={55.00,12.00},proc=ButtonProc_dddautoremovejump1DC
	Button Symx07,title="Jump1D",fSize=10
	Button Symx02,pos={419.00,225.00},size={30.00,12.00},proc=ButtonProc_fix_map
	Button Symx02,title="Pt",fSize=10
	Button Symx08,pos={359.00,257.00},size={55.00,12.00},proc=ButtonProc_cnfyjc
	Button Symx08,title="Jump 2D",fSize=10
	Button Symx04,pos={419.00,257.00},size={30.00,12.00},proc=ButtonProc_fixline
	Button Symx04,title="Line",fSize=10
	Button Symx10,pos={359.00,272.00},size={90.00,12.00},proc=ButtonProc_correct2Dmapc
	Button Symx10,title="Fix Gate Leak",fSize=10
	Button Normline2p4,pos={118.00,522.00},size={100.00,12.00},proc=ButtonProc_linenorm2pongraphc
	Button Normline2p4,title="LnBkg (frm graph)",fSize=10
	Button Symx11,pos={359.00,287.00},size={90.00,12.00},proc=ButtonProc_Conslevel
	Button Symx11,title="Rmv.  Fig Trend",fSize=10
	Button DeletePoints5,pos={81.00,88.00},size={49.00,35.00},proc=ButtonProc_killags
	Button DeletePoints5,title="KILL\rGraphs",labelBack=(65535,0,0),fSize=11
	Button DeletePoints5,fStyle=1,fColor=(65535,0,0)
	Button Jumpcal,pos={456.00,114.00},size={80.00,15.00},proc=ButtonProc_stepmove
	Button Jumpcal,title="Jump Cal",labelBack=(44253,29492,58982),fSize=11,fStyle=1
	Button Jumpcal,fColor=(65535,0,26214)
	Button Map77,pos={456.00,131.00},size={38.00,15.00},proc=ButtonProc_convertG
	Button Map77,title="CtG",fSize=11
	Button Map82,pos={498.00,131.00},size={38.00,15.00},proc=ButtonProc_reorg2ndd
	Button Map82,title="LtE",fSize=11
	SetVariable setvarsetciu,pos={234.00,328.00},size={200.00,14.00},proc=SetVarProc_colormatmorevv
	SetVariable setvarsetciu,title="\\JLdvg_bwr_20_95_c54"
	SetVariable setvarsetciu,labelBack=(65535,65535,65535)
	SetVariable setvarsetciu,limits={0,107,1},value=colorindexuser,textAlign=2
	SetVariable setvarsetciu1,pos={187.00,391.00},size={200.00,14.00},disable=1,proc=SetVarProc_colormatmorevvline
	SetVariable setvarsetciu1,title="\\JLSpectrumBlack"
	SetVariable setvarsetciu1,labelBack=(65535,65535,65535)
	SetVariable setvarsetciu1,limits={0,97,1},value=colorsetedc3,textAlign=2
	Button button73,pos={208.00,444.00},size={170.00,19.00},disable=1,proc=ButtonProc_RGBimagetoIntensity2
	Button button73,title="\\K(65535,0,0)Extract Image Data From Paper",fSize=8
	Button Map88,pos={13.00,182.00},size={123.00,17.00},proc=ButtonProc_Cons3dplot
	Button Map88,title="3D Multifunc. Displayer",fSize=10
	Button Map85,pos={454.00,621.00},size={23.00,15.00},proc=ButtonProc_C4shearcorrectc
	Button Map85,title="Go",fSize=10
	Button Map89,pos={477.00,621.00},size={37.00,15.00},proc=ButtonProc_Shearmat3d
	Button Map89,title="Go3D",fSize=10
	Button Symx15,pos={4.00,620.00},size={50.00,12.00},proc=ButtonProc_renormcuts_k
	Button Symx15,title="Rscl.*/",fSize=10
	Button button97,pos={246.00,11.00},size={100.00,18.00},proc=ButtonProc_EMDC
	Button button97,title="EMDC",fSize=13
	Button Symx17,pos={59.00,620.00},size={50.00,12.00},proc=ButtonProc_rescale_pi
	Button Symx17,title="Rscl.+-",fSize=10
	Button button28,pos={147.00,242.00},size={80.00,15.00},proc=ButtonProc_t2nddpeakc
	Button button28,title="MultiPeak 1D",fSize=11,fColor=(65535,65535,0)
	Button Symx18,pos={419.00,241.00},size={30.00,12.00},proc=ButtonProc_ddd
	Button Symx18,title="Sgl.",fSize=10
	Button Map81,pos={454.00,564.00},size={25.00,12.00},proc=ButtonProc_FTc
	Button Map81,title="Q\\BC4",fSize=8
	TitleBox title0,pos={358.00,136.00},size={92.00,17.00}
	TitleBox title0,title="Try Latt.  Segregation",labelBack=(65535,65535,65535)
	TitleBox title0,fSize=8,fixedSize=1
	Button Map54,pos={118.00,793.00},size={75.00,12.00},proc=ButtonProc_MZMscaling_poison
	Button Map54,title="Scal.+Poison",fSize=10
	Button Map55,pos={168.00,780.00},size={25.00,12.00},proc=ButtonProc_Batchscalingoure
	Button Map55,title="2D",fSize=10
	Button Theo1,pos={3.00,748.00},size={112.00,16.00},proc=ButtonProc_automatrixTC
	Button Theo1,title="Cal.  Matrix H(k)",fSize=13
	Button Map97,pos={479.00,564.00},size={19.00,12.00},proc=ButtonProc_FTclp
	Button Map97,title="LP",fSize=8,fColor=(39321,39319,1)
	Button Map90,pos={498.00,564.00},size={15.00,12.00},proc=ButtonProc_FTlinecutc
	Button Map90,title="Y",labelBack=(65535,65533,32768),fSize=8
	Button Map90,fColor=(39321,39319,1)
	Button Map09,pos={117.00,754.00},size={42.00,12.00},proc=ButtonProc_LFuModel
	Button Map09,title="Profile",fSize=10
	Button Map17,pos={117.00,741.00},size={60.00,12.00},proc=ButtonProc_intereractionMBS
	Button Map17,title="MBS Split",fSize=10
	Button Map18,pos={117.00,767.00},size={20.00,12.00},proc=ButtonProc_predictLL
	Button Map18,title="LL",fSize=10
	Button Map25,pos={277.00,754.00},size={29.00,12.00},proc=ButtonProc_dscgap
	Button Map25,title="dSC",fSize=10
	Button Map26,pos={180.00,741.00},size={56.00,12.00},proc=ButtonProc_tbmodel
	Button Map26,title="TB_Cprt",fSize=10
	Button Map27,pos={186.00,767.00},size={82.00,12.00},proc=ButtonProc_Svortex
	Button Map27,title="BCSVortex line",fSize=10
	Button Map28,pos={268.00,780.00},size={67.00,12.00},proc=ButtonProc_S_Svortex
	Button Map28,title="S/Vortex Ln",fSize=10
	Button Map29,pos={196.00,780.00},size={70.00,12.00},proc=ButtonProc_S_Svortexindiv
	Button Map29,title="Ind. S/Vortex",fSize=10
	Button Map36,pos={202.00,754.00},size={73.00,12.00},proc=ButtonProc_calculateband
	Button Map36,title="Band abinitio",fSize=10
	Button Map47,pos={139.00,767.00},size={45.00,12.00},proc=ButtonProc_LLDOS
	Button Map47,title="LL DOS",fSize=10
	Button Map48,pos={161.00,754.00},size={39.00,12.00},proc=ButtonProc_CdGMDirac
	Button Map48,title="CdGM",fSize=10
	Button Map49,pos={239.00,741.00},size={56.00,12.00},proc=ButtonProc_tbmodelIBSC
	Button Map49,title="TB_FeSC",fSize=10
	Button Map50,pos={298.00,741.00},size={38.00,12.00},proc=ButtonProc_fanoline
	Button Map50,title="Fano",fSize=10
	Button Jump1,pos={117.00,728.00},size={220.00,12.00},proc=ButtonProc_Demoautormjump2DPro
	Button Jump1,title="Demo: Trace Slanted Jumping Line",fSize=10
	Button Map60cpr5,pos={118.00,815.00},size={76.00,12.00},proc=ButtonProc_HaldaneCons
	Button Map60cpr5,title="Haldane Model",fSize=9
	Button Map60cpr3,pos={118.00,827.00},size={42.00,12.00},proc=ButtonProc_HaldaneA
	Button Map60cpr3,title="A(k,ω)",fSize=10
	Button Map60cpr4,pos={161.00,827.00},size={32.00,12.00},proc=ButtonProc_HaldaneBC
	Button Map60cpr4,title="Ω(k)",fSize=10
	Button Map60cpr1,pos={196.00,793.00},size={70.00,12.00},proc=ButtonProc_PRB_98_214503_n
	Button Map60cpr1,title="FeSC(M k.p)",fSize=10
	Button Map60cpr2,pos={268.00,793.00},size={70.00,12.00},proc=ButtonProc_fourbandkpFeSC
	Button Map60cpr2,title="FeSC(Γ k.p)",fSize=10
	Button Map60cpr,pos={307.00,754.00},size={29.00,12.00},proc=ButtonProc_nonsinodal
	Button Map60cpr,title="CPR",fSize=10
	Button KMExist3,pos={144.00,268.00},size={58.00,32.00},proc=ButtonProc_autogatemap
	Button KMExist3,title="Auto\rGateMp"
	Button KMExist2,pos={297.00,268.00},size={55.00,32.00},proc=ButtonProc_autoloadgrid
	Button KMExist2,title="Auto\rGridMp"
	Button Map60cpr6,pos={274.00,815.00},size={64.00,12.00},proc=ButtonProc_QWZCons
	Button Map60cpr6,title="Qi-Wu-Zhang",fSize=8
	Button Map60cpr7,pos={197.00,815.00},size={73.00,12.00},proc=ButtonProc_QHZ
	Button Map60cpr7,title="Qi-Hughes-Zhang",fSize=7
	Button Map60cpr9,pos={238.00,828.00},size={42.00,12.00},proc=ButtonProc_QHZLDOSCall
	Button Map60cpr9,title="*(LDOS)",fSize=8
	Button Map60cpr8,pos={197.00,828.00},size={37.00,12.00},proc=ButtonProc_Solveedgestate_QHZc
	Button Map60cpr8,title="*(Slab)",fSize=8
	Button Map60cpr0,pos={283.00,828.00},size={55.00,12.00},proc=ButtonProc_QHZslabcutc
	Button Map60cpr0,title="*(A[k,ω,L])",fSize=8
	Button KMExist1,pos={205.00,268.00},size={58.00,32.00},proc=ButtonProc_AutoNanislinecut
	Button KMExist1,title="Auto\rLinecut"
	Button KMExist4,pos={265.00,268.00},size={30.00,15.00},proc=ButtonProc_autotopo
	Button KMExist4,title="Topo",fSize=8
	Button KMExist5,pos={265.00,285.00},size={30.00,15.00},proc=ButtonProc_Z_R_Rhomapc
	Button KMExist5,title="ZR\\$WMTEX$ \rho\\$/WMTEX$",fSize=8
	Button Symx23,pos={516.00,564.00},size={22.00,12.00},proc=ButtonProc_LF
	Button Symx23,title="2D",fSize=8
	Button Symx22,pos={539.00,564.00},size={22.00,12.00},proc=ButtonProc_LFtc
	Button Symx22,title="3D",fSize=8
	Button Map71,pos={344.00,621.00},size={40.00,12.00},proc=ButtonProc_doampfftforphase
	Button Map71,title="PreFFT",fSize=8
	Button Map72,pos={390.00,621.00},size={27.00,12.00},proc=ButtonProc_pickupPA
	Button Map72,title="getA",fSize=8
	Button Map73,pos={422.00,621.00},size={27.00,12.00},proc=ButtonProc_pickupPB
	Button Map73,title="getB",fSize=8
	Button Map74,pos={344.00,634.00},size={67.00,12.00},proc=ButtonProc_PhaseMap
	Button Map74,title="Phase DIF of 2",fSize=8
	Button Map83,pos={412.00,634.00},size={37.00,12.00},proc=ButtonProc_PhaseMapcorrectbd
	Button Map83,title="FixBnd",fSize=8
	Button Map60cpr10,pos={344.00,678.00},size={62.00,12.00},proc=ButtonProc_SIMUtopodefectc
	Button Map60cpr10,title="Topo. Defect",fSize=8
	Button Map60cpr11,pos={344.00,692.00},size={62.00,12.00},proc=ButtonProc_FeSC_normal
	Button Map60cpr11,title="FeSC FS",fSize=8
	Button Map60,pos={344.00,598.00},size={105.00,12.00},proc=ButtonProc_findpolarizationc
	Button Map60,title="Calculate Pplarization",fSize=8
	Button Symx24,pos={516.00,607.00},size={45.00,13.00},proc=ButtonProc_t2dlockinandFilter
	Button Symx24,title="Lckin/Ftd",fSize=8
	Button Symx12,pos={516.00,621.00},size={23.00,13.00},proc=ButtonProc_t2dlockin
	Button Symx12,title="Old",fSize=8
	Button Symx25,pos={540.00,621.00},size={21.00,13.00},proc=ButtonProc_Correct2DlockinampcoutInd
	Button Symx25,title="Cr",fSize=8
	Button Map60cpr12,pos={358.00,157.00},size={55.00,12.00},proc=ButtonProc_SumCompOrder
	Button Map60cpr12,title="Multi.Order",fSize=8
	Button Map60cpr09,pos={344.00,664.00},size={62.00,12.00},proc=ButtonProc_SimuPDW1Dc
	Button Map60cpr09,title="PDW Linecut",fSize=8
	Button Map60cpr13,pos={408.00,664.00},size={28.00,12.00},proc=ButtonProc_simupdwwithw
	Button Map60cpr13,title="OLD",fSize=8
	Button Symx5,pos={457.00,167.00},size={35.00,13.00},proc=ButtonProc_legend_dIdV_vs_V
	Button Symx5,title="dI/dV",fSize=10
	Button Symx6,pos={493.00,167.00},size={28.00,13.00},proc=ButtonProc_legend_distance_vs_V
	Button Symx6,title="d/V",fSize=10
	Button Map06,pos={522.00,167.00},size={36.00,13.00},proc=ButtonProc_sizedos
	Button Map06,title="2e2/h",fSize=10
	Button Map39,pos={457.00,185.00},size={50.00,13.00},proc=ButtonProc_sizecurve
	Button Map39,title="Format",fSize=10
	Button Map91,pos={508.00,200.00},size={50.00,13.00},proc=ButtonProc_sizecurvenone
	Button Map91,title="None",fSize=10
	Button Map92,pos={457.00,200.00},size={50.00,13.00},proc=ButtonProc_sizecurvelableon
	Button Map92,title="Label on",fSize=10
	Button Map93,pos={457.00,233.00},size={30.00,13.00},proc=ButtonProc_sizecurveplan
	Button Map93,title="Plan",fSize=10
	Button Map94,pos={489.00,233.00},size={30.00,13.00},proc=ButtonProc_sizecurveauto
	Button Map94,title="Auto",fSize=10
	Button Map95,pos={521.00,233.00},size={30.00,13.00},proc=ButtonProc_sizecurverect
	Button Map95,title="Rect",fSize=10
	Button Map00,pos={457.00,218.00},size={50.00,13.00},proc=ButtonProc_sizemapauto
	Button Map00,title="Topo",fSize=10
	Button DeletePoints,pos={454.00,264.00},size={110.00,12.00},proc=ButtonProc_deletepoint
	Button DeletePoints,title="DeletePoints",fSize=10
	Button Symx,pos={454.00,381.00},size={40.00,12.00},proc=ButtonProc_symbands
	Button Symx,title="Symx",fSize=10
	Button Symx7,pos={454.00,293.00},size={60.00,12.00},proc=ButtonProc_Rflwaves
	Button Symx7,title="Reflection",fSize=10
	Button DeletePoints1,pos={454.00,278.00},size={26.00,12.00},proc=ButtonProc_cutksmall
	Button DeletePoints1,title="k-",fSize=10
	Button DeletePoints2,pos={482.00,278.00},size={26.00,12.00},proc=ButtonProc_cutklarge
	Button DeletePoints2,title="k+",fSize=10
	Button DeletePoints3,pos={510.00,278.00},size={26.00,12.00},proc=ButtonProc_cutEsmall
	Button DeletePoints3,title="E-",fSize=10
	Button DeletePoints4,pos={538.00,278.00},size={26.00,12.00},proc=ButtonProc_cutElarge
	Button DeletePoints4,title="E+",fSize=10
	Button PAD_1D,pos={501.00,308.00},size={22.00,12.00},proc=ButtonProc_extending1D
	Button PAD_1D,title="1D",fSize=10
	Button Map56,pos={516.00,293.00},size={30.00,12.00},proc=ButtonProc_slopedata
	Button Map56,title="Slope",fSize=6
	Button Map58,pos={498.00,381.00},size={32.00,12.00},proc=ButtonProc_tdtodc
	Button Map58,title="2to1",fSize=10
	Button Map40,pos={454.00,337.00},size={63.00,12.00},proc=ButtonProc_twoDinterpolatel
	Button Map40,title="Interp NxN",fSize=10
	Button Map41,pos={454.00,322.00},size={69.00,12.00},proc=ButtonProc_Complextoreal
	Button Map41,title="Cmplx2Rl",fSize=10
	Button Map53,pos={543.00,337.00},size={20.00,12.00},proc=ButtonProc_twoDinterpy
	Button Map53,title="Y",fSize=10
	Button Map6,pos={454.00,367.00},size={47.00,12.00},proc=ButtonProc_SmoothMat_k23
	Button Map6,title="Smooth",fSize=10
	Button Map64,pos={454.00,352.00},size={55.00,12.00},proc=ButtonProc_rescalemapasa1dcurve
	Button Map64,title="UnevenY",fSize=10
	Button Map65,pos={548.00,293.00},size={15.00,12.00},proc=ButtonProc_slopedataall
	Button Map65,title="all",fSize=6
	Button Map68,pos={520.00,337.00},size={21.00,12.00},proc=ButtonProc_twoDlinterp2Dall
	Button Map68,title="all",fSize=10
	Button Map05,pos={533.00,381.00},size={30.00,12.00},proc=ButtonProc_rescale
	Button Map05,title="Resl.",fSize=10
	Button Rotate2,pos={511.00,352.00},size={27.00,12.00},proc=ButtonProc_Newrotateproc
	Button Rotate2,title="Rot",fSize=10
	Button Pad2D,pos={454.00,308.00},size={45.00,12.00},proc=ButtonProc_padmc
	Button Pad2D,title="Pad 2D",fSize=10
	Button Map86,pos={527.00,321.00},size={35.00,10.00},proc=ButtonProc_rotatedsheard
	Button Map86,title="Demo",fSize=8
	Button Map87,pos={527.00,309.00},size={35.00,10.00},proc=ButtonProc_rotatedshearc
	Button Map87,title="Shear",fSize=8
	Button Rotate3,pos={540.00,352.00},size={23.00,12.00},proc=ButtonProc_Controtate
	Button Rotate3,title="adj",fSize=10
	Button Symx05,pos={454.00,461.00},size={47.00,12.00},proc=ButtonProc_sEDC
	Button Symx05,title="EDC",fSize=10
	Button Symx09,pos={504.00,461.00},size={47.00,12.00},proc=ButtonProc_sMDC
	Button Symx09,title="MDC",fSize=10
	Button Symx13,pos={454.00,411.00},size={35.00,12.00},proc=ButtonProc_sumonedc
	Button Symx13,title="It3/1",fSize=10
	Button Symx14,pos={503.00,367.00},size={60.00,12.00},proc=ButtonProc_Normalinecut
	Button Symx14,title="Norm Matrix",fSize=8
	Button Symx21,pos={454.00,396.00},size={110.00,12.00},proc=ButtonProc_Fmarqueegetsub
	Button Symx21,title="Partial by Marquee",fSize=10
	Button Symx27,pos={528.00,411.00},size={35.00,12.00},proc=ButtonProc_sum2dlinecutc
	Button Symx27,title="It2/1",fSize=10
	Button Symx29,pos={491.00,411.00},size={35.00,12.00},proc=ButtonProc_SumlayerFFT3Dc2
	Button Symx29,title="It3/2",fSize=10
	Button Symx19,pos={454.00,650.00},size={25.00,12.00},proc=ButtonProc_LS
	Button Symx19,title="Self",fSize=8
	Button Symx20,pos={480.00,650.00},size={34.00,12.00},proc=ButtonProc_LS2
	Button Symx20,title="Other",fSize=8
	Button Symx28,pos={516.00,650.00},size={31.00,12.00},proc=ButtonProc_DBD_PRQPI
	Button Symx28,title="Do it",fSize=8
	Button Symx30,pos={539.00,663.00},size={23.00,12.00},proc=ButtonProc_makelatticec
	Button Symx30,title="Go",fSize=8
	Button Map60cpr14,pos={344.00,746.00},size={100.00,12.00},proc=ButtonProc_FFTTwistanglemap
	Button Map60cpr14,title="TBG Twist angle Map",fSize=8
	Button Symx31,pos={489.00,606.00},size={24.00,15.00},proc=ButtonProc_cal_strainbyshearc
	Button Symx31,title="ε",fSize=10
	Button Map52,pos={456.00,770.00},size={50.00,15.00},proc=ButtonProc_Consmoo
	Button Map52,title="Smooth",fSize=10
	Button Map99,pos={508.00,770.00},size={49.00,15.00},proc=ButtonProc_Zcoloro
	Button Map99,title="Z_color",fSize=10
	Button Map96,pos={512.00,787.00},size={45.00,15.00},proc=ButtonProc_Conslinethick
	Button Map96,title="LThick",fSize=10
	Button Map67,pos={456.00,787.00},size={55.00,15.00},proc=ButtonProc_Consoffset
	Button Map67,title="OffsetXY",fSize=10
	Button Map98,pos={456.00,804.00},size={53.00,15.00},proc=ButtonProc_Consactiveall
	Button Map98,title="active all",fSize=10
	Button Map60cpr15,pos={456.00,822.00},size={101.00,15.00},proc=ButtonProc_makevectorfield
	Button Map60cpr15,title="Vector Field Plot",fSize=10
	Button Symx32,pos={454.00,440.00},size={55.00,12.00},proc=ButtonProc_shrinkmatrixbysteps
	Button Symx32,title="CoarseM",fSize=10
	Button b98,pos={336.00,365.00},size={65.00,16.00},proc=ButtonProc_cyclecolorwavec
	Button b98,title="Cycle Color",fSize=8
	Button Map60cpr16,pos={408.00,678.00},size={40.00,12.00},proc=ButtonProc_vortexantivortexsimuc
	Button Map60cpr16,title="vortex pair",fSize=5
	Button Theo2,pos={3.00,765.00},size={112.00,23.00},proc=ButtonProc_QPISIMUNew
	Button Theo2,title="FeSC-A(ω,k)+LDOS+QPI\rTwo bands TB",fSize=8,fStyle=1
	Button Theo2,fColor=(13107,0,0),valueColor=(65535,65535,65535)
	Button buttoncg,pos={21.00,364.00},size={52.00,19.00},proc=ButtonProc_Capturename_child
	Button buttoncg,title="Cap#G*",fSize=11
	Button Theo3,pos={66.00,730.00},size={49.00,17.00},proc=ButtonProc_d3dsimu
	Button Theo3,title="\\$WMTEX$Plot_{A(k,ω)} \\$/WMTEX$"
	Button Theo3,labelBack=(65535,65535,65535),fSize=10,fColor=(29524,1,58982)
	Button Theo3,valueColor=(65535,65535,65535)
	Button Map60cpr17,pos={270.00,767.00},size={40.00,12.00},proc=ButtonProc_FFTstripesimulationc
	Button Map60cpr17,title="Stripe@FFT",fSize=5
	Button Map60cpr18,pos={344.00,762.00},size={40.00,12.00},proc=ButtonProc_calculateMoireLc
	Button Map60cpr18,title="Moiré λ",fSize=8
	Button Map60cpr19,pos={408.00,692.00},size={40.00,12.00},proc=ButtonProc_simuCDWc
	Button Map60cpr19,title="\\$WMTEX$ {\rm NbSe}_{2} \\$/WMTEX$",fSize=9
	Button Map60cpr20,pos={64.00,793.00},size={50.00,12.00},proc=ButtonProc_oneUCFeSegapsimu
	Button Map60cpr20,title="∆(1UC-FeSe)",fSize=6
	Button Symx33,pos={521.00,218.00},size={30.00,13.00},proc=ButtonProc_Drawarrowy
	Button Symx33,title="axis",fSize=10
	Button Symx34,pos={510.00,579.00},size={51.00,12.00},proc=ButtonProc_Strainanalysisc
	Button Symx34,title="Cal. Tensor",fSize=8
	Button Symx35,pos={543.00,512.00},size={16.00,12.00},proc=ButtonProc_peakIndi
	Button Symx35,title="Q",fSize=8
	Button SMap3,pos={4.00,656.00},size={85.00,12.00},proc=ButtonProc_convolvetempc
	Button SMap3,title="Temp convolve",fSize=10
	Button Map60cpr21,pos={344.00,706.00},size={104.00,12.00},proc=ButtonProc_choiceparameterc
	Button Map60cpr21,title="2D PDM with 2 Gap",fSize=8,fStyle=1
	Button Map60cpr21,fColor=(26411,1,52428),valueColor=(65535,65532,16385)
	Button SMap4,pos={4.00,669.00},size={85.00,12.00},proc=ButtonProc_convallc
	Button SMap4,title="T-conv batch",fSize=10
	Button sym_c4,pos={454.00,690.00},size={22.00,12.00},proc=ButtonProc_C4_symc
	Button sym_c4,title="C4",fSize=8,fStyle=0,fColor=(32768,40777,65535)
	Button sym_c5,pos={527.00,678.00},size={35.00,10.00},proc=ButtonProc_calculateRCc
	Button sym_c5,title="\\$WMTEX$ R\nu_{\rm i}= \nu_{\rm j} \\$/WMTEX$",fSize=6
	Button sym_c5,fStyle=0
	Button sym_c6,pos={478.00,690.00},size={35.00,12.00},proc=ButtonProc_Mdiag_symc
	Button sym_c6,title="M_dia",fSize=8,fStyle=0,fColor=(19675,39321,1)
	Button sym_c7,pos={515.00,690.00},size={47.00,12.00},proc=ButtonProc_Moffdiag_symc
	Button sym_c7,title="M_offdia",fSize=8,fStyle=0
	Button sym_c8,pos={515.00,703.00},size={47.00,12.00},proc=ButtonProc_My_symc
	Button sym_c8,title="My",fSize=8,fStyle=0
	Button sym_c9,pos={478.00,703.00},size={35.00,12.00},proc=ButtonProc_Mx_symc
	Button sym_c9,title="Mx",fSize=8,fStyle=0,fColor=(19675,39321,1)
	Button sym_c0,pos={454.00,703.00},size={22.00,12.00},proc=ButtonProc_D4_symc
	Button sym_c0,title="D4",fSize=8,fStyle=0,fColor=(52428,34958,1)
	Button sym_c1,pos={502.00,717.00},size={60.00,12.00},proc=ButtonProc_symmetrizeQPIdallc
	Button sym_c1,title="Sym.  All",fSize=8,fStyle=0,fColor=(48059,48059,48059)
	Button buttonpntreader,pos={13.00,219.00},size={123.00,12.00},proc=ButtonProc_showpntreader
	Button buttonpntreader,title="Point reader",fSize=10,fStyle=0
	Button Getp,pos={13.00,233.00},size={60.00,21.00},proc=ButtonProc_GPc
	Button Getp,title="Get Peak\r2D Gaussian ",fSize=8
	Button Getp1,pos={76.00,233.00},size={60.00,21.00},proc=ButtonProc_getpeakfromwfc
	Button Getp1,title="Get Peak\r1D multi",fSize=8
	Button Getp2,pos={13.00,257.00},size={123.00,12.00},proc=ButtonProc_Conshist
	Button Getp2,title="Auto Histogram",fSize=10
	Button Symx26,pos={13.00,272.00},size={34.00,15.00},proc=ButtonProc_Showfigind
	Button Symx26,title="d(*)",fSize=12
	Button Symx16,pos={48.00,272.00},size={35.00,15.00},proc=ButtonProc_RDF
	Button Symx16,title="RDF",fSize=12
	Button Symx8,pos={84.00,272.00},size={52.00,15.00},proc=ButtonProc_length
	Button Symx8,title="Length",fSize=12
	Button Getp3,pos={13.00,289.00},size={123.00,12.00},proc=ButtonProc_Csrtracor1
	Button Getp3,title="Csr Tracor",fSize=10
	Button SMap5,pos={4.00,682.00},size={40.00,12.00},proc=ButtonProc_TBGsimu
	Button SMap5,title="TBG",fSize=10
	Button SMap6,pos={49.00,682.00},size={40.00,12.00},proc=ButtonProc_TTGsimu
	Button SMap6,title="TTG",fSize=10
	Button SMap7,pos={4.00,695.00},size={85.00,12.00},proc=ButtonProc_Honeycomb
	Button SMap7,title="A(honeycomb)",fSize=10
	Button Map66,pos={358.00,172.00},size={92.00,12.00},proc=ButtonProc_appendVline
	Button Map66,title="Draw lines",fSize=10
	Button Map08,pos={358.00,188.00},size={37.00,12.00},proc=ButtonProc_Fitimagehoneycombc
	Button Map08,title="Gr-lat",fSize=10
	Button Map34,pos={397.00,188.00},size={25.00,12.00},proc=ButtonProc_Fitimagetriangularc
	Button Map34,title="Tri",fSize=10
	Button Map35,pos={425.00,188.00},size={24.00,12.00},proc=ButtonProc_Fitimagesquarec
	Button Map35,title="Sq",fSize=10
	Button Symx36,pos={454.00,426.00},size={110.00,12.00},proc=ButtonProc_Gridtolinecutc
	Button Symx36,title="It3 to linecut",fSize=10
	Button Map38,pos={225.00,654.00},size={112.00,12.00},proc=ButtonProc_diffeall
	Button Map38,title="Differentiate I/V",fSize=10
	Button Map42,pos={225.00,668.00},size={112.00,12.00},proc=ButtonProc_scalewave
	Button Map42,title="Apply divider (single)",fSize=10
	Button Map43,pos={225.00,683.00},size={112.00,12.00},proc=ButtonProc_rescalegroupc
	Button Map43,title="Linecut with divider",fSize=10,fColor=(1,39321,39321)
	Button Map44,pos={225.00,711.00},size={112.00,12.00},proc=ButtonProc_unevenlinep
	Button Map44,title="Linecut from Random",fSize=10,fColor=(1,39321,39321)
	Button Map46,pos={225.00,697.00},size={112.00,12.00},proc=ButtonProc_madewavebytemplate
	Button Map46,title="Format wave A as B",fSize=10
	Button SMap9,pos={134.00,640.00},size={85.00,12.00},proc=ButtonProc_RCSJ
	Button SMap9,title="RCSJ Model",fSize=10,fColor=(49163,65535,32768)
	Button SMap0,pos={134.00,654.00},size={85.00,12.00},proc=ButtonProc_CalculateP0Ec
	Button SMap0,title="P(E) Theory",fSize=10,fColor=(49163,65535,32768)
EndMacro
