;+
;NAME:
;yymmddtodmy - convert yymmdd to ddMonyy
;
;SYNTAX: dddMonyy=yymmddtodmy(yymmdd)
;ARGS:
;       yymmdd: long convert yymmdd to ddMONyy (eg. 020210 to 10mar02)
;RETURNS:
;        ddMONyy:string return '' if bad format..
;         
;DESCRIPTION
;   Convert from yymmdd long to ddMONyy string
;EXAMPLE:
;   yymmdd=060428
;   ddMONyy=yymmddtodmy(yymmdd)
;   print,ddMONyy
;   28apr06
;-
function yymmddtodmy,yymmdd
    monlist=['jan','feb','mar','apr','may','jun','jul','aug','sep','oct',$
        'nov','dec']
    lyymmdd=long(yymmdd)
    day=lyymmdd mod 100L
    mon=(lyymmdd/100L) mod 100L
    yr =lyymmdd/10000L

    if (mon lt 0 ) or (mon gt 12) then return,''
    monl=monlist[mon-1]
    return,string(format='(i2.2,a,i2.2)',day,monl,yr)
end
