;+
;NAME:
;cordfbp - return the digital filter bandpasses.
; 
;SYNTAX: bp=cordfbp(b,force=force)
;
;ARGS:   
;       b: {corget} correlator data to make banpasses for.
;KEYWORDS:   
;   force: if set then force the recomputation of the bandpasses
;          rather than taking them from the common block if they are
;          already there.
;RETURNS :
; bp  : {corget} holds the normalized digital filter bandpasses.
;
;DESCRIPTION:
;   The normalized digital filter bandpasses are returned in a standard
;{corget} data structure. If the input (b) is an array, then only 
;bandpasses for the first element of b are returned. The computed
;bandpasses are stored in a local common block so that repeated calls with the
;same type of data will go faster.
;   50 Mhz bandpasses are returned as all 1's (since there is no digital 
;filtering). 
;   Stokes data returns the digital filter bandpasses for the
;original PolA, polB data rather than I and Q. The last two polarized band
;passes are returned as all 1's. 
;
;EXAMPLE:
;;  Input a data scan and divide each record by the digital filter bandpass.
;;  Note that the digital filter bandpasses are already normalized to unity.
;;
; istat=corinpscan(lun,b,scan=scan)
; dfbp=cordfbp(b)
; bpc=cormath(b,dfbp,/div)
;
; The current filtering scheme seems to be:
;   filter on upconvert - all
;   filter 1 for interpolation after upconvert : double nyquist
;   filter 2 for interpolation after upnconvert: 12.5 Mhz and below
;
;SEE ALSO: dfhbfilter, cormath
;-
;history: 08sep02 started.
function cordfbp,b,force=force 
; 
    common cordfbp,bpdfcom
;    on_error,1
;
;   see if we already have it made.
;
    nbrdsinp=n_tags(b[0])
    nbrdscom=n_tags(bpdfcom)
    bldnew=1
    if keyword_set(force) then goto,donechk
    if (nbrdscom eq nbrdsinp) then begin
        for i=0,nbrdsinp-1 do begin
;
;   number of lags, number of sbc must match
;
            if (b[0].(i).h.cor.lagsbcout ne bpdfcom.(i).h.cor.lagsbcout) or $
               (b[0].(i).h.cor.numsbcout ne bpdfcom.(i).h.cor.numsbcout) then $
                    goto,donechk
;
;   bwnum 2 must match lower bandwidths are the same. 
;
            if  ((   b[0].(i).h.cor.bwNum eq 2) and $
                 (bpdfcom.(i).h.cor.bwNum ne 2)) or $
                ((   b[0].(i).h.cor.bwNum ne 2) and $
                 (bpdfcom.(i).h.cor.bwNum eq 2)) then goto,donechk
;
;   bwnum 1 is must match
;
            if  (b[0].(i).h.cor.bwNum eq 1) and $
                 (bpdfcom.(i).h.cor.bwNum ne 1) then goto,donechk
        endfor
        bldnew=0
    endif
donechk:
    if not bldnew then return, bpdfcom
    bpdfcom=b[0]
    fold=1
    for i=0,nbrdsinp-1 do begin
        nsbc =bpdfcom.(i).h.cor.numsbcout
        bwNum=bpdfcom.(i).h.cor.bwnum
        nlags=bpdfcom.(i).h.cor.lagsbcout
        dnyquist=corhdnyquist(bpdfcom.(i).h)
        flip    =corhflippedh(bpdfcom.(i).h,i+1)
        case 1 of 
        bwNum eq 1: bpdfcom.(i).d[*,0]=fltarr(nlags)+1.
        bwNum eq 2: bpdfcom.(i).d[*,0]=dfhbfilter(nlags,/norm,/two,fold=fold,$
                            /fup,flip=flip)
        else      : begin
            fextra=2
            if dnyquist then fextra=1
            bpdfcom.(i).d[*,0]=dfhbfilter(nlags,/norm,/two,fold=fold,$
                            /fup,fintp=fextra,flip=flip)
            end
        endcase
        if nsbc ge 2 then  begin
            bpdfcom.(i).d[*,1]=bpdfcom.(i).d[*,0]
            if nsbc gt 2 then begin
                bpdfcom.(i).d[*,2]=fltarr(nlags)+1.
                bpdfcom.(i).d[*,3]=fltarr(nlags)+1.
            endif
        endif
    endfor
    return,bpdfcom
end
