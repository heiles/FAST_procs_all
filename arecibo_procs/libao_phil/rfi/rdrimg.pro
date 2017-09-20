;+
;NAME:
;rdrimg - make an image from a radar time series.
;SYNTAX: img=rdrimg,d,smptosue,ipps,ipptot,first=first
;ARGS:
;    d[npts]: float  radar total power time series
;   smptouse: long   number samples in each ipp to plot starting from first
;ipps[nipps]: long   ipp length in ipps for each ipp.
;     ipptot: double the sum of ipps[] with any measured fractional values.
;KEYWORDS:
; 
;      first: long    index first sample to plot (def 0)
;DESCRIPTION:
;   Make a image of a radar dataset. The left side of the image will
;be at the same phase of the radar ipp. Take a subset of the points
;(smptouse) for each row. Use ipptot to move from one set of ipps to the
;next. With a set use the individual ipps to move from 1 ipp to the next.
;When specifying first be careful the first ipp found is the first one in
;ipps[].
;
;EXAMPLE:
;   findrdripp,d,minipp,maxipp,10,radonminval,ipps,offset
;; compute eps fractional offset by looking farther down in the dataset.
;   ipptot=total(ipps)
;   ipptouse=ipptot + eps 
;   smptouse=800
;   img=rdrimg(d,smptouse,ipps,ipptotuse,first=30)
;   imgdisp,img,zy=-5
;-
;
function rdrimg,d,smptouse,ipps,ipptot,first=first
;
;  
    if not keyword_set(first) then first=0
    npts    =n_elements(d)
    nipps   =n_elements(ipps)
    nipptot =long(npts/ipptot)
    nrows   = nipptot*nipps
    img  = fltarr(smptouse,nrows)
    for  i=0,nipptot-1 do begin
        k=first+long(i*ipptot)
        for j=0,nipps-1 do begin
            img[*,i*nipps+j]=d[k:k+smptouse-1]
            k=k+ipps[j]
        endfor
    endfor
    return,img
end
