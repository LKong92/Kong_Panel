#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
//======================================================================
// Moire STM Topography Simulator
//======================================================================
// Interactive moire lattice simulator
//
// Supported lattice forms:
//
//     1 = Square
//     2 = Honeycomb
//     3 = Triangular
//     4 = Kagome
//
// Bottom and top layers can be selected independently.
//
// Examples:
//
//     bottom = Square,    top = Honeycomb
//     bottom = Kagome,    top = Triangular
//     bottom = Honeycomb, top = Square
//
// The geometric model does not require the two lattices to have the
// same symmetry or to form a commensurate supercell.
//
//======================================================================
// Unified definition of lattice constant
//======================================================================
//
// aBottom and aTop always denote the Bravais-lattice translation
// length.
//
// Square lattice:
//
//     a1 = (a,0)
//     a2 = (0,a)
//
//     nearest-neighbor distance = a
//
// Triangular lattice:
//
//     a1 = (a,0)
//     a2 = (a/2,sqrt(3)*a/2)
//
//     nearest-neighbor distance = a
//
// Honeycomb lattice:
//
//     triangular Bravais lattice + two-atom A/B basis
//
//     A-A distance = B-B distance = a
//     A-B nearest-neighbor distance = a/sqrt(3)
//
// Kagome lattice:
//
//     triangular Bravais lattice + three-atom A/B/C basis
//
//     each individual sublattice has lattice constant a
//     Kagome nearest-neighbor distance = a/2
//
//======================================================================
// Layer angles
//======================================================================
//
//     bottomAngle = globalAngle
//
//     topAngle = globalAngle + twistAngle
//
// For example:
//
//     globalAngle = 45 degrees
//     twistAngle  = 3 degrees
//
// gives:
//
//     bottomAngle = 45 degrees
//     topAngle    = 48 degrees
//
//======================================================================
// Image sampling
//======================================================================
//
// nPoint:
//
//     Number of pixels along each direction.
//     Output wave size is nPoint x nPoint.
//
// lengthScale:
//
//     Total physical field of view along both x and y.
//
// Internal pixel spacing:
//
//     pixelSize = lengthScale/(nPoint-1)
//
// Therefore changing nPoint changes spatial sampling but does not
// change the physical field of view.
//======================================================================
Function ButtonProc_GenerateMoireSquareFastc(ctrlName) : ButtonControl
	String ctrlName
	Execute "GenerateMoireSquareFastc()"
End


Proc GenerateMoireSquareFastc(nPoint, lengthScale, aBottom, aTop, globalAngle, twistAngle, sigmaAtom, xiStack, AM)

    Variable nPoint = 512
    Variable lengthScale = 200

    Variable aBottom = 3.5
    Variable aTop = 3.5

    Variable globalAngle = 45
    Variable twistAngle = 3

    Variable sigmaAtom = 1
    Variable xiStack = 0.6
    Variable AM = 4



    Prompt nPoint, "Number of points along x and y"
    Prompt lengthScale, "Total image length along x and y"

    Prompt aBottom, "Bottom Bravais lattice constant"
    Prompt aTop, "Top Bravais lattice constant"

    Prompt globalAngle, "Overall lattice angle relative to x axis (deg)"
    Prompt twistAngle, "Top-layer twist relative to bottom layer (deg)"

    Prompt sigmaAtom, "Atomic Gaussian width"
    Prompt xiStack, "Stacking-contrast decay length"
    Prompt AM, "Moire modulation amplitude"



    //==================================================================
    // Save numerical parameters as global variables
    //
    // The SetVariable controls below directly modify these globals.
    //==================================================================

    Variable/G root:gMoireN = nPoint
    Variable/G root:gMoireLength = lengthScale

    Variable/G root:gMoireABottom = aBottom
    Variable/G root:gMoireATop = aTop

    Variable/G root:gMoireGlobalAngle = globalAngle
    Variable/G root:gMoireTwistAngle = twistAngle

    Variable/G root:gMoireSigmaAtom = sigmaAtom
    Variable/G root:gMoireXiStack = xiStack
    Variable/G root:gMoireAM = AM


    //==================================================================
    // Lattice-form global variables
    //
    // 1 = Square
    // 2 = Honeycomb
    // 3 = Triangular
    // 4 = Kagome
    //
    // They are not Proc parameters because Igor Proc/Macro has a
    // limited number of input parameters.
    //
    // The initial state is square/square.
    //==================================================================

    Variable/G root:gMoireBottomForm = 1
    Variable/G root:gMoireTopForm = 1


    //==================================================================
    // Initial real-space calculation
    //
    // Initial forms:
    //
    //     bottomForm = 1 = Square
    //     topForm    = 1 = Square
    //==================================================================

    GenerateMoireSquareFast(nPoint, lengthScale, aBottom, aTop, 1, 1, globalAngle, twistAngle, sigmaAtom, xiStack, AM)


    //==================================================================
    // Initial FFT calculation
    //==================================================================

    FFTrmoire(MoireMap,2)

	String MoireMap_FFT = "MoireMap_FFT"

    //==================================================================
    // Create main interactive window
    //==================================================================

    DoWindow/K MoireSquareInteractive

    Display/N=MoireSquareInteractive

    ModifyGraph width=1200,height=650


    //==================================================================
    // Left HOST subwindow: real-space MoireMap
    //==================================================================

    Display/HOST=#/W=(0,0.1,0.45,0.7)

    AppendImage MoireMap

    ModifyGraph width=500,height=500
    ModifyGraph nticks=0,noLabel=2
    ModifyGraph axThick=2,standoff=0,mirror=2
    ModifyGraph margin(right)=72

    ColorScale/C/N=text0/F=0/A=RC/X=-23/Y=0 image=MoireMap
    ColorScale/C/N=text0 frame=0.00

    ModifyImage MoireMap ctab={*,*,:Packages:NewColortable:XLiu_T,0}

    ColorScale/C/N=text0/A=LC/X=101/Y=0/F=0
    ColorScale/C/N=text0 frame=0.00,image=$NameOfWave(MoireMap)

    SetActiveSubwindow ##


    //==================================================================
    // Right HOST subwindow: MoireMap_FFT
    //==================================================================

    Display/HOST=#/W=(0.47,0.1,0.92,0.7)

    AppendImage $MoireMap_FFT

    ModifyGraph width=500,height=500
    ModifyGraph nticks=0,noLabel=2
    ModifyGraph axThick=2,standoff=0,mirror=2
    ModifyGraph margin(right)=72

    ColorScale/C/N=text0/F=0/A=RC/X=-23/Y=0 image=$MoireMap_FFT
    ColorScale/C/N=text0 frame=0.00

    ModifyImage $MoireMap_FFT ctab={*,*,:Packages:NewColortable:XLiu_G,0}

    ColorScale/C/N=text0/X=-15.00/Y=0.00

    color3s_for3dmfMoire($MoireMap_FFT,1000)

    SetActiveSubwindow ##


    //==================================================================
    // Set initial FFT range
    //
    // Initial top lattice is Square, therefore topForm = 1.
    //==================================================================

    SetMoireFFTAxis(aTop,globalAngle,twistAngle,1)


    //==================================================================
    // Group 1: numerical grid and field of view
    //==================================================================

    SetVariable moireN win=MoireSquareInteractive, title="\Z12\\$WMTEX$ N \\$/WMTEX$", pos={30,9}, size={120,18}, value=root:gMoireN, limits={32,4096,16}, proc=SetVarProc_MoireSquare

    SetVariable moireLength win=MoireSquareInteractive, title="\Z12\\$WMTEX$ L \\$/WMTEX$ (Å)", pos={30,30}, size={120,18}, value=root:gMoireLength, limits={0.001,inf,10}, proc=SetVarProc_MoireSquare


    //==================================================================
    // Group 2: lattice constants and layer angles
    //
    //     theta_bottom = phi
    //     theta_top    = phi + theta
    //==================================================================

    SetVariable moireAT win=MoireSquareInteractive, title="\Z12\\$WMTEX$ a_{\rm top} \\$/WMTEX$ (Å)", pos={235,9}, size={130,18}, value=root:gMoireATop, limits={0.001,inf,0.1}, proc=SetVarProc_MoireSquare

    SetVariable moireAB win=MoireSquareInteractive, title="\Z12\\$WMTEX$ a_{\rm bottom} \\$/WMTEX$ (Å)", pos={368,9}, size={130,18}, value=root:gMoireABottom, limits={0.001,inf,0.1}, proc=SetVarProc_MoireSquare

    SetVariable moireGlobalAngle win=MoireSquareInteractive, title="\Z12\\$WMTEX$ \phi \\$/WMTEX$", pos={235,30}, size={130,18}, value=root:gMoireGlobalAngle, limits={-180,180,0.5}, proc=SetVarProc_MoireSquare

    SetVariable moireTwistAngle win=MoireSquareInteractive, title="\Z12\\$WMTEX$ \theta \\$/WMTEX$", pos={368,30}, size={130,18}, value=root:gMoireTwistAngle, limits={-180,180,0.5}, proc=SetVarProc_MoireSquare


    //==================================================================
    // Group 3: apparent-height model
    //
    //     sigma_atom : width of each atomic Gaussian
    //     xi_stack   : registry-selection length
    //     A_M        : moire modulation amplitude
    //==================================================================

    SetVariable moireSigma win=MoireSquareInteractive, title="\Z12\\$WMTEX$ \sigma_{\rm atom} \\$/WMTEX$ (Å)", pos={540,20}, size={140,18}, value=root:gMoireSigmaAtom, limits={0.001,inf,0.5}, proc=SetVarProc_MoireSquare

    SetVariable moireXi win=MoireSquareInteractive, title="\Z12\\$WMTEX$ \xi_{\rm stack} \\$/WMTEX$ (Å)", pos={750,9}, size={130,18}, value=root:gMoireXiStack, limits={0.001,inf,0.5}, proc=SetVarProc_MoireSquare

    SetVariable moireAM win=MoireSquareInteractive, title="\Z12\\$WMTEX$ A_M \\$/WMTEX$", pos={750,30}, size={130,18}, value=root:gMoireAM, limits={-inf,inf,0.1}, proc=SetVarProc_MoireSquare


    //==================================================================
    // Group 4: top- and bottom-layer lattice forms
    //
    //     L_top
    //     L_bottom
    //==================================================================

    PopupMenu moireTopForm win=MoireSquareInteractive, title="\Z12\\$WMTEX$ L_{\rm top} \\$/WMTEX$", pos={1003,9}, size={190,20}, mode=1, value="Square;Honeycomb;Triangular;Kagome;", proc=PopMenuProc_MoireLattice

    PopupMenu moireBottomForm win=MoireSquareInteractive, title="\Z12\\$WMTEX$ L_{\rm bottom} \\$/WMTEX$", pos={987,30}, size={200,20}, mode=1, value="Square;Honeycomb;Triangular;Kagome;", proc=PopMenuProc_MoireLattice


    //==================================================================
    // Back button
    //==================================================================

    Button turnoffls3d title="\Z11BACK", size={45,12}, valueColor=(0,0,0), fColor=(1,65535,33232), proc=ButtonProc_lsturnoff3d, pos={1150,5} 	//==================================================================
    // Theory equations and current parameter values
    //==================================================================

    UpdateMoireTheoryAnnotation()

    TextBox/C/N=realSpaceTitle/F=0/B=0/A=MT/X=-25/Y=9 "\Z15Registry-modulated topography \Z15\\$WMTEX$ z(x,y)\\$/WMTEX$"

	TextBox/C/N=fftTitle/F=0/B=0/A=MT/X=22/Y=9 "\Z15Hanning-windowed Fourier amplitude \Z15\\$WMTEX$ Z(k_x,k_y)=\left|{\rm FFT}\left[W_{\rm H}(x,y)z(x,y)\right]\right| \\$/WMTEX$"
End



//======================================================================
// SetVariable callback
//
// All numerical controls call UpdateMoireInteractive().
//======================================================================

Function SetVarProc_MoireSquare(ctrlName,varNum,varStr,varName) : SetVariableControl

    String ctrlName
    Variable varNum
    String varStr
    String varName

    UpdateMoireInteractive()

    return 0

End



//======================================================================
// PopupMenu callback
//
// popNum:
//
//     1 = Square
//     2 = Honeycomb
//     3 = Triangular
//     4 = Kagome
//======================================================================

Function PopMenuProc_MoireLattice(ctrlName,popNum,popStr) : PopupMenuControl

    String ctrlName
    Variable popNum
    String popStr

    NVAR gMoireBottomForm = root:gMoireBottomForm
    NVAR gMoireTopForm = root:gMoireTopForm


    if (CmpStr(ctrlName,"moireBottomForm") == 0)

        gMoireBottomForm = popNum

    endif


    if (CmpStr(ctrlName,"moireTopForm") == 0)

        gMoireTopForm = popNum

    endif


    UpdateMoireInteractive()

    return 0

End



//======================================================================
// Common interactive update function
//
// This is called whenever:
//
//     1. A SetVariable value changes
//     2. The bottom lattice form changes
//     3. The top lattice form changes
//
// It recalculates:
//
//     1. Real-space MoireMap
//     2. MoireMap_FFT
//     3. FFT display range
//     4. FFT color scale
//======================================================================

Function UpdateMoireInteractive()

    NVAR gMoireN = root:gMoireN
    NVAR gMoireLength = root:gMoireLength

    NVAR gMoireABottom = root:gMoireABottom
    NVAR gMoireATop = root:gMoireATop

    NVAR gMoireBottomForm = root:gMoireBottomForm
    NVAR gMoireTopForm = root:gMoireTopForm

    NVAR gMoireGlobalAngle = root:gMoireGlobalAngle
    NVAR gMoireTwistAngle = root:gMoireTwistAngle

    NVAR gMoireSigmaAtom = root:gMoireSigmaAtom
    NVAR gMoireXiStack = root:gMoireXiStack
    NVAR gMoireAM = root:gMoireAM

    String MoireMapName = "MoireMap"
    String MoireMapFFT = "MoireMap_FFT"


    //==================================================================
    // Matrix size must be an integer
    //==================================================================

    gMoireN = round(gMoireN)

    if (gMoireN < 2)

        gMoireN = 2

    endif


    //==================================================================
    // Restrict lattice form indices to 1...4
    //==================================================================

    gMoireBottomForm = round(gMoireBottomForm)
    gMoireTopForm = round(gMoireTopForm)

    gMoireBottomForm = max(1,min(4,gMoireBottomForm))
    gMoireTopForm = max(1,min(4,gMoireTopForm))


    //==================================================================
    // Recalculate real-space topography
    //==================================================================

    GenerateMoireSquareFast(gMoireN, gMoireLength, gMoireABottom, gMoireATop, gMoireBottomForm, gMoireTopForm, gMoireGlobalAngle, gMoireTwistAngle, gMoireSigmaAtom, gMoireXiStack, gMoireAM)


    //==================================================================
    // Recalculate FFT
    //==================================================================

    FFTrmoire($MoireMapName,2)


    //==================================================================
    // Reset FFT axis using the top-layer first-order Bragg shell
    //==================================================================

    SetMoireFFTAxis(gMoireATop, gMoireGlobalAngle, gMoireTwistAngle, gMoireTopForm)


    //==================================================================
    // Reset FFT color range
    //==================================================================

    color3s_for3dmfMoire($MoireMapFFT,1000)


    // Update the equations and displayed parameter values.

    //UpdateMoireTheoryAnnotation()


    DoUpdate

    return 0

End


//======================================================================
// Set FFT axis range from top-layer first-order Bragg peaks
//
// topForm:
//
//     1 = Square
//     2 = Honeycomb
//     3 = Triangular
//     4 = Kagome
//
//======================================================================
// Reciprocal-lattice conventions
//======================================================================
//
// The FFT axes are treated as cycles per unit length.
//
// Square:
//
//     direct Bravais lattice:
//         a1 = (a,0)
//         a2 = (0,a)
//
//     first-order reciprocal radius:
//         g0 = 1/a
//
// Honeycomb, triangular and Kagome:
//
//     all use the same triangular Bravais lattice:
//
//         a1 = (a,0)
//         a2 = (a/2,sqrt(3)*a/2)
//
//     first-order reciprocal radius:
//
//         g0 = 2/(sqrt(3)*a)
//
// Honeycomb and Kagome basis atoms can change FFT intensities and
// produce structure-factor suppression, but the Bragg-point positions
// remain those of the triangular Bravais lattice.
//
// The displayed x and y limits are 1.3 times the largest corresponding
// components of the complete first-order Bragg shell.
//======================================================================

Function SetMoireFFTAxis(aTop,globalAngle,twistAngle,topForm)

    Variable aTop
    Variable globalAngle
    Variable twistAngle
    Variable topForm

    Variable topAngle
    Variable theta

    Variable g0

    Variable peakCount
    Variable peakIndex

    Variable angleOffset
    Variable angleStep
    Variable peakAngle

    Variable gx
    Variable gy

    Variable kxLimit
    Variable kyLimit


    //==================================================================
    // Check input
    //==================================================================

    if (aTop <= 0)

        Print "Error: aTop must be positive in SetMoireFFTAxis."

        return -1

    endif


    topForm = round(topForm)

    if ((topForm < 1) || (topForm > 4))

        Print "Error: topForm must be 1, 2, 3 or 4."

        return -1

    endif


    //==================================================================
    // Absolute orientation of the visible top layer
    //==================================================================

    topAngle = globalAngle+twistAngle

    theta = topAngle*pi/180


    //==================================================================
    // Define the first-order reciprocal-lattice shell
    //==================================================================

    if (topForm == 1)

        //==============================================================
        // Square lattice
        //
        // Four first-order Bragg points:
        //
        //     (+g0,0)
        //     (-g0,0)
        //     (0,+g0)
        //     (0,-g0)
        //==============================================================

        g0 = 1/aTop

        peakCount = 4
        angleStep = pi/2
        angleOffset = 0


    else

        //==============================================================
        // Honeycomb, triangular and Kagome
        //
        // These lattices share a triangular Bravais lattice.
        //
        // There are six first-order Bragg points.
        //
        // For a1 parallel to the real-space x axis, the first reciprocal
        // vector is rotated by -30 degrees.
        //==============================================================

        g0 = 2/(sqrt(3)*aTop)

        peakCount = 6
        angleStep = pi/3
        angleOffset = -pi/6

    endif


    //==================================================================
    // Find the largest x and y components
    //==================================================================

    kxLimit = 0
    kyLimit = 0


    for (peakIndex=0; peakIndex<peakCount; peakIndex+=1)

        peakAngle = theta+angleOffset+peakIndex*angleStep

        gx = g0*cos(peakAngle)
        gy = g0*sin(peakAngle)

        kxLimit = max(kxLimit,abs(gx))
        kyLimit = max(kyLimit,abs(gy))

    endfor


    //==================================================================
    // Add 30 percent margin
    //==================================================================

    kxLimit = 1.3*kxLimit
    kyLimit = 1.3*kyLimit


    //==================================================================
    // G1 is the second HOST subwindow containing MoireMap_FFT
    //==================================================================

    SetAxis/W=MoireSquareInteractive#G1 bottom,-kxLimit,kxLimit
    SetAxis/W=MoireSquareInteractive#G1 left,-kyLimit,kyLimit


    return 0

End



//======================================================================
// Squared distance to the nearest bottom-layer atom
//
// Input:
//
//     xp, yp
//
// Position expressed in the unrotated coordinate frame of the bottom
// layer.
//
//     aBottom
//
// Bottom-layer Bravais lattice constant.
//
//     bottomForm
//
//         1 = Square
//         2 = Honeycomb
//         3 = Triangular
//         4 = Kagome
//
// Output:
//
//     Squared Euclidean distance from (xp,yp) to the nearest atomic site
//     in the bottom layer.
//
//======================================================================
// General lattice representation
//======================================================================
//
// Every atomic position is written as:
//
//     R(n,m,s) = n*a1 + m*a2 + b_s
//
// where:
//
//     n,m     integer unit-cell indices
//     a1,a2   primitive Bravais vectors
//     b_s     basis atom position
//
// The point is first converted into fractional primitive coordinates.
// The nearest rounded cell and its surrounding 3 x 3 cells are then
// searched for every basis atom.
//
// The local search is needed because independently rounding fractional
// coordinates in an oblique lattice does not always return the nearest
// Euclidean lattice point.
//======================================================================

Function MoireNearestBottomD2(xp,yp,aBottom,bottomForm)

    Variable xp
    Variable yp
    Variable aBottom
    Variable bottomForm


    // Primitive vectors.

    Variable a1x
    Variable a1y

    Variable a2x
    Variable a2y


    // Basis information.

    Variable basisCount
    Variable basisIndex

    Variable bx
    Variable by


    // Fractional-coordinate conversion.

    Variable determinant

    Variable qx
    Variable qy

    Variable f1
    Variable f2

    Variable i0
    Variable j0


    // Neighbor-cell search.

    Variable di
    Variable dj

    Variable candidateX
    Variable candidateY

    Variable dxLocal
    Variable dyLocal

    Variable d2
    Variable minimumD2


    //==================================================================
    // Check input
    //==================================================================

    if (aBottom <= 0)

        Print "Error: aBottom must be positive."

        return NaN

    endif


    bottomForm = round(bottomForm)

    if ((bottomForm < 1) || (bottomForm > 4))

        Print "Error: bottomForm must be 1, 2, 3 or 4."

        return NaN

    endif


    //==================================================================
    // Define bottom-layer primitive vectors and basis count
    //==================================================================

    if (bottomForm == 1)

        //==============================================================
        // 1. Square lattice
        //
        // Primitive vectors:
        //
        //     a1 = (aBottom,0)
        //     a2 = (0,aBottom)
        //
        // Basis:
        //
        //     b_A = (0,0)
        //
        // Nearest-neighbor distance:
        //
        //     d_NN = aBottom
        //==============================================================

        a1x = aBottom
        a1y = 0

        a2x = 0
        a2y = aBottom

        basisCount = 1


    elseif (bottomForm == 2)

        //==============================================================
        // 2. Honeycomb lattice
        //
        // Triangular Bravais lattice:
        //
        //     a1 = (aBottom,0)
        //
        //     a2 = (aBottom/2,sqrt(3)*aBottom/2)
        //
        // Basis:
        //
        //     b_A = (0,0)
        //
        //     b_B = (0,aBottom/sqrt(3))
        //
        // aBottom is the intra-sublattice lattice constant:
        //
        //     A-A = B-B = aBottom
        //
        // The nearest inter-sublattice bond length is:
        //
        //     A-B = aBottom/sqrt(3)
        //==============================================================

        a1x = aBottom
        a1y = 0

        a2x = aBottom/2
        a2y = sqrt(3)*aBottom/2

        basisCount = 2


    elseif (bottomForm == 3)

        //==============================================================
        // 3. Triangular lattice
        //
        // Primitive vectors:
        //
        //     a1 = (aBottom,0)
        //
        //     a2 = (aBottom/2,sqrt(3)*aBottom/2)
        //
        // Basis:
        //
        //     b_A = (0,0)
        //
        // Nearest-neighbor distance:
        //
        //     d_NN = aBottom
        //==============================================================

        a1x = aBottom
        a1y = 0

        a2x = aBottom/2
        a2y = sqrt(3)*aBottom/2

        basisCount = 1


    else

        //==============================================================
        // 4. Kagome lattice
        //
        // Triangular Bravais lattice:
        //
        //     a1 = (aBottom,0)
        //
        //     a2 = (aBottom/2,sqrt(3)*aBottom/2)
        //
        // Three-atom basis:
        //
        //     b_A = (0,0)
        //
        //     b_B = a1/2
        //         = (aBottom/2,0)
        //
        //     b_C = a2/2
        //         = (aBottom/4,sqrt(3)*aBottom/4)
        //
        // Each individual sublattice is triangular with lattice
        // constant aBottom.
        //
        // The shortest Kagome bond length is:
        //
        //     d_NN = aBottom/2
        //==============================================================

        a1x = aBottom
        a1y = 0

        a2x = aBottom/2
        a2y = sqrt(3)*aBottom/2

        basisCount = 3

    endif


    //==================================================================
    // Primitive-vector matrix determinant
    //==================================================================

    determinant = a1x*a2y-a1y*a2x


    if (abs(determinant) < 1e-15)

        Print "Error: singular bottom-layer primitive-vector matrix."

        return NaN

    endif


    minimumD2 = 1e30


    //==================================================================
    // Search the nearest site for every basis atom
    //==================================================================

    for (basisIndex=0; basisIndex<basisCount; basisIndex+=1)


        //==============================================================
        // Default basis atom A
        //==============================================================

        bx = 0
        by = 0


        //==============================================================
        // Honeycomb basis atom B
        //
        //     b_B = (0,aBottom/sqrt(3))
        //==============================================================

        if ((bottomForm == 2) && (basisIndex == 1))

            bx = 0
            by = aBottom/sqrt(3)

        endif


        //==============================================================
        // Kagome basis atom B
        //
        //     b_B = a1/2
        //         = (aBottom/2,0)
        //==============================================================

        if ((bottomForm == 4) && (basisIndex == 1))

            bx = aBottom/2
            by = 0

        endif


        //==============================================================
        // Kagome basis atom C
        //
        //     b_C = a2/2
        //         = (aBottom/4,sqrt(3)*aBottom/4)
        //==============================================================

        if ((bottomForm == 4) && (basisIndex == 2))

            bx = aBottom/4
            by = sqrt(3)*aBottom/4

        endif


        //==============================================================
        // Position relative to the current basis atom
        //==============================================================

        qx = xp-bx
        qy = yp-by


        //==============================================================
        // Convert Cartesian coordinates to fractional cell coordinates
        //
        //     q = f1*a1 + f2*a2
        //==============================================================

        f1 = (qx*a2y-qy*a2x)/determinant
        f2 = (-qx*a1y+qy*a1x)/determinant


        //==============================================================
        // Central candidate unit cell
        //==============================================================

        i0 = round(f1)
        j0 = round(f2)


        //==============================================================
        // Search surrounding 3 x 3 cells
        //==============================================================

        for (di=-1; di<=1; di+=1)

            for (dj=-1; dj<=1; dj+=1)

                candidateX = bx+(i0+di)*a1x+(j0+dj)*a2x
                candidateY = by+(i0+di)*a1y+(j0+dj)*a2y

                dxLocal = xp-candidateX
                dyLocal = yp-candidateY

                d2 = dxLocal^2+dyLocal^2


                if (d2 < minimumD2)

                    minimumD2 = d2

                endif

            endfor

        endfor

    endfor


    return minimumD2

End


//======================================================================
// Core real-space simulation
//
// The original function name is retained for compatibility, although
// this function now supports four different lattice forms.
//
// bottomForm and topForm:
//
//     1 = Square
//     2 = Honeycomb
//     3 = Triangular
//     4 = Kagome
//
//======================================================================
// Physical model
//======================================================================
//
// Only top-layer atoms are directly drawn into MoireMap.
//
// The bottom layer is used to calculate the local geometric registry.
//
// For each top-layer atom i:
//
//     d_i^2 = squared distance to the nearest bottom-layer atom
//
// The apparent height of that top atom is:
//
//     atomHeight_i
//       = 1 + AM*exp[-d_i^2/(2*xiStack^2)]
//
// Thus:
//
//     d_i = 0
//
// gives the largest stacking contribution when AM > 0.
//
// The topographic contribution of each top atom is represented by a
// Gaussian:
//
//     exp[-|r-R_i|^2/(2*sigmaAtom^2)]
//
// The complete map is:
//
//     MoireMap(r)
//       = sum_i atomHeight_i
//         * exp[-|r-R_i|^2/(2*sigmaAtom^2)]
//
// This is a geometric apparent-height model. It is not a microscopic
// LDOS or tunneling-current calculation.
//
//======================================================================
// General top-lattice representation
//======================================================================
//
// Every top-layer atom is written as:
//
//     R(i,j,s) = i*a1 + j*a2 + b_s
//
// followed by a rotation through:
//
//     topAngle = globalAngle + twistAngle
//
//======================================================================

Function GenerateMoireSquareFast(nPoint, lengthScale, aBottom, aTop, bottomForm, topForm, globalAngle, twistAngle, sigmaAtom, xiStack, AM)

    Variable nPoint
    Variable lengthScale

    Variable aBottom
    Variable aTop

    Variable bottomForm
    Variable topForm

    Variable globalAngle
    Variable twistAngle

    Variable sigmaAtom
    Variable xiStack
    Variable AM


    // Layer angles.

    Variable bottomAngle
    Variable topAngle

    Variable thT
    Variable thB

    Variable cosT
    Variable sinT

    Variable cosB
    Variable sinB


    // Image sampling.

    Variable pixelSize
    Variable halfLength


    // Top-layer primitive vectors before rotation.

    Variable topA1x
    Variable topA1y

    Variable topA2x
    Variable topA2y


    // Top-layer basis.

    Variable topBasisCount
    Variable basisIndex

    Variable topBasisX
    Variable topBasisY


    // Primitive-cell index-range calculation.

    Variable topDeterminant

    Variable inverseRowNorm1
    Variable inverseRowNorm2

    Variable cutoff
    Variable radius
    Variable nMax


    // Gaussian factors.

    Variable inv2Sigma2
    Variable inv2Xi2


    // Lattice-cell indices.

    Variable i
    Variable j


    // Top-layer atomic coordinates.

    Variable u
    Variable v

    Variable xt
    Variable yt


    // Top atom expressed in bottom-layer frame.

    Variable xp
    Variable yp


    // Registry-dependent height.

    Variable d2
    Variable atomHeight


    // Matrix coordinates.

    Variable ix
    Variable iy

    Variable ix0
    Variable ix1

    Variable iy0
    Variable iy1

    Variable xPos
    Variable yPos

    Variable r2


    //==================================================================
    // Validate input
    //==================================================================

    nPoint = round(nPoint)

    bottomForm = round(bottomForm)
    topForm = round(topForm)


    if (nPoint < 2)

        Print "Error: nPoint must be at least 2."

        return -1

    endif


    if (lengthScale <= 0)

        Print "Error: lengthScale must be positive."

        return -1

    endif


    if ((aBottom <= 0) || (aTop <= 0))

        Print "Error: aBottom and aTop must be positive."

        return -1

    endif


    if ((sigmaAtom <= 0) || (xiStack <= 0))

        Print "Error: sigmaAtom and xiStack must be positive."

        return -1

    endif


    if ((bottomForm < 1) || (bottomForm > 4))

        Print "Error: bottomForm must be 1, 2, 3 or 4."

        return -1

    endif


    if ((topForm < 1) || (topForm > 4))

        Print "Error: topForm must be 1, 2, 3 or 4."

        return -1

    endif


    //==================================================================
    // Layer-angle definitions
    //==================================================================

    bottomAngle = globalAngle

    topAngle = globalAngle+twistAngle


    //==================================================================
    // Image sampling
    //
    // lengthScale fixes the physical field of view.
    //
    // nPoint controls only sampling density.
    //==================================================================

    pixelSize = lengthScale/(nPoint-1)

    halfLength = lengthScale/2


    //==================================================================
    // Create output matrix
    //==================================================================

    Make/O/D/N=(nPoint,nPoint) MoireMap

    MoireMap = 0


    // Both axes cover the requested physical length.

    SetScale/I x,-halfLength,halfLength,"",MoireMap
    SetScale/I y,-halfLength,halfLength,"",MoireMap


    //==================================================================
    // Convert layer angles from degrees to radians
    //==================================================================

    thT = topAngle*pi/180
    thB = bottomAngle*pi/180

    cosT = cos(thT)
    sinT = sin(thT)

    cosB = cos(thB)
    sinB = sin(thB)


    //==================================================================
    // Define top-layer primitive vectors and number of basis atoms
    //
    // Every lattice is written in the form:
    //
    //     R(i,j,s) = i*a1 + j*a2 + b_s
    //
    // where:
    //
    //     a1,a2   Bravais-lattice primitive vectors
    //     b_s     basis position
    //
    // Unified definition:
    //
    //     aTop always denotes the Bravais-lattice translation length.
    //
    // For Honeycomb and Kagome, aTop is not the shortest bond length.
    //==================================================================

    if (topForm == 1)

        //==============================================================
        // 1. Square lattice
        //
        // Primitive vectors:
        //
        //     a1 = (aTop,0)
        //     a2 = (0,aTop)
        //
        // Basis:
        //
        //     b_A = (0,0)
        //
        // Nearest-neighbor distance:
        //
        //     d_NN = aTop
        //==============================================================

        topA1x = aTop
        topA1y = 0

        topA2x = 0
        topA2y = aTop

        topBasisCount = 1


    elseif (topForm == 2)

        //==============================================================
        // 2. Honeycomb lattice
        //
        // Honeycomb is not itself a Bravais lattice.
        //
        // It consists of:
        //
        //     triangular Bravais lattice
        //     +
        //     two-atom A/B basis
        //
        // Primitive vectors:
        //
        //     a1 = (aTop,0)
        //
        //     a2 = (aTop/2,sqrt(3)*aTop/2)
        //
        // Basis:
        //
        //     b_A = (0,0)
        //
        //     b_B = (0,aTop/sqrt(3))
        //
        // aTop is the intra-sublattice triangular-lattice constant:
        //
        //     A-A = B-B = aTop
        //
        // Inter-sublattice nearest-neighbor distance:
        //
        //     A-B = aTop/sqrt(3)
        //==============================================================

        topA1x = aTop
        topA1y = 0

        topA2x = aTop/2
        topA2y = sqrt(3)*aTop/2

        topBasisCount = 2


    elseif (topForm == 3)

        //==============================================================
        // 3. Triangular lattice
        //
        // Primitive vectors:
        //
        //     a1 = (aTop,0)
        //
        //     a2 = (aTop/2,sqrt(3)*aTop/2)
        //
        // Basis:
        //
        //     b_A = (0,0)
        //
        // Nearest-neighbor distance:
        //
        //     d_NN = aTop
        //
        // This Bravais lattice is also the underlying Bravais lattice
        // of the Honeycomb and Kagome lattices.
        //==============================================================

        topA1x = aTop
        topA1y = 0

        topA2x = aTop/2
        topA2y = sqrt(3)*aTop/2

        topBasisCount = 1


    else

        //==============================================================
        // 4. Kagome lattice
        //
        // Kagome is not itself a Bravais lattice.
        //
        // It consists of:
        //
        //     triangular Bravais lattice
        //     +
        //     three-atom A/B/C basis
        //
        // Primitive vectors:
        //
        //     a1 = (aTop,0)
        //
        //     a2 = (aTop/2,sqrt(3)*aTop/2)
        //
        // Basis:
        //
        //     b_A = (0,0)
        //
        //     b_B = a1/2
        //         = (aTop/2,0)
        //
        //     b_C = a2/2
        //         = (aTop/4,sqrt(3)*aTop/4)
        //
        // Each individual basis sublattice is triangular with lattice
        // constant aTop.
        //
        // The shortest Kagome nearest-neighbor distance is:
        //
        //     d_NN = aTop/2
        //==============================================================

        topA1x = aTop
        topA1y = 0

        topA2x = aTop/2
        topA2y = sqrt(3)*aTop/2

        topBasisCount = 3

    endif


    //==================================================================
    // Gaussian parameters
    //
    // Atomic contributions beyond four sigmaAtom are neglected.
    //==================================================================

    cutoff = 4*sigmaAtom

    inv2Sigma2 = 1/(2*sigmaAtom*sigmaAtom)

    inv2Xi2 = 1/(2*xiStack*xiStack)


    //==================================================================
    // Determine sufficient primitive-cell index range
    //
    // The distance from the image center to one corner is:
    //
    //     sqrt(2)*halfLength
    //
    // The inverse primitive-vector matrix converts the Cartesian radius
    // into a conservative primitive-cell index bound.
    //==================================================================

    radius = sqrt(2)*halfLength+cutoff


    topDeterminant = topA1x*topA2y-topA1y*topA2x


    if (abs(topDeterminant) < 1e-15)

        Print "Error: singular top-layer primitive-vector matrix."

        return -1

    endif


    // First row norm of the inverse primitive-vector matrix.

    inverseRowNorm1 = sqrt(topA2x^2+topA2y^2)/abs(topDeterminant)


    // Second row norm of the inverse primitive-vector matrix.

    inverseRowNorm2 = sqrt(topA1x^2+topA1y^2)/abs(topDeterminant)


    nMax = ceil(radius*max(inverseRowNorm1,inverseRowNorm2))+3


    //==================================================================
    // Generate top-layer atoms
    //==================================================================

    for (i=-nMax; i<=nMax; i+=1)

        for (j=-nMax; j<=nMax; j+=1)

            for (basisIndex=0; basisIndex<topBasisCount; basisIndex+=1)


                //======================================================
                // Define basis position in the current top unit cell
                //
                // basisIndex:
                //
                // Square:
                //     0 = A
                //
                // Honeycomb:
                //     0 = A
                //     1 = B
                //
                // Triangular:
                //     0 = A
                //
                // Kagome:
                //     0 = A
                //     1 = B
                //     2 = C
                //======================================================


                // Default basis atom A.

                topBasisX = 0
                topBasisY = 0


                //======================================================
                // Honeycomb basis atom B
                //
                //     b_B = (0,aTop/sqrt(3))
                //======================================================

                if ((topForm == 2) && (basisIndex == 1))

                    topBasisX = 0
                    topBasisY = aTop/sqrt(3)

                endif


                //======================================================
                // Kagome basis atom B
                //
                //     b_B = a1/2
                //         = (aTop/2,0)
                //======================================================

                if ((topForm == 4) && (basisIndex == 1))

                    topBasisX = aTop/2
                    topBasisY = 0

                endif


                //======================================================
                // Kagome basis atom C
                //
                //     b_C = a2/2
                //         = (aTop/4,sqrt(3)*aTop/4)
                //======================================================

                if ((topForm == 4) && (basisIndex == 2))

                    topBasisX = aTop/4
                    topBasisY = sqrt(3)*aTop/4

                endif


                //======================================================
                // Unrotated top-layer atomic position
                //
                //     R = i*a1 + j*a2 + basis
                //======================================================

                u = i*topA1x+j*topA2x+topBasisX

                v = i*topA1y+j*topA2y+topBasisY


                //======================================================
                // Rotate top layer into the laboratory frame
                //======================================================

                xt = u*cosT-v*sinT

                yt = u*sinT+v*cosT


                //======================================================
                // Keep atoms whose Gaussian overlaps the image
                //======================================================

                if ((xt >= -halfLength-cutoff) && (xt <= halfLength+cutoff) && (yt >= -halfLength-cutoff) && (yt <= halfLength+cutoff))


                    //==================================================
                    // Transform top atom into bottom-layer coordinates
                    //
                    //     r_bottom = R(-bottomAngle)*r_lab
                    //==================================================

                    xp = xt*cosB+yt*sinB

                    yp = -xt*sinB+yt*cosB


                    //==================================================
                    // Squared distance to the nearest bottom atom
                    //==================================================

                    d2 = MoireNearestBottomD2(xp,yp,aBottom,bottomForm)


                    //==================================================
                    // Registry-dependent apparent height
                    //==================================================

                    atomHeight = 1+AM*exp(-d2*inv2Xi2)


                    //==================================================
                    // Matrix-index range influenced by this atom
                    //==================================================

                    ix0 = max(0,floor((xt-cutoff+halfLength)/pixelSize))

                    ix1 = min(nPoint-1,ceil((xt+cutoff+halfLength)/pixelSize))


                    iy0 = max(0,floor((yt-cutoff+halfLength)/pixelSize))

                    iy1 = min(nPoint-1,ceil((yt+cutoff+halfLength)/pixelSize))


                    //==================================================
                    // Add Gaussian peak to MoireMap
                    //==================================================

                    for (ix=ix0; ix<=ix1; ix+=1)

                        xPos = -halfLength+ix*pixelSize


                        for (iy=iy0; iy<=iy1; iy+=1)

                            yPos = -halfLength+iy*pixelSize


                            r2 = (xPos-xt)^2+(yPos-yt)^2


                            MoireMap[ix][iy] += atomHeight*exp(-r2*inv2Sigma2)

                        endfor

                    endfor

                endif

            endfor

        endfor

    endfor


    return 0

End



//======================================================================
// FFT calculation
//
// sel = 1:
//
//     Direct FFT without an additional window.
//
// sel = 2:
//
//     Apply a two-dimensional Hanning window before FFT.
//
// Output wave:
//
//     input wave name + "_FFT"
//======================================================================

Function FFTrmoire(name,sel)

    Wave name
    Variable sel

    String FFTout


    Duplicate/O name,named


    // Replace NaN values before FFT.

    func_NaN0(named)


    FFTout = NameOfWave(name)+"_FFT"


    //==================================================================
    // Direct FFT
    //==================================================================

    if (sel == 1)

        FFT/OUT=3/DEST=$FFTout cvtcmplx(named)

    endif


    //==================================================================
    // Hanning-windowed FFT
    //==================================================================

    if (sel == 2)

        Duplicate/O named,nametemp_fft

        imagewindow/O hanning nametemp_fft

        FFT/OUT=3/DEST=$FFTout cvtcmplx(nametemp_fft)

        KillWaves nametemp_fft

    endif


    KillWaves named

    return 0

End



//======================================================================
// FFT color-scale function
//
// This function uses the existing user helper functions:
//
//     gethistgram_npcolor()
//     grabwinchild()
//
// and the custom colortable:
//
//     :Packages:NewColortable:XLiu_G
//
// tt controls the displayed color interval.
//======================================================================

Function color3s_for3dmfMoire(name,tt)

    Wave name
    Variable tt

    String W_coef = "W_coef"

    Wave W_coefw = $W_coef

    Variable sigma

    Variable lc
    Variable lh


    gethistgram_npcolor(NameOfWave(name))


    sigma = sqrt(2)*W_coefw[3]


    WaveStats/Q name


    //==================================================================
    // Lower color limit
    //==================================================================

    if (W_coefw[2]-0.5*tt*sigma > V_min)

        lc = W_coefw[2]-0.5*tt*sigma

    else

        lc = V_min

    endif


    //==================================================================
    // Upper color limit
    //==================================================================

    if (W_coefw[2]+0.5*tt*sigma < V_max)

        lh = W_coefw[2]+0.5*tt*sigma

    else

        lh = V_max

    endif


    ModifyImage/W=$grabwinchild(NameOfWave(name)) $NameOfWave(name) ctab={lc,lh,:Packages:NewColortable:XLiu_G,0}


    return 0

End



//======================================================================
// Display the central simulation equations and current parameters
//
// Important Igor-TeX syntax:
//
//     Igor TeX supports only a subset of LaTeX.
//
//     Use:
//         {\rm top}
//         {\rm bottom}
//         \xi_{\rm stack}
//         \sigma_{\rm atom}
//
//     Avoid:
//         \mathrm{top}
//         \mathbf{R}
//
// The WMTEX opening and closing markers require double backslashes
// inside an Igor string:
//
//     \\$WMTEX$ ... \\$/WMTEX$
//
// Inside the TeX formula itself, use normal single backslashes.
//======================================================================

//======================================================================
// Update the theoretical formula and current parameters displayed
// at the bottom of the interactive moire-simulation window.
//
// The displayed formula is:
//
// z(r)
//   = sum over visible top-layer atoms
//
// A_i
//   = registry-dependent apparent amplitude of top atom i
//
// d_i
//   = distance from top atom i to the nearest bottom-layer atom
//
// theta_bottom = globalAngle
// theta_top    = globalAngle + twistAngle
//
// The equation is displayed in a single line using Igor WMTEX.
//======================================================================

Function UpdateMoireTheoryAnnotation()

    //==================================================================
    // References to the current interactive parameters
    //==================================================================

    //NVAR gMoireN = root:gMoireN
    //NVAR gMoireLength = root:gMoireLength

    //NVAR gMoireABottom = root:gMoireABottom
    //NVAR gMoireATop = root:gMoireATop

    //NVAR gMoireBottomForm = root:gMoireBottomForm
    //NVAR gMoireTopForm = root:gMoireTopForm

    //NVAR gMoireGlobalAngle = root:gMoireGlobalAngle
    //NVAR gMoireTwistAngle = root:gMoireTwistAngle

    //NVAR gMoireSigmaAtom = root:gMoireSigmaAtom
    //NVAR gMoireXiStack = root:gMoireXiStack
    //NVAR gMoireAM = root:gMoireAM


    //==================================================================
    // Derived quantities
    //==================================================================

    //Variable pixelSize
    //Variable bottomAngle
    //Variable topAngle

    //String bottomFormName
    //String topFormName


    //if (gMoireN > 1)

    //    pixelSize = gMoireLength/(gMoireN-1)

    //else

    //    pixelSize = NaN

    //endif


    //bottomAngle = gMoireGlobalAngle

    //topAngle = gMoireGlobalAngle+gMoireTwistAngle


    //bottomFormName = MoireLatticeFormName(gMoireBottomForm)

    //topFormName = MoireLatticeFormName(gMoireTopForm)


    //==================================================================
    // Strings used in the annotation
    //==================================================================

    String equationLine

    //String parameterLine1
    //String parameterLine2

    String completeText


    //==================================================================
    // Main equation
    //
    // Notes on WMTEX syntax:
    //
    // 1. Use {\rm top}, {\rm bottom}, etc.
    //
    // 2. Avoid \mathbf and \mathrm because they may not be supported
    //    correctly by the Igor WMTEX parser.
    //
    // 3. The opening and closing WMTEX markers require doubled
    //    backslashes inside an Igor string:
    //
    //        \\$WMTEX$
    //        \\$/WMTEX$
    //
    // 4. The equation itself uses ordinary single backslashes.
    //
    // The font size can be adjusted by changing \Z13 below.
    //==================================================================

    equationLine = "\Z18\\$WMTEX$ z(r)=\sum_{i\in{\rm top}}A_i\exp\left[-\frac{\left|r-R_i^{\rm top}\right|^2}{2\sigma_{\rm atom}^2}\right]\;;\qquad A_i=1+A_M\exp\left(-\frac{d_i^2}{2\xi_{\rm stack}^2}\right)\;;\qquad d_i=\min_{j\in{\rm bottom}}\left|R_i^{\rm top}-R_j^{\rm bottom}\right|\;;\qquad \theta_{\rm bottom}=\phi,\quad\theta_{\rm top}=\phi+\theta \\$/WMTEX$"


    //==================================================================
    // First parameter line
    //
    // Displays:
    //
    // bottom lattice form
    // bottom lattice constant
    // bottom absolute angle
    //
    // top lattice form
    // top lattice constant
    // top absolute angle
    //==================================================================

    //sprintf parameterLine1, "\Z11Bottom: %s,  a = %.5g Å,  angle = %.4g deg       Top: %s,  a = %.5g Å,  angle = %.4g deg", bottomFormName, gMoireABottom, bottomAngle, topFormName, gMoireATop, topAngle


    //==================================================================
    // Second parameter line
    //
    // Displays:
    //
    // matrix size
    // field of view
    // physical pixel size
    // atomic Gaussian width
    // stacking-selection length
    // moire modulation amplitude
    // relative twist angle
    //==================================================================

    //sprintf parameterLine2, "\Z11N = %.0f,   L = %.6g Å,   pixel size = %.6g Å,   sigma = %.5g Å,   xi = %.5g Å,   AM = %.5g,   twist = %.4g deg", gMoireN, gMoireLength, pixelSize, gMoireSigmaAtom, gMoireXiStack, gMoireAM, gMoireTwistAngle


    //==================================================================
    // Combine the equation and parameter lines
    //
    // \r creates a new annotation line.
    // \sa+08 adds a small vertical separation before the parameters.
    //==================================================================

    completeText = equationLine

    //completeText += "\r\sa+08"+parameterLine1

    //completeText += "\r"+parameterLine2


    //==================================================================
    // Check whether the parent graph exists
    //==================================================================

    DoWindow MoireSquareInteractive

    if (V_flag == 0)

        return -1

    endif


    //==================================================================
    // Delete the previous annotation
    //==================================================================

    //TextBox/W=MoireSquareInteractive/K/N=moireTheory


    //==================================================================
    // Create the new annotation
    //
    // A=MB:
    //     Anchor to the middle-bottom of the parent window.
    //
    // X=0:
    //     Center horizontally.
    //
    // Y=1:
    //     Place slightly above the bottom boundary.
    //
    // B=0:
    //     No annotation background box.
    //
    // F=0:
    //     No annotation frame.
    //==================================================================

    TextBox/W=MoireSquareInteractive/C/N=moireTheory/F=0/B=0/A=MB/X=0/Y=1 completeText


    return 0

End
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
