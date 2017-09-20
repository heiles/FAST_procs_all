;+
;NAME:
;lbgain - compute lband gain as a function of az,za
;SYNTAX: gain=lbgain(az,za)
;ARGS  : az[n]   - float azimuth in degrees.
;        za[n]   - float zenith angle in degrees.
;RETURNS:
;       gain[n]  - float kelvins/Jy.
;DESCRIPTION
;   Compute the gain of the lband system in Kelvins per Jansky. Data
;was taken from jul00,aug00 lbn and lbwide on/off position switching
;data using the correlator (see http://www.naic.edu/~phil). 1405 Mhz
;was used and polA polB were averaged together.
;-
function lbgain,az,za

;
;   the za dependence
    g=8.92204 -0.11083*za 
    ind=where(za ge 14,count)
    if count gt 0 then begin
        zap=za[ind] - 14.
        g[ind]= g[ind] + .00214*zap*zap -.00342*zap*zap*zap
    endif
;
;   az dependence
;
    g=g+  0.41611*cos(az*!dtor) + 0.18207*sin(az*!dtor)   $
          -.10120*cos(2.*az*!dtor) + .02740*sin(2.*az*!dtor) $
          -.30386*cos(3.*az*!dtor) - .14610*sin(3.*az*!dtor)
    return,g
end
