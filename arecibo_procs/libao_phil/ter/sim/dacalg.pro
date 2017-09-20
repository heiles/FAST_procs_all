;
dac1=lonarr(4096)
dac2=lonarr(4096)
num =lonarr(4096)
val=-2048
for i=0,4095 do begin
	num[i]=val
	if val ge 0 then begin
		dac1[i]='800'XL + (val and '7ff'XL)
		dac2[i]=      (not val) and '7ff'XL
	endif else begin
		dac1[i]=(val and '7ff'XL)
		dac2[i]='800'XL + ((not val) and '7ff'XL)
	endelse
	val=val+1
endfor
plot,num,dac1,/xstyle,/ystyle,psym=-2
plot,num,dac2 ,/xstyle,/ystyle,psym=-2
dif=(dac1-dac2) - (dac2-dac1)
;
hor,-5,5
ver,-20,20
plot,num,dif,/xstyle,/ystyle,psym=-2,xtitle='requested dac value',$
ytitle='differential voltage [in dac voltage steps]',$
title='algorithm for differential dac output voltage vs dacValue'
flag,0
oplot,num,fltarr(4096)
end


