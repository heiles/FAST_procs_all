;+ 
;NAME:
;wasopen - open a was fits files for i/o
;
;SYNTAX: istat=wasopen(filename,desc)
;
;ARGS:
;   filename: string  filename to open
;
;KEYWORDS:
;       all:  if the keyword is set, open all files that were taken at
;             this time. In this case filename should be the name
;             of one of the files.
;RETURNS:
;  istat: int          0 couldn't open file
;                      1 file opened successfully
;   desc: {wasdescr} - descriptor holding info for file i/o.
;
;DESCRIPTION:
;   Open a was (wapp) spectral line fits file. Load
;the descriptor with the scan info for the entire file. This
;descriptor will be passed to the wasxxx corxxx routines to do the 
;file i/o. This descriptor replaces the standard lun that is 
;used for the interim correlator data.
;   The descriptor contains:
; 
;   help,desc,/st
;
;   LUN       LONG     0        .. idl lun 
;   FILENAME  STRING '/share/wapp11/a9999_wapp1_0027.fits' ..filename 
;   TOTSCANS  LONG     1        .. total scans in file (obs scans not pattern)
;   TOTRECS   LONG     1        .. total recs (integ)  in file 
;   TOTROWS   LONG  7216        .. total number of rows in bintable
;   CURPOS    LONG     1        .. position for next read 0 based (row-1)
;   SCANIND   LONG     1        .. scan index for next read 0 based 
;   colI      struct            .. column number in table for various info
;   onlI      struct            .. info to process online files.
;   onLine    long              .. true if file is growing (hole exists)
;   SCANI     STRUCT  Array[totscans]   .. scan info  
;   ------------------------------
;   help,desc.scanI,/st
;   SCAN      LONG  327939505   .. this scan number
;   nbrds     long           1  .. number of wapps used
;   nlags     intarr(MAXBRDS)   .. lags sbc per board
;   brdNum    bytarr(MAXBRDS)   .. brd number 1..7
;   nsbc      bytarr(MAXBRDS)   .. number sbc this board 1,2,4
;   level     bytarr(MAXBRDS)   .. 3 or 9 level
;   pol       bytarr(4,MAXBRDS) .. pol id for each sbc of each board
;   corrattn  bytarr(4,MAXBRDS) .. 0 to 15 each pol each board
;                                  1,2,3,4 or 0 not used.
;   rowsinrec  long           0 .. rows in 1 rec
;   rowsinscan LONG           0  .. number of recs (rows) this scan
;                                  multiple recs per observation.
;   recsInScan long           0 .. records in scan
;   cumRecStart long            .. cumulative rec number in file start this scn
;   rowStartInd long          0 .. rowIndex for start of this scan
;   cumRecStartInd lONG       0 .. cum rec index for start of this scan
;  -------------------------------
;   help,desc.colI           .. column numbers for various info
;   scan   long              .. col that scan info in 
;   grp    long              .. col that scan info in 
;   az     long              .. col for az encoder
;   el     long              .. col for main elevatio encoder
;   elAlt  long              .. col for alternate za encoder
;   enctm  long              .. col for the encoder time.
;   patnam long              .. col for the pattern name.
;   flip   long              .. col for the flip spectra
;WAPPMASK  LONG                65
;   CTYPE1 LONG                20
;   JD     LONG                21
; RESTFREQ LONG                14
;VELOCITY  LONG                15
;
;EXAMPLE:
;   filenm='/share/wapp11/wapp1.20040118.a1849.0010.fits'
;   istat=wasopen(filenm,desc)
;
;   waslist,desc            ; list scan summary
;   istat=corget(desc,b)    ; read a record
;   corplot,b               ; plot it
;   istat=corinpscan(desc,b,scan=401864155,maxrecs=600) ; input a scan
;   wasclose,desc           ; when done.
;-
;history:
; 30jan04: added byte offset for start of
;          naxis2 - updates each write single rec
;          theap  - constant till end of file when it is shrunk 
;                   then it will get smaller (end bintableheader to startheap)
; 03feb04: added patNm to scanI.
; 26oct04: added coli.crval2a
function wasopen,filename,desc ,debug=debug
	common wascom,wasnluns,waslunar

    if not keyword_set(debug) then debug=0
    if not keyword_set(all) then all=0
;
    tmStp=dblarr(10)
    if debug then tmStp[0]=systime(1)
    MAXBRDS=8
    MAXSCANS= 500L          ; for now online monitoring limited to 500
;
;	 keyword columns have changed with time...
;    we will search starting with the most recent and then move
;    backwards. We then store the column number to access the data in the hdr.
;
    scanColNm=['SCAN_NUMBER','OBS_SCAN','SCAN']
    grpColNm=['PATTERN_NUMBER','OBS_NUM','GRPNUM']
    ifvalColNm=['IFVAL','IFVAL5']
    corrmodeColNm=['BACKENDMODE','CORRMODE']
	wappnoColNm=['INPUT_ID','WAPPNO']
	patnamColNm=['OBSMODE','PATTERN_NAME']

    azColNm   =['ENC_AZIMUTH','AZIMUTH']
    elColNm   =['ENC_ELEVATIO','ELEVATIO']
    elAltColNm=['ENC_ALTEL','ALT_ZA']
    encTmColNm=['ENC_TIME','POS_TIME']
    flipColNm =['UPPERSB','FLIP']
    wappMaskColNm=['WAPPMASK']
    ctype1Nm   =['SPECSYS','CTYPE1']
    restfreqNm =['RESTFRQV','RESTFRQ','RESTFREQ']
    velocityNm   =['CRVAL1V','VELOCITY']
    jdNm         =['MJD-OBS','JD']
    alfaAngleNm  =['ALFA_ANG']
    paraAngleNm  =['PARA_ANG']
    beamAzNm     =['BEAM_OFFAZ','BEAM_AZ']
    beamZaNm     =['BEAM_OFFZA','BEAM_ZA']
	crval2aNm    =['CRVAL2A'] 		 ; this implies 2b,2c,2g 
				   ; crval1v,crdelt1v,drpix1v,cunit1v,ctype1v,specsys
				   ; croff2b,croff3b
    raJNm        =['CRVAL2C','RAJ']  ; this is paraxial ray of optics
    decJNm       =['CRVAL3C','DECJ'] ; this is paraxial ray of optics
    raJBmNm      =['CRVAL2A']  ; this is for each beam -1 --> not there
    decJBmNm     =['CRVAL3A']  ; this is for each beam -1 --> not there
    rateRaNm     =['RATE_C1','RATE_RA']  ;
    rateDecNm    =['RATE_C2','RATE_DEC'] ;
    rateTm       =['RATE_TIME'] ;
;
    extension=1                 ; first extension
;
;   scan info
; patnm names:upper case:
;
;'ONOFF','CAL','DRIFT','DPS','CROSS','ON','RUN'
;
    scanIstr={   scan: 0L ,$ ; scan number
         nbrds: 0L ,$ ; number of boards (wapps) used this scan 1,2,3,4..8
         patNm: '' ,$ ; name that wapp uses
         nlags:  intarr(MAXBRDS),$ ;  number of lags per sbc each board
        brdnum:  bytarr(MAXBRDS),$ ;  board number 1..8
         nsbc :  bytarr(MAXBRDS),$ ; number of sbc each brd 1,2,4,..8
         level:  bytarr(MAXBRDS),$ ; 3 or 9 .. level sampling each board
         pol  :  bytarr(4,MAXBRDS),$ ;polId 1,2,3,4, 0 not used. 
		 ind  :  bytarr(4,MAXBRDS),$ ; ind for this boards data in the rec.
       corattn: bytarr(4,MAXBRDS),$  ;correlator attenuation 0..15
;                                     each sbc each board.
    rowsinrec :                 0L,$ ; number (rows) in a rec (all boards)
    rowsinscan:                 0L,$ ; number (rows) in the scan
    recsinscan:                 0L,$ ; number records in a scan
    rowStartInd:                0L,$ ; row index start scan
    cumRecStartInd:             0L}  ; cum rec index start scan
;
; column info
;
    colI={   scan:  0L,$   ; col that scan info in
              grp:  0L,$   ; col that grp number info in
               az:  0L,$   ;
               el:  0l,$   ;col for main elevatio encoder
            elAlt:  0l,$   ;alternate elevation encoder     
            encTm:  0L,$   ; col for the encoder time.
            patnam: 0L,$   ; col for the pattern name
              flip: 0L,$   ; col true if freq flipped
          wappMask: 0L,$   ; col for wapp mask
          ctype1  : 0L,$   ; col for velo coord system
          jd      : 0L,$   ; jd or mjd
          restfreq: 0L,$   ; col for rest freq
          velocity: 0L,$   ; col for rest freq
            beamAz: 0L,$   ; alfa beam offset az -1 not present
            beamZa: 0L,$   ; alfa beam offset za -1 not present
         alfaAngle: 0L,$   ; col for alfa rotation angle. -1 not present
         paraAngle: 0L,$   ; col for parallactic angle -1 not present
               raJ: 0L,$   ; col for j2000 ra paraxial ray
              decJ: 0L,$   ; col for j2000 dec paraxial ray
             raJBm: 0L,$   ; col for j2000 ra  each beam of alfa
            decJBm: 0L,$   ; col for j2000 dec each beam of alfa
            rateRa: 0L,$   ; col for rate coord 1
           rateDec: 0L,$   ; col for rate coord 2
            rateTm: 0L,$   ; col for when rate started
           crval2a: 0L $   ; col for version 1 additions. 2a-2g,pix1v,etc..
            }
;
;   online file info
;
    onlI={ byteOffNaxis2: 0L,$  ; bytes offset naxis2 keyword line
           byteOffTheap : 0L,$  ; bytes offset Theap keyword 
           maxScans     : 0L $  ; maximum scans we've allocated for
         }
;
    errmsg=''
    lun=-1
    if debug then tmStp[1]=systime(1)
    fxbopen,lun,filename,extension,errmsg=errmsg
    if errmsg ne '' then begin
        print,errmsg
        goto,errout
    endif 
;
;	 remember lun in case wasclose,/all
;
	ind=where(waslunar eq 0,count)
	if count gt 0 then begin
		waslunar[ind[0]]=lun
		wasnluns=wasnluns+1
	endif
    if debug then tmStp[2]=systime(1)
;------------------------------------------------------------------------------
;   find out where various columns are in the header.
;   map from key name to col number. This will try and take into
;   account changes in the keyword names (at least as we start using
;   the sdfits files).
;
    errmsg=''
	for i=0,n_elements(scanColNm)-1 do begin
    	colI.scan=fxbcolnum(lun,scanColNm[i],errmsg=errmsg)
    	if colI.scan ne 0 then break
	endfor
    if colI.scan eq 0 then begin
       print,'cannot find scan column in header'
       goto,errout
    endif

	for i=0,n_elements(grpColNm)-1 do begin
    	colI.grp=fxbcolnum(lun,grpColNm[i],errmsg=errmsg)
    	if colI.grp ne 0 then break
	endfor
    if colI.grp eq 0 then begin
       print,'cannot find group column in header'
       goto,errout
    endif

	for i=0,n_elements(ifvalColNm)-1 do begin
    	colIfval=fxbcolnum(lun,ifvalColNm[i],errmsg=errmsg)
    	if colIfval ne 0 then break
	endfor
    if colIfval eq 0 then begin
       print,'cannot find ifval column in header'
       goto,errout
    endif

	for i=0,n_elements(corrmodeColNm)-1 do begin
    	colCorrmode=fxbcolnum(lun,corrmodeColNm[i],errmsg=errmsg)
    	if colCorrmode ne 0 then break
	endfor
    if colCorrmode eq 0 then begin
       print,'cannot find corrmode column in header'
       goto,errout
    endif

	for i=0,n_elements(wappNoColNm)-1 do begin
    	colwappno=fxbcolnum(lun,wappNoColNm[i],errmsg=errmsg)
    	if colwappno ne 0 then break
	endfor
    if colwappno eq 0 then begin
       print,'cannot find wappno column in header'
       goto,errout
    endif

	for i=0,n_elements(azColNm)-1 do begin
    	colI.az=fxbcolnum(lun,azColNm[i],errmsg=errmsg)
    	if colI.az ne 0 then break
	endfor
    if colI.az eq 0 then begin
       print,'cannot find azimuth column in header'
       goto,errout
    endif

	for i=0,n_elements(elColNm)-1 do begin
    	colI.el=fxbcolnum(lun,elColNm[i],errmsg=errmsg)
    	if colI.el ne 0 then break
	endfor
    if colI.el eq 0 then begin
       print,'cannot find elevation column in header'
       goto,errout
    endif

	for i=0,n_elements(elAltColNm)-1 do begin
    	colI.elalt=fxbcolnum(lun,elAltColNm[i],errmsg=errmsg)
    	if colI.elalt ne 0 then break
	endfor
    if colI.elalt eq 0 then begin
        print,'cannot find alt elevation column in header'
        goto,errout
    endif

	for i=0,n_elements(encTmColNm)-1 do begin
    	colI.encTm=fxbcolnum(lun,encTmColNm[i],errmsg=errmsg)
    	if colI.encTm ne 0 then break
	endfor
    if colI.encTm eq 0 then begin
         print,'cannot find encoder time column in header'
         goto,errout
    endif

	for i=0,n_elements(patnamColNm)-1 do begin
    	colI.patnam=fxbcolnum(lun,patnamColNm[i],errmsg=errmsg)
    	if colI.patnam ne 0 then break
	endfor
    if colI.patnam eq 0 then begin
         print,'cannot find pattern_name column in header'
         goto,errout
    endif

	for i=0,n_elements(flipColNm)-1 do begin
    	colI.flip=fxbcolnum(lun,flipColNm[i],errmsg=errmsg)
    	if colI.flip ne 0 then break
	endfor
    if colI.flip eq 0 then begin
         print,'cannot find flip column in header'
         goto,errout
    endif
	 
	for i=0,n_elements(wappMaskColNm)-1 do begin
    	colI.wappMask=fxbcolnum(lun,wappMaskColNm[i],errmsg=errmsg)
    	if colI.wappMask ne 0 then break
	endfor
    if colI.wappMask eq 0 then begin
         print,'cannot find wappMask column in header'
         goto,errout
    endif

	for i=0,n_elements(ctype1Nm)-1 do begin
    	colI.ctype1=fxbcolnum(lun,ctype1Nm[i],errmsg=errmsg)
    	if colI.ctype1 ne 0 then break
	endfor
    if colI.ctype1 eq 0 then begin
         print,'cannot find ctype1/specsys column in header'
         goto,errout
    endif

	for i=0,n_elements(restFreqNm)-1 do begin
    	colI.restFreq=fxbcolnum(lun,restFreqNm[i],errmsg=errmsg)
    	if colI.restFreq ne 0 then break
	endfor
    if colI.restFreq eq 0 then begin
         print,'cannot find restFreq column in header'
         goto,errout
    endif

    for i=0,n_elements(velocityNm)-1 do begin
        colI.velocity=fxbcolnum(lun,velocityNm[i],errmsg=errmsg)
        if colI.velocity ne 0 then break
    endfor
    if colI.velocity eq 0 then begin
         print,'cannot find velocity column in header'
         goto,errout
    endif

    for i=0,n_elements(jdNm)-1 do begin
        colI.jd=fxbcolnum(lun,jdNm[i],errmsg=errmsg)
        if colI.jd ne 0 then break
    endfor
    if colI.jd eq 0 then begin
         print,'cannot find jd/mjd column in header'
         goto,errout
    endif

    for i=0,n_elements(beamAzNm)-1 do begin
        colI.beamAz=fxbcolnum(lun,beamAzNm[i],errmsg=errmsg)
        if colI.beamAz ne 0 then break
    endfor
    if colI.beamAz eq 0 then begin
		 colI.beamAz = -1
    endif

    for i=0,n_elements(beamZaNm)-1 do begin
        colI.beamZa=fxbcolnum(lun,beamZaNm[i],errmsg=errmsg)
        if colI.beamZa ne 0 then break
    endfor
    if colI.beamZa eq 0 then begin
		 colI.beamZa = -1
    endif
 
    for i=0,n_elements(alfaAngleNm)-1 do begin
        colI.alfaAngle=fxbcolnum(lun,alfaAngleNm[i],errmsg=errmsg)
        if colI.alfaAngle ne 0 then break
    endfor
    if colI.alfaAngle eq 0 then begin
		 colI.alfaAngle = -1
    endif

	for i=0,n_elements(paraAngleNm)-1 do begin
        colI.paraAngle=fxbcolnum(lun,paraAngleNm[i],errmsg=errmsg)
        if colI.paraAngle ne 0 then break
    endfor
    if colI.paraAngle eq 0 then begin
         colI.paraAngle = -1
    endif

	for i=0,n_elements(raJNm)-1 do begin
        colI.raJ=fxbcolnum(lun,raJNm[i],errmsg=errmsg)
        if colI.raJ ne 0 then break
    endfor
    if colI.raJ eq 0 then begin
         print,'cannot find raJ column in header'
         goto,errout
    endif

	for i=0,n_elements(decJNm)-1 do begin
        colI.decJ=fxbcolnum(lun,decJNm[i],errmsg=errmsg)
        if colI.decJ ne 0 then break
    endfor
    if colI.decJ eq 0 then begin
         print,'cannot find decJ column in header'
         goto,errout
    endif

	for i=0,n_elements(raJBmNm)-1 do begin
        colI.raJBm=fxbcolnum(lun,raJBmNm[i],errmsg=errmsg)
        if colI.raJBm ne 0 then break
    endfor
    if colI.raJBm eq 0 then begin
         colI.raJBm = -1
    endif

	for i=0,n_elements(decJBmNm)-1 do begin
        colI.decJBm=fxbcolnum(lun,decJBmNm[i],errmsg=errmsg)
        if colI.decJBm ne 0 then break
    endfor
    if colI.decJBm eq 0 then begin
         colI.decJBm = -1
    endif

	for i=0,n_elements(rateRaNm)-1 do begin
        colI.rateRa=fxbcolnum(lun,rateRaNm[i],errmsg=errmsg)
        if colI.rateRa ne 0 then break
    endfor
    if colI.rateRa eq 0 then begin
         print,'cannot find rateRa column in header'
         goto,errout
    endif

	for i=0,n_elements(rateDecNm)-1 do begin
        colI.rateDec=fxbcolnum(lun,rateDecNm[i],errmsg=errmsg)
        if colI.rateDec ne 0 then break
    endfor
    if colI.rateDec eq 0 then begin
         print,'cannot find rateDec column in header'
         goto,errout
    endif

    for i=0,n_elements(rateTmNm)-1 do begin
        colI.rateTm=fxbcolnum(lun,rateTmNm[i],errmsg=errmsg)
        if colI.rateTm ne 0 then break
    endfor
    if colI.rateTm eq 0 then begin
         colI.rateTm = -1
    endif

    for i=0,n_elements(crval2aNm)-1 do begin
        colI.crval2a=fxbcolnum(lun,crval2aNm[i],errmsg=errmsg)
        if colI.crval2a ne 0 then break
    endfor
    if colI.crval2a eq 0 then begin
         colI.crval2a = -1
    endif


    if debug then tmStp[3]=systime(1)
;------------------------------------------------------------------------------
;  for online monitoring...
;
; get starting locations in file for header lines that contain:
; naxis2,theap. we use them for online monitoring to see when the
; file grows.
;
    h=fxbheader(lun)
    a=strmid(h,0,6)
    ind=where(a eq 'NAXIS2',gotNaxis2)
    if not gotNaxis2 then begin
        print,'did not find NAXIS2 keyword in extension header'
        goto,errout
    endif
    onlI.byteOffNaxis2=2880L + (ind[0]*80L) 
    ind=where(a eq 'THEAP ',gotTheap)
    if not gotTheap then begin
        print,'did not find THEAP keyword in extension header'
        goto,errout
    endif
    onlI.byteOffTheap=2880L + (ind[0]*80L) 
    if debug then tmStp[4]=systime(1)
;
;   check to make sure that the file is not empty..
;
    naxis1=fxpar(h,'NAXIS1')
    naxis2=fxpar(h,'NAXIS2')
    theap =fxpar(h,'THEAP')
	projId=strtrim(fxpar(h,'OBS_ID')) 
	if naxis2 eq 0 then begin
print,'naxis2 keyword in header says there are 0 rows of data in the file'
		goto,errout
	endif

;------------------------------------------------------------------------------
; 
;   read in the scan column
;
    fxbread,lun,scan,colI.scan,errmsg=errmsg
    if errmsg ne '' then begin
       print,errmsg
       goto,errout
    endif
    if debug then tmStp[5]=systime(1)
   	totrows=n_elements(scan)
;
; 	check if we have any 0 scan  numbers.. 
;   maybe the file was not collapsed correctly
;
	if totrows gt 0 then begin
		ind=where(scan eq 0,count)
		if count gt 0 then begin 
			totrows=ind[0] 
		endif
		if totrows gt 0 then begin
			scan=scan[0:totrows-1]
		endif 
	endif
;
;   see where each scan starts
;
    case 1  of
        totrows eq 0: begin
            nscans=0
            nrows=0
            ind=-1
            end
        totrows eq 1: begin
            nscans=1
            nrows=totrows
            ind=0
            end
        else: begin 
			scandif=scan-shift(scan,1) 
            ind=where(scandif ne 0,nscans)
            if nscans eq 0 then  begin
                nscans=1
                ind=0
            endif
            if nscans eq 1 then  begin
                nrows=totrows
            endif else begin
			     iscanchk=where(scandif[1:*] lt 0,countscnchk)	 
				 if countscnchk gt 0 then begin
					print,'Warning:some records have out of order scan numbers'
				 endif
                 nrows=shift(ind-shift(ind,1),-1)
                 nrows[nscans-1l]= totrows-ind[nscans-1]
            endelse
            end
    endcase
;
;   read in pattern name
;
    fxbread,lun,patNm,colI.patnam,errmsg=errmsg
    if errmsg ne '' then begin
            print,errmsg
            goto,errout
    endif
;
;   see if we are online and the file is growing..
;
;   online=(naxis1*naxis2) ne theap
    online=0
    onlI.maxscans =(online) ? MAXSCANS: nscans
    ii=(onlI.maxScans ne 0)? onlI.maxScans:1
    desc={   lun     : lun       ,$;
             filename: filename,$;
             totScans:  nscans  ,$; 1 file
             totRecs :  0L       ,$; total records in a table 
             totRows :  totrows ,$; total number of rows in table 
             curPos  : 0L       ,$; row-1 this file
             scanInd : 0L       ,$; scan index for next read
			 projId  : projId ,$; projid. constant for whole file??
             onLine  : online,$; 1 if online and file growing.
             colI    : colI     ,$; column numbers location info
             onlI    : onlI     ,$; online info 
             scanI   :replicate(scanIStr,ii)}
    if debug then tmStp[6]=systime(1)
    if nscans gt 0 then begin
        desc.scanI[0:nscans-1].scan=scan[ind]
        desc.scanI[0:nscans-1].rowStartInd=ind     ; this scan in hdu. row - 1..
        desc.scanI[0:nscans-1].rowsinscan=nrows    ; number recs each scan
        desc.scanI[0:nscans-1].patNm=patNm[ind]    ; number recs each scan
;
;    fill in info for each scan
;    1. nbrds,
;    2. nsbc/board
;    3. lags/sbc each board
;    4. pol for each sbc of each board
;
;       group number,nlags,
;
        fxbread,lun,grpnum,colI.grp,errmsg=errmsg
        if errmsg ne '' then begin
            print,errms
            goto,errout
        endif
        fxbread,lun,nlags,'LAGS_IN',errmsg=errmsg
        if errmsg ne '' then begin
            print,errms
            goto,errout
        endif
        fxbread,lun,ifval,colIfval,errmsg=errmsg
        if errmsg ne '' then begin
            print,errms
            goto,errout
        endif

        fxbread,lun,corrmode,colCorrmode,errmsg=errmsg
        if errmsg ne '' then begin
            print,errms
            goto,errout
        endif

        fxbread,lun,wappno,colWappno,errmsg=errmsg
        if errmsg ne '' then begin
            print,errms
            goto,errout
        endif
		 
        fxbread,lun,wappMask,colI.wappMask,errmsg=errmsg
        if errmsg ne '' then begin
            print,errms
            goto,errout
        endif
         
        fxbread,lun,corAttn,'ATTN_COR',errmsg=errmsg
        if errmsg ne '' then begin
            print,errmsg
            goto,errout
        endif


        if debug then tmStp[7]=systime(1)
        for iscan=0l,nscans-1 do begin  
;
;   
;
            j=desc.scanI[iscan].rowStartInd		; start row this scan
            scanCur=scan[j]
			wappMaskCur=wappMask[j]
			rowsInRec=0
			rowsInWapp=lonarr(4)		        ; 4 wapps max
;
;			figure out rows per rec from wappmask and use alfa
;
			for ii=0,3 do begin 
				ival=wappMaskCur and '0ff'xul
				if ival ne 0 then begin
					case ival  of
						1 	: rowsInWapp[ii]=1
						3 	: rowsInWapp[ii]=2
						15 	: rowsInWapp[ii]=4
					'0ff'xul: rowsInWapp[ii]=8
					endcase
				endif
				wappmaskCur=ishft(wappMaskCur,-8)
			endfor
			rowsInRec=long(total(rowsInWapp) + .5)
			desc.scanI[iscan].rowsInRec=rowsInRec
			if rowsInRec gt desc.scanI[iscan].rowsInScan then begin
				print,desc.scanI[iscan].scan,' scan has single partial record.'
				rowsInRec=desc.scanI[iscan].rowsInScan
			endif
			jj=j+rowsInRec-1			; last index for this rec
;
; 		see if last record is  partial 
;
			if jj ge naxis2 then begin
				print,'last record of file is incomplete'
				jj=naxis2-1
			endif
;
; 			figure out how many rows per board. equal to rowsPer wapp if no alfa
;           equal to rowsPerwapp/2 if alfa enables. key off of largest wappno used..
;
			rowsInBrd =lonarr(MAXBRDS)		    ; 
			useAlfa=(max(wappno[j:jj])) gt 3 
			inc=(useAlfa)?2:1
			for ii=0,3 do begin
				rowsInBrd[ii*inc]  =rowsInWapp[ii]/inc
				if rowsInBrd[ii*inc] gt 4 then begin
					lab=string(format='("scan:",i9," brd:",i1," incorrect # of rows:",i2)'$
						    ,desc.scanI[iscan].scan,ii+1,rowsInBrd[ii*inc])
					print,lab
					rowsInBrd[ii*inc]=4
				endif
				if useAlfa then rowsInBrd[ii*inc +1]=rowsInBrd[ii*inc]
			endfor 
			ibrd=0					    ; index into our brd array
			for ii=0,maxbrds-1 do begin ; see which boards are used
				ind=where(wappno[j:jj] eq ii,count)
				if count ne rowsInBrd[ii] then begin
				lab=string(format='("scan:",i9," brd:",i1," incorrect # of rows:",i2)',$
						desc.scanI[iscan].scan,ii+1,count)
					print,lab
					if count gt rowsInBrd[ii] then begin
						count= rowsInBrd[ii]
						ind  = ind[0:count-1]
					endif
				endif
				if count gt 0 then begin
;
					desc.scanI[iscan].nlags[ibrd] = nlags[j+ind[0]]
					desc.scanI[iscan].brdnum[ibrd]= wappno[j+ind[0]] + 1 ; 1..8
					desc.scanI[iscan].nsbc[ibrd]  = count
					desc.scanI[iscan].level[ibrd] = $
                    	(strpos(corrmode[j+ind[0]],'3-level') eq -1)?9:3
					desc.scanI[iscan].pol[0:count-1,ibrd]  = ifval[j+ind] + 1
					desc.scanI[iscan].ind[0:count-1,ibrd]  = ind
					desc.scanI[iscan].corattn[0:count-1,ibrd]= corattn[j+ind]
					ibrd=ibrd+1
				endif
			endfor
			desc.scanI[iscan].nbrds=ibrd
        endfor
        desc.scanI.recsInScan    =desc.scanI.rowsInScan/desc.scanI.rowsInRec
	   ind=where(( desc.ScanI.rowsInscan mod  desc.scanI.recsInScan) ne 0,count)
		if (count gt 0) then begin
			print,'Warning: incomplete record in scans:',desc.scanI[ind].scan
		endif
        desc.totrecs=total(desc.scanI.recsInScan)
        desc.scanI.cumRecStartInd= total(desc.scanI.recsInScan,/cum) - $
								desc.scanI.recsInScan
        if debug then tmStp[8]=systime(1)
    endif
    if debug then begin
        for i=1,8 do print,i,tmStp[i], tmStp[i]-tmStp[i-1]
    endif
    return,1
errout:
    if lun ne -1 then fxbclose,lun
    return,0
end
