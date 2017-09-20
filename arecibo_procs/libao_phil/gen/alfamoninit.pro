;+
;NAME:
;alfamoninit - initialize to alfa dewar monitor routines
;SYNTAX: @corinit
;DESCRIPTION:
;   call this routine before using any of the alfa deware monitor (amxxx)
; idl routines.
;It sets up the path for the idl alfamon directory and defines the
;necessary structures.
;-

@geninit
addpath,'alfamon'
@alfamon.h
