;+
;NAME:
;corgetm - input multiple correlator records to array.
;SYNTAX: istat=corgetm(lun,ngrps,bb,scan=scan,sl=sl,han=han,noscale=noscale,$
;                      check=check) 
;ARGS:
;        lun:   int open file to read
;KEYWORDS:
;       scan: long if provided, position to scan before reading.
;       sl[]: {sl} returned from getsl(). If provided then direct access
;                  to scan is provided.
;        han: if set then hanning smooth
;    noscale: if set, then do not scale each sub correlator to the
;               9level corrected 0 lag.
;    check  : if set, then verify that the records are compatible to store
;             in a single record.
;RETURNS:
;        bb[]:{corget}   array of corget structures that were read in
;       istat:          1 got all of the groups requested.
;                       0 did not get all of the groups requested.
;DESCRIPTION:
;   Read ngrp consecutive correlator records from disc and return them
;in bb (an array of {corget} structures). The routine will read from the
;current position on disc (after optional positioning to scan). It will 
;read across scan number boundaries if needed.
;- 
;history:
;31jun00 updated to new corget struct
function corgetm,lun,ngrps,bb,scan=scan,sl=sl,han=han,noscale=noscale,$
                _extra=e,check=check
;
    on_error,2
    grp=0
    if  keyword_set(scan) then begin
        if keyword_set(sl) then begin
           istat=posscan(lun,scan,1,sl=sl)
        endif else begin
           istat=posscan(lun,scan,1)
        endelse
        if istat ne 1 then begin
            print,'Position error to scan:',scan
            goto,errinp
        endif
    endif
    if not keyword_set(han)     then han=0
    if not keyword_set(noscale) then noscale=0
    istat=corget(lun,b,han=han,noscale=noscale,_extra=e)
    if istat ne 1 then goto,errinp
    nbrds=b.(0).h.cor.numbrdsused
    bb=corallocstr(b,ngrps)
    bb[0]=b
    grp=grp+1
    for i=1,ngrps-1 do begin
        istat=corget(lun,b,han=han,noscale=noscale,_extra=e)
        if istat ne 1  then goto,errinp
        if keyword_set(check) then begin
            if corchkstr(b,bb[0]) eq 0 then goto,errinp
        endif
        corstostr,b,i,bb
        grp=grp+1
    endfor
    return,1
errinp:
    if (grp eq 0) then begin
        bb=""
    endif else begin
        if grp ne ngrps then begin
            bb=bb[0:grp-1]
        endif
    endelse
    return,0
end
