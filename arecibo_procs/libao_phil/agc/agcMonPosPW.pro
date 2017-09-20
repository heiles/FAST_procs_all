;spawn,'/home/aosun/u4/phil/vw/Solaris/bin/agcMonPos',unit=fdp, /NOSHELL
spawn,'/home/aosun/u4/phil/vw/Solaris/bin/agcMonPosD < /share/online/log/pnt/cbFb960724.dat -s 26850 ',unit=fdp
;
numpnts=100             ; points to display
pltout=2                ; how often to output plots
xdim=512
ydim=300
window,/pixmap,xsize=xdim,ysize=ydim,/free
pixwin=!d.window
window,xsize=xdim,ysize=ydim,/free
win=!d.window

lasti=numpnts -1        ; last index in array
x=fltarr(numpnts)       ; hold the data
xtval=[0,25,50,75,100]  ; x tick values
extrav=1.  ; two degrees above/below
;ytval=[0.,90.,180.,270.,360.]
;ytval=[200.,210.,220.,230.,240.]
;yrange=[200.,250.]

mon=    {monI, $
             hour:   0l, $
             min:    0l, $
             sec:    0., $
             azPos:  0., $
             azVel:  0., $
             azEnc1: 0., $
             azEnc2: 0.}
readu,fdp,mon
x(*)=mon.azPos;
maxv=x(0) 
minv=x(0) 
ymax=maxv + extrav
ymin=(minv - extrav) > 0.
!p.noclip=0
!p.noerase=0
!x.style=0
!y.style=1
!x.ticks=4
!x.tickv=xtval
!y.ticks=4
!y.tickv=0
!x.minor=-1
!y.minor=-1
; !y.range=yrange
!y.range=[ymin,ymax]
device,set_graphics=3
;plot,x(*,iptr),xminor=1,yminor=1,xticks=4,yticks=4,xtickv=xtval,ytickv=ytval
plot,x
;
;
pltcnt=0
; !p.noclip=1               ; no clipping
; !x.style=4                ; no axis x
; !y.style=4                ; no axis y
;
for i=0,1,0 do begin
readu,fdp,mon
;
pltcnt=pltcnt+1
lastx=x(lasti)
x(*)=shift(x(*),1)
x(0)=mon.azPos
;
; see if last value was == to max
;
if (maxv eq minv ) then  maxv=minv   else $
if (lastx ge maxv ) then maxv=max(x(*)) else $
if (lastx le minv ) then minv=min(x(*))
;
; see if new value will rescale
;
maxv= x(0) > maxv
minv= x(0) < minv

ymax=maxv + extrav
ymin=(minv - extrav) > 0.

print,x(0),ymin,ymax
if (pltcnt ge pltout ) then  begin
!y.range=[ymin,ymax]
wset,pixwin
plot,x
wset,win
device,copy=[0,0,xdim,ydim,0,0,pixwin]
pltcnt=0
endif
endfor
end
