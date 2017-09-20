;+
;NAME:
;shsclpchkipp - see if this is clp ipp
;SYNTAX: istat=shsclpchkipp(txbuf,smpUsec=smpUsec,codeUsec=codeUsec,$
;				corRatio=corRatio)
;ARGS:
;txbuf[2,N]: short   tx buffer i,q n samples
;KEYWORDS:
;smpUsec   : float   sample rate in usecs (def=.2 usecs)
;codeUsec  : float   codelength in usecs (def=440 usecs)
;
;RETURNS:
;istat[n]  : 1 - is a ipp
;            0   not a clp ipp
;            one for each tx buf passed in
;corRatio  :  float  acf of txbuf . 0..1
;DESCRIPTION:
;  Check to see if this ipp is a clp ipp by looking at the power across the
;transmitter pulse
; values used:
;
;  midipp: 150.. must have power .. gets rid of power profile which may have
;                                   echo at 440,500
;  power : 52 usecs
;  clpipp: 440. 
;  topSid: 500 usecs
;  mracf : 300 usecs
;  txSmpDelayUsecs .. usually about 5.6 usecs
;  slopEnd : 5 usecs; .. move this far back from falling  edge of pulse before average start
;  avgSmpls:100= 20 secs
;  make sure power at 440 - 6 usecs
;  acf:
;  - compute acf for lags 0 .. 50  (0 to 10 usecs)
;  - avg lags 20-50 ( 4 to 10 usecs)
;  - normalize to 0 lag
;    make sure correlation is less than acfLim (.4)
;  - this gets rid of topsid.. so i'll remove the topside  limits
;  -  mracf, pwr, clp all have low correlation
;  
;-
function  shsclpchkipp,txbuf,smpUsec=smpUsec,codeUsec=codeUsec,verb=verb,$
			corRatio=corRatio

	if n_elements(smpUsec) eq 0 then smpUsec=.2
	if n_elements(codeUsec) eq 0 then codeUsec=440.
	if n_elements(verb) eq 0 then verb=0
;
	corThreshold=.4            ;   // topside is  .98 to 1
    slopEndUsec=5.             ;   // finish avg 5 usecs before end of code
    midIppUsec=150.            ;
    topSideCodeUsec=500.;
    txSkipUsecs=5.57;          ; //delay for tx to come up .. looked at data  
    smpToAvg=100;              ; // avg 100 samples
	txSmpRead=n_elements(txBuf[0,*])


;//   had 40000. increase since pwr,mracf can have return from 75 km 
;//   and may look like clp
	txMinPwr=1.5e6
    minVal= txMinPwr;
    nlags=50
;	// average over these.. 4 usecs to 10 usecs
	ilag1=20
	ilag2=nlags -1
    a=reform(complex(txbuf[0,*],txbuf[1,*]))
    ac=conj(a)
	; samples we compute over
    i0=long(txSkipUsecs/smpUsec) ; skip begining of tx pulse and end
    touse=long((codeUsec - slopEndUsec)/smpUsec - nlags )
    ac=ac[i0:i0+touse-1]         ; this one is not shifted
    xcor=fltarr(nlags)
    for i=0,nlags-1 do begin &$
   		i1=i0+touse-1 &$
        xcor[i]=abs(total(a[i0:i1] * ac))^2 &$
        i0++ &$
    endfor 
    corRatio=median(xcor[ilag1:ilag2])/xcor[0]
    nocor= corRatio lt corThreshold


;  for end of codes move avg back 5 usecs from end of code

    imid  =(long((midIppUsec + txSkipUsecs )/smpUsec) - smpToAvg/2)
    iclp  =(long((codeUsec   + txSkipUsecs - slopEndUsec)/smpUsec) - smpToAvg/2)
;    itpsd =(long((topSideCodeUsec   + txSkipUsecs - slopEndUsec)/smpUsec) - smpToAvg/2)
;    if (itpsd  ge txSmpRead) then begin
;        print,"chkclpipp: not enough txSamples to check for topSide ipp"
;        return,0  
;    endif
	pwrTxBuf=reform(txBuf[0,*]*1.*txBuf[0,*] + txBuf[1,*]*1.*txBuf[1,*])
    pwrMid =total(pwrtxBuf[imid:imid+smpToAvg-1])/smpToAvg
    pwrClp =total(pwrtxBuf[iclp:iclp+smpToAvg-1])/smpToAvg
;    pwrTpsd=total(pwrtxBuf[itpsd:itpsd+smpToAvg-1])/smpToAvg
	if (verb) then begin
 print,format='("iclp:",i4," Vclp:",4e10.3," corRatio:",f5.2)',$
            iclp,pwrtxBuf[iclp:iclp+3],corRatio
            
	endif
    return,(pwrClp gt minVal) and (pwrMid gt minVal) and (nocor)
end
