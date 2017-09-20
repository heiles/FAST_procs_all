; STRUCTURE 'muellerparams' CONTAINS THE BASIC MATRIX PARAMETERS...
;for definitions, see atom report on mueller matrix definition...
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
    m7:  0,  $  ;whether done with m7 (1) or not (0). m7 uses cumcorr, 
    $ ;which might be good for interference excision.
    m_tot: fltarr( 4,4) $ ; the mueller matrix
    
}
