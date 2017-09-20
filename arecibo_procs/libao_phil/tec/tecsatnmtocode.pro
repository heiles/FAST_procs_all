;+
;NAME:
;tecsatnmtocode - map satellite name to satellite code
;SYNTAX: satcode=tecsatnmtocode(satNam)
;ARGS:
;satNam: string satellite name (as defined in the data files).
;RETURNS:
;satcode:  int      satellite code number for satNam
;                   0 if there if this sat name is not in the list
;-
function tecsatnmtocode,satNm,satList=satList
; 
; return satellite code.. index+1 into the list
; 
    satList=tecsatlist()
;
;   trim the blanks off the right of satNm
;
    satNmL=strtrim(satNm,2);
;
    ii=where(satNmL eq satList,cnt)
    if cnt eq 0 then return,0
    return,ii[0]+1 
end
