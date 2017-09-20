;+
;Name:
;ephmaord - read in an ao ephmeris file.
;SYNTAX: n=ephmaord(fname,ephmI,rangedop=rangedop,$
;                   yyyymmdd1=yyyymmdd1,yyyymmdd2=yyyymmdd2)
;ARGS:
;file: string filename
;KEYWORDS:
;rangedop: if true then range, doppler ar last two fields
;yyyymmdd1: double  first record to return is >= to this
;                  utc date. includes fraction of day.
;yyyymmdd2: double  last record returned is <= this utc date
;                  e. includes fraction of day.
;RETURNS:
;n   : int    -1  if can't read file
;             >0   number of entries
;ephmI: {}  structure holding info. 
;DESCRIPTION:
;	input an ao ephemeris file. This is the format
;used by the pointing program. The format is:
;       UTC            RA         DEC 
; yyyy-mm-dd hh:mm:ss hhmmss.ss +ddmmss.s   az   el
;
;	the ra,dec can be j2000 or of date (current).
; The data is returned in the structure
; help,ephmI,/st
;
;   TARGET          STRING    'Moon (301)'
;   J2000           BYTE         0
;   N               LONG               212
;   DAT             STRUCT    -> <Anonymous> Array[212]
;help,ephmI.dat,/st
;   JD              DOUBLE           2456503.9
;   YYYYMMDD        LONG          20130730 utc
;   SECMID          FLOAT           32460.0 utc
;   RAHR            DOUBLE           2.8377028
;   DECD            DOUBLE           16.014861
;   AZD             DOUBLE           91.399200 .. Source azimuth
;   ZAD             DOUBLE           24.834300
; if keyword set /rangedop add:
;   range           double           AU
;   dop             double           km/sec .. neg is approaching
;  
;
;  See /share/megs/phil/x101/ephm/ obs_tbl.sc and hortoao.pl to grab
; horizons file and convert to ao format
;-
function ephmaord,fname,ephmI,rangedop=rangedop,yyyymmdd1=yyyymmdd1,$
				yyyymmdd2=yyyymmdd2
;
;   read # comments, we want the coord sys
;
	comment='#'
	n=readasciifile(fname,inp,comment=";")
	if n le 0 then return,n
	icur=0L
	target=''
	crdJ=0
	for i=0,n-1 do begin
		icur=i
		if (strmid(inp[i],0,1) ne comment) then break
		mstr="# Target body name:"
		len=strlen(mstr)
		if strcmp(inp[i],mstr,len) then begin
			target=strtrim(strmid(inp[i],len,20),2)
			continue
		endif 
		mstr="#  Date__("
		len=strlen(mstr)
		if strcmp(inp[i],mstr,len) then begin
			crdJ=strpos(inp[i],'apparent') eq -1
			continue
		endif 
	endfor
	if keyword_set(rangedop) then begin
	dat={ jd: 0d ,$
		yyyymmdd:0L,$ ; utc
		secMid:0.  ,$ ; utc
        raHr:0d,$
        decD:0d,$
		azD :0d,$
		zaD :0d,$
	    range:0d,$
	    dop:0d}
	endif else begin
		dat={ jd: 0d ,$
			yyyymmdd:0L,$ ; utc
			secMid:0.  ,$ ; utc
        	raHr:0d,$
        	decD:0d,$
			azD :0d,$
			zaD :0d}
	endelse
	if (keyword_set(rangedop)) then begin
	a=stregex(inp[icur:*],$
;yyyy    mm     dd     hh     mm    ss     hhmmss     ddmmss.s range.   dop
"([0-9]+)-([0-9]+)-([0-9]+) +([0-9]+):([0-9]+):([0-9]+) +([0-9.]+) +([0-9.+-]+) +([0-9.]+) +([0-9.]+) +([0-9.]+) +([0-9.-]+)" ,$
	/sub,/extr)
	endif else begin
	a=stregex(inp[icur:*],$
;yyyy    mm     dd     hh     mm    ss     hhmmss     ddmmss.s   
"([0-9]+)-([0-9]+)-([0-9]+) +([0-9]+):([0-9]+):([0-9]+) +([0-9.]+) +([0-9.+-]+) +([0-9.]+) +([0-9.]+)" ,$
	/sub,/extr)
	endelse
	ii=where(a[0,*] ne '',cnt)
	a=a[*,ii]
	nn=n_elements(a[0,*])
	ii=lindgen(nn)

	yyyymmdd=reform(long(a[1,*])*10000L + long(a[2,*])*100L + long(a[3,*]))
	secmid=long(reform(a[4,*]))*3600L +  long(reform(a[5,*]))*60l + long(reform(a[6,*]))
	yyyymmddF=yyyymmdd + secmid/86400d
	if (keyword_set(yyyymmdd1) or keyword_set(yyyymmdd2)) then begin
		y0=(keyword_set(yyyymmdd1))?yyyymmdd1:20000101d
		if (y0/10000L lt 99) then y0+=20000000D
		y1=(keyword_set(yyyymmdd2))?yyyymmdd2:22000101d
		if (y1/10000L lt 99) then y1+=20000000D
		ii=where((yyyymmddF ge y0) and (yyyymmddF le y1),nn)
		if nn eq 0 then begin
			ephmI=''
			return,0
		endif
	endif
	ephmi={$
		target:target,$
		j2000 : crdJ ,$ ; 1--> j2000, 0 --> current
		n     : nn,   $ ; number of entries
		dat   :replicate(dat,nn)$
	}
	ephmI.dat.yyyymmdd=yyyymmdd[ii]
	ephmI.dat.secMid =secMid[ii]
	ephmI.dat.rahr=hms1_hr(double(reform(a[7,ii]))) 
	ephmI.dat.decD=dms1_deg(double(reform(a[8,ii]))) 
	ephmI.dat.azD=double(reform(a[9,ii])) 
	ephmI.dat.zaD=90. - double(reform(a[10,ii])) 
	ephmI.dat.jd =yymmddtojulday(ephmI.dat.yyyymmdd) + ephmI.dat.secMid/86400D
	if keyword_set(rangedop) then begin
		ephmI.dat.range =double(reform(a[11,ii]))
		ephmI.dat.dop   =double(reform(a[12,ii]))
	endif
	return,nn
end
