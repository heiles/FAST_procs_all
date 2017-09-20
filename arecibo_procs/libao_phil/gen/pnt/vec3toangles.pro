;+
;NAME:
;vec3ToAngles - convert 3 vector to angles
;
;SYNTAX: vec3toangles,v,angle1,angle2,deg=deg
;ARGS:
;   v[3,npts]   : input 3 vector array
;
;KEYWORDS:
;   c1pos       : if set then the first angle will be returned >=0
;   deg         : if set then return angles rather than radians
;
;RETURNS:
;   c1Rd[npts]: 1st angle coordinate in radians
;   c2Rd[npts]: 2nd angle coordinate in radians
;
;DESCRIPTION:
; Convert the input 3 vector to angles (radians).
; If posC1 is set, then the first angle will always be returned as a positive
; angle (for hour angle system you may want to let the ha be negative ).
;
; The coordinate systems are:
;   c1 - ra, ha, azimuth
;   c2 - dec,dec, altitude
;-
pro vec3toangles,v,c1rd,c2rd,c1pos=c1pos,deg=deg

		type=size(v,/type)
		if ((type eq 5) || (type eq 9)) then begin
			pi=!dpi
			radeg=180D/pi
		endif else begin
			pi=!pi
			radeg=!radeg
		endelse
        c1Rd=atan(v[1,*],v[0,*])
;
;        atan2 returns -pi to pi. If user requested, make sure we return
;         0 to 2pi;
        if keyword_set(c1Pos) then begin 
          ind=where(c1Rd < 0.,count)
          if count gt 0 then c1Rd[ind] = c1Rd[ind] + 2.*pi
        endif
        c2Rd=asin(v[2,*])       ;asin (z)
        c1Rd=reform(c1Rd,/overwrite)    ; remove leading  dim of 1)
        c2Rd=reform(c2Rd,/overwrite)    ; remove leading  dim of 1)
		if keyword_set(deg) then begin
			c1Rd*=radeg
			c2Rd*=radeg
		endif
        return;
end
