;+
;NAME:
;satpass - compute satellite pass at AO
;SYNTAX: npts=satpass(satNm,passI,yymmdd=yymmdd,hhmmss=hhmmss,$
;                     jd=jd,nsecs=nsecs,tlefile=tlefile,radec=radec)
;ARGS:
; satNm: string     name of satellite, must match  name in tle file
;
;KEYWORDS:
;yymmdd:  long  date (AST) for pass.
;hhmmss:  long  hour,min,sec of day (AST).If not provided find 
;               first pass of day.
;jd    :  double time for the pass
;nsecs : long   if provided then the number of secs to report
;               If not provided then do the entire pass. If 
;               nsecs is provided, then the resolution is 1 second.
;tlefile: string filename holding the two line elements for this sat.
;               if '/' not in name then prepend default path.
;               If this is not supplied then the program will search
;               all tle files for this satellite name
;radec:         If set (/radec) then include the ra,dec for each az,za position.
;               This takes a little longer to run.
;               
;RETURNS:
;   npts: long  > 0 number of entries in passI. 
;               < 0 error occurred.
;passI[npts]: structure holding pass info for each time point.
;DESCRIPTION:
;   Compute az,za,ra,dec for satellite  pass over ao for a given day.
;Use yymmdd,hhmmss   or jd to specify when the passes should occur. If
;no date/time is provided use the current time. 
;Passes will be computed that are above the horizon for the specified time.
;-
function satpass,satNm,passI,yymmdd=yymmdd,hhmmss=hhmmss,jd=jd,nsecs=nsecs,$
                tlefile=tlefile,radec=radec
;
;   secsRef corresponds to jdRef...(utc)
; 
    forward_function satfindtle
;
    astToUtc=4D/24D
    suI=satsetup();
    if (not keyword_set(tlefile)) then begin
        tlefile=satfindtle(satNm)
        if (tlefile eq '') then begin
            print,"could not find a tle file for :",satNm
            return,-1
        endif
    endif
    tlePath=(strpos(tlefile,'/') eq -1)?suI.tleDir:''
;
;   check if they specified a date or time..
;
    if (keyword_set(yymmdd) || keyword_set(hhmmss)) then begin
        dateAr=bin_date(systime(0))
        dateAr[3:5]=0L                  ; default is ast midnite
        if (keyword_set(yymmdd)) then begin
            dateAr[0]=(yymmdd / 10000L)
            if (dateAr[0] lt 100) then $
                dateAr[0]=(dateAr[0] lt 50) ?dateAr[0]+2000L:$
                                             dateAr[0]+1900L
            dateAr[1]=yymmdd/100L mod 100L
            dateAr[2]=yymmdd mod 100L
        endif
        if (keyword_set(hhmmss)) then begin
            dateAr[3]=hhmmss/10000L 
            dateAr[4]=hhmmss/100L mod 100L
            dateAr[5]=hhmmss mod 100L 
        endif
        jd=julday(dateAr[1],dateAr[2],dateAr[0],dateAr[3],dateAr[4],dateAr[5])$
                + astToUtc
        secs1970=tosecs1970(aa,aa,jd=jd)
    endif else begin
        if (keyword_set(jd)) then begin
            secs1970=tosecs1970(aa,aa,jd=jd) 
        endif else begin
            secs1970=systime(1)
        endelse
    endelse
;
; cmd is predict -t tlefile -q obsLoc satnm 
;
    satNmL=satNm
    if (strmid(satNm,0,1) ne "'") && (strmid(satNm,0,1) ne '"') then begin
        satNmL='"' + satNmL + '"'
    endif
	if (n_elements(nsecs) eq 1 ) then begin
	 secs1=long(secs1970 + .5)
     cmd=string(format='(a,1x," -t ",a," -q ",a," -f ",a," ",i10,1x,i10)',$ 
        suI.predictcmd,tlePath+tlefile,suI.qthfile,satNmL,secs1,secs1+nsecs - 1)
	endif else begin
     cmd=string(format='(a,1x," -t ",a," -q ",a," -p ",a," ",i10)',$ 
        suI.predictcmd,tlePath+tlefile,suI.qthfile,satNmL,long(secs1970 +.5))
	endelse
    spawn,cmd,reply
;
;	check for ERROR! in the reply
;
	a=stregex(reply,"ERROR!")
	ii=where(a ne -1,cnt)
	if cnt gt 0 then begin
		print,"-->In satpass, satNm:",satNm
		print,"--> predict error computing orbit:"
		print,reply
		a=tlePath+tlefile
		if strlen(a) gt 48 then begin
			print,"--> tlepath,filename gt 48 chars (max allowed in predict program)"
		endif
		return,-1
	endif
;
      n=n_elements(reply)
      astr=stregex(reply,$
; secs     day   mon   time   el       az     phase lat lon range orbitNum
'^([0-9]*) [^ ]* [^ ]* [^ ]* +([^ ]*) +([^ ]*) +([^ ]*) +([^ ]*) +([^ ]*) +([^ ]*) +([^ ]*)',/sub,/extract)
;
    a={    jd: 0d,$ ; julday utc based
          secs:0d,$ ; from 1970
           az: 0d,$ ; source
           za: 0d,$ ; 
          raHr:0d,$
          decD:0d,$ ;
;         some satellite info
          phase:0L,$ ; modulo 256. relative to perigee
          lat  :0L,$ ; of sub sat point (N)
          lon  :0L,$ ; of sub sat point (W)
          rangeKm:0L,$; slant range in km.
          orbitNum:0L}; increments each orbit.
    passI=replicate({satPass},n)
    passI.secs=reform(astr[1,*])
    passI.jd=(passI.secs - tosecs1970(000101,000000))/86400D + $
				julday(1,1,2000D,0,0,0)
    passI.az=reform(astr[3,*])
    passI.za=90d - reform(astr[2,*])
;   0-->  no model since az,za have no model
	if keyword_set(radec) then begin
    	ao_azzatoradec_j,0,passi.az-180.,passi.za,passI.jd,raHr,decD
    	passI.raHr=raHr
    	passI.decD=decD
	endif
    passI.phase=reform(astr[4,*])
    passI.lat=reform(astr[5,*])
    passI.lon=reform(astr[6,*])
    passI.rangeKm=reform(astr[7,*])
    passI.orbitNum=reform(astr[8,*])
    return,n
end
