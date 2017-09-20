;+
;NAME:
;spwrinit - initialize to use the site power idl  routines.
;SYNTAX: @corinit   
;DESCRIPTION:
;   call this routine before using any of the site power idl routines.
;It sets up the path for the idl spwr directory and defines the
;necessary structures.
;-
@geninit
addpath,'spwr'
@spwr.h
forward_function spwrget

