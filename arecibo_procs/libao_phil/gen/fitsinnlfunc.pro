; nodoc
;NAME:
;fitsinnlfunc - nonlinear fit to a sine
;
; y= a[0] + a[1]*sin(a[2]*x + a[3])
; a[0] - offset
; a[1] - amplitude
; a[2] - frequency (radians/sec)
; a[3] - phase (radians)
; x    - in radians
; called by fitsinnl
; 
pro fitsinnlfunc,x,a,f,pder
    sinval=sin(a[2]*x+a[3])
    f= a[0]+ a[1]*sinval
    if n_params() ge 4 then begin
        pder=fltarr(n_elements(x),4)
        pder[*,0]=1.                ;  d/dconstant
        pder[*,1]=sinval            ;  d/dAmplitude
        pder[*,3]=a[1]*cos(a[2]*x+a[3]) ; d/dPhase
        pder[*,2]=pder[*,3]*x       ;  d/dOmega
    endif
    return
end
