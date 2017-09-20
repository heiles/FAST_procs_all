;+
;NAME:
;hms1_rad - convert hhmmss.sss as a double to radians.  
;SYNTAX: angRad=hms1_rad(hhmmss)
;ARGS:
;   hhmmss: double value to convert
;RETURNS:
;   angRad: double the angle converted to radians.  
;DESCRIPTION
; Convert packed hours, minutes, seconds to radians.
;The input is a single double with hhmmss.ss with hh hours, mm minutes,
;ss.s seconds.
;-
function  hms1_rad,hms
;
    forward_function hms1_hms3
    hms3=hms1_hms3(hms)
    if n_elements(hms) gt 1 then begin
        return,reform(2.D*!PI*hms3[3,*]*(hms3[0,*]/24.D + hms3[1,*]/1440.D + $
                    hms3[2,*]/86400.D));
    endif else begin
    return,2.D*!PI*hms3[3]*(hms3[0]/24.D + hms3[1]/1440.D + hms3[2]/86400.D);
    endelse
end
