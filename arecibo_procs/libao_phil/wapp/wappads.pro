;+
;NAME:
;wappads - compute alpha/sigma for 3, 9 level sampling
;SYNTAX: wappads,lag0,bias,level9,ads,pwrratio 
;                       han=han)
;ARGS:
;  lag0[n:  float   lag 0 values (bias already removed).
;  bias  :  float   bias value
; level9 :  int     true if 9 level
;RETURNS:
;  ads[n]:  float   alpha/sigma (dig threshold / rms voltage)
;pwrratio[n]: float   optimumPower/(measured power)
;
;DESCRIPTION:
;   compute digitizerthreshold/signalVoltage for 3 or 9 level 
;samples wapp data. Also return the ratio of the measured
;power to the optimum power. 
;   The 0 lags should already have had the bias removed.
;
;-
;history:
; 21apr04 - 3 level ads include multiply by sqrt(2)
;           instead of *.5 in pwrratio.
pro wappads,lag0,bias,level9,ads,pwrratio
;     
;
;   some constants that belong in an include file
;
    ADS_OPTM_3LEV=.6115059D
    ADS_OPTM_9LEV=.266916
    n=n_elements(lag0)
;
;------------------------------------------------------------------------
; 9 level:
;
;
; Terminology:
;  alpha - digitizer threshold for 0 to 1 transition on 9 level sampling.
;  sigma - the rms voltage
;  x1    - this is alpha/sigma (or alpha expressed in units of sigma).
;  r0    - the 0 lag measured with the 9 level sampling. It the bias has been
;          removed, and it is normalized to the integration time.
;          It can take on values from 0 to 16
;  r0d16  -r0/16 .. this is what is passed in. it can take on values 0 .. 1
;           To get this value from the correlator, you must combine the
;           4 correlator chips and scale:
;            bias = integrationClock*.5  (since last bit not read out)
;            bias16=bias*16     (9 + 2*3 + 1 == 16)
;            r0d16=( 9*hi + 3(hl+lh) + ll - bias16)/bias16
;  rho    - this is the multibit lag0 after correction.
; optimumVal- this is the value of alpha/sigma that gives the best statistics
;              .266916.
;
;Compute alpha divided by sigma for 9 level correlator data given the
;normalized 9 level zero lag (r0d16).
;
;r0 can take on values from 0 to 16. There are 3 equations that can
;be used:
;  0 < r0 < 1, 1<=r0<=7.9, r0>7.9
;
;The routine
;
;On return  alpha/sigma computed is returned as well as
; (alpha/sigma)optimum  /  (alpha/sigma)measured. For a fixed alpha (
;which the digitizers have this is proportional to
; sigmaMeasured/sigma(optimum).
;
;The equation comes from a memo from MURRAY lewis  data
;5. 30jan97 (x1/sigma) as a function of r0
;
    if  level9 then begin
        ads=fltarr(n)
        lag0L=(bias eq 0.D)? lag0*16.D: lag0/bias * 16.D
;    
;   don't blow up around 0 or 16
;
        ind=where(lag0L lt 1e-3,count)
        if (count gt 0) then  lag0L[ind]=1e-3
        ind=where(lag0L gt 16.,count)
        if (count gt 0)  then  lag0L[ind]=16.
;  
;   1<= r0 <= 7.9
; 
        ind=where((lag0L ge 1.  ) and (lag0L le 7.9),count)
        if count gt 0 then begin
            ads[ind]=      .31605042           + $
                           .25071109/lag0L[ind] + $
               lag0L[ind]*(-.04820257           + $
               lag0L[ind]*( .00420818           + $
               lag0L[ind]*(-.00019467           ))) 
        endif
; 
;     *  r0 < 1
;
        ind=where((lag0L lt 1.  ),count)
        if count gt 0 then begin
            ads[ind]=         1.53758489             + $
                               .04495581/lag0L[ind]  + $
                 lag0L[ind]*(-3.02707342             + $
                 lag0L[ind]*( 3.52699656             + $
                 lag0L[ind]*(-1.97708732             + $
                 lag0L[ind]*(  .41972065        )))) 
        endif
        ind=where((lag0L gt 7.9 ),count)
        if (count gt 0) then begin
            ads[ind]=              .35745688         + $
                 lag0L[ind]*( -.03848164         + $
                 lag0L[ind]*(  .00156769         + $
                 lag0L[ind]*( -.00003496        ))) 
        endif
        pwrratio= (ADS_OPTM_9LEV/ads)^2
    endif else begin


;------------------------------------------------------------------------
;   3 level
;
        nzeros=(bias ne 0.D) ? (1.D - lag0/bias):1.D - lag0 ;# of 0's for invErf
        ads= inverf(nzeros)*sqrt(2D) ; digThrehold/sigma
        pwrratio=((ADS_OPTM_3LEV)/ads)^2 ;
    endelse
    return
end
