;+
;calpos - calibrate position info
; SYNTAX: calpos,filename,ld,tm,coefpot,difpos,coeftm,diftm,ecPiToDac,
;			pnt1=pnt1,pnt2=pnt2
;ARGS:
;		filename:	string .. to input
;		ld[npts]:   {terlog} input data
;		tm[npts]:   float   tm in seconds
;		coefPot[3,5]  2nd order fit to pot
;		diffpot[npts,5]  enc-fit to encoder vs pot
;		coeftm [2,5]  1st order encPos to tm
;		diftm   [npts,5]  fit to pos vs time
;		ecPiToDa[5]   dacCnts for 1 encCnt Per interval
;KEYWORDS:
;	pnt1		long	first point to use. count from 0. def 0
;	pnt2		long	last pnt to use. default npts-1
;
;DESCRIPTION:
;	Given data at constant dac value, fit pot to encoder (2nd order)
;Also fit encoder vs time to see linearity in encoder (or dac stability)
;return data-fit. also compute conversion enc/intvl to dac counts.
; 	Fit pot to encoder counts (2nd order).
; use old log version (pre 19nov00)
;-
pro calpos0,filename,ld,tm,coefpot,difpos,coeftm,diftm,ecPiToDac,$
		pnt1=pnt1,pnt2=pnt2
   
	openr,lun,filename,/get_lun
	maxpnts=70000L
	intvlPerSec=200.
	rew,lun
	ld=terloginp0(lun,maxpnts)
	free_lun,lun
	npts=(size(ld))[1]
	ind1=0L
	ind2=npts-1
	if n_elements(pnt1) gt 0 then ind1=pnt1
	if n_elements(pnt2) gt 0 then ind2=pnt2
	if ind2+1L gt npts then ind2=npts-1L
	ld=ld[ind1:ind2]
	tm=(ld.tmMs-ld[0].tmMs) * .001
	npts=(size(ld))[1]
	dac=total(ld.velcmd,2)/(npts*1.)
;
;	 fit encoder vs pot
;
	ndeg=2
	coefpot=dblarr(ndeg+1,5)
	difpos=fltarr(npts,5)
	for i=0,4 do begin &$
		coefpot[*,i]=poly_fit(ld.pot[i],ld.enccur[i],ndeg,fit) &$
		difpos[*,i]=ld.enccur[i]-fit &$
	endfor
;
; fit velocity compare with dac values to get enccnts/dac cnt
;
	ndegtm=1
	coeftm=dblarr(ndeg+1,5)
	diftm  =fltarr(npts,5)
	for i=0,4 do begin &$
    	coeftm[*,i]=poly_fit(tm,ld.enccur[i],ndeg,fit) &$
    	diftm[*,i]=ld.enccur[i]-fit &$
	endfor
	ecPitoDac =1./ (coeftm[1,*]/intvlPerSec/dac)
    return;
end
