;+
;pltsfitvszaall - plot the 6 azswing coef's vs za
; 
; SYNTAX:
;  pltsfitvszaall,azfit,roll=roll,raw=raw ,label=label,_EXTRA=e
; 
; ARGS:
;     azfit[nza]  {azf} the azimuth fits.
;
; KEYWORDS:
;     roll  0--> do pitch, ne 0 --> roll
;     raw   if ne 0 then set vertical scales for fits on notcorrected data.
;    label  date for label at top 
;   extra:
;    ver    [2,6] vertical min,max for each of 6 outputs
;
; DESCRIPTION:
;     plot the 6 azswing fit coef. for the naz swings. This routine
; sets the vertical scale and then calls pltsfitvsza multiple times.
;-
;
pro pltsfitvszaall,azfit,roll=roll,raw=raw,label=label,_EXTRA=e
	if n_elements(raw) eq 0 then raw=0
	if n_elements(roll) eq 0 then roll=0
	if n_elements(label) eq 0 then label=' '
    for i=0,5 do pltsfitvsza,azfit,i,roll=roll,label=label,raw=raw,_EXTRA=e
    return
end
