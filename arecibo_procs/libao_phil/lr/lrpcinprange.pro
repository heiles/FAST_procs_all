;+
;NAME:
;lrpcinprange - input a range of pc laser ranging data.
;SYNTAX: istat=lrpcinprange(year,mmdd1,mmdd2,b,ext=ext)
;ARGS:
;    year: long  4 digit year of interest
;   mmdd1: long  mon,day to start
;   mmdd2: long  mon,day to end
;KEYWORDS:
;     ext:       if set then try and return extended info.. az,gr,ch positions. 
;                This uses the tdsummary info. It is not available for the
;                current month.
;  RETURNS:
;  b[npts]: {lrdat} array holding the data
;   istat :  int    number of entries found
;                   use current year.
;                   -1 if an error  
;
;DESCRIPTION:
;   The routine inputs multiple days worth of laser ranging data. It returns the
;data from the laser ranging PC as well as the heigts converted to feet
;above sea level (the conversion factors were measured in 1990 and have
;probably changed!). The data available goes back to 2000. The routine
;constrains you to 1 year at a time. see lrpcinp for a description
;of the data.
;
;NOTES:
;   You need to do @lrinit once before calling this routine to define the
;   {lrdat} structure.
;
;-
function lrpcinprange,year,mmdd1,mmdd2,bb,ext=ext
;
;   create the day:
;   
    daynum1=dmtodayno(mmdd1 mod 100,mmdd1/100,year)
    daynum2=dmtodayno(mmdd2 mod 100,mmdd2/100,year)
;
; check that daynum 2 does not go beyond end of year
;
    if isleapyear(year) then begin
        daynum2=(daynum2 < 366)
    endif else begin
        daynum2=(daynum2 < 365)
    endelse
    if daynum2 lt daynum1 then begin
        print,'mmdd1 must come before mmdd2'
        return,-1
    endif
    nrecs=0L
    maxrecday=720L   ; if run at once a minute
    ndays=(daynum2-daynum1) + 1L
    fact=2L
    if ndays gt 100 then fact=1.3
    maxrecs=long(ndays*maxrecday*fact)

    for i=daynum1,daynum2 do begin
        nfound=lrpcinp(0,b,daynum=i,year=year,ext=ext)  
        if nfound gt 0 then begin
            if i eq daynum1 then begin
                bb=replicate(b[0],maxrecs)
            endif
            bb[nrecs:nrecs+nfound-1L]=b
            nrecs=nrecs+nfound
        endif
    endfor
    if nrecs lt maxrecs then bb=temporary(bb[0:nrecs-1])
    return,nrecs
end
