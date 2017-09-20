pro phaseplot_08, title, frq, xy, yx, $
        ozero, oslope, windownr=windownr
;+
; NAME: phaseplot_08
;
; PURPOSE: plot phase vs frq for observed points and fit.
;
; CALLING SEQUENCE:
;phaseplot_08, title, frq, xy, yx, ozero, oslope, windownr=windownr
;
; INPUTS:
;TITLE - the title to put on the plot. this is now ignored.
;FRQ - the frequencies of the spectral points. Normally in MHz
;XY, YX - the crosscorrelation spectra used to calculate the phase fit
;OZERO - the phase at frq=0. units RADIANS
;OSLOPE - the phase slope, units RADIANS/MHz
;
; OPTIONAL INPUTS:
;WINDOWNR - if specified, use this window; otherwise, use current window
;
;-

if n_elements( windownr) ne 0 then wset,windownr

phase_cal_observed= atan( yx,xy)

plot, frq, phase_cal_observed, xtit='Freq, MHz', $
        yra=[-!pi, !pi], /ysty, ytit = 'Cal Defln Phase, Radians', $
        xsty=9, title='from intensity_phase.idl', $ 
        psym=3;, position=[.07,.09,.98,.93]
oplot, frq, modangle(ozero[0] + oslope[0]*frq, $
                     2*!pi, /NEGPOS), color=!red, thick=2
xyouts, .3,.3,'white is data, red is fit', /norm
;axis, /xaxis, xra=[0, n_elements( yx)], xtit= 'Chnl nr', /xsty, /save
return
end

