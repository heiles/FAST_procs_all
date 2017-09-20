;+
;NAME:
;corstat - compute mean,rms by sbc 
; 
;SYNTAX    : corstat=corstat(b,mask=mask,/print,/median)
;
;ARGS      :   
;      b[n]: {corget} correlator data
;KEYWORDS  :   
;      mask: {cormask}  Compute mean, rms within mask (see cormask).
;     print:            If set then output info to stdout.
;    median:            If set then use median rather than the mean.
;RETURNS   :
;corstat[n]: {corstat} stat info
;
;DESCRIPTION:
;   corstat computes the mean and rms by sbc for a correlator dataset. The
;input data b can be a single {corget} structure or an array of {corget}
;structures. The mean,avg will be computed for each record of b[n]. If
;a mask is provided then the mean and average will be computed within the
;non-zero elements of the mask (see cormask()). The same mask will be used
;for all records in b[n].
;   The returned data structure corstat consists of:
;  corstat.avg[2,8] the averages
;  corstat.rms[2,8] the rms's
;  corstat.fracMask[8]  fraction of the bandpass that the mask covered.
;                   a single mask is used for each board. 
;  corstat.p[2,8]   This will contain a 1 if pola, 2 if polB and 0 if this
;                   entry is not used.
;EXAMPLES:
;   Process a position switch scan then compute the rms and mean using a mask
;that the user defines.
;   istat=corposonoff(lun,b,t,cals,/sclcal,scan=scan)
;   cormask,b,mask
;   cstat=corstat(b,mask=mask,/print)
;-
;history:
;16may05  - if pol mode return the 4 polarization values. Use 
;           corstatp structure rather than corstat.
;           r
function corstat,b,mask=mask,print=print,median=median
; 
;    on_error,2
    useStk=b[0].b1.h.cor.numsbcout eq 4
    useMask=keyword_set(mask)
    nrecs=n_elements(b)
    nbrds=n_tags(b)
    count=0
    if useStk then begin
        cstat=(nrecs eq 1)?{corstatp}:replicate({corstatp},nrecs)
    endif else begin
        cstat=(nrecs eq 1)?{corstat}:replicate({corstat},nrecs)
    endelse
;
;   loop over boards
;
    for ibrd=0,nbrds-1 do begin
        nlags=b[0].(ibrd).h.cor.lagsbcout
        nsbc =b[0].(ibrd).h.cor.numsbcout
;
;   loop over sbc of board
;  j=ipol
;  i=ibrdf
;  k=irec
;
        countAvg=0.
        if not useMask then begin
            ind=lindgen(nlags)
            countAVg=nlags
        endif
        for ipol=0,nsbc-1 do begin
            if useMask then begin
                ind=(nsbc eq 1)?where(mask.(ibrd) ne 0.,count): $
                            where(mask.(ibrd)[*,ipol] ne 0.,count) 
                countAvg=countAvg + count
            endif else begin
				count=nlags
		    endelse
            if ipol gt 1 then begin
                cstat.p[ipol,ibrd]=ipol+1
            endif else begin
                cstat.p[ipol,ibrd]=b[0].(ibrd).p[ipol]
            endelse
            for irec=0,nrecs-1 do begin
                if (count eq 0) then begin
                   a=[0.,1]
                endif else begin
                  if (nsbc eq 1) then begin
                      a=rms(b[irec].(ibrd).d[ind,ipol],/quiet)
                      if keyword_set(median) then a[0]=$            
                            median(b[irec].(ibrd).d[ind])
                  endif else begin
                    a=rms(b[irec].(ibrd).d[ind,ipol],/quiet)
                    if keyword_set(median) then a[0]= $
                            median(b[irec].(ibrd).d[ind,ipol])
                  endelse
                endelse
                cstat[irec].avg[ipol,ibrd]=a[0]
                cstat[irec].rms[ipol,ibrd]=a[1]
            endfor
            cstat.fractmask[ibrd]=countAvg/nsbc
        endfor
    endfor
;
;avg1a avg1b avg2a avg2b avg3a avg3b avg4a avg4b
;sbc1a   sbcNA    rms2a rms2b rms3a rms3b rms4a rms4b
;avgnnn ddd.dddd ddd.dddd ddd.dddd ddd.dddd ddd.dddd ddd.dddd ddd.dddd ddd.dddd
;rmsnnn ddd.dddd ddd.dddd ddd.dddd ddd.dddd ddd.dddd ddd.dddd ddd.dddd ddd.dddd
    npol=lonarr(nbrds)
    if keyword_set(print) then begin 
        polar=[' ','A','B']
        lab='       '
        labM='maskFraction of bandpass:'
        for ibrd=0,nbrds-1 do begin
            labM=labM + string(format='(f5.3," ")',cstat[0].fractMask[ibrd])
            for ipol=0,1 do begin
                pol=polar[b[0].(ibrd).p[ipol]]
                if pol ne ' ' then begin
                    lab=lab+ string(format='("  brd",i1,A1,"  ")',ibrd+1,pol)
                    npol[ibrd]++
                endif else begin
                    lab=lab + ' '
                endelse
            endfor
        endfor
        print,labM
        print,lab
        for irec=0,nrecs-1 do begin
            labavg=string(format='("avg",i3," ")',irec+1)
            labrms=string(format='("rms",i3," ")',irec+1)
            for ibrd=0,nbrds-1 do begin
                labavg+=string(format='(2(f9.4))',$
                        cstat[irec].avg[0:npol[ibrd]-1,ibrd])
                labrms+=string(format='(2(f9.4))',$
                        cstat[irec].rms[0:npol[ibrd]-1,ibrd])
            endfor
            print,labavg
            print,labrms
        endfor
    endif
    return,cstat 
end
