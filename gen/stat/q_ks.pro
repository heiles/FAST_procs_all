function q_ks, lambda
;+
; NAME:
;       Q_KS
; PURPOSE:
;       Return the significance of the Kolmogoroff-Smirnov statistic, given the 
;input parameter lambda. this differs from the goddard version prob_ks, which 
;computes lambda internally; the goddard version is not usable for the 2d case.
;this function is identical to goddard's prob_ks except that the input parameter
;is lambda, not the other stuff.

; EXPLANATION:
;       Returns the significance level of an observed value of the 
;       Kolmogorov-Smirnov statistic D for a given LAMBDA.   Called by KS2D1S
;
; CALLING SEQUENCE:
;       RESULT= Q_KS( LAMBDA)
;
; INPUT PARAMATERS:
;       LAMBDA, the input parameter--see NR
;
; OUTPUT PARAMETERS:
;       returns P_KS, a floating scalar between 0 and 1 giving the significance level of
;               the K-S statistic.   Small values of PROB suggest that the 
;               distribution being tested are not the same
;
; REVISION HISTORY:
;       Written     W. Landsman                August, 1992
;       Corrected typo (termbv for termbf)    H. Ebeling/W.Landsman  March 1996
;       Probably did not affect numeric result, but iteration went longer
;       than necessary
;       Converted to IDL V5.0   W. Landsman   September 1997
;	modified by C Heiles 17 oct 03 from prob_ks to q_ks
;-
 On_error,2

; if N_params() LT 3 then begin
;     print,'Syntax - prob_ks, D, N_eff, prob'
;     print,'  D - Komolgorov-Smirnov statistic, input'
;     print,'  N_eff - effective number of data points, input'
;     print,'  prob - Significance level of D, output'
;     return
; endif

 eps1 = 0.001    ;Stop if current term less than EPS1 times previous term
 eps2 = 1.e-8    ;Stop if current term changes output by factor less than EPS2

;THE FOLLOWING TWO LINES ARE DELETED FROM PROB_KS...
; en = sqrt( N_eff )
; lambda = (en + 0.12 + 0.11/en)*D

 a2 = -2.*lambda^2
 probks = 0.
 termbf = 0.
 sign = 1.

 for j = 1,100 do begin 

     term = sign*2*exp(a2*j^2)
     probks = probks + term

     if ( abs(term) LE eps1*termbf ) or $ 
        ( abs(term) LE eps2*probks ) then return, probks

     sign = -sign                  ;Series alternates in sign
     termbf = abs(term)

 endfor

 probks = 1.          ;Sum did not converge after 100 iterations

 return, probks

 end
