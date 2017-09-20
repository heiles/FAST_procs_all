;+
;NAME:
;satpassconst - compute satellite passes for a constellation
;SYNTAX: npts=satpassconst(passAr,gps=gps,iridium=iridium,yymmdd=yymmdd,$
;               hhmmss=hhmmss,jd=jd,radec=radec,verb=verb,tlefile=tlefile)
;ARGS:
;
;KEYWORDS:
;gps:           if set then use the gps constellations
;iridium:       if set then use the iridium constellations
;glonass:       if set then use the glonass constellations
;galileo:       if set then use the galileo constellations
;globalstar:    if set then use the globalstar constellations
;tlefile: string if provided then read all sat from this tle file.
;               If you don't put a leading / then it will use
;               the default location.
;satNmAr[]:string if tlefile is supplied then only include
;               satellites names in satNmAr[]
;yymmdd:  long  date (AST) for pass.
;hhmmss:  long  hour,min,sec of day (AST).If not provided find 
;               first pass of day.
;    jd:  double if provided then use this for the pass time.
; nsecs:  long  Instead of entire pass, compute the location
;               once a second started at requested time for 
;               nsecs. This gives fixed time resolution.
;               .. warning.. if a satellite is not visible during
;                  the requested time, predict loops forever..
; radec:        if set then include ra,dec for each az,za position.
;  verb:        if set then print tlefiles as they are input
;               
;RETURNS:
;   nsat: long  > 0 number of satellites found
;               < 0 error occurred.
;passAr[nsat]: array of structures holding pass info for each satellite
;DESCRIPTION:
;   Compute az,za,ra,dec for satellites in the specified constellation
;as the specified time. The all passes should be above the horizon at the
;specified time. 
;-
function satpassconst,passAr,yymmdd=yymmdd,hhmmss=hhmmss,jd=jd,nsecs=nsecs,$
                      gps=gps,iridium=iridium,glonass=glonass,$
       dice=dice,globalstar=globalstar,galileo=galileo,radec=radec,$
	   tlefile=tlefile,satNmAr=satNmAr,verb=verb
;
	if n_elements(tlefile) eq 1 then begin
		basenm=basename(tlefile,dirnm=tledir)
    	nsattot=satinfo(satI,tledir=tledir)
	endif else begin
    	nsattot=satinfo(satI)
	endelse
    maxPnts=(n_elements(nsecs) eq 1)?nsecs:150
    satP={npnts:0L,$    ; pnts in in pass
         satNm:'',$
         zaMin: 0.,$    ; min za for this pass
         secsMin: 0D,$  ; secs from 1970 for time of min za
        P:replicate({satpass},maxPnts)$
     }
;
;	if they specified a tle file then use it
;
	if n_elements(tlefile) eq 1  then begin
		tleFileL=tleFile
		baseNm=basename(tlefileL,dirnm=dirnm,nmLen=nmLen)
	    
		if nmLen[0] eq 0 then begin
			basenm=basename(satI[0].tlefile,dirnm=dirnm)
			tleFileL=dirNm + tleFileL
		endif
		ii=where(satI.tlefile eq tleFileL,maxsat)
		if maxsat eq 0 then begin
			print,"no sat found in tlefile:tlefileL"
			return,-1
		endif
	endif else begin
    	case  1 of
    	keyword_set(iridium): begin &satPre='IRIDIUM'&satNm='iridium'&end
    	keyword_set(glonass): begin &satPre='COSMOS' &satNm='glonass'&end
    	keyword_set(globalstar):begin& satPre='GLOBALSTAR'&satNm='globalStar'&end
    	keyword_set(dice):begin& satPre='DICE'&satNm='dice'&end
    	keyword_set(galileo): begin 
		                  satPre=['GIOVE','GALILEO'] 
                         satNm='galileo'
                         end
		
       	 else:    begin &satPre='GPS'&satNm='gps' &end
    	endcase
	
		if n_elements(satPre) eq 1 then begin
    		ii=where(strpos(satI.nm,satPre) eq 0,maxsat)
		endif else begin
			ok=intarr(n_elements(satI.nm))
			nn=n_elements(satPre)
			maxSat=0L
			for i=0,nn-1 do begin
    	    	ii=where(strpos(satI.nm,satPre[i]) eq 0,cnt)
				if cnt gt 0 then ok[ii]=1
			endfor
			ii=where(ok eq 1,maxsat)
		endelse
    	if maxsat le 0 then begin
       	 print,"did not find tle files for "+ satPre
                return,-1
    	endif
	endelse

    tleFiles=satI[ii[uniq(satI[ii].tlefile,sort(satI[ii].tlefile))]].tleFile
    passAr=replicate(satP,maxSat)
    icur=0
    start=1

    for ifile=0,n_elements(tleFiles)-1 do begin &$
        nsat=satinptlefile(tleFiles[ifile],tleAr) &$
		if (keyword_set(verb)) then print,ifile," ",tlefiles[ifile]
        for isat=0,nsat-1 do begin &$
            nm=strtrim(tleAr[isat].satnm) &$
			if n_elements(satNmAr) gt 0 then begin
				ii=where(satNmAr eq nm,cnt)
				if cnt eq 0 then continue
			endif
            npts=satpass(nm,tlefile=tleFiles[ifile],pI,yymmdd=yymmdd,$
                     hhmmss=hhmmss,jd=jd,nsecs=nsecs,radec=radec) &$
			npts=(npts < maxPnts)
            passAr[icur].npnts=npts &$
            passAr[icur].satNm=nm &$
            passAr[icur].p[0:npts-1]=pI[0:npts-1] &$
            icur++ &$
        endfor &$
    endfor
    if icur lt maxSat then passAr=passAr[0:icur-1]
    nsat=icur
;
;   timestamp each pass at the minimum za
;   then sort by this min za time
    for isat=0,nsat-1 do begin &$
        zaMin=min(passAr[isat].p[0:passAr[isat].npnts-1].za,ind) &$
        passAr[isat].secsMin=passAr[isat].p[ind].secs &$
        passAr[isat].zaMin=passAr[isat].p[ind].za &$
    endfor
    ii=sort(passAr.secsMin)
    passAr=passAr[ii]
    return,nsat
end
