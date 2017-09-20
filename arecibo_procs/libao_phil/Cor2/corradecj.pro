;+
;NAME:
;corradecj - get ra,dec J2000 positions
;SYNTAX:  npnts=corradecj(bscan,raHrJ,decDegJ)
;ARGS:      
; bscan[n]: {corget}  get ra,dec positions for this scans data
;KEYWORDS:
;RETURNS:
;   RAHRJ[N]: double ra  J2000 in hours for records in scan
; decDegI[N]: double dec J2000 in degrees for records in scan
;
;DESCRIPTION:
;   Take the requested ra/dec positions from the header and interpolate
;them to the center of the data samples. If bscan only has a single
;record then no interpolation is done.
;
;NOTE: If the data was taken with a mapping routine ;(cormap,cordrift,
; etc) you should probably use cormapinp().
;-
;
function corradecj,bscan,raHr,decD
;   
;   on_error,2
;
    radegD=180D/!dpi
    nrecs=n_elements(bscan)
    if nrecs eq 1 then begin
        raHr=b.b1.h.pnt.r.raJcumRd*radegD/15d
        decD=b.b1.h.pnt.r.decJcumRd*radegD
        return,1
    endif
    blankingOn=ishft(bscan[0].b1.h.cor.state , -2 ) and '1'XL
    raHr =bscan.b1.h.pnt.r.raJcumRd*radegD/15d      ; requested ra
    decD=bscan.b1.h.pnt.r.decJcumRd*radegD          ; requested dec
    tmPnt=bscan.b1.h.pnt.r.secMid*1D                ; time stamp of req
    startData=bscan[0].b1.h.std.stscantime*1D       ; start data
;
;   get time step each data point
;
    if blankingOn then begin
        tmStep=(bscan[nrecs-1].b1.h.std.time - (bscan[0].b1.h.std.time))/(nrecs-1d)
    endif else begin
        tmStep=corhintrec(bscan[0].b1.h)*1D
    endelse
    tmData = (dindgen(nrecs)+.5)*(tmStep) + startData
;
;   When interpolating time, be careful with midnite crossing, 
;   find jump and add 1 day
;
    dif=tmPnt-shift(tmPnt,1)
    ii=where(dif[1:*] lt -43200L,count)
    if count gt 0 then begin
         ii=ii+1         ; inc since we started dif[1:]
         tmPnt[i1[0]:*]= tmPnt[i1[0]:*] + 86400D
     endif
    dif=tmData-shift(tmData,1)
    ii=where(dif[1:*] lt -43200L,count)
    if count gt 0 then begin
         ii=ii+1         ; inc since we started dif[1:]
         tmData[i1[0]:*]= tmData[i1[0]:*] + 86400D
     endif
;
;     when interpolating ra, we can cross 0 hours ra..
;     - find median value ra,
;     - find all of the data points 12 hours away from this.. 
;     - add or sub 24 hours to make them contiguous
;
    raMed=median(raHr)
    ind=where((raHr - raMed) gt 12.,count)
    if count gt 0 then raHr[ind]=raHr[ind]-24D
    ind=where((raHr - raMed) lt -12.,count)
    if count gt 0 then raHr[ind]=raHr[ind]+24D
;
;   now interpolate the ra,dec to the center of the data samples
;
    raHr=interpol(raHr,tmPnt,tmData)
    decD=interpol(decD,tmPnt,tmData)
    return,nrecs
end
