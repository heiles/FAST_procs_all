;spawn,'/home/aosun/u4/phil/vw/Solaris/bin/agcMonPos',unit=fdp, /NOSHELL
spawn,'/home/aosun/u4/phil/vw/Solaris/bin/agcMonPosD < /share/online/log/pnt/cbFb960724.dat -s 26850 ',unit=fdp
numpnts=100             ; points to display
lasti=numpnts -1        ; last index in array
pltout=2                ; pnts before plot
x=fltarr(numpnts,2)     ; hold the data
iptr=0;                 ; pnt at 1st block
xtval=[0,25,50,75,100]  ; x tick values
yrange=[200.,260.]
;ytval=[0.,90.,180.,270.,360.]
ytval=[200.,220.,240.,260.,280.]

mon=    {monI, $
             hour:   0l, $
             min:    0l, $
             sec:    0., $
             azPos:  0., $
             azVel:  0., $
             azEnc1: 0., $
             azEnc2: 0.}
readu,fdp,mon
x(*,0)=mon.azPos;
x(*,1)=mon.azPos;
!p.noclip=0
!p.noerase=0
!x.style=2
!y.style=2
!x.ticks=4
!x.tickv=0
!y.ticks=4
!y.tickv=ytval
!x.minor=-1
!y.minor=-1
!y.range=yrange
device,set_graphics=3
;plot,x(*,iptr),xminor=1,yminor=1,xticks=4,yticks=4,xtickv=xtval,ytickv=ytval
plot,x(*,iptr)
;
extrav=1.  ; two degrees above/below
maxv=x(0) 
minv=x(0) 
;
pltcnt=0
eraval=0
!p.noclip=1             ; no clipping
!p.noerase=1            ; no erase
!x.style=4              ; no axis x
!y.style=4              ; no axis y
;
for i=0,1,0 do begin
readu,fdp,mon
;
pltcnt=pltcnt+1
lastx=x(lasti,iptr)
x(*,iptr)=shift(x(*,iptr),1)
x(0,iptr)=mon.azPos
;
; see if last value was == to max
;
if (maxv eq minv ) then  maxv=minv   else $
if (lastx ge maxv ) then maxv=max(x(*,iptr)) else $
if (lastx le minv ) then minv=min(x(*,iptr))
;
; see if new value will rescale
;
maxv= x(0,iptr) > maxv
minv= x(0,iptr) < minv

ymax=maxv + extrav
ymin=(minv - extrav) > 0.

print,x(0,iptr),ymin,ymax
if (pltcnt ge pltout ) then  begin
; !y.range=[ymin,ymax]
; erase the old plot
i=(iptr+1) mod 2
; plot,x(*,i),xminor=1,yminor=1,xticks=4,yticks=4,xtickv=xtval,ytickv=ytval,/noerase,color=0
; plot,x(*,iptr),xminor=1,yminor=1,xticks=4,yticks=4,xtickv=xtval,ytickv=ytval,/noerase,color=!p.color
plot,x(*,i),color=0
plot,x(*,iptr),color=!p.color
iptr=i
pltcnt=0
endif
endfor
end
