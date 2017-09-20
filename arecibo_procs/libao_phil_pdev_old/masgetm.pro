;+
;NAME:
;masgetm - read multiple rows from a mas fits file
;SYNTAX: istat=masgetm(desc,nrows,b,row=row,avg=avg,tp=tp)
;ARGS:
;    desc: {} returned by masopen
;   nrows: long rows to read
;KEYWORDS: 
;     row: long row to position to before reading (cnt from 1)
;               if row=0 then ignore row keyword
;     avg:      if keyword set then return the averaged data
;               It will average over nrows and ndumps per row.
;               the returned data structure will store the averaged
;               spectra as a double.
; hdronly:      if set then only headers (row) will be returned.no data,stat.
;RETURNS:
;  istat: 1 got all the requested records
;       : 0 returned no rows
;       : -1 returned some but not all of the rows
;   b[n]: {}   array of structs holding the data
; tp[n*m,2]: float array holding the total power for each spectra/sbc
;              m depends on the number of spectra per row
;-
function masgetm,desc,nrows,bb,row=row ,avg=avg,tp=tp,_extra=e
;
;   optionally position to start of row
;
    lrow=n_elements(row) eq 0 ? 0L:row
    usetp=arg_present(tp)
;
;   loop reading the data
;
    ngot=0L
    naccum=0L
    ntp=0L
;;    if usetp then tp=fltarr(nrecs,desc.nsbc<2)
    for i=0L,nrows-1 do begin
        istat=masget(desc,b,row=lrow,_extra=e)
        lrow=0L
        if istat ne 1 then break
        ndump=b.ndump
        if keyword_set(avg) then begin
           if i eq 0 then begin
              npol=b.npol
              bb={    h :b.h,$
                   nchan:b.nchan,$
                   npol :npol ,$
                   ndump:1L ,$
                   st   :b.st[0],$
                   d    :dblarr(b.nchan,npol)$  
               }
            endif
            if (ndump gt 1 ) then begin
                bb.d=(npol eq 1)?bb.d  + total(b.d,2):bb.d+total(b.d,3)
            endif else begin
               bb.d+=b.d
            endelse
            naccum+=ndump
        endif else begin
            if i eq 0 then bb=replicate(b,nrows)
             bb[i]=b
        endelse
        if usetp then begin
            if i eq 0 then begin
                npol=b.npol < 2
                tp=fltarr(ndump*nrows,npol)
            endif
            case 1 of 
                ndump eq 1: begin 
                    tp[np,*]=reform(total(b.d[*,0:npol-1],1),npol)
                            end
                else : begin
                     tp[ntp:ntp+ndump-1,*]=transpose(total(b.d[*,0:npol-1,*],1))
                     end
            endcase
            ntp+=ndump
        endif
        ngot++
    endfor
            if usetp then tp=tp[0:ntp-1,*]
    case 1 of
    ngot eq  0: begin
            bb=''
            tp=''
            return,0
         end
   nrows eq ngot: begin
             if keyword_set(avg) then bb.d/=naccum
             if usetp  and ( (size(tp))[1] ne ntp) then tp=tp[0:ntp-1,*]
             return,1
             end
   else: begin
            if keyword_set(avg) then begin
                bb.d/=naccum
            endif else begin
                bb=bb[0:ngot-1]
            endelse
            if usetp  and ( (size(tp))[1] ne ntp) then tp=tp[0:ntp-1,*]
            return,-1
         end
    endcase
end
