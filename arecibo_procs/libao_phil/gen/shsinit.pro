@geninit
addpath,'atm'
;
; hold the luns as we open descriptors, 
; this allows us to close all the luns at once if we want
;
common shscom,shsnluns,shslunar
    shsnluns=0L
    shslunar=intarr(100)
