;+
;NAME:
;tdinpday - input a days worth of td archive data.
;  SYNTAX:  n=tdinpday(yymmdd,td,alldat=alldat)
;    ARGS:   
;  yymmdd:long  day to input
;KEYWORDS:
;  alldat:      if set then return all the data. The default is to return
;               a subset of the data.
;RETURNS:
;      n:long   number of samples we found 
;  td[n]:{}     structure holding the tiedown data. This format will
;               depend on the /alldat keyword.
;DESCRPIPTION:
;   Input a days worth of the tiedown archive data. This info is written
;once a second. the default data returned is:
;
;** Structure TD, 7 tags, length=56, data length=56:
;   SECM  LONG  0           seconds from midnite this sample
;   AZ    FLOAT 359.372     az position deg.
;   GR    FLOAT 2.40010     gregorian position deg
;   CH    FLOAT 8.83440     carriage house position deg.
;   POS   FLOAT Array[3]    tie positions [12,4,8] in inches (0 is up)
;   KIPS  FLOAT Array[2, 3] tiedown cable tensios in kips [2cbl,3td]
;   KIPST FLOAT 129.620     total kips (sum off kips[])
;
; If the alldat keyword is used then then entire data structure is returned:
;
;** Structure TDALL, 10 tags, length=276, data length=276:
;   SECM     LONG   0
;   STATWD   LONG   33
;   SYNCTRY  LONG   9
;   SYNCFAIL LONG   0
;   VTXTMMS  LONG   86400025
;   AZ       LONG   3593720
;   GR       LONG   24001
;   CH       LONG   88344
;   TEMPPL   LONG   0
;   SLV      STRUCT TDSLV Array[3]
;
;this is the same as the online data strcuture: see ~phil/vw/h/tieProgState.h
;-
function tdinpday,yymmdd,td,alldat=alldat
;
; input 1 days worth of td inp
;
;;  on_error,1
;
;   see how much of file is left
;
    istat=tdfindfile(yymmdd,fullname)
    if istat eq 0 then begin
         print,string(format='("could not find file for date: ",i6.6)',yymmdd)
         td=''
         return,0L
     endif
    openr,lun,fullname,error=err,/get_lun
    if err ne 0 then begin
        print,"could not open file " + fullname
        td=''
        return,0
    endif
    if keyword_set(alldat) then begin
        npts=tdinpall(lun,td,86500L)
    endif else begin
        npts=tdinp(lun,td,86500L)
    endelse
    free_lun,lun
    return,npts
end
