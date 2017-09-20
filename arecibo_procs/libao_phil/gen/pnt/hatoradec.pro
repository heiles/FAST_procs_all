;+
;NAME:
; hatoradec - hour angle/dec to ra/dec (of date).
;SYNTAX: v3out=hatoradec(v3,lst)
;ARGS:
;   v3[3,n]: double ha,dec data to convert to ra of date
;  lstRd[n]: double local apparent sidereal time in radians
;OUTPUTS
;   v3out[3,n]:double ra,dec of date
;
; DESCRIPTION
;
; Transform from  from an hour angle dec system to a right ascension (of date)
; dec system. The  inputs are double precision 3 vectors. The lst is passed
; in radians.
; If the lst is the mean sidereal time , then the ra/dec and hour angle should
; be the mean positions. If lst is the apparent sidereal time then the
; ra/dec, hour angle should be the apparent positions.
;
; The transformation is simlar to the raDecToHa except that we reflect
; first (left handed to right handed system) before we do the rotation in 
; the opposite direction.
;-
function   hatoradec,v3,lstRd
 
        coslst=cos(-lstRd);
        sinlst=sin(-lstRd);
        v3out=v3
        v3out[0,*] =   (v3[0,*] * coslst) + (-v3[1,*] * sinlst);
        v3out[1,*] =   (-(v3[0,*]    * sinlst) + (-v3[1,*] * coslst));
        v3out[2,*] =   (v3[2,*]);
        return,v3out
end
