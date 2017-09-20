;+
;lrdxdytopr - convert dx,dy laser ranging to pitch,roll
;
pro lrdxdytopr,sec,dx,dy,az,za,lr
;
; SYNTAX:
;     lrld,sec,dx,dy,az,za,lr
;
; ARGS:
;	  sec  : sec midnite for measurement
;	   dx  : inches dx (plus is east)
;	   dy  : inches dy (plus is north)
;     az   : for dome side deg;  
;     za   : for dome  deg
;     lr   : []{lr} structure fill in..
;
; RETURN   :
;		 lr:  structure.
; DESCRIPTION:
; 
;	Routine will compute x,y from az,za. p,r computed using 
; 435 feet. 
;  {lr ,  sec:  0. ,$; time when this was sampled
;           x:  0. ,$; x position dome east  positive(unit deg za)
;           y:  0. ,$; y position dome north positive
;           az:  0. ,$; az
;           za:  0. ,$; za
;           dx:  0. ,$; dx motion  inches. positive east
;           dy:  0. ,$; dy motion  inches. positive north
;           p:  0. ,$; pitch angle deg
;           r:  0. };  roll deg
;-
;				  
	lr.sec     =sec
	lr.aznomod =az
	lr.az      =az mod 360
	lr.za =za
	lr.dx =dx				; dx + should already be east
	lr.dy =dy				; dx + should already be east
	lr.x  =lr.za*cos((-lr.az+90.)*!dtor)
	lr.y  =lr.za*sin((-lr.az+90.)*!dtor)
;
; project dx,dy onto the x,y radial direction for each point
;
	lr.p=((lr.dx*lr.x)+(lr.dy*lr.y))/sqrt(lr.x*lr.x + lr.y*lr.y)
;
; now get the roll component perp to radius. (x,y) perp is (-y,x)
;when pointing north,looking from the center this vector points to the
; left or ccw for positive theta
	lr.r= ((-lr.y*lr.dx)+(lr.x*lr.dy))/sqrt(lr.x*lr.x + lr.y*lr.y)
;
; convert from inches to deg using 1/435 feet and straigten out the direction
; note on sign..
;     .. if we moved the dome radially out, then the pitch of the dome
;        is too small (it thinks it is at a lower za.).
;        so positive radius, is negative pitch
;     .. if we face north and move the dome to + x, it will rotate
;        ccw looking from the center. this is negative roll.. so use
;        a minus sign
;
	lr.p =-(lr.p)/(12.*435) * !radeg
	lr.r =-(lr.r)/(12.*435) * !radeg
	return
end
