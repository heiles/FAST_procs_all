;+
;NAME:
;pfcalib - intensity calibrate an entire file
;
;SYNTAX: istat=pfcalib(filename,bf,bcalf,han=han,
;                      scan=scan,dir=dir,sl=sl,maxrecs=maxrecs,
;                      edgefract=edgefract,mask=mask,
;                      bpc=bpc,smobpc=smobpc,blrem=blrem,svd=svd,$
;                      rcv=rcv,sav=sav,fsav=fsav,rsl=rsl)
;ARGS:
;         filename: string  .. file to process
;
;KEYWORDS
;      han:         if set then hanning smooth the data
;     scan: long    if set then start at this scan number rather than the
;                   beginning of the file.
;    dir[]: string  search for filename in these directories.
;                   in this case filename should not have a path.
;     sl[]: {slist} Scan list to use when searching file. This saves having 
;                   to scan the file. Use this to speed processing if you 
;                   have already scanned the file (see the Rsl keyword).
; maxrecs : long    The maximum number of recs to allow in a scan
;                   the default is 300.
;
;edgefract[1/2]: float fraction of bandpass on each side to not use during
;                   calibration. default .1
;     mask:{cormask} mask structure created for each brd via cormask routine
;                   use this rather than edgefract.
;      bpc: int   1 band pass correct with cal off
;                 2 band pass correct with calon-caloff
;                 3 band pass correct (smooth or fit) with data spectra
;                   The default is no bandpass correction
;   fitbpc: int     fit a polynomial of order fitbpc  to the masked
;                   version of the band pass correction and use the
;                   polynomial rather than the data to do the bandpass
;                   correction. This is only done if bpc is specified.
;   smobpc: int     smooth the bandpass correction spectra by smobpc channels
;                   before using it to correct the data. The number should be
;                   an odd number of channels. This is only done if bpc is
;                   specified.
;    blrem: int     Remove a polynomial baseline of order blrem. Fit to the
;                   masked portion of the spectra. This is done after
;                   any bandpass correction or averaging.
;      svd:         If baselining is done (blrem) then the default fitting
;                   routine is poly_fit (matrix inversion). Setting svd
;                   will use svdfit (single value decomposition) which is
;                   more robust but slower.
;      rcv: int     If supplied then only process receiver number rcv.
;                    (1-327,2-430,3-610,5-lbw,6-lbn,7-sbw,8-sbh,9-cb,11=xb,
;                     12-sbn)
;      sav:         if keyword set then save the processed data to 
;                   ddmmyy.projid.N.sav . The keyword fsav will let you 
;                   switch this to a different save file.
;     fsav: string  name for save file. Only used if /sav is set.
;                   file will be forced to end in .sav
;
;RETURNS:
;  istat: int   >=0 number of patterns found
;               <0  could not process file.
; bdat[]: {corget} intensity calibrated data spectra
; bcal[]: {corget} intensity calibrated cal spectra
;Rsl[nscans]: {sl} return scan list that was used.
;  nBadIndAr: int  number of scans not used because different type.
;                  the indices into sl[] are returned in badindar.
;badIndAr[nBadIndAr]: int   .. hold indices into sl[] of on/off position
;                  switch data that were not processed because they had 
;                  a different data structure. The number of elements will 
;                  be in nbadindar
;
;DESCRIPTION:
;   pfcalib will do the corcalib() processing on all of the 
;on/calon/caloff patterns in filename. The keyword dir[] will search for 
;filename in all of the directories in dir.
;
;   The processing averages the data scan, converts the data and cal scans
;to kelvins using the cals, and optionally bandpass corrects the data.
;pfcalib requires that the cal scans follow immediately after the data scans.
;See corcalib() for a discussion of the edgefraction,mask and bandpass
;correction using fitting or smoothing. 
;   
;   pfcalib() will use the same edgefraction or mask, and bandpass correction
;on all of the scans in the file. It also always averages the data scans
;to 1 record.
;
;   The routine will first scan the file and create a scan list array (see
;getsl()). If you have already scanned the file, then using the sl=sl keyword
;lets you pass in the scan list array and save the time to scan the file 
;(the scanlist array used is returned in the rsl=rsl keyword).
;
;   The processing then proceeds one pattern at a time. If there are more than
;300 records in a scan, then you must use the maxscans= keyword set to the
;maximum number of records. If an incomplete on/calon/caloff pattern is found,
;the routine will skip forward and continue searching. The processing can be
;limited to a subset of the entire file by :
;
; 1.  scan= keyword. Start processing on this scan.
; 2.  rcv=N keyword. Only process data from receiver number N.
;
;   The data and cals are returned in arrays of {corget} structures.
;For this to work, all of the data must meet the following criteria:
;
; 1. All scans use the same number of boards.
; 2. For a single board (say board n) 
;    a. All scans should have the same number of polarizations.
;    b. all scans should have the same number of lags.
;    (It is ok if different boards have  different number of polarizations or
;    lags).
;
;Any scans whose data structure is different than the first pattern will be 
;skipped (with a message output to the terminal). The keywords nbadIndAr 
;and badIndAr will return the number and indices into rsl[] of the patterns 
;not included because the data type differed from the first pattern found.
;
;   The /sav keyword will store the processed data in an idl save file. The
;default name is ddmmmyy.projid.n.sav where ddmmmyy.projid.n is taken
;from the correlator datafile name. You can change the savefile name
;with the fsav= keyword (it still must end in .sav). The variable names
;stored in the file will be:
;
;   bf[npairs], bcalf[2,npairs]
;   srcnamesf[npairs]:string  An array holding the source names
;
;The save file lets you recall this data into a later session of idl using
;restore:
;   restore,'02may02.x101.1.sav'
;
;SEE ALSO: corcalib()
;-
;21sep02 started
function    pfcalib,filename,bf,bcalf,maxrecs=maxrecs,sl=sl,han=han,$
            dir=dir,scan=scan,_extra=e,rcv=rcv,sav=sav,fsav=fsav,rsl=rsl,$
            nbadindar=nbadindar,badindar=badindar

;
; _extra=e
;edgefract=edgefract,mask=mask,bpc=bpc,smobpc=smobpc,blrem=blrem,svd=svd,
;maxrecs=maxrecs,han=han

 
    if not keyword_set(rcv) then rcv=0
    lun=-1
    nbadindar=0
    badindar =-1
    numsto=0                ; number we've stored
    if file_exists(filename,fullname,dir=dir) then begin
        openr,lun,fullname,/get_lun,error=err
        if err ne 0 then begin
            print,'pfcalib open error:',!err_string
            numfound=-1
            goto,done
        endif
    endif else begin
            print,'pfcalib file not found:',filename
            numfound=-1
            goto,done
    endelse
    if not keyword_set(sl) then begin
        print,'scanning file:',filename
        sl=getsl(lun)
    endif 
;
;       if start at scan, throw out all scans before this
;
    if keyword_set(scan) then begin
        ind=where(sl.scan eq scan,count)
        if count eq 0 then begin
            print,'cannot position to scan:',scan
            numfound=-1
            goto,done
        endif
        sl=sl[ind[0]:*]
    endif
    rsl=sl
;
; find all of the on,then calon off,
;
    numfound=corfindpat(sl,indar,pattype=3,rcv=rcv)
    if numfound eq 0 then goto ,done
    badIndar=indar
    retfit=0
    for i=0,numfound-1 do begin
        istat=corcalib(lun,bdat,bcal,scan=sl[indar[i]].scan,sl=sl,$
                       /avg,_extra=e)
        if istat eq 1 then begin
            if (numsto eq 0 ) then begin
                bf=corallocstr(bdat,numfound)
                bcalf=corallocstr(bcal[0],2*numfound)
            endif else begin
                istat=corchkstr(bf[0],bdat)
            endelse
            if istat eq 1 then begin
                corstostr,bdat,numsto,bf
                corstostr,bcal,numsto*2,bcalf
                lab=string(format='( "process scan:",i9," ",a)',$
                bdat.b1.h.std.scannumber,$ 
                    string(bdat.b1.h.proc.srcname))
                badIndAr[i]=-1              ; its ok
                numsto=numsto+1
            endif else begin
                lab=string(format=$
                '( "skip    scan:",i9," ",a," different data format")',$
                bdat.b1.h.std.scannumber,string(bdat.b1.h.proc.srcname))
            endelse
            print,lab
        endif
    endfor
done:
    if lun gt 0 then free_lun,lun
    if numfound le 0 then begin
        bf=''
        bcalf=''
    endif else begin
        if (numfound ne numsto) then begin 
            bf=bf[0:numsto-1] 
            bcalf=bcalf[0:numsto*2-1] 
            numfound=numsto
        endif
        bcalf=reform(bcalf,2,numfound)
    endelse
    if keyword_set(sav) and (numfound gt 0) then begin
        if n_elements(fsav) gt 0 then begin
;
;       make sure it ends in .sav . This way they can't overwrite a datafile
;
            suf=''
            if strmid(fsav,3,4,/reverse_offset) ne '.sav' then suf='.sav'
            fsavl=fsav+suf
        endif else begin
            fsavl=filename
            i=strpos(fsavl,'/',/reverse_search)
            if i ne -1 then fsavl=strmid(fsavl,i+1) 
            fsavl=strmid(fsavl,8)  + '.sav'
        endelse
        srcnamesf=string(bf.b1.h.proc.srcname)
        print,'save data to file:',fsavl
        save,bf,bcalf,srcnamesf,file=fsavl
    endif
;
;   return all of the indices that didn't match
;
    if nbadindar gt 0 then begin
        ind=where(badIndAr ne -1,count)
        if count gt 0 then begin
            badIndAr=badIndAr[ind]
            nBadIndAr=count
        endif else begin
            badindar=-1
            nbadindar=0
        endelse
    endif
    return,numfound
end
