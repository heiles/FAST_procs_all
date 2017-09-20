;+
;NAME:
;genpidcoef -  compute pid coef from the input parameters.
;ARGS:
;	coef - holds the parameters
;   area  - integral of error
;   coef  - hold pid coef to use
;RETURNS:
;	coef    pid structure holding evaluated params
;-
function genpidcoef,Ka,Kf,Kp,Ki,Kd,T
;
	coef={piCoef}
	coef.Ka=Ka
	coef.Kf=Kf
	coef.Kp=Kp
	coef.Ki=Ki
	coef.Kd=Kd
	coef.T =T 
	FF    =exp(-coef.Kf*coef.T)
;
;   * Scaling due to velocity command being  0.0318033914 encoder
;   * counts / 5 msecs / command bit

	Cnv   = 0.0318033914
	coef.P=FF *coef.Ka*coef.Kf*coef.Kp*cnv
	coef.I=(1.-FF)*coef.Ka*coef.Ki*coef.T *cnv
	coef.D=-(FF*coef.Ka*(coef.Kf*coef.Kf)*coef.Kd)/coef.T * cnv
	return,coef
end
