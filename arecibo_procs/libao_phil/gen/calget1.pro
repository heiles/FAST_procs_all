;+
;NAME:
;calget1 - return the cal value given rcvr,frq,type.
;
;SYNTAX: stat=calget1(rcvrNum,caltype,freq,calval,date=date,hybrid=hybrid, 
;                     fname=fname,swappol=swappol) 
;
;ARGS:
;     rcvrNum: int receiver number 1..16 (see helpdt feeds).
;     calType: int type of cal used 0 through 7.
;                  0-lcorcal,1-hcorcal,2-lxcal,3-hxcal,
;                  4-luncorcal,5-huncorcal,6-l90cal,7-h90cal 
;     freq[n]: float  freq in Mhz for cal value.
;KEYWORDS:
;    date[2]: int  [year,daynumber] data for calvalue. Default is the
;                  current date.
;     hybrid:      if set then a hybrid was in use and the cal values should
;                  be averaged together.
;   fname:string use an alternative filename for cal data.
; swappol:         if set then swap the polA, polB calvalues on return.
;                  This can be used to correct for the 1320 hipass
;                  polarization cable switch or a xfer switch.
; alfaBmNum:       0..6. If alfa receiver then only return cal values
;                  for this beam number. The default is all 6 beams.
;RETURNS:
;calval[2,n]: float .. calValues in deg K for polA,polB
;                    Note if this is alfa, then [2,7] value are returned
;                    for the 7 pixels..
;     stat: int   .. -1 error, 1 got the values ok.
;
;DESCRIPTION:
;   Return the cal values in degrees K for the requested reciever, caltype,
;and frequency. This routine always returns 2 (or 2x7) values: pola, and polB.
;
;   The calvalues for the receiver in use are looked up and then the
;values are interpolated to the observing frequency.
;
;EXAMPLES:
;   Get the cal values for lbw (rcvrNum=5) using the high correlated cal 
;(caltype=1) at 1400. Mhz.
;   stat=calget1(5,1,1400.,calval)
;
;NOTE:
;   Some cals have measurements at a limited range of frequencies (in some
;cases only 1 frequency). If the requested frequency is outside the range
;of measured freqeuncies, then the closest measured calvalue is used 
;(no extrapolation is done).
;   If you have a datatking header, you can use calget(). It will 
;take the rcvrNum, and caltype,  from the header.
;
;SEE ALSO:calget, calval, calinpdata, corhcalval
;-
function calget1,rfnum,calnum,freq,calValL,date=date,hybrid=hybrid,$
            fname=fname,swappol=swappol,alfaBmNum=alfaBmNum
;
; return the cal value for this freq
; retstat: -1 error, ge 0 ok
;
    forward_function iflohrfnum,iflohcaltype,calval,iflohlbwpol
    common cmcorcaldat,cmcorcaldat
     
    useAlfa=rfnum eq 17
	calValL=fltarr(2)	; incase error exit

;    rfnum =iflohrfnum(hdr.iflo)     ; get rcvr number
;    calnum=iflohcaltype(hdr.iflo)
    rdfile=(n_elements(cmcorcaldat) eq 0 ) or (n_elements(fname) ne 0)
    if n_elements(hybrid) eq 0 then hybrid=0
    if n_elements(date) eq 2 then begin
        year  =date[0]
        dayNum=date[1]
    endif else begin
          a=bin_date()
          year  =a[0]
          dayNum=dmtodayno(a[2],a[1],a[0])
    endelse
    if (not rdfile) then begin
       if  (cmcorcaldat.rcvnum ne rfnum)  or $
           (cmcorcaldat.calnum ne calnum) or $

           ((cmcorcaldat.startYr  gt year) or $
            (cmcorcaldat.endYr    lt year) or $

            ((cmcorcaldat.startYr eq year) and $
             (cmcorcaldat.startDaynum gt dayNum)) or $

            ((cmcorcaldat.endYr eq year) and $
             (cmcorcaldat.endDaynum le dayNum)) ) then rdfile=1
    endif
    if (rdfile) then begin
        datel=[year,dayNum]
        if  calinpdata(rfnum,calnum,cmcorcaldat,date=datel,fname=fname)$
                lt 1 then return,-1
    endif

;    hybrid=0
;    if iflohlbwpol(hdr[0].iflo) eq 1 then hybrid=1
    if (calval(freq,cmcorcaldat,calValL,hybrid=hybrid,swappol=swappol,$
			   alfaBmNum=alfaBmNum) lt 0 ) $
                then return,-1
    return,1
end
