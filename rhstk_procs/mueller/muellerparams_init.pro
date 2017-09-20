function muellerparams_init, NOMINAL_LINEAR=nominal_linear

;+
;function muellerparams_init, NOMINAL_LINEAR=nominal_linear
;
;PURPOSE: CREATE and INITIALIZE the structure we usually call
;muellerparams0, which contains initial guesses for the nonlinear fit to
;the mueller matrix parameters defined in the heiles et al mueller
;matrix writeups. This structure is an input parameter for the least
;squares fit procedure MMLSFIT
;
;INPUT KEYWORD: 
;       nominal_linear. Set equal to:
;               1 for native linear (the default)
;               0 for native pol unknown
;               -1 for native circular
;
;-

;create the structure muellerparams_carl:
create_muellerparams_carl, a

; STRUCTURE 'muellerparams' CONTAINS THE BASIC MATRIX PARAMETERS...
;   muellerparams_init= {muellerparams_carl}
   muellerparams_init= a

;assume nominal linear if not set...
if n_elements( nominal_linear) eq 0 then nominal_linear=1

   muellerparams_init.deltag  = 0.01
   muellerparams_init.epsilon = 0.01
   muellerparams_init.phi     = 0.1
   muellerparams_init.chi     = !pi/2.
   muellerparams_init.qsrc     = 0.01 
   muellerparams_init.usrc    = 0.01  

   muellerparams_init.alpha   = !pi/4. ; this should be overwritten by rcvrgen...

if nominal_linear eq 1 then begin
    muellerparams_init.alpha= 0. 
    muellerparams_fixpsi= 0
    muellerparams_init.psi= 0.1 
endif

if nominal_linear eq -1 then begin
    muellerparams_init.alpha= -!pi/4. 
    muellerparams_init.fixpsi= 1
    muellerparams_init.psi= 0. 
endif

if nominal_linear ne 1 and nominal_linear ne -1 then begin
    muellerparams_init.alpha   = -!pi/8. 
    muellerparams_init.fixpsi= 0
    muellerparams_init.psi= 0.1 
endif

;stop

return, muellerparams_init
end
