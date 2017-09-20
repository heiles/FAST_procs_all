function get_xleg, xin, xmin, xmax, delx, quick=quick

;+
;NAME:
;GET_XLEG -- transform xin to optimum range of x valuesfor legendre fitting
;
;SEE DOC IN LEGENDREFIT OR LEGENDREFIT_SVD. REPEAT THOSE IMPORTANT NOTES:
;       (1) GODDARD'S FLEGENDRE/POLYLEG ARE MUCH FASTER THAN IDL'S LEGENDRE!
;       (2) THUS, GIVEN LEGENDRE COEFFS, EVALUATE: YFIT= POLYLEG( XDATA, LEGCOEFFS)
;       (3) THE XDATA MUST LIE BETWEEN -1 AND 1. WHAT'S MORE...
;       (4) PAY ATTENTION TO DOUBLE PRECISION FOR HARD PROBLEMS!!!
;       (5) IF THE ORIGINL XDATA VALUES ARE ***UNIFORMLY*** SPACED, then
;           to obtain max orthogonality:
;               (A) YOU HAVE nrt POINTS
;               (B) THESE nrt POINTS SPAN A TOTAL RANGE range
;               (C) THEN THE INTERVAL BETWEEN POINTS IS delta= range/(nrt-1)
;               (D) MAKE THE INPUT X VALUES BE...
;
;                       X = (2*findgen(nrt) - (nrt-1))/nrt
;
;                   the end points are half a bin away from the (-1,1) ends.
;               THIS IS ACCOMPLISHED BY x= get_xleg( quick=nrt)
;
;       (6) IF THE ORIGINL XDATA VALUES ARE ***NONUNIFORMLY*** SPACED, then
;           then a reasonable mapping scheme to the (-1,1) interval is...
;
;                       frtspan= max( frt)- min( frt)
;                       dfrtspan= frtspan/( nrt-1)
;                       sfrtspan= max( frt)+ min( frt)
;                       x = (2.*frt - sfrtspan)/(frtspan+ dfrtspan)
;           THE ABOVE 4 EQNS ARE PERFORMED BY...
;                       x = get_xleg( frt, min( frt), max( frt), dfrtspan)
;           TO MAP AN ARBITRAY SET OF F INTO THE SAME INTERVAL USE...
;                       x = (2.*f - sfrtspan)/(frtspan+ dfrtspan)
;           WHICH IS ACCOMPLISHED BY
;                       x = get_xleg( f, min( frt), max( frt), dfrtspan)
;
;SETTING quick=nrt USES (5) ABOVE; OTHERWISE 
;	DON'T SET QUICK AND THE SET (6) IS USED.
;
;CALLING SEQUANCE:
;	RESULT= GET_XLEG( XIN, XMIN, XMAX, DELX, [QUICK=NPTS]
;
;INPUTS:
;	XIN, the x values for which transformed valuse of XLEG are desired
;	XMIN, the minimum value of X for the transformation
;	XMAX, the maximum value of X for the transformation
;	DELX, the interval between x values for uniformly spaced array
;
;OPTIONAL INPUT:
;	QUICK. YOU CAN SET THIS EUAL TO NR OF POINTS FOR A UNIFORMLY 
;SPACED ARRAY AND NOT USE THE OTHER STANDARD INPUTS.
;
;OUTPUT:
;	XLEG, the transformed values of the inputs.  For a uniformly
;spaced array containing NRT elements, the values of XLEG lie between
;[-(nrt-1)/nrt] and [+(nrt-1)/nrt]
;
;EXAMPLE:
;
;	you have NRT=512 uniformly spaced values of frequency (FRT) and
;you want to do a legendre-nomial fit.  transform the original values to
;the proper range (XLEG)
;
;		xleg= get_xleg( quick=512)
;
;altenatively, use 
;		frtmin= min(frt)
;		frtmax= frt(max)
;		delfrt= (frtmax- frtmin)/( nrt-1)
;		xleg= get_xleg( frt, frtmin, frtmax, delfrt)
;
;then do the fit (you should use legendrefit_svd for hard problems)...
;
;	legendrefit, xlegfit[indxwb_incl], spwb_c[ indxwb_incl], degree, $
;        coeffs, sigcoeffs, yfit, residbad= 4., problem=problem
;
;	after doing the fit you want to apply these coefficients to an
;arbiTrary set of frequencies (FRA). 
;
;		xra= get_xleg( fra, frtmin, frtmax, delfrt)
;		xrafit = polyleg( xra, coeffs)
;
;HISTORY - documentation updated 3apr2006 by ch
;-

if keyword_set( quick) then begin
	xleg= (2.d*dindgen(quick)- (quick-1.d))/quick
	return, xleg
endif

fspan= xmax- xmin
sfspan= xmax+ xmin
xleg= (2.* xin- sfspan)/(fspan+ delx)
return, xleg

end

