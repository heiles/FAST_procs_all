;+
;NAME:
;masmath - perform math on correlator data
;SYNTAX: bout=masmath(b1,b2,sub=sub,add=add,div=div,mul=mul,$
;                       avg=avg,median=median,polAvg=polAvg,$
;                       sadd=sadd,ssub=ssub,sdiv=sdiv,smul=smul,$
;                       norm=norm,mask=mask,double=double)
;ARGS: 
;     b1[n]     :  {masget} first math argument
;     b2[n or 1]:  {masget} second math argument
;KEYWORDS:
;  2  Vector
;     sub: if set then  bout= b1-b2
;     add: if set then  bout= b1+b2
;     div: if set then  bout= b1/b2
;     mul: if set then  bout= b1*b2 
;  1 vector
;     avg: if set then  bout= avg(b1)
;  median: if set then  bout= median(b1)
;    polavg: if set then avg the pols this can be called 
;                   avg, or med.
;
;    sadd: if set then  bout= b1+sadd  (scalar add)
;    ssub: if set then  bout= b1-ssub  (scalar subtract)
;    sdiv: if set then  bout= b1/sdiv  (scalar divide) 
;    smul: if set then  bout= b1*smul  (scalar multiply)
;    norm: if set then if:
;            :b1,b2, and add,sub,mult,div
;            		normalize (mean) each elm of b2 before op.
;            :b1, /norm and no add,sub,mul,div
;                   Normalize (mean) each elm of b1
;            :b1,b2 and  /norm and no add,sub,mul,div
;                   Error
;            :scaler op then /norm does nothing
;
;   mask :{masmask}  (not implemented yet)
;                   a mask to use with norm keyword (see masmask).
;   double: if set then make data array double rather than float.
;
;RETURNS:
;   bout[n]: {masget} result of arithmetic operation.
;                     with d not float rather than long
;
;DESCRIPTION:
;   Perform arithmetic on mas  data structures. The operation performed
;depends on the keyword supplied. 
;
;VECTOR OPERATIONS:
;	-op=/add,/sub,/mul,/div
;      bout=b1 op b2 on a spectra by spectra operation.
;      If /norm is also set then each spectra of
;       b2 is normalized (mean) before the operation.   
;
;SCALER OPERATIONS:
;	-op= /ssub,sadd,smul,sdiv
;		: bout=b1* op
;       : Scaler can be a single value. This number will be used
;         for all operations,
;       : Scaler can be fltarr(npol) equal to the number of pols
;         Then each polarizion will used its on value:
;	     eg: bout.d[*,ipol]=b1.d[*,ipol] op scalVal[ipol]
;MISC OPERATIONS:
;	-op=/norm with no add,sub,mul,div specified
;       :just normalize each spectra of b1 (mean):
;        eg: bout[i].d[*,ipol]=b1[i].d[*,ipol]/mean(b1[i].d[*,ipol])
;   -op= /avg,/median
;		: compute the average or median by pol
;         eg: bavg.d[*,ipol]=mean(b1.d[*,ipol],dim=2) avg over spectra
;
;EXAMPLES:
;   let bon[300] be position switch on data
;       boff[300] be position swith off data
;
;1. avg on,off
;	bonavg=masmath(bon,/avg) or masmath(bon,/median)
;   boffavg=masmath(boff,/avg) or masmath(boff,/median)
;
;2. on/off -1
;   bonoff=masmath(bonavg,boffavg,/div)
;   bonoff=masmath(bonoff,ssub=1.)
;
;3. Normalize each 1 sec on by the 1 sec off
;   bonoffM=masmath(bon,boff,/div,/norm)
;
;4  Normalize each bon rec to unity
;   bonN=masmath(bon,/norm)
;
;5. use normalized average off to remove bandpass for each
;   rec of bon
;   bonFlat=masmath(bon,boffavg,/div,/norm)
;
;6 remove a smoothed bandpass from each spectra of bon
;  ;; compute bsmo somehow.. then
;  bonSmo=masmath(bon,bsmo,/sub)
;
;-
;modhistory
;20sep09 - stole from cormath
;  
;
; ----------------------------------------------------------------
function  doavg,b,nparams,avg=avg,median=median,double=double,polavg=polavg
;
	if nparams ne 1 then begin
         message,'masmath with /avg or /median requires 1 arg '
         return,''
    endif
	doavg=keyword_set(avg)
 	domedian=keyword_set(median)
	if (domedian) then doavg=0				; median take precedence
	doPolAvg=keyword_set(polAvg)
 	nrecs=n_elements(b)
 	ndump=b[0].ndump
    if (doavg or domedian) and (nrecs lt 2) and (ndump eq 1) then  begin
         message,'masmath with /avg or /median requires > 1 spectra '
         return,''
    endif
	npol=(dopolAvg)?1:b[0].npol
	if doPolAvg and (npol eq 4) then begin
         message,'masmath PolAvg not allowed with stokes data'
         return,''
    endif
	if (not keyword_set(double)) then   float=1
	bout=masmkstruct(b[0],ndump=1,npol=npol,nelm=1,float=float,double=double)
	nchan=bout[0].nchan
    bout.ndump=1
    bout.accum=0.
	if doPolAvg then begin
;
;		if polAvg of just 1 spectra, do it here
;
		if nrecs*ndump eq 1 then begin
			bout.d=total(b.d,2)/2.
			return,bout
		endif
;       zero for accume
		bout.d=(keyword_set(double))?0D:0.
	endif

	npol=b[0].npol
	for ipol=0,npol-1 do begin
	  if doPolAvg then begin
		if ndump gt 1 then begin
			if (doavg) then bout.d[*]+=total(reform(b.d[*,ipol,*],nchan,ndump*nrecs),2,double=double)/(nrecs*ndump)
    		if (domedian) then bout.d[*]+=median(reform(b.d[*,ipol,*],nchan,ndump*nrecs),dim=2,double=double)
		endif else begin
			if (doavg) then bout.d[*]+=total(b.d[*,ipol],2,double=double)/(nrecs)
    		if (domedian) then bout.d[*]+=median(b.d[*,ipol],dim=2,double=double)
		endelse
	  endif else begin
		if ndump gt 1 then begin
			if (npol eq 1) then begin
    			bout.d[*]=(keyword_set(median))?median(reform(b.d[*,*],nchan,ndump*nrecs),dim=2,double=double)$
								         :total(reform(b.d[*,*],nchan,ndump*nrecs),2,double=double)/(nrecs*ndump)
			endif else begin
    			bout.d[*,ipol]=(keyword_set(median))?median(reform(b.d[*,ipol,*],nchan,ndump*nrecs),dim=2,double=double)$
								         :total(reform(b.d[*,ipol,*],nchan,ndump*nrecs),2,double=double)/(nrecs*ndump)
			endelse
		endif else begin
    		bout.d[*,ipol]=(keyword_set(median))?median(b.d[*,ipol],dim=2,double=double)$
										  :total(b.d[*,ipol],2,double=double)/(nrecs)
		endelse
	  endelse
	endfor
	if doPolAvg then  bout.d/=npol
	return,bout
end
; ----------------------------------------------------------------
function  donorm,b,nparams,double=double
;
    forward_function mkbout
	if nparams ne 1 then begin
         message,'masmath:/norm by itself only takes 1 arg:b1'
         return,''
    endif
	nrec=n_elements(b)
	ndump=b[0].ndump
	npol=b[0].npol
	bout=mkbout(b[0],ndump,nrec,double=double)
	if ndump gt 1 then begin
		for irec=0,nrec-1 do begin 
		  bout[irec].h=b[irec].h
		  for idmp=0,ndump-1 do begin
			for ipol=0,npol-1 do  bout[irec].d[*,ipol,idmp]=$
			b[irec].d[*,ipol,idmp]/mean(b[irec].d[*,ipol,idmp])
		  endfor
		endfor
	endif else begin
		for irec=0,nrec-1 do begin
		    bout[irec].h=b[irec].h
			for ipol=0,npol-1 do  begin
				bout[irec].d[*,ipol]=$
				b[irec].d[*,ipol]/mean(b[irec].d[*,ipol])
			endfor
		endfor
	endelse
	return,bout
end
; ----------------------------------------------------------------
function  doscaler,b,scaler,add=add,sub=sub,mul=mul,div=div,double=double
;
    forward_function mkbout

;
;	if scaler dimension doesn't match npol, just use scaler[0] for 
;   all pols
;
	nrecs=n_elements(b)
	ndump=b[0].ndump
	npol=b[0].npol
	scalerL=scaler
    if (n_elements(scaler) ne npol) then begin
            scalerL=fltarr(npol)+scaler[0]
	endif
;
    bout=mkbout(b[0],ndump,nrecs,double=double)
	for irec=0,nrecs-1 do bout[irec].h=b[irec].h
	if ndump gt 1 then begin
	case 1 of 
		keyword_set(add):for ipol=0,npol-1 do bout.d[*,ipol,*]=b.d[*,ipol,*]+scalerL[ipol]
		keyword_set(sub):for ipol=0,npol-1 do bout.d[*,ipol,*]=b.d[*,ipol,*]-scalerL[ipol]
		keyword_set(mul):for ipol=0,npol-1 do bout.d[*,ipol,*]=b.d[*,ipol,*]*scalerL[ipol]
		keyword_set(div):for ipol=0,npol-1 do bout.d[*,ipol,*]=b.d[*,ipol,*]/scalerL[ipol]
	endcase
	endif else begin
	case 1 of 
		keyword_set(add):for ipol=0,npol-1 do bout.d[*,ipol]=b.d[*,ipol]+scalerL[ipol]
		keyword_set(sub):for ipol=0,npol-1 do bout.d[*,ipol]=b.d[*,ipol]-scalerL[ipol]
		keyword_set(mul):for ipol=0,npol-1 do bout.d[*,ipol]=b.d[*,ipol]*scalerL[ipol]
		keyword_set(div):for ipol=0,npol-1 do bout.d[*,ipol]=b.d[*,ipol]/scalerL[ipol]
	endcase
	endelse
	return,bout
end
; ----------------------------------------------------------------
function  dovec,b1,b2,nparams,add=add,sub=sub,mul=mul,div=div,double=double,norm=norm
;
    forward_function mkbout

	if nparams lt 2 then begin
    	message,'masmath with /sub,/add,/mul,/div requires 2 args'
        return,''
    endif
	if b1[0].npol ne b2[0].npol then begin
    	message,'masmath with /sub,/add,/mul,/div different # of pols in b1,b2'
        return,''
    endif
	if b1[0].nchan ne b2[0].nchan then begin
    	message,'masmath with /sub,/add,/mul,/div different # of freq chans in b1,b2'
        return,''
    endif
	nrecs1=n_elements(b1)
	ndump1=b1[0].ndump
	ndump2=b2[0].ndump
	npol1=b1[0].npol
	npol2=b2[0].npol
	nrecs2=n_elements(b2)
	byrec=0
    bout=mkbout(b1[0],ndump1,nrecs1,double=double)
;
;	if b2 is a single spectra, process each of b1 separately  by b2
;   warning.. code below probably fails with single pol
; 
    if (nrecs1 ne nrecs2) then begin
		if ((ndump2*nrecs2) ne 1) then begin
      		message,'b1,b2 must have the same number of records'
      		return,''
    	endif
        y2=b2.d	
	    if keyword_set(norm) then begin
			for ipol=0,npol2-1 do y2[*,ipol]/=mean(y2[*,ipol])
		endif
		case 1 of
		keyword_set(add): begin
			if ndump gt 1 then begin
				for irec=0,nrecs1-1 do begin 
				    bout[irec].h=b1[irec].h
					for idmp=0,ndump1-1 do bout[irec].d[*,*,idmp]=b1[irec].d[*,*,idmp]+ y2
				endfor
			endif else begin
				for irec=0,nrecs1-1 do begin
					bout[irec].h=b1[irec].h
					bout[irec].d=b1[irec].d + y2
				endfor
			endelse
		end
		keyword_set(sub): begin
			if ndump1 gt 1 then begin
				for irec=0,nrecs1-1 do begin
					bout[irec].h=b1[irec].h
					for idmp=0,ndump1-1 do bout[irec].d[*,*,idmp]=b1[irec].d[*,*,idmp]-y2
				endfor
			endif else begin
				for irec=0,nrecs1-1 do begin
					bout[irec].h=b1[irec].h
					bout[irec].d=b1[irec].d - y2
				endfor
			endelse
		end
		keyword_set(mul): begin
			if ndump1 gt 1 then begin
				for irec=0,nrecs1-1 do begin 
					bout[irec].h=b1[irec].h
					for idmp=0,ndump1-1 do bout[irec].d[*,*,idmp]=b1[irec].d[*,*,idmp] * y2
				endfor
			endif else begin
				for irec=0,nrecs1-1 do begin
					bout[irec].h=b1[irec].h
					bout[irec].d=b1[irec].d * y2
				endfor
			endelse
		end
		keyword_set(div): begin
			if ndump1 gt 1 then begin
				for irec=0,nrecs1-1 do begin
					bout[irec].h=b1[irec].h
					for idmp=0,ndump1-1 do bout[irec].d[*,*,idmp]=b1[irec].d[*,*,idmp]/y2
				endfor
			endif else begin
				for irec=0,nrecs1-1 do begin
					bout[irec].h=b1[irec].h
					bout[irec].d=b1[irec].d / y2
				endfor
			endelse
		end
		endcase
		return,bout
	endif

;
;   length b1 same as b2 do all at once unless /norm
;
	if ndump1 ne ndump2 then begin
   		message,'b1,b2 must have the same dumps per record'
      	return,''
	endif
	if not keyword_set(norm) then begin
    	case 1 of
        keyword_set(add): bout.d=b1.d +b2.d
        keyword_set(sub): bout.d=b1.d -b2.d
        keyword_set(mul): bout.d=b1.d *b2.d
        keyword_set(div): bout.d=b1.d /b2.d
    	endcase
		bout.h=b1.h
		return,bout
	endif
;
;  b1=b2 same size but keyword /norm set..
;  so normalize each b2 spectra before operation
;
	if nump1 gt 1 then begin
		case 1 of
		keyword_set(add): begin
    		for irec=0,nrec1-1 do $
				for idmp=0,ndump1-1 do $
					for ipol=0,npol1-1 do $
			bout[irec].d[*,ipol,idmp]=b1[irec].d[*,ipol,idmp] $
					+ b2[irec].d[*,ipol,idmp]/mean(b2[irec].d[*,ipol,idmp])
		end
		keyword_set(sub): begin
            for irec=0,nrec1-1 do $
                for idmp=0,ndump1-1 do $
                    for ipol=0,npol1-1 do $
            bout[irec].d[*,ipol,idmp]=b1[irec].d[*,ipol,idmp] $
                    - b2[irec].d[*,ipol,idmp]/mean(b2[irec].d[*,ipol,idmp])
        end
		keyword_set(mul): begin
            for irec=0,nrec1-1 do $
                for idmp=0,ndump1-1 do $
                    for ipol=0,npol1-1 do $
            bout[irec].d[*,ipol,idmp]=b1[irec].d[*,ipol,idmp] $
                    * (b2[irec].d[*,ipol,idmp]/mean(b2[irec].d[*,ipol,idmp]))
        end
		keyword_set(div): begin
            for irec=0,nrec1-1 do $
                for idmp=0,ndump1-1 do $
                    for ipol=0,npol1-1 do $
            bout[irec].d[*,ipol,idmp]=b1[irec].d[*,ipol,idmp] $
                    / (b2[irec].d[*,ipol,idmp]/mean(b2[irec].d[*,ipol,idmp]))
        end
		endcase
		bout.h=b1.h
	endif else begin
		 case 1 of
        keyword_set(add): begin
            for irec=0,nrec1-1 do $
                    for ipol=0,npol1-1 do $
            bout[irec].d[*,ipol]=b1[irec].d[*,ipol] $
                    + b2[irec].d[*,ipol]/mean(b2[irec].d[*,ipol])
        end
        keyword_set(sub): begin
            for irec=0,nrec1-1 do $
                    for ipol=0,npol1-1 do $
            bout[irec].d[*,ipol]=b1[irec].d[*,ipol] $
                    - b2[irec].d[*,ipol]/mean(b2[irec].d[*,ipol])
        end
        keyword_set(mul): begin
            for irec=0,nrec1-1 do $
                    for ipol=0,npol1-1 do $
            bout[irec].d[*,ipol]=b1[irec].d[*,ipol] $
                    * (b2[irec].d[*,ipol]/mean(b2[irec].d[*,ipol]))
        end
        keyword_set(div): begin
            for irec=0,nrec1-1 do $
                    for ipol=0,npol1-1 do $
            bout[irec].d[*,ipol]=b1[irec].d[*,ipol] $
                    / (b2[irec].d[*,ipol]/mean(b2[irec].d[*,ipol]))
        end
        endcase
		bout.h=b1.h
	endelse
	return,bout
end
; ----------------------------------------------------------------
;   make the bout array.. 
function mkbout,b,ndump,nrecsout,avg=avg,double=double

	TYPE_FLOAT=4
	TYPE_DOUBLE=5
	ndumpL=ndump
	nrecsoutL=nrecsout
	sz=size(b[0])
	Dtype=sz[n_elements(sz)-1]
	if keyword_set(avg) then begin
		ndumpL=1
	    nrecsoutL=1
		if (not keyword_set(double)) then float=1
	endif
	return,masmkstruct(b[0],ndump=ndumpL,nelm=nrecsOutL,float=float,double=double)
end
; ----------------------------------------------------------------
function masmath,b1,b2,sub=sub,add=add,div=div,mul=mul,avg=avg,median=median,polAvg=polAvg,$
                sadd=sadd,ssub=ssub,sdiv=sdiv,smul=smul,norm=norm,mask=mask,$
				double=double
;
	maxpol=4
;   for size.
;    on_error,2
    nparams=n_params()
    nrecs1=n_elements(b1)
	npol1=b1[0].npol
	nrecsOut=nrecs1
	ndump1= b1[0].ndump
	nchan1=b1[0].nchan
    if nparams gt 1 then begin
		nrecs2=n_elements(b2)
		npol2 =b2[0].npol
	    ndump2=b2[0].ndump
	endif
;   ----------------------------------------------------------------------
;   see if they want averaging
;
	if (keyword_set(avg) or keyword_set(median) or keyword_set(polAvg) ) then begin
	   return,doavg(b1,nparams,median=median,double=double,polavg=polavg)
	endif
;   ----------------------------------------------------------------------
;   see if they want a scaler operation
;
    case 1 of 
   		(n_elements(ssub) ne 0): return,doscaler(b1,ssub,/sub,double=double)
   		(n_elements(sadd) ne 0): return,doscaler(b1,sadd,/add,double=double)
   		(n_elements(smul) ne 0): return,doscaler(b1,smul,/mul,double=double)
   		(n_elements(sdiv) ne 0): return,doscaler(b1,sdiv,/div,double=double)
		else: 
	endcase
;   ----------------------------------------------------------------------
; 	see if they want a vector op
;
    case 1 of 
        keyword_set(sub):return,dovec(b1,b2,nparams,/sub,double=double,norm=norm)
        keyword_set(add):return,dovec(b1,b2,nparams,/add,double=double,norm=norm)
        keyword_set(mul):return,dovec(b1,b2,nparams,/mul,double=double,norm=norm)
        keyword_set(div):return,dovec(b1,b2,nparams,/div,double=double,norm=norm)
		else: 
	endcase
;
;   ----------------------------------------------------------------------
; 	they wanted just norm on b1
;
	if keyword_set(norm) then return,donorm(b1,nparams,double=double)
;
; 	error nothing specified
;
    message,'masmath did not specify operation to perform'
    return,''
end
