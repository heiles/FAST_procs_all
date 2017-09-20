
pro posang_conv, long1, lat1, posang1, $
                 long2, lat2, posang2, $
    eq_to_gal=eq_to_gal, equinox=equinox, rmatrix=rmatrix, inverse=inverse

;+
;Convert the position angle of linear pol in one coordsys to another.
;POSANG_CONVERT, posang1, length1, posang2, length2, $
;    eq_to_gal=eq_to_gal, gal_to_eq=gal_to_eq, rmatrix=rmatrix
;
;INPUTS:
;NOTE: IF INPUTS ARE ARRAYS, they must all be the same length.
;LONG1: the 'longitude-like' angle in system1 (1d array OK) DEGREES
;LAT1: the 'latitude-like' angle in system1 (1d array OK) DEGREES
;POSANG1, the position angle in system1 (1d array OK) DEGREES
;
;OUTPUTS
;LONG2: the 'longitude-like' angle in system2 DEGREES
;LAT2: the 'latitude-like' angle in system2 DEGREES
;POSANG2, the position angle in system2  DEGREES
;
;KEYWORDS:
;set ONLY ONE of the following keywords!
;EQ_TO_GAL: system 1 is equatorial, system 2 is Galactic
;inverse: go the other direction
;EQUINOX: equinox to use for eq_to_gal (2000 is default).
;RMATRIX: the rotation matrix that converts system 1 to system 2.
;
;kluge: use glactc for eq to gal as of 19 feb 2017
;-

;stop

if keyword_set( eq_to_gal) then begin
if n_elements( equinox) eq 0 then equinox=2000.d0
glactc, longpole, latpole, equinox, 0.d0, 90.d0, 2, /deg
;longpole= 192.85948
;latpole= 27.128302
longoffset= 57.068 ; *0.
rmatrix, longpole, latpole, rmatrix, longoffset=longoffset
inverse=0
;stop
if keyword_set( gal_to_eq) then inverse=1
endif else begin
if n_elements( rmatrix) ne 9 then begin
stop, 'you have not specified coord sys nr 2. STOPPING'
;   return
endif
endelse
;stop
nrp= n_elements( long1)

;first, get the positions in system2:
sph_coord_conv, long1, lat1, rmatrix, long2, lat2, inverse=inverse
long2= modangle(long2, 360.)

;next, the end points of line segments 0.2 deg long...
del_long1= 0.1*sin(!dtor* posang1)/ cos(!dtor*lat1) 
del_lat1= 0.1*cos(!dtor* posang1)
long1m= long1- del_long1
lat1m= lat1- del_lat1
long1p= long1+ del_long1
lat1p= lat1+ del_lat1
sph_coord_conv, long1m, lat1m, rmatrix, long2m, lat2m, inverse=inverse
sph_coord_conv, long1p, lat1p, rmatrix, long2p, lat2p, inverse=inverse
del_long2= long2p- long2m
del_lat2= lat2p- lat2m

posang2= atan( del_long2* cos(!dtor* lat2), del_lat2)/ !dtor
posang2= modangle( posang2, 180.)
;posang1x= atan( del_long1* cos(!dtor* lat1), del_lat1)/ !dtor
;print, 'posang1x= ', posang1x

return

end
