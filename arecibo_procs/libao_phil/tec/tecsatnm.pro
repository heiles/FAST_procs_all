;+
;NAME:
;tecsatnm - map satellite code to satellite name
;SYNTAX: istat=tecsatnm(satCode,satNm,satList=satList)
;ARGS:
;satCode: int   satellite code stored in tecAr.sat
;RETURNS:
;istat: int     1 found satellite name
;               0 illegal satCode
;satList[]: strarr array holding all of the satellite names we know of.
;-
function tecsatnm,satCode,satNm,satList=satList
    forward_function tecsatlist
; 
; return satellite code.. index+1 into the list
; 
    satList=tecsatlist()
;
;   trim the blanks off the right of satNm
;
    n=n_elements(satList)
    ii=satCode-1
    if (ii lt 0) or (ii ge n) then begin
        print,'illegal satellite code number:',satCode
        return,0
    endif
;
    satNm=satList[ii]
    return,1
end
