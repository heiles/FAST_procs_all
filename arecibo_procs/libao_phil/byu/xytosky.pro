;+
;NAME:
;xytosky - convert focus x,y to sky amin
;SYNTAX: xytosky(xy,sky,usemeas=cenNm)
;ARGS:
;xy[2,n] : double cm  [0,*]x offset along azimuth (downhill is pos)
;                     [1,*]y offset toward stairwell is pos
;sky[2,*]: double amin[0,*] az 
;                 amin[1,*] za
;KEYWORDS:
;usemeas: string : A1,A2...."
;		if supplied the use the following algorithm.
;			1. compute xy to sky mapping using germans equ->sky
;		    2. read the measured center offset from the offset pointing file
;           3. subtrace sky[*,0] then add back on the sky[*,0] read from 
;              file.
; data from german
;
pro xytosky,xy,sky,usemeas=usemeas

	spatab="[ " + string(9b) + "]+"
	nspatab="([^ " + string(9b) + "]+)"
	centersFile="/home/online/Tcl/Proc/byu/data/skyOffsetsForCenters.dat"
	useMeasL=n_elements(usemeas) eq 1
	if useMeasL then begin
		n=readasciifile(centersFile,inplines,comment="#")
		matchString="([ACD][0-6])"+spatab+nspatab+spatab+nspatab
		a=stregex(inplines,matchString, /extract,/sub)
		ii=where(a[1,*] eq useMeas,cnt)
		if cnt eq 0 then begin
			print,"Err xytosky.. illegal center name requested:",useMeas
			return
		end
		cenOffAz=double(a[2,ii[0]])
		cenOffZa=double(a[3,ii[0]])
	endif
			
n=n_elements(xy[0,*])
x=xy[0,*]
y=xy[1,*]
sky=fltarr(2,n)

;
; daz 
;
a1    = 0.0000823231D
a2    = -6.47323d-6
a3    = 1.12026D-7
b1    = -0.24924D
b2    = 7.85327D-7
b3    =-0.0000102022D
a1b1=-0.000103633D
a2b1=-0.0000102767D
a1b2=-3.23359D-7
sky[0,*] = a1*x + a2*x*x + a3*x^3 + b1*y + b2*y^2 + b3*y^3 + a1b1*x*y + $
             a2b1*x^2*y + a1b2*x*y^2

; dza
a1    = 0.316372D
a2    = -0.000438707D
a3    = 5.64841d-6
b1    = 0.0000820729D
b2    = -0.000594738D
b3    =7.21237D-8
a1b1= 0.0000208497d
a2b1=-4.09273d-8
a1b2=6.93529d-6
sky[1,*] = a1*x + a2*x^2 + a3*x^3 + b1*y + b2*y^2 + b3*y^3 + a1b1*x*y +$
             a2b1*x^2*y + a1b2*x*y^2
sky[1,*] = -1.*sky[1,*]
;
if useMeasL then begin
	sky[0,*]=sky[0,*] - sky[0,0] + cenOffAz
	sky[1,*]=sky[1,*] - sky[1,0] + cenOffZa
endif
; 
return
end
