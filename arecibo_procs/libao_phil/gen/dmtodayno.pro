;+
;NAME:
;dmtodayno - convert day,mon,year to daynumber
;
;SYNTAX: daynum=dmtodayno(day,mon,year)
;ARGS:
;       day[] : int/long day of month
;      mon [] : int/long month of year 1..12
;      year[] : int/long  4 digit year
;
;RETURNS:
;      daynum[]: int/long  daynumber of year. First day of year is 1.
;
;DESCRIPTION:
;   Convert from dayofmonth, month , and year to daynumber of year.
;It also works with arrays.
;-
function dmtodayno,day,mon,year
    dayNoDat=[0,0,31,59,90,120,151,181,212,243,273,304,334,$
              0,0,31,60,91,121,152,182,213,244,274,305,335]

    ind=where(mon lt 1,count)
    if count gt 1 then mon[ind]=1
    ind=where(mon gt 12,count)
    if count gt 1 then mon[ind]=12
    index=isleapyear(year)*13
    return,dayNoDat[index + mon] + day
end

