;+
;NAME:
;pdevavg -  read and average records
;SYNTAX: istat=pdevavg(desc,nrecs,b,rec=rec,verb=verb,tp=tp)
;ARGS:
;    desc: {} returned by pdevopen
;   nrecs: long recs avg
;KEYWORDS: 
;     rec: long record to position to before reading (cnt from 1)
;RETURNS:
;     istat: number of records averaged.
;          : 0 returned no records
;          : -1 returned some but not all of the recs
;   tp[nrecs,npol]: float if supplied then return the total power at each sample
;DESCRIPTIION:
;   Read and average the requested number of records from file.
;
;-
function pdevavg,desc,nrecs,bb,rec=rec ,verb=verb,tp=tp
;
;   optionally position to start of rec
;
    lrec=n_elements(rec) eq 0 ? 0L:rec
    usetp=arg_present(tp)
;
;
;   loop reading the data
;
    if usetp then begin
       nsbc=desc.nsbc < 2
       tp=fltarr(nrecs,nsbc)
    endif
    toprint=100L
    nrecTot=0L
;    print,'toprint,verb:',toprint,keyword_set(verb)
    for irec=0L,nrecs-1 do begin
        istat=pdevget(desc,b,rec=lrec)
        if istat ne 1 then break
        if keyword_set(verb) and ((irec mod toprint) eq 0L) then $
            print,nrecTot
        lrec=0L
        if irec eq 0 then begin
           bb=b
           dsum=dblarr(desc.nchan,desc.nsbc)
        endif
        dsum+=b.d
        if usetp then tp[irec,*]=total(b.d[*,0:nsbc-1],1)
        nrecTot++
    endfor
    if nrecTot eq 0 then return,nrectot
    bb.d=dsum/nrecTot
    if usetp then begin
        if nrectot eq 0 then begin
           tp=''
        endif else begin
            if nrecTot ne nrecs then tp=tp[0:nrecTot-1,*]/nrecTot
        endelse
    endif
    return,nrecTot
end
