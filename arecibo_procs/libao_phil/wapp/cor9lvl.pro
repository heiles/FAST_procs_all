;+
;NAME:
;cor9lvl - 9 level correct acf's
;SYNTAX: acfCor=cor9lvl(acfinp,nlags,nacfs,bias,double=double,ads=ads)
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
;*DESCRIPTION
;*Compute the 9 level correction a la murray lewis 14feb97 memo.
;*The high/low acfs should have already been combined and the bias removed
;*including the divide by 16..
;*
;*Murray computed his corrections without removing the factor of 16. so
;*i but it back in then take it out again so the data remains
;*.2 for optimum value.
;*
;*The resolution is float. The coeff are done as doubles then moved to
;*a float array. eventually things will probably be changed to double.
;*
;*Note
;*   Murrays fits only work for correlation up to 39/40 (normalized to unity).
;*In particular if you plug the zero lag in, it comes out to be 1.02 instead
;*of unity.
;*
;-
function cor9lvl,acf,nlags,nacfs,bias,double=double,ads=ads,pwrratio=pwrratio
;
;   
    forward_function cmpC1ToC5
    if keyword_set(double) then begin
        one=1.D
        biasL=double(bias)
    endif else begin
        one=1.
        biasL=float(bias)
    endelse

    acfret=keyword_set(double)?dblarr(nlags,nacfs):fltarr(nlags,nacfs)
    normalize=(biasL eq 0.)?one:one/biasL
    lag0=(acf[0,*]-biasL)*normalize
    wappads,lag0,biasL,1,ads,pwrratio
    for isbc=0,nacfs-1 do begin            ; loop over each sbc
        r0D      =acf[0,isbc]*16D ;     /* murray wants it 0 to 16*/
        c=keyword_set(double)?cmpC1ToC5(r0D):float(cmpC1ToC5(r0D))
        r=acf[1:*,isbc]*one/acf[0,isbc]
        acfRet[1:*,isbc]=r*(c[0] + r*(c[1] + r*(c[2] + r*(c[3] + r*c[4])))) 
        acfRet[0,isbc]=one
    endfor
    return,acfRet
end
;
; cmpC1ToC5 - compute coefficients for correction.
;
;ARGS:
;   r0  double  0 lag 0 to 16.
;RETURNS:
;   c[5] double coef..
;
function cmpC1ToC5,r0
;
; coeffients for compC1ToC5
; 
    c1= [$
        1.105842267D, -0.053258115D, 0.011830276D, -0.000916417D, 0.000033479D]
   c2_L=[$
        1.285303775D, -1.472216011D, 0.640885537D, -0.123486209D, 0.008817175D]
   c2_M=[$
        0.519701391D, -0.451046837D, 0.149153116D, -0.021957940D, 0.001212970D]
   c2_H=[$
        0.111705575D, -0.066425925D, 0.014844439D, -0.001369796D, 0.000044119D]
   c3_H=[$
        1.244495105D, -0.274900651D, 0.022660239D, -0.000760938D, -1.993790548D]
     c3=[$
        1.249032787D, 0.101951346D, -0.126743165D, 0.015221707D, -2.625961708D]
   c4_H=[$
        0.664003237D, -0.403651682D, 0.093057131D, -0.008831547D, 0.000291295D]
     c4=[$
        9.866677289D,-12.858153787D, 6.556692205D, -1.519871179D, 0.133591758D]
   c5_H=[$
        0.033076469D, -0.020621902D, 0.001428681D,  0.000033733D]
   c5_M=[$
       -1.475903733D,  1.158114934D,-0.311659264D,  0.028185170D]
   c5_L=[$
        5.284269565D, 6.571535249D, -2.897741312D, 0.443156543D]


    c=dblarr(5)
;   
;   c1 
;   
    c[0]= c1[0] + r0*(c1[1] + r0*(c1[2] + r0*(c1[3] + c1[4]*r0)));
;
;    c2 
;
    case 1 of
    r0 lt 2.1D : $
        c[1]= c2_L[0] + r0*(c2_L[1] + r0*(c2_L[2] + r0*(c2_L[3] + r0*c2_L[4])))
    r0 gt 4.5D  : $
        c[1]= c2_H[0] + r0*(c2_H[1] + r0*(c2_H[2] + r0*(c2_H[3] + r0*c2_H[4])))
    else       : $
        c[1]= c2_M[0] + r0*(c2_M[1] + r0*(c2_M[2] + r0*(c2_M[3] + r0*c2_M[4])))
    endcase
;
;    c3 
;   
    case 1 of 
    
    r0 gt 2.0D : $
        c[2]= c3_H[0] + r0*(c3_H[1] + r0*(c3_H[2] + r0*(c3_H[3]))) + c3_H[4]/r0
    else      : $
        c[2]= c3[0] + r0*(c3[1] + r0*(c3[2] + r0*(c3[3]))) + c3[4]/r0
    endcase
;
;    c4 
;   
    case 1 of 
    r0 gt 3.15D : $
        c[3]= c4_H[0] + r0*(c4_H[1] + r0*(c4_H[2] + r0*(c4_H[3] + c4_H[4]*r0)))
    else       : $
        c[3]= c4[0] + r0*(c4[1] + r0*(c4[2] + r0*(c4[3] + c4[4]*r0)))
    endcase
;
;    c5 
;   
    case 1 of
    r0 gt 2.2D: $
        c[4]= c5_L[0] + r0*(c5_L[1] + r0*(c5_L[2] + r0*(c5_L[3])))
    r0 gt 4.0D: $
        c[4]= c5_H[0] + r0*(c5_H[1] + r0*(c5_H[2] + r0*(c5_H[3])))
    else      : $
        c[4]= c5_M[0] + r0*(c5_M[1] + r0*(c5_M[2] + r0*(c5_M[3])))
    endcase
    return,c
end
