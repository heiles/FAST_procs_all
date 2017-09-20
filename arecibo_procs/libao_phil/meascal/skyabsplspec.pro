pol=0
!p.multi=[0,1,2]
ver,0,.3
hor
inc=.01
x=findgen(256*16)*25/256.+1212.50-12.5
pollab=['polA','polB']
for pol=0,1 do begin
stripsxy,x,reform(dsky.spcal[*,pol],256*4*4,numloopssky),0,inc,/step ,$
;stripsxy,x,reform(dabs.spcal[*,pol],256*4*4,numloopsabs),0,inc,/step ,$
xtitle='by frequency',ytitle='Cal/Tsys',$
title='28jan02 cal (sky) in tsys units by freq '+pollab[pol]
flag,findgen(4)*256*4,linestyle=2
endfor
end
