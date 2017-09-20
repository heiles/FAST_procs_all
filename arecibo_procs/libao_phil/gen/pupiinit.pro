;+
;NAME:
;pupiinit - initialize to use the pupi  routines
;SYNTAX: @pupfinit
;DESCRIPTION:
;   call this routine before using any of the pupi... idl routines.
;It sets up the path for the idl pupi directory and defines the
;necessary structures.
;-
@geninit
@masinit
addpath,'pupi'

;
;
; mainly the fits file definitions
;@mas.h
;
; hold the luns as we open descriptors, 
; this allows us to close all the luns at once if we want
;
; for fits data
common pupfcom,pupfnluns,pupflunar
    pupfnluns=0L
    pupflunar=intarr(100)
; for raw data
common puprcom,puprnluns,puprlunar
    puprnluns=0L
    puprlunar=intarr(100)
;
forward_function pupffilelist,pupffreq,$
      pupfget,pupfgetm,pupfopen

forward_function puprget,puprgetm,pupropen
