;+
;NAME:
;immktm  - make the time array array for a days worth of data.
;SYNTAX:  hr=immktm(d)
;
;ARGS:
;   d:{iminpday} days worth of data input using iminpday.
;RETURNS:
;  hr[n]:float   hour of day for each record in d.
;
;DESCRIPTION:
;   Compute the time array for a days worth of data. The data is
;returned in hours from midnite (ast).
;-
pro immktm,d,y
;
; d     {imday} days data, extract the times
; tm    float[]  return the times .. hours
;
    y= d.r.h.secmid / 3600.
    return
end
