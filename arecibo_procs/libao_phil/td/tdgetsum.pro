;+
;NAME:
;tdgetsum - input tiedown summary from archive.
;SYNTAX: nrecs=tdgetsum(yymmdd1,yymmdd2,tds)
;ARGS: 
;      yymmdd1  : long    year,month,day of first day to get (ast)
;      yymmdd2  : long    year,month,day of last  day to get (ast)
;RETURNS:
;   tds[nrecs] : {tdlr}   return summary data 
;        nrecs : long     number of records found
;DESCRIPTION:
;   Input the the tiedown summary information from the archive. The archive
;starts on 01oct01 and continues till the present day (new data is added
;to the archive at the end of the month). Each record is a {tdlr} structure
;and contains:
;** Structure TDLR, 9 tags, length=68, data length=68:
;DAY             DOUBLE   1.6951389  ; daynumber of year (count from 1)
;AZ              FLOAT  315.157      ; azimuth (gregorian side)
;GR              FLOAT   11.4503     ; gregorian za
;CH              FLOAT    8.83490    ; ch za
;POS             FLOAT  Array[3]     ; td jack positions inches (td12,td4,td8)
;KIPS            FLOAT  Array[2, 3]  ; td kips [2cables,td12/td4/td8]
;KIPST           FLOAT   112.920     ; total tension kips
;TEMP            FLOAT    76.2484    ; platform temp deg F
;HGHT            FLOAT  1256.35      ; platform average hgt feet above sealevel
;
;   Since the structure only has the daynumber of the year, records of the
;same daynumber can not be differentiated by year.
;   When accessing the data, there will be about 43200 entries per month.
;The data is normally sampled once a minute. Occasionally there will be
;incomplete data. This is caused by the distomats not recording the heights
;(because of bad weather) or temperatures not being recorded. I have tried
;to flag this data with zeros. The tiedown tensions occasionally drift
;(or actually jump after a lightning strike). A good way to test for this
;is by looking at the difference in the tensions for individual tiedowns.
;There are two cables with two tension measurements on each tiedown block.
;These values should be the same.
;
;SEE ALSO:
;-
function tdgetsum,yymmdd1,yymmdd2,tdsgl
;
; list the files in the directory
;
;    on_error,1
        
    year =(yymmdd1/10000L) + 2000L
    year2=(yymmdd2/10000L) + 2000L
    
    if year ne year2 then begin
        print,'tdgetsum can not span years...',string(07b)
        return,0
    endif
    
    dir='/share/megs/phil/x101/td/'
    maxrecs=200000L
    recgrow=maxrecs/2l
    cmd='ls ' + dir + 'tds_*.sav'
    spawn,cmd,list
    nmonfiles=n_elements(list)
    dayNumAr=dblarr(2,nmonfiles)       ; start,end juldates each file
;
;   yymmdd1 is ast
;
    daynum1=dmtodayno(yymmdd1 mod 100,(yymmdd1/100L) mod 100,year)
    daynum2=dmtodayno(yymmdd2 mod 100,(yymmdd2/100L) mod 100,year)
    useMon=intarr(nmonfiles)

    for i=0,nmonfiles-1 do begin 
        a=stregex(list[i],'tds_([0-9]*)\.sav',/extract,/subexpr ) 
;
;       convert begin,end day each month to daynums
;
        yymm   =long(a[1]) 
        yymmddf1=yymm*100L + 01
        if (yymm/100) +2000L  ne  year then goto,botloop1
        daynumf1=dmtodayno(yymmddf1 mod 100,(yymmddf1/100L) mod 100,year)

        nextyymm= yymm + 1
        if (nextyymm mod 100 eq 13) then  begin
            daynumf2=daynumf1 + 30L
        endif else begin
            nextyymm= nextyymm*100L + 1
            daynumf2=dmtodayno(nextyymm mod 100,(nextyymm/100L) mod 100,year)
        endelse
        if (daynumf2 lt daynum1) or (daynumf1 gt daynum2) then begin
        endif else begin
            useMon[i]= 1
        endelse
;        print,list[i]," use:",usefile[i]
botloop1:
    endfor
    ind=where(useMon eq 1,count)
    if count eq 0 then return,0
    tdsGl=replicate({tdlr},maxrecs)
    inprecs=0L
    for i=0,nmonfiles-1 do begin
        if useMon[i] then begin
            restore,list[i]
;
;           file overlaps 1 side of range, just use part in range
;
            nrecs=n_elements(tds)
            if nrecs eq 0 then goto,botloop
            ind=where(((tds.day) ge daynum1) and $
                      ((tds.day) le (daynum2+1.d)),nrecs)
;
;           add to the big array, make sure we have space..
;
            if nrecs gt 0 then begin
                  if (inprecs + nrecs) gt maxrecs then begin 
                     tdsGlT=temporary(tdsGl)
                     n=maxrecs+recgrow
                     tdsGl =replicate({tdlr},n)
                     tdsGl[0:maxrecs-1]=tdsGlT
                     tdsGlT=''
                     maxrecs=maxrecs + recgrow       
                  endif
                  tdsGl[inprecs:inprecs+nrecs-1l]=tds[ind]
                  tds=''
;
                  inprecs =inprecs + nrecs
            endif     ;
        endif         ;
botLoop:
    endfor
    if inprecs lt maxrecs then begin
        if inprecs eq 0 then begin
            tdsGl=''
        endif else begin
            tdsGl=tdsGl[0:inprecs-1]
        endelse
    endif
    return,inprecs
end
