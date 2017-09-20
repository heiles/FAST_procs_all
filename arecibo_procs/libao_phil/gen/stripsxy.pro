;+
;NAME:
;stripsxy - plot strips with offset and increment verus x.
;SYNTAX: stripsxy,x,y,offset,step,over=over,smo=tosmo,dec=dec,title=title,$
;       xtitle=xtitle,ytitle=ytitle,stepcol=stepcol,colar=colar,_extra=e
;ARGS:
;   x[n]  : float   data for x axis.
;   y[n,m]: float   2d data to plot. m strips of n points.
;   offset: float   offset first strip by this amount.
;   step  : float   separate each strip by this amount.
;KEYWORDS:
;   over  :     if set then continue plotting from a previous call.
;   smo   : int number of points to smooth each line.
;   dec   : int number of points to decimate each each line.
;   title : string title of plot
;   xtitle: string xlabel 
;   ytitle: string ylabel 
;  colAr[]: int    lut indices to use for color
;  stepcol: if set then alternate colors between each line. Use color
;           indices 1-10. use ldcolph to load the color table.
;   _extra:        pass this to the plot,oplot routine.
;-
;history
;   if decimation does not divide into length, chop off the end
;
pro stripsxy,x,y,offset,step,_extra=e,over=over,smo=tosmo,dec=dec,title=title,$
        xtitle=xtitle,ytitle=ytitle,stepcol=stepcol,colar=colar
;
    common colph,decomposedph,colph
;    on_error,2
    curoffset=offset
    colind=0
    if n_elements(colar) eq 0 then begin
        colar=lindgen(10) + 1
    endif
    if n_elements(tosmo) eq 0 then tosmo=0
    if n_elements(dec) eq 0 then dec=0
    if not keyword_set(xtitle) then xtitle=' '
    if not keyword_set(ytitle) then ytitle=' '
    if not keyword_set(title) then  title=' '
    a=size(y)
    if  a[0] gt 2 then begin
        n1=a[1]
        nstrips=a[2]
        for i=3,a[0] do nstrips=nstrips*a[i]
        yl=reform(y,n1,nstrips)
    endif else begin
		if (a[0] eq 1) then begin
            yl=y
            nstrips=1
		endif else begin
        	yl=y
        	nstrips=a[2]
		endelse
    endelse
    if dec gt 0 then begin
        lenx=n_elements(x)
        declen=lenx-(lenx mod dec)
        yd=fltarr(declen/dec,nstrips)
        xd=x
        if tosmo gt 1 then xd=smooth(xd,tosmo,/edge_truncate)
        if declen eq lenx then declen=0
        if declen  ne 0 then begin
            xd=select(xd[0:declen-1],dec/2,dec)
        endif else begin
            xd=select(xd,dec/2,dec)
        endelse
    endif

    for i=0L,nstrips-1 do begin
        if (tosmo gt 1) then yl[*,i]=smooth(yl[*,i],tosmo,/edge_truncate)
        if (dec  gt 1) then begin
            if declen gt 0 then begin
                yd[*,i] =select(yl[0:declen-1,i],dec/2,dec)
            endif else begin
                yd[*,i] =select(yl[*,i],dec/2,dec)
            endelse
        endif
        if (i eq 0) and (not keyword_set(over)) then begin
            if dec gt 1 then begin
                    plot,xd,yd[*,i]+curoffset, /xstyle,/ystyle,$
                    _extra=e,xtitle=xtitle,ytitle=ytitle,title=title,$
                        color=colph[colAr[colind]]
            endif else begin
                plot,x,yl[*,i]+curoffset, /xstyle,/ystyle,_extra=e,$
                    xtitle=xtitle,ytitle=ytitle,title=title,$
                       color=colph[colAr[colind]]
            endelse
        endif else begin
            if dec gt 1 then begin 
                oplot,xd,yd[*,i]+curoffset,color=colph[colAr[colind]],_extra=e
            endif else begin
                oplot,x,yl[*,i]+curoffset,color=colph[colAr[colInd]],_extra=e
            endelse
        endelse
        curoffset=curoffset+step
        if keyword_set(stepcol) then begin
            colind=((colind + 1) mod 10) 
        endif
    endfor
    return
end


