;+
;NAME:
;ricrossinp - get 1 or more ri cross patterns
;SYNTAX: patInp=ricrossinp(lun,baz,bza,bcal,patreq,scan=scan)
;ARGS:   lun : long  lun to read from
;      patreq: long  the number of patterns to read in
;RETURNS:
;        baz : {} return az strips
;        bza : {} return za strips
;       bcal : {} return cals here if we find them
;      patInp: long number of patterns input
;
;DESCRIPTION:
;   Read in 1 or more ricross patterns. The pattern has an az strip and 
;a za strip. These are return in baz and bza. If cals were taken then they
;will be returned in bcal. By default, the routine starts reading from the 
;current position in the file. If the scan keyword is supplied then 
;it will position to scan before reading the data. The format of the returned
;data for a single pattern is (either baz or bza):
;   b.h[nrecs]   - header from each rec of az or za strip
;   b.d[npts,2]  - all the data for 1 strip. The second dimension is polA,B
;-
function ricrossinp,lun,baz,bza,bcal,patreq,scan=scan
;
    calsInp=0
    if n_params() lt 4 then patreq=1
    if n_elements(scan) ne 0 then begin
        istat=posscan(lun,scan,1)
        if istat ne 1 then begin
            print,"posscan returned stat:",istat,' for scan',scan
            return,0
        endif
    endif
    patInp=0
    for i=0,patreq-1 do begin
;
;       see if there is a cal record here
;
        istat=rigethdr(lun,hdr,/pos)
        if (istat ne 1) then begin
            print,'riget: error reading header rec',i+1
            goto ,done
        endif
        if (string(hdr.proc.car[*,0]) eq 'cal') then begin
            istat=riget(lun,cal,numrecs=2)
            if (istat ne 2) then begin
                print,'ricrossinp: error getting cal'
                goto,done
            endif
            if calsInp eq 0 then begin
                npts=(size(cal.d1))[2]
                a={h:hdr,don:fltarr(npts,2,/nozero),doff:fltarr(npts,2,/nozero)}
                bcal=replicate(a,patreq)
            endif
            bcal[calsInp].h =cal[0].h
            bcal[calsInp].don[*,0]=reform(cal[0].d1[0,*],npts)
            bcal[calsInp].don[*,1]=reform(cal[0].d1[1,*],npts)
            bcal[calsInp].doff[*,0]=reform(cal[1].d1[0,*],npts)
            bcal[calsInp].doff[*,1]=reform(cal[1].d1[1,*],npts)
            calsInp=calsInp+1
        endif
        istat=ricrossinp1(lun,b)
        if (istat ne 1) then begin
            print,'Error getting az strip rec',i+1
            goto,done
        endif
        if i eq 0 then begin
            baz=replicate(b,patreq)
        endif
        baz[i].h=b.h
        baz[i].d=b.d
;
;   get za strip
;
        istat=ricrossinp1(lun,b)
        if (istat ne 1) then begin
            print,'Error getting za strip rec',i+1
            goto,done
        endif
        if i eq 0 then begin
            bza=replicate(b,patreq)
        endif
        bza[i].h=b.h
        bza[i].d=b.d
        patInp=patInp+1
    endfor
done:
    if (patreq ne patInp) then begin
        if (patinp eq 0 ) then begin
            bza=''
            baz=''
        endif else begin
            bza=bza[0:patInp-1]
            baz=baz[0:patInp-1]
        endelse
    endif
    if (calsInp gt 0) and (calsInp ne patreq) then bcal=bcal[0:calsInp-1]
    return,patInp
end
