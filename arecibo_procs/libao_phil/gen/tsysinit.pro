;+
;NAME:
;tsysinit - initialize idl to process system temperature monitoring data.
;SYNTAX: @tsysinit
;ARGS:   none 
;DESCRIPION:
;   Initialize to process tsys data taken daily with the tsysall program
;online.
;-
;
;
addpath,'tsys'
@geninit
@tsys.h
