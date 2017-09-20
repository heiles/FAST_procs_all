;+
;NAME:
;mascaldatafind - find patterns with cals and data
;SYNTAX: n=mascaldatafind(projId,sumI,patI,yymmdd=yymmdd,appbm=appbm,
;                dirI=dirI,bm=bm,band=band,grp=grp,useSumI=useSumI)
;ARGS:
;projid: string project id to search for '.*' for all proj
;                [3]=2    cal off has to match cnt in cal on
;KEYWORDS:
;useSumI: int    if true then user supplies sumI
;
;  selection keyords
;yymmdd: long    yyyymmdd limit to this date
; appbm:         apply bm number to each directory. This should normally
;                be set:
;dirI[2]: string if data not in default /share/pdataN/pdev
;                see masfilelist for usage.
;bm     : int    if supplied limit to this beam
;band   : int    0,1 limit to this band. Note if you have single pixel
;                data you probably should set band=1 or masfilelist may
;                not find the files.
;grp    : int    limit to this group 0, or 1.
;
;RETURNS:
;   n   :int     number proccessed patterns found. Each pointing pattern
;                will have 1 entry
;                multple bms.
;patI[n]:		 info on processed patterns
;useI[m]:        summary info
;
; patI STRUCTURE:
; PATID           LONG          34700117
; CALONSCAN       LONG          34700118
; CALOFFSCAN      LONG          34700119
; DATAOBSMODE     STRING    'FIXEDAZ'
; DATASCAN        LONG          34700117
; DATAFILENUM1    LONG               200
; NDATAFILES      LONG                 1
; DATAROWS        LONG              1200
; DATADMPSROW     LONG                 1
; USEGRP          INT       Array[2]
; USEBANDBMGRP    INT       Array[2, 7, 2]
;
;DESCRIPTION:
;	Find all of the patterns that have:
;1. a data scan
;2. a cal on ,off scans
;3. and meet the keyword specs
;The routine accepts the same parameters at masfilelist:
; yymmdd=,dirI=,bm=,band=,grp=num=,appbm=appbm
;The routine will pass back an array of patI structs holding info on 
;each pattern that meets the criteria. The info includes the 
;patid and and and numbers of the cals, data. You can then use these
;values to search through the fnmI struct that is returned and then read the
;files.
;	
;
;EXAMPLE:
;
;1.	Find the patterns with cals for 20101213:
;   yymmdd=20101213
;   projid='.*'
;   npat=mascaldatafind(projId,fnmI,patI,yymmdd=yymmdd,/appbm)
;                yymmdd=yymmd20100930,grp=0,band=1,/appbm)
;
;2. recall mascaldatafind with user supplying fnmI
;   n=masfilelist('',fnmI, params)
;   npat=mascaldatafind(projId,fnmI,patI,/usefnmI)
; 
;-
function mascaldatafind,projId,sumI,patI,yymmdd=yymmdd,appbm=appbm,dirI=dirI,$
			bm=bm,band=band,grp=grp,list=list,usesumI=useSumI
;
	NM='mascaldatafind'
	CALNM='CAL'
	if not keyword_set(useSumI) then begin
		n=masfilelist('',fnmI,proj=projId,yymmdd=yymmdd,grp=grp,band=band,bm=bm,/appbm)
	endif
	if not useSumI then begin
		n=masfilesum('',sumI,fnmI=fnmI,list=list)
	endif
	a={ patId     : 0L,$  $
		calOnScan : 0L,$
		calOffScan: 0L,$
	    projId    : '',$
		dataObsMode: '',$
		dataScan  : 0L,$
		dataFileNum1: 0L,$; filenum for first file
	 	ndataFiles : 0L,$ ; only report the first . this tells if others
		dataRows  : 0L,$ ; 1st file bm 0
		dataDmpsRow:0L,$ ; 1st file bm 0
		useGrp    : intarr(2),$
		useBandBmGrp : intarr(2,7,2)$   ; (low,hi), nbeams 1--> this one used
	 }
	patId=sumI.h.pattern_id
	upatid=sumI[uniq(patId,sort(patId))].h.pattern_id
	maxpat=n_elements(upatid)
	patI=replicate(a,maxpat)
	iisumI0=where((sumi.bm eq 0) and (sumI.band eq 1),cnt)
	sumI0=sumI[iisumI0]
	patid=sumi0.h.pattern_id
	obsMode=sumi0.h.obsMode
	npatid=n_elements(patid)
	icnt=0L
	ocnt=0l
	calOnScan=0L
	calOffScan=0L
	dataScan=0L
	dataFileNum1=-1L
	ndataRows=0L
	dataDmpsRows=0L
	while (icnt lt npatid) do begin &$
		calCnt=0L &$
		dataCnt=0L &$
		ndataRows=0L &$
		dataDmpsRow=0L &$
		dataScan   =0L  &$
		dataFileNum1=-1L &$
		dataObsMode='' &$
		projId='' &$
		cpatid=patid[icnt] &$
		while (icnt lt npatid) do begin &$
		  if ( patid[icnt] eq cpatid) then begin &$
			if (obsMode[icnt] eq CALNM) then begin &$
            	calCnt++ &$
				if (sumI0[icnt].h.scantype eq 'ON') then begin
					calOnScan=sumI0[icnt].h.scan_id
				endif else begin
					if (sumI0[icnt].h.scantype eq 'OFF') then begin
					 	calOffScan=sumI0[icnt].h.scan_id
					endif
				endelse
		    endif else begin &$
				dataCnt++ &$
				ndataRows+=sumI0[icnt].nrows &$
				if dataCnt eq 1 then begin
					dataObsMode=sumI0[icnt].h.obsmode
					dataFileNum1=sumI0[icnt].num
					dataScan=sumI0[icnt].h.scan_id
					dataDmpsRow= sumI0[icnt].dumpRow &$
                    bname=basename(sumI0[icnt].fname)
					ii=strpos(bname,".")
				    projId=strmid(bname,0,ii)
				endif
			endelse &$
		    icnt++ &$
		  endif else begin &$
			if (calCnt gt 1) and (dataCnt gt 0) then begin &$
				patI[ocnt].patId     =cpatId &$
				patI[ocnt].calOnScan =calOnScan  &$
				patI[ocnt].calOffScan=calOffScan &$
				patI[ocnt].dataObsmode  =dataObsMode &$
				patI[ocnt].projId       =projId &$
				patI[ocnt].dataScan     =dataScan &$
				patI[ocnt].dataFileNum1 =dataFileNum1 &$
				patI[ocnt].ndataFiles   =dataCnt
				patI[ocnt].dataRows     =ndataRows &$
				patI[ocnt].dataDmpsRow  =dataDmpsRow &$
				ocnt++ &$
			endif &$
			calCnt=0L &$
			dataCnt=0L &$
		    calOnScan=0L
		    calOffScan=0L
		    dataScan=0L
			ndataRows=0L &$
			dataObsMode=''
			projId=''
			dataDmpsRow=0L &$
			cpatid=patid[icnt] &$
		  endelse &$
	    endwhile &$
		if (calCnt gt 1) and (dataCnt gt 0) then begin &$
			patI[ocnt].patId     =cpatId &$
			patI[ocnt].calOnScan =calOnScan  &$
			patI[ocnt].calOffScan=calOffScan &$
			patI[ocnt].dataObsmode  =dataObsMode &$
			patI[ocnt].projId       =projId &$
			patI[ocnt].dataScan     =dataScan &$
			patI[ocnt].dataFileNum1 =dataFileNum1 &$
			patI[ocnt].ndataFiles   =dataCnt
			patI[ocnt].dataRows     =ndataRows &$
          ocnt++ &$
    	endif &$
	endwhile
	patI=patI[0:ocnt-1]
	npatI=n_elements(patI)
	for ipat=0,npatI-1 do begin
		ii=where((sumI.h.scan_id eq patI[ipat].calOnScan),cnt)
		for j=0,cnt-1 do begin
			bm  =sumI[ii[j]].bm
			band=sumI[ii[j]].band
			grp =sumI[ii[j]].grp
			patI[ipat].usegrp[grp]=1
			patI[ipat].useBandBmGrp[band,bm,grp]=1
		endfor
	endfor
	return,ocnt
end
