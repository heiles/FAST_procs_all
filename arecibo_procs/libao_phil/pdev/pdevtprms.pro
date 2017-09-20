;+
;NAME:
;devtprms - compute rms on total power array
;SYNTAX: pdevtprms,toAvg,tp,,rmsAr,allen=allen
;ARGS:
; toAvg[n]: long    samples to average before computing rms.
;                   If n, greater than 1 then the rms will be computed
;                   on each dataset.
;  tp[m,2]:float   total power data low band. 2nd index is pola,b
;KEYWORDS:
;   allen:          if set then return the allen deviation rather than
;                   the standard deviation. 
;                   it is y[i]=sqrt(.5*mean((tp[i]-tp[i+1])^2))
;RETURNS:
;  rmsAr[n,4]:float  return rms info for low band
;DESCRIPTION:
;   Compute the rms deviation of a set of total power noise samples. If the
;keyword /allen is set then the sqrt of the allen variance is computed rather
;than the standard deviation.
;   toAvg determines the number of adjacent samples to average before
;computing the deviation. If toavg is an array then the deviation will
;be computed for each set of averages.
;   The info is returned in rmsAr[n,4] where n is the number of entries in
;toavg[n]. The 4 entries for each average contains:
;
;   rmsAr[n,0] - rms for tp polA
;   rmsAr[n,1] - rms for tp polB
;   rmsAr[n,2] - pnts averaged before rms computed.
;   rmsAr[n,3] - pnts available for rms after averaging
;-
pro pdevtprms,toavgar,tp,rmsAr,allen=allen
;
; compute the regular rms at the integration times they requested
;
;
npnts=n_elements(tp[*,0])
nsteps=n_elements(toavgAr)
rmsAr=fltarr(nsteps,4)         ; 0,1 rmsA,b, intTm 3rd, number samples4)
if ~ keyword_set(allen) then begin
for i=0,nsteps-1 do begin &$
    toAvg=toAvgAr[i] &$
    npntsA=(npnts/toavg)&$      ; after averagin
    npntsB=npntsA*toavg &$          ; before averaging , multiple toavg
    rmsAr[i,2]=toAvg &$
    rmsAr[i,3]=npntsA &$
;
    aaA=rms(total(reform(tp[0:npntsB-1,0],toavg,npntsA),1)/toavg,/quiet) &$
    aaB=rms(total(reform(tp[0:npntsB-1,1],toavg,npntsA),1)/toavg,/quiet) &$
    rmsAr[i,0]=aaA[1] &$
    rmsAr[i,1]=aaB[1] &$
endfor
endif else begin
; -----------------
; try the allen variance
;
for i=0,nsteps-1 do begin &$
    toAvg=toAvgAr[i] &$
    npntsA=(npnts/toavg)&$      ; after averagin
    npntsB=npntsA*toavg &$          ; before averaging , multiple toavg
    rmsAr[i,2]=toAvg &$
    rmsAr[i,3]=npntsA/2 &$
    ii=lindgen(npntsA/2)*2 &$
;
    a=total(reform(tp[0:npntsB-1,0],toavg,npntsA),1,/double)/toavg &$
;    print,rms(a) &$
    rmsAr[i,0]=mean((a[ii]-a[ii+1])^2)*.5 &$
;
    a=total(reform(tp[0:npntsB-1,1],toavg,npntsA),1,/double)/toavg &$
    rmsAr[i,1]=mean((a[ii]-a[ii+1])^2)*.5 &$
;
endfor
rmsAr[*,0]=sqrt(rmsAr[*,0])
rmsAr[*,1]=sqrt(rmsAr[*,1])
endelse
return
end
