;+
;NAME: 
;strips - plot strips with offset and increment versus sample.
;SYNTAX:  strips,y,offset,step,smo=n,title=title,xtitle=xtitle,
;           ytitle=ytitle
;ARGS:
;   y[m,n]:       2d data to plot.
;   offset: float offset to add to the first line plotted.
;   step  : float value to add to plot the next line.
;KEYWORDS:
;   smo  : int  smooth each line by n before plottting.
; title  : string title of plot
; xtitle : string label for x axis
; ytitle : string label for y axis
;
;DESCRPIPTION:
;   Plot the 2d array y line by line. Offset the first line by off and
;then space each line by step.
;EXAMPLE:
;   dat[100,20] is the data
;   strips,dat,0,.02
;You should setup the vertical scale with ver first.
;SEE ALSO:
; stripsxy,ver,hor
;-
pro strips,y,offset,step,_extra=e,over=over,smo=tosmo,title=title,$
            xtitle=xtitle,ytitle=ytitle
;
    curoffset=offset
    if n_elements(tosmo) eq 0 then tosmo=1
    if n_elements(title) eq 0 then title=''
    if n_elements(xtitle) eq 0 then xtitle=''
    if n_elements(xtitle) eq 0 then ytitle=''
    a=size(y)
    if  a[0] gt 2 then begin
        n1=a[1]
        nstrips=a[2]
        for i=3,a[0] do nstrips=nstrips*a[i]
        yl=reform(y,n1,nstrips)
    endif else begin
        yl=y
        nstrips=a[2]
    endelse
    for i=0L,nstrips-1 do begin
        if (tosmo gt 1) then yl[*,i]=smooth(yl[*,i],tosmo,/edge_truncate)
        if (i eq 0) and (not keyword_set(over)) then begin
            plot,yl[*,i]+curoffset, /xstyle,/ystyle,_extra=e,$
                title=title,xtitle=xtitle,ytitle=ytitle
        endif else begin
                oplot,yl[*,i]+curoffset,_extra=e
        endelse
        curoffset=curoffset+step
    endfor
    return
end


