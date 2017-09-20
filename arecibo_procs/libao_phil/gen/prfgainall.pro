;+
;NAME:
;prfgainall- compute fractional gain do to pitch,roll,focus
;SYNTAX: fracgain=prfgainall(az,za,rcvr,pitch,roll,focus,freq=freq,
;                   foctouse=foctouse,rolltouse=rolltouse,pitchtouse=pitchtouse)
;ARGS:   az[npts] - float  azimuth degrees
;        za[npts] - float  za degrees
;        rcvr     : string: lb,sb,cb,xb 1400,2380,5000,10000
;        pitch    : optional arg. return pitch here deg.    
;        roll     : optional arg. return roll  here  deg
;        focus    : optional arg. return focus here  inches
;KEYWORDS:
;            freq : Mhz. if provided, then use the specified rcvr function
;                        and add on the relative difference from  this
;                        and the rcvr default freq.
;   foctouse[npts]: float use this as the focus instead of the model
;   rolltouse[npts]: float use this as the roll instead of the model
;   pitchtouse[npts]: float use this as the pitch instead of the model
;DESCRIPTION:
;   Compute the fractional gain do to the pitch roll and focus. We use:
;1. the pitch,roll,focus fits from feb00 
;2. aoant for pitch,roll
;3. focus curve sband for the loss do to focus
;4. asssume pitch roll error adds in quadrature
;5. assume we multiply the focus loss by pitch,roll loss
;
; before calling this routine do @prfinit
;EXAMPLE:
;   make a plot of gain versus az,za
;   keep za above 2 degrees since za=0 not measured.
;   mkazzagrid,az,za,azstep=10,zastep=1,zastart=2
;   gain=prfgainall(az,za,'sb')
;   stripsxy,az,gain,0,0,/stepcol
;-
;16feb01.. before this there was a bug in the program..
;       .. was using fwhm= (12.31"/1.74) *2. = 14.15" = 35.94cm.
;          correct values is 2Lambda = 25.2 cm 
;          12.31 was from jul99 sband focus curve and it was the 
;          fwhm not the half width.
;         aoant, and the feb01 focus curves both give lambda as the
;         distance to fall 3db or 2lambda for fwhm
;
function prfgainall,az,za,rcvr,pitch,roll,focus,freq=freq,$
        foctouse=foctouse,rolltouse=rolltouse,pitchtouse=pitchtouse
    c=2D10
    useDefFreq=1
    case 1 of
        (rcvr eq 'lb') or  (rcvr eq 'LB'): begin
            rcvr='lb'   
            lambdaDef=21.
        end
        (rcvr eq 'sb') or  (rcvr eq 'SB'): begin
            rcvr='sb'   
            lambdaDef=12.6
        end
        (rcvr eq 'cb') or  (rcvr eq 'CB'): begin
            rcvr='cb'   
            lambdaDef=6.
        end
        (rcvr eq 'xb') or  (rcvr eq 'XB'): begin
            rcvr='xb'   
            lambdaDef=3.
        end
        else: message,'prfgainall: rcvr is lb,sb, or cb'
    endcase
    if n_elements(freq) gt 0  then begin
        lambda=c/(freq*1D6)
        useDefFreq=0
    endif else begin
        lambda=lambdaDef
        freq=c/lambda*1d-6
    endelse
    forward_function prfit2deval,focerr
;
;   input model
;
;    prfit2dio,prf2d,"/home/online/vw/etc/Pnt/pr.coef",io="read"
    prfit2dio,prf2d
;
;   evaluate at az,za
;
    if n_elements(pitchtouse gt 0) then begin
        pitch=pitchtouse
    endif else begin
        pitch=prfit2deval(prf2d,az,za)
    endelse
    if n_elements(rolltouse gt 0) then begin
        roll=rolltouse
    endif else begin
        roll =prfit2deval(prf2d,az,za,/roll)
    endelse
    if n_elements(foctouse gt 0) then begin
        focus=foctouse
    endif else begin
        focus=focerr(az,za)
    endelse
;
;   combine pitch roll in quadrature
;
    prq= sqrt(pitch*pitch + roll*roll)
;
; focus curve. use 12.31" sband 1/2 width 1/2 max..td inches
; 1.74 td to  platform inches..... still need cos(za) to get to
;  forget about cos za.. avg 10 deg just 2%
;
;   fwhm= 12.31*2./1.74*lambda/12.6 ; linear  in lambda.12.6=sband
;   16feb01 fix..
    fwhm=(2.*lambda)/2.54           ; focerr returns in inches..
    foc=gseval(fwhm,focus)
;
; compute relative gain (linear) do to  pitch,roll
;
    if useDefFreq then begin
        gainprq=prfgain(prq,rcvr=rcvr)
    endif else begin
        gainprq=prfgain(prq,rcvr=rcv,freq=freq)
    endelse
;
; include all three  1 pr * foc
; this is normalized  to 1.
;
    return,gainprq*foc
end
