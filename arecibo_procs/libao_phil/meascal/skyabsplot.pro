;
; plot the cal values
; first call lbninp
;            lbncmp
; 		     pltlbn
;
; note that running pltlbndiag requires you to rerun dolbncmp
;
freqmin=1250
freqmax=1520
deg=2
freq=dabs.freq
frqold=freq
calOld=fltarr(16,2)
calOldN=fltarr(16,2)
fnameN='/share/obs4/rcvm/cal.datR6Test
fname='/share/obs4/rcvm/cal.datR6
for i=0,16-1 do begin &$
	if i eq 0 then begin &$
		istat=calget1(6,0,frqOld[i],calval,fname=fnameN) &$
	endif else begin &$
		istat=calget1(6,0,frqOld[i],calval) &$
	endelse &$
	calOldN[i,0]=calval[0] &$
	calOldN[i,1]=calval[1] &$
endfor
for i=0,16-1 do begin &$
	if i eq 0 then begin &$
		istat=calget1(6,0,frqOld[i],calval,fname=fname) &$
	endif else begin &$
		istat=calget1(6,0,frqOld[i],calval) &$
	endelse &$
	calOld[i,0]=calval[0] &$
	calOld[i,1]=calval[1] &$
endfor
;
;
!p.multi=[0,1,2]
ver,1,3
hor,1200,1600
df=3
df2=6
polLab=['pol A','pol B']
for pol=0,1 do begin &$
;
; 	calabs
;
plot ,freq,calabs[pol,*,*]    ,psym=2,$
xtitle='freq [Mhz]',ytitle='calValue K',$
title='28jan02 lbnCal '+polLab[pol]+' measured using sky and absorber' &$
ln=2 &$
xp=.1 &$
scl=.8 &$

note,ln,'Cal from absorber',xp=xp &$
note,ln+1*scl,'Cal from sky     ',xp=xp,color=2 &$
note,ln+2*scl,'Cal from Ratio sky,absorber',xp=xp,color=4 &$
;
xp=.6 &$
ln=10+pol*15 &$
scl=.7 &$
lab=string(format='("Tsky+Tscattered:",f5.1)',Tsky+Tscattered) &$
note,ln,lab,xp=xp  &$
lab=string(format='("TAbsorber      :",f5.1)',Tabs) &$
note,ln+1*scl,lab,xp=xp  &$
lab=string(format='("Treceiver      :",f5.1)',Trcvr[pol]) &$
note,ln+2*scl,lab,xp=xp  &$
;
oplot,ufrq,calAbsF[pol,*],psym=-1,color=1
;
; 	calsky
;
oplot,freq+df,calSky[pol,*,*]  ,psym=2,color=2 &$
oplot,ufrq,calSkyF[pol,*],psym=-1,color=2
;
;   calratio
oplot,freq+df2,calratio[pol,*,*],psym=2,color=4 &$
oplot,ufrq,calRatioF[pol,*],psym=-1,color=4
;
oplot,frqOld,calOld[*,pol],color=6 &$
oplot,frqOld,calOldN[*,pol],color=7 &$
;
endfor
;
; plot calvalue by strip
;
hor
!p.multi=[0,1,3]
cs=1.5
pol=0
stripsxy,freq[0:15],reform(calabs[pol,*,*],16,numloopsabs),0,0,/step,psym=-2,$
charsize=cs,xtitle='freq Mhz',ytitle='Cal Value [K]',$
title='28jan02 lbn calvalue from absorber PolA'
stripsxy,freq[0:15],reform(calsky[pol,*,*],16,numloopssky),0,0,/step,psym=-2,$
charsize=cs,xtitle='freq Mhz',ytitle='Cal Value [K]',$
title='28jan02 lbn calvalue from sky'
stripsxy,freq[0:15],reform(calratio[pol,*,*],16,numloopsratio),0,0,/step,psym=-2,$
charsize=cs,xtitle='freq Mhz',ytitle='Cal Value [K]',$
title='28jan02 lbn calvalue from absorber, sky ratio'
;
!p.multi=[0,1,3]
pol=1
stripsxy,freq[0:15],reform(calabs[pol,*,*],16,numloopsabs),0,0,/step,psym=-2,$
charsize=cs,xtitle='freq Mhz',ytitle='Cal Value [K]',$
title='28jan02 lbn calvalue from absorber PolB'
stripsxy,freq[0:15],reform(calsky[pol,*,*],16,numloopssky),0,0,/step,psym=-2,$
charsize=cs,xtitle='freq Mhz',ytitle='Cal Value [K]',$
title='28jan02 lbn calvalue from sky'
stripsxy,freq[0:15],reform(calratio[pol,*,*],16,numloopsratio),0,0,/step,psym=-2,$
charsize=cs,xtitle='freq Mhz',ytitle='Cal Value [K]',$
title='28jan02 lbn calvalue from absorber, sky ratio'
;
end
