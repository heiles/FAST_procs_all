;+
;
pro srclabedge,srcnames,colar=colar,hard=hard,nmpercol=nmpercol,xpsrcl=xpsrcl,$
    dyscale=dyscale
    common colph,decomposedph,colph
    
    if not keyword_set(xpsrcl) then  begin
        xpsrcl=-.1
        if keyword_set(hard) then xpsrcl=-.2
    endif
    if not keyword_set(dyscale) then dyscale=1.
    xpsrcr=1.
    if not keyword_set(nmpercol) then nmpercol=28
    if not keyword_set(colar) then begin
        numcol=10
        colar=lindgen(numcol) + 1
    endif else begin
        numcol=n_elements(colar)
    endelse
    nsrc=n_elements(srcnames)
    if nsrc gt 2*nmpercol then begin
        nsrc=2*nmpercol
        srcnamesl=srcnames[0:nsrc-1]
        srcnamesl[nsrc-1]='more..'
    endif else begin
        srcnamesl=srcnames
    endelse
    for i=0,nsrc-1 do begin
        j=i+1
        xp=xpsrcl
        if j gt nmpercol then begin
            j=j-nmpercol
            xp=xpsrcr
        endif
        note,j,srcnames[i],xp=xp,color=colph[colar[i mod numcol]],dyscale=dyscale
    endfor
    return
end
