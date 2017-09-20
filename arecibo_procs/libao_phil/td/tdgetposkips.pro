;+
;NAME:
;tdgetposkips - interpolate pos,kips to requested times
;SYNTAX: npnts=tdgetposkips(jdar,posAr,kipsAr,okAr)
;ARGS:
;    jdar: double  array of julian dates for time points you want.
;RETURNS:
;   npnts         : long  points returned
;   posAr[npnts,3]: float positions interpolated to requested times. Order
;                         is td12,td4,td8
;   KipsAr[npnts,6]: float kips interpolated to requested times. Order
;                         is td12a,b td4a,b, td8a,b where a,b are the two
;                         cable tensions at each tiedown.
;  okAr[npnts]     : int  1 if data for this day was read from disc (0 if not)
;
;DESCRIPTION:
;   The user passes in julian dates for times when they want the tiedown
;position and tension info. The routine will read the info from the disc
;and interpolate the measured data to the requested times. The positions
;and kips are returned. An OkAr is also returned. OkAr[npnts] will have
;a 0 in each element whose days data was not found on disc. 
;
;NOTE: okAr equals 1 for each point who's data was found on disc. If
;      there was a large gap in the data for a pariticular day, it will 
;      still interpolate the data and return a 1 in that element of 
;      okAr[] (this is probably not what you want.. it would be better
;      if okAr[] returned 0 if there is no data within N secs of the
;      requested point).
;
;-
function tdgetposkips,jdAr,posAr,kipsAr,okAr,secAr=secAr

;
;   convert to ast time
;
	npts=n_elements(jdar)
	GmtToAst=4./24D
;
; 	we want ast hr,min,sec to go gmt to ast
	caldat,JDar-GmtToAst,mon,day,yr,hr,min,sec
	secAr=hr*3600. + min*60. + sec
;

;   create yymmdd array and secMidnite array
;
    yymmddAr=(yr mod 100L)*10000L + mon*100L + day
;
;   find unique yymmdd to get
;
	yymmddU=yymmddAr[uniq(yymmddAr,sort(yymmddAr))]
	ndays=n_elements(yymmddU)
    posAr=fltarr(npts,3)
    kipsAr=fltarr(npts,6)
;    okAr  =intarr(npts,6)
    okAr  =intarr(npts)
    icur=0L
	for iday=0,ndays-1 do begin
		n=tdinpday(yymmddU[iday],td)
        if n le 0 then begin
           print, "no tiedown data found for:",yymmddU[iday]
        endif else begin
          ii=where(yymmddAr eq yymmddU[iday],cnt)
          if cnt gt 0  then  begin
            for itd=0,2 do begin
              posAr[icur:icur+cnt-1,itd]=interpol(td.pos[itd],td.secm,secAr[ii])
              for ikips=0,1 do begin
                kipsAr[icur:icur+cnt-1,itd*2+ikips]=$
                      interpol(td.kips[ikips,itd],td.secm,secAr[ii])
              endfor
    	    endfor
            icur=icur + cnt
            okAr[ii]=1
		  endif
		endelse
    endfor
	return,npts
end
