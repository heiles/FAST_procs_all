pro create_muellerparams_carl, a

;+
;pro CREATE_MUELLERPARAMS_CARL, A
;
;purpose: INITIALIZE the structure muellerparams_carl, which contains
;initial guesses for the nonlinear fit to the mueller matrix parameters
;defined in the heiles et al mueller matrix writeups...

;if  keyword_set({muellerparams_carl}) eq 0 then begin
a= {muellerparams_carl, $
    deltag :       0., $;
    epsilon:       0., $;
    alpha  :       0., $;
    phi    :       0., $;
    chi    :       0., $;
    psi    :       0., $ ;
    fixpsi  :       0,   $ ;

    sigdeltag :       0., $;
    sigepsilon:       0., $;
    sigalpha  :       0., $;
    sigphi    :       0., $;
    sigchi    :       0., $;
    sigpsi    :       0., $ ;
    sigfixpsi  :       0,   $ ;

    sourcename: '',  $
    sourceflux: 0.0,  $
    qsrc    : 0.0, $
    usrc    : 0.0, $
    polsrc  : 0.0, $
    pasrc   : 0., $

    sigqsrc : 0., $
    sigusrc : 0., $
    sigpolsrc : 0., $
    sigpasrc : 0., $

    tcalxx:    0.0,  $
    tcalyy:    0.0,  $
    freq:      0.0d0, $
    backend: '', $

    sigma:  0., $
    problem:  0,  $
    m7:  0,  $  not used...
    m_tot: fltarr( 4,4) $ ; the mueller matrix
}

;    endif else a= {muellerparams_carl}

return
end
