;
; try and compute shim positions 
;
; do a linear ramp for current values.
; assume length of bar is D feet.
;
; try it 2 different ways:
; 1- assume optic axis goes through the center
; 2- optic axis is 1.1113 deg uphill from center of beam
;    changes za value for yp2,yp1.
;
hard=1
if hard then pscol,'shimcmp.ps'
R=420.75	                 ; use rolling surface
Beam=21.5                 ; 21 feet between trolleys.
width = 146.5             ; inches between the rails
dzhbm= asin(Beam/2./R)*!radeg ; half angle beam subtends
thopAx=1.1113			  ; optic axis offset  this many deg uphill from center
za1=10.
za2=22
dpMax=.125 * 1.2         ; total pitch change start to 20 degrees, scaled to 22
drmax = .00 * 1.2         ; total roll change, start to end (0.8 to 20 degrees)
dpdz=dpMax/(za2-za1)	 ; change in slope per za
drdz=drMax/(za2-za1)	 ; change in slope per za
;
; dp=dpdz*(za-za1)
;
; the change in pitch is just:
; asin((yp2-yp1)/Beam) where dp2,dp1 are the changes from the
; original positions (we assume the original positions are 0)
; y(za)
zastp=.1
zamax=25
nstp=(zamax/zastp)
za=findgen(nstp)*zastp		; in .1 za steps
yp  =fltarr(nstp)
ypoa=fltarr(nstp)
rpoa=fltarr(nstp)
;
for i=0,nstp-1 do begin
	if za[i] gt za2 then goto,done;
	if za[i] gt za1 then begin ; we shim above here
;
; 	figure out za position of edges of beam
;
		z1=za[i]-dzhbm		   ; za of lower part of beam
		z2=za[i]+dzhbm         ; za of upper part of beam
;
;	for a. use optic axis offset
;
		zoa1=za[i]-dzhbm-thOpAx ; za of lower part of beam
		zoa2=za[i]+dzhbm-thOpAx ; za of upper part of beam
		ind1=long(z1/zastp)     ; index for lower part
		ind2=long(z2/zastp)     ; index for upper part
		indoa1=long(zoa1/zastp)     ; index for lower part
		indoa2=long(zoa2/zastp)     ; index for upper part
		dp=dpdz*(za[i]-za1)   ; pitch change we want at this point
		dr=drdz*(za[i]-za1)   ; roll change we want at this point
;
;	    dp=asin((yp2-yp1)/beam)
; so    sin(dp)*beam=(yp2-yp1)
; or    yp2=sin(dp)*beam+yp1
		yp[ind2]=yp[ind1]+sin(dp*!dtor)*beam
		ypoa[indoa2]=ypoa[indoa1]+sin(dp*!dtor)*beam
		rpoa[indoa2] = sin(dr*!dtor) * width
	endif
endfor
done:
yp=yp*12
ypoa=ypoa*12
ypr=yp/cos(za*!dtor)
ypoar=ypoa/cos(za*!dtor)
hor,10,23
ver,0,1.8
plot,za,yp,$
xtitle='za',ytitle='vertical change [inches]',$
title='Motion needed for shimming vs za'
oplot,za,ypoa,color=3
ln=3
note,ln  ,'vertical motion',xp=xp
note,ln+1,'shim length',xp=xp,color=2
note,ln+2,'Vertical motion (with optic axis offset)',xp=xp,color=3
note,ln+3,'shim length     (with optic axis offset)',xp=xp,color=4
note,ln+4,'* Panel points (shim locations)',xp=xp
;
oplot,za,ypr,color=2 
oplot,za,ypoar,color=4 
flag,findgen(10)*dzhbm+10,linestyle=2
ln=35
xp=.05
scl=.8
lab=string(format=$
'("linear ramp pitch 0 to ",f5.3,"deg. For za:",f4.1," to ",f4.1)',$
	dpMax,za1,za2)
note,ln,lab,xp=xp
lab=string(format='("beam length:",f4.1,"ft (",f5.3," deg half angle)")',$
	beam,dzhbm)
note,ln+1*scl,lab,xp=xp
note,ln+2*scl,'flag beam half angles',xp=xp
shimpnts,shimnm,shimza
;
; evaluate the shim length at each point
nshims=n_elements(shimza)
shimval  =fltarr(2,nshims)
shimvaloa=fltarr(2,nshims)
shimdifoa=fltarr(nshims)
ln=ln+3
lnoa=ln+10*scl
note,lnoa,'shimming using optical axis offset for y1,y2 position',xp=xp
;lnoa=lnoa+1
j=0
for i=0,nshims-1 do begin &$
	ind=where(za ge shimza[i]) &$
	shimval[0,i]=ypr[ind[0]] &$
	shimval[1,i]=yp[ind[0]] &$
	shimvaloa[0,i]=ypoar[ind[0]] &$
	shimvaloa[1,i]=ypoa[ind[0]] &$
    shimdifoa[i] = rpoa[ind[0]] &$
	if shimval[0,i] ne 0.0 then begin  &$
		lab=string(format=$
'("panel pnt:",f4.1," za:",f5.2,"  Shim:",f5.3," VertDelta:",f5.3," inches")',$
		shimnm[i],shimza[i],shimval[0,i],shimval[1,i]) &$
		note,ln+j*scl,lab,xp=xp &$
		j=j+1 &$
	endif &$
	if shimvaloa[0,i] ne 0.0 then begin  &$
		lab=string(format=$
'("panel pnt:",f4.1," za:",f5.2,"  Shim:",f5.3," VertDelta:",f5.3," inches")',$
		shimnm[i],shimza[i],shimvaloa[0,i],shimvaloa[1,i]) &$
		note,lnoa+j*scl,lab,xp=xp &$
	endif &$
endfor
oplot,shimza,shimval[0,*],psym=2,color=2
oplot,shimza,shimvaloa[0,*],psym=2,color=4
if hard then hardcopy
x
;
; fit polynomial to za 11 through 20 to shimr
;
ind=where((shimza ge 11) and (shimza le 19.5),count)
x=shimza[ind]
y=shimval[0,ind]
deg=2
shimRadFit=poly_fit(x,y,deg,yfit)
plot,x,y
oplot,x,yfit,color=2
;
y=shimvaloa[0,ind]
deg=2
shimRadFitoa=poly_fit(x,y,deg,yfit)
oplot,x,y,color=3
oplot,x,yfit,color=4
;
end
