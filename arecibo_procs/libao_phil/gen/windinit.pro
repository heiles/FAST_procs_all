;+
;NAME:
;windinit - initialize idl to process wind monitoring data.
;SYNTAX: @windinit
;ARGS:   none 
;DESCRIPION:
;   Initialize to process wind data.
;-
;
;
addpath,'wind'
@geninit
@wind.h
