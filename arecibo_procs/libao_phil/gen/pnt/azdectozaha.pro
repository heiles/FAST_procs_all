;+
;NAME:
;azdectozaha - az,decCur to za,hour angle conversion.
;SYNTAX: istat=azdectozaha(az,dec,za,ha,verbose=verbose)
;ARGS:
;az[n]:  double feed azimuths to use
;dec[n]: double degrees declination to use. Should be current declination.
;
;KEYWORDS:
; verbose: print out the results
;RETURNS:
;istat  :1 if ok,-1 if at least one of the elements of az could not be computed.
;                  eg. you picked az on wrong side of declination
;za[n]  : double zenith angle in degrees
;ha[n]  : double  hour angle in hours.
;
;DESCRIPTION:
;   Where the equations come from:
;
; for spherical triangle let the Angles/Sides be:
; A B C the angles
; a b c the opposing sides
; form the triangle
; a=90-dec   A=az
; b=za       B=hour angle
; c=90-lat   C=parallactic Angle
;
; We are solving for b za and B hour angle. 
; 
; 1. The law of cosines is:
;    cos(a)=cos(b)cos(c) + sin(b)sin(c)cos(A)
; - we need to eliminate cos(b) or sin(b) to solve for za.
;
;2. smart page 10 formula C solve for sin(b)
;   sin(a)cos(C)=cos(c)sin(b) -sin(c)cos(b)cos(A)
;   : sin(b)=( sin(a)cos(C) + sin(c)cos(b)cos(A))/cos(c)
;
;3. insert sin(b) into 1
;
; cos(a)=cos(b)cos(c) + [sin(a)cos(C) + sin(c)cos(b)cos(A)]*sin(c)cos(A)/cos(c)
;
;4. collect cos(b) terms, multiply right side by cos(c)/cos(c)
;
;cos(b)=[cos(a)cos(c) - sin(a)cos(C)sin(c)cos(A)]
;        ------------------------------------------
;        [cos^2(c) + sin^2(c)cos^2(A)]
;
; ----------------------------------------------------------------------
;   substitute 1-sin^2(c) for cos^2(c) -->
;         [1 - sin^2(c)[1-cos^2(A)]]=[1-sin^2(c)sin^2(A)]
;
;cos(b)=[cos(a)cos(c) - sin(a)cos(C)sin(c)cos(A)]
;        ------------------------------------------
;           [1-sin^2(c)sin^2(A)]
; ----------------------------------------------------------------------
; plug in angles, arcs a,b,c from above:
;
;cos(za)=[sin(dec)sin(lat) - cos(dec)cos(PA)cos(lat)cos(az)]
;        ------------------------------------------
;           [1-cos^2(lat)sin^2(az)]
;
; substitute PA
;
; sin(PA)=sin(az)cos(lat)/cos(dec)   .. from law of sines
; cos^2(PA)=1- sin^2(az)cos^2(lat)/cos^2(dec)
; def sq:
; sq = cos^2(PA)cos^2(dec)= cos^2(dec) - sin^2(az)cos^2(lat)
;
;cos(za)=[sin(dec)sin(lat) - sqrt(sq)*cos(lat)cos(az)]
;        ------------------------------------------
;           [1-cos^2(lat)sin^2(az)]
;    check the + and - results from sqrt(). pick za closer to 0.
;
; this matches desh's routine that cima is using..
;
; -->using law of sines to get hour angle
;   sin(ha)/sin(za)=sin(az)/sin(90-dec)
;  fix sign of hour angle so rising is negative
;
;-
;
function azdectozaha,az,dec,za,ha,verbose=verbose,$
            zap=zap,zam=zam,ham=ham,hap=hap
    

; 
    dtorD=!dpi/180D
    aoLatD=18.353806D     ; 18d21'13.7"
    aoLatD=18.353944      ; 18d21'14.2"
    azlRd=(az-180d)*dtorD ; need source azimuth
    aoLatRd=aolatD*dtorD
    decRd=dec*dtorD

    sinLat=sin(aoLatRd)
    cosLat=cos(aoLatRd)
    sinAz =sin(azlRd)
    cosAz =cos(azlRd)
    sindec=sin(decRd)
    cosdec=cos(decRd)
;
    sq=cosdec*cosdec - sinaz*sinaz*coslat*coslat
    n=where(sq lt 0,cnt)
    if (cnt gt 0) then begin
        print,"sq < 0 ",cnt," times in input vector"
        return,-1
    endif
    tmp1=(1D - coslat*coslat*sinaz*sinaz);
    coszaP=(sindec*sinLat - sqrt(sq)*coslat*cosaz)/tmp1
    coszaM=(sindec*sinLat + sqrt(sq)*coslat*cosaz)/tmp1
    zaP=acos(coszaP) / dtorD
    zaM=acos(coszaM) / dtorD
;
;  source in north, cosaz > 0, coszaM larger ==> zaM smaller
;  source in south  cosaz < 0  coszaP larger --> zaP smaller angle
;
;   check for cos -1 to 1
;
    if keyword_set(verbose) then begin
        if verbose gt 1 then begin
        print,"tmp1:",tmp1
        print,"coszaP,zaP:",coszaP, zaP
        print,"coszaM,zaM:",coszaM, zaM
       endif
    endif
;
    za=zaP
    ii=where((zaM gt 0D) and  (zaM lt 20D),cnt)
    if cnt gt 0 then za[ii]=zaM[ii]
    
    sinha=sinAz*sin(za*dtorD)/cosdec
;   print,"sinHa:",sinHa
    ha=asin(sinha)/(dtorD*15D)
    if arg_present(haM) then haM=asin(sinAz*sin(zam*dtorD)/cosdec)/(dtorD*15D)
    if arg_present(haP) then haP=asin(sinAz*sin(zaP*dtorD)/cosdec)/(dtorD*15D)
    if keyword_set(verbose) then begin
        n=n_elements(az)
        for i=0,n-1 do begin
        ln=string(format=$
'("srcAz:",f6.1," decD:",f4.1," za:",f5.1," ha:",f4.1," PAd:",f5.1)',$
        az[i]-180.,dec[i],za[i],ha[i],asin((sinaz[i]*coslat)/cosDec[i])*!radeg)
        print,ln
        endfor
    endif
    return,1
end
