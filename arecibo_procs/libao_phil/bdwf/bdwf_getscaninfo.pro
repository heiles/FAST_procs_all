;+
;NAME:
;bdwf_getscaninfo - get scan info for a set of fnmI files
;SYNTAX: nscans=bdwf_getscaninfo(fnmi,rcvNum,scanIAr,maxDfileScan=maxDfileScan)
;ARGS:
;fnmI[]:{}  array of fnmI structs to search. This is returned from 
;           masgetfilelist()
;rcvNum: int  receiver number to use
;KEYWORDS:
;maxDfileScan: long Limit the maximum data files per scan. If not 
;                   supplied, then the program searches for the maximum.
;RETURNS:
; scanIAr[nscans]: {} array holding info on all the scans found 
;-
function bdwf_getscaninfo,fnmi,rcvNum,scaniar,maxDfileScan=maxDFileScan
;
;
; figure out order for beam 0 . others will follow
;
	ii=where(fnmi.bm eq 0,cnt)
	fnmiT=fnmi[ii]
;
; file summary for these 
;
	nsum=masfilesum(flist,sumI,fnmi=fnmiT)
	ii=where(sumI.h.rfNum eq rcvNum,cnt)
	if cnt eq 0 then begin
		print,"No scans found for rcvNum:",rcvNum
		return,-1
	endif
	sumI=sumI[ii]
; 
; sort by time
;
	ii=sort(sumi.h.mjdxxobs)
	sumi=sumi[ii]
	ii=where(sumi.h.obsmode eq 'ON')
	ii=ii[0]
	; make sure we start on a data scan
	sumI=sumI[ii:*]
	scanAr=sumi.h.scan_id
	uscanAr=scanAr[uniq(scanar,sort(scanar))]
	if not (keyword_set(maxDFileScan)) then begin
		maxDFileScan=0L
		for i=0,n_elements(uscanar)-1 do begin &$
			ii=where(scanAr eq uscanar[i],cnt) &$
			maxDfileScan=(maxDFileScan > cnt) &$
		endfor
	endif
	ii=where((fnmi.date eq sumI[0].date) and $
	         (fnmi.band eq sumI[0].band) and $
	         (fnmi.grp  eq sumI[0].grp)  and $
	         (fnmi.num  eq sumI[0].num),nbeams)
	ubeams=fnmi[ii].bm
;
; loop getting the data and cals
;
;   indices for calon,caloff, start of data beam 0
	 iion=where((sumi.h.obsmode eq 'CAL') and $
               (sumi.h.scantype eq 'ON'),non)
     iioff=where((sumi.h.obsmode eq 'CAL') and $
                 (sumi.h.scantype eq 'OFF'),noff)

; following  assumes data takes less than 100 files...
	iid1=where((sumi.h.obsmode eq 'ON')  and $
		       (sumi.num mod 100L eq 0),ndatst)
	nscans=min([n_elements(iion),n_elements(iioff),n_elements(iid1)])
;	ii=where((sumi.h.obsmode eq 'CAL')  and $
;             (sumi.h.scantype eq 'OFF'),nscans)
	scanI={$
		nfilesD   : 0L,$
		nrowsD    : 0L,$
		ndumpD    : 0L,$
		nrowsC    : 0L,$
		ndumpC    : 0L,$
		sumI_D0   : sumi[0],$ ;  bm 0 dat 0 sumI file
		fnmIDat   :replicate(fnmi[0],nbeams,maxDFileScan),$
		fnmICalOn :replicate(fnmi[0],nbeams),$
		fnmICalOff:replicate(fnmi[0],nbeams)$
	}
	scanIAr=replicate(scanI,nscans)
;
	for iscan=0,nscans -1 do begin
		iid   =iid1[iscan]
		iiCon =iion[iscan]
		iiCoff=iioff[iscan]
		scanD=sumI[iid].h.scan_id
		nfilesD=0
		nrowsD=0L       		; all datafiles
		for i=0,maxDfileScan-1 do begin
			if sumi[iid+i].h.scan_id ne scanD then break
			nfilesD++
			nrowsD+=sumi[iid+i].nrows
		endfor
		scanIAr[iscan].nrowsD=nrowsD
		scanIAr[iscan].ndumpD=sumI[iid].dumprow; spc per row (except maybe last?)
		scanIAr[iscan].nfilesD=nfilesD
; 		assumes calon=caloff and only 1 file for each
		scanIAr[iscan].nrowsC=sumi[iiCon].nrows
		scanIAr[iscan].ndumpC=sumi[iiCon].dumprow
        scanIar[iscan].sumI_d0  =sumi[iid]
		for ibm=0,nbeams-1 do begin
;
;		here's the data
 			for i=0,nfilesD - 1 do begin
				ii=where((fnmi.date eq sumi[iid+i].date) and $
		             (fnmi.num  eq sumi[iid+i].num) and $
				     (fnmi.bm eq ibm),cnt)
				if cnt ne 1 then begin
					print,"could not find data scan for bm:",ibm
					help,sumi[iid+i],/st
					return,-1
				endif
				scanIAr[iscan].fnmiDat[ibm,i]=fnmi[ii]
			endfor
;       cals
			ii=where((fnmi.date eq sumi[iicOn].date) and $
		         	 (fnmi.num  eq sumi[iicOn].num) and $
				 	 (fnmi.bm eq ibm),cnt)
			if cnt ne 1 then begin
				print,"could not find calOn scan for bm:",ibm
					help,sumi[iicon],/st
					return,-1
			endif
			scanIAr[iscan].fnmICalOn[ibm]=fnmi[ii]
;      cal off
			ii=where((fnmi.date eq sumi[iicOff].date) and $
		          	 (fnmi.num  eq sumi[iicOff].num) and $
				 	 (fnmi.bm eq ibm),cnt)
			if cnt ne 1 then begin
				print,"could not find calOff scan for bm:",ibm
				help,sumi[iicoff],/st
				return,-1
			endif
			scanIAr[iscan].fnmiCalOff[ibm]=fnmi[ii]
		endfor
	endfor
	return,nscans
end
