;+
;NAME:
;satpassplt - plot a satellite constellation passes over AO
;SYNTAX: satpassplt,yymmdd=yymmdd,hhmmss=hhmmss,jd=jd,satAr=satAr,v=v,$
;                   gps=gps,iridium=iridium,glonass=glonass,galileo=galileo,$
;                   globalstar=globalstar,tlefile=tlefile,wait=wait,radec=radec,$
;                   samepage=samepage,ln0=ln0
;ARGS:
;KEYWORDS:
;   yymmdd: long    if supplied then the AST date for the pass
;   hhmmss: long    if supplied then the AST time for the pass  
;   jd    : double  if supplied then the julian date for the pass
;   nsecs : long    instead of plotting an entire pass, plot nsecs
;                   points starting at requested time spaced by 1 sec.
;                   .. warning. If a satellite is not visible during
;                      this time, predict seems to loop forever...
;   v[2]  : float   if supplied then then min, max za for plotting.
;     gps :         if set then plot the gps constellation
;  iridium:         if set then plot the iridium constellation
;  glonass:         if set then plot the glonass constellation
;globalstar:        if set then plot the globalstar constellation
;tlefile   :string  if provided then ignore constellation names. Plot
;                   all satellites in this file
;satNmAr[] :string  if supplied with tlefile then only plot these sat
;                   names. 
;wait      :        if set then wait for keyboard input before plotting
;                   the next page. This is only needed for iridium and
;                   globalstar (they have more than 32 satellites).
;radec     :        If set then include the ra,dec in the returned info
;                   This slows down the routine a little. This is only
;                   used if satAr is supplied to return the info in.
;samepage  :        if set then continue plotting on the current page
;                   useful for constellation with only a few satellites
;ln0       : int    first linenumber for display of first sat name.
;                   useful if you are using samepage. Then you can
;                   have the sat name appear in the frame you are writing in.
;                  values .. about 0 to 31
;
;RETURNS:
;satAr[nsat]: {}  strucuture containing satellite info for each pass and 
;                 point within a pass.
;DESCRIPTION:
;   Plot the passes over ao for the specified constellation at a given time. 
;The time can be specified by yymmdd,hhmmss keywords or jd (julian date). If no
;date is specified then the current time is used. 
;
;   A satellite pass is included in the plot if any portion of a pass is
; above the AO horizon at the specified time.
;
;   Only one constellation can be specified per call. If no constellation
;is specified then gps is used.
;   
;   A maximum of 32 satellites can be plotted per page. If you want to
;see each page as it is generated either make a hardcopy, or use the
;/wait keyword to wait before plotting the next page.
;
; satAr is an array satAr[31] .. one for each satellite.
;
;L> help,satAr,/st
;   NPNTS     LONG      92      .. number of points in pass (valid pnts in P[])
;   SATNM     STRING    'GPS16' .. name of satellite
;   ZAMIN     FLOAT     18.8150 .. minimum za for this pass
;   SECSMIN   DOUBLE    1.2221771e+09 .. time secs 1970 for za Min.
;   P         STRUCT    SATPASS Array[150] .. array of points for each pass. Only the first
;                                  satAr[i].npnts are valid for this pass.
;
; the pass structure P contains:
;
;IDL> help,satAr.p,/st
; JD       DOUBLE       2.7793265e+08 .. jd for this point
; SECS     DOUBLE       1.2221659e+09 .. secs 1970 for this point
; AZ       DOUBLE           204.47500 .. source az for pnt
; ZA       DOUBLE           89.974000 .. za for this pnt
; RAHR     DOUBLE          0.23571587 .. J2000 right ascension in hours for this point
; DECD     DOUBLE          -66.452344 .. J2000 declination in deg for this point
; PHASE    LONG               226     .. phase in orbit 0..255
; LAT      LONG               -50     .. north lattitude of sat sub orbit point
; LON      LONG               105     .. west longitude  of sat sub orbit point
; RANGEKM  LONG             25677     .. slant range in kilometers to satellite
; ORBITNUM LONG              4142     .. orbit number. increments once each orbit.
;
;
;EXAMPLE:
;idl
;@satinit
;yymmdd=080923
;hhmmss=141500
;satpassplt,yymmdd=yymmdd,hhmmss=hhmmss,satAr=satAr,/gps
;-
;
pro satpassplt,yymmdd=yymmdd,hhmmss=hhmmss,jd=jd,nsecs=nsecs,satAr=satAr,v=v,sym=sym,$
        gps=gps,iridium=iridium,galileo=galileo,glonass=glonass,tlefile=tlefile,satNmAr=satNmAr,$
        globalstar=globalstar,wait=wait,radec=radec,samepage=samepage,$
		ln0=ln0
;
    common colph,decomposedph,colph


	if n_elements(ln0) eq 0 then ln0=0l
    satPerPage=32
	radecL=0
	if keyword_set(radec) and (n_elements(satAr) gt 0) then radecL=1
    nsat=satpassconst(satAr,hhmmss=hhmmss,yymmdd=yymmdd,jd=jd,nsecs=nsecs,$
        gps=gps,iridium=iridium,globalstar=globalstar,glonass=glonass,$
            galileo=galileo,tlefile=tlefile,satNmAr=satNmAr,radec=radecL)
    tit1=$
'          za vs az (source) for                               AST time min Za of pass'
	if (n_elements(tlefile) eq 1) then begin
		constNm=basename(tlefile)
		if (strmid(constnm,3,4,/reverse_offset) eq '.tle') then begin
			constNm=strmid(constNm,0,strlen(constNm)-4)
		endif
	endif else begin
    	case (1) of
        keyword_set(gps):constNm='gps'
        keyword_set(iridium):constNm='iridium'
        keyword_set(galileo):constNm='galileo'
        keyword_set(glonass):constNm='glonass'
        keyword_set(globalstar):constNm='globalstar'
        keyword_set(dice):constNm='dice'
   	 endcase
	endelse
    len=strlen(constNm)
    tit=strmid(tit1,0,32) + constNm + strmid(tit1,32+len)
;
;if hard then pscol,'gpspasses.ps',/full
	if not keyword_set(samepage) then !p.multi=[0,1,4]
    vl=[0,92]
    hor,-5,500
    if keyword_set(v) then begin
        vl=(n_elements(v) eq 1)?[0,v] : v[0:1]
    endif
    ver,vl[0],vl[1]

    symL=(n_elements(sym) gt 0)?sym[0]:1
    isat=0
    cs=1.7
    xp=.74
    step1=7.6
    step2=.66
    done=0
    while (not done) do begin
        for i=0,3 do begin &$
            ln=i*step1 + 1.2 + ln0 &$
            plot,[0,1],[0,1],/nodata,charsize=cs,$
            xtitle='azimuth (source) [deg]',ytitle='za [deg]',$
            title=tit
            for j=0,7 do begin
                icol=j + 1 
                n=satAr[isat].npnts
                x=satAr[isat].p[0:n-1].az 
                y=satAr[isat].p[0:n-1].za 
				if n gt 1 then $
                	oplot,x,y,col=colph[icol],psym=symL
                zamin=min(satAr[isat].p[0:n-1].za,ind)
                transit=systime(0,satAr[isat].p[ind].secs)
                a=bin_date(transit)
                yymmddL=(a[0] mod 100L)*10000L + a[1]*100L + a[2]
            ldate=string(format='(i06,1x,i02,":",i02,":",i02)', yymmddL,a[3:5])
            len1=strlen(satAr[isat].satNm)
            if len1 gt 8 then begin
				if (strmid(satar[isat].satNm,0,7) eq "GALILEO")  then begin
					len=strlen(satar[isat].satnm)
					nm1="GALI-" + strmid(satar[isat].satnm,2,3,/reverse)
				endif else begin
                  a=stregex(satAr[isat].satNm,"^[^0-9]+([0-9]+)$",/sub,/extract)
                  len=strlen(a[1])
                  nm1=strmid(satAr[isat].satNm,0,8-len) + a[1]
				endelse
            endif else begin
                nm1=satAr[isat].satNm
            endelse
        note,ln+j*step2,nm1 + ' ' + ldate,xp=xp,col=colph[icol] 
                 isat++ 
                 done=(isat ge nsat)
                if done then break
            endfor &$
            if done then break
        endfor
        if  keyword_set(wait) &&  (nsat gt isat) then begin
            print,'hit enter to continue plotting'
            key=checkkey(/wait)
        endif
    endwhile
return
end
