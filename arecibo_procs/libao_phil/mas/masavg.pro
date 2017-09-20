;+
;NAME:
;masavg - read and average spectra 
;SYNTAX: istat=masavg(desc,navgspc,b,bIn=bIn,row=row,toavg=toavg,double=double)
;ARGS:
;    desc: {} returned by masopen
;   navgspc: long number of averaged spectra to return
;KEYWORDS: 
;    bIn[]:{}  if suppplied then take input data from bIn rather than 
;              reading from disc (desc is ignored).
;     row: long row to position to before reading (cnt from 1)
;   toavg: long number of spectra to avg
;  double:      if set then avg data as doubles. default is float.
;RETURNS:
;  istat: 1 returned the requested number of averaged spectra
;       : 0 returned no average spectra
;       : -1 returned some but not all of the rows
; b[navgspc]: {}   array of structs holding the averaged data
;DESCRIPTION
;	Read and average spectra. Each spectra will average toavg spectra 
;(if not supplied then average 1 spectra). Continue reading and averaging
;spectra until navgspc averaged spectra have been done. 
;	If blanking is enabled then scale the averaged spectra by the
;number of ffts (so that all averaged spectra have the same mean value).
;In this case the b.st.fftaccum field will hold the fft's accumulated
;for the first spectra of the average (can't have routine the correct value
;since this is a short rather than a float).
;-
function masavg,desc,navgreq,bb,bIn=bIn,row=row ,toavg=toavg,_extra=e,$
		double=double
;
;   optionally position to start of row
;
    lrow=n_elements(row) eq 0 ? 0L:row
    if n_elements(toavg) eq 0 then toavg=1
	useBin=0
	if n_elements(bIn) gt 0 then begin
		useBin=1
		nrows=n_elements(bIn)
		irow=(n_elements(row) gt 0)?row-1:0
		if irow ge nrows then begin
			print,"Requested row:",row," beyond end of bIn array"
			return,0
		endif
	endif		
;
;   loop reading the data
;
    iavg=0L
    naccum=0L
    done=0
    start=1
    icnt=0
	blankcor=1
    while (not done) do begin
		if (useBin) then  begin
			if irow ge nrows then begin
				stop
				 break
			endif
			b=bIn[irow]
			irow+=1
			istat=1
		endif else begin
        	istat=masget(desc,b,row=lrow,_extra=e,blankcor=blankcor)
		endelse
;       print,"cnt",icnt++,"masget istat:",istat," ndumps:",b.ndump," iavg:",iavg 
        lrow=0L
        if istat ne 1 then break
        if start then begin
              npol=b.npol
			  floatL=keyword_set(double)?0:1
			  bb=masmkstruct(b,float=floatL,double=double,ndump=1,$
				  npol=npol,nelm=navgreq)
			  bb.blankcordone=1
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
    if naccum ne 0 then iavg-=1     ; only keep complete averages 
    navg=iavg
    if navg eq 0 then begin
        bb=''
    endif  else begin
        if navg lt navgreq then bb=bb[0:navg-1]
    endelse
    istat=(navg eq 0)?0:(navg eq navgreq)?1:-1
    return,istat
end
