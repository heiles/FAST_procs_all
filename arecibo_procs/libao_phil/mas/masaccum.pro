;+
;NAME:
;masaccum - accumulate an array of buffers
;SYNTAX: naccum=masaccum(bIn,baccum,avg=avg,scl=scl,new=new,mb=mb)
;ARGS:
;   bIn[n]: {}   stuctures to accumulate
;KEYWORDS: 
;     avg:      if set then average when done 
;  scl[n]:      if provided then  scale the bIn data by scl before
;                adding. This can be used to weight data by g/t.
;                scl can be a single number (then every spectra is 
;                    scaled by this
;                scl[n]: then every entry of bIn is scaled by its own
;                value.
;                if /mb is used then scl can be dim 1 or dim baccum[]
;                (which equals the first dim of Bin).
;                Note that polA,B of one bIn[i] always get the same scale
;                value.
;      mb:      if set then bIn[nbm,nrecs] is a multi beam array. The 1st
;               dimension is the number of beams, the 2nd dimension are the
;               records to accumulate. In this case baccum[nbm] and
;               only the 2nd dimension of bIn is accumulated.
;     new:      if set then allocate baccum. This is the first call
;               if not set then baccum passed in will be added to.
;   double:     if set then make accum array double. needs to be used
;               when /new is called.
;RETURNS:
;  naccum: > 0 number of accumulatins  we accumulated in baccum (this does
;              not include scl).
;       : 0   none summed
; baccum[nbm]: {}   the accumulated spectra
;
; 	The overflow status bits inf baccum.b.st will hold the max
;overflow count for the records that were included in the accumulation.
;
;DESCRIPTION:
;  Accumulate 1 or more records worth of data into baccum. If keyword
;/new is set then allocate baccum before adding. The header values in
;baccum will come from the first record added into baccum.
;
;   Each element of bin[i] will be added to baccum with the following weights:
;1. If scl= is not defined, it defaults to 1.
;2. if binp[i].b1.accum is 0., it is set to 1.
;3. if binp[i].b1.accum is < 0 it is multplied by -1.
;   (This happens after masavg has been called on an accumlated bacccum.
;    It divides by bacccum.b1.accum and then sets badd.b1.accum to its negative.)
;4  sclFact= binp[i].b1.d*scl*binp[i].b1.accum
;5. badd.b1.d+=sclFact*binp[i].b1.d
;6. badd.b1.accum+=sclFact
;
;   When masplot is called, it will scale the data by 1./badd.b1.accum. before
;plotting.
;   When calling masaccum with the new keyword, you can include the
;/mb keyword. This will allocate baccum to be the same dimension as
;the first dimension of binp. All future calls using baccum will add binp element 
;wise to baccum. This can be used when accumulating multiple maps.
;   Accumulated data must be of the same type (numlags, numbsbc, bw,etc..).
;
;Example:
;
;   print,masget(lun,b)
;   masaccum,b,badd,/new
;   print,masget(lun,b)
;   coraccum,b,badd
;   masplot,badd
;
;; Add n scans together element wise:
;  for i=0,n-1 do begin
;       print,masgetfile(lun,b)
;       masaccum,b,bsum,new=(i eq 0),/array
;  endfor
;;
;; input an entire scan and then plot the average of the records
;; (this can also be done directly by masgetfile).
;   print,masgetfile(lun,b,scan=scan)
;   masaccum,b,bsum,/new
;   masplot,bsum
;;
;-
function masaccum,bIn,bacc,mb=mb,new=new,avg=avg,double=double
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
    if keyword_set(mb) then begin
        if (szIn[0] eq 1 )then begin
			mbDim=ndim1
			recsToAdd=1
		endif else begin
			mbDim=ndim1
			recsToAdd=ndim2
		endelse
        usemb=1
    endif else begin
    	for i=1,ndimIn do recsToAdd*=szIn[i];
	endelse
    usedouble=keyword_set(double)
	usefloat=(usedouble)?0:1
    if keyword_set(new) then begin
;
;       create a single element
;
		bacc=masmkstruct(bin[0],ndump=1,double=usedouble,float=usefloat)
		bacc.d=(keyword_set(double))?0d:0.
;
;   now create the array to hold the results
;
        if (usemb) then begin
            bacc=replicate(bacc,mbDim)
			ii=lindgen(mbDim)
            bacc.h=bIn[ii].h
            bacc.st=bIn[ii].st[0]
        endif
    endif else begin
;
;		if the input has been averaged, blow it back up
;
		for i=0,n_elements(bacc)-1 do begin
			if (bacc[i].accum lt 0.) then begin
				bacc[i].accum*=-1.
                bacc[i].d*=bacc[i].accum 
			endif
		endfor
	endelse
    if (nchan ne bacc[0].nchan) $
       or (bIn[0].npol  ne bacc[0].npol)  then begin
        print,"nchan,npol of input buf doesn't match values from accum buf"
        return,-1
    endif
;
;	setup scale
;
	nscl=n_elements(scl)
	if nscl gt 1 then begin
		if usemb and (nscl ne mbDim) then begin
			print,"for /mb dim of scl = 1, or length mb:",mbdim
			return,-1
		endif else begin
			if nscl ne recsToAdd then begin
				print,"dim of scl = 1, or length of Bin:",recstoadd
				return,-1
			endif
		endelse
		lscl=scl
	endif else begin
		val=(nscl eq 0)?1.:scl
		lscl=(usemb)?fltarr(mbdim)+val:fltarr(recstoadd)+val
	endelse
    dumpRec=bIn[0].ndump
    if (not usemb) then begin
    	if npol eq 1 then begin
			for i=0,recsToAdd-1 do begin
;               if bin.accum < 0 --> avged, multiply back up
;               if bin.accum != 0 then need to increase output scale by this for accum
				sclIn=(bin[i].accum ne 0.)?abs(bin[i].accum):1.
				sclIn1=(bin[i].accum lt 0.)?sclIn:1.
        		bacc.d+=total(reform(bin[i].d,nchan,dumpRec),2,double=usedouble)*(lscl[i]*sclIn1)
			    bacc.accum+=lscl[i]*sclIn*dumpRec
			endfor
        endif else begin 
			for i=0,recsToAdd-1 do begin
				sclIn=(bin[i].accum ne 0.)?abs(bin[i].accum):1.
				sclIn1=(bin[i].accum lt 0.)?sclIn:1.
        		bacc.d+=total(reform(bin[i].d,nchan,npol,dumprec),3,double=usedouble)*(lscl[i]*sclIn1)
			    bacc.accum+=lscl[i]*dumpRec*sclIn
			endfor
        endelse
		bacc.st.ADCOVERFLOW=max(bin.st.adcoverflow) > bacc.st.ADCOVERFLOW
        bacc.st.PFBOVERFLOW=max(bin.st.pfboverflow)>bacc.st.PFBOVERFLOW
        bacc.st.satcntvshift=max(bin.st.satcntVshift)>bacc.st.satcntvshift
        bacc.st.satcntaccs2s3=max(bin.st.satcntaccs2s3) > $
									  bacc.st.satcntaccs2s3
        bacc.st.satcntaccs0s1=max(bin.st.satcntaccs0s1) > $
            						  bacc.st.satcntaccs0s1
        bacc.st.satcntashfts2s3=max(bin.st.satcntashfts2s3) > $
            							bacc.st.satcntashfts2s3
        bacc.st.satcntashfts0s1=max(bin.st.satcntashfts0s1) >$
										 bacc.st.satcntashfts0s1
    endif else begin
		jj=recsToAdd
    	for i=0,mbDim-1 do begin
			for j=0,recsToAdd-1 do begin
				sclIn=(bin[i,j].accum ne 0.)?abs(bin[i,j].accum):1.
				sclIn1=(bin[i,j].accum lt 0.)?sclIn:1.
        		if npol eq 1 then begin
               		bacc[i].d+= total(reform(bin[i,j].d,nchan,dumpRec),2, double=usedouble)*$
						   (lscl[i]*sclIn1)
				endif else begin
                	bacc[i].d+=total(reform(bin[i,j].d,nchan,npol,dumpRec),3, double=usedouble)*$
						   (lscl[i]*sclIn1)
				endelse
			   bacc[i].accum+=(lscl[i]*dumpRec*sclIn)
			endfor
			bacc[i].st.ADCOVERFLOW=max(bin[i,*].st.adcoverflow) > $
			 							bacc[i].st.ADCOVERFLOW
            bacc[i].st.PFBOVERFLOW=max(bin[i,*].st.pfboverflow) >$
             							bacc[i].st.PFBOVERFLOW
            bacc[i].st.satcntvshift=max(bin[i,*].st.satcntVshift) >$
             							 bacc[i].st.satcntvshift
            bacc[i].st.satcntaccs2s3=max(bin[i,*].st.satcntaccs2s3) > $
             							  bacc[i].st.satcntaccs2s3
            bacc[i].st.satcntaccs0s1=max(bin[i,*].st.satcntaccs0s1) > $
             							  bacc[i].st.satcntaccs0s1
            bacc[i].st.satcntashfts2s3=max(bin[i,*].st.satcntashfts2s3) > $
             								bacc[i].st.satcntashfts2s3
            bacc[i].st.satcntashfts0s1=max(bin[i,*].st.satcntashfts0s1) > $
             							    bacc[i].st.satcntashfts0s1
         endfor
    endelse
    if keyword_set(avg) then begin
        for i=0,n_elements(bacc)-1 do begin
            scl=(bacc[i].accum le 0.)?1.:1./bacc[i].accum
            bacc[i].d*=scl
            bacc[i].accum=(bacc[i].accum gt 0.)?-bacc[i].accum:bacc[i].accum
        endfor
    endif
    return,dumprec*recstoAdd
end
