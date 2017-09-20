;+
;NAME:
;maspatfind - find data taking patterns
;SYNTAX: n=maspatfind(projId,obsModeAr,scanTypeAr,minScanPat,recCntMatch,
;               patI,npat,upatIdAr,nsrc,usrcAr,$
;               yymmdd=yymmdd,appbm=appbm,dirI=dirI,bm=bm,band=band,grp=grp)
;ARGS:
;projid: string project id to search for
;obsModeAr[n]: strarr obsmode for each step in pattern
;scanTypeAr[n] : strarr scan type name for each scan in pattern
;minScanPat    : int    minimum number scans required for pattern.
;                   obsmodear,scantypear should have the optional 
;                   scans at the end. eg for on,off you could optionally
;                   have a cal.
;recCntMatch[n]: int  index in obsModeAr that has to have the same
;                number of records.
;                eg: suppose onoff position swithch with cals.. then
;                recntMatch=[-1,0,-1,2] index from 0, -1 --> don't care
;                [0]=-1   pos on don't care any number is on .. on
;                [1]=0    pos off has to match cnt in on.
;                [2]=-1   cal on  don't  care
;                [3]=2    cal off has to match cnt in cal on
;KEYWORDS:
;yymmdd: long    yyyymmdd limit to this date
; appbm:         apply bm number to each directory. This should normally
;                be set. If yymdd=0 then any date will match.
;dirI[2]: string if data not in default /share/pdataN/pdev
;                see masfilelist for usage.
;bm     : int    if supplied limit to this beam
;band   : int    0,1 limit to this band. Note if you have single pixel
;                data you probably should set band=1 or masfilelist may
;                not find the files.
;grp    : int    limit to this group 0, or 1.
;
;RETURNS:
;   n   :int     number proccessed patterns. Each pointing pattern
;                can generate multiple processed patterns if you use
;                multple bms.
;patI[n]:		 info on processed patterns
;npat   : int    number of pointing patterns executed.
;nsrc   : int    number of unique sources
;srcAr[nsrc]: string list of sources used.
;
; patI STRUCTURE:
;	- there will be one entry for each pattern and bm used
;     If you have 4 bms then a single patId will have 4 entries
;     in patI[]
;
;      patI[i].srcNm      - source name
;      patI[i].nscans     - # of scans in pattern ..
;      patI[i].bm        - bm number 0..6
;      patI[i].grp       - grp 0 or 1
;      patI[i].flist[maxScans]  - list of filenames: 
;                                same orde as scanTypeAr
;      patI[i].sumI[maxScans]  - summary info for each scan 
;
;DESCRIPTION:
;	Find all of the patterns the given project and constraints.
;The routine accepts the same parameters at masfilelist:
; yymmdd=,dirI=,bm=,band=,grp=num=,appbm=appbm
;The routine will pass back an array of patI structs holding info on 
;each pattern. 
;
;	There is a distinction between a pointing pattern and a processed 
;dataset. You can have multiple processed datasets for each pointing
;pattern if you used multiple beams or groups.
;	
;
;EXAMPLE:
;
;1.	Find the dps info for project a2516 on 20100930 group 0.
;   n=masdpsfind('a2516',patI,npat,upatIdAr,nsrc,usrcAr,$
;                yymmdd=20100930,grp=0,band=1,/appbm)
;       patI[n] - holds the info
;       npat    - number of pointing patterns found
;       upatIdAr[npat] - unique pattern id for each pointing pattern.
;                 This can include multiple patI[] entries if multiple
;                 bms taken on each pointing pattern.
;       nsrc    - Number of unique on source names found
;       usrcAr[nsrc] - list of source names.
;
;2. now process all of the patterns found using group 0 bm 1.
;   ii=where((patI.grp eq 0 ) and (patI.bm eq 0),cnt)
;   for i=0,cnt-1 do begin
;       j=ii[i]				; index in patI for this dataset
;       istat=masdpsp(patI[j].flist,b)
;       if i eq 0 then b0ar=replicate(b[0],cnt); generate large array
;       b0ar[i]=b
;  endfor
;
;  this assumes that all of the bm=0 data sets have the same
;  number of channels (since we are trying to store them all in an array).
;
;3. plot out the first set of results
;   masplot,b0ar[0]
;
;-
function maspatfind,projId,obsModeAr,scanTypeAr,minScanPat,recCntMatch,$
                    patI,npatId,upatId,nsrc,usrcar,$
			yymmdd=yymmdd,appbm=appbm,dirI=dirI,$
			bm=bmX,band=bandX,grp=grpX
;
	NM='maspatfind'
	maxScanPat=n_elements(obsModeAr)
	n=masfilelist('',fnmI,proj=projId,yymmdd=yymmdd,bm=bmX,band=bandX,grp=grpX,$
				appbm=appbm,dirI=dirI)
	if (n lt minscanPat ) then return,0 
;
;	get file summaries
;
	n=masfilesum(flist,sumI,fnmI=fnmI)
	a={	srcNm: '', $
        bm   : 0,$ 
        grp  : 0,$ 
        nscans:0,$ 
		patid: 0L,$
        filelist:strarr(maxScanPat),$
		sumI    :replicate(sumI[0],maxScanPat)$
	}
	
	if (n lt minScanPat) then return,0
;
	upatid=sumI[uniq(sumI.h.pattern_id,sort(sumI.h.pattern_id))].h.pattern_id
	npatid=n_elements(upatid)
	patI=replicate(a,npatid)
	icur=0
	nsrc=0
	for ipat=0,npatid-1 do begin
		ii=where(sumI.h.pattern_id eq upatid[ipat],n)
		sumI1=sumI[ii]
;
;		now look for different beams and groups
;
		grp=sumI1.grp
		ugrp=grp[uniq(grp,sort(grp))]
		ngrp=n_elements(ugrp)
		for igrp=0,ngrp-1 do begin
			ii=where(sumI1.grp eq ugrp[igrp],cnt)
			if cnt eq 0 then continue
			sumI2=sumI1[ii]
			bm=sumI2.bm
			ubm=bm[uniq(bm,sort(bm))]
			nbm=n_elements(ubm)
			for ibm=0,nbm-1 do begin
				ii=where(sumI2.bm eq ubm[ibm],cnt)
				if (cnt lt minScanPat) then continue
				if icur eq 0 then begin
					patI=replicate(a,npatid*ngrp*nbm)
				endif
;   figure where the scans are in ii[]
				ok=1
				i=0
				for i=0,cnt-1  do begin
;                   see if we have obsmode and scantype. not an error if
;                   we are beyond the minscanpat 
    				jj=where((sumI2[ii].h.scantype eq scanTypeAr[i]) and $
    				         (sumI2[ii].h.obsmode  eq obsModeAr[i]),cnt1)
				    if cnt1 ne 1 then begin
						print,"Incomplete pattern. grp,bm,patternId,iscan:",$
							ugrp[igrp],ubm[ibm],upatId[ipat],i
						ok=0
						break
				    endif else begin
						ll=ii[jj[0]] 
						kk=(i eq 0)?ll:[kk,ll]
				   	endelse
				endfor
				if not ok then continue	
				patI[icur].nscans=cnt
				patI[icur].sumI=sumI2[kk]
;   make sure no incomplete scans
				ok=1 
				for i=0,cnt-1 do begin
					if (recCntMatch[i] ge 0) then begin
						if (patI[icur].sumI[i].nrows ne $
					     patI[icur].sumI[recCntMatch[i]].nrows) then begin
						print,"Incomplete scan. grp,bm,patternId,iscan:",$
							ugrp[igrp],ubm[ibm],upatId[ipat],i+1
							ok=0
					    	break 
						endif
					endif
				endfor
				if not ok then continue
			    patI[icur].filelist=patI[icur].sumI.fname
				patI[icur].srcnm=patI[icur].sumI[0].h.object
				patI[icur].bm   =patI[icur].sumI[0].bm
				patI[icur].grp  =patI[icur].sumI[0].grp
				patI[icur].patid=patI[icur].sumI[0].h.pattern_id
				if nsrc eq 0 then begin
					usrcAr=patI[icur].srcnm
					nsrc=1
				endif else begin
					jj=where(usrcAr eq patI[icur].srcnm,cnt)
				    if cnt eq 0 then usrcAr=[usrcAr,patI[icur].srcnm]
				endelse
				icur++
			endfor
		endfor
	endfor
	if icur lt n_elements(patI) then begin
		if icur eq 0 then return,0
		patI=patI[0:icur-1]
	endif
	nsrc=(nsrc eq 0)?0:n_elements(usrcar)
	upatid=$
	patI[uniq(patI.patid,sort(patI.patid))].patid
	npatid=n_elements(upatid)
	return,icur
end
