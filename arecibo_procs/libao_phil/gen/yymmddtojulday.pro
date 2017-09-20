;+
;NAME:
;yymmddtojulday - convert yymmdd to julian day
;
;SYNTAX: julday=yymmddtojulday(yymmdd)
;ARGS:
;    yymmdd[]: long    to convert
;RETURNS:
;    julday[]: double  julian day
;
;DESCRIPTION:
;   Convert from yymmdd to julian day.
;The input can be a scalar or an array.
;-
function yymmddtojulday,yymmdd

	yymmddL=yymmdd*1L
    yr=yymmddL/10000L
    ind=where(yr lt 50,count)
    if count gt 0 then yr[ind]=yr[ind]+2000
    ind=where((yr ge 50) and (yr lt 100),count)
    if count gt 0 then  yr[ind]=yr[ind]+1900
    mm=yymmddL/100L mod 100L
    dd=yymmdd mod 100L
    return,julday(mm,dd,yr,0,0,0)
end

