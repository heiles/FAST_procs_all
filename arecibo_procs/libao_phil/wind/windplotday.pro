;+
;NAME:
;windplotday - plot a days worth of wind data.
;SYNTAX: windplotday,d
;ARGS:
; d[n]:{}	wind data input by windinpraw()
;RETURNS:
;		plots the wind data.
;DESCRIPTION:
;	Plot the wind data for a day. The top plot is the wind data versus hour 
;of data (ast). The data has bin binned to 1 minute steps. The white (black)
;plot is the average over each minute. The red plot is the peak hold over
;each minute.
;	The bottom plot is the median wind velocity for each minute versus 
;ast hour of day. The direction is where the wind is coming from.
;
;EXAMPLE:
;	Get the data and then plot it.
;
; yymmdd=070412
; n=windinpraw(yymmdd,d)
; windplotday,d
;
;-
pro windplotday,d,maxvel=maxvel

    common colph,decomposedph,colph

    maxaccel  =30.              ; max accel vel/sec^2 before we ignore data
	accel=(d.vel - shift(d.vel,1))
    accel[0]=accel[1]
	ii=where( abs(accel) gt maxaccel,cnt)
	if cnt gt 0 then begin
 	 	d[ii].vel=0
 	 	d[ii].dir=0
	endif
;
	
; figure out the date
;  
n=n_elements(d)
jd0=d[n/2].jd - 4./24D
caldat,jd0,mon,day,year,hour,k
ldate=string(format='(i02,a,i02)',day,monname(mon),year mod 100L)
;
; convert jd to minutes
;
min=(d.jd - long(d[0].jd) - .5 - 4D/24)*24D*60D
;
; histogram to get indices for each minute
;
nbins=24*60L
minstep=1
h=histogram(min,min=0,nbins=nbins,binsize=minStep,revers=r)
velPk=fltarr(nbins)
velMd=fltarr(nbins)
dirMd=fltarr(nbins)
for i=0,nbins-1 do begin &$
	if (r[i] ne r[i+1]) then begin
       velPk[i]=max(d[r[r[i]:r[i+1]-1]].vel) &$
       velMd[i]=median(d[r[r[i]:r[i+1]-1]].vel) &$
       dirMd[i]=mean(d[r[r[i]:r[i+1]-1]].dir) &$
	endif
endfor
ii=where(velPk gt 0.,cnt)
ii=max(ii)
ii=lindgen(ii+1)
;
hr=findgen(nbins)/60. 
colPk=2
vmax=(n_elements(maxvel) gt 0)?maxvel: (long(max(velpk)/5) + 1 )*5
ver,0,vmax
;
; plot velocity 
;
!p.multi=[0,1,2]
;
plot,hr[ii],velMd[ii],$
	xtitle='hour of day [AST]',ytitle='velocity [mph]',$
	title='Wind velocity for ' + ldate

oplot,hr[ii],velPk[ii],col=colph[colPk]
ver,0,360
sym=2
plot,hr[ii],dirMd[ii],psym=sym,$
	xtitle='hour of day [AST]',ytitle='Wind from direction [deg]',$
	title='Wind direction for ' + ldate
oplot,[0,24],[90,90],col=colph[2]
oplot,[0,24],[180,180],col=colph[3]
oplot,[0,24],[270,270],col=colph[4]
x=1
y=90
yeps=5
cs=1.5
xyouts,x,y+yeps,'From the East',col=colph[2],charsize=cs
y=180
xyouts,x,y+yeps,'From the South',col=colph[3],charsize=cs
y=270
xyouts,x,y+yeps,'From the West',col=colph[4],charsize=cs
return
end
