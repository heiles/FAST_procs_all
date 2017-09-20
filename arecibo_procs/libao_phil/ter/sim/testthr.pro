;
pro testthr,axis=axis,ln=ln,sclln=sclln
if n_elements(ln) eq 0 then ln=3
if n_elements(axis) eq 0 then axis='tilt'
if n_elements(sclln) eq 0 then sclln=1.
if n_elements(hora) eq 0 then hora=[2.5,4.5]
numarr=20
test=fltarr(2000,numarr)
dat=findgen(numarr)*100  
accsec=.5
maxvel=1024.
for i=0,numarr-1 do begin &$
	tersetup,pi,accsec=accsec,kithr=dat[i],freq=1.,maxvel=maxvel,ax=axis &$
	tercmp,pi,100000 &$
	test[*,i]=pi.poserr &$
endfor
test=test*pi.enctoin
;
; now the plots
;
x=findgen(2000)/200.
xp=.4
!x.style=1
!y.style=1
title=$
string(format=$
'("5in tert move, freq=1hz,damping=.707,accTm:",f3.1,"sec,maxVel:",f5.0)',$
accsec,maxvel)
ver,-.04,.04
case axis of &$
	'ver': hor,4,5.5 &$
	'tilt': hor,2.5,4 &$
	'hor': hor,2.5,4 &$
endcase
for i=0,numarr-1 do begin &$
	col=(i) mod 10 + 1 &$
	if (i eq 0) then begin &$
		plot,x,test[*,i],title=title,xtitle='secs',ytitle='posErr [in]',$
		col=col &$
	endif else begin &$
		oplot,x,test[*,i],col=col &$
	endelse &$
	val1=.005*i &$
	val2=val1/pi.enctoin &$
	note,ln+(i+2)*sclln,$
	string(format='(f4.2," ",f5.0)',val1,val2),color=col,xp=.05 &$
endfor
note,ln+1*sclln,'inch encCnts',xp=.05
note,ln,axis + ' KiThreshold step .0 to .1 by .005 [inch]'
end
