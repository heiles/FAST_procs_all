;------------------------------------------------------------------------------
;tsAzSwFit - fit to azimuth swings . constant,linear,1az,3az
;
;ARGS  from 1 az swing
;       az - az arrary deg
;       za - single value for this spin (deg)
;       p  - pitch array
;       r  - roll  array
;       azf - return fitdata here .. {azf} struct
;DESCRIPTION:
; fit y= A + B*az + Csin(az-D) + Esin(3az-F)
;
;   result:
;          azf - struct.. see hdrTilt.h in ../h
;
; notes:
; Asin(wt-phi)= Asin(wt)cos(phi) - Acos(wt)sin(phi) =  Bsin(wt) + Ccos(wt)
;      B=Acos(phi)
;      C=-Asin(phi)
;    phi      = atan(sin(phi)/cos(phi))/ = atan(-c,b)
;    amplitude=sqrt(B^2+C^2)
; a[0] - constant
; a[1] - linear deg/rad
; a[2] - B1 sinaz
; a[3] - C1 cosaz
; a[4] - B3 sin3az
; a[5] - C3 cos3az
;
; history:
; 13apr00 - call svdfit with double arg
; 
pro tsAzSwFit,az,za,p,r,azf
;
    sng=0
;
;   pitch
;
    azrd=az*!dtor
    a=svdfit(azrd,p,6,function_name='tsfitfunc',singular=sng,/double)
;
    if  sng ne 0 then  message,"svdfit returned singularity fitting pitch"
;
;   move to azf struct
;
    azf.za     = za
    azf.p.c0   = a[0]         ; constant term
    azf.p.c1   = a[1]*!dtor ; a[1]=deg/rad ..convert  to deg/deg
    azf.p.az1Ph=(atan(-a[3],a[2]))
    if azf.p.az1Ph lt 0 then azf.p.az1Ph=azf.p.az1Ph + 2*!pi
    azf.p.az1A  =sqrt(a[2]*a[2]+a[3]*a[3])
    azf.p.az3Ph =(atan(-a[5],a[4]))
    if azf.p.az3Ph lt 0 then azf.p.az3Ph=azf.p.az3Ph + 2*!pi
    azf.p.az3A =sqrt(a[4]*a[4]+a[5]*a[5])
;
;   roll
;
    a=svdfit(azrd,r,6,function_name='tsfitfunc',singular=sng,/double)
;
    if  sng ne 0 then  message,"svdfit returned singularity fitting roll"
;
;   move to azf struct
;
    azf.r.c0   = a[0]         ; constant term
    azf.r.c1   = a[1]*!dtor ; a[1]=rad/deg ..convert  to deg/deg
    azf.r.az1Ph=(atan(-a[3],a[2]))
   if azf.r.az1Ph lt 0 then azf.r.az1Ph=azf.r.az1Ph + 2*!pi
    azf.r.az1A =sqrt(a[2]*a[2]+a[3]*a[3])
    azf.r.az3Ph=(atan(-a[5],a[4]))
    if azf.r.az3Ph lt 0 then azf.r.az3Ph=azf.r.az3Ph + 2*!pi
    azf.r.az3A =sqrt(a[4]*a[4]+a[5]*a[5])
    return
end
