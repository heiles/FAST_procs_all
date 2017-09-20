;+
;NAME:
;dfspctechnote - return the 128 point spectra of the digital filters.
; 
;SYNTAX:  spc=dfspctechnote(db=db)
;KEYWORDS:
;	db	: if set the return in db scale. default is linear.
;RETURNS:   
; spc[128]: double    returns the 128 point spectra of digital filters.
;
;DESCRIPTION:
;	Return the 128 point spectrum of the digital filters. This was taken
;from the harris chip technical note. You can compare this to the computed
;filter bandpasses.
;-
;history:
; 04sep0t started
function dfspctechnote,db=db
; 
     on_error,1
	 openr,lun,aodefdir()+'df/hbspctechnote.dat',/get_lun
	 spc=dblarr(128)
	 readf,lun,spc
	 free_lun,lun
     if keyword_set(db) then return,spc
	 return,10^(spc*.1)
end
