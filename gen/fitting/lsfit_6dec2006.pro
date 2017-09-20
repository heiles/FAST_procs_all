pro lsfit_svd, X, y, U, V, $
	wgt, a, vara, siga, ncov, s_sq, $
	xxinv_svd=xxinv_svd, wgt_inv=wgt_inv, ybar=ybar, cov=cov, $
	status=status, divide=divide, itmax=itmax

;+ 
;NAME:
;LSFIT_SVD -- do lsfit using SVD instead of inverse normal equations.
;
;	The equations of condition are
;
;	X a = y
;
;where X is a the equation-of-conditon matrix, A is the vector of unknowns,
;and y are the measured values.
;
;	This returns the solution vector x, its variances and sigmas,
;and the normalizedd covariance matrix. These are the standard ls fit things.
;It also returns the vector of SVD weights and the V matrix (see NM section
;2.6 ('SVD of a Square Matrix') and chapter 15 (least squares solution by SVD).
;
;CALLING SEQUENCE:
;lsfit_svd, X, y, U, V, $
;	wgt, a, vara, siga, ncov, s_sq, $
;	xxinv_svd=xxinv_svd, wgt_inv=wgt_inv, ybar=ybar, cov=cov
;
;INPUTS:
;	X, the equation-of-conditon matrix
;	y, the vector of measured values
;	U, NM's matrix U (input only if WGT_INV is used; see discussion below)
;	V, NM's matrix V (input only if WGT_INV is used; see discussion below)
;
;OUTPUTS:
;	U, NM's U matrix. also an input; see discussion below
;	V, NM's V matrix, the matrix whose columns are the 
;orthonormal eigenvectors. also an input; see discussion below
;	WGT, the vector of weights of V (see discussion below)
;	A, the vector of unknowns
;	vara, a vector containing the variance of a
;	siga, a vector containing the sigma of a (sqrt variance)
;	ncov, the normalized covariance matrix
;	s_sq, the variance of the datapoints
;
;KEYWORDS:
;	WGT_INV, the vector of reciprocal weights (equal to 1/WGT unless you
;change them yourself). If WGT_INV is specified, then the procedure assumes
;that  you have already run it once, examined the weight vector WGT and
;found a problem, and specified the new vector of WGT_INV=1/WGT. It uses this
;modified WGT_INV and it uses the values of U and V given as inputs
;(because they have already been computed). If WGT_INV is not specified, it
;evaluates U and V and returns them as outputs.
;See COMMENTARIES below.
;
;	XXINV_SVD, the effective inverse of X obtained using WGT_INV. 
;If WGT_INV is left unmodified, XXINV_SVD is the inverse of X. But the
;whole point of SVD is to modify WGT_INV by setting certain elements to 
;zero so a to eliminate an effectively degenerate inverse of X. 
;See COMMENTARIES below.
;
;	COV, the usual covariance matrix
;
;	YBAR, the fitted values of the datapoints
;
;IMPORTANT COMMENTARIES REGARDING USE OF SVD!!!
;	Read NM's discussion of WGT. Each element of WGT refers to the 
;corresponding column of V; consider each column of V to be an eigenvector
;in the space defined by the X matrix. 
;If a particular value of WGT is small, then the projection of the
;corresponding eigenvector in V is small. 
;
;	As discussed in NM, you should then rerun the solution with the 
;corresponding elements of WGT_INV set equal to 1/WGT, except for the problem 
;value which should be set equal to zero (yes, if a particular element of
;WGT is small the corresponding WGT_INV element is large; you set it equal to
;zero to remove it from the solution).

;HISTORY: written by carl heiles while flying back from Arecibo in july 2004.
;mistakes in covariance matrix and associated parameter errors 27 feb 05.
;	29jun05: replace SVDC (which doesn't always converge) 
;with LA_SVD (needs idl 5.6)
;	23aug05: use !version to choose svd routine. warn if svdc.
;-

ndata= (size( x)) [2]

quick=0

;stop, 'STOP, lsfit_svd-1'

;DO CASE OF XXINV_SVD SPECIFIED...
IF  keyword_set( xxinv_svd) THEN BEGIN
nparams= ( size( xxinv_svd))[2]
quick=1
GOTO, QUICKSOLVE
ENDIF

;DO CASE OF wgt_inv UNSPECIFIED...
IF  keyword_set( wgt_inv) eq 0 THEN BEGIN
	if float( !version.release) lt 5.6 then begin
;	print, 'idl version is', !version.release, ' ; using SVDC'
	svdc, x, wgt, u, v, /double, itmax=itmax
	endif else begin
	la_svd, x, wgt, u, v, status=status, divide=divide
;	print, 'idl version is', !version.release, ' ; using LA_SVD'
	endelse
wgt_inv= 1./wgt
ENDIF

;stop, 'STOP, lsfit_svd-2'

;EVALUATE THE DIAGONAL wgt MATRIX...
nparams= n_elements( wgt_inv)
diags= (nparams+1l)* lindgen(nparams)
wdiagmatrix= dblarr( nparams, nparams)
wdiagmatrix[diags]= wgt_inv

;print, 'starting evaluation of a', systime()
;EVALUATE THE DERIVED PARAMETER MATRIX...
xxinv_svd= v ## wdiagmatrix ## transpose( u) 

;stop, 'STOP, lsfit_svd-3'

QUICKSOLVE:
a= xxinv_svd ## y
;print, 'finished evaluation of a', systime()

;EVALUATE THE VARIANCE OF THE DATAPOINTS...
ybar= x ## a
dely= y - ybar
s_sq= total( dely^2)/( ndata- nparams)

IF  quick eq 1 THEN RETURN

;EVALUATE THE COVARIANCE MATRIX AND ALSO NCOV...
cov=  v ## wdiagmatrix^2 ## transpose(v)
ncov= cov/ sqrt( cov[ diags] ## cov[ diags])

vara= s_sq* cov[ diags]
siga= sqrt( vara)
a= reform( a)

;stop

return
end

