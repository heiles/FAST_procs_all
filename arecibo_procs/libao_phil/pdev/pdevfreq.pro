;+
;NAME:
;pdevfreq - return freq array for a spectra
;SYNTAX: freqAr=pdevfreq(desc,skycfr=skycfr,lo2offset=lo2offset,lenfft=lenfft,$
;                        double=double)
;ARGS:
;    desc: {} returned by pdevopen
;KEYWORDS: 
;     skycfr: double sky cfr of band
;  lo2Offset: double offset lo2 from center of band. default: bw/2.
;   lenfft  : long   if timedomain data, then specify the len of the fft
;  double   :        if true make sure double
;
;RETURNS:
;     freqAr[]:  frequency array in Mhz for the points in the spectra
;Description:
;  After aug11, program uses info from desc.hao ao header to determin
;the freq. prior to that it has to guess (or you can enter the 
;skycfr,lo2offset values).
;-
; history: 
; 25sep07 if addclk /adcfrq differ by more than 2%, issue warning,
;         and use adcfrq
; 13feb08 lo2 mixing is complex, it does not flip the band
function pdevfreq,desc,skycfr=skycfr,lo2offset=lo2offset,lenfft=lenfft,$
				double=double
;
;   optionally position to start of rec
;
    if keyword_set(desc.tmd)  then begin
        if n_elements(lenfft) eq 0 then begin
            print,"You must specify lenfft for time domain data"
            return,0
        endif
    endif else begin
        lenFft=long(desc.hsp.fftlen)
    endelse
	scl=(keyword_set(double))?1d:1.
;
; 	if desc.hao present, use it..
;
	if (desc.hao.hdrver ne '') then begin
		flip=(desc.hao.bandincrfreq eq 1)?scl:-scl
		if (keyword_set(double)) then begin
		freq=(dindgen(lenfft)/lenfft - .5d)*desc.hao.bandwdhz*(1d-6*flip) + $
				desc.hao.cfrHz*1d-6
		endif else begin
		freq=(findgen(lenfft)/lenfft - .5*scl)*desc.hao.bandwdhz*(1e-6*flip) + $
				desc.hao.cfrHz*scl*1e-6
		endelse
		return,freq
	endif
;
;   2nd mixing stage is not flipping the lo's
;
    lo2flip=1.*scl
    dec=(desc.hsp.hrmode eq 0)?scl:(desc.hsp.hrdec*scl)
    if (abs(scl*desc.hdev.adcf/desc.hdev.adcclk - scl) gt .01)  then begin
        print,$
'hdr adcfrq/adcclk differ> 1%. using measured adcfrq'
    adcF=desc.hdev.adcf;
    endif else begin
          adcF=desc.hdev.adcclk
    endelse
    
            
    bw=(adcF*scl)*1e-6/dec
    binWd = bw/lenFft
    cenChan=lenFft/2

;   if skycfr specified.. if flipped cenChan--

    if keyword_set(skycfr) then begin
        lo1flip=-scl
        lo2offset=(n_elements(lo2offset) gt 0)?lo2Offset*scl:bw/2.
		if keyword_set(double) then begin
       	     x=(dindgen(lenFft)-cenChan*scl)*(binWd*lo1flip)*lo2flip  + $
                 skyCfr*scl + (lo2offset*lo1flip)
		endif else begin
       	 	x=(findgen(lenFft)-cenChan*scl)*(binWd*lo1flip)*lo2flip  + $
                 skyCfr + (lo2offset*lo1flip)
		endelse
    endif else begin
;
;   just if band don't bother flipping
;
        if n_elements(lo2offset) gt 0  then begin
            off=lo2offset*scl
        endif else begin
        off= (( desc.hdev.subband eq 0) and (desc.hdev.lo2mix0 ne 0)) ? $
                desc.hdev.lo2mix0*scl                                 : $
               (( desc.hdev.subband eq 1) and (desc.hdev.lo2mix1 ne 0)) ? $
                  desc.hdev.lo2mix1*scl                                : $
                  0.*scl

        endelse
		if keyword_set(double) then begin
        	x=(dindgen(lenFft)-cenChan*scl)*(binWd) + off*1d-6
		endif else begin
        	x=(findgen(lenFft)-cenChan)*(binWd) + off*1e-6
		endelse
    endelse
    if (desc.tmd eq 0) then begin
        if (desc.hsp.chndump1 ne 0) or $
         (desc.hsp.chndump2 ne (desc.hsp.fftlen-1)) then $
            x=x[desc.hsp.chndump1:desc.hsp.chndump2]
    endif
    return,x
end
