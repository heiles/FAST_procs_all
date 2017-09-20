;
openr,lun,'/share/obs4/usr/x101/model/model11/idldat.rawerrs',/get_lun
dat=fltarr(4,1522)
readf,lun,dat
free_lun,lun
az=reform(dat[0,*])
za=reform(dat[1,*])
azErr=reform(dat[2,*])
zaErr=reform(dat[3,*])
fitmod,az,za,azErr,zaErr,modI,resAz,resZa

print,modi.model.enctblaz
;
; try creating lookup table of residuals..
;
npts=n_elements(az)
;
; map to x,y
; let y be north, x be east.. azimuth increases counter clockwise..
;
x=za*sin(az*!dtor)
y=za*cos(az*!dtor)
triangulate,x,y,tr
loadct,0
;
; trigrid
;
gs=[.1,.1]
bounds=[-20.,-20.,20.,20.]
trgaz=trigrid(x,y,resAz[*,1],tr,gs,bounds,/quintic,max_value=20.,min_value=-20.)
trgza=trigrid(x,y,resZa[*,1],tr,gs,bounds,max_val=4)
xpos=findgen(401)*.1-20.
ypos=findgen(401)*.1-20.
shade_surf,trgaz,xpos,ypos,az=25,ax=30,max_value=30.,min_value=-30
shade_surf,trgza,xpos,ypos,az=25,ax=40
;
;

;
; min curve surface
; .. not so hot..
gs=[1.,1.]
bounds=[-20.,-20.,20.,20.]
xpos=findgen(41)-20.
ypos=findgen(41)-20.
mcsaz=min_curve_surf(resAz[*,1],x,y,gs=gs,bounds=bounds)
mcsza=min_curve_surf(resZa[*,1],x,y,gs=gs,bounds=bounds)
shade_surf,mcsaz,xpos,ypos
shade_surf,mcsza,xpos,ypos,az=25,ax=40
;
; tri_surface
;
gs=[1.,1.]
bounds=[-20.,-20.,20.,20.]
xpos=findgen(41)-20.
ypos=findgen(41)-20.
trsaz=tri_surf(resAz[*,1],x,y,gs=gs,bounds=bounds,/extrapolate)
shade_surf,trsaz,xpos,ypos,max_value=30.,min_value=-30.
;
; krigging
e=[1.,0.]
xpos=findgen(41)-20.
ypos=findgen(41)-20.
krigaz=krig2d(resAz[*,1],x,y,exponential=e,gs=gs,bounds=bounds)
shade_surf,krigaz,xpos,ypos,az=25,ax=30,max_value=30.,min_value=-30
;
; compute the x,y position for integral values of x,y
;
azc=findgen(360) # (fltarr(21)+1.)
zac=(fltarr(360)+1.) # findgen(21) 
xc=(zac*sin(azc*!dtor))
yc=(zac*cos(azc*!dtor))
xcp=(xc + 20.)*10.
ycp=(yc + 20.)*10.
result=bilinear(trgaz,xcp,ycp)
shade_surf,result,xc,yc
;
; test galconv..
;
@goddard
aI=[0.D,0.D]
bI=[0.D,90.D]
;
euler,aI,bI,ao,bo,2
galconv,aI,bI,aoP,boP
galconv,aI,bI,aoN,boN
