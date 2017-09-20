;
; try to reproduce rick fischers code
;
function chkrick,map_az_deg,map_el_deg,src_az_deg,src_el_deg,verb=verb
	
;    convert degrees to radians
    dToR=!dpi/180D
    radeg=180D/!dpi
	pi=!dpi
    
	verbL=keyword_set(verb)
    map_az_rad =  map_az_deg *dToR
    map_el_rad =  map_el_deg *dToR
    src_az_rad =  src_az_deg *dToR
    src_el_rad =   src_el_deg *dToR
; convert map spherical coordinates into a 3-D cartesian unit vector
; 
;    anglestovec3 works the same as sla routine.
;    matrot() works negative of sla_deuler.
;    matrot() pos : vector rotates ccw looking down the pos axis
;    sla_deuler(): pos: coordinate system rotates CCW looking down the pos axis
    vec = anglestovec3( map_az_rad, map_el_rad)
    vec0=[1.,0.,0.]
;   the offset telescope position is determined iteratively, starting
;   with a guess
    elg = (src_el_rad - map_el_rad)*1D
    azg = src_az_rad - map_az_rad /cos(elg)
;     position tolerance of 2 arcsec in radians
    err_tol = 2.D/3600. *dToR
    num_iter = 10  
    if verbL  then begin
		print,map_az_deg,map_el_deg,$
			format='("map_az:",f8.4, " map_el:",f8.4)'
         print,src_az_deg,src_el_deg,$
			format='("src_az:",f8.4, " src_el:",f8.4)'
	endif
    for i=0,num_iter-1 do begin
;     determine the rotation matrix for moving the map origin to the
;     guessed azimuth and elevation
;        rmat = sla_deuler('yzx', elg, -azg, 0.0)
;
;  rotvec is opposite from sla routine so use opposite signs here 
;  from rick
		rmat=matrot("yz",-elg,azg)
		new_vec=rmat # vec
;tn         convert the rotated map vector to az, el coordinates
		vec3toangles,new_vec,az,el
		az_diff = src_az_rad - az
        if az_diff gt pi then begin
            az_diff -= 2.D * !dpi
        endif
        el_diff = src_el_rad - el

        if verbL then begin
		    vec3toangles,vec,azT,elT,/deg
			print,format='(i2," vec    :",f10.5,f10.5,f10.5," angle:",f9.4,1x,f9.4)',$
							i,vec,[azT,elT]
		    vec3toangles,new_vec,azT,elT,/deg
			print,format='("  new_vec:",f10.5,f10.5,f10.5," angle:",f9.4,1x,f9.4,"          ")',$
					new_vec,[azT,elT]
            print,format='(40x,"srcPos  ",f8.4,1x,f8.4)',[src_az_deg,src_el_deg]
            print,format='(40x,"ErrAsec:",f8.4,1x,f8.4)',$
						[(src_az_rad-az)*cos(src_el_rad),(src_el_rad-el)]*radeg*3600.
          
			print,format='(40x,"Guess  :",f8.4,1x,f8.4)',[azG,elG]*radeg
           print,'--> diffAsecs: ', az_diff*radeg*cos(elg)*3600,$
                  el_diff*radeg*3600,$
                format='(a,1x,f8.1,1x,f7.1)'
; test
;			print,format='(i2," vec0   :",f10.5,f10.5,f10.5)',i,vec0
;			print,format='(" new_vec01:",f10.5,f10.5,f10.5," rotaboutY")',$
;					new_vec1_0
;			print,format='(" new_vec02:",f10.5,f10.5,f10.5," rotAboutZ")',$
;					new_vec2_0
;			print,format='(3x,f10.5,f10.5," az0,el0,cmpSrcAz/ell")',$
; 				az_0*radeg,el_0*radeg
;			stop
		endif
;       if the differences are within tolerance, quit
        if (abs(az_diff) lt err_tol) and (abs(el_diff) lt err_tol) then begin
            break
        endif
;        if not, apply the differences for a new guess
        azg += az_diff
        elg += el_diff
	endfor
	aa=[azg,elg]*radeg	
	return,aa
end
