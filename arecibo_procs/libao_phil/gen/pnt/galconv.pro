;+
;NAME:
; galconv - convert between J2000 and galactic LII,BII.
;SYNTAX:  galconv,c1In,c2In,c1Out,c2Out,conv=conv,hms=hms,deg=deg,usened=usened
;ARGS:
;     c1In[n] : double coord 1 In: gal l (def) or (ra) input
;     c2In[n] : double coord 2 In: gal b (def) or (dec) input
;    c1Out[n] : double coord 1 Out: ra (def) or (gal l) output
;    c2Out[n] : double coord 2 Out: dec (def) or (gal b) output
;
;KEYWORDS:
;   togal:  By default the routine inputs galactice l,b and outputs 
;           ra,dec. If /togal is set then the routine takes ra,dec as
;           input and outputs gal l,b
;     rad:  By default the input/output parameters are in degrees. If rad
;           is set then the input parameter should be radians, and the
;           output parameters will be radians.
;
; DESCRIPTION
;
; Transform from  galactic l,b to J200 ra,dec. If the keyword /togal is
;set then convert from ra,dec J2000 to l,b. By default the input and output
;parameters are in degrees. If the /rad keyword is set then the input
;and output will be in radians.
;
;   The position for the galactic pol is
;NOTE:... THIS DOES NOT WORK YET. I'VE GOT 1 MORE ROTATION TO FIGURE OUT..
;positions of galatic pole, center taken from ned
;lb      ra           dec               ra            dec
;(0,0)  266.40506655,-28.93616241 or (17:45:37.21597,-28:56:10.1847)
;(0,90) 192.85949646,27.12835323  or (12:51:26.2791f, 27:07:42.0716) 
;-
pro   galconv,c1in,c2in,c1out,c2out,togal=togal,rad=rad,usened=usened
; 
;
;   convert galactic angles to ra/dec J2000 angles. 
;   stolen from idl goddard routine euler..
;
;
    twopi   =   2.0d*!DPI
    fourpi  =   4.0d*!DPI
    deg_to_rad = !DPI/180.0d
    rad_to_deg = 180.0d/!DPI

;
;   from ned
;
    if keyword_set(usened) then begin
        raGalOrig =266.40506655D
        decGalOrig=-28.93616241D
        raGalPol  =192.85949646D
        decGalPol = 27.12835323D
;
;
;    let a=arc,A be opposite angle
;    sin(a) sin(b)
;   ------==------
;    sin(A) sin(B)
;
;    a=decGalOrig
;    A=angle gal plane with eq plane
;    b=gal long of equatorial plane
;    B=90
;
        thetaRd = (decGalPol-90.D)*deg_to_rad
        galLonEqPlaneRd= asin(sin(deg_to_rad*decGalOrig)/$
                           sin(thetaRd))

        psi   = (raGalPol + 90.D)*deg_to_rad ; psi  =282.85946 deg (192+90)
        stheta= sin(thetaRd)            ; theta=-62.871747 (27-90)
        ctheta= cos(thetaRd)            ; 
        phi   = galLonEqPlaneRd         ; phi  = 32....
    endif else begin
;
;   J2000 coordinate from euler are based on the following constants
;   (see the Hipparcos explanatory supplement).
;  alphaG = 192.85948d               Right Ascension of Galactic North Pole
;  deltaG = 27.12825d                Declination of Galactic North Pole
;  lomega = 32.93192d                Galactic longitude of celestial equator

        psi   = 4.9368292465D       ; 282.85948=192.85948d +90.
        stheta=-0.88998808748D      ; theta=-62.871750 = 27.12825d -90.
        ctheta= 0.45598377618D
        phi   = 0.57477043300D      ; 32.93192
    endelse
;
; position differences..
; ned-euler asecs
; raGalPol    :  0.059256
; decGalPol   :   .37163  
; GalLongCelEq:   .0746
;
    if keyword_set(rad) then begin
        a=c1in - phi 
        b=double(c2in)
    endif else begin
        a=c1in*deg_to_rad - phi
        b=c2in*deg_to_rad 
    endelse
;
    sb=sin(b) 
    cb=cos(b)
    cbsa=cb*sin(a)
    b=-stheta*cbsa + ctheta*sb
    a=atan(ctheta*cbsa +stheta*sb, cb*cos(a))
    if (keyword_set(rad)) then begin
        c1out=(a+psi + fourpi) mod twopi
        c2out=asin((b<1.0d))
    endif else begin
        c1out=((a+psi + fourpi) mod twopi)*rad_to_deg
        c2out=asin((b<1.0d))* rad_to_deg
    endelse
    return
end
