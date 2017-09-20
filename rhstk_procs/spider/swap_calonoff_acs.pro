pro swap_calonoff_acs, filename, scndata
;+
; 5/23/07 Tim Robishaw adds a catch for spectrometer data... each strip for
; the ACS is taken as CALON,CALOFF -> DATA -> CALON,CALOFF but we've
; assumed in setup_initialize_gbtcal that CALOFF came before CALON, which
; is the way it used to be for the Spectral Processor.  So we check the
; filename and swap scndata.indxcalon and scndata.indxcaloff if we're
; reducing Spectrometer Data...
;
; since indxcalon/indxcaloff are hardwired upon entering, we can only know
; to make a swap once the user has specified a file.  therefore, we should
; do the swap in the "doit.idl" scripts.  also, we might need to swap back
; to the original order if we process a Spectral Processor file (SP) after
; a Spectrometer file (ACS).
;-

; DON'T DO ANYTHING IF THIS IS NOT AN ACS FILE...
case 1 of
   strmatch(filename,'*_acs_*',/FOLD_CASE) : begin
      ; CALON COMES BEFORE CALOFF...
      if (scndata.indxcalon[0] lt scndata.indxcaloff[0]) then return
   end
   strmatch(filename,'*_sp_*',/FOLD_CASE) : begin
      ; CALOFF COMES BEFORE CALON...
      if (scndata.indxcalon[0] gt scndata.indxcaloff[0]) then return
   end
   else: message, 'Unknown Backend'
endcase

; OTHERWISE, SWAP THEM..
tmp = scndata.indxcalon
scndata.indxcalon=scndata.indxcaloff
scndata.indxcaloff=tmp

end
