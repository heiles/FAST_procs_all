;+
;NAME:
;anglestovec3 - convert from angles to 3 vectors.
;
;SYNTAX: v=anglestovec3(c1Rd,c2Rd)
;
;ARGS:
;   c1Rd[npts] : float/double first  angular coordinate in radians.
;   c2Rd[npts] : float/double second angular coordinate in radians.
;
;RETURNS
;   v[3,npts]  : float/double x,y,z vector
;
;DESCRIPTION
; Convert the input angular coordinate system to a 3 vector Cartesian
; representation. Coordinate system axis are set up so that x points
; toward the direction when priniciple angle equals 0 (ra=0,ha=0,az=0).
; Y is towards increasing angle.
;
;   c1   c2    directions
;
;   ra   dec   x towards vernal equinox,y west, z celestial north.
;          this is a righthanded system.
;   ha   dec   x hour angle=0, y hour angle=pi/2(west),z=celestial north.
;          This is a left handed system.
;   az   alt   x north horizon,y east, z transit.
;          This is a left handed system.
;
;SEE ALSO:
; vec3ToAngles
;-
function anglesToVec3,c1Rd,c2Rd

    cosC2=cos(c2Rd);
	type=size(c1rd,/type)
	if ((type eq 5) || (type eq 9)) then begin
    	v=dblarr(3,n_elements(c1Rd))
	endif else begin
    	v=fltarr(3,n_elements(c1Rd))
	endelse
    v[0,*] = cos(c1Rd)*cosC2
    v[1,*] = sin(c1Rd)*cosC2
    v[2,*] = sin(c2Rd)
    return,v
end
