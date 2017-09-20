;+
;NAME:
;ricross2dfit - fit 2d gaussian to a cross pattern.
;SYNTAX: coef=ricross2dfit(baz,bza,coefinit,azfit=azfit,zafit=zafit,$
;             covar=covar,chisq=chisq,sigma=sigma,sigCoef=sigCoef,$
;             trouble=trouble,weights=weights
;ARGS:
;   baz :{ricrossinp} azimuuth input info
;   bza :{ricrossinp} za       input info
;coefinit[10]:floats  initial values for coef.
;              [0] - offset
;              [1] - amplitude
;              [2] - xoffset
;              [3] - yoffset
;              [4] - fwhm az (amin)
;              [5] - fwhm za (amin)
;              [6] - theta  rotate unprimed to primed aligned along ellipsoid 
;                           of beam, degrees.
;              [7] - linear term in za deltaTsys/deltaZa (K/Amin)
;KEYWORDS:
;   pol : int  0 (def) return polA, 1 --> return polB
;
;RETURNS:
;azfit[npts]: fit evaluated along az strip
;zafit[npts]: fit evaluated along za strip
;covar[n,n]:float covariance matrix
;       chisq:float chisq of fit
;      sigma :float sigma of fit
; sigCoef[n]:float sigmas for coefficients
; weights[npts,2]: weights to use az,za
;                smaller number, less important
;NOTES:
;   Set fwhm az,za to slightly different values. The routine lets curvefit
;(in idl) compute the derivatives). If the fwhm are the same, then the
;rotation angle theta has no affect. The derivative comes out to be 0
;and it divides by the partial derivative array when doing the fit..
;
; If you enter 8 coefinit values then it will all fit for a linear term in za
;-
function ricross2dfit,baz,bza,coefinit,azfit=azfit,zafit=zafit,$
      covar=covar,chisq=chisq,sigma=sigma,sigCoef=sigCoef,trouble=trouble,$
      cfplot=cfplot,pol=pol,weights=weights

    ncoef=n_elements(coefinit)
    linearza=ncoef eq 8
    npts1axis=n_elements(baz[0].d[*,0])
    npts=2*npts1axis
    lpol=0
    if keyword_set(pol) then lpol=1
    if not keyword_set(weights) then begin
        weightsl=0.D
    endif else begin
        weightsl=reform(weights*1.D,npts)
    endelse
    azOffset=baz[0].h[0].proc.dar[0]
    zaOffset=baz[0].h[0].proc.dar[0]

    azLoc=fltarr(npts1axis,2)
    zaLoc=fltarr(npts1axis,2)
    azLoc[*,0]=-(findgen(npts1axis)/npts1axis - .5)*azOffset*2.
    azLoc[*,1]=0.;
    zaLoc[*,0]=0.;
    zaLoc[*,1]=-(findgen(npts1axis)/npts1axis - .5)*zaOffset*2.
    z=fltarr(npts1axis,2)
    z[*,0]=baz.d[*,lpol]
    z[*,1]=bza.d[*,lpol]
    coef=gsfit2d(azLoc,zaLoc,z,coefinit,zfit=zfit,covar=covar,weights=weightsl,$
        sigCoef=sigCoef,chisq=chisq,sigma=sigma,trouble=trouble,cfplot=cfplot,$
        linearza=linearza)
    zfit=reform(zfit,npts1axis,2,/overwrite)
    azfit=zfit[*,0]
    zafit=zfit[*,1]
    return,coef
end
