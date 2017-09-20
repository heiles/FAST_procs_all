;+
;NAME:
;ricrossplt - plot the data from a cross
;SYNTAX: ricrossplt,baz,bza,az=az,za=za,step=step,pol=pol
;ARGS:
;   baz[n]: {anoncross} hold az info
;   bza[n]: {anoncross} hold za info
;KEYWORDS:
;   az   if set then include az in plots        
;   za   if set then include za in plots        
;  pol:  string "a", or "b" if not provided, then plot both
;step=step  if n>1 then do a strip plot with this step between strips
;           default is 0.
;DESCRIPTION:
;   plot the data input from ricrossinp. The default is to plot
;both az and za. If only az is set or only za is set, then
;just that axis will be plotted. If n is > 1 then the strips will be
;overplotted with a step between each strip.
;-
pro ricrossplt,baz,bza,az=az,za=za,step=step,over=over,pol=pol,_extra=e
;
    common colph,decomposedph,colph
    overl=keyword_set(over)
    lpol=3
    if keyword_set(pol) then begin
        lpol=1
        if (pol eq 'b') or (pol eq 'B') then lpol=2
    endif
    if  n_elements(az) eq 0  then az=0
    if  n_elements(za) eq 0 then za=0
    if  n_elements(step) eq 0 then step=0.
    if (az eq 0) and (za eq 0) then begin
        az=1
        za=1
    endif
    s=size(baz)
    azOff=baz[0].h[0].proc.dar[0]
    npts=baz[0].h[0].proc.iar[3]
    x=-(findgen(npts)/npts - .5 )*azOff*2.
    xp=.05
    print,overl
    if s[1] gt 1 then begin
        if az eq 1 then begin
          if (lpol and 1) ne 0 then begin
          stripsxy,x,baz.d[*,0],0,step,/xstyle,/ystyle,xtitle='Amin',_extra=e,$
                over=overl
          overl=1
          note,3,'az polA',col=1,xp=xp
          endif 
          if (lpol and 2) ne 0 then begin
            if overl eq 0 then begin
                plot,x,baz.d[*,1],/nodata,xtitle='Amin',_extra=e
                overl=1
            endif   
            stripsxy,x,baz.d[*,1],0,step,/xstyle,/ystyle,xtitle='Amin',$
                   over=overl,color=colph[2],_extra=e
            note,4,'az polB',col=2,xp=xp
          endif
        endif
        if (za eq 1)then begin
            if (lpol and 1 ) ne 0 then begin
                if overl eq 0 then begin
                    plot,x,bza.d[*,0],/nodata,xtitle='Amin',_extra=e
                    overl=1
                endif   
            stripsxy,x,bza.d[*,0],0,step,over=overl,color=colph[3],xtitle='amin',$
                _extra=e
            note,5,'za polA',col=3,xp=xp
            endif
            if (lpol and 2 ) ne 0 then begin
                if overl eq 0 then begin
                    plot,x,bza.d[*,1],/nodata,xtitle='Amin',_extra=e
                    overl=1
                endif   
            stripsxy,x,bza.d[*,1],0,step,over=overl,color=colph[5],_extra=e
            note,6,'za polB',col=5,xp=xp
            endif
        endif
    endif else begin
        if (az eq 1) then begin
            if (lpol and 1) ne 0 then begin
                if overl eq 0 then begin 
                    plot,x,baz.d[*,0],/xstyle,/ystyle,xtitle='amin',$
                        _extra=e,/nodata
                    overl=1
                endif
                oplot,x,baz.d[*,0], _extra=e
                note,3,'az polA',col=1,xp=xp
            endif
            if (lpol and 2) ne 0 then begin
                if overl eq 0 then begin 
                    plot,x,baz.d[*,1],/xstyle,/ystyle,xtitle='amin',$
                        _extra=e,/nodata
                    overl=1
                endif
                oplot,x,baz.d[*,1],color=colph[2],_extra=e
                note,4,'az polB',col=2,xp=xp
            endif
        endif
        if (za eq 1) then begin
            if (lpol and 1) ne 0 then begin
                if overl eq 0 then begin 
                    plot,x,bza.d[*,0],xtitle='amin',_extra=e,/nodata
                    overl=1
                endif 
                oplot,x,bza.d[*,0],color=colph[3],_extra=e
                note,5,'za polA',col=3,xp=xp
            endif
            if (lpol and 2) ne 0 then begin
                if overl eq 0 then begin 
                    plot,x,bza.d[*,1],xtitle='amin',_extra=e
                    overl=1
                endif
                oplot,x,bza.d[*,1],color=coph[5],_extra=e
                note,6,'za polB',col=5,xp=xp
            endif
        endif
    endelse
    return
end
