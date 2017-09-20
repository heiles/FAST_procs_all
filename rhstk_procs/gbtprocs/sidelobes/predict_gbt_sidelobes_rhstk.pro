
; PROGRAM IS BELOW....

;========================================================================

function predict_gbt_sidelobes_rhstk_shield, theta, phi, radius, width
;+
; generate a guess for sheild beam given delaz, delza
; theta and phi are passed in in degrees
; radius and angle are passed in in degrees
; delaz is great circle degrees; delza is degrees.
; evaluate the angular dependence...
;-
ts= findgen(8)
;hg=[900., 70., 100., 70., 0., 70.,  100., 70.]
hg=[900., 70., 100., 70., 30., 70.,  100., 70.]
hgf= fft(hg)
delfrq= 1./8
frq= shift( -0.5 + findgen(8)*delfrq,4)
;dft, frq, hgf,ts, hgf_dft, /inverse
;tsx= 0.1*findgen(80)
;dft, frq, hgf,tsx, hgfx_dft, /inverse
;wset,0
;plot, tsx, hgfx_dft
;oplot, ts, hgf_dft, psym=4

;radius0 = 2.8 
;radiuswid= 1.1 - carl originally had 1.1 here
; but he also had the gaussian distribution formula off by a factor of two
; don't understand the choice
;radiuswid = 2.1

tsa= 8.* (!dtor * phi)/(2.*!pi)
dft, frq, hgf, tsa, ampl, /inverse

output = ampl* exp( -0.5 * ( (theta - radius) / (width/2.35482d0) )^2 )
outputr = real_part(output) > 0
outputr = outputr/900.

return, outputr
end ; predict_gbt_sidelobes_rhstk_shield

;========================================================================

pro predict_gbt_sidelobes_rhstk, vlsr, derivs, fsrc, $
                           sidelobes, SHOWMAP=showmap, $
                           NONEARIN=nonearin, NOTIMES2=notimes2, $
                           LAB_PATH=lab_path

;+
; NAME:
;       PREDICT_GBT_SIDELOBES
;
; PURPOSE:
;       GIVEN A POSITION AND AN MJD, THIS WILL CONVOLVE OUR MODELED GBT
;       SIDELOBE RESPONSE WITH THE LAB HI SURVEY TO PREDICT THE SIDELOBE
;       CONTRIBUTION IN A 21-CM GBT SPECTRUM...

; INPUTS:
;       VLSR, the set of VLSR's for which the responses are computed
;       DERIVS, the set of angular derivatives for squint, squash
;       FSRC - the Heiles/Robishaw-style array of structures for
;              frequency-switched observations....
;              If fsrc is imported from elsewhere, it needs tags:
;              .sname (source name)
;              .lst (hours) *********SEE NOTE RAGARDING LST AND MJD BELOW!
;              .mjd (mod jul day) ***SEE NOTE RAGARDING LST AND MJD BELOW!
;              .antlat (nlat of telescope in deg)
;              .antlong (wlong of telescope in deg)
;              .sra (source ra in ***** DEGREES ********)
;              .sdec (source dec in deg)
;              .sepoch (obs epoch in yr, e.g. 2000.00)
;
; OUTPUTS:
;       SIDELOBES - a structure containing the various GBT sidelobe
;                   contributions to the observed 21-cm spectrum at the
;                   requested position and time.  It contains the following
;                   tags:
;
;                   .VLSR - the VLSR vector for the 5 spectra below.
;                   .SPILLOVER - the contribution from our model of the
;                                spillover ring around the secondary.
;                   .SPOT - the contribution from our model of the Poisson
;                           spot behind the secondary.
;                   .NEARIN - the contribution from our model of the
;                             near-in first sidelobe of the main beam.
;                   .SCREEN - the contribution from our empirically
;                             determined model for the low-level response
;                             we see at 163 arcmin from the main beam
;                             (whose source we have been hypothesizing is
;                             the spillover screen on the armward side of
;                             the secondary)
;                   .ONSOURCE - the LAB spectrum at the source position
;
; DEPENDENCIES:
;         READFITS() - Goddard function
;         FITS_MAKE_AXIS() - Robishaw function
;         GLACTC - Goddard procedure
;         PRECESS - Goddard procedure
;         LEGEND - Goddard procedure
;         HADEC2ALTAZ - Goddard procedure
;         ALTAZ2HADEC - Goddard procedure
;         LOOP_PROGRESS - 
;         RMATRIX -
;         SPH_COORD_CONV -
;         SQCORR -
;           Z17_EVAL - 
;                   
; KEYWORDS:
;        /SHOWMAP - will show the sidelobe response on a map of tha LAB
;                   survey.
;        /NONEARIN - bypasses the nearin component. If you set this,
;                    DERIVS is a dummy input.
;        /NOTIMES2 - default is to multiply LAB data by 2 to give us the
;                    Stokes I output.  Set this keyword if you want the
;                    temperature rather than the Stokes I.
;        LAB_PATH - path to the LAB fits file ('lab.fits')
;                   if none given, it searches for the file
;
; NOTE REGARDING LST AND MJD...
;       The MJD is used for the velocity calculation. 
;       The LST is used for locating beams in the sky.
;       These are used independently, so they don't have to 'match'. In
;       particular, the Velocity doesn't change much with time, so if
;       you are comparing a bunch of different LSTs for given source
;       position you don't need to increment MJD along with LST (unless
;       you really want the ultimate in accuracy--but if you are
;       concerned about accuracy at that level, you should get a better
;       scheme for doing these calculations!
;
; LIMITATIONS:
; * we never consider spillover hitting ground; if your source is at low
;   declination such that the spillover ring is hitting the ground, our
;   algorithm still incorporates the Milky Way emission from the positions
;   where the sidelobe is actually hitting the ground.
; * when shifting spectra to new velocity frames, we are simply shifting by
;   the closest integer number of frequency channels; we are not doing any
;   weird interpolation and fractional pixel shifts.
;
; HISTORY: 
; 24dec2008: ch incoporated spillovercoeff, etc, in the returned spectra.
; 06jul2012: tr made a number of changes:
; * cleaned up code that was never being used
; * was using a "test" LAB cube that did not cover full velocity extent or
;   full sky; this led to problems for sources outside the test cube. now
;   using the entire lab.fits data cube.
; * we changed order in which we process LAB spectra:
;   we now leave the LAB spectra in their native velocity resolution and
;   shift the velocity of each line of sight appropriately; we then
;   resample the final LAB spectrum to the GBT velocity sampling.  We had
;   been resampling LAB spectra prior to the velocity shifts.
; * there was an incorrect one-pixel shift to negative velocities for all
;   spillover spectra, now fixed
; * removed addpath calls to direcories in Carl's berkeley directory; have
;   not tested behavior of SQCORR if /NONEARIN is not set
;
;-

; ADOPTED MULTIPLIERS FROM TABLE 2 OF THE PAPER...
; THESE ARE THE COEFFICIENTS BY WHICH YOU MULTIPLY THE SIDELOBES,
; SPILLOVER, AND SPOT CONTRIBUTIONS, RESPECTIVELY...
spillovercoeff= 0.087
nearincoeff= 0.022
spotcoeff= 0.001
screencoeff=0.007

srcnm = fsrc[0].sname

; WE'LL NEED THE LST...
gbt_lst = fsrc.lst

; WE'LL NEED THE FULL JULIAN DAY...
gbt_julday = fsrc.mjd + 2400000.5d0

; WE NEED THE VELOCITY...
gbt_v = vlsr
nv_gbt = N_elements(vlsr)

;==========================================================================
; NEXT WE OPEN THE LAB LSR CUBE...
; WE SHIFT EACH SPECTRUM TO THE TOPOCENTRIC FRAME...
; WE COVOLVE WITH THE SIDELOBE MODEL RESPONSE...
; WE THEN TRANSFORM THE FINAL SPECTRUM BACK TO THE LSR FRAME...

; RESTORE THE LAB CUBE IN THE LSR FRAME...
labfilename = 'lab.fits'

; HAS THE USER POINTED US TO THE LAB FITS FILE...
if (N_elements(lab_path) eq 1) then begin
   labfile = lab_path + '/' + labfilename
   found = file_test(labfile)
   if (found eq 0) then message, 'LAB FITS file not found at '+lab_path
endif else begin
   labfile = FILE_SEARCH(STRSPLIT(!PATH, PATH_SEP(/SEARCH_PATH),/EXTRACT) $
                         + '/' + labfilename, COUNT=n_files)
   if (n_files eq 0) then message, 'LAB FITS file not found on !PATH.'
endelse

; OPEN THE LAB FITS FILE...
print, 'Opening LAB FITS file: '+labfile
labcube_lsr = readfits(labfile,hdr)

l = fits_make_axis(hdr,1)
b = fits_make_axis(hdr,2)
nl = N_elements(l)
nb = N_elements(b)
lab_v = fits_make_axis(hdr,3) / 1d3 ; km/s

; SHIFT THE LAB CUBE SO IT RUNS FROM l=360->0 RATHER THAN -180->+180...
labcube_lsr = shift(labcube_lsr,360,0,0)
l = shift(l,360)
l = l + 360*(l lt 0)

; NORTHERN LDS DATA ARE MISSING ANY CHANNELS ABOVE CHANNEL=832...
; SO WE GET RID OF THESE CHANNELS FROM EVERY LAB SPECTRUM
; TO AVOID WEIRDNESS...
lab_v = lab_v[0:832]
labcube_lsr = labcube_lsr[*,*,0:832]
nv_lab = (size(labcube_lsr))[3]

; GET THE VELOCITY RESOLUTIONS...
gbt_vres = gbt_v[3] - gbt_v[2]
lab_vres = lab_v[3] - lab_v[2]

; MAKE IMAGES OF THE L AND B...
lgrid = rebin(l,nl,nb)
bgrid = transpose(rebin(b,nb,nl))

; GET THE GALACTIC COORDINATES OF THE NCP...
;lncp = 122.93194
;bncp = 27.128405
;useless = min(abs(l-lncp),ncp_lindx)
;useless = min(abs(b-bncp),ncp_bindx)

; MAKE DATA CUBE STOKES I... MULTIPLY BY 2...
if keyword_set( notimes2) then begin
    print, '>>>> NOT multiplying lab cube by 2 (notimes2 is set) <<<<'
    endif else begin
        labcube_lsr = 2*labcube_lsr
        print, '******** MULTIPLYING LAB DATA CUBE BY 2 TO GET STOKES I !!!! ************'
    endelse

; MAKE SURE LAB AND GBT NCP SPECTRA ARE ALIGNED...
;plot, gbt_v, gbt_stokes_i[*,0], xs=19
;oplot, lab_v, labcube_lsr[ncp_lindx, ncp_bindx,*], co=!red

; EACH MEASURED GBT LST WILL BE USED TO MAKE OUR MODEL...
nlst = N_elements(gbt_lst)

; MAKE ARRAY TO STORE AVERAGED LAB SPECTRA...
avg_lab_stokes_I_spill = fltarr(nv_lab, nlst)
avg_lab_stokes_I_spot = fltarr(nv_lab, nlst)
avg_lab_stokes_I_screen_163 = fltarr(nv_lab, nlst)

; MAKE ARRAY TO STORE AVERAGED LAB SPECTRA AFTER INTERPOLATION TO GBT
; SAMPLING...
avg_lab_stokes_I_spill_interp = fltarr(nv_gbt, nlst)
avg_lab_stokes_I_spot_interp = fltarr(nv_gbt, nlst)
avg_lab_stokes_I_screen_163_interp = fltarr(nv_gbt, nlst)

; STACK THESE SPECTRA TO MAKE A 2D ARRAY OF [POSITION,CHANNEL]...
labstack_lsr = reform(labcube_lsr, nl*nb, nv_lab)
lstack = reform(lgrid, nl*nb)
bstack = reform(bgrid, nl*nb)

;ncp_indx = (ncp_bindx * nl) + ncp_lindx

; WE'LL DISPLAY THE CUBE INTEGRATED OVER VELOCITY...
map = total(labcube_lsr,3)^0.5
map_img = map/max(map)

; TAKE A LOOK AT A MAP OF THE HA/DEC AS A FUNCTION OF AZ/EL AS SEEN FROM
; GREEN BANK...
; FOR THESE OBSERVATIONS, THE TELESCOPE WAS ALWAYS POINTING AT THE NCP, AT
; (AZ,EL) = (0,GBTLAT)...
; THE FEED ARM IS **ABOVE** THE PRIMARY, SO THE SPILLOVER LOBE WILL POINT
; TO HIGHER ELEVATION THAN THE NCP (BY 12.3 DEGREES)...
; SO WHAT RA DOES THIS CORRESPOND TO AT A GIVEN LST?
; WELL, THE HA AT AZ=0 AND ELEVATIONS ABOVE THE NCP IS 0 HOURS, SO
; FOR THE CENTER OF THE SIDELOBE, RA = LST - 0h, OR RA=LST...

; SET UP THE DISPLAY WINDOWS...
xsize = 500
ysize = 500
pix_win = 13 
window, pix_win, XSIZE=xsize, YSIZE=ysize, /PIXMAP
plot_win = 0
window, plot_win, XSIZE=xsize, YSIZE=ysize

; WE NEED IMAGES OF THE RA AND DEC...
glactc, ragrid, decgrid, 2000, lgrid, bgrid, 2

; GET THE WLONG AND NLAT OF THE GBT...
gbtlat = fsrc[0].antlat
gbtlong = fsrc[0].antlong

; DEFINE THE POSITION VECTOR TOWARD EACH LINE OF SIGHT IN THE LAB CUBE...
s_grid = [[[cos(!dtor*15.*ragrid)*cos(!dtor*decgrid)]], $
          [[sin(!dtor*15.*ragrid)*cos(!dtor*decgrid)]], $
          [[sin(!dtor*decgrid)]]]

; STACK THESE; GO FROM 3D [NL,NB,3] ARRAY TO 2D [NL*NB,3] ARRAY...
s_grid = reform(s_grid,nl*nb,3)

; THE DISTANCE OF THE FEED-SECONDARY AXIS FROM THE MAIN BEAM AXIS...
sl_distance = 12.329 ; deg

; THE TRANSFORM FROM THE LSR TO THE HELIOCENTRIC FRAME IS
; INDEPENDENT OF TIME...
ra0 = ten(18,03,50.24) ; hr J2000
dec0 = ten(30,00,16.8) ; deg J2000
v_sun_wrt_lsr_dot_s = 20.0 * (cos(!dtor*15.0*(ragrid-ra0)) $
                              * cos(!dtor*decgrid) $
                              * cos(!dtor*dec0) $
                              + sin(!dtor*decgrid) $
                              * sin(!dtor*dec0))

lsr_to_helio = - v_sun_wrt_lsr_dot_s

; CREATE BLANK SHIFTED LAB ARRAY...
labstack_topo = fltarr(nl*nb,nv_lab,/NOZERO)

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; SOURCE DEPENDENCE...

; GET THE REQUESTED SOURCE RA AND DEC...
; DO NOT GET THE TELESCOPE ENCODER VALUES, BECAUSE THERE ARE ODDITIES,
; ESPECIALLY AT THE POLES...
src_ra = fsrc[0].sra   ; deg
src_dec = fsrc[0].sdec ; deg
if (fsrc[0].sepoch ne 2000) then begin
   precess, src_ra, src_dec, fsrc[0].sepoch, 2000.0
endif

; GET THE GALACTIC COORDINATES OF THE SOURCE...
glactc, src_ra/15.0, src_dec, 2000, src_l, src_b, 1

; GET THE ONSOURCE LAB SPECTRUM...
dummy= min(abs(l- src_l), src_lindx)
dummy= min(abs(b- src_b), src_bindx)
onsource = reform(labcube_lsr[src_lindx,src_bindx,*])

; FREE UP SOME MEMORY...
labcube_lsr = 0b

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; GO THROUGH EACH MEASURED GBT LST AND POPULATE THE AVERAGE LAB
; SPECTRUM ARRAY BY CONVOLVING THE SIDELOBE PATTERN WITH THE LAB...
for a = 0, nlst-1 do begin

   ; UPDATE OUR PROGRESS...
   loop_progress, a, 0, nlst-1

   ;-------------------------------------------------------
   ; GET THE (RA,DEC) OF THE FEED-SECONDARY AXIS...

   ; GET THE (AZ,EL) OF THE SOURCE...
   ; COULD PROBABLY USE THE AZ AND ZA STORED IN FSRC...

   src_ha_deg = 15.*gbt_lst[a] - src_ra ; degrees
   hadec2altaz, src_ha_deg, src_dec, gbtlat, src_el, src_az

   ;print, '~~~~~~~~~~~~~~~~'
   ;print, src_el, src_az
   ;print, 90.0-fsrc[a].za, fsrc[a].az
   ;print, '~~~~~~~~~~~~~~~~'

   ; THE SIDELOBE WILL BE CENTERED AT AN ELEVATION THAT IS 12.3 DEGREES
   ; ABOVE THE SOURCE POSITION...

   ; IF THE SOURCE IS ABOVE ELEVATION (90-12.3) THEN WE MUST BE CAREFUL...
   ; THE SIDELOBE WILL BE LOCATED AT AN AZIMUTH THAT IS 180 DEGREES AWAY
   ; FROM THE MAIN BEAM AND THE ELEVATION WILL BE 180-12.3-(source elev)
   sl_el = src_el + sl_distance
   sl_az = src_az
   if (sl_el gt 90.0) then begin
      sl_el = 180.0 - sl_el
      sl_az = sl_az - 180.0
   endif

   ; GET THE (HA,DEC) OF THE SIDELOBE CENTER...
   altaz2hadec, sl_el, sl_az, gbtlat, sl_ha, sl_dec

   ; GET THE RIGHT ASCENSION OF THE SIDELOBE CENTER AT THIS LST...
   sl_ra = gbt_lst[a] - sl_ha/15.0 ; hours

   ; GET THE GALACTIC COORDINATES OF THE SIDELOBE CENTER...
   glactc, sl_ra, sl_dec, 2000, l_sl, b_sl, 1

   ;goto, skip_transform

   ;------------------------------------------------------
   ; TRANSFORM LAB CUBE TO TOPOCENTRIC FRAME...

   ; TRANSFORM FROM THE GEOCENTRIC TO THE TOPOCENTRIC FRAME...
   ; VTOPO = VGEO + 0.465 * cos(latitude) * cos(dec) * sin(HA)
   v_topo_wrt_geo_dot_s = - 0.465 * cos(!dtor*gbtlat) $
                          * cos(!dtor*decgrid) $
                          * sin(!dtor*15.*(gbt_lst[a]-ragrid))

   geo_to_topo = - v_topo_wrt_geo_dot_s

   ;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
   ; THE CHANGE OVER THE MAP WILL BE AT MOST 1 KM/S IN 24 HOURS
   ; WITH MOST LINES OF SIGHT SHOWING A CHANGE BETWEEN 0.2 AND 0.6
   ; KM/S...

   ; TRANSFORM FROM HELIOCENTRIC TO THE GEOCENTRIC FRAME...
   baryvel, gbt_julday[a], 2000, v_geo_wrt_helio, v_geo_wrt_bary

   ;^^^^^^^^^^
   ; SEP03....
   ;
   ; OBSERVATIONS WERE TAKEN A WEEK APART, SO THE EARTH VELOCITY
   ; WRT THE SUN HAS CHANGED FROM +10 TO +7.5 KM/S.  OVER A 24
   ; HOUR PERIOD IN SEPTEMBER, THE CHANGE IS ABOUT 0.5 KM/S.
   ;
   ; JAN03....
   ;
   ; OBSERVATIONS WERE TAKEN OVER 2 WEEKS WITH THE EARTH VELOCITY
   ; WRT THE SUN CHANGING FROM -29 TO -26.5 KM/S.  OVER 12 HOURS,
   ; THE VELOCITY CHANGED BY ABOUT 0.2 KM/S.

   for pos = 0l, nl*nb-1l do begin

      ; VGEO = VHELIO - (V_GEO_WRT_HELIO dot s)      
      v_geo_wrt_helio_dot_s = total(v_geo_wrt_helio * s_grid[pos,*])
      
      helio_to_geo = - v_geo_wrt_helio_dot_s

      lsr_to_topo = lsr_to_helio[pos] + $
                    helio_to_geo + $
                    geo_to_topo[pos]

      ; CALCULATE THE NUMBER OF CHANNELS TO SHIFT BY...
      shift_chan_lsr_to_topo = lsr_to_topo / lab_vres

      ; NOW SHIFT THE SPECTRA...
      labstack_topo[pos,0] = shift(labstack_lsr[pos,*], 0, $
                                   shift_chan_lsr_to_topo)

      ;plot, lab_v, labstack_lsr[pos,*]
      ;oplot, lab_v, labstack_topo[pos,*], co=!red
      ;io = get_kbrd(1)

   endfor

   skip_transform:

   ;--------------------------------------------------------

   ; ORIENT THE SIDELOBE AND CALCULATE WEIGHTS...

   ; THE TOTAL SIDELOBE RESPONSE WILL COME FROM THE FOLLOWING
   ; COMPONENTS...
   ; SPILL = SPILLOVER
   ; ARAGO = POISSON SPOT
   ; SCREEN = SCREEN
   
   ; CALCULATE THE ROTATION MATRIX CENTERED ON THE FEED-SECONDARY
   ; AXIS...
   rmatrix, l_sl, b_sl, rtot_spillover, LONGOFFSET=0

   ; GET THE ANGLE FROM THE FEED-SECONDARY AXIS TO THE SOURCE
   ; POSITION...
   sph_coord_conv, src_l, src_b, rtot_spillover, phi_src, theta_src
   
   ; OUR NEW ROTATION MATRIX WILL NEED TO ROTATED BY THIS ANGLE...
   ; WE ALSO WANT THE ZERO TO BE ON THE OTHER SIDE OF THE MAIN
   ; BEAM, TOWARD THE FEED ARM, SO WE ADD 180 DEGREES...
   rmatrix, l_sl, b_sl, rtot_spillover, $
            LONGOFFSET=phi_src[0]+180.0
   
   ; NOW WE DEFINE THE NEW SECONDARY-CENTERED SPHERICAL COORDINATE
   ; SYSTEM...
   sph_coord_conv, lgrid, bgrid, rtot_spillover, sl_phigrid, sl_thetagrid

   ; LET'S GET THE COORDINATES OF THE EDGE OF THE SECONDARY...
   theta = 90.0 - 15. + fltarr(361)
   phi = findgen(361)
   sph_coord_conv, phi, theta, rtot_spillover, lring, bring, /INVERSE
   lring = modangle(lring,360.0)

   ; MAKE AN IMAGE OF THE DECLINATION OFFSET RELATIVE TO THE
   ; CENTER OF THE SIDELOBE...
   ;ddec = decgrid - sl_dec ; degrees
   
   ; MAKE AN IMAGE OF THE RIGHT ASCENSION OFFSET RELATIVE TO THE
   ; CENTER OF THE SIDELOBE...
   ;dra = ragrid - sl_ra ; hours
   ;dra = modangle(dra, 24, /NEGPOS) ; hours
   
   ; GET THE GREAT CIRCLE DISTANCE BETWEEN THE SIDELOBE CENTER AND
   ; ALL POINTS IN THE MAP...
   ; INPUT RA(HR), DEC(DEG), OUTPUT DIST(ARCSEC)...
   gcirc, 1, sl_ra, sl_dec, ragrid, decgrid, sl_dist
   sl_dist = sl_dist / 3600.0
   
   old_scheme = 0;+1
   
   if keyword_set(old_scheme) then begin

      ; THESE ARE THE PARAMETERS FOR THE FEED TAPER...
      feed_pattern = [7.0, -1.26667] ; dB/deg
      
      ; MAKE AN IMAGE OF THE FEED ILLUMINATION PATTERN...
      dist_dB = feed_pattern[0] + feed_pattern[1] * sl_dist
      
      ; THE POWER RESPONSE OF THE FEED WILL DETERMINE OUR WEIGHTS...
      weight_ring = 10d0^(dist_dB/10.0)

      ;---------------------------
      ; SAVE TIME BY SELECTING ONLY THE WEIGHTS THAT FALL WITHIN AN
      ; ANNULUS...
      r0 = 15.0 ; deg
      r1 = 35.0 ; deg
      wgt_indx = where(sl_dist gt r0 AND sl_dist lt r1, nwgt, $
                       COMP=out_indx, NCOMP=nout)
      weight_ring[out_indx] = 0.0

   endif else begin
      
      ; WE'RE GOING TO USE THE FUNCTIONAL FORM DERIVED FROM THE SUN
      ; SCANS FOR THE RADIAL RESPONSE FUNCTION...
      hgt = [48.1225,42.0081]
      cen = [20.5933,16.3681]
      wid = [3.33469,8.77619] ; FWHM
      weight_ring = sl_dist * 0
      for ng = 0, N_elements(hgt)-1 do $
         weight_ring = weight_ring $
         + hgt[ng] * exp( -0.5 * (sl_dist - cen[ng])^2 / (wid[ng]/2.35482d0)^2 )

      ;---------------------------
      ; SAVE TIME BY SELECTING ONLY THE WEIGHTS THAT FALL WITHIN AN
      ; ANNULUS...
      r0 =  0.0  ; deg
      r1 = 45.0 ; deg
      wgt_indx = where(sl_dist gt r0 AND sl_dist lt r1, nwgt, $
                       COMP=out_indx, NCOMP=nout)
      weight_ring[out_indx] = 0.0
      
   endelse


   ;---------------------------
   ; BY EYE, IT LOOKS LIKE THE ARMWARD SCREEN SUBTENDS 10.7% OF
   ; THE CIRCUMFERENCE OF THE SPILLOVER RING... THAT IS AN ARC OF
   ; 0.671 RADIANS OR 38.447 DEGREES...
   ; THE SCREEN IS OPPOSITE THE MAIN BEAM...
   ; ROGER SENT US SPECS FOR THE SCREEN...
   ; ITS EXENT IS 120 INCHES = 3.048m
   ; THE CIRCUMFERENCE OF THE SECONDARY IS ROUGHLY:
   ; 2*PI*(7.55m/2) = 23.72m
   ; THE ANGULAR EXTENT OF THE SCREEN IS THEREFORE ~38.55 DEG
   ; screen_angle = 38.5 ; deg

;   screen_angle = 55.0
   screen_angle = 49.4 ;the weighted average. change 3sep2008.

   screen_mask = where(abs(sl_phigrid) lt 0.5*screen_angle)
      
   weight_ring[screen_mask] = 0.0

   ;---------------------------
   ; WEIGHT AND AVERAGE THE DATA...
   weight_ring_img = rebin(weight_ring[wgt_indx],nwgt,nv_lab)
   lab_avg_stokes_I = total(weight_ring_img  * labstack_topo[wgt_indx,*],1) / $
                      total(weight_ring[wgt_indx])
   
   avg_lab_stokes_I_spill[0,a] = lab_avg_stokes_I

   ;---------------------------
   ; NOW WE ADD A RADIAL RECTANGLE...
   ; THE WIDTH IS DETERMINED BY THE DIFFRACTION LIMIT...
   ; lambda/D = 21cm / 7.55 m = 1.6 deg
   ; WE CONSIDER EQUAL PATH LENGTHS FROM OUT AT INFINITY
   ; CONVERGING ON THE FEED FROM BELOW AND ABOVE THE SECONDARY,
   ; WHICH IS TILTED SO THAT THE "TOP" IS CLOSER TO THE FEED THAN
   ; THE "BOTTOM"...
   ; THIS IS KNOWN AS "ARAGO'S SPOT" OR "POISSON'S SPOT"...
   ; THE SPOT WILL EXTEND FROM THE FEED-SECONDARY AXIS TOWARD THE MAIN
   ; BEAM...
   ;arago_width = 1.6 ; deg
   ;arago_length = 2.869 ; deg
   
   sl_dgrid = 90 - sl_thetagrid
   sl_xgrid = sl_dgrid * sin(!dtor * sl_phigrid)
   sl_ygrid = sl_dgrid * cos(!dtor * sl_phigrid)

   ; SPOT CAN BE FIT FROM SUN SCANS AS A GAUSSIAN WITH PARAMETERS
   ; IN THE RADIAL DIRECTION...
   ; hgt = 87.2899
   ; SAME HEIGHT AS MAX RESPONSE OF SPILLOVER SIDELOBE; THIS IS ACTUALLY
   ; THEORETICALLY EXPECTED FOR PLANE WAVES INCIDENT ON THE
   ; SECONDARY... THE WAVES WERE SPHERICAL THE INTENSITY WOULD BE 1/4 OF
   ; THE SPILLOVER INTENSITY...
   ; cen = 0.392895 ; deg
   ; wid = 1.08842  ; deg

   ;!!!!!!!!!!!!!!!!!!
   ; THE WIDTH OF THIS SHOULD BE SMALLER BECAUSE THE SUN IS CONVOLVED WITH
   ; THE SPOT...
   ;!!!!!!!!!!!!!!!!!!
   
   weight_spot = 87.2899 * exp( -0.5 * ( (sl_ygrid - (-0.3929) )^2 + (sl_xgrid - 0.0)^2 ) $
                                / (1.0884/2.35482d0)^2 )
   spot_indx = where(sl_dgrid lt 6.0,nspot)
   weight_spot_img = rebin(weight_spot[spot_indx],nspot,nv_lab)
   lab_avg_stokes_I_spot = total(weight_spot_img * labstack_topo[spot_indx,*],1) / $
                            total(weight_spot[spot_indx])

   avg_lab_stokes_i_spot[0,a] = lab_avg_stokes_I_spot

   ; FIND THE POINTS IN THIS RECTANGLE...
   ;arago_mask = where(abs(sl_xgrid) le 0.5*arago_width AND $
   ;                   sl_ygrid le 0 AND sl_ygrid ge -arago_length, narago)
   ;weight_spot = fltarr(nl,nb)

   ; JUST TAKE A STRAIGHT MEAN OF THE POINTS IN THE RECTANGLE...
   ;if (narago gt 0) then begin
   ;   weight_spot[arago_mask] = 1.0
   ;   lab_avg_stokes_I_spot = total(labstack_topo[arago_mask,*],1) / $
   ;                           narago
   ;   avg_lab_stokes_I_spot[0,a] = lab_avg_stokes_I_spot
   ;  ;plot, lab_v, lab_avg_stokes_I_spot
   ;  ;io = get_kbrd(1)
   ;endif else stop, 'No SPOT'

   ;---------------------------
   ; NOW WE ADD A CONTRIBUTION FROM THE SCREEN...

   ; LOBE IS CENTERED AT -2.6 DEGREES FROM MAIN BEAM...
   ; HAS WIDTH OF 1.1 DEGREES...
   ; BRIGHTER ON SIDE OF MAIN BEAM AWAY FROM THE SECONDARY...
   ; PEAK RESPONSE IS 3.2 TIMES THAT OF THE SPILLOVER MAXIMUM...
   ; IT'S DOWN TO 1.25 TIMES THE SPILLOVER PEAK ON THE ARMS ALIGNED
   ; AT 45 DEGREES TO THE VERTICAL...

   ; WE WANT TO SET UP A COORDINATE SYSTEM CENTERED ON THE SOURCE POSITION,
   ; WHERE THE MAIN BEAM IS POINTING...

   ; WE'LL TAKE THE ZERO OF THE ANGULAR COORDINATE TO BE POINTED
   ; AWAY FROM THE SECONDARY...
   rmatrix, src_l, src_b, rtot_mainbeam, $
            LONGOFFSET=phi_src[0]

   rmatrix, src_l, src_b, rtot_mainbeam2, $
            LONGOFFSET=phi_src[0]+180.0

   ; NOW WE DEFINE THE NEW SECONDARY-CENTERED SPHERICAL COORDINATE
   ; SYSTEM...
   sph_coord_conv, lgrid, bgrid, rtot_mainbeam, mb_phigrid, mb_thetagrid
   mb_dist = 90.0 - mb_thetagrid

   sph_coord_conv, lgrid, bgrid, rtot_mainbeam2, mb_phigrid2, mb_thetagrid2
   mb_dist2 = 90.0 - mb_thetagrid2

   ; WE TRY THREE DIFFERENT RADII...
   weight_screen_163 = reform( $
                       predict_gbt_sidelobes_rhstk_shield( $
                       mb_dist, mb_phigrid, 2.8, 0.5), $
                       nl, nb)

   ; SAVE TIME BY SELECTING OUT TO A RADIUS OF 6 DEGREES...
   wgt_indx = where(mb_dist lt 6.0,nwgt)

   weight_screen_163_img = rebin(weight_screen_163[wgt_indx],nwgt,nv_lab)

   lab_avg_stokes_I_screen_163 = total(weight_screen_163_img * labstack_topo[wgt_indx,*],1) / $
                                 total(weight_screen_163[wgt_indx])

   ;plot, gbt_stokes_i[*,a]
   ;oplot, lab_avg_stokes_I_screen, co=!red
   ;stop

   avg_lab_stokes_I_screen_163[0,a] = lab_avg_stokes_I_screen_163

   ;display, mb_thetagrid, l, b, out=out
   ;contour, mb_thetagrid, l, b, levels=findgen(15)*10-50, c_col=!blue, /OVER
   ;plots, lncp, bncp, thick=2, col=!red, ps=7
   ;plots, l_sl, b_sl, thick=2, col=!magenta, ps=7
   ;plots, src_l, src_b, thick=2, col=!orange, ps=7

   ;display, mb_phigrid, l, b, out=out
   ;contour, mb_phigrid, l, b, levels=findgen(36)*10-180, c_col=!blue, /OVER
   ;contour, mb_phigrid, l, b, levels=0, c_col=!red, /OVER
   ;plots, lncp, bncp, thick=2, col=!red, ps=7
   ;plots, l_sl, b_sl, thick=2, col=!magenta, ps=7
   ;plots, src_l, src_b, thick=2, col=!orange, ps=7

   ;display, phigrid, l, b, out=out
   ;contour, phigrid, l, b, levels=findgen(36)*10-180, c_col=!blue, /OVER
   ;contour, phigrid, l, b, levels=0, c_col=!red, /OVER
   ;plots, lncp, bncp, thick=2, col=!red, ps=7
   ;plots, l_sl, b_sl, thick=2, col=!magenta, ps=7

   ;display, thetagrid, l, b, out=out
   ;contour, thetagrid, l, b, levels=findgen(11)*10-20, c_col=!blue, /OVER
   ;plots, lncp, bncp, thick=2, col=!red, ps=7
   ;plots, l_sl, b_sl, thick=2, col=!magenta, ps=7

   ;stop

   ;=======================================================================
   ; NOW WE TRANSFORM THE AVERAGE SPECTRA BACK TO THE LSR FRAME...

   src_ra_hr = src_ra / 15.0 ; hr J2000

   v_topo_wrt_geo_dot_s = - 0.465 * cos(!dtor*gbtlat) $
                          * cos(!dtor*src_dec) $
                          * sin(!dtor*15.*(gbt_lst[a]-src_ra_hr))

   topo_to_geo = + v_topo_wrt_geo_dot_s

   s_src = [cos(!dtor*15.*src_ra_hr)*cos(!dtor*src_dec), $
            sin(!dtor*15.*src_ra_hr)*cos(!dtor*src_dec), $
            sin(!dtor*src_dec)]

   v_geo_wrt_helio_dot_s = total(v_geo_wrt_helio * s_src)
   
   geo_to_helio = + v_geo_wrt_helio_dot_s
   
   ; THE TRANSFORM FROM THE LSR TO THE HELIOCENTRIC FRAME IS
   ; INDEPENDENT OF TIME...
   ra0 = ten(18,03,50.24) ; hr J2000
   dec0 = ten(30,00,16.8) ; deg J2000
   v_sun_wrt_lsr_dot_s = 20.0 * (cos(!dtor*15.0*(src_ra_hr-ra0)) $
                                 * cos(!dtor*src_dec) $
                                 * cos(!dtor*dec0) $
                                 + sin(!dtor*src_dec) $
                                 * sin(!dtor*dec0))

   helio_to_lsr = + v_sun_wrt_lsr_dot_s

   topo_to_lsr = topo_to_geo + geo_to_helio + helio_to_lsr

   shift_chan_topo_to_lsr = topo_to_lsr / lab_vres

   avg_lab_stokes_I_spill[0,a] = shift(avg_lab_stokes_I_spill[*,a], $
                                       shift_chan_topo_to_lsr)

   ; ALSO HAVE TO SHIFT SPOT SPECTRUM...
   avg_lab_stokes_I_spot[0,a] = shift(avg_lab_stokes_I_spot[*,a], $
                                      shift_chan_topo_to_lsr)

   avg_lab_stokes_I_screen_163[0,a] = shift(avg_lab_stokes_I_screen_163[*,a], $
                                            shift_chan_topo_to_lsr)

   ;plot, gbt_v, gbt_stokes_i[*,a], xs=19
   ;oplot, lab_v, avg_lab_stokes_i[*,a], co=!red

   ;stop

   ;=======================================================================
   ; MAKE A MAP TO SHOW THE SIDELOBE...
   if not keyword_set(SHOWMAP) then continue

   setcolors, /sys, /silent

   ; THE TOTAL WEIGHT IMAGE WILL BE THE SUM OF THE
   ; SPILLOVER AND THE POISSON SPOT...
   weight = weight_ring / max(weight_ring) $
            + weight_spot / max(weight_spot) $
            + weight_screen_163 / max(weight_screen_163)

   ; SHOW THE SIDELOBE POSITION...
   wset, pix_win

   title = srcnm+'!CLST: '+string(sixty(gbt_lst[a]),FORMAT='(3(I2.2," "))')
   
   wgt_img = weight/max(weight)
   
   img = [[[wgt_img]],[[map_img]],[[wgt_img^0.2]]]
   display, img, l, b, $
            tit=title
;   plots, lncp, bncp, thick=2, col=!yellow, ps=7

   plots, src_l, src_b, thick=2, col=!orange, ps=7
   plots, l_sl, b_sl, thick=1, col=!cyan, ps=7, symsize=0.4
   oplot, lring, bring, co=!green
   oplot, [lring[0]], [bring[0]], ps=7, co=!yellow, thick=2

   legend, PSYM=[7,7,7,0], THICK=[2,1,2,1], LINESTYLE=[0,0,0,0], $
           COLOR=[!orange,!cyan,!yellow,!green], $
           ['Source Position','Center of Secondary','Arm Screen Position','Edge of Secondary'], $
           POSITION=[0,1], /NORM, BOX=0
   
   wset, plot_win
   device, copy=[0,0,!d.x_vsize,!d.y_vsize,0,0,pix_win]

   ;io = get_kbrd(1)
   
endfor

; NOW WE INTERPOLATE THE LAB SPECTRA TO THE VELOCITY SAMPLING OF THE GBT
; DATA...
onsource = interpol(onsource, lab_v, gbt_v,/LSQUADRATIC)
for i = 0, nlst-1 do begin
   avg_lab_stokes_I_spill_interp[0,i] = interpol(avg_lab_stokes_I_spill[*,i], lab_v, gbt_v,/LSQUADRATIC)
   avg_lab_stokes_I_spot_interp[0,i] = interpol(avg_lab_stokes_I_spot[*,i], lab_v, gbt_v,/LSQUADRATIC)
   avg_lab_stokes_I_screen_163_interp[0,i] = interpol(avg_lab_stokes_I_screen_163[*,i], lab_v, gbt_v,/LSQUADRATIC)
endfor

; SHOULD BE CAREFUL ABOUT GBT SPECTRA HAVING VELOCITY EXTENTS LARGER THAN
; THE LAB SURVEY... JUST ZERO ANY SUCH CHANNELS OUTSIDE THE LAB BOUNDARIES...
vrange = minmax(lab_v)
out_of_range = where(gbt_v lt vrange[0] OR gbt_v gt vrange[1],n_out_of_range)
if (N_out_of_range gt 0) then begin
   onsource[out_of_range] = 0
   avg_lab_stokes_I_spill_interp[[out_of_range],*] = 0
   avg_lab_stokes_I_spot_interp[[out_of_range],*] = 0
   avg_lab_stokes_I_screen_163_interp[[out_of_range],*] = 0
endif

; GET RID OF PRE-INTERPOLATED DATA TO SAVE SPACE...
avg_lab_stokes_I_spill = 0b
avg_lab_stokes_I_spot = 0b
avg_lab_stokes_I_screen_163 = 0b

; DO WE WANT TO CALCULATE CONTRIBUTION FROM NEAR-IN SIDELOBE...
if keyword_set(NONEARIN) then begin 

   squint_stokes_I= fltarr( nv_gbt) 

endif else begin
   
   ;original way: obtain derivs. new way: derivs are inputted.
   ;z17datapath = '/dzd4/heiles/gbt/z17/stg2/sav/'
   ;z17datafile = 'fs.'+srcnm+'_Z17*.sav.sav'
   ;get_derivs_sepstates, z17datapath, z17datafile, derivs, sigderivs
   
   pa = fsrc.pa
   if (srcnm eq 'NCP') then pa = - (gbt_lst*15.0 - 0.0) + 180.0
   
   delx_squint = 5.0
   phisquint = 180.0
   delx_squash = 0.0
   phisquash = 0.0
   
   squint_stokes_I = fltarr(nv_gbt,nlst)
   
   for i = 0, nlst-1 do begin
      sqcorr, derivs, pa[i], $
              delx_squint, phisquint, $
              delx_squash, phisquash, $
              squint_predicted, squash_predicted
      
      squint_stokes_I[*,i] = squint_predicted
      ;squint_stokes_I[0,i] = squint_predicted[xra[0]:xra[1]]
   endfor

endelse

; SAVE THE SIDELOBE COMPONENTS IN A STRUCTURE...
sidelobes = {vlsr: gbt_v, $
             spillover: avg_lab_stokes_I_spill_interp, $
             spot: avg_lab_stokes_I_spot_interp, $
             nearin: squint_stokes_I,$
             screen:avg_lab_stokes_I_screen_163_interp, $
             onsource: onsource}

; MULTIPLY EACH COMPONENT BY THE COEFFICIENT FROM TABLE 2 OF ROBISHAW AND
; HEILES 2009...
sidelobes.spillover= spillovercoeff* sidelobes.spillover
sidelobes.spot= spotcoeff* sidelobes.spot
sidelobes.screen= screencoeff* sidelobes.screen
sidelobes.nearin= nearincoeff* sidelobes.nearin

end ; predict_gbt_sidelobes_rhstk
