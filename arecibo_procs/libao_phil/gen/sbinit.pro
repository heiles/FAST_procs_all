;+
;NAME:
;sbinit - initialize to use the sband tx idl routines
;SYNTAX: @sbinit
;DESCRIPTION:
;   call this routine before using any of the sb... idl routines.
;It sets up the path for the idl sband directory and defines the
;necessary structures.
;-
@geninit
addpath,'sb'
; struct definitions
@sb.h
