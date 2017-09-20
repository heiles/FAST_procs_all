;+
;NAME:
;hexpr - hex printout
;SYNTAX: hexpr,num
;ARGS:
;num[]:  long	output num as hex (1 number per line)
;
;-
pro hexpr,num
	n=n_elements(num)
	if n gt 0 then begin
		for i=0,n-1 do begin
			print,num[i],format='(z)'
		endfor
	endif else begin
		print,num,format='(z)'
	endelse
	return
end
;
