;+
;NAME:
;masinit - initialize to use the mock spectrometer fits routines
;SYNTAX: @masinit
;DESCRIPTION:
;   call this routine before using any of the mas... idl routines.
;It sets up the path for the idl mas directory and defines the
;necessary structures.
;-
@geninit
addpath,'mas'
;
; this has some of jeffs pdev definitions we need
@pdev.h
;
; mainly the fits file definitions
@mas.h
;
; to get mmparams{} struct
; 
@hdrMueller.h
;
; hold the luns as we open descriptors, 
; this allows us to close all the luns at once if we want
;
common mascom,masnluns,maslunar
    masnluns=0L
    maslunar=intarr(100)
;
forward_function masavg,masavgmb,masfilelist,masfilesum,masfreq,masfreqdesc,$
      masget,masgetm,masgetstat,masopen,masrdrsat,masmostrecentfile,masaccum
