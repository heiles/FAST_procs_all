pro z16hdrdef_sep00, successful, stokesc1, stokesc1_w, board, b_all, b, $
	no_mcorr=no_mcorr,  m_skycorr=m_skycorr, m_astro=m_astro, $
	zero_deltag= zero_deltag, mm_pro_user= mm_pro_user, $
	ozero_srcdfln= ozero_srcdfln, oslope_srcdfln= oslope_srcdfln

;+
;PURPOSE: for each pattern, store the results into arrays that are saved
;and written on disk.  These arrays are 1, 2, 3, or 4 dimensional, and
;the last dimension is always the pattern number within the corfile. The
;pattern number is NRC or NPATT..
;
;KEYWORDS:
;
;       NO_MCORR inhibits mm correction
;
;       M_SKYCORR is normally set, corrects for sky rotn wrt az arm
;during tracking.

;       M_astro is normally set, rotates PA's to astronomical definition.

;	ZERO_DELTAG forces deltag in the mmatrix to zero, which should
;be set when you are using cal values adjusted make deltag zero.

;	mm_pro_user: if specified, it uses this proc name for the
;Mueller matrix correction. otherwise it uses the default. added 20oct02

;	ozero_srcdfln= ozero_srcdfln, oslope_srcdfln= oslope_srcdfln:
;source deflection phase zero and slope. added 31oct02. place into
;hdr1info[ 9,*] and hdr1info[ 47, *].

;OUTPUTS:
;The content of each array is documented in the source code.
;
;These include:
;
;
;       CORHDR[ 22, NRC], an array of four header structures, one for
;each of th 22 spectra in the pattern [calon/caloff for onsrc (2
;spectra), calon/caloff for offsrc ( spectra), 2 onsrc spectra, 16 offsrc
;spectra]
;
;       HDRSRCNAME[ NRC], the array of source names, one per pattern.
;
;	HDRSCAN[ NRC], the array of scan numbers, one per pattern.
;
;       HDR1INFO[ 48, NRC], an array containing important parameters for
;each pattern, one per pattern.
;
;       HDR2INFO[ 22, 32, NRC], an array containing important info for
;each of the 240 points within each pattern.
;
;	STKON[ 2048, 4, NRC]: 2048 chnls, 4 stokes, NRC patterns. 
;The array of the on-source spectra.  The two taken in each pattern are
;averaged. 
;
;	STKOFF[ 2048, 4, NRC]: 2048 chnls, 4 stokes, NRC patterns. 
;The array of the off-source spectra.  The 16 taken in each pattern are
;averaged. This info is redundant--same as the average of all 16 spectra
;in STK16OFFS.
;
;
;	STK16OFFS[ 2048, 4, 16, NRC]: 2048 channels, 4 stokes params, 16 OFF
;positions, NRC patterns. 
;
;HISTORY: 2 nov 2002, fixed mcorr indication and keyword problems with
;m_skycorr and m_astro

;-

common timecoord
common zmnparams
common hdrdata
common board3info


if (successful eq 1) then begin

;IF THIS IS THE FIRST CALL TO THIS ROUTINE, DEFINE THE HEADER VARIABLES...
IF (NRC EQ 0) THEN BEGIN   
;corhdr = replicate( b.(board).h, n12, nrc+1)
corhdr = (b_all)[ board, *]
hdr1info= fltarr( 48, nrc+1)
hdr2info= fltarr( n12, 32, nrc+1)
stkon= fltarr( 2048, 4, nrc+1)
stkoff= fltarr( 2048, 4, nrc+1)
stk16offs= fltarr( 2048, 4, 16, nrc+1)
ENDIF ELSE BEGIN

;IF THIS IS NOT THE FIRST CALL, THEN INCREMENT THE VARIABLES...
boost_array, hdr1info, fltarr( 48)
boost_array, hdr2info, fltarr( n12, 32)
boost_array, stkon, fltarr( 2048, 4)
boost_array, stkoff, fltarr( 2048, 4)
boost_array, stk16offs, fltarr( 2048, 4, 16)
corhdrnew= replicate( (b_all)[ board,0], n12, nrc+1)
corhdrnew[*, 0:nrc-1]= corhdr
corhdr= corhdrnew
corhdr[ *, nrc]= b_all[ board,*]
ENDELSE

getrcvr, b, rcvr_name, rcvrn, mmprocname=mmprocname   ;RECEIVER NUMBER

;CHECK FOR USER-SPECIFIED MMCORR PROCNAME...
if ( n_elements( mm_pro_user) ne 0) then mmprocname= mm_pro_user

;------ DO THE MM CORRECTION -------------------------
;SET UP MM PARAMS FOR A DIAGONAL MATRIX AND ASSUME NO CORRECTION,
;       THEN TRY TO DO IT AND CHANGE THINGS.
mcorr=0
deltag=0.
epsilon=0.
alpha=0.
chi=90.*!dtor
psi=0.
phi=0.

IF (KEYWORD_SET( NO_MCORR) EQ 0) THEN begin
;print, 'mmprocname = ', mmprocname
IF (MMPROCNAME NE '') THEN BEGIN
print, 'MUELLER-CORRECTING USING mmprocname = ', mmprocname  
call_procedure, mmprocname, cfr, m_tot, m_astron, $
       deltag, epsilon, alpha, phi, chi, psi, angle_astron, /zero_deltag
;print, m_astro
;print, m_astron
mcorr= 1+ 2*keyword_set( m_skycorr)+ 4*keyword_set( m_astro)
mm_corr_zmn, m_tot, m_astron, azmidpntn, zamidpntn, stokesc1, 22, $
        m_skycorr=m_skycorr, m_astro=m_astro
ENDIF
ENDIF

;CALCULATE THE CHANNEL-INTEGRATED STOKES PARAMETERS...
;WE DID THIS BEFORE, IN CROSS3_GENCAL, BUT HERE THINGS HAVE   
;BEEN MUELLER CORRECTED WHILE THERE THEY WERE NOT.

zmn3_sep00_b, integ_time, stokesc1, $
        onscn, offscn, icont, qcont, ucont, vcont, $
        icontonoff, qcontonoff, ucontonoff, vcontonoff
zmn3_sep00_b, integ_time, stokesc1_w, $
        onscn, offscn, icont_w, qcont_w, ucont_w, vcont_w, $
        icontonoff_w, qcontonoff_w, ucontonoff_w, vcontonoff_w
   
;-----------------------------------------------------


;IF THE CENTRAL FREQ IS 1420.4 INSTEAD OF 1420.405, THEN CORRECT VLSR...
if ( abs( cfr - 1420.4) lt 0.001) then begin
	velorz = velorz + 5.8/4.74
	velorz_w = velorz_w + 5.8/4.74
endif

;SAVE THE HEADER INFO...

IF (nrc eq 0) then begin
hdrsrcname= [sourcename]
hdrscan= [scannr[0]]
ENDIF ELSE BEGIN
hdrsrcname= [ hdrsrcname, sourcename]
hdrscan= [ hdrscan, scannr[0]]          ;STARTING SCAN OF GROUP
ENDELSE

hdr1info[0,nrc] = utbeginn[0]		;UNIVERSAL TIME AT GROUP START
hdr1info[1,nrc] = b.(board).h.proc.dar[ 0]
					;OFFSET MULTIPLIER...DEFAULT 3.5 ARCMIN
hdr1info[2,nrc] = julianday[0]		;REDUCED JULIAN DAY AT GROUP START
hdr1info[3,nrc] = astbeginn[0]		;AST AT GROUP BEGINNING
hdr1info[4,nrc] = bandwidth		;BANDWIDTH
hdr1info[5,nrc] = cfr			;CENTER FREQUENCY--IN CHNL 1024.
hdr1info[6,nrc] = mcorr                 ;0, no mmcorr; 1, rcvr mmcorr'
					;2, sky; 4, astron; bitwise sum
hdr1info[7,nrc] = velorz[0]		;CENTRAL LSR VELOCITY.
;hdr1info[8,nrc] = *********** DO NOT USE! USED BY LATER REDN PGMS!*****

hdr2info[0:nrloops-1,0,nrc] = lstmidpntn	;LST MIDPOINT OF EACH SCAN
hdr2info[0:nrloops-1,1,nrc] = azmidpntn		;CENTER AZIMUTH OF EACH SCAN
hdr2info[0:nrloops-1,2,nrc] = zamidpntn		;CENTER ZA OF EACH SCAN
hdr2info[0:nrloops-1,3,nrc] = ra1950		;RA1950 OF EACH SCAN
hdr2info[0:nrloops-1,4,nrc] = dec1950		;DEC1950 OF EACH SCAN
hdr2info[0:nrloops-1,5,nrc] = pangle(azmidpntn, zamidpntn, 1)
						;PA ANGLE OF EACH SCAN
hdr2info[0:nrloops-1,6,nrc] = az_encoder	;ENCODER AZ OF EACH SCAN
hdr2info[0:nrloops-1,7,nrc] = za_encoder	;ENCODER ZA EACH SCAN
hdr2info[0:nrloops-1,8,nrc] = pwr1		;PWR XX OF EACH SCAN
hdr2info[0:nrloops-1,9,nrc] = pwr2		;PWR YY OF EACH SCAN

;NEXT THE MEASUREMENTS...

hdr1info[10,nrc] = icontonoff	;AVERAGE SOURCE DEFLECTION, STOKES I
hdr1info[11,nrc] = qcontonoff	;AVERAGE SOURCE DEFLECTION, STOKES Q
hdr1info[12,nrc] = ucontonoff	;AVERAGE SOURCE DEFLECTION, STOKES U
hdr1info[13,nrc] = vcontonoff	;AVERAGE SOURCE DEFLECTION, STOKES V

hdr1info[14,nrc] = deltag       ;M_TOT PARAMETER
hdr1info[15,nrc] = epsilon      ;M_TOT PARAMETER
hdr1info[16,nrc] = alpha        ;M_TOT PARAMETER
hdr1info[17,nrc] = phi          ;M_TOT PARAMETER, RADIANS
hdr1info[18,nrc] = chi          ;M_TOT PARAMETER, RADIANS
hdr1info[19,nrc] = psi          ;M_TOT PARAMETER, RADIANS

hdr1info[40,nrc] = icontonoff_w	;AVERAGE SOURCE DEFLECTION, STOKES I, BOARD3
hdr1info[41,nrc] = qcontonoff_w	;AVERAGE SOURCE DEFLECTION, STOKES Q, BOARD3
hdr1info[42,nrc] = ucontonoff_w	;AVERAGE SOURCE DEFLECTION, STOKES U, BOARD3
hdr1info[43,nrc] = vcontonoff_w	;AVERAGE SOURCE DEFLECTION, STOKES V, BOARD3

hdr2info[0:nrloops-1,10,nrc] = icont	;STOKES I TOTAL POWER
hdr2info[0:nrloops-1,11,nrc] = qcont	;STOKES Q TOTAL POWER
hdr2info[0:nrloops-1,12,nrc] = ucont	;STOKES U TOTAL POWER
hdr2info[0:nrloops-1,13,nrc] = vcont	;STOKES V TOTAL POWER

hdr2info[0:nrloops-1,20,nrc] = icont_w	;STOKES I TOTAL POWER
hdr2info[0:nrloops-1,21,nrc] = qcont_w	;STOKES Q TOTAL POWER
hdr2info[0:nrloops-1,22,nrc] = ucont_w	;STOKES U TOTAL POWER
hdr2info[0:nrloops-1,23,nrc] = vcont_w	;STOKES V TOTAL POWER

hdr2info[0:nrloops-1,28,nrc] = pwr1_w		;PWR XX OF EACH SCAN
hdr2info[0:nrloops-1,29,nrc] = pwr2_w		;PWR YY OF EACH SCAN

hdr2info[ *,30,nrc] = integ_time		;INT TIME, SEC

;NEXT THE DERIVED PARAMETERS...
;FIRST, LS FITS FOR PHASE = A + B*(FREQ-FREQZERO) FOR SPECIFIED BOARD
;******** UNITS ARE RADIANS AND RADIANS/MHZ ***********
hdr1info[20,nrc] = ozero_offsrc[0]	;A COEFFICIENT FOR CAL, OFF_SOURCE
hdr1info[21,nrc] = oslope_offsrc[0]	;B COEFFICIENT FOR CAL, OFF_SOURCE
hdr1info[22,nrc] = ozero_onsrc[0]	;A COEFFICIENT FOR CAL, ON_SOURCE
hdr1info[23,nrc] = oslope_onsrc[0]	;B COEFFICIENT FOR CAL, ON_SOURCE
hdr1info[24,nrc] = ozero_offsrc[1]	;ERROR IN CAL A COEFFICIENT, OFF_SOURCE
hdr1info[25,nrc] = oslope_offsrc[1]	;ERROR IN CAL B COEFFICIENT, OFF_SOURCE
hdr1info[26,nrc] = ozero_onsrc[1]	;ERROR IN CAL A COEFFICIENT, ON_SOURCE
hdr1info[27,nrc] = oslope_onsrc[1]	;ERROR IN CAL B COEFFICIENT, ON_SOURCE

hdr1info[ 28,nrc] = tcalxx		;XX CAL VALUE USED IN REDUCTION.
hdr1info[ 29,nrc] = tcalyy		;YY CAL VALUE USED IN REDUCTION.

;NEXT, LS FITS FOR PHASE = A + B*(FREQ-FREQZERO) FOR BOARD3
;******** UNITS ARE RADIANS AND RADIANS/MHZ ***********
hdr1info[30,nrc] = ozero_offsrc_w[0]	;A COEFFICIENT FOR CAL, OFF_SOURCE
hdr1info[31,nrc] = oslope_offsrc_w[0]	;B COEFFICIENT FOR CAL, OFF_SOURCE
hdr1info[32,nrc] = ozero_onsrc_w[0]	;A COEFFICIENT FOR CAL, ON_SOURCE
hdr1info[33,nrc] = oslope_onsrc_w[0]	;B COEFFICIENT FOR CAL, ON_SOURCE
hdr1info[34,nrc] = ozero_offsrc_w[1]	;ERROR IN CAL A COEFFICIENT, OFF_SOURCE
hdr1info[35,nrc] = oslope_offsrc_w[1]	;ERROR IN CAL B COEFFICIENT, OFF_SOURCE
hdr1info[36,nrc] = ozero_onsrc_w[1]	;ERROR IN CAL A COEFFICIENT, ON_SOURCE
hdr1info[37,nrc] = oslope_onsrc_w[1]	;ERROR IN CAL B COEFFICIENT, ON_SOURCE

;PUT UNCALIBRATED SOURCE PHASE AND SLOPE INTO BLANK HDR WORDS...
hdr1info[9,nrc] = ozero_srcdfln[ 0]	;A COEFF FOR UNCALIB SRC DEFLN
hdr1info[47,nrc] = oslope_srcdfln[ 0]	;b COEFF FOR UNCALIB SRC DEFLN

;CALCULATE THE MEAN PA FOR THE PATTERN FOR HDR1INFO[38...]
pa_all= !dtor* hdr2info[ *, 5, nrc]
avg_srcphase, pa_all, meanpa
hdr1info[ 38,nrc]= !radeg* meanpa       ;MEAN PA FOR PATTERN IN **DEGREES**    

hdr1info[39,nrc] = angle_astron         ;ANGLE TO ROTATE TO ASTRO COORDS, DEGS.

hdr1info[44,nrc] = bandwidth_w		;BANDWIDTH, BOARD 3
hdr1info[45,nrc] = cfr_w		;CENTER FREQUENCY--BOARD 3
hdr1info[46,nrc] = velorz_w[0]		;CENTRAL LSR VELOCITY BOARD 3.

;CALCULATE AVG OF ALL ONSRC SCANS, ALSO OFFSRC SCANS...
stokeson = fltarr(2048,4)
stokesoff = fltarr(2048,4)
for nr=0, n_elements(onscn)-1 do stokeson = stokeson + $
	integ_time[onscn[nr]]*stokesc1[*,*,onscn[nr]]
for nr=0, n_elements(offscn)-1 do stokesoff = stokesoff + $
	integ_time[offscn[nr]]*stokesc1[*,*,offscn[nr]]
stokeson = stokeson / total(integ_time[onscn])
stokesoff = stokesoff / total(integ_time[offscn])

stkon[*,*,nrc] = stokeson
stkoff[*,*,nrc] = stokesoff

stk16offs[ *,*,*,nrc] = stokesc1[ *,*,offscn]

;NOTE:
;STK16OFFS[2048,4,16,1500]:
;	2048 channels
;	4 stokes params I Q U V
;	16 OFF positions 
;	1500 possible sources

endif else nrc=nrc-1

;stop

end


 

