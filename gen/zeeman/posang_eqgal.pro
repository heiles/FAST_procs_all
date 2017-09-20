
pro posang_eqgal, ra, dec, eqangle, year, glon, glat, gangle, $
                 inverse=inverse
;+
;Convert the position and position angle of linear pol in eq to gal, or
;vice-versa. 
;POSANG_EQGAL, ra, dec, eqangle, year, glon, glat, gangle, inverse=inverse

;INPUTS (in or out, depending on inverse):
;NOTE: IF INPUTS ARE ARRAYS, they must all be the same length.
;RA in DEGREES
;DEC
;EQANGLE, the equatorial position angle DEGREES
;GLONG: Gal long DEGREES
;GLAT: Gal lat
;Gangle, the galatic position angle in DEGREES
;
;INVERSE: go the other direction
;-

if keyword_set( inverse) eq 0 then begin
glactc, ra, dec, year, glon, glat, 1, /deg
del_ra= 0.1* sin(!dtor* eqangle) / cos(!dtor*dec) 
del_dec= 0.1* cos(!dtor* eqangle)
ram= ra- del_ra
decm= dec- del_dec
glactc, ram, decm, year, glonm, glatm, 1, /deg

rap= ra+ del_ra
decp= dec+ del_dec
glactc, rap, decp, year, glonp, glatp, 1, /deg

del_glon= modangle( glonp-glonm, 360., /negpos) * cos(!dtor* glat)
del_glat= modangle( glatp-glatm, 360., /negpos)

gangle= atan( del_glon, del_glat)/ !dtor
gangle= modangle( gangle, 180.)

;stop
endif

if keyword_set( inverse) then begin
glactc, ra, dec, year, glon, glat, 2, /deg
del_glon= 0.1*sin(!dtor* gangle) / cos(!dtor*glat) 
del_glat= 0.1*cos(!dtor* gangle)
glonm= glon- del_glon
glatm= glat- del_glat
glactc, ram, decm, year, glonm, glatm, 2, /deg

glonp= glon+ del_glon
glatp= glat+ del_glat
glactc, rap, decp, year, glonp, glatp, 2, /deg

del_ra= modangle( rap-ram, 360., /negpos) * cos(!dtor* dec)
del_dec= modangle( decp-decm, 360., /negpos)

eqangle= atan( del_ra, del_dec)/ !dtor
eqangle= modangle( eqangle, 180.)
endif

;stop
return

end
