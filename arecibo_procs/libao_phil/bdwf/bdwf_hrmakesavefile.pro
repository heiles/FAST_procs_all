;+
;NAME:
;bdwf_hrmakesavefile - make hires save file
;SYNTAX:istat=bdwf_hrmakesavefile(hrI,hdcopytp=hdcopytp)
;ARGS:
;hrI : {}  struct initialized by bdef_hrinit();
;keywords: 
; hdrcopytp: int if set then make total power hardcopy
;                (calling bdwf_hrplottp
;RETURNS:
;istat: int 0 ok, -1 we had an error processing the
;             requested data (files not there?)
;hrI : {}  some of the elements in this structure
;          get loaded:
;          hrI.nsavfiles, hrI.savFileNms[], hrI.pntsEachScan
;
;DESCRPTION:
;	The user first calls bdwf_hrinit(..) to initialize hrI
;structure with the scan to process. This routine then
;searches for the mock datafiles, inputs them,calibrates
;the data, optionally averages over the spectra in 1 row 
;(giving .9 sec resolution vs .1 sec resolution),
; computes the rms by freq channel, computes the total
;power for each mock band, and then stores all of this
;info in a save file.
;	This save file is later used by the other bdwf_xxx routines
;to create the binary image file, and display the spectra.
; do hires processing for a detection
; user must set when the detection occurred.
;
;-
function bdwf_hrmakesavefile,hrI,hdcopytp=hdcopytp

	lyyyymmdd=string(format='(i08)',hrI.yyyymmdd)
	lproj=hrI.proj
;expTimeUtc= expTimeAst + 3600*4d &$
;
	grp=0
	band=1 
	wait=0
	n=masfilelist('',fnmI,proj=hrI.proj,yymmdd=hrI.yyyymmdd,grp=grp,band=band,/appbm)
	if n eq 0 then begin &$
		print,"no files found"
		return,-1
	endif
	nscans=bdwf_getscaninfo(fnmI,hrI.rcvNum,scaniar)
	src=scaniar.sumI_d0.h.object
	ii=where(src eq hrI.srcToGet,cnt)
	scaniar=scaniar[ii]
	ii=where((scaniar.fnmidat[0].num eq hrI.fileNumDat),cnt)
	scanIar=scanIar[ii]
	scanInStrip=ii[0]
;
	nsrc=1

	lbase=hrI.srcToGet  + "_" +  lyyyymmdd + string(format='("_",i02)',scanInStrip)
	print," process scan set:",scanIar.fnmidat[0].fname," for src:",hrI.srcToGet
;
	saveBaseAr=hrI.savDirNm + lbase 
	print,"avgrow...",hrI.avgrow
	istat=bdwf_hrdoitmock(hrI,scanIAr,saveBaseAr,wait=wait)
;
	if (n_elements(hdcopytp) eq 0) then return,0
	if not keyword_set(hdcopytp) then return,0
; below.. cut an paste to generate total power
; plots of this 1 scan (with the burst).
; 
	print,"making hardcopy plots of total power for this scan"
	fitScanDeg=2 &$
	fitza=0
	usrc=hrI.srctoget
	vpol=[[-100,100],[-20,20],[-5,5],[-5,5]]
	vpol=[[-100,100],[-40,40],[-40,40],[-40,40]]
	savBase1=saveBaseAr + "_" &$
	srcNm=hrI.srctoget &$
	ii=where(scanIar.sumi_d0.h.object eq srcNm,nscan1) &$
	pntsScan1=hrI.pntsEachScan[0]  &$
	lbase1=srcnm + "_hr_" + lyyyymmdd &$
	ldate1=srcnm + lyyyymmdd &$
	bdwf_plttp,savbase1,nscan1,pntsScan1,lproj,lbase1,ldate1,fitscandeg=fitscandeg,$
			tpall=tpall,tpfall=tpfall,zaall=zaall,azall=azall,fitza=fitza,jdall=jdall,$
			/hr,vpol=vpol
	return,0
;
end
