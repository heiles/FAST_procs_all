pro tim_a2119_hdrdef, successful, nrspectra, stokesc1, b, board, $
        no_mcorr=no_mcorr,  m_skycorr=m_skycorr, m_astro=m_astro


;+
;PURPOSE: for each pattern, store all spectra and hdr info individually
;	The spectrum number is NRC or NPATT..
;
;KEYWORDS:
;
;       NO_MCORR inhibits mm correction
;
;       M_SKYCORR is normally set, corrects for sky rotn wrt az arm
;during tracking.

;       M_astro is normally set, rotates PA's to astronomical definition.

;OUTPUTS:
;The content of each array is documented in the source code.
;
;These include:
;
;	NRC, the total nr of spectra.
;
;       SRCNM[ NRC], the array of source names, string
;
;       SCN[ NRC], the array of scan numbers, long integers
;
;       HDR[ 48, NRC], an array containing important parameters for
;each spectrum
;
;       HDRDBL[ 2, NRC], an array containing important info for
;each spectrum, double.
;
;       STK[ 2048, 4, NRC]: 2048 chnls, 4 stokes, NRC spectra.
;The array of the on-source spectra.  
;
;13jul2006 mods:
;	included board as input param
;	hdrdbl[2:3] are topocentric freqs of zeroth and last chnl
;	hdr[5] is board nr
;	m_astro and m_skycorr recorded in hdr
;-

common timecoord
common zmnparams
common hdrdata

if (successful eq 1) then begin

freq = corfrq( b.(board).h)
freqlim= [ freq[ 0], freq[ n_elements( freq)- 1l]]
freqcntr= mean( freqlim)

nrc= nrc+ nrspectra

getrcvr, b, rcvr_name, rcvrn, mmprocname=mmprocname   ;RECEIVER NUMBER
print, 'rcvr_name = ', rcvr_name, ' rcvrn = ', rcvrn, $
	'mmprocname = ', mmprocname

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
angle_astron=0.

IF (KEYWORD_SET( NO_MCORR) EQ 0) THEN begin
;print, 'mmprocname = ', mmprocname
IF (MMPROCNAME NE '') THEN BEGIN
print, 'mmprocname = ', mmprocname
;call_procedure, mmprocname, cfr, m_tot, m_astron, $
call_procedure, mmprocname, freqcntr, m_tot, m_astron, $
       deltag, epsilon, alpha, phi, chi, psi, angle_astron
;print, m_astro
;print, m_astron
mcorr= 1+ m_skycorr
mm_corr_zmn, m_tot, m_astron, azmidpntn[ 0:nrspectra-1], zamidpntn[ 0:nrspectra-1], $
	stokesc1, nrspectra, m_skycorr=m_skycorr, m_astro=m_astro
ENDIF
ENDIF

;CALCULATE THE CHANNEL-INTEGRATED STOKES PARAMETERS...
;WE DID THIS BEFORE, IN CROSS3_GENCAL, BUT HERE THINGS HAVE
;BEEN MUELLER CORRECTED WHILE THERE THEY WERE NOT.
                                                
stg0_b, stokesc1, icont, qcont, ucont, vcont

;-----------------------------------------------------

;THIS DEFINES 'HEADER' QUANTITIES for ZEEMAN SPECTRA OBS.
nspct = nrspectra

srcnm[ nrc- nspct: nrc-1 ] = sourcename
scn[ nrc- nspct: nrc-1 ] = scannr[ 0:nspct-1]
hdrdbl[ 0, nrc- nspct: nrc-1 ] = julianday[ 0:nspct-1]	;REDUCED JULIAN DAY AT GROUP START
hdrdbl[ 1, nrc-nspct: nrc-1 ] = cfr			;CENTER FREQUENCY--IN CHNL 1024.
hdrdbl[ 2, nrc-nspct: nrc-1 ] = freqlim[0]		;topo freq zroth chnl
hdrdbl[ 3, nrc-nspct: nrc-1 ] = freqlim[1]		;topo freq last chnl

hdr[ 0, nrc-nspct: nrc-1 ] = utbeginn[ 0:nspct-1]	;UNIVERSAL TIME AT GROUP START
hdr[ 1, nrc-nspct: nrc-1 ] = calon[ 0:nspct-1]		;1 if cal on, 0 if off
hdr[ 2, nrc-nspct: nrc-1 ] = nrc-1                      ;running number
hdr[ 3, nrc-nspct: nrc-1 ] = astbeginn[ 0:nspct-1]	;AST AT GROUP BEGINNING
hdr[ 4, nrc-nspct: nrc-1 ] = bandwidth			;BANDWIDTH
hdr[ 5, nrc-nspct: nrc-1 ] = board			;BOARD NR: 0 to 3
hdr[ 6, nrc-nspct: nrc-1 ] = mcorr                 ;0, no mmcorr; 1, mmcorr w/o sky;
                                        	   ;2, full mmcorr.
hdr[ 7, nrc-nspct: nrc-1 ] = velorz[ 0:nspct-1]		;CENTRAL LSR VELOCITY.
;gvhdr[ 8, nrc-nspct: nrc-1 ] = *********** DO NOT USE! USED BY LATER REDN PGMS!*****
hdr[ 9, nrc-nspct: nrc-1 ] = integ_time[ 0:nspct-1]	;INT TIME, SEC

hdr[ 10, nrc-nspct: nrc-1 ] = lstmidpntn[ 0:nspct-1]	;LST MIDPOINT OF EACH SCAN
hdr[ 11, nrc-nspct: nrc-1 ] = azmidpntn[ 0:nspct-1]	;CENTER AZIMUTH OF EACH SCAN
hdr[ 12, nrc-nspct: nrc-1 ] = zamidpntn[ 0:nspct-1]	;CENTER ZA OF EACH SCAN
hdr[ 13, nrc-nspct: nrc-1 ] = ra1950[ 0:nspct-1]	;RA1950 OF EACH SCAN
hdr[ 14, nrc-nspct: nrc-1 ] = dec1950[ 0:nspct-1]	;DEC1950 OF EACH SCAN
hdr[ 15, nrc-nspct: nrc-1 ] = (pangle(azmidpntn, zamidpntn, 1))[ 0:nspct-1]
							;PA ANGLE OF EACH SCAN
hdr[ 16, nrc-nspct: nrc-1 ] = az_encoder[ 0:nspct-1]	;ENCODER AZ OF EACH SCAN
hdr[ 17, nrc-nspct: nrc-1 ] = za_encoder[ 0:nspct-1]	;ENCODER ZA EACH SCAN
hdr[ 18, nrc-nspct: nrc-1 ] = pwr1[ 0:nspct-1]		;PWR XX OF EACH SCAN
hdr[ 19, nrc-nspct: nrc-1 ] = pwr2[ 0:nspct-1]		;PWR YY OF EACH SCAN

;NEXT THE MEASUREMENTS...

hdr[ 20, nrc-nspct: nrc-1 ] = icont[ 0:nspct-1]		;STOKES I TOTAL POWER
hdr[ 21, nrc-nspct: nrc-1 ] = qcont[ 0:nspct-1]		;STOKES Q TOTAL POWER
hdr[ 22, nrc-nspct: nrc-1 ] = ucont[ 0:nspct-1]		;STOKES U TOTAL POWER
hdr[ 23, nrc-nspct: nrc-1 ] = vcont[ 0:nspct-1]		;STOKES V TOTAL POWER

hdr[ 24, nrc-nspct: nrc-1 ] = deltag       ;M_TOT PARAMETER
hdr[ 25, nrc-nspct: nrc-1 ] = epsilon      ;M_TOT PARAMETER
hdr[ 26, nrc-nspct: nrc-1 ] = alpha        ;M_TOT PARAMETER
hdr[ 27, nrc-nspct: nrc-1 ] = phi          ;M_TOT PARAMETER, RADIANS
hdr[ 28, nrc-nspct: nrc-1 ] = chi          ;M_TOT PARAMETER, RADIANS
hdr[ 29, nrc-nspct: nrc-1 ] = psi          ;M_TOT PARAMETER, RADIANS
hdr [30, nrc-nspct: nrc-1 ] = angle_astron         ;ANGLE TO ROTATE TO ASTRO COORDS, DEGS.

;NEXT THE DERIVED PARAMETERS...
;FIRST, LS FITS FOR PHASE = A + B*(FREQ-FREQZERO) FOR SPECIFIED BOARD
;******** UNITS ARE RADIANS AND RADIANS/MHZ ***********
hdr[ 31, nrc-nspct: nrc-1 ] = ozero_onsrc[0]	;A COEFFICIENT FOR CAL, ON_SOURCE
hdr[ 32, nrc-nspct: nrc-1 ] = oslope_onsrc[0]	;B COEFFICIENT FOR CAL, ON_SOURCE
hdr[ 33, nrc-nspct: nrc-1 ] = ozero_onsrc[1]	;ERROR IN CAL A COEFFICIENT, ON_SOURCE
hdr[ 34, nrc-nspct: nrc-1 ] = oslope_onsrc[1]	;ERROR IN CAL B COEFFICIENT, ON_SOURCE

hdr[ 35, nrc-nspct: nrc-1 ] = m_astro
hdr[ 36, nrc-nspct: nrc-1 ] = m_skycorr

hdr[ 37, nrc-nspct: nrc-1 ] = tcalxx
hdr[ 38, nrc-nspct: nrc-1 ] = tcalyy

hdr[ 39, nrc-nspct: nrc-1 ] = 1.  ; reserved for stokesv_mult, used to correct
				  ;	the sign of stokes V in later programs.

stk[ *,*, nrc-nspct: nrc-1 ] = stokesc1

;NOTE:
;STK[ 2048, 4, nrc]:
;	2048 channels
;	4 stokes params I Q U V
;	nrc spectra

endif 

;stop

end


 

