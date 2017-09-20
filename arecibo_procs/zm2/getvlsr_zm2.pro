
pro getvlsr_zm2, hdr1info, hdrdbl, vlsr, npatt=npatt, noneg=noneg, $
             chnlsep=chnlsep, chnlsepvel=chnlsepvel
;+
;PURPOSE: calculate the vlsr of the 2048 chnl spectra from
;       arecibo's interim correlator for zm2 pattern spectra.
;
;CALLING SEQUENCE:
;        GETVLSR_ZM2, hdr1info, hdrdbl, vlsr, npatt=npatt, noneg=noneg, $
;             chnlsep=chnlsep, chnlsepvel=chnlsepvel
;
;INPUT:
;HDR1INFO, the hdr1info array from the p1 sav fild. uses the zeroth one
;unless npatt is specified, in  which case it uses the npatt one.
;hdrdbll, the double-precision hdr info.
;
;OPTIONAL INPUT:
;NPATT, the pattrn nr. if unspecified, uses the zeroth one.
;
;OUTPUT:
;VLSR[2048], the array of vlsr.
;
;KEYWORDS FOR OUTPUT
;NONEG=NONEG: reverses dir of vlsr. you should not have to use this.
;CHNLSEP=CHNLSEP: chn separation in Hz
;CHNLSEPVEL=CHNLSEPVEL: chnl separation in vellcity
;-

mult=1.
if keyword_set( noneg) then mult=-1.
if n_elements( npatt) eq 0 then npatt=0

;GET THE CHANNEL SEPARATION in HZ...
chnlsep = 1e6*hdr1info[4, npatt]/2048.
vlsrcntr = hdr1info[7,npatt]
cfr = hdrdbl[1,npatt]

;stop
if (cfr lt 1500.) then begin
cntrchnl = 1023.
vlsr = vlsrcntr - (findgen(2048)-cntrchnl) * chnlsep * $
        2.99792458e5/(1e6* cfr)
endif else begin
cntrchnl = 1024.
vlsr = vlsrcntr + mult*(findgen(2048)-cntrchnl) * chnlsep * $
        2.99792458e5/(1e6* cfr)
endelse

chnlsepvel= mult* chnlsep * 2.99792458e5/(1e6* cfr) 

return
end
