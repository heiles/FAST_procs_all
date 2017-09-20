;+
;NAME:
;dms1_deg - convert ddmmss.sss as a double to degrees.
;SYNTAX: angDeg=dms1_deg(ddmmss)
;ARGS:
;   ddmmss: double value to convert
;RETURNS:
;   angdeg: double the angle converted to degrees.
;DESCRIPTION
; Convert packed degrees, minutes, seconds to degrees.
;The input is a single double with ddmmss.ss with dd degrees, mm minutes,
;ss.s seconds.
;-
function  dms1_deg,dms
;
    forward_function dms1_dms3
    dms3=dms1_dms3(dms)
    if n_elements(dms) gt 1 then begin
        return,reform(dms3[3,*]*(dms3[0,*] + dms3[1,*]/60.D +dms3[2,*]/3600.D));
    endif else begin
        return,dms3[3]*(dms3[0] + dms3[1]/60.D +dms3[2]/3600.D);
    endelse
end
