;
pro testacc,axis=axis,ln=ln
if n_elements(ln) eq 0 then ln=3
if n_elements(axis) eq 0 then axis='tilt'
numarr=10
tacc=fltarr(2000,numarr)
acc=(findgen(numarr)+1.)*.1 
maxvel=1024
kithr=500
kf=1.
offset=.05
freq=1.
ver,-.7,1
hor,2.,7
hormid=(2.+7)/2 + 1.5
for i=0,numarr-1 do begin &$
	tersetup,pi,accsec=acc[i],kithr=kithr,freq=freq,maxvel=maxvel,kf=kf,$
		ax=axis &$
	tercmp,pi,100000 &$
	tacc[*,i]=pi.poserr &$
endfor
x=findgen(2000)/200.
xp=.3
stripsxy,x,pi.encToIN*tacc,0,.05,xtitle='secs',ytitle='posErr [in]',$
	title='5in tert move, freq=1hz,damping=.707 vary accTime',/stepcol
	lab=string(format=$
'("maxvel=",i4," dacCnts kithr=",i4," encCnts,kf=",f3.1)',$
			maxvel,kithr,kf)
	note,ln,lab,xp=xp
	col=1
for i=0,numarr-1 do begin &$
	lab=string(format='(f4.2," secs")',acc[i]) &$
	xyouts,hormid,i*offset,lab,color=col &$
	col=(col mod 10) + 1 &$
endfor
return
end
