;
; strip plot of status for 6 distomats. assumes data in
; lrd
ver,-.5,10.
!x.style=1
!y.style=1
len=(size(lrd))[1]
da=intarr(6,len)
mask=1
for i=0,5 do begin
    da[i,*]=(lrd.stat and mask) ne 0
    mask=mask * 2
endfor
;
stripsxy,lrd.day,transpose(da),0,1.1,title=title,xtitle=xtitle
note,3,'up:ok  down: no reading',xp=.05
end
