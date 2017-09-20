pro slopefit, datax, datay, $
          slope, slopeangle, sigslope, sigslopeangle, niterations
;+
;NAME:
;SLOPEFIT -- lsfit a slope, no offset, and discard bad datapoints
;
;PURPOSE:
;    Least-square fits a slope to data, assuming no zero offset.
;         It then looks at the residuals, discards data exceeding 
;         3 sigma, anditerates until all data lies within 3 sigma.
;         This is used to calibrate the relative phase of two 
;         linearly polarized channels. We would observe a linearly
;         polarized source at different position angles and measure
;         the real and imaginary parts of the correlated output. We
;         would plot the Im versus the Re and find the slope, which
;         then gives the tangent of the angle required to correct
;         the phase to pure circular.
;
;CALLING SEQUENCE:
;    SLOPEFIT, datax, datay, $
;         slope, slopeangle, sigslope, sigslopeangle, niterations
;
;INPUTS:
;     datax: the x-axis data points. X is the independent variable,
;         assumed to be known perfectly in the least squares fit.
;     datay: the y-axis data points.
;
;OUTPUTS:
;     slope: the fitted slope.
;     slopeangle: the angle corresponding to that slope.
;     sigslope: the uncertainty in the slope.
;     sigslopeangle: the uncertainty in the angle.
;     niterations: the nr of iterations required.
;
;RESTRICTIONS:
;    With noisy data having no significant slope, the derived
;         slope doesn't mean much...
;EXAMPLE:
;
;    SLOPEFIT, datax, datay, $
;         slope, slopeangle, sigslope, sigslopeangle, niterations
;+

x = datax
t = datay
niterations=0

iterate:
ndata = n_elements(x)
s = fltarr(1, ndata, /nozero)
s[0,*] = x

ss = transpose(s) ## s
st = transpose(s) ## transpose(t)
ssi = invert(ss)
a = ssi ## st
bt = s ## a
resid = t - bt
sigsq = total(resid^2)/(ndata-1.)
sigslope = sqrt( sigsq * ssi[0,0])
sigma = sqrt(sigsq)

jndx = where( abs(resid) lt 3.*sigma, count)
;print, count, ndata, ndata-count

;stop
if ( (count-ndata) ne 0l) then begin
x = x[jndx]
t = t[jndx]
niterations=niterations+1
goto, iterate
endif

slope = a[0]
slopeangle = !radeg*atan(slope)
slopeangleplus = !radeg*atan(slope+sigslope)
slopeangleminus = !radeg*atan(slope-sigslope)
sigslopeangle = 0.5*abs(slopeangleplus-slopeangleminus)
;stop
return
end
