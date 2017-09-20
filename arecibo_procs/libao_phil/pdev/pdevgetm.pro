;+
;NAME:
;pdevgetm - read multiple pdev recs
;SYNTAX: istat=pdevgetm(desc,nrecs,b,rec=rec,avg=avg,tp=tp)
;ARGS:
;    desc: {} returned by pdevopen
;   nrecs: long recs to read
;KEYWORDS: 
;     rec: long record to position to before reading (cnt from 1)
;     avg:      if keyword set then return the averaged data
;nobitrev:      if set then don't do bit reversal on read
;RETURNS:
;  istat: 1 got all the requested records
;       : 0 returned no records
;       : -1 returned some but not all of the recs
;   b[n]: {}   array of structs holding the data
; tp[n,2]: float array holding the total power for each spectra/sbc
;-
function pdevgetm,desc,nrecs,bb,rec=rec ,avg=avg,tp=tp,_extra=e
;
;   optionally position to start of rec
;
    lrec=n_elements(rec) eq 0 ? 0L:rec
    usetp=arg_present(tp)
;
;   loop reading the data
;
    ngot=0L
    if usetp then tp=fltarr(nrecs,desc.nsbc<2)
    for i=0L,nrecs-1 do begin
        istat=pdevget(desc,b,rec=lrec,_extra=e)
        lrec=0L
        if istat ne 1 then break
        if keyword_set(avg) then begin
           if i eq 0 then begin
              bb=b
           endif else begin
              bb.d+=b.d
           endelse
        endif else begin
            if i eq 0 then bb=replicate(b,nrecs)
             bb[i]=b
        endelse
        if usetp then tp[ngot,*]=reform(total(b.d[*,0:desc.nsbc<1],1),1,2)
        ngot++
    endfor
    case 1 of
    ngot eq  0: begin
            bb=''
            tp=''
            return,0
         end
   nrecs eq ngot: begin
             if keyword_set(avg) then bb.d/=ngot
                return,1
             end
   else: begin
            if keyword_set(avg) then begin
                bb.d/=ngot
            endif else begin
                bb=bb[0:ngot-1]
            endelse
            if usetp then tp=tp[0:ngot-1,*]
            return,-1
         end
    endcase
end
