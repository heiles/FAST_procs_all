;+
;NAME:
;hms1_hr - convert hhmmss.sss as a double to hours.
;SYNTAX: angHr=hms1_hr(hhmmss)
;ARGS:
;   hhmmss: double value to convert
;RETURNS:
;   angHr: double the angle converted to hours
;DESCRIPTION
; Convert packed hours, minutes, seconds to hours.
;The input is a single double with hhmmss.ss with hh hours, mm minutes,
;ss.s seconds.
;-
function  hms1_hr,hms
;
    forward_function hms1_hms3
    hms3=hms1_hms3(hms)
    if n_elements(hms) gt 1 then begin
        return,reform(hms3[3,*]*(hms3[0,*] + hms3[1,*]/60.D +hms3[2,*]/3600.D));
    endif else begin
        return,hms3[3]*(hms3[0] + hms3[1]/60.D +hms3[2]/3600.D);
    endelse
end
