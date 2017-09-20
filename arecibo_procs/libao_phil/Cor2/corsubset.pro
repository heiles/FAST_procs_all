;+
;NAME:
;corsubset - make a copy of data keeping only specified boards
;SYNTAX:   bret=corsubset(b,brd,pol=pol)
;ARGS:   b[m]:  {corget} original structure 
;        brd[]:  int     brd's to keep.. count 1,2,3,4
;RETURNS:
;   bret[m]   : {corget} return subset data here
;               if an illegal brd is requested then '' is returned.
;               You can check this with keyword_set(bret) eq 0.
;KEYWORDS:
;   pol  :     if set then just return first polarization. 
;              This is used by coravg...
;DESCRIPTION:
;   corsubset will create a subset of a correlator data structure 
;keeping only the specified boards. It will also update
;some header locations so the header will reflect the data.
;
;The input structure can be a single structure or an array of structures.
;EXAMPLE:
;..Keep boards 1 and 3 of all the records of the data structure.
;   print,corinpscan(lun,bsum,b,/sum)
;   b13=corsubset(b,[1,3])      ; all the records
;   b13sum=corsubset(bsum,[1,3]); the summary record
;-
function corsubset,b,brd,pol=pol
;
;    on_error,1
    lpol=0
    if keyword_set(pol) then lpol=1
    nbrdsinp=n_tags(b[0])
    nbrdsout=n_elements(brd)
    for i=0,nbrdsout-1 do begin
        if brd[i] gt nbrdsinp then begin
            message,'illegal brd requested',/info
            return,''
        endif
    endfor
;
    case nbrdsout of
        1: begin
            i=brd[0]-1
            if lpol then begin
                bret={b1:{h:b[0].(i).h,$
                      p:b[0].(i).p,$
                  accum:b[0].(i).accum,$
                      d:b[0].(i).d[*,0] }}
            endif else begin
                bret={b1:{h:b[0].(i).h,$
                      p:b[0].(i).p,$
                  accum:b[0].(i).accum,$
                      d:b[0].(i).d }}
            endelse
           end
        2: begin
            i1=brd[0]-1
            i2=brd[1]-1
            if lpol then begin
                bret={b1:{h:b[0].(i1).h,$
                      p:b[0].(i1).p,$
                  accum:b[0].(i1).accum,$
                      d:b[0].(i1).d[*,0] },$
                  b2:{h:b[0].(i2).h,$
                      p:b[0].(i2).p,$
                  accum:b[0].(i2).accum,$
                      d:b[0].(i2).d[*,0] }}
            endif else begin
                bret={b1:{h:b[0].(i1).h,$
                      p:b[0].(i1).p,$
                  accum:b[0].(i1).accum,$
                      d:b[0].(i1).d },$
                  b2:{h:b[0].(i2).h,$
                      p:b[0].(i2).p,$
                  accum:b[0].(i2).accum,$
                      d:b[0].(i2).d }}
            endelse
           end
        3: begin
            i1=brd[0]-1
            i2=brd[1]-1
            i3=brd[2]-1
            if lpol then begin
                bret={b1:{h:b[0].(i1).h,$
                      p:b[0].(i1).p,$
                  accum:b[0].(i1).accum,$
                      d:b[0].(i1).d[*,0] },$
                  b2:{h:b[0].(i2).h,$
                      p:b[0].(i2).p,$
                  accum:b[0].(i2).accum,$
                      d:b[0].(i2).d[*,0] },$
                  b3:{h:b[0].(i3).h,$
                      p:b[0].(i3).p,$
                  accum:b[0].(i3).accum,$
                      d:b[0].(i3).d[*,0] }}
            endif else begin 
                bret={b1:{h:b[0].(i1).h,$
                      p:b[0].(i1).p,$
                  accum:b[0].(i1).accum,$
                      d:b[0].(i1).d },$
                  b2:{h:b[0].(i2).h,$
                      p:b[0].(i2).p,$
                  accum:b[0].(i2).accum,$
                      d:b[0].(i2).d },$
                  b3:{h:b[0].(i3).h,$
                      p:b[0].(i3).p,$
                  accum:b[0].(i3).accum,$
                      d:b[0].(i3).d }}
            endelse
            end
         4: begin
            i1=0&i2=1&i3=2&i4=3
            if lpol then begin
                bret={b1:{h:b[0].(i1).h,$
                      p:b[0].(i1).p,$
                  accum:b[0].(i1).accum,$
                      d:b[0].(i1).d[*,0] },$
                  b2:{h:b[0].(i2).h,$
                      p:b[0].(i2).p,$
                  accum:b[0].(i2).accum,$
                      d:b[0].(i2).d[*,0] },$
                  b3:{h:b[0].(i3).h,$
                      p:b[0].(i3).p,$
                  accum:b[0].(i3).accum,$
                      d:b[0].(i3).d[*,0] },$
                  b4:{h:b[0].(i4).h,$
                      p:b[0].(i4).p,$
                  accum:b[0].(i4).accum,$
                      d:b[0].(i4).d[*,0] }}
            endif else begin
                bret={b1:{h:b[0].(i1).h,$
                      p:b[0].(i1).p,$
                  accum:b[0].(i1).accum,$
                      d:b[0].(i1).d },$
                  b2:{h:b[0].(i2).h,$
                      p:b[0].(i2).p,$
                  accum:b[0].(i2).accum,$
                      d:b[0].(i2).d },$
                  b3:{h:b[0].(i3).h,$
                      p:b[0].(i3).p,$
                  accum:b[0].(i3).accum,$
                      d:b[0].(i3).d },$
                  b4:{h:b[0].(i4).h,$
                      p:b[0].(i4).p,$
                  accum:b[0].(i4).accum,$
                      d:b[0].(i4).d }}
            endelse
            end

          6: begin
            i1=0&i2=1&i3=2&i4=3
            i5=4&i6=5
            if lpol then begin
                bret={b1:{h:b[0].(i1).h,$
                      p:b[0].(i1).p,$
                  accum:b[0].(i1).accum,$
                      d:b[0].(i1).d[*,0] },$
                  b2:{h:b[0].(i2).h,$
                      p:b[0].(i2).p,$
                  accum:b[0].(i2).accum,$
                      d:b[0].(i2).d[*,0] },$
                  b3:{h:b[0].(i3).h,$
                      p:b[0].(i3).p,$
                  accum:b[0].(i3).accum,$
                      d:b[0].(i3).d[*,0] },$
                  b4:{h:b[0].(i4).h,$
                      p:b[0].(i4).p,$
                  accum:b[0].(i4).accum,$
                  d:b[0].(i4).d[*,0] },$
                 
                  b5:{h:b[0].(i5).h,$
                      p:b[0].(i5).p,$
                  accum:b[0].(i5).accum,$
                      d:b[0].(i5).d[*,0] },$
                  b6:{h:b[0].(i6).h,$
                      p:b[0].(i6).p,$
                  accum:b[0].(i6).accum,$
                      d:b[0].(i6).d[*,0] }}
            endif else begin
                bret={b1:{h:b[0].(i1).h,$
                      p:b[0].(i1).p,$
                  accum:b[0].(i1).accum,$
                      d:b[0].(i1).d },$
                  b2:{h:b[0].(i2).h,$
                      p:b[0].(i2).p,$
                  accum:b[0].(i2).accum,$
                      d:b[0].(i2).d },$
                  b3:{h:b[0].(i3).h,$
                      p:b[0].(i3).p,$
                  accum:b[0].(i3).accum,$
                      d:b[0].(i3).d },$
                  b4:{h:b[0].(i4).h,$
                      p:b[0].(i4).p,$
                  accum:b[0].(i4).accum,$
                      d:b[0].(i4).d } ,$
                  b5:{h:b[0].(i5).h,$
                      p:b[0].(i5).p,$
                  accum:b[0].(i5).accum,$
                      d:b[0].(i5).d },$
                  b6:{h:b[0].(i6).h,$
                      p:b[0].(i6).p,$
                  accum:b[0].(i6).accum,$
                      d:b[0].(i6).d }}
            endelse

            end

          8: begin
            i1=0&i2=1&i3=2&i4=3
            i5=4&i6=5&i7=6&i8=7
            if lpol then begin
                bret={b1:{h:b[0].(i1).h,$
                      p:b[0].(i1).p,$
                  accum:b[0].(i1).accum,$
                      d:b[0].(i1).d[*,0] },$
                  b2:{h:b[0].(i2).h,$
                      p:b[0].(i2).p,$
                  accum:b[0].(i2).accum,$
                      d:b[0].(i2).d[*,0] },$
                  b3:{h:b[0].(i3).h,$
                      p:b[0].(i3).p,$
                  accum:b[0].(i3).accum,$
                      d:b[0].(i3).d[*,0] },$
                  b4:{h:b[0].(i4).h,$
                      p:b[0].(i4).p,$
                  accum:b[0].(i4).accum,$
                  d:b[0].(i4).d[*,0] },$
                 
                  b5:{h:b[0].(i5).h,$
                      p:b[0].(i5).p,$
                  accum:b[0].(i5).accum,$
                      d:b[0].(i5).d[*,0] },$
                  b6:{h:b[0].(i6).h,$
                      p:b[0].(i6).p,$
                  accum:b[0].(i6).accum,$
                      d:b[0].(i6).d[*,0] },$
                  b7:{h:b[0].(i7).h,$
                      p:b[0].(i7).p,$
                  accum:b[0].(i7).accum,$
                      d:b[0].(i7).d[*,0] },$
                  b8:{h:b[0].(i8).h,$
                      p:b[0].(i8).p,$
                  accum:b[0].(i8).accum,$
                      d:b[0].(i8).d[*,0] }}
            endif else begin
                bret={b1:{h:b[0].(i1).h,$
                      p:b[0].(i1).p,$
                  accum:b[0].(i1).accum,$
                      d:b[0].(i1).d },$
                  b2:{h:b[0].(i2).h,$
                      p:b[0].(i2).p,$
                  accum:b[0].(i2).accum,$
                      d:b[0].(i2).d },$
                  b3:{h:b[0].(i3).h,$
                      p:b[0].(i3).p,$
                  accum:b[0].(i3).accum,$
                      d:b[0].(i3).d },$
                  b4:{h:b[0].(i4).h,$
                      p:b[0].(i4).p,$
                  accum:b[0].(i4).accum,$
                      d:b[0].(i4).d } ,$
                  b5:{h:b[0].(i5).h,$
                      p:b[0].(i5).p,$
                  accum:b[0].(i5).accum,$
                      d:b[0].(i5).d },$
                  b6:{h:b[0].(i6).h,$
                      p:b[0].(i6).p,$
                  accum:b[0].(i6).accum,$
                      d:b[0].(i6).d },$
                  b7:{h:b[0].(i7).h,$
                      p:b[0].(i7).p,$
                  accum:b[0].(i7).accum,$
                      d:b[0].(i7).d },$
                  b8:{h:b[0].(i8).h,$
                      p:b[0].(i8).p,$
                  accum:b[0].(i8).accum,$
                      d:b[0].(i8).d }}
            endelse

            end
        endcase
    if n_elements(b) gt 1 then begin
        bret=corallocstr(bret,n_elements(b))
        if lpol then begin
          for i=0,nbrdsout-1 do begin
            j=brd[i]-1
            bret.(i).h=b.(j).h
            bret.(i).p=b.(j).p
            bret.(i).accum=b.(j).accum
            bret.(i).d=b.(j).d[*,0]
          endfor
        endif else begin
          for i=0,nbrdsout-1 do begin
            j=brd[i]-1
            bret.(i).h=b.(j).h
            bret.(i).p=b.(j).p
            bret.(i).accum=b.(j).accum
            bret.(i).d=b.(j).d
          endfor
        endelse
    endif
;
;   clean up some header locations
;
;   each board has all 4 freqoffsets, if we moved boards around
;   (via ind) we need to also move these frequency offsets around
;
    
    if nbrdsinp le 4 then begin
        freqoffsets=b.b1.h.dop.freqoffsets
        freqoffsets[0:nbrdsout-1]=freqoffsets[brd-1]
        if (nbrdsout lt nbrdsinp)  then freqoffsets[nbrdsout:*]=0.
    endif
    for i=0,nbrdsout-1 do begin
        bret.(i).h.std.grptotrecs=nbrdsout
        bret.(i).h.std.grpcurrec =i+1
        bret.(i).h.cor.numbrdsused =nbrdsout
        bret.(i).h.cor.numsbcout   =(size(bret[0].(i).d))[0]
        if nbrdsinp le 4  then begin
            if n_elements(b) gt 1 then begin    
              bret.(i).h.dop.freqoffsets=freqoffsets # (fltarr(n_elements(b))+1)
            endif else begin
              bret.(i).h.dop.freqoffsets=freqoffsets
            endelse
        endif
    endfor
    return,bret
end
