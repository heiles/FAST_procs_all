;+
;NAME:
;warch_gettbl - input table of scans from wapp archive
;SYNTAX: nsets=warch_gettbl(yymmdd1,yymmdd2,warchI,rcvnum=rcvnum,
;                            freq=freq,proj=proj)
;ARGS: 
;    yyyymmdd1  :long   year,month,day of first day to get (utc)
;    yyyymmdd2  :long   year,month,day of last  day to get (utc)
;
;KEYWORDS:
;       rcvnum  :long   receiver number to extract:
;                        1=327,2=430,3=610,5=lbw,6=lbn,7=sbw,8=sbw,9=cb,$
;                        10=xb,12=sbn,100=430ch
;       freq[2] :float  Require cfr of band to be between freq[0] and freq[1]
;                       in Mhz. At least 1 sbc of scan must match this.
;       proj    :string project number to match (eg. 'p1473')
;
;RETURNS:
;   nsets       :long   number of data sets found
; warchI[nscans]:{wapparchI}  wapp archive info structure
;
;TERMINOLOGY:
;   data set: The wapps can create 1 to 4 files imultaneously (depending
;             on many wapps are used). A data set is one of these sets of
;             files. Each file can not be greater than 2.2 gb.
;   scan    : A scan is one continuous integration. It can contain one
;             or more datasets (depending on the i/o rate and length of the
;             integration.
;
;DESCRIPTION:
;   This routine will scan the wapp pulsar archive and return a table 
;(an array of wapparchI structures) for all datasets in the archive that meet 
;the requested criteria.
;
;   The array contains one entry for each wapp dataset found. 
;The data structure contains a part that is independent of the 
;4 wapps and then a portion that is different for each wapp. The data
;structure is:
;
; --------------------------------------------------------------------------
;IDL> help,warchI,/st
;** Structure WAPPARCHI, 21 tags, length=436, data length=392:
;   PROJID          STRING 'P1555'   ; project id for this set
;   SCAN            LONG   318911152 ; generated from start time 1st wapp
;                                    ; format : ydddnnnnn 
;   JD              DOUBLE 2452828.6 ; JulDay start time 1st wapp used
;   OBS_CODE        BYTE   1         ; 1-search,2-folding data
;   SRC_RAHR        DOUBLE 18.898889 ; starting ra  of scan in Hrs (alfapix 0)
;   SRC_DECD        DOUBLE 13.081389 ; starting dec of scan in deg (alfapix 0)
;   START_AZ        FLOAT  283.687   ; starting az  of scan in deg (alfapix 0)
;   START_ZA        FLOAT  18.3252   ; starting za  of scan in deg (alfapix 0)
;   START_AST       FLOAT  83129.0   ; starting seconds from Midnite (ast) 
;   START_LST       FLOAT  17.6855   ; starting lst of scan seconds
;   OBS_TIME        FLOAT  900.096   ; requested seconds for scan
;   WAPP_TIME       FLOAT  64.00     ; wapp sample time usecs
;   TIMEOFF         LONG64 0         ; usecs from start of scan for start of
;                                    ; this datasets (for scans with more 
;                                    ; than 1 dataset
;   RFNUM           BYTE   0         ; feed number. alfa=17
;   ALFA_ANG        FLOAT  0.00      ; alfa rotation angle (deg)
;   SYN1            DOUBLE 0.00      ; 1st lo (mhz)
;   SYNFRQ          DOUBLE Array[4]  ; 2nd lo's (Mhz) if not alfa
;   NWAPPS          BYTE   1         ; number of wapps used (1 to 4)
;   WAPPUSED        BYTE   Array[4]  ; 1--> this wapp used, 0--> not used
;   IND1ST          BYTE   0         ; index into wappused for first wappused
;                                    ; (0 to 3).
;   WAPP            STRUCT  -> WAPPARCHICPU Array[4] ; wapp specific info
;
; There are always 4 entries for the wapp[] array. The wappused[4]
;array tells which of these were in use.
;
;   IDL> help,warchI.wapp,/st
;** Structure WAPPARCHICPU, 15 tags, length=76, data length=67:
;   DIR             STRING '/proj/p1555/' ; directory for file
;   FNAME           STRING 'P1555.1853+1308A.wapp1.52828.0000'; filename
;   ONDISC          BYTE    1             ; 1--> on disc (last we checked)
;   FILESIZE        DOUBLE  2.1463117e+09 ; file size in bytes
;   JD              DOUBLE  2452828.6     ; julian day start this wapp
;   WAPPNO          BYTE    1             ; wappnumber 1 thru 4
;   CENT_FREQ       DOUBLE  1400.0000     ; center frequency this wapp
;   BANDWIDTH       FLOAT   100.000       ; bandwidth in Mhz.
;   NUM_LAGS        LONG    128           ; number of lags used
;   LEVEL           BYTE    1             ; level used: 1-3,2-9 ??
;   SUM             BYTE    0             ; 1--> sum polarizations
;   LAGFORMAT       BYTE    0             ; 0 - 16 bit unsigned ints acf
;                                         ; 1 - 32 bit unsigned ints acf
;                                         ; 2 - 32 bit floats        acf
;                                         ; 3 - 32 bit float spectra
;   NBINS           LONG    0             ; number of bins if folding
;   NIFS            BYTE    2             ; number of IF's 1,2 , 4=stokes
;   ISFOLDING       BYTE    0             ; 1 if folding mode
; --------------------------------------------------------------------------
;
;EXAMPLES
;
;   The following examples will read the warchI array for all the data
;between jan03 and dec04 (that is in the archive). The examples will then 
;select different pieces of information that are in this warchI array. 
;
;;get tbl for all data we have from 2003 thru apr 2005
;
; nscans=warch_gettbl(20030101,20050431,warchI)
;;
;; get the starting ra,decs for each integration and plot them
;;
;   raHr=warchI.src_RaHr        ; start ra  in hours
;   decD=warchI.src_DecD        ; start dec in degrees
;
;   plot,raHr,decD,psym=2
;
;; find all of the p2030 data and see what ra/dec they have covered
;; (this is just plotting the starting ra/dec of each scan.
;
;   ind=where(warchI.projid eq 'p2030')
;   ver,0,38 & hor , 0,24
;   plot,raHr[ind],decD[ind],psym=2
;
;NOTE:
;   The recording of the archive started in apr05. It contains info  on
;all of the data on disc at that time (29 terabytes) and all data taken
;after that.
;-
function warch_gettbl,yymmdd1,yymmdd2,warchIGl,rcvnum=rcvnum,$
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
            freqL[0]=freq[0]-25.5
            freqL[1]=freq[0]+25.5
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
    dir='/share/megs/phil/x101/archive/wapp/save/'
    cmd='ls ' + dir + 'f*archI.sav'
    spawn,cmd,list,count=nmonfiles
    if nmonfiles eq 0 then begin
        warchIGl=''
        return,0
    endif
    juldates=dblarr(2,nmonfiles)       ; start,end juldates each file
    warchIGl=replicate({wapparchI},maxscans)
;
;   yymmdd1 is utc
;
    julday1=yymmddtojulday(yymmdd1) 
    julday2=yymmddtojulday(yymmdd2) 
    useMon=intarr(nmonfiles)

    for i=0,nmonfiles-1 do begin 
        a=stregex(list[i],'f_([0-9]*)_([0-9]*)_archI\.sav',/extract,/subexpr ) 
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
    for i=0,nmonfiles-1 do begin
        if useMon[i] then begin
            restore,list[i]
;
;           file overlaps 1 side of range, just use part in range
;
            nscans=n_elements(warchI)
            if nscans eq 0 then goto,botloop
            nscansI=nscans
            if useProj then begin
                ind=where(strlowcase(warchI.projid) eq  projL,nscans)
                if nscans eq 0 then goto, botloop
                warchI=warchI[ind]
            endif
            if n_elements(rcvnum) gt 0 then begin
                ind=where(warchI.rfnum eq rcvnum,nscansnew)
                if (nscansnew eq 0) then goto,botloop
                if (nscansnew ne nscans) then warchI=warchI[ind]
                nscans=nscansnew
            endif
            if useFreq then begin
                ind=where( ((warchI.wappused[0] eq 1)                     and $ 
                            (    warchI.wapp[0].cent_freq  ge freqL[0])   and $
                            (    warchI.wapp[0].cent_freq  le freqL[1]) )  or $

                           ((warchI.wappused[1] eq 1)                     and $ 
                             (   warchI.wapp[1].cent_freq  ge freqL[0])   and $
                             (   warchI.wapp[1].cent_freq  le freqL[1]) )  or $

                           ((warchI.wappused[2] eq 1)                     and $ 
                             (   warchI.wapp[2].cent_freq  ge freqL[0])   and $
                             (   warchI.wapp[2].cent_freq  le freqL[1]) )  or $

                           ((warchI.wappused[3] eq 1)                     and $ 
                             (   warchI.wapp[3].cent_freq  ge freqL[0])   and $
                             (   warchI.wapp[3].cent_freq  le freqL[1]) ),  $
                            nscansnew)
                if (nscansnew eq 0) then goto,botloop
                if (nscansnew ne nscans) then warchI=warchI[ind]
                nscans=nscansnew
            endif
;
            if nscans gt 0 then begin
               i1st=findgen(nscans)*4L + warchI.ind1st ;ind start wapp each set
               jd=(warchI.wapp.jd)[i1st]
               ind=where((jd ge julday1) and $
                          (jd lt julday2+1),nscansnew)
               if nscansNew eq 0 then goto,botloop  
               if nscansnew ne nscans then begin
                  warchI=warchI[ind]
                  nscans=nscansnew
               endif
;
;           add to the big array, make sure we have space..
;
               if nscans gt 0 then begin
                  if (inpscans + nscans) gt maxscans then begin 
                     warchIGlT=temporary(warchIGll)
                     n=maxscans+scangrow
                     warchIGl = replicate({wapparchI},n)
                     warchIGl[0:maxscans-1]=warchIGlT
                     warchIGlT=''
                     maxscans=maxscans + scangrow       
                  endif
;       
;                 now move the data over
;   
                  warchIGl[inpscans:inpscans+nscans-1L]=warchI
                  inpscans =inpscans + nscans
               endif  ; nscans gt 0 (2)
            endif     ; nscans gt 0 (1)
        endif         ; usefile
botLoop:
    endfor
    if inpscans lt maxscans then begin
        if inpscans eq 0 then begin
            warchIGl=''
        endif else begin
            warchIGl=warchIGl[0:inpscans-1]
        endelse
    endif
    return,inpscans
end
