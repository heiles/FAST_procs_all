;+
;NAME:
;gs2d - generate a 2d gaussian
;SYNTAX: f=gs2d(len,height,fwhm)
;ARGS:
;        len:   int  .. length one side. x values will be 0 thru len-1
;                       make an odd value for center to be located
;                       at center of array.
;     height:   float.. height of the gaussian.
;     fwhm  :   float.. full width at half maximum. full range 0 to len-1
; RETURNS:
;  xy(2,len,len): double x,y coorinate for each point
;     computed 2d gaussian as a double.
;-
function gs2d,len,h,w,xy=xy
    
	x2=dblarr(len,len)
	y2=dblarr(len,len)
	mm2=(dindgen(len) - len/2L)^2
	for i=0,len-1 do  begin
		x2[*,i]=mm2
		y2[i,*]=mm2
	endfor 
 	if (arg_present(xy)) then begin
		mm=(dindgen(len) - len/2L)
		xy=dblarr(2,len,len)
		for i=0,len-1 do  begin
			xy[0,*,i]=mm
			xy[1, i,*]=mm
		endfor 
	endif
    sigma2=(w*w)*1.D/(4.* 0.693147180560D)  ;fwhm**2 to sig**2 (1/(4*ln2)
    return,  double(h)*(exp(-(x2 + y2)/sigma2) > 1e-14)
end
