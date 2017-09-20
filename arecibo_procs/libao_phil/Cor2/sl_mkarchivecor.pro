;+
;NAME:
;sl_mkarchivecor - create cor scan list for archive
;
;SYNTAX: nscans=sl_mkarchivecor(slAr,slFileAr,slcor,slfilecor,verbose=verbose,$
;                   logfile=logfile
;
;ARGS:
;     slAr[n]: {sl}     sl array returned by arch_gettbl
; slFileAr[m]: {slind}  returned by arch_gettbl
;
;RETURNS:
;   slCor[nscans] {corsl} Extended scanlist containing ra,dec and corinfo
;  slFileCor[m]: {slind}  file array. same as slfilear unless some files
;                         have disappeared between running slar,slcorar.
;
;KEYWORDS:
;   verbose:    If set then print each file as we process it.
;   logfile: string   name of file to write progress messages. by default 
;               messages only go to stdout.

;
;DESCRIPTION:
;   sl_mkarchive creates a large scanlist for a set of files (usually a
;months worth of data. These files are stored on disc and arch_gettbl
;allows you to retrieve this data or a subset of it. The info in slAr
;is a limited set that contains info common to all scans at ao (correlator
;ri, radar, atm, etc..). 
;   The sl_mkarchivecor will take the slAr and make a superset of this
;structure. In addition to the {sl} info it will contain ra,dec info as well
;as correlator info. You can then access this info with the arch_gettbl
;command using the /cor keyword.
;
;   The slcor[] is an array of structures (1 per scan) containing:
;
;    scan      :         0L, $; scannumber this entry
;    bytepos   :         0L,$; byte pos start of this scan
;    fileindex :         0L, $; lets you point to a filename array
;    stat      :         0B ,$; not used yet..
;    rcvnum    :         0B ,$; receiver number 1-16
;    numfrq    :         0B ,$; number of freq,cor boards used this scan
;    rectype   :         0B ,$;1-calon,2-caloff,3-posOn,4-posOff
;    numrecs   :         0L ,$; number of groups(records in scan)
;    freq      :   fltarr(4),$;topocentric freqMhz center each subband
;    julday    :         0.D,$; julian day start of scan
;    srcname   :         ' ',$;source name (max 12 long)
;    procname  :         ' ',# ;procedure name used.
;
;   .. the extended cor info begins here...
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
;    raHrReq   :         0.D,$; requested ra ,  start of scan  J2000
;    decDReq   :         0.D,$; requested dec,  start of scan J2000.
;
;                       Delta end-start real angle for requested position
;    raDelta   :         0. ,$; delta ra last-first recs. Amins real angle
;   decDelta   :         0. ,$; delta dec (last-frist)Arcminutes real  angle
;
;    azErrAsec :         0. ,$; avg azErr Asecs great circle
;    zaErrAsec :         0.  $; avg zaErr Asecs great circle
;
;
;   The routine sl_mkarchive is run monthly and the info is stored in 
;files by month. This routine can then be run to create the slcor data.
;
;EXAMPLE:
;
;   The monthly processing would look like:
;;
;;1. create listfile from corflist.sc 010101 010131 excl.dat outside of idl.
;;2. make the slAr, slFileAr and save it
;
;nscans=sl_mkarchive(listfile,slAr,slfilear)
;save,sl,slar,file='/share/megs/phil/x101/archive/sl/f010101_010131.sav'
;;
;;3. now make slcor ar.
; arch_gettbl(010101,010131,slAr,slFilear)
; nscans=sl_mkarchivecor(slar,slfilear,slcor,slfilecor)
; slar=slcor            ; so they have the same names
; slfileAr=slfilecor   ; so they have the same names
; save,slar,slfilear,file=$
;       '/share/megs/phil/x101/archive/slcor/f010101_010131.sav'
;
;SEE ALSO:sl_mkarchive,arch_gettbl,arch_getdata
;-
;history:
;   04jan03 - now checks to see if gr is master so it gets correct za
;             for ch.            
;   04jan03 - was using same reclen for all recs in a group. Needed to
;             look at each rec of each group separately
;   16jan03 - reclen was float. needed to be double or long. when 
;             next record of group computed, it lost precision on large files.
;   11feb03 - radelta has trouble crossing midnite
;   03may03 - if badheader found i was not updating the cross
;             reference of slfilear.i1,i2 back into slar.
;   12aug04 - started to change to support the wapps.. 
;             did not finish since need to redimension some of the 
;             arrays in the structure and this will break the data
;             currently stored in the archive.
;
function  sl_mkarchivecor,slAr,slFileAr,slcor,slfilecor,verbose=verbose,$
            logfile=logfile
;
    totscans=n_elements(slAr)
    slcor=replicate({corsl},totscans)
    ST_BLANK='0x00000004'XL
    radToHr =24.D/(!dpi*2.D)
    radToDeg=360.D/(!dpi*2.D)
    hrToAmin=360.D*60.D/24.D
    nfiles=n_elements(slFileAr)
    lun=-1
    lunOpen=-1
    lunOut=-1
    if n_elements(logfile) gt 0 then begin
        openw,lunout,logfile,/get_lun,/append
        printf,lunout,'starting sl_mkarchivecor' + systime()
    endif

     
    iarch=0L                    ; count of sl elements we've processed
    ist=slfilear[0].i1
    iend=slfilear[nfiles-1].i2
    slfileCor=slfilear
    ifilegood=0                 ; weve processed.may be missing files
    for ifile=0,nfiles-1 do begin
        file=slFileAr[ifile].path+slFileAr[ifile].file
        useWas=wascheck(lun,file=file)
        if lunOpen ne -1 then begin
            if useWas then begin
                wasclose,lun
            endif else begin
                free_lun,lun
            endelse
            lunOpen=-1
        endif
        stat=file_exists(file,junk,size=size)
        if (stat ne 1) or (not keyword_set(size)) then goto,botloop

        if useWas then begin
            istat=wasopen(file,lun)
            lunOpen=1
        endif else begin
            openr,lun,file,/get_lun
            lunOpen=1
        endelse
;
;       get ptrs into slAr for this file
;
        i1=slFileAr[ifile].i1
        i2=slFileAr[ifile].i2
;
;       copy to cor version. use current start position
;
        slfileCor[ifilegood]=slfilear[ifile]
        slfilecor[ifilegood].i1=iarch
;
;       projid
;
        ind1=strpos(slFileAr[ifile].file,'.',8) + 1
        len =strpos(slFileAr[ifile].file,'.',/reverse_s) - ind1
        projId=strlowcase(strmid(slfileAr[ifile].file,ind1,len))
        if keyword_set(verbose) then begin
            print,'start:',slfileAr[ifile].file," scans:",i2-i1+1,' cum:',iarch
            if lunOut ne -1 then $
                printf,lunOut,$
                'start:',slfileAr[ifile].file," scans:",i2-i1+1,' cum:',iarch

        endif
;
;       loop through each scan of this file
;
        for iscan=i1,i2 do begin
            if useWas then begin
                istat=posscan(lun,slar[iscan].scan)
            endif else begin
                point_lun,lun,slAr[iscan].bytepos
            endelse
            nbrds=slAr[iscan].numfrq
            nrecs=slAr[iscan].numrecs
;           
;           get hdrs first rec of scan. fill in rec independent junk
;
            istat=corgethdr(lun,rethdr)
            if istat ne 1 then begin
         lab=string(format='("gethdr errA:",i8," file,scan,rec:",a,I10,i5)',$
                istat,file,slar[iscan].scan,0)

                print,lab,string(7b)
                if lunOut ne -1 then $
                    printf,lunOut,lab
                goto,botscan
            endif
            reclen=ulong(total(rethdr.std.reclen,/double) + .5)
            slcor[iarch].secsPerRec=rethdr[0].cor.dumpsPerInteg*$
                                     (rethdr[0].cor.dumpLen/50000000.)
            slcor[iarch].channels[0:nbrds-1]=rethdr.cor.lagSbcOut
            slcor[iarch].bwNum[0:nbrds-1]   =rethdr.cor.bwNum
            slcor[iarch].lagConfig[0:nbrds-1]=rethdr.cor.lagConfig
            slcor[iarch].lag0[*,0:nbrds-1]  =rethdr.cor.lag0PwrRatio
            slcor[iarch].projId            =projId
            slcor[iarch].blanking          =((rethdr[0].cor.state and  $
                                                ST_blank) eq 0) ? 0B : 1B
            slcor[iarch].rcvnum =slar[iscan].rcvnum
;
;
            if pnthgrmaster(rethdr[0].pnt) then begin
                za=rethdr[0].std.grttd*.0001    
            endif else begin
                za=rethdr[0].std.chttd*.0001    
            endelse
;
;           this is at the end of the first record..
;
            slcor[iarch].azAvg             =(rethdr[0].std.azttd*.0001)
            slcor[iarch].zaAvg             =za
            slcor[iarch].raHrReq= retHdr[0].pnt.r.rajcumrd*12.D/(!dpi)
            slcor[iarch].decDReq= retHdr[0].pnt.r.decJcumrd*180.D/(!dpi)
            slcor[iarch].julday = slar[iscan].julday ; from scan start time
            slcor[iarch].scan   =slar[iscan].scan
            slcor[iarch].bytepos=slar[iscan].bytepos
            slcor[iarch].fileindex=ifilegood
            slcor[iarch].stat   =slar[iscan].stat
            slcor[iarch].numfrq =slar[iscan].numfrq
            slcor[iarch].rectype=slar[iscan].rectype
            slcor[iarch].numrecs=slar[iscan].numrecs
            slcor[iarch].freq   =slar[iscan].freq
            slcor[iarch].srcname=slar[iscan].srcname
            slcor[iarch].procname=slar[iscan].procname

            azErrRd=retHdr[0].pnt.errAzRd*sin(za*!dtor)
            zaErrRd=retHdr[0].pnt.errZaRd
;;          print,'1strec:',rethdr.cor.lag0pwrratio
;;          stop
;;  print,'az,za avg0:',slcor[iarch].azAvg,slcor[iarch].zaavg
;
;           now do the per record accumulations.. be careful with
;           computing bytepos. make sure it is unsigned long so it will
;           work to 4gb.
;
            for irec=1UL,nrecs-1 do begin
                if not useWas then $
                    point_lun,lun,slAr[iscan].bytepos + irec*(reclen)
                istat=corgethdr(lun,rethdr)
                if istat ne 1 then begin
                    lab=string(format=$
'("gethdr errB:",i8," file,scan,rec:",a,I10,i5)',$
                istat,file,slar[iscan].scan,irec)
                    print,lab,string(7b)
                    if lunOut ne -1 then printf,lunOut,lab
                    goto,botscan
                endif
                slcor[iarch].lag0[*,0:nbrds-1]  =$
                    slcor[iarch].lag0[*,0:nbrds-1]  + rethdr.cor.lag0PwrRatio
;;              print,'irec:',irec
;;      print,rethdr.cor.lag0pwrratio,' cum:',slcor[iarch].lag0[*,0:nbrds-1]
                slcor[iarch].azAvg              = slcor[iarch].azAvg  + $ 
                                                (rethdr[0].std.azttd*.0001)
                if pnthgrmaster(rethdr[0].pnt) then begin
                    za=rethdr[0].std.grttd*.0001    
                endif else begin
                    za=rethdr[0].std.chttd*.0001    
                endelse
                slcor[iarch].zaAvg             =za + slcor[iarch].zaAvg 
                azErrRd=azErrRd +retHdr[0].pnt.errAzRd*sin(za*!dtor)
                zaErrRd=zaErrRd + retHdr[0].pnt.errZaRd
;
;           store ra,dec cum second to last record. Sometimes the last
;           record has info for start of next scan if timed scan.
;
                if (nrecs eq 2) or (irec eq (nrecs - 2)) then begin
                    rahEnd =retHdr[0].pnt.r.rajcumrd*12.D/(!dpi)
                    decDEnd=retHdr[0].pnt.r.decJcumrd*180.D/(!dpi)
;
;               how long the interval to measure the delta ra,dec
;
                    divSec=1.*$
                        (retHdr[0].pnt.r.secmid - retHdr[0].std.stScanTime)
                    if divSec lt -43200. then divSec=divSec+86400.
                endif
;;  print,'az,zaN,za:',irec,za,slcor[iarch].azAvg,slcor[iarch].zaavg
            endfor
;           if (slar[iscan].scan eq 226400262L) then stop
            if nrecs gt 1 then begin
;;              stop
                slcor[iarch].lag0[*,0:nbrds-1]=$
                    slcor[iarch].lag0[*,0:nbrds-1]/nrecs
;               print,slar[iscan].scan,slcor[iarch].lag0[0,0]
                slcor[iarch].zaAvg          =slcor[iarch].zaAvg/nrecs
                slcor[iarch].azAvg          =slcor[iarch].azAvg/nrecs
;
;               compute req change in ra,dec end - start in ArcMinutes
;               use the 2nd to last rec
;
                totSecs=slAr[iscan].numrecs*slcor[iarch].secsPerRec
                deltaRa = totSecs*(raHEnd  - slcor[iarch].raHrReq)/(divSec)
                slcor[iarch].decDelta = $
                    60.D*totSecs*(decDEnd - slcor[iarch].decDReq)/(divSec)
                    dRaHr=raHEnd  - slcor[iarch].raHrReq
                    case 1 of
                      dRaHr gt 12. : dRaHr=DRaHr-24.D
                      dRaHr lt -12.: dRaHr=DRaHr+24.D
                      else :
                    endcase
                slcor[iarch].raDelta  =15.*60.D*totSecs*dRaHr/(divSec)*$
                        cos((slcor[iarch].decDReq + $
                       .5D*slcor[iarch].decDelta/60.D)*!dtor)
            endif
            slcor[iarch].azErrAsec= azErrRd*3600.D*180.D/(!dpi*nrecs) 
            slcor[iarch].zaErrAsec= zaErrRd*3600.D*180.D/(!dpi*nrecs)
;           help,slcor[iarch],/st

            iarch=iarch+1L
botScan:

        endfor
botloop:            ; looping on 1 file
        slfileCor[ifilegood].i2=iarch-1L
        if slfilecor[ifilegood].i1 le slfilecor[ifilegood].i2 then $
                ifilegood=ifilegood+1L
    endfor
    if lunOpen ne -1 then begin
        if useWas then begin
            wasclose,lun
        endif else begin
            free_lun,lun
        endelse
    endif
    if lunOut ne -1 then begin
        printf,lunOut,'finished running sl_mkarchive'+ systime()
        free_lun,lunOut
        lunOut=-1
    endif
    if (n_elements(slcor) ne iarch) and (iarch gt 0)  then slcor=slcor[0:iarch-1L]
    if (n_elements(slfilecor) ne ifilegood) and (ifilegood gt 0)  then slfilecor=$
                slfilecor[0:ifilegood-1L]
    return,iarch
end
