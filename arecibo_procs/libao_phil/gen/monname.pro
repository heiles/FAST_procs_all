;+
;NAME:
;monname - return month name given month number
;SYNTAX:  nm=monname(monnum)
;ARGS  :
;        monnum  int   month number  1 to 12
;DESCRIPTION:
;  Return the 3 character name of the month given the month number
;
;EXAMPLE:
;   monnum=3
;   monNam=monname(monnum)  ; this returns 'mar'
;-
function  monname,monnum
    monlist=['jan','feb','mar','apr','may','jun','jul','aug','sep','oct',$
             'nov','dec']

    i= (monnum lt 1)? 1 : $
           (monnum gt 12)? 12 : monnum
    return,monlist[i-1]
end
