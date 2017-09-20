;+
;NAME:
;corinterprfi - interpolate spectra across rfi.
;SYNTAX: binterp=corinterpolrfi(b,fsin=fsin,deg=deg,ndel=ndel,verb=verb,$
;               _extra=e)
;   
;ARGS:
;       b: {corget} Corget structure to interpolate.
;KEYWORDS:
;    fsin: int  degree of sin fit to use (default 8).see corblauto
;    deg : int  degree of polynomial fit to use (default 1).see corblauto
;    ndel: int  The number of adjacent points to exclude when a bad point
;               is found (default 5). see corblauto
;    verb: int  if -1 then plot the baseline fitting while it's being done.
;   _extra:     Any extra keywords will be passed to corblauto (see corblauto
;               for a list of keywords you can use).
;RETURNS:
;   binterp:{corget} the {corget} data strucuture b with interpolation
;               over the excluded (outlying) data points.
;
;DESCRIPTION:
;   This routine finds bandpass outliers (by fitting polynomials and sines
;to the bandpass using corblauto). It then interpolates across the
;outliers using the idl interpol() routine (with the default linear
;interpolation). 
;   Normally the "outliers" include the edges of the bandpass
;(since they are hard to fit). This is not desired when fitting for 
;"just rfi". To correct this, the routine searches in from both edges
;of the bandpass until it finds a "non  outlier" point. All the outliers
;from the edge to this point are not interpolated across.
;
;EXAMPLE:
;; input a scan, create a median bandpass, and then interpolate
;; across any rfi. Use this average bandpass as the bandpass correction
;; for the image display routine corimgdisp().
;
;   istat=corinpscan(b)
;   bavg=cormedian(bavg)
;   bpc=corinterprfi(b,verb=-1) 
;   img=corimgdisp(b,bpc=bpc)
;-
;
function corinterprfi,b,fsin=fsin,deg=deg,ndel=ndel,verb=verb,$
        _extra=e,coef=coef 

    if n_elements(deg) eq 0 then deg=1
    if n_elements(fsin) eq 0 then fsin=8
    if n_elements(ndel) eq 0 then ndel=5

;
;   fit the function,find the points we ignored
;
    binterp=b
    istat=corblauto(b,bfit,mask,coef,deg=deg,fsin=fsin,verb=verb,_extra=e)
    for ibrd=0,3 do begin
        nlags=coef.nlags[ibrd]
        if nlags gt 0 then x=lindgen(nlags)
        for ipol=0,1 do begin
            if coef.pol[ipol,ibrd] ne 0 then begin
                m=mask.(ibrd)[*,ipol]
;
;               get the points we used
;
                ind=where(m ne 0,count)
;
;               keep the edges (up to the first point, after the last point
;
                imin=ind[0]
                imax=ind[count-1]
                if imin ne 0 then ind=[lindgen(imin),ind]
                if imax ne (nlags-1) then $
                    ind=[ind,lindgen((nlags-1)-imax)+imax+1]
                binterp.(ibrd).d[*,ipol]=interpol(b.(ibrd).d[ind,ipol],x[ind],x)
            endif
        endfor
    endfor
    return,binterp
end
