;
; structure to hold cal spectra/data
;
a={meascal,$
    freq    : 0.     ,$; freq in mhz center of band
    type    : 0      ,$; 1 abs, 2 skj
    scan    : 0L     ,$; first scan of pair
    brd     : 0      ,$; brd 0..3
    spOn    : fltarr(256,2),$; spectra cal on, a,b
    spOff   : fltarr(256,2),$; spectra cal off,a,b
    spcal   : fltarr(256,2),$; cal on/off
    tpCal   : fltarr(2),$; computed from spcal
    tpOn    : fltarr(2),$; total power cal on a,b no mask
    tpOff   : fltarr(2)} ; total power cal off a,b no mask
addpath,'Cor2/rfi'
.run mcalinp
