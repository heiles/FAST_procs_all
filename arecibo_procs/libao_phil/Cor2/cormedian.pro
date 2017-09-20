;+ 
;NAME: 
;cormedian - median filter a set of integrations
;SYNTAX: bfiltered=cormedian(b)
;ARGS:   b[] : {corget} array of corget structures
;RETURNS:
;       bfiltered : {corget} after median filtering each sbc,brd of b
;DESCRIPTION:
;   if b[] is an array of n corget structures, cormedian() will compute the
;median (over the records). It will return a single averaged corget struct.
;This is the same as coravg() except that it uses the median rather than 
;the mean.
;-
function cormedian,b
;
    on_error,1
    nbrds=b[0].b1.h.cor.numbrdsused
    npnts = (size(b))[1]
    c=b[0]
    for i=0,nbrds-1 do begin
        lensbc=b[0].(i).h.cor.lagsbcout
        numsbc=b[0].(i).h.cor.numsbcout
        for j=0,numsbc-1 do begin
            if (!version.release ge '5.6' ) then begin
                c.(i).d[*,j]=median(b.(i).d[*,j],dimension=2,/even)
            endif else begin
                bloc=''
                bloc=transpose(b.(i).d[*,j])
                for k=0,lensbc-1 do c.(i).d[k,j]=median(bloc[*,k],/even)
            endelse
        endfor
    endfor
    return,c
end
