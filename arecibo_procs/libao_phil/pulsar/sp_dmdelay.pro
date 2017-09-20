;+
;NAME:
;sp_dmdelay -  delay in secs between two sky freq
;SYNTAX: delay=sp_dmdelay(f1,f2,dm)
;ARGS:
;   f1: double   frequency 1 Mhz
;   f2: double   frequency 2 Mhz
;   DM: double   dispersion measure 
;RETURNS:
;   delay:double in seconds
;
;DESCRIPTION:
;   Compute the delay f2-f1 for dispersion measure dm. 
;Positive numbers means that f1 arrives after f2 (f1 is the lower freq)
;
;NOTES:
; I stole this from dunc's sigproc routine
;-
function sp_dmdelay,f1,f2,dm
    return,(4148.741601D * ((1D/(f1*f1))-(1D/(f2*f2)))*dm) 
end
