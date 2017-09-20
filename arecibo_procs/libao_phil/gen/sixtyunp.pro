;+
;NAME:
;sixtyunp - unpack hhmmss.s or ddmmss.s to hh mm ss.s or dd mm ss.s
;SYNTAX: sixtyunp(xxyyzz,sgn,result)
;ARGS:
;   xxyyzz: float,long,double either hhmmss.s or ddmmss.s
;
;RETURNS:
;   sgn      : int   sign either +1 or -1
;   result[3]: float  [hh,mm,ss.s]  or [dd,mm,ss.s]
;
;DESCRIPTION:
;   split hhmmss.s or ddmmss.s to h,m,s or d,m,s. Return the positive
;values in the array result. The sign of the value is returned in sgn.
;
;EXAMPLES:
; sixtyunp,112233.3 ,sgn,result.. sgn=1., result=[11.,22.,33.3]
; sixtyunp,-000033.3,sgn,result.. sgn=-1., result=[0.,0.,33.3]
;-
;
pro sixtyunp,xxyyzz,sgn,result

    xxyyzzl=double(xxyyzz)
    sgn=1.
    if xxyyzzl lt 0. then begin
        sgn=-1
        xxyyzzl=-xxyyzzl
    endif
    itemp=long(xxyyzzl)
    result=fltarr(3)
    result[0]=itemp/10000L
    result[1]=(itemp/100L) mod 100L
    result[2]=xxyyzzl - itemp + (itemp mod 100l)
;
;    check round off error
;
    if result[2] ge 60. then begin
       result[2]=result[2]-60.
       result[1]=result[1]+1.
    endif
    if result[1] ge 60. then begin
       result[1]=result[1]-60.
       result[2]=result[2]+1.
    endif
    return
end
