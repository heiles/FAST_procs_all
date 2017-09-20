;+
;NAME:
;daynotodm - convert daynumber to day,month
;
;SYNTAX: [day,month]=daynotodm(daynum,year)
;ARGS:
;       daynum: int/long daynumber of year 1..365or 366
;      year : int/long  4 digit year
;RETURNS:
;      [day,month] as a vector. 
;DESCRIPTION
;   convert daynumber and year to day of month (1..31) and 
;month of year (1.l12).
;-
function daynotodm,dayno,year
    dayNoDat=[[0,31,59,90,120,151,181,212,243,273,304,334,365],$
              [0,31,60,91,121,152,182,213,244,274,305,335,366]]

    if isleapyear(year) then begin
       indyr=1
       daysInYear=366
    endif else begin
       indyr=0
       daysInYear=365
    endelse
    if dayno lt 1 then dayno = 1
    if dayno gt daysInYear then dayno = daysInYear
    ind=where(daynodat[*,indyr] ge dayno,count)
    mon=ind[0]
    return,[dayno-dayNoDat[ind[0]-1,indyr],mon]
end

