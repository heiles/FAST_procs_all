;.............................................................................
;
pro tsnext,lun,d,npts,flrpitch=flrpitch,flrroll=flrroll
;
; process the next set of npts
    tsinp,lun,d,npts
    npts=n_elements(d)
    if (npts gt 0) then begin
        tsscl,d,flrpitch=flrpitch,flrroll=flrroll
    endif
    return
end
