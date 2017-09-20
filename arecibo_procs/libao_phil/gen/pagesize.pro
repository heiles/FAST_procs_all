;+
;NAME:
;pagesize - set the postscript page size.
;SYNTAX:  pagesize,fullpage=fullpage,yoff=yoff
;KEYWORDS: 
;   fullpage: if set then set the pagesize to 7 by 10 inches.
;             default is 7 by 5 inches.
;   yoff    : if supplied then move the plot from the default 
;             position this many inches on the page.
;DESCRIPTION:
;   Set the postscript output page size. This should only be called
;when you are plotting to the postscript device (ps,psimage,pscol).
;SEE ALSO:
;ps, pscol, psimage
;-
pro pagesize,fullpage=fullpage,yoff=yoff

on_error,2
if keyword_set(fullpage) then begin
    yoffLoc=.1
    if n_elements(yoff) ne 0 then yoffLoc= yoff
    device,ysize=10.,yoffset=yoffLoc,/inches
endif else begin
    yoffLoc=5
    if n_elements(yoff) ne 0 then yoffLoc= yoff
    device,yoffset=yoffLoc,ysize=5,/inches
endelse
return
end
