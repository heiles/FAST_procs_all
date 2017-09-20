function p_chisq, chiSQ, nu

;+
;NAME:
;p_chisq -- CALCULATE the CHI SQuare pdf GIVEN CHISQ AND NU.
;CALCULATE CHI SQ PROB DIST GIVEN CHISQ AND NU.
;CALLIING SEQUENCE:
;	PCHISQ= P_CHIS1Q( CHISQ, NU)
;
;INPUTS:
;	CHISQ, the value of chisquared
;	NU, the degrees of freedom
;
;OUTPUTS: 
;	P_CHISQ, the probability of finding chisq given nu.
;
;COMMENTS:
;
;	for nu le 30, uses the exact formula. however, factors of this
;formula go to infinity for large nu, so we revert to a logarithmic
;approximation for large nu.
;
;-

if (nu gt 30.) then begin

term1 = alog( chisq)* (nu - 2.)/2.

term2 = 0.5* chisq

term3 = alog(2.) * nu/2.

term4 = lngamma( nu/2.)         ;note: lngamma is IDL fcn

result = term1 - term2 - term3 - term4

return, exp(result)

endif

result = chisq^( (nu - 2.)/2.) * exp(-chisq/2.)/(2.^(nu/2.) * gamma(nu/2.))

return, result


end
