pro make_mmlsfit_inputs_m7, indx, a, beamin_arr, beamout_arr, $
        stkOffsets_chnl_arr,qpa, xpy, xmy, xy, yx, $
	muellerparams_init, muellerparams0, pacoeffs, ngoodpoints, $
	mueller_az=mueller_az, negate_q=negate_q, chnl=chnl

;+
;PURPOSE:
;	Generate inputs for the Mueller LS fit.  These depend only on
;the input data and, also, the Mueller matrix by which they have been
;corrected.  If they have been corrected by a Mueller matrix MMM, then
;setting MUELLER_AZ equal to MMM gives you the incremental correction to
;MMM. 

;######## question: how does MUELLER_AZ interact wiht MUELLERPARAMS0???

;INPUTS:
;
;	RCVR_NAME, the receiver name;
;
;	A, the input data structure that contains all hdr ifo
;
;	BEAMIN_ARR, structure containing the chnl-by-chnl stripfit 
;data that will be least squares fit for the Mueller matrix
;
;	BEAMOUT_ARR, structure containing the stripfit data that will
;be least squares fit for the Mueller matrix

;	MUELLERPARAMS_INIT: the initialization muellerparams to use as
;guesses in the nonlinear ls fit.
;
;KEYWORDS:
;
;	MIELLERPARAMS0: the values of muellerparams_init changed to
;reflect the particular receiver being used.

;	MUELLER_AZ: See explanation under "purpose" above.
;
;	NEGATE_Q: changes sign of the Mueller-uncorrected measure Stokes
;Q. "Always set to zero"

;	CHNL; if set, does channel CHNL instead of continuum.

;OUTPUTS:
;
;	QPA, the position angle at the center of each scan
;
;	XPY, the X+Y I at the scan center, normalized to X+Y.
;Thus this is always unity.
;
;	XMY, the X-Y at the scan center, normalized to X+Y. If the
;calibration were perfect, this would be Stokes Q.
;
;	XY, YX--ditto.

;	PACOEFFS: the output from striptopacoeffs
;-

forward_function  muellerparams_init

count_indx= n_elements( indx)

qpa= beamout_arr[ indx].azcntr

;strp_stk_src= beamin_arr[ indx].stkoffsets_chnl_arr
strp_stk_src=  stkoffsets_chnl_arr[*,*,*,*,indx]
szz= size( strp_stk_src)
total_number= n_elements( strp_stk_src)/ szz[ 1]
strp_stk_src= reform( strp_stk_src, szz[ 1], total_number)

discard= intarr( total_number)

strp_cfs_src= beamout_arr[ indx].stripfit

;CORRECT THE CHANNELS WITH CUMFILTER...
for nrtmp =0l, total_number-1 do begin
;for nrtmp =10l, 20l do begin
        tmp= strp_stk_src[ *, nrtmp]
;plot, tmp, xra=[ 4,123]
        cumfilter, tmp, 32, 3., indxgood, indxbad, countbad, $
;       cumfilter, tmp, 64, 12., indxgood, indxbad, countbad, $
        /median, /correct
        strp_stk_src[ *, nrtmp]= tmp
        discard[ nrtmp]= n_elements( indxbad)
;oplot, tmp, color=red
;res=get_kbrd( 1)
endfor
strp_stk_src= reform( strp_stk_src, szz[1], szz[2], szz[3]*szz[4], count_indx)


fitchnls= indgen(128)
;fitchnls= fitchnls[ 4:123]
fitchnls= fitchnls[ 8:119]
sigmalimit=3.

;qpa= fltarr( 4, count_indx)
xpy= fltarr( 4* count_indx)
xmy= fltarr( 4* count_indx)
xy= fltarr( 4* count_indx)
yx= fltarr( 4* count_indx)


;CYCLE THRU EACH OBSERVATION...
indxobs= 0
FOR NRC= 0, COUNT_INDX-1 DO BEGIN
        
FOR NSTRIP=0,3 DO BEGIN
stripchnl_fit, sigmalimit, fitchnls, nstrip, $
        strp_cfs_src, strp_stk_src, beamin_arr, nrc, $
        hgt1, sighgt1, a, sigarray, problem, negate_q= negate_q
xpy[ indxobs]= hgt1[ 0]/ hgt1[ 0]
xmy[ indxobs]= hgt1[ 1]/ hgt1[ 0]
xy[ indxobs]= hgt1[ 2]/ hgt1[ 0]
yx[ indxobs]= hgt1[ 3]/ hgt1[ 0]
indxobs= indxobs+1
ENDFOR  ;NSTRIP

ENDFOR  ;NRC

;HARDWIRE THE SIGMA FOR RESIDUALS TO BE DISCARDED...
sigmalimit=3.

qpa= reform( qpa, n_elements( qpa))
;STOP
;DERIVE THE POSITION ANGLE FITS...
stripfit_to_pacoeffs, qpa, xpy, xmy, xy, yx, sigmalimit, $
        pacoeffs, qsource, usource, qtrue, utrue, $
        sig_sq_qsource, sig_sq_usource, ngoodpoints=ngoodpoints, /short

;define the set of mueller params that will be used...
muellerparams0= muellerparams_init()

;GET RCVR PARAMETERS...
mmparam_define, a[ indx[0]].rcvnam, a[ indx[0]].cfr, fixpsi, alpha0, psi0
muellerparams0.alpha= alpha0
muellerparams0.psi= psi0
muellerparams0.fixpsi= fixpsi


return
end

