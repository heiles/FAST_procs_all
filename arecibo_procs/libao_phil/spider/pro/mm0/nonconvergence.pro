pro nonconvergence, dpdf, sa, ca, kk, sigsa, sigca, sigarray
;SETS DEFAULT OUTPUTS FOR NONCONVERGENCE CASES.
kk = dpdf/!radeg
sigkk = 0.
sa = 0.
ca = 1.
sigsa = 0.
sigca = 0.
sigarray = [0., 0., 0.]
sigma = 0.

print, 'SETTING OUTPUTS TO DEFAULTS AND RETURNING...', string(7b)
return
end
