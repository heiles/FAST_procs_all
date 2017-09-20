;+
;NAME:
;masdpsproc - process multiple dps patterns
;SYNTAX:npat=masdpsproc(ProjId,nband,bar,patI,srcNm=srcNm,cfr=cfr,dateAr=datear,$
;                       epscfr=epscfr,exclpatid=exclpatid,wait=wait,$
;                       barp=barp)
;ARGS:
; projId: string    project id to match.
;
;KEYWORDS:
;srcNm[m]:strarr    limit to sources in srcNm array. The names 
;                   should match those in the fits.object header.case matters.
;cfr     :float     only include patterns whose average freq is cfr(in Mhz).
;                   The routine averages all of cfr's of a pattern.
;                   also see epscfr=
;dateAr[l]:lonarr   only include patterns whose file dates match a 
;                   date in datear[]. The format is yyyymmdd. 
;epscfr   :float    Include patterns with average cfr within epsCfr of
;                   the cfr keyword. Units are MHz. The default value
;                   is 10. Mhz.
;exclPatId[n]: int  exclude any pattern id's in this array.
;wait     : int     if true then wait for a keyboard entry between
;                   each plot.
;
;RETURN VALUES:
;            npat:int number of patterns we found
;           nband:int number of frequency bands in each pattern
; bar[nband,npat]: {} array of mas struct holding dps processed patterns
;patI[nband,npat]: {} array of structs holding info on each pattern.
;barP[nband,npat]: {} array of mas struct holding dps processed patterns
;                     after polarizations have been added. 
;
;TERMINOLOGY:
; spectra: a single integrated spectrum. Typically 1 second.
; scan   : a set of spectra with the same receiver setup and telescope motion,
;          taken for a requested number of spectra..
;          eg. the on source, or off source are separate scans. The header holds
;          a h.scan_id to identify each scan
; pattern: A number of scans that are taken to form a particular pattern. In 
;          dps there are at least 4 scans in a pattern: calibrator on,off and
;          source on,off. The header contains hdr.pattern_id
; band   : a single scan,pattern can have up to 14 frequency bands (corresponding
;          to the 14 mock boxes. 
;
;DESCRIPTION:
;	Find and process a number of dps (double position switch) patterns.
;This routine uses masdpsfind and masdpsp. 
;	The user specifies the project id to search for. The caller can further limit 
;the patterns used by:
;   srcNm[m] : this is an array of source names. For a pattern to be included
;              its hdr.object must match one of these names. Case in important.
;   dateAr[l]: a list of dates that each pattern must match. Format is
;              yyyymmdd. The files includes must have one of these dates.
;  cfr,epscfr: Mhz. Average the cfr of all of the bands in a pattern. To be
;              included, it must be withing epsCfr(mhz) of the supplied cfr.
;exclPatId[n]: exclude any pattern id that is in this array. You can use
;              this to skip bad patterns.
;
;	After finding all of the patterns that meet the requirements, the routine
;will process one pattern at a time. Each processed pattern will be plotted to
;the screen. If the wait keyword is set, then the user will have to hit a key
;to continue after each plot.
;
;	The routine returns the processed pattern data in bar[nbands,npat]. If 
;barp=barp keyword is present, then then barp[nbands,npat] variable will contain
;the polarization averaged spectra. 
;
; ---------------------------------------------------------------------
;EXAMPLE:
;	process the a2772 5-6 ghz data taken  07jun13 -> 12jun13.
;
;   projId  ='a2765'
;   scrNm   ='ARP220'
;   cfr     =5500.
;   yymmddar=[20130607,$
;             20130610,$
;             20130611,$
;             20130612] 
;   npat=masdpsproc,projId,nband,bar,patI,srcNm=srcNm,cfr=cfr,dateAr=dateAr,$
;                   barp=barp
;
;   The returned values are:
;   npat=20
;   nband=14
;   bar[14,20]
;   barp[14,20]
;   patI[14,20]
;
;  The patI struct contains
;IDL> help,pati
;PATI            STRUCT    = -> <Anonymous> Array[14, 20]
;IDL> help,pati,/st
;** Structure <8e1d68>, 7 tags, length=7664, data length=7568, refs=2:
;   SRCNM           STRING    'ARP220'
;   BM              INT              0
;   GRP             INT              0
;   NSCANS          INT              4
;   PATID           LONG         315800057
;   FILELIST        STRING    Array[6]
;   SUMI            STRUCT    -> <Anonymous> Array[6]
;
; The SumI holds summary info for a scan. It includes the fits header
;
;IDL> help,pati.sumi,/st
;** Structure <91e808>, 13 tags, length=1256, data length=1241, refs=2:
;   OK              INT              1
;   FNAME           STRING    '/share/pdata1/pdev/a2765.20130607.b0s1g0.00200.fits'
;   FSIZE           LONG64                  20643840
;   NROWS           LONG               300
;   DUMPROW         LONG                 1
;   DATE            LONG          20130607
;   BM              INT              0
;   BAND            INT              1
;   GRP             INT              0
;   NUM             LONG               200
;   H               STRUCT    -> MASFHDR Array[1]  <--- standard fits header
;   HMAIN           STRUCT    -> PDEV_HDRPDEV Array[1]
;   HSP1            STRUCT    -> PDEV_HDRSP1 Array[1]
;
;SEE ALSO:
; masdpsfind(), masdpsp()
;-
function masdpsproc,projId,nbands,bar,patI,srcNm=srcNm,cfr=cfr,dateAr=dateAr,$
                       epscfr=epscfr,exclpatid=exclpatid,wait=wait,$
                       barp=barp
;
	nsrcNm=n_elements(nsrcNm)
	if (n_elements(epscfr) eq 0) then epscfr=10.
	if (n_elements(wait)   eq 0) then wait=0
	nexcl=n_elements(exclpatid)
	polAvg=arg_present(barp)
	
	
	print,"Searching..."
	n=masdpsfind(projid,patI,npat,upatidar,nsrc,usrcar,$
			yymmdd=dateAr,/appbm,band=1,srcnm=srcnm)
	;
	; check to make sure each pattern this date is our  center freq
    ; 	
	patOk=intarr(n)				; put 1 for each pattern that is ok
	nbands=-1
	for ipat=0,npat-1 do begin
		if nexcl gt 0 then begin
		   ii=where(upatidar[ipat] eq exclpatid,cnt)
		   if cnt gt 0 then begin
			 print,"excluding patId match:",upatidar[ipat]," skipping"
			 continue
		   endif
		endif
		ii=where(patI.patid eq upatidar[ipat],nbandsPat)
		if nbands lt 0 then nbands=nbandsPat
	   ; compute mean freq all bands of this pattern
		if (n_elements(cfr) gt 0) then begin
   			cfrAvg=mean(pati[ii].sumi[0].h.crval1*1e-6)
	 		if ((abs(cfravg - cfr) gt epsFreq)) then begin
        		print," Skipping pattern id:",upatidar[ipat],$
            		" Srcnm:",patI[ii[0]].srcNm," CenterFreq:",cfravg
			endif
		endif
		if (nbandsPat ne nbands) then begin
			   	print,"expected:",nbands," freq bands. Found:",nbandsPat," skipping"
			   continue
		endif
		patOk[ii]=1
	endfor
	ii=where(patOk eq 1,nNew)
	if (nNew eq 0) then begin 
		print,"No dps patterns found."
		return,0
	endif
	if nNew ne n then begin
		patI=patI[ii]
		n=n_elements(patI)
	endif
	upatidar=patI[uniq(pati.patid,sort(pati.patid))].patid
	npat=n_elements(upatidar)
;
;
; 	input each pattern, and store in large array:
;    bar[14,npat]= with both pols
;    barP[14,npat]=  pols have been added
;
	print,"Found:",npat
    print,"Processing..."
	icur=0
	for ipat=0,npat-1 do begin
;   get all the band for this pattern
		ii=where(pati.patid eq upatidar[ipat],nb)
		lab=string(format='("patInd:",i3," patId:",i9," bands:",i2," 1stfile:",a)',$
					ipat,upatidar[ipat],nb,basename(pati[ii[0]].filelist[0]))
	    print,lab
	;
	; loop over the bands for this pattern
	;
		for ib=0,nb-1 do begin &$
		 	is=masdpsp(pati[ii[ib]].filelist,b) &$
			if PolAvg then bp=masmath(b,/polavg) &$
			if (icur eq 0) and (ib eq 0)  then begin &$
				bar=replicate(b,nbands,npat) &$
				if polAvg then barp=replicate(bp,nbands,npat) &$
				; just to make sure same order as bands &$
				patIS=replicate(patI[0],nbands,npat) &$
			endif &$
        	bar[ib,icur] =b &$
        	if polAvg then barp[ib,icur]=bp &$
			patIS[ib,icur]=pati[ii[ib]] &$
		endfor
	; 
	; plot all the bands
	; adjust vertical scale to -/+ .2 of median
	; make horizontal min,max of freq
		val=(polAvg)?median(barp[*,ipat].d):median(bar[*,ipat].d)
		eps=.2
		if icur eq 0 then  begin
			bw=pati[ii].sumi[0].h.bandwid*1e-6
			cfrAr=pati[ii].sumi[0].h.crval1*1e-6
			minVal=min(cfrar,iimin)
			minVal-=bw[iimin]/2.
			maxVal=max(cfrar,iimax)
			maxVal+=bw[iimax]/2.
			hor,minVal,maxval
		endif
		ver,val-eps,val+eps
		patid=(bar[0,ipat].h.pattern_id)
		fname=basename(pati[ii[0]].filelist[0])
		if polAvg then begin
			masplot,barp[*,ipat],/mfreq,title='Patternid:'+string(bar[0,ipat].h.pattern_id) + ". 1stfile:" +fname
		endif else begin
			masplot,bar[*,ipat],/mfreq,title='Patternid:'+string(bar[0,ipat].h.pattern_id) + ". 1stfile:" +fname
		endelse
		empty
		if (wait) then begin
			print,'xmit to continue'
			key=checkkey(/wait)
		endif
		icur+=1
		patOk[ipat]=1
	endfor
;
	patI=patiS
	return,npat 
end
