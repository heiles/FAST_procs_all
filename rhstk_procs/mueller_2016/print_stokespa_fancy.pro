pro print_stokespa_fancy, coeffs_out, sigcoeffs_out, $
        ngoodpoints, nloop, problem

; ROUTINE JUST PRINTS OUT THE FITTED PARAMETERS OBTAINED FROM SPIDER SCANS...

print
print, 'SRC           = ', coeffs_out.src

print
print, 'DELTAG        = ', $
       string(coeffs_out.deltag, format='(f8.4)'), ' +/- ', $
       strtrim(string(sigcoeffs_out.deltag, format='(f8.4)'),2)
print, 'PSI_deg       = ', $
       string(!radeg*coeffs_out.psi, format='(f+8.2)'), ' +/- ', $
       strtrim(string(!radeg*sigcoeffs_out.psi, format='(f8.2)'),2)
print, 'PSI           = ', $
       string(coeffs_out.psi, format='(f+8.2)'), ' +/- ', $
       strtrim(string(sigcoeffs_out.psi, format='(f8.2)'),2)
;print, 'ALPHA_deg_mod = ', modangle(!radeg* coeffs_out.alpha), $
print, 'ALPHA_deg_mod = ', $
       string(modangle(!radeg* coeffs_out.alpha,180.0), $
                      format='(+f8.2)'), ' +/- ', $
       strtrim(string(!radeg*sigcoeffs_out.alpha, format='(f8.2)'),2)
print, 'ALPHA_deg     = ', $
       string(!radeg* coeffs_out.alpha, format='(f+8.2)'), ' +/- ', $
       strtrim(string(!radeg*sigcoeffs_out.alpha, format='(f8.2)'),2)
print, 'ALPHA         = ', $
       string(coeffs_out.alpha, format='(f+8.2)'), ' +/- ',  $
       strtrim(string(sigcoeffs_out.alpha, format='(f8.2)'),2)
print, 'EPSILON       = ', $
       string(coeffs_out.epsilon, format='(f+8.4)'), ' +/- ', $
       strtrim(string(sigcoeffs_out.epsilon, format='(f8.4)'),2)
print, 'PHI_deg       = ', $
       string(!radeg*coeffs_out.phi, format='(f+8.2)'), ' +/- ', $
       strtrim(string(!radeg*sigcoeffs_out.phi, format='(f8.2)'),2)
print, 'PHI           = ', $
       string(coeffs_out.phi, format='(f+8.2)'), ' +/- ', $
       strtrim(string(sigcoeffs_out.phi, format='(f8.2)'),2)
print, 'QSRC          = ', $
       string(coeffs_out.qsrc, format='(f+8.4)'), ' +/- ', $
       strtrim(string(sigcoeffs_out.qsrc, format='(f8.4)'),2)
print, 'USRC          = ', $
       string(coeffs_out.usrc, format='(f+8.4)'), ' +/- ', $
       strtrim(string(sigcoeffs_out.usrc, format='(f8.4)'),2)
print, 'VSRC          = ', $
       string(coeffs_out.vsrc, format='(f+8.4)'), ' +/- ', $
       strtrim(string(sigcoeffs_out.vsrc, format='(f8.4)'),2)
print, 'POLSRC        = ', $
       string(coeffs_out.polsrc, format='(f+8.4)'),' +/- ', $
       strtrim(string(sigcoeffs_out.polsrc, format='(f8.4)'),2)
print, 'PASRC         = ', $
       string(coeffs_out.pasrc, format='(f+8.3)'),' +/- ', $
       strtrim(string(sigcoeffs_out.pasrc, format='(f8.3)'),2)

end
