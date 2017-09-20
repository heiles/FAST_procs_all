;no doc+
;NAME:
;tsysvsza - return the system temperature az a function of za
;SYNTAX: tsys=tsysvsza(za,rcvr,pol,misc)
;ARGS  : 
;       za[]: float zenith angle in degrees to evaluate tsys
;       rcvr: string  "lbn","lbw","lbwoh","sbn"
;       pol : string  'a' or 'b'
;DESCRIPTION
;   return the system temperature for the requested zenith angles.
;For lband wide the fit is from data taken with the hybrid in.
;nodoc-
