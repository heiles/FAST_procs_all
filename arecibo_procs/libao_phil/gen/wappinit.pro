;+
;NAME:
;wappinit - initialize to use the idl wapp pulsar routines.
;SYNTAX: @wappinit   
;DESCRIPTION:
;   call this routine before using any of the wapp idl routines.
;It sets up the path for the idl wapp directory and defines the
;necessary structures.
;-
@geninit
@hdrWapp.h
addpath,'wapp'
forward_function wappget,wappgethdr,wappfrq,wappgetfileinfo,wappgetfiproj,$
        wappgetfilist,wappgethdr,wappmonimg,wappmonimgp,warch_gettbl,$
        wappfilesizei
