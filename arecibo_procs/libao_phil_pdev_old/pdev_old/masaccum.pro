;+
;NAME:
;masaccum - accumulate an array of buffers
;SYNTAX: naccum=masaccum(bIn,baccum,avg=avg,new=new,mb=mb)
;ARGS:
;	bIn[n]: {}   stuctures to avg
;KEYWORDS: 
;      mb:      if set then bInn[nrecs,nbm] is a Nrecs,nbeams array. 
;               We accumuate only the first dimension.
;               output is baccum[nbm]
;     new:      if set then allocate baccum. This is the first call
;               if not set then baccum passed in will be added to.
;   double:     if set then make accum array double. needs to be used
;               when /new is called.
;     avg:      if set then compute avg rather than sum
;   toavg: long number of spectra to avg
;RETURNS:
;  naccum: > 0 number we accumulated in baccum
;       : 0   none summed
; baccum[nbm]: {}   the accumulated spectra
;-
function masaccum,bIn,bacc,mb=mb,new=new,avg=avg,double=double
;
;   optionally position to start of row
;
    lrow=n_elements(row) eq 0 ? 0L:row
	if n_elements(toavg) eq 0 then toavg=1
;
;   loop reading the data
;
	szIn=size(bIn)
	ndimIn=szIn[0]
	usemb=0
	if ((ndimIn lt 1)  or (ndimin) gt 2) then begin
		print,'masccum only supports 1 or 2d arrays'
		return,-1 
	endif
	ndim1=szIn[1]
	ndim2=(szIn[0] eq 2)?szIn[2]:0
	nchan=bin[0].nchan
	npol=bIn[0].npol
	recsToAdd=1;
	for i=1,ndimIn do recsToAdd*=szIn[i];
	if keyword_set(mb) then begin
        if (szIn[0] ne 2 )then begin
		  print,'/mb need 2d input array. if only single dim try reform(b,1,n)'
		  return,-1
		endif
		usemb=1
		recsToAdd=szIn[1]
	endif
	usedouble=keyword_set(double)
	if keyword_set(new) then begin
;
;		create a single element
;
		if (npol eq 1) then begin
				x=(keyword_set(double))?dblarr(nchan):fltarr(nchan)
		endif else begin
				x=(keyword_set(double))?dblarr(nchan,npol):fltarr(nchan,npol)
		endelse
		bacc={h     : bIn[0].h,$
		   	   nchan: nchan,$
		    	npol: npol,$
		   	   ndump: 1,$
		          st: bIn[0].st[0],$
			   accum: 0d,$
		           d: x $
		   }
;
; 	now create the array to hold the results
;
		if (usemb) then begin
			bacc=replicate(bacc,szIn[2])
			for i=0,ndim2-1  do begin
				bacc[i].h=bIn[0,i].h
				bacc[i].st=bIn[0,i].st[0]
			endfor
		endif
	endif 
	if (nchan ne bacc[0].nchan) $
	   or (bIn[0].npol  ne bacc[0].npol)  then begin
		print,"nchan,npol of input buf doesn't match values from accum buf"
		return,-1
	endif
	dumpRec=bIn[0].ndump
	if (not usemb) then begin
			if npol eq 1 then begin
				bacc.d+=total(reform(bin.d,nchan,recsToAdd*dumpRec),2,$
							double=usedouble)
			endif else begin 
				bacc.d+=total(reform(bin.d,nchan,npol,recsToAdd*dumpRec),3,$
							  double=usedouble)
			endelse
			bacc.accum+=dumpRec*recsToAdd
	endif else begin
		    for i=0,ndim2-1 do begin
				if npol eq 1 then begin
					bacc[i].d+=$
						total(reform(bin[*,i].d,nchan,recsToAdd*dumpRec),2,$
								double=usedouble)
				endif else begin 
					bacc[i].d+=$
					total(reform(bin[*,i].d,nchan,npol,recsToAdd*dumpRec),3,$
						double=usedouble)
				endelse
				bacc[i].accum+=dumpRec*recsToAdd
			endfor
	endelse
	if keyword_set(avg) then begin
		for i=0,n_elements(bacc)-1 do begin
			scl=(bacc[i].accum eq 0.)?1.:1./bacc[i].accum
			bacc[i].d*=scl
			bacc[i].accum=0.
		endfor
	endif
	return,dumprec*recstoAdd
end

