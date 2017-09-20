; pmbase   - function to remove baseline
; pmbaseg  - remove baseline using gauss fit to noise bump
; turpos   - compute turret position
; dblevels - compute dblevels for contours
; pmaxis   - compute turret, dome axis arrays
; pmpostm  - position to a start of run via start dat,start src
;
; contour plotting..
;  1. for alignment use the phase from fit and include the
;     time constant (since this shifts the phase a little).
;     I found that if you used the exact values, the contour would hang
;     with colinear pnts.. so i added an offset of .00006 in pmdone.
;history:
;.............................................................................
function pmbase,pmi,y,linfit=linfit
;
; remove the baseline using a linear baseline and then
; removing the average of one turret cycle from each edge
;
; ARGS:
; 	  y       - holds the data
; 	  ncycles - how many turret cycles are in x
;KEYWORDS:
;	  linfit  - return the coef of linear fit a[2], a[0] +a[1]*x
;
	len=pmi.samplesPerStrip
	ncycles=long(pmi.secsPerStrip*pmi.turFrqH + .5)
	cyclelen=long(pmi.samplesPerStrip/ncycles + .5)
;
;	compute the weight array
;
	tmp=fltarr(len)				;the weight array
	tmp(0:cyclelen-1)=1.
	tmp(len-cyclelen:len-1)=1.
	result=polyfitw(findgen(len),y,tmp,1,yfit)
	if (n_elements(linfit) gt 0) then linfit=result
;
;	generate turret swing curve to subtract. average 1st/last cycle
;   don't include constant,it is already in the linear fit
;
	tmp=reform(tmp,cyclelen,ncycles)
   	tmp(*,0)=(y(0:cyclelen-1)+ y(len-cyclelen:len-1))*.5 - result(0)
;   	tmp(*,0)=(y(0:cyclelen-1) < y(len-cyclelen:len-1))   - result(0)
	for i=1,ncycles-1 do  tmp(*,i)=tmp(*,0)
    return,y-(reform(tmp,len) + yfit )
end
;.............................................................................
function pmbaseg,pmi,phase,y,linfit=linfit,tmcon=tmcon
;
; remove the baseline using a gauss fit to the average of the first and
; last cycles
;
; ARGS:
; 	  y       - holds the data
; 	  ncycles - how many turret cycles are in x
;KEYWORDS:
;	  linfit  - return the gauss fit coef.
;
	len=pmi.samplesPerStrip
	ncycles=long(pmi.secsPerStrip*pmi.turFrqH + .5)
	cyclelen=long(pmi.samplesPerStrip/ncycles + .5)
;
;
	pmaxis,pmi,phase,xt,xg,tmcon=tmcon
	x1=xt[0:cyclelen-1]
	yf=(  y[0:cyclelen-1] +y[len-cyclelen:len-1])*.5
	nterms=5
	estimates=fltarr(nterms)
	estimates[0]=20.
	estimates[1]=x1[cyclelen/2]
	estimates[2]=pmi.turampd
	estimates[3]=min(yf)
	estimates[4]=0.
    yfit =gaussfit(x1,yf ,a ,estimates=estimates,nterms=nterms)
	yb=a[0]*exp(-((xt-a[1])/a[2])^2/2.) + a[3] + a[4]*xt
;
;	compute the weight array
;
	if (n_elements(linfit) gt 0) then linfit=a
    return,(y-yb )
end
;.............................................................................
function turpos,pmi,phase,tmcon=tmcon
;
; compute turret position given
; starting values . input units are degrees, an hz
;
;     tmcon   - timeconstant secs to use.. if not set, use 0
;
	if n_elements(tmcon) eq 0 then tmcon = 0.
	smpRate=pmi.samplesPerStrip/pmi.secsPerStrip
return,pmi.turPosD+pmi.turAmpD * $
	sin((pmi.turFrqH*(findgen(pmi.samplesPerStrip)/smpRate - tmcon) +  $
		   phase/360.)*2.*!pi)
end
;.............................................................................
;
function dblevels,y,nlevels,dbstep,eps=eps
;
;  compute levels for contour that have nlevels with dbstep  starting at the max
;
    ymax=max(y)
	if n_elements(eps) eq 0 then eps=ymax*1e-3
	levels=ymax*10^(-.1*(findgen(nlevels))*dbstep)
	return, levels
end
;.............................................................................
; 
; compute axis
;
pro pmaxis,pmi,phase,xt,xg,_extra=e
;
; _extra:  tmcon=tmcon 
    xt=turpos(pmi,phase,_extra=e)
    xg=(findgen(pmi.samplesPerStrip)/(pmi.samplesPerStrip)*2. - 1.) * $
				abs(pmi.zaOffSTartD*60.)
	 return
end
;.............................................................................
;
pro pmcont1,phase,nlevels,dbstep,tmcon=tmcon,color=color,smo=smo,polb=polb,$
				bg=bg,inpbuf=inpbuf,tccor=tccor,gcaz=gcaz,_extra=e
;
; contour the next one we are pointing at..phase should be the phase
; for this  strip
; bg - baseline using gaussian fit
;
	common pmccom,pmcI,pmc,pmcb

	if n_elements(tmcon) eq 0 then tmcon=0.
	if n_elements(color) eq 0 then color=0
	if n_elements(smo) eq 0 then smo=0
	if n_elements(polb) eq 0 then polb=0
	if n_elements(tccor) eq 0 then tccor=0 
	tmconl=tmcon ; contour would hange if we used exact solution
							; from fit..
;
; 	input the data to common block
;
	if n_elements(inpbuf) eq 0 then begin
	cget
    if  pmci.iostat ne 1 then  begin
		print,"error inputing strip",pmci.stripreq
		return
	endif
;
;	baseline
;
	if  polb eq 0  then begin
		polind=0
		pol='a'
	endif else begin
		polind=1
		pol='b'
	endelse
;
; 	if correct for time constant.. do it here..
;
	if tccor ne 0 then begin
		ctccor,tccor,pol=pol 
		tmconl=tmconl-tccor		;; we moved by this much..
	endif
	if keyword_set(bg) then begin
		pmcb=fltarr(pmc.pmi.samplesperstrip,2)
		if (smo gt 1 ) then  begin
			pmcb[*,polind]=pmbaseg(pmc.pmi,phase,smooth(pmc.d[*,polind],smo),$
				linfit=linfit,tmcon=tmconl)
		endif else begin
			pmcb[*,polind]=pmbaseg(pmc.pmi,phase,pmc.d[*,polind],$
				linfit=linfit,tmcon=tmconl)
		endelse
	endif else begin
		cbase,pol=pol,smo=smo
	endelse
	ybase=pmcb[*,polind]
	endif else begin
		ybase=inpbuf
	endelse
;
;	 compute contouring levels
;
	levels=dblevels(ybase,nlevels,dbstep)
	levels=levels(sort(levels))
;
;	compute x,y axis for contour plot
;
	pmaxis,pmc.pmi,phase,xt,xg,tmcon=tmconl
	if (pmc.pmi.zaOffStartD > 0) then xg=reverse(xg)
	if keyword_set(gcaz) then begin
		xt=(pmc.pmi.turPosD-xt)*(-45.)/60.
		xtitle='az offset [Amin great circle]'
	endif else begin
		xtitle="turret position [deg]"
	endelse
;
	title=string(format=$
'("az:",f6.2," za:",f5.2," dbstep:",i0," mincon:",i0," strip:",i0)', $
	  pmc.pmi.az,pmc.pmi.za,dbstep,dbstep*(nlevels-1),pmc.pmi.stripNum)

;;	triangulate,xt,xg,tri
;
;	to catch any contour errors..
;
	error_status=0
    catch,error_status
	if error_status ne 0 then begin
		lab=string(format='("scan:",i9," strip:",i4," err:",i6)',$
				pmc.h.std.scannumber,pmc.pmi.stripnum,error_status)
		print,lab
		print,' errmsg:',!err_string
		retall
	endif
;
;	 call contour with optional colors
;
	if color ne 0 then begin
		colind=reverse(indgen(nlevels))
		contour,ybase,xt,xg,/irregular,levels=levels,/fill,c_color=colind,$
			title=title,_extra=e,/close, $
			xtitle=xtitle,ytitle="dome offset [amin]"
	endif else begin
		contour,ybase,xt,xg,/irregular,levels=levels,title=title,$
			xtitle=xtitle,ytitle="dome offset [amin],_extra=e"
	endelse
	return
end
;.............................................................................
;
; loop contouring ..
;
pro pmcont,toloop,phase,nlevels,dbstep,delay,_extra=e ,step=step,gcaz=gcaz
;
; _extra  .. tmcon=tmcon,/color,smo=n,/polb,/bg,tccor=tccor,plotting
	common pmccom,pmcI,pmc,pmcb

	step=keyword_set(step)
	tst=' '
;
;	 position to requested strip
;
	cpos,iook 
	if iook ne 1 then begin
		print,"error positioning to scan.."
		return
	endif
	Dnlevels=8
	Ddbstep =3
	Ddelay  =.5
	nparms=n_params()
	if (nparms lt 3) then nlevels=Dnlevels
	if (nparms lt 4) then dbstep =Ddbstep
	if (nparms lt 5) then delay  =Ddelay
	for i=0,toloop-1 do begin 
		print,i
        pmcont1,phase[i],nlevels,dbstep,gcaz=gcaz,_extra=e
		if (pmci.iostat ne 1) then return
		if  step eq 0 then begin
			wait,delay
		endif else begin
			read,'xmit to cotinue, q to quit:',tst
			if (tst eq 'q') or (tst eq 'Q') then goto,done
		endelse
	endfor
done:
	return
end
;.............................................................................
;
pro pmload, lun,bb,scan,maxrecs
;
; load entire scan into bb
;
	if (n_params() lt 4) then maxrecs=999
	point_lun,-lun,curpos
	numrecs=maxrecs
	for i=1,maxrecs do begin
		if ( posscan(lun,scan,i) ne 1) then  begin
			numrecs=i-1
			goto,cont1
		endif
	endfor
cont1: 
;	print,'numrec',numrecs
	point_lun,lun,curpos
	istat=pmget(lun,b)
	if  istat ne 1 then return
	nstrips=numrecs/b.pmi.recsperstrip
	bb=replicate(b,nstrips)
    bb[0]=b
	for i=1,nstrips-1 do begin
		istat=pmget(lun,b)
		if istat ne 1 then return
		bb[i].h  =b.h
		bb[i].d  =b.d
		bb[i].pmi=b.pmi
	endfor
	return
end
;.............................................................................
function pmturedg,y,xt,degatedg
;
; fit polynomial to y, using ndeg from the turret extremes
;
	deg=2
	ylen=n_elements(y)
	yfit=fltarr(ylen)
	mintur=min(xt)
	maxtur=max(xt)
	wts=fltarr(ylen)
	indarr=where( (xt lt (mintur+degatedg)) or (xt gt (maxtur-degatedg))) 
	wts[indarr]=1
  	result=polyfitw(xt,y,wts,deg,yfit)
	print,result
	return,yfit
end
;
pro junk,b,startPh,endPh,stepPh,delay

	for ph=startPh,endPh,stepPh do begin
		xt=turpos(b.pmi,ph)
		plot,xt,b.d(*,0)
		print,"phase: ", ph
		wait,delay
	endfor
	return
end
