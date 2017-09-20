;---------------------------------------------------------------------------
;imn,d{imday}  - display next record number
;---------------------------------------------------------------------------
pro imn,d
    if (d.crec lt 1) then d.crec=1          ; in case we havent started yet
    i=d.crec+1                              ; next one
    if (d.cfrq gt 0) then begin             ; user specified freq
        for j=i,d.nrecs do begin            ; till end or hit new freq
            if (j gt d.nrecs) then goto,endloop     ; hit end
            if (d.r[j-1].h.cfrDataMhz eq d.cfrq) then goto,endloop
        end
endloop: i=j
    endif

    if (i gt d.nrecs) then begin
            print,'hit last record:',d.nrecs
            return
     endif
     d.crec=i;
     implot,d.r[d.crec-1]
    return;
end
