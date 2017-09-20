;+
;NAME:
;dffltcoef - generate the filter coef for the digital filter.
; 
;SYNTAX:  coef=dffltcoef(len=len)
;KEYWORDS:
;	len: long  the length to return. if gt than 67 then it will zero fill.
;RETURNS:   
; coef[128]: complex  the 128 coef defining the digital filter
;
;DESCRIPTION:
;	The digital filter coefficients are generated from the published spectra
;in the harris techincal note.
;SEE ALSO: dfspcdat()
;-
;history:
; 04sep0t started
function dffltcoef,len=len
; 
;     on_error,1
	 spc=10^(dfspcdat(/db)/20.)		;go from power to voltage
;
;	symmeterize it since real..
;
	a=dblarr(256)
	a[0:127]=spc
	a[129:*]=reverse(spc[1:*])
	a[128]  =a[127]						; don't have the nyquist point
	carr=dcomplex(a)
;
; inverse transform to get the coef
;
	coef=(shift(fft(carr,-1),33))[0:66]
	if not keyword_set(len) then return,coef
	if len le 67  then return,coef
	carr=dcomplexarr(len)
	carr[0:66]=coef
	return,carr
end
