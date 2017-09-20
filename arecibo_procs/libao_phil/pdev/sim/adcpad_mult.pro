pro adcpad_mult,a,b,ovl_i,y,ovl ,verb=verb,stop=stop

	ash=long64(ishft(long(a),6))
	bsh=long64(ishft(long(b) and 'ffff'XL,1))
    prod=ash*bsh
; 
;   changes..
;   comment lines are what jeff has.. it is off by 1 bit
;	m1=(prod and '800000000'XLL) ne 0
;	m2=(prod and '400000000'XLL) ne 0 
;
;   jeff does not have m3,m4 so
;   adc=1024 with * 2 should be an overflow but isn't
;
 	m1=(prod and '400000000'XLL) ne 0
 	m2=(prod and '200000000'XLL) ne 0 
	yp=fix(ishft(prod,-21) and '1fff'xLL) 
	m3=(yp and '1000'x) ne 0
	yp=((yp and '1000'x) ne 0)? fix(yp or 'f000'x) + 1:fix(yp and 'fff'x) + 1 
	m4=(yp and '1000'x) ne 0
    ovl=ovl_i || ( m1 ne m2) || (m3 ne m4) 
	y=ishft(yp,-1)
	neg=((y and '800'x) ne 0)
	y=(neg)?fix(y or 'f000'X):fix(y and '0fff'X) 
	if keyword_set(verb) then begin
	   hexpr,[a,b,prod,m1,m2,m3,m4,yp,y]
	   print,a,b,ovl,y,y,format='("a:",i," con:",z4," ovl:",i1," out:",i6,1x,z)'
	endif
	if keyword_set(stop) then stop
	return
end
	
