;
numarr=20
tacc=fltarr(2000,numarr)
acc=findgen(numarr)*.1 + 1./numarr
for i=0,numarr-1 do begin
	tersetup,pi,accsec=acc[i],kithr=200,freq=1.,maxvel=500 
	tercmp,pi,100000
	tacc[*,i]=pi.poserr
endfor
x=findgen(2000)/200.
xp=.4
stripsxy,x,pi.encToIN*tacc,0,0,xtitle='secs',ytitle='posErr [in]',$
	title='5" tert move, freq=1hz,damping=.707,accTm .05 to 1.95 by .05 secs'
	note,3,'maxVel=500 Dac Counts, KiThreshold=200 EncCnts',xp=xp
end
