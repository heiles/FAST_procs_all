;+
;NAME:
;daysinmon - return number of days in this month
;
;SYNTAX: days=daysinmon(mon,year)
;ARGS:
;      mon  : int/long month of year 1..12
;      year : int/long  2/4 digit year
;
;RETURNS:
;      days : int/long  number of days in this month
;
;DESCRIPTION:
;   Return the number of days in the specified month.
;If two digit year is entered then value gt 50 are 1999
;-
function daysinmon,mon,year
;               1   2  3  4  5  6  7  8  9 10 11 12
    daymon  =[0,31,28,31,30,31,30,31,31,30,31,30,31,$
              0,31,29,31,30,31,30,31,31,30,31,30,31]

    if mon lt 1  then mon = 1   
    if mon gt 12 then mon = 12
    yrl=year
    if yrl lt 1000 then yrl=(yrl gt 50)?yrl+1900:yrl+2000L
    index=isleapyear(yrl)*13
    return,daymon[index + mon]
end

