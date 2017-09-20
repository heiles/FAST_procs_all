;+
;NAME:
;aobeampatcmp - compute ao beam pattern from bessel function
;SYNTAX n=aobeampatcmp(freqMhz,diam=diam,nsdlb=nsdlb,thMin=thMin,thMax=thMax,$
;                       valMax=valMax,fwhmA=fwhmA,np=np,p=p,thD=thD)
;ARGS:
;freqMhz: float frequency in Mhz to use.
;KEYWORDS:
;   diam: float dish diameter in meters to used. The default is 225 meters.
;  nsdlb: int   number of sidelobes,nulls to compute. The default is 10.
;  np   : long  number of points to use in the beam pattern. The default
;               is 10000 points.
;RETURNS:
;    n   : int  number of sidelobes computed.
;thMin[n]: float angle (arcminutes) where nulls were found
;thMax[n]: float angle (arcminutes) where peaks were found (includes
;                main beam at 0 degrees).
;valMax[n]: float value at each peak (mainbeam and sidelobes).
;                normalized to mainbeam  = 1.
;fwhmA    : float full width at half maximum in arcminutes.
;p[np]    : float beam pattern linear scale.
;thD[np]  : float the angle (from center of beam pattern) for each point
;                 in p[n]. Units are Degrees.
;DESCRIPTION:
;   Compute a beam pattern for the arecibo telescope. See 
; tools of radio astronomy, rohlfs and wilson page 139. 
;The computation uses a circular aperture with uniform illumination (
;not quite the ao taper but...).
;
;   You specify the frequency in Mhz. The routine will compute and plot
;the beam pattern listing the first nsdlb nulls and sidelobes on the plot.
;It can pass back to the caller the computed information.
;
;-
function aobeampatcmp,freqMhz,diam=diam,nsdlb=nsdlb,np=np,thMin=thMin,$ 
            thMax=thMax,valMax=valMax,fwhmA=fwhmA,p=p,thD=thD
   common colph,decomposedph,colph
;

    if n_elements(diam) eq 0 then diam=225.  ; diameter
    if n_elements(nsdlb) eq 0 then nsdlb=10 
    if n_elements(np) eq 0 then np=10000L
    d=diam
    lambda=3e8/(freqMhz*1e6)
;
; th = angle from max power
; u  = sin(th) projection on the x axis.
;
    fwhm0=lambda/d * !radeg         ; guess for fwhm
    thMaxDeg=(nsdlb + 1) * fwhm0
;
    thD=dindgen(np)/np * thMaxDeg
    thAmin=thD*60.
    u=sin(thD*!dtor)
    
    xx=2*!dpi*u*(D/(2*lambda))   ;lambdas center to edge, in radians * u
    x=dindgen(np)
;
    P=(2.*beselj(xx,1,/double)/xx)^2
    p[0]=1.
    dif=p  - shift(p,1)
    dif[0]=dif[1] 
    ipk=lonarr(np)
    ipk[0]=1
    sgnCurPos=dif[1] gt 0.
    for i=1L,np-1 do begin &$
        sgnCur=dif[i] gt 0 &$
        if sgnCur ne sgnCurPos then ipk[i]=1 &$
        sgnCurPos=sgnCur &$
    endfor
    ii=where(ipk eq 1,cnt)
    cnt=cnt/2*2
    ii=reform(ii[0:cnt-1],2,cnt/2)
    imax=reform(ii[0,*])
    imin=reform(ii[1,*])
;
    i=where(p le .5)
    i=i[0]
    fwhmD=thD[i]*2.
    fwhmA=fwhmD*60.
    dbp=dbit(p)
    !p.multi=[0,1,2]
    ls=1 
    hor,0,fwhmA*3.
    ver
    lab=string(format='(f7.0,"Mhz"," ",f5.0,"meterIllum")',$
                    freqMhz,d)
    plot,thAmin,p,charsize=cs,$
        xtitle='Arc Minutes',ytitle='Power',$
        title='Beam pattern for uniform spherical illumination. ' + lab
    
    oplot,[0,fwhmA/2],[.5,.5],col=colph[4]
    flag,fwhmA/2.,linestyle=ls,col=colph[4]
    scl=.8
    xp=.25
    ln=2.5
    note,ln-scl,'Nulls   Th(Amin) ',col=colph[3],xp=xp
    note,ln-scl,'sdLbPk  Th(Amin) PkDb',xp=xp+.25,col=colph[2]
    for i=0,nsdlb-2 do begin &$
        lab=string(format='(i2,4x,f7.3,2x,f5.1)',i+1,thAmin[imin[i]]) &$
        note,ln+(i)*scl,lab,xp=xp,col=colph[3] &$
    endfor
    xp=xp+.25
    for i=1,nsdlb-1 do begin &$
        lab=string(format='(3x,i2,4x,f7.3,2x,f5.1)',i,thAmin[imax[i]],$
                dbP[imax[i]]) &$
        note,ln+(i-1)*scl,lab,xp=xp,col=colph[2] &$
    endfor
    ;
    ln=10
    xp=.4
    note,ln,string(format='("FWHM:",f6.2," Amin",f7.1,"Asec")',$
                fwhmA,fwhmD*3600.),xp=xp,col=colph[4]
    ver,-50,0
    hor
    plot,thAmin,dbp,$
        xtitle='Arc Minutes',ytitle='Power [db scale]',$
        title='Beam pattern (log scale)'
    flag,thamin[imax-1],linestyle=ls,col=colph[2]
    flag,thamin[imin-1],linestyle=ls,col=colph[3]
    thMin=thAmin[imin]
    thMax=thAmin[imax]
    valMax=p[imax]
    return,n_elements(thMin)
end
