;+
;NAME:
;flag - flag a set of vertical lines
;SYNTAX: flag,x,yr=yr,_extra=e
;ARGS:
;   x[n]: float x values where the vertical lines should be drawn
;KEYWORDS:
;  yr[2]: float min,max y values for the veritical lines. The defalut is to
;               cover the entire y range.
;_extra:        Any extra keywords are passed to the oplot routine. This
;               can be color=, linestyle=, etc..
;DESCRIPTION:
;   Draw 1 or more vertical lines on the plot. By default the entire
;y range is used. You can limit that with the yr= keyword. Any keywords
;accepted by oplot can also be passed in. 
;
;EXAMPLE:
;   After plotting, x vs y, draw two vertical dashed lines at x=15 and x=23.
;   plot,x,y
;flag,[15,23],linestyle=2
;- 
pro flag,x,_extra=e,yr=yr
    len      =n_elements(x)
    if n_elements(yr) eq 2 then begin
        yy=yr
    endif else begin
        yy=(!y.type eq 1)?10.^(!y.crange):!y.crange
    endelse
    for i=0L,len-1 do begin
        xx=[x[i],x[i]]
        oplot,xx,yy,_extra=e
    endfor
    return
end
