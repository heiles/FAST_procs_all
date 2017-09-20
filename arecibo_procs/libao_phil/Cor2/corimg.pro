;+
;NAME:
;corimg - create an image of freq vs time for 1 sbc.
;SYNTAX:  d=corimg(b,brd,sbc,bscl=bscl,cmpscl=cmpscl,edgchn=edgchn)
;ARGS:
;        b[n] : {corget} input data
;        brd  :  1-4 which board to use
;        sbc  :  1,2 in this board to use
;KEYWORDS:
;        bscl : {corget} divide into each entry in b[n]. Usually comes from
;                        coravgint().
;        cmpscl: int  1 compute mean  ,use to flatten image (default)
;                     2 compute median,use to flatten image
;                     3 donot flatten image.
;        edgchn: int  number of channels on each edge to set to unity
;RETURNS:
;         d[lensbc,n]: floats .. scaled data
;DESCRIPTION:
;   For the board and sbc of interest return a floating point array
; d[nlags,nrecs]. It will be normalized by :
; if bscl provided then 
;       d=b/bscl for the particular sbc.
; if cmpscl returns
;     0,1   d=b/avg(b)
;       2   d=b/median(b)
;       3   just return the data with no bandpass correction.
;-
function corimg,b,brd,sbc,bscl=bscl,cmpscl=cmpscl,edgchn=edgchn
;
    on_error,1
    if n_elements(edgchn)  eq 0 then edgchn=0
    cmpsclloc=1
    if keyword_set(cmpscl) then cmpsclloc=cmpscl 
    if (cmpsclloc lt 1 ) or (cmpsclloc gt 3) then begin
        message,$
'err cmpscl keyword..1-use mean,2-use median to flatten,3-no flattening'
    endif
    nbrds=b[0].b1.h.cor.numbrdsused
    lensbc=b[0].(brd-1).h.cor.lagsbcout
    if (brd lt 1) or (brd  gt nbrds) then message,'illegal sbc request.'
;
    if (n_elements(bscl) gt 0 ) then begin
        return, mav(b.(brd-1).d[*,sbc-1], 1./bscl.(brd-1).d[*,sbc-1])
    endif else begin
        npts=(size(b))[1]
        case cmpsclloc of
        1 : begin
            bp=total(b.(brd-1).d[*,sbc-1],2)/(npts*1.)
            end
        2 : begin
            bp=fltarr(lensbc)
            bloc=transpose(b.(brd-1).d[*,sbc-1])
            for k=0,lensbc-1 do begin
                bp[k]=median(bloc[*,k],/even)
            endfor
            end
        3 : begin
            bp=fltarr(lensbc)+1.
            end
        endcase
        if (edgchn eq 0) then return,mav(b.(brd-1).d[*,sbc-1], 1./bp)
        a=mav(b.(brd-1).d[*,sbc-1], 1./bp)
        a[0:edgchn-1,*]=1.
        a[lensbc-edgchn-1:lensbc-1,*]=1.
        return,a
    endelse
end
