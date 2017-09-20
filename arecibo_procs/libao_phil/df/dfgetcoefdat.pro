;+
;NAME:
;dfgetcoefdat - return the 128 filter coef.
; 
;SYNTAX:  coef=dfgetcoef(complex=complex,len=len,norm=norm)
;KEYWORDS:
;	complex:	  if set then return data as complex double
;	    len: long zero extend to length len (len must be >=67)
;	   norm:      if set then normalize coef to unity.
;RETURNS:   
; coef[128]: double    returns the 128 coef.
;
;DESCRIPTION:
;	Return the 128 coefficients for the digital filters. They were
;sent via fax from harris corporation. 
;-
;history:
; 04sep0t started
function dfgetcoefdat,complex=complex,len=len,norm=norm
; 
	common dfcom,dfc_coef
     on_error,1
	 if n_elements(dfc_coef) ne 67 then begin 
	 	openr,lun,aodefdir()+'df/hbcoef.dat',/get_lun
	 	dfc_coef=dblarr(67)
	 	readf,lun,dfc_coef
	 	free_lun,lun
	 endif
	 coef=dfc_coef
	 if keyword_set(norm) then coef=coef/max(coef)
	 if keyword_set(len) then begin
		if len gt 67 then begin
	 	   a=dblarr(len)
		   a[0:66]=coef
		   coef=a
		endif 
	endif
	if keyword_set(complex) then return,dcomplex(coef)
	return,coef
end
