;+
;NAME:
;masavg - read and average spectra 
;SYNTAX: istat=masavg(desc,navgspc,b,row=row,toavg=toavg)
;ARGS:
;    desc: {} returned by masopen
;   navgspc: long number of averaged spectra to return
;KEYWORDS: 
;     row: long row to position to before reading (cnt from 1)
;   toavg: long number of spectra to avg
;RETURNS:
;  istat: 1 returned the requested number of averaged spectra
;       : 0 returned no average spectra
;       : -1 returned some but not all of the rows
; b[navgspc]: {}   array of structs holding the averaged data
;-
function masavg,desc,navgreq,bb,row=row ,toavg=toavg,_extra=e
;
;   optionally position to start of row
;
    lrow=n_elements(row) eq 0 ? 0L:row
	if n_elements(toavg) eq 0 then toavg=1
;
;   loop reading the data
;
    iavg=0L
    naccum=0L
	done=0
	start=1
	icnt=0
	while (not done) do begin
        istat=masget(desc,b,row=lrow,_extra=e)
;		print,"cnt",icnt++,"masget istat:",istat," ndumps:",b.ndump," iavg:",iavg 
        lrow=0L
        if istat ne 1 then break
        if start then begin
              npol=b.npol
              b1={    h :b.h,$
                   nchan:b.nchan,$
                   npol :npol ,$
                   ndump:1L ,$
                   st   :b.st[0],$
				   accum: 0d,$
                   d    :dblarr(b.nchan,npol)$  
               }
			   bb=replicate(b1,navgreq)
			   start=0
         endif
		 for ispc=0L,b.ndump-1 do begin
			if naccum eq 0 then  begin
				bb[iavg].h=b.h
				bb[iavg].st=b.st[ispc]
			endif
			bb[iavg].d+=b.d[*,*,ispc]
			naccum++
		 	if naccum eq toavg then begin
				bb[iavg].d/=toavg
		    	iavg++
				naccum=0L
			    if iavg ge navgreq then break
			endif
		 endfor
		 done=iavg ge navgreq
	endwhile
	if naccum ne 0 then iavg-=1		; only keep complete averages 
	navg=iavg
	if navg eq 0 then begin
		bb=''
	endif  else begin
		if navg lt navgreq then bb=bb[0:navg-1]
	endelse
	istat=(navg eq 0)?0:(navg eq navgreq)?1:-1
	return,istat
end
