;+
;NAME:
;cgeninit - initialize to use cummings generator routines
;SYNTAX: @cgeninit
;DESCRIPTION:
;   call this routine before using any of the cgen routines to
;access the cummings generator datafiles.
;-

@geninit
addpath,'cgen'
@cgen.h
