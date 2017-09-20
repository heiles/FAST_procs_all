;+
;kipsTempTdpos - compute total kips on platform from temp, avg td position
; SYNTAX:
;       kips=kipsTempTdpos(tempDegF,avgTdPos,epoch=epoch)
;
;epoch 
;2000    fit comes from 7mar00 through 4may00 data
;2002 (default) comes from 2002 (see x101/td/model/yr2002.. 
;					all data after massaging. fit rms:3.90 kips
;-
function kipsTempTdpos,temp,avgTdpos,epoch=epoch
;	
	if n_elements(epoch) eq 0 then epoch=2002
	if epoch eq 2000 then begin
		return,[285.32827D - 2.9821866D*temp + 6.2067121D*avgTdPos]
	endif else begin
		return,[245.41285D -2.7409479D*temp  + 6.8979111D*avgTdPos]
	endelse
end
