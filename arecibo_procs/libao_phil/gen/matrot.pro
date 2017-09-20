;+
;NAME: 
;matrot - generate 1 or more rotation matrices
;SYNTAX: mat=matrot(order,th1,th2,th3)
;ARGS:
;order: string   "xyz" order for the rotations
;th1  :  float    first angle in radians
;th2  :  float    2nd angle in radians
;th3  :  float    3rd angle in radians
;RETURNS:
;mat[3,3]: float   rotation matrix 
;DESCRIPTION:
;	concatenate 3 rotation matrices.
;similar to slalib_euler routine.
;This rotates the coordinate system. A positive rotatation
;is CCW looking down the rotation axis from the positive side
;
;-
function matrot,order,th1,th2,th3,double=double
;
	matI=(keyword_set(double))?dblarr(3,3):fltarr(3,3)
	matI[0,0]=1.
	matI[1,1]=1.
	matI[2,2]=1.
	mat=matI
	slen=strlen(order)
	lorder=strlowcase(order)
	for i=0,slen-1 do begin
		th=(i eq 0)?th1:(i eq 1)?th2:th3
		s=sin(th)
		c=cos(th)
		mm=matI
		case strmid(lorder,i,1) of
		'x': begin
		     mm[4]=c	
		     mm[5]=s	
		     mm[7]=-s	
		     mm[8]=c	
			 end
		'y': begin
		     mm[0]=c	
		     mm[2]=-s	
		     mm[6]=s	
		     mm[8]=c	
			 end
		'z': begin
		     mm[0]=c	
		     mm[1]=s	
		     mm[3]=-s	
		     mm[4]=c	
			 end
	    endcase
		mat=mm#mat
	endfor
	return,mat
end
