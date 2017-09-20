;+
;NAME:
;pfrms - compute rms/mean by chan for every scan in file
;SYNTAX: numproc=pfrms(filein,fileout,rembase=rembase,minrecs=minrecs,
;                      excludepat=excludepat,zerorate=zerorate,lunLog=lunLog,
;                      han=han,doplot=doplot)
;ARGS:
;       fileIn  :string     name of input file
;       fileOut :string     name of file to store rms/mean by channel
;KEYWORDS:
;       minrecs : int       minimum number of records needed in a scan
;                           to process it. (default=5).
;       rembase : int       if set then remove linear baseline before rms
;   excludepat[]: strings   array of patterns to exclude.
;   zerorate    : int       if set then require zero rate to process scan.
;   han         : int       if set then hanning smooth the input data.
;   lunLog      : int       lun to append ascii log info to.
;   doplot      : int       if set then plot each rms after computing
;RETURNS:
;   numproc :   int         number of scans output.
;                        -1 error opening input file
;                        -2 error opening output file
;DESCRIPTION:
;  For each scan in fileIn compute rms/mean by channel. Output the
;rms/mean by channel along with the header to file fileOut. This data
;can be read in later with corget(lun,b,/noscale);
;The data output will have the same format header,data except that:
;1. the freq data is replaced by rms/mean by channel
;2. there is  only one record per scan.
;-
;13nov04 - mods for was files
;13feb05 - exclude pattern spider*, cross*
;
function pfrms,fileIn,fileOut,minRecs=minRecs,rembase=rembase,han=han,$
               zerorate=zerorate,lunLog=lunLog,excludepat=excludepat,$
               doplot=doplot
            
                
;
    if not keyword_set(minRecs) then minRecs=5
;
;   open files
;
	fileOpen=0
	usewas=wascheck(0,file=fileIn)
    lunIn=-1 
    lunOut=-1
    scanout=0
    if not keyword_set(lunLog)  then lunLog=-1
    if not keyword_set(rembase) then rembase=0
    if not keyword_set(doplot)  then doplot =0
	if usewas then begin
		istat=wasopen(fileIn,lunIn)
		if istat ne 1 then begin
        	print,'err opening:',fileIn
        	if lunLog ne -1 then printf,lunLog,'err opening:',fileIn
        	retstat=-1
        	goto,errout
		endif
    endif else begin
    	openr,lunIn,fileIn,error=err,/get_lun
    	if err ne 0 then begin
        	print,'err opening:',fileIn,!err_string
          if lunLog ne -1 then printf,lunLog,'err opening:',fileIn,!err_string
        	retstat=-1
        	goto,errout
    	endif
	endelse
    numexclude=0
    if keyword_set(excludepat) then numexclude=n_elements(excludepat);
    if not keyword_set(zerorate) then zerorate=0.
;
    openw,lunOut,fileOut,error=err,/get_lun
	fileOpen=1

    if err ne 0 then begin
        print,'err opening:',fileOut,!err_string
        if lunLog ne -1 then printf,lunLog,'err opening:',fileOut,!err_string
        retstat=-2
        goto,errout
    endif
	if not usewas then begin
		print,'scanning:',filein
		slar=getsl(lunIn)
		print,'scanning complete:'
	endif
;
;   loop till end of file
;
	nscans=(usewas)?lunIn.totscans: n_elements(slar)
;
; debug
;    print,'found ',nscans,'scans in file'
;    if lunLog ne -1 then printf,lunLog,'found ',nscans,'scans in file'
;
; debug
;
	for i=0,nscans-1 do begin
;    while (corinpscan(lunIn,b,han=han,sl=sl) gt 0) do begin
        skip=0
        matchrate=0
        matchcnt =0
		numrecs=(usewas)?lunIn.scanI[i].recsInScan:slar[i].numrecs
		procNm =(usewas)?lunIn.scanI[i].patnm:slar[i].procname
		scan   =(usewas)?lunIn.scanI[i].scan:slar[i].scan
        if (numrecs lt minRecs) then begin
		  lab=string(format='("Skipping ",i9," nrecs<minrecs:",i3,i3)',$
				scan,numrecs,minrecs)
		  print,lab
;		  if lunlog ne -1 then printf,lunlog,lab
		  goto,botloop
		endif
; 
;       was pol mode, skip since acf's , also skip
;
		if (usewas) then begin
		   if (strlowcase(strmid(lunIn.scanI[i].patnm,0,6)) eq 'spider') then $
			     goto,botloop
		   if (strlowcase(strmid(lunIn.scanI[i].patnm,0,5)) eq 'cross') then $
			     goto,botloop
		endif

        if  (numexclude gt 0) then begin
            ind=where(procNm eq excludepat, matchcnt)
			if matchcnt gt 0 then begin
		  		lab=string(format='("Skipping ",i9," excl patnam:",a)',$
							scan,procNm)
		        print,lab
;;		        if lunlog ne -1 then printf,lunlog,lab
				goto,botloop
			endif
        endif
        istat=corinpscan(lunIn,b,han=han,sl=slar,scan=scan)
		if istat ne 1 then begin
		  		lab=string(format='("Skipping ",i9," corinpscan stat:",i2)',$
							scan,istat)
		        print,lab
		        if lunlog ne -1 then printf,lunlog,lab
			goto,botloop
		endif
        if n_elements(b) lt minrecs then begin
	lab=string(format='("Skipping ",i9," corinpscan too few recs read.")',$
							scan)
		        print,lab
		        if lunlog ne -1 then printf,lunlog,lab
			goto,botloop
		endif

		numbrdsused=b[0].b1.h.cor.numbrdsused 
		if (b[0].b1.h.cor.lagconfig eq 10) then begin
		        print,"skipping scan, since stokes mode"
				goto,botloop
		endif
			
        if (zerorate and (numrecs gt 1)) then begin
			if usewas then begin
                if  (b[1].b1.hf.rate_ra  ne 0.) or $
                (b[1].b1.hf.rate_dec ne 0.) then begin
		  		lab=string(format='("Skipping ",i9," nonzero rate")',$
							scan)
		        print,lab
		        if lunlog ne -1 then printf,lunlog,lab
				goto,botloop 
			    endif	
			endif else begin
               if  (b[1].b1.h.pnt.r.reqraterdsec[0] ne 0.) or $
                      (b[1].b1.h.pnt.r.reqraterdsec[1] ne 0.) then goto,botloop 
			endelse
        endif
        lfrq=''
        for j=0,numbrdsused-1 do begin
              lfrq=lfrq + string(format='(f7.1)',corhcfrtop(b[0].(j).h))
        endfor
        lab=string(format=$
'("src: ",a16," scan: ",i9," recs: ",i3," rcv: ", i2," frq: ",a," han: ",i1)',$
        string(b[0].b1.h.proc.srcname),b[0].b1.h.std.scannumber,$
                    numrecs,iflohrfnum(b[0].b1.h.iflo),lfrq,han)
        print,lab
        if lunLog ne -1 then printf,lunLog,lab
        if (doplot) then begin 
           r=corrms(b,rembase=rembase) 
           corplot,r
           coroutput,lunOut,r
        endif else begin
           coroutput,lunOut,corrms(b,rembase=rembase)
        endelse
        scanout=scanout+1
botloop:
    endfor
	if usewas then begin
		if n_tags(lunin) gt 0 then wasclose,lunIn
	endif else begin
    	free_lun,lunIn
	endelse
    free_lun,lunOut 
    if lunLog ne -1 then flush,lunLog
	if (scanout eq 0) and (fileopen) then file_delete,fileOut
    return,scanout
errout:
    if usewas then begin
		if n_tags(lunin) gt 0 then wasclose,lunIn
	endif else begin
    	if lunIn gt 0 then  free_lun,lunIn
	endelse
    if lunOut gt 0 then free_lun,lunOut
    if lunLog ne -1 then flush,lunLog
	if (scanout eq 0) and (fileopen) then file_delete,fileOut
    return,retstat
end
