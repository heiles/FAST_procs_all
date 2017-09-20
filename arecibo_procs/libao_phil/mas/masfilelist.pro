;+
;NAME:
;masfilelist - get list of mas files (using perl)
;SYNTAX: nfiles=masfilelist(dirBase,fnmiar,projId=projId,year=year,mon=mon,$
;               day=day,yymmdd=yymmdd,bm=bm,band=band,grp=grp,num=num,$
;               appBm=appBm,pdev=pdev,psrfits=psrfits,dirI=dirI,verb=verb)
;
;ARGS:
;   dirBase: char    base directory to start search
;                    if '' then use default /share/pdata
;
;KEYWORDS:
; projId   : string  beginning of filename.if null then any
;                    You can also use a reg exp as eg:
;                    proj='x101_7_[12]' 
;   year   : long    year. < 0==> any year
;    mon   : long    mon . < 0--> any month
;    day   : long    day . < 0--> any day
; yymmdd   : lond    080615.. date for data. If supplied, ignor year,mon,day
;                    format is yymmdd or yyyymmdd. If you want to search
;                    and entire month yymm00 or yyyymm00 will also work.
;       bm : int   beam to use 0..6. if not present or < 0 use all beams
;     band : int   band to get, 0 or 1 .. not present or <0  --> all
;     grp  : int   grp to get 0 or 1. .. not present or < 0 --> check 
;                  both g0,g1. grp 0 files on psrv1-7, grp1 on 8-14
;     num  : long  sequence number. If not present or < 0 get all
;     appBm:       if set then append (bm+1) to the end of dirBase when
;                  defining the initial base directories
;     pdev :       if set then look for .pdev files rather than .fits
;   psrfits:       if set then assume filename contains srcname
;     dirI : strarr(2): directory info. If the files are in a non standard place
;                  then pass in location in dirI
;                   dirI[0]=prefix  for dir: /share/pdata
;                        Num 1..n goes here
;                   dirI[1]=postfix for dir: /pdev
;              
;RETURNS:
;   ntot    : long  number of .fits files found
;fnmIAr[ntot]:{}    an array of structures holding info on the
;                   mas files found
;DESCRIPTION:
;   Search for mas fits files or psrfits files (with the /psrfits keyword).
;The search starts in /share/pdataN by default. You specify the base directory and the 
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
;   src             string     ''  if psrfits file
;   bm              int        0
;   band            int        0 
;   grp             int        0 
;   num             long       0
;-
function masfilelist,dirBase,fnmIAr,projId=projId,year=year,mon=mon,day=day,$
                bm=bm,band=band,grp=grp,num=num,appBm=appBm,pdev=pdev,$
                yymmdd=yymmdd,psrfits=psrfits,dirI=dirI,verb=verb
;
	opts='--incidl';
	dirIL=["/share/pdata","/pdev/"]
	if n_elements(dirI) eq 2 then dirIL=dirI
    if not keyword_set(appbm) then begin
		opts+=" --onedir"
		if dirBase ne "" then dirIL[0]=dirBase
	endif
	opts=opts + " --dirI=" + '"' + dirIL[0] + "," + dirIL[1] + '"'
	if keyword_set(projId) then opts+=" --proj="+ "'" + projId + "'"
	if n_elements(year) gt 0 then $
		 opts+=" --year="+string(format='(i0)',year)
	if n_elements(mon) gt 0 then $
		 opts+=" --mon="+string(format='(i0)',mon)
	if n_elements(day) gt 0 then $
		 opts+=" --day="+string(format='(i0)',day)
	if n_elements(bm) gt 0 then $
		 opts+=" --bm="+string(format='(i0)',bm)
	if n_elements(band) gt 0 then $
		 opts+=" --band="+string(format='(i0)',band)
	if n_elements(grp) gt 0 then $
		 opts+=" --grp="+string(format='(i0)',grp)
	if n_elements(num) gt 0 then $
		 opts+=" --num="+string(format='(i0)',num)
	if keyword_set(pdev) then $
		 opts+=" --pdev"
	if (n_elements(yymmdd) gt 0) then begin $
		 if yymmdd gt 0 then $
		 	opts+=" --yyyymmdd="+string(format='(i0)',yymmdd)
	endif
	if keyword_set(psrfits) then $
		 opts+=" --psrfits"
	opts+=" --sort"
;
; see if we loop appending bm+2 to dirBase
;
	dir=aodefdir() + "etc/bin/"
	cmd=dir + "mockls " + opts
	now1=systime(1)
	spawn,cmd,flist
	now2=systime(1)
	ntot=n_elements(flist)
    if ntot eq 0 then return,0
	if flist[0] eq '' then return,0

;    a={ dir  : '',$;
;        fname: '',$;
;        proj : '',$; 
;        date : 0L,$;
;		src  : '',$;
;        bm   : 0 ,$; 0-6
;        band : 0 ,$; 0,1           int        0 
;        grp  : 0 ,$; 0,1
;        num  : 0L }
    fnmIAr=replicate({masfnmpars},ntot)
	if keyword_set(psrfits) then begin
	  for i=0L,ntot-1 do begin
		a=strsplit(flist[i]," ",/extract)
        fnmIAr[i].dir   =a[0]
        fnmIAr[i].fname =a[1]
        fnmIAr[i].proj  =a[2]
        fnmIAr[i].date  =long(a[3])
     	fnmIAr[i].src   =a[4] 
     	fnmIAr[i].bm    =fix(a[5])
     	fnmIAr[i].band  =fix(a[6])
     	fnmIAr[i].grp   =fix(a[7])
     	fnmIAr[i].num   =long(a[8])
	  endfor
	endif else begin
	  for i=0L,ntot-1 do begin
		a=strsplit(flist[i]," ",/extract)
        fnmIAr[i].dir   =a[0]
        fnmIAr[i].fname =a[1]
        fnmIAr[i].proj  =a[2]
        fnmIAr[i].date  =long(a[3])
     	fnmIAr[i].bm    =fix(a[4])
     	fnmIAr[i].band  =fix(a[5])
     	fnmIAr[i].grp   =fix(a[6])
     	fnmIAr[i].num   =long(a[7])
	  endfor
	endelse
	now3=systime(1)
	 if  keyword_set(verb) then $
        print,"FileSrch:",now2-now1," split:",now3-now2
    return,ntot
end
