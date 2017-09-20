;+
;NAME:
;cor3lvlstokes - to 3 level correction for stokes data
;SYNTAX: acfCor=cor3lvlstokes(acfIn,nlags,bias,ntodo,double=double,ads=ads
;ARGS:
;   acfIn[nlags,4,ntodo]:      uncorrected acf's
;   nlags: int      number of lags in each auto or cross correlation.
;   ntodo: int      number of sets of aa,bb,ab,ba to do.
;KEYWORDS:
;   double:         if set then do computation in double precision 
;RETURNS:
;   acfcor[nlags,4,ntodo]: float/double corrected correlation functions
;   ads[2,ntodo]: float/double   digThreshold/sigma for the auto correlations.
;DESCRIPTION:
;   3 level correct the auto and cross correlations. The data should
; be ordered AA[nlags],BB[nlags],ab[nlags],ba[nlags] 
;NOTE!!! THIS IS STILL BEING TESTED...
;-
function cor3lvlstokes,acfin,nlags,bias,ntodo,double=double,ads=ads
;
;   
    if keyword_set(double) then begin
        one=1.D
        pi=!dpi
        pid2=pi/2.D
        p5=one/2D
    endif else begin
        one=1.
        pi=!pi
        pid2=pi/2.
        p5=one/2.
    endelse
    acfin=reform(acfin,nlags,4L,ntodo,/overwrite)
;
;   grab 0 lags, compute alpha/sigma
;   these are dimensioned [2,ntodo]
;
    normalize = (bias eq 0.)? one: one/(bias)
    lag0      = (reform(acfin[0,0:1,*])-bias*one)*normalize
    if ntodo eq 1 then lag0=reform(lag0,2,1)
    minLag0   = ( lag0[0,*] < lag0[1,*])        ; use smaller of 2 lag0's
    nzeros    = (one - lag0)
    ads       = reform(inverf(nzeros),2,ntodo)*sqrt(2D)    ; digThrehold/sigma
; 
;   
    ads2 = ads*ads                                    ;square of alpha/sigma
    a = piD2 * exp(ads2) 
    b = (a * (1. - ads2)) & b = b*b/6.
    c = pi * exp( p5*ads2) 
;   print,"ads[0]",ads[0]
;   print,"a",a
;   print,"b",b
;   print,"c",c
;
;   the cross cor variables
;   these are all dimensioned [ntodo]
;
    ax= piD2 * exp(p5*(ads2[0,*]+ads2[1,*]))    
    bx= ax*ax*(one - ads2[0,*])*(one-ads2[1,*])/6.
    gamma2=p5*(ads2[0,*]+ads2[1,*])
    gamma =sqrt(gamma2)
    epsilon=sqrt( (ads[0,*]-ads[1,*])^2/(2.*gamma2)) 
    delta  =(gamma*exp( -p5*gamma2)*epsilon)/(4.*sqrt(pi))
    beta   = pi*exp(p5*gamma2)

    acfC=(acfin - bias)*normalize
;
;   loop over number of sets to do
;
    for i=0L,ntodo- 1 do begin
;
;   loop over two acf this group
;
        for j=0,1 do begin
          temp= acfC[*,j,i]
          acfC[*,j,i]= a[j,i]*temp*(1. - b[j,i]*temp*temp);
          ind=where(abs(acfC[*,j,i]) gt  .86,count)
          if count gt 0 then begin
              acfC[ind,j,i]= cos(c[j,i]*(lag0[j,i]-abs(temp[ind])));
              ii=where(temp[ind] lt 0.,count1)
              if count1 gt 0 then acfC[ind[ii],j,i]= -acfC[ind[ii],j,i]
          endif
        endfor
;
;   now the two cross correlations
;
        for j=2,3 do begin
              temp=  acfC[*,j,i]            ; save normalized value
              acfC[*,j,i]= ax[i]*temp*(one - bx[i]*temp*temp) 
              ind=where(abs(acfC[*,j,i]) gt  .86,count)
              if count gt 0 then begin
                rho=(minLag0[i] - temp[ind]) + delta[i]
                acfC[ind,j,i]= cos(beta[i]*rho)
                ii=where(temp[ind] lt 0.,count1)
                if count1 gt 0 then acfC[ind[ii],j,i]= -acfC[ind[ii],j,i]
              endif
        endfor
    endfor
    return,acfC
end
