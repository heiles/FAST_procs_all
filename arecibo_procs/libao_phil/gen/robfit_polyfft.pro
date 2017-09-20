;+
;NAME:
;robfit_polyfft - automatic baselining of a function
; 
;SYNTAX:  istat=robfit_polyfft(ydat,yfit,maskused,coef,$
;                         edgefract=edgefract,masktouse=masktouse,$
;                         nsig=nsig,ndel=ndel,maxloop=maxloop,$
;                         deg=deg,sub=sub,verbose=verbose,fsin=fsin,
;                         double=double,plver=plver
;ARGS:   
; ydat[n]       input data to baseline. 
;
;KEYWORDS :   
;edgefract[2]: float The fraction of each edge of the bandpass to not use
;                 in the computations. if n=1 then use the same fraction for 
;                 both sides. If n=2 then use [0] for the left edge and [1] for
;                 the right edge. The default value is .08.
;                 The keyword masktouse will override this option.
;masktouse:fltarr[n] if provided,then use this rather than edgefract for the
;                 starting mask. This allows to you to force certain
;                 areas to not be included in the fit. 0--> exclude
;     nsig: int   The rms loop will throw out all outliers greater than
;                 nsig*sigma. By default nsig is 3.
;     ndel: int   The number of extra channels to remove whenever we
;                 throw out a channel because of large rms. def=1
;  maxloop: int   When removing outliers in the rms loop, it will continue
;                 looping until no points are removed or maxloop iterations
;                 is hit. By default maxloop is 15.
;      deg: int   maximum degree of polynomial fit. 
;                 The routine starts at order 1 and iterates the
;                 rmsloop,fit iterating the degree after each pass
;                 until the last fitorder done is deg. By default deg is 1.
;     sub :       if set then return the data-blfit rather than the fit.
; verbose :       1 plot status after each fit, stop after last fit of plot
;                 2 plot status each fit, stop after each plot
;                 3 plot status each rms loop. stop each plot
;                -1 same as 1 but don't wait..
;    fsin : int   the order of cos(nx),sin(nx) to also fit.
; double  :       if set then fit using double precision
; plver[2]:float  vertical range [min,max ]to use for plotting bandpasses
;                 (before subtraction). the default is autoscaling.
;                 
;RETURNS  :
; yfit    :fltarr(n) the baselined fits or ydat-yfit if /sub set.
; maskused:fltarr(n) the mask used for the fits.
; coefInfo:{}     structure holding the coef's for the fit of each sbc
;   istat : int   1 if all the fits done, 0 if one or more sbc not fit.
;
;DESCRIPTION:
;   robfit_polyfft will automatically create a mask and then use it to baseline
;a functionn. The input is an array of data. It will
;return the masks created, the coefs of the fits, and the fits. It will
;optionally remove the fits from the input data and return the difference
;data-fit. The verb= option will plot the data as the fitting is done.
;The routine can be used for mask creation (just ignore the fits)
;or mask creation and baselining.
;
; NOTE:
; You must .compile robfit_polyfft once before using the routine since
;the fitting funtion is embedded in the file.
; ----------------------------------------------------------------------
;
;   The parameters that control the algorithm are:
;
;edgefract: This is the fraction of points on each edge of the data that
;           are not used. The default is .08 . For a sbc 1024 points this
;           would ignore 82 points on each edge.
;masktouse: This is a mask with 0's and 1s. The 0 parts will not be
;           used in the fits.
;
;deg:   The maximum degree for the fit. The default is 1. Values larger
;       than 12 or 13 may have pivot errors in the fitting. 
;
;ndel:  The number of extra channels to throw out on the left and right
;       of each new channel we delete. This insures that skirts of 
;       lines don't get included in the mask.
;
;nsig   : The rms computation removes all points greater than nsig*sigma.
;         By default nsig is set to 3.
;
;maxLoop: The rms removal loops until there are no points within Nsigma*sigma
;         or maxloop iterations have occured. By default maxLoop is 15.
; ---------------------------------------------------------------------------
;ALOGORITHM:
;
;0. compute the starting points to use from the edge fraction or the masktouse.
;   The excluded points will never be included in the mask selection or fits.
;   let x0 by the x points, y0 be the y points after this selection.
;
;1. set fitOrder=0, set yfit=mean(y0)
;
;2. set  yresiduals= y0  - yfit
;
;   the rms loop starts here 
;
;3. compute the rms of yresiduals
;
;4. remove all points in y with yresiduals gt nsig*sigma . 
;   For each point removed, also remove ndel adjacent points (determined
;   by the ndel keyword).
;   
;5. if the number of points removed in 4 is gt 0 and we've looped lt maxloop 
;   times then goto 3.
;
;   fitting .. we now have a set of points within nsig of the mean.
;
;6. fitdeg=fitdeg+1   
;7. fit a polynomial of fitDeg and a harmonic function of order fsin
;   to the points left in y.
;
;8. evaluate the fitted function for the entire dataset y0
;   yfit=poly(x0,coef). 
;
;9. If fitdeg lt keyword deg goto 2.
; ---------------------------------------------------------------------------
;The coef structure returns the fit results:
;
; {corcoef}: 
;         deg     : int    of polynomial fit
;         fsin    : int    of harmonic fit
;         npnts   : int    number pnts in ydata
;coefAr[(deg+1)+fsin*2]: float  coef for each fit. the polynomial
;                                  coef are followed by the cos,sin coef.
;         rms: float        of the fitted region within the mask
;   maskFract: float        npointsmask/pntsData
;
;   To use the coefficients to recompute the fit, the x values should go
;from -pi to +pi If Nchn is the number of channels in the spectra then
;   x=((findgen(Nchn)/(Nchn-1.) - .5)*2.*pi
;
;EXAMPLES:
;
;1. Use a polynomial fit of 3, remove the fit from the data, plot the
;   data and stop after each sbc done:
;
;   istat=robfit_polyfft(ydat,yfit,maskused,coefinfo,deg=3,/sub,verb=1)
;;  plot the datafit with the mask overplotted  
;   plot,yfit,cmask=maskused
;
;2. Use a polynomial fit of 2 and a harmonic fit of 2. Create a mask
;   to use before calling this. Plot the results without stopping for keyboard
;   input
;
;   istat=robfit_polyfft(ydat,yfit,maskused,coefinfo,deg=2,fsin=2,/sub,$
;               masktouse=masktouse,verb=-1)
;
;   On return :
;   coefinfo.coefar[0:2,  are the c0,c1,c2 of the polynomial fit and
;   coefinfo.coefar[3:4]  are the cos(x) sin(x) amplitudes while
;   coefinfo.coefar[5:6]  are the cos(2x) sin(2x) amplitudes 
;
;	This routine was ripped off from corblauto and made to work with a
;generic float array (rather than a correlator datastructure).
;SEE ALSO: corblauto
;-
;history:
; 27feb11: stole from corblauto
; --------------------------------------
;   here is  the function to evaluate
;
; assume x in radians (-pi,pi)
function fitpolyfftfunc,x,m
    common robfit_polyfftcom,sinOrder,polyOrder

    ret=[1.]
    z=x
    for i=1,polyOrder do begin 
        ret=[ret,[z]] 
        z=z*x 
    endfor
    for i=1,sinOrder do ret=[ret,[cos(i*x)],[sin(i*x)]]
    return,ret
end
;
function robfit_polyfft,ydat,yfit,maskused,coefI,$
                   edgefract=edgefract,nsig=nsig,ndel=ndel,maxloop=maxloop,$
                   deg=deg,sub=sub,verbose=verbose,fsin=fsin,$
                   double=double ,masktouse=masktouse,plver=plver
    common robfit_polyfftcom,sinOrder,polyOrder
    common colph,decomposedph,colph
    forward_function fitpolyfftfunc
; 
;    on_error,1
;
;   setup the defaults
;
    retstat=1
	npnts=n_elements(ydat)
;
    ps= !d.flags and 1
;
    if n_elements(deg)       eq 0 then deg = 1
    if n_elements(nsig)      eq 0 then nsig=3
    if n_elements(ndel)      eq 0 then ndel=1
    if n_elements(maxloop)   eq 0 then maxloop=15
    if n_elements(edgefract) eq 0 then edgefract=.08
    if n_elements(verbose)   eq 0 then verbose=0
    if n_elements(fsin)      eq 0 then fsin=0
    if (verbose ne 0 ) then !p.multi=0
    edgefractLoc=edgefract
    if n_elements(edgefractLoc) eq 1 then edgefractLoc=[edgefract,edgefract]
    a=size(masktouse)
    useinpmask= (n_elements(masktouse) gt 0) and (a[0] ne 0) and $
                (a[n_elements(a)-2] ne 7) ;
    ;                                               instead of edgefraction
    sinOrderTot =fsin
    polyOrderTot=deg
    nparmsFitTot=polyOrderTot+1 + sinOrderTot*2
;
;   figure out the colors to use
;    create the coefInfo structure
;
    coefI={     deg   : 0             ,$;polynomial fit order
                fsin  : 0             ,$;harmonic fit order
                npnts :npnts          ,$;
                coefAr:fltarr(sinOrderTot*2+polyOrderTot+1),$;coef from fit 
                rms   :0.  ,$; of fit inside the mask
                maskFract:0.}  ;fraction of band used for fit
    coefI.deg=deg
    coefI.fsin=fsin
;
;   create the masks, all zeros 
;
    maskused=fltarr(npnts)
    yfit=ydat
;
;   x is -pi to pi for all fits
;
    x=(findgen(npnts)/(npnts-1.) -.5) *2. * !pi
    if abs(verbose) ne 0 then xi=lindgen(npnts)
    if not useinpmask then begin
    	i1=long(edgefractLoc[0]*npnts)
        i2=npnts-long(edgefractLoc[1]*npnts)
        ind0=lindgen(i2-i1+1)+i1
    endif
;
;       create the remXX arrays used for deleting to the left,and right of pnts
;       just shift the indices by 1 to ndel. We then index into them with 
;       the new indices to delete and set these extra points to 0
;
    if (n_elements(iirem) ne npnts) and (ndel gt 0) then begin
    	iirem=indgen(npnts)
        remRight=intarr(npnts,ndel)
        remLeft =intarr(npnts,ndel)
        for i=0,ndel-1 do begin 
        	remRight[*,i]=shift(iirem,-(i+1)) 
            remRight[npnts-1-i-1:npnts-1,i]=npnts-1 
            remLeft[*,i]=shift(iirem, (i+1)) 
            remleft[0:i+1,i]=0
        endfor
    endif
;
;       loop on polarizations
;
    if useinpmask then ind0=where(masktouse ne 0.)
    y0=ydat
    yfit=mean(y0[ind0])
;
;   fit loop step polyFit .. use full harmonic fit
;
    for ideg=1,coefI.deg+1 do begin
    	degToUse= ideg < coefI.deg
        ind=ind0
        y=ydat-yfit
        rmsloopDone=0
        rmsloop=0
; 
;               rms loop
;
        while not rmsloopDone do begin
        	lastRms=rms(y[ind],/quiet)
            ii=where(abs(y[ind] - lastRms[0]) gt nsig*lastRms[1],countcmp)
            if countcmp eq 0 then begin
            	rmsloopDone=1
            endif else begin
;
;           here is where we remove ndel extra points from the
;           right and left of the ones we just found
;
            	m=intarr(npnts) 
           		m[ind]=1                ; we've kept from before &$
            	m[ind[ii]]=0            ; new ones to dump
            	if abs(verbose) eq 3 then iisave=ind[ii]
            	for j=0,ndel-1 do begin ; 0 the req num left, right
            		m[remRight[ind[ii],j]]=-(j+1) ; dump on right
               		m[ remLeft[ind[ii],j]]=-(j+1) ; dump on left
            	endfor 
            	ind=where(m eq 1)       ; new set to keep
            endelse
            rmsloop=rmsloop+1
            if abs(verbose) eq 3 then begin
            	print,'sbc:',ibrd+1,' rmsl:',rmsloop,' count:',$
                      countcmp,' done:',rmsloopDone
                if n_elements(plver) eq 2 then begin
                	ver,plver[0],plver[1]    
                endif else begin
                    ver
                endelse
                if n_elements(m) gt 0 then begin
                	ii1=where(m lt 0,count1)
                endif else begin
                    count1=0
                endelse
                lab=string(format=$
'(" fit:",i2," rmsloop:",i2," sig:",f6.4," rmsRej:",i3," ndel:",i3)',$
                degToUse,rmsloop+1,lastRms[1],countcmp,count1)
                tit=string(format='("plotting rms loop. lastfit:",i2)',$
                               degToUse-1)
                plot,xi,y,xtitle='chan',title=tit
                ln=3
                xp=.04
                note,ln   ,'rejected (total)',color=colph[2],xp=xp
                note,ln+1,'rejected (ndelete)',color=colph[3],xp=xp
                note,ln+2,'rejected (from rms)',color=colph[4],xp=xp
                note,23,lab,xp=.14,charsize=1.4
                if n_elements(m) gt 0 then begin
                	ii0=where(m ne 1,count0)
                endif else begin
                     count0=0
                endelse
                if count0 gt 0 then oplot,xi[ii0],y[ii0],psym=2,$
                             color=colph[2]
                if count1 gt 0 then oplot,xi[ii1],y[ii1],psym=2,$
                             color=colph[3]
                if n_elements(iisave) gt 0 then $
                            oplot,xi[iisave],y[iisave],psym=2,color=colph[4]
                if verbose gt 0 then begin 
                     key=checkkey(/wait)
                   	 if key eq 's' then stop 
                endif
            endif
            if rmsloop ge maxloop then rmsloopdone=1
        endwhile
;
;       see if we do any plotting via verbose keyword
;
        doplot=(abs(verbose) ge 2) or ((abs(verbose) eq 1) $
                 and (ideg eq (degToUse + 1)))
        if doplot then begin
         	!p.multi=[0,1,2]    
            if n_elements(plver) eq 2 then begin
            	ver,plver[0],plver[1]   
            endif else begin
                ver
            endelse
            lab=string(format=$
                '(" y and fit fordeg:",i2," ndel:",i2)', degToUse,ndel)
            plot ,xi,y0,title=lab
            oplot,xi[ind],y0[ind],psym=2,color=colph[2]
            ln=3
            xp=.04
            note,ln+2,'totfit',xp=xp,color=colph[4]
        endif
;
; now try fitting
;
        sinOrder=sinOrderTot
        polyOrder=degToUse
        nParmsLoc=polyOrder+1+sinOrder*2
        if (sinOrder gt 0) or (polyOrder gt 1) then begin
        	if (lastRms[0] eq 0.) and (lastRms[1] eq 0.) then begin
            	print,'cannot fit. data constant..'
                print,'Returning..'
                return,0
            endif
         endif
         coef=svdfit(x[ind],y0[ind],nParmsLoc,double=double,$
                    function_name='fitpolyfftfunc',singular=single)
         if single eq nParmsLoc then begin
         	print,'warning fit failed..'
            return,0
         endif 
         yfit=poly(x,coef[0:degToUse])
         j=degToUse+1
         for i=1,sinOrder do begin
         	yfit=yfit + coef[j]*cos(i*x) + coef[j+1]*sin(i*x)
            j=j+2
         endfor
;
;
         if doplot then begin
         	oplot,xi,yfit,color=colph[4]
            lab=string(format=$
'("(y - fit) poly:",i2," harmonic:",i2," ndel:",i2)',degToUse,sinOrder,ndel)
            lab1=string(format= '(i1," * sigma (before current fit)")',nsig) 
            xp=.04
            ln=3
            ver,-(2*nsig)*lastRms[1],(2*nsig)*lastRms[1]
            plot,xi,y0 -yfit,title=lab
            oplot,xi[ind],y0[ind]-yfit[ind],psym=2,color=colph[2]
            ysig=nsig*lastRms[1]
            oplot,[-1.,1],[ysig,ysig],color=colph[3]
            oplot,[-1.,1],[-ysig,-ysig],color=colph[3]
            oplot,[0,npnts],[ysig,ysig],color=colph[3]
            oplot,[0,npnts],[-ysig,-ysig],color=colph[3]
            ln=16
            note,ln,lab1,xp=xp,color=colph[3]
            note,ln+1,'pnts used for fit',xp=xp,color=colph[2]
            aa=rms(y0[ind]-yfit[ind],/quiet)
            lab2=string(format='("rmsSelected pnts:",f8.4)',lastRms[1])
            note,ln+2,lab2,xp=.04,charsize=1.4
            !p.multi=0
            if verbose gt 0 then begin
            	print,'deg:',degToUse,' xmit to cont'
                key=checkkey(/wait)
                if key eq 's' then stop 
             endif
         endif
     endfor
     coefI.coefAr[*]=coef
     coefI.rms=(rms(y0[ind]-yfit[ind],/quiet))[1]
     coefI.maskFract=n_elements(ind)/(npnts*1.)
     maskused[ind]=1
     if keyword_set(sub) then begin
     	yfit=y0 - yfit
      endif 
    return,1
end
;

