;+
;NAME:
;fisecmidhms3 - secs from midnite to hh:mm:ss
;SYNTAX: label=fisecmidhms3(secsMidnite,hour,min,sec,float=float,$
;                           nocolon=nocolon)
;ARGS:
;   secsMidnite:    long/float/double  seconds from midnite to format.
;KEYWORD:
;   float:          if set then return secs at float
;nocolon:           if set then do not return colons
;
;RETURNS:
;   hour:   long    hour of day.
;    min:   long    minute of hour.
;    sec:   long    sec of hour.
;    lab:  string   formatted string: hh:mm:ss
;
;DESCRIPTION:
;   Convert seconds from midnight to hours, minutes, seconds and then
;return a formatted string hh:mm:ss. The 2 digit numbers are 0 filled to the
;left. If the input data is float/double and the float keyword is
;not provided,the the data is truncated to long. The float keyword rounds
;to 2 digits beyond the decimal point.
;-
function fisecmidhms3 , secs,h,m,s,float=float,nocolon=nocolon
    
    if not keyword_set(float) then begin
        i=long(secs+.5)
        h=i/3600
        m =(i - (h*3600))/60
        s =i   mod 60
        return,(keyword_set(nocolon)) $
        ? string(format='(i2.2,i2.2,i2.2)',h,m,s) $
        : string(format='(i2.2,":",i2.2,":",i2.2)',h,m,s)
    endif else begin
       secsL=secs
       s = (secsL  mod 60)
       if (s mod 1.) ge .9949 then begin        ; round to .01
        secsL=long(secs)+1L
        s= secsL mod 60
       endif
       i=long(secsL)
       h=i/3600
       m =(i - (h*3600))/60
;
;    fixup secs to integer an fract
;
       s1=long(s)
       s2=long((s mod 1) *100 + .5)
       return,(keyword_set(nocolon)) $
        ? string(format='(i2.2,i2.2,i2.2,".",i2.2)',h,m,s1,s2) $
        : string(format='(i2.2,":",i2.2,":",i2.2,".",i2.2)',h,m,s1,s2)
    endelse
        
end
