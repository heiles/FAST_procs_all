;+
;NAME: 
;inverf - compute inverse error function
;SYNTAX: val=inverf(x)
;ARGS:
;     x[n] : float/double   evalute the function at x.
;RETURNS:
;   val[n] :  double the inverse error function value.
;
;DESCRIPTION:
;   Compute the inverse error function. 
;  The following approximations to the inverse of the error function are
;  taken from J. M. Blair, C. A. Edwards, and J. H. Johnson, "Rational
;  Chebyshev Approximations for the Inverse of the Error Function",
;  Mathematics of Computation, 30 (1976) 827-830 + microfiche appendix.
;
; via fred schwab
;-
function inverf,xinp

   x=double(xinp)           ; in case it was float  
   ntot=n_elements(x)
   ret=dblarr(ntot)
   ndone=0L
   ax = abs(x);

   ind=where(ax le 0.75D,count)
   if count gt 0 then begin
;  
; This approximation, taken from Table 10 of Blair et al., is valid
;  for |x|<=0.75 and has a maximum relative error of 4.47 x 10^-8.

        p = [-13.0959967422D,26.785225760D,-9.289057635D]
        q = [-12.0749426297D,30.960614529D,-17.149977991D,1.00000000D]
        t = x[ind]*x[ind]-0.75d*0.75D;
        ret[ind] = x[ind]*(p[0]+t*(p[1]+t*p[2]))/(q[0]+t*(q[1]+t*(q[2]+t*q[3])))
        ndone=ndone+count
    endif
    if ndone eq ntot then return,ret

    ind=where((ax gt 0.75D) and  (ax le 0.9375D ),count)
    if count gt 0 then begin

; This approximation, taken from Table 29 of Blair et al., is valid
; for .75<=|x|<=.9375 and has a maximum relative error of 4.17 x 10^-8.

        p = [-.12402565221D,1.0688059574D,-1.9594556078D,.4230581357D]
        q = [-.08827697997D,.8900743359D,-2.1757031196D,1.0000000000D]
        t = x[ind]*x[ind] - 0.9375D*0.9375D
        ret[ind] = x[ind]*(p[0]+t*(p[1]+t*(p[2]+t*p[3])))/ $
                (q[0]+t*(q[1]+t*(q[2]+t*q[3])))
        ndone=ndone+count
    endif
    if ndone eq ntot then return,ret

    ind=where(( ax gt 0.9375D) and (ax le (1.0D - 1.d-100)),count)
    if count gt 0 then begin 
 
; This approximation, taken from Table 50 of Blair et al., is valid
; for .9375<=|x|<=1-10^-100 and has a maximum relative error of 2.45 x 10^-8.

        p= [ .1550470003116D,1.382719649631D,.690969348887D, $
           -1.128081391617D,  .680544246825D,-.16444156791D]
        q= [.155024849822D,1.385228141995D,1.000000000000D]
        t= 1.0/sqrt(-alog(1.0D - ax[ind]))
        sgnx=dblarr(count)+1.
        ii=where(x[ind] lt 0.,countii)
        if countii gt 0 then sgnx[ii]=-1.D
        ret[ind] = sgnx*(p[0]/t+p[1]+t*(p[2]+t*(p[3]+t*(p[4]+t*p[5]))))/ $
                   (q[0]+t*(q[1]+t*(q[2])));
        ndone=ndone+count
    endif
    if ntot eq ndone then return,ret
    ind=where(ax gt (1.0D - 1.d-100),count)
    if count gt 0 then ret[ind]=!values.d_infinity
    return,ret
end
