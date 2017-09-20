;+
;NAME:
;corhan - hanning smooth correlator data.
;SYNTAX: corhan,b,bsmo
;ARGS: 
;       b[m]:  {corget} data to hanning smooth
;    bsmo[m]:  {corget} return smoothed data here. Note.. if only 1 argument
;                    is passed to the routine then the data is smoothed in
;                    place (it is returned in b).
;DESCRIPTION:
;   corhan will hanning smooth the data in the structure b. If a single
;argument is passed to the routine, then the smoothed data is returned 
;in place. If two arguments are passed (b,bsmo) then the data is returned
;in the second argument.
;EXAMPLE:
;   print,corget(lun,b)
;   corhan,b            ; this smooths the data an returns it in b.
;   print,corget(lun,b)
;   corhan,b,bsmo       ; this smooths the data an returns it in bsmo
;-
;modhistoru
;31jun00 - changed to new form corget
;03may02 - added secodn argument 
pro corhan,b,bsmo
;
; hanning smooth the data in b
;
on_error,2
;
;
;
han=[.5,1.,.5]
nbrds=n_tags(b[0])
nrecs=n_elements(b)
i=0
if n_params() eq 2 then  begin
    bsmo=b
    for k=0,nrecs-1 do begin
        for i=0 , nbrds-1 do begin
         for j=0 , b[0].(i).h.cor.numSbcOut-1 do  begin
             if (b[0].(i).h.cor.lagsbcout gt 2) then begin
               bsmo[k].(i).d[*,j]=convol(b[k].(i).d[*,j],han,2.,/edge_truncate)
             endif else begin
               bsmo[k].(i).d[*,j]=b[k].(i).d[*,j]
             endelse
        endfor
        endfor
    endfor
endif else begin
    for k=0,nrecs-1 do begin
    for i=0 , nbrds-1 do begin
     for j=0 , b[0].(i).h.cor.numSbcOut-1 do  begin
         if (b[0].(i).h.cor.lagsbcout gt 2) then begin
         b[k].(i).d[*,j]=convol(b[k].(i).d[*,j],han,2.,/edge_truncate)
         endif 
     endfor
    endfor
    endfor
endelse
return
end
