;*************************************************************************
; pntquery - query bitmasks from pnt header. functions input
;             pnt header and return 1,0 for true,false
;
;*************************************************************************
;+
;NAME:
;pnthgrmaster - return 1 if greg is master, 0 if ch master
;SYNTAX: istat=pnthgrmaster(pnthdr)  
;ARGS:
;       pnthdr:{hdrpnt}   .. pnt portion of header.
;RETURNS:
;       istat: int 1 if greg master, 0 if ch master
;EXAMPLE:
;   suppose we have a correlator data:
;   print,corget(lun,b)
;   istat=pnthgrmaster(b.b1.h.pnt)
;-  
function pnthgrmaster,pnthdr
    on_error,1
    istat=0
    if  (pnthdr.stat and '00200000'XL) ne 0 then istat=1
    return, istat
end
;
;+
;NAME:
;pnthcoordsys - return coordinate system code
;SYNTAX: icode=pnthcoordsys(pnthdr)
;ARGS:
;       pnthdr:{hdrpnt}   .. pnt portion of header.
;RETURNS:
;       icode: int code for coordinate system used: 
;                   1 galactic
;                   2 B1950
;                   3 J2000
;                   4 BEcliptic
;                   5 JEcliptic
;                   6 Ra/Dec of date (current
;                   7 hour angle dec
;                   8 az,za of source
;                   9 az,za of feed (az is 180 deg from source if dome used)
;                  10 az,za of feed with no pointing model included
;                       
;EXAMPLE:
;   suppose we have a correlator data record:
;   print,corget(lun,b)
;   icode=pnthcoordsys(b.b1.h.pnt)
;
;To extract the data manually (without this routine) use:
; 
; icode= ishft(b.b1.h.pnt.stat and '00078000'XL, -15)
;
;-
function pnthcoordsys,pnthdr
    on_error,1
    icode=0
    icode= ishft(pnthdr.stat and '00078000'XL, -15)
    return,icode
end
