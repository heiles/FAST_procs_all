;+
;NAME:
;robfit_poly - robust polyfit for 1d array
;SYNTAX:  coef=robfit_poly(x,y,deg,nsig=nsig,double=double,sig=sig,$
;                      gindx=gindx,ngood=ngood,bindx=bindx,nbad=nbad,$
;                      fpnts=fpnts,iter=iter,yfit=yfit,maxiter=maxiter)
;  ARGS:
;     x[n]  : x array for fit
;     y[n]  : y  array for fit 
;      deg  : int deg of polynomial fit
;KEYWORDS:
;     nsig  : float use nsig*sigma as the threshold for the points to
;                   keep on each iteration. The default is 3.
;     double:       if set then force computation to be done in double
;                   precision.
;    maxiter:       maximum number of times to loop. default is 20.
; RETURNS:
;coef[deg+1]: float/double the fit coef. 
;   sig       float/double the last computed rms
;   fpnts :   float        the fraction of points used for the final
;                          computation
;    gindx:   long[]       indices into d for the points that were used
;                          for the computation.
;    ngood    long         number of points in gindx.
;    bindx:   long[]       indices into d for the points that were not used
;    nbad     long         number of points in bindx.
;    iter     long         number of iterations performed.
;    yfit :  float/double the fit evaluated at x[n]
;
; DESCTRIPTION:
;    compute a robust polynomial fit for the input data x,y. The program loops
; doing:
;   0. create a mask that includes all the points.
;   1. fit the polynomial, rms residuals over the current mask
;   2. Find all points in the original array that are within nsig*sig of 
;      the fit. This becomes the new mask. 
;   3. if sig is less than the minimum sig so far, minsig=sig, and
;      store indices for this minimum sig
;   4  If the new mask does not have the   same number of points than the 
;      old mask, go to 1.
;   5. Check the coef of the Check if the 
;   5. Return the last coefs computed. If the keywords are present, return
;      the sig, index for good points, index for bad points, and the fraction
;      of points used in the final computation, and yfit.
;.
;-
;history:
; 06apr05 .. stole from avgrob
; 13jun05 .. this can oscillate. keep track of gindx of min sig
;            an place a limit on iter
;
function  robfit_poly,x,y,deg,nsig=nsig,double=double,sig=sig,gindx=gindx,$
                      iter=iter,ngood=ngood,bindx=bindx,nbad=nbad,fpnts=fpnts,$
                      yfit=yfit,status=status,maxiter=maxiter
    one=(keyword_set(double))?1D:1.
    if n_elements(maxiter) eq 0 then maxiter=20
    szx=size(x)
    npntsTot=szx[szx[0]+2]
    if not keyword_set(nsig) then nsig=3.
    nsig=nsig*one
    ngood=npntsTot
    gindx=lindgen(ngood)
    done=0
    iter=1
    minsig=-1.
    chkiter=20
    gindsminsig=gindx
    start=1
    while (not done) do begin
        coef=poly_fit(x[gindx],y[gindx],deg,double=double,status=status,$
            yerror=sig)
        if sig eq 0. then begin
            done=1
        endif else begin
            yfit=poly(x,coef)
            gindx =where( abs(yfit-y) lt (nsig*sig),count)
            if start then  begin
                    gindxminsig=gindx
                    minsig=sig
                    start=0
                    mincoef=coef
            endif
            if    (count ne ngood) then begin
                ngood=count
                iter=iter+1
                if sig lt minsig then begin
                    minsig=sig
                    gindxminsiq=gindx
                    mincoef=coef
                endif
            endif else begin
                DONE=1
            endelse
        endelse
        if ngood eq 0 then done=1
        if iter gt maxiter then done=1
    endwhile
    if (sig gt minsig) and (start eq 0)  then begin
        sig=minsig
        gindx=gindxminsig
        ngood=n_elements(gindx)
        coef=mincoef
    endif
    if arg_present(bindx) or arg_present(nbad) then begin
        ii=intarr(npntsTot)
        if ngood gt 0 then ii[gindx]=1
        bindx=where(ii eq 0,nbad)
    endif
    if (n_elements(yfit) eq 0) and (arg_present(yfit)) then yfit=poly(x,coef)
    fpnts=ngood/(npntsTot*1.)
    return,coef
end
