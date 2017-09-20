pro mmparam_define, rcvrname, cfr, fixpsi, alpha0, psi0

;+
;PURPOSE: Define the initial guesses for the MM parameters when fitting
;for the mueller matris coefficients using MMLSFIT. These coefficients
;depend on rcvr and frequency.

;These parameters must be updated if fundamental feed properties change
;(for example, when we did the initial calibrations 430 gregorian rcvr
;was linearly polarized and it was then changed to circular), or when a
;new rcvr is added. See the discussions in the AOTM for what the
;appropriate choices are. If you are dealing with an unknown system close
;to linear polarization, try as initial values the parameters for lbw
;below. if you are fairly but not really close to circular polarization, 
;you can try those also. if you are really close to circular (which
;currently happens only for lbn at 1415 MHz), try the
;values for lbn at 1415 MHz below.  
; history:
; 20sep01 - pjp added sbw with same parameters as lbw
;-

;DEFINE DEFAULT VALUES...
fixpsi=0
alpha0=0.
psi0=!pi

if ( rcvrname eq 'lbw') then begin
fixpsi= 0
alpha0= 0.
psi0= !pi
return
endif

if ( rcvrname eq 'sbw') then begin
fixpsi= 0
alpha0= 0.
psi0= !pi
return
endif


if ( rcvrname eq 'cb') then begin
fixpsi= 0
alpha0= 0.
psi0= !pi/2.
if (cfr gt 4750.) then psi0= -!dtor* 135.
return
endif

if ( rcvrname eq '430') then begin
fixpsi=0
alpha0=0.
psi0=!pi
endif

if ( rcvrname eq '610') then begin
fixpsi=0
alpha0=0.
psi0=!dtor*135.
endif

if ( rcvrname eq '430ch') then begin
fixpsi=1
alpha0=-!pi/4
psi0=0.
endif

if ( rcvrname eq 'sbn') then begin
fixpsi=0
alpha0=-!pi/4.
psi0=-!pi/4.
endif

if ( rcvrname eq 'test') then begin
fixpsi=0
alpha0=-!pi/4.
psi0=-!pi/4.
endif

if ( rcvrname eq 'lbn') then begin
fixpsi=0
alpha0=!pi/2.
psi0=!dtor* 43.628

if (cfr gt 1430.) then alpha0=0.
	
if ( abs(cfr - 1415.) lt 1.) then begin
	fixpsi=1
	alpha0=!pi/4.
endif

endif

return
end

