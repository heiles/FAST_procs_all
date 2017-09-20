;+
;NAME:
;pupfinit - initialize to use the pupfits  mock spectrometer routines
;SYNTAX: @pupfinit
;DESCRIPTION:
;   call this routine before using any of the pupfits... idl routines.
;It sets up the path for the idl pupfits directory and defines the
;necessary structures.
;-
@geninit
@masinit
addpath,'pupf'

;
; this has some of jeffs pdev definitions we need
;
; mainly the fits file definitions
;@mas.h
;
; hold the luns as we open descriptors, 
; this allows us to close all the luns at once if we want
;
common pupfcom,pupfnluns,pupflunar
    pupfnluns=0L
    pupflunar=intarr(100)
;
forward_function pupffilelist,pupffreq,$
      pupfget,pupfgetm,pupfopen
