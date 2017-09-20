function muellerparams_init

; STRUCTURE 'muellerparams' CONTAINS THE BASIC MATRIX PARAMETERS...

muellerparams_init= {muellerparams_carl}
muellerparams_init.deltag  = 0.01
muellerparams_init.epsilon = 0.01
muellerparams_init.alpha   = !pi/4. ; this should be overwritten by rcvrgen...
muellerparams_init.phi     = 0.1
muellerparams_init.chi     = !pi/2.
muellerparams_init.psi     = 0.1    ; this should be overwritten by rcvrgen...

muellerparams_init.qsrc     = 0.01    ; this should be overwritten by rcvrgen...
muellerparams_init.usrc    = 0.01    ; this should be overwritten by rcvrgen...

return, muellerparams_init
end
