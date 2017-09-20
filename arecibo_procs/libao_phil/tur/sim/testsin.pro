;
pro testsin,axis=axis,ln=ln,sclln=sclln
if n_elements(ln) eq 0 then ln=2
if n_elements(sclln) eq 0 then sclln=1.
if n_elements(axis) eq 0 then axis='tilt'
case axis of 
	'tilt': maxVelInPerSec=3.5
	'hor' : maxVelInPerSec=3.5
	'ver' : maxVelInPerSec=2.
endcase
nsteps=2000
thrEC=500
limAccSec=.5
DacMaxVel=1024
frq=1.
numarr=20
amplIn=.1				; amplitude in for sine wave 
test=fltarr(nsteps,numarr) 
maxVel=fltarr(numarr)	; in/sec 
maxAcc=fltarr(numarr)   ; in/sec^2
posreq=fltarr(nsteps);  ; in
posStep=0.
dat=findgen(numarr)*.1 + .1
limVel=dacMaxVel/2048.*maxVelInPerSec			;in/sec
limAcc=maxVelInPerSec/limAccSec
for i=0,numarr-1 do begin &$
	tersetup,pi,accsec=limAccSec,kithr=thrEC,freq=frq,maxvel=dacMaxVel,$
		ax=axis &$
	posReq=amplIn/pi.encToIn*sin(findgen(nsteps)*2*!pi*dat[i]/pi.STEPSPERSEC)+$
			posStep/pi.encToIn &$
	tercmp,pi,posReq &$
	test[*,i]=pi.poserr &$
	w=2*!pi*dat[i] &$
	maxVel[i]=w*AmplIn	&$  ; in/sec
	maxAcc[i]=w*w*AmplIn &$	; in/sec^2
endfor
test=test*pi.enctoin
;
; now the plots
x=findgen(nsteps)/200.
xp=.4
!x.style=1
!y.style=1
title=string(format=$
'("1in step then sinWave. bw=1hz,damp=.707.accTm=",f3.1,"sec,maxVel=",i4)',$
	limAccSec,DacMaxVel)
ver,-.01,.01
hor
;ver,-.003,.003
;hor,0,4
numarrpl=10
for i=0,numarrpl-1 do begin &$
	col=(i) mod 10 + 1 &$
	if (i eq 0) then begin &$
		plot,x,test[*,i],title=title,xtitle='secs',ytitle='posErr [in]',$
		col=col &$
	endif else begin &$
		oplot,x,test[*,i],col=col &$
	endelse &$
	note,ln+i*sclln,string(format='(f4.2)',dat[i]),color=col,xp=.1 &$
endfor
lab=string(format='("axis:",a," KiThresh=",i4)',axis,thrEC)
note,ln,lab
lab='sin wave:.1in*sin(frq) step frq=.1 to 1 hz'
note,ln+1,lab
return
end
