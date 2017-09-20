;
; try to reproduce rick fischers code
;
function chkrick3,map_az_deg,map_el_deg,src_az_deg,src_el_deg,verb=verb
	
;    convert degrees to radians
	verbl=(keyword_set(verb))?verb:0
	debug2=verbL gt 1
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
;   vector for beam center
;
    vecTel = anglestovec3(-map_az_rad,  -map_el_rad)
	vecSrc = anglestovec3(src_az_rad , src_el_rad)
;
    vecOff = anglestovec3( map_az_rad,  map_el_rad)
    vec0   = [1.,0.,0D]
;
    elg = (src_el_rad - map_el_rad)*1D
    azg = src_az_rad - map_az_rad /cos(elg)
	vecG=anglestovec3(azg,elg)
;
;  rotate offset and vec0  so offset is beam center and
;  vec0 is map offset off relative to bm 0
	if debug2 then begin
	mm=matrot("yz",map_el_rad,-map_az_rad)
	vecoff1=mm#vecOff
	vec01=mm#vec0
;
; see if these match the other values
	  vec3toangles,vecoff1,azT,elT,/deg
	  print,vecOff1,azT,elT,$
      format='("vecoff1   xy:",f10.5,f10.5,f10.5," angle:",f9.4,1x,f9.4)'
	  vec3toangles,vec01,azT,elT,/deg
	  print,vec01,azt,elT,$
	  format='("vec01     xy:",f10.5,f10.5,f10.5," angle:",f9.4,1x,f9.4)'
	endif
;
;  position tolerance of 2 arcsec in radians
;  rotating our offset feed to the source will rotate
; vec to the place to point the telescope
;  
; this was close	mm=matrot("yz",-src_el_rad,src_az_rad)
;
;   take offset position and rotate it to 0,0
;   first along az, then el
;
;   testing
;
	if (debug2) then begin 
	print,"start Testing"
	mm1=matrot("zy",-map_az_rad,map_el_rad)
	aa=mm1#vecOff
	vec3toangles,aa,az1,el1,/deg
	  print,aa,az1,el1,$
      format='("vecoffTo  xy:",f10.5,f10.5,f10.5," angle:",f9.4,1x,f9.4)'

	mm2=matrot("y",-src_el_rad)
    mm3=mm2#mm1
	bb=mm2#aa
    bbT=mm3#vecOff
	vec3toangles,bb,az1,el1,/deg
	  print,bb,az1,el1,$
      format='("vec0toElsrc :",f10.5,f10.5,f10.5," angle:",f9.4,1x,f9.4)'
	vec3toangles,bbT,az1,el1,/deg
	  print,bbT,az1,el1,$
      format='("vec0toElsrcM:",f10.5,f10.5,f10.5," angle:",f9.4,1x,f9.4)'

	mm4=matrot("z",src_az_rad)
    cc=mm4#bb
	vec3toangles,cc,az1,el1,/deg
	  print,bb,az1,el1,$
      format='("vec0tosrc :",f10.5,f10.5,f10.5," angle:",f9.4,1x,f9.4)'

	mm5=matrot('yz',-src_el_rad,src_az_rad)
	mm6=mm5#mm1
	dd=mm6#vecOff
	vec3toangles,dd,az1,el1,/deg
	  print,dd,az1,el1,$
      format='("vec0tosrcM:",f10.5,f10.5,f10.5," angle:",f9.4,1x,f9.4)'
	print,"end Testing"
	endif
;
;    end testing
;
;   matrix  to rotate map offset to 0,0
;
	mm1=matrot("zy",-map_az_rad,map_el_rad)
;
; matrix to rotate center to  source position
;
	mm2=matrot('yz',-src_el_rad,src_az_rad)
	mm=mm2#mm1
;
;  apply this to  beam center (vec0)
;  also apply to map az,el offset to check that it lands on source
;	
	new_vecTel=mm#vec0
	new_vec0  =mm#vecOff
	vec3toangles,new_vec0,azNew0,elNew0,/deg
	vec3toangles,new_vecTel,azNewTel,elNewTel,/deg
	vec3toangles,vec0,az0,el0,/deg
	if verbL then begin
	  print,vecSrc,src_az_deg,src_el_deg,$
      format='("srcAz,El  xy:",f10.5,f10.5,f10.5," angle:",f9.4,1x,f9.4)'
;	  print,vec0,az0,el0,$
;      format='("vec0        :",f10.5,f10.5,f10.5," angle:",f9.4,1x,f9.4)'
	  print,vecOff,map_az_deg,map_el_deg,$
	  format='("OffAz,El  xy:",f10.5,f10.5,f10.5," angle:",f9.4,1x,f9.4)'
	  print,vecTel,-map_az_deg,-map_el_deg,$
	  format='("TelAz,El  xy:",f10.5,f10.5,f10.5," angle:",f9.4,1x,f9.4)'
	  print,"--> rotated values:"
	  print,new_vec0,aznew0,elnew0,$
	  format='("vec0Az,El xy:",f10.5,f10.5,f10.5," angle:",f9.4,1x,f9.4)'
	  print,new_vecTel,aznewTel,elnewTel,$
	  format='("Tel0Az,El xy:",f10.5,f10.5,f10.5," angle:",f9.4,1x,f9.4)'
	  print,vecG,[azG,elG]*!radeg,$
	  format='("GuesAz,El xy:",f10.5,f10.5,f10.5," angle:",f9.4,1x,f9.4)'
	  errAz=(aznewTel- azG*!radeg)*3600.*cos(elg)
	  errEl=(elnewTel - elG*!radeg)*3600.
	  print,errAz,errEl,$
	  format='("Error                                       error:",f9.4,1x,f9.4)'
	endif
	return,[aznewTel,elnewTel]
end
