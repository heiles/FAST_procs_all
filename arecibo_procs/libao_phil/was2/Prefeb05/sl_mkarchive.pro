;+
;NAME:
;sl_mkarchive - create scan list for archive
;
;SYNTAX: nscans=sl_mkarchive(listfile,slAr,slFileAr,logfile=logfile,$
;							 verbose=verbose)
;
;ARGS:
;   listfile: string. filename holding names of files to scan
;                     (one per line). semi-colon as the first char is a comment.
;RETURNS:
;   slAr[nscans] {sl}    One large scanlist array for all the files
;   slfileAr[m]: {slInd} One entry per file showing where each file starts/
;                        stops in slAr.
;   nscans     : long  number of scans found
;
;KEYWORDS:
;   verbose:    If set then print each file as we process it.
;   logfile: string   name of file to write progress messages. by default 
;               messages only go to stdout.

;
;DESCRIPTION:
;   sl_mkarchive is given a list of spectral line fits files. It scans 
;each of these files and extracts information to put into an archive record.
;There is on archive record per scan. This information is then stored
;on disc in an idl save file format (usually by month). The routine
;arch_gettbl() can then be used to read this information in and process it.
;
;   The archive record consists of:
;  scan      :         0L, $; scannumber this entry
;    rowStart  :         0L, $; row in fits file start of scan 0 based.
;    fileindex :         0L, $; lets you point to a filename array
;    stat      :         0B ,$; not used yet..
;    rcvnum    :         0B ,$; receiver number 1-16, 17=alfa
;    numfrq    :         0B ,$; number of freq,cor boards used this scan
;    rectype   :         0B ,$;1-calon,2-caloff,3-posOn,4-posOff
;    numrecs   :         0L ,$; number of groups(records in scan)
;    freq      :   fltarr(8),$;topocentric freqMhz center each subband
;    julday    :         0.D,$; julian day start of scan
;    srcname   :         ' ',$;source name (max 12 long)
;    procname  :         ' ',$;procedure name used.
;    stepName  :         ' ',$;name of step in procedure this scan
;    projId    :         '' ,$; from the filename
;    patId     :         0L ,$; groups scans beloging to a known pattern
;
;   secsPerrec :         0. ,$; seconds integration per record
;    channels  :   intarr(8),$; number output channels each sbc
;    bw        :   fltarr(8),$; bandwidth used Mhz
;    backendmode:  strarr(8),$; lag config each sbc
;    lag0      :  fltarr(2,8),$; lag 0 power ratio (scan average)
;    blanking  :         0B  ,$; 0 or 1
;
;    azavg     :         0. ,$; actual encoder azimuth average of scan
;    zaavg     :         0. ,$; actual encoder za      average of scan
;    encTmSt   :         0. , $; secs Midnite ast when encoders read
;;                               start of scan
;
;    raHrReq   :         0.D,$; requested ra ,  start of scan  J2000
;    decDReq   :         0.D,$; requested dec,  start of scan J2000.
;
;;                       Delta end-start real angle for requested position
;    raDelta   :         0. ,$; delta ra last-first recs. Amins real angle
;   decDelta   :         0. ,$; delta dec (last-frist)Arcminutes real  angle
;
;    pntErrAsec :         0. ,$; avg great circle pnt error
;
;
;;     alfa related
;
;     alfaAngle:         0.  , $; alfa rotation angle used in deg
;     alfaCen :          0B  $; alfa pixel that is centered on ra/dec position
;
;
;   The routine sl_mkarchive is run monthly and the info is stored in 
;files by month. This routine can then be run to create the slar data
;for the was
;
;EXAMPLE:
;
;   The monthly processing would look like:
;;
;;1. create listfile from corflist.sc 010101 010131 excl.dat outside of idl.
;;2. make the slAr, slFileAr and save it
;
;nscans=sl_mkarchive(listfile,slAr,slfilear)
;save,sl,slar,file='/share/megs/phil/x101/archive/was/f010101_010131.sav'
;;
;
;SEE ALSO:sl_mkarchive,arch_gettbl,arch_getdata
;-
;history:
;   17aug04 - start was2 
;   28jan05 - <pjp001> raj was being converted from deg to hours but it 
;             was already  in hours.. rerun nov, dec archive..
;
function  sl_mkarchive,listfile,slAr,slFileAr,verbose=verbose,$
            logfile=logfile
;
	mjdOffset=2400000.5D
    maxscans=30000L
    maxfiles=1000L
    filind=0L
    fileInp=0L
    fnameind=0
    scnInp=0L
    slAr    =replicate({slwas}   ,maxscans)
    slFileAr=replicate({slInd},maxfiles)
    scangrow=maxScans/2
    filegrow=maxfiles/2
    cnt=0
    lunOut=-1
    on_ioerror,done
    lun1=-1
    openr,lun1,listfile,/get_lun
    line=' '
    if n_elements(logfile) gt 0 then begin
        openw,lunout,logfile,/get_lun,/append
        printf,lunout,'starting sl_mkarchive' + systime()
    endif
	itot=0L
	while 1 do begin
    	readf,lun1,line
;       print,'inp:'+line
        if strmid(line,0,1) eq ';' then  goto,botloop
        fullname=strsplit(line,' ',/extract)
        fullname=fullname[fnameind]
        lab=string(format='("processing file:",a," scans done:",i5)',$
                        fullname,itot)
        print,lab
        size=0L
        if lunOut ne -1 then printf,lunOut,lab
        stat=file_exists(fullname,junk,size=size)
        if (stat ne 1) or  (size eq 0) then begin
			  lab='file:'+fullname+ ' has no data'
              print,lab
              if lunOut ne -1 then printf,lunOut,lab
			  goto,botloop
		endif
        error=0
        useWas=wascheck(lun,file=fullname)
        if not useWas then begin
			lab='file:'+fullname+' not a fits file. skipping..'
			print,lab
            if lunOut ne -1 then printf,lunOut,lab
		    goto,botloop 
		endif
        istat=wasopen(fullname,desc)
        if istat eq 0 then begin
		 	error=1
            lab='Err opening ' + fullname
            print,lab
            if lunOut ne -1 then printf,lunOut,lab
		    goto,botloop
		endif 			

		if desc.totscans eq 0 then goto,botloop
		if itot + desc.totscans gt maxScans then begin
           slART=temporary(slAr)
           slAr =replicate({sl},maxscans+scangrow)
           slAr[0:maxscans-1]=slArT
           slArT=''
           maxScans=maxScans+scangrow
        endif
        if fileInp eq maxFiles then begin
            slfileArT  =temporary(slfileAr)
            slFileAr   =replicate({slInd},maxfiles+filegrow)
            slFileAr[0:maxfiles-1]=slFileArT
            slFileArT=''
            maxFiles=maxFiles+filegrow
        endif
;
;		loop over all the scans in this file
;	
		itot0=itot				; start itot value
		nscans=desc.totscans
		for iscan=0,nscans-1 do begin
			if desc.scanI[iscan].rowsinscan lt desc.scanI[iscan].rowsinrec then $
						continue
			slAr[itot].scan    =desc.scanI[iscan].scan
			rowInd        =desc.scanI[iscan].rowStartInd
			slAr[itot].rowStart=rowInd
			slAr[itot].stat    =0B
		    fxbread,desc.lun,frontend,'FRONTEND',rowInd+1,errmsg=errmsg
			useAlfa=frontend eq 'alfa'
       		if useAlfa then begin
				slAr[itot].rcvnum = 17
;
;				see if rotation angle is in the header
;
				if desc.colI.alfaAngle ne -1 then begin
		    		fxbread,desc.lun,rotangle,desc.colI.alfaAngle,rowInd+1,$
							errmsg=errmsg
					slar[itot].alfaAngle=rotangle
				endif
			endif else begin
		    	fxbread,desc.lun,itemp,'RFNUM',rowInd+1,errmsg=errmsg
       			slAr[itot].rcvnum = itemp
       			slAr[itot].alfaAngle = 0.
			endelse
	
       		slAr[itot].numrecs= desc.scanI[iscan].recsInScan
			ilast=(desc.scanI[iscan].nbrds < 8)
			slar[itot].numfrq = ilast

       		for j=0,ilast-1 do begin
           		irow=rowInd  + desc.scanI[iscan].ind[0,j]
           		fxbread,desc.lun,frq,'CRVAL1',irow + 1,errmsg=errmsg
           		slAr[itot].freq[j] = frq*1d-6
       		    fxbread,desc.lun,bw,'BANDWID',irow  + 1,errmsg=errmsg
		        slAr[itot].bw[j]   =bw*1e-6
       		    fxbread,desc.lun,backendmode,'BACKENDMODE',irow  +1,$
							errmsg=errmsg
		        slAr[itot].backendmode[j] =backendmode
       		endfor
       		fxbread,desc.lun,dtemp,desc.coli.jd,rowInd+1,errmsg=errmsg
       		slAr[itot].julday = dtemp + mjdOffset
       	   	fxbread,desc.lun,srcnm,'OBJECT',rowInd+1,errmsg=errmsg
            slAr[itot].srcname  = strtrim(srcnm)
       	    fxbread,desc.lun,procnm,'OBSMODE',rowInd+1,errmsg=errmsg
      		slAr[itot].procname = strlowcase(strtrim(procnm))
       	    fxbread,desc.lun,stepname,'OBS_NAME',rowInd+1,errmsg=errmsg
      		slAr[itot].stepname = strlowcase(strtrim(stepname))

			case slar[itot].procname of
				'onoff'  : begin	
						  case slar[itot].stepname of
							'on'  :slar[itot].rectype=3
							'off' :slar[itot].rectype=4
							else  :slar[itot].recteyp=0
						  endcase
						  end
				'cal'    : begin
						  case slar[itot].stepname of
							'on'  :slar[itot].rectype=1
							'off' :slar[itot].rectype=2
							else  :slar[itot].rectype=0
						  endcase
						  end
				'smartf'      :slar[itot].rectype=27
				'fixedaz'     :slar[itot].rectype=28
				'basketweave' :slar[itot].rectype=29
				'spidera0'    :slar[itot].rectype=20
				'spidera1'    :slar[itot].rectype=21
				'spidera2'    :slar[itot].rectype=22
				'spidera3'    :slar[itot].rectype=23
				'spidera4'    :slar[itot].rectype=24
				'spidera5'    :slar[itot].rectype=25
				'spidera6'    :slar[itot].rectype=26

				'crossa0'     :slar[itot].rectype=30
				'crossa1'     :slar[itot].rectype=31
				'crossa2'     :slar[itot].rectype=32
				'crossa3'     :slar[itot].rectype=33
				'crossa4'     :slar[itot].rectype=34
				'crossa5'     :slar[itot].rectype=35
				'crossa6'     :slar[itot].rectype=35
				else          :slar[itot].rectype=0
			endcase
		
		    slAr[itot].projId  =desc.projId
       		fxbread,desc.lun,pattern_scan,'PATTERN_SCAN',rowInd+1,$
					errmsg=errmsg
		    slAr[itot].patid   =pattern_scan
       		fxbread,desc.lun,exposure,'EXPOSURE',rowInd+1,errmsg=errmsg
		    slAr[itot].secsPerRec  =exposure
		   	slAr[itot].channels    =desc.scanI[iscan].nlags
       		fxbread,desc.lun,enctm,'ENC_TIME',rowInd+1,errmsg=errmsg
		   	slAr[itot].encTmSt     = encTm*.001
;
;		 read all rows of scan for following positions 
;
			rowRange=[rowInd,rowInd+desc.scanI[iscan].ROWSINSCAN-1]+1
       		fxbread,desc.lun,lag0,'TOT_POWER',rowRange,errmsg=errmsg
       		fxbread,desc.lun,az,'ENC_AZIMUTH',rowRange,errmsg=errmsg
       		fxbread,desc.lun,el,'ENC_ELEVATIO',rowRange,errmsg=errmsg
       		fxbread,desc.lun,pntErr,'CUR_TOL',rowRange,errmsg=errmsg
			slAr[itot].azavg=mean(az)
			slAr[itot].zaavg=mean(90.-el)
			slAr[itot].pntErrAsec=mean(pntErr)
;
;	 			need to redimension lag0 to match the data
;
			rowsInRec=desc.scanI[iscan].rowsinrec
			nrecs=desc.scanI[iscan].rowsInScan/rowsInRec
			lag0=reform(lag0[0:rowsInRec*nrecs-1],rowsInRec,nrecs)
			for i=0,ilast-1 do begin
				slAr[itot].lag0[0,i]=mean(lag0[desc.scanI[iscan].ind[0,i],*])
				if  desc.scanI[iscan].pol[1,i] ne 0 then $
					slAr[itot].lag0[1,i]=$
						mean(lag0[desc.scanI[iscan].ind[1,i],*])
			endfor
;
; 	ra,dec
;
       		fxbread,desc.lun,ra,desc.colI.raj,rowInd+1,errmsg=errmsg
       		fxbread,desc.lun,dec,desc.colI.decj,rowInd+1,errmsg=errmsg
;			slAr[itot].raHrReq=ra/15D  ; <pjp001> already in hours
 			slAr[itot].raHrReq=ra 
			slAr[itot].decDReq=dec
;
;  get ra,dec deltas, start,end of scan
;
       		fxbread,desc.lun,raEnd,desc.coli.raJ,$
				rowInd+desc.scanI[iscan].rowsInScan,errmsg=errmsg
       		fxbread,desc.lun,decEnd,desc.coli.decJ,$
				rowInd+desc.scanI[iscan].rowsInScan,errmsg=errmsg
			slAr[itot].decDelta=(decEnd-dec)*60.
			if (slAr[itot].decDelta) lt 1e-6  then slAr[itot].decDelta=0.
			slAr[itot].raDelta =(raEnd-ra)*cos((decEnd+dec)$
						*!dtor)*60.*15.    ; <pjp001> its in hours..
			if (slAr[itot].raDelta) lt 1e-6  then slAr[itot].raDelta=0.
			itot=itot+1l
        endfor
		wasclose,desc
;
;           split,path and filename
;
        ind=strpos(fullname,'/',/reverse_search)
        if ind ne -1 then begin
           filename=strmid(fullname,ind+1L)
           pathname=strmid(fullname,0,ind+1L)
        endif else begin
           filename=fullname
           pathname='./'
        endelse
        slAr[itot0:itot0+nscans-1].fileindex=lonarr(nscans) + fileInp
        slFileAr[fileInp].i1=itot0
        slFileAr[fileInp].i2=itot0 + nscans - 1L
        slFileAr[fileInp].path=pathname
        slFileAr[fileInp].file=filename
        slFileAr[fileInp].size=size
        fileInp=fileInp+1L
botloop:
    endwhile
done:
    if lunOut ne -1 then begin
        printf,lunOut,'finished running sl_mkarchive'+ systime()
        free_lun,lunOut
        lunOut=-1
    endif
	if lun1 ne -1 then free_lun,lun1
    if fileInp lt maxFiles then begin
        if fileinp eq 0 then begin
            slfilear=''
            slar=''
            itot=0L
        endif else begin
            if fileinp ne maxfiles then slFileAr=slFileAr[0:fileinp-1]
            if scnInp lt maxScans then  slAr    =   slAr[0:itot-1]
        endelse
    endif
    return,itot
end
