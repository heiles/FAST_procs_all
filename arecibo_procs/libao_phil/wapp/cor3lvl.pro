;+
;NAME:
;cor3lvl - 3 level correct acf's
;SYNTAX: acfCor=cor3lvl(acfinp,nlags,nacfs,bias,double=double,ads=ads)
;
;ARGS:
;acfinp[nlags,nacfs] float  acf's to correct.
;   nlags:  long    number of lags each acf
;   nacfs:  long    number of acfs to process
;   bias :  float   bias to remove and scale by.
;KEYWORDS:
;  double:          if set then process in double precision
;
; RETURNS:
;   acfCor[nlags,nacfs]: float  3 level corrected acfs. The 0 lags are
;                   normalized to unity.
;ads[nacfs]:float   alpha/sigma computed for each acf.
;
;DESCRIPTION:
;   Perform the 3 level correction and return the corrected data in acfCor.
;The user inputs the raw acfs, the number of lags for each acf, the number of
;acfs, and the bias. If more than one acf is input, they must all have
;the same number of lags, bias, etc.. The clippinglevel/sigma is
;returned (for each acf) in ads. 
;
;   The routine does the following:
;1. remove the bias and divide by the bias
;2. compute the clippingLevel/sigma using the number of zeros
;   and the inverse error function.
;3. perform the 3 level correction using the algorithm of
;   kulkarni and heiles astron. J. 85(10) oct 1980.
;4. The acfs are returned with the 0 lag normalized to unity. The
;   power info can be found in ads^2.
;
;-
function cor3lvl,inp,nlags,nacf,bias,double=double,ads=ads
;
;   
    if keyword_set(double) then begin
        one=1.D
        pi=!dpi
        pid2=pi/2.D
    endif else begin
        one=1.
        pi=!pi
        pid2=pi/2.
    endelse
    normalize=(bias eq 0.)?one:one/bias
    lag0      =(inp[0,*]-bias*one)*normalize
    nzeros    =one - lag0 ; # of 0's for invErf
    ads       = inverf(nzeros)*sqrt(2.*one) ; digThrehold/sigma
; 
;   acf=reform(acf,nlags,npol,nsamples,/overwrite)
    ads2 = ads*ads;                 /* square of alpha/sigma*/
    a = piD2 * exp(ads2);
    b = (a * (1. - ads2)); 
    b = b*b/6.;
    c = pi * exp( ads2/2.);
    acfC=(inp - bias)*normalize
    for i=0L,nacf - 1 do begin
          temp= acfC[*,i]
          acfC[*,i]= a[i]*temp*(1. - b[i]*temp*temp);
          ind=where(abs(acfC[*,i]) gt  .86,count)
          if count gt 0 then begin
              acfC[ind,i]= cos(c[i]*(lag0[i]-abs(temp[ind])));
              ii=where(temp[ind] lt 0.,count1)
              if count1 gt 0 then acfC[ind[ii],i]= -acfC[ind[ii],i]
          endif
    endfor
    acfC[0,*]=one
    return,acfC
end
