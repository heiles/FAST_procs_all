;+
;NAME:
;wappgetpol- input wapp data taken in polarization mode
;SYNTAX: istat=wappgetpol(lun,hdr,d,nrec=nrec,posrec=posrec,retpwr=retpwr,$
;               raw=raw,han=han,avg=avg,lvlcor=lvlcor)
;ARGS:
;   lun:    long      logical unit number for file to read
;   hdr:    {wapphdr} wapp header user passes in (see wappgethdr)
;  d[] :    float     return data here   
;
;KEYWORDS:
;   nrec:   long    number of time samples to input
; posrec:   long    position to this spectra before reading(count from 1) 
;                   if posrec is not supplied (or equals 0) then no 
;                   positioning is done.
; retpwr:           if set then just return total power (0lags)
;                   d[npol,nrecs] where npol is 1 or 2 (ignore crosspol)
;    raw:           just return the data read from disc, no processing
;    han:           if set then hanning window before transforming.
;    avg:           if set and nrec is greater than 1, then average the data 
;                   before returning. This is done in the time domain so
;                   it can speed up the processing (since fewer ffts needed)
;   lvlc:           If set then do the level correction for the lags
;                   (for now it only works for 3 level)
;RETURNS:
;   istat: > 0 number of recs found
;          -1 illegal lag format found
;
;DESCRIPTION:
;   Input wapp polarization  data from the logical unit number LUN. 
;The user must have already input the file header and stored it in the hdr
;variable (see wappgethdr). By default the routine will read from the current 
;position in the file. You can use the posrec keyword to position to a 
;particular record in the file. By default 1 record (integration)  of data
;will be input. You can input multiple records using the nrec keyword.
;
;   For each record requested the two acf's (pola,polb) followed by the
;2 cross correlations are input. The processing is:
;
; let d[nlags,4] be a time sample with:
;   0=polA,1=polB,2=polaxpolb, 3 polBxpolA (i'm not sure of the order of
;   that last two since it's done in the hardware .. i guess i could
;   check it...)
;
; 1. do the 3 level correction if requested. This should scale the acfs
;    so that the 0lag=1.
; 2. zero extend the acf's and do a forward transform to get the
;    spectra.
; 3. scale the normalized spectra (since acf was set to 1) so that the 
;    power units are measured/optimum power for the level sampling used
;    (This comes from the [1./(digThreshold/Sigma)]^2 you compute using
;    the inverse error function (at least for the 3 level case).
;
; 4. combine the cross correlations placing the first in the lower
;    nlags, and a flipped version of bxa in the upper nlags-1 (don't repeat
;    the first element). Interpolate the missing value.
; 5. compute the cross spectra. Scale it to (digThreshA/sigmaA)*
;    (digThreshB/sigmaB) . This is the product of Va*Vb in the units of the
;    spectra.
;
;   The  data is returned in the d array as float numbers. 
;It is dimensioned as d[nlags,4,nrecs] where nrecs are just the consecutive
;time samples. 
;
;EXAMPLES:
;   file='/share/wapp25/adleo.wapp2.52803.049'
;   openr,lun,file,/get_lun
;   istat=wappgethdr(lun,hdr)
;   nrec=wappgetpol(lun,d,nrec=50,/lvlcor)         ; read 50 records
;;  d is now dimensioned:  d[128,4,50]   
;
;NOTES:
;1. This only works for polarization data. For none pol data use wappget().
;2. It does not work correctly with lagtruncation.
;3. It is probably a good idea to do the level correction for
;   3 levels (i'm a little hazy on the scaling for the none level correction
;   case).
;4. No 9 level correction is supported (yet). The scaling factors for the
;   xspectra you get back in this case  should be checked.
;5. You might want to take a close look at the scaling of the
;   cross correlations. 
;   Be careful with file positioning. The following will cause problems:
;
; istat=wappgethdr(lun,hdr)             ok
; nrec=wappgetpol(lun,hdr,d,nrec=50)       ok
;
; rew,lun                               positioned at hdr not data..
;;  the line below returns bad data. It is positioned at the hdr, not
;;  the first record of data.
; nrec=wappgetpol(lun,hdr,d,nrec=50)       bad data returned.
;
; In the above case use:
; rew,lun
; nrec=wappgetpol(lun,hdr,d,nrec=50,posrec=1)
;-
;history
;10feb06 - started
; 
function wappgetpol,lun,hdr,d,nrec=nrec,posrec=posrec,retpwr=retpwr,raw=raw,$
                 han=han,avg=avg,lvlcor=lvlcor
;     
;
;   some constants that belong in an include file
;   ADS_OPTM_9LEV=.266916
;
    ADS_OPTM_3LEV=.6115059
    folding=hdr.obs_type_code eq 2
    search =hdr.obs_type_code eq 1
    deadTimeUsec=.34                ; wapp dead time on dump
    if n_elements(nrec) eq 0 then nrec=1
    doavg=( keyword_set(avg) and (nrec gt 1))
    if n_elements(retpwr) eq 0  then retpwr=0
    nlags=hdr.num_lags
    nifs=hdr.nifs
    if nifs ne 4 then begin
        print,'wappgetpol: File does not contain stokes data'
        return,-1
    endif
    nbrds  = (hdr.isalfa)? 2:1
    nifsBrds= nifs*nbrds
    cmpspc=1
    levels=(hdr.level eq 1)? 3:9
    hansmooth=keyword_set(han)
;
;   allocate the input array type depending on the lagformat
;   need to work on the shift ..
;
    case (hdr.lagformat and 7) of

        0: begin                ; unsigned int 16 bit
            inp=uintarr(nlags,nifsBrds*nrec)
            bytelen=2UL
           end

        1: begin                ; unsigned long 32 bit
            inp=ulonarr(nlags,nifsBrds*nrec)
            bytelen=4UL
           end

        2: begin                ; floats
             inp=fltarr(nlags,nifsBrds*nrec)
             bytelen=4UL
           end
        3: begin                ; unsigned long 32 bit
             inp=fltarr(nlags,nifsBrds*nrec)
             bytelen=4Ul
             cmpspc=0           ; already spectra
           end
        else: return,-1
    endcase
;
;   position in file: should really check the positioning..
;
    if keyword_set(posrec) then begin
        point_lun,lun,(hdr.byteOffData+ (posrec-1L)*bytelen*nlags*nifsBrds)
    endif
    point_lun,-lun,startpos  ; remember where we started    
;   
;   get the data
;
    on_ioerror,ioerr
    readu,lun,inp,transfer_count=nfound
ioerr: 
    recinp=nfound/(nifsBrds*nlags)
    if recinp ne nrec then begin
        point_lun,-lun,curpos
        byteInp = (curpos-startpos)
        if byteInp eq 0 then begin
            if eof(lun) then return,0
            return,-1
        endif
        recinp=byteInp/(nifsBrds*nlags*bytelen)
        point_lun,lun,startpos+(recinp*(nlags*nifsBrds)*bytelen)
        inp=inp[*,0:recinp*nifsBrds-1L]
    endif
;
;   recinp number of time inputs
;   stkinp number of sets of 4 sbc (twice recinp if alfa nbrds=2)
;
;   swap and average if needed
;
    if hdr.needswap then  inp=swap_endian(inp)
    if doavg then begin
        inp=total(reform(inp,nlags,nifsBrds,recinp),3)/recinp
        recinp=1
    endif
        
    if keyword_set(raw) then begin
        d=inp
        return,recinp
    endif
    stkinp=(nbrds eq 2)?recinp*2:recinp
;
;-------------------------------------------------------------------
; setups for wapp
;
; name:    level    numifs  stokes  bw   maxlags  sumPol  
; CH1LEV3   3       1         0     100  8192      0,1
; CH2LEV3   3       2         0     100  4096      0
; CH1LEV9   9       1         0     100  2048      0
; CH4LEV3P  3       4         1     100  2048      0
;
; CH1LEV3   3       1         0     50   16384     0,1
; CH2LEV3   3       2         0     50   8192      0
;
; CH1LEV9   9       1         0     50   4096      0,1
; CH2LEV9   9       2         0     50   2048      0
;
; CH4LEV3P  3       4         1     50   4096      0
; CH4LEV9P  9       4         1     50   4096      0
;-------------------------------------------------------------------
;    process the data.. 0 lag and then spectra
;
;  computing the bias..
;
;   The wapp clock is 100 Mhz. It always multiplies at this rate.
;   Lower bandwidths have a slower shift rate, but the multiply
;   rate is always 100 Mhz.
;
;   A 100 Mhz clock can give a max of 50Mhz bandwidth. For 100 Mhz
;   bandwidth you need to use interleaved mode. This ends up doubling
;   the bias since you combine two sets of correlations. oo,ee, eo,oe
;
;   The correlator does not read out the lowest bit of the accumulator
;   so we multiply by .5
;
;   If we sum polariztions, then the value increases by another factor
;   of 2.
;   If 9 level, then increase by 16.
;
    if retpwr or cmpspc then begin
        if search then begin ; search data
            bias=float(100. * (hdr.wapp_time-deadTimeUsec) * (hdr.sum+1.))*.5
        endif else begin        ; folded data, acf's
;
;   !!note if folded 9 level data has not been divided by 16. we need
;          to do it here..
            bias=0.D
        endelse
        if  hdr.bandwidth eq 100. then bias=bias*2.
        if  levels eq 9        then bias=bias*16.   
        if hansmooth then w=(hanning(nlags*2))[nlags:*]     
;
;       reform into sets of 4 sbc 2acf,2ccfo 
;
        inp=reform(inp,nlags,4,stkinp,/overwrite) 
;
;       get lag0's
;
        lag0=reform(inp[0,0:1,*],2,stkinp) - bias
;
;   -->NOTE: I think the  folded data acf's have been scaled to:
;           for each lag , phase bin that is added in
;           acf[i]= [acf[i] - bias ] / bias
;           at the end:
;           acf[i]=acf[i]/numTimesBinIncremented
;
;           It does not look like the 3 or 9 level correction is done
;           and the 9 level data is not divided by 16 (it probably should
;           be. A bias = 0 for 9level will work if the times 16 has been 
;           removed.
;
        if retpwr then begin
            wappads,lag0,bias,(levels eq 9),ads,pwrratio
            d=reform(pwrratio,2,stkinp)
            return,recinp
        endif
;
;       see if we do the 3 level correction 
;

        if (keyword_set(lvlcor) and (levels eq 3)) then begin
            inp=cor3lvlstokes(inp,nlags,bias,stkinp,ads=ads,/double)
            pwrratio=((ADS_OPTM_3LEV)/ads)^2 
            lag0=lag0*0. + 1;           ; cor3lv normalized it  to 1
            bias=0.                     ; it's been removed
        endif else begin
            wappads,lag0,bias,(levels eq 9),ads,pwrratio
        endelse
        pwrratio=reform(pwrratio,2,stkinp,/overwrite)
        d=fltarr(nlags,4,stkinp)
;
;           Scaling:
;               bias - remove the bias 
;               2     since zero extended
;               2*nlags  (scaling of fft)length used
;               divide lag0 to normalize to zero lag
;               pwrratio - to make it linear in power
;               y[0]=y[0]*.5 since factor of two above was for non zero lags
;                 
        fftscl=float(2.* (2.*nlags))/(lag0)*pwrratio ; fft scales by nlags, 
;
;        note: 1/ads[0,*] is proportional to voltage in A
;              the lag[0] is only needed if we didn't do the 3 level correction
;   
        Va=ADS_OPTM_3LEV/ads[0,*]
        Vb=ADS_OPTM_3LEV/ads[1,*]
;       ccfscl=(Va*Vb)/(Va*Va + Vb*Vb)/(sqrt(lag0[0,*]*lag0[1,*]))
        ccfscl=reform((Va*Vb)/(sqrt(lag0[0,*]*lag0[1,*])))
        tempBuf=fltarr(nlags*2)             ; this zeroextends
        for i=0L,stkinp-1 do begin
            for ipol=0,1 do begin
                if lag0[ipol,i] ne 0. then begin
                    if hansmooth then begin
                       tempBuf[0:nlags-1]=w*(inp[*,ipol,i]-bias)*fftscl[ipol,i]
                    endif else begin
                       tempBuf[0:nlags-1]=  (inp[*,ipol,i]-bias)*fftscl[ipol,i] 
                    endelse
                    tempBuf[0]=tempBuf[0]*.5    ; correct for factor 2 on 0lag
                    d[*,ipol,i]=(float(fft(tempBuf)))[0:nlags-1]
                endif else begin
                    d[*,ipol,i]=0.
                endelse
            endfor
;
;       now the cross spectra a x b bottom half
;                             b x a top half flipped
;       and ab[0]=ba[0] so only use it once. interpolate the missing point
;
            tempBuf[0:nlags-1]=inp[*,2,i]
            tempBuf[nlags+1:*]=reverse(inp[1:*,3,i])
            tempBuf[nlags]=(inp[nlags-1,2,i] + (inp[nlags-1,3,i]))*.5
            spcX=(fft(tempBuf-bias,1))[0:nlags-1]
            d[*,2,i]=float(spcX)*ccfscl[i]
            d[*,3,i]=-imaginary(spcX)*ccfscl[i]
        endfor
    endif

    if (stkinp gt 0) and ( not retpwr) then begin
       if stkinp eq 1 then begin
            d=reform(d,nlags,4,/overwrite)
        endif else begin
            d=reform(d,nlags,4,stkinp,/overwrite)
        endelse
    endif
    return,stkinp
end
