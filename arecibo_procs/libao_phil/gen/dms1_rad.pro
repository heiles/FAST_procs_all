;+
;NAME:
;dms1_rad - convert ddmmss.sss as a double to radians.  
;SYNTAX: angRad=dms1_rad(ddmmss)
;ARGS:
;   ddmmss: double value to convert
;RETURNS:
;   angRad: double the angle converted to radians.  
;DESCRIPTION
; Convert packed deg, minutes, seconds to radians.
;The input is a single double with ddmmss.ss with dd deg, mm minutes,
;ss.s seconds.
;-
function  dms1_rad,dms
;
    forward_function dms1_dms3
    dms3=dms1_dms3(dms)
    if n_elements(dms) gt 1 then begin
        return,reform(2.D*!PI*dms3[3,*]*$
        (dms3[0,*]/360.D + dms3[1,*]/21600.D + dms3[2,*]/1296000.D));
    endif else begin
        return,2.D*!PI*dms3[3]*$
        (dms3[0]/360.D + dms3[1]/21600.D + dms3[2]/1296000.D);
    endelse
end
