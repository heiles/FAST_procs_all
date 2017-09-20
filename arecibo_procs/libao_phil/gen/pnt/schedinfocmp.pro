;+
;NAME:
;schedinfocmp - compute schedule info for sources
;SYNTAX:istat=schedinfocmp(ra,dec,srcNm,srcI,coord=coord,fmt=fmt,
;                 zamin=zamin,zamax=zamax,print=print,$
;				alist=alist,hdrLabAr=hdrLabAr,exclnorise=exclnorise)
;ARGS:
;   ra[N]: float    ra. default hms
;  dec[n]: ffoat   dec.. def   dms
;srcNm[n]: string   source names
;KEYWORDS:
; coord[n]: string  coord type: j=j2000,,b=b1950,g-gal. def:j
;                  If coord is a single element, then all elements of
;                  ra[n],dec[n] should be this coordinate type
;   fmt :  int     0 - hms,dms
;                  1= hh:mm:ss dd:mm:ss
;                  2= degrees,degrees
;                  3= hours,degrees
;  zamin : float   min za to allow
;  zamaz : float   max za to allow
;print   :         if set the write the 1 line summaries for each line
;                  to standard out
;exclnorise:       if set then exclude sources that never rise
;RETURNS:
; istat  : int    n number of sources returned
;                -1 trouble with a source
; srcI[n]: {}   struct holding info:
;alist[n]: string  if supplied then return a formated list 
;                  1 line per source
;hdrLabAr[3]:string header labels for alist array.
;
;DESCRIPTION:
;   Given a set of ra,decs for sources, return the  the LST rise,transit, and
;set times (all in LST hours) in the structure srcI[n].
; 	Also return the time durations: rise to transit, and keyhole to transit.
;Both of these are returned in solar hours (since you'll probably want
;them to compute integration times). 
;
; 	The routine will also return a formatted list with 1 line entry per source
;if th alist=  parameter is supplied (aline[n]). the hdrLabAr[3] is the 
;header lines for these lines.
;
;   The user can specify the zamax,zamin where the sources rise and where they
;hit the keyhole (the default is 19.69 and 1.06) . 
;
;	When coordinates are precessed to the current date using the time when the
;routine is run.
;
;   The structure contains:
;
; srcI:{ srcName: ' ',$;
;            raC: 0.,$; current ra in deg
;           decC: 0.,$; current dec in deg
;       neverRises: 0,$; 1 (true) if never rises
;;      Next 3 times are lst (sidereal) times
;       transitHr  : 0D,$; transit time: lst hour
;       riseHr     :0D,$ ; rises :       lst hour
;       setHr      :0D,$ ; sets :        lst hour
;       Next 2 time durations are solar time durations
;       riseToTrHr :0d,$ ; time rise to transit : solar  hours
;     keyHoleToTrHr:0d} ; keyhole to transit time:solar hour
;
;- 
function schedinfocmp,ra,dec,srcName,srcI,coord=coord,fmt=fmt,$
           zamin=zamin,zamax=zamax,print=print,alist=alist,hdrLabAr=hdrLabAr,$
		   exclnorise=exclnorise
;
	SIDEREAL_TO_SOLAR=   .997269566330
    obsLatD=(18. + (21. + 14.2/60.)/60.) 
    obsLatRd=obsLatD * !dtor
    if n_elements(zamin) eq 0 then zaMin=1.06
    if n_elements(zamax) eq 0 then zaMax=19.69
    zaMaxRd=zamax*!dtor
    zaMinRd=zamin*!dtor
    aa={ srcName: ' ',$;
             raC: 0.,$; current ra
            decC: 0.,$; current dec
        neverRises: 0,$; true if never rises
;         lst times
        transitHr  : 0D,$; lst hour
        riseHr     :0D,$ ; lst hour
        setHr      :0D,$ ; lst hour
        riseToTrHr :0d,$ ; solor time differenct rise to transit
        keyHoleToTrHr:0d} ;soloar time difference  keyhole to transit
    
    n=n_elements(ra)
	coordOk='jbg'
    coordl=strarr(n)+'j'
	niij=n
	niig=0
	niib=0
    ncoord=n_elements(coord)
    if (ncoord gt 0) then begin
		coordl=strmid(strlowcase(coord),0,1)
		if ncoord eq 1 then begin
			ncoord=n
			coordl=strarr(n) + coord
		endif
		iij=where(coordl eq 'j',niij)
		iib=where(coordl eq 'b',niib)
		iig=where(coordl eq 'g',niig)
		if (ncoord ne (niij + niib + niig)) then begin
			jj=where((coordl ne 'j') and (coordl ne 'b') and (coordl ne 'g'),cnt)
	 		print,"Coordinate system codes are j,b,g. Illegal code req:",coord[jj]
			return,-1
		endif
	endif
;
;   put everything in degrees
;
    fmtl=0
    if keyword_set(fmt) then fmtl=fmt
    if (fmtl lt 0 ) or (fmtl gt 3) then begin
        print,$
"fmt= should be 0:hhmmss/ddmmss,1:hh:mm:ss/dd:mm:ss,2:deg/deg,3:hrs/degrees"
        return,-1
    endif
    case fmtl of 
        0: begin
           raC =hms1_rad(ra)*!radeg
           decC=dms1_rad(dec)*!radeg
           end
        1: begin
            raC =fltarr(n)
            decC=fltarr(n)
            for i=0,n-1 do begin
                a=strsplit(ra[i],":",count=count,/extract)
                case count of
                    1:raC[i]= float(ra[i])/3600. * 15.; seconds of time
                    2:raC[i]= (float(a[0]) + float(a[1])/60)/60. * 15.
                    3:raC[i]= (float(a[0]) + (float(a[1]) + float(a[2])/60)/60.)$
                               *15.
                endcase
                a=strsplit(dec[i],":",count=count,/extract)
;
;			for minus sign
;
			    a0=a[0]
				ipos=strpos(a0,'-')
				isign=1.
				if (ipos ne -1 ) then begin
					isign=-1.
					strput,a0,' ',ipos 
				endif
                case count of
                    1:decC[i]= float(a0)/3600. ; seconds of arc
                    2:decC[i]= (float(a[0]) + float(a[1])/60)/60.
                    3:decC[i]= (float(a[0]) + (float(a[1]) + float(a[2])/60)/60.)
                endcase
				decC[i]*=isign
            endfor
           end
        2: begin
           raC =ra
           decC=dec
           end
        3: begin
           raC =ra*15.
           decC=dec
          end
    endcase
;
;  if galactic, go to j2000
;
    if (niig gt 0 ) then begin
		r=raC[iig]
        d=decC[iig]
        euler,r,d,select=2
		raC[iig]=r
        decC[iig]=d
    endif
;
;    if b1950 go to j2000
;
    if (niib gt 0 ) then begin
		r=raC[iib]
        d=decC[iib]
        jprecess,r,d,raJ,decJ
        raC[iib]=raJ
        decC[iib]=decJ
    endif
;
;   precess to coord of date
;
    jd2000=julday(1D,1,2000,0,0,0)
    jdNow=systime(/julian)
    epochNow=(jdNow - jd2000)/365.25  + 2000.
    precess,raC,decC,2000D,epochNow
;
;   for each source compute az,za for rise,set,transit
;
    srcI=replicate(aa,n)
    if n_elements(srcName) eq n then  srcI.srcname=srcName
    srcI.raC=raC
    srcI.decC=decC
;
    ii=where((abs(srcI.decC - obsLatD) gt zamax),cnt) 
    if cnt gt 0 then srcI[ii].neverRises=1
    decRd=decC*!dtor
    dtemp=cos(decRd)*cos(obsLatRd)
    ii=where(dtemp eq 0.,cnt1)
    if (cnt1 gt 0) then dtemp[ii]=1.
    arg=(cos(zaMaxRd)-sin(decRd)*sin(obsLatRd) ) / dtemp;
    jj=where(abs(arg) gt 1,cnt)
    if cnt gt 0 then arg[jj]=0.
    haRiseHr=acos(arg)*!radeg/15D;
    if cnt1 gt 0 then haRiseHr[ii]=0.
    srcI.transitHr=raC/15d   ;  to hours	
    srcI.riseHr   =srcI.transitHr - haRiseHr
    srcI.setHr    =srcI.transitHr + haRiseHr
    srcI.riseToTrHr=abs(haRiseHr)* SIDEREAL_TO_SOLAR 
;
;    put rise, set 0 to 24
    ii=where(srcI.riseHr lt 0,cnt)
    if cnt gt 0 then srcI[ii].riseHr+= 24d
    ii=where(srcI.riseHr ge (24d),cnt)
    if cnt gt 0 then srcI[ii].riseHr-= 24d

    ii=where(srcI.setHr lt 0,cnt)
    if cnt gt 0 then srcI[ii].setHr+= 24d
    ii=where(srcI.setHr ge (24d),cnt)
    if cnt gt 0 then srcI[ii].setHr-= 24d
;   
;   find za for transit. see if outside min,max za limits
;
    zaLatAo=obsLatRd*!radeg
    zaTr=(decC - zaLatAo)
    zaSgn=zaTr*0. + 1 
    ii=where(zaTr lt 0,cnt)
    if cnt gt 0 then begin
        zaSgn[ii]=-1.
        zaTr[ii]*=-1.
    endif
    ii=where(zaTr lt zaMin,cnt)
;
;   given: zaMin,dec, lat comp ha
;  a=za,b=90-lat,c=90-dec
;
;  cosa=cos(b)*cos(c) + sin(b)*sin(c)cosA
;  cos(za)=cos(90-lat)*cos(90-dec) + sin(90-lat)sin(90-dec)cos(HA) 
;  cos(ha)=(cos(za)- cos(90-lat)*cos(90-dec))/(sin(90-dec)sin(90-lat))
;                
    if cnt gt 0 then begin
        arg=(cos(zaMinRd) - cos(!pi/2 - obsLatRd)*cos((90-decC[ii])*!dtor))/$
            (sin((90-decC[ii])*!dtor)*sin(!pi/2 - obsLatRd))
        srcI[ii].keyholeToTrHr=acos(arg)*!radeg/15. * SIDEREAL_TO_SOLAR
    endif
    ii=where(srcI.neverRises eq 1,cnt)
    if cnt gt 0 then begin
		if keyword_set(exclnorise) then begin
    		ii=where(srcI.neverRises eq 0,n)
            if n eq 0 then return,n
			srcI=srcI[ii]
		endif else begin
        	srcI[ii].transitHr=0.
        	srcI[ii].riseHr=0.
        	srcI[ii].setHr=0.
        	srcI[ii].riseToTrHr=0.
        	srcI[ii].keyholeToTrHr=0.
		endelse
    endif
	if (arg_present(alist) or keyword_set(print)) then begin &$
		alist=strarr(n)
	 	hdrLabAr=[$
"          Never  |-----------LST----------||---Minutes(solar)--|",$  
"  Source  Rises  | Rise   Transit     Set || RiseTo   KeyHole  |",$
"                                             KeyHole  ToTransit|"]
		if (keyword_set(print)) then begin
			print,"zaMax:",zaMax," zaMin:",zaMin
			for i=0,n_elements(hdrlabar)-1 do print,hdrlabar[i]
		endif
		for i=0,n-1 do begin
			 alist[i]=string(format='(a10,2x,i1)',srcI[i].srcName,srcI[i].neverRises)
             if srcI[i].neverRises eq 0 then begin
             	alist[i]+=string(format='(4x,a8,1x,a8,1x,a8,3x,f5.1,4x,f5.1)',$
            			fisecmidhms3(srcI[i].riseHr*3600.),$
            			fisecmidhms3(srcI[i].transitHr*3600.),$
            			fisecmidhms3(srcI[i].setHr*3600.),$
            			(srcI[i].riseToTrHr-srcI[i].keyHoleToTrHr)*60d,$
            			(srcI[i].keyHoleToTrHr)*60d)
     		endif else begin 
				alist[i]+="                                               "
			endelse
		    if (keyword_set(print)) then print,alist[i]
		endfor
	endif
    return,n
end
