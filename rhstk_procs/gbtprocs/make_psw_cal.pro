pro make_psw_cal, onpair, src, stokescal, src_psw_cal

;+
;PURPOSE: replicate the original on-source src structures, filling the
;spectra with calibrated switched spectra. POSITIONS-SWITCHED DATA ONLY!
;
;CALLING SEQUENCE:
;       MAKE_PSW_CAL, onpair, src, stokescal, src_psw_cal
;
;INPUTS:
;       ONPAIR is the index of the on/off pair that is on-source. For
;example, if the second member of the pair is on source, onpair=1.
;       SRC is the src array, which consists of N pairs of on/off
;uncalibrated spectra and theh associated info
;       STOKESCAL is the set of switched calibrated spectra
;
;OUTPUTS:
;       SRC_PSW_CAL is the array of N calibrated spectra and their
;associated info (for the on-source half of the pairs).
;
;-

sz0= size( src.subscan)
src= reform( src, 2l, sz0[ 2]/2l)
src_psw_cal= reform( src[ onpair, *])
src= reform( src, sz0[ 2])

sz1= size( stokescal)
stokescal= reform( stokescal, sz1[1], 1, 4, sz0[ 1], sz0[ 2]/2l)

src_psw_cal.subscan.spec= stokescal

return
end
