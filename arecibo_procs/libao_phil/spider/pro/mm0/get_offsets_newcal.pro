pro get_offsets_newcal, scndata, stokesc1,fitInd,hb_arr, beamin_arr,$
                    stkOffsets_chnl_arr,byChnl=byChnl
;+
;NAME:
;get_offsets_newcal
;GET THE ANGULAR OFFSETS, SPECTRA, AND SPECTRUM-INTEGRATED POWERS 
;   FOR THE FOUR STRIPS IN ARRAYS OF [*, 4]
;THE UNITS OF ANGULAR OFFSETS ARE ---> NO LONGER <--- THE SPECIFIED HPBW.
;THE UNITS OF ANGULAR OFFSETS ARE ---> ARCMIN <--- .
;--------> THIS IS A BIG CHANGE!!! <------------

;NOTE: at the end, we attempt to generalize to an arbitrary nr of
;strips and points per strip. however, we read these data from 
;our HAND-GENERATED STRUCTURE SCNDATA instead of from the corfile data.
;
;THIS SHOULD BE FIXED, but i don't know the definitions of the corfile
;structure.
;
;       BEWARE!!
;-


;---GET THE POSITIONS OF EACH DATA POINT ----------------

points_per_strip =  float( [ hb_arr[0,fitInd].proc.iar[2],$
     hb_arr[1,fitInd].proc.iar[2], $
     hb_arr[2,fitInd].proc.iar[2], hb_arr[3,fitInd].proc.iar[2]])

azoffset = fltarr( (points_per_strip)[0], 4)
zaoffset = fltarr( (points_per_strip)[0], 4)
totoffset = fltarr( (points_per_strip)[0], 4)

az_begin = [ hb_arr[0,fitInd].proc.dar[1], hb_arr[1,fitInd].proc.dar[1], $
     hb_arr[2,fitInd].proc.dar[1], hb_arr[3,fitInd].proc.dar[1]]
za_begin = [ hb_arr[0,fitInd].proc.dar[2], hb_arr[1,fitInd].proc.dar[2], $
     hb_arr[2,fitInd].proc.dar[2], hb_arr[3,fitInd].proc.dar[2]]

az_rate = [ hb_arr[0,fitInd].proc.dar[3], hb_arr[1,fitInd].proc.dar[3], $
     hb_arr[2,fitInd].proc.dar[3], hb_arr[3,fitInd].proc.dar[3]]
za_rate = [ hb_arr[0,fitInd].proc.dar[4], hb_arr[1,fitInd].proc.dar[4], $
     hb_arr[2,fitInd].proc.dar[4], hb_arr[3,fitInd].proc.dar[4]]

sec_per_strip =  float( [ hb_arr[0,fitInd].proc.iar[1],$
                          hb_arr[1,fitInd].proc.iar[1], $
     hb_arr[2,fitInd].proc.iar[1], hb_arr[3,fitInd].proc.iar[1]])

az_binwidth = az_rate* sec_per_strip/ points_per_strip
za_binwidth = za_rate* sec_per_strip/ points_per_strip

for nrstrip = 0,3 do begin
azoffset[ *, nrstrip] = az_begin[ nrstrip] + $
    az_binwidth[ nrstrip]* ( 0.5 + findgen( points_per_strip[0]))
zaoffset[ *, nrstrip] = za_begin[ nrstrip] + $
    za_binwidth[ nrstrip]* ( 0.5 + findgen( points_per_strip[0]))
endfor

totoffset[ *,0] = azoffset[*,0]
totoffset[ *,1] = zaoffset[*,1]
totoffset[ *,2:3] = sqrt( azoffset[ *,2:3]^2 + zaoffset[ *,2:3]^2)

temp_tot = totoffset[*,2:3]
temp_az = azoffset[*,2:3]
indx = where( temp_az lt 0.)
temp_tot[ indx] = temp_tot[ indx] * (-1.)
totoffset[ *,2:3] = temp_tot


;CONVERT ALL ANGLES FROM DEGREES TO ARCMIN...
azoffset = 60.* azoffset
zaoffset = 60.* zaoffset
totoffset = 60.* totoffset

;INSERT AZOFFSET, ZAOFFSET, TOTOFFSET INTO THE BEAMIN STRUCTURE...
; CONVERTING TO UNITS OF ARCMIN.
beamin_arr[fitInd].azoffsets= azoffset
beamin_arr[fitInd].zaoffsets= zaoffset
beamin_arr[fitInd].totoffsets= totoffset

;

;------------GET THE STOKES SPECTRA OF EACH DATA POINT ----------------

nchnls= scndata.nchnls
nrpts= points_per_strip[ 0]
nrstrips= scndata.nrstrips
nrcal= scndata.ptsforcal
;
;   move the cal spectra over
;
    beamin_arr[fitInd].stkoffsets_chnl_cal= stokesc1[*,*,0:1]

;   compute the total power 

    ngainchnls=n_elements(scndata.gainchnls)
    beamin_arr[fitInd].stkoffsets_cont=$
        total(reform(stokesc1[scndata.gainchnls,*, nrcal:*],ngainchnls,$
                4,nrpts,nrstrips), 1)/ ngainchnls
    if keyword_set(byChnl) then begin
        stkoffsets_chnl_arr[*,*,*,*,fitInd]=$
                        reform(stokesc1[*,*,nrcal:*],nchnls,4,nrpts,nrstrips)
    endif

;stop

return
end

