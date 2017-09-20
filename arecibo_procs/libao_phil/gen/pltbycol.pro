;+
;NAME:
;pltbycol - plot values by color
;SYNTAX: pltbycol,x,y,grpid,col=colar,xtitle=xtitle,ytitle=ytitle,
;                 title=title,sym=sym,_extra=e,over=over
;ARGS:
;       x[npts]: float  xdata to plot
;       y[npts]: float  ydata to plot
;   grpid[npts]: long   unique number identifying a particular group. It 
;                       should run 0 through maxgrp-1. It is used to 
;                       generate the color.
;KEYWORDS: 
;   colar[ncol]: long lut values to use.
;        xtitle: string xlabel for plot
;        ytitle: string ylabel for plot
;         title: string title for plot
;          sym : int    symbol to use for ploting.
;        over  : int    if set, then overplot this dataset on previous
;     _extra=e :        will be passed to plot and oplot routine
;
;DESCRIPTION:
;   Plot x,y points. Group points by color. grpind[npts] is used to identify
;the points that have a common color. colar[ncol] is used for the color.
;If there are more groups than colors, then the colors get reused modulo
;ncolors. 
;
;EXAMPLE:
;
;   An example would be ploting the za Error for a given set of sources 
;by za. Suppose the array of structures src[npts] has the following elements:
;
; src[i].name  - source name
; src[i].za    - za for a measurement
; src[i].zaErr - za error for the measurement
;
; The unique srcnames are:
;   names=src[uniq(src[sort(src.name)].name)].name
;
; You could generate the grpind[npts] array by:
;
;   nsrc=n_elements(names)      ; number of unique names
;   grpind=lonarr(npnts)        ; will hold srcid 0..nsrc-1
;   for i=0,nsrc-1 do begin 
;       ind=where(src.name eq names[i],count)  
;        if count gt 0 then grpind[ind]=i
;   endfor
; You could then call pltbysrc with:
;
;   pltbysrc,src.za,src.zaErr,grpind,sym=1
;
; The default color array is:
;   colar=findgen(10)+1
;
; This has 10 unique colors (usually setup by ldcolph). Colors get reused 
;every 10 sources 
; The default symbol is *.
;- 
pro pltbycol,x,y,grpind,xtitle=xtitle,ytitle=ytitle,title=title,$
            col=colar,sym=sym,over=over,_extra=e

    common colph,decomposedph,colph    

    if not keyword_set(xtitle) then xtitle=''
    if not keyword_set(ytitle) then ytitle=''
    if not keyword_set(title) then  title=''
    if not keyword_set(sym)   then  sym  =2
    if not keyword_set(over)   then  over=0
    if not keyword_set(colar) then begin
        numcol=10
        colar=lindgen(numcol)+1
    endif else begin
        numcol=n_elements(colar)
    endelse
    nsrc=max(grpind)+1
    for i=0,nsrc-1 do begin
        ind=where(grpind eq i,count)
        if (count gt 0 ) then begin
        col=colar[i mod numcol]
        if (i eq 0) and (not over) then begin
            plot,x[ind],y[ind],xtitle=xtitle,ytitle=ytitle,title=title,$
                color=colph[col],psym=sym,_extra=e
        endif else begin
            oplot,x[ind],y[ind],color=colph[col],psym=sym,_extra=e
        endelse
        endif
    endfor
    return
end
