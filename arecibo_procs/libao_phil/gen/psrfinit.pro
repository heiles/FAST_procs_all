;+
;NAME:
;psrfinit - initialize to use the psrfits  mock spectrometer routines
;SYNTAX: @psrfinit
;DESCRIPTION:
;   call this routine before using any of the psrfits... idl routines.
;It sets up the path for the idl psrfits directory and defines the
;necessary structures.
;-
@geninit
@masinit
addpath,'psrfits'

;
; this has some of jeffs pdev definitions we need
@pdev.h
;
; mainly the fits file definitions
;@mas.h
;
; hold the luns as we open descriptors, 
; this allows us to close all the luns at once if we want
;
common psrfcom,psrfnluns,psrflunar
    psrfnluns=0L
    psrflunar=intarr(100)
;
forward_function psrffilelist,psrffreq,$
      psrfget,psrfgetm,psrfopen,psrffilesum
