;+
;NAME:
;arch_gettbl - input table of scans from cor archive
;SYNTAX: nscans=arch_gettbl(yymmdd1,yymmdd2,slAr,slfileAr,rcvnum=rcvnum,
;                            freq=freq,proj=proj,cor=cor)
;ARGS: 
;      yymmdd1  : long    year,month,day of first day to get (ast)
;                         for interim correlator data yy is two digits.
;                         for was data, yy is 4 digits 2004mmdd
;      yymmdd2  : long    year,month,day of last  day to get (ast)
;                         for interim correlator data yy is two digits.
;                         for was data, yy is 4 digits 2004mmdd
;KEYWORDS:
;       rcvnum  : long  .. receiver number to extract:
;                       1=327,2=430,3=610,5=lbw,6=lbn,7=sbw,8=sbw,9=cb,$
;                       10=xb,12=sbn,100=430ch
;       freq[2] : float  Require cfr of band to be between freq[0] and freq[1]
;                        in Mhz. At least 1 sbc of scan must match this.
;       proj    : string project number to match (eg. 'a1473')
;       cor     :       If set then return the cor scanlist (see below)
;RETURNS:
;   slAr[count] : {sl} or {corsl}   scanlist array for each scan
;   slFileAr[n] : {slInd} one entry per file found
;        nscans : long   number of scans found
;DESCRIPTION:
;   This routine will scan the correlator archive and return a table 
;(an array of scanlist structures) for all scans in the archive that meet 
;the requested criteria. Two arrays are returned:
;1. slAr[]      holds 1 entry per scan 
;2. slfileAr[m] holds 1 entry per file found.
; -------------------------------------------------------------------
; For Interim correlator data:
;
;   Each slAr entry is an {sl} or {corsl} structure that contains:
;
;    scan      :         0L, $; scannumber this entry
;    bytepos   :         0L, $; byte pos start of this scan
;    fileindex :         0L, $; lets you point to a filename array
;    stat      :         0B ,$; not used yet..
;    rcvnum    :         0B ,$; receiver number 1-16
;    numfrq    :         0B ,$; number of freq,cor boards used this scan
;    rectype   :         0B ,$;type of pattern used to take the data. The 
;                              values are listed below (see getsl() under
;                              generic idl routines for the most recent list).
;                              1-calon,2-caloff,3-posOn,4-posOff,5-coron
;                              6-cormap1,7-cormapdec,8-cordrift,
;                              9-corcrossch (used by calibration routines)
;                             10-x111auto (rfi monitoring),11-one(bml),
;                             12-onoffbml
;                              ... see getsl() in GENEral idl
;    numrecs   :         0L ,$; number of groups(records in scan)
;    freq      :   fltarr(4),$;topocentric freqMhz center each subband
;    julday    :         0.D,$; julian date start of scan 
;    srcname   :         ' ',$;source name (max 12 long)
;    procname  :         ' '};procedure name used.
;
;   If the /cor  keyword is included then the slAr will be an {corsl} 
;structure and will contain the following additional fields:
;
;   projId    :         '' ,$; from the filename
;   patId     :         0L ,$; groups scans beloging to a known pattern
;
;   secsPerrec :         0. ,$; seconds integration per record
;    channels  :   intarr(4),$; number output channels each sbc
;    bwNum     :   bytarr(4),$; bandwidth number 1=50Mhz,2=25Mhz...
;    lagConfig :   bytarr(4),$; lag config each sbc
;    lag0      :  fltarr(2,4),$; lag 0 power ratio (scan average)
;    blanking  :         0B  ,$; 0 or 1
;
;    azavg     :         0. ,$; actual encoder azimuth average of scan
;    zaavg     :         0. ,$; actual encoder za      average of scan
;
;    raHrReq   :         0.D,$; ra hours  requested ,  start of scan
;    decDReq   :         0.D,$; dec degrees requested, start of scan J2000
;
;                       Delta ScanEnd-scanStart.. real angle for motion
;    raDelta   :         0. ,$; delta ra  Arcminutes  real angle
;   decDelta   :         0. ,$; delta dec Arcminutes 
;    azErrAsec :         0. ,$; avg azErr Asecs great circle
;    zaErrAsec :         0.  $; avg zaErr Asecs great circle
; -------------------------------------------------------------------
; For was2  data:
;   The return slar data structure is:
;a={slwas ,$
;    scan      :         0L, $; scannumber this entry
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
;    raHrReq   :         0.D,$; requested ra ,  start of scan  J2000
;    decDReq   :         0.D,$; requested dec,  start of scan J2000.
;
;;                       Delta end-start real angle for requested position
;    raDelta   :         0. ,$; delta ra last-first recs. Amins real angle
;   decDelta   :         0. ,$; delta dec (last-frist)Arcminutes real  angle
;
;    pntErrAsec :         0. ,$; avg great circle pnt error
;
;;     alfa related
;
;     alfaAngle:         0.  , $; alfa rotation angle used in deg
;     alfaCen :        
;
;   You can use the slAr and slFileAr to then access the actual data files
;without having to search through the file.
;
;EXAMPLES
;   The following examples will read the scanlist array for all the data
;beteen jan02 and apr02. The examples will then select different pieces
;of information that are in this scanlist array.  The final step will
;extract some of the actual datascans.
;
;;get tbl for all data for jan02->apr02.
;
; nscans=arch_gettbl(020101,020430,slAr,slFileAr)
;
;; work with this scanlist dataset..
;; make a list of the unique source names
;
;  srcnames=slar[uniq(slar.srcname,sort(slar.srcname))].srcname
;  print,srcnames
;;
;; find all of the on/off position switch data for cband (rcv=9)
;; (note corfindpat does not yet work for was2 data..)
;  n=corfindpat(slar,indar,pattype=1,rcv=9)
;; find source NGC2264
;  indar=where(slar.srcname eq 'NGC2264',count)
;
; now extract the scan averaged data. It will extract all data scans
;that match the dataformat of the first entry of indar[0] (see arch_getdata().
;
;  n=arch_getdata(slar,slfilear,indar,b,type=3,/han,incompat=incompat)
;
;SEE ALSO:getsl, arch_getdata,corfindpat. 
;NOTES:
;   22aug04. this is now implemented for was2 data. The cor= keyword is
;ignored. The data stucture returned is a little different than the
;interim corr structure.
;-
; history:
; 18apr06 cmd=ls --> cmd='\ls' for people who have aliased ls
;
function arch_gettbl,yymmdd1,yymmdd2,slArGl,slfileArGl,rcvnum=rcvnum,$
                      freq=freq,proj=proj,cor=cor
;
; list the files in the directory
;
;    on_error,1
    useFreq=0
    if keyword_set(freq) then begin
        freqL=fltarr(2)
        useFreq=1
        if n_elements(freq) eq 1 then begin
            freqL[0]=freq[0]-12.5
            freqL[1]=freq[0]+12.5
        endif else begin
            freqL=freq
        endelse
    endif
    useProj=0
    if keyword_set(proj) then begin
        useProj=1
        projL=strlowcase(proj)
    endif
        
    maxscans=50000           ;
    scangrow=maxscans/2
    maxfiles=5000            ; 
    filegrow=maxfiles/2
    usecor=(keyword_set(cor)) ? 1 : 0
    if usecor then begin
        slArGl=replicate({corsl},maxscans)
        dir='/share/megs/phil/x101/archive/slcor/'
    endif else begin
        slArGl=replicate({sl},maxscans)
        dir='/share/megs/phil/x101/archive/sl/'
    endelse
    slFileArGl=replicate({slInd},maxfiles)
    cmd='\ls ' + dir + 'f*sav'
    spawn,cmd,list
    nmonfiles=n_elements(list)
    juldates=dblarr(2,nmonfiles)       ; start,end juldates each file
;
;   yymmdd1 is ast
;
    julday1=yymmddtojulday(yymmdd1) + 4./24. ; go utc to ast
    julday2=yymmddtojulday(yymmdd2) + 4./24. ; go utc to ast
    useMon=intarr(nmonfiles)

    for i=0,nmonfiles-1 do begin 
        a=stregex(list[i],'f([0-9]*)_([0-9]*)\.sav',/extract,/subexpr ) 
;
;   convert begin,end to jul days
;
        yymmddf1=long(a[1]) 
        yymmddf2=long(a[2]) 
        juldates[0,i]=yymmddtojulday(yymmddf1)
        juldates[1,i]=yymmddtojulday(yymmddf2)
        if (yymmddf2 lt yymmdd1) or (yymmddf1 gt yymmdd2) then begin
        endif else begin
            useMon[i]= 1
        endelse
;        print,list[i]," use:",usefile[i]
    endfor
    inpscans=0L
    inpfiles=0L
    for i=0,nmonfiles-1 do begin
        if useMon[i] then begin
            restore,list[i]
;
;           file overlaps 1 side of range, just use part in range
;
            nscans=n_elements(slAr)
            if nscans eq 0 then goto,botloop
            nscansI=nscans
            if useProj then begin
                nfiles=n_elements(slfilear)
                ind1=strpos(slFileAr.file,'.',8) + 1
                len =strpos(slFileAr.file,'.',/reverse_s) - ind1
                ind1=reform(ind1,1,nfiles)
                len =reform(len,1,nfiles)
                projLAr=strmid(slfileAr.file,ind1,len)
                find=where(projL eq strlowcase(projLAr),count)
                if count eq 0 then goto,botloop
                slFileAr=slFileAr[find]
                nlen=(slFileAr.i2 - slFileAr.i1)+1 ; scans this file
                slArT=(usecor)? replicate({corsl},total(nlen)): $
                                replicate({sl},total(nlen))
                jj=0
                for j=0,n_elements(slFileAr)-1 do begin  
                        i1=jj 
                        i2=i1+ nlen[j]-1 
                        slArT[i1:i2]=slAr[slFileAr[j].i1:slFileAr[j].i2] 
                        slArT[i1:i2].fileindex=j 
                        slFileAr[j].i1=i1 
                        slFileAr[j].i2=i2 
                        jj=jj+nlen[j] 
                endfor
                slAr=slArT
                slArT=''
                nscans=n_elements(slAr)
                if nscans eq 0 then goto,botloop
                nscansI=nscans          ; slFileAr,slAr are in sync..
            endif
            if n_elements(rcvnum) gt 0 then begin
                ind=where(slAr.rcvnum eq rcvnum,nscans)
                if (nscans eq 0) then goto,botloop
                if (nscans ne nscansI) then slAr=slAr[ind]
            endif
            if useFreq then begin
                ind=where($
                ((slAr.freq[0] ge freqL[0]) and (slAr.freq[0] le freqL[1])) or $
                ((slAr.freq[1] ge freqL[0]) and (slAr.freq[1] le freqL[1])) or $
                ((slAr.freq[2] ge freqL[0]) and (slAr.freq[2] le freqL[1])) or $
                ((slAr.freq[3] ge freqL[0]) and (slAr.freq[3] le freqL[1])),$
                nscans)
                if (nscans eq 0) then goto,botloop
                if (nscans ne nscansI) then slAr=slAr[ind]
            endif
;
            if nscans gt 0 then begin
               indsl=where(((slAr.julday) ge julday1) and $
                      ((slAr.julday) lt julday2+1),nscans)
;
;           add to the big array, make sure we have space..
;
               if nscans gt 0 then begin
                  if (inpscans + nscans) gt maxscans then begin 
                     slArGlT=temporary(slArGl)
                     n=maxscans+scangrow
                     slArGl =(usecor)? replicate({corsl},n): $
                                       replicate({sl},n)
                     slArGl[0:maxscans-1]=slArGlT
                     slArGlT=''
                     maxscans=maxscans + scangrow       
                  endif
;
;                 If we took a subset, then we need to redo the 
;                 ptrs in slAr and slFileAr 
;                 1. subset slAr
;                 2. get the uniq file indices after subset
;                 3. subset slfileAr 
;                 4. for entry slFileAr 
;                    - update slAr.fileindex
;                    - update slFileAr.i1,i2
;
                  if nscans ne nscansI then begin   ; may have deleted some
                     slAr=slAr[indsl]
                     find=slAr[uniq(slAr.fileindex,$
                                sort(slAr.fileindex))].fileindex
                     n=n_elements(find)     ; old file indicies
                     slFileAr=slFileAr[find]
                     for j=0,n-1 do begin
                        ind=where(slAr.fileindex eq find[j],count)
                        slAr[ind].fileindex=j   ; now the jth file
                        slFileAr[j].i1=ind[0]   ; assume contigous in sl
                        slFileAr[j].i2=ind[0]+count-1
                     endfor
                  endif
                  nfiles=n_elements(slFileAr)
                  if (nfiles+inpfiles) gt maxfiles then begin
                      slFileArGlT=temporary(slFileAr)
                      slFileArGl =replicate({slInd},maxfiles+growfile)
                      slFileArGl[0:maxfiles-1]=slFileArGlT
                      slFileArGlT=''
                      maxfiles=maxfiles+growfile
                  endif
;       
;                 now move the data over
;   
                  slAr.fileindex=slAr.fileindex + inpfiles ; add new offset
                  slFileAr.i1=slFileAr.i1   + inpscans
                  slFileAr.i2=slFileAr.i2   + inpscans
                  slArGl[inpscans:inpscans+nscans-1L]=slAr
                  slFileArGl[inpfiles:inpfiles+nfiles-1L]=slFileAr
                  inpscans =inpscans + nscans
                  inpfiles =inpfiles + nfiles
               endif  ; nscans gt 0 (2)
            endif     ; nscans gt 0 (1)
        endif         ; usefile
botLoop:
    endfor
    if inpscans lt maxscans then begin
        if inpscans eq 0 then begin
            slArGl=''
        endif else begin
            slArGl=slArGl[0:inpscans-1]
        endelse
    endif
    if inpfiles lt maxfiles then begin
        if inpfiles eq 0 then begin
           inpfiles=''
        endif else begin
           slFileArGl=slFileArGl[0:inpfiles-1]
        endelse
    endif
    return,inpscans
end
