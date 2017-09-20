;+
;NAME:
;xytosky - convert focus x,y to sky amin
;SYNTAX: xytosky(xy,sky)
;KEYWORDS: 
; usegc :    if set use german cortes 2013 offsets for sky,
;            ignore x,y offsets
;
;ARGS:
;xy[2,n] : double cm  [0,*]x offset along azimuth (downhill is pos)
;                     [1,*]y offset toward stairwell is pos
;sky[2,*]: double amin[0,*] az 
;                 amin[1,*] za
;
;Uses germans fit. Need new equations.
;
pro xytosky,xy,sky,usegc=usegc

;
; germans sky 2013 offsets.
;     Sky Coordinates  
;  vaxis  is az direction +v increases az 
;     -  moving dipole toward stairwell 
;        gives negative v (or lower az) 
;  Uaxis  is za direction 
;     - moving dipole to lower za (+x)  
;       gives positive za 
;   az           -za
;    V-axis       U-axis 
;   [arcmin]    [arcmin] 
;               ],$ 
skyOffGc=[$
[ -0.00019, 0.00094],$
[ -3.32734,-0.08132],$
[ -1.67879,-3.84626],$
[  1.65934,-3.84924],$
[  3.32388,-0.08646],$
[  1.66023, 3.66847],$
[ -1.66550, 3.67157],$
[ -6.75467,-0.34218],$
[ -5.07516,-4.05580],$
[ -3.44125,-7.99048],$
[ -0.02333,-7.86330],$
[  3.38866,-7.99483],$
[  5.04515,-4.06656],$
[  6.74241,-0.35335],$
[  5.02911, 3.52535],$
[  3.37305, 7.23024],$
[ -0.00255, 7.29333],$
[ -3.38374, 7.23996],$
[ -5.04263, 3.53220]]
	if (keyword_set(usegc)) then begin
		sky=skyOffGc
		sky[1,*]*=-1
		return
	endif
	cenOffAz=0D
	cenOffZa=0D
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
; 
return
end
