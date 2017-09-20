pro lsfit_svd, X, y, U, V, $
	wgt, a, vara, siga, ncov, s_sq, $
	xxinv_svd=xxinv_svd, wgt_inv=wgt_inv, ybar=ybar, cov=cov, $
	status=status, divide=divide, svdonly=svdonly, quick=quick, $
        itmax=itmax, double=double
;+ 
;NAME:
;LSFIT_SVD -- do lsfit using SVD instead of inverse normal equations. 
;
;For a simple explanation of its use, see
;============= HOW TO USE THIS PROCEDURE FOR LS FITTING ================
;below.
;
;	The equations of condition are
;
;	X A = Y
;
;where X is a the equation-of-conditon matrix, A is the vector of unknowns,
;and y are the measured values.
;
;       This returns the solution vector a, its variances and sigmas,
;and the normalizedd covariance matrix. These are the standard ls fit
;things.  It also returns the vector of SVD weights and the V matrix
;(see Numerical Recipes [NR] section 2.6 ('SVD of a Square Matrix') and
;chapter 15 (least squares solution by SVD).
;
;CALLING SEQUENCE:
;lsfit_svd, X, Y, U, V, $
;	wgt, A, vara, siga, ncov, s_sq, $
;	xxinv_svd=xxinv_svd, wgt_inv=wgt_inv, ybar=ybar, cov=cov, $
;	status=status, divide=divide, svdonly=svdonly, itmax=itmax
;
;INPUTS:
;	X, the equation-of-conditon matrix. not needed if WGT_INV and V
;	are specified
;	Y, the vector of measured values
;	U, NR's matrix U (input only if WGT_INV is used; see discussion below)
;	V, NR's matrix V (input only if WGT_INV is used; see discussion below)
;
;OUTPUTS:
;	U, NR's U matrix. also an input; see discussion below
;	V, NR's V matrix, the matrix whose columns are the 
;orthonormal eigenvectors. also an input; see discussion below
;	WGT, the vector of weights of V (see discussion below)
;	A, the vector of unknowns
;	vara, a vector containing the variance of a
;	siga, a vector containing the sigma of a (sqrt variance)
;	ncov, the normalized covariance matrix, doesn't calculate if already defined.
;	s_sq, the variance of the datapoints
;
;KEYWORDS/OPTIONAL OUTPUTS:
;	WGT_INV, the vector of reciprocal weights (equal to 1/WGT unless you
;change them yourself). If WGT_INV is specified, then the procedure assumes
;that  you have already run it once, examined the weight vector WGT and
;found a problem, and specified the new vector of WGT_INV=1/WGT. It uses this
;modified WGT_INV and it uses the values of U and V given as inputs
;(because they have already been computed). If WGT_INV is not specified, it
;evaluates U and V and returns them as outputs. ***NOTE***: if WGT_INV
;is specified, then V must also be specified.
;See COMMENTARIES below.
;
;	XXINV_SVD, the effective inverse of X obtained using WGT_INV. 
;If WGT_INV is left unmodified, XXINV_SVD is the inverse of X. But the
;whole point of SVD is to modify WGT_INV by setting certain elements to 
;zero so a to eliminate an effectively degenerate inverse of X. 
;See COMMENTARIES below.
;
;	COV, the usual covariance matrix. doesn't calculate if already defined.
;	YBAR, the fitted values of the datapoints
;       STATUS, the status of the SVD solution from LA_SVD
;       DIVIDE, set for the DIVIDE/CONQUER option in LA_SVD
;       DOUBLE, do the first-pass svd solution in double precision.
;       SVDONLY, set to do SVD matrix evaluations only and not the
;solution. In ths case you don't need to specify Y as input; use a dummy variable.
;       QUICK, set to return only the derived coeffs and not COV, NCOV, or errors
;       ITMAX, max nr of iterations sfor SVDC, an obsolete version of LA_SVD
;
;============= HOW TO USE THIS PROCEDURE FOR LS FITTING ================
;
; ---------------------- FIRST --------------------------------
;run lsfit_svd with inputs X and Y and regard all other
;parameters (in particular: U, V, wgt) as output. That is:
;
;lsfit_svd, X, Y, U, V, $
;       wgt, A, vara, siga, ncov, s_sq
;
;The vector of derived coefficients is A; the vector of variances is
;vara, the normalized covariance matrix is ncov, etc.

;If the problem is NOT DEGENERATE, you are finished. How do you tell
;degeneracy? Look at the wgt vector. If the ratio of max(wgt)/min(wgt)
;is large (and especially if it approaches machine accuracyh (~10^7 for
;single precision), then the problem IS degenerate, and proceed to the
;next step, which immediately follows. IF THE PROBLEM IS DEGENERATE, the
;results from this step are TOTALLY WORTHLESS!!!
;
; ---------------------- SECOND -------------------------------- 
;you need to do this step only if the problem is degenerate, i.e. if
;some elements ('baddies') of the WGT vector are small or zero. Do the
;following:
;
;wgt_inv= 1./wgt
;wgt_inv[ baddies] = 0.
;lsfit_svd, X, Y, U, V, $
;       wgt, A, vara, siga, ncov, s_sq, wgt_inv=wgt_inv
;
;note, here, that U and V are now INPUTS, having been determined as
;OUTPUTS from the first call.

;========================================================================
;
;WANT TO UNDERSTAND WHAT YOU'RE DOING?  Read NR's discussion of
;WGT. Each element of WGT refers to the corresponding column of V;
;consider each column of V to be an eigenvector in the space defined by
;the X matrix.  The columns of U aree the new basis functions
;(orthonormal eigenfunctions corresponding to the eigenvectors in V);
;The columns of X are the old nonorthogonal basis functions. . If a
;particular value of WGT is small, then the projection of the X
;eigenfunctions onto the corresponding eigenvector in V is small,
;producing degeneracy.
;
;	As discussed in NR, you should then rerun the solution with the 
;corresponding elements of WGT_INV set equal to 1/WGT, except for the problem 
;values which should be set equal to zero.

;============================================================
;
;HISTORY: written by carl heiles while flying back from Arecibo in july 2004.
;mistakes in covariance matrix and associated parameter errors 27 feb 05.
;	29jun05: replace SVDC (which doesn't always converge) 
;       with LA_SVD (needs idl 5.6)
;	23aug05: use !version to choose svd routine. warn if svdc.
;       6dec06: include keyword SVDONLY (option of not solving, just 
;       16mar2010: corrected the documentation.
;       16apr2010: enhanced documentation.
;-

ndata= (size( x)) [2]

;CHECK FOR INPUTS ...
if keyword_set( wgt_inv) and keyword_set( v) eq 0 then begin
    print, 'WGT_INV IS SPECIFIED AND V IS NOT, WHICH IS FORBIDDEN'
    return
endif

;DO CASE OF THE wgt_inv VECTOR UNSPECIFIED...
IF  keyword_set( wgt_inv) eq 0 THEN BEGIN
	if float( !version.release) lt 5.6 then begin
;	print, 'idl version is', !version.release, ' ; using SVDC'
	svdc, x, wgt, u, v, double=double, itmax=itmax
	endif else begin
	la_svd, x, wgt, u, v, status=status, divide=divide, double=double
;	print, 'idl version is', !version.release, ' ; using LA_SVD'
	endelse
wgt_inv= 1./wgt
ENDIF

;stop, 'STOP, lsfit_svd-2'

;CREATE THE DIAGONAL wgt^(-1) MATRIX FROM THE WGT_INV VECTOR...
nparams= n_elements( wgt_inv)
diags= (nparams+1l)* lindgen(nparams)
wdiagmatrix= dblarr( nparams, nparams)
wdiagmatrix[diags]= wgt_inv

;IF XXINV_SVD IS NOT SPECIFIED, EVALUATE IT...
if keyword_set( xxinv_svd) eq 0 then xxinv_svd= v ## wdiagmatrix ## transpose( u) 

;EVALUATE THE COVARIANCE MATRIX AND ALSO NCOV...
IF KEYWORD_SET( QUICK) EQ 0 THEN BEGIN
if keyword_set( cov) eq 0 then cov=  v ## wdiagmatrix^2 ## transpose(v)
if keyword_set( ncov) eq 0 then ncov= cov/ sqrt( cov[ diags] ## cov[ diags])
ENDIF

if keyword_set( svdonly) then return

;SOLVE FOR COEFFS AND GET the residuals
a= xxinv_svd ## y

ybar= x ## a
a= reform( a)

dely= y - ybar
s_sq= total( dely^2)/( ndata- nparams)

if keyword_set( quick) then return

;GET COEFFICIENT VARIANCES IF QUICK NOT SET
vara= s_sq* cov[ diags]
siga= sqrt( vara)

return
end

