;+
;pfchkcalonoff - given an array of headers, check which ones have 
;                valid calonoffs
;SYNTAX: numfound=pfchkcalonoff(hdrscn,indarr)
;ARGS  :  
;	   hdrscn[] : {pfhdrstr} array input from prochdrs.
;RETURNS:
;       indarr  : index into hdrscn for start of each
;			      calonoff pair.
;		numfound: long.. number of calonoff pairs found.
;-
function pfchkcalonoff,hdrscn,indarr
;
	numfound=0
	indarr=0
	indon=where((string(hdrscn.hst[0].proc.procname) eq 'calonoff') and $
	            (string(hdrscn.hst[0].proc.car[*,0]) eq 'on'),count)
	if count eq 0 then return,0
	indoff=where((string(hdrscn[indon+1].hst[0].proc.procname) eq 'calonoff')$
			 and (string(hdrscn[indon+1].hst[0].proc.car[*,0]) eq 'off'),count)
	if count eq 0 then return,0
	indarr=indon[indoff]
	return,(size(indarr))[1]
end
