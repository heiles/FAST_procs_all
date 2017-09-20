;+
;NAME:
;dopcorbuf - offline doppler correct voltage data
;SYNTAX:bufCor=dopcorbuf(dopI,buf,firstBuf=firstBuf)
;ARGS:
;dopI: {}  structure holding dopper info. initialize
;          with dopcoroflinit(0
;buf[n]:   complexar  data to doppler correct
;KEYWORDS:
;firstBuf:  if true then assume this is the first buf
;           It will reset the buf time to the time of
;           first buf, and set the phase offset to 0.
;remdc   :  if true, then remove dc from voltages before
;           doppler shifting
;RETURNS:
;bufCor[n]: complexarr doppler corrected data
;
;dopI.dopFrq[m]: doppler frequency for m tims
;dopI.dopTms[m]: time for each doppler value
;dopI.tmStpSmp : time step each sample
;  these get updated on each call
;dopI.phoff	: phase off for start of buf
;dopI.tmStBuf  : updated on each call
;
;DESCRIPTION:
; 	Offline doppler correct voltage data. You must
;call dopcorbufinit() before starting to call dopcorbuf().
;	The init routine will store the doppler info, startime
;of 1st buffer, sampletime, and current phase offset.
;
;	Each call to this routine will doppler correct the 
;buffer and increment the start time and phase of the next
;buffer.
;	The sequence should be:
; dopI=dopcorbufinit()
;	loop from first buff
;	 	input next buffer
;		bufC=dopcorbuf(dopI,buf)
;	endloop
;
;	If you want to start over, you could recall dopcorbufinit()
;or call dopcorbuf(...,/firstbuf). /firstbuf will reset the
;current buf time to the time of the first buffer, and 0 the
;accumulated phase.
;-
function dopcorbuf,dopI,buf,firstbuf=firstbuf,remdc=remdc
;
	if keyword_set(firstbuf) then  begin
		dopI.curBufTmU=dopI.bufStTmU
		dopI.phOffRd=0D
	endif
	npnts=n_elements(buf)
;
;   tm value for each sample for interpolation of freq
;
;	tmUBuf=dindgen(npnts)*dopI.smpTmUStep + dopI.curBufTmU
;	frqBuf=interpol(dopI.dopFrq,dopI.dopTmU,tmUBuf)*dopI.smpTmSec
;	phbuf=(total(frqBuf,/cum)*2d*!dpi + dopI.phOffRd ) mod (!dpi*2)
;
	phBuf=(total($
	      interpol(dopI.dopFrqUsed,dopI.dopTmU,$
             dindgen(npnts)*dopI.smpTmUStep + dopI.curBufTmU)* $
	 		 dopI.smpTmSec mod 1d ,/cum)*2d*!dpi + dopI.phOffRd) mod (!dpi*2d)
	if keyword_set(remdc) then begin
		bufC=(buf-mean(buf)) *exp(dcomplex(0D,-phbuf))
	endif else begin
		bufC=buf *exp(dcomplex(0D,-phbuf))
	endelse
;
;	update for next buffer
;
	dopI.phOffRd=phBuf[npnts-1l] mod (!dpi *2d)
	dopI.curBufTmU+=dopI.smpTmUStep * npnts
	return,bufC
end
