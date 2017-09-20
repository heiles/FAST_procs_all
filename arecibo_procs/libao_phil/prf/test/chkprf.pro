; check that idl routines match values computed by pointing
; (that we implemented the pointing correctly)
;
; program.
; 1. generate az,za tracks 
; 2. output time,az,za  to file and then run through
; 
; ~phil/vw/Solaris/bin/tdtrkfilter /home/online/vw/etc/Pnt/pr.coef < 
; azza.dat > td.dat
; 3. compare td positions from 2. with values computed from
;    idl routines. 
;@geninit
;@pntinit
;@prfinit
;@tdinit
; file size pr.coef: 20
;
temp=72
dec=[16,0.,0.]
decToAzZa,dec,az,za,step=1.
npts=n_elements(az)
outdata=fltarr(2,npts)
outdata[0,*]=az
outdata[1,*]=za
openw,lun,'azza.dat',/get_lun
writeu,lun,outdata
free_lun,lun
;
td=fltarr(3,npts)
openr,lun,'td.dat',/get_lun
readu,lun,td
free_lun,lun
tdparms,reftdpos=tdref
for i=0,2 do begin &$
td[i,*]=td[i,*]+tdref[i]&$
endfor
x=za
hor,0,20
ver,0,25
plot,x,td[0,*]
oplot,x,td[1,*],color=2
oplot,x,td[2,*],color=3
;
; now compute from idl.. use temp=72 deg.
;
    prfit2dio,prf2d
	prfk=prfkposcmp(az,za,temp,prf2d)
oplot,x,prfk.tdpos[0],color=4
oplot,x,prfk.tdpos[1],color=5
oplot,x,prfk.tdpos[2],color=6
;
plot,x,td[0]-prfk.tdpos[0]
