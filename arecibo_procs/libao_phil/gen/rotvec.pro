;+
;NAME:
;rotvec - rotate a vector through an angle (in deg)
;SYNTAX: rvec=rotvec(vec,thetaDeg,axis=axis)
;ARGS:
; vec[m,n]: float/double data before rotation. first dim is x,y,z
;theta    : float angle in degrees to rotate vector
;KEYWORDS:
; axis:     int    1=x,2=y,3=z. default axis=3 (z axis)
;RETURNS:
;rvec[m,n]: float  rotated vector
;
;DESCRIPTION
;   Rotate a vector through the angle theta (in degrees). Return the 
;rotated vector in rvec.
;   The first dimension of vec, rvec can be 2 (for a 2d rotations) or 
;3 for 3d rotations. The axis= keyword (1=x,2=y,3=z) specifies which 
;axis to rotate about. The default is axis=3 (z). If dim1 of vec is
;2 then axis= is ignored and the rotation is about the z axis.
;	Positive rotate is counter clockwise looking down from the positive
;axis of rotation. The definition rotates a vector in this direction.
;Rotation of the coordinate system would be in the oppposite sense.
;-
function rotvec,vec,theta,axis=axis,usedouble=usedouble

;
;   get the array sizes
;
	dbltype=5
	flttype=4
	sz=size(vec)
	ndim=sz[0]
	if (ndim gt 2) or (ndim lt 1)  then begin
		print,"rotvec needs a 1 or 2d array)"
		return,0
	endif
	usedoubleL=(sz[ndim+1] eq dbltype) || keyword_set(usedouble)
	sz[ndim+1]=(usedoubleL)?dbltype:flttype   ; force float

    twoD=(sz[1] eq 2)
	if (~ twoD) && (sz[1] ne 3)  then begin	
		print,"rotvec first dimension must be 2 or 3"
		return,0
	endif
	axisl=(keyword_set(axis))?axis:3
	if twoD then axisl=3
	if (axisl lt 1) || (axisl gt 3) then begin
		print,"rotvec axis= is 1=x,2=y,3=z"
		return,0
	endif
;   the -1 gives CCW rotation looking down the axis 
	sgn=(usedoubleL)?-1D:-1.
;
	cosTh=cos(sgn*theta*!dtor)
	sinTh=sin(sgn*theta*!dtor)

	rvec=make_array(size=sz,/nozero)
	
	case  1 of
	
      axisl eq 3: begin
			rvec[0,*]= vec[0,*]*costh + vec[1,*]*sinth
			rvec[1,*]=-vec[0,*]*sinth + vec[1,*]*costh
			if ~twoD then rvec[2,*]=vec[2,*]
			end
      axisl eq 1: begin
			rvec[0,*]=vec[0,*]
			rvec[1,*]=vec[1,*]*costh  + vec[2,*]*sinth
			rvec[2,*]=-vec[1,*]*sinth + vec[2,*]*costh
			end
      axisl eq 2: begin
			rvec[0,*]=vec[0,*]*costh - vec[2,*]*sinth
			rvec[1,*]=vec[1,*]
			rvec[2,*]=vec[0,*]*sinth + vec[2,*]*costh
			end
	endcase
	return,rvec
end
