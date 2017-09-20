pro randomn_multi, seed, covar, nn, dx

;+
;NAME: RANDOMN_MULTI -- return a set of random vectors with a multiGaussian pdf
;
;PURPOSE: return a set of random vectors with a multiGaussian pdf having
;	a specified covariance matrix. 
;
;CALLING SEQUENCE: randomn_multi, seed, covar, nn, dx
;
;INPUTS:
;	SEED, the usual IDL seed variable for random nr generation.
;	COVAR, the (MxM) covariance matrix
;	NN, the number of random vectors to return.
;
;OUTPUTS:
;	DX, the set of N random vectors, each of length M
;
;METHOD: uses cut and try method. Limits values to 5 sigma.
;
;HISTORY: CH 20apr2007: fixed missing factor of 0.5 in definition of pdf!! 
;-

covar_inverse= invert( covar)

;USE CHAUVENET'S CRITERION TO DETERMINE THE MAX RANGE IN DX...
DXMAX= sqrt(2.)* inverf( 1.- 1./(2.*nn)) * sqrt( diag_matrix( covar))
mm= n_elements( dxmax)

dx= fltarr( mm, nn)

;GENERATE n SETS OF RANDOM NUMBERS THAT LIE WITHIN 5 SIGMA OF EACH DIAGONAL ELEMENT...
nyes= 0l
nr=0l

WHILE 1 DO BEGIN
dx0= 2.* dxmax* randomu( seed, mm)- dxmax

pdf= exp( -0.5* dx0 ## covar_inverse ## transpose( dx0))
pdf_random= randomu( seed, 1)

IF PDF_RANDOM LE PDF THEN BEGIN
dx[ *,nyes]= dx0
nyes=nyes+1l
;print, nr, nyes
ENDIF

nr=nr+1l
if ( nyes eq nn) then break

ENDwhile

print, 'it took ', nr, ' trials to generate ', nyes, ' random vectors.'

;histo_wrap, xr[0,*], -10., 10., 200., be, bc, hx

return

end


