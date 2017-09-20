pro angrotate, xrealin, yimagin, phi, xrealout, yimagout
;TURNS xrealIN, yimagIN INTO COMPLEX; ROTATES BY ANGLE PHI
; RETURNS xrealOUT, yimagOUT
original1 = complex( xrealin, yimagin)
new1 = original1 * exp(complex( 0., !dtor*phi))
xrealout = float( new1)
yimagout = imaginary( new1)
return
end

