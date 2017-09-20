pro ls_xy_3, xxin, sigmaxx, zzin, sigmazz, $
	a_ls, atry, chisq, chisq_reduced, sigsqa, zzbar, $
	tolerance=tolerance

;+
;NAME: 
;LS_XY_3 -- FITS MULTIVARIATE SLOPES PLUS CONSTANT
;
;PURPOSE: FITS MULTIVARIATE SLOPES PLUS CONSTANT, E.G.
;	ZZ = A0*U + A1*V + a2*W +...
;
;assumes U, V, W... are the independent variables (or functions of 
;independent variables)
;
;
;************************* CAVAET ******************************
;tests by my ay250 class in 2005 indicate that the variances of 
;derived parameters may not be correct. however, there appears to
;be no bias in the derived parameters.
;****************************************************************
;
;INPUTS:
;	XXIN, the X matrix of the independent variables, of the form...
;		 _                  _
;		| u_0   v_0   w_0  ... |
;		| u_1   v_1   w_1  ... |
;		| u_2   v_2   w_2  ... |
;		| ...   ...   ...  ... |
;		|_                    _|
;
;	SIGMAXX, the intrinsic sigmas (uncertainties) of the U, V values, 
;	in which ONE of the independent variables can have nonzero errors.
;	This makes SIGMAXX to be of the form...
;
;		 _                       _
;		| sig(u_0)    0    0  ... |
;		| sig(u_0)    0    0  ... |
;		| sig(u_0)    0    0  ... |
;		|  ...       ...  ... ... |
;		|_                       _|
;
;	ZZIN, a 'horizontal' vector of the ZZ measurements
;	SIGMAZZ, the intrinsic measurement errors (sigmas) of the ZZ values.
;
;KEYWORDS:
;	TOLERANCE, the maximum change in any derived parameter. 
;	default is 1e-3
;OUTPUTS:
;	A_LS, the vector of results for the 'conventional' ls fit 
;		(the one that assumes no errors in U,  V...
;	ATRY, the vector of results for the ls fit
;	CHISQ, the chisq of the fit
;	CHISQ_REDUCED, the reduced chisq of the fit
;	SIGSQA, the sigma-squared of ATRY
;	ZZBAR, the predicted z-values from the derived ls parameters
;
;COMMENTS, RESTRICTIONS: See lsfit2005 writeup. max nr iterations is
;nr_iterate_max, currently set for max of 100.
;
;chisq definition is questionable (divided by
;	number of variables).
;
;	I'm not sure about the exact value of chisq...seems to be off 
;	(too small) by a little bit.
;
;HISTORY: 10 June 2002 by Carl Heiles
;updated mar2004...extraneous stuff removed and documentation firmed up.
;	tested only one a single independent variable.
;updated feb2005...more testing, realized errors can exist only for one
;	independent variable. For more generasl solns see Jefferys AJ 85, 177.
;-

nr_iterate_max= 100

;-------------------BEGIN WITH A STD LS FIT--------------------

if ( n_elements( tolerance) eq 0) then tolerance= 1.0e-3

xxoriginal= xxin
zzoriginal= zzin
xx= xxin
zz= zzin

;M IS THE NR OF POINTS
sizexx= size( xx)
n= sizexx[ 1]
m= sizexx[ 2]

xxm= transpose( xx) ## xx
xzm= transpose( xx) ## zz

xxmi= invert( xxm)
dc= xxmi[ (n+1)* indgen( n)] 
ncov= xxmi/ sqrt( dc # dc)

a= xxmi ## xzm
zzbar= xx ## a
zzbar_ls= zzbar
delzz= zz- zzbar
s_sq= total( delzz^2)/ ( m- n)
siga_sq= s_sq* dc
siga= sqrt( siga_sq)
a_ls= a

;stop

;----------------------BEGIN ALL-ERRORS PART--------------------
atry=a
zz= transpose( zzoriginal)
zzbar= transpose( zzbar)
xxmod= fltarr( n,m)
wgt = fltarr( m,m)

nr_iterate=0

ITERATE:

;DELTAZZ IS 'Delta y_m';;;
deltazz = zzbar - zz

;Amatrix is A_m in equations 12.29...
Amatrix= fltarr( n-1, n-1)

FOR mr=0, m-1 DO BEGIN

FOR nr=1, n-1 DO BEGIN
Amatrix[ nr-1,*]= atry[ nr]
Amatrix[ nr-1, nr-1]= $
	atry[ nr]* ( 1.+ $
	( sigmazz[ mr]/( atry[ nr]* sigmaxx[ nr, mr]) )^2 )
ENDFOR

invert_Amatrix= invert( Amatrix, astatus)
deltazzvector= transpose(  deltazz[ mr]+ fltarr( n-1) )

;********************* NEGATIVE SIGN?? ****************************
;DELXXVECTOR is delta_m in equation 12.30...
delxxvector= -invert_Amatrix ## deltazzvector

;XXMOD is X-MOD (section 12.3)
xxmod[ 0, mr]= 1.+ fltarr( n)
xxmod[ 1:*, mr]= xxoriginal[ 1:*, mr]+ delxxvector

wgtsum= total( (atry* sigmaxx[ *, mr])^2)
wgtsum= wgtsum+ sigmazz[ mr]^2
;wgtsum= (n-1)* wgtsum
wgt[ mr, mr]= sqrt( 1./ wgtsum)
ENDFOR

xxmodw = wgt ## xxmod
xxw = wgt ## xx
zzw = wgt ## zz

xx_w= transpose( xxmodw) ## xxw
xz_w= transpose( xxmodw) ## zzw
xx_wi= invert( xx_w, status)
anew= xx_wi ## xz_w
zzbar= xx ## anew

delta_a = anew- atry

;CHK FOR TOO MANY ITERATIONS...
IF ( nr_iterate eq nr_iterate_max-1) THEN BEGIN
	print, 'NO CONVERGENCE AFTER ', nr_iterate, ' ITERATIONS', $
		string(7b)
	print, 'NO CONVERGENCE AFTER ', nr_iterate, ' ITERATIONS', $
		string(7b)
	goto, finish
ENDIF 

;CHK FOR CONVERGENCE...
atry= anew
nr_iterate= nr_iterate+ 1
if ( max( abs(delta_a) ) gt tolerance) then goto, iterate

FINISH:
chisq_n= fltarr( m)

FOR mr=0, m-1 DO BEGIN
denom_sum= 1.+ total( (atry* sigmaxx[ *, mr]/sigmazz[ mr])^2 )
chisq_n[ mr]= (deltazz[ mr]/sigmazz[ mr])^2/ denom_sum
ENDFOR

chisq = total( chisq_n)
chisq_reduced = chisq / (m - n)

;BELOW SHOULD WE BE USING XX_WI OR invert( transpose( xxw) ## xxw)?????
sigsqa = chisq_reduced* xx_wi[ lindgen(n) * (n+1)]

;STOP

return
end
	
