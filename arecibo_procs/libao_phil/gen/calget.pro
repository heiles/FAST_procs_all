;+
;NAME:
;calget - return the cal value given hdr,freq.
;
;SYNTAX: stat=calget(hdr,freq,calval,date=date,swappol=swappol)
;
;ARGS:
;      hdr: {hdr}  header holding at least hdr.iflo
;  freq[n]: float  freq in Mhz for cal value.
;KEYWORDS:
;  date[2]: int    [year,daynumber] epoch for cal value. 
;                  Default is the date in the header.
;  swappol:        If set then swap the polA polB calvalues. This
;                  can be used to correct the 1320 hipass polarization 
;                  problem, or to compensate for a xfer switch being
;                  used.
;
;RETURNS:
;calval[2,n]: float  cal values in deg K for polA,polB. if alfa then it returns
;                    calval[2,7,n]
;     stat: int     -1 error, 1 got the values ok.
;
;DESCRIPTION:
;   Return the cal values in degrees K for the requested freq. The hdr can be
;a correlator or ri header (as long as it includes hdr.iflo). This 
;routine always returns 2 values: pola, and polB.
;
;   The calvalues for the receiver in use are looked up and then the
;values are interpolated to the observing frequency.
;
;NOTE:
;   Some cals have measurements at a limited range of frequencies (in some
;cases only 1 frequency). If the requested frequency is outside the range
;of measured freqeuncies, then the closest measured calvalue is used 
;(no extrapolation is done).
;   hdr should be a single element rather than an array.
;   This routine extracts info from the header and then calls calget1().
;
;SEE ALSO:calget1, calval, calinpdata, corhcalval
;-
; 25jun09.. return value was not being passed back correctly
;
function calget,hdr,freq,calval,date=date,swappol=swappol
;
; return the cal value for this freq
; retstat: -1 error,  1 ok
;
    forward_function iflohrfnum,iflohcaltype,calval,iflohlbwpol,calget1
;    common cmcorcaldat,cmcorcaldat
     
    calVal=fltarr(2)               ; return polA,b here
    useCh= (pnthgrmaster(hdr[0].pnt) eq 0)
    if useCh then begin
        rfnum = 100
        calnum=5                    ; hcal
        hybrid=0
    endif else begin
        rfnum =iflohrfnum(hdr.iflo)     ; get rcvr number
        calnum=iflohcaltype(hdr.iflo)
        hybrid=0
        if iflohlbwpol(hdr[0].iflo) eq 1 then hybrid=1
    endelse
    if n_elements(date) eq 0 then begin     
        year  =hdr[0].std.date / 1000L 
        daynum=hdr[0].std.date mod 1000L
        date=[year,daynum]
    endif
    if rfnum eq 17 then alfaPix=(hdr[0].cor.boardid-1)  mod 8
    istat=calget1(rfnum,calnum,freq,calval,hybrid=hybrid,date=date,$
                   swappol=swappol)
	return,istat
end
