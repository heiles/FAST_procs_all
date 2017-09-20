pro beamout_azzapa, nrcmax, beamin_arr, beamout_arr

;+
;NAME:
; beamout_azzapa
;PURPOSE:

;fill beamout structure with az, za, and beamout values for center of
;scans... 

;INPUTS: from beamin:
;   beamin.azencoders, 240 az encoder values
;   beamin.zaencoders, 240 za encoder values

;OUTPUTS:
;   az, za, and pa for each scan center in the structure beamout. 
;all values in degrees. 

;-

FOR NRC=0, NRCMAX-1 DO BEGIN
;beamin= beamin_arr[ nrc]

beamout_arr[ nrc].azcntr= beamin_arr[ nrc].azencoders[ 29,*]
beamout_arr[ nrc].zacntr= beamin_arr[ nrc].zaencoders[ 29,*]

beamout_arr[ nrc].pacntr= $
    pangle( beamout_arr[ nrc].azcntr, beamout_arr[ nrc].zacntr, 1)
ENDFOR

return
end

