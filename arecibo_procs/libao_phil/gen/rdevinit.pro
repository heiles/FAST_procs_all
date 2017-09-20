;+
;NAME:
;rdevinit - initialize to use the pdev radar processor
;SYNTAX: @rdevinit
;DESCRIPTION:
;   call this routine before using any of the rdev idl routines.
;It sets up the path for the idl rdev directory and defines the
;necessary structures.
;-
@geninit
addpath,'pdev'
addpath,'rdev'
@pdev.h
@rdev.h
common rdevcom,rdevnluns,rdevlunar
    rdevnluns=0L
    rdevlunar=intarr(100)

