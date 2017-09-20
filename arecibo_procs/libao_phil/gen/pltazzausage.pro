;+
;NAME:
;pltazzausage - plot the 2D az,za coverage.
;
;SYNTAX: pltazzausage,az,za,title=title,sym=sym,over=over,dx=dx,_extra=e
;
;ARGS:
;   az[npts]    : float azimuth positions (degrees).
;   za[npts]    : float zenith angle positions (degrees).
;
;KEYWORDS:
;    title: string label for top of plot
;      sym: int symbol to plot at each position.Default is *.
;     over:     if set then overplot this data with what is there.
;       dx:     The step size in feet along the x,y axis. default is 10 feet.
;    _extra:    extra keyword values to pass to plot and oplot routine.
;               eg (color=n).
;RETURNS:
;
;DESCRIPTION:
;   Plot the azimuth, za positions as a cartesian x,y plot. The axes are
;feet from the center of the dish (projected onto z=0). This routine can
;give an idea of how well a set of sources has covered the dish.
;-
pro pltazzausage,az,za,sym=sym,over=over,title=title,_extra=e,dx=dx
;
	forward_function dectoazza
    common colph,decomposedph,colph
    symloc=2
    if keyword_set(sym) then  symloc=sym
    if not keyword_set(dx)  then  dx=10.
    if symloc lt 0 then symloc=-symloc
    if not keyword_set(over) then over=0
    if not keyword_set(title) then title=''
    azr=az*!dtor
    zar=za*!dtor
    radius=870.
    rsin=radius*sin(zar)
    xaz=rsin*sin(azr)
    yaz=rsin*cos(azr)
    xr=!x.range
    yr=!y.range
    hor,-320,320
    ver,-320,320
    if (not over) then begin
        plot,xaz,yaz,psym=symloc,_extra=e,/isotropic,$
        xtitle='feed_west(rising)    FEET    feed_east(setting)',$
        ytitle='feed_south    FEET   feed_north',title=title
    endif else begin
        oplot,xaz,yaz,psym=symloc,_extra=e
    endelse
    if keyword_set(over) then goto,done


; plot the decs
    npts=20
    dec=fltarr(3)
    lns=2
    for i=0,38 do begin
        dec[0]=i 
        npts=dectoazza(dec,azl,zal,step=60.)
        rsin=radius*sin(zal*!dtor)
        xaz=rsin*sin(azl*!dtor)
        yaz=rsin*cos(azl*!dtor)
        lcol=4
        lns=2
        if i mod 5 eq 0 then begin
            lcol=3
            lns=0
            j=n_elements(azl)-1
            xyouts,dx+xaz[j],yaz[j],'dec'+ string(format='(i0)',i),$
                  color=colph[3]
        endif
        oplot,xaz,yaz,color=colph[lcol],linestyle=lns
    endfor
    dec[0]=18.2
    npts=dectoazza(dec,azl,zal,step=60.)
    rsin=radius*sin(zal*!dtor)
    xaz=rsin*sin(azl*!dtor)
    yaz=rsin*cos(azl*!dtor)
    lcol=2
    lns=0
    oplot,xaz,yaz,color=colph[lcol],linestyle=lns
;
;   plot za rings every 5 degs za
;
	   th=findgen(50)/49 * 360 * !dtor
    	r =fltarr(50);
		zaAr=[5,10,15]
		ls=0
		col=1
		for i=0,n_elements(zaAr)-1 do begin
			  zaL=zaAr[i]
			  r[*]=sin(zaL*!dtor) * radius
	          oplot,r,th,/polar ,linestyle=ls,color=colph[col]
		endfor
done:
	
    !x.range=xr
    !y.range=yr
    return
end
