;+
;NAME:
;wst - initialize to use idl weather station routines
;SYNTAX: @wst
;DESCRIPTION:
;   call this routine before using any of the wst... orion weatherstation
;idl routines. 
;This routine sets up the path for the idl wst directory and defines the
;necessary structures.
;-
@geninit
addpath,'wst'
;
@wst.h
;
;forward_function masavg,masavgmb,masfilelist,masfilesum,masfreq,masfreqdesc,$
;      masget,masgetm,masgetstat,masopen,masrdrsat,masmostrecentfile
