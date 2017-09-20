;+
;NAME:
;corinit - initialize to use the idl correlator routines.
;SYNTAX: @corinit   
;DESCRIPTION:
;   call this routine before using any of the correlator idl routines.
;It sets up the path for the idl correlator directory and defines the
;necessary structures.
;-
@geninit
@hdrCor.h
@hdrMueller.h
addpath,'df'
addpath,'Cor2'
; @procfileinit
.compile corhquery
.compile corhflippedh
;.compile corblauto
; 05jul02 moved to geninit
;.compile dophquery
;.compile pnthquery
;.compile iflohquery
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
;;.compile corloop
;.compile corwaitgrp
;.compile cormon
;forward_function corget,chkcalonoff,corallocstr,coravgint,corcalonoff,$
;        corcalonoffm,corfrq,corgethdr,corgetm,corimg,corinpscan,$
;        cormedian,corposonoff,corposonoffm,corpwr,corpwrfile,corrms,$
;        mmget ,cormapsclk,corhgainget,corhstate,cordfbp
; 07jul08.. put all functions (that are used) in foward_function line

forward_function arch_getdata,arch_getmap,arch_getmapinfo,arch_getonoff,$
 	arch_gettbl,arch_openfile,chkcalonoff,coracf,corallocstr,coravg,$
	coravgint,corbl,corblautoeval,corcalcmp,corcalib,corcalonoff,$
	corcalonoffm,corchkstr,corcmbsav,corcmpdist,corcumfilter,$
	cordfbp,corfindpat,corfrq,corget,corgethdr,corgetm,corimg,$
	corimgdisp,corimgonoff,corinpscan,corinterprfi,cormaskmk,$
	cormath,cormedian,coronl,corposonoff,corposonoffm,corposonoffrfi,$
	corposonoffrfisep,corpwr,corpwrfile,corradecj,corrms,corsavbysrc,$
	corstat,corstokes,corsubset,cortblradius,cortpcaltog,corwriteascii,$
	mm_chkpattern,mmcmpmatrix,mmcmpsefd,mmfindpattern,mmget,mmgetarchive,$
	mmgetparams,mmtostr,pfcalib,pfcalonoff,pfcorimgonoff,pfposonoff,$
	pfposonoffrfi,sl_mkarchive,sl_mkarchivecor,wascheck

