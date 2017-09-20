;+
;NAME:
;chebfit - chebyshev polynomial fit to data
;SYNTAX:coef=chebfit(x,y,deg,merr=merr,$
;                   yfit=yfit,rangex=rangex,singular=singular,chisq=chisq,$
;                   covar=covar)
;ARGS:
;   x[n]: float/double independent var.  
;   y[n]: float/double measured dependent variable
;    deg: int          deg of fit (ge 1)
;KEYWORDS:
;merr[n]: float/double  measurement errors for y.default is uniform
;
;RETURNS:
;   coef[deg+1]:  coefs from fit
;
;KEYWORDS RETURNS:
;   yfit[n]: float or double . fit evaluated at x locations.
; rangex[2]: float/double     min max values of x used for fit.
;                          these were used to map the x axis 
;                          into [-1,1] for the fit.
;chisq   : float/double chisqr from svdfit
;covar[] : float/double covariance matrix from svdfit().
;singular: int          number of singular points found (see svdfit()).
;
;DESCRIPTION:
;   Do a chebyshev polynomial fit of order deg to the x,y data. Merr
;are the measurement errors (see idl svdfit routine).
;Return the coefs for the fit as well as the mapping of the xrange
;into [-1,1].  
;SEE ALSO:
;   chebeval() to evaluate the coef.
;
;NOTE:
;The fitting function svdcheb() is contained in this file. If the
;routine gives an error that it cannot find svdcheb() just compile
;this routine explicitly (.compile chebfit). 
;-           
;  
function chebfit,x,y,deg,yfit=yfit,rangex=rangex,merr=merr
;
;   map x,y to min,max   
;
    xmin=min(x,max=xmax) 
    xloc=(2.d*x-(xmax+xmin))/(xmax-xmin)            ; scale -1 1
    coef=svdfit(xloc,y,deg+1,function_name='svdcheb',chisq=chisq,$
        covar=covar,/double,yfit=yfit,singular=sng,measure_err=merr)
    if  sng ne 0 then  print,"svdfit returned singularity"
    rangex=[xmin,xmax]
    return,coef
end
; 
;NAME:
;svdcheb - chebyshev fitting function for svdfit
;
function svdcheb,X,M
;
;
        XX=X[0]                 ; ensure scalar XX
        basis=dblarr(m)
        basis[0]=1.0D
        basis[1]=xx
        FOR i=2,M-1 DO basis[i]=2.D*basis[i-1]*XX-basis(i-2)
    return,basis
end
