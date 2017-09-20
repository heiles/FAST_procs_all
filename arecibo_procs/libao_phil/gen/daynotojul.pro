;+
;NAME:
;daynotojul - convert daynumber,year to julday
;
;SYNTAX: julday=daynotojul(dayno,year)
;ARGS:
; dayno[n]: int/long/double daynumber of year 1..365or 366
;  year[n]: int/long  4 digit year
;KEYWORDS:
; gmtoffHr: double   offset from gmt for dayno,year. gmtOffHr/24. will
;                    be added to the computed julian days. Probably best
;                    used when dayno id double or float.
;RETURNS:
;      julday[n]:double julian day. This starts at noon
;DESCRIPTION
;   convert daynumber and year to julian daynumber with fraction of day.
;Method:
; 1. loop for each year.
;   a. take the first day of the year (day1), convert it to long (iday).
;   b. convert iday1 to julianday
;   c. for all the data of the year juldayYr=julday1 + day-iday1
;-
function daynotojul,dayno,year,gmtoffHr=gmtoffHr

;
;   loop for number of years
;
    yuniq=year[uniq(year,sort(year))]           ; get the years
    juldayA=dblarr(n_elements(dayno));hold the juliandays
;
;   loop on the years
;
    for i=0,n_elements(yuniq)-1 do begin
        ind=where(year eq yuniq[i],count)
        days=dayno[ind]
        days1=long(min(days))
        dm=daynotodm(days1,yuniq[i]) ; to day,month
        julday1=julday(dm[1],dm[0],yuniq[i],0,0,0) ; first jul day , midnite
        juldayA[ind]=julday1 + days - days1 
    endfor
    if keyword_set(gmtOffHr) then juldayA=julDayA + gmtOffHr/24.D
    return,juldayA
end

