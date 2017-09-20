;+
;NAME:
;avgrms - avgerage then compute rms for data set
;SYNTAX: avgrms,toAvg,d,rmsAr,allen=allen
;ARGS:
; toAvg[navg]: long  samples to average before computing rms.
;                   If i, greater than 1 then the rms will be computed
;                   on each dataset.
;  d[m,ncol]:float  average along m and then compute rms. Do this for each ncol
;KEYWORDS:
;   allen:          if set then return the allen deviation rather than
;                   the standard deviation. 
;                   it is y[i]=sqrt(.5*mean((d[i]-d[i+1])^2))
;                   where d[x] has first been averaged by toavg[i].
;RETURNS:
;  rmsAr[navg,ncol]:float  return rms info for each dataset
;DESCRIPTION:
;   Average the first index of d and then compute the rms. Do this for
;all ncol. If the keyword /allen is set then the sqrt of the allen variance
; is computed rather than the standard deviation.
;   ToAvg determines the number of adjacent samples to average before
;computing the deviation. If toavg is an array then the deviation will
;be computed for each set of averages.
;   The info is returned in rmsAr[navg,ncol] where navg is the number of
; entries in toavg[]. 
;   This routine can be used to check if the rms noise decreases as
;1/sqrt(bw*time). To do this, you should normalize the input data to
; the mean (or median) value of each column
; (since it is DeltAT/T=1./sqrt(b*tau)).
;
;-
pro avgrms,toavgAr,d,rmsAr,allen=allen
;
; compute the regular rms at the integration times they requested
;
;
    ndatapnts=n_elements(d[*,0])
    ntoavg=n_elements(toavgAr)
    ncol=1
    a=size(d)
    if a[0] eq 2 then ncol=a[2]
    rmsAr=fltarr(ntoavg,ncol)  ;
    if ~ keyword_set(allen) then begin
        for iavg=0,ntoavg-1 do begin &$
             toAvg=toAvgAr[iavg] &$
             npntsA=(ndatapnts/toavg)&$      ; after averagin
             npntsB=npntsA*toavg &$          ; before averaging , multiple toavg
             for icol=0,ncol-1 do begin
                aa=rms(total(reform(d[0:npntsB-1,icol],toavg,npntsA),1)/toavg,$
                            /quiet) &$
                rmsAr[iavg,icol]=aa[1] &$
             endfor
         endfor
    endif else begin
; -----------------
; try the allen variance
;
    for iavg=0,ntoavg-1 do begin &$
        toAvg=toAvgAr[iavg] &$
        npntsA=(ndatapnts/toavg)&$      ; after averagin
        npntsB=npntsA*toavg &$          ; before averaging , multiple toavg
        ii=lindgen(npntsA/2)*2      ; every other point after average
        a=total(reform(d[0:npntsB-1,*],toavg,npntsA,ncol),1,/double)/toavg &$
        for icol=0,ncol-1 do begin
            rmsAr[iavg,icol]=mean((a[ii,icol]-a[ii+1,icol])^2)*.5 &$
        endfor
    endfor
    rmsAr=sqrt(rmsAr)
endelse
return
end
