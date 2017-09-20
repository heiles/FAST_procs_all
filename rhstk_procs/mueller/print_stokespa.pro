pro print_stokespa, indx, a, muellerparams1, ngoodpoints, nloop

; ROUTINE JUST PRINTS OUT THE FITTED PARAMETERS OBTAINED FROM SPIDER SCANS...

print
print, 'DELTAG        = ', $
       string(muellerparams1.deltag, format='(f8.4)'), ' +/- ', $
       strtrim(string(muellerparams1.sigdeltag, format='(f8.4)'),2)
;print, 'CHI = ', !radeg* muellerparams1.chi, ' +/-  0.0'
print, 'PSI_deg       = ', $
       string(!radeg*muellerparams1.psi, format='(f+8.2)'), ' +/- ', $
       strtrim(string(!radeg*muellerparams1.sigpsi, format='(f8.2)'),2)
print, 'PSI           = ', $
       string(muellerparams1.psi, format='(f+8.2)'), ' +/- ', $
       strtrim(string(muellerparams1.sigpsi, format='(f8.2)'),2)
;print, 'ALPHA_deg_mod = ', modangle(!radeg* muellerparams1.alpha), $
print, 'ALPHA_deg_mod = ', $
       string(modangle(!radeg* muellerparams1.alpha,180.0), $
                      format='(+f8.2)'), ' +/- ', $
       strtrim(string(!radeg*muellerparams1.sigalpha, format='(f8.2)'),2)
print, 'ALPHA_deg     = ', $
       string(!radeg* muellerparams1.alpha, format='(f+8.2)'), ' +/- ', $
       strtrim(string(!radeg*muellerparams1.sigalpha, format='(f8.2)'),2)
print, 'ALPHA         = ', $
       string(muellerparams1.alpha, format='(f+8.2)'), ' +/- ',  $
       strtrim(string(muellerparams1.sigalpha, format='(f8.2)'),2)
print, 'EPSILON       = ', $
       string(muellerparams1.epsilon, format='(f+8.4)'), ' +/- ', $
       strtrim(string(muellerparams1.sigepsilon, format='(f8.4)'),2)
print, 'PHI_deg       = ', $
       string(!radeg*muellerparams1.phi, format='(f+8.2)'), ' +/- ', $
       strtrim(string(!radeg*muellerparams1.sigphi, format='(f8.2)'),2)
print, 'PHI           = ', $
       string(muellerparams1.phi, format='(f+8.2)'), ' +/- ', $
       strtrim(string(muellerparams1.sigphi, format='(f8.2)'),2)
print, 'QSRC          = ', $
       string(muellerparams1.qsrc, format='(f+8.4)'), ' +/- ', $
       strtrim(string(muellerparams1.sigqsrc, format='(f8.4)'),2)
print, 'USRC          = ', $
       string(muellerparams1.usrc, format='(f+8.4)'), ' +/- ', $
       strtrim(string(muellerparams1.sigusrc, format='(f8.4)'),2)
print, 'POLSRC        = ', $
       string(muellerparams1.polsrc, format='(f+8.4)'),' +/- ', $
       strtrim(string(muellerparams1.sigpolsrc, format='(f8.4)'),2)
print, 'PASRC         = ', $
       string(muellerparams1.pasrc, format='(f+8.3)'),' +/- ', $
       strtrim(string(muellerparams1.sigpasrc, format='(f8.3)'),2)

print, '***UNCORRECTED FOR M_ASTRO***'
print, 'NR GOOD POINTS = ', ngoodpoints[1:3], ' / ', ngoodpoints[0]

print, 'problem = ', muellerparams1.problem, ';  nloop = ', nloop, $
        string( (muellerparams1.PROBLEM ne 0)* 7B)
print, 'sigma = ', muellerparams1.sigma

print, 'SOURCE IS: ', a[ indx[0]].srcname
print, 'FREQUENCY IS: ', a[ indx[0]].cfr

end
