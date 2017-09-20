;+
;NAME:
;puprinit - initialize to use the puppi raw file routines
;SYNTAX: @puprinit
;DESCRIPTION:
;   call this routine before using any of the pupr (puppi_*.raw)...
;  idl routines.
;It sets up the path for the idl pupr directory and defines the
;necessary structures.
;-
@geninit
@masinit
addpath,'pupr'

;
; hold the luns as we open descriptors, 
; this allows us to close all the luns at once if we want
;
common puprcom,puprnluns,puprlunar
    puprnluns=0L
    puprlunar=intarr(100)
;
forward_function puprget,puprgetm,pupropen
