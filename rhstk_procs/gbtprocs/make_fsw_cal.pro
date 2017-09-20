pro make_fsw_cal, src, stokescal10, stokescal01, src_fsw_cal

;+
;PURPOSE: replicate the original on-source src structures, filling the
;spectra with calibrated switched spectra. for fsw data.
;
;CALLING SEQUENCE:
;       MAKE_FSW_CAL, src, stokescal10, stokescal01, src_fsw_cal
;
;INPUTS:
;       SRC is the src array, which consists of N scans of fsw data
;uncalibrated spectra and theh associated info
;       STOKESCAL10 is the set of switched calibrated spectra for (LO_1,
;LO_0) regarded as (ON, OFF)
;       STOKESCAL01 is the set of switched calibrated spectra for (LO_0,
;LO_1) regarded as (ON, OFF)
;
;OUTPUTS:
;       SRC_FSW_CAL is the array of N calibrated spectra and their
;associated info (for the on-source half of the pairs).
;
;-

src_fsw_cal= src

sz0= size( src.subscan)
sz1= size( stokescal10)
;stop
stokescal10= reform( stokescal10, sz1[ 1], 1, 4, sz0[ 1], sz0[ 2])
stokescal01= reform( stokescal01, sz1[ 1], 1, 4, sz0[ 1], sz0[ 2])
src_fsw_cal.subscan.spec[ *, 0, *, *,*]= stokescal10 
src_fsw_cal.subscan.spec[ *, 1, *, *,*]= stokescal01 

;stop
return
end
