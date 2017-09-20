;+
;NAME:
;arch_gettbl - input table of scans from cor archive
;SYNTAX: nscans=arch_gettbl(yymmdd1,yymmdd2,slAr,slfileAr,rcvnum=rcvnum,
;                            freq=freq,proj=proj)
;ARGS: 
;      yyyymmdd1  : long    year,month,day of first day to get (ast)
;      yyyymmdd2  : long    year,month,day of last  day to get (ast)
;KEYWORDS:
;       rcvnum  : long  .. receiver number to extract:
;                       1=327,2=430,3=610,5=lbw,6=lbn,7=sbw,8=sbw,9=cb,$
;                       10=xb,12=sbn,100=430ch
;       freq[2] : float  Require cfr of band to be between freq[0] and freq[1]
;                        in Mhz. At least 1 sbc of scan must match this.
;       proj    : string project number to match (eg. 'a1473')
;RETURNS:
;   slAr[count] : {sl} or {corsl}   scanlist array for each scan
;   slFileAr[n] : {slInd} one entry per file found
;        nscans : long   number of scans found
;DESCRIPTION:
;   This routine will scan the was archive and return a table 
;(an array of scanlist structures) for all scans in the archive that meet 
;the requested criteria. Two arrays are returned:
;1. slAr[]      holds 1 entry per scan 
;2. slfileAr[m] holds 1 entry per file found.
;
;   Each slAr entry is an {sl} or {corsl} structure that contains:
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
;    }
;
;   You can use the slAr and slFileAr to then access the actual data files
;without having to search through the file.
;
;EXAMPLES
;   The following examples will read the scanlist array for all the data
;beteen sep04 and dec04. The examples will then select different pieces
;of information that are in this scanlist array.  The final step will
;extract some of the actual datascans.
;
;;get tbl for all data for sep04->oct04.
;
; nscans=arch_gettbl(20040901,20041201,slAr,slFileAr)
;
;; work with this scanlist dataset..
;; make a list of the unique source names
;
;  srcnames=slar[uniq(slar.srcname,sort(slar.srcname))].srcname
;  print,srcnames
;;
;; find all of the on/off position switch data for cband (rcv=9)
;;; not yet... n=corfindpat(slar,indar,pattype=1,rcv=9)
;; find source NGC2264
;  indar=where(slar.srcname eq 'NGC2264',count)
;
; now extract the scan averaged data. It will extract all data scans
;that match the dataformat of the first entry of indar[0] (see arch_getdata().
;
;  n=arch_getdata(slar,slfilear,indar,b,type=3,/han,incompat=incompat)
;
;SEE ALSO:getsl, arch_getdata,corfindpat. 
;-
function arch_gettbl,yymmdd1,yymmdd2,slArGl,slfileArGl,rcvnum=rcvnum,$
                      freq=freq,proj=proj
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
    slArGl=replicate({slwas},maxscans)
    dir='/share/megs/phil/x101/archive/was/sl/'
    slFileArGl=replicate({slInd},maxfiles)
    cmd='ls ' + dir + 'f*sav'
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
                ind=where(strlowcase(slar.projid) eq  projL,nscans)
                if nscans eq 0 then goto, botloop
                slAr=slAr[ind]
            endif
            if n_elements(rcvnum) gt 0 then begin
                ind=where(slAr.rcvnum eq rcvnum,nscansnew)
                if (nscansnew eq 0) then goto,botloop
                if (nscansnew ne nscans) then slAr=slAr[ind]
                nscans=nscansnew
            endif
            if useFreq then begin
                ind=where($
                ((slAr.freq[0] ge freqL[0]) and (slAr.freq[0] le freqL[1])) or $
                ((slAr.freq[1] ge freqL[0]) and (slAr.freq[1] le freqL[1])) or $
                ((slAr.freq[2] ge freqL[0]) and (slAr.freq[2] le freqL[1])) or $
                ((slAr.freq[3] ge freqL[0]) and (slAr.freq[3] le freqL[1])) or $
                ((slAr.freq[4] ge freqL[0]) and (slAr.freq[4] le freqL[1])) or $
                ((slAr.freq[5] ge freqL[0]) and (slAr.freq[5] le freqL[1])) or $
                ((slAr.freq[6] ge freqL[0]) and (slAr.freq[6] le freqL[1])) or $
                ((slAr.freq[7] ge freqL[0]) and (slAr.freq[7] le freqL[1])), $
                nscansnew)
                if (nscansnew eq 0) then goto,botloop
                if (nscansnew ne nscans) then slAr=slAr[ind]
                nscans=nscansnew
            endif
;
            if nscans gt 0 then begin
               indsl=where(((slAr.julday) ge julday1) and $
                      ((slAr.julday) lt julday2+1),nscansnew)
               if nscansnew ne nscans then begin
                  slar=slar[indsl]
                  nscans=nscansnew
               endif
;
;           add to the big array, make sure we have space..
;
               if nscans gt 0 then begin
                  if (inpscans + nscans) gt maxscans then begin 
                     slArGlT=temporary(slArGl)
                     n=maxscans+scangrow
                     slArGl = replicate({slwas},n)
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
                      slFileArGlT=slFileArGl[0:inpfiles-1]
                      slFileArGl =replicate({slInd},maxfiles+filegrow)
                      slFileArGl[0:inpfiles-1]=slFileArGlT
                      slFileArGlT=''
                      maxfiles=maxfiles+filegrow
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
