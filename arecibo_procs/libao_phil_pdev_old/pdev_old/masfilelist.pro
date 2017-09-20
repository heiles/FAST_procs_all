;+
;NAME:
;masfilelist - get list of mas files 
;SYNTAX: nfiles=masfilelist(dirBase,fnmiar,projId=projId,year=year,mon=mon,$
;               day=day,yymmdd=yymmdd,bm=bm,band=band,grp=grp,num=num,$
;               appBm=appBm,pdev=pdev)
;
;ARGS:
;   dirBase: char    base directory to start search
;                    if '' then use default /share/pdata
;
;KEYWORDS:
; projId   : string  beginning of filename.if null then any
;   year   : long    year. < 0==> any year
;    mon   : long    mon . < 0--> any month
;    day   : long    day . < 0--> any day
; yymmdd   : lond    080615.. date for data. If supplied, ignor year,mon,day
;       bm : int   beam to use 0..6. if not present or < 0 use all beams
;     band : int   band to get, 0 or 1 .. not present or <0  --> all
;     grp  : int   grp to get 0 or 1. .. not present or < 0 all groups
;     num  : long  sequence number. If not present or < 0 get all
;     appBm:       if set then append (bm+1) to the end of dirBase when
;                  defining the initial base directories
;     pdev :       if set then look for .pdev files rather than .fits
;RETURNS:
;   ntot    : long  number of .fits files found
;fnmIAr[ntot]:{}    an array of structures holding info on the
;                   mas files found
;DESCRIPTION:
;   Search for mas fits files. You specify the base directory and the 
;filename characteristics to search for (via the keywords). 
; Example:
;   The spectrometer files are nfs mounted to
;  /share/pdataN/pdev/ 
;
;   This would require dirBase="/share" which would make the search to
;broad. The appBm keyword can narrow this down. If set, it will append
;all of the beam numbers +1 to to the end of dirBase before searching..
;
; so dirBase=/share/pdata  
;  and the searches would go thru
;      /share/pdata1, /share/pdata2, .. etc..
;
;   The returned structure contains:
; nmAr='/share/pdata/mas/agc110443/x107.20070123.agc110443.b0a.00000.mas'
; istat=masfilelist(nmAr,fnmI)
; help,fnmI,/st
;* Structure masfnmInfo   8 tags, length=60, data length=60:
;   DIR             STRING    '/share/pdata1/pdev/'
;   FNAME           STRING    'philtest.20080219.b0s0g0.00000.fits'
;   PROJ            STRING    'philtest'
;   DATE            LONG          20080219
;   bm              int        0
;   band            int        0 
;   grp             int        0 
;   num             long       0
;-
function masfilelist,dirBase,fnmIAr,projId=projId,year=year,mon=mon,day=day,$
                bm=bm,band=band,grp=grp,num=num,appBm=appBm,pdev=pdev,$
				yymmdd=yymmdd
;
	suffix=(keyword_set(pdev))?"\.pdev":"\.fits"
    maxfiles=500L
;
;   build the search pattern
;
    if ((n_elements(projId) eq 0) || (projId eq '' )) then  begin
        srchPat="[^.]*" + "\."
    endif else begin
        srchPat=projId + "\."
    endelse
;
;   date
;
	yrl=0&monl=0&dayl=0
	if n_elements(yymmdd) gt 0 then begin
		yrl =yymmdd/10000L
		if yrl eq 0 then yrl=2000L
	    monl=(yymmdd/100L) mod 100L
	    dayl=(yymmdd mod 100L)
	endif else begin
		if (n_elements(year) ne 0) and (year ne 0) then yrl=year
 		if n_elements(mon)  ne 0 then monl=mon
 		if n_elements(day)  ne 0 then dayl=day
	endelse
    if (yrl eq 0) then  begin
        srchPat+='20[0-9][0-9]'
    endif else begin
        yrl=(yrl lt 99)?yrl + 2000:yrl
        srchPat+=string(format='(i4.4)',yrL)
    endelse

    if ((monl le 0 )) then  begin
        srchPat+='[01][0-9]'
    endif else begin
        srchPat+=string(format='(i2.2)',monl)
    endelse
    if ((dayl le 0 )) then  begin
        srchPat+='[0-3][0-9]\.'
    endif else begin
        srchPat+=string(format='(i2.2,"\.")',dayl)
    endelse
;
;  bm,spectra,grp
;
    bm=(n_elements(bm) eq 0)?-1:bm
    bmS=(bm ge 0 )?string(format='("b",i1)',bm): 'b[0-6]'   
    band=(n_elements(band) eq 0)?-1:band
    bandS=(band ge 0 )?string(format='("s",i1)',band):'s[0-1]'  
    grp=(n_elements(grp) eq 0)?-1:grp
    grpS=(grp ge 0)?string(format='("g",i1)',grp):'g[0-1]'  
;
    srchPat+=(bmS + bandS + grpS + "\.")
;
; number
;
    if n_elements(num) gt 0 then begin
        numS=string(format='(i5.5)',num)
    endif else begin
        numS='[0-9][0-9][0-9][0-9][0-9]'
    endelse
    srchPat+=(numS + suffix)
;
; see if we loop appending bm+2 to dirBase
;
    ntot=0L
    dirBL=(dirBase eq '')?'/share/pdata':dirBase
    if not keyword_set(appBm) then  begin
        flist=file_search(dirBL,srchPat,count=ntot,/quote)
    endif  else  begin
        len=strlen(dirBL)
        dirL=(strmid(dirBL,0,1,/reverse_offset) eq "/")? $
              strmid(dirBL,0,len-1):dirBL
        bmAr=(bm lt 0)?[0,1,2,3,4,5,6]:[bm]
        for i=0,n_elements(bmAr)-1 do begin
            dirBaseLL=dirL + string(format='(i1)',bmAr[i]+1)
            ff=file_search(dirBaseLL,srchPat,count=nfiles,/quote)
            if nfiles gt 0 then begin
                flist=(ntot eq 0)?ff:[flist,ff]
                ntot+=nfiles
            endif
        endfor
    endelse
    if ntot eq 0 then return,0
    a={ dir  : '',$;
        fname: '',$;
        proj : '',$; 
        date : 0L,$;
        bm   : 0 ,$; 0-6
        band : 0 ,$; 0,1           int        0 
        grp  : 0 ,$; 0,1
        num  : 0L }
    fnmIAr=replicate(a,ntot)
;                             dir       projid  date  obs??  bm
	if (keyword_set(pdev)) then begin
    matchList=stregex(flist,$
;   dir  proj    date  obs?? bm     band    grp      num
"^(.*/)([^.]+)\.([0-9]+)\.[^.]*b([0-6])s([0-1])g([0-1])\.([0-9]+)\.pdev",$
               /extract,/subexpr)
	endif else  begin
    matchList=stregex(flist,$
;   dir  proj    date  obs?? bm     band    grp      num
"^(.*/)([^.]+)\.([0-9]+)\.[^.]*b([0-6])s([0-1])g([0-1])\.([0-9]+)\.fits",$
               /extract,/subexpr)
	endelse
    fnmIAr.dir =reform(matchList[1,*])
    fnmIAr.proj=reform(matchlist[2,*])
    fnmIAr.date=reform(matchlist[3,*])
    fnmIAr.bm  =reform(matchlist[4,*])
    fnmIAr.band=reform(matchlist[5,*])
    fnmIAr.grp =reform(matchlist[6,*])
    fnmIAr.num =reform(matchlist[7,*]) 
	if (keyword_set(pdev)) then begin
    	fnmIAr.fname=reform($
                 (stregex(flist,"^.*/(.*\.pdev)",/extract,/subexpr))[1,*])
	endif else begin
    	fnmIAr.fname=reform($
                 (stregex(flist,"^.*/(.*\.fits)",/extract,/subexpr))[1,*])
	endelse
    return,ntot
end
