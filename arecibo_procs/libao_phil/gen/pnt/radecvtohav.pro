;+
;NAME:
;radecVtohaV - current ra/dec (v3) to hourAngle/dec (v3)
;
;SYNTAX: hadecV=radecVtohaV(radecV,lstRd)
;
;ARGS  :
; radecv[3,Npts]: float/double. 3 vector ra,dec
;    lstRd[npts]: float/double. local sidereal time in radians
;
;RETURNS:
;   haDecV[3,npts]: hour angle/dec 3 vector.
;
;DESCRIPTION
;
; Transform from  from a right ascension (of date) dec system to an
; hour angle dec system. The  inputs are normalized 3 vectors and
; the local sidereal time in radians. See radecDtohaV for a version
; that uses angles for input.
;
; The ra/dec system is a right handed coordinate system while the ha/dec
; frame is left handed. This requires a rotation and then a reflection
; to change the handedness (the minus sign around the y portion).
; The returned value is the ha dec 3 vector.
;-
; modhistory:
;   26feb05 - was using the first ra,dec for all the elements of the array
;
function radecvtohaV,haDecV,lstRd
;
     coslst=cos(lstRd);
     sinlst=sin(lstRd);
     v =haDecV
     v1=dblarr(3,n_elements(lstRd))
     v1[0,*] =  (  v[0,*]* coslst) + (v[1,*] * sinlst);
     v1[1,*] = -(-(v[0,*]* sinlst) + (v[1,*] * coslst));
     v1[2,*] =  (  v[2,*]);
     return,v1
end
