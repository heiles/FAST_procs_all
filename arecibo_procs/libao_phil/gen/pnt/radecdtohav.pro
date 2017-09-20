;+
;NAME:
;radecDtohaV - Current ra/dec Angles to hourAngle/dec V3
;
;SYNTAX: hadecV=radecDtohaV(raRd,decRd,lstRd)
;
;ARGS  :
;  raRd      : float/double. right ascension of date  in radians
; decRd      : float/double. declination of date in radians
; lstRd[npts]: float/double. local sidereal time in radians
;
;RETURNS:
;   haDecV[3,npts]: hour angle/dec 3 vector.
;
;DESCRIPTION
;
; Transform from  from a right ascension (of date) dec system to an
; hour angle dec system. The  inputs are ra,dec angles in radians and
; the local sidereal time in radians.
;
; The ra/dec system is a right handed coordinate system while the ha/dec
; frame is left handed. This requires a rotation and then a reflection
; to change the handedness (the minus sign around the y portion).
; The returned value is the ha dec 3 vector.
;
; RETURNS
; The resulting  haDec 3 vector is returned via the pointer phaDec. The function
; returns void.
;
;SEE ALSO: hadecVtohaV
;-
; mod history 
;   26feb05 - use using first elements of ra,dec for all the elements in
;             the array
function radecdtohaV,raRd,decRd,lstRd
;
     coslst=cos(lstRd);
     sinlst=sin(lstRd);
     v =anglestovec3(raRd,decRd)
     v1=dblarr(3,n_elements(lstRd))
     v1[0,*] =  (  v[0,*]* coslst) + (v[1,*] * sinlst);
     v1[1,*] = -(-(v[0,*]* sinlst) + (v[1,*] * coslst));
     v1[2,*] =  (  v[2,*]);
     return,v1
end
