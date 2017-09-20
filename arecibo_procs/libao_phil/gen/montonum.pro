;+
;NAME:
;montonum - convert ascii month to number 1-12
;SYNTAX:  num=montonum(month)
;ARGS  :
;        month   string holding 3 character month
;DESCRIPTION:
;   Given a 3 character month abreviation return the month of year (1..12).
;-
function  montonum,month
    monlist=['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT',$
             'NOV','DEC']

    ind=where(strupcase(month) eq monlist,count)
    if count eq 0 then return,0
    return,ind[0]+1
end
