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
;   xcan   long              .. col that scan info in 
;   grp    long              .. col that scan info in 
;   az     long              .. col for az encoder
;   el     long              .. col for main elevatio encoder
;   elAlt  long              .. col for alternate za encoder
;   enctm  long              .. col for the encoder time.
;   patnam long              .. col for the pattern name.
;   flip   long              .. col for the flip spectra
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
function wasopen,filename,desc ,debug=debug
	common wascom,wasnluns,waslunar

    if not keyword_set(debug) then debug=0
    if not keyword_set(all) then all=0
;
    tmStp=dblarr(10)
    if debug then tmStp[0]=systime(1)
    MAXBRDS=7
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
	wappnoColNm=['WAPPNO']
	patnamColNm=['OBSMODE','PATTERN_NAME']

    azColNm   =['ENC_AZIMUTH','AZIMUTH']
    elColNm   =['ENC_ELEVATIO','ELEVATIO']
    elAltColNm=['ENC_ALTEL','ALT_ZA']
    encTmColNm=['ENC_TIME','POS_TIME']
    flipColNm =['UPPERSB','FLIP']
;
    extension=1                 ; first extension
;
;   scan info
; patnm names:upper case:
;
;'ONOFF','CAL','DRIFT','DPS','CROSS','ON','RUN'
;
    scanIstr={   scan: 0L ,$ ; scan number
         nbrds: 0L ,$ ; number of boards (wapps) used this scan 1,2,3,4..7
         patNm: '' ,$ ; name that wapp uses
         nlags:  intarr(MAXBRDS),$ ;  number of lags per sbc each board
        brdnum:  bytarr(MAXBRDS),$ ;  board number 1..7
         nsbc :  bytarr(MAXBRDS),$ ; number of sbc each brd 1,2,4
         level:  bytarr(MAXBRDS),$ ; 3 or 9 .. level sampling each board
         pol  :  bytarr(4,MAXBRDS),$ ;polId 1,2,3,4, 0 not used. 
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
              grp:  0L,$   ;col that scan info in
               az:  0L,$   ;
               el:  0l,$   ;col for main elevatio encoder
            elAlt:  0l,$   ;alternate elevation encoder     
            encTm:  0L,$   ; col for the encoder time.
            patnam: 0L,$   ; col for the pattern name
              flip: 0L $   ; col true if freq flipped
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
            ind=where(scan-shift(scan,1) ne 0,nscans)
            if nscans eq 0 then  begin
                nscans=1
                ind=0
            endif
            if nscans eq 1 then  begin
                nrows=totrows
            endif else begin
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
    naxis1=fxpar(h,'NAXIS1')
    naxis2=fxpar(h,'NAXIS2')
    theap =fxpar(h,'THEAP')
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
         
        fxbread,lun,corAttn,'ATTN_COR',errmsg=errmsg
        if errmsg ne '' then begin
            print,errmsg
            goto,errout
        endif


        if debug then tmStp[7]=systime(1)
         
        for i=0l,nscans-1 do begin  
;
;   
;
            curbrd=-1
            ibrd=-1
            j=desc.scanI[i].rowStartInd
            scanCur=scan[j]
            keeplooping=(scanCur eq scan[j]) and (grpnum[j] eq 0) 
            while (keeplooping) do begin
                brd=wappno[j]
                if curbrd ne brd then begin
                    ibrd=ibrd+1
                    curbrd=brd
                    desc.scanI[i].nbrds=ibrd+1
                    desc.scanI[i].nlags[ibrd]=nlags[j]
                    desc.scanI[i].level[ibrd]=$
                    (strpos(corrmode[j],'3-level') eq -1)?9:3
                    desc.scanI[i].brdNum[ibrd]=curbrd
                    ipol=0
                endif
                desc.scanI[i].nsbc[ibrd]     = desc.scanI[i].nsbc[ibrd]+1
                desc.scanI[i].pol[ipol,ibrd] = (ifval[j] eq 0)?1:2
                desc.scanI[i].corattn[ipol,ibrd]=corattn[j]
                desc.scanI[i].rowsinrec= desc.scanI[i].rowsinrec+1
                j=j+1
                ipol=ipol+1
                if j ge n_elements(scan) then begin
                    keeplooping=0
                endif else begin
                    keeplooping=(scanCur eq scan[j]) and (grpnum[j] eq 0) 
                endelse
            endwhile
        endfor
        desc.scanI.recsInScan    =desc.scanI.rowsInScan/desc.scanI.rowsInRec
        desc.scanI.cumRecStartInd=total(desc.scanI.recsInScan,/cum)-$
                                        desc.scanI.recsInScan 
        desc.totrecs=total(desc.scanI.recsInScan)
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
