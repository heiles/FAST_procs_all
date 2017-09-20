;+ 
;NAME:
;galopen - open a galfa fits files for i/o
;
;SYNTAX: istat=galopen(filename,desc,tmI=tmiI,scanI=scanI)
;
;ARGS:
;   filename: string  filename to open
;
;KEYWORDS:
;
;RETURNS:
;  istat: int          0 couldn't open file
;                      1 file opened successfully
;   desc: {galdescr} - descriptor holding info for file i/o.
;
;  scanI: {}           structure holding info about each record in
;                      file. You can use this to sort out where
;                      different patterns started (without having
;                      to read the entire file).
; tmI[6]: {}           structure holding timing info:
;                      tmI[i].nm  label of where the time was measured  
;                      tmI[i].tm  time value (from call to systime(1)).
;                      The units are seconds (with fraction). To get the
;                      relative time, you should subtract tmI[0].tm from
;                      all of the .tm values or (tmI.tm - shift(tmI.tm,1)
;DESCRIPTION:
;   Open a gal (galfa) spectral line fits file. Load
;the descriptor with the info for the entire file. This
;descriptor will be passed to the galxxx corxxx routines to do the 
;file i/o. This descriptor replaces the standard lun that is 
;used for the interim correlator data.
;   The descriptor contains:
; 
;   help,desc,/st
;
;   LUN       LONG     0        .. idl lun 
;   FILENAME  STRING '/share/wapp11/a9999_wapp1_0027.fits' ..filename 
;   TOTRECS   LONG     1        .. total recs (integ)  in file 
;   TOTROWS   LONG  7216        .. total number of rows in bintable
;   CURPOS    LONG     1        .. position for next read 0 based (row-1)
;   tmStartFile LONG   0        .. secs since 1970 start of file
;   rowStartRec lonarr(nrecs) 
;   rowsinrec lonarr(nrecs)
;  -------------------------------
;
; If the scanI keyword is returned, then the scanI[nrecs] structure array 
;returned contains:
; 
;IDL> help,scanI
;SCANI      0     STRUCT    = -> <Anonymous> Array[600]
;
;IDL> help,scanI,/st
; SEQNUM    LONG    1203        ; seq number from fits file
; OBSMODE   STRING  'BASKET'    ; pattern used
; OBS_NAME  STRING  'BASKET'    ; step in pattern 
; OBJECT    STRING  'lwb_14_00' ; source name
; SEC       DOUBLE   1.1209410e+09 ;sec from 1970 start of rec. rounded to
;                                 closest sec: round(g_time[0]+g_time[1]*1d-6)
; AZ        FLOAT    359.382    ; az position (deg)
; ZA        FLOAT    14.7502    ; za position (deg)
; RESTFREQ  DOUBLE   1420.2858  ; crval1:rest freq Mhz (narrow band)
; NUM       LONG     0          ; unused.. user can load 
; 
; The az,za are taken from the file. They are not interpolated to the
;center of the data sample.
;
;
;EXAMPLE:
; 1. open a file
;
;   filenm='/share/wapp11/wapp1.20040118.a1849.0010.fits'
;   istat=galopen(filenm,desc)
;
;   gallist,desc            ; list scan summary
;   istat=corget(desc,b)    ; read a record
;   corplot,b               ; plot it
;   istat=corinpscan(desc,b,scan=401864155,maxrecs=600) ; input a scan
;   galclose,desc           ; when done.
;
; 2. open file, return timing info and scanI
;   istat=galopen(filenm,desc,scanI=scanI,tmI=tmI)
;   print,tmI.tm - tmI[0].tm
;;  look for pattern name of CAL
;   ind=where(scanI.obsmode eq 'CAL',count)
;   if count gt 0 then ...
;      process cal records
;   endif
;   	
;-
;history:
; 30jan04: added byte offset for start of
;          naxis2 - updates each write single rec
;          theap  - constant till end of file when it is shrunk 
;                   then it will get smaller (end bintableheader to startheap)
; 03feb04: added patNm to scanI.
function galopen,filename,desc ,tmI=tmI,scanI=scanI
    common galcom,galnluns,gallunar

;   version numbers i generate for verion that did not include the
;   verions keyword
;
    versionL1=20040901;
    versionL2=20041022;
    versionL3=20041028;
    debug=arg_present(tmI)
    useScanI=arg_present(scanI)
;
    if debug then begin
        a={ nm: '' ,$; what it is measuring
            tm: 0d } ; what we meausured since previous call
        idb=0
        tmI=replicate(a,7)
        tmI[idb].tm=systime(1)
        tmI[idb].nm='start'
        idb=idb+1
    endif
    MAXBRDS=7
;
;
    extension=1                 ; first extension
    errmsg=''
    lun=-1
    fxbopen,lun,filename,extension,h,errmsg=errmsg
    if errmsg ne '' then begin
        print,errmsg
        goto,errout
    endif 
;
;    remember lun in case galclose,/all
;
    ind=where(gallunar eq 0,count)
    if count gt 0 then begin
        gallunar[ind[0]]=lun
        galnluns=galnluns+1
    endif
    if debug then begin
        tmI[idb].tm=systime(1)
        tmI[idb].nm='fxbopen'
        idb=idb+1
    endif
;------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------
;
;   check to make sure that the file is not empty..
;
    naxis1=fxpar(h,'NAXIS1')
    naxis2=fxpar(h,'NAXIS2')
    istat=galfnamepars(filename,nm)
    projId=nm.projid
;    projId=strtrim(fxpar(h,'OBS_ID')) 
    if naxis2 eq 0 then begin
print,'naxis2 keyword in header says there are 0 rows of data in the file'
        goto,errout
    endif
;
; see how many columns in g_wide .. fxbdimen has a bug so don't pass errmsg
;
    errmsg=''
    nchanwb=(fxbdimen(lun,'G_WIDE'))[0]

;    fxbread,lun,g_wide,'G_WIDE',1,errmsg=errmsg
      if errmsg ne '' then begin
       print,errmsg
       goto,errout
    endif
;    nchanwb=n_elements(g_wide)
    nchannb=8191L - nchanwb

;
;------------------------------------------------------------------------------
;   get the sequence number
;
    if debug then begin
        tmI[idb].tm=systime(1)
        tmI[idb].nm='fxpar'
        idb=idb+1
    endif
    fxbread,lun,seqnum,'G_SEQ',errmsg=errmsg
    if debug then begin
        tmI[idb].tm=systime(1)
        tmI[idb].nm='fxbread,g_seq'
        idb=idb+1
    endif
    if errmsg ne '' then begin
       print,errmsg
       goto,errout
    endif
    fxbread,lun,gtime,'G_TIME',1,errmsg=errmsg
    if debug then begin
        tmI[idb].tm=systime(1)
        tmI[idb].nm='fxbread,g_time'
        idb=idb+1
    endif
    if errmsg ne '' then begin
       print,errmsg
       goto,errout
    endif
    totrows=n_elements(seqnum)
;
;   find out where the new recs start
;   use seqnum change
;
    case 1 of
        totrows eq 0: begin     ;file empty
            nrecs=0
            indrec  =-1
            end
        totrows eq 1: begin     ; file with 1 row
            nrecs    = 1
            indrec   = 0
            rowsInRec=totrows
            end
        else : begin
            indrec=where(seqnum - shift(seqnum,1) ne 0,nrecs)
;
; check this line..
;
            if (nrecs eq 0) or (nrecs eq 1) then begin
                nrecs=1
                indrec=0
                rowsInRec=totrows
            endif
            if nrecs gt  1 then begin
                rowsInRec=shift(indrec - shift(indrec,1),-1)
                rowsInRec[nrecs-1]=totrows - indrec[nrecs-1]
            endif
         end
    endcase
;
;   figure out the version:
;   1 20040901
;   2 20040922 512 length wideband and no crval2a
;   3 20041028 512 and crval2a
;   n from version in header
; 
    errmsg=''
    colnocrval2a=fxbcolnum(lun,'CRVAL2A',errmsg=errmsg)
    if debug then begin
        tmI[idb].tm=systime(1)
        tmI[idb].nm='fcbcolnum,crval2a'
        idb=idb+1
    endif
    if  ( nchannb eq 256 ) then begin
           version=versionL1
    endif else begin
        if colnocrval2a eq 0 then begin
           version=versionL2
        endif else begin
            !err=0
            version=fxpar(h,'VERSION')
            if !err eq -1 then version=versionL3 
        endelse
    endelse
    startSec=round(gtime[0]+gtime[1]*1d-6)

;
    desc={   lun     : lun       ,$;
             filename: filename,$;
             version :  version,$; verions number
             totRecs :  nrecs   ,$; total records in a table 
             totRows :  totrows ,$; total number of rows in table 
             curPos  : 0L       ,$; row-1 this file
         secStartFile: startSec ,$; secs since 1970 start of file
          recStartrow: indrec   ,$; row for each rec start
           rowsinrec : rowsInRec,$;
             nbchan  :  nchannb ,$; number of narrow band channels
             wbchan  :  nchanwb ,$; number of wideband channels
             projId  : projId $; projid. constant for whole file??
        }
;
; see if they want the scan I
;
    if useScanI then begin
        a={ seqNum :  0L  , $ ; seq number from fits file
            obsmode:    '', $ ; cal
           obs_name:    '', $ ; on or off
             object:    '', $ ; source
              sec  :  0D  , $ ; secs since 1970 round(g_time[0],g_time[1])
              az   :  0.  , $ ; azimuth
              za   :  0.  , $ ; za
           restFreq:  0D  , $ ; rest freq Mhz
             num   :  0L   }   ; unused..user can load (with filename index)

        scanI=replicate(a,desc.totRecs)
        errmsg=''

        scanI.seqNum =seqNum[indrec]

        fxbread,desc.lun,inpdata,'OBSMODE',errmsg=errmsg
        if errmsg ne '' then goto,hdrreaderr
        scanI.obsmode=strtrim(inpdata[indrec])

        fxbread,desc.lun,inpdata,'OBS_NAME',errmsg=errmsg
        if errmsg ne '' then goto,hdrreaderr
        scanI.obs_name=strtrim(inpdata[indrec])
;
        fxbread,desc.lun,inpdata,'OBJECT',errmsg=errmsg
        if errmsg ne '' then goto,hdrreaderr
        scanI.object  =strtrim(inpdata[indrec])
;
        fxbread,desc.lun,inpdata,'RESTFREQ',errmsg=errmsg
        if errmsg ne '' then goto,hdrreaderr
        scanI.restfreq  =inpdata[indrec]*1d-6

        fxbread,desc.lun,inpdata,'CRVAL2B',errmsg=errmsg
        if errmsg ne '' then goto,hdrreaderr
        scanI.az    = inpdata[indrec]

        fxbread,desc.lun,inpdata,'CRVAL3B',errmsg=errmsg
        if errmsg ne '' then goto,hdrreaderr
        scanI.za    = inpdata[indrec]

        fxbread,lun,inpdata,'G_TIME',errmsg=errmsg
        if errmsg ne '' then goto,hdrreaderr
        scanI.sec   =reform(round(inpdata[0,indrec]+inpdata[1,indrec]*1d-6))
    endif


    if debug then begin
        tmI[idb].tm=systime(1)
        tmI[idb].nm='till_end'
        idb=idb+1
    endif
    return,1
hdrreaderr:
    print,errmsg 

errout:
    if lun ne -1 then fxbclose,lun
    return,0
end
