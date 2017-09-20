;+ 
;NAME:
;note - write a string at the requested line on the plot.
;SYNTAX: note,line,lab,xp=xp,sym=sym,lnstyle=lnstyle,dyscale=dyscale,_extra=e
;ARGS:
;   line: float linenumber to start on. 1-33 covers the plot.
;   lab : string to write on plot.
;   xp  : float  xposition to start at. 0 to 1 covers the plot. default is
;                center each line on page.
;   sym : int    sym number. If present then plot the symbol at the start
;                of the line (leave some blanks in lab at the start).
; lnstyle: int   if provided then draw a short line of type lnstyle at the 
;                beginning of the line (leave blanks at start of lab).
; dyscale:float  if set then scale the y spacing this amount.
;DESCRIPTION:
;   Write a line of text on a plot. The default line position runs 1 through
;33. Use the xp  keyword to align the text horizonally. The sym and linestyle
;keywords let you put lines, symbols at the start of your text so you can
;define what they are. 
;   If !p.multi is used for multiple pages then you must recompute where
;the lines go. The line number is relative to the entire page, not the 
;current window of !p.multi.
;-
pro note,line,str,xpos=xpos,sym=sym,lnstyle=lnstyle,dyscale=dyscale,_extra=e
    common colph,decomposedph,colph
    
    dy=(1.0/30.)
;    dy=(1.0/25.)
    if keyword_set(dyscale) then dy=dy*dyscale
    dx=dy
    yval= 1. - dy*line
    align=.5
    xp =.5
    if (n_elements(xpos) ne 0) then begin
        align=0.
        xp=xpos
    endif
    xp=xp*(!x.window[1]-!x.window[0]) + !x.window[0] ; make 0-1 in the pltwind
;   xyouts,xp,yval,str,alignment=align,/normal,charsize=1.4
    if keyword_set(sym) then plots,xp,yval+dy/4.,psym=sym,/normal,_extra=e
    if n_elements(lnstyle) gt 0 then begin
        plots,[xp,xp+dx],[yval+dy/4.,yval+dy/4.],linestyle=lnstyle,$
                /normal,_extra=e
    endif else begin
        dx=0
    endelse
    xyouts,xp+dx,yval,str,alignment=align,/normal,charsize=1.,_extra=e
    return
end
