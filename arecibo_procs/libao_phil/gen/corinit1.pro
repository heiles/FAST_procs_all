;+
;NAME:
;corinit1 - initialize to use the idl correlator routines (no lut load).
;SYNTAX: @corinit   
;DESCRIPTION:
;   call this routine before using any of the correlator idl routines.
;It sets up the path for the idl correlator directory and defines the
;necessary structures. It calls geninit1 instead of geninit. The color
;table ldcolph call is not made. This speeds things up for remote observers.
;-
@geninit1
@hdrCor.h
@hdrMueller.h
addpath,'Cor2'
; @procfileinit
.compile corhquery
.compile dophquery
.compile pnthquery
.compile iflohquery
addpath,'Cor2/cormap'
;.compile corgethdr
;.compile corget
;.compile corwaitgrp
;.compile corlist
;.compile corfrq
;.compile corpwr
;.compile corhan
;.compile corplot
;.compile cornext
;.compile corloopinit
;.compile corloop
;.compile corwaitgrp
;.compile cormon
forward_function corget,chkcalonoff,corallocstr,coravgint,corcalonoff,$
        corcalonoffm,corfrq,corgethdr,corgetm,corimg,corinpscan,$
        cormedian,corposonoff,corposonoffm,corpwr,corpwrfile,corrms,$
        mmget ,cormapsclk,corhgainget
