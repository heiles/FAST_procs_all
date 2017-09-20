;+
;NAME:
;chkcalonoff - check that hdrs are a valid cal on,off.
;SYNTAX: istat=chkcalonoff(hdrOn,hdrOff)
;  ARGS:  
;        lun:   assigned to file we are reading
;       hdrOn:  hdr from cal on.
;      hdrOff:  hdr from cal off.
;RETURNS:
;       istat: 1 it is a valid cal onoff pair
;            : -1 The hdrOn  passed in is not a cal on
;            : -2 The hdrOff passed in is not a cal off
;DESCRIPTION:
;   Check that the  two headers passed in belong to a calonoff pair.
;The routine checks the procedure name and that car[*,0] contains 'on' and
;'off' respectively.
;EXAMPLE: 
;   input 2 records and check that they are from a cal on,off
;   print,posscan(lun,32500007L,1)
;   print,corgetm(lun,2,bb)
;   istat=chkcalonoff(bb[0].b1.h,bb[1].b1.h)
;-
function chkcalonoff,hdrOn,hdrOff
;
    if corhcalrec(hdrOn) ne 1 then return,-1
    if corhcalrec(hdrOff) ne 2 then return,-2
    return,1
end
