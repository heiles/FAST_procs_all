;+
;NAME:
;mmgetarchive - restore all or part of calibration archive
;SYNTAX: count=mmgetarchive(yymmdd1,yymmdd2,mm,rcvnum=rcvnum,dir=dir)
;ARGS: 
;      yymmdd1  : long    year,month,day of first day to get (ast)
;      yymmdd2  : long    year,month,day of last  day to get (ast)
;KEYWORDS:
;       rcvnum  : long  .. receiver number to extract:
;                       1=327,2=430,3=610,5=lbw,6=lbn,7=sbw,8=sbw,9=cb,$
;                       10=xb,12=sbn,100=430ch
;       dir     : string If provided, then this is the path to acces the
;                        archive save files. The default is:
;                        /share/megs/phil/x101/x102/runs/ .
;RETURNS:
;   mm[count]: {mueller} data found
;   count       : long   number of patterns found
;DESCRIPTION:
;   This routine will restore the x102 calibration data stored in 
;/share/megs/phil/x101/x102/runs. It is updated monthly. You specify
;the start and end dates of the data to extract. You can optionally
;specify a receiver with keyword rcvnum. Once the data has been input
;you can created subsets of the data with the mmget() routine.
;
;See mmrestore for a description of the structure format.
;
;EXAMPLES
;
;;get all data for jan02->apr02
; nrecs=mmgetarchive(020101,020430,mm)
;
;;get the cband data for apr02
;
; nrecs=mmgetarchive(020101,020430,mm,rcvnum=9)
;
;;from the cband data extract the 5000 Mhz data
; mm5=mmget(mm,count,freq=5000.)
;
;
;-
function mmgetarchive,yymmdd1,yymmdd2,mmall,rcvnum=rcvnum,dir=dir
;
; list the files in the directory
;
	mjdToJd=2400000.5D
	astToUtc=4D/24D
    on_error,1
    maxrecs=100000           ; y04 to apr13 hit 70000L
    if  not keyword_set(dir) then $
    dir='/share/megs/phil/x101/x102/runs/'
    cmd='ls ' + dir + 'c*sav'
    spawn,cmd,list
    nfiles=n_elements(list)
    juldates=dblarr(2,nfiles)       ; start,end juldates each file
;
;   yymmdd1 is ast
;
    julday1=yymmddtojulday(yymmdd1) + astToUtc ; go utc to ast
    julday2=yymmddtojulday(yymmdd2) + astToUtc ; go utc to ast
    usefile=intarr(nfiles)
    for i=0,nfiles-1 do begin 
        a=stregex(list[i],'c([0-9]*)_([0-9]*)\.sav',/extract,/subexpr ) 
;
;   convert begin,end file days to jul days
;
        yymmddf1=long(a[1]) 
        yymmddf2=long(a[2]) 
        juldayF1=yymmddtojulday(yymmddf1) + astToUtc
        juldayF2=yymmddtojulday(yymmddf2) + astToUtc
		eps=1e-6		; for floating point compares
;
;		a file can have data from previous day (if crosses midnite ast)
;       so test for start of file > end of request needs to have a day
;       of slop
;
		if ((juldayf2 + eps) lt julday1 ) or $
		   ((juldayf1 - eps) gt (julday2 +1)) then  begin
        endif else begin
            usefile[i]= 1
        endelse
;        print,yymmddf1,yymmddf2,usefile[i],$
;			[juldayF1,julday1,juldayF2,julday2]-mjdtojd,$
;format='("file:",i06,"-",i06," use:",i1," f1,r1,f2,r2:",4f14.5)'
    endfor
    mmall=replicate({mueller},maxrecs)
    ii=0
    for i=0,nfiles-1 do begin
        if usefile[i] then begin
            restore,list[i],/verb	
;
;           file overlaps 1 side of range, just use part in range
;
            nrecs=n_elements(mm)
            if n_elements(rcvnum) gt 0 then begin
                ind=where(mm.rcvnum eq rcvnum,nrecs)
                if nrecs gt 0 then mm=mm[ind]
            endif
            if nrecs gt 0 then begin
			   ; note: carl stored mjd in julday!
               ind=where(((mm.julday + mjdToJd) ge julday1) and $
                      ((mm.julday    + mjdToJd) lt julday2+1),count)
               if count gt 0 then begin
                  mmall[ii:ii+count-1]=mm[ind]
                  ii=ii+count
               endif
            endif
        endif
    endfor
    nrecs=ii
    if nrecs lt maxrecs then begin
        if nrecs eq 0 then begin
            mmall='' 
        endif else begin
            mmall=mmall[0:nrecs-1]
        endelse
    endif 
    return,nrecs
end
