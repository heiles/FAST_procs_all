;+ 
; arrpltazza -  arrow plot of source function vs az,za
;SYNTAX: arrpltazza,srcinp,srcout,az,za,y,tit,tickLen,unitName,sbc=sbc,pol=pol
;					rotmin=rotmin,rotabs=rotabs
;ARGS:
;		srcinp[]:	{PFSRCINFO} holds source name info
;		srcinp[]:	{PFSRCOUT} holds source name info
;		az[npts]:	float azimuth deg
;		za[npts]:	float za deg
;		 y[npts]:	float data points y(az,za) to plot
;		     tit:  string. title.. keg 'Gain K/Jy'
;		 tickLen:	float in units of y. eg 5. if 1tick=5 K/Jy
;		 unitName:	string for above tickLen. eg 'K/Jy'
;KEYWORDS:
;	sbc:	int 0-3.. sbc to plot .. default first:
;	pol:	int 1,2   pol to use. default 1
;rotmin:   	if set then scale rotation from min,not max
;rotabs:   	float use fixed value for rotation of 180 degrees
;-
pro arrpltazza,srcinp,srcout,az,za,yin,tit,tickLen,unitName,$
				hard=hard,sbc=sbc,pol=pol,rotmin=rotmin,rotabs=rotabs
;
; we only have the magnitude so make the length of the vectore
; len : 0 to 10 
; angle:180degrees = 50% down from max
;         90 - (1- (g/maxg))*360
; for hard copy: 
;  change xpsrcl,-.1 -> -.2
;
	xpsrcl=-.1				; where source names go for screen	
	xpsrcr=1.

	if keyword_set(hard) then xpsrcl=-.2	;for printer
	if not keyword_set(pol) then pol=1
	pol=pol-1
	if n_elements(sbc) eq 0 then sbc=0
	yloc=yin[pol,sbc,*]
	maxfile=max(srcinp.srccol)
	azrad=!dtor*az
	sclPos=1.
; 	arrow head fraction (of length)
	arrowHd=.2
;
; 	scale arrow to requested length
	sclArrow=1./tickLen
;
; setup the axis... no data
;
	th=findgen(50)/49 * 360 * !dtor
	r =fltarr(50);
	create_view
	plot,th,r,xrange=[-21,21],yrange=[-21,21],/nodata, $
		ytitle="west (rising) ",/xstyle,/ystyle
;
;  lines constant za
;
	for a=5,20,5 do begin $
  		r(*)=a  & $
;  		print,r[1] & $
 		 oplot,r,th,/polar & $
	endfor
;
;  lines constant angle
;
	r=20.*findgen(50)/50.
	for a=0,360,30 do begin $
  		th= (fltarr(50) + a) * !dtor & $
  		oplot,r,th,/polar & $
	endfor
;
	arrowmag  =abs(sclArrow*yloc)
	if n_elements(rotabs) ne 0  then begin
		maxy=max(yloc)
		arrowangle= (90. - (yloc/rotabs)* 180.)*!dtor
	endif else begin
		if not keyword_set(rotmin) then begin
			maxy=max(yloc)
			arrowangle= (90.- (1- yloc/maxy)*360)*!dtor
		endif else begin
			miny=min(yloc)
	 		arrowangle= (90.- (1- miny/yloc)*360)*!dtor
		endelse
	endelse
	xerr=arrowmag*cos(arrowangle)
	yerr=arrowmag*sin(arrowangle)
;
;	 the offset for this az,za point put in center of plot
; 	make right of plot be east, top north, left west
;
	x=sclPos*za*cos(!pi/2. - azrad) 
	y=sclPos*za*sin(!pi/2. - azrad) 
	nsrc=(size(srcinp))[1]
	for i=0,nsrc-1 do begin
		ind=where(srcout.srcnum eq i)
		col=(i mod 10 ) + 1
		arrow,x[ind],y[ind],x[ind]+xerr[ind],y[ind]+yerr[ind],/data,$
			hsize=-arrowHd,color=col
		j=i+1
   	 	inc=0
    	xp=xpsrcl
    	if j gt 28 then begin
       		j=j-28 
       		xp=xpsrcr
    	endif
    	note,j,srcinp[i].name,xp=xp,color=col
	endfor
done:
	xp=.02
	note,1,tit + ' vs az,za by src',xp=xp
	note,2,string(format='("1 div=",f5.2,a)',tickLen,unitName),xp=xp
	if keyword_set(rotabs) then begin
		note,3,string(format='("angle:180 deg= ",f5.2)',rotabs),xp=xp
	endif else begin 
		if keyword_set(rotmin) then begin
			note,3,'angle:180 deg=Min*2',xp=xp
		endif else begin
			note,3,'angle:180 deg=Max/2',xp=xp
		endelse
	endelse
	xyouts,-2,-21,'SOUTH (feed)'
	xyouts,-2,20, 'NORTH (feed)'
;
; compute max,avg,rms in 5 degree increments
;
	a=fltarr(3,5)
	aa=rms(yloc)
	a[0,0]=max(yloc)
	a[1,0]=aa[0]
	a[2,0]=aa[1]
;
	ind=where(za le 5)
	aa=rms(yloc[ind])
	a[0,1]=max(yloc[ind])
	a[1,1]=aa[0]
	a[2,1]=aa[1]
;
	ind=where((za gt 5) and (za le 10))
	aa=rms(yloc[ind])
	a[0,2]=max(yloc[ind])
	a[1,2]=aa[0]
	a[2,2]=aa[1]
;
	ind=where((za gt 10) and (za le 15))
	aa=rms(yloc[ind])
	a[0,3]=max(yloc[ind])
	a[1,3]=aa[0]
	a[2,3]=aa[1]
;
	ind=where(za gt 15)
	aa=rms(yloc[ind])
	a[0,4]=max(yloc[ind])
	a[1,4]=aa[0]
	a[2,4]=aa[1]
;
	ln=24
	note,ln,string(format='(a," each 5deg")',tit),xp=xp
	ln=ln+1
	zar=[5,10,15,20]
	note,ln,'za max  avg  rms',xp=xp
	for i=0,4 do begin &$
		if i eq 0 then begin &$
			lab='all' &$
		endif else begin &$
			lab=string(format='(i2)',zar[i-1]) &$
		endelse &$
;		print,lab
		line=string(format='(a,f5.2,f5.2,f5.2)',lab,a[0,i],a[1,i],a[2,i]) &$
		note,ln+1+i,line,xp=xp &$
	endfor
end
