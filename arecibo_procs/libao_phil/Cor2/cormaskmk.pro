;+
;NAME:
;cormaskmk - create the cormask structure from the corget structure
; 
;SYNTAX: cmask=cormaskmk(b,edgefract=edgefract,ones=ones,raw=raw)
;
;ARGS:   
;    b[n]: {corget} correlator data
;KEYWORDS:   
;   edgefract[1or2]: float . if provided then create a mask ignoring
;                    lagsPerSbc*edgefract lags on each edge of the bandpass. 
;                    if edgefract has two entries then use
;                    edgefract[0] for the left and edgefract[1] for the right.
;    ones:           if set and edgefraction not supplied, return the
;                    mask filled with ones rather than zero.
;    raw:            if the raw keyword is supplied, return a mask with
;                    1 brd, 1 pol of raw pnts.
;                     
;RETURNS :
; cmask  : {cormask} structure holding a zeroed mask for each board
;                    if edgefract was supplied then the values inside
;                    the edgefraction will be set to 1.
;DESCRIPTION:
;   create a cormask structure from the corget data structure.
;The mask structure contains float arrays:
;   cmask.b1[lensbc1,npol1]
;   cmask.b2[lensbc2,npol2]
;   cmask.b3[lensbc3,npol3]
;   cmask.b4[lensbc4,npol4]
;
;The arrays will be zeroed. If the edgefract keyword is supplied, then
; edgefract*lensbc on each edge will be set to zero and the reset will
;be set to 1.
;
;   This routine is called by cormask and corcumfilter.
;
;-
;history:
; 24jun04 - increase nbrds option to 8
; 15may05 - if stokes then mask for all 4 pols
function cormaskmk,b,edgefract=edgefract,ones=ones,raw=raw
; 
;    on_error,2
    useRaw=0
    if keyword_set(raw) then begin
        nbrds=1
        npol=1
        lagSbcOut=raw
        npolAr=intarr(1)+1
        useRaw=1
    endif else begin
        nbrds=n_tags(b)
        npolAr=intarr(nbrds)
        lagSbcOut=intarr(nbrds)
        for i=0,nbrds-1 do begin
            a=size(b[0].(i).d)
            npolAr[i]=(a[0] eq 1)?1:a[2]
            lagSbcOut[i]=b[0].(i).h.cor.lagsbcout
        endfor
    endelse

    case nbrds of
        1 : cmask={b1:fltarr(lagsbcOut[0],npolAr[0])}
        2 : cmask={b1:fltarr(lagsbcout[0],npolAr[0]) ,$
                   b2:fltarr(lagsbcout[1],npolAr[1])}
        3 : cmask={b1:fltarr(lagsbcout[0],npolAr[0]) ,$
                   b2:fltarr(lagsbcout[1],npolAr[1]) ,$ 
                   b3:fltarr(lagsbcout[2],npolAr[2])}
        4 : cmask={b1:fltarr(lagsbcout[0],npolAr[0]) ,$
                   b2:fltarr(lagsbcout[1],npolAr[1]) ,$ 
                   b3:fltarr(lagsbcout[2],npolAr[2]) ,$ 
                   b4:fltarr(lagsbcout[3],npolAr[3])}
        5 : cmask={b1:fltarr(lagsbcout[0],npolAr[0]) ,$
                   b2:fltarr(lagsbcout[1],npolAr[1]) ,$ 
                   b3:fltarr(lagsbcout[2],npolAr[2]) ,$ 
                   b4:fltarr(lagsbcout[3],npolAr[3]) ,$
                   b5:fltarr(lagsbcout[4],npolAr[4])}
        6 : cmask={b1:fltarr(lagsbcout[0],npolAr[0]) ,$
                   b2:fltarr(lagsbcout[1],npolAr[1]) ,$ 
                   b3:fltarr(lagsbcout[2],npolAr[2]) ,$ 
                   b4:fltarr(lagsbcout[3],npolAr[3]) ,$
                   b5:fltarr(lagsbcout[4],npolAr[4]) ,$
                   b6:fltarr(lagsbcout[5],npolAr[5])}

        7 : cmask={b1:fltarr(lagsbcout[0],npolAr[0]) ,$
                   b2:fltarr(lagsbcout[1],npolAr[1]) ,$ 
                   b3:fltarr(lagsbcout[2],npolAr[2]) ,$ 
                   b4:fltarr(lagsbcout[3],npolAr[3]) ,$
                   b5:fltarr(lagsbcout[4],npolAr[4]) ,$
                   b6:fltarr(lagsbcout[5],npolAr[5]) ,$
                   b7:fltarr(lagsbcout[6],npolAr[6])  }
        8 : cmask={b1:fltarr(lagsbcout[0],npolAr[0]) ,$
                   b2:fltarr(lagsbcout[1],npolAr[1]) ,$ 
                   b3:fltarr(lagsbcout[2],npolAr[2]) ,$ 
                   b4:fltarr(lagsbcout[3],npolAr[3]) ,$
                   b5:fltarr(lagsbcout[4],npolAr[4]) ,$
                   b6:fltarr(lagsbcout[5],npolAr[5]) ,$
                   b7:fltarr(lagsbcout[6],npolAr[6]) ,$
                   b8:fltarr(lagsbcout[6],npolAr[6])  }
    endcase
    if n_elements(edgefract)  ne 0 then begin 
        edg1=edgefract[0]
        edg2=edgefract[0]
        if n_elements(edgefract) gt 1 then edg2=edgefract[1]
        for ibrd=0,nbrds-1 do begin
            npol =b[0].(ibrd).h.cor.numsbcout
            nlags=n_elements(cmask.(ibrd)[*,0])
            i1=((long(edg1*nlags+.5)) > 0) < (nlags/2-1)
            i2=((long(edg2*nlags+.5)) > 0) < (nlags/2-1)
            i2=nlags-i2-1
            if i1 le i2 then begin
                for ipol=0,npol - 1 do cmask.(ibrd)[i1:i2,ipol]=1.
            endif
        endfor
    endif else begin 
        if keyword_set(ones) then begin
            for i=0,nbrds-1 do cmask.(i)=cmask.(i) + 1.
        endif
    endelse
    nrecs=n_elements(b)
    if (nrecs gt 1) and (not useRaw) then return,replicate(cmask,nrecs)
    return,cmask
end
