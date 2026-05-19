#pragma rtGlobals=1		// Use modern global access method.
#include <Resize Controls>
proc imtb()
variable,startmapping
variable,startphi
variable,detaphi
string startdata="data"+num2str(startmapping+1)
imageindex=startmapping+p
imagephi=startphi+p*detaphi
waveed=dimsize($startdata,0)
waveetaed=waveed
end
//////////////////////#pragma rtGlobals=1		// Use modern global access method.

/////////////////////////////////////////////////////////////////////////////

Function DeNaN(OriginalWave)       //Evaluate all NaN to 0

	Wave OriginalWave



	Variable i,j

	i=0

	j=0



	Do

		Do

			If(OriginalWave[i][j]<=100)

				OriginalWave[i][j]=OriginalWave[i][j]

			else

				OriginalWave[i][j]=0

			endif

			i+=1

		while(i<Dimsize(OriginalWave,0))



		j+=1

		i=0

	While(j<Dimsize(OriginalWave,1))



End



Function Interpolate_x(OriginalWave, Factor, IntMethod)

	wave OriginalWave

	Variable Factor

	Variable IntMethod



	Variable FinalNum

	FinalNum=dimsize(originalWave,0)*factor



	Make/o/n=(Finalnum,dimsize(originalWave,1)) NewWave

	make/o/n=(dimsize(originalWave,0)) xwave

	make/o/n=(finalnum) Newxwave



	Variable i,j

	i=0



	Do

		j=0

		Do



			xwave[j]=OriginalWave[j][i]

			j+=1

		While(j<dimsize(originalWave,0))



			j=0



			Interpolate2/T=(intmethod)/N=(FinalNum)/Y=newxwave/X=test1_Lx xwave

		Do

			Newwave[j][i]=newxwave[j]

			j+=1

		While(j<dimsize(newwave,0))

		i+=1

	While(i<dimsize(originalWave,1))



	setscale x, dimoffset(originalWave,0), dimoffset(originalWave,0)+dimdelta(originalWave,0)*dimsize(originalWave,0), NewWave

	setscale y, dimoffset(originalWave,1), dimoffset(originalWave,1)+dimdelta(originalWave,1)*dimsize(originalWave,1), NewWave



	Duplicate/o newwave OriginalWave

	//Killwaves Newwave, newxwave, xwave



End



Function Interpolate_y(OriginalWave, Factor, IntMethod)

	wave OriginalWave

	Variable Factor

	Variable IntMethod



	Variable FinalNum

	FinalNum=dimsize(originalWave,1)*factor



	Make/o/n=(dimsize(originalWave,0), finalNum) NewWave

	make/o/n=(dimsize(originalWave,1)) ywave

	make/o/n=(finalnum) Newywave



	Variable i,j

	i=0



	Do

		j=0

		Do



			ywave[j]=OriginalWave[i][j]

			j+=1

		While(j<dimsize(originalWave,1))



			j=0



			Interpolate2/T=(intmethod)/N=(FinalNum)/Y=newywave/X=test_Lx ywave

		Do

			Newwave[i][j]=newywave[j]

			j+=1

		While(j<dimsize(newwave,1))

		i+=1

	While(i<dimsize(originalWave,0))



	setscale x, dimoffset(originalWave,0), dimoffset(originalWave,0)+dimdelta(originalWave,0)*dimsize(originalWave,0), NewWave

	setscale y, dimoffset(originalWave,1), dimoffset(originalWave,1)+dimdelta(originalWave,1)*dimsize(originalWave,1), NewWave



	Duplicate/o newwave OriginalWave

	//Killwaves Newwave, newxwave, xwave



End



Function Interpolate_xy(OriginalWave, Factor, IntMethod)

	wave OriginalWave

	Variable Factor

	Variable IntMethod



	Interpolate_x(OriginalWave, Factor, IntMethod)

	Interpolate_y(OriginalWave, Factor, IntMethod)

End
/////////////////////////////////////////////////////////////////////////////////
Function BCS_delta_T(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = 0.086*ratio*tc*tanh(ratio*sqrt(x/tc-1))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = ratio
	//CurveFitDialog/ w[1] = tc

	return 0.086*w[0]*w[1]*tanh(w[0]*sqrt(x/w[1]-1))
End

Function LiangFu(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = c*(bessJ(0,(u/d)*x/k)*exp(-x/k+80/k))^2+c*(bessJ(1,(u/d)*x/k)*exp(-x/k+80/k))^2
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 4
	//CurveFitDialog/ w[0] = c
	//CurveFitDialog/ w[1] = u
	//CurveFitDialog/ w[2] = d
	//CurveFitDialog/ w[3] = k

	return w[0]*(bessJ(0,(w[1]/w[2])*x/w[3])*exp(-x/w[3]+80/w[3]))^2+w[0]*(bessJ(1,(w[1]/w[2])*x/w[3])*exp(-x/w[3]+80/w[3]))^2
End

Window Graph3() : Graph
	PauseUpdate; Silent 1		// building window...
	Display /W=(696,131,1091,339) sgsg_g2
EndMacro
