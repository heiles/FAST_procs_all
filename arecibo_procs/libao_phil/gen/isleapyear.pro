;+
;NAME:
;isleapyear - check if year is a leap year.
;SYNTAX: istat=isleapyear(year)
; ARGS:   year[]: int/long 4 digit year
; Returns:
;        istat[]: int  0 if not a leap year.
;                     1 if  a leap year.
;DESCRIPTION:
; Determine whether a year is a leap year in the gregorian calendar.
; Leap years are those years 
;  divisible by 4 and (!(divisible by 100) or (divisible by 400)).
; eg. (1900 is not a leap year, 2000 is).
;The input can be a scalar or an array.
;-
function isleapyear,year
; 
    if n_elements(year) gt 1 then begin
        val=intarr(n_elements(year))
        ind=where( ( (year mod   4) eq 0) and $
                   (((year mod 100) ne 0) or (year mod 400) eq 0),count)
        if count gt 0 then val[ind]=1
        return,val
    endif else begin
        if (year mod 4  ) ne 0 then return,0
        if (year mod 100) ne 0 then return,1
        if (year mod 400) eq 0 then return,1
        return,0
    endelse
end
