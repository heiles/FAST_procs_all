;+
;prfit2d - 2d fit (az,za) to pitch,roll data
;
;SYNTAX:
;     prfit2d,az,za,pitch,roll,version,prfit2d
;
;ARGS:
;     az    - []  azimuth values (degrees)
;     za    - []  za values (degrees)
;     pitch - []  measured pitch values.
;     roll  - []  measured roll values.
;
;RETURNS:
;     prfit2d - {prfit2d} - return structure with pitch, roll fit
;				see ~phil/idl/h/hdrTilt.h for a description
;COMMON BLOCKS:
;	prfit2d 	holding prfit2d_azza. This is an array of the az,za values
;				that are passed indirectly to prfit2dFunc via svdfit
;DESCRIPTION:
;   fit P(az,za) and R(az,za) using the measured pitch,roll and the
; idl routine svdfit.
;The input values should be a 1-d array (float or double). The fit is
;done in double precision. The current fitting function is stored in 
; prfit2dFunc.pro. It consists of:
;
; c0 + c1*sin(az) + c2*cos(az)  + c3   *sin(3az) + c4   *cos(3az) +
;                                 c5*za*sin(3az) + c6*za*cos(3az) +
;                                 c7*za*sin(4az) + c8*za*cos(4az) +
;                                 c9*za*sin(6az) + c10*za*cos(6az) +
;
;    + c11*zaM    + c12*zaM^2  + c13*zaM^3 + c14*zaM^4 + c15*zaM^5
;    + c16*zaM^6  + c17*zaM^7  + c18*zaM^8 + c19*zaM^9 + c20*zaM^10
;    + c21*zaM^11 + c22*zaM^12 + c23*zaM^13 
;
; where zaM = (za-10.)/4. 
;
; The Acos(x) + Bsin(x) fit pairs are converted to:
;   A'*sin(x - phase)  via:
;
; Asin(wt-phi)= Asin(wt)cos(phi) - Acos(wt)sin(phi) =  Bsin(wt) + Ccos(wt)
;      B=Acos(phi)
;      C=-Asin(phi)
;    phi      = atan(sin(phi)/cos(phi))/ = atan(-c,b)
;    amplitude=sqrt(B^2+C^2)
;
;
; The fit values are returned in {prfit2d} (see ~phil/idl/h/hdrTilt.h).
; The fit can be evaluated using prfit2deval().
;
;SEE ALSO:
; prfit2dFunc, prfit2deval
;-
;23jan02 added za*4az,za*6az
;	  
pro prfit2d,az,za,p,r,version,prfit2d
;
	forward_function prfit2dFunc
    common prfit2d ,prfit2d_azza
    sng=0
;
;   pitch
;
	prfit2d={prfit2d}
	prfit2d.zaPolyMin=10.D 	; must also update in prfit2dfunc
	prfit2d.zaPolyDiv=4.D   ; ditto
    prfit2d.zaPolyDeg=13L   ; ditto
    prfit2d.version=version ; ditto
    len=((size(az))[1])
	prfit2d_azza=replicate({prazza},len)

    prfit2d_azza.azrd=double(az*!dtor)
    prfit2d_azza.za  =double(za)
    x=dindgen(len)
    numparms=24
;
; 	use pp version since  > 32k points
;    A=SVdfitpp(x,p,numparms,function_name='prfit2dFunc',/double,singular=sng)
     A=SVdfit(x,p,numparms,function_name='prfit2dFunc',/double,singular=sng)
;
    if  sng ne 0 then  print,"svdfit returned singularity fitting pitch"
;
;   move to prfit2d struct
;
    prfit2d.p.c0   = a[0]         ; constant term
;
    prfit2d.p.az1Ph=(atan(-a[2],a[1]))
    if prfit2d.p.az1Ph lt 0 then prfit2d.p.az1Ph=prfit2d.p.az1Ph + 2.*!pi
    prfit2d.p.az1A  =sqrt(a[1]*a[1]+a[2]*a[2])
;
    prfit2d.p.az3Ph =(atan(-a[4],a[3]))
    if prfit2d.p.az3Ph lt 0 then prfit2d.p.az3Ph=prfit2d.p.az3Ph + 2.*!pi
    prfit2d.p.az3A =sqrt(a[3]*a[3]+a[4]*a[4])
;
    prfit2d.p.za3Ph =(atan(-a[6],a[5]))
    if prfit2d.p.za3Ph lt 0 then prfit2d.p.za3Ph=prfit2d.p.za3Ph + 2.*!pi
    prfit2d.p.za3A =sqrt(a[5]*a[5]+a[6]*a[6])
;
    prfit2d.p.za4Ph =(atan(-a[8],a[7]))
    if prfit2d.p.za4Ph lt 0 then prfit2d.p.za4Ph=prfit2d.p.za4Ph + 2.*!pi
    prfit2d.p.za4A =sqrt(a[7]*a[7]+a[8]*a[8])
;
    prfit2d.p.za6Ph =(atan(-a[10],a[9]))
    if prfit2d.p.za6Ph lt 0 then prfit2d.p.za6Ph=prfit2d.p.za6Ph + 2.*!pi
    prfit2d.p.za6A =sqrt(a[9]^2+a[10]^2)
;
;   and the za terms
;
    for i=0,prfit2d.zaPolyDeg-1 do begin
        prfit2d.p.czapoly[i]=a[i+11]
    endfor
;
;   roll
;
;    A=SVdfitpp(x,r,numparms,function_name='prfit2dFunc',/double,singular=sng)
     A=SVdfit(x,r,numparms,function_name='prfit2dFunc',/double,singular=sng)
;
    if  sng ne 0 then  print,"svdfit returned singularity fitting roll"
;
;   move to prfit2d struct
;
    prfit2d.r.c0   = a[0]         ; constant term
;
    prfit2d.r.az1Ph=(atan(-a[2],a[1]))
    if prfit2d.r.az1Ph lt 0 then prfit2d.r.az1Ph=prfit2d.r.az1Ph + 2.*!pi
    prfit2d.r.az1A  =sqrt(a[1]*a[1]+a[2]*a[2])
;
    prfit2d.r.az3Ph =(atan(-a[4],a[3]))
    if prfit2d.r.az3Ph lt 0 then prfit2d.r.az3Ph=prfit2d.r.az3Ph + 2.*!pi
	    prfit2d.r.az3A =sqrt(a[3]*a[3]+a[4]*a[4])
;
    prfit2d.r.za3Ph =(atan(-a[6],a[5]))
    if prfit2d.r.za3Ph lt 0 then prfit2d.r.za3Ph=prfit2d.r.za3Ph + 2.*!pi
    prfit2d.r.za3A =sqrt(a[5]*a[5]+a[6]*a[6])
;   
    prfit2d.r.za4Ph =(atan(-a[8],a[7]))
    if prfit2d.r.za4Ph lt 0 then prfit2d.r.za4Ph=prfit2d.r.za4Ph + 2.*!pi
    prfit2d.r.za4A =sqrt(a[7]*a[7]+a[8]*a[8])
;
;   za*6az
    prfit2d.r.za6Ph =(atan(-a[10],a[9]))
    if prfit2d.r.za6Ph lt 0 then prfit2d.r.za6Ph=prfit2d.r.za6Ph + 2.*!pi
    prfit2d.r.za6A =sqrt(a[9]^2+a[10]^2)
;
;   and the za terms
;
    for i=0,prfit2d.zaPolyDeg-1 do begin
        prfit2d.r.czapoly[i]=a[i+11]
    endfor
    return
end
