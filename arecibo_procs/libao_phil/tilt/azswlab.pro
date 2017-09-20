;-----------------------------------------------------------------------------
; label plot with azswing fit values
;
pro azswlab,azfit,x,y,roll=roll,foc=foc,color=color,dy=dy

    common colph,decomposedph,colph
;
; generate fit function.. return as as string
;
    if (n_elements(roll) eq 0) then roll=0
    if (n_elements(foc) eq 0) then  foc=0
    if (n_elements(color) eq 0) then  color=1
	case 1 of 
		roll ne 0: begin
        	f=azfit.r
        	labtype="Roll ="
		    end
		foc ne 0: begin
        	f=azfit.p
        	labtype="Focus="
		    end
		else: begin
        	f=azfit.p
       		labtype="Pitch="
		end
	endcase
;
;   constant term vs za
;
    l=strarr(3)
	if (size(azfit))[1] eq 1 then begin
		c0=f.c0
		c1za=0
		c2az=f.c1
		a1amp=f.az1a
		a1ph =f.az1ph*!radeg
		a3amp=f.az3a
		a3ph =f.az3ph*!radeg
	endif else begin
	    a2=linfit(azfit.za,f.c0)
	    c0=a2[0]
	    c1za=a2[1]
	    a=rms(f.c1)
	    c2az=a[0]
	    a=rms(f.az1a)
	    A1amp=a[0]
	    a=rms(f.az1Ph)
        a1=rms((f.az1Ph+!pi) mod (2.*!pi))
        if  a1[1] lt a[1] then begin &$
            a[0]=a1[0] - !pi &$
            a[1]=a1[1]
        endif
		if a[0] lt 0 then a[0]=a[0]+ 2*!pi
	    A1Ph=a[0]*!radeg
	    a=rms(f.az3a)
	    A3amp=a[0]
	    a=rms(f.az3Ph)
        a1=rms((f.az3Ph+!pi) mod (2.*!pi))
        if  a1[1] lt a[1] then begin
            a[0]=a1[0] - !pi
            a[1]=a1[1]
        endif
		if a[0] lt 0 then a[0]=a[0]+ 2*!pi
	    A3Ph=a[0]*!radeg
	endelse
    a=[c0,c1za,c2az]
    sgn=["+","+","+"]
    i=where(a lt 0,count)
    if count gt 0 then sgn[i]="-"
    l[0]=string(format='(A6,1x,f7.4,a3,f7.4,"*za",a3,e8.2,"*az + ")',$
            labtype,c0,sgn[1],abs(c1za),sgn[2],abs(c2az))
;   l[1]=string(format='("       ",f6.4,"*sin( az - ",f5.1,") + ")', A1amp,A1ph)
    l[1]=string(format='("za:",f4.1," ",f6.4,"*sin( az - ",f5.1,") + ")', $
		azfit.za,A1amp,A1ph)
    l[2]=string(format='("        ",f6.4,"*sin(3az - ",f5.1,")")', A3amp,A3ph)
	if n_elements(dy) eq 0 then  dy=(!y.crange[1]-!y.crange[0])/30.
    xyouts,x,y,l[0],color=colph[color]
    xyouts,x,y-dy,l[1],color=colph[color]
    xyouts,x,y-2.*dy,l[2],color=colph[color]
    return
end
