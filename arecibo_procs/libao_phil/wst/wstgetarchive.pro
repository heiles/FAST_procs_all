;+
;NAME:
;wstgetarchive - restore all or part of calibration archive
;SYNTAX: count=wstgetarchive(yymmdd1,yymmdd2,ball,ndays=ndays,dir=dir,$
;                            maxDays=maxDays)
;ARGS: 
;yymmdd1  : long    year,month,day of first day to get (ast)
;yymmdd2  : long    year,month,day of last  day to get (ast)
;KEYWORDS:
;    ndays: long    number of days to return. If supplied then
;                   ignore yymmdd2. 
;      dir: string  If provided, then this is the path to 
;                         acces the archive save files. The default 
;                         is:/share/megs2_u1/wst/ .
;   maxDays: long   by default the program will limit you to
;                   about 366 days (this is about 240Mbytes). If 
;                   you want more data, than set maxdays to the
;                   maximum allowable value (be sure your computer
;                   has enough memory).
;RETURNS:
;   ball[count]: {wst}     number of samples returned
;DESCRIPTION:
;   This routine will input weather station data stored in the
;idl archive. This archive is updated at the end of each month
;from the online file. 
;You specify the start and end dates of the data to extract. 
;
;	A single month will consist of about 20Mbytes of data.
;
;EXAMPLES
;
;;get all data for jan14
; nrecs=wstgetarchive(140101,140131,ball)
;
;-
function wstgetarchive,yymmdd1,yymmdd2,ball,ndays=ndays,dir=dir,$ 
				maxDays=maxDays 
;
; list the files in the directory
;
	secsPerPnt=15.
	pntsDay=86400D/secsPerPnt
	maxDaysL=(n_elements(maxDays) eq 1)?maxDays:366D
	astToUtc=4D/24D
    on_error,1
    dirl='/share/megs2_u1/wst/'
	if n_elements(dir) eq 1 then dirl=dir
    cmd='ls ' + dirl + 'wst_*.sav'
    spawn,cmd,list
    nfiles=n_elements(list)
    juldates=dblarr(2,nfiles)       ; start,end juldates each file
;
;   yymmdd1 is ast
;
    julday1=yymmddtojulday(yymmdd1) + astToUtc ; go utc to ast
	if n_elements(ndays) eq 1 then begin
		julday2=julday1 + ndays - 1L
	endif else begin
    	julday2=yymmddtojulday(yymmdd2) + astToUtc ; go utc to ast
	endelse
	ndaysReq=long(julday2 - julday1 + 1 + .5)
	if ndaysReq gt maxDaysL then begin
		print,"max days allowed is maxDays:",maxDaysL," You requested:",ndaysReq
		print,"increase maxdays or decrease the date range"
		return,-1
	endif
	slop=5000L
	maxPnts=ndaysReq*pntsDay + slop
    usefile=intarr(nfiles)
    for i=0,nfiles-1 do begin 
        a=stregex(list[i],'wst_([0-9]*)\.sav',/extract,/subexpr ) 
		if a[0] eq '' then continue
		yyyymm=long(a[1])
		year=yyyymm/100L
		mon=yyyymm mod 100l
		daysInMon=daysinmon(mon,year)
;
;   convert begin,end file days to jul days
;
        yymmddf1=yyyymm * 100l + 1
        yymmddf2=yyyymm * 100l + daysInMon
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
	
	ii=0L
	done=0
	verb=1
    for i=0,nfiles-1 do begin
        if usefile[i] then begin
            restore,list[i],verb=verb
;
;           file overlaps 1 side of range, just use part in range
;
            nrecs=n_elements(bar)
            if nrecs gt 0 then begin
			   ;
               ind=where(((bar.jd) ge julday1) and $
                      ((bar.jd) lt julday2+1),count)
               if count gt 0 then begin
				  if ii eq 0 then ball=replicate(bar[0],maxPnts)
				  if (ii + count) ge maxPnts then begin
				  		count=maxPnts - ii -1L
						print,"truncating request date range.. ball too small"
						done=1
				  endif
                  bAll[ii:ii+count-1]=bar[ind]
                  ii=ii+count
				  if done then break
               endif
            endif
        endif
    endfor
    npnts=ii
    if npnts lt maxpnts then begin
        if npnts eq 0 then begin
            ball=''
        endif else begin
            ball=ball[0:npnts-1]
        endelse
    endif 
    return,npnts
end
