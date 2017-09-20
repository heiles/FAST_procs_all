; last setup 19sep00
;
; cband
;
step=1
ver,.8,1.2
cali9=calratio(25.,40.,r9,step=step)
;
; sband wide..start after daynum 207. before that diode 1 had jumped up
; whole thing is rising up..
;
ind=where(r7.r.date  ge 207.) 
r7m=r7
r7m.r[0:ind[0]-1].ct.tsysv=1.			; so we don't use it
cali7=calratio(50.,70.,r7m,step=step)
;
;lbandwide start after day 34..
;
r5m=r5
ind=where(r5m.r.date  ge 34.) 
r5m.r[0:ind[0]-1].ct.tsysv=1.			; so we don't use it
cali5=calratio(30,45,r5m,step=step)
;
; 430 mhz dome start after daynum 141.
;
r2m=r2
ind=where(r2m.r.date  ge 142.)
r2m.r[0:ind[0]-1].ct.tsysv=1.           ; so we don't use it
cali2=calratio(40,75,r2m,step=step)
;
openw,lun,'junk.out',/get_lun 
calratiopr,9,cali9,lun
calratiopr,5,cali5,lun
calratiopr,7,cali7,lun
printf,lun,""
calratiopr,2,cali2,lun
free_lun,lun
end
