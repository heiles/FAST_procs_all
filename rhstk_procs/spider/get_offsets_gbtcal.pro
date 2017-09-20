pro get_offsets_gbtcal, scndata, beamin,  $
        calbefore, strip, calafter, $
	nrc, stokesc1 ;, $
;	azoffset, zaoffset, totoffset, stokesoffset, stokesoffset_cont, $
;	azoffset_cal, zaoffset_cal, stokesoffset_cal

;+
;GET THE ANGULAR OFFSETS, SPECTRA, AND SPECTRUM-INTEGRATED POWERS 
;	FOR THE FOUR STRIPS IN ARRAYS OF [*, 4]
;THE UNITS OF ANGULAR OFFSETS ARE ---> ARCMIN <--- .
; 
;ALSO REARRANGE THE STRIP DIRECTIONS AND ORDER TO CONFORM TO THE
;ORIGINAL ARECIBO VALUES.

;ALSO, BE CAREFUL IN DEFINING TOTOFFSET SO THAT THE SIGNS ALWAYS
;INCREASE ALONG EACH STRIP.

;-


;---GET THE POSITIONS OF EACH DATA POINT ----------------

nchnls= strip[ 0].nchan
beamin.nchnls= nchnls

azoffset = $
	strip[ 4* nrc: 4* nrc+ 3].subscan[ 0:scndata.ptsperstrip-1].azoffset
zaoffset = $
	strip[ 4* nrc: 4* nrc+ 3].subscan[ 0:scndata.ptsperstrip-1].zaoffset

;CONVERT ALL ANGLES FROM DEGREES TO ARCMIN...
azoffset0 = 60.* azoffset
zaoffset0 = 60.* zaoffset

;INSERT AZOFFSET, ZAOFFSET, TOTOFFSET INTO THE BEAMIN STRUCTURE...
; CONVERTING TO UNITS OF ARCMIN.
beamin.azoffsets= azoffset0
beamin.zaoffsets= zaoffset0

;------------GET THE STOKES SPECTRA OF EACH DATA POINT ----------------

nrpts= scndata.ptsperstrip
nrstrips= scndata.nrstrips
nrcal= scndata.ptsforcal

beamin.stkoffsets_chnl = $
	stokesc1[ *, *, nrcal/2:nrcal/2+ nrpts- 1, *]

;THEN INTEGRATE OVER CHANNELS...
beamin.stkoffsets_cont= total( beamin.stkoffsets_chnl,1)/nchnls

;NOW REARRANGE ALL OFFSETS ORDERING TO CONFORM TO ORIGINAL ARECIBO STYLE...
;NOTE WHAT YOU HAVE TO DO BECAUSE YOU CAN'T OPERATE ON PARTIAL STRUCTURES...
quan= beamin.azencoders & gbt_to_ao, quan & beamin.azencoders= quan
quan= beamin.zaencoders & gbt_to_ao, quan & beamin.zaencoders= quan
quan= beamin.azoffsets & gbt_to_ao, quan & beamin.azoffsets= quan
quan= beamin.zaoffsets & gbt_to_ao, quan & beamin.zaoffsets= quan

;stkoffset_cont= beamin.stkoffsets_cont
FOR NR=0, 3 DO BEGIN
;********** using REFORM below is REQUIRED!!!! ***********
quan= reform( beamin.stkoffsets_cont[ nr, *, *])
gbt_to_ao, quan
beamin.stkoffsets_cont[ nr, *, *]= quan
ENDFOR

quan1= beamin.stkoffsets_chnl
;********** using REFORM below is REQUIRED!!!! ***********
quan1= reform( quan1, nchnls* 4, nrpts, nrstrips)
FOR NR=0l, nchnls*4l- 1l DO BEGIN
quan= reform( quan1[ nr, *, *])
gbt_to_ao, quan
quan1[ nr, *, *]= quan
ENDFOR
quan1= reform( quan1, nchnls, 4, nrpts, nrstrips)
beamin.stkoffsets_chnl= quan1

;tst_cont= total( beamin.stkoffsets_chnl,1)/256
;STOP, 'GET_OFFSETS_GBTCAL, 2'

;NOW DEAL WITH TOTOFFSET...
azoffset= beamin.azoffsets
zaoffset= beamin.zaoffsets
totoffset = sqrt( azoffset^2+ zaoffset^2)

totoffset[ *,0]= totoffset[ *,0]* sign( azoffset[ *,0])
totoffset[ *,1]= totoffset[ *,1]* sign( zaoffset[ *,1])

temp_tot = totoffset[*,2:3]
temp_az = azoffset[*,2:3]
indx = where( temp_az lt 0.)
temp_tot[ indx] = temp_tot[ indx] * (-1.)
totoffset[ *,2:3] = temp_tot
beamin.totoffsets= totoffset

;stokesc1_cont= total(stokesc1[*,*,2:81,*],1)/256.
;stop, 'end of get_offsets_gbtcal'

return
end

