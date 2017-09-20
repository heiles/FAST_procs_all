;corhdrq - functions to query header info:
;         bitmasks in correlator header.  
;         frequecies..
;         calonoff..
;          each routine takes as input a single correlator header,or std
;modhistory
;31jun00 - updated to new corget format
;22nov01 - added corhgainget()
;16dec02 - corhgainget() was using current date if date= keyword not supplied
;03jan03 - corhcfrtop(),corhflipped now work with arrays of arbitray headers
;*****************************************************************************
;+
;NAME:
;corhflipped - check if current data is flipped in freq.
;SYNTAX: stat=corhflipped(corhdr)
;ARGS:
;   corhdr[]: {corhdr} to check.
;RETURNS:   istat- 0 increasing frq, 1- decreasing freq order.
;             if corhdr[] is an array then istat will be an array of ints.
;DESCRIPTION:
;   Check if the correlator data for this sbc is stored in increasing
;or decreasing frequency order (even or odd number of high side lo's).
;EXAMPLE:
;   check first board: istat=corhflipped(b.b1.h.cor)
;-
function corhflipped,corh
    on_error,2
    if n_elements(corh) gt 1 then begin
        ind=where((corh.state and '00100000'XL) ne 0,count)
        val=intarr(n_elements(corh))
        if count gt 0 then val[ind]=1
        return,val
    endif else begin
        if ((corh.state and '00100000'XL) ne 0 ) then return,1 else return,0
    endelse
end
;*****************************************************************************
;+
;NAME:
;corhcfrtop - return the topocentric freq of band center.
;SYNTAX: cfr=corhcfrtop(hdr)
;ARGS:
;    hdr: {hdr}  .. header for board to check
;RETURNS:
;    cfr: double .. center freq of band in Mhz
;DESCRIPTION:
;   Return the topocentric rf center of the band for the requested board.
;hdr can be an array of hdrs but they must all come from the same
;board. eg b[].b1.h
;
;EXAMPLE:
;   get the freq of the 2nd board: cfrMhz=corhcfrtop(b.b2.h)
;-
;17sep00 - change to work on arrays as long as they are from the same
;          sbc.
function corhcfrtop,hdr
;
; return the topocentric frequency for the band center
;
    forward_function dophsball
;    brdInd =hdr[0].std.grpCurRec -1      ; for synth offsets..index to use...
    brdInd =hdr.std.grpCurRec -1      ; for synth offsets..index to use...
    ind=where(brdind gt 3,count)
    if count gt 0 then brdind[ind]=0    ; FIX when 8 synths..
    ind=dophsball(hdr.dop)               ; 1 sball , 0 rf only
    ind0=where(ind eq 0,count0)          ; rfonly
    ind1=where(ind eq 1,count1)          ; sball
;
;   ind=1 --> sball , 0--> cfr only
;
    cfrTopMhz=hdr.dop.freqBCRest        ; create the array
    if (count1 gt 0) then begin         ; (rest*offset)*doppler
        cfrTopMhz[ind1]=hdr[ind1].dop.factor * $
            (hdr[ind1].dop.freqBCRest + hdr[ind1].dop.freqOffsets[brdInd])
    endif
    if (count0 gt 0) then begin         ; (rest*doppler)+ offset
        cfrTopMhz[ind0] = hdr[ind0].dop.freqBCRest*hdr[ind0].dop.factor + $
                    hdr[ind0].dop.freqOffsets[brdInd]
    endif
    return,cfrTopMhz
end
;*****************************************************************************
;+
;NAME:
;corhcfrrest - return the rest freq of band center.
;SYNTAX: cfr=corhcfrrest(hdr)
;ARGS:
;    hdr: {hdr}  .. header for board to check
;RETURNS:
;    cfr: double .. rest center freq of band in Mhz
;DESCRIPTION:
;   Return the rf rest frequency for the band center of the requested board.
;EXAMPLE:
;   get the rest freq of the 3nd board: cfrMhz=corhcfrrest(b.b3.h)
;-
function corhcfrrest,hdr
;
; return the rest frequency for the band center
;
    forward_function dophsball
    brdInd =hdr.std.grpCurRec -1      ; for synth offsets..index to use...
    ind=dophsball(hdr.dop)               ; 1 sball , 0 rf only
    ind0=where(ind eq 0,count0)          ; rfonly
    ind1=where(ind eq 1,count1)          ; sball
    cfrRestMhz=fltarr(n_elements(hdr))
    if count1 gt 0 then begin   ; doppler correct all sub bands
        cfrRestMhz[ind1]=hdr[ind1].dop.freqBCRest + $
                         hdr[ind1].dop.freqOffsets[brdInd]
    endif 
    if count0 gt 0 then begin
        cfrTopMhz = hdr[ind0].dop.freqBCRest*hdr[ind0].dop.factor + $
                    hdr[ind0].dop.freqOffsets[brdInd]
        cfrRestMhz[ind0]=cfrTopMhz/hdr[ind0].dop.factor; back to cfr rest frame
    endif
    return,cfrRestMhz
end
;*****************************************************************************
;+
;NAME:
;corhcalval - return the pol A/B  cal values for a sbc.
;
;SYNTAX: stat=corhcalval(hdr,calval,date=date,swappol=swappol)
;
;ARGS:
;     hdr: {hdr}    header for board to check
;
;KEYWORDS:
; date[2]: intarray [year,dayNum] if provided, then compute the calvalues
;                      that were valid at this epoch.
; swappol:          if set then swap the pola,polb cal values. This can
;                   be used to correct for the 1320 hipass cable switch
;                   problem or the use of a xfer switch in the iflo.
;
;RETURNS:
; calval[2]: float .. calValues in deg K for polA,polB
;      stat: int   .. -1 error, 1 got the values ok.
;
;DESCRIPTION:
;   Return the cal values in degrees K for the requested sbc. This 
;routine always returns 2 values (polA then polB) even if the header
;is for a board that uses only one polarization.
;   The calvalues for the receiver in use are looked up and then the
;values are interpolated to the observing frequency.
;
;EXAMPLE:
;   input a correlator record and then get the calvalues for the 
;   3rd correlator board:
;   print,corget(lun,b)
;   istat=corhcalval(b.b3.h,calval)
;   .. calval[2] now has the cal values in degrees K for polA and polB.
;
;NOTE:
;   Some cals have measurements at a limited range of frequencies (in some
;cases only 1 frequency). If the frequency is outside the range of measured
;frequencies, then the closest measured calvalue is used (there is no 
;extrapolation).
;   The year daynum from the header is used to determine which set of
;calvalue measurements to use (if the receiver has multiple timestamped
;sets).
;
;   This routine computes the frequency of the sbc from hdr and then calls
;calget(). 
;
;SEE ALSO:
;gen/calget gen/calval.pro, gen/calinpdata.pro
;-
;history: 
; 19jan01 - udpated to use date in the request.. 
;
function corhcalval,hdr,calval,date=date,swappol=swappol
;
; return the cal value for this board
; retstat: -1 error, ge 0 ok
;
    cfr=corhcfrtop(hdr[0])             ; sub topocentric cfr
    istat=calget(hdr[0],cfr,calVal,date=date,swappol=swappol)
    if istat eq -1 then return,istat
    rfnum =iflohrfnum(hdr[0].iflo)
    if rfnum ne 17 then return,istat
    alfapixL=(hdr[0].cor.boardid-1) mod 7
    calval=reform(calval[*,alfapixL],2)
    return,istat
end
;*****************************************************************************
;+
;NAME:
;corhcalrec- check if an input rec is a cal rec.
;SYNTAX:    istat=corhcalrec(hdr)
;ARGS  :    hdr - header from 1 of the boards
;RETURNS:  istat- 0 not a cal rec, 1-on, 2-off
;DESCRIPTION:
;   Check if a record input is part of a cal record.
;EXAMPLE:
;   corget(lun,b)
;   istat=corhcalrec(b.b1.h)
;-
function corhcalrec,hdr

    if (string(hdr.proc.procname)  ne 'calonoff'  ) and $
       (string(hdr.proc.procname)  ne 'calonoffbl') then  return,0
    if (string(hdr.proc.car[*,0]) eq 'on')       then  return,1
    if (string(hdr.proc.car[*,0]) eq 'off')      then  return,2
    return,0
end
;*****************************************************************************
;+
;NAME:
;corhdnyquist - check if rec taken in double nyquist mode
;SYNTAX:    istat=corhdnyquist(hdr)
;ARGS  :    hdr{} - header from 1 of the boards of the record
;RETURNS:  istat- 0 not taken in double nyquist mode. 
;                 1 taken in double nyquist mode. 
;DESCRIPTION:
;   Check if a record was taken in double nyquist mode.
;EXAMPLE:
;   corget(lun,b)
;   istat=corhdnyquist(b.b1.h)
;-
function corhdnyquist,hdr

    on_error,2
    if ((hdr.cor.state and '00000001'XL) ne 0 ) then return,1 else return,0
    return,0
end
;*****************************************************************************
;+
;NAME:
;corhgainget - return the gain given a header
;
;SYNTAX: stat=corhgainget(hdr,gainval,date=date,az=az,za=za,onlyza=onlyza)
;
;ARGS:
;  hdr[n]: {hdr}    header for board to check
;
;KEYWORDS:
; date[2]: intarray [year,dayNum] if provided, then compute the gain value
;                   at this epoch.
;   az[n]: fltarray If provided, use this for the azimuth value rather than
;                   the header values
;   za[n]: fltarray If provided, use this for the zenith angle values rather
;                   than the header values
;  onlyza:          If set then return the za dependence (average of az)
;RETURNS:
; gainval: float .. gainvalue in K/Jy
;    stat: int   -1 --> error, no data returned
;                 0 --> requested freq is outside freq range of fits.
;                       Return gain of the closed frequency.
;                 1 --> frequency interpolated gain value returned.
;DESCRIPTION:
;   Return the telescope gain value in K/Jy for the requested sbc. 
;The gain fits for the receiver in use are input and then the
;values are interpolated to the az, za and observing frequency.
;   If hdr[] is an array then the following restrictions are:
;   1. each element must be from the same receiver and at the same 
;      frequency (eg. all the records from a single scan).
;   2. If the az,za keywords are provided, they must be dimensioned the same
;      as hdr
;
;EXAMPLE:
;   input a correlator record and then get the gain value for the 
;   3rd correlator board:
;   print,corget(lun,b)
;   istat=corhgainget(b.b3.h,gain)
;   .. gain now has the gain value in K/Jy
;   
;   input an entire scan and compute the gain for all
;   records of 1 sbc. assume 300 records..
;   print,corinpscan(lun,bar)
;   istat=corhgainget(bar.b3.h,gain)
;   gain is now a array of 300 records
;
;NOTE:
;   Some receivers have measurements at a limited range of frequencies (in some
;cases only 1 frequency). If the frequency is outside the range of measured
;frequencies, then the closest measured gain is used (there is no 
;extrapolation in frequency).
;   The year daynum from the header is used to determine which set of
;gain fits to use (if the receiver has multiple timestamped sets).
;   This routine takes the az,za, date, and frequency from the
;header and then calls gainget().
;   If you input an array of corget recs , then they must all be from the
;same sbc.
;
;SEE ALSO:
;gen/gainget gen/gaininpdata.pro
;-
;history: 
; 22nov01 - wrote
; 16dec02 - if date= not supplied, was using the current date instead of 
;           date from header.
;         - rfnum was an array, make it a single element
;
function corhgainget,hdr,gainval,date=date,az=az,za=za,onlyza=onlyza
;
; return the gain value for this board
; retstat: -1 error, ge 0 ok
  forward_function iflohrfnum,corhcfrtop,pnthgrmaster

;
    rfnum =iflohrfnum(hdr[0].iflo)     ; get rcvr number
    cfr   =corhcfrtop(hdr[0])       ; sub topocentric cfr
    if n_elements(az) eq 0 then az    =hdr.std.azTTd*.0001
    if n_elements(za) eq 0 then begin
        if   pnthgrmaster(hdr[0].pnt) then begin
            za=hdr.std.grttd*.0001
        endif else begin
            za=hdr.std.chttd*.0001
        endelse
    endif
    if n_elements(date) eq 2 then begin
        datel=date
    endif else begin
        year  =hdr[0].std.date / 1000
        dayNum=hdr[0].std.date mod 1000
        datel=[year,daynum]
    endelse
    return,gainget(az,za,cfr,rfnum,gainval,date=datel,zaonly=onlyza)
end
;*****************************************************************************
;+
;NAME:
;corhstokes - check if record taken in stokes mode
;SYNTAX:    istat=corhstokes(hdr)
;ARGS  :    hdr{} - header from 1 of the boards of the record
;RETURNS:  istat- 0 not taken in stokes mode. 1-->taken in stokes mode
;DESCRIPTION:
;   Check if a record was taken stokes (polarization) mode.
;EXAMPLE:
;   corget(lun,b)
;   istat=corhstokes(b.b1.h)
;-
function corhstokes,hdr

    on_error,2
;    if ((hdr.cor.state and '20000000'XL) ne 0 ) then return,1 else return,0
    if (hdr[0].cor.numsbcout eq 4) then return,1
    return,0
end

