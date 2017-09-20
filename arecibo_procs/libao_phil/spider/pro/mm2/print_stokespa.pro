;04aug07 pjp002 .. added pasrc, polsrc printouts
pro print_stokespa, indx, a, muellerparams1, ngoodpoints, nloop

print, ' '
print, 'DELTAG = ', muellerparams1.deltag, ' +/- ', muellerparams1.sigdeltag   
print, 'EPSILON = ', muellerparams1.epsilon, ' +/- ', muellerparams1.sigepsilon
print, 'ALPHA_deg_mod = ', modangle(!radeg* muellerparams1.alpha,180.), $
        ' +/- ', !radeg*muellerparams1.sigalpha
print, 'ALPHA_deg = ', !radeg* muellerparams1.alpha, ' +/- ', !radeg*muellerparams1.sigalpha
print, 'ALPHA = ', muellerparams1.alpha, ' +/- ',  muellerparams1.sigalpha
print, 'PHI_deg = ', !radeg*muellerparams1.phi, ' +/- ', !radeg*muellerparams1.sigphi
print, 'PHI = ', muellerparams1.phi, ' +/- ', muellerparams1.sigphi
;print, 'CHI = ', !radeg* muellerparams1.chi, ' +/-  0.0'
print, 'PSI_deg = ', !radeg*muellerparams1.psi, ' +/- ', !radeg*muellerparams1.psi
print, 'PSI = ', muellerparams1.psi, ' +/- ', muellerparams1.sigpsi   
print, 'QSRC = ', muellerparams1.qsrc, ' +/- ', muellerparams1.sigqsrc
print, 'USRC = ', muellerparams1.usrc, ' +/- ', muellerparams1.sigusrc
;<pjp002>
print, 'POLSRC        = ', $
       string(muellerparams1.polsrc, format='(f+8.4)'),' +/- ', $
       strtrim(string(muellerparams1.sigpolsrc, format='(f8.4)'),2)
print, 'PASRC         = ', $
       string(muellerparams1.pasrc, format='(f+8.3)'),' +/- ', $
       strtrim(string(muellerparams1.sigpasrc, format='(f8.3)'),2)

print, '***UNCORRECTED FOR M_ASTRO***'
print, 'NR GOOD POINTS= ', ngoodpoints[1:3], ' / ', ngoodpoints[0]

print, 'problem = ', muellerparams1.problem, ';  nloop = ', nloop, $
        string( (muellerparams1.PROBLEM ne 0)* 7B)
print, 'sigma= ', muellerparams1.sigma

print, 'SOURCE IS: ', a[ indx[0]].srcname
print, 'FREQUENCY IS: ', a[ indx[0]].cfr

return
end
