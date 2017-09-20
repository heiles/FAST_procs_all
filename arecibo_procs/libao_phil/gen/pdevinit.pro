;+
;NAME:
;pdevinit - initialize to use the pdev spectrometer
;SYNTAX: @pdevinit
;DESCRIPTION:
;   call this routine before using any of the pdev idl routines.
;It sets up the path for the idl pdev directory and defines the
;necessary structures.
;-
@geninit
addpath,'pdev'
@pdev.h
;
; hold the luns as we open descriptors,
; this allows us to close all the luns at once if we want
;
common pdevcom,pdevnluns,pdevlunar
    pdevnluns=0L
    pdevlunar=intarr(100)

;
; 
forward_function pdevavg,pdevbitrevind,pdevcmpstats,pdevfileinfo,$
			     pdevfilelist,pdevfreq,pdevget,pdevgetm,pdevinplpf,$
			     pdevinppfb,pdevlevels,pdevopen,pdevparsfnm,pdevpwr,pdevrms,$
			     pdevtdspc,pdevtpfile
