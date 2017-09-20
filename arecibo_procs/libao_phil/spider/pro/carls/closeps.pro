pro closeps

;+
;NAME: 
;	CLOSEPS
;
;PURPOSE:
;	Closes the ps device and reopens windows. Use after you've
;opened ps device to generate a postscript file.
;-

device, /close

;RETURN TO XWINDOWS...
set_plot, 'x'

return
end
