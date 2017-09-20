
pro getvlsr, hdr1info, vlsr, npatt=npatt, noneg=noneg, $
             chnlsep=chnlsep, chnlsepvel=chnlsepvel
;+
;PURPOSE: calculate the vlsr of the 2048 chnl spectra from
;       arecibo's interim correlator for z17 pattern data.
;CALLING SEQUENCE:
;        getvlsr, hdr1info, vlsr, npatt=npatt, noneg=noneg, $
;             chnlsep=chnlsep, chnlsepvel=chnlsepvel
;
;INPUT:
;HDR1INFO, the hdr1info array from the p1 sav fild. uses the zeroth one
;unless npatt is specified, in  which case it uses the npatt one.
;
;optional input:
;NPATT, the pattrn nr. if unspecified, uses the zeroth one.
;
;OUTPUT:
;VLSR[2048], the array of vlsr.
;-
mult=1.
if keyword_set( noneg) then mult=-1.
if n_elements( npatt) eq 0 then npatt=0

;GET THE CHANNEL SEPARATION in HZ...
chnlsep = 1e6*hdr1info[4, npatt]/2048.
vlsrcntr = hdr1info[7,npatt]
cntrfreq = hdr1info[5,npatt]

;stop
if (cntrfreq lt 1500.) then begin
cntrchnl = 1023.
vlsr = vlsrcntr - (findgen(2048)-cntrchnl) * chnlsep * $
        2.99792458e5/(1e6*hdr1info[5,npatt])
endif else begin
cntrchnl = 1024.
vlsr = vlsrcntr + mult*(findgen(2048)-cntrchnl) * chnlsep * $
        2.99792458e5/(1e6*hdr1info[5,npatt])
endelse

chnlsepvel= mult* chnlsep * 2.99792458e5/(1e6*hdr1info[5,npatt]) 

return
end
