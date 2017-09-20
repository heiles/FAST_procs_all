pro beamout_azzapa, nrcmax, beamin_arr,  $
        calbefore, strip, calafter, $ 
	beamout_arr

;+
;PURPOSE:

;fill beamout structure with az, za, and beamout values for center of
;scans... 

;INPUTS: from beamin:
;	beamin.azencoders, 240 az encoder values
;	beamin.zaencoders, 240 za encoder values

;OUTPUTS:
;	az, za, and pa for each scan center in the structure beamout. 
;all values in degrees. 

;MOD HISTORY: 22 JUL 2008, REPLACED PANGLE BY PARANGLE.
;-

FOR NRC=0, NRCMAX-1 DO BEGIN
;beamin= beamin_arr[ nrc]

t29= strip[ 4*nrc].nsubscan/2
beamout_arr[ nrc].azcntr= beamin_arr[ nrc].azencoders[ t29,*]
beamout_arr[ nrc].zacntr= beamin_arr[ nrc].zaencoders[ t29,*]

eq2az, hacntr, deccntr, beamout_arr[ nrc].azcntr, beamout_arr[ nrc].zacntr, beamout_arr[nrc].antlat, /reverse

beamout_arr[ nrc].pacntr= parangle( hacntr, deccntr, beamout_arr[nrc].antlat)
;beamout_arr[ nrc].pacntr= pangle( beamout_arr[ nrc].azcntr, beamout_arr[ nrc].zacntr, 1)
;stop
ENDFOR

return
end

