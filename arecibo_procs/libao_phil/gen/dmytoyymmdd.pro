;+
;NAME:
;dmytoyymmdd - convert ddMonyy to yymmdd
;
;SYNTAX: yymmdd=ddmytoyymmdd(ddMONyy)
;ARGS:
;       ddMONyy: string convert 10mar02 to 020210 etc..
;RETURNS:
;        yymmdd: long return 0 if bad format..
;         
;DESCRIPTION
;   The datataking files use ddMONyy in the name where dd is the day
;of the month, MON is a 3 letter abbreviation for the name,
;and yy is the last two digits of the year. This routine will
;convert the value into a long yymmdd 
;-
function dmytoyymmdd,ddMonyy
    monlist=['jan','feb','mar','apr','may','jun','jul','aug','sep','oct',$
        'nov','dec']
    day=long(strmid(ddMonyy,0,2))
    yr =long(strmid(ddMonyy,5,2))
    ind=where(strmid(ddMonyy,2,3) eq monlist,count)
    if count gt 0 then begin
        mon=ind+1
    endif else begin
        return,0
    endelse
    return,yy*10000L+mon*100+day
end

