;nodoc +
;gsfituser - let the user interactively subtract a baseline and fit a gaussian.
;SYNTAX: istat=gsfituser(x,y,mask,h,w,position)
;ARGS:   
;       x[npts]: float x data
;       y[npts]: float y data to fit
;RETURNS:
;    maskbl[npts]: float  mask used for baseline.
;    h           : float  height of guassian
;    w           : float  width of gaussian fwhm units of x
;    p           : float  index into y for peak (start at 0).
;no doc-
function gsfituser,x,y,masbl,h,w,p
;
;   baseline the data
;
    print,'baselining the data..'
    if (bluser(x,y,coef,yfit,maskbl,_extra=e) eq 0) return,0
    print,'  ... not yet done..'
    return;
end
