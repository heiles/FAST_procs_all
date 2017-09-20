;+
;NAME:
;masrms - compute rms/Mean  by channel
;SYNTAX: brms=masrms(bin,rembase=rembase,nodiv=nodiv)
;ARGS:  
;  bin[] : {masget} array of masget structures
;KEYWORDS:     
;rembase :          If set then remove a linear baseline (by channel) before
;                   computing the rms.
;nodiv  :           If set then don't divide by the mean values of each chan.
;RETURNS:
;       brms : {masget} where brms.bN.d[] is now the rms/mean by channel.
;DESCRIPTION
;   The program will compute the rms/mean for each frequency channel. If the
;/nodiv keyword is set then the rms is not divided by the channel mean (so
;you can then see the size of the rms in spectrometer counts). The rembase
;keyword will remove a linear baseline in each channel before computing
;the rms.
;   The input data (bin) can be a single row element with multiple dumps per
;row or it can be an array of row elements (with one or more dumps per row).
;There must be at least 5 number per channel for the rms computation.
;-
; history
; 07nov08 - stole from corrms
function masrms,bin,rembase=rembase,nodiv=nodiv
;
;    on_error,2
    nodivL=keyword_set(nodiv)
    npol=bin[0].npol
    ndump=bin[0].ndump
    lensbc=bin[0].nchan
    n1 = n_elements(bin)
    npnts=n1*ndump
    if npnts lt 3 then begin
        print,'Not enough pnts to compute rms..'
        return,''
    endif
    ident=fltarr(npnts)+1.
    if keyword_set(rembase) then x=findgen(npnts)
    if ndump gt 0 then begin
		bout=masmkstruct(bin[0],ndump=1,/float)
		bout.accum=bin[0].accum
;             get max for overflows	    
	    bout.st.ADCOVERFLOW=max(bin.st.adcoverflow)
		bout.st.PFBOVERFLOW=max(bin.st.pfboverflow)
		bout.st.satcntvshift=max(bin.st.satcntVshift)
		bout.st.satcntaccs2s3=max(bin.st.satcntaccs2s3)
		bout.st.satcntaccs0s1=max(bin.st.satcntaccs0s1)
		bout.st.satcntashfts2s3=max(bin.st.satcntashfts2s3)
		bout.st.satcntashfts0s1=max(bin.st.satcntashfts0s1)
    endif else begin
        bout=bin[0]
    endelse

	fftaccumStd=max(bin.st.fftaccum)*1.
	fftAccumAr=reform(bin.st.fftaccum,npnts)
	blankCorDone=bin[0].blankCorDone
	if blankCorDone then begin
		nblank=0L
	endif else begin
		iiblnk=where(fftAccumAr ne fftaccumStd,nblank)
	endelse
    stkMode=npol gt 2
    for ipol=0,npol-1 do begin
        dloc=''
        if ndump gt 1 then begin 
			if npol eq 1 then begin
            	dloc=transpose(reform(bin.d[*,*],lensbc,npnts))
			endif else begin
            	dloc=transpose(reform(bin.d[*,ipol,*],lensbc,npnts))
			endelse
        endif else begin
            dloc=transpose(reform(bin.d[*,ipol],lensbc,npnts))
        endelse
        if (nblank gt 0)  then begin
			for iblnk=0,nblank-1 do dloc[iiblnk[iblnk],*]*=$
					fftaccumStd/fftAccumAr[iiblnk[iblnk]]
		endif
        if not keyword_set(rembase) then begin
;
;           compute mean,sdev for 1 sbc in 1 shot(hope we have enough mem)
;
            Mean=total(dloc,1,/double)/(npnts*1.)   ; avg over N time points
            sdev=sqrt(total((dloc - (ident#Mean))^2,1,/double)/(npnts -1.0))
            if (stkMode) then begin
                case 1 of 
                ipol eq 0: begin
                    meanBp=mean
                    bout.d[*,ipol]=(nodivL)?sdev:sdev/Mean   
                    end
                ipol eq 1: begin
                    meanBp=sqrt(meanBp*mean)
                    bout.d[*,ipol]=(nodivL)?sdev:sdev/Mean   
                    end
                ipol gt 1: begin
                    bout.d[*,ipol]=(nodivL)?sdev:sdev/MeanBp   
                    end
                endcase
            endif else begin
                bout.d[*,ipol]=(nodivL)?sdev: sdev/Mean
            endelse
        endif else begin
            if (ipol eq 0) then meanBp=fltarr(lensbc) 
            svBp=(ipol eq 0) or (not stkMode)
            for k=0,lensbc-1 do begin
                aa=poly_fit(x,dloc[*,k],1,yfit,status=status)
                if (status eq 1) or (status eq 3) then begin
                    bout.d[*,ipol]=0.        ; bad values
                endif else begin
                    a=(dloc[*,k]/yfit)*(yfit[npnts/2])
                    mean=total(a)/(npnts*1.)
                    if svBp then meanBp[k]=mean
                    sdev=sqrt(total((a- meanBp[k])^2)/(npnts-1.))
                    bout.d[k,ipol]=(nodivL)?sdev:sdev/meanBp[k]
                endelse
            endfor
        endelse
        if (check_math() ne 0) then begin
            ind=where(finite(bout.d[*,ipol]) eq 0,count)
            if (count gt 0) then bout.d[ind,ipol]=0.
        endif
    endfor
	bout.blankCorDone=1
    return,bout
end
