;
; doit lbn to compute, then call this for plotting.
;-----------------------------------
; plot the power levels
;
ver,-50,-30
hor
!p.multi=[0,1,2]
plot,bar.b1.h.iflo.if1.pwrdbm[0],xtitle='sample',ytitle='pwr[dbm]',$
title='06dec01 pwr dbm at input to fiber optics upstairs'
oplot,bar.b1.h.iflo.if1.pwrdbm[1],color=2
flag,findgen(4)*40,color=3
flag,findgen(numloopssky-1+numloopsabs)*80+(120),color=3
;
ver,-60,-40
plot,bar.b1.h.iflo.if2.pwrdbm[0],xtitle='sample',ytitle='pwr[dbm]',$
title='06dec01 pwr dbm at if2 pwrmeter downstairs'
oplot,bar.b1.h.iflo.if2.pwrdbm[1],color=2
;flag,findgen(numloops6)*10*4*3,color=3
;-----------------------------------
; power counters... median value probably 25 counts/ 1sigma
; 9*power--> 3*25 or 75 counts.. duty cycle about 10% for aerostat so
; we are saturating the a/d during the bursts..
;
!p.multi=[0,1,4]
cs=1.5
ver,.5,2
plot,(bar.b1.h.cor.pwrcnt[0])/median(bar.b1.h.cor.pwrcnt[0]),charsize=cs,$
xtitle='sample',ytitle='pwr/median(power)',$
title='06dec01 lbn calMeaurement. power count (50Mhz at each sample)'
ln=2
xp=.05
stp=.17
note,ln+1,'brd 0 to 4 (top to bottom)',xp=xp
oplot,(bar.b1.h.cor.pwrcnt[1])/median(bar.b1.h.cor.pwrcnt[1]),color=2
flag,findgen(6)*10*4*3,color=6
plot,bar.b2.h.cor.pwrcnt[0]/median(bar.b2.h.cor.pwrcnt[0]),charsize=cs,$
xtitle='sample',ytitle='pwr/median(power)'
oplot,bar.b2.h.cor.pwrcnt[1]/median(bar.b2.h.cor.pwrcnt[1]),color=2
flag,findgen(6)*10*4*3,color=6
plot,bar.b3.h.cor.pwrcnt[0]/median(bar.b3.h.cor.pwrcnt[0]),charsize=cs,$
xtitle='sample',ytitle='pwr/median(power)'
oplot,bar.b3.h.cor.pwrcnt[1]/median(bar.b3.h.cor.pwrcnt[1]),color=2
flag,findgen(6)*10*4*3,color=6
plot,bar.b4.h.cor.pwrcnt[0]/median(bar.b4.h.cor.pwrcnt[0]),charsize=cs,$
xtitle='sample',ytitle='pwr/median(power)'
oplot,bar.b4.h.cor.pwrcnt[1]/median(bar.b4.h.cor.pwrcnt[0]),color=2
flag,findgen(6)*10*4*3,color=6
;
!p.multi=[0,1,4]
cs=1.5
ver,.7,1.6
plot ,bar.b1.h.cor.lag0pwrratio[0],charsize=cs,$
xtitle='sample',ytitle='lag0PwrRatio',$
title='06dec01 lbncals lag0pwrratio vs sample, brd 0'
ln=2
xp=.05
stp=.17
oplot,bar.b1.h.cor.lag0pwrratio[1],color=2
flag,findgen(6)*10*4*3,color=6
plot ,bar.b2.h.cor.lag0pwrratio[0],charsize=cs,$
xtitle='sample',ytitle='lag0PwrRatio',$
title='06dec01 lbncals lag0pwrratio vs sample, brd 1'
oplot,bar.b2.h.cor.lag0pwrratio[1],color=2
flag,findgen(6)*10*4*3,color=6
plot ,bar.b3.h.cor.lag0pwrratio[0],charsize=cs,$
xtitle='sample',ytitle='lag0PwrRatio',$
title='06dec01 lbncals lag0pwrratio vs sample, brd 2'
oplot,bar.b3.h.cor.lag0pwrratio[1],color=2
flag,findgen(6)*10*4*3,color=6
plot ,bar.b4.h.cor.lag0pwrratio[0],charsize=cs,$
xtitle='sample',ytitle='lag0PwrRatio',$
title='06dec01 lbncals lag0pwrratio vs sample, brd 3'
oplot,bar.b4.h.cor.lag0pwrratio[1],color=2
flag,findgen(6)*10*4*3,color=6
end

