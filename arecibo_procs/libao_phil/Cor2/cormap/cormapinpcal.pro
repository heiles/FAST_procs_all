;+ 
;NAME:
;cormapinpcal - process a cal on/off for cormapinp
;SYNTAX: stat=cormapinpcal(lun,b,calAr,brdIndA,brdIndB,calrec,totcals,stripNum,
;                          rdrec=rdrec,han=han)
;ARGS:
;   lun  :  int     unit number assigned to file to read.
;   b    : {corget}   optional. calOn rec if already read in.
;brdIndA : int      board index to process for polA count(0..3)
;brdIndb : int      board index to process for polB count(0..3)
;calrec  : int      index into calAr[] to place this cal data
;                   If sucessful, this variable gets incremented on return.
;totcals : int      total number of cals that will be placed in calAr.
;                   On the first cal with calrec=0, totcals is used
;                   to initially allocate calAr[totcals].
;stripNum: int      the strip number for this cal (count from 1)
;KEYWORDS: rdrec    if set, then the cal on rec should be read from
;                   the current location of lun and placed in b. If rdrec
;                   is not set, then the user has already read the
;                   the calon rec and it is passed in via b.
;     han:          if set and returning calrecs, hanning smooth the
;                   cal spectra.
;RETURNS:
;stat    :  int     1 successful, 0 error.
;calAr[n]: {calstr} array holding calinfo for each strip of map.
;                   The data for the current cal will be stored in
;                   calar[calrec] (before calrec is incremented).
;calrec  : int      will be incremented on successful return. This keeps
;                   track of where the next cal will go in calAr.
;b       :{corget}  If rdrec is not set, then the calOn rec is returned
;
;DESCRIPTION:
;   This routine is normally called by cormapinp. It will process the 
;next calonoff pair of scans. If rdrec is set,
;then lun should point to the calOnRec. If rdrec is not set, then the
;cal on rec should already have been read into the variable b and lun
;should point at the cal off rec.
;   The routine calls corcalonoffrec(). It loads the cal results in
;the strcuture calAr[calrec]. Calrec is then incremented.
;-
;modhistory
;31jun00 - checked for corget change.. no mods
;02feb04 - if version le 5.3 need to move the bon,boff to b separately..
function cormapinpcal,lun,b,cals,ipa,ipb,calrec,totcals,stripNum,$
                rdrec=rdrec,han=han

    if not keyword_set(han) then han=0
    if keyword_set(rdrec) then begin
        istat=corget(lun,b,han=han)
        if istat ne 1 then begin
            print,"error inputing cal strip:",stripNum
            return,0
        endif
        point_lun,-lun,calOffStart
    endif
    if (corcalonoff(lun,calDat,b)) eq 0 then begin
        print,"error processing calonoff, strip:",stripNum
        return,0
    endif
    print,'calOn:          scan:',b[0].b1.h.std.scannumber
;    if  (n_elements(cals) eq 0)  then begin
     if  (not keyword_set(cals) )  then begin
            cals=replicate(caldat[0],totcals)
    endif
    cals[calrec].h=caldat[ipa].h
    if ipa eq ipb then begin
        cals[calrec].calval=caldat[ipa].calval
        cals[calrec].calscl=caldat[ipa].calscl
    endif else begin
        cals[calrec].calval[0]  =caldat[ipa].calval[0]
        cals[calrec].calscl[0]  =caldat[ipa].calscl[0]
        if (b.(ipb).p[0] eq 2) then begin
            i=0
        endif else begin
            if (b.(ipb).p[1] eq 2) then begin
                 i=1
            endif else begin
                print,'cormapinpcal..error: sbc',ipb+1,'does not have polB info'
                return,0
            endelse
        endelse
        cals[calrec].calval[1]      =caldat[ipb].calval[i]
        cals[calrec].calscl[1]      =caldat[ipb].calscl[i]
        cals[calrec].h.cor.calon[1] =caldat[ipb].h.cor.calon[i]
        cals[calrec].h.cor.caloff[1]=caldat[ipb].h.cor.caloff[i]
        cals[calrec].h.cor.lag0pwrratio[1]=caldat[ipb].h.cor.lag0pwrratio[1]
    endelse
;   print,"dbg:",calrec,cals[calrec].calscl,caldat[ipa].calscl
    if keyword_set(rdrec) then begin
        point_lun,lun,calOffStart
        istat=corget(lun,boff,han=han)
        if istat ne 1 then begin
            print,"error inputing cal off strip:",stripNum
            return,0
        endif
        if !version.release le '5.3' then begin
            bb=corallocstr(b,2)
            corstostr,b,0,bb
            corstostr,boff,1,bb
            b=bb
        endif else begin
            b=[b,boff]
        endelse
    endif
    calrec=calrec+1
    return,1
end
