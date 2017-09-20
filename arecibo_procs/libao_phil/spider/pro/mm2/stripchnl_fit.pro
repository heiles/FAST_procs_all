pro stripchnl_fit, sigmalimit, fitchnls, nstrip, $
	strp_cfs, strp_stk, beamin_arr, indx00, $
	hgt1, sighgt1, a_esoteric, sigarray, problem, negate_q=negate_q

;+
;PURPOSE: Like stripfit_to_pacoeffs, but intended for the chnl-by-chnl
;fits.  In the bandwidth-integrated fits, we fit Gaussians to the main
;beam.  But here, because these might be noisy, we don't fit the centers
;or the widths of the Gaussians; rather, we force the centers and widths
;to be the same as those in the bandwidth-integrated fits and fit only
;the heights. This turns the process from a nonlinear ls fit to a linear
;one. 
;
;	Having done this, we then fit the heights to the function
;
;       XY = A + B cos(2PA) + C sin(2PA),
;
;as in STRIPFIT_TO_PACOEFFS.
;
;CALLING SEQUENCE:
;STRIPCHNL_FIT, sigmalimit, fitchnls, nstrip, $
;	strp_cfs, strp_stk, hdr2info, indx00, $
;	hgt1, sighgt1, a, sigarray, problem
;
;INPUTS:
;	SIGMALIMIT: discard points with residuals exceeding
;sigmalimit*sigma. 
;
;	FITCHNLS the channel, or vectpr of channels, to fit.
;
;	MSTRIP: the strip number (0 thru 3)
;
;	STRP_CFS[ 12, 4, 4, *]: the array of STRIPFITS, which contains the
;bandwidth-integrated results. There is one entry in this array for each
;pattern. See BEAM_DESCRIBE and HDRDEF_ALLCAL.
;
;	STRP_STK[ 128, 4, 240, *]: the set of channel data for all 240
;positions in this all strips (one entry for each pattern). see
;HDRDEF_ALLCAL and related documentation.
;
;	HDR2INFO: contains various information about the pattern. See
;HDRDEF_ALLCAL for complete documentation
;
;	INDX00, the pattern number (if there are N patterns, INDX00
;ranges from 0 to N-1)
;
;OUTPUTS:
;	HGT1, the height of the main beam Gaussian from this fit.
;	SIGHGT1, the error of the height of the main beam Gaussian from
;this fit. 
;	A_ESOTERIC, the array of fitted stuff. Of esoteric interest only.
;	SIGARRAY, the errors in a
;	PROBLEM, nonzero if there's a fitting problem
;-


hgt1= fltarr(4)
sighgt1= fltarr(4)

problem=0
nfitchnls= n_elements(fitchnls)

stripfit= strp_cfs[ *,*,*,indx00]
if keyword_set( negate_q) then stripfit[ *,1,*]= -stripfit[ *,1,*]

totoffset= beamin_arr[ indx00].totoffsets
totoffset= reform( totoffset, 60, 4)
xdata= totoffset[ *,nstrip]

for nstk=0,3 do begin
;nstk=0

;NOW INTEGRATE THE POWERS DIRECTLY...ARE ANSWERS THE SAME?
chnldata_allstrips= strp_stk[ fitchnls, nstk, *, indx00]

IF ( NSTK EQ 1) THEN BEGIN
if keyword_set( negate_q) then $
	chnldata_allstrips[ *,0,*]= -chnldata_allstrips[ *,0,*]
ENDIF

chnldata_allstrips= reform( chnldata_allstrips, nfitchnls, 60, 4)
chnldata= total( chnldata_allstrips[*, *, nstrip], 1)/nfitchnls

;EVALUATE THE AMPLITUDE OF THE MAIN LOBE...
tsys= stripfit[ 10, nstk, nstrip]
slope= stripfit[ 11, nstk, nstrip]
alpha= stripfit[ 0, nstk, nstrip]

hgt= [ stripfit[ 1, nstk, nstrip], $
	stripfit[ 2, nstk, nstrip], stripfit[ 3, nstk, nstrip]]
hgt_stokesi= [ stripfit[ 1, 0, nstrip], $
	stripfit[ 2, 0, nstrip], stripfit[ 3, 0, nstrip]]
;REMEMBER TO USE NSTK=0 FOR THE CENTERS AND WIDTHS...
cen= [ stripfit[ 4, 0, nstrip], $
	stripfit[ 5, 0, nstrip], stripfit[ 6, 0, nstrip]]
wid= [ stripfit[ 7, 0, nstrip], $
	stripfit[ 8, 0, nstrip], stripfit[ 9, 0, nstrip]]

squint= stripfit[ 4, nstk, nstrip]
squash= stripfit[ 7, nstk, nstrip]

;WE MUST DERIVE THE TERMS IN EQN 15, SECTION 4 OF THE AOTM.

;THE FIRST TERM (THE POLARIZED AMPLITUDE):
gcurv_allcal, xdata, tsys, slope, alpha, hgt, cen, wid, $
	tfit_main_first

;;IF NSTK eq 0 THEN WE NEED ONLY THE FIRST TERM...

if (nstk ne 0) then begin
;;THE SECOND TERM (THE SQUINT)...
dmult= 0.01d0
cenoffset= cen
cenoffset[ 0] = cen[ 0] + wid[ 0]*(0. + dmult)
gcurv_allcal, xdata, tsys, slope, alpha, hgt_stokesi, cenoffset, wid, $
	gtfitplus
cenoffset[ 0] = cen[ 0] + wid[ 0]*(0. - dmult)
gcurv_allcal, xdata, tsys, slope, alpha, hgt_stokesi, cenoffset, wid, $
	gtfitminus
squint_derivative= (gtfitplus- gtfitminus)/(2.*dmult*wid[ 0])
tfit_squint= squint* squint_derivative

;;THE THIRD TERM (THE SQUASH)...
widoffset = wid
widoffset[ 0] = wid[ 0]*(1. + dmult)
gcurv_allcal, xdata, tsys, slope, alpha, hgt_stokesi, cen, widoffset, $
	gtfitplus
widoffset[ 0] = wid[ 0]*(1. - dmult)
gcurv_allcal, xdata, tsys, slope, alpha, hgt_stokesi, cen, widoffset, $
	gtfitminus
squash_derivative= (gtfitplus- gtfitminus)/(2.*dmult*wid[ 0])
tfit_squash= squash* squash_derivative

tfit_main_first= tfit_main_first+ tfit_squint+ tfit_squash
endif

tfit_both= tfit_main_first

;------------------NOW DO THE FIT...
tdata= chnldata-tfit_both

alldatasize= n_elements( tdata)
nparams= 3
jndx = indgen( alldatasize)

s_all=fltarr( nparams, alldatasize)
s_all[ 0,*] = 1.
s_all[ 1,*] = findgen( alldatasize) - (alldatasize-1.)/2.

;POLARIZED TSRC...

;THE FIRST TERM (THE POLARIZED AMPLITUDE):

TSRC_PLUS= [hgt[ 0] + 1., hgt[ 1], hgt[ 2]]
gcurv_allcal, xdata, $
	tsys, slope, alpha, TSRC_PLUS, cen, wid, TFIT_PLUS

TSRC_MINUS= [hgt[ 0] - 1., hgt[ 1], hgt[ 2]]
gcurv_allcal, xdata, $
	tsys, slope, alpha, TSRC_MINUS, cen, wid, TFIT_MINUS

s_all[ 2,*] = (TFIT_PLUS- TFIT_MINUS)/(TSRC_PLUS[ 0]- TSRC_MINUS[ 0])

;DEFINE NLOOP_BAD, THE NR OF ITERATIONS FOR BAD POINTS...
nloop_bad = 0
        
;---------- BEGINNING OF ITERATION LOOP FOR BAD POINTS---------

ITERATE_BAD:

;DETERMINE THE SIZE OF THE DATA ARRAY...
dtsize = n_elements(jndx)
        
s= s_all[ *, jndx]
t = tdata[ jndx] 

ss = transpose(s) ## s
st = transpose(s) ## t
ssi = invert(ss)
a = ssi ## st
        
tfit_all= s_all ## a
resid_all= tdata- tfit_all
resid= resid_all[ jndx]

sigsq = total( resid^2)/(dtsize - nparams)
sigma = sqrt( sigsq)
;CHECK TO SEE IF RESIDUALS EXCEED sigmalimit * SIGMA...
jjndx = where( abs(resid_all) lt sigmalimit*sigma, count_jjndx)

;stop

;IF THERE ARE TOO FEW GOOD POINTS, RETURN...
if (count_jjndx le nparams) then begin
        problem = -5
        GOTO, PROBLEM
endif
        
;IF THEY EXCEED sigmalimit * SIGMA, DISCARD AND ITERATE...
if ( count_jjndx lt dtsize) then begin
        jndx= jjndx
        nloop_bad= nloop_bad+1
;       stop, 'iterating, ', nloop_bad, count
        goto, ITERATE_BAD
end

;IF YOU GET THIS FAR, YOU'VE SUCCEEDED!!!

sigarray = sigsq * ssi[indgen(nparams)*(nparams+1)]
indxsqrt = where( sigarray lt 0., countsqrt)
sigarray = sqrt( abs(sigarray))

;TEST FOR NEG SQRTS...
if (countsqrt ne 0) then begin
        ;print, countsqrt, ' negative sqrts in sigarray!'
        sigarray[indxsqrt] = -sigarray[indxsqrt]
        problem=-3
        GOTO, PROBLEM
endif

;TEST FOR INFINITIES, ETC...
indxbad = where( finite( a) eq 0b, countbad)
if (countbad ne 0) then begin
        problem=-4
        GOTO, PROBLEM
endif

;DERIVE THE NORMALIZED COVARIANCE ARRAY...
doug = ssi[indgen(nparams)*(nparams+1)]
doug = doug#doug
cov = ssi/sqrt(doug)
        
goto, FINISH

;--------------------------
PROBLEM:
a= fltarr(nparams)   
sigarray= fltarr(nparams)

;------------------------
FINISH:

;print, transpose(a)
;print, sigarray

hgt1[ nstk]= hgt[ 0]+ a[ 2]
sighgt1[ nstk]= sigarray[ 0]

endfor

return

;-----------------------
PLOTM:

;print, hgt

;LEAVING THE HGT IN THE ORIGINAL EVALUATION OF TFIT_MAIN AND TFIT_BOTH,
;	GIVES THE INCREMENT INSTEAD OF TEH VALUE. THEN THE ACTUAL
;	HGT IS: HGT (FROM AWY ABOVE) PLUS A[2].

wset,0
plot, tdata, psym=-4, /ysty ;, yra=[ -2,2]
;plot, tdata, color=green, psym=6
oplot, tfit_all,color=green
oplot, tfit_both,color=magenta

wset,1
plot, chnldata, psym=-4, color=green, /ysty ;, yra=[ .5,1] ;yra=[ 48,52]
oplot, tfit_main_first
oplot, chnldata, psym=-4, color=green
oplot, tfit_main_first
;oplot, stokesoffset_cont[nstk, *, nstrip], color=green, psym=6
;oplot, tfit_both,color=magenta

;result= get_kbrd(1)
;endfor

end
