;+
;NAME:
;dbit - convert to db's
; 
;SYNTAX: a=dbit(b,minval=minval)
;
;ARGS:        b[]:input value
;KEYWORDS: minval: float.. all values < this set to minval before log
;RETURNS:     a[]: b in db's
;-
function dbit,b,minval=minval

    if not keyword_set(minval) then minval=0.
    if minval ne 0. then begin
        return,alog10((b > minval)/(max(b>minval)))*10.
    endif else begin
        return,alog10(b/max(b))*10.
    endelse
end
