@corinit
addpath,'galfa'
; get updated version
;.compile corhquery
@gal.h
;
; hold the luns as we open descriptors, 
; this allows us to close all the luns at once if we want
;
common galcom,galnluns,gallunar
    galnluns=0L
    gallunar=intarr(100)
