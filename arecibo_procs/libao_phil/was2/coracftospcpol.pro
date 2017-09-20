;+
;NAME:
;coracftospcpol - convert acf to spectra for polarization data.
;
;SYNTAX: istat=coracftospcpol(acf,spc)
;
;ARGS:
;   acf[m]: {corget}    array of corget structures hold acf data (from the
;                       wapps).
;RETURNS:
;   spc[m]: {corget}    array of corget structures holding computed
;                       specra.
;
;DESCRIPTION:
;   
;   Convert acfs to spectra for polarization data taken on the wapps.
;You can pass in a single or an array of corget records.
;
;The processing is:
;1. The wapp data has already had the bias removed and it has been
;   normalized to the number of multiplies.
;2. Do the 3 level correction  (this does not yet work for 9 level data).
;   Use the routine cor3lvlstokes in the gen/ directory.
;3. compute the spectra for the auto correlations and the cross correlation.
;4. compute spc[].ibrd.d[*,0]= I  = (polA + polB)/ (pwrA+pwrB)
;           spc[].ibrd.d[*,1]= Q  = (polA - polB)/ (pwrA+pwrB)
;           spc[].ibrd.d[*,2]= U  = real(ccfSpectra)/sqrt(pwrA*pwrB)
;           spc[].ibrd.d[*,3]= V  = -img(ccfSpectra)/sqrt(pwrA*pwrB)
;  where ibrd is b1,b2,b3, or b4.
;          
;   The spectra are normalized to the total power (I). To convert back to
;power units use the lag0pwrratios[2] in the header
;
;    spc.[].ibrd.h.cor.lag0pwrratio[2]  [0] is polA power, [1] is polB
; power in units of Optimum/Measured power.
;-
; 19may08 - if band flipped also have to flip the sign of V
function coracftospcpol,acfIn,spc
;
    ADS_OPTM_3LEV=.6115059D
    nbrds=n_tags(acfIn[0])
    nrecs=n_elements(acfIn)
    spc=acfIn
    bias=0.D
    for ibrd=0,nbrds-1 do begin &$
        nlags=acfIn[0].(ibrd).h.cor.lagsbcout
        fftscl=(2.*(2.*nlags))
        fftsclC=2.      ; complex scale needed to get cal correct
        spc.(ibrd).d=cor3lvlstokes(acfIn.(ibrd).d,nlags,bias,nrecs,$
                            double=double,ads=ads) &$
;
;   store the power levels
;
        pwrA=1./reform(ads[0,*])^2
        pwrB=1./reform(ads[1,*])^2
        pwrAB=1./reform(ads[0,*]*ads[1,*])
        pwrNorm=pwrA+pwrB
        pwrA=pwrA/pwrNorm
        pwrB=pwrB/pwrNorm
        pwrAB=pwrAB/pwrNorm
;
        pwrratio=((ADS_OPTM_3LEV)/ads)^2 
;
;   Scaling:
;       bias - remove the bias.. its been removed for wapp data
;       2     since zero extended .. only for acf's
;       2*nlags  (scaling of fft)length used .. only for reverse xform
;       divide lag0 to normalize to zero lag .. done by 3level correction.
;       pwrratio - It comes back normalized to unity (divide by zero lag).
;       y[0]=y[0]*.5 since factor of two above was for non zero lags
;              only for the acf, ccf had no zero extend
;
;   now loop computing the spectra 
;
        tempBuf =fltarr(nlags*2L)       ;   for zero extending
        tempBufC=tempBuf                ; for complex transform
;
;      pol data does not have this.. 
;
        spc.(ibrd).h.cor.lag0pwrratio=(ADS_OPTM_3LEV/ads)^2

        for irec=0,nrecs-1 do begin
;
;           the auto correlations
;
            tempBuf[0:nlags-1]=spc[irec].(ibrd).d[*,0]*(fftscl*pwrA[irec])
            tempBuf[0]= tempBuf[0]*.5
            spcAA=(float(fft(tempBuf)))[0:nlags-1L]
            tempBuf[0:nlags-1]=spc[irec].(ibrd).d[*,1]*(fftscl*pwrB[irec])
            tempBuf[0]= tempBuf[0]*.5
            spcBB=(float(fft(tempBuf)))[0:nlags-1L]

;
;   the cross correlations
;   fill with [ba  , , reverse(ab[1:nlags)]
;   center point is the average of the ba,ab last points.
;
;  fft(x,1) is the reverse transform with no scaling.
;
            tempBufC[0:nlags-1]=spc[irec].(ibrd).d[*,3]
            tempBufC[nlags+1:*]=reverse(spc[irec].(ibrd).d[1:*,2]) ;
            tempBufC[nlags]=(spc[irec].(ibrd).d[nlags-1,3] + $
                             spc[irec].(ibrd).d[nlags-1,2])*.5
            spcC           =(fft(tempBufC,1 ))[0:nlags-1]*fftsclC


            flipped=((spc[irec].(ibrd).h.cor.state and '0x00100000'XUL) ne 0)
            if flipped then begin
                spc[irec].(ibrd).d[*,0]=reverse(spcAA+spcBB) ; I
                spc[irec].(ibrd).d[*,1]=reverse(spcAA-spcBB) ; Q
                spc[irec].(ibrd).d[*,2]=reverse(float(spcC)) *(pwrAB[irec]) 
;               if flipped then sign of V switches
                spc[irec].(ibrd).d[*,3]=reverse(imaginary(spcC))*(pwrAB[irec])
            endif else begin
                spc[irec].(ibrd).d[*,0]=spcAA+spcBB ; I
                spc[irec].(ibrd).d[*,1]=spcAA-spcBB ; Q
                spc[irec].(ibrd).d[*,2]=float(spcC) *(pwrAB[irec]) 
                spc[irec].(ibrd).d[*,3]=-imaginary(spcC)*(pwrAB[irec])
            endelse
        endfor
    endfor
    return,nrecs
end
