pro qu2pa, qq, uu, sigqq, siguu, $
               polpwr, polang, sigpolpwr, sigpolang, reverse=reverse
;
;+
;PURPOSE: Convert linear pol specification variable from Stokes Q,U to
;polowr and polang; or, go the other way if /reverse

;CALLING SEQUENCE
;QU2PA, qq, uu, sigq, sigu, $
;           polpwr, polang, sigpolpwr, sigpolang, reverse=reverse
;
;INPUTS:
;       QQ is stokes Q; SIGQQ is error in stokes Q
;       UU is stokes U; SIGUU is error in stokes U
;       POLPWR is total linear polarization.
;       POLANG is the position angle in DEGREES
;       SIGQQ, SIGUU are errors in QQ and UU
;       SIGPOLPWR, SIGPOLANG are errors in (POLPWR, POLANG); sigpolang
;       is in DEGREES
;
;KEYWORDS:
;       Set REVERSE to convert (POLPWR, POLANG to Q,U)
;
;OUTPUTS:
;       see INPUTS. if REVERSE, then polpwr, polang, sigpolowr,
;       sigpolang are inputs and QQ, etc outputs. 
;
;HISTORY
;       23nov2016 CH adapted from qoru_polfit.pro
;
;-

if keyword_set( reverse) eq 0 then begin
polpwr= sqrt( qq^2 + uu^2)
polang= !radeg* 0.5* atan( uu, qq)

sigpolpwr= sqrt( qq^2*sigqq^2 + uu^2*siguu^2) /polpwr
;sigpolpwr= sqrt( qq^2*sigqq^2 + uu^2*siguu^2) /polpwr^2
sigpolang= !radeg* 0.5* sigpolpwr/ polpwr
;sigpolang= !radeg* sqrt( (qq^2*siguu^2 + uu^2*sigqq^2)/polpwr^4)
;stop
endif else begin
uu= polpwr* sin(2.* !dtor* polang)
qq= polpwr* cos(2.* !dtor* polang)

;too lazy to calculate these right now...
siguu= -99.
sigqq= -99.
endelse
;stop
return
end
