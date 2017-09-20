;+
;NAME:
;masfreqdesc - return freq array for a spectra given the descriptor
;SYNTAX: freqAr=masfreqdesc(desc,skycfr=skycfr,lo2offset=lo2offset,
;						lenfft=lenfft)
;ARGS:
;    desc: {} returned by pdevopen
;KEYWORDS: 
;     skycfr: double sky cfr of band
;  lo2Offset: double offset lo2 from center of band. default: bw/2.
;   lenfft  : long   if timedomain data, then specify the len of the fft
;DESCRIPTION:
; 	This is an old routine prior to the fits header having the correct
;frequency info. Now you should use masfreq(hdr).
;
;RETURNS:
;     freqAr[]:  frequency array in Mhz for the points in the spectra
;-
; history: 
; 25sep07 if addclk /adcfrq differ by more than 2%, issue warning,
;         and use adcfrq
; 13feb08 lo2 mixing is complex, it does not flip the band
function masfreqdesc,desc,skycfr=skycfr,lo2offset=lo2offset,lenfft=lenfft
;
;   optionally position to start of rec
;
    lenFft=long(desc.hsp1.fftlen)
;
;   2nd mixing stage is not flipping the lo's
;
    lo2flip=1.
    dec=(desc.hsp1.hrmode eq 0)?1.:(desc.hsp1.hrdec*1.)
    if (abs(1.*desc.hmain.adcf/desc.hmain.adcclk - 1.) gt .01)  then begin
        print,$
'hdr adcfrq/adcclk differ> 1%. using measured adcfrq'
    adcF=desc.hmain.adcf;
    endif else begin
          adcF=desc.hmain.adcclk
    endelse
    
            
    bw=adcF*1e-6/dec
    binWd = bw/lenFft
    cenChan=lenFft/2

;   if skycfr specified.. if flipped cenChan--

    if keyword_set(skycfr) then begin
        lo1flip=-1.
        lo2offset=(keyword_set(lo2offset))?lo2Offset:bw/2.
        x=(findgen(lenFft)-cenChan)*(binWd*lo1flip)*lo2flip  + $
                 skyCfr + (lo2offset*lo1flip)
    endif else begin
;
;   just if band don't bother flipping
;
        if n_elements(lo2offset) gt 0  then begin
            off=lo2offset
        endif else begin
        off= (( desc.hmain.subband eq 0) and (desc.hmain.lo2mix0 ne 0)) ? $
                desc.hmain.lo2mix0                                     : $
               (( desc.hmain.subband eq 1) and (desc.hmain.lo2mix1 ne 0)) ? $
                  desc.hmain.lo2mix1                                     : $
                  0.

        endelse
        x=(findgen(lenFft)-cenChan)*(binWd) + off*1e-6
    endelse
    if (desc.hsp1.chndump1 ne 0) or $
         (desc.hsp1.chndump2 ne (desc.hsp1.fftlen-1)) then $
            x=x[desc.hsp1.chndump1:desc.hsp1.chndump2]
    return,x
end
