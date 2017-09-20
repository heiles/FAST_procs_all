pro doppler, ra_hrs, dec_deg, equinox, julday, obslongitude, obslatitude, $
	v_barycen, v_lsr

;+
;NAME: DOPPLER
;
;PURPOSE:
;	GIVE DOPPLER VELOCITY KM/S WITH RESPECT TO BARYCENTER AND ALSO LSR. 
;
;CALLING SEQUENCE:
;	doppler, ra_hrs, dec_deg, equinox, julday, obslongitude, obslatitude, $
;	v_barycen, v_lsr
;
;INPUTS:
;	RA, DEC ARE OF THE SPECIFIED EQUINOX. UNITS ARE DECIMAL HOURS, DEGREES
;	EQUINOX: EQUINOX OF THE RA, DEC, IN YEARS. E.G. 2000.	
;	JULDAY: THE JULIAN DAY IN DBL PRECISION, TELLS THE EXACT TIME.
;	OBSLONGITUDE, OBSLATITUDE: OBSERVER'S LONGITUDE, LATITUDE IN DEGREES.
;		LONGITUDE IS WEST LONG, E.G. CALIFORNIA IS +122.
;		IF LATITUDE LT ZERO, IT GIVES VELOCITY OF EARTH'S CENTER.
;
;OUTPUTS:
;	V_BARYCEN IS VELOCITY WRT BARYCENTER AND V_LSR IS WRT LSR. 
;		NEGATIVE VELOCITIES MEAN APPROACH, OR
;		HIGHER FREQUENCIES FROM THE DOPPLER SHIFT
;
;COMMENTS, RESTRICTIONS, ETC:
;	THE LSR IS BASED ON THE CLASSIC RADIO ASTRONOMY ONE, 
;		20 KM/S TOWARDS (RA,DEC)_1900 = (18:00, 30:00)
;	WE NEGLECT THE OBSERVER'S HEIGHT ABOVE SEA LEVEL. THIS ISN'T
;		GOOD FOR HIGH PLACES LIKE MAUNA KEA!
;	ACCURACY SHOULD BE 1 M/S. BASED ON GSFC BARYVEL.
;
;TO COMPUTE JULDAY, YOU CAN USE JDCNV. EXAMPLE: GMT 5.5 HRS ON 15-FEB-1994,
;	JDCNV, 1994, 2, 15, 5.5, JULDAY
;
;-

baryvel, julday, equinox, vhelio, vbary

daycnv, julday, yr, mn, day, hr
equinox_julday = yr + ((mn+0.5)/12.)
ra_julday  = 15. * ra_hrs
dec_julday = dec_deg
precess, ra_julday, dec_julday, equinox, equinox_julday

ra  = !dtor * ra_julday
dec = !dtor * dec_julday

;PROJECT VELOCITY TOWARD STAR...
v_barycen = vbary(0)*cos(dec)*cos(ra) + $   
	vbary(1)*cos(dec)*sin(ra) + vbary(2)*sin(dec) 

v_barycen = -v_barycen

lsrvel, ra_hrs, dec_deg, equinox, delvlsr

v_lsr = delvlsr + v_barycen

delvtopo = 0.
if (obslatitude ge 0.) then $
	topovel, obslongitude, obslatitude, ra, dec, julday, delvtopo

v_barycen = v_barycen + delvtopo

;print, delvlsr, v_barycen, v_lsr, delvtopo

;print, 'year, month, day, hour = ', yr, mn, day, hr

;stop

return
end

