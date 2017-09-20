;+
;NAME:
;tecver - convert from slant to vertical tec
;SYNTAX: tecv=tecver(tAr,Hght,oblAng=oblang,freg=freg,ereg=ereg);
;ARGS:
;   tar[n]: {}    array of tec structures from tecget
;   hght  : float the height in the atmosphere for the vertical measure
;                  (units are kilometers).
;KEYWORDS:
;freg     :      if set, ignore altitude, use hght of 350 km.
;ereg     :      if set, ignore altitude, use hght of 110 km.
;RETURNS;
;tecv[n]  : float    the vertical tec
;oblAng[n]: float    the obliquity angle for each tec value used for the 
;                    correction.
;DESCRIPTION:
;   Compute the obliquity angle:
;   oblAng=(Re + Hght) / (sqrt((Re + Hght)^2 - (Re*cos(el))^2)
;   
;   where:
;     Re is the radius of the earth : 6376.5 meters (from tempo).
;   Hght is the atmospheric height passed in (in km).
;   el   is the elevation of the satellite from ao for each sample. 
;
; The corrected tec is then
;  tecV= tecS/oblAng
;-
function tecver,tAr,Hght,oblAng=oblAng,freg=freg,ereg=ereg
;
    case 1 of 
        keyword_set(freg): hghtL=350.
        keyword_set(ereg): hghtL=110.
        else             : hghtL=hght 
    endcase
    r3=[2390490.0, -5564764.0,1994727.0]*1e-3; x,y,z geocentric ao from tempo
    radE=sqrt(r3[0]^2 + r3[1]^2 + r3[2]^2)
    oblAng=(RadE + hghtL)/sqrt((radE + hghtL)^2 - (radE*cos(tar.el*!dtor))^2)
    return,tar.tec/oblAng
end
