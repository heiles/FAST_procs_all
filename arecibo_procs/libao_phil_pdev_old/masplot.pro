;+
;NAME:
;masplot - plot mas spectra
;SYNTAX: masplot,b,freq=freq ,over=over,brdlist=brdlist,norm=normRange,off=off
;ARGS:
; b[n]: {b}   mas structure from masget to plot
;KEYWORDS:
;freq[n]: float  if provided then use this as the x axis
;   over:        if set then overplot spectra
;brdlist: long   pols to plot: 12 = polA,B
;norm[2]: float  normalize the spectra. If two element array then is is the range
;                of frequency bins to use for the median (cnt from 0). If a single
;                element or /norm then use all the bins.
;    off: float  If multiple spectra then increment each spectra by off.   
;   chn :        if set then plot vs channel number (count from 0)
;-
pro masplot,b,freq=freq,_extra=e,over=over,brdlist=brdlist,norm=norm,$
            chn=chn,off=pltoff
;
        common colph,decomposedph,colph

    if (keyword_set(norm)) then begin
        useNorm=1
        normRange=(n_elements(norm) eq 2)
    endif else begin
        useNorm=0 
    endelse
	if n_elements(pltoff) eq 0 then pltoff=0.
    nrow =n_elements(b)
    ndump=b[0].ndump
    nchan =b[0].nchan
    nsbc =b[0].npol
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
    if (keyword_set(chn)) then begin
        x=findgen(nchan)
    endif else begin
        if (n_elements(freq) gt 0) then begin
            x=freq
        endif else begin
            x=masfreq(b[0].h)
        endelse
    endelse
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

    if nrow*ndump eq 1 then begin
        if not doover then $
            plot,[x[0],x[nx-1]],[ymin,ymax],_extra=e,/nodata
        for isbc=0,nsbc-1 do begin
            if (pltsbc[isbc]) then begin
				ploffcum=0.
                if (useNorm) then begin
                    scale=normRange?mean(b.d[norm[0]:norm[1],isbc]) : $
                                    mean(b.d[*,isbc])
                    oplot,x,b.d[*,isbc]/scale ,$
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
			   pltoffcum=0.
               for irec=0,nrow-1 do begin
                   if ndump eq 1 then begin
                     if (useNorm) then begin
                       scale=normRange?mean(b[irec].d[norm[0]:norm[1],isbc]):$
                                   mean(b[irec].d[*,isbc])
					   if pltoffcum ne 0. then begin
                        	oplot,x,b[irec].d[*,isbc]/scale + pltoffcum,$
                            	col=colph[isbc+2],_extra=e
					   endif else begin
                        	oplot,x,b[irec].d[*,isbc]/scale,$
                            	col=colph[isbc+2],_extra=e
					   endelse
                     endif else  begin
					   if pltoffcum ne 0. then begin
                       	 oplot,x,b[irec].d[*,isbc]+pltoffcum,col=colph[isbc+2],_extra=e
					   endif else begin
                       	 oplot,x,b[irec].d[*,isbc],col=colph[isbc+2],_extra=e
					   endelse
                     endelse
					 pltoffcum+=pltoff
                   endif else begin
                    for idump=0,ndump-1 do begin
                        if (useNorm) then begin
                           scale=normRange?$
                                mean(b[irec].d[norm[0]:norm[1],isbc,idump]) : $
                                mean(b[irec].d[*,isbc,idump])
                            if pltoffcum ne 0. then begin
                            	oplot,x,b[irec].d[*,isbc,idump]/scale+pltoffcum,$
                                	col=colph[isbc+2],_extra=e
						    endif else begin
                            	oplot,x,b[irec].d[*,isbc,idump]/scale,$
                                	col=colph[isbc+2],_extra=e
							endelse
                        endif else  begin
							if pltoffcum ne 0. then begin
                            	oplot,x,b[irec].d[*,isbc,idump]+pltoffcum,$
										col=colph[isbc+2],_extra=e
							endif else begin
                            	oplot,x,b[irec].d[*,isbc,idump],col=colph[isbc+2],$
                                    _extra=e
							endelse
                        endelse
						pltoffcum+=pltoff
                    endfor
                   endelse
            endfor
          endif 
        endfor
    end
    return
end
