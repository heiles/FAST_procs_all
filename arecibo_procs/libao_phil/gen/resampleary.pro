;+
;NAME:
;resampleary= resample an array in the y direction
;SYNTAX:nyout=resampleary(arIn,yIn,yStpOut,arOut,$
;						y1=y1,y2=y2,
;                       cntyOut=cntyOut;
;ARGS:
;arIn[nxIn,nyIn]   : float input array 
;yIn[nyIn]         : float yvalue for arIn[*,nyIn]
;yStpOut           : float y step value for output array
;KEYWORDS:
;y1                : float first y value to use for output
;                          def is yIn[0]
;y2                : float last y value to use for output
;                          def is yIn[nyIn-1]
;RETURNS:
;nyOut             : long number of y entries i output:arOut[*,nout]
;arOut[nxIn,nyOut] : float averaged output
;yOut[nyOut]       : float the y values for each arOut[*,i]
;cntyOut[nyOut]    : long   number of arIn[*,i] averaged for
;                            each arOut[*,i]
;DESCRIPTION:
;	Given an array arIn[nx,ny] of unevenly sampled data in the 
;y direction, create an array of evenly spaced data in the 
;y direction arOut[nx,nyOut]. 
;	The yIn array has the y values for each arIn[*,iy].
;Use the reverse indices of the histogram function on yIn
;to find the arIn[*,iiy] elements that map to each arOut[*,iy]
;	yIn[] should be in increasing order. yStpOut defines the
;fixed y spacing in arOut[*,iy]
;	cntYOut[nyOut] has the number of input rows arInp[*,i] averaged
;for  each arOut[*,j]
;-
function resampleary,arInp,yInp,yStpOut,arOut,$
					y1=y1,y2=y2,yout=yout,cntYOut=cntYOut
;
	nx=n_elements(arInp[*,0])
	nyIn=n_elements(arInp[0,*])
	if n_elements(y1) eq 0 then y1=yInp[0]
	if n_elements(y2) eq 0 then y2=yInp[nyIn-1]
;
	cntYOut=histogram(yInp,min=y1,max=y2,binsize=yStpOut,reverse=r,$
			locations=yout)
	nyout=n_elements(yout)
;
;	yout is the start of each bin..
;
	arOut=(size(arInp,/type) eq 5)?dblarr(nx,nyOut):fltarr(nx,nyout)
;	now average each ouput bin
	for i=0L,nyOut-1 do begin
		if (cntYout[i] gt 0) then begin 
		   ii=r[r[i]:r[i+1]-1]
		   arOut[*,i]=(n_elements(ii) eq 1)?arInp[*,ii]$
										   :total(arInp[*,ii],2)/$
								(cntYOut[i]*1.)
		endif
	endfor
	return,nyout
end
