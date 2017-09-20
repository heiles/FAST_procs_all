;+
;NAME:
;meanrob - robust mean for 1d array
;SYNTAX:  mean=meanrob(y,nsig=nsig,double=double,sig=sig,$
;                      gindx=gindx,ngood=ngood,bindx=bindx,nbad=nbad,$
;                      fpnts=fpnts,iter=iter,maxiter=maxiter,chkinf=chkinf)
;  ARGS:
;     y[n]  : array to compute robust mean
;KEYWORDS:
;     nsig  : float use nsig*sigma as the threshold for the points to
;                   keep on each iteration. The default is 3.
;     double:       if set then force computation to be done in double
;                   precision.
; RETURNS:
;     mean:   float/double the computed mean
;   sig       float/double the last computed rms
;   fpnts :   float        the fraction of points used for the final
;                          computation
;    gindx:   long[]       indices into d for the points that were used
;                          for the computation.
;    ngood    long         number of points in gindx.
;    bindx:   long[]       indices into d for the points that were not used
;    nbad     long         number of points in bindx.
;    iter     long         number of iterations performed.
;    maxiter  long         maximum number of times to iterate. default=5
;    chkinf   int          if set then check for infinities and ignore these
;                          points
;
; DESCTRIPTION:
;    compute the robust mean for the input data array. The program loops
; doing:
;   0. create a mask that includes all the points.
;   1. compute the mean, rms over the current mask
;   2. Find all points in the original array that are within nsig*sig of 
;      the mean. This becomes the new mask. If the new mask has fewer 
;      points than the old mask, go to 1.
;   4. Return the last mean computed. If the keywords are present, return
;      the sig, index for good points, index for bad points, and the fraction
;      of points used in the final computation.
;.
;-
;history:
; 27mar04 .. check to see if sig is 0. 
;
function  meanrob,d,nsig=nsig,double=double,sig=sig,gindx=gindx,iter=iter,$
                       ngood=ngood,bindx=bindx,nbad=nbad,fpnts=fpnts ,$
                       maxiter=maxiter,chkinf=chkinf
    one=(keyword_set(double))?1D:1.
    if not keyword_set(maxiter) then maxiter=5
	if n_elements(chkinf) eq 0 then chkinf=0
    szd=size(d)
    npntsTot=szd[szd[0]+2]
    if not keyword_set(nsig) then nsig=3.
    nsig=nsig*one
    ngood=npntsTot
	ninf=0L
	if chkinf then begin
		jj=finite(d)
		gindx=where(jj eq 1)
		iiInf=where(jj eq 0,ninf)
		ngood=npntsTot - ninf
	endif else begin
    	gindx=lindgen(ngood)
	endelse
    done=0
    iter=1
    while (not done) do begin
        meanv = total(d[gindx],double=double)/ngood
        resid=d[gindx]-meanV
;
;       stole from moment to go a little faster
;
        sig =sqrt( (total(resid^2, Double = Double) - $
                     (total(resid, Double = Double)^2)/ngood)/(ngood-1.0))
;
;       go back to the original dataset to see what is within nsig
;       of the new mean,sig
        if sig eq 0. then begin
            done=1
        endif else begin
            gindx =where( abs(d-meanV) lt (nsig*sig),count)
			if (ninf gt 0)  then begin
				okInf=lonarr(npntsTot)
				okInf[gindx]=1
				okInf[iiInf]=0
				gindx=where(okInf eq 1,count)
			endif
            if    (count ne ngood) then begin
                ngood=count
                iter=iter+1
            endif else begin
                DONE=1
            endelse
        endelse
        if ngood eq 0 then done=1
        if iter gt maxiter then done=1 
    endwhile
    if arg_present(bindx) or arg_present(nbad) then begin
        ii=intarr(npntsTot)
        if ngood gt 0 then ii[gindx]=1
        bindx=where(ii eq 0,nbad)
    endif
    fpnts=ngood/(npntsTot*1.)
    return,meanv
end
