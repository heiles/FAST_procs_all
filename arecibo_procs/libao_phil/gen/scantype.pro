;+
;NAME:
;scantype - return the type of scan
;SYNTAX: type=scantype(hdr)
;  ARGS:  
;        hdr: {hdr} 
;RETURNS:
;       type:  0 unknown
;              1 calon of calonoff pattern
;              2 caloff of calonoff pattern
;              3 position on  of onoff pattern
;              4 position off of onoff pattern
;DESCRIPTION:
;   Return the type of scan from the header info. 
;EXAMPLE: 
;   print,corget(lun,b)
;   type=scantype(b.b1.h)
;-
function scantype,hdr
;
    forward_function corhcalrec
    calrec=corhcalrec(hdr)
    if calrec ne 0 then return,calrec
    if (string(hdr.proc.procname) eq 'onoff') then begin
       car0=string(hdr.proc.car[*,0])
       if car0 eq 'on'   then return,3
       if car0 eq 'off'  then return,4
    endif
    return,0
end
