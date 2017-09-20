;
; try to reproduce rick fischers code
;
function chkrick2,map_az_deg,map_el_deg,src_az_deg,src_el_deg,verb=verb
	
;    convert degrees to radians
    dToR=!dpi/180D
    radeg=180D/!dpi
    
	verbL=keyword_set(verb)
    map_az_rad =  map_az_deg *dToR
    map_el_rad =  map_el_deg *dToR
    src_az_rad =  src_az_deg *dToR
    src_el_rad =   src_el_deg *dToR
;
;  let center of beam (0,0) by at our offset. then
;  the pointing center will be - mapaz, -mapel
; 
;    anglestovec3 works the same as sla routine.
    vec = anglestovec3( -map_az_rad, -map_el_rad)
;   the offset telescope position is determined iteratively, starting
;   with a guess
    elg = (src_el_rad - map_el_rad)*1D
    azg = src_az_rad - map_az_rad /cos(elg)
;     position tolerance of 2 arcsec in radians
    err_tol = 2.D/3600. *dToR
    if verbL  then begin
		print,map_az_deg,map_el_deg,$
			format='("map_az:",f7.3, " map_el:",f7.4)'
        print,src_az_deg,src_el_deg,$
			format='("src_az:",f7.3, " src_el:",f7.4)'
	endif
;
;  rotating our offset feed to the source will rotate
; vec to the place to point the telescope
;  
    new_vec1  = rotvec(vec ,-src_el_rad*radeg,axis=2)
    new_vec2  = rotvec(new_vec1  , src_az_rad*radeg ,axis=3)
	vec3toangles,new_vec2,azTel,elTel
	   vec3toangles,vec,azT,elT
	   print,format='(2x," vec    :",f10.5,f10.5,f10.5," angle:",f7.3,1x,f7.3)',$
				vec,azT,elT
	   vec3toangles,new_vec1,azT,elT
	   print,format='("  new_vec1:",f10.5,f10.5,f10.5," angle:",f7.3,1x,f7.3," rotaboutY")',$
					new_vec1,[azT,elT]*radeg
	   print,format='("  new_vec2:",f10.5,f10.5,f10.5," angle:",f7.3,1x,f7.3," rotAboutZ")',$
                        new_vec2,[azTel,elTel]*radeg
	   print,format='(40x,"Guess  :",f7.3,1x,f7.3)',[azG,elG]*radeg
       print,format='(40x,"ErrAsec:",f7.3,1x,f7.3)',$
					[(azTel-azg)*cos(src_el_rad),(elTel-elg)]*radeg*3600.
       print,format='(40x,"TrueSrc:",f7.3,1x,f7.3)',[src_az_rad,src_el_rad]*radeg
          
	return,[azTel,elTel]*radeg
end
