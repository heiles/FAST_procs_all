pro coeffs_to_b, chnlsep, coeffs, lande_g, bfld, berr, gain, gainerr

;+
;convert coeffs from zec2_zfit to b for the GBT data structure.
;INPUTS:
;	CHNLSEP, the freq diff btn chnls in Hz, e.g. freq[1]-freq[0]
;	COEFFS, the coeffs array from zec2_zfit
;	LANDE_G, the lande-G factor for the transition.
;OUTPUTS:
;	BFLD, BERR: the magnetic field from the coeffs in microGauss
;	GAIN, GAINERR: gain and its error.
;
;********* !!!!!!!!! IMPORTANT at HI Z !!!!!!!!! *************
;IF you have a highly redshifted line, the zeeman splitting is redshifted,
;too, so the splitting is smaller than it would be with no redshift. so if
;the redshift is z, you need to multiply the derived field by (1+z).
;
;NOTES
;	COEFFS is in units of chnl separation.  convert this to Hz,
;correct for lande_g, and you're home.
;       29 nov 2007: created this from coeffs_to_b_gbt.
;-


; THE SPLITTING IN CHANNELS AND ITS ERROR ARE STORED IN
; COEFFS[1,0] AND [1,1]...
bfld= chnlsep* coeffs[1,0]/ lande_g
berr= abs( chnlsep)* coeffs[1,1]/ abs( lande_g)

; THE GAIN AND ITS ERROR ARE STORED IN COEFFS[0,0] AND [0,1]...
gain = coeffs[ 0,0]
gainerr = coeffs[ 0,1]

return
end
