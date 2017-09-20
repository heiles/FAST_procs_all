;+
;NAME:
;hor -- set horizontal scale for all plots
;------------------------------------------------------------------------------
;hor - xmin, xmax  set min,max plotting range
;-

pro hor,xmin,xmax
	if N_PARAMS() eq 0 then  begin
		!x.range=0
		!x.style=0
		return
	endif
	!x.range=[xmin,xmax]
	!x.style=1
	return
end
