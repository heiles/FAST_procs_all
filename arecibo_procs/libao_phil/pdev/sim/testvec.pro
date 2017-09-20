;
; test vectors
;
scl1='8000'x
scl2='ffff'x
adcIn  =[1,10,1024,2046,2047,2048]
adcOff =0
a={ adcIn  : 0,$
	adcScl	: 0,$
	adcOff : 0,$
	adcOut : 0,$
	ovl     : 0}
nadcIn=n_elements(adcIn)

testV=replicate(a,2,nadcIn)
nv=n_elements(testV)
for i=0,nv-1 do begin &$
	testV[0,i].adcIn =adcIn[i] &$
	testV[0,i].adcScl=scl1 &$
	testV[1,i]=testV[0,i] &$
	testV[1,i].adcScl=s2 &$
endfor
; ------------------------------------------------------------------
; test adcpad_mult
;
for i=0,nv-1 do begin &$
    adcpad_mult,testV[i].adcIn,testV[i].adcScl,ovlIn,y,ovl &$
	testV[i].adcOut=y &$
	testV[i].ovl   =ovl &$
endfor
prtestv,testv
; --------------------------------------------------------------------
; test adcpad, adcpad_mult
;
testV.adcOff=1
for i=0,nv-1 do begin &$
    adcpad,testV[i].adcOff,testV[i].adcScl,testV[i].adcIn,y,ovl &$
	testV[i].adcOut=y &$
	testV[i].ovl   =ovl &$
endfor
prtestv,testv
; --------------------------------------------------------------------
