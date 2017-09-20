pro avg_srcphase, sourcephase, srcphase

;+
;NAME:
; avg_srcphase - calc the vector average angle of a set of input angles

;CALLING SEQUENCE:
;
;  avg_srcphase, sourcephase, srcphase
;
;INPUTS:
;
;   SOURCEPHASE: the array of phases to average, units ***RADIANS***
;
;OUTPUTS:
;
;      SRCPHASE: the average phase, units ***RADIANS***.
;-

y = total(sin( sourcephase))

x = total(cos( sourcephase))

srcphase = atan( y,x)

return
end
