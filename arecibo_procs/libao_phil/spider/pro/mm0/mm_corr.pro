pro mm_corr, mm_pro_user,rcvrn, cfr,stokesc1,azencoders,zaencoders, mcorr, $
    m_rcvrcorr= m_rcvrcorr, m_skycorr= m_skycorr, m_astro= m_astro

;+ 
;NAME:
;mm_corr
;PURPOSE: Mueller-correct the stokes data .stkoffsets_chnlxx 
;   (data that have already been calibrated with the cal). 
;
;INPUTS:
;
;   MM_PRO_USER: String; If specfied, use this proc to determine the
;mm coefficients instead of the default.  Set equal to '' for default. 
;
;   cfr: float  center frequency in Mhz for the data.
;   stokesc1[128,4,242] phase and intensity calibarated data to correct
;   
;   azencoders[60,4]: az encoder for the strip points
;   zaencoders[60,4]: az encoder for the strip points
;           stkoffsets_chnl[128,4,60,4,*] and stkoffsets_chnl_cal[128,4,2,*].
;
;KEYWORDS:
;
;   M_RCVRCORR is normally set, corrects for rcvr--this is the
;matrix that we put so much effort into calibrating!
;
;   M_SKYCORR is normally set, corrects for sky rotn wrt az arm 
;during tracking.
;
;   M_ASTRO is normally set, rotates PA's to astronomical definition.
;this rotation is not known for all rcvrs. at the moment it is known only
;for LBW and, maybe, CB. It is defined in the mmp.*** files.
;
;OUTPUTS:
;   BEAMIN: structure that contains the mm-corrected stkoffsets_chnlxxx data
;(the correction is done in place)
;
;   MCORR: the first three digits of this integer number tell
;whether: first digit, m_rcvr was applied; second, m_ksy was applied;
;third, m_astro was applied.
;
;NOTE:
;   the data stokesc1 will be corrected according to the keywords
;   m_rcvrcorr,m_skycorr,m_astro
;   the cal data stokesc1[*,*,0:1] will  only be corrected for
;   m_rcvrcorr no matter what the other keywords are set to. This will
;   let you see how well the rcvr_cor is doing since all of the polarized
;   power should end up in U for the cal difference.
;   Because of this we can use beamin_arr.azenc.. since we only need
;   the 240 locations for the paralactic angle correction, not the cals.
;
;---------------------------
;-

getrcvr, 0, rcvr_name, rcvrn, mmprocname=mmprocname

if ( not keyword_set(m_rcvrcorr)) then m_rcvrcorr=0
if ( not keyword_set(m_skycorr)) then m_skycorr=0
if ( not keyword_set(m_astro)) then m_astro=0
if ( n_elements( mm_pro_user) eq 0) then mm_pro_user = ''
if ( mm_pro_user ne '') then mmprocname= mm_pro_user


;------ DO THE MM CORRECTION -------------------------
;SET UP MM PARAMS FOR A DIAGONAL MATRIX AND ASSUME NO CORRECTION,
;   THEN TRY TO DO IT AND CHANGE THINGS.
mcorr=0
deltag=0.
epsilon=0.
alpha=0.
chi=90.*!dtor
psi=0.
phi=0.

IF (MMPROCNAME NE '') THEN BEGIN

print, 'FOR MM CORRECTION WE ARE USING MMPROCNAME = ', mmprocname

 call_procedure, mmprocname, cfr, m_tot, m_astron, $
       deltag, epsilon, alpha, phi, chi, psi, angle_astron

;print, m_astro
;print, m_astron

mcorr = 100* m_rcvrcorr+ 10* m_skycorr+ m_astro

mm_corr_stokesc1, m_tot, m_astron, stokesc1,azencoders,zaencoders, $
    m_rcvrcorr= m_rcvrcorr, m_skycorr= m_skycorr, m_astro= m_astro
ENDIF

end
