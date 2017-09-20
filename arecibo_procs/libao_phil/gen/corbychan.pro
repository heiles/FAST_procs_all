;+
;NAME:
;corbychan - auto/xcorrelate dynamic spc by chan.
;SYNTAX:  cormat=corbychan(spc1,spc2,avg1=avg1,avg2=avg2,rms1=rms1,rms2=rms2)
;  ARGS:
;     spc1[nchn,mtime] : float first dynamic spectra
;     spc2[nchn,mtime] : float 2nd dynamic spectra (not needed if auto
;                              correlation done
;KEYWORDS:
;   
; RETURNS:
;     cormat[nchn,nchn]: float  correlation matrix returned
;     avg1[nchn]       : float robust average over time of spc1
;     avg2[nchn]       : float robust average over time of spc2
;     rms1[nchn]       : float rms by channel of spc1
;     rms2[nchn]       : float rms by channel of spc2
;
; DESCTRIPTION:
;    Compute the correlation matrix for a set of dynamic spectra. It computes
; the correlation between every two pairs of channels in one set of
; dynamic spectra (if only spc1 entered) or between channels in two
; sets of dynamic spectra (if spc1,spc2 entered).
;
;   The computation is:
;
;   Let:
;   nchn=the number of freq channels
;   mtm =the number of time samples
;   for spc 1 or 2 let:
;       savg[nchn]= mean(spc[,]) averaging over the time samples
;       srms[nchn]= rms(spc) computed along the time axis of each chan
;   s[i,j]    = (spc[i,j] - sAvg[i]))/srms[i] .. remove mean normalize to sigma
;
;   cormat[i,j]= sum_k(s1[i,k]*s2[j,k])/nsmp
;
;    The routine uses robust averaging and rms (outliers are not used).
;-
function corbychan,spc1,spc2,avg1=avg1,avg2=avg2,rms1=rms1,rms2=rms2,$
    norob=norob 
    nspc=n_params()
    a1=size(spc1) 
    a2=(nspc eq 2)?size(spc2):a1
    if a1[0]  ne 2 then message,'input array should be 2d'
    if (total(a1[0:2] - a2[0:2]) ne 0) then $
        message,'The two arrays must have the same dimension'
    nchn=a1[1]
    nsmp=a1[2]
;
;   average over time of spc1
;
    if keyword_set(norob) then begin
        avg1=total(spc1,2)/a1[2]
        rms1=rmsbychan(spc1,/nodiv)
    endif else begin
     avg1=avgrobbychan(spc1,rms=rms1) 
    endelse
;
;   *spc1 - average) / rms
;   Instead of looping over channels, create 2d arrays (avg), (rms)
;   for subraction and scaling
;
    d1= (spc1 - (avg1 # (fltarr(nsmp)+1.)))*((1./rms1) # (fltarr(nsmp)+1.))
    if nspc eq 2 then begin
        if keyword_set(norob) then begin
            avg2=total(spc2,2)/a2[2]
            rms2=rmsbychan(spc2,/nodiv)
        endif else begin
            avg2=avgrobbychan(spc2,rms=rms2) 
        endelse
        d2= (spc2 - (avg2 # (fltarr(nsmp)+1.)))*((1./rms2) # (fltarr(nsmp)+1.))
;
;       multiply, scale by number of adds (nsmp) in matrix multiply)
;
        d12=(d1 # transpose(d2))*(1./nsmp)
    endif else begin
        d12=(d1 # transpose(d1))*(1./nsmp)
    endelse
    return,d12
end
