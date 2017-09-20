;
pro prtestv,testv
;
;num   inp   out  off   scl ovl
;iii iiiii iiiii iiiii xxxx  i
;

print,"num   inp   out  off   scl ovl"
	for i=0,n_elements(testv)-1 do begin
	   print,i,testV[i].adcIn,testV[i].adcOut,testV[i].adcOff,testV[i].adcScl,$
	           testV[i].ovl,format='(i3,1x,i5,1x,i5,1x,i5,1x,z4,2x,i1)'
	endfor
	return
end
