;+ 
;NAME:
;pwrlawdist - generate a power law distribution.
;SYNTAX: y=pwrlawdist(alpha,npts,minVal=minVal,maxVal=maxVal,
;                    dohist=dohist,nbins=nbins,h=h,xh=xh)
;ARGS:
;    alpha: float exponent for power law.
;     npts: long  number of points to return
;
;KEYWORDS:
;   minVal: float minimum value for the distribution. If alpha is less
;                 than 0., then minval should be gt 0 to keep it from
;                 blowing up. default:.01
;   maxVal: float maximum value for the distribution. It should be 
;                 greater tham minVal.Default:1.
;   dohist:       if set, then compute histogram, make log,log plot
;                 of histogram, and then do a linear fit to non zero values.
;    nbins: long  number of bins if histogram requested. default is
;                 npts*.005
;RETURNS:
;   y[npts]: double the power law distributed data.
;
; h[nbins]: long  return histogram of y. (linear)
;xh[nbins]: float return center of each bin.(linear)
;
;DESCRIPTION:
;   Generate a random variable with a power law distribution:
; y=r**(alpha). The data range will be: (minVal ge y le maxVal).
;   The routine will optionally compute the histogram of the data,
;fit a line to a log,log version of the histogram, and then 
;plot the histogram and the fit. This lets you see how close to the
;ideal power law you got. The fit can have trouble if the data range
;does not make a good match to the binsize,number of bins.
;
;   The method blows up for alpha=-1. If alpha is within 
; 1e-4 of -1, the routine uses -1+/-1e-4 and gives a warning..
;
;See numerical recipes in C, section: 7.2 transformation methods, page 287.
;for an description of how it's done.
;
;EXAMPLE:
;
;  1. create a power law distribution r^1.5 ranging from 0 to 1. 
;     Return,10000L points. Make the histogram with 100 points.
;
;   y=pwrlawdist(1.2,20000L,minval=.0,maxval=1.,/dohist,h=h,xh=xh,$
;                  nbins=100)
;
;   ..create a power law dist r^-2.2 with 10000L points.
;
;plot out the histogram. have the values go 1 to 500.
;return the histogram with it's binvalues.
;kick up the number of bins to 1000 so the histogram fit works.
;
;   y=pwrlawdist(-2.2,10000L,minval=1.,maxval=500.,/dohist,h=h,xh=xh,$
;                   nbins=1000)
;
;-
function pwrlawdist,alpha,npts,dohist=dohist,nbins=nbins,h=h,xh=xh,$
            minval=minval,maxval=maxval

    common colph,decomposedph,colph    

    eps=1d-4
    alphaLoc=alpha
    if abs(alpha+1.D) lt eps then begin
           alphaLoc=(alpha lt -1.)? -1.D - eps:-1.D+eps
           print,'warning: routine diverges at alpha=-1. using:',alphaLoc
    endif
    yminLoc=.01D
    ymaxLoc=1.D
    if n_elements(minval) ne 0 then yminLoc=minVal
    if n_elements(maxval) ne 0 then ymaxloc=maxVal
    if alpha lt 0 then begin
        if (minvalLoc lt eps) then begin
            print,$
'warning: minval close to 0 causes r**(alpha) to blow up (alpha<0)'
        endif
        if (maxval lt eps) then begin   
            print,$
'warning: maxval close to 0 causes r**(alpha) to blow up (alpha<0)'
        endif
    endif
    yrange=[yminLoc,ymaxLoc]
    xrange=yrange^((1.+ alphaLoc))
    if xrange[0] gt xrange[1] then begin
        tmp=xrange[1]
        xrange[1]=xrange[0]
        xrange[0]=tmp
    endif
    x=randomu(0.,npts,/double)*(xrange[1]-xrange[0])+xrange[0]
    y=(x^(-1.D/(-alphaLoc-1.D)))
    if not keyword_set(dohist) then return,y
;
;   create a log,log hist and fit
;
    if not keyword_set(nbins) then nbins=npts*.005
    bin=(ymaxLoc-yminLoc)/nbins
    xh=findgen(nbins)*bin + yminLoc + bin/2.
    h=histogram(y,nbin=nbins,min=yminLoc,max=ymaxLoc)
    w=sqrt(h)
;
    ind=where(h gt 3,count)
    plot,xh[ind],h[ind],/xlog,/ylog,$
        xtitle='x',ytitle='p[x]',$
        title='log,log plot of probability histogram'
    xl=alog10(xh[ind])
    hl=alog10(h[ind])
    a=poly_fit(xl,hl,1,measure_err=1./w[ind])
    oplot,10^xl,10^poly(xl,a),color=colph[2]
    lab=string(format='("linear fit to log,log plot: const:",f," slope:",f)',$
            a[0],a[1])
    ln=3
    note,ln,lab,xp=.1,color=colph[2]
    return,y
end
