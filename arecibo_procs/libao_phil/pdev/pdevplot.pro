;+
;NAME:
;pdevplot - plot pdev spectra
;SYNTAX: pdevplot,b,freq=freq ,over=over,brdlist=brdlist,norm=normRange
;-
pro pdevplot,b,freq=freq,_extra=e,over=over,brdlist=brdlist,norm=norm
;
        common colph,decomposedph,colph
    if (keyword_set(norm)) then begin
        useNorm=1
        normRange=(n_elements(norm) eq 2)
    endif else begin
        useNorm=0 
    endelse
    nspec=n_elements(b)
    nchan =b[0].nchan
    nsbc =b[0].nsbc
    pltsbc=intarr(nsbc)   ; 0--> no plot,1--> plot
    if n_elements(brdlist) ne 0 then begin
       itemp=long(brdlist)
       while itemp gt 0 do begin
           ival=itemp mod 10
           if ival gt 0 then pltsbc[ival-1]=1
           itemp=itemp/10L
       endwhile
    endif else begin
        for i=0,nsbc-1 do pltsbc[i]=1
    endelse
;
    x=(n_elements(freq) gt 0)?freq:findgen(nchan)
    nx=n_elements(x)
    doover=keyword_set(over)
    autoscale=((!y.range[0] eq 0.) and (!y.range[1] eq 0.))
    if autoScale and (not doover) then begin
        if useNorm then begin
            ymin=0
            ymax=2.             ; too much trouble to figure it out..
        endif else begin
        ymin=min(b.d,max=ymax)
        endelse
        ver,ymin,ymax
    endif else begin
        ymin=!y.range[0]
        ymax=!y.range[1]
    endelse 

    if nspec eq 1 then begin
        if not doover then $
            plot,[x[0],x[nx-1]],[ymin,ymax],_extra=e,/nodata
        for isbc=0,nsbc-1 do begin
            if (pltsbc[isbc]) then begin
                if (useNorm) then begin
                    scale=normRange?mean(b.d[norm[0]:norm[1],isbc]) : $
                                    mean(b.d[*,isbc])
                    oplot,x,b.d[*,isbc]/scale,$
                                col=colph[isbc+2],_extra=e
                endif else begin
                    oplot,x,b.d[*,isbc],col=colph[isbc+2],_extra=e
                endelse
            endif
        endfor  
    endif else begin
        if not doover then $
            plot,x[[0,nx-1]],[ymin,ymax],_extra=e,/nodata
        for isbc=0,nsbc-1 do begin
            if (pltsbc[isbc]) then begin
               for irec=0,nspec-1 do begin
                    if (useNorm) then begin
                   scale=normRange?mean(b[irec].d[norm[0]:norm[1],isbc]) : $
                                   mean(b[irec].d[*,isbc])
                       oplot,x,b[irec].d[*,isbc]/scale,$
                            col=colph[isbc+2],_extra=e
                    endif else  begin
                       oplot,x,b[irec].d[*,isbc],col=colph[isbc+2],_extra=e
                    endelse
               endfor
            endif
        endfor
    end
    return
end
