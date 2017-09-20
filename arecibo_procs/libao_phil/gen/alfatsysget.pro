;+
;NAME:
;alfatsysget - return alfa Tsys for the requested positions
;
;SYNTAX: stat=alfatsysget(az,za,freqMhz,rotAngle,tsysValAr,date=date,fitI=fitI,
;                         fname=fname)
;
;ARGS:
;      az[n]: float azimuth in degrees
;      za[n]: float zenith angle in degrees
; freqMhz[n]: float freq in Mhz.
;rotAngle[n]: float rotation angle of alfa in degrees.
;
;KEYWORDS:
; date[2]: int   [year,daynumber] to use for gain computation. The default
;                is to use the current day. If the Tsys curves change
;                with time, this allows you to access the curve that
;                was in use when the data was taken.
; fname:  string alternate file holding fit coefficients.
;RETURNS:
; tsysValAr[2,7,n]: float tsys for the 2pols, 7 pixels and n positions in Kelvins
; fitI[2,7]     : {alfatsysfitI} optionanly return the fit information (see alfatsysgetdat for
;                                a description of the structure).
;    stat: int   -1 --> error, no data returned
;                 1 --> data returned ok 
;
;DESCRIPTION:
;   Return the system temperature (K) for the 2*7 pols*pixels of alfa using a 
;model of az,za,rotation Angle, and frequency. The date keyword allows you
;to access a tsys curve that was valid at some other epoch (the default is the
;most recent curve). If the input variables are an array of dimension N then
;the retured data will be an array of Tsys(2,7,N)
;
;   Fits have been done for Tsys(az,za,freq,rotationAngle). This routine will 
;input the fit information (calling alfatsysinpdata) and then compute the Tsys for the 
;given input parameters.
;   The input fit data is stored in a common block so the data does not have to
;be input from disc on any succeeding calls.
;
;NOTE:
;   For a description of the Tsys fits see:
;http://www.naic.edu/~phil/mbeam/Tsys/Fits/fittingTsys.html  .
;
;EXAMPLES:
;
;;  1 value at az,za,rotangle,freq
;   az=180.
;   za=15.
;   rotAngle=19.
;   freq=1385.
;   stat=alfatsysget(az,za,freq,rotAngle,tsysVal)
;;
;;  18 values at za 2 thru 19 in 1deg steps, az=180,freq=1385.
;
;   n=18
;   az=fltarr(n) + 180.
;   za=findgen(n)+2            ; za=2..19
;   rotA=fltarr(n) + 19.
;   freq=fltarr(n) + 1385.
;   stat=alfatsysget(az,za,freq,rotA,tsysVal)
;   
;SEE ALSO:alfatsysinpdata
;-
function alfatsysget,az,za,freqMhz,rotA,tsysvalAr,date=date,fitI=fitI,$
			fname=fname
;
; return the Tsy value for alfa given az,za,freq,rotation angle
; retstat: -1 error, ge 0 ok
;
    forward_function alfatsysinpdata,dmtodayno,alfatsysfiteval
    common cmalfatsysdata,tfitI
     
    n=n_elements(az)
    if ( (n_elements(za) ne n      ) or $
         (n_elements(freqMhz) ne n ) or $
         (n_elements(rotA)    ne n )) then begin
            print,'The input parameters must all have the same number of dimensions'
            return,-1
    endif
    rdfile=(n_elements(tfitI) eq 0 )
    if n_elements(date) eq 2 then begin
        year  =date[0]
        dayNum=date[1]
    endif else begin
        a=bin_date()
        year  =a[0]
        dayNum=dmtodayno(a[2],a[1],a[0])
    endelse
    if (not rdfile) then begin
           if ((tfitI[0].startYr  gt year) or $
               (tfitI[0].endYr    gt year) or $

               ((tfitI[0].startYr eq year) and $
                (tfitI[0].startDaynum gt dayNum)) or $

               ((tfitI[0].endYr eq year) and $
                (tfitI[0].endDaynum le dayNum)) ) then rdfile=1
    endif
    if (rdfile) then begin
        datel=[year,dayNum]
        if  alfatsysinpdata(tfitI,date=datel,fname=fname) lt 1 then return,-1
    endif
;
;    now compute the values for the requested number of points pixels
;
    frqGhz=freqMhz*.001
    tsysValAr=fltarr(14,n)
    for i=0,13  do tsysvalar[i,*]=alfatsysfiteval(tfitI[i].fittype,az,za,frqGhz,rota,$
            tfitI[i].coef)
    tsysvalar=(n eq 1) ?reform(tsysvalar,2,7):reform(tsysvalar,2,7,n)
    if arg_present(fiti) then fiti=tfitI
    return,1
end
