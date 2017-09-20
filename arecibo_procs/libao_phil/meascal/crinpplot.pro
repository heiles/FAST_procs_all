; file x101.2
;  cfr:4000.0 scan:135400344 off1 hcorcal
;  to
;   cfr:4900.0 scan:135400527 cal on hcal
;  scans:2*10*10=200, recs 1000.
;
; file x101.3
; cfr:5000.0 scan:135400549 off1 hcorcal
; to
;  cfr:6000.0 scan:135400749 off1 hcorcal
;  scans:2*10*11=220, recs 1100.
;
; order:
; off,cal  hcorcal       0
; off,cal  hcal          1
; off,cal  hxcal         2
; off,cal  h90cal        3
; off,cal  hcorcal       4
; off,cal  lcorcal       5
; off,cal  lcal          6
; off,cal  lxcal         7
; off,cal  l90cal        8
; off,cal  hcorcal       9
;
; pushd,'../../020128/'
; @mcalinit.pro
; popd
goto,makplot
hard=0
file1='corfile.20dec01.x101.2'
file2='corfile.20dec01.x101.3'
dir='/proj/x101cor/'
openr,lun1,dir+file1,/get_lun
openr,lun2,dir+file2,/get_lun
;corlist,lun
scan1=135400344L
scan2=135400549L
ncals=10
numsteps1=ncals*10
numsteps2=ncals*11
d1=mcalinp(lun1,2,numsteps1,1,scan=scan1)
d2=mcalinp(lun2,2,numsteps2,1,scan=scan2)
nd1=n_elements(d1)
nd2=n_elements(d2)
d=replicate(d1[0],nd1+nd2)
d[0:nd1-1]=d1
d[nd1:*]=d2
d1=''
d2=''
;
rew,lun1
print,corpwr(lun1,10*10*2*5,p1)	
rew,lun2
print,corpwr(lun2,11*10*2*5,p2)	
np1=n_elements(p1)
np2=n_elements(p2)
p=replicate(p1[0],np1+np2)
p[0:np1-1]=p1
p[np1:*]  =p2
p1=''
p2=''
;
rew,lun1
print,corgetm(lun1,np1,b1)
rew,lun2
print,corgetm(lun2,np2,b2)
b=corallocstr(b1[0],np1+np2) 
corstostr,b1,0,b
corstostr,b2,np1,b
b1=''
b2=''
;
numsteps=10+11
frq=fltarr(4,10,numsteps)
f=findgen(numsteps)*100+4000-37.5
for i=0,3 do begin &$
for j=0,9 do begin &$
	frq[i,j,*]=f+i*25 &$
endfor &$
endfor
d=reform(d,4,10,numsteps)
p=reform(p,5,2,10,numsteps)
;
pol=0
ver,0,2
plot,frq[*,0,*],d[*,0,*].tpcal[pol],psym=-2
oplot,frq[*,4,*],d[*,4,*].tpcal[pol],psym=-2,color=2
oplot,frq[*,9,*],d[*,9,*].tpcal[pol],psym=-2,color=3
flag,findgen(numsteps)*100+4000-37.5,linestyle=2
;
ver,0,3
plot,frq[*,0,*],d[*,0,*].tpon[0],psym=-2
oplot,frq[*,0,*],d[*,0,*].tpoff[0],psym=-2,color=2
oplot,frq[*,4,*],d[*,4,*].tpon[0],psym=-2
oplot,frq[*,4,*],d[*,4,*].tpoff[0],psym=-2,color=2
oplot,frq[*,9,*],d[*,9,*].tpon[0],psym=-2
oplot,frq[*,9,*],d[*,9,*].tpoff[0],psym=-2,color=2
flag,findgen(numsteps)*100+4000-37.5,linestyle=2
;
;--------------------------------------------------------------------------- 
x=(findgen(256)/256-.5)*25.
ver,0,3
i=3
s=5
plot,x +frq[i,0,s],d[i,0,s].spon[*,0]
oplot,x+frq[i,4,s],d[i,4,s].spon[*,0],color=2
oplot,x+frq[i,9,s],d[i,9,s].spon[*,0],color=3
;--------------------------------------------------------------------------- 
; plot hcal first attempt each rec
;
ver,0,3
plot,p[*,0,0,*].pwr[0,0],psym=-2
oplot,p[*,1,0,*].pwr[0,0],color=2,psym=-2
flag,findgen(numsteps)*5,color=2,linestyle=2
;
oplot,p[*,0,4,*].pwr[0,0],color=3,psym=-2
oplot,p[*,1,4,*].pwr[0,0],color=4,psym=-2
;
oplot,p[*,0,9,*].pwr[0,0],color=5,psym=-2
oplot,p[*,1,9,*].pwr[0,0],color=6,psym=-2
;--------------------------------------------------------------------------- 
ver,0,2
i=18
plot,d[*,0,i].spcal[*,0]
oplot,d[*,4,i].spcal[*,0],color=2
oplot,d[*,9,i].spcal[*,0],color=3
flag,findgen(4)*256
;--------------------------------------------------------------------------- 
ver,0,2
plot,d[*,0,i].spon[*,0]
oplot,d[*,0,i].spoff[*,0],color=2
flag,findgen(4)*256,linestyle=2
;--------------------------------------------------------------------------- 
ver,0,2
hor
test=''
len=256
x=(findgen(len)/len-.5)*100.
sbc=0
for i=0,numsteps-1 do begin &$
y=d[sbc, 0,i].spcal[*,0] &$
f=x+ frq[sbc,0,i] &$
plot,f,y &$
range=len/4 &$
limit=3 &$
cumfilter,y,range,limit,indxgood,indxbad,countbad &$
oplot,f[indxgood],y[indxgood],psym=2,color=2 &$
print,"next?" &$
read,test &$
endfor
;
; try cumfiltering each calspec
;
d=reform(d,4*10*numsteps)
calcumA=fltarr(4*10*numsteps)
calcumB=fltarr(4*10*numsteps)
ratioA=fltarr(4,10,numsteps)
ratioB=fltarr(4,10,numsteps)
for i=0,4*10*numsteps-1 do begin &$
	x=reform(d[i].spcal[*,0],256) &$
	cumfilter,x,range,limit,indxgood,indxbad,countbad &$
	calcumA[i]=median(x[indxgood]) &$
	x=reform(d[i].spcal[*,1],256) &$
	cumfilter,x,range,limit,indxgood,indxbad,countbad &$
	calcumB[i]=median(x[indxgood]) &$
endfor
;
; compute "other cals as ratios of hcorcal
; interpolate between 0,4,9
;
d=reform(d,4,10,numsteps)
calcumA=reform(calCumA,4,10,numsteps)
calcumB=reform(calCumB,4,10,numsteps)
x=[0.,4.,9.]
x1=findgen(10)
for i=0,numsteps-1 do begin &$
	for j=0,3 do begin &$
 		hcalA=interpol(reform(calCumA[j,[0,4,9],i],3),x,x1) &$
 		hcalB=interpol(reform(calCumB[j,[0,4,9],i],3),x,x1) &$
; 		hcalA=fltarr(10)+median(reform(calCumA[j,[0,4,9],i])) &$
; 		hcalB=fltarr(10)+median(reform(calCumB[j,[0,4,9],i])) &$
		for k=0,9 do begin &$
			ratioA[j,k,i]=calCumA[j,k,i]/hcalA[k] &$
			ratioB[j,k,i]=calCumB[j,k,i]/hcalB[k] &$
		endfor &$
	endfor &$
endfor
;-----------------------------------------------------------------------------
; average together common measurements eg diode 2->polA r
; then average over 100 Mhz (the common measurement)
;high cals
;
; diode2 -> polA: 2 + 3
;
y=(ratioA[*,2,*]*1.D + $
   ratioA[*,3,*]*1.D)*.5
rd2a=total(y,1)/4.
rd2a=reform(rd2a,21)
rd2a[20]=0.
;
; diode2 -> polb: 1 + 3 B
;
y= (ratioB[*,1,*]*1.D + $
    ratioB[*,3,*]*1.D)*.5
rd2B=total(y,1)/4.
rd2B=reform(rd2b,21)
rd2B[20]=0.
;-----------------------------------------------------------------------------
;low
;
; diode1 -> A
;
y=(ratioA[*,5,*] + $
   ratioA[*,6,*])*.5
rd1aL=total(y,1)/4.
rd1al=reform(rd1al,21)
rd1al[19:20]=0.
;
; diode1 -> B
;
y=(ratioB[*,5,*] + $
   ratioB[*,7,*])*.5
rd1bL=total(y,1)/4.
rd1bl=reform(rd1bl,21)
rd1bl[19:20]=0.
;
; diode2 -> A
;
y=(ratioA[*,7,*] + $
   ratioA[*,8,*])*.5
rd2aL=total(y,1)/4.
rd2al=reform(rd2al,21)
rd2al[19:20]=0.
;
; diode2 -> B
;
y=(ratioB[*,6,*] + $
   ratioB[*,8,*])*.5
rd2bL=total(y,1)/4.
rd2bl=reform(rd2bl,21)
rd2bl[19:20]=0.
frq1=reform(total(frq[*,0,*],1)/4.,21)
;
;-----------------------------------------------------------------------------
makplot:
if hard then pscol,'cbcalratiodec01.ps',/full
!p.multi=[0,1,2]
ver,0,1.5
hor,3950,6050
xp=.8
ln=2 
scl=.6
plot,fltarr(52),/nodata,$
xtitle='freq',ytitle='calSize [fraction Tsys]',$
title='20dec01 cb (high cals) versus freq'
note,ln      ,'hcorcal',xp=xp
note,ln+1*scl,'hcal'  ,xp=xp,color=2
note,ln+2*scl,'hxcal' ,xp=xp,color=3
note,ln+3*scl,'h90cal',xp=xp,color=4
note,ln+4*scl,'hcorcal',xp=xp,color=1
note,ln+5*scl,'* is polB',xp=xp,color=1
for i=0,4 do begin &$
col=i+1 &$
if i eq 4 then col=1 &$
oplot,frq[*,i,*],calCumA[*,i,*],color=col &$
oplot,frq[*,i,*],calCumB[*,i,*],color=col,psym=-2 &$
endfor
flag,findgen(numsteps)*100+3950,linestyle=2
;
ver,.05,.18
hor,3950,6050
xp=.8
ln=17
scl=.6
plot,fltarr(52),/nodata,$
xtitle='freq',ytitle='calSize [fraction Tsys]',$
title='20dec01 cb (low cals) versus freq'
note,ln      ,'lcorcal',xp=xp
note,ln+1*scl,'lcal'  ,xp=xp,color=2
note,ln+2*scl,'lxcal' ,xp=xp,color=3
note,ln+3*scl,'l90cal',xp=xp,color=4
note,ln+4*scl,'* is polB',xp=xp,color=1
for i=5,8 do begin &$
col=i-4 &$
oplot,frq[*,i,*],calCumA[*,i,*],color=col &$
oplot,frq[*,i,*],calCumB[*,i,*],color=col,psym=-2 &$
endfor
flag,findgen(numsteps)*100+3950,linestyle=2
;--------------------------------------------------------------------
; plot as ratio of hcorcal
;
!p.multi=[0,1,2]
ver,.8,1.2
hor,3950,6050
xp=.05
ln=2
scl=.6
ls=0
plot,fltarr(52),/nodata,$
xtitle='freq',ytitle='cal/hcorcal',$
title='20dec01 cb (high cals)/hcorcal versus freq'
note,ln+0*scl,'hcalA:diode 1->polA / diode1->polA'  ,xp=xp,color=1
note,ln+1*scl,'hcalB:diode 2->polB / diode1->polB'  ,xp=xp,color=2

note,ln+2*scl,'hxcalA:diode 2->polA / diode1->polA'  ,xp=xp,color=3
note,ln+3*scl,'hxcalB:diode 1->polB / diode1->polB'  ,xp=xp,color=4

note,ln+4*scl,'h90calA:diode 2->polA / diode1->polA'  ,xp=xp,color=5
note,ln+5*scl,'h90calB:diode 2->polB / diode1->polB'  ,xp=xp,color=6
col=1
for i=1,3 do begin &$
print,col &$
oplot,frq[*,i,*],ratioA[*,i,*],color=col &$
col=col+1 &$
oplot,frq[*,i,*],ratioB[*,i,*],color=col&$
col=col+1 &$
endfor
oplot,frq1,rd2A,linestyle=ls,psym=-2
oplot,frq1,rd2B,linestyle=ls,psym=-2
;flag,findgen(numsteps)*100+3950,linestyle=2
;
ver,.05,.18
xp=.35
ln=23
plot,fltarr(52),/nodata,$
xtitle='freq',ytitle='calSize [fraction Tsys]',$
title='20dec01 cb (low cals)/hcorcal versus freq'
note,ln+0*scl,'lcorcalA:ldiode 1->polA / hdiode1->polA'  ,xp=xp,color=7
note,ln+1*scl,'lcorcalB:ldiode 1->polB / hdiode1->polB'  ,xp=xp,color=8

note,ln+2*scl,'lcalA   :ldiode 1->polA / hdiode1->polA'  ,xp=xp,color=1
note,ln+3*scl,'lcalB   :ldiode 2->polB / hdiode1->polB'  ,xp=xp,color=2

note,ln+4*scl,'lxcalA  :ldiode 2->polA / hdiode1->polA'  ,xp=xp,color=3
note,ln+5*scl,'lxcalB  :ldiode 1->polB / hdiode1->polB'  ,xp=xp,color=4

note,ln+6*scl,'l90calA :ldiode 2->polA / hdiode1->polA'  ,xp=xp,color=5
note,ln+7*scl,'l90calB :ldiode 2->polB / hdiode1->polB'  ,xp=xp,color=6
col=7
for i=5,8 do begin &$
oplot,frq[*,i,*],ratioA[*,i,*],color=col &$
col=col+1 &$
oplot,frq[*,i,*],ratioB[*,i,*],color=col &$
col=col+1 &$
if col gt 8 then col=1 &$
endfor
oplot,frq1,rd1al,psym=-2
oplot,frq1,rd1bl,psym=-2
oplot,frq1,rd2al,psym=-2 
oplot,frq1,rd2bl,psym=-2
;flag,findgen(numsteps)*100+3950,linestyle=2
;-----------------------------------------------------------------------------
;
; look to see if it is the cal or the Tsys that is changing
; between the various measurements
;
ver,-.05,.05
ln=2
xp=.2
plot,fltarr(10),/nodata,$
xtitle='freq',ytitle='hcorcal[4,9]/hcorcal[0]',$
title='20dec01 cb polA Calon[n]/calon[0],calOff[n]/calOff[0]  -1'
note,ln      ,'hcorcal[1]/hcorcal[0]-1',xp=xp,color=2
note,ln+1*scl,'hcorcal[2]/hcorcal[0]-1',xp=xp,color=3
note,ln+2*scl,'* calon, + caloff',xp=xp

oplot,frq[*,0,*],d[*,4,*].tpon[0]/d[*,0,*].tpon[0]-1,color=2,psym=-2
oplot,frq[*,0,*],d[*,9,*].tpon[0]/d[*,0,*].tpon[0]-1,color=3,psym=-2
;
oplot,frq[*,0,*],d[*,4,*].tpoff[0]/d[*,0,*].tpoff[0]-1,color=2,psym=-1
oplot,frq[*,0,*],d[*,9,*].tpoff[0]/d[*,0,*].tpoff[0]-1,color=3,psym=-1
oplot,frq[*,0,*],fltarr(52)
flag,findgen(numsteps)*100+3950,linestyle=2
;
if hard then hardcopy
x
;
; generate the table to compute the actual cals
;
openw,lunout,'calcbratio.dat',/get_lun
printf,lunout,$
';frq   nd1PaH  nd1PaL  nd1PbH  nd1PbL  nd2PaH  nd2PaL  nd2PbH  nd2PbL'
for i=0,n_elements(frq1)-1 do begin &$
;
; d1PAH d1Pal nd1Pbh nd1pBl nd2PaH nd2PaL nd2PBh nd2pBl
lab=string(format=$
'(f5.0,8f8.4)',$
frq1[i],1.,rd1al[i],1.,rd1bl[i],rd2a[i],rd2al[i],rd2b[i],rd2bl[i]) &$
printf,lunout,lab &$
endfor
free_lun,lunout
;
end

