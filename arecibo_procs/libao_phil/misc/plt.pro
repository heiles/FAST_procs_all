;
; d=inpplt(file=fnum,pol=pol,linear=linear)
; args:
;    fnum   =1-11
;    pol    = 1 oc, 2 sc
;    linear = 1-->linear, 0 --> log
;
function  inpplt,fnum=fnum,pol=pol,linear=linear

on_error,1
on_ioerror,endit
if not keyword_set(fnum) then fnum=1
if not keyword_set(pol)  then pol =1
if not keyword_set(linear)  then linear=0

d=fltarr(4096,4095)
fname=string(format='("/export/data30/phil/mar30/p",i1,"/ven.mapf")',pol)
if fnum lt 10 then begin 
	fnumc=string(format='(i1)',fnum)
endif else begin
	fnumc=string(format='(i2)',fnum)
endelse
fname=fname+fnumc
openr,lun,fname,/get_lun
readu,lun,d
if linear eq 0 then d=alog10(d)
endit:
	free_lun,lun
return,d
end
;
pro plt,d,maxd=maxd,mind=mind,prof=prof,scalex=scalex,scaley=scaley
; 0 or 1 for profiles
if not keyword_set(maxd)  then maxd=0
if not keyword_set(mind)  then mind=0
if not keyword_set(prof)  then prof=0
if not keyword_set(scalex)  then scalex=-4
if not keyword_set(scaley)  then scaley=-5

max=max(d,min=min)
print,'max,min values (log)',max,min
window,0
frq=.5*1./(8e-6*4095.)
xf=(findgen(4096)/4096 -.5) * frq*2.
xr=findgen(4095)/4095 *8e-6*4095.*1000.
rng=(8e-6*4095.)*1000.
!x.style=1
!y.style=1
!p.multi=[0,1,2]
plot,xf,total(d[*,0:9],2)/10.,xtitle='frequency',$
title='log pwr versus frequency. avg range bins 0-9'
plot,xr,total(d[2043:2052,*],1)/10.,xtitle='range',$
title='log pwr versus range. avg 10 frq bins about dc'
!p.multi=0
;
if maxd eq 0 then begin
	maxDisp=max
endif else begin
   maxdisp=maxd
endelse
;
if mind eq 0 then begin
	minDisp=min
endif else begin
   mindisp=mind
endelse

imgdisp,((d>minDisp)<maxDisp),zx=scalex,zy=scaley,xrange=[-frq,frq],$
                 yrange=[0,rng],prof=prof
return
end
