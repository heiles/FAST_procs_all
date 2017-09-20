;+
;NAME:
;rms - compute the mean and standard deviation
;SYNTAX:  result=rms(x,quiet=quiet)
;  ARGS:
;     x[]  : array to compute rms
;KEYWORDS:
;     quiet: if set then don't print the rms,mean to stdout.    
;   
; RETURNS:
;     result[2]: result[0]=mean, result[1]= std deviation
; DESCTRIPTION:
;    compute the mean and standard deviation. Print the results to
; stdio, and return in result[2]
;-
function rms,x,quiet=quiet
    nx=n_elements(x)
    meanx=total(x,/double)/nx
    res=x-meanx
    type=size(x[0],/type)
;
;   do complex data correctly
;
    if (type eq 6) or (type eq 9) then begin
        vrr=total(real_part(res)^2,/double)/(nx-1.0)
        vri=total(imaginary(res)^2,/double)/(nx-1.0)
        stddev=complex(sqrt(vrr),sqrt(vri))
    endif else begin
        var=total(res^2,/double)/(nx-1.0)
        stddev=sqrt(var)
    endelse
    if not keyword_set(quiet) then print,"Mean:",meanx," stddev:",stddev
    return,[meanx,stddev]
end
