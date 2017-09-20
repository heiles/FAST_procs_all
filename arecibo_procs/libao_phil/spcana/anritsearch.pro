;
;
;ARGS:
;inpl[n]: strarr  of input data
;indstart : long    index to start on .. count from zero
;key    : str     to search for
;
;RETURNS:
;ISTAT  :    -1   not found
;            >=0  index where key was found
;val    : string   value found (without =)
;KEYWORDS:
;	noval:         if set then just look for the key, ignore value
;
;
;DESCRIPTION
; Search thru inpl looking for key. if found get value (as string)
;
function anritsearch,inpl,indstart,key,val,noval=noval
;
	n=n_elements(inpl)
	if indstart ge n then begin
		print,"Starting index ge number of elements"
		return,-1
	endif
	icur=indStart
	keylen=strlen(key)
	while (strmid(inpl[icur],0,keylen) ne key) do begin
		icur++
		if icur ge n then return,-1
	endwhile
	if not keyword_set(noval) then $	
		val=(strsplit(inpl[icur],"=",/extract))[1]
	return,icur
end
