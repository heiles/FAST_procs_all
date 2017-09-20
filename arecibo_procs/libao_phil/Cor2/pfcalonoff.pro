;+
;NAME:
;pfcalonoff - extract calon/off scans and compute cal size and tsys.
;SYNTAX: ncals=pfcalonoff(lun,sl,pfcalI,han=han,scanOnAr=scanOnAr,slAr=slAr,$
;                           bla=bla,blda=blda,verb=verb)
;ARGS:
;        lun : int    open to file to process
;        sl[]: {slar} scan list of file from getsl()
;KEYWORDS:
;      han:      if set then hanning smooth the data on input
;scanOnAr[n]:long  if supplied then this is the list of calOn scans to process.
;                sl is ignored.
;  slAr[n]:long  Output from slar=getsl(lun). When scanOnAr is used sl is
;                ignored. You can still pass in slAr to speed the file access.
;      bla:      if set then use corblauto and fit to calOn-calOff to remove
;                outliers
;     blda:      if set then use corblauto and fit to (calOn-calOff)/caloff
;                to remove outliers
;verb     :      if set to -1 then have corblauto plot the fits and residuals
;           as it goes along.
;otherParms any extra keywords are passed to corcalcmp. These mainly
;           deal itin will be passed to corcalcmp
;           they can be used to control the selection of then channels
;           in each spectra to use.
;RETURNS:
;   ncals        : long       number of cal pairs found.
;   pfcalI[ncals]: {} return cal info (defined below)
;
;DESCRIPTION:
;   Find all of the on/off pairs in the scan list and then process them.
;The processing uses corcalcmp() to compute the cal value. It returns
;the processed data in pfcalI[].
;
; pfcalI contains:
;  pfcalI.scan          scan number of cal on
;  pfcalI.az            azimuth of cal on
;  pfcalI.za            azimuth of cal on
;  pfcalI.nbrds         number of boards this scan, entries in brdI[]
;  pfcalI.cfr[8]        center frequency for each board (topocentric)
;  pfcalI.bw[8]         bandwidth for each board (Mhz)
;  pfcalI.pols[2,8]     [pols,brds] 0==> not use, 1==>polA, 2--> polB
;  pfcalI.calScl[2,8]   cal scale factore (K/correaltor count)
;  pfcalI.calval[2,8]   cal in kelvins
;  pfcalI.tsysOn[2,8]   Tsys for cal on 
;  pfcalI.tsysOff[2,8]  Tsys for cal off 
;
; The array in pfcalI are dimensioned for the max number of sbc
; (including alfa). Use Use pfcalI.pols[] to decide whether a particular
; entry has data (0 --> no data).
;
; Examples:
;1. process the entire file. Tell corblauto to use (calOn-calOff)/calOff to
;   construct the mask of channels to use. Plot these fits.
;
;   file='/share/olcor/corfile...'
;   openr,lun,file,/get_lun
;   sl=getsl(lun)
;   ncals=pfcalonoff(lun,sl,pfcalI,/han,/blda,verb=-1)
;
;2. The sl array that is passed in does not have to be the scanlist
;   from the entire file. You can create a subset and it will process
;   what it is passed (but the sl passed in must contain the calon,off
;   scans you want processed). For the example, only process the
;   source "EA1".. 
;
;
;   ind=where(sl.srcname eq 'EA1',count)
;   if count gt 0 then begin
;       ncals=pfcalonoff(lun,sl[ind],pfcalI,/han,/blda,verb=-1)
;   endif
;; 
;;  You could have also made the selection on any other entry in sl[]
;
;3. The scanOnAr is another way to process only a subset of the file. It
;   contains a list of calOn scans to process. In this case the sl argument
;   is ignored. To speed up the i/o you can still scan the file and 
;   pass the scan list in as slar=slar keyword
;
;   Only process cal pair that starts with calOnSCan=517500001L
;
;   sl=getsl(lun)                   ; this is optional 
;   scanOn=517500001l
;   ncal=pfcalonoff(lun,junk,pfcalI,scanOnAr=scanOn,/blda,verb=-1,slar=sl)
;
;-
function pfcalonoff,lun,sl,pfcalI,han=han,scanOnAr=scanOnAr,slar=slar,_extra=e
;
    useScanAr=(n_elements(scanOnAr) gt 0)
    npairs=(useScanAr)?n_elements(ScanOnAr) : corfindpat(sl,indar,pattype=6)
    if npairs eq 0 then goto,done
;
;   allocate the pfcalI array
;
    maxbrds=8
;    a={ scan  :0L,$;
;            az:0.,$;
;            za:0.,$;
;         nbrds:0 ,$;
;           cfr:fltarr(maxbrds),$; center freq board in Mhz (topocentric)
;            bw:fltarr(maxbrds),$; bandwidth of board Mhz
;          pols:intarr(2,maxbrds),$;[pols,brds] 0==>not used,1==>polA,2--> polB
;        calScl:fltarr(2,maxbrds),$;[pols,brds] Kelvins/corCount
;        calVal:fltarr(2,maxbrds),$;[pols,brds] cal value used in Kelvins
;        tsysOff:fltarr(2,maxbrds) $;[pols,brds] Tsys in Kelvins cal off
;    }
    pfcalI=replicate({corcalpf},npairs)
    igot=0
    for ipair=0,npairs-1 do begin
        ok=0
;
;   input data, compute the cals
;
        if (useScanAr) then begin
            istat=corinpscan(lun,b,/sum,han=han,slar=slar,$
                             scan=scanOnAr[ipair])
            if istat eq 1 then begin
                istat=corinpscan(lun,boff,/sum,han=han,slar=slar); next is off
            endif
            if istat eq 0 then begin        
                print,'i/o error.. skipping scan:',sl[ii].scan
                goto,botloop
            endif
            istat=corcalcmp(b,boff,calscl,calValAr=calValAr,$
                tsys=tsys,_extra=e)
        endif else begin
            ii=indar[ipair]
            nOn =sl[ii].numrecs     ;numrecs cal on
            ntot=2*non
            istat=corgetm(lun,ntot,b,scan=sl[ii].scan,han=han)  ; get the data
            if istat eq 0 then begin
                print,'i/o error.. skipping scan:',sl[ii].scan
                goto,botloop
            endif
            istat=corcalcmp(b[0:nOn-1],b[non:*],calscl,calValAr=calValAr,$
                tsys=tsys,_extra=e)
        endelse
        if istat eq 0 then begin
            print,'error computing cal corcalcmp.. skipping scan:',$
                        b[0].b1.h.std.scannumber
            goto,botloop
        endif
;
;   load the data 
;   
        nbrds=b[0].b1.h.cor.numbrdsused
        pfcalI[igot].scan =b[0].b1.h.std.scannumber
        pfcalI[igot].az   =b[0].b1.h.std.azttd*.0001
;
;   note assumes dome za..
;
        pfcalI[igot].za   =b[0].b1.h.std.grttd*.0001
        pfcalI[igot].nbrds=nbrds
        pfcalI[igot].calScl[*,0:nbrds-1]=calScl
        pfcalI[igot].calVal[*,0:nbrds-1]=calValAr
        pfcalI[igot].tsys[*,0:nbrds-1]  =tsys[*,*,1]
        for ibrd=0,nbrds-1 do begin
            pfcalI[igot].pols[*,ibrd]=b[0].(ibrd).p
            pfcalI[igot].cfr[ibrd]=corhcfrtop(b[0].(ibrd).h)
            bw=b[0].(ibrd).h.cor.bwnum
            bw=(bw eq 0)?100.:50./(2^(bw-1))
            pfcalI[igot].bw[ibrd]=bw
        endfor
        igot=igot+1
botloop:
    endfor
done:
    if igot ne npairs then begin
        pfcalI=(igot eq 0)?'' : pfcalI[0:igot-1]
    endif
    return,igot
end
