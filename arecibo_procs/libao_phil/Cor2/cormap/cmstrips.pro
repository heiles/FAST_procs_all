;+
;NAME:
;cmstrips   - overplot spectra by strip.
; 
;SYNTAX:  cmstrips,m,pol,offset,step,smo=n,title=title,xtitle=xtitle,
;           ytitle=ytitle,first=first,last=last,freq=freq,vel=vel,
;           tp=tp,color=color
;ARGS: 
;   m[2,xdim,ydim] : {}     map array 
;              pol : int    1 or 2 for pol A or pol B
;           offset : float. the y offset to add to the first strip.
;             step : float. the y offset to add between strips.
;
;KEYWORDS
;           smooth : int   .. smooth adjacent frequency channels by n.     
;            title : string.. title for plot
;           xtitle : string.. x axes label
;           ytitle : string.. y axes label
;            first : int   .. first strip to plot. default is 1
;             last : int   .. last  strip to plot. default is end of map
;             freq : if set then plot versus frequency
;              vel : if set then plot versus velocity
;               tp : if set then plot total power instead of spectra.
;           color  : if set then change color for each strip
;                    (you should probably enter ldcolph before running
;                    this so that the color table are loaded..)
;
;DESCRIPTION:
;   Overplot the spectra for all the strips in a map. Each strip is
;offset from the previous by offset. 
;   If the keyword tp is set, then plot the total power by strip for all 
;strips in the map. Each horizontal line will be the total power for
;each sample of a strip. The freq,vel keywords are not used.
;   You will probably need to use the ver,minver,maxver function to
;for the vertical scale to be within the range of the data plotted.
;
;EXAMPLE:
;   Assume the map is dimensioned m[2,31,21] with 1024 frequency channels.
;cmstrips,m,1,.01,.02 will plot
;  m[0,*,i].d+offset+(i-1)*step for strips 1 thru 21.
;
;cmstrips,m,1,.01,.02,/freq .. will plot versus frequency
;cmstrips,m,1,.01,.02,/vel  .. will plot versus velocity
;   
;   To plot total power by strip with zero offset between strips:
;ver,.95,1.2
;cmstrips,m,1.,0,0,/tp,/color
;SEE ALSO:
;   ver,hor (generic idl routines).
;-
pro cmstrips,m,pol,offset,step,_extra=e,over=over,smo=tosmo,title=title,$
            xtitle=xtitle,ytitle=ytitle,first=first,last=last,freq=freq,$
            vel=vel,color=color,tp=tp
;
    curoffset=offset
    if n_elements(tosmo) eq 0 then tosmo=1
    if not keyword_set(tp)   then tp=0
    if not keyword_set(color) then color=0
    if n_elements(title) eq 0 then title=''
    if n_elements(xtitle) eq 0 then xtitle=''
    if n_elements(xtitle) eq 0 then ytitle=''
    nchn=(size(m.d))[1]
    x=findgen(nchn)

    a=size(m)
    if  (a[0] ne 3) or (a[1] ne 2) then begin
        print,'cmstrips..first arg is the map array'
        return
    endif
    pind=pol-1
    nsmpl  =a[2]
    nstrips=a[3]
    if not keyword_set(first) then first=1
    if not keyword_set(last) then  last=nstrips
    firsttime=not keyword_set(over)
    if keyword_set(tp) then begin
        x=findgen(nsmpl)
        tosmoloc=tosmo
        if tosmo lt 2 then tosmoloc=0
        stripsxy,x,reform(m[pol-1,*,first-1:last-1].p),offset,step,$
                over=over,smo=tosmoloc,step=color,title=title,$
                xtitle=xtitle,ytitle=ytitle
    endif else begin
    for i=first-1,last-1 do begin
        if color then begin
            col= ( ((i-(first-1))) mod 10) + 1
;           print,i,first,col
        endif else begin
            col=1
        endelse
        if (keyword_set(freq)) or (keyword_set(vel))  then begin
            retvel=keyword_set(vel)
            x=corfrq(m[0,0,i].h,retvel=retvel)
        endif
        for j=0,nsmpl-1 do begin
            if (tosmo gt 1) then  begin
                if (firsttime) then begin
                  plot,x,smooth(m[pind,j,i].d,tosmo,/edge_truncate)+curoffset, $
                    /xstyle,/ystyle,_extra=e,color=col,$
                    title=title,xtitle=xtitle,ytitle=ytitle
                  firsttime=0
                endif else begin
                  oplot,x,smooth(m[pind,j,i].d,tosmo,/edge_truncate)+$
                        curoffset,_extra=e,color=col
                endelse
            endif else begin    
                if (firsttime) then begin
                  plot,x,m[pind,j,i].d+curoffset, /xstyle,/ystyle,_extra=e,$
                    title=title,xtitle=xtitle,ytitle=ytitle,color=col
                  firsttime=0
                endif else begin
                  oplot,x,m[pind,j,i].d+curoffset,_extra=e,color=col
                endelse
            endelse
        endfor
        curoffset=curoffset+step
    endfor
    endelse
    return
end
