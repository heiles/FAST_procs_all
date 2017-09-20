;+
;NAME:
;calget1fit - return linear fit to cal values
;
;SYNTAX: stat=calget1fit(rcvrNum,caltype,f1,f2,coefAr,date=date,hybrid=hybrid, 
;                     fname=fname,swappol=swappol) 
;
;ARGS:
;     rcvrNum: int receiver number 1..16 (see helpdt feeds).
;     calType: int type of cal used 0 through 7.
;                  0-lcorcal,1-hcorcal,2-lxcal,3-hxcal,
;                  4-luncorcal,5-huncorcal,6-l90cal,7-h90cal 
;     f1: float    Mhz min freq
;     f2: float    Mhz max freq
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
;coefAr[2,npol=2]: float .. linear fit to polA,polB
;                 Note if this is alfa, then coefAr=[2,npol,7]
;                    value are returned for the 7 pixels unless
;                    alfabmnum is selected.
;     stat: int   .. -1 error, 1 got the values ok.
;
;DESCRIPTION:
;   Return a linear fit to the calvalues between f1 and f2 for the requested
;calType and receiver. The cal value in kelvins could then be computed as:
; CalAK[f]=coefAr[0,0] + coefAr[1,0]*FreqMhz
; CalBK[f]=coefAr[0,1] + coefAr[1,1]*FreqMhz
;
;   If the receiver is alfa then the returned coefs are:
; coefAr[2,npol,nbeams] unless alfaBmNum keyword is used. In that case
;the coef for the single beam are returned.
;
;EXAMPLES:
;   Get the cal values for lbw (rcvrNum=5) using the high correlated cal 
;(caltype=1) between 1300 and 1500 Mhz.
;   stat=calget1fit(5,1,1300,1500,coefAr)
; calAK=poly(findgen(200)+1300),coefAr[*,0])
;
;NOTE:
;
;SEE ALSO:calget, calval, calinpdata, corhcalval
;-
function calget1fit,rfnum,calnum,f1,f2,coefAr,date=date,hybrid=hybrid,$
            fname=fname,swappol=swappol,alfaBmNum=alfaBmNum
;
; return the cal value for this freq
; retstat: -1 error, ge 0 ok
;
    forward_function iflohrfnum,iflohcaltype,calval,iflohlbwpol
    common cmcorcaldat,cmcorcaldat
     
    useAlfa=rfnum eq 17
	coefAr=fltarr(2,2)	; incase error exit

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
    if (calvalfit(f1,f2,cmcorcaldat,coefAr,hybrid=hybrid,swappol=swappol,$
			   alfaBmNum=alfaBmNum) lt 0 ) then return,-1
    return,1
end
